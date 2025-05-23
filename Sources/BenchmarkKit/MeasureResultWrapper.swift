//
//  File.swift
//  BenchmarkKit
//
//  Created by xuyunshi on 2025/5/21.
//

import Foundation

public enum ReportUnit {
    case nanoseconds
    case milliseconds
    case seconds
    
    var suffix: String {
        switch self {
        case .nanoseconds: return "ns"
        case .milliseconds: return "ms"
        case .seconds: return "s"
        }
    }
    
    var multiplier: Double {
        switch self {
        case .nanoseconds: return 1_000_000_000
        case .milliseconds: return 1_000
        case .seconds: return 1
        }
    }
}

func selectUnit(for results: [MeasureResult]) -> ReportUnit {
    let maxTimeInNs = results.map { $0.average * 1_000_000_000 }.max() ?? 0
    if maxTimeInNs < 1_000_000 {
        return .nanoseconds
    } else if maxTimeInNs < 1_000_000_000 {
        return .milliseconds
    } else {
        return .seconds
    }
}

public struct MeasureResultWrapper {
    public let cols: [String]
    public let rows: [String]
    public let cells: [MeasureResult?]
    public let unit: ReportUnit
    
    func timeString(for result: MeasureResult) -> String {
        let time = result.average * unit.multiplier
        return String(format: "%.1f %@", time, unit.suffix)
    }
    
    public init(results: [MeasureResult]) {
        let labels = results.reduce(into: Set<String>()) { $0.insert($1.taskName) }
        let secondLabels: Set<String> = results.reduce(into: Set<String>()) { $0.insert($1.impLabel) }
        cols = labels.map(\.self).sorted()
        rows = secondLabels.map(\.self).sorted()
        
        var cells: [MeasureResult?] = []
        for row in rows {
            for col in cols {
                let result = results.first { $0.taskName == col && $0.impLabel == row }
                cells.append(result)
            }
        }
        self.cells = cells
        
        self.unit = selectUnit(for: results)
    }
}
