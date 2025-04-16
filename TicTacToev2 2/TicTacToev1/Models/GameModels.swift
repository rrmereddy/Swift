//
//  GameModels.swift
//  TicTacToev1
//
//  Created by Ritin Mereddy on 2/19/24.
//

import SwiftUI

enum GameType{
    case single, bot, peer, undetermined
    
    var description:String{
        switch self{
            //lower case self is a current instance of the structure
            //upper case Self is the the structure itself
        case .single:
            return "Share your device and play against a friend."
            
        case .bot:
            return "Play againat the device."
            
        case .peer:
            return "Invite someone near you with the app to play."
            
        case .undetermined:
            return ""
        }
    }
    
}

enum GamePiece: String{
    case x, o
    var image:Image{
        Image(self.rawValue)
    }
}


struct Player{
    let gamePiece:GamePiece
    var name:String
    var moves:[Int] = []
    var isCurrent = false
    
    var isWinner:Bool{
        for moves in Moves.winningMoves{
            if moves.allSatisfy(self.moves.contains){
                return true
            }
        }
        return false
    }
}

enum Moves{
    static var all = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]

    static var winningMoves = [
        // Horizontal rows (3 consecutive in each row)
        [1, 2, 3], [2, 3, 4],
        [5, 6, 7], [6, 7, 8],
        [9, 10, 11], [10, 11, 12],
        [13, 14, 15], [14, 15, 16],
        
        // Vertical columns (3 consecutive in each column)
        [1, 5, 9], [5, 9, 13],
        [2, 6, 10], [6, 10, 14],
        [3, 7, 11], [7, 11, 15],
        [4, 8, 12], [8, 12, 16],
        
        // Diagonals (3 consecutive in each diagonal)
        [1, 6, 11], [6, 11, 16],
        [4, 7, 10], [7, 10, 13]
    ]
    
    
}

