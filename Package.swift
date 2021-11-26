// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import class Foundation.ProcessInfo

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

if ProcessInfo.processInfo.environment["ENABLE_DOCC"] != nil {
    package.dependencies.append(
        .package(url: "https://github.com/apple/swift-docc.git",
                 .revision("swift-DEVELOPMENT-SNAPSHOT-2021-11-20-a"))
    )
}
