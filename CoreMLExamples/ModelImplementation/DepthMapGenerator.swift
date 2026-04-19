//
//  FCRNDepthImplementor.swift
//  CoreMLExamples
//
//  Created by Mamunul Mazid on 16/7/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import CoreML
import Foundation
import SwiftUI
import UIKit

class DepthMapGenerator: Intelligence {
//    private let imageSize = CGSize(width: 304, height: 228)
    private let imageSize = CGSize(width: 518, height: 392) //518 × 392
    var modelOptions: [ModelOption]

    enum DepthMapGeneratorError: Error {
        case pixelBufferMake
        case uiImageInit
        case fileNotFound
    }

    enum Options: String {
        case DepthAnythingV2SmallF16, DepthAnythingV2SmallF16P6
    }

    init() {
        let modelOption1 = ModelOption(modelFileName: Options.DepthAnythingV2SmallF16.rawValue, modelOptionParameter: nil)
        let modelOption2 = ModelOption(modelFileName: Options.DepthAnythingV2SmallF16P6.rawValue, modelOptionParameter: nil)
        modelOptions = [ModelOption]()
        modelOptions.append(modelOption1)
        modelOptions.append(modelOption2)
    }

    func process(image: UIImage, with option: ModelOption) throws -> IntelligenceOutput {
        let output = try runModel(image: image, option: option)
        let result = IntelligenceOutput(
            image: output,
            confidence: -0,
            executionTime: -0,
            title: "NA",
            modelSize: 0,
            imageSize: imageSize
        )
        return result
    }

    private func runModel(image: UIImage, option: ModelOption) throws -> UIImage {
        let model = try makeModel(option: option)

        let nimage = image.resized(to: imageSize)
        guard let pixelBuffer = nimage.pixelBuffer(width: Int(nimage.size.width), height: Int(nimage.size.height)) else {
            throw DepthMapGeneratorError.pixelBufferMake
        }

        let result = try model.prediction(image: pixelBuffer)
        guard let depthImage = UIImage(pixelBuffer: result.depth) else { throw DepthMapGeneratorError.uiImageInit }
        return depthImage
    }

    private func makeModel(option: ModelOption) throws -> IDepthAnythingV2 {
        var model: IDepthAnythingV2
        guard let modelURL = Bundle.main.url(forResource: option.modelFileName, withExtension: "mlmodelc") else {
            throw DepthMapGeneratorError.fileNotFound
        }
        switch Options(rawValue: option.modelFileName) {
        case .DepthAnythingV2SmallF16, .none:
            model = try DepthAnythingV2SmallF16(contentsOf: modelURL)
        case .DepthAnythingV2SmallF16P6:
            model = try DepthAnythingV2SmallF16P6(contentsOf: modelURL)
        }

        return model
    }
}

protocol IDepthAnythingV2 {
    func prediction(image: CVPixelBuffer) throws -> IDepthAnythingV2Output
}

extension DepthAnythingV2SmallF16: IDepthAnythingV2 {
    func prediction(image: CVPixelBuffer) throws -> IDepthAnythingV2Output {
        let output: DepthAnythingV2SmallF16Output = try prediction(image: image)
        return output
    }
}

extension DepthAnythingV2SmallF16P6: IDepthAnythingV2 {
    func prediction(image: CVPixelBuffer) throws -> IDepthAnythingV2Output {
        let output: DepthAnythingV2SmallF16P6Output = try prediction(image: image)
        return output
    }
}

protocol IDepthAnythingV2Output: MLFeatureProvider {
    var depth: CVPixelBuffer { get }
}

extension DepthAnythingV2SmallF16Output: IDepthAnythingV2Output {
}

//
extension DepthAnythingV2SmallF16P6Output: IDepthAnythingV2Output {
}
