// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "Example",
  platforms: [.macOS(.v10_15)],
  dependencies: [
    .package(name: "Alamofire", url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.4.0")),
    .package(name: "SwiftyJSON", url: "https://github.com/SwiftyJSON/SwiftyJSON", .upToNextMajor(from: "5.0.0")),
    .package(name: "Charts", url: "https://github.com/danielgindi/Charts", .upToNextMajor(from: "3.5.0"))
  ],
  targets: [
    .target(
      name: "Example",
      dependencies: [
        .product(name: "Alamofire", package: "Alamofire"),
        .product(name: "SwiftyJSON", package: "SwiftyJSON"),
        .product(name: "Charts", package: "Charts")
      ])
  ]
)
