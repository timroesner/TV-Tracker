//
//  Debouncer.swift
//  TV Tracker
//
//  Created by Tim Roesner on 6/4/21.
//

import Foundation

public class Debouncer {
    typealias Handler = () -> Void
    
    var handler: Handler? {
        didSet {
            renewInterval()
        }
    }
    
    private let timeInterval: TimeInterval
    private var timer: Timer?
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    private func renewInterval() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] timer in
            self?.timeIntervalDidFinish(for: timer)
        }
    }
    
    @objc private func timeIntervalDidFinish(for timer: Timer) {
        guard timer.isValid else { return }
        handler?()
        handler = nil
    }
}
