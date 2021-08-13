//
//  NameChange.swift
//  Seal
//
//  Created by tz on 8/11/21.
//

import Foundation
import UIKit

class NameChange: HostAppTableViewItemizable {
  var leftLabelText = "Your Display Name"
  var rightLabelText = "<Placeholder>"
  var accessoryType: UITableViewCell.AccessoryType = .disclosureIndicator

  func performAction(controller: ViewController) {
    let vc = NameChangeViewController(style: .grouped)
    controller.navigationController?.pushViewController(vc, animated: true)
  }
}
