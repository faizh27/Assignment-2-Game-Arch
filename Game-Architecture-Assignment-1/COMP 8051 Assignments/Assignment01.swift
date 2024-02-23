//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Lab05: Add text that shows rotation angle of rotating cube
//        as well as 3D text
// *** NOT WORKING!!
//
//====================================================================

import SceneKit
import SwiftUI	

class Assignment1Crate: SCNScene {
    var rotAngle = CGSize.zero // Keep track of drag gesture numbers
    var rot = CGSize.zero // Keep track of rotation angle
    var isRotating = true // Keep track of if rotation is toggled
    var cameraNode = SCNNode() // Initialize camera node
    var textX = 0.0
    var panTranslation = SCNVector3(x: 0, y: 0, z: 0)
    
    var secondRot = CGSize.zero
    
    var diffuseLightPos = SCNVector4(0, 0, 0, Double.pi/2) // Keep track of flashlight position
    var flashlightPos = 7.0
    var flashlightAngle = 15.0
    
    var dragTranslation = CGSize.zero
    
    // Catch if initializer in init() fails
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Initializer passing binding variable for the drag gesture numbers
    override init() {
        super.init() // Implement the superclass' initializer
        
        background.contents = UIColor.black // Set the background colour to black
        
        setupCamera()
        //setupSceneLight()
        setupSceneLight()
        setupFlashlight()
        setupDirectionalLight()
        setupAmbientLight()
        addCube1()
        addCube2()
        addText()
        
        
        Task(priority: .userInitiated) {
            await firstUpdate()
        }
        
    }
    
    // Function to setup the camera node
    func setupCamera() {
        let camera = SCNCamera() // Create Camera object
        cameraNode.camera = camera // Give the cameraNode a camera
        cameraNode.position = SCNVector3(5, 5, 5) // Set the position to (5, 5, 5)	
        cameraNode.eulerAngles = SCNVector3(-Float.pi/4, Float.pi/4, 0) // Set the pitch, yaw, and roll
        rootNode.addChildNode(cameraNode) // Add the cameraNode to the scene
    }
    
    // Create Cube
    func addCube1() {
        let theCube = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)) // Create a object node of box shape with width of 1 and height of 1
        theCube.name = "The Cube" // Name the node so we can reference it later
        let materials = [UIColor.red, UIColor.green, UIColor.blue, UIColor.yellow, UIColor.cyan, UIColor.magenta] // List of materials for each side
        theCube.geometry?.firstMaterial?.diffuse.contents = materials[0] // Diffuse the red colour material across the whole cube
        
        var nextMaterial: SCNMaterial // Initialize temporary variable to store each texture
        
        for index in 1...5 {
            nextMaterial = SCNMaterial() // Empty the variable
            nextMaterial.diffuse.contents = materials[index] // Set the material of the temporary variable to the material at index 1 in the list
            theCube.geometry?.insertMaterial(nextMaterial, at: index) // Set the side of the cube at index 1 to the material stored in the temporary variable
        }
        
        theCube.position = SCNVector3(0, 0, 0) // Put the cube at position (0, 0, 0)
        rootNode.addChildNode(theCube) // Add the cube node to the scene
    }
    
    func addCube2() {
        let theCube2 = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)) // Create a object node of box shape with width of 1 and height of 1
        theCube2.name = "The Cube2" // Name the node so we can reference it later
        let materials = [UIImage(named: "gold.jpeg"), UIImage(named: "diamond_block_side.png"), UIImage(named: "cobblestone.png"), UIImage(named: "dark_oak_leaves.png"), UIImage(named: "grass.png"), UIImage(named: "emerald_block_side.png")] // List of materials for each side
        theCube2.geometry?.firstMaterial?.diffuse.contents = materials[0] // Diffuse the red colour material across the whole cube
        
        var nextMaterial: SCNMaterial // Initialize temporary variable to store each texture
        
        for index in 1...5 {
            nextMaterial = SCNMaterial() // Empty the variable
            nextMaterial.diffuse.contents = materials[index] // Set the material of the temporary variable to the material at index 1 in the list
            theCube2.geometry?.insertMaterial(nextMaterial, at: index) // Set the side of the cube at index 1 to the material stored in the temporary variable
        }
        
        theCube2.position = SCNVector3(0, -5, 0) // Put the cube at position (0, 0, 0)
        rootNode.addChildNode(theCube2) // Add the cube node to the scene
    }
    
    func addText() {
        
        //### Repeat the above but this time for text we will use to track angles
        let dynamicText = SCNText(string: "123", extrusionDepth: 1.0)
        let dynamicTextNode = SCNNode(geometry: dynamicText)
        dynamicTextNode.name = "Dynamic Text"
        dynamicTextNode.position = SCNVector3(x: 0, y: -2.5, z: 0) // Position below the crate
        dynamicTextNode.scale = SCNVector3(0.03, 0.03, 0.03)
        dynamicTextNode.eulerAngles = cameraNode.eulerAngles    // Tie the rotation to the camera so it looks 2D
        dynamicTextNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        rootNode.addChildNode(dynamicTextNode) // Add the text object to the scene
    }
    
    func setupFlashlight() {
        let lightNode = SCNNode()
        lightNode.name = "Flashlight"
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLight.LightType.spot
        lightNode.light!.castsShadow = true
        lightNode.light!.color = UIColor.red
        lightNode.light!.intensity = 20000
        lightNode.position = SCNVector3(0, 7, flashlightPos)
        lightNode.rotation = SCNVector4(1, 0, 0, -Double.pi/3)
        lightNode.light!.spotInnerAngle = 0
        lightNode.light!.spotOuterAngle = flashlightAngle
        lightNode.light!.shadowColor = UIColor.black
        lightNode.light!.zFar = 500
        lightNode.light!.zNear = 50
        rootNode.addChildNode(lightNode)
    }
    
    // Sets up an ambient light (all around)
    func setupAmbientLight() {
        let ambientLight = SCNNode() // Create a SCNNode for the lamp
        ambientLight.name = "Ambient Light"
        ambientLight.light = SCNLight() // Add a new light to the lamp
        ambientLight.light!.type = .ambient // Set the light type to ambient
        ambientLight.light!.color = UIColor.white // Set the light color to white
        ambientLight.light!.intensity = 1000 // Set the light intensity to 5000 lumins (1000 is default)
        rootNode.addChildNode(ambientLight) // Add the lamp node to the scene
    }
    
    func setupSceneLight() {
        let sceneLight = SCNNode() // Create a SCNNode for the lamp
        sceneLight.name = "Scene Light 222"
        sceneLight.light = SCNLight() // Add a new light to the lamp
        sceneLight.light!.type = .directional; // Set the light type to ambient
        sceneLight.light!.color = UIColor.white // Set the light color to white
        sceneLight.light!.intensity = 0 // Set the light intensity to 5000 lumins (1000 is default)
        rootNode.addChildNode(sceneLight) // Add the lamp node to the scene
    }
    
    // Sets up a directional (diffuse?) light
    func setupDirectionalLight() {
        let directionalLight = SCNNode() // Create a SCNNode for the lamp
        directionalLight.name = "Diffuse Light" // Name the node so we can reference it later
        directionalLight.light = SCNLight() // Add a new light to the lamp
        directionalLight.light!.type = .directional // Set the light type to directional
        directionalLight.light!.color = UIColor.magenta // Set the light color to white
        directionalLight.light!.intensity = 1000 // Set the light intensity to 20000 lumins (1000 is default)
        directionalLight.rotation = diffuseLightPos // Set the rotation of the light from the flashlight to the flashlight position variable
        rootNode.addChildNode(directionalLight) // Add the lamp node to the scene
    }
    
    @MainActor
    func firstUpdate() {
        reanimate() // Call reanimate on the first graphics update frame
    }
    
    // Just like the Update() function in Unity
    @MainActor
    func reanimate() {
        let theCube = rootNode.childNode(withName: "The Cube", recursively: true) // Get the cube object by its name (This is where line 45 comes in)
        let theCube2 = rootNode.childNode(withName: "The Cube2", recursively: true)
        if (isRotating) {
            rot.width += 0.05 // Increment rotation of the cube by 0.0005 radians
        } else {
            rot = rotAngle // Let the rot variable follow the drag gesture
            
            // move cube
            theCube?.position.x = Float(panTranslation.x)
            theCube?.position.y = Float(panTranslation.y)
        }
        
        var rotX = Double(rot.height / 50)
        var rotY = Double(rot.width / 50)
        theCube?.eulerAngles = SCNVector3(rotX, rotY, 0) // Set the cube rotation to the numbers given from the drag gesture
        
        // rotate second cube
        secondRot.width += 0.05
        let secondRotX = Double(secondRot.height / 50)
        let secondRotY = Double(secondRot.width / 50)
        theCube2?.eulerAngles = SCNVector3(secondRotX, secondRotY, 0)
        
        //### These lines set the dynamic text to report the rotation angles of the crate
        let dynamicTextNode = rootNode.childNode(withName: "Dynamic Text", recursively: true)
        if let textGeometry = dynamicTextNode?.geometry as? SCNText {
            rotX *= 180.0 / Double.pi
            rotY *= 180.0 / Double.pi
            
            if let rotZ = theCube?.rotation.z, let positionX = theCube?.position.x, let positionY = theCube?.position.y, let positionZ = theCube?.position.z {
                textGeometry.string = String(format: "Rotation: %.2f, %.2f, %.2f\nPosition: %.2f, %.2f, %.2f", rotX, rotY, rotZ, positionX, positionY, positionZ)
            } else {
                // Handle the case when any of the values is nil
                textGeometry.string = "Unable to retrieve rotation and position values"
            }
            
            let (minVec, maxVec) = textGeometry.boundingBox
            dynamicTextNode?.pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2 + minVec.x, (maxVec.y - minVec.y) / 2 + minVec.y, 0)
        }
        
        Task { try! await Task.sleep(nanoseconds: 10000)
            reanimate()
        }
    }
    
    @MainActor
    // Function to be called by double-tap gesture
    func handleDoubleTap() {
        isRotating = !isRotating // Toggle rotation
    }
    
    
    @MainActor
    // Function to be called by drag gesture
    func handleDrag(offset: CGSize) {
        rotAngle = offset // Get the width and height components of the CGSize, which only gives us two, and put them into the x and y rotations of the flashlight
        dragTranslation = offset
    }
    
    @MainActor
    func handleZoom(scale: CGFloat) {
        guard !isRotating, let camera = cameraNode.camera else { return }
        
        let newFov = camera.fieldOfView / scale
        camera.fieldOfView = max(min(newFov, 120), 20)
        
    }
    
    @MainActor
    func handleDoubleTouchPan(translation: CGPoint) {
        let translationScale: Float = 0.005 // Adjust this value to control the speed
        panTranslation = SCNVector3(Float(translation.x) * translationScale, -Float(translation.y) * translationScale, 0.0)
    }
    
    @MainActor
    func resetCubePos() {
        rot = CGSize.zero
        rotAngle = CGSize.zero
        panTranslation = SCNVector3(x: 0, y: 0, z: 0)
    }
    
    @MainActor
    func toggleFlashlight() {
        let light = rootNode.childNode(withName: "Flashlight", recursively: true)
        light?.isHidden.toggle()
    }
    
    @MainActor
    func toggleAmbientLight() {
        let light = rootNode.childNode(withName: "Ambient Light", recursively: true)
        light?.isHidden.toggle()
    }
    
    @MainActor
    func toggleDiffuseLight() {
        let light = rootNode.childNode(withName: "Diffuse Light", recursively: true)
        light?.isHidden.toggle()
    }
}
