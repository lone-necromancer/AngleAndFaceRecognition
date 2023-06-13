//
//  CameraView.swift
//  AngleAndFaceRecognition
//
//  Created by Aviv Frenkel on 12/06/2023.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    let captureSession = AVCaptureSession()
    private let faceRecognitionService: FaceRecognitionServiceProtocol
    
    init(faceRecognitionService: FaceRecognitionServiceProtocol) {
        self.faceRecognitionService = faceRecognitionService
    }

    func makeUIView(context: Context) -> UIView {
        var previewView = UIView(frame: UIScreen.main.bounds)
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            addCaptureSession(&previewView)
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    DispatchQueue.main.async {
                        addCaptureSession(&previewView)
                    }
                } else {
                    debugPrint("Authorization Denied")
                    #warning("TODO: implement a dialog requesting user to move to settings")
                }
            })
        }

        return previewView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    private func addMissingCameraLabel(_ superView: UIView) {
        let title = UILabel()
        title.text = "Camera is not available"

        title.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: superView.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: superView.centerYAnchor),
            title.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 16),
            title.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -16)
        ])
    }

    private func addCaptureSession(_ superView: inout UIView) {
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: frontCamera) else {

            addMissingCameraLabel(superView)
            return
        }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)

            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = superView.bounds
            superView.layer.addSublayer(previewLayer)

            DispatchQueue.global(qos: .utility).async {
                captureSession.startRunning()
            }
        } else {
            addMissingCameraLabel(superView)
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            let videoQueue = DispatchQueue(label: "videoQueue")
            videoOutput.setSampleBufferDelegate(faceRecognitionService, queue: videoQueue)
        }

    }
}
