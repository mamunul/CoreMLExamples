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
    var modelOptions: [ModelOption] = []
    private let imageSizeDeepLab = CGSize(width: 513, height: 513)
    private let imageSizeDETR = CGSize(width: 448, height: 448)

    enum Options: String, CaseIterable {
        case DeepLabV3, DeepLabV3FP16, DeepLabV3Int8LUT
        case DETRResnet50SemanticSegmentationF16, DETRResnet50SemanticSegmentationF16P8
    }

    enum SegmenterError: Error {
        case predictionError
        case fileNotFound
    }

    init() {
        for option in Options.allCases {
            let modelOption1 = ModelOption(modelFileName: option.rawValue)
            modelOptions.append(modelOption1)
        }
    }

    func process(image: UIImage, with option: ModelOption) throws -> IntelligenceOutput {
        let output = try runModel(image: image, option: option)

        var imageSize = imageSizeDETR

        if option.modelFileName == Options.DeepLabV3.rawValue ||
            option.modelFileName == Options.DeepLabV3FP16.rawValue ||
            option.modelFileName == Options.DeepLabV3Int8LUT.rawValue {
            imageSize = imageSizeDeepLab
        }

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
        var model: IDeepLab
        guard let modelURL = Bundle.main.url(forResource: option.modelFileName, withExtension: "mlmodelc") else {
            throw SegmenterError.fileNotFound
        }
        switch Options(rawValue: option.modelFileName) {
        case .DeepLabV3, .none:
            model = try DeepLabV3(contentsOf: modelURL )
        case .DeepLabV3FP16:
            model = try DeepLabV3FP16(contentsOf: modelURL)
        case .DeepLabV3Int8LUT:
            model = try DeepLabV3Int8LUT(contentsOf: modelURL)
        case .DETRResnet50SemanticSegmentationF16:
            model = try DETRResnet50SemanticSegmentationF16(contentsOf: modelURL)
        case .DETRResnet50SemanticSegmentationF16P8:
            model = try DETRResnet50SemanticSegmentationF16P8(contentsOf: modelURL)
        }

        
        var imageSize = imageSizeDETR

        if option.modelFileName == Options.DeepLabV3.rawValue ||
            option.modelFileName == Options.DeepLabV3FP16.rawValue ||
            option.modelFileName == Options.DeepLabV3Int8LUT.rawValue {
            imageSize = imageSizeDeepLab
        }

        let nimage = image.resized(to: imageSize)
        let pixelBuffer = nimage.pixelBuffer(width: Int(nimage.size.width), height: Int(nimage.size.height))

        let result = try model.prediction(image: pixelBuffer!)
        guard let outputImage = result.semanticPredictions.image(max:21) else { throw SegmenterError.predictionError }
        
        return outputImage
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

extension DETRResnet50SemanticSegmentationF16: IDeepLab {
    func prediction(image: CVPixelBuffer) throws -> IDeepLabOutput {
        let output: DETRResnet50SemanticSegmentationF16Output = try prediction(image: image)
        return output
    }
}

extension DETRResnet50SemanticSegmentationF16P8: IDeepLab {
    func prediction(image: CVPixelBuffer) throws -> IDeepLabOutput {
        let output: DETRResnet50SemanticSegmentationF16P8Output = try prediction(image: image)
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

extension DETRResnet50SemanticSegmentationF16Output: IDeepLabOutput {
}

extension DETRResnet50SemanticSegmentationF16P8Output: IDeepLabOutput {
}
