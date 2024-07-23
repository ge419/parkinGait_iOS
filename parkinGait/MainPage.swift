//
//  MainPage.swift
//  parkinGait
//
//  Created by 신창민 on 6/23/24.
//

import SwiftUI
import CoreMotion
import AVFoundation

struct MainPage: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var gaitConstant: Double = 0
    @State private var threshold: Double = 0
    @State private var goalStep: Double = 0
    @State private var placement: String = ""
    
    @State private var isWalking = false
    @State private var stepLength: Double = 0
    @State private var range: Double = 30
    @State private var vibrateOption = "Over Step Goal"
    @State private var vibrateValue = "Vibrate Phone"
    @State private var isPlaying = false
    @State private var player: AVAudioPlayer?
    @State private var timer: Timer?
    
    @State private var accelerometerData: [CMAccelerometerData] = []
    @State private var stepLengthFirebase: [Double] = []
    @State private var peakTimes: [Double] = []
    @State private var waitingFor1stValue = false
    @State private var waitingFor2ndValue = false
    @State private var waitingFor3rdValue = false
    @State private var isEnabled = false
    @State private var lastPeakSign = -1
    @State private var lastPeakIndex = 0
    @State private var isFirstPeakPositive = false
    @State private var dynamicThreshold: Double = 0
    @State private var recentAccelData: [Double] = []
    
    private var motionManager = CMMotionManager()
    
    let ACCELEROMETER_TIMING = 0.1
    let ACCELEROMETER_HZ = 1.0 / 0.1
    let USER_HEIGHT = 1.778
    let METERS_TO_INCHES = 39.3701
    let DISTANCE_THRESHOLD = 3.0
    
    let bgColor = Color(red: 0.8706, green: 0.8549, blue: 0.8235)
    
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack {
                    Text("Gait Tracker Home Page")
                        .font(.largeTitle)
                        .padding(.top, 20)
                    
                    Button(action: handleToggleWalking) {
                        Text(isWalking ? "Stop Walking" : "Start Walking")
                            .font(.title)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    Text("Step Length Estimate: \(String(format: "%.2f", stepLength)) inches")
                        .font(.title2)
                        .padding(.top, 20)
                    Text("Goal Step Length: \(String(format: "%.0f", goalStep)) inches")
                        .foregroundColor(.gray)
                        .font(.body)
                        .padding(.top, 5)
                    Text("Start Metronome")
                        .font(.title)
                        .padding(.top, 20)
                    
                    Toggle(isOn: $isPlaying) {}
                        .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                        .padding(.horizontal, 200)
                        .padding(.top, 10)
                        .onChange(of: isPlaying) {
                            metronome(with: isPlaying)
                        }
                    
                    
                    Text("\(Int(range)) Steps per Minute")
                        .font(.title2)
                    
                    Slider(value: $range, in: 30...120, step: 1)
                        .padding(.horizontal, 50)
                        .padding(.bottom, 20)
                        .onChange(of: range) {
                            if isPlaying {
                                stopMetronome()
                                startMetronome()
                            }
                        }
                    
                    Text("Vibrate If...")
                        .font(.title2)
                        .padding(.top, 20)
                    
                    Picker("Vibration Option", selection: $vibrateOption) {
                        Text("Over Step Goal").tag("Over Step Goal")
                        Text("Under Step Goal").tag("Under Step Goal")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 50)
                    
                    Text("Vibration Mode")
                        .font(.title2)
                        .padding(.top, 20)
                    
                    Picker("Vibration Mode", selection: $vibrateValue) {
                        Text("Vibrate Phone").tag("Vibrate Phone")
                        Text("Vibrate Wristband").tag("Vibrate Wristband")
                        Text("No Vibrations").tag("No Vibrations")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 50)
                    
                    HStack {
                        Spacer()
                        NavigationLink(destination: EditProfile()) {
                            Text("Change User Information")
                                .font(.body)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                            
                        }.fixedSize()
                        
                        
                        NavigationLink(destination: Dashboard()) {
                            Text("Go to Dashboard")
                                .font(.body)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                            
                        }.fixedSize()
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding()
                    
                    
                    NavigationLink(destination: Calibration(), label: {
                        Text("Recalibrate")
                            .font(.body)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    })
                    Button{
                        viewModel.signOut()
                    } label: {
                        Text("Sign Out")
                            .font(.body)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }
            }
            .navigationTitle("MainPage")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear{
            if let calibration = viewModel.currentCalibration {
                gaitConstant = calibration.gaitConstant
                threshold = calibration.threshold
                goalStep = Double(calibration.goalStep) ?? 0
                placement = calibration.placement
            }
        }
    }
    
    func playSound1() {
        guard let soundURL1 = Bundle.main.url(forResource: "beep2", withExtension: "mp3") else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: soundURL1)
            player.play()
        } catch {
            print("DEBUG: Failed to play sound 1 \(error.localizedDescription)")
        }
    }
    
    func playSound2() {
        guard let soundURL2 = Bundle.main.url(forResource: "beep3", withExtension: "mp3") else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: soundURL2)
            player.play()
        } catch {
            print("DEBUG: Failed to play sound 2 \(error.localizedDescription)")
        }
        
    }
    
    func metronome(with value: Bool) {
        prepareAudioPlayer()
        if value {
            startMetronome()
        } else {
            stopMetronome()
        }
    }
    
    // DEBUG: Metronome for 119, 120 BPM doesnt work properly
    // maybe the beep is too long for 120 BPM
    func startMetronome() {
        stopMetronome()
        let interval = 60.0 / range
        print(interval)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.playSound()
            print("beep")
        }
    }
    
    func stopMetronome() {
        timer?.invalidate()
        timer = nil
    }
    
    func playSound() {
        player?.play()
    }
    
    func prepareAudioPlayer() {
        if let url = Bundle.main.url(forResource: "beep2", withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.prepareToPlay()
                print("Prepared to play sound")
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        } else {
            print("Audio file not found")
        }
    }
    
    func movingAverage(data: [Double], windowSize: Int) -> [Double] {
        var result: [Double] = []
        
        for i in 0..<(data.count - windowSize + 1) {
            let currentWindow = Array(data[i..<(i + windowSize)])
            let windowAvg = currentWindow.reduce(0, +) / Double(windowSize)
            result.append(windowAvg)
        }
        
        return result
    }
    
    func stdDev(arr: [Double]) -> Double {
        let avg = arr.reduce(0, +) / Double(arr.count)
        let sumOfSquares = arr.reduce(0) { $0 + ($1 - avg) * ($1 - avg) }
        return sqrt(sumOfSquares / Double(arr.count))
    }
    
    func handleToggleWalking() {
        if isWalking {
            // stop walking
            isWalking = false
            motionManager.stopAccelerometerUpdates()
        } else {
            // start walking
            accelerometerData.removeAll()
            peakTimes.removeAll()
            stepLength = 0
            waitingFor1stValue = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isWalking = true
                waitingFor1stValue = true
                waitingFor2ndValue = false
                waitingFor3rdValue = false
                isFirstPeakPositive = false
                lastPeakSign = -1
                lastPeakIndex = -1
                let vibrationDuration: Double = 0.9
                let vibrate = UIImpactFeedbackGenerator(style: .heavy)
                vibrate.prepare()
                for _ in 0..<Int(vibrationDuration * 10) {
                    vibrate.impactOccurred()
                    usleep(100000) // 100ms
                }
                if motionManager.isAccelerometerAvailable {
                    motionManager.accelerometerUpdateInterval = ACCELEROMETER_TIMING
                    motionManager.startAccelerometerUpdates(to: .main) {data, error in
                        if let data = data {
                            handleNewAccelerometerData(data: data)
                        }
                        
                    }
                }
            }
            
        }
    }
    
    func handleNewAccelerometerData(data: CMAccelerometerData) {
        accelerometerData.append(data)
        recentAccelData.append(data.acceleration.z)
        
        if recentAccelData.count > 20 {
            recentAccelData.removeFirst()
        }
        
        let zData = recentAccelData

        let stdDev = stdDev(arr: zData)
        let mean = zData.reduce(0, +) / Double(zData.count)
        dynamicThreshold = mean + stdDev * 1.5
        
        detectSteps()
    }
    
    func detectSteps() {
        let zData = accelerometerData.map { $0.acceleration.z }
        let mean = zData.reduce(0, +) / Double(zData.count)
        let variance = zData.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(zData.count)
        let stdDev = sqrt(variance)
        let dynamicThresholdZ = mean + stdDev * 0.5

        let currentIndex = zData.count - 1

        if currentIndex < 2 { return }

        let zDataCurr = zData[currentIndex]
        let zDataPrev = zData[currentIndex - 1]
        let DataTime = Double(currentIndex) / ACCELEROMETER_HZ

        if waitingFor1stValue && ((zDataCurr < threshold && zDataPrev > threshold) || (zDataCurr > threshold && zDataPrev < threshold)) {
            if lastPeakIndex == -1 || currentIndex - lastPeakIndex > Int(threshold) || currentIndex - lastPeakIndex > Int(dynamicThresholdZ) {
                if lastPeakSign == -1 {
                    if peakTimes.isEmpty {
                        peakTimes.append(DataTime)
                    } else {
                        peakTimes.append(DataTime)
                    }
                    lastPeakIndex = currentIndex
                    lastPeakSign = 1
                    isFirstPeakPositive = true
                    waitingFor1stValue = false
                    waitingFor2ndValue = true
                }
            }
        }

        if waitingFor2ndValue && ((zDataCurr < threshold && zDataPrev > threshold) || (zDataCurr > threshold && zDataPrev < threshold)) {
            if currentIndex - lastPeakIndex > Int(threshold) || currentIndex - lastPeakIndex > Int(dynamicThresholdZ) {
                if lastPeakSign == 1 {
                    peakTimes.append(DataTime)
                    lastPeakIndex = currentIndex
                    lastPeakSign = -1
                    waitingFor2ndValue = false
                    waitingFor1stValue = true
                }
            }
        }

        if peakTimes.count == 2 {
            let peak2 = peakTimes.last!
            let peak1 = peakTimes.first!
            let peakBetweenTime = peak2 - peak1
            let stepLengthEst = peakBetweenTime * gaitConstant * METERS_TO_INCHES

            stepLength = stepLengthEst
            stepLengthFirebase.append(stepLengthEst)
            let sec = Date().timeIntervalSince1970
            Task {
                await viewModel.updateStepLength(sec: sec, stepLengthEst: stepLengthEst)
            }
            print("STEP: \(stepLengthEst)")

            if vibrateOption == "Over Step Goal" {
                if vibrateValue == "Vibrate Phone" && stepLengthEst > goalStep {
                    let vibrate = UIImpactFeedbackGenerator(style: .heavy)
                    vibrate.prepare()
                    vibrate.impactOccurred()
                    playSound2()
                }
            }

            if vibrateOption == "Under Step Goal" {
                if vibrateValue == "Vibrate Phone" && stepLengthEst < goalStep {
                    let vibrate = UIImpactFeedbackGenerator(style: .heavy)
                    vibrate.prepare()
                    vibrate.impactOccurred()
                    playSound1()
                }
            }

            waitingFor1stValue = true
            peakTimes = [peakTimes.last!]
        }
    }

}

#Preview {
    MainPage()
}
