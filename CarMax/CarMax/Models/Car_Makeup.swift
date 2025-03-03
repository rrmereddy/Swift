//
//  Car_Makeup.swift
//  CarMax
//
//  Created by Ritin Mereddy on 3/3/25.
//

import SwiftUI

struct Car: Identifiable{
    var id: UUID = UUID() // not sure what this does, but was necessary to filter cars(copilot code)
    var make: String
    var model: String
    var year: Int
    
}

// Hardcoded set of Cars, can also add to the list
let cars = [
    Car(make: "Toyota", model: "Camry", year: 2022),
    Car(make: "Toyota", model: "Corolla", year: 2021),
    Car(make: "Honda", model: "Civic", year: 2020),
    Car(make: "Honda", model: "Accord", year: 2022),
    Car(make: "Ford", model: "Mustang", year: 2023)
]

// helps with filtering the cars, based on their values
var makes: [String] {
    ["All"] + Set(cars.map { $0.make }).sorted()
}

var models: [String] {
    ["All"] + Set(cars.map { $0.model }).sorted()
}

var years: [Int] {
    [0] + Set(cars.map { $0.year }).sorted()
}
