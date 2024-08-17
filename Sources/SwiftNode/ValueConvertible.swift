import CNodeAPI
import Foundation

public protocol ValueConvertible: Sendable {
    init?(_ value: napi_value) async throws
    var nativeValue: NativeValue { get }
}

public func strictlyEquals(env: napi_env, lhs: napi_value, rhs: napi_value) throws
    -> Bool
{
    var isEqual = false
    let status = napi_strict_equals(
        env, lhs, rhs, &isEqual)
    guard status == napi_ok else { throw NodeError.status(status) }
    return isEqual
}

extension ValueConvertible {
    @MainActor public func strictlyEquals(to other: napi_value) throws -> Bool {
        guard let lhs = self.nativeValue.native else {
            throw NodeError.msg("\(self) native value is value")
        }
        return try SwiftNode.strictlyEquals(env: NodeContext.context.env, lhs: lhs, rhs: other)
    }
}

extension ValueConvertible {
    @MainActor var env: napi_env {
        NodeContext.context.env
    }
}

extension Optional: ValueConvertible where Wrapped: ValueConvertible {
    public init?(_ value: napi_value) async throws {
        guard let wrapped = try await Wrapped.init(value) else {
            throw NodeError.msg("init optional error")
        }
        self = .some(wrapped)
    }

    public var nativeValue: NativeValue {
        switch self {
        case .none:
            return .optional(nil, false)
        case .some(let value):
            return .optional(value.nativeValue.native, true)
        }
    }
}

// extension Dictionary: ValueConvertible, @unchecked Sendable
// where Value: NSObjectProtocol & Sendable, Key: ValueConvertible {

//     public init?(_ value: napi_value) async throws {
//         fatalError("No need")
//     }

//     public var nativeValue: NativeValue {

//     }

// }

extension Dictionary: @preconcurrency ValueConvertible, @unchecked Sendable
where Key: ValueConvertible, Value: ValueConvertible {
    public init?(_ value: napi_value) throws {
        fatalError("No need")
    }
    @MainActor public var nativeValue: NativeValue {

        var result: napi_value!

        var status = napi_create_object(NodeContext.context.env, &result)
        guard status == napi_ok else {
            return .dictionary(nil, false)
        }

        for (key, value) in self
        where key.nativeValue.isValided == true && value.nativeValue.isValided == true {
            status = napi_set_property(
                env, result, key.nativeValue.native, value.nativeValue.native)
            guard status == napi_ok else { return .dictionary(nil, false) }
        }
        return .dictionary(result, status == napi_ok)
    }
}

extension Array: @preconcurrency ValueConvertible where Element: ValueConvertible {
    public init?(_ value: napi_value) throws {
        fatalError("No need")
    }

    @MainActor public var nativeValue: NativeValue {
        var result: napi_value!
        var status = napi_create_array_with_length(
            NodeContext.context.env, self.count, &result)
        if status == napi_ok {
            for (index, element) in self.enumerated() where element.nativeValue.isValided {
                debugPrint("Array:\(index)=>\(element)")
                status = napi_set_element(env, result, UInt32(index), element.nativeValue.native)
                guard status == napi_ok else { return .array(nil, false) }
            }
            return .array(result, true)
        } else {
            return .array(nil, false)
        }
    }

}

extension String: @preconcurrency ValueConvertible, @unchecked Sendable {
    @MainActor public init?(_ value: napi_value) throws {
        var status: napi_status!
        var length: Int = 0

        let env = NodeContext.context.env
        status = napi_get_value_string_utf8(env, value, nil, 0, &length)
        guard status == napi_ok else { throw NodeError.msg("\(status)") }

        var data = Data(count: length + 1)

        status = data.withUnsafeMutableBytes {
            napi_get_value_string_utf8(env, value, $0, length + 1, &length)
        }
        guard status == napi_ok else { throw NodeError.msg("\(String(describing: status))") }
        self.init(data: data.dropLast(), encoding: .utf8)!

    }

    @MainActor public var nativeValue: NativeValue {
        var result: napi_value?
        let data = self.data(using: .utf8)!

        let status = data.withUnsafeBytes { (bytes: UnsafePointer<Int8>) in
            napi_create_string_utf8(NodeContext.context.env, bytes, data.count, &result)
        }
        print("\(NodeContext.context.env)====\(status)<====>\(result)")
        return .string(result, status == napi_ok)

    }
}

extension Double: @preconcurrency ValueConvertible, @unchecked Sendable {

    @MainActor public init?(_ value: napi_value) throws {
        var pValue: Double = .nan
        let status = napi_get_value_double(NodeContext.context.env, value, &pValue)
        if status != napi_ok {
            throw NodeError.msg("String")
        } else {
            self = pValue
        }
    }

    @MainActor public var nativeValue: NativeValue {
        var value: napi_value?
        let status = napi_create_double(env, self, &value)
        return .double(value, status == napi_ok)
    }
}

extension Bool: @preconcurrency ValueConvertible, @unchecked Sendable {

    @MainActor public init?(_ value: napi_value) throws {
        var pValue = false
        let status = napi_get_value_bool(NodeContext.context.env, value, &pValue)
        if status != napi_ok {
            throw NodeError.msg("String")
        } else {
            self = pValue
        }
    }

    @MainActor public var nativeValue: NativeValue {
        var value: napi_value?
        let status = napi_get_boolean(env, self, &value)
        return .boolean(value, status == napi_ok)
    }
}

extension ValueConvertible where Self == Bool {
    @MainActor public func value(
        name: String, attributes: NodePropertyDescriptor.Attribute = .default
    )
        -> NodePropertyDescriptor
    {
        NodePropertyDescriptor.value(
            name: name, value: self.nativeValue.native,
            attributes: attributes)

    }
}
