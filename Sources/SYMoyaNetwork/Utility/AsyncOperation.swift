//
//  AsyncOperation.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/9/5.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation

/// An asynchronous operation object that implements `Operation`
public class AsyncOperation: Operation {
    private let lockQueue = DispatchQueue(label: "com.shannonyang.SYMoyaNetwork.BatchRequest.Asyncoperation", attributes: .concurrent)

    /// Indicates whether the current Operation is asynchronous
    override public var isAsynchronous: Bool {
        true
    }

    private var _isExecuting: Bool = false

    /// A Boolean value indicating whether the current `Operation` is executing
    override public private(set) var isExecuting: Bool {
        get {
            lockQueue.sync { [weak self] () -> Bool in
                self?._isExecuting ?? false
            }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            lockQueue.sync(flags: [.barrier]) { [weak self] in
                self?._isExecuting = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _isFinished: Bool = false

    /// A Boolean value indicating whether the current `Operation` is finished
    override public private(set) var isFinished: Bool {
        get {
            lockQueue.sync { [weak self] () -> Bool in
                self?._isFinished ?? false
            }
        }
        set {
            willChangeValue(forKey: "isFinished")
            lockQueue.sync(flags: [.barrier]) { [weak self] in
                self?._isFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }

    /// Start executing an asynchronous task
    override public func start() {
        guard !isCancelled else {
            finish()
            return
        }

        isFinished = false
        isExecuting = true
        main()
    }

    /// Check whether the subclass implements the `main` method, and throws an error if it does not.
    override public func main() {
        fatalError("Subclasses must implement `main` without overriding super.")
    }

    /// Complete execution of asynchronous tasks
    public func finish() {
        isExecuting = false
        isFinished = true
    }
}
