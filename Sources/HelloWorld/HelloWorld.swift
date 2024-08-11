import NodeAPI

func hello() -> String {
    return "world"
}


func initHelloWorld(env: OpaquePointer, exports: OpaquePointer) -> OpaquePointer? {
    return initModule(env, exports, [
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


@_cdecl("_init_hello_world")
func initClass(env: OpaquePointer, exports: OpaquePointer) -> OpaquePointer? {

    let classResult = try! Class(
        named: "Person",
        { _, _ in
            return nil
        },
        [
            PropertyDescriptor.function(
                "hello",
                {
                    return hello()
                })
        ]
    ).napiValue(env)

    return classResult
}

