//
//  NameChange.swift
//  Seal
//
//  Created by tz on 8/11/21.
//

import Foundation
import UIKit

class NameChange: HostAppTableViewItemizable {
  var leftLabelText: String = ""
  var rightLabelText: String = ""
  var accessoryType: UITableViewCell.AccessoryType = .disclosureIndicator
  unowned var controller: ViewController

  func performAction(controller: ViewController) {
    let vc = NameChangeViewController(style: .grouped)
    controller.navigationController?.pushViewController(vc, animated: true)
  }

  init(controller: ViewController) {
    self.controller = controller
    leftLabelText = "Your Display Name"
    rightLabelText = getChatDisplayName()
  }

  private func getChatDisplayName() -> String {
    let userDefaults = UserDefaults(suiteName: "group.com.3tz.seal")!

    if let displayName = userDefaults.string(forKey: UserDefaultsKeys.chatDisplayName.rawValue) {
      return displayName
    } else {
      // Display name is empty, so initialize.
      let alertMessage = """
      This will be UNENCRYPTED and shown on all messages.
      Must be shorter than 16 characters.
      """
      let alert = UIAlertController(
        title: "Set your display name", message: alertMessage, preferredStyle: .alert)
      // Save to UserDefaults and reload VC
      let saveAction = UIAlertAction(title: "save", style: .default) { [unowned self] _ in
        let input = alert.textFields![0].text
        userDefaults.setValue(input, forKey: UserDefaultsKeys.chatDisplayName.rawValue)
        userDefaults.synchronize()
        self.controller.reloadData()
      }
      alert.addAction(saveAction)
      // Save button is only enabled if it's within the specified length limits.
      alert.addTextField(configurationHandler: { (textField) in
        textField.text = ""
        saveAction.isEnabled = false
        NotificationCenter.default.addObserver(
        forName: UITextField.textDidChangeNotification,
        object: textField,
        queue: OperationQueue.main) { (notification) in
          let inputLength = textField.text!.count
          if 0 < inputLength && inputLength < 16 {
          saveAction.isEnabled = true
          } else {
          saveAction.isEnabled = false
          }
        }
      })
      controller.present(alert, animated: true, completion: nil)
      // Leave the cell empty for now. Once it's saved, it will refresh and load.
      return ""
    }
  }
}
