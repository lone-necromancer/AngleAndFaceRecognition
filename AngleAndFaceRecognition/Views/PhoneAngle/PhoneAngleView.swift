//
//  PhoneAngleView.swift
//  AngleAndFaceRecognition
//
//  Created by Aviv Frenkel on 11/06/2023.
//

import SwiftUI
import CoreMotion

struct PhoneAngleView: View {
    @ObservedObject private var viewModel: PhoneAngleViewModel
    
    @State private var isAngleLowAnimating = false
    @State private var isAngleLowShowing = false
    @State private var isAngleHighAnimating = false
    @State private var isAngleHighShowing = false
    @State private var title = "Move your phone to the designated position"
    @State private var subTitle = ""
    @State private var faceDetectionViewActive = false
    @State private var startTestActive = false
    @State private var buttonEnabled = false
    
    init(viewModel: PhoneAngleViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        onReceives {
            ZStack {
                NavigationLink(destination: StartTestView(viewModel: viewModel.startTestViewModel()), isActive: $startTestActive) { EmptyView() }

                if faceDetectionViewActive {
                    faceDetectionView()
                }

                phoneAngleView()
            }
            .navigationTitle("Angle Placement")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.startMotionUpdates()
            }
            .onDisappear {
                viewModel.stopMotionUpdates()
            }
        }
    }
}

// MARK: - Private API
private extension PhoneAngleView {
    @ViewBuilder func phoneAngleView() -> some View {
        VStack {
            lowAngleAnimation()
            
            Text(title)
                .font(.title)
                .multilineTextAlignment(.center)
            Text(subTitle)
                .font(.caption)
                .multilineTextAlignment(.center)
                .opacity(subTitle == "" ? 0 : 1)
                .animation(.easeInOut)
            
            highAngleAnimation()
        }
    }
    
    @ViewBuilder func faceDetectionView() -> some View {
        ZStack {
            CameraView(faceRecognitionService: viewModel.faceRecognitionService)
            VStack {
                Spacer()
                Button {
                    viewModel.navigateToTest()
                } label: {
                    Text("START TEST")
                }
                .padding()
                .foregroundColor(.white)
                .clipShape(Capsule())
                .buttonStyle(ScalingButton(enabled: $buttonEnabled))
                .padding(16)
                .animation(.easeInOut)
            }
        }
    }
    
    @ViewBuilder func onReceives<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .onReceive(viewModel.$navigationState, perform: { state in
                switch state {
                case .faceDetection:
                    subTitle = ""
                    title = ""
                    self.faceDetectionViewActive = true
                    viewModel.subscribeToFaceRecognitionUpdates()
                case .startTest:
                    subTitle = ""
                    startTestActive = true
                    viewModel.stopSubscribeToFaceRecognitionUpdates()
                default:
                    title = "Move your phone to the designated position"
                    subTitle = ""
                    isAngleHighShowing = false
                    isAngleHighAnimating = false
                    isAngleLowShowing = false
                    isAngleLowAnimating = false
                    faceDetectionViewActive = false
                    viewModel.stopSubscribeToFaceRecognitionUpdates()
                    break
                }
                
            })
            .onReceive(viewModel.$angle) { output in
                switch output {
                case .tooHigh:
                    title = "Move your phone to the designated position"
                    subTitle = ""
                    isAngleHighAnimating = true
                    isAngleHighShowing = true
                    isAngleLowShowing = false
                    isAngleLowAnimating = false
                case .tooLow:
                    title = "Move your phone to the designated position"
                    subTitle = ""
                    isAngleHighShowing = false
                    isAngleHighAnimating = false
                    isAngleLowAnimating = true
                    isAngleLowShowing = true
                case .inRange(let ReachedNeededTimer):
                    isAngleHighAnimating = false
                    isAngleHighShowing = false
                    isAngleLowAnimating = false
                    isAngleLowShowing = false
                    if ReachedNeededTimer {
                        subTitle = ""
                        title = "Great now we can move on to the next step"
                        viewModel.navigateToFaceDetection()
                    } else {
                        subTitle = "Hold your position for a bit longer"
                    }
                case .none:
                    isAngleHighAnimating = false
                    isAngleHighShowing = false
                    isAngleLowAnimating = false
                    isAngleLowShowing = false
                    subTitle = ""
                    title = "Move your phone to the designated position"
                }
            }
            .onReceive(viewModel.$faceRecognitionUpdates) { output in
                buttonEnabled = output
            }
    }
    
    @ViewBuilder func lowAngleAnimation() -> some View {
        VStack {
            Image(systemName: "arrow.up")
                .font(.largeTitle)
            
            Text("Turn outside of your face")
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .offset(y: isAngleLowAnimating ? -80 : 0)
        .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true))
        .opacity(isAngleLowShowing ? 1 : 0)
    }
    
    @ViewBuilder func highAngleAnimation() -> some View {
        VStack {
            Text("Turn down towards your face")
                .multilineTextAlignment(.center)
                .padding()
            Image(systemName: "arrow.down")
                .font(.largeTitle)
        }
        .padding()
        .offset(y: isAngleHighAnimating ? 80 : 0)
        .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true))
        .opacity(isAngleHighShowing ? 1 : 0)
    }
}

struct PhoneAngleView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneAngleView(viewModel: PhoneAngleViewModel(motionManagerWrapper: MotionManagerWrapper(), faceRecognitionService: FaceRecognitionService()))
    }
}
