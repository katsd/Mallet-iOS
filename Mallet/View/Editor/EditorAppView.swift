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
        GeometryReader { geo in
            ZStack {
                Color.white

                grid(screenSize: geo.size)

                ForEach(editorViewModel.uiIDs, id: \.self) { id in
                    EditorUIOverlayView(uiData: editorViewModel.getUIDataOf(id), appViewGeo: geo) {
                        MUI.generateView(uiData: editorViewModel.getUIDataOf(id), screenSize: geo.size)
                    }
                        .environmentObject(editorViewModel)
                }

                if let id = editorViewModel.selectedUIID {
                    if id != MUI.none.uiID {
                        UIFrameEditingView(uiData: editorViewModel.getUIDataOf(id),
                                           appViewScale: self.$appViewScale,
                                           appViewGeo: geo) {
                            MUI.generateView(uiData: editorViewModel.getUIDataOf(id), screenSize: geo.size)
                        }
                            .environmentObject(editorViewModel)
                    }
                }
            }
                .background(
                    Color.white.opacity(0.001)
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: 2000, height: 2000)
                        .onTapGesture {
                            editorViewModel.deselectUI()
                        }
                )
                .colorScheme(.light)
                .onTapGesture {
                    editorViewModel.deselectUI()
                }
        }
    }

    private func grid(screenSize: CGSize) -> some View {
        let padding = EditorAppViewInfo.gridRectPadding(screenSize: screenSize)
        let spacerHeight = EditorAppViewInfo.gridSpacerHeight(screenSize: screenSize, rectPadding: padding)

        return VStack(spacing: 0) {
            subGrid(gridHeight: EditorAppViewInfo.gridHeight1, padding: padding)
            Spacer()
                .frame(height: spacerHeight)
            subGrid(gridHeight: EditorAppViewInfo.gridHeight2, padding: padding)
        }
    }

    private func subGrid(gridHeight: Int, padding: CGFloat) -> some View {
        ForEach(0..<gridHeight) { _ in
            HStack(spacing: 0) {
                ForEach(0..<EditorAppViewInfo.gridWidth) { _ in
                    Rectangle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .frame(width: EditorAppViewInfo.gridRectSize, height: EditorAppViewInfo.gridRectSize)
                        .overlay(
                            GeometryReader { geo in
                                if let selectedUIGlobalFrame = editorViewModel.selectedUIGlobalFrame {
                                    if geo.frame(in: .global).intersects(selectedUIGlobalFrame) {
                                        Color.blue.opacity(0.1)
                                    }
                                }
                            }
                        )
                        .padding(padding)
                }
            }
        }
    }

}
