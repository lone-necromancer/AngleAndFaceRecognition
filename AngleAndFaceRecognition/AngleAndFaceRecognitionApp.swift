//
//  AngleAndFaceRecognitionApp.swift
//  AngleAndFaceRecognition
//
//  Created by Aviv Frenkel on 11/06/2023.
//

import SwiftUI

@main
struct AngleAndFaceRecognitionApp: App {
    private let motionManagerWrapper: MotionManagerWrapperProtocol = MotionManagerWrapper()
    private let faceRecognitionService: FaceRecognitionServiceProtocol = FaceRecognitionService()
    
    init() {
        let coloredNavAppearance = UINavigationBarAppearance()

        coloredNavAppearance.configureWithOpaqueBackground()
        coloredNavAppearance.backgroundColor = .systemBlue
        coloredNavAppearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredNavAppearance.backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredNavAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredNavAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
               
        UINavigationBar.appearance().standardAppearance = coloredNavAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredNavAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            MainView(viewModel: MainViewModel(motionManagerWrapper: motionManagerWrapper, faceRecognitionService: faceRecognitionService))
        }
    }
}
