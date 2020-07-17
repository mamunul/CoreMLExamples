//
//  IntelligenceCategoryView.swift
//  CoreMLExamples
//
//  Created by Mamunul Mazid on 17/7/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import SwiftUI

struct IntelligenceCategoryView: View {
    @ObservedObject var presenterObject: Presenter
    private let selectedBGColor = Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.2)
    private let nonSelectedBGColor = Color.clear
    private let dividerHeight: CGFloat = 10
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(presenterObject.intelligentArray, id: \.self) { intelligent in
                    HStack {
                        Text(intelligent.name)
                            .background(self.getBindingInstance(intelligent).wrappedValue.isSelected ? self.selectedBGColor : self.nonSelectedBGColor)
                        Divider().frame(height: self.dividerHeight)
                    }
                    .onTapGesture {
                        self.getBindingInstance(intelligent).wrappedValue.isSelected = true
                        self.presenterObject.update(intelligent: intelligent)
                    }
                }
            }
        }
    }
    
    func getBindingInstance(_ intelligent: Intelligent) -> Binding<Intelligent> {
        $presenterObject.intelligentArray[presenterObject.intelligentArray.firstIndex(of: intelligent)!]
    }
}

struct IntelligenceCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        IntelligenceCategoryView(presenterObject: Presenter())
    }
}
