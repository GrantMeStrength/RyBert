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
    
    
    private var qbertLife1 : SKSpriteNode?
    private var qbertLife2 : SKSpriteNode?
    private var qbertLife3 : SKSpriteNode?
   
    private var littleA1 : SKSpriteNode?
    private var littleA2 : SKSpriteNode?
    private var littleA3 : SKSpriteNode?
    private var littleA4 : SKSpriteNode?
    
    
    
    private var targetTile : SKSpriteNode?
    
    
    private var levelLabel : SKLabelNode?
    private var roundLabel : SKLabelNode?
    private var scoreLabel : SKLabelNode?
    
    private var inactivityCounter = 1
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
    
    private var soundPrize = SKAction.playSoundFileNamed("prize.mp3", waitForCompletion: false)
    private var soundTune = SKAction.playSoundFileNamed("tune.mp3", waitForCompletion: false)
    private var soundTune2 = SKAction.playSoundFileNamed("tune-2.mp3", waitForCompletion: false)
    private var soundCoin = SKAction.playSoundFileNamed("coin.mp3", waitForCompletion: false)
    
    
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if GameState != .action { return }
        let event = ["collision": "blob"]
        let notification = Notification(name: .gameEvent, object: nil, userInfo: event)
        NotificationCenter.default.post(notification)
        
    }
    
    
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        // Configure scene scaling and background
        scene!.scaleMode = .aspectFit
        scene!.backgroundColor = .black
        
        // Initialize UI labels from scene
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
            statusLabel.alpha = 0.0
            // Enhance the status label appearance
            statusLabel.fontName = "AvenirNext-Bold"
            statusLabel.fontSize = 56
            statusLabel.fontColor = .white
            statusLabel.setScale(1.0)
            
            // Remove any background rectangle that might exist
            removeStatusLabelBackground()
            
            // Add glow effect for visibility
            setupStatusLabelGlow()
        }
        
        Blobs = Blob(withScene: self)
        Tiles = Tile(withScene: self)
        
        Tiles?.drawTiles(round: round)
        Grid = GameGrid(withLevel: level)
       TheSid = Sid(withScene: self)
        QBert = QbertClass(withScene: self)
        
        
        self.qbertLife1 = self.childNode(withName: "//qbertLife1") as? SKSpriteNode
        self.qbertLife2 = self.childNode(withName: "//qbertLife2") as? SKSpriteNode
        self.qbertLife3 = self.childNode(withName: "//qbertLife3") as? SKSpriteNode
        self.targetTile = self.childNode(withName: "//targetTile") as? SKSpriteNode
        self.arrows = self.childNode(withName: "//arrowsSprite") as? SKSpriteNode
        arrows?.alpha = 0
        
        self.littleA1 = self.childNode(withName: "//little1") as? SKSpriteNode
        self.littleA2 = self.childNode(withName: "//little2") as? SKSpriteNode
        self.littleA3 = self.childNode(withName: "//little3") as? SKSpriteNode
        self.littleA4 = self.childNode(withName: "//little4") as? SKSpriteNode
        
        let blink1 = SKAction.sequence([SKAction.fadeOut(withDuration: GameConstants.flashDuration), SKAction.wait(forDuration: 0.5), SKAction.fadeIn(withDuration: GameConstants.flashDuration), SKAction.wait(forDuration: 0.5)])
        let blink2 = SKAction.sequence([SKAction.fadeIn(withDuration: GameConstants.flashDuration), SKAction.wait(forDuration: 0.5), SKAction.fadeOut(withDuration: GameConstants.flashDuration), SKAction.wait(forDuration: 0.5)])
        
        
        littleA1?.run(SKAction.repeatForever(blink1))
        littleA2?.run(SKAction.repeatForever(blink2))
        littleA3?.run(SKAction.repeatForever(blink2))
        littleA4?.run(SKAction.repeatForever(blink1))
        
        // Create arrow animation for hints
        let fadeArrowsInAndOut = SKAction.sequence([SKAction.fadeIn(withDuration: GameConstants.flashDuration), SKAction.wait(forDuration: GameConstants.flashDuration), SKAction.fadeOut(withDuration: GameConstants.flashDuration) ])
        
        
        // Set up game event notification system
        
        NotificationCenter.default.addObserver(forName: .gameEvent, object: nil, queue: nil) {(notification) in
            
            
            if let data = notification.userInfo as? [String: String] {
                
                for (name, thing) in data {
                    
                    if  name == "fall"
                    {
                        self.GameState = .died
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.deathDelay) {
                            
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
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.diskDelay) {
                           
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
        
        // Play opening sound and start game timer
        self.run(soundTune2)
        
        let _ = Timer.scheduledTimer(withTimeInterval: GameConstants.gameTimerInterval, repeats: true) { [self] timer in
            
            
            
            
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
                
                
                if (GameStateCounter % GameConstants.attractDanceInterval == 0)
                {
                    Tiles!.danceTiles()
                }
                
                GameStateCounter = GameStateCounter + 1
                
                if (GameStateCounter % GameConstants.attractTextInterval == 0)
                {
                    let randomMessage = GameConstants.tapToPlayMessages.randomElement() ?? "Tap to Play"
                    showPulsingMessage(randomMessage)
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
                   
                    
                    status()
                    QBert!.hideRude()
                    Blobs!.hide()
                    TheSid!.hide()
                    Blobs!.reset(level: level)
                    TheSid!.reset()
                    let randomMessage = GameConstants.getReadyMessages.randomElement() ?? "Get Ready!"
                    showMessage(randomMessage)
                }
                GameStateCounter = GameStateCounter + 1
                if GameStateCounter == GameConstants.getReadyDelay {
                    arrows?.isHidden = true
                    GameState = .action
                    GameStateCounter = 0
                }
                
            case .action:
                
                if level > 1 {
                    TheSid!.controlSid(qbert_position: (QBert?.getPosition())!)
                }
                Blobs!.controlBlobs()
                
                // Show arrow hints for new players who haven't moved yet
                inactivityCounter = inactivityCounter + 1
                if inactivityCounter % GameConstants.inactivityBlinkInterval == 0 {
                if lives == GameConstants.maxLives { arrows?.isHidden = false;
                    
                    arrows?.run(SKAction.sequence([fadeArrowsInAndOut,fadeArrowsInAndOut,fadeArrowsInAndOut] ))
                }
                }
                
            case .died:
                if GameStateCounter == 0
                {
                    QBert!.stop()
                    Blobs!.stop()
                    if level > 1 {
                        TheSid!.stop()
                        TheSid!.resetPosition()
                    }
                    lives = lives - 1
                    status()
                }
                GameStateCounter = GameStateCounter + 1
                if GameStateCounter == Int(GameConstants.deathDelay) {
                    
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
                    self.run(soundTune)
                    Tiles?.flashTiles()
                    levelUp()
                    status()
                    let randomMessage = GameConstants.levelCompleteMessages.randomElement() ?? "Level Complete!"
                    showCelebrationMessage(randomMessage)
                }
                else
                {
                    
                    if GameStateCounter > GameConstants.levelCompleteDelay
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
                    let randomMessage = GameConstants.gameOverMessages.randomElement() ?? "Game Over"
                    showMessage(randomMessage)
                    GameStateCounter = 1
                }
                else
                {
                    if GameStateCounter == GameConstants.gameOverDelay {
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
    
    func ResetGrid() {
        
        // Reset the grid array
        Grid!.reset(gridlevel: level)
    }
    
    func prepareLevel() {
        
        setLevelDetails()
        Blobs!.reset(level: level)
        QBert!.reset()
        TheSid!.reset()
        
        // Delete any existing level and reset it to create a new one.
        ResetGrid()
        Tiles!.drawTiles(round: round)
        
        // Reset positions and options
        
        Blobs!.reset(level: level)
        TheSid!.reset()
    }
    
    func prepareGame() {
        
        score = 0
        level = 1
        round = 1
        lives = GameConstants.maxLives
    }
    
    func levelUp() {
        
        round = round + 1
        
        if round == GameConstants.roundsPerLevel {
            round = 1
            level = level + 1
        }
    }
    
    
    func status() {
        
        if lives > 2 {self.qbertLife3?.isHidden=false} else {self.qbertLife3?.isHidden=true}
        if lives > 1 {self.qbertLife2?.isHidden=false} else {self.qbertLife2?.isHidden=true}
        if lives > 0 {self.qbertLife1?.isHidden=false} else {self.qbertLife1?.isHidden=true}
        roundLabel?.text = String(round)
        levelLabel?.text = String(level)
        scoreLabel?.text = String(score)
        
        if level == 1 {
            switch round {
            case 1 : targetTile?.texture = SKTexture(imageNamed: "square_blue")
            case 2 : targetTile?.texture = SKTexture(imageNamed: "square_grey_white")
            case 3 : targetTile?.texture = SKTexture(imageNamed: "square_yuck_two")
            default : targetTile?.texture = SKTexture(imageNamed: "square_red")
            }
        }
        
        if level > 1 {
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
        case 1 : level_count = GameConstants.level1TileCount
        case 2 : level_count = GameConstants.level2PlusTileCount
        case 3 : level_count = GameConstants.level2PlusTileCount
        default : level_count = GameConstants.level2PlusTileCount
        }
    }
    
    
    func freshtile() {
        self.level_count = self.level_count - 1
        self.score = self.score + GameConstants.pointsPerTile
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
            Tiles!.generateAlternateTile(atPoint: CGPoint(x: p.x, y: p.y - GameConstants.gridTileOffset), tile: 2)
            freshtile()
        }
        else
        {
            if level == 3 {
                Grid?.setTile(X: X, Y: Y, tile: 3)
                let p = Grid!.convertToScreenFromGrid(X: X, Y: Y)
                Tiles!.generateAlternateTile(atPoint: CGPoint(x: p.x, y: p.y - GameConstants.gridTileOffset), tile: 3)
                freshtile()
            }
            
        }
    }
    
    
    
    
    func touchDown(atPoint pos : CGPoint) {
        
        // Handle touch input for Q*bert movement
        if self.GameState == .action {
            QBert?.moveQbert(tap: pos)
            inactivityCounter = 0
        }
        
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
    
    // MARK: - Message Animation Helpers
    
    func removeStatusLabelBackground() {
        // Look for any background shapes that might be behind the status label
        // Check parent and siblings for rectangles or background shapes
        if let statusLabel = self.statusLabel {
            // Check the label's parent for background shapes
            if let parent = statusLabel.parent {
                for child in parent.children {
                    // Look for shape nodes that might be backgrounds
                    if let shapeNode = child as? SKShapeNode,
                       child != statusLabel,
                       abs(child.position.x - statusLabel.position.x) < 200,
                       abs(child.position.y - statusLabel.position.y) < 100 {
                        // Make it transparent
                        shapeNode.fillColor = .clear
                        shapeNode.strokeColor = .clear
                        shapeNode.alpha = 0.0
                    }
                    // Also check for sprite nodes that might be backgrounds
                    if let spriteNode = child as? SKSpriteNode,
                       child != statusLabel,
                       child.name?.contains("background") == true || child.name?.contains("status") == true {
                        spriteNode.alpha = 0.0
                    }
                }
            }
        }
    }
    
    func setupStatusLabelGlow() {
        guard let statusLabel = self.statusLabel else { return }
        
        // Remove any existing background or glow effects
        statusLabel.removeAllChildren()
        
        // Create glow effect using multiple shadow labels
        let glowColors: [UIColor] = [
            UIColor.black.withAlphaComponent(0.9),
            UIColor.black.withAlphaComponent(0.7),
            UIColor.black.withAlphaComponent(0.5),
            UIColor.black.withAlphaComponent(0.3)
        ]
        
        let glowOffsets: [(CGFloat, CGFloat)] = [
            (0, 0),   // Direct shadow
            (3, 3),   // First offset shadow
            (6, 6),   // Second offset shadow
            (9, 9)    // Outer glow
        ]
        
        for (index, color) in glowColors.enumerated() {
            let glowLabel = SKLabelNode()
            glowLabel.fontName = statusLabel.fontName
            glowLabel.fontSize = statusLabel.fontSize
            glowLabel.fontColor = color
            glowLabel.text = statusLabel.text
            glowLabel.horizontalAlignmentMode = statusLabel.horizontalAlignmentMode
            glowLabel.verticalAlignmentMode = statusLabel.verticalAlignmentMode
            glowLabel.position = CGPoint(x: glowOffsets[index].0, y: -glowOffsets[index].1)
            glowLabel.zPosition = -1 - CGFloat(index)
            glowLabel.name = "glow_\(index)"
            statusLabel.addChild(glowLabel)
        }
    }
    
    func updateGlowText(_ text: String) {
        guard let statusLabel = self.statusLabel else { return }
        
        // Update main label
        statusLabel.text = text
        
        // Update all glow labels
        for i in 0..<4 {
            if let glowLabel = statusLabel.childNode(withName: "glow_\(i)") as? SKLabelNode {
                glowLabel.text = text
            }
        }
    }
    
    func createMessageAnimation() -> SKAction {
        // Bouncy entrance animation
        let scaleUp = SKAction.scale(to: 1.2, duration: GameConstants.messageBounceDuration / 2)
        let scaleDown = SKAction.scale(to: 1.0, duration: GameConstants.messageBounceDuration / 2)
        let fadeIn = SKAction.fadeIn(withDuration: GameConstants.messageAppearDuration)
        let bounce = SKAction.sequence([scaleUp, scaleDown])
        
        let entrance = SKAction.group([fadeIn, bounce])
        let wait = SKAction.wait(forDuration: GameConstants.messageDisplayDuration)
        let fadeOut = SKAction.fadeOut(withDuration: GameConstants.messageFadeDuration)
        
        return SKAction.sequence([entrance, wait, fadeOut])
    }
    
    func createPulsingMessageAnimation() -> SKAction {
        // Pulsing animation for attract mode
        let scaleUp = SKAction.scale(to: 1.1, duration: GameConstants.messagePulseDuration / 2)
        let scaleDown = SKAction.scale(to: 1.0, duration: GameConstants.messagePulseDuration / 2)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        
        let fadeIn = SKAction.fadeIn(withDuration: GameConstants.messageAppearDuration)
        let wait = SKAction.wait(forDuration: GameConstants.messageDisplayDuration)
        let fadeOut = SKAction.fadeOut(withDuration: GameConstants.messageFadeDuration)
        
        let pulseGroup = SKAction.group([pulse, fadeIn])
        return SKAction.sequence([pulseGroup, wait, fadeOut])
    }
    
    func showMessage(_ text: String, animated: Bool = true) {
        statusLabel?.removeAllActions()
        updateGlowText(text)
        statusLabel?.setScale(1.0)
        
        if animated {
            statusLabel?.run(createMessageAnimation())
        } else {
            statusLabel?.alpha = 1.0
        }
    }
    
    func showPulsingMessage(_ text: String) {
        statusLabel?.removeAllActions()
        updateGlowText(text)
        statusLabel?.setScale(1.0)
        statusLabel?.run(createPulsingMessageAnimation())
    }
    
    func showCelebrationMessage(_ text: String) {
        statusLabel?.removeAllActions()
        updateGlowText(text)
        statusLabel?.setScale(1.0)
        statusLabel?.run(createCelebrationAnimation())
    }
    
    func createCelebrationAnimation() -> SKAction {
        // Exciting celebration animation with multiple bounces
        let bigBounce = SKAction.scale(to: 1.5, duration: 0.2)
        let settle1 = SKAction.scale(to: 0.9, duration: 0.1)
        let bounce2 = SKAction.scale(to: 1.2, duration: 0.1)
        let settle2 = SKAction.scale(to: 1.0, duration: 0.1)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let celebration = SKAction.sequence([bigBounce, settle1, bounce2, settle2])
        
        let entrance = SKAction.group([fadeIn, celebration])
        let wait = SKAction.wait(forDuration: GameConstants.messageDisplayDuration)
        let fadeOut = SKAction.fadeOut(withDuration: GameConstants.messageFadeDuration)
        
        return SKAction.sequence([entrance, wait, fadeOut])
    }
}
