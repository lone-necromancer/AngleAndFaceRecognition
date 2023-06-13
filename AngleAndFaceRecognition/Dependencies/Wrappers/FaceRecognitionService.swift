//
//  FaceRecognitionService.swift
//  AngleAndFaceRecognition
//
//  Created by Aviv Frenkel on 12/06/2023.
//

import Foundation
import Vision
import Combine
import AVFoundation

public protocol FaceRecognitionServiceProtocol: AVCaptureVideoDataOutputSampleBufferDelegate {
    var detectedFacePublisher: AnyPublisher<Bool, Never> { get }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
}

public final class FaceRecognitionService: NSObject, FaceRecognitionServiceProtocol {
    let faceDetectionRequest = VNDetectFaceRectanglesRequest()
    var detectedFaceSubject = CurrentValueSubject<Bool, Never>(false)
    public var detectedFacePublisher: AnyPublisher<Bool, Never> {
        detectedFaceSubject.eraseToAnyPublisher()
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let requestHandler = VNSequenceRequestHandler()
        do {
            try requestHandler.perform([faceDetectionRequest], on: imageBuffer, orientation: .up)
            
            guard let detectedFaces = faceDetectionRequest.results,
                  detectedFaces.count > 0 else {
                detectedFaceSubject.send(false)
                return
            }
            detectedFaceSubject.send(true)
            
        } catch {
            print("Face detection request failed with error: \(error.localizedDescription)")
        }
    }
}
