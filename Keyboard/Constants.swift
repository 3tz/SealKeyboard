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
  static let superViewHeight = 330 as CGFloat,
    keyboardButtonsViewHeight = 220 as CGFloat,
    cryptoButtonsViewHeight = superViewHeight - keyboardButtonsViewHeight,

    superViewSpacing = 14 as CGFloat,

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

let buttonLayout: [String: [[String]]] = [
  Keyboard.State.alphabets.rawValue: [
    ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
    ["spacer_1", "a", "s", "d", "f", "g","h", "j", "k", "l", "spacer_1"],
    ["shift", "spacer_2", "z", "x", "c", "v", "b", "n", "m", "spacer_2", "backspace"],
    ["123", "switch", "space", "return"]
  ],
  Keyboard.State.numbers.rawValue:[
    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0",],
    ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
    ["#+=", "spacer_2", ".", ",", "?", "!", "'", "spacer_2", "backspace"],
    ["ABC", "switch", "space", "return"]
  ],
  Keyboard.State.symbols.rawValue:[
    ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
    ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "·"],
    ["123", "spacer_2", ".", ",", "?", "!", "'", "spacer_2", "backspace"],
    ["ABC", "switch", "space", "return"]
  ]
]

let specialKeyNames = [
  "123", "ABC", "space", "return", "backspace", "switch", "#+=", "shift"
]


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
