// swift-tools-version: 5.9

// WARNING:
// This is an App Playground package. Open the TamirWellbeing.swiftpm folder in
// Xcode 15+ (or Swift Playgrounds 4.4+). Edit app settings below with care.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Tamir Wellbeing",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "Tamir Wellbeing",
            targets: ["AppModule"],
            bundleIdentifier: "com.tamir.wellbeing",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .heart),
            accentColor: .presetColor(.teal),
            supportedDeviceFamilies: [
                .phone,
                .pad
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)
