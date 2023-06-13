//
//  FaceRecognitionServiceMock.swift
//  AngleAndFaceRecognitionTests
//
//  Created by Aviv Frenkel on 13/06/2023.
//

import Foundation
import AngleAndFaceRecognition
import XCTest
import Combine
import AVFoundation

public final class FaceRecognitionServiceMock: NSObject, FaceRecognitionServiceProtocol {
    public var detectedFacePublisher: AnyPublisher<Bool, Never> {
        detectedFaceSubject.eraseToAnyPublisher()
    }
    
    private var detectedFaceSubject = CurrentValueSubject<Bool, Never>(false)
    private var detectedFaceMock: Bool
    
    init(detectedFaceMock: Bool) {
        self.detectedFaceMock = detectedFaceMock
        super.init()
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        detectedFaceSubject.send(detectedFaceMock)
    }
    
    public func sendCaptureOutputMockData() {
        let captureConnection = AVCaptureConnection(inputPorts: [AVCaptureInput.Port](), output: AVCapturePhotoOutput())
        self.captureOutput(AVCapturePhotoOutput(), didOutput: getCMSampleBuffer(), from: captureConnection)
    }
    
    fileprivate func getCMSampleBuffer() -> CMSampleBuffer {
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, 100, 100, kCVPixelFormatType_32BGRA, nil, &pixelBuffer)

        var info = CMSampleTimingInfo()
        info.presentationTimeStamp = CMTime.zero
        info.duration = CMTime.invalid
        info.decodeTimeStamp = CMTime.invalid

        var formatDesc: CMFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                     imageBuffer: pixelBuffer!,
                                                     formatDescriptionOut: &formatDesc)

        var sampleBuffer: CMSampleBuffer?

        CMSampleBufferCreateReadyWithImageBuffer(allocator: kCFAllocatorDefault,
                                                 imageBuffer: pixelBuffer!,
                                                 formatDescription: formatDesc!,
                                                 sampleTiming: &info,
                                                 sampleBufferOut: &sampleBuffer)

        return sampleBuffer!
    }
    
}
