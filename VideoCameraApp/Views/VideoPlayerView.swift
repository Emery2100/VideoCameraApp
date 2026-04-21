//
//  VideoPlayerView.swift
//  VideoCameraApp
//
//  Created by David Emery on 4/20/26.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    
    let memo: VideoMemo
    @ObservedObject var viewModel: VideoMemoViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showingDeleteAlert = false
    @State private var isEditing = false
    @State private var editedTitle: String
    
    @State private var player: AVPlayer
    
    init(memo: VideoMemo, viewModel: VideoMemoViewModel) {
        self.memo = memo
        self.viewModel = viewModel
        
        _player = State(initialValue: AVPlayer(url: memo.videoURL))
        _editedTitle = State(initialValue: memo.title)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VideoPlayer(player: player)
                    .frame(height: 300)
                    .onAppear {
                        player.seek(to: .zero)
                    }
                    .onDisappear {
                        player.pause()
                    }
                
                if isEditing {
                    editingForm
                } else {
                    infoSection
                }
                
                Spacer()
            }
            .navigationTitle("Video Memo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    if isEditing {
                        Button("Save") {
                            saveEdits()
                        }
                        .bold()
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                    }
                }
                
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            .alert("Delete Video Memo?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteMemo()
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
    
    private var infoSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Title")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(memo.title)
                        .font(.title2)
                        .bold()
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Date Created")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(memo.formattedDate)
                        .font(.body)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(memo.formattedDuration)
                        .font(.body)
                }
            }
            .padding()
        }
    }
    
    private var editingForm: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Title", text: $editedTitle)
            }
        }
    }
    
    private func saveEdits() {
        viewModel.updateMemo(memo, title: editedTitle)
        isEditing = false
    }
    
    private func deleteMemo() {
        viewModel.deleteMemo(memo)
        dismiss()
    }
}

#Preview {
    VideoPlayerView(
        memo: VideoMemo.samples[0],
        viewModel: VideoMemoViewModel()
    )
}
