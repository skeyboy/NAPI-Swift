import CNodeAPI

public struct Null: @unchecked Sendable {
    private init() {}
    public static let null: Null = Null()
}

extension napi_value: @unchecked @retroactive Sendable {

}

extension Null: @preconcurrency ValueConvertible {
    @MainActor public init?(_ value: napi_value) throws {
        guard try Self.null.strictlyEquals(to: value) else {
            throw NodeError.msg("Expected null")
        }
    }

    @MainActor public var nativeValue: NativeValue {
        var result: napi_value?
        let status = napi_get_null(env, &result)
        return .null(result, status == napi_ok)
    }
}

extension Null: CustomDebugStringConvertible, CustomStringConvertible {
    public var debugDescription: String {
        "null"
    }
    public var description: String {
        "null"
    }
}

extension Null: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        true
    }
}
