//
//  ContentView.swift
//  CoreMLExamples
//
//  Created by Mamunul Mazid on 16/7/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import PhotosUI
import SwiftUI

struct LoadingView: View {
    let text: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.8)
                    .tint(.white)

                Text(text)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.8))
            )
        }
    }
}

struct ModelSelectionView: View {
    @ObservedObject var presenter: MainPresenter
    private let selectedBGColor = Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.4)
    private let nonSelectedBGColor = Color.clear
    private let dividerHeight: CGFloat = 10

    var body: some View {
        VStack {
            Picker("Select a Model", selection: $presenter.selectedModel) {
                ForEach(presenter.modelOptions, id: \.self) { model in
                    Text(model.modelFileName).tag(model)
                }
            }
            .pickerStyle(.menu)
        }
        .onChange(of: presenter.selectedModel) { _, _ in
            presenter.onModelSelection()
        }
    }
}

struct MainView: View {
    @State var image: Image?
    @State var showPicker = false
    @State var selectedItem: PhotosPickerItem?
    @StateObject var presenter = MainPresenter()

    var body: some View {
        VStack {
            ZStack {
                ImagePreview(image: $image)
                if presenter.isLoading {
                    LoadingView(text: "Loading...")
                }
                ButtonView(showPicker: $showPicker, presenter: self.presenter)
                IntelligentConsoleView(output: $presenter.output)
            }
            IntelligenceCategoryView(presenter: presenter)
                .padding([.bottom, .top])
                .disabled(self.$presenter.isLoading.wrappedValue)
            ModelSelectionView(presenter: presenter)
                .padding([.bottom, .top])
                .disabled(self.$presenter.isLoading.wrappedValue)
        }
        .onReceive(self.presenter.$output) { output in
            if let image = output.image {
                self.image = Image(uiImage: image)
            }
        }
        .photosPicker(isPresented: $showPicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try await newItem.loadTransferable(type: Data.self),
                   let uiimage = UIImage(data: data) {
                    self.image = Image(uiImage: uiimage)
                    presenter.update(image: uiimage)
                    showPicker = false
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
