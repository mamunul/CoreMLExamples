//
//  ActivityIndicatiorView.swift
//  Anonymous
//
//  Created by Mamunul Mazid on 23/4/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {
    @Binding var isAnimating: Bool

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.color = UIColor.black
        indicator.backgroundColor = UIColor.white
        return indicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Self>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct ActivityIndicatiorView_Previews: PreviewProvider {
    @State static var animating = true
    static var previews: some View {
        ActivityIndicatorView(isAnimating: $animating)
    }
}
