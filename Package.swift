// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "iSwift",
    dependencies: [
        .package(url: "https://github.com/Zewo/ZeroMQ.git", from: "1.0.0"),
        .package(url: "https://github.com/IBM-Swift/BlueCryptor.git", from: "1.0.0"),
        .package(url: "https://github.com/DanToml/Jay.git", from: "1.0.0"),
        .package(url: "https://github.com/jensravens/interstellar.git", from: "2.0.0"),
        .package(url: "https://github.com/jpsim/SourceKitten", from: "0.21.0"),
        .package(url: "https://github.com/yume190/CommandLine", from: "4.0.0"),
    ],
    targets: [
        
        .target(
            name: "iSwift",
            dependencies: [
                "Jay",
                "CommandLine",
                "SourceKittenFramework",
                "Interstellar",
                "ZeroMQ",
                "Cryptor",
            ],
            path : "Sources"
        ),
    ]
)
