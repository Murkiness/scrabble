//
//  GameScene.swift
//  ScrabbleDefence
//
//  Created by Vladimir Hohrenko on 02/05/2018.
//  Copyright © 2018 Vladimir Hohrenko. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Edge: Int {
    case Both = 2
    case One = 1
    case None = 0
}

struct Ways {
    static let Left = CGPoint(x: -1, y: 0)
    static let Right = CGPoint(x: 1, y: 0)
    static let Top = CGPoint(x: 0, y: 1)
    static let Bottom = CGPoint(x: 0, y: -1)
}

protocol EventListenerNode {
    func didMoveToScene()
}

typealias TileCoordinates = (column: Int, row: Int)


class GameScene: SKScene {
    //MARK: - Game constants
    let mapColumns = 10
    let mapRows = 10
    let numOfStartLetters = 9
    let alphabetArray = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map({ String($0) })
    
    var gameIsBusy = false
    
    var scrabbleBackgroundMap: SKTileMapNode?
    
    var obstacles = [Letter]()
    
    
    override func didMove(to view: SKView) {
        
        createBackground()
        startGame()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameIsBusy { return }

        guard  let touch = touches.first else { return }
        
        let activeNode = Letter.activeNode
        
        let posInScene = touch.location(in: self)
        let touchedNode = self.atPoint(posInScene)
        
        if touchedNode.name == "Background" && activeNode != nil {
            gameIsBusy = true
            if let currentLetter = moveActiveLetter(posInScene) {
                findAdjacentLetter(letter: currentLetter)
            } else {
                gameIsBusy = false
            }
        }
        
    }
    
    //MARK: Handle Finding Words
    func findAdjacentLetter(letter: Letter) {
        let currentPosition = letter.gridPosition
        var horizontalArray = [Letter]()
        var verticalArray = [Letter]()
        
        var tempArray = [Letter]()
        
        horizontalArray.append(contentsOf: go(way: Ways.Left, currentPoint: currentPosition, &tempArray))
        horizontalArray.reverse()
        horizontalArray.append(letter)
        tempArray.removeAll()
        horizontalArray.append(contentsOf: go(way: Ways.Right, currentPoint: currentPosition, &tempArray))
        
        tempArray.removeAll()
        verticalArray.append(contentsOf: go(way: Ways.Top, currentPoint: currentPosition, &tempArray))
        verticalArray.reverse()
        verticalArray.append(letter)
        tempArray.removeAll()
        verticalArray.append(contentsOf: go(way: Ways.Bottom, currentPoint: currentPosition, &tempArray))
        
        var hstr = horizontalArray.map { $0.getActualLetter()}
        var h = hstr.joined(separator: "")
        
        var vstr = verticalArray.map { $0.getActualLetter()}
        var v = vstr.joined(separator: "")
        
        print("Horizontal string is \(h)")
        print("Vertical string is \(v)")
        
        findWords(source: h)
        
        
//        print("Horizontal string is \(horizontalString)")
//        print("Vertical string is \(verticalString)")
        
        
    }
    
    // need to come with other name
    func go(way: CGPoint, currentPoint: CGPoint, _ letterArray: inout [Letter]) -> [Letter] {
        let resultPoint = way + currentPoint
        if Int(resultPoint.x) >= mapColumns
            || Int(resultPoint.y) >= mapRows
            || Int(resultPoint.x) < 0
            || Int(resultPoint.y) < 0 {
            return letterArray
        }
        
        let letter = obstacles.filter { $0.gridPosition == resultPoint }.first
        
        if letter == nil {
            return letterArray
        } else {
            letterArray.append(letter!)
            return go(way: way, currentPoint: resultPoint, &letterArray)
        }
        
    }
    
    func findWords(source: String) -> [String] {
        var result = [String]()
        let file = "ospd.txt"
        
        if let path = Bundle.main.path(forResource: "ospd", ofType: "txt"){
            let fm = FileManager()
            let exists = fm.fileExists(atPath: path)
            
            if exists {
                let content = fm.contents(atPath: path)
                if let contentAsString = String(data: content!, encoding: .utf8) {
                    let index = contentAsString.index((contentAsString.startIndex), offsetBy: 20)
                    print("Reading from file \(contentAsString[...index])")
                    
                }
                



                
            }
            
            
        }
        
        
        
        return result
    }
    
    func startGame() {
        createLettersOnMap(numberToGenerate: numOfStartLetters)
    }
    
    //MARK: - Map generation methods and helper methods
    
    func createBackground() {
        let basicTexture = SKTexture(imageNamed: "tile1_2")
        let basicTileDefinition = SKTileDefinition(texture: basicTexture)
        let tileGroup = SKTileGroup(tileDefinition: basicTileDefinition)
        let tileset = SKTileSet(tileGroups: [tileGroup])
        tileset.name = "BackgroundSet"
        scrabbleBackgroundMap = SKTileMapNode(tileSet: tileset, columns: mapColumns, rows: mapRows, tileSize: basicTileDefinition.size, fillWith: tileGroup)
        scrabbleBackgroundMap?.name = "Background"
        
        addChild(scrabbleBackgroundMap!)
    }

    //MARK: - Generate letters methods
    
    func generatePlacesOnMap(for number: Int) -> [(Int, Int)] {
        let numOfRows = scrabbleBackgroundMap!.numberOfRows
        let numOfColumns = scrabbleBackgroundMap!.numberOfColumns

        //TODO: place should be checking on existing map!!

        var placesOnMap: [(row: Int, col: Int)] = []
        var i = 0
        while i != number {
            let tempPlace = generatePlace(numOfRows, numOfColumns)
            if !placesOnMap.contains(where: { $0 == tempPlace }) {
                
                placesOnMap.append(tempPlace)
                i += 1
            }
        }
        
        return placesOnMap
    }
    
    func generateRandomLetter() -> String {
        // TODO: maybe complex logic should be here to take into account rare/frequent letters
        return alphabetArray[Int.random(alphabetArray.count)]
    }
    
    func createLettersOnMap(numberToGenerate: Int) {
        
        let places = generatePlacesOnMap(for: numberToGenerate)
        
        for i in 0..<numberToGenerate {
            let letter = generateRandomLetter()
            let place = places[i]
            let gridPos = CGPoint(x: place.0, y: place.1)
            let letterNode = Letter(letter: letter, gridPosition: gridPos)
            
            let pos = scrabbleBackgroundMap?.centerOfTile(atColumn: place.0, row: place.1)
            letterNode.position = pos!
            addChild(letterNode)
            letterNode.didMoveToScene()
            obstacles.append(letterNode)
        }
        //Everytime letter node created, it is counted as obstacle for pathfinding
//        for place in places {
//            //obstacles.append(CGPoint(x: place.0, y: place.1))
//
//        }
        

    }
    
    func generatePlace(_ upperBoundRow: Int, _ upperBoundCol: Int) -> (Int, Int) {
        let row = Int.random(upperBoundRow)
        let col = Int.random(upperBoundCol)
        
        return (col, row)
    }
    
    func tile(in tileMap: SKTileMapNode,at coordinates: TileCoordinates) -> SKTileDefinition? {
            return tileMap.tileDefinition(atColumn: coordinates.column,
                                            row: coordinates.row)
    }
    
    func tileCoordinates(in tileMap: SKTileMapNode, at position: CGPoint) -> TileCoordinates {
        let column = tileMap.tileColumnIndex(fromPosition: position)
        let row = tileMap.tileRowIndex(fromPosition: position)
        return (column, row)
    }
    
}

//MARK: Move letter methods
extension GameScene {
    func moveActiveLetter(_ toPosition: CGPoint) -> Letter? { // refactor???
        let startCoordinates = getCoordinates(at: Letter.activeNode!.position)
        let endCoordinates = getCoordinates(at: toPosition)
        
        let graph = GKGridGraph(fromGridStartingAt: vector2(0, 0), width: Int32(mapColumns), height: Int32(mapRows), diagonalsAllowed: false)
        
        let startNode = graph.node(atGridPosition: vector_int2(startCoordinates.0, startCoordinates.1))
        let endNode = graph.node(atGridPosition: vector_int2(endCoordinates.0, endCoordinates.1))
        
        //find current Letter in obstacles and remove it from there
        let x = Int(startCoordinates.0)
        let y = Int(startCoordinates.1)
        let currentNodePosition = CGPoint(x: x, y: y)
        let blocked = isNodeBlocked(position: currentNodePosition)
        if  blocked {
            return nil
        }
        
        let currentLetter = obstacles.filter { $0.gridPosition == currentNodePosition}.first!
        obstacles.remove(at: obstacles.index(of: currentLetter)!)
        
        //transforming obstacles to work with grid
        let preGKObstacles = obstacles.map { $0.gridPosition}
        let gkObstacles = preGKObstacles.map {
            graph.node(atGridPosition: simd_int2(Int32($0.x), Int32($0.y)))!}
        
        //find path
        graph.remove(gkObstacles as [GKGraphNode])
        let path = graph.findPath(from: startNode!, to: endNode!) as! [GKGridGraphNode]
        var points = path.map { $0.gridPosition}
        points.remove(at: 0) //mb possible to delete?
        
        //move Letter using path and handle its state
        var moveActions = [SKAction]()
        for p in points {
            let position = scrabbleBackgroundMap!.centerOfTile(atColumn: Int(p[0]), row: Int(p[1]))
            moveActions.append(SKAction.move(to: position, duration: 0.5))
        }
        
        Letter.activeNode?.run(SKAction.sequence(moveActions)) {
            self.gameIsBusy = false
        }
        Letter.deactivateNode()
        
        //update moved Letter and add it to obstacles again
        let newX = Int(endCoordinates.0)
        let newY = Int(endCoordinates.1)
        currentLetter.gridPosition = CGPoint(x: newX, y: newY)
        obstacles.append(currentLetter)
        
        return currentLetter
        
    }
    
    func isNodeBlocked(position: CGPoint) -> Bool {
        let stateOfNode: Edge
        let x = Int(position.x)
        let y = Int(position.y)
        if (x == 0 || x == mapColumns-1), (y == 0 || y == mapRows-1) {
            stateOfNode = .Both
        } else if x == 0 || x == mapColumns-1 || y == 0 || y == mapRows-1 {
            stateOfNode = .One
        } else {
            stateOfNode = .None
        }
        
        let neighborNodes = obstacles.filter { $0.gridPosition == position + Ways.Left
                                            || $0.gridPosition == position + Ways.Right
                                            || $0.gridPosition == position + Ways.Top
                                            || $0.gridPosition == position + Ways.Bottom }
        
        switch stateOfNode {
        case .Both:
            if neighborNodes.count == 2 {
                return true
            }
        case .One:
            if neighborNodes.count == 3 {
                return true
            }
        case .None:
            if neighborNodes.count == 4 {
                return true
            }
        }
        
        return false
    }
    
    
    func getCoordinates(at position: CGPoint) -> (Int32, Int32) {
        let row = scrabbleBackgroundMap!.tileRowIndex(fromPosition: position)
        let col = scrabbleBackgroundMap!.tileColumnIndex(fromPosition: position)
        
        return (Int32(col), Int32(row))
    }
}
