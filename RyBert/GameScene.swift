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
    private var liveslabel : SKLabelNode?
    private var rude : SKSpriteNode?
    
    private var ticks = 0
    
    
    
    private var level = 1
    private var lives = 3
    private var score = 0
    private var level_count = 0
    
    private var Blobs : Blob?
    private var Tiles : Tile?
    private var Grid : GameGrid?
    private var TheSid : Sid?
    private var QBert : QbertClass?
    
    
    
    enum gameState {
        
        case attract
        case gamestart
        case levelstart
        case getready
        case action
        case died
        case levelcomplete
        case flying
        case gameover
    }
    
    
    private var GameState : gameState = .getready
    private var GameStateCounter = 0
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
            label.text = "Score: " + String(score)
        }
        
        self.liveslabel = self.childNode(withName: "//livesLabel") as? SKLabelNode
        if let liveslabel = self.liveslabel {
            liveslabel.alpha = 0.0
            liveslabel.run(SKAction.fadeIn(withDuration: 2.0))
            liveslabel.text = "Lives: " + String(score)
        }
        
        Blobs = Blob(withScene: self)
        Tiles = Tile(withScene: self)
        Tiles?.drawTiles()
        Grid = GameGrid()
        Tiles?.removeTiles()
        TheSid = Sid(withScene: self)
        QBert = QbertClass(withScene: self)
        
        self.rude = SKSpriteNode(imageNamed: "rude")
        if let rude = rude {
            rude.size = CGSize(width: 348/2, height: 172/2)
            rude.zPosition = 3
            rude.isHidden = true
            self.addChild(rude)
            
        }
        
        
        // Add notification system
        
        NotificationCenter.default.addObserver(forName: .gameEvent, object: nil, queue: nil) {(notification) in
            
            
            if let data = notification.userInfo as? [String: String] {
                
                for (name, score) in data {
                    
                    if  name == "fall"
                    {
                        self.GameState = .died
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.QBert!.reset()
                            
                        }
                    }
                    
                    if name == "collision" && self.GameState == .action
                    {
                        let p = self.QBert!.getSpritePosition()
                        self.rude?.position = CGPoint(x: p.x, y: p.y + 64)
                        self.rude?.isHidden = false
                        self.GameState = .died
                        //self.QBert!.setPosition(X: 1, Y: 1)
                    }
                    
                    if name == "Tile" {
                        
                        let p = self.QBert?.getPosition()
                        self.drawAlternateTile(X: p!.0, Y: p!.1)
                        self.level_count = self.level_count + 1
                        self.score = self.score + 25
                        self.label?.text = "Score: " + String(self.score)
                    }
                    
                    if name == "Disk" {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.GameState = .action
                            let event = ["Tile": "fly"]
                            let notification = Notification(name: .gameEvent, object: nil, userInfo: event)
                            NotificationCenter.default.post(notification)
                        }
                        
                        self.GameState = .flying
                        self.QBert?.flyingQbert()
                        if (score == "left") {
                            self.Tiles?.flyingDisk(left_side : true, qbertpos: (self.QBert?.getPosition())!)
                        }
                        else {
                            self.Tiles?.flyingDisk(left_side : false, qbertpos: (self.QBert?.getPosition())!)
                        }
                        
                    }
                    
                    print("\(name) went and \(score) !")
                }
            }
            
        }
        
        
        
        let _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [self] timer in
            
            ticks = ticks + 1
            
            if ticks == 4 { ticks = 0}
            
            switch GameState {
            case .attract:
                print(GameState)
            case .gamestart:
                print(GameState)
                lives = 3
                level = 1
            case .levelstart:
              //  Blobs!.reset(level: level)
                QBert!.reset()
              //  TheSid!.reset()
                liveslabel?.text = "Level start!"
                GameState = .getready
            case .getready:
                if GameStateCounter == 0
                {
                rude?.isHidden = true
                Blobs!.reset(level: level)
                TheSid!.reset()
                liveslabel?.text = "Get Ready"
                }
                GameStateCounter = GameStateCounter + 1
                if GameStateCounter == 4 {
                    GameState = .action
                    GameStateCounter = 0
                }
            case .action:
                liveslabel?.text = "Action"
                TheSid!.controlSid(qbert_position: (QBert?.getPosition())!)
            //    Blobs!.controlBlobs(qbert_position: (QBert?.getPosition())!)
                GameStateCounter = 0
            case .died:
                if GameStateCounter == 0
                {
                print("Died")
                TheSid!.resetPosition()
                lives = lives - 1
                liveslabel?.text = "Lives: " + String(lives)
                }
                GameStateCounter = GameStateCounter + 1
                if GameStateCounter == 4 {
                    
                    if lives == 0 {
                        GameState = .gameover
                    }
                    else
                    {
                        GameState = .getready
                    }
                    GameStateCounter = 0
                }
               
            case .levelcomplete:
                if (GameStateCounter == 0) {
                Tiles?.flashTiles()
                }
                else
                {
                    GameStateCounter = GameStateCounter + 1
                    if GameStateCounter > 5
                    {
                        GameStateCounter = 0
                        GameState = .levelstart
                    }
                }
                
                print(GameState)
            case .flying:
                liveslabel?.text = "Wheeeeee!"
                
            case .gameover:
                liveslabel?.text = "Game Over"
                
            }
            
            
        }
        
    }
    
    
    
    func drawAlternateTile(X : Int, Y: Int)
    {
        
        if Grid?.getTile(X: X, Y: Y) == 1 {
            Grid?.setTile(X: X, Y: Y, tile: 2)
            let p = Grid!.convertToScreenFromGrid(X: X, Y: Y)
            Tiles!.generateAlternateTile(atPoint: CGPoint(x: p.x, y: p.y - 40), tile: 2)
        }
        else
        {
            if level == 3 {
                Grid?.setTile(X: X, Y: Y, tile: 3)
                let p = Grid!.convertToScreenFromGrid(X: X, Y: Y)
                Tiles!.generateAlternateTile(atPoint: CGPoint(x: p.x, y: p.y - 40), tile: 3)
            }
            
        }
    }
    
    
    
    
    func touchDown(atPoint pos : CGPoint) {
        
        // Can only move Qbert 
        if self.GameState == .getready || self.GameState == .action {
            QBert?.moveQbert(tap: pos)
        }
        // Baddies won't appear until the player first moves..
        
        if GameState == .getready {
            GameState = .action
        }
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
       
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      
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
