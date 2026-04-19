//
//  YoloImplmplementor.swift
//  CoreMLExamples
//
//  Created by Mamunul Mazid on 16/7/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import CoreML
import Foundation
import UIKit
import Vision

struct ObjectBox {
    var identifier: String
    var confidence: Float
    var bound: CGRect
}

class ObjectDetector: Intelligence {
    private let imageSize = CGSize(width: 416, height: 416)
    var modelOptions: [ModelOption] = []

    enum Options: String, CaseIterable {
        case YOLOv3Tiny, YOLOv3TinyFP16, YOLOv3TinyInt8LUT
    }

    enum ObjectDetectorError: Error {
        case imageBuffer
        case predictionError
        case fileNotFound
    }

    init() {
        for option in Options.allCases {
            let modelOption1 = ModelOption(modelFileName: option.rawValue)
            modelOptions.append(modelOption1)
        }
    }

    func process(image: UIImage, with option: ModelOption) async throws -> IntelligenceOutput {
        let nimage = image.resized(to: imageSize)

        let boxArray = try await runModel(image: nimage, option: option)

        let img = UIHelper().createBox(objectBoxArray: boxArray, in: nimage)
        let output = IntelligenceOutput(
            image: img,
            confidence: -0,
            executionTime: -0,
            title: "NA",
            modelSize: 0,
            imageSize: imageSize
        )
        return output
    }

    private func runModel(image: UIImage, option: ModelOption) async throws -> [ObjectBox] {
        guard let modelURL = Bundle.main.url(forResource: option.modelFileName, withExtension: "mlmodelc") else {
            throw ObjectDetectorError.fileNotFound
        }

        let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))

        return try await withCheckedThrowingContinuation { continuation in

            do {
                let request = VNCoreMLRequest(model: visionModel) { request, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let results = request.results else {
                        continuation.resume(returning: [])
                        return
                    }

                    let boxes = VisionHelper.processResult(results, size: image.size)
                    continuation.resume(returning: boxes)
                }

                let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
                try handler.perform([request])

            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

class VisionHelper {
    class func processResult(_ results: [Any], size: CGSize) -> [ObjectBox] {
        var objectBoxArray = [ObjectBox]()
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(size.width), Int(size.height))

            let flippedRect = CGRect(
                x: objectBounds.origin.x,
                y: size.height - objectBounds.origin.y - objectBounds.height,
                width: objectBounds.width,
                height: objectBounds.height
            )

            let box = ObjectBox(
                identifier: topLabelObservation.identifier,
                confidence: topLabelObservation.confidence,
                bound: flippedRect
            )

            objectBoxArray.append(box)
        }
        return objectBoxArray
    }
}
