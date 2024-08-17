import CNodeAPI

public typealias NAPICallback = (_ env: napi_env?, _ info: napi_callback_info?) ->
    napi_value?
class CallbackData {
    let callback: NAPICallback

    init(callback: @escaping @convention(c) NAPICallback) {
        self.callback = { env, info in
            return callback(env, info)
        }
    }
}

public class NodePropertyDescriptor: @unchecked Sendable {
    public enum Attribute: UInt32 {
        case `default` = 0
        case writable = 1
        case enumerable = 2
        case configurable = 4
        case `static` = 100_000_000
        case `defaultMethod` = 5
        case `defaultJsProperty` = 7
        var nativeAttribute: napi_property_attributes {
            return napi_property_attributes.init(rawValue)
        }
    }

    var napi_property_descriptor: napi_property_descriptor
    @MainActor static func method(
        name: napi_value,
        callback: @escaping @convention(c) (_ env: napi_env?, _ info: napi_callback_info?) ->
            napi_value?,
        attributes: NodePropertyDescriptor.Attribute = .defaultJsProperty
    ) -> NodePropertyDescriptor {

        return .init(
            name: name,
            callback: callback,
            attributes: attributes)
    }

    @MainActor static func value(
        name: String,
        value: napi_value!,
        attributes: Attribute = .default
    ) -> NodePropertyDescriptor {
        return .init(
            name: name.nativeValue.native!,
            value: value,
            attributes: attributes)
    }

    @MainActor static func value(
        name: String,
        value: any ValueConvertible,
        attributes: Attribute = .default
    ) -> NodePropertyDescriptor {
        return Self.value(
            name: name,
            value: value.nativeValue.native!,
            attributes: attributes)
    }

    convenience init(
        name: napi_value,
        value: napi_value,
        attributes: NodePropertyDescriptor.Attribute = .defaultJsProperty
    ) {
        self.init(
            utf8name: nil,
            name: name,
            method: nil,
            getter: nil,
            setter: nil,
            value: value,
            data: nil)
    }

    convenience init(
        name: napi_value,
        callback: @escaping @convention(c) (_ env: napi_env?, _ info: napi_callback_info?) ->
            napi_value?,
        attributes: NodePropertyDescriptor.Attribute = .defaultJsProperty
    ) {

        let methodCallbackData: CallbackData = CallbackData(callback: callback)
        let methodCallbackDataPointer = Unmanaged.passRetained(methodCallbackData).toOpaque()
        self.init(
            utf8name: nil,
            name: name,
            method: callback,
            getter: nil,
            setter: nil,
            value: nil,
            data: methodCallbackDataPointer)
    }
    init(
        utf8name: String?,
        name: napi_value,
        method: napi_callback!,
        getter: napi_callback!,
        setter: napi_callback!,
        value: napi_value!,
        attributes: Attribute = .default,
        data: UnsafeMutableRawPointer!
    ) {
        self.napi_property_descriptor = CNodeAPI.napi_property_descriptor(
            utf8name: nil,
            name: name,
            method: method,
            getter: getter,
            setter: setter,
            value: value,
            attributes: attributes.nativeAttribute,
            data: data)

    }
}

public protocol PropertyDescriptorConvertible: Sendable {
    @MainActor func convertPropertyDescriptor(name: String)
        -> NodePropertyDescriptor
    @MainActor var propertyDescriptors: [NodePropertyDescriptor] { get }
}
extension PropertyDescriptorConvertible {
    @MainActor public func convertPropertyDescriptor(name: String)
        -> NodePropertyDescriptor
    {
        let pSelf = self as? (any ValueConvertible)
        return NodePropertyDescriptor.value(
            name: name,
            value: pSelf!.nativeValue.nativeValue.native!,
            attributes: NodePropertyDescriptor.Attribute.default)
    }
    @MainActor public var propertyDescriptors: [NodePropertyDescriptor] {
        []
    }
}

extension Bool: PropertyDescriptorConvertible {}
extension String: PropertyDescriptorConvertible {}
extension Double: PropertyDescriptorConvertible {}
extension Int32: PropertyDescriptorConvertible {}
extension [ValueConvertible]: PropertyDescriptorConvertible where Element == any ValueConvertible {

    public func convertPropertyDescriptor(name: String) -> NodePropertyDescriptor {
        let pSelf = self as? (any ValueConvertible)
        return NodePropertyDescriptor.value(
            name: name,
            value: pSelf!.nativeValue.native,
            attributes: NodePropertyDescriptor.Attribute.default)
    }

    public var propertyDescriptors: [NodePropertyDescriptor] {
        []
    }
}

extension [String: ValueConvertible]: PropertyDescriptorConvertible
where Value == any ValueConvertible, Key == String {
    public func convertPropertyDescriptor(name: String) -> NodePropertyDescriptor {
        let pSelf = self as? (any ValueConvertible)
        return NodePropertyDescriptor.value(
            name: name,
            value: pSelf!.nativeValue.native,
            attributes: NodePropertyDescriptor.Attribute.default)
    }

    @MainActor public var propertyDescriptors: [NodePropertyDescriptor] {
        var propertyDescriptors: [NodePropertyDescriptor] = []
        for (key, value) in self {
            print("converttoProperty \(key)====>\(value)")
            if let propertyDescriptor =
                (value as? PropertyDescriptorConvertible)?
                .convertPropertyDescriptor(
                    name: key)
            {
                propertyDescriptors.append(propertyDescriptor)
            } else {
                let propertyDescriptor: NodePropertyDescriptor = NodePropertyDescriptor.value(
                    name: key, value: value)
                propertyDescriptors.append(propertyDescriptor)
            }
        }

        return propertyDescriptors
    }
}
