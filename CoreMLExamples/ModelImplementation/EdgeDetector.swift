//
//  HEDImplementor.swift
//  CoreMLExamples
//
//  Created by Mamunul Mazid on 16/7/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import Accelerate
import CoreGraphics
import CoreML
import Foundation
import UIKit

enum HEDOptions: String {
    case fuse = "upscore-fuse", dsn5 = "upscore-dsn5", dsn4 = "upscore-dsn4", dsn3 = "upscore-dsn3", dsn2 = "upscore-dsn2", dsn1 = "upscore-dsn1"
}

class EdgeDetector: Intelligence {
    var modelOptions: [ModelOption]
    
    init() {
        let modelOption1 = ModelOption(modelFileName: "HED_fuse", modelOptionParameter: "upscore-fuse")
        let modelOption2 = ModelOption(modelFileName: "HED_so", modelOptionParameter: "upscore-dsn5")
        let modelOption3 = ModelOption(modelFileName: "HED_so", modelOptionParameter: "upscore-dsn4")
        let modelOption4 = ModelOption(modelFileName: "HED_so", modelOptionParameter: "upscore-dsn3")
        let modelOption5 = ModelOption(modelFileName: "HED_so", modelOptionParameter: "upscore-dsn2")
        let modelOption6 = ModelOption(modelFileName: "HED_so", modelOptionParameter: "upscore-dsn1")
        modelOptions = [ModelOption]()
        modelOptions.append(modelOption1)
        modelOptions.append(modelOption2)
        modelOptions.append(modelOption3)
        modelOptions.append(modelOption4)
        modelOptions.append(modelOption5)
        modelOptions.append(modelOption6)
    }

    
    private let hedMain = HED_fuse()
    private let hedSO = HED_so()

    private var modelOption: HEDOptions = .fuse
    private let imageSize = CGSize(width: 500, height: 500)
    func execute(in image: UIImage, onCompletion: @escaping (IntelligenceOutput?) -> Void) {
        let output = doInferencePressed(inputImage: image)
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

    private func doInferencePressed(inputImage: UIImage) -> UIImage? {
        guard let inputPixelBuffer = inputImage.resized(width: Int(imageSize.width), height: Int(imageSize.height))
            .pixelBuffer(width: Int(imageSize.width), height: Int(imageSize.height)) else {
            return nil
        }

        let featureProvider: MLFeatureProvider
        do {
            switch modelOption {
            case .fuse:
                featureProvider = try hedMain.prediction(data: inputPixelBuffer)
            case .dsn1, .dsn2, .dsn3, .dsn4, .dsn5:
                featureProvider = try hedSO.prediction(data: inputPixelBuffer)
            }
        } catch {
            return nil
        }

        guard let outputFeatures = featureProvider.featureValue(for: modelOption.rawValue)?.multiArrayValue else {
            return nil
        }

        let bufferSize = outputFeatures.shape.lazy.map { $0.intValue }.reduce(1, { $0 * $1 })

        let featurePointer = outputFeatures.dataPointer.assumingMemoryBound(to: Double.self)
        let dataPointer = UnsafeMutableBufferPointer(start: featurePointer, count: bufferSize)

        var imgData = [UInt8](repeating: 0, count: bufferSize)

        for i in 0 ..< Int(imageSize.width) {
            for j in 0 ..< Int(imageSize.height) {
                let idx = i * Int(imageSize.width) + j
                let value = dataPointer[idx]

                let sigmoid = { (input: Double) -> Double in
                    1 / (1 + exp(-input))
                }

                let result = sigmoid(value)
                imgData[idx] = UInt8(result * 255)
            }
        }

        let cfbuffer = CFDataCreate(nil, &imgData, bufferSize)!
        let dataProvider = CGDataProvider(data: cfbuffer)!
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let cgImage2 = CGImage(
            width: Int(imageSize.width),
            height: Int(imageSize.height),
            bitsPerComponent: 8,
            bitsPerPixel: 8,
            bytesPerRow: Int(imageSize.width),
            space: colorSpace,
            bitmapInfo: [],
            provider: dataProvider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent)
        if cgImage2 != nil {
            let resultImage = UIImage(cgImage: cgImage2!)
            return resultImage
        }
        return nil
    }
}
