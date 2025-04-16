//
//  ContentView.swift
//  TicTacToeV1
//
//  Created by Ritin Mereddy on 2/10/25.
//

/*
    Started with creating a project, type of views the project can have, uploaded assets with launch screen * Icon - 1024 x 1024, refactoring names of Views
    Created models for the states of the game, created enum with switch
    Created state variable to hold important info
    Created Vstack and UI, and logic required for UI shown dpending on gameType
 */


import SwiftUI


struct StartView: View {
    @State private var gameType: GameType = .undetermined
    @State private var playerName: String = ""
    @State private var opponentName: String = ""
    
    @FocusState private var focus: Bool
    
    @State private var startGame: Bool = false
    @StateObject private var gameService = GameService()
    
    var body: some View {
        VStack{
            Picker("Select Game Type", selection: $gameType) {
                Text("Select Game Type").tag(GameType.undetermined)
                Text("Two sharing a device").tag(GameType.single)
                Text("Challenge a bot").tag(GameType.bot)
                Text("Play online!").tag(GameType.peer)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding()
            
            Text(gameType.description)
                .padding()
            
            VStack{
                switch gameType {
                case .undetermined:
                    EmptyView()
                case .single:
                    TextField("Your Name", text: $playerName)
                        .padding()
                    TextField("Opponent's name", text: $opponentName)
                        .padding()
                case .bot:
                    TextField("Your Name", text: $playerName)
                        .padding()
                case .peer:
                    EmptyView()
                }
            }
            .padding()
            .textFieldStyle(.roundedBorder)
            .focused($focus)
            .frame(width: 350)
            
            if gameType != .peer && gameType != .undetermined {
                Button("Start Game"){
                    // set up the game - RM
                    focus = false
                    startGame.toggle()
                }
                .padding()
                .buttonStyle(.borderedProminent)
                .disabled(
                    gameType == .undetermined || playerName.isEmpty || (gameType == .single && opponentName.isEmpty) || startGame == true
                )
                Image("welcomeScreen")
            }
        }
        .padding()
        .navigationTitle("Tic-Tac-Toe")
        .fullScreenCover(isPresented: $startGame){
            GameView()
                .environmentObject(gameService)
        }
    }
}

#Preview {
    StartView()
        .environmentObject(GameService())
}
