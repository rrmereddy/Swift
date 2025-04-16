//
//  DrawingCanvasView.swift
//  Journal-2
//
//  Created by Ritin Mereddy on 4/15/25.
//

import SwiftUI

struct DrawingCanvasView: View {
    @State private var lines = [Line]()
    @State private var currentLine: Line?
    @State private var selectedColor: Color = .black
    @State private var lineWidth: CGFloat = 3.0
    
    var body: some View {
        VStack {
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
            
            // Controls
            HStack {
                Button("Clear") {
                    lines = []
                    currentLine = nil
                }
                .padding()
                
                Spacer()
                
                ColorPicker("", selection: $selectedColor)
                    .labelsHidden()
                    .padding()
                
                Slider(value: $lineWidth, in: 1...10)
                    .frame(width: 100)
                    .padding()
            }
        }
        .navigationTitle("Drawing Canvas")
    }
}

#Preview{
    DrawingCanvasView()
}
