//
//  Tiles.swift
//  RyBert
//
//  Created by John Kennedy on 10/18/21.
//

import SpriteKit
import GameplayKit

class Tile {
    
    
    private var gamegrid = GameGrid()
    private var tile_blue : SKSpriteNode?
    private var tile_yellow : SKSpriteNode?
    private var tile_red : SKSpriteNode?
   
    private var myScene : SKScene?
    
    private var disk_left : SKSpriteNode?
    private var disk_right : SKSpriteNode?
    private var disk_frames : [SKTexture] = []
   
    
    
    init (withScene theScene: SKScene)
    {
        
        myScene = theScene
        
        
        buildDisk()
        
        // Create tile node for drawing the game grid
        
        self.tile_yellow = SKSpriteNode(imageNamed: "square_yellow")
        if let tile_yellow = tile_yellow {
            tile_yellow.size = CGSize(width: 288/3, height: 320/2.5)
            tile_yellow.zPosition = 1
        }
        
        
        // Create alternate tile node for drawing the game grid
        
        self.tile_blue = SKSpriteNode(imageNamed: "square_blue")
        if let tile_blue = tile_blue {
            tile_blue.size = CGSize(width: 288/3, height: 320/2.5)
            tile_blue.zPosition = 2
        }
        
        self.tile_red = SKSpriteNode(imageNamed: "square_red")
        if let tile_red = tile_red {
            tile_red.size = CGSize(width: 288/3, height: 320/2.5)
            tile_red.zPosition = 3
        }
        
        // Spinny disks
        
        self.disk_left = SKSpriteNode(texture: disk_frames[0])
        if let disk_left = disk_left {
            disk_left.size = CGSize(width: 291/4, height: 115/3)
            disk_left.zPosition = 2
            myScene!.addChild(disk_left)
        }
        
        
        self.disk_right = SKSpriteNode(texture: disk_frames[0])
        if let disk_right = disk_right {
            disk_right.size = CGSize(width: 291/4, height: 115/3)
            disk_right.zPosition = 2
            myScene!.addChild(disk_right)
        }
        
        disk_left!.run(SKAction.repeatForever(
            SKAction.animate(with: disk_frames,
                             timePerFrame: 0.25,
                             resize: false,
                             restore: true)),
            withKey:"spin_left")
        
        disk_right!.run(SKAction.repeatForever(
            SKAction.animate(with: disk_frames,
                             timePerFrame: 0.25,
                             resize: false,
                             restore: true)),
            withKey:"spin_right")
        
    }
    
    
    func buildDisk() {
      let diskAtlas = SKTextureAtlas(named: "disk")
      var spinFrames: [SKTexture] = []

      let numImages = diskAtlas.textureNames.count
      for i in 1...numImages {
        let diskTextureName = "disk\(i)"
        spinFrames.append(diskAtlas.textureNamed(diskTextureName))
      }
      disk_frames = spinFrames
    }

    
    
    
    func generateTile(atPoint pos: CGPoint) {
        if let n = self.tile_yellow?.copy() as! SKSpriteNode? {
            n.position = pos
            myScene!.addChild(n)
        }
    }
    
    func generateAlternateTile(atPoint pos: CGPoint) {
        if let n = self.tile_blue?.copy() as! SKSpriteNode? {
            n.position = pos
            myScene!.addChild(n)
        }
    }
    
    func drawTiles()
    {
          
        for y in 0...6 {
            for x in 0...12 {
                
                if gamegrid.getTile(X: x, Y: y) == gamegrid.yellow {
                    let p = gamegrid.convertToScreenFromGrid(X: x, Y: y)
                    generateTile(atPoint: CGPoint(x: p.x, y: p.y - 40))
                }
                
                if gamegrid.getTile(X: x, Y: y) == gamegrid.diskLeft { // a disk
                    let p = gamegrid.convertToScreenFromGrid(X: x, Y: y)
                    disk_left!.position = CGPoint(x: p.x, y: p.y - 24)
                    
                }
                
                if gamegrid.getTile(X: x, Y: y) == gamegrid.diskRight { // Right disk
                    let p = gamegrid.convertToScreenFromGrid(X: x, Y: y)
                    disk_right!.position = CGPoint(x: p.x, y: p.y - 24)

                }
                
            }
        }
    }
    
}
