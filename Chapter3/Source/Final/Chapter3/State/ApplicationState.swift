//
//  AppDelegate.swift
//  Chapter3
//
//  Copyright © 2016 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation
import Katana

struct ApplicationState: State {
  var isGameFinished: Bool
  var turn: Player
  var board: [Player?]
  var winningLine: [Int]?
  
  var player1Score: Int
  var player2Score: Int
  
  init() {
    self.isGameFinished = false
    
    let random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    self.turn = random > 0.5 ? .one : .two
    
    self.player1Score = 0
    self.player2Score = 0
    
    self.winningLine = nil
    
    self.board = [
      nil, nil, nil,
      nil, nil, nil,
      nil, nil, nil,
    ]
  }
}
