//
//  PhoneAngleViewModel.swift
//  AngleAndFaceRecognition
//
//  Created by Aviv Frenkel on 11/06/2023.
//

import Foundation
import Combine

public final class PhoneAngleViewModel: ObservableObject {
    private let motionManagerWrapper: MotionManagerWrapperProtocol
    private(set) var faceRecognitionService: FaceRecognitionServiceProtocol
    
    @Published public private(set) var angle: MotionManagerWrapperTiltState = .none
    @Published public private(set) var error: Error = .none
    @Published public private(set) var navigationState: NavigationState = .none
    @Published public private(set) var faceRecognitionUpdates: Bool = false
    
    private var subscribers = Set<AnyCancellable>()
    private var detectedFaceSubscriber: AnyCancellable?
    
    public init(motionManagerWrapper: MotionManagerWrapperProtocol, faceRecognitionService: FaceRecognitionServiceProtocol) {
        self.motionManagerWrapper = motionManagerWrapper
        self.faceRecognitionService = faceRecognitionService
        motionManagerWrapper.tiltStatePublisher
            .mapError({ error -> Error in
                switch error {
                case .couldNotCaputeSelf:
                    return .applicationIssue
                case .couldNotFindMotionObject, .DeviceMotionUnavailable:
                    return .motionManagerIssue
                }
            })
            .sink(receiveCompletion: { [weak self] completion in guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.error = error
                }
            }, receiveValue: { [weak self] state in guard let self = self else { return }
                self.angle = state
            })
            .store(in: &subscribers)
    }
    
    public func subscribeToFaceRecognitionUpdates() {
        detectedFaceSubscriber = faceRecognitionService.detectedFacePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in guard let self = self else { return }
                self.faceRecognitionUpdates = output
            }
    }
    
    public func stopSubscribeToFaceRecognitionUpdates() {
        detectedFaceSubscriber?.cancel()
    }
    
    public func startMotionUpdates() {
        do {
            try motionManagerWrapper.startMotionUpdates()
        } catch let error {
            switch error {
            case MotionManagerWrapperError.DeviceMotionUnavailable:
                break
                
            default:
                break
            }
        }
    }
    
    public func stopMotionUpdates() {
        motionManagerWrapper.stopMotionUpdates()
        angle = .none
    }
    
    public func navigateToFaceDetection() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
            self?.navigationState = .faceDetection
        })
    }
    
    public func navigateToTest() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
            self?.navigationState = .startTest
        })
    }
    
    public func startTestViewModel() -> StartTestViewModel {
        StartTestViewModel()
    }
}

// MARK: - Encapsulated Objects
extension PhoneAngleViewModel {
    public enum Error: Swift.Error {
        case applicationIssue
        case motionManagerIssue
        case none
    }
    
    public enum NavigationState {
        case none
        case faceDetection
        case startTest
    }
}
