//
//  GameScene.swift
//  RyBert
//
//  Created by John Kennedy on 10/15/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var statusLabel : SKLabelNode?
    private var arrows : SKSpriteNode?
    private var demoStatusLevel : SKLabelNode?
    
    private var CLS : SKShapeNode?
    private var qbertDemo : SKSpriteNode?
   
    
    private var qbertLife1 : SKSpriteNode?
    private var qbertLife2 : SKSpriteNode?
    private var qbertLife3 : SKSpriteNode?
    private var qbertLife4 : SKSpriteNode?
   
    private var littleA1 : SKSpriteNode?
    private var littleA2 : SKSpriteNode?
    private var littleA3 : SKSpriteNode?
    private var littleA4 : SKSpriteNode?
    
    
    
    private var targetTile : SKSpriteNode?
    
    
    private var levelLabel : SKLabelNode?
    private var roundLabel : SKLabelNode?
    private var scoreLabel : SKLabelNode?
    private var highScoreLabel : SKLabelNode?
    
    private var inactivityCounter = 1
    private var ticks = 0
    
    
    private var round = 1
    private var level = 1
    private var lives = 3
    private var score = 0
    private var highscore = 1000
    private var level_count = 0
    private var target_for_extra_life = 2000

    
    private var Blobs : Blob?
    private var Tiles : Tile?
    private var Grid : GameGrid?
    private var TheSid : Sid?
    private var QBert : QbertClass?
    
    private var soundPrize = SKAction.playSoundFileNamed("prize.mp3", waitForCompletion: false)
    private var soundTune = SKAction.playSoundFileNamed("tune.mp3", waitForCompletion: false)
    private var soundTune2 = SKAction.playSoundFileNamed("tune-2.mp3", waitForCompletion: false)
    private var soundCoin = SKAction.playSoundFileNamed("coin.mp3", waitForCompletion: false)
    private var soundJumpPause = SKAction.playSoundFileNamed("jump-3.mp3", waitForCompletion: false)
    
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
    
    
    private var GameState : gameState = .attract
    private var GameStateCounter = 0
    private var gsc_delay = 4
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if GameState != .action { return }
        
        // which blob? is it visible?
       
        if (contact.bodyA.node?.isHidden == true || contact.bodyB.node?.isHidden == true)
        {
           // Can't be collision as it's hidden
            
            return
        }
        
        Blobs!.stop()
        QBert!.stop()
       
        let event = ["collision": "blob"]
        let notification = Notification(name: .gameEvent, object: nil, userInfo: event)
        NotificationCenter.default.post(notification)
        
        
    }
    
    
    
    override func didMove(to view: SKView) {
        
//        for family in UIFont.familyNames {
//            print("\(family)")
//
//            for name in UIFont.fontNames(forFamilyName: family) {
//                print("\(name)")
//            }
//        }
        
        physicsWorld.contactDelegate = self
        //view.showsPhysics = true <- see outlines, useful for debugging
        
        // Magical scaling code
        scene!.scaleMode = .aspectFit
        scene!.backgroundColor = .black
        
        // Get label node from scene and store it for use later
        self.scoreLabel = self.childNode(withName: "//scoreLabel") as? SKLabelNode
        if let scoreLabel = self.scoreLabel {
            scoreLabel.text = String(score)
        }
        
        self.highScoreLabel = self.childNode(withName: "//highScoreLabel") as? SKLabelNode
        if let highScoreLabel = self.highScoreLabel {
            highScoreLabel.text = String(highscore)
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
            statusLabel.alpha = 0.0
        }
        
        self.demoStatusLevel = self.childNode(withName: "//demoLevelNumber") as? SKLabelNode
        if let demoStatusLevel = self.demoStatusLevel {
            demoStatusLevel.text = "Monkey"
        }
        
        Blobs = Blob(withScene: self)
        Tiles = Tile(withScene: self)
        
        Tiles?.drawTiles(round: round)
        Grid = GameGrid(withLevel: level)
       TheSid = Sid(withScene: self)
        QBert = QbertClass(withScene: self)
        
        QBert?.hide()
        
        self.qbertLife1 = self.childNode(withName: "//qbertLife1") as? SKSpriteNode
        self.qbertLife2 = self.childNode(withName: "//qbertLife2") as? SKSpriteNode
        self.qbertLife3 = self.childNode(withName: "//qbertLife3") as? SKSpriteNode
        self.qbertLife4 = self.childNode(withName: "//qbertLife4") as? SKSpriteNode
        self.qbertDemo = self.childNode(withName: "//qbertdemo") as? SKSpriteNode
        
       
        self.targetTile = self.childNode(withName: "//targetTile") as? SKSpriteNode
        self.arrows = self.childNode(withName: "//arrowsSprite") as? SKSpriteNode
        arrows?.alpha = 0
        
        self.CLS = self.childNode(withName: "//CLS") as? SKShapeNode
        CLS?.alpha = 0
        CLS?.position = CGPoint(x: 0, y: 0)
        
        self.littleA1 = self.childNode(withName: "//little1") as? SKSpriteNode
        self.littleA2 = self.childNode(withName: "//little2") as? SKSpriteNode
        self.littleA3 = self.childNode(withName: "//little3") as? SKSpriteNode
        self.littleA4 = self.childNode(withName: "//little4") as? SKSpriteNode
        
        let blink1 = SKAction.sequence([SKAction.fadeOut(withDuration: 0.1), SKAction.wait(forDuration: 0.5), SKAction.fadeIn(withDuration: 0.1), SKAction.wait(forDuration: 0.5)])
        let blink2 = SKAction.sequence([SKAction.fadeIn(withDuration: 0.1), SKAction.wait(forDuration: 0.5), SKAction.fadeOut(withDuration: 0.1), SKAction.wait(forDuration: 0.5)])
        
        //let fadeCLS = SKAction.fadeOut(withDuration: 2.5)
        
        littleA1?.run(SKAction.repeatForever(blink1))
        littleA2?.run(SKAction.repeatForever(blink2))
        littleA3?.run(SKAction.repeatForever(blink2))
        littleA4?.run(SKAction.repeatForever(blink1))
        
        let fadeTextInAndOut = SKAction.sequence([SKAction.fadeIn(withDuration: 0.2), SKAction.wait(forDuration: 1.0), SKAction.fadeOut(withDuration: 0.2) ])
        
        //CLS?.run(fadeCLS)
        
        let fadeArrowsInAndOut = SKAction.sequence([SKAction.fadeIn(withDuration: 0.2), SKAction.wait(forDuration: 0.2), SKAction.fadeOut(withDuration: 0.2) ])
        
        
        // Add notification system
        
        NotificationCenter.default.addObserver(forName: .gameEvent, object: nil, queue: nil) {(notification) in
            
            
            if let data = notification.userInfo as? [String: String] {
                
                for (name, thing) in data {
                    
                    if  name == "fall"
                    {
                        self.GameState = .died
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            
                            if self.lives > 0 {
                                self.QBert!.reset()
                            }
                            else {
                                self.QBert!.hide()
                            }
                            
                        }
                        print("\(name) -> \(thing) !")
                        break
                    }
                    
                    if name == "collision" && self.GameState == .action
                    {
                        
                        self.QBert!.showRude()
                        self.QBert!.gotoPosition()
                        
                        self.GameState = .died
                        print("\(name) -> \(thing) !")
                        break
                    }
                    
                    if name == "Tile" {

                        let p = self.QBert?.getPosition()
                        self.drawAlternateTile(X: p!.0, Y: p!.1)
                    }
                    
                    if name == "Disk" {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.65) {
                           
                            self.GameState = .action
                            let event = ["Tile": "fly"]
                            let notification = Notification(name: .gameEvent, object: nil, userInfo: event)
                            NotificationCenter.default.post(notification)
                        }
                        
                        self.GameState = .flying
                      
                       
                        
                        if (thing == "left") {
                            self.Tiles?.flyingDisk(left_side : true, qbertpos: (self.QBert?.getPosition())!)
                        }
                        else {
                            self.Tiles?.flyingDisk(left_side : false, qbertpos: (self.QBert?.getPosition())!)
                        }
                        
                        self.QBert?.flyingQbert()
                        
                       
                    }
                    
                    //print("\(name) -> \(thing) !")
                }
            }
            
        }
        
        // Opening sound
        self.run(soundTune2)
        
        let _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [self] timer in
            
            
            
            
            ticks = ticks + 1
            
            if ticks == 4 { ticks = 0}
            
            switch GameState {
                
                
            case .attract:
              
              
                if GameStateCounter == 0
                {
                    status()
                    Blobs!.hide()
                    TheSid!.hide()
                    QBert!.hideRude()
                }
                
                
                if (GameStateCounter % 20 == 0)
                {
                    Tiles!.danceTiles()
                }
                
                GameStateCounter = GameStateCounter + 1
                
                if (GameStateCounter % 5 == 0)
                {
                    
                    statusLabel?.text = "Tap to play"
                    statusLabel?.run(fadeTextInAndOut)
                }
                
            case .gamestart:
                prepareGame()
                ResetGrid()
                
                status()
                GameState = .levelstart
                self.run(soundCoin)
                
            case .levelstart:
                prepareLevel()
                status()
                GameStateCounter = 0
                GameState = .getready
                
                
            case .getready:
                
                if GameStateCounter == 0
                {
                    if round == 1 && lives >= 3
                    {
                        demoStatusLevel?.text = String(level)
                        CLS?.position = CGPoint(x: 0, y: 0)
                        CLS?.alpha = 1
                        gsc_delay = 5
                        
                        // Do complicated QBert jumps
                        
                       Demo()
                        
                    }
                    else
                    {
                        gsc_delay = 4
                    }
                    
                    status()
                    QBert!.hideRude()
                    Blobs!.hide()
                    TheSid!.hide()
                    Blobs!.reset(level: level, round: round)
                    TheSid!.reset()
                    statusLabel?.text = "Get Ready"
                    statusLabel?.run(fadeTextInAndOut)
                }
                GameStateCounter = GameStateCounter + 1
                
                if (GameStateCounter == gsc_delay)
                {
                 print (gsc_delay)
                    arrows?.isHidden = true
                    GameState = .action
                    GameStateCounter = 0
                }
                
               
                
            case .action:
                
                if (GameStateCounter == 0)
                {
                    if round == 1 && lives >= 3
                    {
                        CLS?.position = CGPoint(x: 1000, y: 1000)
                        CLS?.alpha = 0
                       
                    }
                    
                    
                }
                
                if level > 1 {
                    TheSid!.controlSid(qbert_position: (QBert?.getPosition())!)
                }
                Blobs!.controlBlobs()
                
                // If the user hasn't touched the screen in a long time, blink the arrows
                inactivityCounter = inactivityCounter + 1
                if inactivityCounter % 20 == 0 {
                // Blink the arrows to remind folks to move - but only if they haven't touched the screen yet
                if lives == 3 { arrows?.isHidden = false;
                    
                    arrows?.run(SKAction.sequence([fadeArrowsInAndOut,fadeArrowsInAndOut,fadeArrowsInAndOut] ))
                }
                }
                
            case .died:
                if GameStateCounter == 0
                {
                    //QBert!.stop()
                    //Blobs!.stop()
                    if level > 1 {
                        TheSid!.stop()
                        TheSid!.resetPosition()
                    }
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
                    let lc = (level * 3 + round) - 4
                    var bonus = lc * 250
                    if bonus > 5000 { bonus = 5000}
                    updateScore(increment: 1000 + bonus)
                    self.run(soundTune)
                    Tiles?.flashTiles()
                    levelUp()
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
    
    func Demo() {
    
        // 1.
        qbertDemo?.texture = SKTexture(imageNamed: "qbertR")
        DemoJump(side: 2.5, height: 4, side2: 2.5, height2: -10)
        qbertDemo?.run(soundJumpPause)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            //2.
            self.qbertDemo?.texture = SKTexture(imageNamed: "qbert")
            self.DemoJump(side: -2.5, height: 4, side2: -2.5, height2: -10)
            self.qbertDemo?.run(self.soundJumpPause)
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            //3.
            self.qbertDemo?.texture = SKTexture(imageNamed: "qbertLU")
            self.DemoJump(side: -2.5, height: 10, side2: -2.5, height2: -4)
            self.qbertDemo?.run(self.soundJumpPause)
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            
            //3.
            self.qbertDemo?.texture = SKTexture(imageNamed: "qbertRU")
            self.DemoJump(side: 2.5, height: 10, side2: 2.5, height2: -4)
            self.qbertDemo?.run(self.soundJumpPause)
            
        }
        
      
        
       // DemoJump(side: -2.5, height: 8, side2: -2.5, height2: -4)
    }
    
    
    func DemoJump(side : CGFloat, height: CGFloat, side2 : CGFloat, height2: CGFloat) {
       
        let jump1 = SKAction.moveBy(x: side, y: height, duration: 0.2)
        let jump2 = SKAction.resize(toHeight: 72, duration: 0.2)
        let jumpA = SKAction.group([jump1, jump2])
       // let wait = SKAction.wait(forDuration: 0.1)
        
        let jump3 = SKAction.moveBy(x: side2, y : height2, duration: 0.2)
        let jump4 = SKAction.resize(toHeight: 58, duration: 0.2)
       // let jump5 = SKAction.resize(toHeight: 64, duration: 0.2)
        
        let jumpB = SKAction.group([jump3, jump4])
        
        qbertDemo?.run(SKAction.sequence([jumpA, jumpB]))
    }
    
    func ResetGrid() {
        
        // Reset the grid array
        Grid!.reset(gridlevel: level)
    }
    
    func prepareLevel() {
        
        setLevelDetails()
        Blobs!.reset(level: level, round: round)
        QBert!.reset()
        TheSid!.reset()
        
        // Delete any existing level and reset it to create a new one.
        ResetGrid()
        Tiles!.drawTiles(round: round)
        
        // Reset positions and options
        
        Blobs!.reset(level: level, round: round)
        TheSid!.reset()
    }
    
    
    
    func prepareGame() {
        
        score = 0
        level = 1
        round = 1
        lives = 3
    }
    
    func levelUp() {
        
        round = round + 1
        
        if round == 4 {
            round = 1
            level = level + 1
        }
    }
    
    
    func status() {
        if lives > 3 {self.qbertLife4?.isHidden=false} else {self.qbertLife4?.isHidden=true}
        if lives > 2 {self.qbertLife3?.isHidden=false} else {self.qbertLife3?.isHidden=true}
        if lives > 1 {self.qbertLife2?.isHidden=false} else {self.qbertLife2?.isHidden=true}
        if lives > 0 {self.qbertLife1?.isHidden=false} else {self.qbertLife1?.isHidden=true}
        roundLabel?.text = String(round)
        levelLabel?.text = String(level)
        scoreLabel?.text = String(score)
        highScoreLabel?.text = String(highscore)
        
        if level < 3 {
            switch round {
            case 1 : targetTile?.texture = SKTexture(imageNamed: "square_blue")
            case 2 : targetTile?.texture = SKTexture(imageNamed: "square_grey_white")
            case 3 : targetTile?.texture = SKTexture(imageNamed: "square_yuck_two")
            default : targetTile?.texture = SKTexture(imageNamed: "square_red")
            }
        }
        
        if level > 2 {
            switch round {
            case 1 : targetTile?.texture = SKTexture(imageNamed: "square_red")
            case 2 : targetTile?.texture = SKTexture(imageNamed: "square_grey_blue")
            case 3 : targetTile?.texture = SKTexture(imageNamed: "square_yuck_three")
            default : targetTile?.texture = SKTexture(imageNamed: "square_red")
            }
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
    
    
    func updateScore(increment : Int) {
        self.score = self.score + increment
        self.scoreLabel?.text = String(self.score)
        
        if self.score > self.highscore { highscore = score; self.highScoreLabel?.text = String(self.highscore) }
        
        if lives == 4 { return }
        
        if self.score > target_for_extra_life {
            self.run(soundPrize)
            lives = lives + 1
            target_for_extra_life = target_for_extra_life + 10000
            status()
        }
        
        
    }
    
    func freshtile() {
        self.level_count = self.level_count - 1

        updateScore(increment: 25)
        
        if self.level_count == 0 {
            self.GameState = .levelcomplete
        }
    }
    
    func drawAlternateTile(X : Int, Y: Int)
    {
       
        if Grid?.getTile(X: X, Y: Y) == 1 {
            Grid?.setTile(X: X, Y: Y, tile: 2) // Is this really setting the value?!
            
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
        if self.GameState == .action {
            QBert?.moveQbert(tap: pos)
            inactivityCounter = 0
        }
        // Baddies won't appear until the player first moves..
        
        if GameState == .attract {
            GameState = .gamestart
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
