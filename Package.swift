// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "UCLLIUSwift",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "FeimiCore", targets: ["FeimiCore"])
    ],
    targets: [
        .target(name: "FeimiCore"),
        .testTarget(name: "FeimiCoreTests", dependencies: ["FeimiCore"])
    ]
)
