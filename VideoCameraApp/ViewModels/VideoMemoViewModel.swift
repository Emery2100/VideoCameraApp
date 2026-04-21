//
//  VideoMemoViewModel.swift
//  VideoCameraApp
//
//  Created by David Emery on 4/20/26.
//

import Foundation
import AVFoundation
import SwiftUI

class VideoMemoViewModel: ObservableObject {
    
    @Published var videoMemos: [VideoMemo] = []
    @Published var cameraService = CameraService()
    @Published var selectedMemo: VideoMemo?
    @Published var showingDetailSheet = false
    @Published var showingCameraSheet = false
    @Published var temporaryVideoURL: URL?
    
    private let fileManager = FileManager.default
    
    private var memosFileURL: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("videoMemos.json")
    }
    
    init() {
        loadMemos()
        cameraService.setupCamera()
    }
    
    func startRecording() {
        if !cameraService.isSessionRunning {
            cameraService.startSession()
        }
        
        cameraService.startRecording { [weak self] url in
            DispatchQueue.main.async {
                self?.temporaryVideoURL = url
            }
        }
    }
    
    func stopRecording() {
        cameraService.stopRecording()
    }
    
    func saveRecording(title: String) {
        guard let tempURL = temporaryVideoURL else {
            print("No temporary video to save")
            return
        }
        
        let fileName = "video_\(UUID().uuidString).mov"
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(fileName)
        
        do {
            try fileManager.moveItem(at: tempURL, to: destinationURL)
            
            let asset = AVAsset(url: destinationURL)
            let duration = asset.duration.seconds
            
            let newMemo = VideoMemo(
                title: title.isEmpty ? "Untitled Video" : title,
                videoFileName: fileName,
                duration: duration
            )
            
            videoMemos.insert(newMemo, at: 0)
            saveMemos()
            temporaryVideoURL = nil
            
        } catch {
            print("Error saving video: \(error.localizedDescription)")
        }
    }
    
    func cancelRecording() {
        if let tempURL = temporaryVideoURL {
            try? fileManager.removeItem(at: tempURL)
        }
        temporaryVideoURL = nil
    }
    
    func deleteMemo(_ memo: VideoMemo) {
        try? fileManager.removeItem(at: memo.videoURL)
        videoMemos.removeAll { $0.id == memo.id }
        saveMemos()
    }
    
    func updateMemo(_ memo: VideoMemo, title: String) {
        if let index = videoMemos.firstIndex(where: { $0.id == memo.id }) {
            videoMemos[index].title = title
            saveMemos()
        }
    }
    
    func openMemo(_ memo: VideoMemo) {
        selectedMemo = memo
        showingDetailSheet = true
    }
    
    private func saveMemos() {
        do {
            let data = try JSONEncoder().encode(videoMemos)
            try data.write(to: memosFileURL)
        } catch {
            print("Error saving memos: \(error.localizedDescription)")
        }
    }
    
    private func loadMemos() {
        guard fileManager.fileExists(atPath: memosFileURL.path) else {
            print("No saved memos found")
            return
        }
        
        do {
            let data = try Data(contentsOf: memosFileURL)
            let memos = try JSONDecoder().decode([VideoMemo].self, from: data)
            self.videoMemos = memos
        } catch {
            print("Error loading memos: \(error.localizedDescription)")
        }
    }
    
    func checkPermissions(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            checkMicrophonePermission(completion: completion)
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.checkMicrophonePermission(completion: completion)
                } else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
            
        default:
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
    
    private func checkMicrophonePermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            DispatchQueue.main.async {
                completion(true)
            }
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
            
        default:
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
}
