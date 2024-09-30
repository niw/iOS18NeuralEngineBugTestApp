//
//  MainView.swift
//  NeuralEngineTest
//
//  Created by Yoshimasa Niwa on 9/29/24.
//

import Foundation
import CoreML
import SwiftUI

struct VerticalLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .font(.caption.bold())
                .foregroundStyle(.tertiary)
            configuration.content
        }
    }
}

extension LabeledContentStyle where Self == VerticalLabeledContentStyle {
    static var vertical: Self {
        VerticalLabeledContentStyle()
    }
}

private extension MLMultiArray {
    var sample: NSNumber {
        self[count - 1]
    }
}

struct MainView: View {
    @State
    private var isRunning: Bool = false

    @State
    private var cpuAndGPUOutput: Float?

    @State
    private var cpuAndNeuralEngineOutput: Float?

    private func run() {
        Task {
            guard isRunning == false else {
                return
            }
            isRunning = true
            defer {
                isRunning = false
            }

            let c = 3, w = 320, h = 320
            var scalars = [Float]()
            for _ in 0..<c * w * h {
                scalars.append(Float.random(in: 0.0..<1.0))
            }
            let input = MLMultiArray(MLShapedArray<Float>(scalars: scalars, shape: [1, c, w, h]))

            do {
                cpuAndGPUOutput = nil
                let configuration = MLModelConfiguration()
                configuration.computeUnits = .cpuAndGPU
                let model = try Model(configuration: configuration)
                let output = try model.prediction(input: input)
                cpuAndGPUOutput = output.output.sample.floatValue
            } catch {
                print(error)
            }

            do {
                cpuAndNeuralEngineOutput = nil
                let configuration = MLModelConfiguration()
                configuration.computeUnits = .cpuAndNeuralEngine
                let model = try Model(configuration: configuration)
                let output = try model.prediction(input: input)
                cpuAndNeuralEngineOutput = output.output.sample.floatValue
            } catch {
                print(error)
            }
        }
    }

    var body: some View {
        Form {
            Section {
                if let cpuAndGPUOutput {
                    LabeledContent {
                        Text("\(cpuAndGPUOutput)")
                    } label: {
                        Text("CPU and GPU")
                    }
                }
                if let cpuAndNeuralEngineOutput {
                    LabeledContent {
                        Text("\(cpuAndNeuralEngineOutput)")
                    } label: {
                        Text("CPU and NeuralEngine")
                    }
                }
                if let cpuAndGPUOutput, let cpuAndNeuralEngineOutput {
                    let difference = cpuAndNeuralEngineOutput - cpuAndGPUOutput
                    LabeledContent {
                        Text("\(difference)")
                    } label: {
                        Text("Difference")
                    }
                    .foregroundStyle(abs(difference) > 0.0 ? AnyShapeStyle(.red) : AnyShapeStyle(.primary))
                }
            } header: {
                Text("Results")
            } footer: {
                Text("If you see zero value from CPU and NeuralEngine that causes a large difference, it must be a bug and unexpected behavior.")
            }
            .labeledContentStyle(.vertical)

            Section {
                Button("Run") {
                    run()
                }
                .disabled(isRunning)
            }
        }
        .task {
            run()
        }
    }
}

#Preview {
    MainView()
}
