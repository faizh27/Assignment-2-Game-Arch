//
//  GameViewController.swift
//  Assignment 2
//
//  Created by Faiz Hassany on 2024-02-17.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    var rotAngle = CGSize.zero // Keep track of drag gesture numbers
    var rot = CGSize.zero // Keep track of rotation angle
    var isRotating = true // Keep track of if rotation is toggled
    var cameraNode = SCNNode() // Initialize camera node
    var diffuseLightPos = SCNVector4(0, 0, 0, Double.pi/2) // Keep track of flashlight position
    var flashlightOn = true
    // create a new scene
    let scene = SCNScene(named: "art.scnassets/main.scn")!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)

        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        let flashlightButton = UIButton(type: .system)
        flashlightButton.setTitle("Flashlight", for: .normal)
        flashlightButton.addTarget(self, action: #selector(flashlightToggle), for: .touchUpInside)
        flashlightButton.frame = CGRect(x: 100, y: 500, width: 200, height: 100)
        self.view.addSubview(flashlightButton)
        
        addCube()
        reanimate()
        setupFlashLight()
    }
    
    @objc
    func flashlightToggle()
    {
        let flashlight = scene.rootNode.childNode(withName: "Flash Light", recursively: true)
        if (flashlightOn){
            flashlight?.light?.intensity = 0
            flashlightOn = false
        }
        else{
            flashlight?.light?.intensity = 2000
            flashlightOn = true
        }
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    // Create Cube
    func addCube() {
        let theCube = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)) // Create a object node of box shape with width of 1 and height of 1
        theCube.name = "The Cube" // Name the node so we can reference it later
        theCube.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "crate.jpg") // Diffuse the crate image material across the whole cube
        theCube.position = SCNVector3(0, 0, 0) // Put the cube at position (0, 0, 0)
        scene.rootNode.addChildNode(theCube) // Add the cube node to the scene
    }
    
    @MainActor
    func reanimate() {
        let theCube = scene.rootNode.childNode(withName: "The Cube", recursively: true) // Get the cube object by its name (This is where line 45 comes in)
        if (isRotating) {
            rot.width += 0.05 // Increment rotation of the cube by 0.0005 radians
            if (rot.width >= 2*Double.pi*50) {
                rot.width = 0.0
            }
        } else {
            rot = rotAngle // Let the rot variable follow the drag gesture
            if (rot.width >= 2*Double.pi*50) {
                rot.width = 0.0
            }
            if (rot.height >= 2*Double.pi*50) {
                rot.height = 0.0
            }
        }
        var rotX = Double(rot.height / 50)
        var rotY = Double(rot.width / 50)
        theCube?.eulerAngles = SCNVector3(rotX, rotY, 0) // Set the cube rotation to the numbers given from the drag gesture
        
        // Repeat increment of rotation every 10000 nanoseconds
        Task { try! await Task.sleep(nanoseconds: 10000)
            reanimate()
        }
    }
    
    // Sets up a directional light (flashlight)
    func setupFlashLight() {
        let flashlight = SCNNode() // Create a SCNNode for the lamp
        flashlight.name = "Flash Light" // Name the node so we can reference it later
        flashlight.light = SCNLight() // Add a new light to the lamp
        flashlight.light!.type = .directional // Set the light type to directional
        flashlight.light!.color = UIColor.orange // Set the light color to orange
        flashlight.light!.intensity = 2000 // Set the light intensity to 2000 lumins (1000 is default)
        flashlight.rotation = diffuseLightPos // Set the rotation of the light from the flashlight to the flashlight position variable
        scene.rootNode.addChildNode(flashlight) // Add the lamp node to the scene
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
