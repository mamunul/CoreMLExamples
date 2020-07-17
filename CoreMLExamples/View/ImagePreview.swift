//
//  ImagePreview.swift
//  CoreMLExamples
//
//  Created by Mamunul Mazid on 17/7/20.
//  Copyright © 2020 Mamunul Mazid. All rights reserved.
//

import SwiftUI

struct ImagePreview: View {
    @Binding var image: Image?
    var body: some View {
        image?
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct ImagePreview_Previews: PreviewProvider {
    @State static var image: Image?
    static var previews: some View {
        ImagePreview(image: $image)
    }
}
