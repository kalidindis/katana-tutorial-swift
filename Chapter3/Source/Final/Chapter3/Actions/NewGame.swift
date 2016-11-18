//
//  NewGame.swift
//  Chapter3
//
//  Copyright © 2016 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation
import Katana

struct NewGame: SyncAction {
  var payload: ()
  
  func updatedState(currentState: State) -> State {
    guard let state = currentState as? ApplicationState else { fatalError("Invalid state") }
    
    // Create a new state and assign values we should retain (scores)
    var newState = ApplicationState()
    newState.player1Score = state.player1Score
    newState.player2Score = state.player2Score
    
    return newState
  }
}
