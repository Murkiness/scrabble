//
//  Letter.swift
//  ScrabbleDefence
//
//  Created by Vladimir Hohrenko on 06/05/2018.
//  Copyright © 2018 Vladimir Hohrenko. All rights reserved.
//

import SpriteKit

class Letter: SKSpriteNode, EventListenerNode {
    static var activeNode: Letter?
    var gridPosition: CGPoint
    private var value: String
    
    static func deactivateNode() {
        Letter.activeNode?.isActive = false
        Letter.activeNode = nil
    }
    
    var isActive = false {
        didSet {
            if isActive {
                run(SKAction.colorize(with: .red, colorBlendFactor: 0.5, duration: 0.5))
            } else {
                run(SKAction.colorize(with: .white, colorBlendFactor: 1, duration: 1))
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        value = "NO"
        gridPosition = CGPoint.zero // need to implement it when I need to save game
        super.init(coder: aDecoder)
        
    }
    
    init(letter: String, gridPosition: CGPoint) {
        self.gridPosition = gridPosition
        value = letter
        let texture = SKTexture(imageNamed: letter)
        super.init(texture: texture, color: .white, size: texture.size())
        
    }
    
    func getActualLetter() -> String {
        return self.value
    }
    
    func didMoveToScene() {
        isUserInteractionEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if Letter.activeNode == nil {
            Letter.activeNode = self
        } else if Letter.activeNode != self {
            Letter.deactivateNode()
            Letter.activeNode = self
        }
        
        isActive = !isActive
    }
    
}


