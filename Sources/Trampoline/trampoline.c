#include "../CNodeAPI/vendored/node_api.h"

#warning use this to register entry, you can modify example to test @_cdecl("_init_hello_world") 
napi_value _init_hello_world(napi_env, napi_value);

NAPI_MODULE(hello_world, _init_hello_world)
