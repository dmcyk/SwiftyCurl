// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SwiftyCurl",
    products: [
        .library(name: "SwiftyCurl", targets: ["SwiftyCurl"]),
        .executable(name: "SwiftyCurlExample", targets: ["SwiftyCurlExample"])
    ],
    dependencies: [
        .package(url: "https://github.com/dmcyk/CCurl.git", .upToNextMajor(from: "0.2.0"))
    ],
    targets: [
        .target(
            name: "SwiftyCurl",
            dependencies: [
            ]
        ),
        .target(
            name: "SwiftyCurlExample",
            dependencies: [
                "SwiftyCurl"
            ]
        )
    ]
)
