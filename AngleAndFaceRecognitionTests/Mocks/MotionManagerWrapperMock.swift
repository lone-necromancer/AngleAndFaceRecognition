//
//  MotionManagerWrapperMock.swift
//  AngleAndFaceRecognitionTests
//
//  Created by Aviv Frenkel on 13/06/2023.
//

import Foundation
import AngleAndFaceRecognition
import Combine

public final class MotionManagerWrapperMock: MotionManagerWrapperProtocol {
    public var tiltStatePublisher: AnyPublisher<MotionManagerWrapperTiltState, MotionManagerWrapperError> {
        mockTiltStateSubject.eraseToAnyPublisher()
    }
    public let mockTiltState: Result<MotionManagerWrapperTiltState, MotionManagerWrapperError>
    public let shouldFailStartMotionUpdates: Bool
    
    private var mockTiltStateSubject = PassthroughSubject<MotionManagerWrapperTiltState, MotionManagerWrapperError>()
    
    init(mockTiltState: Result<MotionManagerWrapperTiltState, MotionManagerWrapperError>, shouldFailStartMotionUpdates: Bool) {
        self.mockTiltState = mockTiltState
        self.shouldFailStartMotionUpdates = shouldFailStartMotionUpdates
    }
    
    public func startMotionUpdates() throws {
        if shouldFailStartMotionUpdates {
            throw MotionManagerWrapperError.DeviceMotionUnavailable
        } else {
            switch mockTiltState {
            case .success(let state):
                mockTiltStateSubject.send(state)
            case .failure(let error):
                mockTiltStateSubject.send(completion: .failure(error))
            }
        }
    }
    
    /// Currently no reason to test this function since it's a system SDK logic and nothing more
    public func stopMotionUpdates() {}
    
    
}
