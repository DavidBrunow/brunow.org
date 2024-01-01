// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "brunow",
  platforms: [
  .iOS(.v16),
  ],
  products: [
    .library(
      name: "Brunow",
      targets: ["Brunow"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),
  ],
  targets: [
    .target(
      name: "Brunow",
      dependencies: [
      ]
    ),
  ]
)

