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
    private let imageSize = CGSize(width: 304, height: 228)
    var modelOptions: [ModelOption]

    enum Options: String {
        case FCRNFP16, FCRN
    }

    init() {
        let modelOption1 = ModelOption(modelFileName: Options.FCRNFP16.rawValue, modelOptionParameter: nil)
        let modelOption2 = ModelOption(modelFileName: Options.FCRN.rawValue, modelOptionParameter: nil)
        modelOptions = [ModelOption]()
        modelOptions.append(modelOption1)
        modelOptions.append(modelOption2)
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
        let model = makeModel(option: option)

        let nimage = image.resized(to: imageSize)
        let pixelBuffer = nimage.pixelBuffer(width: Int(nimage.size.width), height: Int(nimage.size.height))

        do {
            let result = try model.prediction(image: pixelBuffer!)

            let bufferSize = result.depthmap.shape.lazy.map { $0.intValue }.reduce(1, { $0 * $1 })

            let featurePointer = result.depthmap.dataPointer.assumingMemoryBound(to: Double.self)
            let dataPointer = UnsafeMutableBufferPointer(start: featurePointer, count: bufferSize)

            var imgData = [UInt8](repeating: 0, count: bufferSize)
            let inputW = 160
            let inputH = 128

            for i in 0 ..< inputW {
                for j in 0 ..< inputH {
                    let idx = i * inputW + j
                    if idx >= bufferSize { break }
                    let value = dataPointer[idx]
                    imgData[idx] = UInt8(value * (255.0 / 5.0))
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

        } catch {
            print(error)
        }
        return nil
    }

    private func makeModel(option: ModelOption) -> IFCRN {
        var model: IFCRN

        switch Options(rawValue: option.modelFileName) {
        case .FCRN, .none:
            model = FCRN()
        case .FCRNFP16:
            model = FCRNFP16()
        }

        return model
    }
}

protocol IFCRN {
    func prediction(image: CVPixelBuffer) throws -> IFCRNOutput
}

extension FCRN: IFCRN {
    func prediction(image: CVPixelBuffer) throws -> IFCRNOutput {
        let output: FCRNOutput = try prediction(image: image)
        return output
    }
}

extension FCRNFP16: IFCRN {
    func prediction(image: CVPixelBuffer) throws -> IFCRNOutput {
        let output: FCRNFP16Output = try prediction(image: image)
        return output
    }
}

protocol IFCRNOutput: MLFeatureProvider {
    var depthmap: MLMultiArray { get }
}

extension FCRNOutput: IFCRNOutput {
}

extension FCRNFP16Output: IFCRNOutput {
}
