//
//  File.swift
//  BenchmarkKit
//
//  Created by xuyunshi on 2025/5/21.
//

import Foundation

public struct MeasureResult: CustomStringConvertible, Identifiable, Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public var id: String {
        "\(taskName)\n-\n\(impLabel)\n-\n\(resourceCaseLabel)"
    }

    public var description: String {
        let formattedResult = String(format: """
        Measure Result:
            Label: \(taskName)
            SecondLabel: \(impLabel)
            Subtitle: \(resourceCaseLabel)
            Queue: \(queue.label)
            Times: \(times)
            Average Time: %.3f s
            Work Times: %@
        """, average, worksCost.values.description)
        return formattedResult
    }

    public let taskName: String
    public let impLabel: String
    public let resourceCaseLabel: String
    public let queue: DispatchQueue
    public let times: Int
    public let worksCost: [Int: TimeInterval]
    public var average: TimeInterval {
        let sum = worksCost.values.reduce(0, +)
        return sum / Double(worksCost.count)
    }
    public var variance: Double {
        let avg = average
        let sumOfSquaredDifferences = worksCost.values.reduce(0.0) { sum, value in
            let difference = value - avg
            return sum + (difference * difference)
        }
        return sumOfSquaredDifferences / Double(worksCost.count)
    }
}
