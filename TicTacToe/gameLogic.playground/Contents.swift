import UIKit

var all = [1, 2, 3, 4, 5, 6, 7, 8, 9]

var winningMoves = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
    [1, 4, 7],
    [2, 5, 8],
    [3, 6, 9],
    [1, 5, 9],
    [3, 5, 7]
]

@MainActor
func checkWinner(_ moves: [Int]) -> Bool {
    for move in winningMoves {
        if moves.allSatisfy(moves.contains){
            return true
        }
    }
    
    
    return false
}

print(checkWinner([1, 7, 9, 8]))
