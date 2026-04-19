//
//  Presenter.swift
//  CoreMLExamples
//
//  Created by Mamunul Mazid on 16/7/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import Foundation
import UIKit

protocol Intelligence {
    var modelOptions: [ModelOption] { get set }
    func process(image: UIImage, with option: ModelOption) async throws -> IntelligenceOutput
}

struct ModelOption: Hashable {
    var id = UUID()
    var modelFileName: String
    var modelOptionParameter: String? = nil
}

struct IntelligenceOutput {
    var image: UIImage?
    var confidence: Float
    var executionTime: Float
    var title: String
    var modelSize: Float
    var imageSize: CGSize
}

struct Intelligent: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Intelligent, rhs: Intelligent) -> Bool {
        lhs.id == rhs.id
    }

    var id = UUID()
    var name: String
    var intelligence: Intelligence
}

class MainPresenter: ObservableObject {
    @Published var intelligentArray = [Intelligent]()
    @Published var output: IntelligenceOutput
    @Published var uiImage: UIImage?
    @Published var isLoading = false
    @Published var modelOptions = [ModelOption]()

    private let segmenter = Segmenter()
    private let objectDetector = ObjectDetector()
    private let depthMapper = DepthMapGenerator()
    private let classifier = ImageClassifier()
    @Published var selectedIntelligent: Intelligent?
    @Published var selectedModel: ModelOption?

    init() {
        output =
            IntelligenceOutput(
                image: nil,
                confidence: 0,
                executionTime: 0,
                title: "",
                modelSize: 0,
                imageSize: CGSize(width: 0, height: 0)
            )

        let intelligent2 = Intelligent(name: "Segmentation", intelligence: segmenter)
        intelligentArray.append(intelligent2)

        let intelligent3 = Intelligent(name: "Object Detection", intelligence: objectDetector)
        intelligentArray.append(intelligent3)

        let intelligent4 = Intelligent(name: "Depth Mapping", intelligence: depthMapper)
        intelligentArray.append(intelligent4)

        let intelligent5 = Intelligent(name: "Image Classification", intelligence: classifier)
        intelligentArray.append(intelligent5)

        selectedIntelligent = intelligentArray.first
        selectedModel = selectedIntelligent?.intelligence.modelOptions.first
        modelOptions = selectedIntelligent?.intelligence.modelOptions ?? []
    }

    func update(image: UIImage) {
        uiImage = image
        do {
            try executeOperation()
        } catch {
            print(error)
        }
    }

    func onIntelligenceSelection() {
        modelOptions = selectedIntelligent?.intelligence.modelOptions ?? []
        selectedModel = modelOptions.first

        do {
            try executeOperation()
        } catch {
            print(error)
        }
    }

    func onModelSelection() {
        do {
            try executeOperation()
        } catch {
            print(error)
        }
    }

    private func executeOperation() throws {
        guard let uiImage = uiImage else { return }
        let startTime = CACurrentMediaTime()
        Task { @MainActor in
            self.isLoading = true
        }

        guard let selectedModel = selectedModel else { return }
        Task {
            do {
                let output = try await selectedIntelligent?.intelligence.process(image: uiImage, with: selectedModel)
                let endTime = CACurrentMediaTime()
                let interval = (endTime - startTime) * 1000

                Task { @MainActor in
                    self.output = output!
                    self.output.executionTime = Float(interval)
                    self.isLoading = false
                }
            } catch {
                print(error)
                Task { @MainActor in
                    self.isLoading = false
                }
            }
        }
    }

    private static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 200, height: 200)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
