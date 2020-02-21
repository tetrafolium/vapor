// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Vapor",
    products: [
        .library(name: "Cache", targets: ["Cache"]),
        .library(name: "Configs", targets: ["Configs"]),
        .library(name: "Sessions", targets: ["Sessions"]),
        .library(name: "Testing", targets: ["Testing"]),
        .library(name: "Vapor", targets: ["Vapor"])
    ],
    dependencies: [
        // Swift implementation of the BCrypt password hashing function
        .package(url: "https://github.com/vapor/bcrypt.git", .upToNextMajor(from: "1.1.0")),

        // Console protocol and implementation for powering command line interface.
        .package(url: "https://github.com/vapor/console.git", .upToNextMajor(from: "2.2.0")),

        // Useful helpers and extensions
        .package(url: "https://github.com/vapor/core.git", .upToNextMajor(from: "2.1.2")),

        // Cryptographic digests and ciphers
        .package(url: "https://github.com/vapor/crypto.git", .upToNextMajor(from: "2.1.0")),

        // Core vapor transport layer
        .package(url: "https://github.com/vapor/engine.git", .upToNextMajor(from: "2.2.1")),

        // JSON enum wrapper around Foundation JSON
        .package(url: "https://github.com/vapor/json.git", .upToNextMajor(from: "2.1.0")),

        // Data mapper
        .package(url: "https://github.com/vapor/node.git", .upToNextMajor(from: "2.1.0")),
        
        // Parses `Content-Type: multipart` as defined in RFC 2046.
        .package(url: "https://github.com/vapor/multipart.git", .upToNextMajor(from: "2.1.0")),
        
        // A type safe routing package including HTTP and TypeSafe routers.
        .package(url: "https://github.com/vapor/routing.git", .upToNextMajor(from: "2.1.0"))
    ],
    targets: [
        .target(name: "Cache", dependencies: ["Node"]),
        .testTarget(name: "CacheTests", dependencies: ["Cache"]),
        .target(name: "Configs", dependencies: ["Core", "JSON"]),
        .testTarget(name: "ConfigsTests", dependencies: ["Configs"]),
        .target(name: "Sessions", dependencies: ["Cache", "Cookies", "Crypto", "HTTP"]),
        .testTarget(name: "SessionsTests", dependencies: ["Sessions"]),
        .target(name: "Testing", dependencies: ["Core", "HTTP", "Vapor"]),
        .testTarget(name: "TestingTests", dependencies: ["Testing"]),
        .target(name: "Vapor", dependencies: [
            "BCrypt", 
            "Cache", 
            "Configs", 
            "Console", 
            "FormData",
            "HTTP", 
            "JSON", 
            "Multipart", 
            "Node",
            "Routing", 
            "Sessions", 
            "SMTP",
            "WebSockets"
        ]),
        .testTarget(name: "VaporTests", dependencies: ["Vapor", "Testing"])
    ]
)
