//
//  GameService.swift
//  CandyCrush
//
//  Created by Ritin Mereddy on 3/27/25.
//

import SwiftUI

@MainActor
class GameService: ObservableObject {
    @Published var player = Player(name: "Player")
    @Published var gameOver = false
    @Published var gameBoard = GameSquare.reset
    @Published var selectedSquare: Int?
    @Published var currentLevel: Level?
    @Published var hasLost = false

    var boardDisabled: Bool {
        gameOver || hasLost
    }

    func setupGame(playerName: String, level: Level) {
        player.name = playerName
        currentLevel = level
        reset()
    }

    func reset() {
        player.moves.removeAll()
        player.matches = 0
        gameOver = false
        hasLost = false
        gameBoard = GameSquare.reset
        selectedSquare = nil

        // Set up the board according to the current level
        if let level = currentLevel {
            for (index, candyType) in level.initialBoard.enumerated() {
                gameBoard[index].candyType = candyType
            }
        }
    }

    func selectSquare(at index: Int) {
        if selectedSquare == nil {
            selectedSquare = index
        } else {
            // Try to swap candies
            if let fromIndex = selectedSquare {
                swapCandies(from: fromIndex, to: index)
                selectedSquare = nil
            }
        }
    }

    func swapCandies(from: Int, to: Int) {
        // Only allow swapping adjacent squares
        let isAdjacent = isAdjacent(from: from, to: to)
        
        if isAdjacent {
            // Swap the candies
            let tempCandy = gameBoard[from].candyType
            gameBoard[from].candyType = gameBoard[to].candyType
            gameBoard[to].candyType = tempCandy

            // Check for matches after swap
            checkForMatches()
            
            // Check game state
            checkGameState()
        }
    }

    private func isAdjacent(from: Int, to: Int) -> Bool {
        let fromRow = from / 4
        let fromCol = from % 4
        let toRow = to / 4
        let toCol = to % 4

        // Check if squares are adjacent horizontally or vertically
        return (abs(fromRow - toRow) == 1 && fromCol == toCol) ||
               (abs(fromCol - toCol) == 1 && fromRow == toRow)
    }

    // MARK: - Match Checking

    private func checkForMatches() {
    var matchesFound = false
    var matchCount = 0

    // Check horizontal matches (grid is assumed 4 columns)
    // Valid starting columns for a 3-match are 0 and 1.
    for row in 0..<4 {
        for col in 0..<2 {
            let index = row * 4 + col
            if let candyType = gameBoard[index].candyType {
                let nextIndex = index + 1
                let nextNextIndex = index + 2
                
                // Check for a basic 3-match first.
                if gameBoard[nextIndex].candyType == candyType &&
                   gameBoard[nextNextIndex].candyType == candyType {
                    
                    // For column 0, try for a 4-match.
                    if col == 0 {
                        let nextNextNextIndex = index + 3
                        if gameBoard[nextNextNextIndex].candyType == candyType {
                            // Remove 4 candies
                            gameBoard[index].candyType = nil
                            gameBoard[nextIndex].candyType = nil
                            gameBoard[nextNextIndex].candyType = nil
                            gameBoard[nextNextNextIndex].candyType = nil
                            print("Horizontal 4-match indices: \(index), \(nextIndex), \(nextNextIndex), \(nextNextNextIndex)")
                            matchCount += 1
                            matchesFound = true
                            continue  // Skip the 3-match removal since 4-match took priority.
                        }
                    }
                    // If no 4-match found (or not in column 0), remove 3 candies.
                    gameBoard[index].candyType = nil
                    gameBoard[nextIndex].candyType = nil
                    gameBoard[nextNextIndex].candyType = nil
                    print("Horizontal 3-match indices: \(index), \(nextIndex), \(nextNextIndex)")
                    //matchCount += 1
                    matchesFound = true
                }
            }
        }
    }
    
    // Check vertical matches (grid is assumed 4 rows)
    // Valid starting rows for a 3-match are 0 and 1.
    for row in 0..<2 {
        for col in 0..<4 {
            let index = row * 4 + col
            if let candyType = gameBoard[index].candyType {
                let nextIndex = index + 4
                let nextNextIndex = index + 8
                
                // Check for a basic 3-match vertically.
                if gameBoard[nextIndex].candyType == candyType &&
                   gameBoard[nextNextIndex].candyType == candyType {
                    
                    // For row 0, try for a 4-match.
                    if row == 0 {
                        let nextNextNextIndex = index + 12
                        if gameBoard[nextNextNextIndex].candyType == candyType {
                            // Remove 4 candies
                            gameBoard[index].candyType = nil
                            gameBoard[nextIndex].candyType = nil
                            gameBoard[nextNextIndex].candyType = nil
                            gameBoard[nextNextNextIndex].candyType = nil
                            print("Vertical 4-match indices: \(index), \(nextIndex), \(nextNextIndex), \(nextNextNextIndex)")
                            matchCount += 1
                            matchesFound = true
                            continue  // Skip the 3-match removal.
                        }
                    }
                    // If no 4-match found (or not in row 0), remove 3 candies.
                    gameBoard[index].candyType = nil
                    gameBoard[nextIndex].candyType = nil
                    gameBoard[nextNextIndex].candyType = nil
                    print("Vertical 3-match indices: \(index), \(nextIndex), \(nextNextIndex)")
                    //matchCount += 1
                    matchesFound = true
                }
            }
        }
    }
    
    // Update player's match count if any matches were found
    if matchesFound {
        player.matches += matchCount
        
        // Check if player has won based on required matches
        if let level = currentLevel, player.matches >= level.requiredMatches {
                gameOver = true
            }
        }
    }

    // MARK: - Losing Logic

    private func checkIfGameIsLost() {
        guard let level = currentLevel else { return }

        // If we've already met or exceeded the required matches, we can't lose now
        let remainingMatchesNeeded = level.requiredMatches - player.matches
        if remainingMatchesNeeded <= 0 { return }

        // Check if any possible swap can produce a match
        if canMakeAMove() {
            return
        }

        // If we reach here, we still need matches, but no swap can make a new match
        hasLost = true
    }

    /// Returns true if there's at least one swap that would produce a 3-in-a-row.
    private func canMakeAMove() -> Bool {
        var candyCounts: [CandyType: Int] = [:]
        
        // Count candies
        for square in gameBoard {
            if let candyType = square.candyType {
                candyCounts[candyType, default: 0] += 1
            }
        }
        
        // Check if we have at least 4 of each candy type that's present
        for (_, count) in candyCounts {
            if count < 4 {
                return false // Not enough candies of this type to win
            }
        }

        return true
    }

    /// Returns valid adjacent indices of a given square on our 4x4 board (up, down, left, right).
    private func adjacentIndices(of index: Int) -> [Int] {
        var result = [Int]()
        let row = index / 4
        let col = index % 4

        // Up
        if row > 0 {
            result.append(index - 4)
        }
        // Down
        if row < 3 {
            result.append(index + 4)
        }
        // Left
        if col > 0 {
            result.append(index - 1)
        }
        // Right
        if col < 3 {
            result.append(index + 1)
        }

        return result
    }

    private func checkGameState() {
        guard let level = currentLevel else { return }
        
        // Count remaining candies
        let remainingCandies = gameBoard.filter { $0.candyType != nil }.count
        
        // Win condition: No candies left AND enough matches made
        if remainingCandies == 0 && player.matches >= level.requiredMatches {
            gameOver = true
            return
        }
        
        // Loss condition: Still need matches but can't clear all candies
        let remainingMatchesNeeded = level.requiredMatches - player.matches
        if remainingMatchesNeeded > 0 && !canClearAllCandies() {
            hasLost = true
        }
    }

    private func canClearAllCandies() -> Bool {
        // If there are no candies left, we can "clear" them
        let remainingCandies = gameBoard.filter { $0.candyType != nil }.count
        if remainingCandies == 0 { return true }
        
        // Check if we can make any moves that would lead to clearing candies
        return canMakeAMove()
    }

    // MARK: - Public move API

    func makeMove(at index: Int) {
        selectSquare(at: index)
    }
}
