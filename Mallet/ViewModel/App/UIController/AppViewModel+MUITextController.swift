//
//  AppViewModel+MUITextController.swift
//  Mallet
//  
//  Created by Katsu Matsuda on 2020/05/05.
//  Copyright (c) 2020 Katsu Matsuda. All rights reserved.
//

import SwiftUI
import XyloSwift

extension AppViewModel: MUITextController {

    func setText(args: [XyObj]) -> XyObj {
        getUIData(args[0]).textData.text.wrappedValue = args[1].string()
        return .zero
    }

    func getText(args: [XyObj]) -> XyObj {
        XyObj(getUIData(args[0]).textData.text.wrappedValue)
    }

    func setTextColor(args: [XyObj]) -> XyObj {
        let ui = getUIData(args[0])
        if ui.textData.enabled.wrappedValue {
            getUIData(args[0]).textData.color.wrappedValue = MUIColor(args[1].string())

        }
        if ui.textFieldData.enabled.wrappedValue {
            getUIData(args[0]).textFieldData.color.wrappedValue = MUIColor(args[1].string())
        }
        return .zero
    }

    func getTextColor(args: [XyObj]) -> XyObj {
        let ui = getUIData(args[0])
        if ui.textData.enabled.wrappedValue {
            return XyObj(getUIData(args[0]).textData.color.wrappedValue.hexCode(withAlpha: true))
        }
        if ui.textFieldData.enabled.wrappedValue {
            return XyObj(getUIData(args[0]).textFieldData.color.wrappedValue.hexCode(withAlpha: true))
        }
        return .zero
    }

    func setTextSize(args: [XyObj]) -> XyObj {
        getUIData(args[0]).textData.size.wrappedValue = CGFloat(args[1].float())
        return .zero
    }

    func getTextSize(args: [XyObj]) -> XyObj {
        XyObj(Double(getUIData(args[0]).textData.size.wrappedValue))
    }

    func setTextAlignment(args: [XyObj]) -> XyObj {
        fatalError("setTextAlignment(args:) has not been implemented")
    }

    func getTextAlignment(args: [XyObj]) -> XyObj {
        fatalError("getTextAlignment(args:) has not been implemented")
    }

    var muiTextFuncs: [Xylo.Func] {
        [
            Xylo.Func(funcName: "setText", argNum: 2, setText),
            Xylo.Func(funcName: "getText", argNum: 1, getText),
            Xylo.Func(funcName: "setTextColor", argNum: 2, setTextColor),
            Xylo.Func(funcName: "getTextColor", argNum: 1, getTextColor),
            Xylo.Func(funcName: "setTextSize", argNum: 2, setTextSize),
            Xylo.Func(funcName: "getTextSize", argNum: 1, getTextSize),
            Xylo.Func(funcName: "setTextAlignment", argNum: 2, setTextAlignment),
            Xylo.Func(funcName: "getTextAlignment", argNum: 1, getTextAlignment),
        ]
    }

}
