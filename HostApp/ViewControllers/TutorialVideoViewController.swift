//
//  TutorialVideoViewController.swift
//  Seal
//
//  Created by tz on 8/23/21.
//

import AVFoundation
import UIKit

class TutorialVideoViewController: UIViewController {
  var videoView: UIView!
  var descriptionView: UIView!
  var color: UIColor!
  var player: AVQueuePlayer!
  var looperPlayer: AVPlayerLooper!

  convenience init(color: UIColor) {
    self.init()
    self.color = color
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    videoView = UIView()
    videoView.translatesAutoresizingMaskIntoConstraints = false
    descriptionView = UIView()
    descriptionView.translatesAutoresizingMaskIntoConstraints = false
    descriptionView.backgroundColor = color

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

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if player != nil {
      player.seek(to: CMTime.zero)
      player.play()
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    player.pause()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let path = Bundle.main.path(forResource: "1-messaging", ofType: "mp4")!
    let url = URL(fileURLWithPath: path)
    let item = AVPlayerItem(asset: AVAsset(url: url))
    player = AVQueuePlayer(playerItem: item)
    looperPlayer = AVPlayerLooper(player: player, templateItem: item)
    // Add player to view as a layer.
    let layer = AVPlayerLayer(player: player)
    layer.frame = videoView.bounds
    layer.videoGravity = .resizeAspect
    videoView.layer.addSublayer(layer)
    player.play()
  }
}
