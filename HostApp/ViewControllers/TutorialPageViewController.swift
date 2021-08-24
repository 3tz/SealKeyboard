//
//  TutorialPageViewController.swift
//  Seal
//
//  Created by tz on 8/20/21.
//

import Foundation
import UIKit

class TutorialPageViewController: UIPageViewController {
  var pages: [UIViewController] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Tutorial"
//    navigationController?.navigationBar.prefersLargeTitles = true
    view.backgroundColor = .systemGroupedBackground
    dataSource = self
    // TOOD: placeholder
    pages.append(TutorialVideoViewController(color: .red))
    pages.append(TutorialVideoViewController(color: .blue))

    setViewControllers([pages.first!], direction: .forward, animated: true, completion: nil)
  }
}

extension TutorialPageViewController: UIPageViewControllerDataSource {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let index = pages.firstIndex(of: viewController) else {
      return nil
    }

    if viewController == pages.first {
      return pages.last
    }

    return pages[index - 1]
  }

  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let index = pages.firstIndex(of: viewController) else {
      return nil
    }

    if viewController == pages.last{
      return pages.first
    }

    return pages[index + 1]
  }

  func presentationCount(for pageViewController: UIPageViewController) -> Int {
    return pages.count
  }

  func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    return 0
  }
}
