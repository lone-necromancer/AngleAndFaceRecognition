//
//  MainViewModelTests.swift
//  AngleAndFaceRecognitionTests
//
//  Created by Aviv Frenkel on 13/06/2023.
//

import XCTest
import AngleAndFaceRecognition
import Combine

final class MainViewModelTests: XCTestCase {
    var subscriptions = Set<AnyCancellable>()
    
    func test_phone_angle_view_model_generator() {
        let viewModel = MainViewModel(motionManagerWrapper: MotionManagerWrapperMock(mockTiltState: .failure(.DeviceMotionUnavailable), shouldFailStartMotionUpdates: false), faceRecognitionService: FaceRecognitionServiceMock(detectedFaceMock: false))
        
        let phoneAngleViewModel = viewModel.phoneAngleViewModel()
        
        XCTAssert(phoneAngleViewModel.navigationState == .none)
        XCTAssert(phoneAngleViewModel.error == .none)
        XCTAssert(!phoneAngleViewModel.faceRecognitionUpdates)
    }
    
    func test_navigate_to_phone_angle() {
        let expectation = expectation(description: "navigationState is .phoneAngle")
        
        let viewModel = MainViewModel(motionManagerWrapper: MotionManagerWrapperMock(mockTiltState: .failure(.DeviceMotionUnavailable), shouldFailStartMotionUpdates: false), faceRecognitionService: FaceRecognitionServiceMock(detectedFaceMock: false))
        
        XCTAssert(viewModel.navigationState == .none)
        
        viewModel.nagivateToPhoneAngle()
        
        viewModel.$navigationState
            .sink { state in
                if case .phoneAngle = state {
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)
        
        wait(for: [expectation], timeout: 2.0)
    }
}
