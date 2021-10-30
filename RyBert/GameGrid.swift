//
//  GameGrid.swift
//  RyBert
//
//  Created by John Kennedy on 10/18/21.
//


// Create one grid that is available to all classes

import SpriteKit
import GameplayKit

class GameGrid {
    
  
    public let empty = 0
    public let  yellow = 1
    public let  blue = 2
    public let  red = 3
    public let  diskLeft = 4
    public let  diskRight = 5
   
    
    static var grid : [[Int]] = [
        [0,0,0,0,0,0,1,0,0,0,0,0,0],
        [0,0,0,0,0,1,0,1,0,0,0,0,0],
        [0,0,0,0,1,0,1,0,1,0,0,0,0],
        [0,4,0,1,0,1,0,1,0,1,0,5,0],
        [0,0,1,0,1,0,1,0,1,0,1,0,0],
        [0,1,0,1,0,1,0,1,0,1,0,1,0],
        [1,0,1,0,1,0,1,0,1,0,1,0,1]]
    
    private let level_1 : [[Int]] = [
                                    [0,0,0,0,0,0,1,0,0,0,0,0,0],
                                    [0,0,0,0,0,1,0,1,0,0,0,0,0],
                                    [0,0,0,0,1,0,1,0,1,0,0,0,0],
                                    [0,4,0,1,0,1,0,1,0,1,0,5,0],
                                    [0,0,1,0,1,0,1,0,1,0,1,0,0],
                                    [0,1,0,1,0,1,0,1,0,1,0,1,0],
                                    [1,0,1,0,1,0,1,0,1,0,1,0,1]]
    
    
    private let level_2 : [[Int]] = [
                                    [0,0,0,0,0,0,1,0,0,0,0,0,0],
                                    [0,0,0,0,0,1,0,1,0,0,0,0,0],
                                    [0,0,0,0,1,0,0,0,1,0,0,0,0],
                                    [0,4,0,1,0,0,0,0,0,1,0,5,0],
                                    [0,0,1,0,1,0,0,0,1,0,1,0,0],
                                    [0,1,0,1,0,1,0,1,0,1,0,1,0],
                                    [1,0,1,0,1,0,1,0,1,0,1,0,1]]
    
    private let level_3 : [[Int]] = [
                                    [0,0,0,0,0,0,1,0,0,0,0,0,0],
                                    [0,0,0,0,0,1,0,1,0,0,0,0,0],
                                    [0,0,0,0,1,0,0,0,1,0,0,0,0],
                                    [0,4,0,1,0,0,0,0,0,1,0,5,0],
                                    [0,0,1,0,1,0,0,0,1,0,1,0,0],
                                    [0,1,0,0,0,1,0,1,0,0,0,1,0],
                                    [1,0,1,0,1,0,1,0,1,0,1,0,1]]
  
   
    
    private let x_start = -290
    private let y_start = 350
  
    
    init(withLevel: Int) {
        
      reset(gridlevel: withLevel)
        
    }
    
    func reset(gridlevel : Int) {
        for y in 0...6 {
            for x in 0...12 {
                
                if gridlevel == 1 {
                GameGrid.grid[y][x] = level_1[y][x]
                }
                
                if gridlevel == 2 {
                GameGrid.grid[y][x] = level_2[y][x]
                }
                
                if gridlevel > 2 {
                GameGrid.grid[y][x] = level_3[y][x]
                }
                
            }
        }
        
    }
    
    func getTile(X: Int, Y: Int) -> Int
    {
        if X < 0 || X > 12 || Y < 0 || Y > 6 { return 0}
        return GameGrid.grid[Y][X]
    }
    
    func setTile(X: Int, Y: Int, tile: Int)
    {
        if X < 0 || X > 12 || Y < 0 || Y > 6 { return }
        GameGrid.grid[Y][X] = tile
    }
    
    func convertToScreenFromGrid(X: Int, Y: Int) -> CGPoint
    {
        let xx = x_start + X * (288/3)/2
        let yy = y_start - Y * 288/3
        return CGPoint(x: xx, y: yy)
    }
    
    
}
