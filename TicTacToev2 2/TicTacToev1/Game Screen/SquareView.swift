//
//  SquareView.swift
//  TicTacToev1
//
//  Created by Ritin Mereddy on 3/4/24.
//

import SwiftUI

struct SquareView: View {
    
    @EnvironmentObject var game: GameService
    let index: Int
    
    var body: some View {
        Button{
            game.makeMove(at: index)
        } label: {
            game.gameBoard[index].image
                .resizable()
                .frame(width:70, height:70)
        }
        .disabled(game.gameBoard[index].player != nil)
        .buttonStyle(.bordered)
        .foregroundColor(.primary)
    }
}

#Preview {
    //index set to 1 just for previewing 1 tile
    SquareView(index: 1)
        .environmentObject(GameService())
}
