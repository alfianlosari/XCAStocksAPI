// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XCAStocksAPI",
    platforms: [.macOS(.v12), .iOS(.v13), .watchOS(.v8), .tvOS(.v13)],
    products: [
        .library(
            name: "XCAStocksAPI",
            targets: ["XCAStocksAPI"]),
        .executable(name: "XCAStocksExec",
                    targets: ["XCAStocksExec"])
    ],
    targets: [
        .target(
            name: "XCAStocksAPI",
            dependencies: []),
        .executableTarget(name: "XCAStocksExec",
                         dependencies: ["XCAStocksAPI"])
    ]
)
