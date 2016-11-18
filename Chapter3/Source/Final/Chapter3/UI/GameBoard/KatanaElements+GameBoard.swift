//
//  KatanaElements+GameBoard.swift
//  Chapter3
//
//  Copyright © 2016 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation
import UIKit
import KatanaElements

extension Label.Props {
  
  /// Return the props for the label that displays the player score
  ///
  /// - parameter content:    the content of the label
  /// - parameter key:        the key to associate with the element
  /// - parameter shouldPlay: true if the label is associated with the player that should move next
  static func gameBoardLabelProps<K>(content: String, key: K, shouldPlay: Bool) -> Label.Props {
    var props = Label.Props()
    props.textAlignment = .center
    props.backgroundColor = .clear
    
    if shouldPlay {
      props.backgroundColor = .flatYellow()
      props.borderWidth = .scalable(2)
      props.borderColor = UIColor(white: 0, alpha: 0.5)
    }
    
    props.text = NSAttributedString(string: content, attributes: [
      NSForegroundColorAttributeName: UIColor.black,
      NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 20.0)!
    ])
    
    props.setKey(key)
    
    return props
  }
  
  
  /// Return the props for the loading label
  ///
  /// - parameter key: the to associate with the element
  static func loadingLabelProps<K>(key: K) -> Label.Props {
    var props = Label.Props()
    props.textAlignment = .center
    props.backgroundColor = .clear
    
    props.text = NSAttributedString(string: "Loading...", attributes: [
      NSForegroundColorAttributeName: UIColor.white,
      NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 20.0)!
    ])
    
    props.setKey(key)
    
    return props
  }
}

extension Image.Props {
  
  /// Return the props for the cell image
  ///
  /// - parameter player: the player that has choosen the cell in the current game, if any
  /// - parameter key:    the key to associate with the element
  static func gameCellImage<K>(player: Player?, key: K) -> Image.Props {
    var props = Image.Props()
    
    if let player = player {
      switch player {
      case .one:
        props.image = #imageLiteral(resourceName: "circle")
      default:
        props.image = #imageLiteral(resourceName: "cross")
      }
    }
    
    props.backgroundColor = .clear
    props.setKey(key)
    
    return props
  }
}

extension Button.Props {
  
  /// Return the props for the start button
  ///
  /// - parameter title:  the title of the button
  /// - parameter key:    the key to associate with the element
  /// - parameter didTap: a closure that is invoked when the button is tapped
  static func startButtonProps<K>(title: String, key: K, didTap: (() -> ())?) -> Button.Props {
    var props = Button.Props()
    
    props.setKey(key)
    props.backgroundColor = .flatLightGreen()
    props.borderColor = .flatDarkGreen()
    props.borderWidth = .scalable(2)
    props.cornerRadius = .scalable(10)
    
    props.attributedTitles = [
      .normal: NSAttributedString(string: title, attributes: [
        NSForegroundColorAttributeName: UIColor.black,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 20.0)!
      ]),
      
      .highlighted: NSAttributedString(string: title, attributes: [
        NSForegroundColorAttributeName: UIColor.black.withAlphaComponent(0.5),
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 20.0)!
      ])
    ]
    
    if let didTap = didTap {
      props.touchHandlers = [
        .touchUpInside: didTap
      ]
    }
    
    return props
  }
  
  
  /// Return the props for the load/save score button
  ///
  /// - parameter title:  the title of the button
  /// - parameter key:    the key to associate with the element
  /// - parameter didTap: a closure that is invoked when the button is tapped
  static func loadSaveButtonProps<K>(title: String, key: K, didTap: @escaping () -> ()) -> Button.Props {
    var props = Button.Props()
    
    props.setKey(key)
    props.backgroundColor = .flatLightOrange()
    props.borderColor = .flatDarkOrange()
    props.borderWidth = .scalable(2)
    props.cornerRadius = .scalable(10)
    
    props.attributedTitles = [
      .normal: NSAttributedString(string: title, attributes: [
        NSForegroundColorAttributeName: UIColor.black,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 18.0)!
        ]),
      
      .highlighted: NSAttributedString(string: title, attributes: [
        NSForegroundColorAttributeName: UIColor.black.withAlphaComponent(0.5),
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 18.0)!
        ])
    ]
    
    props.touchHandlers = [
      .touchUpInside: didTap
    ]
    
    return props
  }
  
  
  /// Return the props for the button tha handles the board cell tap
  ///
  /// - parameter isWinningCell: true if the cell is part of the winning line
  /// - parameter didTap:        a closure that is invoked when the button is invoked
  /// - parameter key:           the key to associate with the element
  static func gameCellButtonProps<K>(isWinningCell: Bool, didTap: (() -> ())?, key: K) -> Button.Props {
    var props = Button.Props()
    
    props.backgroundColor = isWinningCell
      ? .flatLightGreen()
      : .white
    
    props.borderColor = .black
    props.borderWidth = .scalable(1)
    props.setKey(key)
    
    if let didTap = didTap {
      props.touchHandlers = [.touchUpInside: didTap]
    }
    
    return props
  }
}
