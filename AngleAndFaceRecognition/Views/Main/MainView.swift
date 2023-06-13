//
//  MainView.swift
//  AngleAndFaceRecognition
//
//  Created by Aviv Frenkel on 11/06/2023.
//

import SwiftUI

struct MainView: View {
    
    @ObservedObject private var viewModel: MainViewModel
    @State private var phoneAngleViewActive: Bool = false
    
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }
    
    var title: some View {
        VStack {
            NavigationLink(destination: PhoneAngleView(viewModel: viewModel.phoneAngleViewModel()), isActive: $phoneAngleViewActive) { EmptyView() }
            Image(systemName: "magnifyingglass")
                .imageScale(.large)
                .foregroundColor(.accentColor)
                .padding()
            
            Text("In order to start the eye test, please click the button below")
                .multilineTextAlignment(.center)
                .font(.title)
                .padding(.horizontal, 30)
        }
        .offset(y: 30)
        .onReceive(viewModel.$navigationState) { output in
            if case .phoneAngle = output {
                phoneAngleViewActive = true
            } else {
                phoneAngleViewActive = false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                title

                Spacer()
                Button {
                    viewModel.nagivateToPhoneAngle()
                } label: {
                    Text("START TEST")
                }
                .buttonStyle(ScalingButton())
            }
            .navigationTitle("Lobby")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel(motionManagerWrapper: MotionManagerWrapper(), faceRecognitionService: FaceRecognitionService()))
    }
}
