//
//  AppRunner.swift
//  Mallet
//
//  Created by Katsu Matsuda on 2019/04/22.
//  Copyright © 2019 Katsu Matsuda. All rights reserved.
//

import UIKit

@objcMembers
class AppRunner: UIViewController, UINavigationControllerDelegate {
    @IBOutlet var appView: UIView!

    var appData: AppData?

    var appUI: Dictionary<Int, AppUI> = Dictionary()

    private let runner = RunnerObjCpp()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.delegate = self

        InitRunner()
    }

    private func InitRunner() {
        guard let appData = self.appData else {
            print("appData is nil")
            fatalError()
        }

        navigationItem.title = appData.appName

        GenerateAppScreen()

        print(appData.code)

        runner.initRunner(appData.code)
    }

    private func GenerateAppScreen() {
        guard let uiData = appData?.uiData else {
            fatalError()
        }

        ScreenGenerator().generateScreen(inputUIData: uiData, appView: appView)
    }

    func CallFunc(id: Int) {
        runner.runCode(Int32(id))
    }

    func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }

    func navigationController(_: UINavigationController, willShow viewController: UIViewController, animated _: Bool) {
        if !(viewController is AppRunner) {
            runner.terminateRunner()
        }
    }

    func SetUIText(id: Int, text: String) {
        DispatchQueue.main.async {
            guard let appRunner = self.topViewController() as? AppRunner else {
                return
            }

            if let uiData = appRunner.appUI[id]?.getUIData() {

                switch uiData.uiType {
                case .Label:
                    uiData.labelData?.text = text
                    print(text)

                case .Button:
                    uiData.buttonData?.text = text

                default:
                    //TODO:
                    break
                }

                appRunner.appUI[id]?.reloadUI()
            }
        }
    }
}
