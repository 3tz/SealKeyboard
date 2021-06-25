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
    buttonCornerRadius = 7 as CGFloat,

    standardFontSize = 25 as CGFloat,
    specialFontSize = 16 as CGFloat

  static private let _specialFontSize: [String: CGFloat] = [
    "123": specialFontSize,
    "ABC": specialFontSize,
    "space": specialFontSize,
    "return": specialFontSize,
    "switch": specialFontSize,
    "#+=": specialFontSize,
    "shift": 25,
    "backspace": 25,
  ]

  static func fontSize(_ keyname: String) -> CGFloat {
    return _specialFontSize[keyname, default: standardFontSize]
  }

}

let returnKeyTypeToString: [UIReturnKeyType: String] = [
  .default: "default",
  .go: "go",
  .google: "google",
  .join: "join",
  .next: "next",
  .route: "route",
  .search: "search",
  .send: "send",
  .yahoo: "yahoo",
  .done: "done",
  .emergencyCall: "emergencyCall",
  .continue: "continue",
]
