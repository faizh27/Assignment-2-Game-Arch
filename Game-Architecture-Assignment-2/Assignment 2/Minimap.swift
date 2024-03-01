//
//  Minimap.swift
//  Assignment 2
//
//  Created by Jun Solomon on 2024-02-22.
//

import Foundation
import SceneKit
import SpriteKit

class Minimap: SKScene {
    // maze stuff
    var numberOfRows = 0 // Number of rows in the grid
    var numberOfColumns = 0 // Number of columns in the grid
    let minimapWidth: CGFloat = 300 // Width of the screen
    let minimapHeight: CGFloat = 300 // Height of the screen
    var cellSize: CGSize = CGSize(width: 0, height: 0)
    let wallWidth: CGFloat = 3
    let wallColor: UIColor = .white
    var gridCoordinates: [String: CGPoint] = [:]
    public var maze: Maze = Maze(0, 0)
    
    var playerNode: SKShapeNode!
    
    init(size: CGSize, maze: Maze) {
        self.maze = maze
        super.init(size: size)
        numberOfRows = Int(maze.rows)
        numberOfColumns = Int(maze.cols)
        createGridCoordinates()
        createMiniMap()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        //anchorPoint = CGPoint(x: 0.0, y: 0.0)
        
        // Create a triangle shape
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -5, y: -5))
        path.addLine(to: CGPoint(x: 0, y: 10))
        path.addLine(to: CGPoint(x: 5, y:-5))
        path.closeSubpath()
        
        playerNode = SKShapeNode(path: path)
        playerNode.fillColor = .white
        playerNode.strokeColor = .clear
        //playerNode.zRotation += CGFloat.pi
        
        // Position the triangle at a specific point
        playerNode.position = gridCoordinates["\(0),\(0)"]!
        
        // Add the triangle to the scene
        addChild(playerNode)
    }

    var cardDirection: [String] = ["north", "east", "south", "west"]
    var currentX = 0
    var currentY = 0
    
    @objc
    func resetPos() {
        playerNode.position = gridCoordinates["\(0),\(0)"]!
        playerNode.zRotation = CGFloat.pi
    }
    
    func movePlayer(playerX: Float, playerZ: Float, playerRot: Float) {
        let x = Int(round(playerZ))
        let y = Int(round(playerX)) * -1
        print("X: \(x), Y: \(y), Rot: \(playerRot)")
        if let newPosition = gridCoordinates["\(x),\(y)"] {
            let moveAction = SKAction.move(to: newPosition, duration: 0.5) // Adjust duration as needed
            playerNode.run(moveAction)
        }
        playerNode.zRotation = CGFloat(playerRot) + CGFloat.pi
    }
    
    // idk I can't believe I did all this
    func createGridCoordinates() {
        let startX = (UIScreen.main.bounds.size.width - minimapWidth) / 2
        let startY = (UIScreen.main.bounds.size.height - minimapHeight) / 2
        
        let cellWidth = minimapWidth / CGFloat(numberOfColumns)
        let cellHeight = minimapHeight / CGFloat(numberOfRows)
        cellSize = CGSize(width: min(cellWidth, cellHeight), height: min(cellWidth, cellHeight))
        
        let cellCenter: CGPoint = CGPoint(x: cellWidth / 2, y: cellHeight / 2)
        
        var reverseRows = numberOfRows - 1
        for row in 0..<numberOfRows {
            for col in 0..<numberOfColumns {
                // Calculate the position of the current cell's center
                let x = startX + CGFloat(col) * cellSize.width + cellCenter.x
                let y = startY + CGFloat(row) * cellSize.height + cellCenter.y
                let string = "\(col),\(reverseRows)"
                gridCoordinates[string] = CGPoint(x: x, y: y)
            }
            reverseRows -= 1
        }
        
//        print("")
//        for (key, value) in gridCoordinates {
//            print("Key:", key, "Value:", value)
//        }
    }
    
    func createMiniMap() {
        for row in 0..<numberOfRows {
            for col in 0..<numberOfColumns {
                let cell = maze.GetCell(Int32(row), Int32(col))
                drawCell(pos: gridCoordinates["\(col),\(row)"]!, northWall: cell.northWallPresent, southWall: cell.southWallPresent, eastWall: cell.eastWallPresent, westWall: cell.westWallPresent)
            }
        }
        
        // uncomment to see grid points
//        for (key, value) in gridCoordinates {
//            print("Key:", key, "Value:", value)
//            let pointSize: CGFloat = 4 // Set the size of the point
//            let point = SKShapeNode(circleOfRadius: pointSize / 2)
//            point.fillColor = .green
//            point.strokeColor = .clear
//            point.position = value
//            addChild(point)
//        }
    }
    
    func drawCell(pos: CGPoint, northWall: Bool, southWall: Bool, eastWall: Bool, westWall: Bool) {
        
        if northWall {
            let northWall = SKSpriteNode(color: wallColor, size: CGSize(width: cellSize.width, height: wallWidth))
            northWall.position = pos
            northWall.position.y += cellSize.height / 2
            northWall.color = .blue
            addChild(northWall)
        }
        if eastWall {
            let eastWall = SKSpriteNode(color: wallColor, size: CGSize(width: wallWidth, height: cellSize.height))
            eastWall.position = pos
            eastWall.position.x += cellSize.width / 2
            eastWall.color = .red
            addChild(eastWall)
        }

        if southWall {
            let southWall = SKSpriteNode(color: wallColor, size: CGSize(width: cellSize.width, height: wallWidth))
            southWall.position = pos
            southWall.position.y -= cellSize.height / 2
            southWall.color = .green
            addChild(southWall)
        }

        if westWall {
            let westWall = SKSpriteNode(color: wallColor, size: CGSize(width: wallWidth, height: cellSize.height))
            westWall.position = pos
            westWall.position.x -= cellSize.width / 2
            westWall.color = .black
            addChild(westWall)
        }
    }
}
