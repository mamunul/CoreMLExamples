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
    private var options = Options.DeepLabV3

    enum Options: String {
        case DeepLabV3, DeepLabV3FP16, DeepLabV3Int8LUT
    }

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
        let output = runModel(image: image, option: option)
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

    private func runModel(image: UIImage, option: ModelOption) -> UIImage? {
        var model: IDeepLab
        switch Options(rawValue: option.modelFileName) {
        case .DeepLabV3, .none:
            model = DeepLabV3()
        case .DeepLabV3FP16:
            model = DeepLabV3FP16()
        case .DeepLabV3Int8LUT:
            model = DeepLabV3Int8LUT()
        }

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

protocol IDeepLab {
    func prediction(image: CVPixelBuffer) throws -> IDeepLabOutput
}

extension DeepLabV3: IDeepLab {
    func prediction(image: CVPixelBuffer) throws -> IDeepLabOutput {
        let output: DeepLabV3Output = try prediction(image: image)
        return output
    }
}

extension DeepLabV3FP16: IDeepLab {
    func prediction(image: CVPixelBuffer) throws -> IDeepLabOutput {
        let output: DeepLabV3FP16Output = try prediction(image: image)
        return output
    }
}

extension DeepLabV3Int8LUT: IDeepLab {
    func prediction(image: CVPixelBuffer) throws -> IDeepLabOutput {
        let output: DeepLabV3Int8LUTOutput = try prediction(image: image)
        return output
    }
}

protocol IDeepLabOutput: MLFeatureProvider {
    var semanticPredictions: MLMultiArray { get }
}

extension DeepLabV3Output: IDeepLabOutput {
}

extension DeepLabV3FP16Output: IDeepLabOutput {
}

extension DeepLabV3Int8LUTOutput: IDeepLabOutput {
}
