import CNodeAPI

public enum NativeValue: ValueConvertible, @unchecked Sendable {

    public init?(_ value: napi_value) throws {
        fatalError("Can not call")
    }

    public var nativeValue: NativeValue {
        self
    }

    public var native: napi_value? {
        switch self {
        case .boolean(let value, _):
            return value
        case .string(let value, _):
            return value
        case .array(let value, _):
            return value
        case .dictionary(let value, _):
            return value
        case .double(let value, _):
            return value
        case .optional(let value, _):
            return value
        case .null(let value, _):
            return value
        case .undefined(let value, _):
            return value
        case .function(let value, _):
            return value
        }
    }

    public var isValided: Bool {
        switch self {
        case .boolean(_, let value):
            return value
        case .string(_, let value):
            return value
        case .array(_, let value):
            return value
        case .dictionary(_, let value):
            return value
        case .double(_, let value):
            return value
        case .optional(_, let value):
            return value
        case .null(_, let value):
            return value
        case .undefined(_, let value):
            return value
        case .function(_, let value):
            return value
        }
    }

    case boolean(napi_value?, Bool)
    case string(napi_value?, Bool)
    case array(napi_value?, Bool)
    case dictionary(napi_value?, Bool)
    case double(napi_value?, Bool)
    case optional(napi_value?, Bool)
    case null(napi_value?, Bool)
    case undefined(napi_value?, Bool)
    case function(napi_value?, Bool)

}
