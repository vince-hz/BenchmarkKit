//
//  BenchmarkKit.swift
//  BenchmarkKit
//
//  Created by xuyunshi on 2025/5/21.
//

import Foundation

let defaultCoordinateQueue: OperationQueue = {
    let defaultCoordinateQueue = OperationQueue()
    defaultCoordinateQueue.maxConcurrentOperationCount = 1
    defaultCoordinateQueue.isSuspended = true
    return defaultCoordinateQueue
}()

private var currentResults: [MeasureResult] = []
public enum BenchmarkKit {
    public static func measureWork<T>(_ input: MeasureInput<T>) {
        var results: [Int: TimeInterval] = [:]

        for index in 0 ..< input.times {
            defaultCoordinateQueue.addOperation(
                AsyncOperation(block: { opFinishCallback in
                    input.prepareWork { preparedInput in
                        let start = CFAbsoluteTimeGetCurrent()
                        input.function(preparedInput) {
                            let end = CFAbsoluteTimeGetCurrent()
                            let duration = end - start
                            results[index] = duration
                            opFinishCallback()
                        }
                    }
                })
            )
        }

        defaultCoordinateQueue.addBarrierBlock {
            let result = MeasureResult(
                taskName: input.taskName,
                impLabel: input.impLabel,
                resourceCaseLabel: input.resourceCaseLabel,
                queue: input.queue,
                times: input.times,
                worksCost: results
            )
            currentResults.append(result)
            input.finishedHandler(result)
        }
    }

    public static func main() async ->  [MeasureResult] {
        currentResults = []
        defaultCoordinateQueue.isSuspended = false
        let results = await withCheckedContinuation { continuation in
            defaultCoordinateQueue.addBarrierBlock {
                continuation.resume(returning: currentResults)
            }
        }
        return results
    }
    
    public static func wrapper(results: [MeasureResult]) -> MeasureResultWrapper {
        let sortedResults = results.sorted { $0.average < $1.average }
        return .init(results: sortedResults)
    }
    
    public static func formView(results: [MeasureResult], title: String) -> ReportFormView {
        let wrapperResult = wrapper(results: results)
        let formView = ReportFormView(formTitle: title, wrappedResult: wrapperResult)
        return formView
    }
    
    public static func report(results: [MeasureResult]) -> String {
        let sortedResults = results.sorted { $0.average < $1.average }
        let unit = selectUnit(for: sortedResults)
        
        // Format device description
        var reportString = "\n" + deviceDescription() + "\n\n"
        
        // Add header
        reportString += "name                                         time            std        iterations\n"
        reportString += "----------------------------------------------------------------------------------\n"
        
        // Add results
        for result in sortedResults {
            let name = "\(result.taskName).\(result.impLabel).\(result.resourceCaseLabel)".replacingOccurrences(of: "\n", with: " ")
            let timeValue = result.average * unit.multiplier
            let stdDevPercent = (sqrt(result.variance) / result.average) * 100
            let formattedResult = String(
                "\(name.padding(toLength: 36, withPad: " ", startingAt: 0))" +
                "\(String(format: "%10.3f", timeValue)) \(unit.suffix)" +
                "\(String(format: "%14.1f ±", stdDevPercent))% " +
                "\(String(format: "%14d", result.times))\n"
            )
            reportString += formattedResult
        }
        
        return reportString
    }
}
