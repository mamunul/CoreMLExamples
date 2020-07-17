//
//  Presenter.swift
//  CoreMLExamples
//
//  Created by Mamunul Mazid on 16/7/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import Foundation
import UIKit

class Presenter {
    let hed = HEDImplementor()
    let deepLap = DeepLabSegmenter()
    let yolo = YoloObjectDetector()
    let fcrn = FCRNDepthMapper()
    let mobileNet = MobileNetClassifier()
    let poseEstimator = PoseEstimator()

    func apply(in image: UIImage) -> UIImage? {
//        hed.doInferencePressed(inputImage: image)
//        deepLap.runModel(image: image)

//        yolo.runModel(image: image) { box in
//            print(box)
//        }

//        return fcrn.runModel(image: image)

//        mobileNet.runVision(image: image) { _ in
//        }

        let poses = poseEstimator.runModel(image: image)

        let imageView = PoseMarkerGenerator()
        let modelInputSize = CGSize(width: 513, height: 513)
        let nimage = image.resized(to: modelInputSize)
        let img = imageView.show(poses: poses, on: image.cgImage!)

        return img

//        return nil
    }
}
