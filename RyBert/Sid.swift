//
//  Sid.swift
//  RyBert
//
//  Created by John Kennedy on 10/20/21.
//

import SpriteKit
import GameplayKit

class Sid {
    
    struct sid_type {
        var active : Bool               // present in this game level
        var sprite : SKSpriteNode
        var x : Int                     // game grid position
        var y : Int
        var c : Int                     // Internal counter to control state, delay drawing etc.
        var mode : Bool                 // false - just a blob, true - a snake
    }
    
    private var sid_frames : [SKTexture] = []
    private var sid = sid_type(active: true, sprite: SKSpriteNode(), x: 6,y: 0, c: -5, mode: false)
    private var gamegrid = GameGrid(withLevel: 1)
    private var myScene : SKScene?
    
    private var soundJump = SKAction.playSoundFileNamed("jump-4.mp3", waitForCompletion: false)
    private var soundDrop = SKAction.playSoundFileNamed("jump-2.mp3", waitForCompletion: false)
    private var soundFall = SKAction.playSoundFileNamed("fall.mp3", waitForCompletion: false)
    
    
    init(withScene theScene: SKScene) {
        
        // Create Sid
        buildSid()
        myScene = theScene
        sid.sprite =  SKSpriteNode(texture: sid_frames[0])
        sid.sprite.size = CGSize(width: 48, height: 48)
        sid.sprite.zPosition = 6
        sid.sprite.isHidden = true
        sid.sprite.physicsBody = SKPhysicsBody(texture: sid.sprite.texture!, size: CGSize(width: 16, height: 8))
        sid.sprite.physicsBody?.collisionBitMask = 0
        sid.sprite.physicsBody?.contactTestBitMask = 1     // test for contact with Qbert code
        sid.sprite.physicsBody?.categoryBitMask = 2 // Code for blob
        sid.sprite.physicsBody?.affectedByGravity = false
        sid.sprite.physicsBody?.isDynamic = true
       
        myScene?.addChild(sid.sprite)
    }
    
    
    func buildSid() {
        let sidAtlas = SKTextureAtlas(named: "sid")
        var spinFrames: [SKTexture] = []
        
        let numImages = sidAtlas.textureNames.count
        for i in 1...numImages {
            let diskTextureName = "sid\(i)"
            spinFrames.append(sidAtlas.textureNamed(diskTextureName))
        }
        sid_frames = spinFrames
    }
    
    func stop() {
       
        sid.sprite.removeAllActions()
        
    }
    
    func hide()
    {
        sid.sprite.isHidden = true
        sid.sprite.position = CGPoint(x: -400, y: -400)
    }
    
     func sidJump(_ dx: Int) {
        // Animate the move
        
        //1. Enlongate and jump up a little, and to the side
        
        let jump1 = SKAction.moveBy(x: CGFloat(dx*16), y: 32.0, duration: 0.2)
        let jump2 = SKAction.resize(toHeight: 86, duration: 0.2)
        let jump = SKAction.group([jump1, jump2])
        
        //2. Shrink to normal at new location
        
        let drop1 = SKAction.move(to: gamegrid.convertToScreenFromGrid(X: sid.x, Y: sid.y), duration: 0.2)
        let drop2 = SKAction.resize(toHeight: 48, duration: 0.2)
        let drop = SKAction.group([drop1, drop2])
        
        
        //3. Compress a little and then return to normal
        
        sid.sprite.run(soundJump)
        let rebound = SKAction.resize(toHeight: 64, duration: 0.2)
        sid.sprite.run(SKAction.sequence([jump, drop, rebound]))
    }
    
    func sidStep(QX: Int, QY: Int, QDisk : Bool)
    {
        // Step a blob down a step
        
        sid.sprite.isHidden = false
        
        if sid.mode == false { // Still a ball
            
            sid.y = sid.y + 1
            let direction = Int.random(in: 0...1) // 0 or 1
            var dx = -1
            if direction == 1 { dx = 1}
            sid.x  =  sid.x  + dx
            
            //1. Enlongate and jump up a little, and to the side
            
            let jump1 = SKAction.moveBy(x: CGFloat(dx*16), y: 32.0, duration: 0.2)
            let jump2 = SKAction.resize(toHeight: 56, duration: 0.2)
            let jump = SKAction.group([jump1, jump2])
            
            //2. Shrink to normal at new location
            
            let drop1 = SKAction.move(to: gamegrid.convertToScreenFromGrid(X: sid.x, Y: sid.y), duration: 0.2)
            let drop2 = SKAction.resize(toHeight: 34, duration: 0.2)
            let drop = SKAction.group([drop1, drop2])
            
            
            //3. Compress a little and then return to normal
            
            sid.sprite.run(soundDrop)
            
            let rebound = SKAction.resize(toHeight: 40, duration: 0.2)
            sid.sprite.run(SKAction.sequence([jump, drop, rebound]))
            
            // 4. If Sid is at bottom row, he changes to a snake
            
            if sid.y == 6 {
                sid.mode = true
                sid.c = 1
                
            }
            
        }
        else
        {
            
            
            // Snake movement
            
            sid.c = sid.c + 1
            
            if sid.c == 9 {
                sid.sprite.texture =  sid_frames[1]
                sid.sprite.size = CGSize(width: 48, height: 72)
            }
            
            if (sid.c > 10)  {
                
                sid.c = 7
                
                // Check in case Sid can jump off and fall
                // If Sid is on a specific square, and Qbert
                // is on a disk, then jump off the edge.
                // How can I find out if qbert is on a disk?
                // QDisk is true if Bert is on a disk
                                
                if QDisk && ((sid.x == 2 && sid.y == 4) || (sid.x == 10 && sid.y == 4)) {
                    
                    // SID FALL
                    var dxs = -48
                    if sid.x == 10 { dxs = -dxs }
                    
                    sid.sprite.run(soundFall)
                    
                    // Set target to 2,4 and jump
                    
                    let jump1 = SKAction.moveBy(x: CGFloat(dxs), y: 32.0, duration: 0.2)
                    let jump2 = SKAction.resize(toHeight: 86, duration: 0.2)
                    let jump = SKAction.group([jump1, jump2])
                    
                    //2. Shrink to normal at new location
                    
                    let drop1 = SKAction.moveBy(x: CGFloat(dxs), y: -700, duration: 0.5)
                    let drop2 = SKAction.resize(toHeight: 48, duration: 0.2)
                    let drop = SKAction.group([drop1, drop2])
                    
                    sid.sprite.run(SKAction.sequence([jump, drop]))
                    
                    // set Sid to not be alive
                    
                    sid.active = false
                    
                    // Notification to add lots of points to score
                    
                    let event = ["score": "sidfall"]
                    let notification = Notification(name: .gameEvent, object: nil, userInfo: event)
                    NotificationCenter.default.post(notification)
                    
                    return
                    
                    
                }
                
                var dx = -1
                var dy = -1
                
                if sid.x == QX {
                    let direction = Int.random(in: 0...1)
                    if direction == 1 { dx = 1}
                }
                else
                {
                    if sid.x < QX { dx = 1}
                }
                
                if sid.y == QY {
                    let direction = Int.random(in: 0...1)
                    if direction == 1 && sid.y<7 { dy = 1; }
                    
                }
                else
                {  if sid.y < QY { dy = 1} }
                
                sid.x = sid.x + dx
                sid.y = sid.y + dy
                
                if gamegrid.getTile(X:  sid.x, Y:  sid.y) == 0
                {
                    sid.x = sid.x - dx
                    sid.y = sid.y - dy
                }
                
                sidJump(dx)
                
            }
            
            
        }
        
        
        
    }
    
    
   
    func sidAppear()
    {
        // Drop a blob onto the top of the game grid
        
        sid.active = true
        sid.x = (Int.random(in: 0...1) == 0) ? 5 : 7
        sid.sprite.position = gamegrid.convertToScreenFromGrid(X: sid.x, Y: -5)
        
        //sid.sprite.position = CGPoint(x: 0, y: 500)
        sid.sprite.isHidden = false
        sid.y = 1
        let moveAction = SKAction.move(to: gamegrid.convertToScreenFromGrid(X: sid.x, Y: sid.y), duration: 0.2)
        sid.sprite.run(moveAction)
    }
    
    func sidDisappear()
    {
        // Fall the blob off the game grid
        
        let direction = Int.random(in: 0...1) // 0 or 1
        var dx = -1
        if direction == 1 { dx = 1}
        
        let jump1 = SKAction.moveBy(x: CGFloat(dx*16), y: 32.0, duration: 0.2)
        let jump2 = SKAction.resize(toHeight: 56, duration: 0.2)
        let jump = SKAction.group([jump1, jump2])
        
        //2. Shrink to normal at new location
        let drop1 = SKAction.moveBy(x: CGFloat(dx*16), y: -400.0, duration: 0.2)
        let drop2 = SKAction.resize(toHeight: 48, duration: 0.2)
        let drop = SKAction.group([drop1, drop2])
        
        sid.sprite.run(SKAction.sequence([jump, drop]))
        
        sid.x = 6
        sid.y = 0
        sid.c = -5
    }
    
    func resetPosition()
    {
        sid.y = 1
        sid.x = (Int.random(in: 0...1) == 0) ? 5 : 7
    }
    
    func reset()
    {
        sid.active = true
        sid.mode = false
        sid.sprite.texture = sid_frames[0]
        sid.sprite.isHidden = true
        sid.c = -4
       resetPosition()
    }
    
   
    
    func controlSid(qbert_position : (Int, Int), onDisk: Bool)
    {
        if sid.active == false {
            sid.sprite.isHidden = true
        }
        else {
            
            sid.c = sid.c + 1
            
            if  sid.c < 0
            {
                sid.sprite.isHidden = true
            }
            else
                if  sid.c == 0
            {
                    sidAppear()
                }
            else
                if sid.c > 0
            {
                    sidStep(QX: qbert_position.0, QY: qbert_position.1, QDisk: onDisk)
                }
            
        }
    }
}

