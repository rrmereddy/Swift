//
//  GameView.swift
//  TicTacToev1
//
//  Created by Ritin Mereddy on 2/26/24.
//

import SwiftUI

struct GameView: View {
    
    @EnvironmentObject var game:GameService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack{
            VStack {
                //run an if check on the array of players and both are current then setboth as false
                if [game.player1.isCurrent, game.player2.isCurrent]
                    .allSatisfy({$0 == false}){
                        Text("Select a player to start")
                    }
                
                HStack{
                    Button(game.player1.name){
                        game.player1.isCurrent = true
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .fill(game.player1.isCurrent ?    Color.green: Color.gray)
                    )
                    .foregroundColor(.white)
                    
                    Button(game.player2.name){
                        game.player2.isCurrent = true
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .fill(game.player2.isCurrent ?    Color.green: Color.gray)
                    )
                    .foregroundColor(.white)
                    
                    
                }//end of HStack
                .disabled(game.gameStarted)
                
                //create game board here
                VStack{
                    HStack{
                        ForEach(0...3, id: \.self){
                            index in SquareView(index: index)
                        }
                    }
                    
                    HStack{
                        ForEach(4...7, id: \.self){
                            index in SquareView(index: index)
                        }
                    }
                    
                    HStack{
                        ForEach(8...11, id: \.self){
                            index in SquareView(index: index)
                        }
                    }
                    
                    HStack{
                        ForEach(12...15, id: \.self){
                            index in SquareView(index: index)
                        }
                    }
                }
                //
                .disabled(game.boardDisabled)
                //display winner when game is over
                VStack{
                    if game.gameOver {
                        Text("Game Over")
                        
                        if game.possibleMoves.isEmpty {
                            Text("Nobody wins")
                        } else {
                            Text("\(game.currentPlayer.name) wins!")
                        }
                        
                        Button("New Game") {
                            game.reset()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .font(.largeTitle)
                Spacer()
                
            }.toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button("End Game"){
                        dismiss()
                    }.buttonStyle(.bordered)
                }
            }//end of toolbar
            .navigationTitle("Tic Tac Toe")
            .onAppear{
                game.reset()
            }
        }//end of navigation stack
    }
}

#Preview {
    GameView()
        .environmentObject(GameService())
}
