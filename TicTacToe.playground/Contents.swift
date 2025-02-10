class Player{
    var isActive: Bool = true
    private var symbol: String
    
    init(isActive: Bool, symbol: String) {
        self.isActive = isActive
        self.symbol = symbol
    }
    
    func getSymbol() -> String {
        return self.symbol
    }
    
    func getMove()->(Int,Int){
        while true{
            print("Enter row: ")
            guard let row = readLine(), let rowInt = Int(row) else { continue }
            print("Enter column: ")
            guard let col = readLine(), let colInt = Int(col) else { continue }
            return (rowInt, colInt)
        }
    }
    
    
}

class Board{
    private let rows = 3
    private let cols = 3
    private var grid: [[String]]
    
    init() {
        self.grid = Array(repeating: Array(repeating: "-", count: cols), count: rows)
    }
    
    func makeMove(row: Int, col: Int, player: Player){
        if grid[row][col] == "-"{
            grid[row][col] = player.getSymbol()
            player.isActive = false
        }
        else{
            print("Invalid Move. Please try again.")
        }
    }
    
    func printBoard() {
        for row in grid {
            print(row.joined(separator: " | "))
        }
        print("\n")
    }
    
}

class Game{
    private var board: Board
    private var player: [Player]
    
    init(board: Board, player: [Player]) {
        self.board = board
        self.player = player
    }
    
    func gameWon(player: Player)->Bool{
        return true
    }
    
    func gameStart()->Void{
        var winner = false
        var currentPlayer: Player = player[0]
        
        while(!winner){
            currentPlayer = player[0].isActive ? player[0] : player[1]
            if currentPlayer === player[0]{
                print("Player 1 turn!")
            }
            else{
                print("Player 2 turn!")
            }
            
            currentPlayer.getMove()
        }
    }
    
}


let boardGame = Board()
let player1 = Player(isActive: true, symbol: "X")
let player2 = Player(isActive: false, symbol: "O")

let game = Game(board: boardGame, player: [player1, player2])

boardGame.printBoard()
