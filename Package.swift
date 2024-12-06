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
        .package(path: "../../MSBCore"),
        .package(path: "../../MSBCoreUI"),
        .package(path: "../../PublicLib/SnapKit"),
        .package(path: "../../PublicLib/RxCocoa"),
        .package(path: "../../PublicLib/Resolver"),
        .package(path: "../../MSBBackbase/Backbase"),
        .package(path: "../../MSBBackbase/BackbaseCountryCore"),
        .package(path: "../../MSBBackbase/BackbaseIdentity"),
        .package(path: "../../MSBBackbase/BackbaseSDKSwiftWrapper"),
        .package(path: "../../MSBBackbase/BackbaseSecureStorage"),
        .package(url: "https://github.com/CombineCommunity/CombineCocoa.git", from: "0.2.1"),
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MSBAuthenticationJourney",
            dependencies: [
                .product(name: "MSBCoreUI", package: "MSBCoreUI"),
                .product(name: "MSBLogger", package: "MSBCore"),
                .product(name: "MSBFoundation", package: "MSBCore"),
                "Moya",
                "Resolver",
                "SnapKit",
                "CombineCocoa",
                "Backbase",
                "BackbaseCountryCore",
                "BackbaseIdentity",
                "BackbaseSDKSwiftWrapper",
                "BackbaseSecureStorage"
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
