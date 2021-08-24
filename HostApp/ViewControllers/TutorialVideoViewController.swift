//
//  TutorialVideoViewController.swift
//  Seal
//
//  Created by tz on 8/23/21.
//

import Foundation
import UIKit

class TutorialVideoViewController: UIViewController {
  var videoView: UIView!
  var descriptionView: UIView!
  var color: UIColor!

  convenience init(color: UIColor) {
    self.init()
    self.color = color
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    videoView = UIView()
    videoView.translatesAutoresizingMaskIntoConstraints = false
    videoView.backgroundColor = color
    descriptionView = UIView()
    descriptionView.translatesAutoresizingMaskIntoConstraints = false
    descriptionView.backgroundColor = .green

    view.addSubview(videoView)
    view.addSubview(descriptionView)

    NSLayoutConstraint.activate([
      videoView.topAnchor.constraint(equalTo: view.topAnchor),
      videoView.leftAnchor.constraint(equalTo: view.leftAnchor),
      videoView.rightAnchor.constraint(equalTo: view.rightAnchor),
      videoView.bottomAnchor.constraint(equalTo: descriptionView.topAnchor),
      descriptionView.leftAnchor.constraint(equalTo: view.leftAnchor),
      descriptionView.rightAnchor.constraint(equalTo: view.rightAnchor),
      descriptionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      videoView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8),
    ])

  }
}
