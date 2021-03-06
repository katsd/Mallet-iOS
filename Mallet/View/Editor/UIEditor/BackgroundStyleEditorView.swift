//
//  BackgroundStyleEditorView.swift
//  Mallet
//  
//  Created by Katsu Matsuda on 2020/03/14.
//  Copyright (c) 2020 Katsu Matsuda. All rights reserved.
//

import SwiftUI

struct BackgroundStyleEditorView: View {

    @Binding var backgroundData: MUIBackgroundData

    @Binding var showingSubEditor: Bool

    var body: some View {
        VStack(spacing: 0) {
            if backgroundData.enabled {
                ColorInputCell(color: $backgroundData.color, title: "Background Color", symbol: "paintpalette", showingSubEditor: $showingSubEditor)

                NumberInputCell(value: $backgroundData.cornerRadius, range: 0...10000, title: "Corner Radius", symbol: "square")
            }
        }
    }
}

extension BackgroundStyleEditorView: Equatable {

    static func ==(lhs: BackgroundStyleEditorView, rhs: BackgroundStyleEditorView) -> Bool {
        lhs.backgroundData == rhs.backgroundData &&
            lhs.showingSubEditor == rhs.showingSubEditor
    }

}
