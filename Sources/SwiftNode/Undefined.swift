import CNodeAPI

public struct Undefined: @unchecked Sendable {
    private init() {}
    public static let undefined: Undefined = Undefined.init()
}

extension Undefined: @preconcurrency ValueConvertible {
    @MainActor public init?(_ value: napi_value) throws {
        guard try Self.undefined.strictlyEquals(to: value) else {
            throw NodeError.msg("Expected null")
        }
    }

    @MainActor public var nativeValue: NativeValue {
        var result: napi_value?
        let status = napi_get_undefined(env, &result)
        return .undefined(result, status == napi_ok)
    }
}
