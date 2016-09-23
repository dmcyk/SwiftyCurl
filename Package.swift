import PackageDescription

let package = Package(
    name: "SwiftyCurl",
    targets: [
        Target(
            name: "SwiftyCurl"
        )
	
    ],
    dependencies: [
        .Package(url: "https://github.com/PerfectlySoft/Perfect-libcurl.git", majorVersion: 0)
    ],
    exclude: [
        "Example"
    ]
)
