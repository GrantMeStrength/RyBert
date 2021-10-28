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
    }
    
    private var master_blob : SKSpriteNode?
   

    
    private var blobs : [blob_type] = [
        blob_type(active: true, sprite: SKSpriteNode(), x: 1,y: 0, c: -5, speed: 1),
        blob_type(active: true, sprite: SKSpriteNode(), x: 1,y: 0, c : -6, speed: 1),
        blob_type(active: true, sprite: SKSpriteNode(), x: 1,y: 0, c : -7, speed: 1)
    ]
   
    private var gamegrid = GameGrid()
    
    
    
    
    // Create blob
    
    init(withScene theScene: SKScene) {
    
    self.master_blob = SKSpriteNode(imageNamed: "blob")
    if let master_blob = master_blob {
        master_blob.size = CGSize(width: 48, height: 48)
        master_blob.zPosition = 5
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
                blobs[b].c = -4 + b*2
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
        // Step a blob down a step
        
        if blobs[b].y == 6 { // at bottom
            blobDisappear(b: b)
            return
        }
        
        blobs[b].y = blobs[b].y + 1
       
        
        let dx = (Int.random(in: 0...1) == 0) ? -1 : 1
        blobs[b].x  =  blobs[b].x  + dx
        
        //1. Enlongate and jump up a little, and to the side
        
        let jump1 = SKAction.moveBy(x: CGFloat(dx*16), y: 32.0, duration: 0.2)
        let jump2 = SKAction.resize(toHeight: 56, duration: 0.2)
        let jump = SKAction.group([jump1, jump2])
        
        
        //2. Shrink to normal at new location
        let drop1 = SKAction.move(to: gamegrid.convertToScreenFromGrid(X: blobs[b].x, Y: blobs[b].y), duration: 0.2)
        let drop2 = SKAction.resize(toHeight: 34, duration: 0.2)
        
        let drop = SKAction.group([drop1, drop2])
        
        
        //3. Compress a little and then return to normal
        
        let rebound = SKAction.resize(toHeight: 40, duration: 0.2)
       
       
        blobs[b].sprite.run(SKAction.sequence([jump, drop, rebound]))
       
    }
    
    func blobAppear(b : Int)
    {
        // Drop a blob onto the top of the game grid
        blobs[b].sprite.isHidden = false
        blobs[b].active = true
        blobs[b].x = (Int.random(in: 0...1) == 0) ? 5 : 7
        blobs[b].sprite.position = gamegrid.convertToScreenFromGrid(X: blobs[b].x, Y: -5)
        blobs[b].y = 1
        let moveAction = SKAction.move(to: gamegrid.convertToScreenFromGrid(X: blobs[b].x, Y: blobs[b].y), duration: 0.2)
        blobs[b].sprite.run(moveAction)
    }
    
    func blobDisappear(b : Int)
    {
        // Fall the blob off the game grid..
        
       // blobs[b].active = false
        
        let dx = (Int.random(in: 0...1) == 0) ? -1 : 1
        
        let jump1 = SKAction.moveBy(x: CGFloat(dx*16), y: 32.0, duration: 0.2)
        let jump2 = SKAction.resize(toHeight: 56, duration: 0.2)
        let jump = SKAction.group([jump1, jump2])
        
        //2. Shrink to normal at new location
        let drop1 = SKAction.moveBy(x: CGFloat(dx*16), y: -400.0, duration: 0.2)
        let drop2 = SKAction.resize(toHeight: 48, duration: 0.2)
        let drop = SKAction.group([drop1, drop2])
        
        blobs[b].sprite.run(SKAction.sequence([jump, drop]))
        
        blobs[b].y = 1
        blobs[b].c = -5
    }
    
    func controlBlobs(qbert_position : (Int, Int))
    {
        for b in 0...2 {
            
            if blobs[b].active == false {
                blobs[b].sprite.isHidden = true
                
            }
            else {
                
                if (qbert_position.0 == blobs[b].x && qbert_position.1 == blobs[b].y)
                {
                    let event = ["collision": "blob"]
                    let notification = Notification(name: .gameEvent, object: nil, userInfo: event)
                    NotificationCenter.default.post(notification)
                    return // no need to animate - blob has done its worst
                }
            
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
