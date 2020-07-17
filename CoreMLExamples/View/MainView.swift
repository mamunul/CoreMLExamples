//
//  ContentView.swift
//  CoreMLExamples
//
//  Created by Mamunul Mazid on 16/7/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import SwiftUI

let presenter = Presenter()

struct MainView: View {
    @State var image: Image?
    @State var showPicker = false

    @ObservedObject var presenterObject = presenter

    var body: some View {
        VStack {
            ZStack {
                ImagePreview(image: $image)

                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            self.showPicker = true
                        }) {
                            Text("Change Photo")
                                .padding()
                        }
                    }
                    Spacer()
                }

                IntelligentConsoleView(output: $presenterObject.output)
            }
            IntelligenceCategoryView(presenterObject: presenterObject)
        }
        .onReceive(self.presenterObject.$output) { output in
            if let image = output.image {
                self.image = Image(uiImage: image)
            }
        }
        .onAppear {
            self.image = Image(uiImage: self.presenterObject.uiImage)
        }
        .sheet(isPresented: $showPicker, onDismiss: {
            self.image = Image(uiImage: self.presenterObject.uiImage)
            self.presenterObject.update(image: self.presenterObject.uiImage)

        }) {
            ImagePickerView(uiImage: self.$presenterObject.uiImage)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
