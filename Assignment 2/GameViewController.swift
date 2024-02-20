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
        
    func createMazeNode() -> SCNNode {
        let mazeNode = SCNNode()
        
        var maze = Maze(5, 5)
        maze.Create()
        
        // Define the size of a single cell, padding, and wall thickness
        let cellSize: CGFloat = 1.0
        let wallThickness: CGFloat = 0.1
        
        // Iterate through maze cells
        for row in 0..<maze.rows {
            for col in 0..<maze.cols {
                let cell = maze.GetCell(row, col)
                let cellPosition = SCNVector3(CGFloat(col) * (cellSize), 0, CGFloat(row) * (cellSize))
                
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
        
        return mazeNode
    }
    
    var rotAngle = CGSize.zero // Keep track of drag gesture numbers
    var rot = CGSize.zero // Keep track of rotation angle
    var isRotating = true // Keep track of if rotation is toggled
    var cameraNode = SCNNode() // Initialize camera node
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
        
        
        // Create the maze node
        let mazeNode = createMazeNode()

        // Add the maze node to the scene
        scene.rootNode.addChildNode(mazeNode)
        
        addCube()
        reanimate()
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
