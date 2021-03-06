# Chapter 3 - Game Logic

In this chapter we'll develop the game logic using the Katana architecture.

### Explore the project

We created a project template, which is exactly the previous chapter's final project. You can find it in the `Source/Initial` folder. 

Before starting we need to install the dependencies using `CocoaPods`. Open a terminal and go to the `Source/Initial` folder. Then type:

```
pod install
```

When the dependencies are installed, open the `Chapter3.xcworkspace` file. Build and run: you should see the game's UI we implemented in the [second chapter](../Chapter2/README.md).

We also added a new file: `GameUtils.swift`. This file contains a method that encapsulates the logic to check whether a move (that is, the choice of a cell in the game board) leads a player to win a game or not. 

### A New Way To Approach The Logic

Before starting the implementation of the game's logic, we want to give an overview of how the business logic is structured in Katana applications.


The first difference with respect to the MVC approach, which is the most common one in iOS development, is that we have a single source of truth. Every single piece of information should be stored in a single place. We call this place **store**. Starting from the information we have in the store we can describe our UI. Every time something changes in the store, Katana recomputes the UI desciption of the application. This may seem very computationally expensive, but in reality it isn't. Katana, in fact, is able to perform several checks and adopt strategies to minimise the UI computation.

As we discussed in the second chapter, we don't put any business logic in the UI description. The question now is: how can we change the store when users interact with the application? In Katana we can leverage  **actions** to update the store. An action represents an intent to do something, or a signal that something has occurred. When an action is dispatched, the state is updated and this triggers an update of the UI.

This approach is very different from the common ones in the iOS development world. Why did we decide to adopt it for Katana? There are many reasons, but the main ones are:

- The architecture is predictable: information flows in a single direction (store, UI, action and then store again) 
- Having a single source of truth instead of many managers (or models) with their own state means that it's easier to see and understand the state of the application. Think about a situation where you have a crash (maybe in production): you can dump the store and the action that led to the bug. With this dump you can reproduce the crash in your development environment: this is extremely powerful
- Every single piece of the architecture is meant to be easily testable. This is very important, especially in complex applications


Now that we have a general idea about the architecture, let's move to the fun part: implementing the logic of our game.

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



As you can see, the struct contains pretty much the same information of the `GameBoard` description we created in the previous chapter. This is not always the case, most of the time there isn't a 1:1 association between the store structure and the various description properties.

Let's take a look at the code. In **(1)** we adopt the `State` protocol: the struct that contains the application's state should always implement this protocol. In **(2)** we have an empty initializer. This a requirement of the `State` protocol and it is used by Katana to create the initial configuration of the application.

Note that in this application we are storing everything in a single struct, since we don't need to manage a large amount of information. In a real world case, you should divide your state in different structures. The only constraint that Katana has is that there is a "root" structure that is used as entry point for your state.

### Connect The State To The UI

The next step is connecting the Store's state to the UI. Open `AppDelegate.swift` and change the `Renderer` initialization in the following way:

```swift
let store = Store<ApplicationState>()
self.renderer = Renderer(rootDescription: intro, store: store)
```

In the first line we are creating the store that will hold the application's state while in the second line we are passing it to the `Renderer` constructor. The `Renderer` instance is now able to inject the store information in the UI and trigger UI updates when the store changes.

Let's first discuss how we can inject information in our UI descriptions. Katana allows developers to decide which descriptions need the store's information (we call these descriptions "connected") and which portion of the information each description needs.

Open the `GameBoard` description and adop the `ConnectedNodeDescription` protocol. This protocol requires a new `associatedtype`:  `StoreState`. Add this line to your description:

```swift
typealias StoreState = ApplicationState
```

We also need to implement a new method:

```swift
static func connect(props: inout PropsType, to storeState: StoreState) {
  props.isGameFinished = storeState.isGameFinished
  props.turn = storeState.turn
  props.board = storeState.board
  props.player1Score = storeState.player1Score
  props.player2Score = storeState.player2Score
  props.winningLine = storeState.winningLine
}
```

The idea of this method is that you receive the properties that whoever created the description has specificed (e.g., in the `GameBoard` case, we will receive the properties defined in the `AppDelegate`, since it is the place where we created the `GameBoard` ) and you can udpdate them with some of the information coming from the store.

Try to change the `ApplicationState`'s `init` method: you should see the UI change accordingly.

The second point we want to discuss is: how does Katana know which descriptions need to be updated when the store changes? From a theoretical point of view, you don't need to know it: you should reason as if the UI was **entirely** recreated every time the store changes. If you are interested in the technical details, though, here is how Katana works:

* When the store changes, Katana searches the descriptions that are connected to the store
* Katana then computes the new properties for each of the connected descriptions by invoking the `connect` method
* For each description whose properties have changed, Katana will trigger a UI update. The equality comparison is performed using the Swift `Equatable` protocol

As you can see, the process is entirely managed by Katana. You don't need to do anything special to handle store changes, just implement the `childrenDescriptions` method according to your properties.

### Manage The Cell Tap

We have now connected the UI to the store, but how can we update the state (and so the UI) when the user does something? As we said before, we can leverage actions to achieve this goal.

Let's start by implementing the action. Create a new file named `PlayerDidTapCell.swift` and paste the following code:

```swift
import Foundation
import Katana

// 1
struct PlayerDidTapCell: SyncAction {
  var payload: Int
  
  // 2
  func updatedState(currentState: State) -> State {
    guard var state = currentState as? ApplicationState else {
    	fatalError("Invalid state")
    }
    
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
```

As you can see in **(1)**, we can create an action by simply adopting the `SyncAction` protocol. Katana also has a protocol for [asyncronous actions](https://bendingspoons.github.io/katana-swift/Protocols/AsyncAction.html) and, in general, you can create your own action type by implementing the [Action protocol](https://bendingspoons.github.io/katana-swift/Protocols/Action.html).

The core of the action is **(2)**. The `updateState` method is invoked by Katana to create the new store's state. There are two important things you need to remember when you implement this method:

* You should **always** return a new copy of the store's state. If you use structs to implement the state (and you really should), this works out of the box
* The method **must be a pure function**. A [pure function](https://en.wikipedia.org/wiki/Pure_function) is a function that always returns the same result value given the same argument values. It also doesn't have side effects. As a rule of thumb, don't put disk interactions, API calls or anything related to external sources of information in the method implementation. This may seem a big limitation, but it is actually very important for many reasons. For instance, having pure `updateState` methods means that you can easily test this part of the logic since pure functions are 100% predictable. Katana provides a way to add your side effects (e.g., API call), we will discuss it in the [fifth chapter](../Chapter5/README.md)

We now have the action, but we need to trigger it somewhere.

Open the `GameCell` file and change the properties by adding a new variable:

```swift
var didTap: () -> ()
```

We also need to update the `init` method:

```swift
init(key: Any, player: Player?, isWinningCell: Bool, didTap: @escaping () -> ()) {
  self.player = player
  self.isWinningCell = isWinningCell
  self.didTap = didTap
  self.setKey(key)
}
```

We are basically adding another parameter to our cells. This closure should be invoked when the the user taps the button, so let's update it in our `childrenDescriptions` method:

```swift
var children: [AnyNodeDescription] = [
  Button(props: .gameCellButtonProps(
    isWinningCell: props.isWinningCell,
    didTap: props.didTap,
    key: Keys.button)
  )
]
```



Try to compile the application now: you should receive some errors in `GameBoard`.  We need, in fact, to update the `GameCell` descriptions. Add the `cellCallback` variable in the `GameBoard`'s `childrenDescriptions` method, just under the `winningLine` variable:

```swift
let cellCallback = { (index: Int) in
  return {
    if !props.isGameFinished {
      // 1
      dispatch(PlayerDidTapCell(payload: index))
    }
  }
}
```

The important part here is **(1)**: when the cell is tapped, the closure will dispatch the action we created before with the proper cell index. This will trigger a state update, which in turn will trigger a UI update.

The last step is to update the cell descriptions in the following way:

```swift
      GameCell(props: GameCell.Props(key: Keys.cell1, player: props.board[0], isWinningCell: winningLine.contains(0), didTap: cellCallback(0))),

      GameCell(props: GameCell.Props(key: Keys.cell2, player: props.board[1], isWinningCell: winningLine.contains(1), didTap: cellCallback(1))),
      
      GameCell(props: GameCell.Props(key: Keys.cell3, player: props.board[2], isWinningCell: winningLine.contains(2), didTap: cellCallback(2))),
      
      GameCell(props: GameCell.Props(key: Keys.cell4, player: props.board[3], isWinningCell: winningLine.contains(3), didTap: cellCallback(3))),
      
      GameCell(props: GameCell.Props(key: Keys.cell5, player: props.board[4], isWinningCell: winningLine.contains(4), didTap: cellCallback(4))),
      
      GameCell(props: GameCell.Props(key: Keys.cell6, player: props.board[5], isWinningCell: winningLine.contains(5), didTap: cellCallback(5))),
      
      GameCell(props: GameCell.Props(key: Keys.cell7, player: props.board[6], isWinningCell: winningLine.contains(6), didTap: cellCallback(6))),
      
      GameCell(props: GameCell.Props(key: Keys.cell8, player: props.board[7], isWinningCell: winningLine.contains(7), didTap: cellCallback(7))),
      
      GameCell(props: GameCell.Props(key: Keys.cell9, player: props.board[8], isWinningCell: winningLine.contains(8), didTap: cellCallback(8))),
```

We basically passed the proper `didTap` parameter to each cell.

Compile and run: you should be able to tap the cells now and see them change!

### Manage A New Game

We miss one piece of logic to complete our game: starting a new match when the current one is finished. In the current implementation, in fact, when the match finishes (either because a player won, or because there are no more valid moves) the new game button appears, but it doesn't do anything.


We need to create and then connect a new action. Let's fist create a new file named `NewGame.swift` and paste the following code:

```swift
import Foundation
import Katana

struct NewGame: SyncAction {
  var payload: ()
  
  func updatedState(currentState: State) -> State {
    guard let state = currentState as? ApplicationState else {
    	fatalError("Invalid state")
    }
    
    // Create a new state and assign values we should retain (scores)
    var newState = ApplicationState()
    newState.player1Score = state.player1Score
    newState.player2Score = state.player2Score
    
    return newState
  }
}
```

As we did before, we have created a new struct and implemented the `SyncAction` protocol. The `updateState` method just creates a new `ApplicationState` and copies the information we need to retain, which is the player scores.

We now need to dispatch the action when the new game button is tapped. Open the `GameBoard` file and update the button description in the `childrenDescriptions` method:

```swift
if props.isGameFinished {
  let startButton = Button(props: .startButtonProps(
    title: "New Game",
    key: Keys.startButton,
    didTap: { dispatch(NewGame()) }
    ))

  children.append(startButton)
}
```

Build and run: you should now be able to play multiple matches! Hurray!

### Wrap It Up: What We Have Learnt

In this chapter we have learnt how to develop the logic of our Katana applications. In particular:

* How to create the application's state
* How to connect the UI to the store and how Katana is able to handle store changes
* How to trigger actions that can update the store's state


You can find the final result in the `Source/Final` folder.




In the [next chapter](../Chapter4/README.md), we'll add some cool animations to our game!