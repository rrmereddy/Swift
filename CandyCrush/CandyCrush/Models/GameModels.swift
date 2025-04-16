//
//  GameModels.swift
//  CandyCrush
//
//  Created by Ritin Mereddy on 3/27/25.
//

import SwiftUI

enum CandyType: String {
    case ball = "ball"
    case drop = "drop"
    case sausage = "sausage"
    case star = "star"
    
    var image: Image {
        Image(self.rawValue)
    }
    
    static var all: [CandyType] = [.ball, .drop, .sausage, .star]
}

struct Level: Identifiable, Hashable {
    let id: Int
    let name: String
    let description: String
    let initialBoard: [CandyType?]
    let requiredMatches: Int
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    // Hashable done by cursor to allow for picker to work
    // Implement Equatable (required by Hashable)
    static func == (lhs: Level, rhs: Level) -> Bool {
        lhs.id == rhs.id
    }
    
    // Struct done by me
    static let all: [Level] = [
        Level(
            id: 1,
            name: "Beginner",
            description: "Match 3 candies to clear the board",
            initialBoard: [
                .ball, .drop, .sausage, .star,
                .drop, .ball, .sausage, .star,
                .ball, .drop, .star, .sausage,
                .ball, .drop, .sausage, .star
            ],
            requiredMatches: 4
        ),
        Level(
            id: 2,
            name: "Intermediate",
            description: "Match 4 candies to clear the board",
            initialBoard: [
                .ball, .ball, .drop, .drop,
                .sausage, .sausage, .star, .star,
                .ball, .ball, .drop, .drop,
                .sausage, .sausage, .star, .star
            ],
            requiredMatches: 4
        ),
        Level(
            id: 3,
            name: "Advanced",
            description: "Match 5 candies to clear the board",
            initialBoard: [
                .ball, .ball, .star, .drop,
                .drop, .drop, .sausage, .sausage,
                .sausage, .ball, .star, .star,
                .ball, .drop, .sausage, .star
            ],
            requiredMatches: 4
        )
    ]
}

struct Player {
    var name: String
    var moves: [Int] = []
    var matches: Int = 0
    
    var isWinner: Bool {
        matches >= 3 // We'll update this based on the level's required matches
    }
}

enum Moves {
    static var all = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]

    static var winningMoves = [
        // Horizontal rows (3 consecutive in each row)
        [1, 2, 3], [2, 3, 4],
        [5, 6, 7], [6, 7, 8],
        [9, 10, 11], [10, 11, 12],
        [13, 14, 15], [14, 15, 16],
        
        // Vertical columns (3 consecutive in each column)
        [1, 5, 9], [5, 9, 13],
        [2, 6, 10], [6, 10, 14],
        [3, 7, 11], [7, 11, 15],
        [4, 8, 12], [8, 12, 16],
        
        // Diagonals (3 consecutive in each diagonal)
        [1, 6, 11], [6, 11, 16],
        [4, 7, 10], [7, 10, 13]
    ]
}

