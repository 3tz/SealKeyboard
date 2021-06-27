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
//    label.textAlignment = .center

    self.insertSubview(keycapBackground, at: 0)


    NSLayoutConstraint.activate([
      keycapBackground.widthAnchor.constraint(
        equalTo: self.widthAnchor,
        constant: -KeyboardSpecs.horizontalSpacing
      ),
      keycapBackground.heightAnchor.constraint(
        equalTo: self.heightAnchor,
        constant: -KeyboardSpecs.verticalSpacing
      ),
      keycapBackground.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      keycapBackground.centerYAnchor.constraint(equalTo: self.centerYAnchor),
    ])

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
      imageView.widthAnchor.constraint(equalTo: keycapBackground.widthAnchor, multiplier: 0.5),
      imageView.heightAnchor.constraint(equalTo: keycapBackground.heightAnchor, multiplier: 0.5),
      imageView.centerXAnchor.constraint(equalTo: keycapBackground.centerXAnchor),
      imageView.centerYAnchor.constraint(equalTo: keycapBackground.centerYAnchor),
    ])

  }

  func setFontSize(_ fontSize: CGFloat) {
    self.titleLabel!.font = self.titleLabel!.font.withSize(fontSize)
  }

  func setTintColor(_ color: UIColor) { self.tintColor = color }

  func setBackgroundColor(_ color: UIColor) { keycapBackground.backgroundColor = color }
}
