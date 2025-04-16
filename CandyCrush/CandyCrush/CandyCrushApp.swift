//
//  CandyCrushApp.swift
//  CandyCrush
//
//  Created by Ritin Mereddy on 3/27/25.
//

import SwiftUI

@main
struct CandyCrushApp: App {
    @StateObject var game = GameService() //create an instance of the class
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(game)
        }
    }
}
