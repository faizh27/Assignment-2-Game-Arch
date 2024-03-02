
import Foundation
import SceneKit
import SpriteKit

class Minimap: SKScene {
    // maze stuff
    var numOfRows = 0
    var numOfColumns = 0
    let mapWidth: CGFloat = 300
    let mapHeight: CGFloat = 300
    var cellSize: CGSize = CGSize(width: 0, height: 0)
    let wallWidth: CGFloat = 3
    let wallColor: UIColor = .black
    var gridCoords: [String: CGPoint] = [:]
    public var maze: Maze = Maze(0, 0)
    
    var playerNode: SKShapeNode!
    
    init(size: CGSize, maze: Maze) {
        self.maze = maze
        super.init(size: size)
        numOfRows = Int(maze.rows)
        numOfColumns = Int(maze.cols)
        createGridCoordinates()
        createMiniMap()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        // Create a triangle shape
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -5, y: -5))
        path.addLine(to: CGPoint(x: 0, y: 10))
        path.addLine(to: CGPoint(x: 5, y:-5))
        path.closeSubpath()
        
        playerNode = SKShapeNode(path: path)
        playerNode.fillColor = .red
        playerNode.strokeColor = .clear
        playerNode.zRotation += CGFloat.pi
        
        playerNode.position = gridCoords["\(0),\(0)"]!
        
        addChild(playerNode)
    }

    var cardDirection: [String] = ["north", "east", "south", "west"]
    var currentX = 0
    var currentY = 0
    
    @objc
    func resetPos() {
        playerNode.position = gridCoords["\(0),\(0)"]!
        playerNode.zRotation = CGFloat.pi
    }
    
    func createGridCoordinates() {
        let startX = (UIScreen.main.bounds.size.width - mapWidth) / 2
        let startY = (UIScreen.main.bounds.size.height - mapHeight) / 2
        
        let cellWidth = mapWidth / CGFloat(numOfColumns)
        let cellHeight = mapHeight / CGFloat(numOfRows)
        cellSize = CGSize(width: min(cellWidth, cellHeight), height: min(cellWidth, cellHeight))
        
        let cellCenter: CGPoint = CGPoint(x: cellWidth / 2, y: cellHeight / 2)
        
        var reverseRows = numOfRows - 1
        for row in 0..<numOfRows {
            for col in 0..<numOfColumns {
                // Calculate the position of the current cell's center
                let x = startX + CGFloat(col) * cellSize.width + cellCenter.x
                let y = startY + CGFloat(row) * cellSize.height + cellCenter.y
                let string = "\(col),\(reverseRows)"
                gridCoords[string] = CGPoint(x: x, y: y)
            }
            reverseRows -= 1
        }
    }
    
    func createMiniMap() {
        for row in 0..<numOfRows {
            for col in 0..<numOfColumns {
                let cell = maze.GetCell(Int32(row), Int32(col))
                drawCell(pos: gridCoords["\(col),\(row)"]!, northWall: cell.northWallPresent, southWall: cell.southWallPresent, eastWall: cell.eastWallPresent, westWall: cell.westWallPresent)
            }
        }
    }
    
    func drawCell(pos: CGPoint, northWall: Bool, southWall: Bool, eastWall: Bool, westWall: Bool) {
        
        if northWall {
            let northWall = SKSpriteNode(color: wallColor, size: CGSize(width: cellSize.width, height: wallWidth))
            northWall.position = pos
            northWall.position.y += cellSize.height / 2
            addChild(northWall)
        }
        if eastWall {
            let eastWall = SKSpriteNode(color: wallColor, size: CGSize(width: wallWidth, height: cellSize.height))
            eastWall.position = pos
            eastWall.position.x += cellSize.width / 2
            addChild(eastWall)
        }

        if southWall {
            let southWall = SKSpriteNode(color: wallColor, size: CGSize(width: cellSize.width, height: wallWidth))
            southWall.position = pos
            southWall.position.y -= cellSize.height / 2
            addChild(southWall)
        }

        if westWall {
            let westWall = SKSpriteNode(color: wallColor, size: CGSize(width: wallWidth, height: cellSize.height))
            westWall.position = pos
            westWall.position.x -= cellSize.width / 2
            addChild(westWall)
        }
    }
    
    public func updatePlayer(position: SCNVector3, rotation: SCNVector3) {
        
        let col = Int(round(position.x))
        let row = Int(round(position.z))
        
        if (row >= 0 && row < maze.rows && col >= 0 && col < maze.cols) {
            playerNode.position = gridCoords["\(col),\(row)"]!
            playerNode.zRotation = CGFloat(rotation.y)
        }
        
        
    }
}
