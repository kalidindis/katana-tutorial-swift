//
//  GameBoard.swift
//  Chapter3
//
//  Copyright © 2016 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation
import Katana
import KatanaElements

enum Player {
  case one, two
}

struct GameBoard: NodeDescription, PlasticReferenceSizeable, PlasticNodeDescription {
  typealias PropsType = Props
  typealias StateType = EmptyState
  typealias NativeView = UIView
  typealias Keys = ChildrenKeys
  
  static var referenceSize = CGSize(width: 320, height: 568)
  var props: PropsType
  
  static func childrenDescriptions(props: PropsType,
                                   state: StateType,
                                   update: @escaping (StateType) -> (),
                                   dispatch: @escaping StoreDispatch) -> [AnyNodeDescription] {
    
    let winningLine = props.winningLine ?? []
    
    var children: [AnyNodeDescription] = [
      View(props: View.Props.build {
        $0.backgroundColor = .flatLightGrey()
        $0.setKey(Keys.background)
      }),
      
      Label(props: .gameBoardLabelProps(content: "Player one: \(props.player1Score)", key: Keys.player1Score, shouldPlay: props.turn == .one)),
      
      Label(props: .gameBoardLabelProps(content: "Player two: \(props.player2Score)", key: Keys.player2Score, shouldPlay: props.turn == .two)),
      
      GameCell(props: GameCell.Props(key: Keys.cell1, player: props.board[0], isWinningCell: winningLine.contains(0))),
      
      GameCell(props: GameCell.Props(key: Keys.cell2, player: props.board[1], isWinningCell: winningLine.contains(1))),
      
      GameCell(props: GameCell.Props(key: Keys.cell3, player: props.board[2], isWinningCell: winningLine.contains(2))),
      
      GameCell(props: GameCell.Props(key: Keys.cell4, player: props.board[3], isWinningCell: winningLine.contains(3))),
      
      GameCell(props: GameCell.Props(key: Keys.cell5, player: props.board[4], isWinningCell: winningLine.contains(4))),
      
      GameCell(props: GameCell.Props(key: Keys.cell6, player: props.board[5], isWinningCell: winningLine.contains(5))),
      
      GameCell(props: GameCell.Props(key: Keys.cell7, player: props.board[6], isWinningCell: winningLine.contains(6))),
      
      GameCell(props: GameCell.Props(key: Keys.cell8, player: props.board[7], isWinningCell: winningLine.contains(7))),
      
      GameCell(props: GameCell.Props(key: Keys.cell9, player: props.board[8], isWinningCell: winningLine.contains(8))),
    ]
    
    if props.isGameFinished {
      let startButton = Button(props: .startButtonProps(
        title: "New Game",
        key: Keys.startButton,
        didTap: nil
        ))
      
      children.append(startButton)
    }
    
    return children
  }
  
  static func layout(views: ViewsContainer<Keys>, props: PropsType, state: StateType) {
    let nativeView = views.nativeView
    let player1Score = views[.player1Score]!
    let player2Score = views[.player2Score]!
    let background = views[.background]!
    
    // background
    background.fill(nativeView)
    
    // player 1 score
    player1Score.fillHorizontally(nativeView, insets: .scalable(0, 15, 0, 15))
    player1Score.setTop(nativeView.top, offset: .scalable(30))
    player1Score.height = .scalable(40)
    
    // player 2 score
    player2Score.fillHorizontally(nativeView, insets: .scalable(0, 15, 0, 15))
    player2Score.top = player1Score.bottom
    player2Score.height = .scalable(40)
    
    // start button
    let startButton = views[.startButton]
    startButton?.asFooter(nativeView, insets: .scalable(0, 10, 10, 10))
    startButton?.height = .scalable(40)
    
    // matrix cells, first row
    let firstRow = [views[.cell1]!, views[.cell2]!, views[.cell3]!]
    
    firstRow.fill(left: nativeView.left, right: nativeView.right)
    for cell in firstRow {
      cell.height = cell.width
      cell.setTop(player2Score.bottom, offset: .scalable(10))
    }
    
    // matrix cells, second row
    let secondRow = [views[.cell4]!, views[.cell5]!, views[.cell6]!]
    
    secondRow.fill(left: nativeView.left, right: nativeView.right)
    for cell in secondRow {
      cell.height = cell.width
      cell.top = firstRow[0].bottom
    }
    
    // matrix cells, third row
    let thirdRow = [views[.cell7]!, views[.cell8]!, views[.cell9]!]
    
    thirdRow.fill(left: nativeView.left, right: nativeView.right)
    for cell in thirdRow {
      cell.height = cell.width
      cell.top = secondRow[0].bottom
    }
  }
}

extension GameBoard {
  enum ChildrenKeys {
    case background
    case player1Score, player2Score
    case startButton
    
    case cell1, cell2, cell3, cell4, cell5, cell6, cell7, cell8, cell9
  }
}

extension GameBoard {
  struct Props: NodeDescriptionProps, Buildable {
    var frame: CGRect = .zero
    var key: String?
    var alpha: CGFloat = 1.0
    
    var isGameFinished: Bool
    var turn: Player
    var board: [Player?]
    var winningLine: [Int]?
    
    var player1Score: Int
    var player2Score: Int
    
    var isLoading: Bool
    
    init() {
      self.isGameFinished = true
      self.turn = .one
      self.player1Score = 0
      self.player2Score = 0
      self.winningLine = nil
      self.isLoading = false
      
      self.board = [
        nil, nil, nil,
        nil, nil, nil,
        nil, nil, nil,
      ]
    }
  }
}
