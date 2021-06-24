//
//  Constants.swift
//  Keyboard
//
//  Created by tz on 6/22/21.
//

import Foundation
import UIKit




enum MessageType: String {
  case ECDH0
  case ECDH1
  case ciphertext
}

struct KeyboardSpecs {
  static let superViewSpacing = 5 as CGFloat
  static let verticalSpacing = 10 as CGFloat
  static let horizontalSpacing = 4 as CGFloat

  static let superViewHeight = 270 as CGFloat
  static let cryptoButtonsViewHeight = 30 as CGFloat
  static let keyboardButtonsViewHeight = superViewHeight - cryptoButtonsViewHeight
}
