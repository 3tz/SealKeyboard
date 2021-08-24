//
//  Tutorial.swift
//  Seal
//
//  Created by tz on 8/24/21.
//

import Foundation
import UIKit

class TutorialHostAppItem: HostAppTableViewItemizable {
  var leftLabelText: String = "Tutorial"
  unowned var controller: ViewController

  init(controller: ViewController) {
    self.controller = controller
  }

  func performAction(controller: ViewController) {
    let vc = TutorialPageViewController(
      transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    controller.present(vc, animated: true, completion: nil)
  }
}
