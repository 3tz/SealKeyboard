//
//  CryptoButtons.swift
//  Keyboard
//
//  Created by tz on 6/22/21.
//

import Foundation
import UIKit

func getCryptoButtonsView() -> UIStackView {
  let requestButton = UIButton(type: .system)
  requestButton.setTitle("Request", for: .normal)
  requestButton.sizeToFit()
  requestButton.backgroundColor = .systemBlue
  requestButton.setTitleColor(.white, for: [])
  requestButton.translatesAutoresizingMaskIntoConstraints = false
  requestButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius

  let unsealButton = UIButton(type: .system)
  unsealButton.setTitle("Unseal Copied Text", for: .normal)
  unsealButton.sizeToFit()
  unsealButton.backgroundColor = .systemBlue
  unsealButton.setTitleColor(.white, for: [])
  unsealButton.translatesAutoresizingMaskIntoConstraints = false
  unsealButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius

  let sealButton = UIButton(type: .system)
  sealButton.setTitle("Seal Message Field Text", for: .normal)
  sealButton.sizeToFit()
  sealButton.backgroundColor = .systemBlue
  sealButton.setTitleColor(.white, for: [])
  sealButton.translatesAutoresizingMaskIntoConstraints = false
  sealButton.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius

  let view = UIStackView(arrangedSubviews: [requestButton, unsealButton, sealButton])
  view.axis = .horizontal
  view.spacing = KeyboardSpecs.horizontalSpacing
  view.distribution = .fillProportionally

  return view

}
