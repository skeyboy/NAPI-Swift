// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import Foundation
import PackageDescription

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
        .target(name: "HelloWorld", dependencies: ["NodeAPI"]),
        .systemLibrary(name: "CNodeAPI"),
        .target(name: "CNodeAPISupport"),
        .target(name: "NodeModuleSupport", dependencies: ["CNodeAPI"]),
        .target(
            name: "NodeAPI", dependencies: ["CNodeAPI", "CNodeAPISupport", "NodeModuleSupport"]),
    ],
    cxxLanguageStandard: .cxx17

)
