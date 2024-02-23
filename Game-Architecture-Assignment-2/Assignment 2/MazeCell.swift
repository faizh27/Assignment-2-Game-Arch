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
            let wallGeometry = SCNBox(width: 0.05, height: 1.0, length: 1.0, chamferRadius: 0.0)
            wallGeometry.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/blue.jpeg")
            let wallNode = SCNNode(geometry: wallGeometry)
            wallNode.position = SCNVector3(0.475, 0.5, 0) // Adjust position to align with cell
            wallNode.castsShadow = true
            self.addChildNode(wallNode)
        }
        if southWall {

            let wallGeometry = SCNBox(width: 0.05, height: 1.0, length: 1.0, chamferRadius: 0.0)
            wallGeometry.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/brick.jpeg")
            let wallNode = SCNNode(geometry: wallGeometry)
            wallNode.position = SCNVector3(-0.475, 0.5, 0) // Adjust position to align with cell
            wallNode.castsShadow = true
            self.addChildNode(wallNode)
        }
        if eastWall {

            let wallGeometry = SCNBox(width: 1.0, height: 1.0, length: 0.05, chamferRadius: 0.0)
            wallGeometry.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/dirt.jpeg")
            let wallNode = SCNNode(geometry: wallGeometry)
            wallNode.position = SCNVector3(0, 0.5, 0.475) // Adjust position to align with cell
            wallNode.castsShadow = true
            self.addChildNode(wallNode)
        }
        if westWall {

            let wallGeometry = SCNBox(width: 1.0, height: 1.0, length: 0.05, chamferRadius: 0.0)
            wallGeometry.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/wood.jpeg")
            let wallNode = SCNNode(geometry: wallGeometry)
            wallNode.position = SCNVector3(0, 0.5, -0.475) // Adjust position to align with cell
            wallNode.castsShadow = true
            self.addChildNode(wallNode)
        }

        
        // Create the floor or other geometry for the cell
        let floorGeometry = SCNBox(width: 1.0, height: 0.01, length: 1.0, chamferRadius: 0.0)
        let floorNode = SCNNode(geometry: floorGeometry)
        
        // will be changed to whatever the model is
        floorNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/cobblestone.jpeg")
        
        self.position = spawnLocation
        self.castsShadow = true
        self.addChildNode(floorNode)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
