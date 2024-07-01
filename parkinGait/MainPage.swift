//
//  MainPage.swift
//  parkinGait
//
//  Created by 신창민 on 6/23/24.
//

import SwiftUI
import CoreMotion

struct MainPage: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isWalking = false
    @State private var stepLength: Double = 0
    @State private var goalStep: Double = 0
    @State private var isEnabled = false
    @State private var range: Double = 30
    @State private var vibrateOption = "Over Step Goal"
    @State private var vibrateValue = "Vibrate Phone"
    
    let bgColor = Color(red: 0.8706, green: 0.8549, blue: 0.8235)
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                VStack {
                    Text("Gait Tracker Home Page")
                        .font(.largeTitle)
                        .padding(.top, 20)
                    
                    //                    Button(action: handleToggleWalking) {
                    //                        Text(isWalking ? "Stop Walking" : "Start Walking")
                    //                            .font(.title)
                    //                            .padding()
                    //                            .background(Color.green)
                    //                            .foregroundColor(.white)
                    //                            .cornerRadius(5)
                    //                    }
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
                    
                    Toggle(isOn: $isEnabled) {
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                    .padding(.horizontal, 200)
                    .padding(.top, 10)
                    
                    Text("\(Int(range)) Steps per Minute")
                        .font(.title2)
                    
                    Slider(value: $range, in: 30...120, step: 1)
                        .padding(.horizontal, 50)
                        .padding(.bottom, 20)
                    
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
}

#Preview {
    MainPage()
}
