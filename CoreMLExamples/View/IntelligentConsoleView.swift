//
//  IntelligentConsoleView.swift
//  CoreMLExamples
//
//  Created by Mamunul Mazid on 17/7/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import SwiftUI

struct IntelligentConsoleView: View {
    @Binding var output: IntelligenceOutput
    var body: some View {
        VStack {
            HStack {
                Text("\(Int(output.executionTime))ms ")
                Text("\(Int(output.modelSize))MB ")
                Text("\(Int(output.imageSize.width)) : \(Int(output.imageSize.height))res")
            }
            HStack {
                Text("Confidence: \(output.confidence)")
                Text("Title: \(output.title)")
            }
        }
    }
}

struct IntelligentConsoleView_Previews: PreviewProvider {
    @State private static var output =
        IntelligenceOutput(
            image: nil,
            confidence: 0,
            executionTime: 0,
            title: "",
            modelSize: 0,
            imageSize: CGSize(width: 0, height: 0)
        )
    static var previews: some View {
        IntelligentConsoleView(output: $output)
    }
}
