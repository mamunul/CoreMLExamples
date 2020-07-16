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
    let deepLap = DeepLabImplementor()
    let yolo = YoloImplementor()

    func apply(in image: UIImage) -> UIImage? {
//        hed.doInferencePressed(inputImage: image)
//        deepLap.runModel(image: image)

        yolo.runModel(image: image) { box in
            print(box)
        }
        return nil
    }
}
