//
//  SceneDelegate.swift
//  Seal
//
//  Created by tz on 6/12/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    // Open Seal Keyboard page in Settings if the host app is invoked through URL with
    //   path == "settings"
    if let url = URLContexts.first?.url {
      guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let path = components.path else {
        return
      }
      if path == "settings" {
        UIApplication.shared.open(
          URL(string: UIApplication.openSettingsURLString)!,
          options: [:],
          completionHandler: nil
        )
      }
    }
  }

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Open Seal Keyboard page in Settings if the host app is invoked through URL with
    //   path == "settings"
    if let url = connectionOptions.urlContexts.first?.url {
      guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let path = components.path else {
        return
      }
      if path == "settings" {
        UIApplication.shared.open(
          URL(string: UIApplication.openSettingsURLString)!,
          options: [:],
          completionHandler: nil
        )
      }
    }

    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(frame: windowScene.coordinateSpace.bounds)
    window?.windowScene = windowScene

    let navigationViewController = UINavigationController()
    let viewController = ViewController(style: .grouped)
    navigationViewController.viewControllers = [viewController]
    window?.rootViewController = navigationViewController
    window?.makeKeyAndVisible()

  }

  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }

  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }


}

