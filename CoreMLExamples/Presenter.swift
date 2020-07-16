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

    func apply(in image: UIImage) {
        hed.doInferencePressed(inputImage: image)
    }
}
