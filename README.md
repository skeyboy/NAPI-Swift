# NAPI-Swift
NAPI with swift for nodejs

**Example to show**
***Hello World***
cd HelloWorld then run npm install
```js
var addon = require('./.build/release/HelloWorld.node')

console.log(addon)
let p = new addon();
p.hello()
console.log(JSON.stringify(addon), p, p.hello,p.hello())

```

you can can **run npm postinstall** to build code, do **npm run test** to exp the result


**Notice**
@_cdecl("node_swift_register") will use some function as the node module regis entry


