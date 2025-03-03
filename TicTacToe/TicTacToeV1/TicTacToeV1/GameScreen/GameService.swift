//
//  GameService.swift
//  TicTacToeV1
//
//  Created by Ritin Mereddy on 2/17/25.
//

import SwiftUI

/*
 Created Game Models for GamePiece, Moves, Player
 Created GameService Class with all publishable/observable states
 */
class GameService: ObservableObject{
    @Published var gameBoard = GameSquare.reset
    @Published var player1: Player = Player(name: "Player 1", gamePiece: .X)
    @Published var player2: Player = Player(name: "Player 2", gamePiece: .O)
    
    @Published var possibleMoves = Moves.all
    
    //Build the Game Board
    @Published var gameOver: Bool = false
    var gameStarted: Bool{
        return player1.isCurrent || player2.isCurrent
    }
    var boardDisable:Bool{
        return gameOver || !gameStarted
    }
    
    var gameType: GameType = GameType.single
    
    var currentPlayer: Player{
        if player1.isCurrent {
            return player1
        }
        
        return player2
    }
    
    func setGameUp(gameType: GameType, player1Name: String, player2Name: String){
        switch gameType {
            case .single:
                self.gameType = .single
                self.player2.name = player2Name
            
            case .bot:
                self.gameType = .bot
                self.player2.name = "Computer"
            
            case .peer:
                self.gameType = .peer
            
            case .undetermined:
                break
            
        }
        self.player1.name = player1Name
    }
    
    func reset(){
        player1.isCurrent = false
        player2.isCurrent = false
        
        player1.moves.removeAll()
        player2.moves.removeAll()
        
        possibleMoves = Moves.all
        
        gameOver = false
        
        gameBoard = GameSquare.reset
    }
    
    func updateMoves(index: Int){
        if player1.isCurrent{
            player1.moves.append(index+1)
            gameBoard[index].player = player1
        } else {
            player2.moves.append(index+1)
            gameBoard[index].player = player2
        }
    }
    
    func checkIfWinner(){
        if player1.isWinner || player2.isWinner{
            gameOver = true
        }
    }
    
    func toggleCurrent(){
        player1.isCurrent.toggle()
        player2.isCurrent.toggle()
    }
    
    func makeMove(at index: Int){
        if gameBoard[index].player == nil{
            withAnimation{
                updateMoves(index: index)
            }
        }
        checkIfWinner()
        
        if !gameOver{
            if let matchingIndex = possibleMoves.firstIndex(where: {$0 == (index + 1)}){
                possibleMoves.remove(at: matchingIndex)
            }
            toggleCurrent()
        }
        if possibleMoves.isEmpty {
            gameOver = true
        }
    }
    
    
}
