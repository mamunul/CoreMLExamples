//
//  IntelligenceCategoryView.swift
//  CoreMLExamples
//
//  Created by Mamunul Mazid on 17/7/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import SwiftUI

struct IntelligenceCategoryView: View {
    @ObservedObject var presenter: MainPresenter
    private let selectedBGColor = Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.4)
    private let nonSelectedBGColor = Color.clear
    private let dividerHeight: CGFloat = 10

    var body: some View {
        VStack {
            Picker("Select an Intelligence", selection: $presenter.selectedIntelligent) {
                ForEach(presenter.intelligentArray, id: \.self) { intelligence in
                    Text(intelligence.name).tag(intelligence)
                }
            }
            .pickerStyle(.menu)
        }
        .onChange(of: presenter.selectedIntelligent) { oldValue, newValue in
            presenter.onIntelligenceSelection()
        }
    }
}

struct IntelligenceCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        IntelligenceCategoryView(presenter: MainPresenter())
    }
}
