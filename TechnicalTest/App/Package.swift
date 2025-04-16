// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "App",
    platforms: [
        .iOS(.v18), // Specify iOS 18 as the minimum deployment target
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "App",
            targets: ["App"]
        ),
    ],
    dependencies: [
        // Add dependencies here
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.1")), // Or latest compatible version
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "7.11.0")), // Or latest compatible version
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "App",
            dependencies: [
                "Alamofire", // Add dependency to the target
                "Kingfisher", // Add dependency to the target
            ],
            path: "Sources/App", // Explicitly set the path for the App target sources
            resources: [ // Define resources to include in the bundle
                .process("Data"), // Process the Data directory (containing users.json)
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: ["App"],
            path: "Tests/AppTests" // Explicitly set the path for the test target sources
        ),
    ]
)
