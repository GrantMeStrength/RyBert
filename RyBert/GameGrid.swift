//
//  GameGrid.swift
//  RyBert
//
//  Created by John Kennedy on 10/18/21.
//

import SpriteKit
import GameplayKit

class GameGrid {
    
    private var level_1 : [[Int]] =          [
                                    [0,0,0,0,0,0,1,0,0,0,0,0,0],
                                    [0,0,0,0,0,1,0,1,0,0,0,0,0],
                                    [0,0,0,0,1,0,1,0,1,0,0,0,0],
                                    [0,4,0,1,0,1,0,1,0,1,0,3,0],
                                    [0,0,1,0,1,0,1,0,1,0,1,0,0],
                                    [0,1,0,1,0,1,0,1,0,1,0,1,0],
                                    [1,0,1,0,1,0,1,0,1,0,1,0,1]]
    
    private let x_start = -290
    private let y_start = 350
  
    
    func getTile(X: Int, Y: Int) -> Int
    {
        return level_1[Y][X]
    }
    
    func setTile(X: Int, Y: Int, tile: Int)
    {
        level_1[Y][X] = tile
    }
    
    func convertToScreenFromGrid(X: Int, Y: Int) -> CGPoint
    {
        let xx = x_start + X * (288/3)/2
        let yy = y_start - Y * 288/3
        return CGPoint(x: xx, y: yy)
    }
    
    
}
