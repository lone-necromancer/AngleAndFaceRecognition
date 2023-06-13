//
//  MainViewModel.swift
//  AngleAndFaceRecognition
//
//  Created by Aviv Frenkel on 11/06/2023.
//

import Foundation
import Combine

public final class MainViewModel: ObservableObject {
    private let motionManagerWrapper: MotionManagerWrapperProtocol
    private let faceRecognitionService: FaceRecognitionServiceProtocol
    
    @Published public var navigationState: NavigationState = .none
    
    public init(motionManagerWrapper: MotionManagerWrapperProtocol, faceRecognitionService: FaceRecognitionServiceProtocol) {
        self.motionManagerWrapper = motionManagerWrapper
        self.faceRecognitionService = faceRecognitionService
    }
    
    public func phoneAngleViewModel() -> PhoneAngleViewModel {
        PhoneAngleViewModel(motionManagerWrapper: motionManagerWrapper, faceRecognitionService: faceRecognitionService)
    }
    
    public func nagivateToPhoneAngle() {
        navigationState = .phoneAngle
    }
}

// MARK: - Encapsulated enums
extension MainViewModel {
    public enum NavigationState {
        case none
        case phoneAngle
    }
}
