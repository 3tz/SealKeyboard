//
//  MessageCellLongPressMenuViewController.swift
//  Seal
//
//  Created by tz on 7/23/21.
//

import Foundation
import UIKit

class MessageCellLongPressMenuViewController: UIViewController {
  var stackView: UIStackView!

  override func loadView() {
    super.loadView()

    let darkMode = traitCollection.userInterfaceStyle == .dark
    view.backgroundColor = darkMode ? UIColor.darkGray : UIColor.black
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let copyButton = UIButton(type: .system)
    copyButton.setTitle("Copy", for: .normal)
    copyButton.sizeToFit()
    copyButton.setTitleColor(.white, for: .normal)
    copyButton.backgroundColor = .clear
    copyButton.translatesAutoresizingMaskIntoConstraints = false

    stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 0 // TODO: placeholder
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.alignment = .center
    stackView.distribution = .fillProportionally
    stackView.backgroundColor = .clear
    stackView.layoutIfNeeded()
    stackView.addArrangedSubview(copyButton)

    view.addSubview(stackView)

  }

  override func updateViewConstraints() {
    super.updateViewConstraints()
    let guide = view.safeAreaLayoutGuide

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: guide.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
      stackView.leftAnchor.constraint(equalTo: guide.leftAnchor),
      stackView.rightAnchor.constraint(equalTo: guide.rightAnchor),
    ])
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    let darkMode = traitCollection.userInterfaceStyle == .dark
    view.backgroundColor = darkMode ? UIColor.darkGray : UIColor.black
  }

}
