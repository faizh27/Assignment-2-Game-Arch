///
/// Source:
/// https://github.com/mgsulaiman/ZoomPanRotationView/blob/main/ZoomView/ZoomView.swift
///
import SwiftUI
import UIKit

class CustomSceneView: UIView, UIGestureRecognizerDelegate {
    var mainScene: Assignment1Crate?

    
    override init(frame: CGRect) {
        super.init(frame: frame)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
      
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
//        
//        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))
//        rotationGesture.delegate = self
//        addGestureRecognizer(rotationGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGesture(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = self
        addGestureRecognizer(doubleTapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handlePinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        mainScene?.handleZoom(scale: recognizer.scale)
        recognizer.scale = 1.0
    }

    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        let offsetSize = CGSize(width: translation.x, height: translation.y)
        // print(recognizer.numberOfTouches)
        if recognizer.numberOfTouches == 1 {
            mainScene?.handleDrag(offset: offsetSize)
        } else if recognizer.numberOfTouches == 2 {
            mainScene?.handleDoubleTouchPan(translation: translation)
        }
    }
//    	
//    @objc func handleRotationGesture(_ recognizer: UIRotationGestureRecognizer) {
//        imageView.transform = imageView.transform.rotated(by: recognizer.rotation)
//        recognizer.rotation = 0
//    }
    	
    @objc func handleDoubleTapGesture(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            mainScene?.handleDoubleTap()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

struct ZoomAndPanAndRotationView: UIViewRepresentable {
    var mainScene: Assignment1Crate
    
    func makeUIView(context: Context) -> CustomSceneView {
        let customImageView = CustomSceneView()
        customImageView.mainScene = mainScene
        return customImageView
    }
    
    func updateUIView(_ uiView: CustomSceneView, context: Context) {
//
    }
}
