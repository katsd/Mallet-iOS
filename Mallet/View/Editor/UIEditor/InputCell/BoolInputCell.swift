//
//  BoolInputCell.swift
//  Mallet
//  
//  Created by Katsu Matsuda on 2020/03/15.
//  Copyright (c) 2020 Katsu Matsuda. All rights reserved.
//

import SwiftUI

struct BoolInputCell: View {

    @Binding private var value: Bool

    private let title: String

    private let symbol: String?

    init(value: Binding<Bool>, title: String, symbol: String? = nil) {
        self._value = value
        self.title = title
        self.symbol = symbol
    }

    var body: some View {
        ListCell {
            HStack {
                if let symbol = symbol {
                    Image(systemName: symbol)
                }
                Text(title)
                Spacer()
                Toggle("", isOn: self.$value)
                    .labelsHidden()
            }
        }
    }
}
