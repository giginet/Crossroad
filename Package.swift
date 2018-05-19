import PackageDescription

let package = Package(
    name: "Crossroad",
    products: [
        .library(
            name: "Crossroad",
            targets: ["Crossroad"]),
    ],
    dependencies: [
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
