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
    ["shift", "spacer2", "z", "x", "c", "v", "b", "n", "m", "spacer2", "backspace"],
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

let specialKeyNames = ["123", "ABC", "space", "return", "backspace", "switch", "#+=", "shift"]

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
  var darkMode: Bool!

  init(darkMode: Bool) {
    mode = .alphabets
    shiftState = .off
    self.darkMode = darkMode

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

    // Same idea for spacers: spacers of the same row have the same width
    var spacerView: UIView? = nil
    var spacer2View: UIView? = nil

    // Add constraints to buttons
    for rowStackView in buttonsStackViews {
      for subView in rowStackView.arrangedSubviews {
        let keyname = subView.accessibilityIdentifier!

        guard let button = subView as? UIButton else {
          // It's a spacer UIView
          // spacers of the same row have the same width
          switch keyname {
            case "spacer":
              if spacerView == nil {
                spacerView = subView
              }
              subView.widthAnchor.constraint(equalTo: spacerView!.widthAnchor).isActive = true
            case "spacer2":
              if spacer2View == nil {
                spacer2View = subView
              }
              subView.widthAnchor.constraint(equalTo: spacer2View!.widthAnchor).isActive = true
            default:
              fatalError()
          }
          subView.heightAnchor.constraint(
            equalTo: buttonWithStandardSize.heightAnchor).isActive = true
          continue
        }
        // all buttons have the same height
        button.heightAnchor.constraint(
          equalTo: buttonWithStandardSize.heightAnchor).isActive = true

        // Calculate width of keys
        // Letters = Symbols \ {.,?!'}
        // Spacers_of_row_i = Spacers_of_row_i
        // Space = 5 * Letter + 4 * HorizonalSpacing
        // 123 = ABC = switch = Shift = Backspace = Numbers = #+=
        //     = [(10-5) * Letter + (9-6-2) * HorizontalSpacing] / 4
        //     = 1.25 * Letter + 0.25 * horizontal Spacing

        switch keyname {
          case keyname where keyname.count == 1:
            button.widthAnchor.constraint(
              equalTo: buttonWithStandardSize.widthAnchor).isActive = true
          case "space":
            button.widthAnchor.constraint(
              equalTo: buttonWithStandardSize.widthAnchor,
              multiplier: 5,
              constant: 4 * KeyboardSpecs.horizontalSpacing
            ).isActive = true
          case "123", "ABC", "switch", "shift", "backspace", "#+=":
              button.widthAnchor.constraint(
                equalTo: buttonWithStandardSize.widthAnchor,
                multiplier: 1.25,
                constant: 0.25 * KeyboardSpecs.horizontalSpacing
              ).isActive = true
          default:
            break
        }
      }
    }


    return view
  }

  func turnOnDarkMode(_ state: Bool) {
    darkMode = state
    for rowStackView in buttonsStackViews {
      for subView in rowStackView.arrangedSubviews {
        guard let button = subView as? UIButton else {
          // It's a spacer UIView
          continue
        }
        let keyname = button.accessibilityIdentifier!

        if specialKeyNames.contains(keyname) && keyname != "space" {
          button.backgroundColor = darkMode ? .darkGray : .lightGray
          if keyname == "switch" {
            button.tintColor = darkMode ? .white : .black
          } else {
            button.setTitleColor(darkMode ? .white : .black, for: [])
          }

        } else {
          button.backgroundColor = darkMode ? .gray : .white
          button.setTitleColor(darkMode ? .white : .black, for: [])
        }
      }
    }
  }

  func reloadButtons() {
    buttonsStackViews.removeAll()
    // Create the buttons
    for row in buttonLayout[mode.rawValue]! {
      var rowOfButtons: [UIView] = []
      for keyname in row {
        if keyname == "spacer" || keyname == "spacer2" {
          let spacer = UIView()
          spacer.translatesAutoresizingMaskIntoConstraints = false
          spacer.accessibilityIdentifier = keyname
          rowOfButtons.append(spacer)
          continue
        }

        let button = UIButton(type: .system)
        button.accessibilityIdentifier = keyname

        // Assign display char
        // Special symbols: ⇧ ⇪  ⌫
        switch keyname {
          case "shift":
            button.setTitle("⇧", for: .normal)
          case "backspace":
            button.setTitle("⌫", for: .normal)
          case "switch":
            button.setImage(UIImage(systemName: "globe"), for: .normal)
          default:
            button.setTitle(keyname, for: .normal)
        }

        button.titleLabel!.font = button.titleLabel!.font.withSize(
          KeyboardSpecs.fontSize(keyname)
        )

        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = KeyboardSpecs.buttonCornerRadius
        rowOfButtons.append(button)
      }

      // Modify button colors based on darkmode or not
      turnOnDarkMode(darkMode)

      let rowStackView = UIStackView(arrangedSubviews: rowOfButtons)
      rowStackView.axis = .horizontal
      rowStackView.spacing = KeyboardSpecs.horizontalSpacing
      rowStackView.alignment = .fill

      buttonsStackViews.append(rowStackView)
    }

  }


}
