# DataLiteCore

DataLiteCore is an intuitive library for working with SQLite in Swift applications.

## Overview

DataLiteCore provides an object-oriented API over the C interface, allowing developers to easily integrate SQLite functionality into their projects. The library offers powerful capabilities for database management and executing SQL queries while maintaining the simplicity and flexibility of the native Swift interface.

## Key Features

- **Connection Management** — a convenient interface for setting up connections to SQLite databases.
- **Preparation and Execution of SQL Statements** — support for parameterized queries for safe SQL execution.
- **Custom Function Integration** — the ability to add custom functions for use in SQL queries.
- **Native Error Handling** — easy error management using Swift's built-in error handling system.

## Requirements

- **Swift**: 5.10+
- **Platforms**: macOS 10.14+, iOS 12.0+, Linux

## Installation

To add DataLiteCore to your project, use Swift Package Manager (SPM).

> **Important:** The API of `DataLiteCore` is currently unstable and may change without notice. It is **strongly recommended** to pin the dependency to a specific commit to ensure compatibility and avoid unexpected breakage when the API evolves.

### Adding to an Xcode Project

1. Open your project in Xcode.
2. Navigate to the `File` menu and select `Add Package Dependencies`.
3. Enter the repository URL: `https://github.com/angd-dev/data-lite-core.git`
4. Choose the version to install.
5. Add the library to your target module.

### Adding to Package.swift

If you are using Swift Package Manager with a `Package.swift` file, add the dependency like this:

```swift
// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "YourProject",
    dependencies: [
        .package(url: "https://github.com/angd-dev/data-lite-core.git", branch: "develop")
    ],
    targets: [
        .target(
            name: "YourTarget",
            dependencies: [
                .product(name: "DataLiteCore", package: "data-lite-core")
            ]
        )
    ]
)
```

## Additional Resources

For more information and usage examples, see the [documentation](https://docs.angd.dev/?package=data-lite-core&version=develop).

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
