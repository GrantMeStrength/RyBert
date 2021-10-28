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
    
    private var root : SKSpriteNode?
   
   
    private var myScene : SKScene?
    
    private var disk_left : SKSpriteNode?
    private var disk_right : SKSpriteNode?
    private var disk_frames : [SKTexture] = []
   
    
    
    init (withScene theScene: SKScene)
    {
        
        myScene = theScene
        
        root = SKSpriteNode()
        myScene?.addChild(root!)
        
        buildDisk()
        
        // Create tile node for drawing the game grid
        
        self.tile_yellow = SKSpriteNode(imageNamed: "square_grey_light")
        if let tile_yellow = tile_yellow {
            tile_yellow.size = CGSize(width: 288/3, height: 320/2.5)
            tile_yellow.zPosition = 1
        }
        
        
        // Create alternate tile node for drawing the game grid
        
        self.tile_blue = SKSpriteNode(imageNamed: "square_grey_blue")
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
            disk_left.zPosition = 3
            myScene!.addChild(disk_left)
        }
        
        
        self.disk_right = SKSpriteNode(texture: disk_frames[0])
        if let disk_right = disk_right {
            disk_right.size = CGSize(width: 291/4, height: 115/3)
            disk_right.zPosition = 3
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
    
    func removeTiles()
    {
        // Delete all existing tiles (except the disks, they're still attached to myscene
        // and don't need re-created.
        
        root!.removeAllActions()
    }
    
    
    func flashTiles()
    {
        let rotate1 = SKAction.rotate(byAngle: 45, duration: 0.1)
        let rotate2 = SKAction.rotate(toAngle: 0, duration: 0.1)
        let color1 = SKAction.colorize(with: UIColor(red: 1.0, green: 0.1, blue: 0.1, alpha: 1.0), colorBlendFactor: 1, duration: 0.2)
        let color2 = SKAction.colorize(with: UIColor(red: 0.1, green: 1.0, blue: 0.1, alpha: 1.0), colorBlendFactor: 1, duration: 0.2)
        let color3 = SKAction.colorize(with: UIColor(red: 0.1, green: 0.1, blue: 1.0, alpha: 1.0), colorBlendFactor: 1, duration: 0.2)
        let color0 = SKAction.colorize(with: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), colorBlendFactor: 1, duration: 0.2)
       
        let s1 = SKAction.group([color1, rotate1])
        let s2 = SKAction.group([color2, rotate1])
        let s3 = SKAction.group([color3, rotate1])
                                                        
            
        for tile in root!.children {
            
            tile.run(SKAction.sequence([s1, s2, s3]))
        
            
        }
        
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            for tile in self.root!.children {
               
                 tile.run(rotate2)
                tile.run(color0)
                
            
        
            }
        }
        
        
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

    
    func flyingDisk( left_side : Bool, qbertpos : (Int, Int))
    {
        let np = CGPoint(x: 0, y: 500-24)
        let fly = SKAction.move(to: np, duration: 1.5)
        
        let vanish = SKAction.fadeAlpha(by: -1.0, duration: 0.1)
        
        gamegrid.setTile(X: qbertpos.0, Y: qbertpos.1, tile: gamegrid.empty)
        
        if left_side {
            disk_left?.run(SKAction.sequence([fly, vanish]))
        }
        else
        {
            disk_right?.run(SKAction.sequence([fly, vanish]))
        }
     
    }
    
    
    func generateTile(atPoint pos: CGPoint) {
        if let n = self.tile_yellow?.copy() as! SKSpriteNode? {
            n.position = pos
            root!.addChild(n)
        }
    }
    
    func generateAlternateTile(atPoint pos: CGPoint, tile : Int) {
        
        if (tile == 2) {
        if let n = self.tile_blue?.copy() as! SKSpriteNode? {
            n.position = pos
            root!.addChild(n)
        }
        }
        else
        {
            if let n = self.tile_red?.copy() as! SKSpriteNode? {
                n.position = pos
                root!.addChild(n)
        }
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
