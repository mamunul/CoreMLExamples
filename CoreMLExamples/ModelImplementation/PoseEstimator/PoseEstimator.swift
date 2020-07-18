//
//  PoseEstimator.swift
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

class PoseEstimator: Intelligence {
    private let modelInputSize = CGSize(width: 513, height: 513)
    private let outputStride = 16
    private var poseBuilderConfiguration = PoseBuilderConfiguration()
    var modelOptions: [ModelOption]

    enum Options: String {
        case PoseNetMobileNet075S8FP16,
            PoseNetMobileNet100S8FP16,
            PoseNetMobileNet075S16FP16,
            PoseNetMobileNet100S16FP16
    }

    init() {
        let modelOption1 = ModelOption(modelFileName: Options.PoseNetMobileNet075S8FP16.rawValue, modelOptionParameter: nil)
        let modelOption2 = ModelOption(modelFileName: Options.PoseNetMobileNet100S8FP16.rawValue, modelOptionParameter: nil)
        let modelOption3 = ModelOption(modelFileName: Options.PoseNetMobileNet075S16FP16.rawValue, modelOptionParameter: nil)
        let modelOption4 = ModelOption(modelFileName: Options.PoseNetMobileNet100S16FP16.rawValue, modelOptionParameter: nil)
        modelOptions = [ModelOption]()
        modelOptions.append(modelOption1)
        modelOptions.append(modelOption2)
        modelOptions.append(modelOption3)
        modelOptions.append(modelOption4)
    }

    func process(image: UIImage, with option: ModelOption, onCompletion: @escaping (IntelligenceOutput?) -> Void) {
        let output = runModel(image: image, option: option)

        let imageView = PoseMarkerGenerator()
        let modelInputSize = CGSize(width: 513, height: 513)
        let img = imageView.show(poses: output, on: image.cgImage!)

        let result =
            IntelligenceOutput(
                image: img,
                confidence: -0,
                executionTime: -0,
                title: "NA",
                modelSize: 0,
                imageSize: modelInputSize
            )
        onCompletion(result)
    }

    func runModel(image: UIImage, option: ModelOption) -> [Pose] {
        let model = makeModel(option: option)
        let nimage = image.resized(to: modelInputSize)
        let pixelBuffer = nimage.pixelBuffer(width: Int(nimage.size.width), height: Int(nimage.size.height))

        do {
            let predictions = try model.prediction(image: pixelBuffer!)

            let poseNetOutput =
                PoseNetOutput(
                    prediction: predictions,
                    modelInputSize: modelInputSize,
                    modelOutputStride: outputStride
                )

            let poseBuilder = PoseBuilder(output: poseNetOutput,
                                          configuration: poseBuilderConfiguration,
                                          inputImage: nimage.cgImage!)

            let poses = [poseBuilder.pose]
            return poses

        } catch {
            print(error)
        }
        return [Pose]()
    }

    private func makeModel(option: ModelOption) -> IPoseNetMobileNet {
        var model: IPoseNetMobileNet

        switch Options(rawValue: option.modelFileName) {
        case .PoseNetMobileNet075S16FP16, .none:
            model = PoseNetMobileNet075S8FP16()
        case .PoseNetMobileNet075S8FP16:
            model = PoseNetMobileNet075S8FP16()
        case .PoseNetMobileNet100S8FP16:
            model = PoseNetMobileNet100S8FP16()
        case .PoseNetMobileNet100S16FP16:
            model = PoseNetMobileNet100S16FP16()
        }

        return model
    }
}

protocol IPoseNetMobileNet {
    func prediction(image: CVPixelBuffer) throws -> IPoseNetMobileNetOutput
}

extension PoseNetMobileNet075S8FP16: IPoseNetMobileNet {
    func prediction(image: CVPixelBuffer) throws -> IPoseNetMobileNetOutput {
        let output: PoseNetMobileNet075S8FP16Output = try prediction(image: image)
        return output
    }
}

extension PoseNetMobileNet100S8FP16: IPoseNetMobileNet {
    func prediction(image: CVPixelBuffer) throws -> IPoseNetMobileNetOutput {
        let output: PoseNetMobileNet100S8FP16Output = try prediction(image: image)
        return output
    }
}

extension PoseNetMobileNet075S16FP16: IPoseNetMobileNet {
    func prediction(image: CVPixelBuffer) throws -> IPoseNetMobileNetOutput {
        let output: PoseNetMobileNet075S16FP16Output = try prediction(image: image)
        return output
    }
}

extension PoseNetMobileNet100S16FP16: IPoseNetMobileNet {
    func prediction(image: CVPixelBuffer) throws -> IPoseNetMobileNetOutput {
        let output: PoseNetMobileNet100S16FP16Output = try prediction(image: image)
        return output
    }
}

protocol IPoseNetMobileNetOutput: MLFeatureProvider {
    var displacementBwd: MLMultiArray { get }
    var displacementFwd: MLMultiArray { get }
    var offsets: MLMultiArray { get }
    var heatmap: MLMultiArray { get }
}

extension PoseNetMobileNet075S8FP16Output: IPoseNetMobileNetOutput {
}

extension PoseNetMobileNet100S8FP16Output: IPoseNetMobileNetOutput {
}

extension PoseNetMobileNet075S16FP16Output: IPoseNetMobileNetOutput {
}

extension PoseNetMobileNet100S16FP16Output: IPoseNetMobileNetOutput {
}
