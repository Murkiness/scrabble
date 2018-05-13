//
//  FindAdjacentLetterTests.swift
//  ScrabbleDefence
//
//  Created by Vladimir Hohrenko on 13/05/2018.
//  Copyright © 2018 Vladimir Hohrenko. All rights reserved.
//

import XCTest


@testable import ScrabbleDefence
class FindAdjacentLetterTests: XCTestCase {
    
    var gameScene: GameScene!
    
    override func setUp() {
        super.setUp()
        gameScene = GameScene()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStartLetterAtZeroZeroPosition() {
        var tempArray1 = [Letter]()
        var tempArray2 = [Letter]()
        var tempArray3 = [Letter]()
        var tempArray4 = [Letter]()
        let l1 = Letter(letter: "A", gridPosition: CGPoint(x: 0, y: 1))
        let l2 = Letter(letter: "B", gridPosition: CGPoint(x: 1, y: 0))
        let l3 = Letter(letter: "D", gridPosition: CGPoint(x: 2, y: 0))
        let targetL = Letter(letter: "C", gridPosition: CGPoint(x: 0, y: 0))
        gameScene.obstacles = []
        gameScene.obstacles.append(contentsOf: [l1, l2, l3, targetL])
        
        let r1 = gameScene.go(way: Ways.Left, currentPoint: targetL.gridPosition, &tempArray1)
        let r2 = gameScene.go(way: Ways.Right, currentPoint: targetL.gridPosition, &tempArray2)
        let r3 = gameScene.go(way: Ways.Top, currentPoint: targetL.gridPosition, &tempArray3)
        let r4 = gameScene.go(way: Ways.Bottom, currentPoint: targetL.gridPosition, &tempArray4)
        
        XCTAssertTrue(r1.count == 0)
        XCTAssertTrue(r2.count == 2)
        XCTAssertTrue(r3.count == 1)
        XCTAssertTrue(r4.count == 0)
        
    }
    
    func testStartLetterAtRightTopCorner() {
        //works only for 10 because currently rows and cols are hardcoded
        //and used for bounds check
        let mapRows = 10
        let mapColumns = 10
        
        var tempArray1 = [Letter]()
        var tempArray2 = [Letter]()
        var tempArray3 = [Letter]()
        var tempArray4 = [Letter]()
        let l1 = Letter(letter: "A", gridPosition: CGPoint(x: mapColumns-2, y: mapRows-1))
        let l2 = Letter(letter: "B", gridPosition: CGPoint(x: mapColumns-3, y: mapRows-1))
        let l3 = Letter(letter: "D", gridPosition: CGPoint(x: mapColumns-1, y: mapRows-2))
        let targetL = Letter(letter: "C", gridPosition: CGPoint(x: mapColumns-1, y: mapRows-1))
        gameScene.obstacles = []
        gameScene.obstacles.append(contentsOf: [l1, l2, l3, targetL])
        
        let r1 = gameScene.go(way: Ways.Left, currentPoint: targetL.gridPosition, &tempArray1)
        let r2 = gameScene.go(way: Ways.Right, currentPoint: targetL.gridPosition, &tempArray2)
        let r3 = gameScene.go(way: Ways.Top, currentPoint: targetL.gridPosition, &tempArray3)
        let r4 = gameScene.go(way: Ways.Bottom, currentPoint: targetL.gridPosition, &tempArray4)
        
        XCTAssertTrue(r1.count == 2)
        XCTAssertTrue(r2.count == 0)
        XCTAssertTrue(r3.count == 0)
        XCTAssertTrue(r4.count == 1)
        
    }
    

    
}
