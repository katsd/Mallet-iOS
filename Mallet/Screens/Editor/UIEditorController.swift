//
//  UIEditorController.swift
//  Mallet
//
//  Created by Katsu Matsuda on 2019/05/05.
//  Copyright © 2019 Katsu Matsuda. All rights reserved.
//

import UIKit

class UIEditorController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate, UINavigationControllerDelegate {
    @IBOutlet var editorView: UIView!
    @IBOutlet var uiTable: UITableView!

    @IBOutlet var UINameTextField: UITextField!
    @IBOutlet var UITextTextField: UITextField!

    var appData: AppData!
    var appName: String!

    var appScreen: UIView = UIView()

    var uiData: [UIData]?

    var uiDictionary = Dictionary<Int, UIView>()
    var uiNum = 0
    var selectedUIID = 0

    var uiScale: CGFloat = 1

    let uiTypeNum = UIType.allCases.count
    var UINumOfEachType = Dictionary<UIType, Int>()
    let uiTypeName = [UIType.Label: "Label",
                      UIType.Button: "Button",
                      UIType.Switch: "Switch"]

    var initialCode = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.delegate = self

        initUIEditor()

        generateScreen()
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is HomeViewController {
            (viewController as! HomeViewController).initAppStackView()
        }
    }

    func initUIEditor() {
        setupAppData()
        setupView()

        selectedUIID = -1

        for type in UIType.allCases {
            UINumOfEachType[type] = 0
        }
    }

    func setupAppData() {
        appName = appData.appName
    }

    func setupView() {
        navigationItem.title = appData.appName

        var screenSize = UIScreen.main.bounds.size
        if let navigationController = navigationController {
            screenSize.height -= navigationController.navigationBar.frame.size.height
        }

        appScreen = UIView()
        self.view.addSubview(appScreen)
        appScreen.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
                [
                    appScreen.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                    appScreen.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                    appScreen.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                    appScreen.rightAnchor.constraint(equalTo: self.view.rightAnchor)
                ]
        )

        appScreen.backgroundColor = UIColor.white

        uiTable.delegate = self
        uiTable.dataSource = self

        UINameTextField.text = ""
        UITextTextField.text = ""

        UINameTextField.addTarget(self, action: #selector(setUINameToValueOfTextField), for: .editingChanged)
        UITextTextField.addTarget(self, action: #selector(setUITextToValueOfTextField), for: .editingChanged)

        UINameTextField.delegate = self
        UITextTextField.delegate = self
    }

    func generateScreen() {
        for uiData in appData.uiData {
            let ui = generateEditorUI(uiType: uiData.uiType, uiID: uiData.uiID, uiName: uiData.uiName)
            appScreen.addSubview(ui)

            var appSampleUIData = ui as! EditorUIData
            appSampleUIData.uiID = uiData.uiID

            ui.center.x = uiData.x * uiScale
            ui.center.y = uiData.y * uiScale

            ui.isUserInteractionEnabled = true

            addGesture(ui: ui)

            setUIText(uiType: uiData.uiType, ui: ui, text: uiData.text)

            UINumOfEachType[uiData.uiType]! += 1

            uiDictionary[uiData.uiID] = ui

            switch uiData.uiType {
            case .Button:
                guard let editorUIButton = ui as? EditorUIButton else {
                    fatalError()
                }

                if uiData.code.count < 1 {
                    editorUIButton.tap = ""
                } else {
                    editorUIButton.tap = uiData.code[0]
                }

                break

            case .Label:
                break

            case .Switch:
                break
            }
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return uiTypeNum
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.selectionStyle = UITableViewCell.SelectionStyle.none

        let uiType: UIType!
        switch indexPath.row {
        case 0:
            uiType = .Label
        case 1:
            uiType = .Button
        case 2:
            uiType = .Switch
        default:
            uiType = .Label
        }

        let ui = generateEditorUI(uiType: uiType, uiID: -1, uiName: "")
        cell.addSubview(ui)

        ui.translatesAutoresizingMaskIntoConstraints = false
        ui.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        ui.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true

        ui.isUserInteractionEnabled = true

        addGesture(ui: ui)

        return cell
    }

    func addGesture(ui: UIView) {
        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragUI(_:)))
        pan.delegate = self
        ui.addGestureRecognizer(pan)

        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(moveToCode(_:)))
        doubleTap.delegate = self
        doubleTap.numberOfTapsRequired = 2
        ui.addGestureRecognizer(doubleTap)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectUI(_:)))
        tap.delegate = self
        tap.numberOfTapsRequired = 1
        tap.require(toFail: doubleTap)
        ui.addGestureRecognizer(tap)
    }

    @objc func moveToCode(_ sender: UILongPressGestureRecognizer) {
        if let senderSuperView = sender.view?.superview {
            if senderSuperView != appScreen {
                return
            }
        }

        self.view.endEditing(true)

        let storyboard = UIStoryboard(name: "CodeEditor", bundle: nil)

        guard let codeEditorController = storyboard.instantiateInitialViewController() as? CodeEditorController else {
            fatalError()
        }

        guard let uiData = sender.view as? EditorUIData else {
            print("This is not UI")
            fatalError()
        }

        codeEditorController.ui = sender.view

        codeEditorController.uiData = uiData

        switch uiData.uiType {
        case .Label:
            codeEditorController.codeStr = ""
        case .Button:
            guard let button = sender.view as? EditorUIButton else {
                print("This is not a button")
                fatalError()
            }

            // TODO:
            codeEditorController.codeStr = button.tap
        case .Switch:
            codeEditorController.codeStr = ""
        }

        navigationController?.pushViewController(codeEditorController, animated: true)
    }

    @objc func selectUI(_ sender: UITapGestureRecognizer) {
        guard let senderView = sender.view else {
            return
        }

        let uiData = senderView as! EditorUIData

        UINameTextField.text = uiData.uiName
        UITextTextField.text = getUIText(uiType: uiData.uiType, ui: senderView)

        selectedUIID = uiData.uiID
    }

    @objc func dragUI(_ sender: UIPanGestureRecognizer) {
        guard let ui = sender.view else {
            return
        }

        var uiData = ui as! EditorUIData

        if sender.state == .began {
            guard let superView = ui.superview else {
                return
            }

            if superView != appScreen {
                // 画面にUIを追加

                let uiType = uiData.uiType
                let uiOnTable = generateEditorUI(uiType: uiType, uiID: -1, uiName: "")
                uiOnTable.transform = CGAffineTransform(scaleX: uiScale, y: uiScale)
                superView.addSubview(uiOnTable)

                uiOnTable.translatesAutoresizingMaskIntoConstraints = false
                uiOnTable.centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
                uiOnTable.centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true

                uiOnTable.isUserInteractionEnabled = true

                addGesture(ui: uiOnTable)

                uiData.uiID = uiNum
                uiNum += 1
                UINumOfEachType[uiType]! += 1

                ui.translatesAutoresizingMaskIntoConstraints = true

                let center = ui.superview?.convert(ui.center, to: appScreen)
                appScreen.addSubview(ui)
                ui.center = center ?? CGPoint()

                let uiName = uiTypeName[uiType]! + String(UINumOfEachType[uiType]!)
                uiData.uiName = uiName

                uiDictionary[uiData.uiID] = ui
            }

            UINameTextField.text = (ui as! EditorUIData).uiName
            UITextTextField.text = getUIText(uiType: uiData.uiType, ui: ui)

            selectedUIID = uiData.uiID
        }

        let move = sender.translation(in: view)
        sender.view?.center.x += move.x
        sender.view?.center.y += move.y

        sender.setTranslation(CGPoint.zero, in: view)
    }

    func generateEditorUI(uiType: UIType, uiID: Int, uiName: String) -> UIView {
        var ui: UIView!

        switch uiType {
        case .Label:
            ui = EditorUILabel(uiID: uiID, uiName: uiName)
        case .Button:
            ui = EditorUIButton(uiID: uiID, uiName: uiName)
        case .Switch:
            ui = EditorUISwitch(uiID: uiID, uiName: uiName)
            (ui as! EditorUISwitch).isOn = true
        }

        ui.transform = CGAffineTransform(scaleX: uiScale, y: uiScale)

        return ui
    }

    @objc func setUINameToValueOfTextField(textField: UITextField) {
        if selectedUIID < 0 {
            return
        }

        var uiData = (uiDictionary[selectedUIID] as! EditorUIData)
        uiData.uiName = textField.text ?? ""
    }

    @objc func setUITextToValueOfTextField(textField _: UITextField) {
        if selectedUIID < 0 {
            return
        }

        guard let uiData = uiDictionary[selectedUIID] as? EditorUIData else {
            fatalError()
        }

        setUIText(uiType: uiData.uiType, ui: uiDictionary[selectedUIID]!, text: UITextTextField.text ?? "")

        uiDictionary[selectedUIID]!.sizeToFit()
    }

    func setUIText(uiType: UIType, ui: UIView, text: String) {
        switch uiType {
        case .Label:
            let label = ui as! UILabel
            label.text = text

        case .Button:
            let button = ui as! UIButton
            button.setTitle(text, for: .normal)

        default:
            break
        }
    }

    func getUIText(uiType: UIType, ui: UIView) -> String {
        switch uiType {
        case .Label:
            let label = ui as! UILabel
            return label.text ?? ""

        case .Button:
            let button = ui as! UIButton
            return button.titleLabel?.text ?? ""

        default:
            return ""
        }
    }

    func getUIValue(uiType _: UIType, ui _: UIView) -> Int {
        // TODO:
        return 0
    }

    func getUIScript(uiType: UIType, ui: UIView) -> String {
        //TODO:

        var script = ""

        switch uiType {
        case .Label:
            break

        case .Button:
            guard let button = ui as? EditorUIButton else {
                fatalError()
            }

            script += button.tap

        case .Switch:
            break
        }

        return script
    }

    func getUINameDeclarationCode() -> String {
        var code = """

                   """

        for ui in uiDictionary {
            guard let editorUIData = ui.value as? EditorUIData else {
                fatalError()
            }

            code += """
                    var \(editorUIData.uiName) = \(editorUIData.uiID)

                    """
        }

        return code
    }

    func generateAppData() -> AppData {
        var uiDataTable = [UIData]()

        var funcID = 1

        var code = """
                   \(getUINameDeclarationCode())

                   var global = 0

                   func init()
                   {
                   \(initialCode)
                   }

                   """


        let sortedUIDictionary = uiDictionary.sorted(by: { $0.key < $1.key })

        for ui in sortedUIDictionary {
            guard let editorUIData = ui.value as? EditorUIData else {
                fatalError()
            }

            let uiText = getUIText(uiType: editorUIData.uiType, ui: ui.value)

            let uiValue = getUIValue(uiType: editorUIData.uiType, ui: ui.value)

            var funcIDs = [Int]()

            var codes = [String]()

            switch editorUIData.uiType {
            case .Label:
                funcID += 1
            case .Button:
                funcIDs.append(funcID)
                funcID += 1

                guard let button = ui.value as? EditorUIButton else {
                    fatalError()
                }
                codes.append(button.tap)

            case .Switch:
                funcID += 1
                break
            }

            let uiData = UIData(
                    uiID: editorUIData.uiID,
                    uiName: editorUIData.uiName,
                    uiType: editorUIData.uiType,
                    text: uiText,
                    value: uiValue,
                    x: ui.value.center.x / uiScale,
                    y: ui.value.center.y / uiScale,
                    funcID: funcIDs,
                    code: codes
            )

            uiDataTable.append(uiData)
            code += """
                    func @\(editorUIData.uiID)_ ()
                    {
                    \(getUIScript(uiType: editorUIData.uiType, ui: ui.value))
                    }

                    """
        }

        let codeData = ConverterObjCpp().convertCode(code) ?? ""

        let appData = AppData(appName: appName, appID: self.appData.appID, uiData: uiDataTable, code: codeData)

        return appData
    }

    @IBAction func runButton(_: Any) {
        let storyboard = UIStoryboard(name: "AppRunner", bundle: nil)

        guard let appRunner = storyboard.instantiateInitialViewController() as? AppRunner else {
            fatalError()
        }

        appRunner.appData = generateAppData()

        navigationController?.pushViewController(appRunner, animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func SettingsButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "AppSettings", bundle: nil)

        guard let appSettingsController = storyboard.instantiateInitialViewController() as? AppSettingsController else {
            fatalError()
        }

        appSettingsController.uiEditorController = self

        navigationController?.present(appSettingsController, animated: true)
    }

    func setAppName(appName: String?) {
        guard let appName: String = appName else {
            return
        }

        self.appName = appName

        self.navigationItem.title = appName
    }

    func saveApp() {
        let appData = generateAppData()

        StorageManager.saveApp(appData: appData)
    }

    func addToHomeScreen() {
        AddShortcut.showShortcutScreen(appID: self.appData.appID, appName: self.appData.appName)
    }
}
