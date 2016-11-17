# Chapter 3 - Game Logic

In this chapter we'll develop the game logic using the Katana architecture.

### Explore the project

We created a project template, which is exactly the final project of the previous chapter. You can find it in the `Source/Initial` folder. 

Before starting we need to install the dependencies using `CocoaPods`. Open a terminal and go to the `Source/Initial` folder. Then type:

```
pod install
```

When the dependencies are installed, open the `Chapter3.xcworkspace` file. Build and run: you should see the game's UI we implemented in the [second chapter](../Chapter3/README.md).

We also added a new file: `GameUtils.swift`. This file contains a method that encapsulates the logic to check whether a move (that is, choose a cell in the game board) leads a player to win a game or not. 

### A New Way To Approach The Logic

Before starting the implementation of the game's logic, we want to give an overview of how the business logic is structured in Katana applications.


The first difference with respect to MVC approach, which is the most common one in iOS development, is that we only have a single source of truth. Every single piece of information related to the application should be stored in a single place. We call this place **store**. Starting from the information we have in the store, we can describe our UI. Every time something changes in the store, Katana recomputes the UI desciption of the application. This may seems very computationally expensive, but in reality it isn't. Katana, in fact, is able to perform several checks and adopt strategies to minimise the UI computation.

As we discussed in the second chapter, we don't put any business logic in the UI description. The question now is: how can we change the store when the user interacts with the application? Katana provides the concept of **action**. An action represents an intent to do something, or a signal that something has happened. When an action is dispatched, the state is updated and this triggers an update of the UI.

This approach is very different from the common ones in the iOS development world. So we did we decided to adopt it for Katana? There are many reasons, but the main ones are:

- The architecture is predictable: information flow in a single direction (store, ui, action and then store) 
- Having a single source of truth instead of many managers (or models) with their own state means that is easier to see and understand the state of the application. Think about a situation where you have a crash (maybe in production): you can dump the store and the action that caused the bug. With this dump you can reproduce the crash in your development environment. This is extremely powerful
- Every single piece of the architecture is meant to be easily testable. This is very important, especially in complex applications




Now that we have a general idea about the architecture, let's move to the fun part: implement the logic of our game.

### The State

We like to start the development of the logic of an application by defining what we need in the store. As we did in the chapter 2, let's first list what we need to handle:

* The score of the two players
* The player that should do the next move
* The moves that have already been made
* Something that tells us if the game is finished (we need to show the `New Game` button)
* Something that tells us if there is a winning line (that is, the cells that compose a winning combination)

Starting from these requirements, we can define the application's state. Create a file named `ApplicationState.swift` and copy the following code:

```swift
import Foundation
import Katana

// 1
struct ApplicationState: State {
  var isGameFinished: Bool
  var turn: Player
  var board: [Player?]
  var winningLine: [Int]?
  
  var player1Score: Int
  var player2Score: Int

 // 2
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
```



As you can see, the struct contains pretty much the same information of the `GameBoard` description we created in the previous chapter. This is not always the case, most of the time there isn't a 1:1 association between the two parts of Katana. The application we are developing is very easy, so this is pretty normal.


Let's take a look at the code. In **(1)** we adopt the `State` protocol: the struct that contains the application's state should always implement this protocol. In **(2)** we have an empty initializer. This a requirement of the `State` protocol and is used by Katana to create the initial state.

Note that in this application we are storing everything in a single struct, since we don't need to manage a large amount of information. In a real world case, you should divide your state in different structures. The only constraint that Katana has is that there is a "root" structure that is used as entry point for your state.

### Connect The State To The UI

### Manage The Cell Tap

### Manage A New Game

### Wrap It Up: What We have Learnt

