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
    @State private var isWalking = false
    @State private var stepLength: Double = 0
    @State private var goalStep: Double = 0
    @State private var range: Double = 30
    @State private var vibrateOption = "Over Step Goal"
    @State private var vibrateValue = "Vibrate Phone"
    @State private var isPlaying = false
    @State private var player: AVAudioPlayer?
    @State private var timer: Timer?
    
    @State private var accelerometerData: [CMAccelerometerData] = []
    
    
    private var motionManager = CMMotionManager()
    
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
                    
                    //                    let binding = Binding {
                    //                        isPlaying
                    //                    } set: {
                    //                        metronome(with: $0)
                    //                    }
                    
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
    
    func handleToggleWalking() {
        if isWalking {
            isWalking = false
        }
        isWalking = !isWalking
    }
}

#Preview {
    MainPage()
}
