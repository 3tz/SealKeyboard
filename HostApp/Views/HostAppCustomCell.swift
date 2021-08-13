//
//  HostAppCustomCell.swift
//  Seal
//
//  Created by tz on 8/12/21.
//

import Foundation
import UIKit

class HostAppCustomCell: UITableViewCell {
  var leftLabel = UILabel()
  var rightLabel = UILabel()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    leftLabel.translatesAutoresizingMaskIntoConstraints = false
    leftLabel.textAlignment = .left
    contentView.addSubview(leftLabel)

    rightLabel.translatesAutoresizingMaskIntoConstraints = false
    rightLabel.textAlignment = .right
    rightLabel.textColor = .systemGray
    contentView.addSubview(rightLabel)

    NSLayoutConstraint.activate([
      leftLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
      leftLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      leftLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor),

      rightLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
      rightLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      rightLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor),

      leftLabel.trailingAnchor.constraint(equalTo: rightLabel.leadingAnchor),
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
