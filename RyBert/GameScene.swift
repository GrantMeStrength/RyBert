//
//  GameScene.swift
//  RyBert
//
//  Created by John Kennedy on 10/15/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var statusLabel : SKLabelNode?
    private var rude : SKSpriteNode?
    private var arrows : SKSpriteNode?
    
    
    private var qbertLife1 : SKSpriteNode?
    private var qbertLife2 : SKSpriteNode?
    private var qbertLife3 : SKSpriteNode?
    
    private var targetTile : SKSpriteNode?
    
    
    private var levelLabel : SKLabelNode?
    private var roundLabel : SKLabelNode?
    private var scoreLabel : SKLabelNode?
    
    
    private var ticks = 0
    
    
    private var round = 1
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
    
    
    private var GameState : gameState = .gamestart
    private var GameStateCounter = 0
    
    override func didMove(to view: SKView) {
        
        // Magical scaling code
        scene!.scaleMode = .aspectFit
        scene!.backgroundColor = .black
        
        // Get label node from scene and store it for use later
        self.scoreLabel = self.childNode(withName: "//scoreLabel") as? SKLabelNode
        if let scoreLabel = self.scoreLabel {
            scoreLabel.text = String(score)
        }
        
        self.levelLabel = self.childNode(withName: "//levelLabel") as? SKLabelNode
        if let levelLabel = self.levelLabel {
            levelLabel.text = String(level)
        }
        
        self.roundLabel = self.childNode(withName: "//roundLabel") as? SKLabelNode
        if let roundLabel = self.roundLabel {
            roundLabel.text = String(round)
        }
        
        self.statusLabel = self.childNode(withName: "//statusLabel") as? SKLabelNode
        if let statusLabel = self.statusLabel {
            //            statusLabel.text = "Plop"
            statusLabel.alpha = 0.0
            //           // liveslabel.run(SKAction.fadeIn(withDuration: 2.0))
            //           // liveslabel.text = "Lives: " + String(score)
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
            rude.zPosition = 7
            rude.isHidden = true
            self.addChild(rude)
            
        }
        
        
        
        self.qbertLife1 = self.childNode(withName: "//qbertLife1") as? SKSpriteNode
        self.qbertLife2 = self.childNode(withName: "//qbertLife2") as? SKSpriteNode
        self.qbertLife3 = self.childNode(withName: "//qbertLife3") as? SKSpriteNode
        self.targetTile = self.childNode(withName: "//targetTile") as? SKSpriteNode
        self.arrows = self.childNode(withName: "//arrowsSprite") as? SKSpriteNode
        arrows?.alpha = 0
        
        
        let fadeTextInAndOut = SKAction.sequence([SKAction.fadeIn(withDuration: 0.2), SKAction.wait(forDuration: 1.0), SKAction.fadeOut(withDuration: 0.2) ])
        
        let fadeArrowsInAndOut = SKAction.sequence([SKAction.fadeIn(withDuration: 0.2), SKAction.wait(forDuration: 0.2), SKAction.fadeOut(withDuration: 0.2) ])
        
        // liveslabel.alpha = 0.0
        // liveslabel.run(SKAction.fadeIn(withDuration: 2.0))
        
        
        
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
                        print("\(name) went and \(score) !")
                        break
                    }
                    
                    if name == "collision" && self.GameState == .action
                    {
                        let p = self.QBert!.getSpritePosition()
                        self.rude?.position = CGPoint(x: p.x, y: p.y + 64)
                        self.rude?.isHidden = false
                        self.GameState = .died
                        print("\(name) went and \(score) !")
                        break
                    }
                    
                    if name == "Tile" {
                        
                        let p = self.QBert?.getPosition()
                        self.drawAlternateTile(X: p!.0, Y: p!.1)
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
                status()
                if GameStateCounter == 0
                {
                    Blobs!.hide()
                    TheSid!.hide()
                    rude!.isHidden = true
                }
                GameStateCounter = GameStateCounter + 1
                
            case .gamestart:
                print(GameState)
                lives = 3
                level = 1
                round = 1
                status()
                GameState = .levelstart
                
            case .levelstart:
                print(GameState)
                setLevelDetails()
                status()
                //  Blobs!.reset(level: level)
                QBert!.reset()
                //  TheSid!.reset()
                GameStateCounter = 0
                GameState = .getready
            case .getready:
                if GameStateCounter == 0
                {
                    if lives == 3 { arrows?.isHidden = false;
                        
                        arrows?.run(SKAction.sequence([fadeArrowsInAndOut,fadeArrowsInAndOut,fadeArrowsInAndOut] ))
                    }
                    status()
                    rude?.isHidden = true
                    Blobs!.reset(level: level)
                    TheSid!.reset()
                    statusLabel?.text = "Get Ready"
                    statusLabel?.run(fadeTextInAndOut)
                }
                GameStateCounter = GameStateCounter + 1
                if GameStateCounter == 4 {
                    GameState = .action
                    GameStateCounter = 0
                   
                }
                
            case .action:
                //statusLabel?.text = "Action"
                arrows?.isHidden = true
                TheSid!.controlSid(qbert_position: (QBert?.getPosition())!)
                Blobs!.controlBlobs(qbert_position: (QBert?.getPosition())!)
                GameStateCounter = 0
                
            case .died:
                if GameStateCounter == 0
                {
                    print("Died")
                    TheSid!.resetPosition()
                    lives = lives - 1
                    status()
                }
                GameStateCounter = GameStateCounter + 1
                if GameStateCounter == 4 {
                    
                    if lives == 0 {
                        GameState = .gameover
                        QBert!.hide()
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
                    status()
                }
                else
                {
                    
                    if GameStateCounter > 5
                    {
                        GameStateCounter = 0
                        GameState = .levelstart
                        break
                    }
                }
                GameStateCounter = GameStateCounter + 1
                
            case .flying:
                
                
                status()
                
            case .gameover:
                if GameStateCounter == 0
                {
                    statusLabel?.text = "Game Over"
                    statusLabel?.run(fadeTextInAndOut)
                    GameStateCounter = 1
                }
                else
                {
                    if GameStateCounter == 10 {
                        GameStateCounter = 0
                        GameState = .attract
                        break
                        
                    }
                }
                
                GameStateCounter = GameStateCounter + 1
                
                status()
                
            }
            
            
        }
        
    }
    
    func status() {
        
        if lives > 2 {self.qbertLife3?.isHidden=false} else {self.qbertLife3?.isHidden=true}
        if lives > 1 {self.qbertLife2?.isHidden=false} else {self.qbertLife2?.isHidden=true}
        if lives > 0 {self.qbertLife1?.isHidden=false} else {self.qbertLife1?.isHidden=true}
        roundLabel?.text = String(round)
        levelLabel?.text = String(level)
        scoreLabel?.text = String(score)
        
        switch round {
        case 1 : targetTile?.texture = SKTexture(imageNamed: "square_blue")
        default : targetTile?.texture = SKTexture(imageNamed: "square_red")
        }
        
        
    }
    
    func setLevelDetails() {
        
        switch level {
        case 1 : level_count = 28
        case 2 : level_count = 28
        case 3 : level_count = 56
        default : level_count = 56
        }
    }
    
    
    func freshtile() {
        self.level_count = self.level_count - 1
        print (self.level_count)
        self.score = self.score + 25
        self.scoreLabel?.text = String(self.score)
        
        if self.level_count == 0 {
            self.GameState = .levelcomplete
        }
    }
    
    func drawAlternateTile(X : Int, Y: Int)
    {
        
        if Grid?.getTile(X: X, Y: Y) == 1 {
            Grid?.setTile(X: X, Y: Y, tile: 2)
            let p = Grid!.convertToScreenFromGrid(X: X, Y: Y)
            Tiles!.generateAlternateTile(atPoint: CGPoint(x: p.x, y: p.y - 40), tile: 2)
            freshtile()
        }
        else
        {
            if level == 3 {
                Grid?.setTile(X: X, Y: Y, tile: 3)
                let p = Grid!.convertToScreenFromGrid(X: X, Y: Y)
                Tiles!.generateAlternateTile(atPoint: CGPoint(x: p.x, y: p.y - 40), tile: 3)
                freshtile()
            }
            
        }
    }
    
    
    
    
    func touchDown(atPoint pos : CGPoint) {
        
        // Can only move Qbert
        if /*self.GameState == .getready ||*/ self.GameState == .action {
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
