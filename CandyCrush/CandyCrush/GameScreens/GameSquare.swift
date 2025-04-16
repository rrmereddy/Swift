//
//  GameSquare.swift
//  CandyCrush
//
//  Created by Ritin Mereddy on 3/27/25.
//


import SwiftUI

struct GameSquare {
    var id: Int
    var candyType: CandyType?
    
    var image: Image {
        if let candy = candyType {
            return candy.image
        } else {
            return Image("none")
        }
    }
    
    static var reset: [GameSquare] {
        var squares = [GameSquare]()
        for index in 1...16 {
            squares.append(GameSquare(id: index))
        }
        return squares
    }
}
