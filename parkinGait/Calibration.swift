//
//  Calibration.swift
//  parkinGait
//
//  Created by 신창민 on 6/23/24.
//

import SwiftUI
import CoreMotion

struct Calibration: View {
    
    @State private var isCollecting = false
    @State private var accelerometerData: [CMAccelerometerData] = []
    @State private var goalStep: Double = 0
    @State private var newGoalStep: String = ""
    @State private var locationPlacement = "In Pocket/In Front"
    @State private var feedbackData: (steps: Int, strideLength: Double, gaitConstant: Double)?
    @State private var showFeedback = false
        
    private let locPlac = ["In Pocket/In Front", "In Waist/On Side"]
    
    var body: some View {
        VStack {
            Text("Calibration")
                .font(.largeTitle)
                .padding(.top, 20)
            
            Text("Recommended Step Length: \(goalStep, specifier: "%.0f") inches")
                .font(.title2)
                .padding(.top, 20)
            
            TextField("Step Length Goal (inches)", text: $newGoalStep)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Text("Phone Location")
                .font(.title2)
                .padding(.top, 20)
            
            Picker("Phone Location", selection: $locationPlacement) {
                ForEach(locPlac, id: \.self) { location in
                    Text(location)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .navigationTitle("Calibration")
        }
    }
}

#Preview {
    Calibration()
}
