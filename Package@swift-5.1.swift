// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SYMoyaNetwork",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SYMoyaNetwork",
            targets: ["SYMoyaNetwork"]),
        .library(
            name: "SYMoyaReactiveHandyJSON",
            targets: ["SYMoyaReactiveHandyJSON"]),
        .library(
            name: "SYMoyaReactiveObjectMapper",
            targets: ["SYMoyaReactiveObjectMapper"]),
        .library(
            name: "SYMoyaHandyJSON",
            targets: ["SYMoyaHandyJSON"]),
        .library(
            name: "SYMoyaRxHandyJSON",
            targets: ["SYMoyaRxHandyJSON"]),
        .library(
            name: "SYMoyaRxObjectMapper",
            targets: ["SYMoyaRxObjectMapper"]),
        .library(
            name: "SYMoyaObjectMapper",
            targets: ["SYMoyaObjectMapper"]),
        .library(
            name: "ReactiveSYMoyaNetwork",
            targets: ["ReactiveSYMoyaNetwork"]),
        .library(
            name: "RxSYMoyaNetwork",
            targets: ["RxSYMoyaNetwork"])
    ],
    dependencies: [
       .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0")),
       .package(url: "https://github.com/tristanhimmelman/ObjectMapper.git", .upToNextMajor(from: "4.2.0")),
       .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .upToNextMajor(from: "5.0.0")),
       .package(url: "https://github.com/alibaba/HandyJSON.git", .upToNextMajor(from: "5.0.1")),
       .package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", from: "6.0.0"),
       .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.6.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SYMoyaNetwork",
            dependencies: [.product(name: "Moya", package: "Moya"),
                           .product(name: "SwiftyJSON", package: "SwiftyJSON")],
            exclude: [
                       "Supporting Files/Info.plist"
                     ]),
        .target(
            name: "SYMoyaReactiveHandyJSON",
            dependencies: ["SYMoyaHandyJSON",
                           .product(name: "ReactiveSwift", package: "ReactiveSwift")]),
        .target(
            name: "SYMoyaReactiveObjectMapper",
            dependencies: ["SYMoyaObjectMapper",
                           .product(name: "ReactiveSwift", package: "ReactiveSwift")]),
        .target(
            name: "SYMoyaHandyJSON",
            dependencies: ["SYMoyaNetwork",
                           .product(name: "HandyJSON", package: "HandyJSON")]),
        .target(
            name: "SYMoyaRxHandyJSON",
            dependencies: ["SYMoyaHandyJSON",
                           .product(name: "RxSwift", package: "RxSwift")]),
        .target(
            name: "SYMoyaRxObjectMapper",
            dependencies: ["SYMoyaObjectMapper",
                           .product(name: "RxSwift", package: "RxSwift")]),
        .target(
            name: "SYMoyaObjectMapper",
            dependencies: ["SYMoyaNetwork",
                           .product(name: "ObjectMapper", package: "ObjectMapper")]),
        .target(
            name: "ReactiveSYMoyaNetwork",
            dependencies: ["SYMoyaNetwork",
                           .product(name: "ReactiveSwift", package: "ReactiveSwift")]),
        .target(
            name: "RxSYMoyaNetwork",
            dependencies: ["SYMoyaNetwork",
                           .product(name: "RxSwift", package: "RxSwift")]),
        
        .testTarget(name: "SYMoyaNetworkTests",
                    dependencies: ["SYMoyaNetwork"])
    ],
    swiftLanguageVersions: [.vv5])
