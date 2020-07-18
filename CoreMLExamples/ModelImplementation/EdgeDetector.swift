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

class EdgeDetector: Intelligence {
    var modelOptions: [ModelOption]

    private let hedMain = HED_fuse()
    private let hedSO = HED_so()

    private let imageSize = CGSize(width: 500, height: 500)

    enum Options: String {
        case HED_so, HED_fuse
    }

    init() {
        let modelOption1 = ModelOption(modelFileName: Options.HED_fuse.rawValue, modelOptionParameter: "upscore-fuse")
        let modelOption2 = ModelOption(modelFileName: Options.HED_so.rawValue, modelOptionParameter: "upscore-dsn5")
        let modelOption3 = ModelOption(modelFileName: Options.HED_so.rawValue, modelOptionParameter: "upscore-dsn4")
        let modelOption4 = ModelOption(modelFileName: Options.HED_so.rawValue, modelOptionParameter: "upscore-dsn3")
        let modelOption5 = ModelOption(modelFileName: Options.HED_so.rawValue, modelOptionParameter: "upscore-dsn2")
        let modelOption6 = ModelOption(modelFileName: Options.HED_so.rawValue, modelOptionParameter: "upscore-dsn1")
        modelOptions = [ModelOption]()
        modelOptions.append(modelOption1)
        modelOptions.append(modelOption2)
        modelOptions.append(modelOption3)
        modelOptions.append(modelOption4)
        modelOptions.append(modelOption5)
        modelOptions.append(modelOption6)
    }

    func process(image: UIImage, with option: ModelOption, onCompletion: @escaping (IntelligenceOutput?) -> Void) {
        let output = doInferencePressed(inputImage: image, option: option)
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

    private func doInferencePressed(inputImage: UIImage, option: ModelOption) -> UIImage? {
        guard let inputPixelBuffer = inputImage.resized(width: Int(imageSize.width), height: Int(imageSize.height))
            .pixelBuffer(width: Int(imageSize.width), height: Int(imageSize.height)) else {
            return nil
        }

        let featureProvider: MLFeatureProvider
        do {
            switch Options(rawValue: option.modelFileName) {
            case .HED_fuse, .none:
                featureProvider = try hedMain.prediction(data: inputPixelBuffer)
            case .HED_so:
                featureProvider = try hedSO.prediction(data: inputPixelBuffer)
            }
        } catch {
            return nil
        }

        guard let outputFeatures = featureProvider.featureValue(for: option.modelOptionParameter!)?.multiArrayValue else {
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
