// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LearningAppEngine",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "LearningCore", targets: ["LearningCore"])],
    targets: [
        .target(name: "LearningCore", path: "Core", resources: [.copy("Resources/SelectedPack"), .copy("Resources/app-config.json"), .copy("Resources/legal.json")]),
        .testTarget(name: "LearningCoreTests", dependencies: ["LearningCore"], path: "Tests/CoreTests")
    ]
)
