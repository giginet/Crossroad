// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Crossroad",
    platforms: [.iOS(.v9),.tvOS(.v9)],
    products: [
        .library(
            name: "Crossroad",
            targets: ["Crossroad"]),
    ],
    targets: [
        .target(
            name: "Crossroad",
            dependencies: []),
        .testTarget(
            name: "CrossroadTests",
            dependencies: ["Crossroad"]),
    ]
)
