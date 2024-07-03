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
    @State private var feedbackData: (steps: Int, strideLength: Double, gaitConstant: Double) = (0, 0, 0)
//    @State private var feedbackData: (steps: Int, strideLength: Double, gaitConstant: Double)?
    @State private var showFeedback = false
    
    private var motionManager = CMMotionManager()
    
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
            
            if showFeedback {
                VStack {
                    Text("Steps Detected: \(feedbackData.steps)")
                    Text("Stride Length: \(feedbackData.strideLength, specifier: "%.2f") meters")
                    Text("Gait Constant: \(feedbackData.gaitConstant, specifier: "%.2f")")
                    Text("Does this seem accurate?")
                    HStack {
                        Button("Yes") {
                            showFeedback = false
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                        
                        Button("No, recalibrate") {
                            showFeedback = false
                            isCollecting = false
                            accelerometerData.removeAll()
                        }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                    }
                }
                .padding()
            }
            
            Button {
                handleToggleCollecting()
            } label: {
                Text(isCollecting ? "Stop Collecting" : "Start Collecting")
                    .padding()
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                
            }.padding()
            
        }.navigationTitle("Calibration")
    }
    
    private func handleToggleCollecting() {
        if !isCollecting {
            accelerometerData.removeAll()
            // begin collecting
        } else {
            isCollecting = false
            motionManager.stopAccelerometerUpdates()
        }
    }
}

#Preview {
    Calibration()
}
