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

class PoseEstimator {
    private let modelInputSize = CGSize(width: 513, height: 513)
    private let outputStride = 16
    private var poseBuilderConfiguration = PoseBuilderConfiguration()

    func runModel(image: UIImage) -> [Pose] {
        guard let model = makeModel() else { return [Pose]() }
        let input = PoseNetInput(image: image.cgImage!, size: self.modelInputSize)
        let nimage = image.resized(to: modelInputSize)
        let pixelBuffer = nimage.pixelBuffer(width: Int(nimage.size.width), height: Int(nimage.size.height))

        do {
//            let predictions = try model.model.prediction(from: input)
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

    private func makeModel() -> PoseNetMobileNet075S8FP16? {
        let modelURL = Bundle.main.url(forResource: "PoseNetMobileNet075S8FP16", withExtension: "mlmodelc")
        do {
            let model = try PoseNetMobileNet075S8FP16(contentsOf: modelURL!)
            return model
        } catch {
            print(error)
        }

        return nil
    }
}
