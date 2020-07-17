//
//  ContentView.swift
//  CoreMLExamples
//
//  Created by Mamunul Mazid on 16/7/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import SwiftUI

let mainPresenter = MainPresenter()

struct MainView: View {
    @State var image: Image?
    @State var showPicker = false

    @ObservedObject var presenter = mainPresenter

    var body: some View {
        VStack {
            ZStack {
                ImagePreview(image: $image)
                ActivityIndicatorView(isAnimating: self.$presenter.loading)
                ButtonView(showPicker: $showPicker, presenter: self.presenter)
                IntelligentConsoleView(output: $presenter.output)
            }
            IntelligenceCategoryView(presenter: presenter)
                .padding([.bottom, .top])
                .disabled(self.$presenter.loading.wrappedValue)
        }
        .onReceive(self.presenter.$output) { output in
            if let image = output.image {
                self.image = Image(uiImage: image)
            }
        }
        .onAppear {
            self.image = Image(uiImage: self.presenter.uiImage)
        }
        .sheet(isPresented: $showPicker, onDismiss: {
            self.image = Image(uiImage: self.presenter.uiImage)
            self.presenter.update(image: self.presenter.uiImage)

        }) {
            ImagePickerView(uiImage: self.$presenter.uiImage)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
