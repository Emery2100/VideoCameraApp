//
//  CameraPreviewView.swift
//  VideoCameraApp
//
//  Created by David Emery on 4/20/26.
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
       
        let view = PreviewView()
        view.session = session
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
      
        uiView.session = session
    }
    
    class PreviewView: UIView {
        
       
        var session: AVCaptureSession? {
            didSet {
              
                previewLayer.session = session
            }
        }
        
        override class var layerClass: AnyClass {
            return AVCaptureVideoPreviewLayer.self
        }
        
        var previewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
        
      
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupPreviewLayer()
        }
        
       
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupPreviewLayer()
        }
        
      
        private func setupPreviewLayer() {
            previewLayer.videoGravity = .resizeAspectFill
        }
    }
}
