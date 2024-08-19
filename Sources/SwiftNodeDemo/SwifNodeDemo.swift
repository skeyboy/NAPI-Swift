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
        value["person"] = try! Class.init(name: "Person") { _ in
            [
                "age": 2,
                "name": "JackLee",
                "option": Optional.some(233),
                "hi": try! Function.function(name: "hello") {
                    hello()
                } as any ValueConvertible,
            ]
        }
        // value["person"] = try! Class(
        //     name: "Person",
        //     constructor: { args in
        //         var value: [String: ValueConvertible] = [:]
        //         value["age"] = 32
        //         return value
        //         // return ["namw": "1", "age": 2]
        //     })
        value["list"] = [1, 2, 4]
        value["other"] = ["name": "Jack", "other": "other"]
        value["null"] = Null.null
        value["optional"] = .some(5)
        value["age"] = 32
        value["helloFunc"] =
            try! Function.function(name: "hello") {
                hello()
            } as any ValueConvertible
        value["undefined"] = Undefined.undefined
        return value
    }
}
