//
//  Alias.swift
//  BenchmarkKit
//
//  Created by xuyunshi on 2025/5/21.
//

import Foundation

public typealias MeasurePrepareFunction<P> = (_ prepareDoneCallback: @escaping (P) -> Void) -> Void
public typealias MeasureFunction<P> = (_ pInput: P, _ done: @escaping () -> Void) -> Void
public typealias MeasureSyncFunction<P> = (_ pInput: P) -> Void
public typealias MeasureFinishFunction = (_ result: MeasureResult) -> Void
