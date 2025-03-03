//
//  GameView.swift
//  TicTacToeV1
//
//  Created by Ritin Mereddy on 2/24/25.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var game: GameService
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View{
        NavigationStack{
            VStack{
                if[game.player1.isCurrent, game.player2.isCurrent]
                    .allSatisfy({$0 == false}){
                    Text("Select a player")
                } // end of if
                
                HStack{
                    Button(game.player1.name){
                        game.player1.isCurrent = true
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .fill(game.player1.isCurrent ? Color.green : Color.gray)
                    )
                    .foregroundColor(.white)
                    
                    Button(game.player2.name){
                        game.player2.isCurrent = true
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .fill(game.player2.isCurrent ? Color.green : Color.gray)
                    )
                    .foregroundColor(.white)
                } // HStack
                .disabled(game.gameStarted)
                
                VStack{
                    HStack{
                        ForEach(0...2, id: \.self){
                            index in SquareView(index: index)
                        }
                    }
                    
                    HStack{
                        ForEach(3...5, id: \.self){
                            index in SquareView(index: index)
                        }
                    }

                    HStack{
                        ForEach(6...8, id: \.self){
                            index in SquareView(index: index)
                        }
                    }

                }// end of board stack
                
                
            }
            .disabled(game.boardDisable)
            .padding(10)
            
            //logic for winner
            
            VStack{
                if game.gameOver{
                    Text("Game Over!")
                    
                    if game.possibleMoves.isEmpty{
                        Text("It's a draw!")
                    } else{
                        Text("\(game.currentPlayer.name) is the winner!")
                    }
                    
                    Button("New Game"){
                        game.reset()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } // game result VStack
            .font(.largeTitle)
            .opacity(game.gameStarted ? 1 : 0)
            
            Spacer()
        }
    }
}

#Preview {
    GameView()
        .environmentObject(GameService())
}
