//
//  Qbert.swift
//  RyBert
//
//  Created by John Kennedy on 10/23/21.
//

import SpriteKit
import GameplayKit

class QbertClass {
    
    private var qbert : SKSpriteNode?
    private var qbert_x = 6
    private var qbert_y = 0
    private var gamegrid = GameGrid()
    private var myScene : SKScene?
    private var jumpCounter = 0
    
    
    init(withScene theScene: SKScene) {
        
        myScene = theScene
        
        self.qbert = SKSpriteNode(imageNamed: "qbert")
        if let qbert = qbert {
            qbert.size = CGSize(width: 64, height: 64)
            qbert.zPosition = 4
            qbert.position = gamegrid.convertToScreenFromGrid(X: qbert_x, Y: qbert_y)
            myScene?.addChild(qbert)
            
            
        }
        
    }
    
    func flyingQbert()
    {
        let np = CGPoint(x: 0, y: 500)
        let fly = SKAction.move(to: np, duration: 1.5)
        
        qbert_x = 6
        qbert_y = 0
        let p = gamegrid.convertToScreenFromGrid(X: qbert_x, Y: qbert_y)
        
        let drop = SKAction.move(to: p, duration: 0.2)
        
        
        qbert?.run(SKAction.sequence([fly, drop]))
        
    }
    
    func getSpritePosition() -> CGPoint {
        return qbert!.position
    }
    
    func getPosition() -> (Int,Int) {
        return (qbert_x, qbert_y)
    }
    
    func setPosition (X: Int, Y: Int) {
        qbert_x = X
        qbert_y = Y
    }
    
    
    func moveQbert(tap: CGPoint)
    {
        if jumpCounter != 0  { return }
        
        // Map current player position to screen
        
        let p = gamegrid.convertToScreenFromGrid(X: qbert_x, Y: qbert_y)
        
        //   let p = CGPoint(x: 0, y: 0 )
        
        // Use tap co-ords to see which direction the player wants to jump
        
        
        
        let h = tap.x - p.x
        let v = tap.y - p.y
        
        var height : CGFloat = 0
        var side : CGFloat = 0
        
        if (h > 0 && v > 0)
        {
            
            qbert_x = qbert_x + 1
            qbert_y = qbert_y - 1
            
            height = 128
            side = 16
            
            qbert?.texture = SKTexture(imageNamed: "qbertRU")
            
            
        }
        
        if (h > 0 && v < 0)
        {
            
            qbert_x = qbert_x + 1
            qbert_y = qbert_y + 1
            
            height = 32
            side = 16
            
            qbert?.texture = SKTexture(imageNamed: "qbertR")
            
            
        }
        
        if (h < 0 && v > 0)
        {
            
            qbert_x = qbert_x - 1
            qbert_y = qbert_y - 1
            
            height = 128
            side = -16
            
            qbert?.texture = SKTexture(imageNamed: "qbertLU")
            
            
        }
        
        if (h < 0 && v < 0)
        {
            
            qbert_x = qbert_x - 1
            qbert_y = qbert_y + 1
            
            height = 32
            side = -16
            
            qbert?.texture = SKTexture(imageNamed: "qbert")
            
        }
        
        
        // Check for fall
        
        var fall = false
        
        if qbert_x < 0 || qbert_x > 12 || qbert_y < 0 || qbert_y > 6
        {
            fall = true
        }
        else
        {
            if gamegrid.getTile(X: qbert_x, Y: qbert_y) == 0 {
                fall = true
            }
        }
        
        jumpCounter = 1
        
        let jump1 = SKAction.moveBy(x: side, y: height, duration: 0.2)
        let jump2 = SKAction.resize(toHeight: 72, duration: 0.2)
        let jumpA = SKAction.group([jump1, jump2])
        
        let np = gamegrid.convertToScreenFromGrid(X: qbert_x, Y: qbert_y)
        
        let jump3 = SKAction.move(to: np, duration: 0.2)
        let jump4 = SKAction.resize(toHeight: 58, duration: 0.2)
        let jump5 = SKAction.resize(toHeight: 64, duration: 0.2)
        
        let jumpB = SKAction.group([jump3, jump4])
        
        
        
        if fall
        {
            let jump = SKAction.sequence([jumpA, jumpB])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.qbert?.zPosition = -1
            }
            
            let fall = SKAction.moveTo(y:-700, duration: 0.4)
            qbert?.run(SKAction.sequence([jump, fall]))
            
            
            let event = ["fall": "qbert"]
            let notification = Notification(name: .gameEvent, object: nil, userInfo: event)
            NotificationCenter.default.post(notification)
            
        }
        else
        {
            // Ok!
            // Change tile color a split second later if it hasn't already been changed
            
            let jump = SKAction.sequence([jumpA, jumpB, jump5])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                
                if self.gamegrid.getTile(X: self.qbert_x, Y: self.qbert_y) == 1 {
                    
                    let event = ["Tile": "Left"]
                    let notification = Notification(name: .gameEvent, object: nil, userInfo: event)
                    NotificationCenter.default.post(notification)
                    
                }
                
                if self.gamegrid.getTile(X: self.qbert_x, Y: self.qbert_y) == self.gamegrid.diskLeft {
                    
                    // Flying disk!
                    
                    let event = ["Disk": "left"]
                    let notification = Notification(name: .gameEvent, object: nil, userInfo: event)
                    NotificationCenter.default.post(notification)
                    self.gamegrid.setTile(X: self.qbert_x, Y: self.qbert_y, tile : 0)
                    
                    
                }
                
                if self.gamegrid.getTile(X: self.qbert_x, Y: self.qbert_y) == self.gamegrid.diskRight {
                    
                    // Flying disk!
                    
                    let event = ["Disk": "right"]
                    let notification = Notification(name: .gameEvent, object: nil, userInfo: event)
                    NotificationCenter.default.post(notification)
                    self.gamegrid.setTile(X: self.qbert_x, Y: self.qbert_y, tile : 0)
                    
                }
                
                
                self.jumpCounter = 0
            }
            
            
            qbert?.run(jump)
        }
        
        
        
    }
}




