//
//  Debounce.swift
//  SampleShopAppMVVM
//
//  Created by Nazmul on 04/06/2023.
//

import Foundation

final class Debounce {
    
    private let timeInterval: TimeInterval
    private let queue: DispatchQueue
    private var dispatchWorkItem = DispatchWorkItem(block: {})
    
    init(timeInterval: TimeInterval, queue: DispatchQueue) {
        self.timeInterval = timeInterval
        self.queue = queue
    }
    
    func dispatch(_ block: @escaping () -> Void) {
        dispatchWorkItem.cancel()
        let workItem = DispatchWorkItem {
            block()
        }
        dispatchWorkItem = workItem
        queue.asyncAfter(deadline: .now() + timeInterval, execute: dispatchWorkItem)
    }
}
