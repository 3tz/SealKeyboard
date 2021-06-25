//
//  Keyboard.swift
//  Keyboard
//
//  Created by tz on 6/22/21.
//

import Foundation
import UIKit

extension String {
  var isSingleAlphabet: Bool {
    return self.rangeOfCharacter(from: CharacterSet.letters.inverted) == nil &&
      !self.isEmpty &&
      self.count == 1
  }
  var isLowercasedAlphabet: Bool {
    return self.rangeOfCharacter(from: CharacterSet.lowercaseLetters.inverted) == nil &&
      !self.isEmpty
  }
  var isUppercasedAlphabet: Bool {
    return self.rangeOfCharacter(from: CharacterSet.uppercaseLetters.inverted) == nil &&
      !self.isEmpty
  }
}

let buttonLayout: [String: [[String]]] = [
  Keyboard.State.alphabets.rawValue: [
    ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
    ["spacer_1", "a", "s", "d", "f", "g","h", "j", "k", "l", "spacer_1"],
    ["shift", "spacer_2", "z", "x", "c", "v", "b", "n", "m", "spacer_2", "backspace"],
    ["123", "switch", "space", "return"]
  ],
  Keyboard.State.numbers.rawValue:[
    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0",],
    ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
    ["#+=", "spacer_2", ".", ",", "?", "!", "'", "spacer_2", "backspace"],
    ["ABC", "switch", "space", "return"]
  ],
  Keyboard.State.symbols.rawValue:[
    ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
    ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "·"],
    ["123", "spacer_2", ".", ",", "?", "!", "'", "spacer_2", "backspace"],
    ["ABC", "switch", "space", "return"]
  ]
]

let specialKeyNames = ["123", "ABC", "space", "return", "backspace", "switch", "#+=", "shift"]

class Keyboard{
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

//  var buttonsStackViews: [UIStackView] = []

  var mode: State!
  var shiftState: ShiftState!
  var shiftDoubleTapped: Bool = false

  var darkMode: Bool!
  var controller: KeyboardViewController!
  var view: UIStackView! = nil


  init(controller: KeyboardViewController, darkMode: Bool) {
    self.darkMode = darkMode
    self.controller = controller

    mode = .alphabets
    shiftState = .off
    view = getButtonsView()
  }

  func getButtonsView() -> UIStackView{
    if view != nil {
      return view
    }

    view = UIStackView()
    view.axis = .vertical
    view.spacing = KeyboardSpecs.verticalSpacing
    reloadButtonsAndLooks()
    return view
  }

  func reloadButtonsAndLooks() {
    reloadButtonsToView()
    updateConstraints()
    updateColors()
  }

  func updateConstraints() {
    // All normal buttons have the same size, so choose one of them and set constraints of
    //  other normal buttons based on that.
    let firstRow = view.arrangedSubviews[0] as! UIStackView
    let buttonWithStandardSize = firstRow.arrangedSubviews[0]

    // Same idea for spacers: spacers of the same row have the same width
    var spacerView: UIView? = nil
    var spacer2View: UIView? = nil

    // Add constraints to buttons
    for rowStackView in view.arrangedSubviews {
      for subView in (rowStackView as! UIStackView).arrangedSubviews {
        let keyname = subView.accessibilityIdentifier!

        guard let button = subView as? UIButton else {
          // It's a spacer UIView
          // spacers of the same row have the same width
          switch keyname {
            case "spacer_1":
              if spacerView == nil {
                spacerView = subView
              }
              subView.widthAnchor.constraint(equalTo: spacerView!.widthAnchor).isActive = true
            case "spacer_2":
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
          case "123", "ABC", "switch", "shift", "backspace", "#+=", ".", ",", "?", "!", "'":
              button.widthAnchor.constraint(
                equalTo: buttonWithStandardSize.widthAnchor,
                multiplier: 1.25,
                constant: 0.25 * KeyboardSpecs.horizontalSpacing
              ).isActive = true
          case keyname where keyname.count == 1:
            button.widthAnchor.constraint(
              equalTo: buttonWithStandardSize.widthAnchor).isActive = true
          case "space":
            button.widthAnchor.constraint(
              equalTo: buttonWithStandardSize.widthAnchor,
              multiplier: 5,
              constant: 4 * KeyboardSpecs.horizontalSpacing
            ).isActive = true
          default:
            break
        }
      }
    }
  }

  func updateColors() {
    updateColors(darkModeOn: darkMode)
  }

  func updateColors(darkModeOn: Bool) {
    darkMode = darkModeOn
    for rowStackView in view.arrangedSubviews {
      for subView in (rowStackView as! UIStackView).arrangedSubviews {
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

  func reloadButtonsToView() {
    for subview in view.subviews {
      subview.removeFromSuperview()
    }
    // Create the buttons
    for row in buttonLayout[mode.rawValue]! {
      var rowOfButtons: [UIView] = []
      for keyname in row {
        if keyname == "spacer_1" || keyname == "spacer_2" {
          let spacer = UIView()
          spacer.translatesAutoresizingMaskIntoConstraints = false
          spacer.accessibilityIdentifier = keyname
          rowOfButtons.append(spacer)
          continue
        }

        let button = UIButton(type: .custom)
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

        switch keyname {
          case "switch":
            button.addTarget(
              controller,
              action: #selector(controller.handleInputModeList(from:with:)),
              for: .allTouchEvents
            )
          case "shift":
            button.addTarget(
              self,
              action: #selector(shiftMutipleTouch(_:event:)),
              for: .touchDownRepeat
            )
            fallthrough
          default:
            button.addTarget(self, action: #selector(keyTouchUpInside), for: .touchUpInside)
        }

        rowOfButtons.append(button)
      }

      let rowStackView = UIStackView(arrangedSubviews: rowOfButtons)
      rowStackView.axis = .horizontal
      rowStackView.spacing = KeyboardSpecs.horizontalSpacing
      rowStackView.alignment = .fill

      view.addArrangedSubview(rowStackView)
    }

  }

  func toggleLettersCases(to newState: ShiftState) {
    if shiftState == newState { return }
    NSLog("Letter cases toggled from \(shiftState!) to \(newState)")
    shiftState = newState

    for rowStackView in view.arrangedSubviews {
      for subView in (rowStackView as! UIStackView).arrangedSubviews {
        guard let button = subView as? UIButton else { continue }
        var keyname = button.accessibilityIdentifier!
        if !keyname.isSingleAlphabet { continue }

        keyname = shiftState == .on || shiftState == .locked
          ? keyname.uppercased() : keyname.lowercased()
        button.accessibilityIdentifier = keyname
        button.setTitle(keyname, for: .normal)

      }
    }
  }

  @objc func keyTouchUpInside(_ sender:UIButton) {
    let keyname = sender.accessibilityIdentifier!

    // Clicking any key key while shift is on but not locked toggles shift back to off
    if shiftState == .on && keyname != "shift"{
      toggleLettersCases(to: .off)
      shiftDoubleTapped = false
    }

    switch keyname {
      case "space":
        controller.textDocumentProxy.insertText(" ")
      case "backspace":
        controller.textDocumentProxy.deleteBackward()
      case "shift":
        if !shiftDoubleTapped {
          switch shiftState {
            case .on:
              toggleLettersCases(to: .off)
            case .off:
              toggleLettersCases(to: .on)
            case .locked:
              toggleLettersCases(to: .off)
            default:
              fatalError()
          }
        }
        shiftDoubleTapped = false
      case "123":
        mode = .numbers
        reloadButtonsAndLooks()
      case "ABC":
        mode = .alphabets
        reloadButtonsAndLooks()
        toggleLettersCases(to: .off)
      case "return":
        break
      case "#+=":
        mode = .symbols
        reloadButtonsAndLooks()
      default:
        controller.textDocumentProxy.insertText(keyname)
    }
  }

  @objc func shiftMutipleTouch(_ sender: UIButton, event: UIEvent) {
    if event.allTouches!.first!.tapCount != 2 { return }
    // Let touchUpInside know that the touch up action this time is from doubletaps
    shiftDoubleTapped = true
    
    toggleLettersCases(to: .locked)
  }

}
