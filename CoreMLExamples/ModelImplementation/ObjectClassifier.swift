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

class ObjectClassifier: Intelligence {
    private let imageSize = CGSize(width: 224, height: 224)
    func execute(in image: UIImage, onCompletion: @escaping (IntelligenceOutput?) -> Void) {
        runVision(image: image) { output in
            let result =
                IntelligenceOutput(
                    image: nil,
                    confidence: output.confidence,
                    executionTime: -0,
                    title: output.identifier,
                    modelSize: 0,
                    imageSize: self.imageSize
                )
            onCompletion(result)
        }
    }

    private func runModel(image: UIImage, onCompletion: @escaping () -> Void) {
        guard let model = makeModel() else { return }

        let nimage = image.resized(to: imageSize)
        let pixelBuffer = nimage.pixelBuffer(width: Int(nimage.size.width), height: Int(nimage.size.height))!
        do {
            let result = try model.prediction(image: pixelBuffer)
            print(result.classLabel)
        } catch {
        }
    }

    func runVision(image: UIImage, onCompletion: @escaping (ObjectBox) -> Void) {
        let nimage = image.resized(to: imageSize)
        guard let modelURL = Bundle.main.url(forResource: "Resnet50", withExtension: "mlmodelc") else { return }
        var visionModel: VNCoreMLModel?
        do {
            visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
        } catch {
        }

        let objectRecognition = VNCoreMLRequest(model: visionModel!, completionHandler: { request, _ in
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

        do {
            try imageRequestHandler.perform([objectRecognition])
        } catch {
            print(error)
        }
    }

    private func makeModel() -> MobileNet? {
        let modelURL = Bundle.main.url(forResource: "MobileNet", withExtension: "mlmodelc")!
        do {
            let model = try MobileNet(contentsOf: modelURL)
            return model
        } catch {
            print(error)
        }

        return nil
    }
}