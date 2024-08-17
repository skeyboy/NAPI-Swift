var addon = require('./.build/release/HelloWorld.node')

console.log(addon)
console.log(addon.list)
let p = new addon();
p.hello()
console.log(JSON.stringify(addon), p, p.hello,p.hello())

while(true){

}