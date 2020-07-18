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
    var modelOptions: [ModelOption]

    enum Options: String {
        case Resnet50, Resnet50FP16, Resnet50Int8LUT, MobileNet
    }

    init() {
        let modelOption1 = ModelOption(modelFileName: Options.Resnet50.rawValue, modelOptionParameter: nil)
        let modelOption2 = ModelOption(modelFileName: Options.Resnet50FP16.rawValue, modelOptionParameter: nil)
        let modelOption3 = ModelOption(modelFileName: Options.Resnet50Int8LUT.rawValue, modelOptionParameter: nil)
        let modelOption4 = ModelOption(modelFileName: Options.MobileNet.rawValue, modelOptionParameter: nil)
        modelOptions = [ModelOption]()
        modelOptions.append(modelOption1)
        modelOptions.append(modelOption2)
        modelOptions.append(modelOption3)
        modelOptions.append(modelOption4)
    }

    func process(image: UIImage, with option: ModelOption, onCompletion: @escaping (IntelligenceOutput?) -> Void) {
        runVision(image: image, option: option) { output in
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

    private func runModel(image: UIImage, option: ModelOption, onCompletion: @escaping () -> Void) {
        guard let model = makeModel() else { return }

        let nimage = image.resized(to: imageSize)
        let pixelBuffer = nimage.pixelBuffer(width: Int(nimage.size.width), height: Int(nimage.size.height))!
        do {
            let result = try model.prediction(image: pixelBuffer)
            print(result.classLabel)
        } catch {
        }
    }

    private func runVision(image: UIImage, option: ModelOption, onCompletion: @escaping (ObjectBox) -> Void) {
        let nimage = image.resized(to: imageSize)
        guard let modelURL = Bundle.main.url(forResource: option.modelFileName, withExtension: "mlmodelc") else { return }
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
