//
//  DeltaTime.swift
//  parkinGait
//
//  Created by 신창민 on 9/30/24.
//


import Foundation

class DeltaTime {
    var prev_ts: TimeInterval = 0
    var first: TimeInterval = 0
    
    func step(ts: TimeInterval) -> Float {
        let dt = Float(ts - prev_ts)
        set(ts: ts)
        return dt
    }
    
    func set(ts: TimeInterval) {
        prev_ts = ts
    }
    
    func cumDiff(ts: TimeInterval) -> Float {
        return Float(ts - first)
    }
}
