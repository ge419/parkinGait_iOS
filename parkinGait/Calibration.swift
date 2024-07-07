//
//  Calibration.swift
//  parkinGait
//
//  Created by 신창민 on 6/23/24.
//

import SwiftUI
import CoreMotion

struct Calibration: View {
    
    @EnvironmentObject private var viewModel: AuthViewModel
    @State private var isCollecting = false
    @State private var accelerometerData: [CMAccelerometerData] = []
    @State private var goalStep: Double = 0
    @State private var newGoalStep: String = ""
    @State private var locationPlacement = "In Pocket/In Front"
    @State private var feedbackData: (steps: Int, strideLength: Double, gaitConstant: Double) = (0, 0, 0)
    //    @State private var feedbackData: (steps: Int, strideLength: Double, gaitConstant: Double)?
    @State private var showFeedback = false
    
    
    private let distanceTraveled: Double = 5
    private let distanceThreshold: Int = 3
    private let userHeight: Double = 1.778
    private let metersToInches: Double = 39.3701
    
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
            
            // Start Collecting button
            //
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
            
            Button {
                handleCalibrate()
            } label: {
                Text("Calibrate")
                    .padding()
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                
            }.padding()
            
        }.navigationTitle("Calibration")
            .onAppear {
                if let height = Double(viewModel.currentUser?.height ?? "") {
                    goalStep = height * 0.414
                } else {
                    goalStep = userHeight * metersToInches * 0.414
                }
            }
    }
    
    private func handleToggleCollecting() {
        if !isCollecting {
            accelerometerData.removeAll()
            // begin collecting
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.isCollecting = true
                self.startAccelerometerUpdates()
            }
        } else {
            isCollecting = false
            motionManager.stopAccelerometerUpdates()
        }
    }
    
    private func handleCalibrate() {
//        let xData = accelerometerData.map { $0.acceleration.x }
        let yData = accelerometerData.map { $0.acceleration.y }
        let zData = accelerometerData.map { $0.acceleration.z
        }
        
        if locationPlacement == "In Pocket/In Front" {
            // use z data
            
            let mean = zData.prefix(zData.count - 10).reduce(0, +) / Double(zData.count - 10)
            
            var steps: [Double] = []
            var lastIndex = 0
            
            for (index, z) in zData.enumerated() {
                if index < zData.count - 10,
                   index - lastIndex > distanceThreshold,
                   (z < mean && zData[index - 1] > mean) || (zData[index - 1] < mean && z > mean) {
                    steps.append(Double(index))
                    lastIndex = index
                }
            }
            
            let times = zip(steps.dropFirst(), steps).map { ($0 - $1) / 10.0 } // times in seconds
            let avTime = times.reduce(0, +) / Double(times.count)
            let avStepLength = distanceTraveled / Double(steps.count)
//            let avStepLengthInches = avStepLength * metersToInches
            let gaitConstant = avStepLength / avTime
            
            Task {
                await viewModel.saveCalibration(gaitConstant: gaitConstant, threshold: mean, goalStep: newGoalStep, placement: locationPlacement)
            }
        }
        else if locationPlacement == "In Waist/On Side" {
            // use y data
            let mean = yData.prefix(yData.count - 10).reduce(0, +) / Double(yData.count - 10)
            
            var steps: [Double] = []
            var lastIndex = 0
            
            for (index, y) in yData.enumerated() {
                if index < yData.count - 10,
                   index - lastIndex > distanceThreshold,
                   (y < mean && yData[index - 1] > mean) || (yData[index - 1] < mean && y > mean) {
                    steps.append(Double(index))
                    lastIndex = index
                }
            }
            
            let times = zip(steps.dropFirst(), steps).map { ($0 - $1) / 10.0 } // times in seconds
            let avTime = times.reduce(0, +) / Double(times.count)
            let avStepLength = distanceTraveled / Double(steps.count)
//            let avStepLengthInches = avStepLength * metersToInches
            let gaitConstant = avStepLength / avTime
            
            Task {
                await viewModel.saveCalibration(gaitConstant: gaitConstant, threshold: mean, goalStep: newGoalStep, placement: locationPlacement)
            }
            feedbackData = (steps: steps.count, strideLength: avStepLength, gaitConstant: gaitConstant)
            showFeedback = true
        }
    }
    
    private func startAccelerometerUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { data, error in
                if let data = data {
                    self.accelerometerData.append(data)
                }
            }
        }
    }
}

#Preview {
    Calibration()
}
