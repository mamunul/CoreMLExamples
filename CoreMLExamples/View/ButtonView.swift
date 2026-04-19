//
//  ButtonView.swift
//  CoreMLExamples
//
//  Created by Mamunul Mazid on 17/7/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import SwiftUI

struct ButtonView: View {
    @Binding var showPicker: Bool
    @ObservedObject var presenter: MainPresenter
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    self.showPicker = true
                }) {
                    Text("Upload Photo")
                        .padding()
                }
                .disabled(self.$presenter.isLoading.wrappedValue)
            }
            Spacer()
        }
    }
}

struct ButtonView_Previews: PreviewProvider {
    @State static var showPicker = false
    static var previews: some View {
        ButtonView(showPicker: $showPicker, presenter: MainPresenter())
    }
}
