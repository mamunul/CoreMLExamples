//
//  MobileNetImplementor.swift
//  CoreMLExamples
//
//  Created by Mamunul Mazid on 16/7/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import CoreML
import Foundation
import SwiftUI
import UIKit
import Vision

class ImageClassifier: Intelligence {
    private let imageSize = CGSize(width: 224, height: 224)
    var modelOptions = [ModelOption]()

    enum Options: String, CaseIterable {
        case Resnet50, Resnet50FP16, Resnet50Int8LUT
        case MobileNetV2
        case FastViTMA36F16, FastViTT8F16
    }

    enum ObjectClassifierError: Error {
        case fileNotFound
        case modelInit
    }

    init() {
        for option in Options.allCases {
            let modelOption1 = ModelOption(modelFileName: option.rawValue)
            modelOptions.append(modelOption1)
        }
    }

    func process(image: UIImage, with option: ModelOption) async throws -> IntelligenceOutput {
        try await withCheckedThrowingContinuation { continuation in

            do {
                try runVision(image: image, option: option) { output in
                    let result =
                        IntelligenceOutput(
                            image: nil,
                            confidence: output.confidence,
                            executionTime: -0,
                            title: output.identifier,
                            modelSize: 0,
                            imageSize: self.imageSize
                        )
                    continuation.resume(returning: result)
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func runVision(image: UIImage, option: ModelOption, onCompletion: @escaping (ObjectBox) -> Void) throws {
        let nimage = image.resized(to: imageSize)

        guard let modelURL = Bundle.main.url(forResource: option.modelFileName, withExtension: "mlmodelc") else {
            throw ObjectClassifierError.fileNotFound
        }
        let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))

        let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { request, _ in
            if let results = request.results {
                if !results.isEmpty, let object = (results[0] as? VNClassificationObservation) {
                    let objectBox =
                        ObjectBox(
                            identifier: object.identifier,
                            confidence: object.confidence,
                            bound: CGRect(x: 0, y: 0, width: 0, height: 0)
                        )
                    print(objectBox)
                    onCompletion(objectBox)
                }
            }
        })

        let imageRequestHandler = VNImageRequestHandler(cgImage: nimage.cgImage!, options: [:])
        try imageRequestHandler.perform([objectRecognition])
    }
}
