//
//  EditorAppView.swift
//  Mallet
//
//  Created by Katsu Matsuda on 2019/12/01.
//  Copyright © 2019 Katsu Matsuda. All rights reserved.
//

import SwiftUI

struct EditorAppView: View {

    @Binding var uiData: [MUI]

    var body: some View {
        ZStack {
            ForEach(0..<uiData.count) { index in
                self.generateUI(index: index)
            }
        }
            .background(Color.white)
            .colorScheme(.light)
    }

    func generateUI(index: Int) -> some View {

        let ui = uiData[index]

        let uiType = ui.uiType

        return MEditorFrameView (frame: $uiData[index].frame) {
            if uiType == .text {
                MUIText()
            }
            else if uiType == .button {
                MUIButton()
            }
            else if uiType == .input {
                MUIInput()
            }
            else if uiType == .slider {
                MUISlider()
            }
            else if uiType == .toggle {
                MUIToggle()
            }
            else {
                fatalError()
            }
        }
    }
}

struct EditorAppView_Previews: PreviewProvider {
    static var previews: some View {
        EditorAppView(uiData: .constant([]))
    }
}
