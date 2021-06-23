//
//  Keyboard.swift
//  Keyboard
//
//  Created by tz on 6/22/21.
//

import Foundation
import UIKit

let buttonLayout: [String: [[String]]] = [
  Keyboard.State.alphabets.rawValue: [
    ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
    ["a", "s", "d", "f", "g","h", "j", "k", "l"],
    ["shift", "z", "x", "c", "v", "b", "n", "m", "backspace"],
    ["123", "switch", "space", "return"]
  ],
  Keyboard.State.numbers.rawValue:[
    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0",],
    ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
    ["#+=", ".", ",", "?", "!", "'", "⌫"],
    ["ABC", "switch", "space", "return"]
  ],
  Keyboard.State.symbols.rawValue:[
    ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
    ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "·"],
    ["123",".", ",", "?", "!", "'", "⌫"],
    ["ABC", "switch", "space", "return"]
  ]
]

class Keyboard {
  enum State: String {
    case alphabets
    case numbers
    case symbols
  }

  enum ShiftState: Int {
    case off
    case on
    case locked
  }

//  var currentView: UIView!
//  var buttons: [[UIButton]] = []
  var buttons: [[UIStackView]] = []


  var mode: State!
  var shiftState: ShiftState!

  init() {
    mode = .alphabets
    shiftState = .off

    reloadButtons()
  }

  func getButtonsView() -> UIView{
    let view = UIView(
      frame: CGRect(x: 0, y:0, width: UIScreen.main.bounds.size.width, height: keyboardButtonsViewHeight)
    )
    NSLog("height: \(view.bounds.height)")
    view.tag = ViewTag.KeyboardButtons.rawValue

    for row in buttons {
      for button in row {
        view.addSubview(button)
      }
    }

    let buttonCharQ = buttons[0][0]

    // Add constraints to buttons
    for (rowIdx, row) in buttons.enumerated() {
      for (colIdx, button) in row.enumerated() {

        // Set left anchors
        if colIdx == 0 { // Left most buttons anchor to view
          button.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        } else { // Non-left most buttons anchor to buttons on their left
          let buttonOnLeft = row[colIdx-1]
          button.leftAnchor.constraint(equalTo: buttonOnLeft.rightAnchor).isActive = true
        }
        // Set top anchors
        if rowIdx == 0 { // Top most buttons anchor to view
          button.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        } else { // Non-top buttons anchors to row on their top
          let buttonOnTop = buttons[rowIdx-1][0]
          button.topAnchor.constraint(equalTo: buttonOnTop.bottomAnchor).isActive = true
        }
        // Set right anchors
        if colIdx == row.count - 1 { // Right most buttons anchor to view
          button.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        }
        // Set bottom anchors
        if rowIdx == buttons.count - 1 { // Bottom most buttons anchor to view
          button.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }

        // Make all characters have the same width
        if button.titleLabel?.text?.count == 1 {
          button.widthAnchor.constraint(equalTo: buttonCharQ.widthAnchor).isActive = true
        }

        // all buttons have the same height
        button.heightAnchor.constraint(equalTo: buttonCharQ.heightAnchor).isActive = true


      }
    }
//    view.translatesAutoresizingMaskIntoConstraints = false

    return view
  }

  func reloadButtons() {
    buttons.removeAll()
    // Create the buttons
    for (rowIdx, row) in buttonLayout[mode.rawValue]!.enumerated() {
      buttons.append([])
      for keyname in row {
        let button = UIButton(type: .system)
        button.setTitle(keyname, for: .normal)
        button.sizeToFit()
        button.backgroundColor = .blue
        button.titleLabel!.textColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        buttons[rowIdx].append(button)
      }
    }

  }


}
