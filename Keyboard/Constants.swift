//
//  Constants.swift
//  Keyboard
//
//  Created by tz on 6/22/21.
//

import Foundation
import UIKit


struct KeyboardSpecs {
  static let buttonLayout: [String: [[String]]] = [
    TypingLayout.alphabets.rawValue: [
      ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
      ["spacer_1", "a", "s", "d", "f", "g","h", "j", "k", "l", "spacer_1"],
      ["shift", "spacer_2", "z", "x", "c", "v", "b", "n", "m", "spacer_2", "backspace"],
      ["123", "switch", "space", "return"]
    ],
    TypingLayout.numbers.rawValue:[
      ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0",],
      ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
      ["#+=", "spacer_2", ".", ",", "?", "!", "'", "spacer_2", "backspace"],
      ["ABC", "switch", "space", "return"]
    ],
    TypingLayout.symbols.rawValue:[
      ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
      ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "·"],
      ["123", "spacer_2", ".", ",", "?", "!", "'", "spacer_2", "backspace"],
      ["ABC", "switch", "space", "return"]
    ]
  ]

  static let specialKeyNames = [
    "123", "ABC", "space", "return", "backspace", "switch", "#+=", "shift", "seal"
  ]

  static let returnKeyTypeToString: [UIReturnKeyType: String] = [
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

  static let backspaceHeldDeleteInterval = 0.1

  static let superViewSpacing = 10 as CGFloat,

    superViewHeight = 270 as CGFloat, // 330 as CGFloat,
    keyboardButtonsViewHeight = 220 as CGFloat,
    cryptoButtonsViewHeight = superViewHeight - keyboardButtonsViewHeight - superViewSpacing,
    verticalSpacing = 14 as CGFloat,
    horizontalSpacing = 6 as CGFloat,
    buttonCornerRadius = 7 as CGFloat,

    standardFontSize = 25 as CGFloat,
    specialFontSize = 16 as CGFloat,

    bottomBarViewHeight = (keyboardButtonsViewHeight - 3 * verticalSpacing) / 4,
    chatViewHeight = keyboardButtonsViewHeight - bottomBarViewHeight

  static private let _specialFontSize: [String: CGFloat] = [
    "123": specialFontSize,
    "ABC": specialFontSize,
    "space": specialFontSize,
    "return": specialFontSize,
    "switch": specialFontSize,
    "#+=": specialFontSize,
    "seal": specialFontSize,
    "shift": 25,
    "backspace": 25,
  ]

  static let specialBackgroundDark = UIColor.darkGray,
    specialTitleDark = UIColor.white,
    regularBackgroundDark = UIColor.gray,
    regularTitleDark = UIColor.white,
    specialBackgroundLight = UIColor.lightGray,
    specialTitleLight = UIColor.black,
    regularBackgroundLight = UIColor.white,
    regularTitleLight = UIColor.black

  static let pressedRegularBackgroundLight = specialBackgroundLight,
    pressedRegularBackgroundDark = specialBackgroundDark,
    pressedSpecialBackgroundLight = regularBackgroundLight,
    pressedSpecialBackgroundDark = regularBackgroundDark

  static func fontSize(_ keyname: String) -> CGFloat {
    return _specialFontSize[keyname, default: standardFontSize]
  }
}

enum DefaultKeys: String {
  case previousPasteboardChangeCount
}
