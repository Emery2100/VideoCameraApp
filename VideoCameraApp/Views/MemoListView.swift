//
//  MemoListView.swift
//  VideoCameraApp
//
//  Created by David Emery on 4/20/26.
//

import SwiftUI

struct MemoListView: View {
    
    @StateObject private var viewModel = VideoMemoViewModel()
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.videoMemos.isEmpty {
                    emptyStateView
                } else {
                    memosList
                }
            }
            .navigationTitle("Video Memos")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        openCamera()
                    }) {
                        Image(systemName: "video.badge.plus")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCameraSheet) {
                CameraView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingDetailSheet) {
                if let memo = viewModel.selectedMemo {
                    VideoPlayerView(memo: memo, viewModel: viewModel)
                }
            }
            .alert("Camera Access Required", isPresented: $showingPermissionAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Please enable camera and microphone access in Settings to record video memos.")
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "video.slash")
                .font(.system(size: 70))
                .foregroundColor(.gray)
            
            Text("No Video Memos Yet")
                .font(.title2)
                .bold()
            
            Text("Tap the + button to record your first video memo")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                openCamera()
            }) {
                Label("Record Video Memo", systemImage: "video.badge.plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
    }
    
    private var memosList: some View {
        List {
            ForEach(viewModel.videoMemos) { memo in
                MemoRowView(memo: memo)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.openMemo(memo)
                    }
            }
            .onDelete(perform: deleteMemos)
        }
        .listStyle(.insetGrouped)
    }
    
    private func openCamera() {
        viewModel.checkPermissions { granted in
            if granted {
                viewModel.showingCameraSheet = true
            } else {
                showingPermissionAlert = true
            }
        }
    }
    
    private func deleteMemos(at offsets: IndexSet) {
        let memosToDelete = offsets.map { viewModel.videoMemos[$0] }
        memosToDelete.forEach { memo in
            viewModel.deleteMemo(memo)
        }
    }
}

struct MemoRowView: View {
    
    let memo: VideoMemo
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "play.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(memo.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(memo.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(memo.formattedDuration)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    MemoListView()
}

#Preview("With Data") {
    let viewModel = VideoMemoViewModel()
    viewModel.videoMemos = VideoMemo.samples
    
    return NavigationView {
        List {
            ForEach(VideoMemo.samples) { memo in
                MemoRowView(memo: memo)
            }
        }
        .navigationTitle("Video Memos")
    }
}
