import XCTest
@testable import DBSCAN

import simd

final class DBSCANTests: XCTestCase {
    func testExample() {
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
        let (clusters, outliers) = dbscan(epsilon: 10, minimumNumberOfPoints: 1, distanceFunction: simd.distance)
        #else
        let (clusters, outliers) = dbscan.callAsFunction(epsilon: 10, minimumNumberOfPoints: 1, distanceFunction: simd.distance)
        #endif

        XCTAssertEqual(clusters.count, 4)
        XCTAssertEqual(Set(clusters.map { Set($0) }), [
            [ [20.0, 33.0, 59.0], [21.0, 32.0, 56.0] ],
            [ [58.0, 79.0, 100.0], [58.0, 76.0, 102.0], [59.0, 77.0, 101.0] ],
            [ [500.0, 300.0, 202.0], [500.0, 302.0, 204.0] ],
            [ [0.0, 10.0, 20.0], [0.0, 11.0, 21.0], [0.0, 12.0, 20.0] ]
        ])

        XCTAssertEqual(outliers.count, 1)
        XCTAssertEqual(outliers[0], [300.0, 70.0, 20.0])
    }
}
