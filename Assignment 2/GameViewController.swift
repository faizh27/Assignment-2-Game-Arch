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
    let mazeSize = 10
    
    let defaultCamRot = SCNVector3(x: 0, y: 3.14159265, z: 0)
    let defaultCamPos = SCNVector3(x: 0, y: 0, z: -3)
    let camRotScale: Float = 50
    let camMoveScale: Float = 50
    
    var fogUI: FogUIComponent?
    var isFogEnabled = true
    var savedFogStartDistance: CGFloat?
    var savedFogEndDistance: CGFloat?
    var savedFogDensity: CGFloat?

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
        
        let flashlightButton = UIButton(type: .system)
        flashlightButton.setTitle("Flashlight", for: .normal)
        flashlightButton.setTitleColor(.white, for: .normal) // Set text color to white
        flashlightButton.layer.cornerRadius = 10 // Set corner radius to make edges rounded
        flashlightButton.layer.borderWidth = 1 // Optionally, you can add a border width
        flashlightButton.addTarget(self, action: #selector(flashlightToggle), for: .touchUpInside)
        flashlightButton.frame = CGRect(x: 20, y: 700, width: 100, height: 30)
        self.view.addSubview(flashlightButton)
        
        let dayTimeToggleButton = UIButton(type: .system)
        dayTimeToggleButton.setTitle("Day/Night", for: .normal)
        dayTimeToggleButton.setTitleColor(.white, for: .normal) // Set text color to white
        dayTimeToggleButton.layer.cornerRadius = 10 // Set corner radius to make edges rounded
        dayTimeToggleButton.layer.borderWidth = 1 // Optionally, you can add a border width
        dayTimeToggleButton.addTarget(self, action: #selector(dayNightToggle), for: .touchUpInside)
        dayTimeToggleButton.frame = CGRect(x: 130, y: 700, width: 100, height: 30)
        self.view.addSubview(dayTimeToggleButton)
        
        flashlightButton.backgroundColor = UIColor.blue
        dayTimeToggleButton.backgroundColor = UIColor.red
        
        // Create the maze node
        let mazeNode = createMazeNode()

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
        let wallPadding: CGFloat = 0.01
        
        // Load textures from URL
        let texture1 = UIImage(named: "art.scnassets/texture1.jpeg")
        let wallMaterialNone = SCNMaterial()
        wallMaterialNone.diffuse.contents = texture1
        let texture2 = UIImage(named: "art.scnassets/texture2.jpeg")
        let wallMaterialLeft = SCNMaterial()
        wallMaterialLeft.diffuse.contents = texture2
        let texture3 = UIImage(named: "art.scnassets/texture3.jpeg")
        let wallMaterialRight = SCNMaterial()
        wallMaterialRight.diffuse.contents = texture3
        let texture4 = UIImage(named: "art.scnassets/texture4.jpeg")
        let wallMaterialBoth = SCNMaterial()
        wallMaterialBoth.diffuse.contents = texture4
        let texture5 = UIImage(named: "art.scnassets/ground.png")
        let groundMaterial = SCNMaterial()
        groundMaterial.diffuse.contents = texture5
        
        // Iterate through maze cells
        for row in 0..<maze.rows {
            for col in 0..<maze.cols {
                let cell = maze.GetCell(row, col)
                let cellPosition = SCNVector3(CGFloat(col) * (cellSize), -0.4, CGFloat(row) * (cellSize))
                
                // Create a node for the cell and texture the floor
                let cellGeometry = SCNBox(width: cellSize, height: 0.0, length: cellSize, chamferRadius: 0)
                let cellNode = SCNNode(geometry: cellGeometry)
                cellNode.geometry?.firstMaterial = groundMaterial
                cellNode.position = cellPosition
                mazeNode.addChildNode(cellNode)
                
                // Check walls and create them if present with the loaded texture
                if cell.northWallPresent {
                    let northWallNode = SCNNode(geometry: SCNBox(width: cellSize, height: 1, length: wallThickness, chamferRadius: 0))
                    northWallNode.position = SCNVector3(cellPosition.x, Float(wallThickness)/2, cellPosition.z - Float(cellSize/2) + Float(wallPadding))
                    // Determine relative left & right configuration and set wall textures accordingly
                    switch (cell.eastWallPresent, cell.westWallPresent) {
                    case (false, false):
                        northWallNode.geometry?.firstMaterial = wallMaterialNone
                    case (true, false):
                        northWallNode.geometry?.firstMaterial = wallMaterialLeft
                    case (false, true):
                        northWallNode.geometry?.firstMaterial = wallMaterialRight
                    case (true, true):
                        northWallNode.geometry?.firstMaterial = wallMaterialBoth
                    }
                    mazeNode.addChildNode(northWallNode)
                }
                if cell.southWallPresent {
                    let southWallNode = SCNNode(geometry: SCNBox(width: cellSize, height: 1, length: wallThickness, chamferRadius: 0))
                    southWallNode.position = SCNVector3(cellPosition.x, Float(wallThickness)/2, cellPosition.z + Float(cellSize/2) - Float(wallPadding))
                    switch (cell.westWallPresent, cell.eastWallPresent) {
                    case (false, false):
                        southWallNode.geometry?.firstMaterial = wallMaterialNone
                    case (true, false):
                        southWallNode.geometry?.firstMaterial = wallMaterialLeft
                    case (false, true):
                        southWallNode.geometry?.firstMaterial = wallMaterialRight
                    case (true, true):
                        southWallNode.geometry?.firstMaterial = wallMaterialBoth
                    }
                    mazeNode.addChildNode(southWallNode)
                }
                if cell.eastWallPresent {
                    let eastWallNode = SCNNode(geometry: SCNBox(width: wallThickness, height: 1, length: cellSize, chamferRadius: 0))
                    eastWallNode.position = SCNVector3(cellPosition.x + Float(cellSize/2) - Float(wallPadding), Float(wallThickness)/2, cellPosition.z)
                    switch (cell.southWallPresent, cell.northWallPresent) {
                    case (false, false):
                        eastWallNode.geometry?.firstMaterial = wallMaterialNone
                    case (true, false):
                        eastWallNode.geometry?.firstMaterial = wallMaterialLeft
                    case (false, true):
                        eastWallNode.geometry?.firstMaterial = wallMaterialRight
                    case (true, true):
                        eastWallNode.geometry?.firstMaterial = wallMaterialBoth
                    }
                    mazeNode.addChildNode(eastWallNode)
                }
                if cell.westWallPresent {
                    let westWallNode = SCNNode(geometry: SCNBox(width: wallThickness, height: 1, length: cellSize, chamferRadius: 0))
                    westWallNode.geometry?.firstMaterial = wallMaterialBoth
                    westWallNode.position = SCNVector3(cellPosition.x - Float(cellSize/2) + Float(wallPadding), Float(wallThickness)/2, cellPosition.z)
                    switch (cell.northWallPresent, cell.southWallPresent) {
                    case (false, false):
                        westWallNode.geometry?.firstMaterial = wallMaterialNone
                    case (true, false):
                        westWallNode.geometry?.firstMaterial = wallMaterialLeft
                    case (false, true):
                        westWallNode.geometry?.firstMaterial = wallMaterialRight
                    case (true, true):
                        westWallNode.geometry?.firstMaterial = wallMaterialBoth
                    }
                    mazeNode.addChildNode(westWallNode)
                }
            }
        }
        
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
    
    // Create Cube
    func addCube() {
        let theCube = SCNNode(geometry: SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0)) // Create a object node of box shape with width of 1 and height of 1
        theCube.name = "The Cube" // Name the node so we can reference it later
        theCube.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/crate.jpg") // Diffuse the crate image material across the whole cube
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
