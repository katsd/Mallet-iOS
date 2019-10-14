//
//  SwitchUISettingsController.swift
//  Mallet
//
//  Created by Katsu Matsuda on 2019/10/13.
//  Copyright © 2019 Katsu Matsuda. All rights reserved.
//

import UIKit

class SwitchUISettingsController: UISettingsController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override init(appID: Int, ui: EditorUI, uiData: UIData, uiSettingsDelegate: UISettingsDelegate, codeEditorControllerDelegate: CodeEditorControllerDelegate) {
        super.init(appID: appID, ui: ui, uiData: uiData, uiSettingsDelegate: uiSettingsDelegate, codeEditorControllerDelegate: codeEditorControllerDelegate)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func numberOfOtherSections() -> Int {
        return 2
    }

    override func titleForHeader(section: Int) -> String {
        switch section {
        case 1:
            return "Switch"
        case 2:
            return "Code"
        default:
            return ""
        }
    }

    override func numberOfRows(section: Int) -> Int {
        switch section {
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }

    override func cellForRow(cell: UITableViewCell, indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 1:
            let titleLabel = UILabel()
            let textField = UITextField()

            textField.delegate = self

            textField.autocapitalizationType = .none

            let textFieldEvent: UIControl.Event = .editingDidEnd

            switch indexPath.row {
            case 0:
                titleLabel.text = "Value"
                textField.text = String(uiData.switchData?.value ?? 0)
                textField.addTarget(self, action: #selector(self.setSwitchValue(_:)), for: textFieldEvent)

            default:
                break
            }

            setCellWithInput(cell: cell, titleLabel: titleLabel, textField: textField)

        case 2:
            cell.accessoryType = .disclosureIndicator
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Changed"
            default:
                break
            }

        default:
            break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 2 {
            let updateCodeClosure: ((String) -> Void)!
            let codeStr: String!
            let codeTitle: String!

            switch indexPath.row {
            case 0:
                updateCodeClosure = { (code) in
                    self.uiData.switchData?.code[.OnChange]?.code = code
                }
                codeStr = self.uiData.switchData?.code[.OnChange]?.code ?? ""
                codeTitle = "Changed"

            default:
                return
            }

            let storyboard = UIStoryboard(name: "CodeEditor", bundle: nil)

            guard let codeEditorController = storyboard.instantiateInitialViewController() as? CodeEditorController else {
                fatalError()
            }

            codeEditorController.codeEditorControllerDelegate = self.codeEditorControllerDelegate

            codeEditorController.updateCodeClosure = updateCodeClosure

            codeEditorController.codeStr = codeStr

            codeEditorController.codeTitle = codeTitle

            codeEditorController.appID = self.appID

            navigationController?.pushViewController(codeEditorController, animated: true)
        }


    }

    @objc private func setSwitchValue(_ textField: UITextField) {
        if (Int(textField.text ?? "0") ?? 0) > 0 {
            textField.text = "1"
            self.uiData.switchData?.value = 1
        } else {
            textField.text = "0"
            self.uiData.switchData?.value = 0
        }
        self.reload()
    }

    @objc private func setButtonFontSize(_ textField: UITextField) {
        self.uiData.buttonData?.fontSize = Int(textField.text ?? "") ?? 0
        self.reload()
    }

    @objc private func setButtonFontColor(_ textField: UITextField) {
        self.uiData.buttonData?.fontColor = textField.text ?? ""
        self.reload()
    }

    @objc private func setButtonBackgroundColor(_ textField: UITextField) {
        self.uiData.buttonData?.backgroundColor = textField.text ?? ""
        self.reload()
    }
}