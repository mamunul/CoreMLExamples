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

class FCRNDepthMapper: Intelligence {
    func execute(in image: UIImage, onCompletion: @escaping (Any?) -> Void) {
        let output = runModel(image: image)
        onCompletion(output)
    }

    private func runModel(image: UIImage) -> UIImage? {
        guard let model = makeModel() else { return nil }

        let nimage = image.resized(to: CGSize(width: 304, height: 228))
        let pixelBuffer = nimage.pixelBuffer(width: Int(nimage.size.width), height: Int(nimage.size.height))

        do {
            let input = FCRNInput(image: pixelBuffer!)
            let result = try model.prediction(input: input)

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

    private func makeModel() -> FCRN? {
        let modelURL = Bundle.main.url(forResource: "FCRN", withExtension: "mlmodelc")!
        do {
            let model = try FCRN(contentsOf: modelURL)
            return model
        } catch {
            print(error)
        }

        return nil
    }
}
