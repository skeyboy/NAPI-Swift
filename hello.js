var addon = require('./.build/release/HelloWorld.node')

console.log(addon)
let p = new addon();
p.hello()
console.log(JSON.stringify(addon), p, p.hello,p.hello())

