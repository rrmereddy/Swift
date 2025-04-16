//
//  ContentView.swift
//  CandyCrush
//
//  Created by Ritin Mereddy on 3/27/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var game: GameService
    @State private var playerName = ""
    @State private var startGame = false
    @State private var selectedLevel: Level?
    @FocusState private var focus: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to Candy Crush!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Image("Welcome")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
                    .padding()
                
                TextField("Enter Your Name", text: $playerName)
                    .textFieldStyle(.roundedBorder)
                    .focused($focus)
                    .frame(width: 300)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Level")
                        .font(.headline)
                    
                    Picker("Level", selection: $selectedLevel) {
                        Text("Choose a level").tag(Optional<Level>.none)
                        ForEach(Level.all, id: \.id) { level in
                            Text(level.name).tag(Optional(level))
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 300)
                    
                    if let level = selectedLevel {
                        Text(level.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                Button("Start Game") {
                    if let level = selectedLevel {
                        game.setupGame(playerName: playerName, level: level)
                        focus = false
                        startGame.toggle()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(playerName.isEmpty || selectedLevel == nil)
                .padding(.top)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Candy Crush")
            .fullScreenCover(isPresented: $startGame) {
                GameView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GameService())
}

