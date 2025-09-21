//
//  GameConstants.swift
//  RyBert
//

import CoreGraphics

struct GameConstants {
    // Grid configuration
    static let gridWidth = 13
    static let gridHeight = 7
    static let gridTileSpacing = 96 // 288/3 = 96
    static let gridTileOffset: CGFloat = 40
    
    // Dynamic grid positioning based on screen size
    static func gridStartPosition(for screenSize: CGSize) -> CGPoint {
        // Calculate scaled grid dimensions
        let scale = scaleFactor(for: screenSize)
        let scaledSpacing = CGFloat(gridTileSpacing) * scale
        let totalGridWidth = CGFloat(gridWidth - 1) * scaledSpacing / 2
        
        // Center the grid horizontally and position it in the upper portion
        let startX = -totalGridWidth / 2
        let startY = screenSize.height * 0.2 // Move higher up on screen
        
        return CGPoint(x: startX, y: startY)
    }
    
    // Scale tile spacing based on screen size
    static func scaledTileSpacing(for screenSize: CGSize) -> Int {
        let baseScreenWidth: CGFloat = 375 // iPhone 8 width
        let scale = min(screenSize.width / baseScreenWidth, 1.2) // Cap at 1.2x
        return Int(CGFloat(gridTileSpacing) * scale)
    }
    
    // Tile types
    static let empty = 0
    static let yellow = 1
    static let blue = 2
    static let red = 3
    static let diskLeft = 4
    static let diskRight = 5
    
    // Sprite sizes
    static let qbertSize = CGSize(width: 64, height: 64)
    static let qbertRudeSize = CGSize(width: 348/2, height: 172/2)
    static let qbertPhysicsRadius: CGFloat = 20
    
    static let blobSize = CGSize(width: 48, height: 48)
    static let blobPhysicsSize = CGSize(width: 4, height: 4)
    
    static let sidSize = CGSize(width: 48, height: 48)
    static let sidPhysicsSize = CGSize(width: 16, height: 8)
    static let sidSnakeSize = CGSize(width: 48, height: 72)
    
    static let tileSize = CGSize(width: 288/3, height: 320/2.5)
    static let diskSize = CGSize(width: 291/4, height: 115/3)
    
    // Physics categories
    static let qbertPhysicsCategory: UInt32 = 1
    static let blobPhysicsCategory: UInt32 = 2
    
    // Z positions
    static let tileZPosition: CGFloat = 1
    static let tileBlueZPosition: CGFloat = 2
    static let tileRedZPosition: CGFloat = 3
    static let diskZPosition: CGFloat = 3
    static let qbertZPosition: CGFloat = 4
    static let blobZPosition: CGFloat = 5
    static let sidZPosition: CGFloat = 6
    static let rudeZPosition: CGFloat = 7
    
    // Game settings
    static let maxLives = 3
    static let pointsPerTile = 25
    static let level1TileCount = 28
    static let level2PlusTileCount = 56
    static let roundsPerLevel = 4
    
    // Animation durations
    static let jumpDuration: Double = 0.2
    static let fallDuration: Double = 0.4
    static let flyDuration: Double = 1.5
    static let fadeInDuration: Double = 1.0
    static let flashDuration: Double = 0.2
    static let danceDuration: Double = 2.0
    
    // Message animation durations
    static let messageAppearDuration: Double = 0.3
    static let messageDisplayDuration: Double = 1.5
    static let messageFadeDuration: Double = 0.3
    static let messagePulseDuration: Double = 0.8
    static let messageBounceDuration: Double = 0.4
    
    // Game messages
    static let tapToPlayMessages = ["Tap to Play", "Start Game", "Ready to Play?", "Let's Go!", "Jump In!"]
    static let getReadyMessages = ["Get Ready!", "Here We Go!", "Prepare Yourself!", "Ready?", "Let's Do This!"]
    static let levelCompleteMessages = ["Level Complete!", "Well Done!", "Excellent!", "Level Cleared!", "Fantastic!", "Amazing!"]
    static let gameOverMessages = ["Game Over", "Nice Try!", "Play Again?", "Good Game!"]
    
    // Movement deltas
    static let jumpSideDistance: CGFloat = 16
    static let jumpUpHeight: CGFloat = 32
    static let jumpDownHeight: CGFloat = 128
    static let fallY: CGFloat = -700
    static let flyY: CGFloat = 500
    
    // Timer intervals
    static let gameTimerInterval: Double = 0.5
    static let inactivityBlinkInterval = 20
    static let attractDanceInterval = 20
    static let attractTextInterval = 5
    
    // Game state delays
    static let deathDelay: Double = 2.0
    static let diskDelay: Double = 1.65
    static let gameOverDelay = 10
    static let getReadyDelay = 4
    static let levelCompleteDelay = 5
    
    // Blob configuration
    static let maxBlobs = 3
    static let blobInitialDelay = [-8, -4, 0]
    
    // Sid configuration
    static let sidInitialDelay = -4
    static let sidSnakeTransitionCount = 9
    static let sidSnakeDelay = 10
    static let sidSnakeRecycleCount = 7
    
    // Screen size adaptation
    static func scaleFactor(for screenSize: CGSize) -> CGFloat {
        // Calculate how much of the screen the grid should occupy
        let gridWidthInPixels = CGFloat(gridWidth) * CGFloat(gridTileSpacing) / 2
        let gridHeightInPixels = CGFloat(gridHeight) * CGFloat(gridTileSpacing)
        
        // Use 80% of screen width and 60% of screen height as maximum
        let maxWidthScale = (screenSize.width * 0.8) / gridWidthInPixels
        let maxHeightScale = (screenSize.height * 0.6) / gridHeightInPixels
        
        // Use the smaller scale to ensure everything fits
        let scale = min(maxWidthScale, maxHeightScale)
        
        return min(max(scale, 0.3), 0.8) // Clamp between 0.3x and 0.8x for aggressive scaling
    }
    
    static func adaptedTileSize(for screenSize: CGSize) -> CGSize {
        let scale = scaleFactor(for: screenSize)
        return CGSize(width: tileSize.width * scale, height: tileSize.height * scale)
    }
    
    static func adaptedSpriteSize(for screenSize: CGSize) -> CGSize {
        let scale = scaleFactor(for: screenSize)
        return CGSize(width: qbertSize.width * scale, height: qbertSize.height * scale)
    }
    
    static func adaptedSpacing(for screenSize: CGSize) -> Int {
        let scale = scaleFactor(for: screenSize)
        return max(Int(CGFloat(gridTileSpacing) * scale), 20) // Minimum spacing of 20 pixels
    }
}