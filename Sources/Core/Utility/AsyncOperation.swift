//
//  AsyncOperation.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/9/5.
//

import Foundation

public class AsyncOperation: Operation {
    private let lockQueue = DispatchQueue(label: "com.shannonyang.SYMoyaNetwork.BatchRequest.Asyncoperation", attributes: .concurrent)
    
    public override var isAsynchronous: Bool {
        return true
    }
    
    private var _isExecuting: Bool = false
    public override private(set) var isExecuting: Bool {
        get {
            return lockQueue.sync { [weak self] () -> Bool in
                return self?._isExecuting ?? false
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
    public override private(set) var isFinished: Bool {
        get {
            return lockQueue.sync { [weak self] () -> Bool in
                return self?._isFinished ?? false
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
    
    public override func start() {
        guard !isCancelled else {
            finish()
            return
        }
        
        isFinished = false
        isExecuting = true
        main()
    }
    
    public override func main() {
        fatalError("Subclasses must implement `main` without overriding super.")
    }
    
    func finish() {
        isExecuting = false
        isFinished = true
    }
}


