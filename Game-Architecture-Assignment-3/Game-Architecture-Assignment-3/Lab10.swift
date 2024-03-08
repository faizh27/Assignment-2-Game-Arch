//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Lab10: Demo using Box2D for a ball that can be launched and
//        a falling brick that disappears when it hits the ball
//
//====================================================================

import SceneKit

import QuartzCore

class Box2DDemo: SCNScene {
    
    var cameraNode = SCNNode()                      // Initialize camera node
    
    var lastTime = CFTimeInterval(floatLiteral: 0)  // Used to calculate elapsed time on each update
    
    private var box2D: CBox2D!                      // Points to Objective-C++ wrapper for C++ Box2D library
    
    // Catch if initializer in init() fails
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Initializer
    override init() {
        
        super.init() // Implement the superclass' initializer
        
        background.contents = UIColor.black // Set the background colour to black
        
        setupCamera()
        
        // Add the ball and the brick
        addBall()
        addBrick()
        
        // Initialize the Box2D object
        box2D = CBox2D()
        //        box2D.helloWorld()  // If you want to test the HelloWorld example of Box2D
        
        // Setup the game loop tied to the display refresh
        let updater = CADisplayLink(target: self, selector: #selector(gameLoop))
        updater.preferredFrameRateRange = CAFrameRateRange(minimum: 120.0, maximum: 120.0, preferred: 120.0)
        updater.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        
    }
    
    
    // Function to setup the camera node
    func setupCamera() {
        
        let camera = SCNCamera() // Create Camera object
        cameraNode.camera = camera // Give the cameraNode a camera
        // Since this is 2D, just look down the z-axis
        cameraNode.position = SCNVector3(0, 50, 100)
        cameraNode.eulerAngles = SCNVector3(0, 0, 0)
        rootNode.addChildNode(cameraNode) // Add the cameraNode to the scene
        
    }
    
    
    func addBrick() {
        
        let theBrick = SCNNode(geometry: SCNBox(width: CGFloat(BRICK_WIDTH), height: CGFloat(BRICK_HEIGHT), length: 1, chamferRadius: 0))
        theBrick.name = "Brick"
        theBrick.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        theBrick.position = SCNVector3(Int(BRICK_POS_X), Int(BRICK_POS_Y), 0)
        rootNode.addChildNode(theBrick)
        
    }
    
    
    func addBall() {
        
        let theBall = SCNNode(geometry: SCNSphere(radius: CGFloat(BALL_RADIUS)))
        theBall.name = "Ball"
        theBall.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        theBall.position = SCNVector3(Int(BALL_POS_X), Int(BALL_POS_Y), 0)
        rootNode.addChildNode(theBall)
        
    }
    
    
    // Simple game loop that gets called each frame
    @MainActor
    @objc
    func gameLoop(displaylink: CADisplayLink) {
        
        if (lastTime != CFTimeInterval(floatLiteral: 0)) {  // if it's the first frame, just update lastTime
            let elapsedTime = displaylink.targetTimestamp - lastTime    // calculate elapsed time
            updateGameObjects(elapsedTime: elapsedTime) // update all the game objects
        }
        lastTime = displaylink.targetTimestamp
        
    }
    
    
    @MainActor
    func updateGameObjects(elapsedTime: Double) {
        
        // Update Box2D physics simulation
        box2D.update(Float(elapsedTime))
        
        // Get ball position and update ball node
        let ballPos = UnsafePointer(box2D.getObject("Ball"))
        let theBall = rootNode.childNode(withName: "Ball", recursively: true)
        theBall?.position.x = (ballPos?.pointee.loc.x)!
        theBall?.position.y = (ballPos?.pointee.loc.y)!
        //        print("Ball pos: \(String(describing: theBall?.position.x)) \(String(describing: theBall?.position.y))")
        
        // Get brick position and update brick node
        let brickPos = UnsafePointer(box2D.getObject("Brick"))
        let theBrick = rootNode.childNode(withName: "Brick", recursively: true)
        if (brickPos != nil) {
            
            // The brick is visible, so set the position
            theBrick?.position.x = (brickPos?.pointee.loc.x)!
            theBrick?.position.y = (brickPos?.pointee.loc.y)!
            //            print("Brick pos: \(String(describing: theBrick?.position.x)) \(String(describing: theBrick?.position.y))")
            
        } else {
            
            // The brick has disappeared, so hide it
            theBrick?.isHidden = true
            
        }
        
    }
    
    
    // Function to be called by double-tap gesture: launch the ball
    @MainActor
    func handleDoubleTap() {
        
        box2D.launchBall()
        
    }
    
    
    // Function to reset the physics (reset Box2D and reset the brick)
    @MainActor
    func resetPhysics() {
        
        box2D.reset()
        let theBrick = rootNode.childNode(withName: "Brick", recursively: true)
        theBrick?.isHidden = false
        
    }
    
}

