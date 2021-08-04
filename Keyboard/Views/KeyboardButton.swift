//
//  KeyboardButton.swift
//  Keyboard
//
//  Created by tz on 6/26/21.
//

import Foundation
import UIKit


class KeyboardButton: UIButton {
  var keycapBackground: UILabel!

  convenience init(keyname: String) {
    self.init(type: .custom)
    translatesAutoresizingMaskIntoConstraints = false
    accessibilityIdentifier = keyname
    backgroundColor = UIColor(white:0, alpha:0.01)

    keycapBackground = UILabel()
    keycapBackground.translatesAutoresizingMaskIntoConstraints = false
    keycapBackground.layer.masksToBounds = true
    keycapBackground.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius

    self.insertSubview(keycapBackground, at: 0)


    NSLayoutConstraint.activate([
      keycapBackground.widthAnchor.constraint(
        equalTo: self.widthAnchor,
        constant: -KeyboardSpecs.horizontalSpacing
      ),
      keycapBackground.heightAnchor.constraint(
        equalTo: self.heightAnchor,
        multiplier: 0.75
      ),
      keycapBackground.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      keycapBackground.centerYAnchor.constraint(equalTo: self.centerYAnchor),
    ])

    setFontSize(KeyboardSpecs.fontSize(keyname))
    sizeToFit()

  }

  // MARK: Methods to only use the convenience UIButton.init(type:) while making Swift happy

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Methods to change displaying character & backgruond

  override func setImage(_ image: UIImage?, for state: UIControl.State) {
    let imageView = UIImageView(image: image)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(imageView)

    NSLayoutConstraint.activate([
      imageView.heightAnchor.constraint(equalTo: keycapBackground.heightAnchor, multiplier: 0.5),
      imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
      imageView.centerXAnchor.constraint(equalTo: keycapBackground.centerXAnchor),
      imageView.centerYAnchor.constraint(equalTo: keycapBackground.centerYAnchor),
    ])

  }

  func setFontSize(_ fontSize: CGFloat) {
    self.titleLabel!.font = self.titleLabel!.font.withSize(fontSize)
  }

  override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
    // Language mode switch key uses a system image instead of text
    if self.accessibilityIdentifier == "switch" {
      self.tintColor = color
    } else {
      super.setTitleColor(color, for: state)
    }
  }

  func setBackgroundColor(_ color: UIColor) { keycapBackground.backgroundColor = color }

  func setDarkModeState(_ darkMode: Bool) {
    let keyname = self.accessibilityIdentifier!

    let (backgroundColor, titleColor) = getKeyColors(
      keyname: keyname, darkMode: darkMode
    )

    setBackgroundColor(backgroundColor)
    setTitleColor(titleColor, for: [])
  }

  func setKeyColor(pressed: Bool, darkMode: Bool) {
    let backgroundColor: UIColor!
    let keyname = self.accessibilityIdentifier!

    if pressed {
      backgroundColor = getPressedKeyBackgroundColors(
        keyname: keyname, darkMode: darkMode)
    } else {
      (backgroundColor, _) = getKeyColors(
        keyname: keyname, darkMode: darkMode
      )
    }
    setBackgroundColor(backgroundColor)
  }

  func getPressedKeyBackgroundColors(keyname: String, darkMode: Bool) -> UIColor{
    switch keyname {
      case "backspace", "return", "seal":
        return darkMode ? KeyboardSpecs.pressedSpecialBackgroundDark :
          KeyboardSpecs.pressedSpecialBackgroundLight
      default:
        return darkMode ? KeyboardSpecs.pressedRegularBackgroundDark :
          KeyboardSpecs.pressedRegularBackgroundLight
    }
  }

  func getKeyColors(keyname: String, darkMode: Bool) -> (UIColor, UIColor){
    switch keyname {
      case "seal":
        return (.systemBlue, .white)
      case keyname where KeyboardSpecs.specialKeyNames.contains(keyname) && keyname != "space":
        // special buttons except for space have a darker color
        return (
          (darkMode ? KeyboardSpecs.specialBackgroundDark : KeyboardSpecs.specialBackgroundLight),
          (darkMode ? KeyboardSpecs.specialTitleDark : KeyboardSpecs.specialTitleLight)
        )
      default:
        // regular input buttons
        return (
          (darkMode ? KeyboardSpecs.regularBackgroundDark : KeyboardSpecs.regularBackgroundLight),
          (darkMode ? KeyboardSpecs.regularTitleDark : KeyboardSpecs.regularTitleLight)
        )
    }
  }
}
