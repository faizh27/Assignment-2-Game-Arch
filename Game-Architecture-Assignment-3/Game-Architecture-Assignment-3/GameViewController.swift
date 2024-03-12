//
//  GameViewController.swift
//  Game-Architecture-Assignment-3
//
//  Created by Jun Solomon on 2024-03-08.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    let paddleMoveSpeed: Float = 0.2
    var arkanoidScene: Arkanoid!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // create a new scene
        arkanoidScene = Arkanoid()
        
        // set the scene to the view
        scnView.scene = arkanoidScene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // Add a pan gesture recognizer to handle paddle movement
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        scnView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
        let translationX = Float(translation.x)
        
        guard let paddleNode = arkanoidScene.rootNode.childNode(withName: "Paddle", recursively: true) else {
            return // Ensure paddle node exists
        }
        
        // Calculate the new position of the paddle
        let newPositionX = paddleNode.position.x + translationX * paddleMoveSpeed
        
        // Set your manual clamp values here
        let minX: Float = -40
        let maxX: Float = 40
        
        // Clamp the new position within the manual clamp values
        let clampedPositionX = min(max(minX, newPositionX), maxX)
        
        // Apply the clamped position
        paddleNode.position.x = clampedPositionX
        
        // Reset the translation of the gesture recognizer
        gestureRecognizer.setTranslation(.zero, in: gestureRecognizer.view)
    }

}
