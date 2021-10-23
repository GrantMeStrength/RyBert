//
//  GameScene.swift
//  RyBert
//
//  Created by John Kennedy on 10/15/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    
  
    private var ticks = 0
    
    private var jumpCounter = 0
    
    private var qbert : SKSpriteNode?
    private var qbert_x = 6
    private var qbert_y = 0
    
    private let level = 1
    private var lives = 3
    private var score = 0
    private var level_count = 0
    
    private var Blobs : Blob?
    private var Tiles : Tile?
    private var Grid : GameGrid?
    private var TheSid : Sid?
    
    
    enum gameState {
        
        case attract
        case gamestart
        case levelstart
        case getready
        case action
        case died
        case levelcomplete
    }

    
    private var GameState : gameState = .attract
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
            label.text = "Score: " + String(score)
        }
        
        Blobs = Blob(withScene: self)
        Tiles = Tile(withScene: self)
        Tiles?.drawTiles()
        Grid = GameGrid()
        TheSid = Sid(withScene: self)
        
        // Create qbert
        
        self.qbert = SKSpriteNode(imageNamed: "qbert")
        if let qbert = qbert {
            qbert.size = CGSize(width: 64, height: 64)
            qbert.zPosition = 3
            qbert.position = Grid!.convertToScreenFromGrid(X: qbert_x, Y: qbert_y)
            self.addChild(qbert)
        }
        

        // Add notification system
               
        NotificationCenter.default.addObserver(forName: .gameEvent, object: nil, queue: nil) {(notification) in
                   
                 
            if let data = notification.userInfo as? [String: String] {
            
                   for (name, score) in data {
                       print("\(name) went and \(score) !")
                   }
               }
                  
               }
              


       
       
        
        let _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [self] timer in
            
            ticks = ticks + 1
            
            if ticks == 4 { ticks = 0}
            
            TheSid!.controlSid(QX : qbert_x, QY: qbert_y)
            Blobs!.controlBlobs(QX : qbert_x, QY: qbert_y)
        }
        
    }
 
    func drawAlternateTile(X : Int, Y: Int)
    {
        if Grid?.getTile(X: X, Y: Y) == 1 {
            Grid?.setTile(X: X, Y: Y, tile: 2)
            let p = Grid!.convertToScreenFromGrid(X: X, Y: Y)
            Tiles!.generateAlternateTile(atPoint: CGPoint(x: p.x, y: p.y - 40))
        }
    }
    


    
    func touchDown(atPoint pos : CGPoint) {
       
    
        if jumpCounter != 0  { return }
        
        // Map current player position to screen
        
      //  let p = convertToScreenFromGrid(X: qbert_x, Y: qbert_y)
        
        let p = CGPoint(x: 0, y: 0 )
        
        // Use tap co-ords to see which direction the player wants to jump
        
      
     
        let h = pos.x - p.x
        let v = pos.y - p.y
        
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
            if Grid!.getTile(X: qbert_x, Y: qbert_y) == 0 {
                fall = true
            }
        }
        
        jumpCounter = 1
        
        let jump1 = SKAction.moveBy(x: side, y: height, duration: 0.2)
        let jump2 = SKAction.resize(toHeight: 72, duration: 0.2)
        let jumpA = SKAction.group([jump1, jump2])
        
        let np = Grid!.convertToScreenFromGrid(X: qbert_x, Y: qbert_y)
        
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
            
            
            let event = ["Qbery": "Fall"]
            let notification = Notification(name: .gameEvent, object: nil, userInfo: event)
            NotificationCenter.default.post(notification)
            
        }
        else
        {
            // Ok!
            // Change tile color a split second later if it hasn't already been changed
            
            let jump = SKAction.sequence([jumpA, jumpB, jump5])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                
                if self.Grid?.getTile(X: self.qbert_x, Y: self.qbert_y) == 1 {
                    
                   
                    self.drawAlternateTile(X: self.qbert_x, Y: self.qbert_y)
                    self.level_count = self.level_count + 1
                    self.score = self.score + 25
                    self.label?.text = "Score: " + String(self.score)
                }
                
                if self.Grid?.getTile(X: self.qbert_x, Y: self.qbert_y) == self.Grid?.diskLeft {
               
                    // Flying disk!
                   
                        let event = ["Disk": "Left"]
                        let notification = Notification(name: .gameEvent, object: nil, userInfo: event)
                        NotificationCenter.default.post(notification)
                    
                    
                }
                
                if self.Grid?.getTile(X: self.qbert_x, Y: self.qbert_y) == self.Grid?.diskRight {
               
                    // Flying disk!
                   
                        let event = ["Disk": "Right"]
                        let notification = Notification(name: .gameEvent, object: nil, userInfo: event)
                        NotificationCenter.default.post(notification)
                
                }
                
               
                self.jumpCounter = 0
            }
            

            qbert?.run(jump)
        }
        
            
    
    }
    
    func touchMoved(toPoint pos : CGPoint) {
      
    }
    
    func touchUp(atPoint pos : CGPoint) {
      
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            //label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
            //label.text = "Score: " + String(score)
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
