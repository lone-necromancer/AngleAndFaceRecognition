//
//  MotionManagerWrapper.swift
//  AngleAndFaceRecognition
//
//  Created by Aviv Frenkel on 11/06/2023.
//

import Foundation
import CoreMotion
import Combine

public protocol MotionManagerWrapperProtocol {
    var tiltStatePublisher: AnyPublisher<MotionManagerWrapper.TiltState, MotionManagerWrapper.Error> { get }
    
    
    /// We use Quaternion to Euler angles conversion to determine the phone pitch attitude in radians,
    /// and then transform them into degrees.
    /// Then we validate that our phone pitch is between 70 - 110 degrees.
    /// - throws: In case the CMMotionManager object is not available, we will throw DeviceMotionUnavailable expection.
    /// - important: We are updating the tiltStatePublisher with any change that has happaned with the pitch attitude.
    func startMotionUpdates() throws
    func stopMotionUpdates()
}


public final class MotionManagerWrapper: MotionManagerWrapperProtocol {
    private var motionManager = CMMotionManager()
    private var tiltState = PassthroughSubject<TiltState, Error>()
    private var tiltTimer: Timer?
    private var tiltDuration: TimeInterval = 0.0
    
    public var tiltStatePublisher: AnyPublisher<TiltState, Error> {
        tiltState.eraseToAnyPublisher()
    }
    
    public init() {}
    
    public func startMotionUpdates() throws {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.5
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
                guard let motion = motion else {
                    self?.tiltState.send(completion: .failure(.couldNotFindMotionObject))
                    return
                }
                guard let self = self else {
                    self?.tiltState.send(completion: .failure(.couldNotCaputeSelf))
                    return
                }
                
                let quat = motion.attitude.quaternion
                let pitchRadians = atan2(2*(quat.x*quat.w + quat.y*quat.z), 1 - 2*quat.x*quat.x - 2*quat.z*quat.z)
                let pitch = abs(pitchRadians * 180.0  / .pi)
                if (70...110).contains(pitch) {
                    self.tiltDuration += 0.5
                    self.tiltState.send(.inRange(ReachedNeededTimer: false))
                } else if pitch > 110 {
                    self.tiltState.send(.tooLow)
                    self.invalidateTimer()
                    self.tiltTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                        self.tiltState.send(.inRange(ReachedNeededTimer: true))
                    }
                } else if pitch < 70 {
                    self.tiltState.send(.tooHigh)
                    self.invalidateTimer()
                    self.tiltTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                        self.tiltState.send(.inRange(ReachedNeededTimer: true))
                    }
                }
            }
        } else {
            throw Error.DeviceMotionUnavailable
        }
    }
    
    func invalidateTimer() {
        self.tiltDuration = 0.0
        self.tiltTimer?.invalidate()
    }
    
    public func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
        tiltTimer?.invalidate()
    }
}

// MARK: - Encapsulated Objects
public typealias MotionManagerWrapperError = MotionManagerWrapper.Error
public typealias MotionManagerWrapperTiltState = MotionManagerWrapper.TiltState

extension MotionManagerWrapper {
    public enum TiltState {
        case none
        case tooHigh
        case inRange(ReachedNeededTimer: Bool)
        case tooLow
    }
    
    public enum Error: Swift.Error {
        case couldNotCaputeSelf
        case couldNotFindMotionObject
        case DeviceMotionUnavailable
    }
}
