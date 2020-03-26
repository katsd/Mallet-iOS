//
//  EditorAppView.swift
//  Mallet
//
//  Created by Katsu Matsuda on 2019/12/01.
//  Copyright © 2019 Katsu Matsuda. All rights reserved.
//

import SwiftUI

struct EditorAppView: View {

    @EnvironmentObject var editorViewModel: EditorViewModel

    @Binding var appViewScale: CGFloat

    var body: some View {
        ZStack {
            Color.white

            ForEach(editorViewModel.uiIDs, id: \.self) { id in
                EditorUIOverlayView(uiData: self.editorViewModel.getUIDataOf(id)) {
                    self.generateUI(id: id)
                }
                    .environmentObject(self.editorViewModel)
            }

            ForEach(editorViewModel.uiIDs, id: \.self) { id in
                Group {
                    if id == self.editorViewModel.selectedUIID {
                        UIFrameEditingView(uiData: self.editorViewModel.getUIDataOf(id),
                                           appViewScale: self.$appViewScale) {
                            self.generateUI(id: id)
                        }
                            .environmentObject(self.editorViewModel)
                    }
                }
            }
        }
            //.background(Color.white)
            .background(
                Color.white.opacity(0.001)
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: 2000, height: 2000)
                    .onTapGesture {
                        self.editorViewModel.deselectUI()
                    }
            )
            .edgesIgnoringSafeArea(.bottom)
            .colorScheme(.light)
            .onTapGesture {
                self.editorViewModel.deselectUI()
            }
    }

    func generateUI(id: Int) -> some View {

        let uiData = editorViewModel.getUIDataOf(id)

        let type = uiData.wrappedValue.uiType

        let frameData = uiData.wrappedValue.frameData

        let backgroundData = uiData.wrappedValue.backgroundData

        let uiView = Group {
            if type == .text {
                MUIText(uiData: uiData)
            } else if type == .button {
                MUIButton(uiData: uiData)
            } else if type == .textField {
                MUITextField(uiData: uiData)
            } else if type == .slider {
                MUISlider(uiData: uiData)
            } else if type == .toggle {
                MUIToggle(uiData: uiData)
            } else {
                MUISpace()
            }
        }

        return Group {
            if frameData.lockWidth && frameData.lockHeight {
                uiView
            } else if frameData.lockWidth {
                uiView
                    .frame(height: frameData.frame.height)
            } else if frameData.lockHeight {
                uiView
                    .frame(width: frameData.frame.width)
            } else {
                uiView
                    .frame(width: frameData.frame.width, height: frameData.frame.height)
            }
        }
            .background(backgroundData.color.toColor)
            .cornerRadius(backgroundData.cornerRadius)
    }
}
