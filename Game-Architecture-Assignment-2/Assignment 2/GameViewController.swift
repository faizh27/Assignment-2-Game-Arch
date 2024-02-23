//
//  GameViewController.swift
//  Assignment 2
//
//  Created by Faiz Hassany on 2024-02-17.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit

class GameViewController: UIViewController {

    let scene = SCNScene(named: "art.scnassets/maze.scn")!
    
    var minimap: Minimap?
    
    var flashLightNode: SCNNode?
    var ambientLightNode: SCNNode?
    var playerNode: SCNNode?
    var cameraNode: SCNNode?
    
    var fogStartDistanceSlider: UISlider!
    var fogEndDistanceSlider: UISlider!
    var fogDensityExponentSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // create maze
        let mazeNode = SCNNode() // Create a new SCNNode instance
        mazeNode.name = "Maze" // Set a name for the node if needed
        var maze = Maze(5, 10)
        maze.Create()
        //maze.CreateWithSeed(1)
        //print("0: \(maze.GetCell(0, 0))")
        for row in 0..<maze.rows {
            for col in 0..<maze.cols {
                let cell = maze.GetCell(row, col)
                //print("(\(col), \(row)) \(cell)")
                let mazeCell = MazeCell(xPos: Float(-row), zPos: Float(col), northWall: cell.northWallPresent, southWall: cell.southWallPresent, eastWall: cell.eastWallPresent, westWall: cell.westWallPresent)
                mazeNode.addChildNode(mazeCell)
            }
        }
        minimap = Minimap(size: self.view.bounds.size, maze: maze)
        minimap?.isHidden = true
        scnView.overlaySKScene = minimap
        
        scene.rootNode.addChildNode(mazeNode)
        
        // set up default fog values and scene
        scene.fogStartDistance = 0.0
        scene.fogEndDistance = 10.0
        scene.fogColor = UIColor.gray
        scene.fogDensityExponent = 2.0
        //scene.background.contents = nil
        
        // get node references
        playerNode = scene.rootNode.childNode(withName: "player", recursively: true)
        flashLightNode = scene.rootNode.childNode(withName: "flashLight", recursively: true)!
        ambientLightNode = scene.rootNode.childNode(withName: "ambient", recursively: true)!
        
        // UI stuff
        let label = UILabel(frame: CGRect(x: 20, y: 70, width: 200, height: 30))
        label.text = "Fog Settings"
        label.font = UIFont.systemFont(ofSize: 25)
        label.textColor = UIColor.white
        view.addSubview(label)
        
        fogStartDistanceSlider = createSliderWithName(xPos: 20, yPos: 100, width: 150, height: 30, minValue: 0, maxValue: 10, value: 0, tag: 0, name: "Start Distance")
        fogEndDistanceSlider = createSliderWithName(xPos: 20, yPos: 150, width: 150, height: 30, minValue: 0, maxValue: 5, value: 10, tag: 1, name: "End Distance")
        fogDensityExponentSlider = createSliderWithName(xPos: 20, yPos: 200, width: 150, height: 30, minValue: 0, maxValue: 3, value: 2, tag: 2, name: "Density Exponent")
        
        // Create and configure the UIColorWell
        let colorWell = UIColorWell(frame: CGRect(x: 280, y: 60, width: 100, height: 50))
        colorWell.addTarget(self, action: #selector(colorDidChange(_:)), for: .valueChanged)
        // Set initial color (optional)
        colorWell.selectedColor = UIColor.gray
        // Add the UIColorWell to the view hierarchy
        view.addSubview(colorWell)
        
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
        
        // add gestures
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scnView.addGestureRecognizer(doubleTapGesture)
        
        let twoFingerDoubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTwoFingerDoubleTap(_:)))
        twoFingerDoubleTapGesture.numberOfTapsRequired = 2
        twoFingerDoubleTapGesture.numberOfTouchesRequired = 2
        scnView.addGestureRecognizer(twoFingerDoubleTapGesture)
        
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
        
        
        // miscellaneous down here...
        
        // set the scene to the view
        scnView.scene = scene
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        addCube()
        Task(priority: .userInitiated) {
            await firstUpdate()
        }
    }
    
    func createSliderWithName(xPos: Int, yPos: Int, width: Int, height: Int, minValue: Float, maxValue: Float, value: Float, tag: Int, name: String) -> UISlider {
        
        // Create UIabel
        let label = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        label.text = name
        label.font = UIFont.systemFont(ofSize: 15)
        view.addSubview(label)
        
        // Create a UISlider
        let slider = UISlider(frame: CGRect(x: xPos + 125, y: yPos, width: width + 50, height: height))
        slider.minimumValue = minValue
        slider.maximumValue = maxValue
        slider.value = value
        slider.minimumTrackTintColor = UIColor.white
        slider.maximumTrackTintColor = UIColor.lightGray
        slider.tag = tag
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        view.addSubview(slider)
        
        return slider
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        let value = CGFloat(sender.value)
        print("\(sender.tag) value = \(value)")
        if sender.tag == 0 {
            scene.fogStartDistance = value
        } else if sender.tag == 1 {
            scene.fogEndDistance = value
            if fogStartDistanceSlider.maximumValue >= sender.value {
                fogStartDistanceSlider.maximumValue = sender.value
                fogStartDistanceSlider.value = sender.value
            }
        } else if sender.tag == 2 {
            scene.fogDensityExponent = value
        }
    }
    
    @objc func colorDidChange(_ sender: UIColorWell) {
        // Handle color changes
        let selectedColor = sender.selectedColor
        scene.fogColor = selectedColor!
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
    }
    
    @objc
    func handleTwoFingerDoubleTap(_ gestureRecognizer: UIGestureRecognizer) {
        minimap?.isHidden.toggle()
    }
    
    var cardDirection: [String] = ["north", "east", "south", "west"]
    var currentForward: Int = 2
    @objc
    func handleDoubleTap(_ gestureRecognizer: UIGestureRecognizer) {
        playerNode?.position = SCNVector3(0, 0.5, 0)
        playerNode?.rotation = SCNVector4(0, 0, 0, 0)
        currentForward = 2
    }
    
    // holy overengineering
    @objc
    func handleSwipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
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
                minimap?.moveTriangle(currentForward: currentForward, swipeDirection: .up)
                playerNode?.runAction(SCNAction.move(by: backwardVector, duration: 1))
            case .down:
                //print("Swiped down!")
                minimap?.moveTriangle(currentForward: currentForward, swipeDirection: .down)
                playerNode?.runAction(SCNAction.move(by: forwardVector, duration: 1))
            case .left:
                //print("Swiped left!")
                minimap?.moveTriangle(currentForward: currentForward, swipeDirection: .left)
                playerNode?.runAction(SCNAction.rotateBy(x: 0, y: -.pi / 2, z: 0, duration: 1))
                currentForward = (currentForward + cardDirection.count - 1) % cardDirection.count
            case .right:
                //print("Swiped right!")
                minimap?.moveTriangle(currentForward: currentForward, swipeDirection: .right)
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
