//
//  CameraService.swift
//  VideoCameraApp
//
//  Created by David Emery on 4/20/26.
//

import AVFoundation
import UIKit
import Combine

class CameraService: NSObject, ObservableObject {

    
    @Published var isRecording = false
    
    @Published var isSessionRunning = false
    
    @Published var errorMessage: String?
    
    private let captureSession = AVCaptureSession()
    
    private var movieFileOutput: AVCaptureMovieFileOutput?
    
    private let sessionQueue = DispatchQueue(label: "com.videomemo.sessionQueue")
    
    private var recordingCompletionHandler: ((URL) -> Void)?
    
    func setupCamera() {
       
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.captureSession.beginConfiguration()
            
            self.captureSession.sessionPreset = .high
            

            self.setupVideoInput()
            

            self.setupAudioInput()
            
        
            self.setupMovieOutput()
            
        
            self.captureSession.commitConfiguration()
            
    
            DispatchQueue.main.async {
                self.isSessionRunning = false
            }
        }
    }
    
   
    private func setupVideoInput() {

        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video,
                                                        position: .back) else {
            handleError("Unable to access camera")
            return
        }
        
        do {
        
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            
        
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                handleError("Unable to add video input")
            }
        } catch {
            handleError("Error setting up camera: \(error.localizedDescription)")
        }
    }
    
 
    private func setupAudioInput() {
     
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
            handleError("Unable to access microphone")
            return
        }
        
        do {
         
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            
          
            if captureSession.canAddInput(audioInput) {
                captureSession.addInput(audioInput)
            } else {
                handleError("Unable to add audio input")
            }
        } catch {
            handleError("Error setting up microphone: \(error.localizedDescription)")
        }
    }
    
    private func setupMovieOutput() {
        let output = AVCaptureMovieFileOutput()
        
 
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
            self.movieFileOutput = output
        } else {
            handleError("Unable to add movie output")
        }
    }
    

    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
       
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
 
                DispatchQueue.main.async {
                    self.isSessionRunning = true
                }
            }
        }
    }
 
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
    
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
                
                DispatchQueue.main.async {
                    self.isSessionRunning = false
                }
            }
        }
    }
    
    func getCaptureSession() -> AVCaptureSession {
        return captureSession
    }
    
    func startRecording(completion: @escaping (URL) -> Void) {
       
        self.recordingCompletionHandler = completion
        
        sessionQueue.async { [weak self] in
            guard let self = self,
                  let movieOutput = self.movieFileOutput else { return }
            
          
            let fileName = "video_\(UUID().uuidString).mov"

            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            movieOutput.startRecording(to: tempURL, recordingDelegate: self)
            
      
            DispatchQueue.main.async {
                self.isRecording = true
            }
        }
    }

    func stopRecording() {
        sessionQueue.async { [weak self] in
            guard let self = self,
                  let movieOutput = self.movieFileOutput else { return }
            
            movieOutput.stopRecording()
            
            DispatchQueue.main.async {
                self.isRecording = false
            }
        }
    }
    
    private func handleError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
        }
    }
}

extension CameraService: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput,
                   didFinishRecordingTo outputFileURL: URL,
                   from connections: [AVCaptureConnection],
                   error: Error?) {
        
        if let error = error {
            handleError("Recording error: \(error.localizedDescription)")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.recordingCompletionHandler?(outputFileURL)
        }
    }
}
