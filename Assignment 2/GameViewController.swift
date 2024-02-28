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
    var cameraNode = SCNNode() // Initialize camera node
    var flashlightOn = true
    var dayTime = true
    var flashLightIntensity = 500.0
    var ambientLightIntensity = 500.0
    // create a new scene
    let scene = SCNScene(named: "art.scnassets/main.scn")!
    let mazeSize = 3
    
    let defaultCamRot = SCNVector3(x: 0, y: 3.14159265, z: 0)
    let defaultCamPos = SCNVector3(x: 0, y: 0, z: -3)
    let camRotScale: Float = 50
    let camMoveScale: Float = 50
    
    var fogUI: FogUIComponent?
    var isFogEnabled = true
    var savedFogStartDistance: CGFloat?
    var savedFogEndDistance: CGFloat?
    var savedFogDensity: CGFloat?
    
    var maze = Maze(0, 0)
    
    var minimap: Minimap?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init fog effects
        scene.fogColor = UIColor.darkGray
        scene.fogStartDistance = 0
        scene.fogEndDistance = 2.5
        scene.fogDensityExponent = 1.0
        savedFogStartDistance = scene.fogStartDistance
        savedFogEndDistance = scene.fogEndDistance
        savedFogDensity = scene.fogDensityExponent

        cameraNode.camera = SCNCamera()
        cameraNode.name = "camera"
                
        cameraNode.eulerAngles = defaultCamRot
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = defaultCamPos
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)

        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
//        // Initialize and add the minimap view
//        minimap = MinimapView(frame: CGRect(x: scnView.frame.width - 325, y: scnView.frame.height - 425, width: 250, height: 250))
//        minimap?.backgroundColor = .lightGray
//        minimap?.isHidden = true
//        minimap?.alpha = 0.8
//        view.addSubview(minimap!)
        
        //var maze = Maze(Int32(mazeSize), Int32(mazeSize))
        //maze.Create()
        
//        var maze = Maze(Int32(mazeSize), Int32(mazeSize))
        
        

        
        // create fog UI
        fogUI = FogUIComponent(frame: CGRect(x: 20, y: 70, width: 320, height: 280))
        fogUI?.backgroundColor = .lightGray
        fogUI?.isHidden = true
        
        // add color button handlers
        fogUI?.fogUIColorChangeHandler = { [weak self] color in
            self?.scene.fogColor = color
        }
        
        // add fog toggle handlers
        fogUI?.fogToggleHandler = { [weak self] in
            self?.toggleFog()
        }
        
        // add fog value handlers
        fogUI?.startDistanceHandler = { [weak self] value in
            if (self!.isFogEnabled) {
                self?.scene.fogStartDistance = CGFloat(value)
            }
        }
        fogUI?.endDistanceHandler = { [weak self] value in
            if (self!.isFogEnabled) {
                self?.scene.fogEndDistance = CGFloat(value)
            }
        }
        fogUI?.densityHandler = { [weak self] value in
            if (self!.isFogEnabled) {
                self?.scene.fogDensityExponent = CGFloat(value)
            }
        }
        view.addSubview(fogUI!)
        
        // add single tap gesture -- toggle fog UI
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        scnView.addGestureRecognizer(singleTapGesture)
        
        // add double tap gesture -- camera orientation reset
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scnView.addGestureRecognizer(doubleTapGesture)
        
        // add pan gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        scnView.addGestureRecognizer(panGesture)
        
        // add 2 finger double tap gesture
        let twoFingerDoubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handle2FingerDoubleTap(_:)))
        twoFingerDoubleTapGesture.numberOfTapsRequired = 2
        twoFingerDoubleTapGesture.numberOfTouchesRequired = 2
        scnView.addGestureRecognizer(twoFingerDoubleTapGesture)
        
        //Flashlight toggle
        let flashlightButton = UIButton(type: .system)
        flashlightButton.setTitle("Flashlight", for: .normal)
        flashlightButton.setTitleColor(.white, for: .normal) // Set text color to white
        flashlightButton.layer.cornerRadius = 10 // Set corner radius to make edges rounded
        flashlightButton.layer.borderWidth = 1 // Optionally, you can add a border width
        flashlightButton.addTarget(self, action: #selector(flashlightToggle), for: .touchUpInside)
        flashlightButton.frame = CGRect(x: 75, y: 700, width: 100, height: 30)
        self.view.addSubview(flashlightButton)
        
        //Daytime Toggle
        let dayTimeToggleButton = UIButton(type: .system)
        dayTimeToggleButton.setTitle("Day/Night", for: .normal)
        dayTimeToggleButton.setTitleColor(.white, for: .normal) // Set text color to white
        dayTimeToggleButton.layer.cornerRadius = 10 // Set corner radius to make edges rounded
        dayTimeToggleButton.layer.borderWidth = 1 // Optionally, you can add a border width
        dayTimeToggleButton.addTarget(self, action: #selector(dayNightToggle), for: .touchUpInside)
        dayTimeToggleButton.frame = CGRect(x: 175, y: 700, width: 100, height: 30)
        self.view.addSubview(dayTimeToggleButton)
        
        flashlightButton.backgroundColor = UIColor.blue
        dayTimeToggleButton.backgroundColor = UIColor.red
        
        // Create the maze node
        let mazeNode = createMazeNode()
        
        minimap = Minimap(size: self.view.bounds.size, maze: maze)
                minimap?.isHidden = true
                scnView.overlaySKScene = minimap
        

        // Add the maze node to the scene
        scene.rootNode.addChildNode(mazeNode)
        
        addCube()
        reanimate()
        setupFlashLight()
        setupAmbientLight()
    }
    
    func createMazeNode() -> SCNNode {
        let mazeNode = SCNNode()
    
        var maze = Maze(Int32(mazeSize), Int32(mazeSize))
        maze.Create()
        
        // Define the size of a single cell, padding, and wall thickness
        let cellSize: CGFloat = 1.0
        let wallThickness: CGFloat = 0.1
        
        // Iterate through maze cells
        for row in 0..<maze.rows {
            for col in 0..<maze.cols {
                let cell = maze.GetCell(row, col)
                let cellPosition = SCNVector3(CGFloat(col) * (cellSize), -0.5, CGFloat(row) * (cellSize))
                
                // Create a node for the cell
                let cellGeometry = SCNBox(width: cellSize, height: 0.0, length: cellSize, chamferRadius: 0)
                let cellNode = SCNNode(geometry: cellGeometry)
                cellNode.position = cellPosition
                mazeNode.addChildNode(cellNode)
                
                // Check walls and create them if present
                if cell.northWallPresent {
                    let northWallNode = SCNNode(geometry: SCNBox(width: cellSize, height: 1, length: wallThickness, chamferRadius: 0))
                    northWallNode.position = SCNVector3(cellPosition.x, Float(wallThickness)/2, cellPosition.z - Float((cellSize)/2))
                    mazeNode.addChildNode(northWallNode)
                }
                if cell.southWallPresent {
                    let southWallNode = SCNNode(geometry: SCNBox(width: cellSize, height: 1, length: wallThickness, chamferRadius: 0))
                    southWallNode.position = SCNVector3(cellPosition.x, Float(wallThickness)/2, cellPosition.z + Float((cellSize))/2)
                    mazeNode.addChildNode(southWallNode)
                }
                if cell.eastWallPresent {
                    let eastWallNode = SCNNode(geometry: SCNBox(width: wallThickness, height: 1, length: cellSize, chamferRadius: 0))
                    eastWallNode.position = SCNVector3(cellPosition.x + Float((cellSize))/2, Float(wallThickness)/2, cellPosition.z)
                    mazeNode.addChildNode(eastWallNode)
                }
                if cell.westWallPresent {
                    let westWallNode = SCNNode(geometry: SCNBox(width: wallThickness, height: 1, length: cellSize, chamferRadius: 0))
                    westWallNode.position = SCNVector3(cellPosition.x - Float((cellSize))/2, Float(wallThickness)/2, cellPosition.z)
                    mazeNode.addChildNode(westWallNode)
                }
            }
        }
        self.maze = maze
        return mazeNode
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
            flashlight?.light?.intensity = flashLightIntensity
            flashlightOn = true
        }
    }
    
    @objc
    func dayNightToggle()
    {
        let ambientLight = scene.rootNode.childNode(withName: "Ambient Light", recursively: true)
        if (!dayTime){
            ambientLight?.light?.intensity = ambientLightIntensity
            dayTime = true
        }
        else{
            ambientLight?.light?.intensity = 100
            dayTime = false
        }
    }
    
    @objc
    func handleSingleTap(_ gestureRecognize: UITapGestureRecognizer) {
        fogUI?.isHidden.toggle()
        minimap?.isHidden = true
    }
    
    @objc
    func handleDoubleTap(_ gestureRecognize: UITapGestureRecognizer) {
        // reset cam's orientation and position to where it started
        cameraNode.position = defaultCamPos
        cameraNode.eulerAngles = defaultCamRot
    }
    
    @objc
    func handleDrag(_ gestureRecognize: UIPanGestureRecognizer) {
        let scnView = self.view as! SCNView
        
        switch gestureRecognize.state {
            
        case .changed:
            let translation = gestureRecognize.translation(in: scnView)
            let initialCameraRot = cameraNode.eulerAngles // Get cam's orientation before
            
            // Get delta values of inputs from pan gesture
            let xDelta = Float(translation.x) / camRotScale
            let yDelta = Float(translation.y) / camMoveScale

            // Coordinates are weird, application of delta values are swapped on euler coordinates
            let change = SCNVector3(initialCameraRot.x, initialCameraRot.y - xDelta, initialCameraRot.z)
            cameraNode.eulerAngles = change
            
            // Get camera position and its front facing vector
            let cameraPos = cameraNode.presentation.position
            let cameraDirection = cameraNode.presentation.worldFront
            let move = min(yDelta * -1, 5)
            
            // Create and assign new position
            let newPos = SCNVector3(x: cameraPos.x + cameraDirection.x * move, y: cameraPos.y + cameraDirection.y * move, z: cameraPos.z + cameraDirection.z * move)
            cameraNode.position = newPos

            // essentially resets the origin point of touch to align with the moving finger
            gestureRecognize.setTranslation(CGPointZero, in: scnView)
            
        default:
            break
        }
    }
    
    @objc
    private func handle2FingerDoubleTap(_ gestureRecognizr: UITapGestureRecognizer) {
        // Hold Alt key to use 2 finger/touch
        minimap?.isHidden.toggle()
        fogUI?.isHidden = true
    }
    
    private func toggleFog() {
        isFogEnabled.toggle()
        
        if (isFogEnabled) {
            scene.fogStartDistance = savedFogStartDistance!
            scene.fogEndDistance = savedFogEndDistance!
            scene.fogDensityExponent = savedFogDensity!
        } else {
            // save previous changes
            savedFogStartDistance = scene.fogStartDistance
            savedFogEndDistance = scene.fogEndDistance
            savedFogDensity = scene.fogDensityExponent
            
            // turn off fog
            scene.fogStartDistance = 0
            scene.fogEndDistance = 0
            scene.fogDensityExponent = 0
        }
    }
    
//    private func updateMinimap() {
//        if (minimap?.isHidden == false) {
//            minimap?.setNeedsDisplay() // redraws the view
//        }
//    }
    
    // Create Cube
    func addCube() {
        let theCube = SCNNode(geometry: SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0)) // Create a object node of box shape with width of 1 and height of 1
        theCube.name = "The Cube" // Name the node so we can reference it later
        theCube.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "crate.jpg") // Diffuse the crate image material across the whole cube
        theCube.position = SCNVector3(0, 0, 0) // Put the cube at position (0, 0, 0)
        scene.rootNode.addChildNode(theCube) // Add the cube node to the scene
    }
    
    @MainActor
    func reanimate() {
        let theCube = scene.rootNode.childNode(withName: "The Cube", recursively: true) // Get the cube object by its name
        rot.width += 0.05 // Increment rotation of the cube by 0.0005 radians
        if (rot.width >= 2*Double.pi*50) 
        {
            rot.width = 0.0
        }
        let rotX = Double(rot.height / 50)
        let rotY = Double(rot.width / 50)
        theCube?.eulerAngles = SCNVector3(rotX, rotY, 0)
        
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
        flashlight.light!.intensity = flashLightIntensity // Set the light intensity to 2000 lumins (1000 is default)
        cameraNode.addChildNode(flashlight) // Add the flashlight node to the scene as a child of the camera
    }
    
    // Sets up an ambient light (all around)
    func setupAmbientLight() {
        let ambientLight = SCNNode() // Create a SCNNode for the lamp
        ambientLight.name = "Ambient Light"
        ambientLight.light = SCNLight() // Add a new light to the lamp
        ambientLight.light!.type = .ambient // Set the light type to ambient
        ambientLight.light!.color = UIColor.white // Set the light color to white
        ambientLight.light!.intensity = ambientLightIntensity // Set the light intensity to 5000 lumins (1000 is default)
        scene.rootNode.addChildNode(ambientLight) // Add the lamp node to the scene
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
