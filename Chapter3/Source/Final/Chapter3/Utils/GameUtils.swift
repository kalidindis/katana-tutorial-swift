//
//  GameUtils.swift
//  Chapter3
//
//  Copyright © 2016 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation

/// Helper utils for the game
struct GameUtils {
  private init() {}
  
  /// heper structure
  private static var winLines = [
    [[1, 2], [4, 8], [3, 6]],
    [[0, 2], [4, 7]],
    [[0, 1], [4, 6], [5, 8]],
    [[4, 5], [0, 6]],
    [[3, 5], [0, 8], [2, 6], [1, 7]],
    [[3, 4], [2, 8]],
    [[7, 8], [2, 4], [0, 3]],
    [[6, 8], [1, 4]],
    [[6, 7], [0, 4], [2, 5]]
  ]
  
  
  /// Returns a winning line from the current board
  /// - parameter board:    the current board configuration
  /// - parameter lastMove: the last move that has been done
  ///
  /// - returns: the winning line, if present
  /// - note: taken from http://stackoverflow.com/questions/1056316/algorithm-for-determining-tic-tac-toe-game-over
  static func winningLine(for board: [Player?], lastMove: Int) -> [Int]? {
    let lastMovePlayer = board[lastMove]
    
    for line in winLines[lastMove] {
      
      guard let position1Player = board[line[0]], let position2Player = board[line[1]] else {
        continue
      }
      
      if position1Player == lastMovePlayer && position2Player == lastMovePlayer {
        return line + [lastMove]
      }
    }
    
    return nil
  }
}
