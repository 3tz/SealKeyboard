//
//  Constants.swift
//  Keyboard
//
//  Created by tz on 6/22/21.
//

import Foundation
import UIKit

let keyboardViewHeight: CGFloat = 270 as CGFloat
let cryptoButtonsViewHeight: CGFloat = 30 as CGFloat
let keyboardButtonsViewHeight: CGFloat = keyboardViewHeight - cryptoButtonsViewHeight


enum MessageType: String {
  case ECDH0
  case ECDH1
  case ciphertext
}

enum ViewTag: Int {
  case KeyboardButtons
}
