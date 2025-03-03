//
//  ContentView.swift
//  CarMax
//
//  Created by Ritin Mereddy on 3/3/25.
//

import SwiftUI

struct ContentView: View {
    // state variable to keep track of filters
    @State private var selectedMake: String = "All"
    @State private var selectedModel: String = "All"
    @State private var selectedYear: Int = 0
    
    // function to filter cars
    var filteredCars: [Car] {
        cars.filter { car in
            (selectedMake == "All" || car.make == selectedMake) &&
            (selectedModel == "All" || car.model == selectedModel) &&
            (selectedYear == 0 || car.year == selectedYear)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome To CarMax")
                    .font(.largeTitle)
                    .bold()
                    .padding()

                // Filter Controls
                HStack{
                    Picker("Select Make", selection: $selectedMake) {
                        ForEach(makes, id: \.self) { make in
                            Text(make).tag(make)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    Picker("Select Model", selection: $selectedModel) {
                        ForEach(models, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    Picker("Select Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(year == 0 ? "All" : "\(year)").tag(year)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                // shows the filtered cars
                List(filteredCars) { car in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(car.make) \(car.model)")
                                .font(.headline)
                            Text("\(car.year)")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
