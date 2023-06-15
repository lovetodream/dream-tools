// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "dream-tools",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "DreamTools", targets: [
            "DreamToolsCore", "DreamToolsMail", "DreamToolsMail"
        ]),
        .library(name: "DreamToolsCore", targets: ["DreamToolsCore"]),
        .library(name: "DreamToolsMail", targets: ["DreamToolsMail"]),
        .library(name: "DreamToolsJWT", targets: ["DreamToolsJWT"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.77.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.2.1"),
        .package(url: "https://github.com/Mikroservices/Smtp.git", from: "3.0.3"),
    ],
    targets: [
        .target(name: "DreamToolsCore"),
        .target(name: "DreamToolsMail", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Smtp", package: "Smtp"),
        ]),
        .target(name: "DreamToolsJWT", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "JWT", package: "jwt"),
        ]),
        .testTarget(name: "DreamToolsTests", dependencies: [
            "DreamToolsCore", "DreamToolsMail", "DreamToolsJWT"
        ]),
    ]
)
