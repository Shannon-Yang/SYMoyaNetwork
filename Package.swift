// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SYMoyaNetwork",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v6)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SYMoyaNetwork",
            targets: ["SYMoyaNetwork"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
       .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0")),
       .package(url: "https://github.com/tristanhimmelman/ObjectMapper.git", .upToNextMajor(from: "4.2.0")),
       .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .upToNextMajor(from: "5.0.0")),
       .package(url: "https://github.com/alibaba/HandyJSON.git", .upToNextMajor(from: "4.1.3"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SYMoyaNetwork",
            dependencies: ["Moya","ObjectMapper","SwiftyJSON","HandyJSON"],path: "Sources"),
        .testTarget(
            name: "SYMoyaNetworkTests",
            dependencies: ["SYMoyaNetwork"]),
    ]
)
