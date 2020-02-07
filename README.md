# DBSCAN

**D**ensity-**b**ased **s**patial **c**lustering of **a**pplications with **n**oise
([DBSCAN](https://en.wikipedia.org/wiki/DBSCAN)).

## Usage

```swift
import DBSCAN
import simd

let input: [SIMD3<Double>] = [[ 0, 10, 20 ],
                              [ 0, 11, 21 ],
                              [ 0, 12, 20 ],
                              [ 20, 33, 59 ],
                              [ 21, 32, 56 ],
                              [ 59, 77, 101 ],
                              [ 58, 79, 100 ],
                              [ 58, 76, 102 ],
                              [ 300, 70, 20 ],
                              [ 500, 300, 202],
                              [ 500, 302, 204 ]]

let dbscan = DBSCAN(input)

#if swift(>=5.2)
let (clusters, outliers) = dbscan(epsilon: 10,
                                  minimumNumberOfPoints: 1,
                                  distanceFunction: simd.distance)
#else // Swift <5.2 requires explicit `callAsFunction` method name
let (clusters, outliers) = dbscan.callAsFunction(epsilon: 10, 
                                                 minimumNumberOfPoints: 1, 
                                                 distanceFunction: simd.distance)
#endif

print(clusters)
// [ [0, 10, 20], [0, 11, 21], [0, 12, 20] ]
// [ [20, 33, 59], [21, 32, 56] ],
// [ [58, 79, 100], [58, 76, 102], [59, 77, 101] ],
// [ [500, 300, 202], [500, 302, 204] ],

print(outliers)
// [ [ 300, 70, 20 ] ]
```

## Requirements

- Swift 5.1+

## Installation

### Swift Package Manager

Add the SwiftMarkup package to your target dependencies in `Package.swift`:

```swift
import PackageDescription

let package = Package(
  name: "YourProject",
  dependencies: [
    .package(
        url: "https://github.com/NSHipster/DBSCAN",
        from: "0.0.1"
    ),
  ]
)
```

Then run the `swift build` command to build your project.

## License

MIT

## Contact

Mattt ([@mattt](https://twitter.com/mattt))

[SE-0253]: https://github.com/apple/swift-evolution/blob/master/proposals/0253-callable.md "Callable values of user-defined nominal types"
