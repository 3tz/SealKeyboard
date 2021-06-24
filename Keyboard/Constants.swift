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
  static let superViewHeight = 270 as CGFloat,
    cryptoButtonsViewHeight = 50 as CGFloat,
    keyboardButtonsViewHeight = superViewHeight - cryptoButtonsViewHeight,

    superViewSpacing = 5 as CGFloat,

    verticalSpacing = 14 as CGFloat,
    horizontalSpacing = 6 as CGFloat,
    buttonCornerRadius = 8 as CGFloat,

    standardFontSize = 25 as CGFloat,
    specialFontSize = 16 as CGFloat

}
