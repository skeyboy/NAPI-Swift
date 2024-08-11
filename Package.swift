// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport
import Foundation

let package = Package(
    name: "NAPI-Swift",
    platforms: [
        .macOS(.v10_15), .iOS(.v13),
    ],
    products: [
        .library(
            name: "NodeAPI",
            targets: ["NodeAPI"]),
        // the example
        .library(name: "HelloWorld", type: .dynamic, targets: ["HelloWorld"]),
    ],
    targets: [
        // use as the napi module register entry
        .target(name: "Trampoline", dependencies: ["CNodeAPI"]),
        .target(name: "HelloWorld",dependencies: ["NodeAPI", "Trampoline"]),
        .systemLibrary(name: "CNodeAPI"),
            .target(name: "CNodeAPISupport"),
        .target(name: "NodeModuleSupport", dependencies: ["CNodeAPI"]),
        .target(
            name: "NodeAPI", dependencies: ["CNodeAPI","CNodeAPISupport"]),
    ],
    cxxLanguageStandard: .cxx17

)
