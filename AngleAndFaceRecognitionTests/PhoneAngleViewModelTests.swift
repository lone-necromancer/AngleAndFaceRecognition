//
//  PhoneAngleViewModelTests.swift
//  AngleAndFaceRecognitionTests
//
//  Created by Aviv Frenkel on 13/06/2023.
//

import XCTest
import AngleAndFaceRecognition
import Combine

final class PhoneAngleViewModelTests: XCTestCase {
    var subscriptions = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_test_navigation_state() {
        let expectation = expectation(description: "navigationState is .startTest")
        
        let viewModel = PhoneAngleViewModel(motionManagerWrapper: MotionManagerWrapperMock(mockTiltState: .failure(.DeviceMotionUnavailable), shouldFailStartMotionUpdates: false), faceRecognitionService: FaceRecognitionServiceMock(detectedFaceMock: false))
        
        XCTAssert(viewModel.navigationState == .none)
        
        viewModel.navigateToTest()
        
        viewModel.$navigationState
            .sink { state in
                if case .startTest = state {
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func test_face_detection_navigation_state() {
        let expectation = expectation(description: "navigationState is .startTest")
        
        let viewModel = PhoneAngleViewModel(motionManagerWrapper: MotionManagerWrapperMock(mockTiltState: .failure(.DeviceMotionUnavailable), shouldFailStartMotionUpdates: false), faceRecognitionService: FaceRecognitionServiceMock(detectedFaceMock: false))
        
        XCTAssert(viewModel.navigationState == .none)
        
        viewModel.navigateToFaceDetection()
        
        viewModel.$navigationState
            .sink { state in
                if case .faceDetection = state {
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func test_stop_motion_updates() {
        let expectation1 = expectation(description: "expectation is tooHigh as expected")
        let expectation2 = expectation(description: "navigationState is .startTest")
        
        let viewModel = PhoneAngleViewModel(motionManagerWrapper: MotionManagerWrapperMock(mockTiltState: .success(.tooHigh), shouldFailStartMotionUpdates: false), faceRecognitionService: FaceRecognitionServiceMock(detectedFaceMock: false))
                
        viewModel.$angle
            .sink { state in
                if case .tooHigh = state {
                    expectation1.fulfill()
                }
                if case .none = state {
                    expectation2.fulfill()
                }
            }
            .store(in: &subscriptions)
        
        viewModel.startMotionUpdates()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak viewModel] in
            viewModel?.stopMotionUpdates()
        })
        
        wait(for: [expectation1, expectation2], timeout: 2.0)
    }
    
    func test_start_motion_updates() {
        let expectation = expectation(description: "expectation is tooHigh as expected")
        
        let viewModel = PhoneAngleViewModel(motionManagerWrapper: MotionManagerWrapperMock(mockTiltState: .success(.tooHigh), shouldFailStartMotionUpdates: false), faceRecognitionService: FaceRecognitionServiceMock(detectedFaceMock: false))
                
        viewModel.$angle
            .sink { state in
                if case .tooHigh = state {
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)
        
        viewModel.startMotionUpdates()
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func test_start_motion_updates_failed_to_start_motion_updates() {
        let expectation = expectation(description: "reached angle with state other then .none value")
        expectation.isInverted = true
        
        let viewModel = PhoneAngleViewModel(motionManagerWrapper: MotionManagerWrapperMock(mockTiltState: .success(.tooHigh), shouldFailStartMotionUpdates: true), faceRecognitionService: FaceRecognitionServiceMock(detectedFaceMock: false))
                
        viewModel.$angle
            .sink { state in
                switch state {
                case .none:
                    break
                default:
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)
        
        viewModel.startMotionUpdates()
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func test_subscribe_to_face_recognition_updates_no_face_detected() {
        let expectation = expectation(description: "face not detected")
        
        let viewModel = PhoneAngleViewModel(motionManagerWrapper: MotionManagerWrapperMock(mockTiltState: .failure(.DeviceMotionUnavailable), shouldFailStartMotionUpdates: false), faceRecognitionService: FaceRecognitionServiceMock(detectedFaceMock: false))
        
        viewModel.$faceRecognitionUpdates
            .sink { detectedFace in
                if !detectedFace {
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)
                
        viewModel.subscribeToFaceRecognitionUpdates()
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func test_subscribe_to_face_recognition_updates_face_detected() {
        let expectation = expectation(description: "face detected")
        
        let faceRecognitionServiceMock = FaceRecognitionServiceMock(detectedFaceMock: true)
        let viewModel = PhoneAngleViewModel(motionManagerWrapper: MotionManagerWrapperMock(mockTiltState: .failure(.DeviceMotionUnavailable), shouldFailStartMotionUpdates: false), faceRecognitionService: faceRecognitionServiceMock)
        viewModel.subscribeToFaceRecognitionUpdates()
        
        viewModel.$faceRecognitionUpdates
            .sink { detectedFace in
                if detectedFace {
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)
                
        faceRecognitionServiceMock.sendCaptureOutputMockData()
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func test_unsubscribe_to_face_recognition_updates_are_not_coming() {
        let expectation = expectation(description: "face detected")
        expectation.isInverted = true
        
        let faceRecognitionServiceMock = FaceRecognitionServiceMock(detectedFaceMock: true)
        let viewModel = PhoneAngleViewModel(motionManagerWrapper: MotionManagerWrapperMock(mockTiltState: .failure(.DeviceMotionUnavailable), shouldFailStartMotionUpdates: false), faceRecognitionService: faceRecognitionServiceMock)
        viewModel.subscribeToFaceRecognitionUpdates()
        
        viewModel.$faceRecognitionUpdates
            .sink { detectedFace in
                if detectedFace {
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)
                
        viewModel.stopSubscribeToFaceRecognitionUpdates()
        faceRecognitionServiceMock.sendCaptureOutputMockData()
        
        wait(for: [expectation], timeout: 2.0)
    }

}
