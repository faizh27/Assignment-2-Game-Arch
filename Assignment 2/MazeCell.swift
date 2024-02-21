//
//  Food.swift
//  Pet Bullet Heaven
//
//  Created by Jun Solomon on 2024-02-14.
//

import Foundation
import SceneKit

///
/// Rudimentary Food Class
///
class MazeCell : SCNNode {
    
    var _Health : Int = 1
    
    //var _Mesh : SCNBox?
    
    var spawnLocation : SCNVector3 = SCNVector3(0, 0, 0)
    var xPos : Float = 0
    var zPos : Float = 0

    var cellSize : CGFloat = 1
    
    init(xPos: Float, zPos: Float, northWall: Bool, southWall: Bool, eastWall: Bool, westWall: Bool) {
        self.xPos = xPos
        self.zPos = zPos
        self.spawnLocation = SCNVector3(xPos, 0, zPos)
        super.init()
        
        // Create walls based on the presence flags
        if northWall {
//            let wallGeometry = SCNBox(width: 1.0, height: 1.0, length: 0.05, chamferRadius: 0.0)
//            let boxMaterial = SCNMaterial()
//            boxMaterial.diffuse.contents = UIColor.red // Set diffuse color to red
//            wallGeometry.firstMaterial = boxMaterial
//            let wallNode = SCNNode(geometry: wallGeometry)
//            wallNode.position = SCNVector3(0, 0.5, 0.475) // Adjust position to align with cell
//            self.addChildNode(wallNode)
            let wallGeometry = SCNBox(width: 0.05, height: 1.0, length: 1.0, chamferRadius: 0.0)
            let boxMaterial = SCNMaterial()
            boxMaterial.diffuse.contents = UIColor.black // Set diffuse color to red
            wallGeometry.firstMaterial = boxMaterial
            let wallNode = SCNNode(geometry: wallGeometry)
            wallNode.position = SCNVector3(0.475, 0.5, 0) // Adjust position to align with cell
            self.addChildNode(wallNode)
        }
        if southWall {
//            let wallGeometry = SCNBox(width: 1.0, height: 1.0, length: 0.05, chamferRadius: 0.0)
//            let boxMaterial = SCNMaterial()
//            boxMaterial.diffuse.contents = UIColor.green // Set diffuse color to red
//            wallGeometry.firstMaterial = boxMaterial
//            let wallNode = SCNNode(geometry: wallGeometry)
//            wallNode.position = SCNVector3(0, 0.5, -0.475) // Adjust position to align with cell
//            self.addChildNode(wallNode)
            let wallGeometry = SCNBox(width: 0.05, height: 1.0, length: 1.0, chamferRadius: 0.0)
            let boxMaterial = SCNMaterial()
            boxMaterial.diffuse.contents = UIColor.blue // Set diffuse color to red
            wallGeometry.firstMaterial = boxMaterial
            let wallNode = SCNNode(geometry: wallGeometry)
            wallNode.position = SCNVector3(-0.475, 0.5, 0) // Adjust position to align with cell
            self.addChildNode(wallNode)
        }
        if eastWall {
//            let wallGeometry = SCNBox(width: 0.05, height: 1.0, length: 1.0, chamferRadius: 0.0)
//            let boxMaterial = SCNMaterial()
//            boxMaterial.diffuse.contents = UIColor.blue // Set diffuse color to red
//            wallGeometry.firstMaterial = boxMaterial
//            let wallNode = SCNNode(geometry: wallGeometry)
//            wallNode.position = SCNVector3(-0.475, 0.5, 0) // Adjust position to align with cell
//            self.addChildNode(wallNode)
            let wallGeometry = SCNBox(width: 1.0, height: 1.0, length: 0.05, chamferRadius: 0.0)
            let boxMaterial = SCNMaterial()
            boxMaterial.diffuse.contents = UIColor.red // Set diffuse color to red
            wallGeometry.firstMaterial = boxMaterial
            let wallNode = SCNNode(geometry: wallGeometry)
            wallNode.position = SCNVector3(0, 0.5, 0.475) // Adjust position to align with cell
            self.addChildNode(wallNode)
        }
        if westWall {
//            let wallGeometry = SCNBox(width: 0.05, height: 1.0, length: 1.0, chamferRadius: 0.0)
//            let boxMaterial = SCNMaterial()
//            boxMaterial.diffuse.contents = UIColor.black // Set diffuse color to red
//            wallGeometry.firstMaterial = boxMaterial
//            let wallNode = SCNNode(geometry: wallGeometry)
//            wallNode.position = SCNVector3(0.475, 0.5, 0) // Adjust position to align with cell
//            self.addChildNode(wallNode)
            let wallGeometry = SCNBox(width: 1.0, height: 1.0, length: 0.05, chamferRadius: 0.0)
            let boxMaterial = SCNMaterial()
            boxMaterial.diffuse.contents = UIColor.green // Set diffuse color to red
            wallGeometry.firstMaterial = boxMaterial
            let wallNode = SCNNode(geometry: wallGeometry)
            wallNode.position = SCNVector3(0, 0.5, -0.475) // Adjust position to align with cell
            self.addChildNode(wallNode)
        }
//        if northWall {
//                            let northWallNode = SCNNode(geometry: SCNBox(width: cellSize, height: 1, length: wallThickness, chamferRadius: 0))
//                            northWallNode.position = SCNVector3(cellPosition.x, Float(wallThickness)/2, cellPosition.z - Float((cellSize)/2))
//                            mazeNode.addChildNode(northWallNode)
//                        }
//        if southWall {
//                            let southWallNode = SCNNode(geometry: SCNBox(width: cellSize, height: 1, length: wallThickness, chamferRadius: 0))
//                            southWallNode.position = SCNVector3(cellPosition.x, Float(wallThickness)/2, cellPosition.z + Float((cellSize))/2)
//                            mazeNode.addChildNode(southWallNode)
//
//                        }
//
//                        if eastWall {
//
//                            let eastWallNode = SCNNode(geometry: SCNBox(width: wallThickness, height: 1, length: cellSize, chamferRadius: 0))
//
//                            eastWallNode.position = SCNVector3(cellPosition.x + Float((cellSize))/2, Float(wallThickness)/2, cellPosition.z)
//                            mazeNode.addChildNode(eastWallNode)
//                        }
//
//                        if westWall {
//                            let westWallNode = SCNNode(geometry: SCNBox(width: wallThickness, height: 1, length: cellSize, chamferRadius: 0))
//                            westWallNode.position = SCNVector3(cellPosition.x - Float((cellSize))/2, Float(wallThickness)/2, cellPosition.z)
//                            mazeNode.addChildNode(westWallNode)
//                        }
        
        // Create the floor or other geometry for the cell
        let floorGeometry = SCNBox(width: 1.0, height: 0.01, length: 1.0, chamferRadius: 0.0)
        let floorNode = SCNNode(geometry: floorGeometry)
        
        // will be changed to whatever the model is
        floorNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/texture.png")
        
        self.position = spawnLocation
        
//        let angleInDegrees: Float = 45.0
//        let angleInRadians = angleInDegrees * .pi / 180.0
//        cubeNode.eulerAngles = SCNVector3(0, angleInRadians, 0)
        self.addChildNode(floorNode)
        
        //self._Mesh = cubeGeometry
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
