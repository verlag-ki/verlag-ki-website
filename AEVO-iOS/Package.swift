// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AEVOLernen",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "AEVOCore", targets: ["AEVOCore"])],
    targets: [
        .target(name: "AEVOCore", path: "Core", resources: [.process("Resources")]),
        .testTarget(name: "AEVOCoreTests", dependencies: ["AEVOCore"], path: "Tests/CoreTests")
    ]
)
