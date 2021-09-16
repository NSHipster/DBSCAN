import XCTest
@testable import DBSCAN

final class DBSCANTests: XCTestCase {
    func testExample() {
        let input: [[Double]] = [[ 0, 10, 20 ],
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

        func euclideanDistance(lhs: [Double], rhs: [Double]) -> Double {
            precondition(lhs.count == rhs.count)
            return zip(lhs, rhs).map(-).map { $0 * $0 }.reduce(0, +).squareRoot()
        }

        let dbscan = DBSCAN(input)

        #if swift(>=5.2)
        let (clusters, outliers) = dbscan(epsilon: 10, minimumNumberOfPoints: 2, distanceFunction: euclideanDistance)
        #else
        let (clusters, outliers) = dbscan.callAsFunction(epsilon: 10, minimumNumberOfPoints: 1, distanceFunction: euclideanDistance)
        #endif

        XCTAssertEqual(clusters.count, 4)
        XCTAssertEqual(Set(clusters.map { Set($0) }), [
            [ [20.0, 33.0, 59.0], [21.0, 32.0, 56.0] ],
            [ [58.0, 79.0, 100.0], [58.0, 76.0, 102.0], [59.0, 77.0, 101.0] ],
            [ [500.0, 300.0, 202.0], [500.0, 302.0, 204.0] ],
            [ [0.0, 10.0, 20.0], [0.0, 11.0, 21.0], [0.0, 12.0, 20.0] ]
        ])

        XCTAssertEqual(outliers.count, 1)
        XCTAssertEqual(outliers.first, [300.0, 70.0, 20.0])
    }

    #if swift(>=5.3)
    func testCapitalsPerformance() throws {
        struct Capital: Equatable, Decodable, CustomStringConvertible {
            let country: String
            let latitude: Double
            let longitude: Double

            var localizedName: String {
                Locale.current.localizedString(forRegionCode: country) ?? country
            }

            var coordinates: [Double] {
                [latitude, longitude]
            }

            var description: String {
                return "\(localizedName) (\(latitude), \(longitude))"
            }
        }

        let url = Bundle.module.url(forResource: "capitals", withExtension: "json")!
        let data = try Data(contentsOf: url)

        let decoder = JSONDecoder()
        let input = try decoder.decode([Capital].self, from: data)

        func haversineDistance(lhs: Capital, rhs: Capital) -> Double {
            func deg2rad(_ degrees: Double) -> Double {
                (degrees / 360) * 2 * .pi
            }

            func haversin(_ radians: Double) -> Double {
                return (1 - cos(radians)) / 2
            }

            let R = 6367444.7
            let (llat, llng) = (deg2rad(lhs.latitude), deg2rad(lhs.longitude))
            let (rlat, rlng) = (deg2rad(rhs.latitude), deg2rad(rhs.longitude))

            return R * 2 * asin(sqrt((haversin(rlat - llat) + cos(llat) * cos(rlat) * haversin(rlng - llng))))
        }

        let dbscan = DBSCAN(input)

        var clusters: [[Capital]] = []
        var outliers: [Capital] = []

        measure {
            let ε: Double = 1_000_000
            (clusters, outliers) = dbscan(epsilon: ε, minimumNumberOfPoints: 2, distanceFunction: haversineDistance)
        }

        XCTAssertEqual(clusters.count, 12)
        XCTAssertEqual(outliers.count, 33)
        XCTAssertTrue(clusters.contains(where: { Set($0.map(\.country)) == ["US", "CA"] }))
    }
    #endif
}
