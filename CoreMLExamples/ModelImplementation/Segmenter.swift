//
//  ImageSegmenter.swift
//  ImageSegmentation
//
//  Created by New User on 22/1/20.
//  Copyright © 2020 New User. All rights reserved.
//

import CoreML
import Foundation
import SwiftUI
import UIKit

class Segmenter: Intelligence {
    var modelOptions: [ModelOption]
    private let imageSize = CGSize(width: 513, height: 513)

    init() {
        let modelOption1 = ModelOption(modelFileName: "DeepLabV3", modelOptionParameter: nil)
        let modelOption2 = ModelOption(modelFileName: "DeepLabV3FP16", modelOptionParameter: nil)
        let modelOption3 = ModelOption(modelFileName: "DeepLabV3Int8LUT", modelOptionParameter: nil)
        modelOptions = [ModelOption]()
        modelOptions.append(modelOption1)
        modelOptions.append(modelOption2)
        modelOptions.append(modelOption3)
    }

    func process(image: UIImage, with option: ModelOption, onCompletion: @escaping (IntelligenceOutput?) -> Void) {
        let output = runModel(image: image)
        let result =
            IntelligenceOutput(
                image: output,
                confidence: -0,
                executionTime: -0,
                title: "NA",
                modelSize: 0,
                imageSize: imageSize
            )
        onCompletion(result)
    }

    private func runModel(image: UIImage) -> UIImage? {
        guard let model = makeModel() else { return nil }

        let nimage = image.resized(to: imageSize)
        let pixelBuffer = nimage.pixelBuffer(width: Int(nimage.size.width), height: Int(nimage.size.height))

        do {
            let result = try model.prediction(image: pixelBuffer!)
            let outputImage = result.semanticPredictions.image()
            return outputImage
        } catch {
            print(error)
        }
        return nil
    }

    private func makeModel() -> DeepLabV3? {
        let modelURL = Bundle.main.url(forResource: "DeepLabV3", withExtension: "mlmodelc")
        do {
            let model = try DeepLabV3(contentsOf: modelURL!)
            return model
        } catch {
            print(error)
        }

        return nil
    }
}
