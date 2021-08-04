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

  static let superViewSpacing = 0 as CGFloat,
    verticalSpacing = 14 as CGFloat,
    horizontalSpacing = 6 as CGFloat,
    buttonCornerRadius = 7 as CGFloat,

    standardFontSize = 25 as CGFloat,
    specialFontSize = 16 as CGFloat,

    bottomBarViewHeight = keyboardButtonsViewHeight / 4,
    chatViewHeight = keyboardButtonsViewHeight - bottomBarViewHeight,

    messageCellPopoverMenuHeight = 40 as CGFloat,
    messageCellPopoverMenuWidth = 60 as CGFloat

  static private let keyboardButtonsViewHeightPortrait = 230 as CGFloat,
    cryptoButtonsViewHeightPortrait = keyboardButtonsViewHeightPortrait / 4,
    superViewHeightPortrait = cryptoButtonsViewHeightPortrait + keyboardButtonsViewHeightPortrait + superViewSpacing,

    keyboardButtonsViewHeightLandscape = 180 as CGFloat,
    cryptoButtonsViewHeightLandscape = keyboardButtonsViewHeightLandscape / 4,
    superViewHeightLandscape = cryptoButtonsViewHeightLandscape + keyboardButtonsViewHeightLandscape + superViewSpacing


  static let maximumWidth = 694.0 as CGFloat

  static var isLandscape = false

  static var keyboardButtonsViewHeight: CGFloat {
    return isLandscape ? keyboardButtonsViewHeightLandscape : keyboardButtonsViewHeightPortrait
  }

  static var cryptoButtonsViewHeight: CGFloat {
    return isLandscape ? cryptoButtonsViewHeightLandscape : cryptoButtonsViewHeightPortrait
  }
  static var superViewHeight: CGFloat {
    return isLandscape ? superViewHeightLandscape : superViewHeightPortrait
  }

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

  static let topBarViewBackgroundColor = UIColor.systemGray5,
    chatViewBackgroundColor = UIColor.systemBackground,
    bottomBarViewBackgroundColor = UIColor.systemGray5

}

enum DefaultKeys: String {
  case previousPasteboardChangeCount
  case currentLayout
}

struct StatusText {
  static let ECDHInitialized = "ECDH initiated.",
    sealSuccessAndSent = "Text encrypted and sent.",
    sealSuccessButNotSent = "Textfield sealed. Ready to send.",
    sealFailureEmpty =  "Unable to seal message because input text field is empty.",
    sealFailureSymmetricAlgo = "Something went wrong. Unable to encrypt. Try again later.",
    sealFailureNoCurrentChatExists = "Cannot seal. No chat exists.",

    unsealFailureEmpty = "No copied text found.",
    unsealFailureParsingError = "Unknown type of message copied.",
    unsealFailureAuthenticationError = "Message signature verification failed.",
    unsealFailureNewSymmetricKeyAlreadyExists = "Cannot create a chat that already exists!",
    unsealFailureOtherError = "Unable to unseal. Unknown key or others.",
    unsealFailureNoCurrentChatExists = "Cannot unseal. No chat exists.",

    unsealSuccessReceivedECDH0 = "Request to generate symmetric key received.",
    unsealSuccessReceivedECDH1 = "Symmetric key generated.",
    unsealSuccessReceivedCiphertext = "Message Decrypted",

    messageCopied = "Message Copied."
}

// todo: placeholder
struct ChatView {
  static let senderMe = NSMessageSender(senderId: "s01", displayName: "me")
}

// todo: placeholder
struct Placeholder {
  static let name = "bob"
}
