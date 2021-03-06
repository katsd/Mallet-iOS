//
//  SemiModalView.swift
//  Mallet
//  
//  Created by Katsu Matsuda on 2020/03/07.
//  Copyright (c) 2020 Katsu Matsuda. All rights reserved.
//

import SwiftUI

struct SemiModalView<Content: View>: View
    where Content: Equatable {

    let content: () -> Content

    @Binding var offset: CGFloat

    @State private var dragGestureCurrentTranslationHeight: CGFloat = 0

    @State private var dragGestureDiffHeight: CGFloat = 0

    private let height: CGFloat

    private let minHeight: CGFloat

    private var maxOffset: CGFloat

    private let minOffset: CGFloat = 0

    private let controlBarHeight: CGFloat

    private let cornerRadius: CGFloat = 10

    init(height: CGFloat, minHeight: CGFloat, controlBarHeight: CGFloat = 30, offset: Binding<CGFloat> = .constant(0), @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.height = height + controlBarHeight
        self.minHeight = minHeight + controlBarHeight
        self.controlBarHeight = controlBarHeight
        self._offset = offset
        maxOffset = self.height - self.minHeight
    }

    var body: some View {
        GeometryReader { geo in
            VStack {
                VStack {
                    Rectangle()
                        .frame(width: 40, height: 4)
                        .cornerRadius(2)
                        .foregroundColor(Color(.systemGray3))
                }
                    .frame(height: controlBarHeight)

                content()
                    .equatable()
            }
                .background(Blur(style: .systemThickMaterial))
                .cornerRadius(cornerRadius)
                .shadow(color: Color.black.opacity(0.1), radius: 3)
                .overlay(
                    ZStack {
                        VStack {
                            Spacer()
                            Color(.tertiarySystemBackground)
                                .frame(height: cornerRadius)
                        }

                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color(.opaqueSeparator), lineWidth: 0.2)
                    }
                )
                .gesture(DragGesture(minimumDistance: 0)
                             .onChanged({ value in
                                 dragGestureOnChanged(value: value)
                             })
                             .onEnded({ _ in
                                 dragGestureOnEnded()
                             })
                )
                .onAppear {
                    self.offset = minOffset
                }
                .edgesIgnoringSafeArea(.bottom)
                .frame(height: height)
                .position(x: geo.size.width / 2,
                          y: geo.size.height + height / 2 - minHeight)
                .offset(y: -offset)
        }
    }

    private func dragGestureOnChanged(value: DragGesture.Value) {
        self.dragGestureDiffHeight = value.translation.height - dragGestureCurrentTranslationHeight
        self.dragGestureCurrentTranslationHeight = value.translation.height

        self.offset =
            max(minOffset,
                min(maxOffset, offset - value.translation.height))
    }

    private func dragGestureOnEnded() {
        if abs(dragGestureDiffHeight) < 2 {
            if offset > (maxOffset + minOffset) / 2 {
                openModalView()
            } else {
                closeModalView()
            }
            return
        }

        if dragGestureDiffHeight < 0 {
            openModalView()
        } else {
            closeModalView()
        }

    }

    private func openModalView() {
        withAnimation(.easeOut(duration: 0.2)) {
            offset = maxOffset
        }
    }

    func closeModalView() {
        withAnimation(.easeOut(duration: 0.2)) {
            offset = minOffset
        }
    }
}
