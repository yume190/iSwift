// swift-tools-version:4.0
import PackageDescription

let dependencies:[Package.Dependency] = [
    .package(url: "https://github.com/Zewo/ZeroMQ.git", from: "1.0.0"),
    .package(url: "https://github.com/IBM-Swift/BlueCryptor.git", from: "1.0.0"),
    .package(url: "https://github.com/DanToml/Jay.git", from: "1.0.0"),
    .package(url: "https://github.com/jensravens/interstellar.git", from: "2.0.0"),
    .package(url: "https://github.com/jpsim/SourceKitten", from: "0.21.0"),
    .package(url: "https://github.com/yume190/CommandLine", from: "4.0.0"),
    
    
    .package(url: "https://github.com/IBM-Swift/FileKit", from: "0.0.1"),
    .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.1.0"),
    
    // 3rd party dependency
    .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "0.8.0"),
    .package(url: "https://github.com/yume190/JSONDecodeKit", from: "4.0.3")
]

let targets:[Target] = [
    .target(
        name: "iSwift",
        dependencies: [
            .target(name: "ISwiftDependency"),
            "Jay", "CommandLine", "SourceKittenFramework", "Interstellar", "ZeroMQ", "Cryptor",
            "FileKit", "Utility"
        ]
    ),
    .target(name: "ISwiftDependency", dependencies: ["CryptoSwift", "JSONDecodeKit"]), // Link custom modules here
]
let products: [Product] = [
    .executable(name: "iSwift", targets: ["iSwift"]),
    .library(name: "ISwiftDependency", type: .dynamic, targets: ["ISwiftDependency"])
]

let package = Package(
    name: "iSwift",
    products: products,
    dependencies: dependencies,
    targets: targets
)
