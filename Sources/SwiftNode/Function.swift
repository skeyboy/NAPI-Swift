import CNodeAPI

public typealias Arguments = (
    napi_value,
    napi_value,
    napi_value,
    napi_value,
    napi_value,
    napi_value,
    napi_value,
    napi_value,
    napi_value,
    napi_value,

    // Number of passed arguments
    length: Int,
    // The `this` value
    this: napi_value
)
public typealias FunctionCallback = (Arguments) -> (any ValueConvertible)?

public class FunctionCallbackData {
    var callback: FunctionCallback
    init(_ callback: @escaping @convention(c) FunctionCallback) {
        self.callback = callback
    }
}

public class Function: @preconcurrency ValueConvertible, @unchecked Sendable {
    @MainActor var name: String? = nil
    @MainActor private var isJSFunction: Bool = true
    @MainActor private var value: napi_value?
    @MainActor private var callback: FunctionCallback?

    ///  This is for js
    /// - Parameter value:
    /// - Throws:

    public required init?(_ value: napi_value) throws {
        self.value = value
    }

    ///  This is for native
    /// - Parameters:
    ///   - name: The function name
    ///   - callback:
    /// - Throws:

    @MainActor public convenience init(name: String, callback: @escaping FunctionCallback) throws {
        var result: napi_value?
        let nameData = name.data(using: .utf8)!
        let data = FunctionCallbackData(callback)
        let dataPointer = Unmanaged.passRetained(data).toOpaque()

        let status = nameData.withUnsafeBytes { nameBytes in
            napi_create_function(
                NodeContext.context.env, nameBytes, nameData.count, swiftNAPICallback, dataPointer,
                &result)
        }
        guard status == napi_ok, let value = result else { throw NodeError.status(status) }
        try self.init(value)!
        self.callback = callback
        self.name = name
        self.isJSFunction = false
    }

    @MainActor public static func function(
        name: String, _ callback: @escaping () -> (any ValueConvertible)?
    ) throws
        -> Function
    {
        return try Function(name: name) { _ in
            return callback()
        }  //.convertPropertyDescriptor(name: name)
    }

    @MainActor public var nativeValue: NativeValue {
        return .function(value, value != nil)
    }

    func apply(_ env: napi_env!, _ cbinfo: napi_callback_info!) {

    }
}

@_cdecl("swift_napi_callback")
func swiftNAPICallback(_ env: napi_env!, _ cbinfo: napi_callback_info!) -> napi_value? {
    var args:
        (
            napi_value?, napi_value?, napi_value?, napi_value?, napi_value?, napi_value?,
            napi_value?, napi_value?, napi_value?, napi_value?, length: Int, this: napi_value?
        ) = (nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 10, nil)
    let dataPointer: UnsafeMutablePointer<UnsafeMutableRawPointer?> = UnsafeMutablePointer<
        UnsafeMutableRawPointer?
    >.allocate(capacity: 1)
    napi_get_cb_info(env, cbinfo, &args.length, &args.0, &args.this, dataPointer)
    let data = Unmanaged<FunctionCallbackData>.fromOpaque(dataPointer.pointee!)
        .takeUnretainedValue()
    return data.callback(args as! Arguments)?.nativeValue.native

}

extension Function: PropertyDescriptorConvertible {

    @MainActor public func convertPropertyDescriptor(name: String)
        -> NodePropertyDescriptor
    {
        // propertyDescriptors[0]
        return NodePropertyDescriptor.method(name: name.nativeValue.native!) { env, info in
            return swiftNAPICallback(env, info)
        }
    }
    public var propertyDescriptors: [NodePropertyDescriptor] {
        [
            NodePropertyDescriptor.method(name: self.nativeValue.native!) { env, info in
                print("+++++++++++")
                return swiftNAPICallback(env, info)
            }
        ]
    }
}
