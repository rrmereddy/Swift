//
//  SqaureView.swift
//  CandyCrush
//
//  Created by Ritin Mereddy on 3/27/25.
//


import SwiftUI

struct SquareView: View {
    
    @EnvironmentObject var game: GameService
    let index: Int
    
    var isSelected: Bool {
        game.selectedSquare == index
    }
    
    var body: some View {
        Button{
            game.makeMove(at: index)
        } label: {
            game.gameBoard[index].image
                .resizable()
                .frame(width:70, height:70)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                )
        }
        //.disabled(game.gameBoard[index].player != nil)
        .buttonStyle(.bordered)
        .foregroundColor(.primary)
    }
}

#Preview {
    //index set to 1 just for previewing 1 tile
    SquareView(index: 1)
        .environmentObject(GameService())
}

