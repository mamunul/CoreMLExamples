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
    func execute(in image: UIImage, onCompletion: @escaping (Any?) -> Void)
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
    var isSelected = false
}

class Presenter: ObservableObject {
    @Published var intelligentArray = [Intelligent]()

    private let hed = HEDImplementor()
    private let deepLap = DeepLabSegmenter()
    private let yolo = YoloObjectDetector()
    private let fcrn = FCRNDepthMapper()
    private let mobileNet = MobileNetClassifier()
    private let poseEstimator = PoseEstimator()
    private var selectedIntelligent: Intelligent
    private var image: UIImage?

    init() {
        let intelligent1 = Intelligent(name: "HED", object: hed)
        selectedIntelligent = intelligent1
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

    func update(image: UIImage) {
        self.image = image
    }

    func update(intelligent: Intelligent) {
        selectedIntelligent = intelligent

        if image != nil {
            selectedIntelligent.object.execute(in: image!) { output in
                print(output)
            }
        }
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
