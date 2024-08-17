import CNodeAPI
import NodeAPI

func hello(a: String) -> String {
    return "world" + a
}
func add(a: Int32, b: Int32) -> Int32 {
    return a + b
}

func initHelloWorld(env: OpaquePointer, exports: OpaquePointer) -> OpaquePointer? {
    //     PropertyDescriptor.function<Int32,Int32>("abc",{ (a:Int32,b:Int32) in
    // return add(a: a, b: b)
    //     }, attributes: napi_default)

    return initModule(
        env, exports,
        [
            .function("hello", hello)

        ])
}

func initCallback(env: OpaquePointer, exports: OpaquePointer) -> OpaquePointer? {

    let funcResult = try? Function(named: "funcHandler") { napi_env, Arguments in
        print("funcHandler=>>>\(napi_env) ===>\(Arguments)")
        return nil
    }.napiValue(env)
    return initHelloWorld(env: funcResult!, exports: exports)
}

@_cdecl("node_swift_register")
func initClass(env: OpaquePointer, exports: OpaquePointer) -> OpaquePointer? {

    let classResult = try! Class(
        named: "Person",
        { _, _ in
            return nil
        },
        [
            PropertyDescriptor.function(
                "hello",
                { a in
                    return hello(a: a)
                })
        ]
    ).napiValue(env)

    return classResult
}
