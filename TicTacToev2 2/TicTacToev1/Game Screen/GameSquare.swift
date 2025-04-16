//
//  GameSquare.swift
//  TicTacToev1
//
//  Created by Ritin Mereddy on 3/4/24.
//

import SwiftUI

struct GameSquare{
    var id:Int //whiich tile 1 to 9
    var player: Player? //? means value can be nil
    
    var image:Image{
        //the line below is not checking for equality.
        //it is only testing for the existence of value within an optional
        
        if let player = player {
            return player.gamePiece.image
        }
        else {
            return Image("none")
        }
    }
    
    static var reset:[GameSquare]{
        var squares = [GameSquare]()
            for index in 1...16 {
                squares.append(GameSquare(id: index))
            }
            return squares
            
        
    }
}
