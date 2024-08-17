import SwiftNode

func add(a: Int32, b: Int32) -> Int32 {
    return a + b
}
func hello() -> String {
    "Hello =====>>>>>"
}
@_cdecl("node_swift_register")
@MainActor func initModule(env: OpaquePointer, exports: OpaquePointer) -> OpaquePointer {

    return try! NodeMoule.register(env, exports) {
        var value: [String: ValueConvertible] = [:]

        value["list"] = [1, 2, 4]
        value["other"] = ["name": "Jack", "other": "other"]
        value["null"] = Null.null
        value["optional"] = .some(5)
        value["helloFunc"] =
            try? Function.function(name: "hello") {
                hello()
            } as! any ValueConvertible
        // value["undefined"] = Undefined.undefined
        return value
    }
}
