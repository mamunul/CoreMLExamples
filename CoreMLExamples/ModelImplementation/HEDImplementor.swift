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

class HEDImplementor:Intelligence {
    private let hedMain = HED_fuse()
    private let hedSO = HED_so()

    private var modelOption: HEDOptions = .fuse

    func doInferencePressed(inputImage: UIImage) -> UIImage? {
        let inputW = 500
        let inputH = 500
        guard let inputPixelBuffer = inputImage.resized(width: inputW, height: inputH)
            .pixelBuffer(width: inputW, height: inputH) else {
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

        for i in 0 ..< inputW {
            for j in 0 ..< inputH {
                let idx = i * inputW + j
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
            width: inputW,
            height: inputH,
            bitsPerComponent: 8,
            bitsPerPixel: 8,
            bytesPerRow: inputW,
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
