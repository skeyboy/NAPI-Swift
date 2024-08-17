import CNodeAPI

public class NodeContext: @unchecked Sendable {
    @MainActor public private(set) var env: napi_env!
    @MainActor public static var env: napi_env = NodeContext.context.env
    @MainActor fileprivate init(_ value: napi_env? = nil) {
        self.env = value
    }
    @MainActor public static let context: NodeContext = .init(nil)
    @MainActor public static func register(env: napi_env) -> NodeContext {
        NodeContext.context.env = env
        return NodeContext.context
    }
}

public class NodeMoule {
    @MainActor private static func defineProperties(
        _ env: napi_env, object: napi_value, properties: () -> [String: ValueConvertible]
    ) throws -> napi_value {
        let props = properties().propertyDescriptors.map {
            item in
            return item.napi_property_descriptor
        }
        print("defineProperties ======> \(props)")
        let status = props.withUnsafeBufferPointer { propertiesBytes in
            napi_define_properties(env, object, props.count, propertiesBytes.baseAddress)
        }
        print("defineProperties ======> \(status)")

        guard status == napi_ok else {
            throw NodeError.status(status)
        }
        return object
    }
    @MainActor public static func register(
        _ env: napi_env, _ exports: napi_value, properties: () -> [String: any ValueConvertible]
    ) throws
        -> napi_value
    {
        _ = NodeContext.register(env: env)
        print("all properties to register:\(properties())")
        return try defineProperties(env, object: exports, properties: properties)
    }
}
