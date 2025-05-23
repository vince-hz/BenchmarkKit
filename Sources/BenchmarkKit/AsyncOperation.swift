//
//  AsyncOperation.swift
//  BenchmarkKit
//
//  Created by xuyunshi on 2025/5/21.
//

import Foundation

class AsyncOperation: Operation, @unchecked Sendable {
    private var _executing = false
    private var _finished = false

    override var isAsynchronous: Bool { true }
    override private(set) var isExecuting: Bool {
        get { _executing }
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }

    override private(set) var isFinished: Bool {
        get { _finished }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    private let block: (@escaping () -> Void) -> Void

    init(block: @escaping (@escaping () -> Void) -> Void) {
        self.block = block
    }

    override func start() {
        guard !isCancelled else {
            finish()
            return
        }

        isExecuting = true

        block { [weak self] in
            self?.finish()
        }
    }

    func finish() {
        isExecuting = false
        isFinished = true
    }
}
