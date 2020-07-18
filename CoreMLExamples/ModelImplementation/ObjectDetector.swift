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
    var modelOptions: [ModelOption]
    
    init() {
        let modelOption1 = ModelOption(modelFileName: "YOLOv3Tiny", modelOptionParameter: nil)
        let modelOption2 = ModelOption(modelFileName: "YOLOv3TinyFP16", modelOptionParameter: nil)
        let modelOption3 = ModelOption(modelFileName: "YOLOv3TinyInt8LUT", modelOptionParameter: nil)
        modelOptions = [ModelOption]()
        modelOptions.append(modelOption1)
        modelOptions.append(modelOption2)
        modelOptions.append(modelOption3)
    }

    
    
    func process(image: UIImage, with option: ModelOption, onCompletion: @escaping (IntelligenceOutput?) -> Void) {
        runModel(image: image) { _ in // FIXME: generate Image
            let result =
                IntelligenceOutput(
                    image: nil,
                    confidence: -0,
                    executionTime: -0,
                    title: "NA",
                    modelSize: 0,
                    imageSize: self.imageSize
                )
            onCompletion(result)
        }
    }

    private func runModel(image: UIImage, onCompletion: @escaping ([ObjectBox]) -> Void) {
        let nimage = image.resized(to: imageSize)
        var objectBoxArray = [ObjectBox]()
        guard let modelURL = Bundle.main.url(forResource: "YOLOv3Tiny", withExtension: "mlmodelc") else { return }
        var visionModel: VNCoreMLModel?
        do {
            visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
        } catch {
            onCompletion(objectBoxArray)
        }

        let objectRecognition = VNCoreMLRequest(model: visionModel!, completionHandler: { request, _ in
            if let results = request.results {
                objectBoxArray = VisionHelper.processResult(results, size: nimage.size)
                onCompletion(objectBoxArray)
            }
        })

        let imageRequestHandler = VNImageRequestHandler(cgImage: nimage.cgImage!, options: [:])

        do {
            try imageRequestHandler.perform([objectRecognition])
        } catch {
            print(error)
            onCompletion(objectBoxArray)
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

            let box =
                ObjectBox(
                    identifier: topLabelObservation.identifier,
                    confidence: topLabelObservation.confidence,
                    bound: objectBounds)

            objectBoxArray.append(box)
        }
        return objectBoxArray
    }
}
