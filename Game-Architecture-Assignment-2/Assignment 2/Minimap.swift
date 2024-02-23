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
    var numberOfRows = 0 // Number of rows in the grid
    var numberOfColumns = 0 // Number of columns in the grid
    let minimapWidth: CGFloat = 250 // Width of the screen
    let minimapHeight: CGFloat = 250 // Height of the screen
    var cellSize: CGSize = CGSize(width: 0, height: 0)
    let wallWidth: CGFloat = 3
    let wallColor: UIColor = .white

    public var maze: Maze = Maze(0, 0)
    
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
        }
    
    var aDic: [String: CGPoint] = [:]


    func createGridCoordinates() {
        
        let startX = (UIScreen.main.bounds.size.width - minimapWidth) / 2
        let startY = (UIScreen.main.bounds.size.height - minimapHeight) / 2
        
        let cellWidth = minimapWidth / CGFloat(numberOfColumns)
        let cellHeight = minimapHeight / CGFloat(numberOfRows)
        cellSize = CGSize(width: cellWidth, height: cellHeight)
        
        let cellCenter: CGPoint = CGPoint(x: cellWidth / 2, y: cellHeight / 2)
        
        var reverseRows = numberOfRows - 1
        for row in 0..<numberOfRows {
            for col in 0..<numberOfColumns {
                // Calculate the position of the current cell's center
                let x = startX + CGFloat(col) * cellSize.width + cellCenter.x
                let y = startY + CGFloat(row) * cellSize.height + cellCenter.y
                let string = "\(col),\(reverseRows)"
                aDic[string] = CGPoint(x: x, y: y)
            }
            reverseRows -= 1
        }
        
        print("")
        for (key, value) in aDic {
            print("Key:", key, "Value:", value)
        }
    }
    
    func createMiniMap() {
        for (key, value) in aDic {
            print("Key:", key, "Value:", value)
            let pointSize: CGFloat = 4 // Set the size of the point
            let point = SKShapeNode(circleOfRadius: pointSize / 2)
            point.fillColor = .green
            point.strokeColor = .clear
            point.position = value
            addChild(point)
            
        }
        
        for row in 0..<numberOfRows {
            for col in 0..<numberOfColumns {
                let cell = maze.GetCell(Int32(row), Int32(col))
                drawCell(pos: aDic["\(col),\(row)"]!, northWall: cell.northWallPresent, southWall: cell.southWallPresent, eastWall: cell.eastWallPresent, westWall: cell.westWallPresent)
            }
        }
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
