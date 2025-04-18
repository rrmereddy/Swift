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
    @Binding var showCameraView: Bool
    @Binding var resetDrawing: Bool
    @State private var targetNumber: [Int] = []
    @State private var currentDigitIndex = 0
    @State private var lines = [Line]()
    @State private var currentLine: Line?
    @State private var selectedColor: Color = .black
    @State private var lineWidth: CGFloat = 10.0
    @State private var predictions: [DigitPrediction] = []
    @State private var correctness: [Bool?] = [nil, nil, nil]
    @State private var feedbackMessage: String = ""
    @State private var gameCompleted = false
    @State private var verificationFailed = false
    
    // Model related
    let model: VNCoreMLModel
    
    // UI Colors
    private let backgroundColor = Color(red: 0.95, green: 0.97, blue: 1.0)
    private let accentColor = Color(red: 0.2, green: 0.5, blue: 0.8)
    private let canvasBackgroundColor = Color.white
    private let secondaryAccentColor = Color(red: 0.3, green: 0.6, blue: 0.9)
    
    #if canImport(UIKit)
    @State private var canvasView: CanvasView? = nil
    #endif
    
    init(showCameraView: Binding<Bool>, resetDrawing: Binding<Bool>) {
        self._showCameraView = showCameraView
        self._resetDrawing = resetDrawing
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
        _correctness = State(initialValue: [nil, nil, nil])
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [backgroundColor, backgroundColor.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                // Header with stylized title
                VStack(spacing: 8) {
                    Text("Human Verification")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(accentColor)
                        .padding(.top, 16)
                    
                    Text("Draw each digit to prove you're human")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 8)
                
                // Game status with animated cards
                HStack(spacing: 12) {
                    Text("Verify:")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    ForEach(0..<targetNumber.count, id: \.self) { index in
                        let color: Color = {
                            if let isCorrect = correctness[index] {
                                return isCorrect ? Color.green : Color.red
                            } else if index == currentDigitIndex {
                                return accentColor
                            } else {
                                return Color.gray.opacity(0.5)
                            }
                        }()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: color.opacity(0.5), radius: 4, x: 0, y: 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(color, lineWidth: 3)
                                )
                            
                            Text("\(targetNumber[index])")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(color)
                        }
                        .frame(width: 60, height: 70)
                        .scaleEffect(index == currentDigitIndex ? 1.1 : 1.0)
                        .animation(.spring(), value: currentDigitIndex)
                    }
                }
                .padding(.horizontal)
                
                // Current step indicator
                Text("Draw the digit: \(targetNumber[currentDigitIndex])")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(accentColor)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 16)
                    .background(
                        Capsule()
                            .fill(accentColor.opacity(0.1))
                    )
                
                // Drawing canvas with decorative frame
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(canvasBackgroundColor)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(accentColor, lineWidth: 3)
                    
                    #if canImport(UIKit)
                    UIKitCanvasViewRepresentable(canvasView: $canvasView)
                        .cornerRadius(16)
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
                }
                .frame(width: 320, height: 320)
                .padding(.vertical, 12)
                
                // Predictions display with animation
                if !predictions.isEmpty {
                    VStack(spacing: 8) {
                        if let bestPrediction = predictions.first {
                            HStack {
                                Text("Detected:")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Text("\(bestPrediction.digit)")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(bestPrediction.digit == targetNumber[currentDigitIndex] ? .green : .red)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill((bestPrediction.digit == targetNumber[currentDigitIndex] ? Color.green : Color.red).opacity(0.15))
                                    )
                                
                                Text("(\(Int(bestPrediction.confidence * 100))%)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        if !feedbackMessage.isEmpty {
                            Text(feedbackMessage)
                                .font(.headline)
                                .foregroundColor(feedbackMessage.contains("Correct") ? .green : .red)
                                .padding(.top, 4)
                                .transition(.scale.combined(with: .opacity))
                                .animation(.spring(), value: feedbackMessage)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Controls with styled buttons
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        Button(action: {
                            #if canImport(UIKit)
                            if let canvas = canvasView {
                                canvas.clearCanvas()
                            }
                            #else
                            lines = []
                            currentLine = nil
                            predictions = []
                            #endif
                        }) {
                            Label("Clear", systemImage: "trash")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .frame(maxWidth: .infinity)
                                .background(
                                    Capsule()
                                        .fill(Color.gray)
                                )
                        }
                        
                        Button(action: { recognizeDrawing() }) {
                            Label("Check", systemImage: "checkmark.circle")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .frame(maxWidth: .infinity)
                                .background(
                                    Capsule()
                                        .fill(accentColor)
                                        .shadow(color: accentColor.opacity(0.4), radius: 4, x: 0, y: 2)
                                )
                        }
                    }
                    
                    Button(action: { startNewGame() }) {
                        Label("New Verification", systemImage: "arrow.clockwise")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(secondaryAccentColor)
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .padding()
        }
        .alert("Verification Complete!", isPresented: $gameCompleted) {
            Button("Continue to Camera") {
                showCameraView = true
            }
        } message: {
            Text("You passed all verification steps! Now let's verify you're not a robot.")
        }
        .alert("Verification failed: You are a bot!", isPresented: $verificationFailed) {
            Button("Try Again") {
                startNewGame()
            }
        } message: {
            Text("Please try again.")
        }
        .onChange(of: resetDrawing) { newValue in
            if newValue {
                startNewGame()
                resetDrawing = false
            }
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
            if let bestPrediction = self.predictions.first {
                let isCorrect = bestPrediction.digit == self.targetNumber[self.currentDigitIndex]
                self.correctness[self.currentDigitIndex] = isCorrect
                self.feedbackMessage = isCorrect ? "Correct!" : "Incorrect."
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    if isCorrect {
                        moveToNextDigit(clearBoard: true)
                    } else {
                        verificationFailed = true
                    }
                }
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
    
    private func moveToNextDigit(clearBoard: Bool = false) {
        if currentDigitIndex < targetNumber.count - 1 {
            currentDigitIndex += 1
            if clearBoard {
                #if canImport(UIKit)
                canvasView?.clearCanvas()
                #endif
                lines = []
                predictions = []
                feedbackMessage = ""
            }
        } else {
            // All steps completed
            if correctness.allSatisfy({ $0 == true }) {
                gameCompleted = true
            }
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
        feedbackMessage = ""
        correctness = [nil, nil, nil]
        verificationFailed = false
        #if canImport(UIKit)
        canvasView?.clearCanvas()
        #endif
    }
}

struct Line: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
}

struct ContentView: View {
    @State private var showCameraView = false
    @State private var resetDrawing = false
    
    var body: some View {
        NavigationView {
            if showCameraView {
                ScavengerCameraView(showCameraView: $showCameraView, resetDrawing: $resetDrawing)
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Back to Drawing") {
                                showCameraView = false
                            }
                        }
                    }
            } else {
                DrawingGameView(showCameraView: $showCameraView, resetDrawing: $resetDrawing)
            }
        }
    }
}

#Preview {
    ContentView()
}
