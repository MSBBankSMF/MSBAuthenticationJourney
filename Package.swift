// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MSBAuthenticationJourney",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MSBAuthenticationJourney",
            targets: ["MSBAuthenticationJourney"]),
    ],
    dependencies: [
        .package(path: "../MSBCore"),
        .package(path: "../MSBCoreUI"),
        .package(path: "../MSBPublicLibs/Resolver"),
        .package(path: "../MSBPublicLibs/AppAuth"),
        .package(path: "../MSBPublicLibs/PluggableAppDelegate"),
        .package(path: "../MSBBackbase/Backbase"),
        .package(path: "../MSBBackbase/BackbaseSecureStorage"),
        .package(path: "../MSBBackbase/BackbaseCountryCore"),
        .package(path: "../MSBBackbase/BackbaseIdentity"),
        .package(path: "../MSBBackbase/BackbaseSDKSwiftWrapper"),
        .package(url: "https://github.com/CombineCommunity/CombineCocoa.git", from: "0.2.1"),
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MSBAuthenticationJourney",
            dependencies: [
                "MSBCore",
                .product(name: "MSBCoreUI", package: "MSBCoreUI"),
                .product(name: "MSBLogger", package: "MSBCore"),
                .product(name: "MSBNetworking", package: "MSBCore"),
                .product(name: "MSBUtilities", package: "MSBCore"),
                "Moya",
                "Resolver",
                "AppAuth",
                "PluggableAppDelegate",
                "CombineCocoa",
                "Backbase",
                "BackbaseSecureStorage",
                "BackbaseCountryCore",
                "BackbaseIdentity",
                "BackbaseSDKSwiftWrapper",
            ],
            resources: [
                .process("Resources") // Include the Config folder
            ]
        ),
        .testTarget(
            name: "MSBAuthenticationJourneyTests",
            dependencies: ["MSBAuthenticationJourney"]
        ),
    ]
)
