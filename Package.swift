import PackageDescription

let package = Package(
    name: "SwiftyCurl",
    targets: [
        Target(
            name: "SwiftyCurl"
        )
	
    ],
    dependencies: [
        .Package(url: "https://github.com/dmcyk/CCurl.git", majorVersion: 0, minor: 1)
    ],
    exclude: [
        "Example"
    ]
)
