//
//  File.swift
//  Seal
//
//  Created by tz on 8/11/21.
//

import Foundation
import UIKit

protocol HostAppTableViewItemizable {
  var leftLabelText: String { get }
  var rightLabelText: String { get }
  var accessoryType: UITableViewCell.AccessoryType { get }
  var leftLabelTextColor: UIColor? { get }

  func performAction(controller: ViewController)
}

extension HostAppTableViewItemizable {
  var rightLabelText: String {
    return ""
  }

  var accessoryType: UITableViewCell.AccessoryType {
    return .none
  }

  var leftLabelTextColor: UIColor? {
    return .none
  }
}
