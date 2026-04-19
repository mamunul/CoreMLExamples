//
//  UIHelper.swift
//  CoreMLExamples
//
//  Created by Mamunul Mazid on 16/7/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import Foundation
import UIKit

class UIHelper {
    func createBox(objectBoxArray: [ObjectBox], in image: UIImage) -> UIImage {
        let detectionOverlay: CALayer = setupLayers(size: image.size)
        for objectBox in objectBoxArray {
            let shapeLayer = createRoundedRectLayerWithBounds(objectBox.bound)

            let textLayer = createTextSubLayerInBounds(objectBox)

            shapeLayer.addSublayer(textLayer)
            detectionOverlay.addSublayer(shapeLayer)
        }

        let img = imageFromLayer(layer: detectionOverlay)

        let result = draw(image: img.cgImage!, on: image.cgImage!)
        return result
    }

    func setupLayers(size: CGSize) -> CALayer {
        let detectionOverlay = CALayer()
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: size.width,
                                         height: size.height)
        detectionOverlay.contentsGravity = .resizeAspectFill
        detectionOverlay.contentsScale = 1
        return detectionOverlay
    }
    
    func imageFromLayer(layer: CALayer) -> UIImage {
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = 1

        let renderer = UIGraphicsImageRenderer(
            size: layer.bounds.size,
            format: rendererFormat
        )

        return renderer.image { context in
//            let cgContext = context.cgContext
//
//              cgContext.translateBy(x: 0, y: layer.bounds.height)
//              cgContext.scaleBy(x: 1, y: -1)

            layer.render(in: context.cgContext)
        }
    }

//    func imageFromLayer(layer: CALayer) -> UIImage {
//        UIGraphicsBeginImageContextWithOptions(layer.frame.size, layer.isOpaque, 0)
//        layer.render(in: UIGraphicsGetCurrentContext()!)
//        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return outputImage!
//    }

    func draw(image: CGImage, on frame: CGImage) -> UIImage {
        let dstImageSize = CGSize(width: frame.width, height: frame.height)
        let dstImageFormat = UIGraphicsImageRendererFormat()

        dstImageFormat.scale = 1
        let renderer = UIGraphicsImageRenderer(size: dstImageSize,
                                               format: dstImageFormat)

        let dstImage = renderer.image { rendererContext in
            // Draw the current frame as the background for the new image.
            draw(image: frame, in: rendererContext.cgContext)
            draw(image: image, in: rendererContext.cgContext)
        }

        return dstImage
    }

    func draw(image: CGImage, in cgContext: CGContext) {
        cgContext.saveGState()
        cgContext.scaleBy(x: 1.0, y: -1.0)
        let drawingRect = CGRect(x: 0, y: -image.height, width: image.width, height: image.height)
        cgContext.draw(image, in: drawingRect)
        cgContext.restoreGState()
    }
    
    func createTextSubLayerInBounds(_ box: ObjectBox) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"

        let text = "\(box.identifier)\nConfidence: \(String(format: "%.2f", box.confidence))"

        let attributed = NSMutableAttributedString(string: text)
        let font = UIFont.systemFont(ofSize: 24)

        attributed.addAttributes(
            [.font: font],
            range: NSRange(location: 0, length: box.identifier.count)
        )

        textLayer.string = attributed
        
        textLayer.frame = CGRect(
            x: 10,
            y: box.bound.height - 50,
            width: box.bound.width - 10,
            height: 50
        )
        
        textLayer.alignmentMode = .left

        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.alignmentMode = .left
        textLayer.isWrapped = true

        return textLayer
    }

    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.frame = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }
}
