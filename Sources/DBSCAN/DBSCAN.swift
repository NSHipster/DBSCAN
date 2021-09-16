/**
 A density-based, non-parametric clustering algorithm
 ([DBSCAN](https://en.wikipedia.org/wiki/DBSCAN)).

 Given a set of points in some space,
 this algorithm groups points with many nearby neighbors
 and marks points in low-density regions as outliers.

 - Authors: Ester, Martin; Kriegel, Hans-Peter; Sander, Jörg; Xu, Xiaowei (1996)
            "A density-based algorithm for discovering clusters
            in large spatial databases with noise."
            _Proceedings of the Second International Conference on
            Knowledge Discovery and Data Mining (KDD-96)_.
 */
public struct DBSCAN<Value: Equatable> {
    private class Point: Equatable {
        typealias Label = Int

        let value: Value
        var label: Label?

        init(_ value: Value) {
            self.value = value
        }

        static func == (lhs: Point, rhs: Point) -> Bool {
            return lhs.value == rhs.value
        }
    }

    /// The values to be clustered.
    public var values: [Value]

    /// Creates a new clustering algorithm with the specified values.
    /// - Parameter values: The values to be clustered.
    public init(_ values: [Value]) {
        self.values = values
    }


    /**
     Clusters values according to the specified parameters.

     - Parameters:
       - epsilon: The maximum distance from a specified value
                  for which other values are considered to be neighbors.
       - minimumNumberOfPoints: The minimum number of points
                                required to form a dense region.
       - distanceFunction: A function that computes
                           the distance between two values.
     - Throws: Rethrows any errors produced by `distanceFunction`.
     - Returns: A tuple containing an array of clustered values
                and an array of outlier values.
    */
    public func callAsFunction(epsilon: Double, minimumNumberOfPoints: Int, distanceFunction: (Value, Value) throws -> Double) rethrows -> (clusters: [[Value]], outliers: [Value]) {
        precondition(minimumNumberOfPoints >= 0)

        let points = values.map { Point($0) }

        var currentLabel = 0
        for point in points {
            guard point.label == nil else { continue }

            var neighbors = try points.filter { try distanceFunction(point.value, $0.value) < epsilon }
            if neighbors.count >= minimumNumberOfPoints {
                defer { currentLabel += 1 }
                point.label = currentLabel

                while !neighbors.isEmpty {
                    let neighbor = neighbors.removeFirst()
                    guard neighbor.label == nil else { continue }

                    neighbor.label = currentLabel

                    let n1 = try points.filter { try distanceFunction(neighbor.value, $0.value) < epsilon }
                    if n1.count >= minimumNumberOfPoints {
                        neighbors.append(contentsOf: n1)
                    }
                }
            }
        }

        var clusters: [[Value]] = []
        var outliers: [Value] = []

        for (label, points) in Dictionary(grouping: points, by: { $0.label }) {
            let values = points.map { $0.value }
            if label == nil {
                outliers.append(contentsOf: values)
            } else {
                clusters.append(values)
            }
        }

        return (clusters, outliers)
    }
}
