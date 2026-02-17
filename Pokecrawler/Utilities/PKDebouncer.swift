//
//  PKDebouncer.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 08/12/25.
//

import Foundation

/// A reusable debouncer that delays execution until input stops for a specified duration.
final class PKDebouncer {
    
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?
    private let queue: DispatchQueue
    
    /// Creates a new debouncer
    /// - Parameters:
    ///   - delay: Time in seconds to wait after last call before executing
    ///   - queue: Queue to execute the action on (defaults to main)
    init(delay: TimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }
    
    /// Debounce an action. Cancels any pending action and schedules a new one.
    func debounce(action: @escaping () -> Void) {
        workItem?.cancel()
        
        let newWorkItem = DispatchWorkItem(block: action)
        workItem = newWorkItem
        
        queue.asyncAfter(deadline: .now() + delay, execute: newWorkItem)
    }
    
    /// Cancel any pending debounced action
    func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}
