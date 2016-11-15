//
//  GameBoard.swift
//  Chapter2
//
//  Created by Mauro Bolis on 15/11/2016.
//  Copyright © 2016 Bending Spoons. All rights reserved.
//

import Foundation
import Katana

struct GameBoard: NodeDescription {
  typealias PropsType = Props
  typealias StateType = EmptyState
  typealias NativeView = UIView
  typealias Keys = ChildrenKeys
  
  var props: PropsType
  
  static func childrenDescriptions(props: PropsType,
                                   state: StateType,
                                   update: @escaping (StateType) -> (),
                                   dispatch: @escaping StoreDispatch) -> [AnyNodeDescription] {
    
    return [
      View(props: View.Props.build {
        $0.backgroundColor = .red
        $0.frame = props.frame
      })
    ]
  }
}

extension GameBoard {
  enum ChildrenKeys {
  }
}

extension GameBoard {
  struct Props: NodeDescriptionProps {
    var frame: CGRect = .zero
    var key: String?
    var alpha: CGFloat = 1.0
  }
}
