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
    static var all = [1, 2, 3, 4, 5, 6, 7, 8, 9]

    static var winningMoves = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
        [1, 4, 7],
        [2, 5, 8],
        [3, 6, 9],
        [1, 5, 9],
        [3, 5, 7]
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
