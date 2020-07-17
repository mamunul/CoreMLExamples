//
//  Presenter.swift
//  CoreMLExamples
//
//  Created by Mamunul Mazid on 16/7/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import Foundation
import UIKit

protocol Intelligence {
}

struct Intelligent: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Intelligent, rhs: Intelligent) -> Bool {
        lhs.id == rhs.id
    }

    var id = UUID()
    var name: String
    var object: Intelligence
}

class Presenter: ObservableObject {
    @Published var intelligentArray = [Intelligent]()

    let hed = HEDImplementor()
    let deepLap = DeepLabSegmenter()
    let yolo = YoloObjectDetector()
    let fcrn = FCRNDepthMapper()
    let mobileNet = MobileNetClassifier()
    let poseEstimator = PoseEstimator()

    init() {
        let intelligent1 = Intelligent(name: "HED", object: hed)
        intelligentArray.append(intelligent1)

        let intelligent2 = Intelligent(name: "deepLap", object: deepLap)
        intelligentArray.append(intelligent2)

        let intelligent3 = Intelligent(name: "yolo", object: yolo)
        intelligentArray.append(intelligent3)

        let intelligent4 = Intelligent(name: "fcrn", object: fcrn)
        intelligentArray.append(intelligent4)

        let intelligent5 = Intelligent(name: "mobileNet", object: mobileNet)
        intelligentArray.append(intelligent5)

        let intelligent6 = Intelligent(name: "poseEstimator", object: poseEstimator)
        intelligentArray.append(intelligent6)
    }

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
