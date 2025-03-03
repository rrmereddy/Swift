func Board() -> String {
    // Crate a board
    return "Board"
}

var validQueenPlace: [[Int]]
var board = Board()


func placeQueen(_ board: String, _ row: Int, _ col: Int, _ validQueenPlace: [[Int]]) -> String {
    
    // go ahead and place a queen
    if checkQueenSafe(board, row, col, validQueenPlace){
        validQueenPlace[Int] = [row, col]
    }
    else{
        // move onto the next spot
        placeQueen(board, row + 1, col, validQueenPlace)
    }
    
    return "Board"
}

func checkQueenSafe(_ board: String, _ row: Int, _ col: Int, _ validQueenPlace: [[Int]]) -> Bool {
    //checks whether the queen can be placed
    
    for int in validQueenPlace{
        // two queen can't be placed in the same column or row
        if int[1] == col ||  int[0] == row{
            return false
        }
        // queen can't be placed in the same diagonal
        if abs(int[0] - row) == abs(int[1] - col){
            return false
        }
    }
    
    return true
}
