// Generated automatically by Perfect Assistant Application
// Date: 2017-09-20 19:30:47 +0000
import PackageDescription
//let package = Package(
//    name: "PerfectTemplate",
//    targets: [],
//    dependencies: [
//        .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 3),
//    ]
//)

let package = Package(
    name: "MyAwesomeProject",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "MyAwesomeProject",
            dependencies: ["PerfectHTTPServer"]),
        ]
)
