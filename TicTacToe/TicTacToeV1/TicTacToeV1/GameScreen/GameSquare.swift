//
//  GameSquare.swift
//  TicTacToeV1
//
//  Created by Ritin Mereddy on 2/24/25.
//

import SwiftUI

struct GameSquare{
    var id: Int
    var player: Player? //? means that the value could be null
    
    var image:Image{
        if let player = player{
            return player.gamePiece.image
        }
        else {
            return Image("None")
        }
    }
    
    static var reset:[GameSquare]{
        var squares:[GameSquare] = []
        
        // 4x4 grid
        for index in 0..<16{
            squares.append(GameSquare(id: index))
        }
        return squares
    }
}
