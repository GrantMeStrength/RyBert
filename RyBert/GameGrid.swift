//
//  GameGrid.swift
//  RyBert
//
//  Created by John Kennedy on 10/18/21.
//

import SpriteKit
import GameplayKit

class GameGrid {
    
  
    public let empty = 0
    public let  yellow = 1
    public let  blue = 2
    public let  red = 3
    public let  diskLeft = 4
    public let  diskRight = 5
   
    
    private var level_1 : [[Int]] = [
                                    [0,0,0,0,0,0,1,0,0,0,0,0,0],
                                    [0,0,0,0,0,1,0,1,0,0,0,0,0],
                                    [0,0,0,0,1,0,1,0,1,0,0,0,0],
                                    [0,4,0,1,0,1,0,1,0,1,0,5,0],
                                    [0,0,1,0,1,0,1,0,1,0,1,0,0],
                                    [0,1,0,1,0,1,0,1,0,1,0,1,0],
                                    [1,0,1,0,1,0,1,0,1,0,1,0,1]]
    
    private let x_start = -290
    private let y_start = 350
  
    
    func getTile(X: Int, Y: Int) -> Int
    {
        if X < 0 || X > 12 || Y < 0 || Y > 6 { return 0}
        return level_1[Y][X]
    }
    
    func setTile(X: Int, Y: Int, tile: Int)
    {
        if X < 0 || X > 12 || Y < 0 || Y > 6 { return }
        level_1[Y][X] = tile
    }
    
    func convertToScreenFromGrid(X: Int, Y: Int) -> CGPoint
    {
        let xx = x_start + X * (288/3)/2
        let yy = y_start - Y * 288/3
        return CGPoint(x: xx, y: yy)
    }
    
    
}
