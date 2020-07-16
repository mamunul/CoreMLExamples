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

class HEDImplementor {
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

        let dataPointer = UnsafeMutableBufferPointer(start: outputFeatures.dataPointer.assumingMemoryBound(to: Double.self),
                                                     count: bufferSize)

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
        let cgImage = CGImage(width: inputW, height: inputH, bitsPerComponent: 8, bitsPerPixel: 8, bytesPerRow: inputW, space: colorSpace, bitmapInfo: [], provider: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        let resultImage = UIImage(cgImage: cgImage!)
        return resultImage
    }

    func createCGImage(fromFloatArray features: MLMultiArray,
                       min: Float = 0,
                       max: Float = 255) -> CGImage? {
        assert(features.dataType == .float32)
        assert(features.shape.count == 3)

        let ptr = UnsafeMutablePointer<Float>(OpaquePointer(features.dataPointer))

        let height = features.shape[1].intValue
        let width = features.shape[2].intValue
        let channelStride = features.strides[0].intValue
        let rowStride = features.strides[1].intValue
        let srcRowBytes = rowStride * MemoryLayout<Float>.stride

        var blueBuffer = vImage_Buffer(data: ptr,
                                       height: vImagePixelCount(height),
                                       width: vImagePixelCount(width),
                                       rowBytes: srcRowBytes)
        var greenBuffer = vImage_Buffer(data: ptr.advanced(by: channelStride),
                                        height: vImagePixelCount(height),
                                        width: vImagePixelCount(width),
                                        rowBytes: srcRowBytes)
        var redBuffer = vImage_Buffer(data: ptr.advanced(by: channelStride * 2),
                                      height: vImagePixelCount(height),
                                      width: vImagePixelCount(width),
                                      rowBytes: srcRowBytes)

        let destRowBytes = width * 4
        var pixels = [UInt8](repeating: 0, count: height * destRowBytes)
        var destBuffer = vImage_Buffer(data: &pixels,
                                       height: vImagePixelCount(height),
                                       width: vImagePixelCount(width),
                                       rowBytes: destRowBytes)

        let error = vImageConvert_PlanarFToBGRX8888(&blueBuffer,
                                                    &greenBuffer,
                                                    &redBuffer,
                                                    Pixel_8(255),
                                                    &destBuffer,
                                                    [max, max, max],
                                                    [min, min, min],
                                                    vImage_Flags(0))
        if error == kvImageNoError {
            return CGImage.fromByteArrayRGBA(pixels, width: width, height: height)
        } else {
            return nil
        }
    }
}
