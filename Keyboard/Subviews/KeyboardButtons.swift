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
    ["spacer", "a", "s", "d", "f", "g","h", "j", "k", "l", "spacer"],
    ["shift", "spacer", "z", "x", "c", "v", "b", "n", "m", "spacer", "backspace"],
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

  var buttonsStackViews: [UIStackView] = []

  var mode: State!
  var shiftState: ShiftState!

  init() {
    mode = .alphabets
    shiftState = .off

    reloadButtons()
  }

  func getButtonsView() -> UIView{
    let view = UIStackView()

    view.axis = .vertical
    view.spacing = KeyboardSpecs.verticalSpacing

    for stackView in buttonsStackViews {
      view.addArrangedSubview(stackView)
    }


    // All normal buttons have the same size, so choose one of them and set constraints of
    //  other normal buttons based on that.
    let buttonWithStandardSize = buttonsStackViews[0].arrangedSubviews[0]
    // Same idea for spacers.
    var spacerView: UIView? = nil

    // Add constraints to buttons
    for rowStackView in buttonsStackViews {
      for subView in rowStackView.arrangedSubviews {
        guard let button = subView as? UIButton else {
          // It's a spacer UIView
          subView.heightAnchor.constraint(
            equalTo: buttonWithStandardSize.heightAnchor).isActive = true
          if spacerView == nil {
            spacerView = subView
          }
          subView.widthAnchor.constraint(equalTo: spacerView!.widthAnchor).isActive = true
          continue
        }
        // all buttons have the same height
        button.heightAnchor.constraint(
          equalTo: buttonWithStandardSize.heightAnchor).isActive = true

        // Calculate width of keys
        // Letters = Shift = Backspace = Numbers = Symbols \ {.,?!'} = #+=
        // Spacers = Spacers
        // Space = 5 * Letter + 4 * HorizonalSpacing
        // 123 = ABC = switch = (2.5 * Letter + HorizontalSpacing) / 2
        //     = 1.25 * Letter + 0.5 HorizontalSpacing
        let keyname = button.titleLabel!.text!

        switch keyname {
          case keyname where keyname.count == 1, "shift", "backspace":
              button.widthAnchor.constraint(
                equalTo: buttonWithStandardSize.widthAnchor).isActive = true
          case "space":
            button.widthAnchor.constraint(
              equalTo: buttonWithStandardSize.widthAnchor,
              multiplier: 5,
              constant: 4 * KeyboardSpecs.horizontalSpacing
            ).isActive = true
          case "123", "ABC", "switch":
              button.widthAnchor.constraint(
                equalTo: buttonWithStandardSize.widthAnchor,
                multiplier: 1.25,
                constant: 0.5 * KeyboardSpecs.horizontalSpacing
              ).isActive = true
          default:
            break
        }

      }
    }


    return view
  }

  func reloadButtons() {
    buttonsStackViews.removeAll()
    // Create the buttons
    for row in buttonLayout[mode.rawValue]! {
      var rowOfButtons: [UIView] = []
      for keyname in row {
        if keyname == "spacer" {
          let spacer = UIView()
          spacer.translatesAutoresizingMaskIntoConstraints = false
          rowOfButtons.append(spacer)
          continue
        }

        let button = UIButton(type: .system)
        button.setTitle(keyname, for: .normal)
        button.sizeToFit()
        button.backgroundColor = .blue
        button.titleLabel!.textColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        rowOfButtons.append(button)
      }
      let rowStackView = UIStackView(arrangedSubviews: rowOfButtons)
      rowStackView.axis = .horizontal
      rowStackView.spacing = KeyboardSpecs.horizontalSpacing
      rowStackView.alignment = .fill

      buttonsStackViews.append(rowStackView)
    }

  }


}
