//
//  CameraView.swift
//  VideoCameraApp
//
//  Created by David Emery on 4/20/26.
//

import SwiftUI

struct CameraView: View {
    
    @ObservedObject var viewModel: VideoMemoViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showingSaveSheet = false
    @State private var recordingTitle = ""
    
    @State private var recordingDuration: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if viewModel.cameraService.isSessionRunning {
                CameraPreviewView(session: viewModel.cameraService.getCaptureSession())
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack {
                topBar
                Spacer()
                
                if viewModel.cameraService.isRecording {
                    recordingIndicator
                }
                
                Spacer()
                controlsBar
            }
        }
        .onAppear {
            viewModel.cameraService.startSession()
        }
        .onDisappear {
            viewModel.cameraService.stopSession()
            
            if viewModel.cameraService.isRecording {
                viewModel.stopRecording()
            }
        }
        .sheet(isPresented: $showingSaveSheet) {
            SaveRecordingView(
                title: $recordingTitle,
                onSave: {
                    viewModel.saveRecording(title: recordingTitle)
                    recordingTitle = ""
                    dismiss()
                },
                onCancel: {
                    viewModel.cancelRecording()
                }
            )
        }
    }
    
    private var topBar: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
            .padding()
            
            Spacer()
        }
    }
    
    private var recordingIndicator: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.red)
                .frame(width: 12, height: 12)
                .opacity(0.8)
            
            Text(formatDuration(recordingDuration))
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.6))
        .cornerRadius(20)
    }
    
    private var controlsBar: some View {
        VStack(spacing: 20) {
            if !viewModel.cameraService.isRecording {
                Text("Tap to record")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            
            Button(action: {
                toggleRecording()
            }) {
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    if viewModel.cameraService.isRecording {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red)
                            .frame(width: 40, height: 40)
                    } else {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 70, height: 70)
                    }
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    private func toggleRecording() {
        if viewModel.cameraService.isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        recordingDuration = 0
        viewModel.startRecording()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingDuration += 0.1
        }
    }
    
    private func stopRecording() {
        viewModel.stopRecording()
        
        timer?.invalidate()
        timer = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingSaveSheet = true
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        let tenths = Int((duration.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, tenths)
    }
}

// Save view (no notes)
struct SaveRecordingView: View {
    
    @Binding var title: String
    
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter title", text: $title)
                }
            }
            .navigationTitle("Save Video Memo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

#Preview {
    CameraView(viewModel: VideoMemoViewModel())
}
