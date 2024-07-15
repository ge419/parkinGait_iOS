//
//  UserCalibration.swift
//  parkinGait
//
//  Created by 신창민 on 7/15/24.
//

import Foundation

struct UserCalibration: Identifiable, Codable {
    let id: String
    let gaitConstant: Double
    let Threshold: Double
    let GoalStep: String
    let placement: String
}
