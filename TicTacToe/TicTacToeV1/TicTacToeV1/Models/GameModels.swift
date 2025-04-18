//
//  GameModels.swift
//  TicTacToeV1
//
//  Created by Ritin Mereddy on 2/10/25.
//

import SwiftUI


enum GameType {
    case single, bot, peer, undetermined

    var description: String {
        switch self {
        case .single:
            return "Share your device with a friend to play."
        case .bot:
            return "Play with a computer."
        case .peer:
            return "Invite somebody to play with you."
        case .undetermined:
            return ""
        }
    }
}

enum GamePiece: String{
    case X, O
    
    var image: Image{
        Image(self.rawValue)
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
/*
 
*/
struct Player{
    var name: String
    let gamePiece: GamePiece
    var isCurrent: Bool = true
    var moves: [Int] = []
    
    
    
    var isWinner: Bool {
        for moves in Moves.winningMoves {
            if moves.allSatisfy(self.moves.contains){
                return true
            }
        }
        
        return false
    }
}
