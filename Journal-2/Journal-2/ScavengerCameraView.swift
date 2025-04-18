//
//  ScavengerCameraView.swift
//  Doodle‑Gate Scavenger
//
//  Step 2: live‑vision "reality check" using YOLOv3‑Tiny
//  Created 17 Apr 2025
//

import SwiftUI
import AVFoundation
import Vision
import CoreML
#if canImport(UIKit)
import UIKit
#endif

// MARK: – Main View
struct ScavengerCameraView: View {
    @StateObject private var vm = ScavengerCameraViewModel()
    @State private var showVerificationAlert = false
    @State private var showDetectedObjects = false
    @State private var showCongratulationsView = false
    @Binding var showCameraView: Bool
    @Binding var resetDrawing: Bool
    
    var body: some View {
        ZStack {
            #if canImport(UIKit)
            CameraPreview(session: vm.session)
                .edgesIgnoringSafeArea(.all)
            #else
            Text("Camera preview not available on this platform")
                .foregroundColor(.red)
            #endif
            
            if showCongratulationsView {
                CongratulationsView(onContinue: {
                    showCongratulationsView = false
                    vm.nextChallenge()
                })
            } else {
                VStack(spacing: 16) {
                    // Challenge instruction
                    HStack {
                        Image(systemName: "camera.viewfinder")
                            .font(.title3)
                        
                        Text("Show me a \(vm.target.capitalized)!")
                            .font(.title2.bold())
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Detection summary
                    if vm.detectedObjects.isEmpty {
                        Text("Looking for objects...")
                            .font(.subheadline)
                            .padding(8)
                            .background(.ultraThinMaterial.opacity(0.7))
                            .clipShape(Capsule())
                    } else {
                        // Simplified top detection indicator
                        if let topObject = vm.detectedObjects.first {
                            HStack(spacing: 8) {
                                Text("I see: \(topObject.label.capitalized)")
                                    .font(.headline)
                                
                                Text("\(Int(topObject.confidence * 100))%")
                                    .font(.subheadline.bold())
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(topObject.label == vm.target ? Color.green : Color.orange)
                                    )
                                    .foregroundColor(.white)
                            }
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            // Toggle for detailed detections
                            Button {
                                withAnimation {
                                    showDetectedObjects.toggle()
                                }
                            } label: {
                                Label(
                                    showDetectedObjects ? "Hide All Detections" : "Show All Detections",
                                    systemImage: showDetectedObjects ? "eye.slash" : "eye"
                                )
                                .font(.caption)
                                .padding(8)
                                .background(.regularMaterial)
                                .clipShape(Capsule())
                            }
                        }
                    }
                    
                    // Detailed detections (expandable)
                    if showDetectedObjects && !vm.detectedObjects.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(vm.detectedObjects, id: \.label) { object in
                                    HStack {
                                        Image(systemName: object.label == vm.target ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(object.label == vm.target ? .green : .gray)
                                        
                                        Text(object.label.capitalized)
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        // Confidence bar
                                        ZStack(alignment: .leading) {
                                            Rectangle()
                                                .frame(width: 100, height: 8)
                                                .opacity(0.2)
                                                .foregroundColor(.gray)
                                            
                                            Rectangle()
                                                .frame(width: 100 * CGFloat(object.confidence), height: 8)
                                                .foregroundColor(object.label == vm.target ? .green : .blue)
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                        
                                        Text("\(Int(object.confidence * 100))%")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(object.label == vm.target ? Color.green.opacity(0.15) : Color.gray.opacity(0.05))
                                    )
                                }
                            }
                            .padding()
                        }
                        .frame(maxHeight: 180)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    Spacer()
                    
                    if vm.passed {
                        Label("Verified!", systemImage: "checkmark.seal.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                            .padding(.bottom, 40)
                            .onAppear {
                                // Show congratulations screen instead of alert
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    withAnimation {
                                        showCongratulationsView = true
                                    }
                                }
                            }
                    } else if vm.timeRemaining > 0 {
                        Text("⏱ \(Int(vm.timeRemaining)) s left")
                            .font(.headline)
                            .padding(8)
                            .background(.regularMaterial)
                            .clipShape(Capsule())
                    } else {
                        Button("Try a different object") { vm.nextChallenge() }
                            .buttonStyle(.borderedProminent)
                            .padding(.bottom, 40)
                    }
                }
                .padding()
            }
        }
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
        .alert("Camera Not Available", isPresented: $vm.showCameraError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This device doesn't have a camera or camera access is restricted.")
        }
    }
}

// MARK: - Congratulations View
struct CongratulationsView: View {
    let onContinue: () -> Void
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            // Confetti
            if showConfetti {
                ConfettiView()
            }
            
            // Content
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "person.fill.checkmark")
                    .font(.system(size: 72))
                    .foregroundColor(.green)
                    .padding()
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 150, height: 150)
                    )
                
                Text("Human Verified!")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Text("Congratulations! You've successfully completed the human verification challenge.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    onContinue()
                } label: {
                    Text("Start New Game")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 48)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.green)
                        )
                }
                .padding(.bottom, 50)
            }
            .padding()
            .onAppear {
                withAnimation(.easeIn(duration: 0.5)) {
                    showConfetti = true
                }
            }
        }
        .transition(.opacity)
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    let colors: [Color] = [.red, .green, .blue, .yellow, .purple, .orange]
    let count = 100
    
    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                ConfettiPiece(color: colors[i % colors.count])
            }
        }
    }
    
    struct ConfettiPiece: View {
        let color: Color
        @State private var xPosition: CGFloat
        @State private var yPosition: CGFloat
        @State private var rotation: Double
        
        init(color: Color) {
            self.color = color
            _xPosition = State(initialValue: CGFloat.random(in: 0...UIScreen.main.bounds.width))
            _yPosition = State(initialValue: CGFloat.random(in: -100...0))
            _rotation = State(initialValue: Double.random(in: 0...360))
        }
        
        var body: some View {
            Rectangle()
                .fill(color)
                .frame(width: 8, height: 8)
                .position(x: xPosition, y: yPosition)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.linear(duration: Double.random(in: 2...4))) {
                        yPosition = UIScreen.main.bounds.height + 100
                        rotation += Double.random(in: 180...360)
                    }
                }
        }
    }
}

// MARK: – Live Preview
#Preview {
    ScavengerCameraView(showCameraView: .constant(true), resetDrawing: .constant(false))
}

// MARK: – View‑Model
@MainActor
final class ScavengerCameraViewModel: NSObject, ObservableObject {
    // Public state
    @Published var passed = false
    @Published var target = "coffee mug"
    @Published var timeRemaining: Double = 15
    @Published var showCameraError = false
    @Published var detectedObjects: [(label: String, confidence: Float)] = []

    // Common household items that can be detected by YOLOv3-Tiny
    private let householdItems = [
        "backpack", "handbag", "suitcase", "bottle", "wine glass", "cup", "fork", "knife",
        "spoon", "bowl", "banana", "apple", "sandwich", "orange", "broccoli", "carrot",
        "hot dog", "pizza", "donut", "cake", "chair", "couch", "potted plant", "bed",
        "dining table", "toilet", "tv", "laptop", "mouse", "remote", "keyboard", "cell phone",
        "microwave", "oven", "toaster", "sink", "refrigerator", "book", "clock", "vase",
        "scissors", "teddy bear", "hair drier", "toothbrush"
    ]
    
    private var usedTargets: Set<String> = []

    // Camera session
    nonisolated let session = AVCaptureSession()
    var model: VNCoreMLModel!
    nonisolated(unsafe) var req: VNCoreMLRequest!

    // Private
    private let captureQ = DispatchQueue(label: "yolo.capture")
    private var timer: Timer?

    // Init
    override init() {
        super.init()
        configureModel()
        configureCamera()
        pickRandomTarget()
    }

    // MARK: – Control
    func start() {
        if !session.isRunning {
            captureQ.async { [weak self] in
                self?.session.startRunning()
                Task { @MainActor [weak self] in
                    self?.restartTimer()
                }
            }
        }
    }

    func stop() {
        if session.isRunning {
            captureQ.async { [weak self] in
                self?.session.stopRunning()
            }
        }
        timer?.invalidate()
    }

    func nextChallenge() {
        passed = false
        pickRandomTarget()
        restartTimer()
    }

    // MARK: – Setup
    private func configureModel() {
        do {
            let config = MLModelConfiguration()
            let mlModel = try YOLOv3Tiny(configuration: config)
            self.model = try VNCoreMLModel(for: mlModel.model)
            
            req = VNCoreMLRequest(model: self.model) { [weak self] request, _ in
                guard let self, !self.passed else { return }
                self.handleDetections(request)
            }
            req.imageCropAndScaleOption = .scaleFill
        } catch {
            fatalError("YOLOv3Tiny.mlmodel not found: \(error)")
        }
    }

    private func configureCamera() {
        guard !session.isRunning else { return }
        
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        
        session.sessionPreset = .vga640x480

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input  = try? AVCaptureDeviceInput(device: device)
        else {
            showCameraError = true
            return
        }

        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: captureQ)
        output.alwaysDiscardsLateVideoFrames = true
        session.addOutput(output)
    }

    // MARK: – Helpers
    private func pickRandomTarget() {
        // If we've used all targets, reset the used targets
        if usedTargets.count >= householdItems.count {
            usedTargets.removeAll()
        }
        
        // Get available targets (not yet used)
        let availableTargets = householdItems.filter { !usedTargets.contains($0) }
        
        // Pick a random target from available ones
        if let newTarget = availableTargets.randomElement() {
            target = newTarget
            usedTargets.insert(newTarget)
        } else {
            // Fallback if something goes wrong
            target = "coffee mug"
        }
    }

    private func restartTimer() {
        timeRemaining = 15
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if self.passed { t.invalidate() }
                else if self.timeRemaining > 0 { self.timeRemaining -= 1 }
                else { t.invalidate() }
            }
        }
    }

    private func handleDetections(_ request: VNRequest) {
        guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
        
        // Update detected objects with their confidence levels
        detectedObjects = results.compactMap { observation in
            guard let top = observation.labels.first else { return nil }
            return (label: top.identifier, confidence: top.confidence)
        }.sorted { $0.confidence > $1.confidence }
        
        // Check if target is detected with high confidence
        if results.contains(where: { obs in
            guard let top = obs.labels.first else { return false }
            return top.identifier == target && top.confidence >= 0.90
        }) {
            DispatchQueue.main.async { self.passed = true }
        }
    }

    // MARK: – Labels helper (reads classes.txt bundled with the model)
    enum YOLOv3TinyLabels {
        static let all: [String] = {
            guard
                let url = Bundle.main.url(forResource: "classes", withExtension: "txt"),
                let txt = try? String(contentsOf: url, encoding: .utf8)
            else { return ["coffee mug"] }
            return txt.components(separatedBy: .newlines).filter { !$0.isEmpty }
        }()
    }
}

#if canImport(UIKit)
// MARK: – Camera Preview Layer
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = UIScreen.main.bounds
        view.layer.addSublayer(layer)
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) { }
}
#endif

// MARK: – Delegate
extension ScavengerCameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixel = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            let handler = VNImageRequestHandler(cvPixelBuffer: pixel,
                                                orientation: .right,
                                                options: [:])
            try? handler.perform([self.req])
        }
    }
}
