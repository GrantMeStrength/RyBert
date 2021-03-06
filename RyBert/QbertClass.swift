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
            qbert.size = CGSize(width: 64, height: 64)
            qbert.zPosition = 4
            qbert.position = gamegrid.convertToScreenFromGrid(X: qbert_x, Y: qbert_y)
            //qbert.physicsBody = SKPhysicsBody(texture: qbert.texture!, size: qbert.frame.size)
            qbert.physicsBody = SKPhysicsBody(circleOfRadius: 20)
            qbert.physicsBody?.collisionBitMask = 0
            qbert.physicsBody?.contactTestBitMask = 0
            qbert.physicsBody?.categoryBitMask = 1          // the code for Qbert
            qbert.physicsBody?.affectedByGravity = false
            qbert.physicsBody?.isDynamic = true
            
            myScene?.addChild(qbert)
        }
        
        self.rude = SKSpriteNode(imageNamed: "rude")
        if let rude = rude {
            rude.size = CGSize(width: 348/2, height: 172/2)
            rude.zPosition = 7
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
       // stop()
        let p = gamegrid.convertToScreenFromGrid(X: qbert_x, Y: qbert_y)
       // qbert?.position = p
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
        qbert?.zPosition = 4
        jumpCounter = 0
        qbert?.isHidden = false
    }
    
    func flyingQbert()
    {
        let np = CGPoint(x: 0, y: 500)
        let fly = SKAction.move(to: np, duration: 1.5)
        
        qbert_x = 6
        qbert_y = 0
        let p = gamegrid.convertToScreenFromGrid(X: qbert_x, Y: qbert_y)
        
        let drop = SKAction.move(to: p, duration: 0.2)
        
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
            // Ok to use grid to check for lack of a tile.
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
            
            
            self.qbert?.run(soundFall)
            
            let event = ["fall": "qbert"]
            let notification = Notification(name: .gameEvent, object: nil, userInfo: event)
            NotificationCenter.default.post(notification)
            
            // Reset to top
            qbert_x = 6
            qbert_y = 0
            
            
            
            
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
                    self.gamegrid.setTile(X: self.qbert_x, Y: self.qbert_y, tile : 0)
                    let event = ["Disk": "left"]
                    let notification = Notification(name: .gameEvent, object: nil, userInfo: event)
                    NotificationCenter.default.post(notification)
                   
                    
                    
                }
                
                if self.gamegrid.getTile(X: self.qbert_x, Y: self.qbert_y) == self.gamegrid.diskRight {
                    
                    // Flying disk!
                    self.gamegrid.setTile(X: self.qbert_x, Y: self.qbert_y, tile : 0)
                    
                    print("Right desk, setting to empty")
                    print(self.gamegrid.getTile(X: self.qbert_x, Y: self.qbert_y))
                    
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




