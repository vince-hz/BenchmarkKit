@testable import BenchmarkKit
import Foundation
import Testing

func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0 ..< length).map { _ in letters.randomElement()! })
}

@Test
func example() async throws {
    for _ in 0 ..< 10 {
        BenchmarkKit.measureWork(
            .init(
                label: randomString(length: 3),
                secondLabel: randomString(length: 2),
                identifier: "c",
                performQueue: .main,
                performTimes: 3,
                prepare: { prepareDoneCallback in
                    prepareDoneCallback(1)
                },
                asyncWork: { _, done in
                    let sleep = Double.random(in: 0.000001 ..< 0.0000011)
                    DispatchQueue.global().asyncAfter(deadline: .now() + sleep) {
                        done()
                    }
                },
                finishedHandler: { _ in
                }
            )
        )
    }

    let results = await BenchmarkKit.main()
    let str = BenchmarkKit.report(results: results)
    print(str)
}
