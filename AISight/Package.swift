// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "AISight",
    platforms: [
        .iOS(.v26),
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "AISight",
            targets: ["AISight"]
        ),
    ],
    targets: [
        .target(
            name: "AISight",
            path: "AISight",
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
