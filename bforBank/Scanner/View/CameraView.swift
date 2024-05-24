//
//  CameraView.swift
//  bforBank
//
//  Created by Ines BOKRI on 23/05/2024.
//
import SwiftUI
import AVFoundation
import Vision

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var coordinator: Coordinator

    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
        
        let regionOfInterest = CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)
        var requests: [VNRecognizeTextRequest] = []
        @Published var detectedIban: String?
        
        override init() {
            super.init()
            setupVision()
        }
        
        private func setupVision() {
            let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                
                for observation in observations {
                    guard let topCandidate = observation.topCandidates(1).first else { return }
                    
                    let detectedText = topCandidate.string
                    print("Detected text: \(detectedText)")
                    
                    let ibanPattern = "FR[0-9A-Z]{25}"
                    if let ibanRange = detectedText.range(of: ibanPattern, options: .regularExpression),
                       NSPredicate(format: "SELF MATCHES %@", ibanPattern).evaluate(with: detectedText[ibanRange]) {
                        DispatchQueue.main.async {
                            self.detectedIban = String(detectedText[ibanRange]).replacingOccurrences(of: " ", with: "")
                            print("---detected Iban----: \(self.detectedIban!)")
                        }
                    }
                }
            }
            textRecognitionRequest.recognitionLevel = .accurate
            textRecognitionRequest.usesLanguageCorrection = true
            self.requests = [textRecognitionRequest]
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetHeight(pixelBuffer)
            let region = CGRect(x: Int(regionOfInterest.origin.x * CGFloat(width)),
                                y: Int(regionOfInterest.origin.y * CGFloat(height)),
                                width: Int(regionOfInterest.size.width * CGFloat(width)),
                                height: Int(regionOfInterest.size.height * CGFloat(height)))
            guard self.cropPixelBuffer(pixelBuffer, toRegion: region) != nil else { return }
            
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            do {
                try requestHandler.perform(self.requests)
            } catch {
                print("Error performing text recognition request: \(error)")
            }
        }
        
        private func cropPixelBuffer(_ pixelBuffer: CVPixelBuffer, toRegion region: CGRect) -> CVPixelBuffer? {
            CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
            let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
            let data = baseAddress! + Int(region.origin.y) * bytesPerRow + Int(region.origin.x) * 4
            var croppedPixelBuffer: CVPixelBuffer?
            let status = CVPixelBufferCreateWithBytes(nil, Int(region.size.width), Int(region.size.height), kCVPixelFormatType_32BGRA, data, bytesPerRow, nil, nil, nil, &croppedPixelBuffer)
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
            if status != kCVReturnSuccess {
                print("Error: could not create new pixel buffer")
                return nil
            }
            return croppedPixelBuffer
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return viewController }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return viewController
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return viewController
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
        } else {
            return viewController
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        DispatchQueue.main.async {
            captureSession.startRunning()
        }
        videoOutput.setSampleBufferDelegate(coordinator, queue: DispatchQueue(label: "videoQueue"))
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
