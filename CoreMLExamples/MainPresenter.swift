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
    var modelOptions: [ModelOption] { get }
    func execute(in image: UIImage, onCompletion: @escaping (IntelligenceOutput?) -> Void)
}

struct ModelOption {
    var modelFileName: String
    var modelOptionParameter: String?
}

struct IntelligenceOutput {
    var image: UIImage?
    var confidence: Float
    var executionTime: Float
    var title: String
    var modelSize: Float
    var imageSize: CGSize
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

class MainPresenter: ObservableObject {
    @Published var intelligentArray = [Intelligent]()
    @Published var output: IntelligenceOutput
    @Published var uiImage: UIImage
    @Published var loading = false

    private let edgeDetector = EdgeDetector()
    private let segmenter = Segmenter()
    private let objectDetector = ObjectDetector()
    private let depthMapper = DepthMapGenerator()
    private let classifier = ObjectClassifier()
    private let poseEstimator = PoseEstimator()
    private var selectedIntelligent: Intelligent

    init() {
        output =
            IntelligenceOutput(
                image: nil,
                confidence: 0,
                executionTime: 0,
                title: "",
                modelSize: 0,
                imageSize: CGSize(width: 0, height: 0)
            )
        var intelligent1 = Intelligent(name: "Edge Detection", object: edgeDetector)
        selectedIntelligent = intelligent1
        intelligent1.isSelected = true
        uiImage = MainPresenter.from(color: UIColor.gray)
        intelligentArray.append(intelligent1)

        let intelligent2 = Intelligent(name: "Segmentation", object: segmenter)
        intelligentArray.append(intelligent2)

        let intelligent3 = Intelligent(name: "Object Detection", object: objectDetector)
        intelligentArray.append(intelligent3)

        let intelligent4 = Intelligent(name: "Depth Mapping", object: depthMapper)
        intelligentArray.append(intelligent4)

        let intelligent5 = Intelligent(name: "Object Classification", object: classifier)
        intelligentArray.append(intelligent5)

        let intelligent6 = Intelligent(name: "Pose Estimation", object: poseEstimator)
        intelligentArray.append(intelligent6)
    }

    func update(image: UIImage) {
        uiImage = image
        executeOperation()
    }

    func update(intelligent: Intelligent) {
        selectedIntelligent = intelligent
        removePreviousSelection(excludeing: intelligent)
        executeOperation()
    }

    private func removePreviousSelection(excludeing it: Intelligent) {
        if let index = intelligentArray.firstIndex(where: { $0.isSelected && it != $0 }) {
            intelligentArray[index].isSelected = false
        }
    }

    private func executeOperation() {
        let startTime = CACurrentMediaTime()
        DispatchQueue.main.async {
            self.loading = true
        }
        DispatchQueue.global().async {
            self.selectedIntelligent.object.execute(in: self.uiImage) { output in
                if output != nil {
                    let endTime = CACurrentMediaTime()
                    let interval = (endTime - startTime) * 1000

                    DispatchQueue.main.async {
                        self.output = output!
                        self.output.executionTime = Float(interval)
                        self.loading = false
                    }
                }
            }
        }
    }

    private static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 200, height: 200)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
