//
//  Blob.swift
//  RyBert
//
//  Created by John Kennedy on 10/18/21.
//

import Foundation
import SpriteKit
import GameplayKit

class Blob {
    
    struct blob_type {
        var active : Bool               // present in this game level
        var sprite : SKSpriteNode
        var x : Int                     // game grid position
        var y : Int
        var c : Int                     // Internal counter to control state, delay drawing etc.
        var speed : Int
        var previousDx : Int
    }
    
    private var master_blob : SKSpriteNode?
    
  
    private var soundFall = SKAction.playSoundFileNamed("jump-2.mp3", waitForCompletion: false)
    
    
    private var blobs : [blob_type] = [
        blob_type(active: true, sprite: SKSpriteNode(), x: 1,y: 0, c: -5, speed: 1, previousDx : 0),
        blob_type(active: true, sprite: SKSpriteNode(), x: 1,y: 0, c : -10, speed: 1, previousDx : 0),
        blob_type(active: true, sprite: SKSpriteNode(), x: 1,y: 0, c : -7, speed: 1, previousDx : 0)
    ]
   
    private var gamegrid = GameGrid(withLevel: 1)
    
    
    // Initialize blob sprites and physics
    
    init(withScene theScene: SKScene) {
    
    self.master_blob = SKSpriteNode(imageNamed: "blob")
    if let master_blob = master_blob {
        master_blob.size = GameConstants.blobSize
        master_blob.zPosition = GameConstants.blobZPosition
        master_blob.physicsBody = SKPhysicsBody(texture: master_blob.texture!, size: GameConstants.blobPhysicsSize)
        master_blob.physicsBody?.collisionBitMask = 0
        master_blob.physicsBody?.contactTestBitMask = GameConstants.qbertPhysicsCategory
        master_blob.physicsBody?.categoryBitMask = GameConstants.blobPhysicsCategory
        master_blob.physicsBody?.affectedByGravity = false
        master_blob.physicsBody?.isDynamic = true
       
    }
    
    blobs[0].sprite = (self.master_blob?.copy() as! SKSpriteNode?)!
    blobs[1].sprite = (self.master_blob?.copy() as! SKSpriteNode?)!
    blobs[2].sprite = (self.master_blob?.copy() as! SKSpriteNode?)!
    
        blobs[0].sprite.isHidden = true
        blobs[1].sprite.isHidden = true
        blobs[2].sprite.isHidden = true

    theScene.addChild(blobs[0].sprite)
    theScene.addChild(blobs[1].sprite)
    theScene.addChild(blobs[2].sprite)
        
    }
    
    
    
    
    func reset(level : Int){
        
        for b in 0...2 {
                blobs[b].sprite.isHidden = true
                blobs[b].active = false
                blobs[b].c = GameConstants.blobInitialDelay[b]
            }
        
        
        switch level {
            
        case 1: blobs[0].active =  true; blobs[1].active =  true; blobs[0].speed = 1; blobs[1].speed = 1;
        case 2: blobs[0].active =  true; blobs[1].active =  true; blobs[0].speed = 1; blobs[1].speed = 1;
        case 3: blobs[0].active =  true; blobs[1].active =  true; blobs[2].active =  true; blobs[0].speed = 1; blobs[1].speed = 1; blobs[2].speed = 1;
        default: blobs[0].active =  true; blobs[1].active =  true; blobs[2].active =  true; blobs[0].speed = 1; blobs[1].speed = 1; blobs[2].speed = 2;
            
            
        }
        
      
    }
    
    func blobStep(b : Int)
    {
        // Move blob down one row on the pyramid
        
        if blobs[b].y == 6 { // at bottom
            blobDisappear(b: b)
            return
        }
        
       
        blobs[b].y = blobs[b].y + 1
       
        
        var dx = (Int.random(in: 0...1) == 0) ? -1 : 1
        
        
        // Avoid jumping onto empty spaces
        if gamegrid.getTile(X: blobs[b].x + dx, Y: blobs[b].y) == 0 {
            
            dx = -dx
            
        }
        
        blobs[b].x  =  blobs[b].x  + dx
       
        
        // Store direction for consistent falling animation
        blobs[b].previousDx = dx
       
        
        // Animate blob jump with stretch and movement
        
        let jump1 = SKAction.moveBy(x: CGFloat(dx) * GameConstants.jumpSideDistance, y: GameConstants.jumpUpHeight, duration: GameConstants.jumpDuration)
        let jump2 = SKAction.resize(toHeight: 56, duration: GameConstants.jumpDuration)
        let jump = SKAction.group([jump1, jump2])
        
        // Land at new position
        let drop1 = SKAction.move(to: gamegrid.convertToScreenFromGrid(X: blobs[b].x, Y: blobs[b].y), duration: GameConstants.jumpDuration)
        let drop2 = SKAction.resize(toHeight: 34, duration: GameConstants.jumpDuration)
        
        let drop = SKAction.group([drop1, drop2])
        
        
        // Bounce animation on landing
        
        let rebound = SKAction.resize(toHeight: 40, duration: GameConstants.jumpDuration)
       
        self.blobs[b].sprite.run(soundFall)
        blobs[b].sprite.run(SKAction.sequence([jump, drop, rebound]), withKey: "blump")
       
    }
    
    func blobAppear(b : Int)
    {
        // Spawn blob at top of pyramid
        blobs[b].sprite.isHidden = false
        blobs[b].active = true
        blobs[b].x = (Int.random(in: 0...1) == 0) ? 5 : 7
        blobs[b].sprite.position = gamegrid.convertToScreenFromGrid(X: blobs[b].x, Y: -5)
        blobs[b].y = 1
        blobs[b].sprite.zPosition = GameConstants.blobZPosition
        let moveAction = SKAction.move(to: gamegrid.convertToScreenFromGrid(X: blobs[b].x, Y: blobs[b].y), duration: GameConstants.jumpDuration)
        blobs[b].sprite.run(moveAction)
    }
    
    func blobDisappear(b : Int)
    {
        // Animate blob falling off bottom of pyramid
        
        
        let dx = blobs[b].previousDx
        
        let jump1 = SKAction.moveBy(x: CGFloat(dx) * GameConstants.jumpSideDistance, y: GameConstants.jumpUpHeight, duration: GameConstants.jumpDuration)
        let jump2 = SKAction.resize(toHeight: 56, duration: GameConstants.jumpDuration)
        let jump = SKAction.group([jump1, jump2])
        
        // Fall off screen
        let drop1 = SKAction.moveBy(x: CGFloat(dx) * GameConstants.jumpSideDistance, y: -400.0, duration: GameConstants.jumpDuration)
        let drop2 = SKAction.resize(toHeight: 48, duration: GameConstants.jumpDuration)
        let drop = SKAction.group([drop1, drop2])
        
        blobs[b].sprite.run(SKAction.sequence([jump, drop]))
        
        blobs[b].y = 1
        blobs[b].c = -5
    }
    
    
    func stop() {
        for b in 0...2 {
            blobs[b].sprite.removeAction(forKey: "blump")
        }
    }
    
    
    func hide()
    {
        for b in 0...2 {
            blobs[b].sprite.isHidden = true
            blobs[b].sprite.position = CGPoint(x: -400,y: -400) // out of harm's way for a contact event
         }
    }
    
    func controlBlobs()
    {
        for b in 0...2 {
            
            if blobs[b].active == false {
                blobs[b].sprite.isHidden = true
                
            }
            else {
              
            
            blobs[b].c = blobs[b].c + 1
            
            if  blobs[b].c < 0
            {
                blobs[b].sprite.isHidden = true
            }
            else
            if  blobs[b].c == 0
            {
                
                blobAppear(b: b)
            }
            else
                if blobs[b].c > 0
            {
                    blobStep(b: b)
                    
                }
            
            }
       }
    }
  
   
    
}
