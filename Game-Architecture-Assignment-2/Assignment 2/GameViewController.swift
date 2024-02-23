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

    let scene = SCNScene(named: "art.scnassets/maze.scn")!
    var flashLightNode : SCNNode?
    var ambientLightNode : SCNNode?
    var playerNode : SCNNode?
    var cameraNode : SCNNode?
    
    var slider: UISlider!
    
    override func viewDidLoad() {
        flashLightNode = scene.rootNode.childNode(withName: "flashLight", recursively: true)!
        super.viewDidLoad()
        
        // Create a UISlider
                slider = UISlider(frame: CGRect(x: 50, y: 50, width: 200, height: 20))

                // Configure the slider properties
                slider.minimumValue = 0
                slider.maximumValue = 100
                slider.value = 50
                slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)

                // Add the slider to the view
                view.addSubview(slider)
        
        var maze = Maze(10, 10)
        maze.Create()
        print(maze.GetCell(0, 0))
        
        for row in 0..<maze.rows {
            for col in 0..<maze.cols {
                let cell = maze.GetCell(row, col)
                let mazeCell = MazeCell(xPos: Float(-row), zPos: Float(col), northWall: cell.northWallPresent, southWall: cell.southWallPresent, eastWall: cell.eastWallPresent, westWall: cell.westWallPresent)
                print("(\(mazeCell.zPos), \(mazeCell.xPos)) = \(cell)")
                
                scene.rootNode.addChildNode(mazeCell)
            }
        }
        
        let mazeNode = SCNNode() // Create a new SCNNode instance
        mazeNode.name = "Maze" // Set a name for the node if needed
        scene.rootNode.addChildNode(mazeNode)
        
        let fogShader = """
        #pragma arguments
        float fogStartDistance;
        float fogEndDistance;
        float4 fogColor;

        #pragma transparent
        #pragma body
        float depth = _surface.position.z / _surface.position.w;
        float fogFactor = (depth - fogStartDistance) / (fogEndDistance - fogStartDistance);
        fogFactor = clamp(fogFactor, 0.0, 1.0);
        _surface.diffuse.rgb = mix(_surface.diffuse.rgb, fogColor.rgb, fogFactor);
        """
        
        
        scene.fogStartDistance = 0.0
        scene.fogEndDistance = 2.0
        scene.fogColor = UIColor.gray
        scene.fogDensityExponent = 2.0
        scene.rootNode.geometry?.shaderModifiers = [.surface: fogShader]
        
        cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)
        
        playerNode = scene.rootNode.childNode(withName: "player", recursively: true)
        // day and night
        ambientLightNode = scene.rootNode.childNode(withName: "ambient", recursively: true)!
        
        let flashLightButton = UIButton(type: .system)
        flashLightButton.setTitle("Toggle Flashlight", for: .normal)
        flashLightButton.addTarget(self, action: #selector(toggleFlashLight), for: .touchUpInside)
        flashLightButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(flashLightButton)
        
        let ambientLightButton = UIButton(type: .system)
        ambientLightButton.setTitle("Toggle Ambient Light", for: .normal)
        ambientLightButton.addTarget(self, action: #selector(toggleDayLight), for: .touchUpInside)
        ambientLightButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(ambientLightButton)
        
        NSLayoutConstraint.activate([
                    flashLightButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    flashLightButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
                    ambientLightButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    ambientLightButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80)
                ])
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        //scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        //scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scnView.addGestureRecognizer(doubleTapGesture)
        
        // Add swipe gesture recognizer for each direction
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeUpGesture.direction = .up
        scnView.addGestureRecognizer(swipeUpGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDownGesture.direction = .down
        scnView.addGestureRecognizer(swipeDownGesture)
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeftGesture.direction = .left
        scnView.addGestureRecognizer(swipeLeftGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRightGesture.direction = .right
        scnView.addGestureRecognizer(swipeRightGesture)
        
        addCube()
        Task(priority: .userInitiated) {
            await firstUpdate()
        }
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
            // Handle slider value changes
            let value = sender.value
            print("Slider value changed to: \(value)")
        }
    
    // Button action
    @objc func toggleFlashLight() {
        print("Button tapped!")
        flashLightNode?.isHidden.toggle()
    }
    
    var isDay = false
    @objc func toggleDayLight() {
        print("Button tapped!")
        let targetIntensity: CGFloat = isDay ? 700 : 0
        let duration: TimeInterval = 1.0 // Adjust the duration as needed

        let intensityAction = SCNAction.customAction(duration: duration) { (node, elapsedTime) in
            guard let light = node.light else { return }
            
            // Calculate the difference between target intensity and current intensity
            let intensityDifference = targetIntensity - light.intensity
            
            // Calculate the new intensity based on elapsed time and intensity difference
            let currentIntensity = light.intensity + (intensityDifference * CGFloat(elapsedTime / duration))
            
            // Set the new intensity
            light.intensity = currentIntensity
        }

        ambientLightNode?.runAction(intensityAction)
        isDay = !isDay
    }
    
    // Create Cube
    func addCube() {
        let theCube = SCNNode(geometry: SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)) // Create a object node of box shape with width of 1 and height of 1
        theCube.name = "The Cube" // Name the node so we can reference it later
        theCube.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "crate.jpg") // Diffuse the crate image material across the whole cube
        theCube.position = SCNVector3(0, 0.25, 0) // Put the cube at position (0, 0, 0)
        scene.rootNode.addChildNode(theCube) // Add the cube node to the scene
    }
    
    @MainActor
    func firstUpdate() {
        reanimate() // Call reanimate on the first graphics update frame
    }
    
    var rotAngle = 0.0
    @MainActor
    func reanimate() {
        let theCube = scene.rootNode.childNode(withName: "The Cube", recursively: true) // Get the cube object by its name (This is where line 69 comes in)
        rotAngle += 0.05 // Increment rotation of the cube by 0.0005 radians
        // Keep the rotation angle in the range of 0 and pi
        if rotAngle > Double.pi {
            rotAngle -= Double.pi
        }
        theCube?.eulerAngles = SCNVector3(0, rotAngle, 0) // Rotate cube by the final amount

        Task { try! await Task.sleep(nanoseconds: 20000000)
            reanimate()
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
    
    var cardDirection: [String] = ["north", "east", "south", "west"]
    var currentForward: Int = 2
    
    @objc
    func handleDoubleTap(_ gestureRecognizer: UISwipeGestureRecognizer) {
        print("double tap")
        playerNode?.position = SCNVector3(0, 0.5, 0)
        playerNode?.rotation = SCNVector4(0, 0, 0, 0)
    }
    
    // holy overengineering
    @objc func handleSwipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
        print(gestureRecognizer.direction)
        if gestureRecognizer.state == .ended {
            var forwardVector = SCNVector3(0, 0, 0)
            if cardDirection[currentForward] == "north" {
                forwardVector = SCNVector3(1, 0, 0)
            } else if cardDirection[currentForward] == "east" {
                forwardVector = SCNVector3(0, 0, -1)
            } else if cardDirection[currentForward] == "south" {
                forwardVector = SCNVector3(-1, 0, 0)
            } else if cardDirection[currentForward] == "west" {
                forwardVector = SCNVector3(0, 0, 1)
            }
            let backwardVector = SCNVector3(-forwardVector.x, -forwardVector.y, -forwardVector.z)
            switch gestureRecognizer.direction {
            case .up:
                //print("Swiped up!")
                playerNode?.runAction(SCNAction.move(by: backwardVector, duration: 1))
            case .down:
                //print("Swiped down!")
                playerNode?.runAction(SCNAction.move(by: forwardVector, duration: 1))
            case .left:
                //print("Swiped left!")
                playerNode?.runAction(SCNAction.rotateBy(x: 0, y: -.pi / 2, z: 0, duration: 1))
                currentForward = (currentForward + cardDirection.count - 1) % cardDirection.count
            case .right:
                //print("Swiped right!")
                playerNode?.runAction(SCNAction.rotateBy(x: 0, y: .pi / 2, z: 0, duration: 1))
                currentForward = (currentForward + 1) % cardDirection.count
            default:
                break
            }
        }
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
