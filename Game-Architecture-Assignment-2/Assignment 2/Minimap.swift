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
    let numberOfRows = 20 // Number of rows in the grid
    let numberOfColumns = 20 // Number of columns in the grid
    let screenWidth: CGFloat = 250 // Width of the screen
    let screenHeight: CGFloat = 250 // Height of the screen
    var cellSize: CGSize = CGSize(width: 0, height: 0)
    let wallWidth: CGFloat = 2
    let wallColor: UIColor = .white

    public var maze: Maze = Maze(0, 0)
    
    override init(size: CGSize) {
        //self.maze = maze
        super.init(size: size)
        createGrid()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }
    
    
    func setMaze(maze: Maze) {
        self.maze = maze
    }
    
    func createGrid() {
        // Calculate the cell size based on the screen size and number of rows/columns
        let cellWidth = screenWidth / CGFloat(numberOfColumns)
        let cellHeight = screenHeight / CGFloat(numberOfRows)

        // Use the minimum of cellWidth and cellHeight to ensure cells fit within the screen
        cellSize = CGSize(width: min(cellWidth, cellHeight), height: min(cellWidth, cellHeight))
        
        let startX = -CGFloat(numberOfColumns) * cellSize.width / 2
        let startY = -CGFloat(numberOfRows) * cellSize.height / 2
        
        for row in 0..<numberOfRows {
            for col in 0..<numberOfColumns {
                let x = startX + CGFloat(col) * cellSize.width
                let y = startY + CGFloat(row) * cellSize.height
                let cellRect = CGRect(x: x, y: y, width: cellSize.width, height: cellSize.height)
                let cellNode = SKShapeNode(rect: cellRect, cornerRadius: 0)
                cellNode.strokeColor = .white
                cellNode.lineWidth = 2
                addChild(cellNode)
                
                // Assign coordinates to the cell
                cellNode.userData = NSMutableDictionary()
                cellNode.userData?.setValue(row, forKey: "row")
                cellNode.userData?.setValue(col, forKey: "column")
            }
        }
    }
    
//    func createNorthWall() {
//        let northWall = SKShapeNode(rectOf: CGSize(width: cellSize.width, height: wallWidth))
//        northWall.position = CGPoint(x: cellX, y: cellY + cellSize)
//        addChild(northWall)
//    }
}
