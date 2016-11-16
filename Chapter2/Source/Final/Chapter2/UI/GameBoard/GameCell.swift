//
//  GameCell.swift
//  Chapter2
//
//  Copyright © 2016 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation
import Katana
import KatanaElements

struct GameCell: NodeDescription, PlasticNodeDescription {
  typealias PropsType = Props
  typealias StateType = EmptyState
  typealias NativeView = UIView
  typealias Keys = ChildrenKeys
  
  var props: PropsType
  
  // 2
  static func childrenDescriptions(props: PropsType,
                                   state: StateType,
                                   update: @escaping (StateType) -> (),
                                   dispatch: @escaping StoreDispatch) -> [AnyNodeDescription] {
    
    var children: [AnyNodeDescription] = [
      Button(props: .gameCellButtonProps(
        isWinningCell: props.isWinningCell,
        didTap: nil,
        key: Keys.button)
      )
    ]
    
    if props.player != nil {
      let image = Image(props: .gameCellImage(player: props.player, key: Keys.image))
      children.append(image)
    }
    
    return children
  }
  
  // 3
  static func layout(views: ViewsContainer<Keys>,
                     props: PropsType,
                     state: StateType) {
    
    let nativeView = views.nativeView
    views[.image]?.fill(nativeView, insets: .scalable(10, 10, 10, 10))
    views[.button]?.fill(nativeView)
  }
}

extension GameCell {
  enum ChildrenKeys {
    case button, image
  }
}

extension GameCell {
  // 1
  struct Props: NodeDescriptionProps {
    var frame: CGRect = .zero
    var key: String?
    var alpha: CGFloat = 1.0
    
    var player: Player?
    var isWinningCell: Bool
    
    init(key: Any, player: Player?, isWinningCell: Bool) {
      self.player = player
      self.isWinningCell = isWinningCell
      self.setKey(key)
    }
  }
}
