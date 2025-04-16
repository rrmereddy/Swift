//
//  GameView.swift
//  CandyCrush
//
//  Created by Ritin Mereddy on 3/27/25.
//


import SwiftUI

struct GameView: View {
    @EnvironmentObject var game: GameService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Player: \(game.player.name)")
                    .font(.title2)
                    .padding()
                
                if let level = game.currentLevel {
                    Text("Level: \(level.name)")
                        .font(.title3)
                    Text("Matches: \(game.player.matches)/\(level.requiredMatches)")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                // Game board
                VStack {
                    HStack {
                        ForEach(0...3, id: \.self) { index in
                            SquareView(index: index)
                        }
                    }
                    
                    HStack {
                        ForEach(4...7, id: \.self) { index in
                            SquareView(index: index)
                        }
                    }
                    
                    HStack {
                        ForEach(8...11, id: \.self) { index in
                            SquareView(index: index)
                        }
                    }
                    
                    HStack {
                        ForEach(12...15, id: \.self) { index in
                            SquareView(index: index)
                        }
                    }
                }
                .disabled(game.boardDisabled)
                
                // Game over state
                VStack {
                    if game.gameOver || game.hasLost {
                        Text("Game Over")
                            .font(.largeTitle)
                        
                        if game.hasLost {
                            Text("No more possible matches!")
                                .font(.title2)
                                .foregroundColor(.red)
                            Text("Try Again")
                                .font(.title)
                        } else {
                            Text("Congratulations!")
                                .font(.title2)
                                .foregroundColor(.green)
                            Text("You Won!")
                                .font(.title)
                        }
                        
                        Button("New Game") {
                            game.reset()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                }
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("End Game") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .navigationTitle("Candy Crush")
            .onAppear {
                game.reset()
            }
        }
    }
}

#Preview {
    GameView()
        .environmentObject(GameService())
}


