import CNodeAPI

public typealias ConstructorCallback = (Arguments) -> ValueConvertible

public class ConstructorCallbackData {
    var callback: ConstructorCallback
    init(_ callback: @escaping @convention(c) ConstructorCallback) {
        self.callback = callback
    }
}

public class Class: @unchecked Sendable {
    @MainActor private var value: napi_value?
    @MainActor private var name: String?
    public required init?(_ value: napi_value) throws {
        self.value = value
    }

    @MainActor public convenience init?(
        name: String, constructor: @escaping ConstructorCallback,
        properties: [NodePropertyDescriptor] = []
    ) throws {
        var result: napi_value?
        let nameData = name.data(using: .utf8)!
        let props = properties.map { $0.napi_property_descriptor }

        let data = ConstructorCallbackData(constructor)
        let dataPointer = Unmanaged.passRetained(data).toOpaque()

        let status = nameData.withUnsafeBytes { nameBytes in
            props.withUnsafeBufferPointer { propertiesBytes in
                napi_define_class(
                    NodeContext.context.env, nameBytes, nameData.count, swiftNAPICallback,
                    dataPointer,
                    properties.count, propertiesBytes.baseAddress, &result)
            }
        }
        print("Class 构造\(status)")
        guard let result: napi_value = result, status == napi_ok else {
            throw NodeError.status(status)
        }
        try self.init(result)
        self.name = name

    }

}
extension Class: @preconcurrency ValueConvertible {
    @MainActor public var nativeValue: NativeValue {
        .class(value, true)
    }

}
