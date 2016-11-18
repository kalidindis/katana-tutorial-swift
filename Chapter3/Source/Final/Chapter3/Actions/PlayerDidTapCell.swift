//
//  PlayerDidTapCell.swift
//  Chapter3
//
//  Copyright © 2016 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation
import Katana

struct PlayerDidTapCell: SyncAction {
  var payload: Int
  
  func updatedState(currentState: State) -> State {
    guard var state = currentState as? ApplicationState else { fatalError("Invalid state") }
    
    let cellIndex = self.payload
    state.board[cellIndex] = state.turn
    
    // check if we have a winner
    let winningLine = GameUtils.winningLine(for: state.board, lastMove: cellIndex)
    if let winningLine = winningLine {
      state.isGameFinished = true
      state.winningLine = winningLine
      
      switch state.turn {
      case .one:
        state.player1Score = state.player1Score + 10
      case .two:
        state.player2Score = state.player2Score + 10
      }
      
      return state
    }
    
    // check if we have other possible moves in the current game
    if !state.board.contains(where: { $0 == nil }) {
      state.isGameFinished = true
      return state
    }
    
    
    // just change the turn
    state.turn = state.turn == .one ? .two : .one
    
    return state
  }
}
