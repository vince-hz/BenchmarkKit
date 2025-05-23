//
//  File.swift
//  BenchmarkKit
//
//  Created by xuyunshi on 2025/5/21.
//

import Foundation

/// P is prepared input type.
public struct MeasureInput<P> {
    public init(
        taskName: String,
        impLabel: String,
        resourceCaseLabel: String,
        performQueue: DispatchQueue,
        performTimes: Int,
        prepare: @escaping MeasurePrepareFunction<P>,
        syncWork: @escaping MeasureSyncFunction<P>,
        finishedHandler: @escaping MeasureFinishFunction
    ) {
        self.init(
            taskName: taskName,
            impLabel: impLabel,
            resourceCaseLabel: resourceCaseLabel,
            performQueue: performQueue,
            performTimes: performTimes,
            prepare: prepare
        ) { pInput, done in
            syncWork(pInput)
            done()
        } finishedHandler: { result in
            finishedHandler(result)
        }
    }

    public init(
        taskName: String,
        impLabel: String,
        resourceCaseLabel: String,
        performQueue: DispatchQueue,
        performTimes: Int,
        prepare: @escaping MeasurePrepareFunction<P>,
        asyncWork: @escaping MeasureFunction<P>,
        finishedHandler: @escaping MeasureFinishFunction
    ) {
        self.taskName = taskName
        self.impLabel = impLabel
        self.resourceCaseLabel = resourceCaseLabel
        self.queue = performQueue
        self.times = performTimes
        self.prepareWork = prepare
        self.function = asyncWork
        self.finishedHandler = finishedHandler
    }

    public let taskName: String
    public let impLabel: String
    public let resourceCaseLabel: String
    public let queue: DispatchQueue
    public let times: Int
    public let prepareWork: MeasurePrepareFunction<P>
    public let function: MeasureFunction<P>
    public let finishedHandler: MeasureFinishFunction
}
