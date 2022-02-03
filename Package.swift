// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Crossroad",
    platforms: [.iOS(.v13),.tvOS(.v13)],
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
