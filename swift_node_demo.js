var addon = require('./.build/release/SwiftNodeDemo.node')

console.log(">>>>>>>>",addon.A, JSON.stringify(addon))
console.log(">>>>>>>",addon.list,addon.other, addon.null, addon.undefined, addon.optional)
console.log(">>>>>>>> helloFunc", addon.helloFunc, typeof addon.helloFunc , JSON.stringify(addon.helloFunc))
console.log(( addon.helloFunc))
