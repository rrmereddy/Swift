//
//  ContentView.swift
//  Journal-2
//
//  Created by Ritin Mereddy on 4/15/25.
//

//
//  ContentView.swift
//  Journal-2
//
//  Created by Ritin Mereddy on 4/15/25.
//

import SwiftUI
import CoreML
import Vision
#if canImport(UIKit)
import UIKit
#endif

struct DigitPrediction {
    let digit: Int
    let confidence: Float
}

#if canImport(UIKit)
struct UIKitCanvasViewRepresentable: UIViewRepresentable {
    @Binding var canvasView: CanvasView?
    
    func makeUIView(context: Context) -> CanvasView {
        let view = CanvasView(frame: .zero)
        view.backgroundColor = .black
        DispatchQueue.main.async {
            self.canvasView = view
        }
        return view
    }
    
    func updateUIView(_ uiView: CanvasView, context: Context) {
        // No-op
    }
}
#endif

struct DrawingGameView: View {
    @State private var targetNumber: [Int] = []
    @State private var currentDigitIndex = 0
    @State private var lines = [Line]()
    @State private var currentLine: Line?
    @State private var selectedColor: Color = .black
    @State private var lineWidth: CGFloat = 10.0
    @State private var predictions: [DigitPrediction] = []
    @State private var showSuccess = false
    @State private var gameCompleted = false
    
    // Model related
    let model: VNCoreMLModel
    
    #if canImport(UIKit)
    @State private var canvasView: CanvasView? = nil
    #endif
    
    init() {
        // Load the MNIST model
        do {
            let modelConfig = MLModelConfiguration()
            let mnistModel = try MNISTClassifier(configuration: modelConfig)
            self.model = try VNCoreMLModel(for: mnistModel.model)
        } catch {
            fatalError("Failed to load MNIST model: \(error)")
        }
        
        // Generate random 3-digit number when initialized
        _targetNumber = State(initialValue: [
            Int.random(in: 0...9),
            Int.random(in: 0...9),
            Int.random(in: 0...9)
        ])
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Game status
            HStack {
                Text("Draw: ")
                    .font(.title)
                
                ForEach(0..<targetNumber.count, id: \.self) { index in
                    Text("\(targetNumber[index])")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(index == currentDigitIndex ? .blue : (index < currentDigitIndex ? .green : .black))
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(index == currentDigitIndex ? Color.blue.opacity(0.2) : (index < currentDigitIndex ? Color.green.opacity(0.2) : Color.gray.opacity(0.1)))
                        )
                }
            }
            .padding()
            
            Text("Current digit to draw: \(targetNumber[currentDigitIndex])")
                .font(.headline)
            
            // Drawing canvas
            #if canImport(UIKit)
            UIKitCanvasViewRepresentable(canvasView: $canvasView)
                .frame(width: 300, height: 300)
                .background(Color.black)
                .border(Color.gray)
            #else
            Canvas { context, size in
                // Draw completed lines
                for line in lines {
                    var path = Path()
                    if let firstPoint = line.points.first {
                        path.move(to: firstPoint)
                        for point in line.points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    
                    context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                }
                
                // Draw current line being drawn
                if let currentLine = currentLine, !currentLine.points.isEmpty {
                    var path = Path()
                    path.move(to: currentLine.points[0])
                    for point in currentLine.points.dropFirst() {
                        path.addLine(to: point)
                    }
                    
                    context.stroke(path, with: .color(currentLine.color), lineWidth: currentLine.lineWidth)
                }
            }
            .background(Color.white)
            .border(Color.gray)
            .frame(height: 300)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let location = value.location
                        
                        if currentLine == nil {
                            // Start a new line
                            currentLine = Line(
                                points: [location],
                                color: selectedColor,
                                lineWidth: lineWidth
                            )
                        } else {
                            // Add point to the existing line
                            currentLine?.points.append(location)
                        }
                    }
                    .onEnded { _ in
                        if let line = currentLine, !line.points.isEmpty {
                            lines.append(line)
                            currentLine = nil
                        }
                    }
            )
            #endif
            
            // Predictions display
            if !predictions.isEmpty {
                HStack {
                    Text("Prediction: ")
                        .font(.headline)
                    
                    if let bestPrediction = predictions.first {
                        Text("\(bestPrediction.digit)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(bestPrediction.digit == targetNumber[currentDigitIndex] ? .green : .red)
                        
                        Text("(\(Int(bestPrediction.confidence * 100))%)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }
            
            // Controls
            HStack {
                Button("Clear") {
                    #if canImport(UIKit)
                    canvasView?.clearCanvas()
                    #else
                    lines = []
                    currentLine = nil
                    predictions = []
                    #endif
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Check") {
                    recognizeDrawing()
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
                
                Button("New Game") {
                    startNewGame()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .navigationTitle("MNIST Drawing Game")
        .padding()
        .alert("Correct!", isPresented: $showSuccess) {
            Button("Continue") {
                moveToNextDigit()
            }
        } message: {
            Text("Great job! You drew \(targetNumber[currentDigitIndex]) correctly.")
        }
        .alert("Game Completed!", isPresented: $gameCompleted) {
            Button("New Game") {
                startNewGame()
            }
        } message: {
            Text("Congratulations! You successfully drew \(targetNumber.map { String($0) }.joined()).")
        }
    }
    
    #if canImport(UIKit)
    private func getCanvasImage() -> UIImage? {
        guard let canvas = canvasView else { return nil }
        return UIImage(view: canvas)
    }
    #endif
    
    private func recognizeDrawing() {
        #if canImport(UIKit)
        guard let image = getCanvasImage(), let cgImage = image.cgImage else {
            print("Failed to get image from canvas")
            return
        }
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                print("Vision ML request error: \(error)")
                return
            }
            guard let results = request.results as? [VNClassificationObservation] else {
                print("Unexpected result type from VNCoreMLRequest")
                return
            }
            self.predictions = results.prefix(3).map { observation in
                if let digit = Int(observation.identifier) {
                    return DigitPrediction(digit: digit, confidence: observation.confidence)
                } else {
                    return DigitPrediction(digit: -1, confidence: observation.confidence)
                }
            }.sorted { $0.confidence > $1.confidence }
            if let bestPrediction = self.predictions.first, bestPrediction.digit == self.targetNumber[self.currentDigitIndex] {
                self.showSuccess = true
            }
        }
        do {
            try imageRequestHandler.perform([request])
        } catch {
            print("Failed to perform image recognition: \(error)")
        }
        #else
        // Fallback for non-iOS
        guard !lines.isEmpty else { return }
        // ... existing code for SwiftUI Canvas ...
        #endif
    }
    
    private func moveToNextDigit() {
        if currentDigitIndex < targetNumber.count - 1 {
            currentDigitIndex += 1
            lines = []
            predictions = []
        } else {
            // All digits completed
            gameCompleted = true
        }
    }
    
    private func startNewGame() {
        targetNumber = [
            Int.random(in: 0...9),
            Int.random(in: 0...9),
            Int.random(in: 0...9)
        ]
        currentDigitIndex = 0
        lines = []
        predictions = []
        gameCompleted = false
        showSuccess = false
    }
}

struct Line: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            DrawingGameView()
        }
    }
}

#Preview {
    ContentView()
}
