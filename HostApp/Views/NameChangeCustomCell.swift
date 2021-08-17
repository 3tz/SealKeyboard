//
//  NameChangeCustomCell.swift
//  Seal
//
//  Created by tz on 8/13/21.
//

import Foundation
import UIKit

class NameChangeCustomCell: UITableViewCell {
  var textField = UITextField()
  unowned var controller: NameChangeViewController?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.text = ""
    textField.textAlignment = .left
    textField.returnKeyType = .done
    textField.clearButtonMode = .always
    textField.delegate = self

    contentView.addSubview(textField)


    NSLayoutConstraint.activate([
      textField.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
      textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      textField.heightAnchor.constraint(equalTo: contentView.heightAnchor),
      textField.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


}

extension NameChangeCustomCell: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    let inputLength = textField.text!.count

    // Within the specified length requirement.
    // Save to UserDefaults and go back to the previous VC.
    if 0 < inputLength && inputLength < 16 {
      let userDefaults = UserDefaults(suiteName: "group.com.3tz.seal")!
      userDefaults.setValue(textField.text!, forKey: UserDefaultsKeys.chatDisplayName.rawValue)
      userDefaults.synchronize()
      textField.resignFirstResponder()
      controller!.navigationController!.popViewController(animated: true)
      return true
    } else {
      // Let user know what's wrong.
      let alertTitle: String
      let alertMessage: String

      if inputLength == 0 {
        alertTitle =  "Cannot Be Empty"
        alertMessage = "Display name cannot be empty."
      } else {
        alertTitle =  "Maximum Length Exceeded"
        alertMessage = "Display name must be shorter than 16 characters."
      }
      let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

      let okButton = UIAlertAction(title: "ok", style: .default)
      alert.addAction(okButton)
      controller!.present(alert, animated: true, completion: nil)
      return false
    }

  }

}
