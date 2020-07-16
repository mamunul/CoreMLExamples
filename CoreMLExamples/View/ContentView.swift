//
//  ContentView.swift
//  CoreMLExamples
//
//  Created by Mamunul Mazid on 16/7/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import SwiftUI

let presenter = Presenter()

struct ContentView: View {
    @State var image: Image?
    @State var showPicker = false
    @State var uiImage: UIImage?

    var presenterObject = presenter

    var body: some View {
        ZStack {
            ImagePreview(image: $image)

            Button(action: {
                self.showPicker = true
            }) {
                Text("choose")
            }
        }.sheet(isPresented: $showPicker, onDismiss: {
            if self.uiImage != nil {
                self.image = Image(uiImage: self.uiImage!)
                if let uiImage = self.presenterObject.apply(in: self.uiImage!) {
                    self.image = Image(uiImage: uiImage)
                }
            }
        }) {
            ImagePickerView(uiImage: self.$uiImage)
        }
    }
}

struct ImagePreview: View {
    @Binding var image: Image?
    var body: some View {
        image?
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
