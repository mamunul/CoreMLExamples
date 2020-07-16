//
//  ContentView.swift
//  CoreMLExamples
//
//  Created by Mamunul Mazid on 16/7/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var image: Image?
    @State var showPicker = false
    @State var uiImage: UIImage?
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
