//
//  CryptoButtons.swift
//  Keyboard
//
//  Created by tz on 6/22/21.
//

import Foundation
import UIKit

func getCryptoButtonsView() -> UIView {
  // Add request and decrypt keys to view
  let view = UIView(
    frame: CGRect(
      x: 0, y:0, width: UIScreen.main.bounds.size.width, height: cryptoButtonsViewHeight
    )
  )

  let requestButton = UIButton(type: .system)
  requestButton.setTitle("Request", for: .normal)
  requestButton.sizeToFit()
  requestButton.backgroundColor = .red
  requestButton.titleLabel!.textColor = .white
  requestButton.translatesAutoresizingMaskIntoConstraints = false

  let unsealButton = UIButton(type: .system)
  unsealButton.setTitle("Unseal Copied Text", for: .normal)
  unsealButton.sizeToFit()
  unsealButton.backgroundColor = .red
  unsealButton.titleLabel!.textColor = .white
  unsealButton.translatesAutoresizingMaskIntoConstraints = false

  view.addSubview(requestButton)
  view.addSubview(unsealButton)

  NSLayoutConstraint.activate([
    requestButton.leftAnchor.constraint(equalTo: view.leftAnchor),
    requestButton.topAnchor.constraint(equalTo: view.topAnchor),
    requestButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    unsealButton.leftAnchor.constraint(equalTo: requestButton.rightAnchor),
    unsealButton.topAnchor.constraint(equalTo: view.topAnchor),
    unsealButton.rightAnchor.constraint(equalTo: view.rightAnchor),
    unsealButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
  ])

  view.translatesAutoresizingMaskIntoConstraints = false
  return view

}
