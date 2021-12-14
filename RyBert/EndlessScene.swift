//
//  EndlessScene.swift
//  RyBert
//
//  Created by John Kennedy on 11/27/21.
//

/*

 Make a pool of the sprites we're likely to use
 
 Make an array map or generate programmatically?
 
 The max number is known, so let's go with that.
 
 I see them moving up the screen, and then the back row dropping off as the front row pops up - will look amazing.
 
 Will never careful management of the Z order
 
 Can worry about anything other than completely full rows later.
 
 
 
 */

import SpriteKit
import GameplayKit

class EndlessScene: SKScene {
    
    var grid : [[SKSpriteNode]] = [[]]
    
  
    
    func plop() {
        
   
        
    }
    
    
    
    override func didMove(to view: SKView) {
        
        print("Good morning")
        
        //physicsWorld.contactDelegate = self
        //view.showsPhysics = true <- see outlines, useful for debugging
        
        // Magical scaling code
        scene!.scaleMode = .aspectFit
        scene!.backgroundColor = .black
        
        // Create a 2d array of tile sprites
        
        grid = [
        
            [generateTile(), generateTile(), generateTile(),generateTile(), generateTile(), generateTile(), generateTile()],
            [generateTile(), generateTile(), generateTile(),generateTile(), generateTile(), generateTile(), generateTile()],
            [generateTile(), generateTile(), generateTile(),generateTile(), generateTile(), generateTile(), generateTile()],
            [generateTile(), generateTile(), generateTile(),generateTile(), generateTile(), generateTile(), generateTile()],
            [generateTile(), generateTile(), generateTile(),generateTile(), generateTile(), generateTile(), generateTile()],
            [generateTile(), generateTile(), generateTile(),generateTile(), generateTile(), generateTile(), generateTile()],
            [generateTile(), generateTile(), generateTile(),generateTile(), generateTile(), generateTile(), generateTile()],
            [generateTile(), generateTile(), generateTile(),generateTile(), generateTile(), generateTile(), generateTile()],
         //   [generateTile(), generateTile(), generateTile(),generateTile(), generateTile(), generateTile(), generateTile()],
          //  [generateTile(), generateTile(), generateTile(),generateTile(), generateTile(), generateTile(), generateTile()]
            
        ]
        
        initGrid()
    
        let _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] timer in
            
            
            updateGrid()
            
            
        }
         
    }
    
    var tileX = -320
    var tileY = -300
    
    let xSpace = (288/3)/2
    let ySpace =  288/3
    
    let fallBorder = 432.0 // 360?
    
    func updateGrid() {
        
        
        
        for y in 0...7 {
            
            if grid[y][0].position.y >= fallBorder {
                
                
                for x in 0...6 {
                    
                    let p =  grid[y][x].position
                 
                        self.grid[y][x].zPosition = -10
                  
                    
                    // Bring it back in 1 second
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4)
                    {
                        self.grid[y][x].zPosition = 10
                        if (Int.random(in: 0...4) == 0) {
                            
                            self.grid[y][x].isHidden = true
                        }
                        else
                        {
                            self.grid[y][x].isHidden = false
                        }
               
                    }
                   
                    let fall = SKAction.group([SKAction.moveBy(x: 0, y: -200, duration: 0.4), SKAction.fadeOut(withDuration: 0.4), SKAction.scale(by: 0.5, duration: 0.2)])
                    
                    
                    let wait = SKAction.wait(forDuration: 0.2)
                    
                    let repos = SKAction.move(to: CGPoint(x: CGFloat(p.x), y: CGFloat(-800)), duration: 0.01)
                    
                    
                    let rise = SKAction.group([SKAction.move(to: CGPoint(x: CGFloat(p.x), y: CGFloat( -(ySpace*6) + (ySpace*3))), duration: 0.4), SKAction.fadeIn(withDuration: 0.4), SKAction.scale(by: 2.0, duration: 0.2)])
                    
                   
                    let drop = SKAction.sequence([fall, wait, repos, wait, rise])
                    
                    
                    grid[y][x].run(drop)
                    
                    
                   // grid[y][x].position = CGPoint(x: CGFloat(p.x), y: CGFloat( -(ySpace*7) + (ySpace*3)))
                    
                }
            }
            else
            {
               // for x in 0...6 {
               //     grid[y][x].zPosition = 1
               // }
            }
            
            for x in 0...6 {
                
                var p =  grid[y][x].position
                
                p.y = p.y + 4
                
                grid[y][x].position = CGPoint(x: CGFloat(p.x), y: CGFloat( p.y))
               
            }
            

        }
    }
    
    func initGrid()
    {
        
        for y in 0...7 {
            
            for x in 0...6 {
                
                if y % 2 == 0 {
                    
                    grid[y][x].position = CGPoint(x: tileX + x * 2 * xSpace, y: tileY + y * ySpace)
                }
                else {
                    
                    grid[y][x].position = CGPoint(x: tileX + xSpace +  x * 2 * xSpace, y: tileY + y * ySpace)
                    
                }
                
                
                
            }
        }
        
        
    }
    
    
    func generateTile() -> SKSpriteNode
    {
       
        let tile_yellow = SKSpriteNode(imageNamed: "square_yellow")
            tile_yellow.size = CGSize(width: 288/3, height: 320/2.5)
            tile_yellow.zPosition = 10
           
            tile_yellow.name = "Yellow"
        self.addChild(tile_yellow)
        return tile_yellow
    }
}
