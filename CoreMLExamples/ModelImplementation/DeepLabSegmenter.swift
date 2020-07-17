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

class DeepLabSegmenter:Intelligence {
    func runModel(image: UIImage) -> UIImage? {
        guard let model = makeModel() else { return nil }

        let nimage = image.resized(to: CGSize(width: 513, height: 513))
        let pixelBuffer = nimage.pixelBuffer(width: Int((nimage.size.width)), height: Int((nimage.size.height)))

        do {
            let result = try model.prediction(image: pixelBuffer!)
            let outputImage = result.semanticPredictions.image()
            return outputImage
        } catch {
            print(error)
        }
        return nil
    }

    private func makeModel() -> DeepLabV3? {
        let modelURL = Bundle.main.url(forResource: "DeepLabV3", withExtension: "mlmodelc")
        do {
            let model = try DeepLabV3(contentsOf: modelURL!)
            return model
        } catch {
            print(error)
        }

        return nil
    }
}
