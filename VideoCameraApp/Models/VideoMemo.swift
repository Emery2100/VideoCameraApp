//
//  VideoMemo.swift
//  VideoCameraApp
//
//  Created by David Emery on 4/20/26.
//

import Foundation

struct VideoMemo: Identifiable, Codable {

    let id: UUID
    
    var title: String
    
    var notes: String
    
    let dateCreated: Date
    
    let videoFileName: String
    
    var duration: Double?
    
    var videoURL: URL {

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
        return documentsPath.appendingPathComponent(videoFileName)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dateCreated)
    }
    
    var formattedDuration: String {
        guard let duration = duration else {
            return "Unknown"
        }
        
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    

    init(title: String, notes: String, videoFileName: String, duration: Double? = nil) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.dateCreated = Date()
        self.videoFileName = videoFileName
        self.duration = duration
    }
}

extension VideoMemo {
  
    static var samples: [VideoMemo] {
        [
            VideoMemo(
                title: "Morning Meeting Notes",
                notes: "Discussed Q1 goals and team assignments",
                videoFileName: "sample1.mov",
                duration: 125.0
            ),
            VideoMemo(
                title: "Quick Idea",
                notes: "App feature brainstorming",
                videoFileName: "sample2.mov",
                duration: 45.0
            ),
            VideoMemo(
                title: "Recipe Tutorial",
                notes: "How to make chocolate chip cookies",
                videoFileName: "sample3.mov",
                duration: 320.0
            )
        ]
    }
}
