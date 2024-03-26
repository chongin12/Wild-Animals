// swift-tools-version: 5.8

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Wild Animals",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "Wild Animals",
            targets: ["AppModule"],
            bundleIdentifier: "blog.mosu.Wild-Animals",
            teamIdentifier: "SYZM4D2Z3D",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
            accentColor: .presetColor(.green),
            supportedDeviceFamilies: [
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait
            ],
            capabilities: [
                .locationWhenInUse(purposeString: "사용자의 위치를 기반으로 동물을 생성하기 때문에 위치 정보가 필요합니다."),
                .photoLibraryAdd(purposeString: "현재 자신의 위치에 어떤 동물을 놓을지 동물의 이미지가 필요합니다.")
            ],
            appCategory: .games
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)