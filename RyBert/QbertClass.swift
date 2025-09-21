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
    private var rude : SKSpriteNode?
    
    private var qbert_x = 6
    private var qbert_y = 0
    private var gamegrid = GameGrid(withLevel: 1)
    private var myScene : SKScene?
    private var jumpCounter = 0
    
    
    private var soundFall = SKAction.playSoundFileNamed("fall.mp3", waitForCompletion: false)
    private var soundJump = SKAction.playSoundFileNamed("jump-3.mp3", waitForCompletion: false)
    private var soundSwear = SKAction.playSoundFileNamed("swear.mp3", waitForCompletion: false)
    private var soundSwear2 = SKAction.playSoundFileNamed("speech-2.mp3", waitForCompletion: false)
   private var soundFly = SKAction.playSoundFileNamed("lift.mp3", waitForCompletion: false)
   
    
    
    init(withScene theScene: SKScene) {
        
        myScene = theScene
        
        self.qbert = SKSpriteNode(imageNamed: "qbert")
        if let qbert = qbert {
            qbert.size = GameConstants.qbertSize
            qbert.zPosition = GameConstants.qbertZPosition
            qbert.position = gamegrid.convertToScreenFromGrid(X: qbert_x, Y: qbert_y)
            qbert.physicsBody = SKPhysicsBody(circleOfRadius: GameConstants.qbertPhysicsRadius)
            qbert.physicsBody?.collisionBitMask = 0
            qbert.physicsBody?.contactTestBitMask = 0
            qbert.physicsBody?.categoryBitMask = GameConstants.qbertPhysicsCategory
            qbert.physicsBody?.affectedByGravity = false
            qbert.physicsBody?.isDynamic = true
            
            myScene?.addChild(qbert)
        }
        
        self.rude = SKSpriteNode(imageNamed: "rude")
        if let rude = rude {
            rude.size = GameConstants.qbertRudeSize
            rude.zPosition = GameConstants.rudeZPosition
            rude.position = CGPoint(x:32, y:64)
            rude.isHidden = true
            qbert?.addChild(rude)
            
        }
        
       
        
    }
    
    func showRude() {
        rude?.isHidden = false
       
        if (Int.random(in: 0...1) == 0) {
            self.qbert?.run(soundSwear) } else {
                self.qbert?.run(soundSwear2) }
    }
    
    func hideRude() {
        rude?.isHidden = true
    }
    
    func stop() {
       
            qbert!.removeAction(forKey: "jump")
        
    }
    
    func hide()
    {
        qbert?.isHidden = true
    }
    
    func gotoPosition() {
        let p = gamegrid.convertToScreenFromGrid(X: qbert_x, Y: qbert_y)
        let drop = SKAction.move(to: p, duration: 0.1)
        qbert?.run(drop)
    }
    
    func reset()
    {
        qbert_x = 6
        qbert_y = 0
        let p = gamegrid.convertToScreenFromGrid(X: qbert_x, Y: qbert_y)
        qbert?.position = p
        qbert?.texture = SKTexture(imageNamed: "qbert")
        qbert?.zPosition = GameConstants.qbertZPosition
        jumpCounter = 0
        qbert?.isHidden = false
    }
    
    func flyingQbert()
    {
        let np = CGPoint(x: 0, y: GameConstants.flyY)
        let fly = SKAction.move(to: np, duration: GameConstants.flyDuration)
        
        qbert_x = 6
        qbert_y = 0
        let p = gamegrid.convertToScreenFromGrid(X: qbert_x, Y: qbert_y)
        
        let drop = SKAction.move(to: p, duration: GameConstants.jumpDuration)
        
        self.qbert?.run(soundFly)
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
        
        // Calculate Q*bert's current screen position and determine jump direction from tap
        let p = gamegrid.convertToScreenFromGrid(X: qbert_x, Y: qbert_y)
        
        let h = tap.x - p.x
        let v = tap.y - p.y
        
        var height : CGFloat = 0
        var side : CGFloat = 0
        
        if (h > 0 && v > 0)
        {
            
            qbert_x = qbert_x + 1
            qbert_y = qbert_y - 1
            
            height = GameConstants.jumpDownHeight
            side = GameConstants.jumpSideDistance
            
            qbert?.texture = SKTexture(imageNamed: "qbertRU")
            
            
        }
        
        if (h > 0 && v < 0)
        {
            
            qbert_x = qbert_x + 1
            qbert_y = qbert_y + 1
            
            height = GameConstants.jumpUpHeight
            side = GameConstants.jumpSideDistance
            
            qbert?.texture = SKTexture(imageNamed: "qbertR")
            
            
        }
        
        if (h < 0 && v > 0)
        {
            
            qbert_x = qbert_x - 1
            qbert_y = qbert_y - 1
            
            height = GameConstants.jumpDownHeight
            side = -GameConstants.jumpSideDistance
            
            qbert?.texture = SKTexture(imageNamed: "qbertLU")
            
            
        }
        
        if (h < 0 && v < 0)
        {
            
            qbert_x = qbert_x - 1
            qbert_y = qbert_y + 1
            
            height = GameConstants.jumpUpHeight
            side = -GameConstants.jumpSideDistance
            
            qbert?.texture = SKTexture(imageNamed: "qbert")
            
        }
        
        // Check if Q*bert will fall off the pyramid
        
        var fall = false
        
        if qbert_x < 0 || qbert_x > 12 || qbert_y < 0 || qbert_y > 6
        {
            fall = true
        }
        else
        {
            // Check if landing on an empty space
            if gamegrid.getTile(X: qbert_x, Y: qbert_y) == 0 {
                fall = true
            }
        }
        
        jumpCounter = 1
        
        let jump1 = SKAction.moveBy(x: side, y: height, duration: GameConstants.jumpDuration)
        let jump2 = SKAction.resize(toHeight: 72, duration: GameConstants.jumpDuration)
        let jumpA = SKAction.group([jump1, jump2])
        
        let np = gamegrid.convertToScreenFromGrid(X: qbert_x, Y: qbert_y)
        
        let jump3 = SKAction.move(to: np, duration: GameConstants.jumpDuration)
        let jump4 = SKAction.resize(toHeight: 58, duration: GameConstants.jumpDuration)
        let jump5 = SKAction.resize(toHeight: 64, duration: GameConstants.jumpDuration)
        
        let jumpB = SKAction.group([jump3, jump4])
        
        
        
        if fall
        {
            let jump = SKAction.sequence([jumpA, jumpB])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.fallDuration) {
                self.qbert?.zPosition = -1
            }
            
            let fall = SKAction.moveTo(y: GameConstants.fallY, duration: GameConstants.fallDuration)
            qbert?.run(SKAction.sequence([jump, fall]))
            
            
            self.qbert?.run(soundFall)
            
            let event = ["fall": "qbert"]
            let notification = Notification(name: .gameEvent, object: nil, userInfo: event)
            NotificationCenter.default.post(notification)
            
            // Reset Q*bert position to start
            qbert_x = 6
            qbert_y = 0
            
            
            
            
        }
        else
        {
            // Handle successful jump - change tile color and check for disk
            
            let jump = SKAction.sequence([jumpA, jumpB, jump5])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.fallDuration) {
                
                if self.gamegrid.getTile(X: self.qbert_x, Y: self.qbert_y) == 1 {
                    
                    let event = ["Tile": "Left"]
                    let notification = Notification(name: .gameEvent, object: nil, userInfo: event)
                    NotificationCenter.default.post(notification)
                    
                }
                
                if self.gamegrid.getTile(X: self.qbert_x, Y: self.qbert_y) == self.gamegrid.diskLeft {
                    
                    // Flying disk!
                    self.gamegrid.setTile(X: self.qbert_x, Y: self.qbert_y, tile : 0)
                    let event = ["Disk": "left"]
                    let notification = Notification(name: .gameEvent, object: nil, userInfo: event)
                    NotificationCenter.default.post(notification)
                   
                    
                    
                }
                
                if self.gamegrid.getTile(X: self.qbert_x, Y: self.qbert_y) == self.gamegrid.diskRight {
                    
                    // Flying disk!
                    self.gamegrid.setTile(X: self.qbert_x, Y: self.qbert_y, tile : 0)
                    
                    let event = ["Disk": "right"]
                    let notification = Notification(name: .gameEvent, object: nil, userInfo: event)
                    NotificationCenter.default.post(notification)
                    
                    
                }
                
                
                self.jumpCounter = 0
            }
            
            self.qbert?.run(soundJump)
            qbert?.run(jump, withKey: "jump")
        }
        
        
        
    }
}




