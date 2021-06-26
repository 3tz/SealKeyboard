//
//  KeyboardButton.swift
//  Keyboard
//
//  Created by tz on 6/26/21.
//

import Foundation
import UIKit


class KeyboardButton: UIButton {
  var label: UILabel!


  convenience init(keyname: String) {
    self.init(type: .custom)
    translatesAutoresizingMaskIntoConstraints = false
    accessibilityIdentifier = keyname
    backgroundColor = UIColor(white:0, alpha:0.01)
    label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.layer.masksToBounds = true
    label.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius
    label.textAlignment = .center

    self.insertSubview(label, at: 0)
    NSLayoutConstraint.activate([
      label.widthAnchor.constraint(
        equalTo: self.widthAnchor,
        constant: -KeyboardSpecs.horizontalSpacing
      ),
      label.heightAnchor.constraint(
        equalTo: self.heightAnchor,
        constant: -KeyboardSpecs.verticalSpacing
      ),
      label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
    ])

  }

  // MARK: Methods to only use the convenience UIButton.init(type:) while making Swift happy

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Other overrides

  override func setTitle(_ title: String?, for state: UIControl.State) { label.text = title }

  override func setImage(_ image: UIImage?, for state: UIControl.State) {
    label.backgroundColor = UIColor(patternImage: image!)
  }

  override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
    label.textColor = color
  }

  // MARK: class methods

  func setFontSize(_ fontSize: CGFloat) { label.font = label.font.withSize(fontSize) }

  func setBackgroundColor(_ color: UIColor) { label.backgroundColor = color }

  func setTintColor(_ color: UIColor) { label.tintColor = color }



}
