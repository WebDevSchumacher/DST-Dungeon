# Final project

Elm Roguelike Game as University project for declarative programming.

## Description of the process and implemented features
### Game World
The player starts in a small room as an entrance.
Rooms are rectangular in shape and made up of squares, with one square corresponding to one step of the player.

Rooms generally have exits on the 4 sides.

Passing an exit takes you to the next room. 
If this one does not yet exist within the world map, it is generated randomly (size of the room, positions of the obstacles).
When the room is generated, it is assigned a level that corresponds to the player's level and retains this level when re-entering.
The room level determines the level of the opponents in this room.

When entering a room, a random opponent is placed within. 
It is also assigned loot, which can consist of several random items. The sum of their item levels correspond to the opponent's level.

Defeated enemies drop loot in the form of a crate.

![Enemy](https://user-images.githubusercontent.com/62644021/132124979-1fcf29ef-57a3-4ecf-8b30-ff64c80a64fd.png)
![Loot](https://user-images.githubusercontent.com/62644021/132124997-c0673111-8f36-4c41-bba5-2deab8b4ec47.png)

The player gains experience and levels up, which makes newly generated rooms more difficult, but also provides better loot.

The game can potentially run indefinitely, tough items are implemented up to level 23, but rooms and enemies continue to scale regardless of this.

### Interactions
The player's actions are determined by the direction of movement or by the context of the target field:

Free field: Player moves onto the field

Opponent: Player hits the opponent

Loot crate: Player collects items

Exit: Player goes to the next room

Enemies also move and attack the player. This is achieved by a pathfinding module (see below for source, or Path.elm).

### Inventory
You can interact with the icons below the listed items by clicking on them:

"Use" (left icon) differs between the item types. Weapons and armour are equipped and taken off, food and potions are consumed.

"Discard" (right icon) removes the entire stack from the inventory.

"Info" (centre icon or item image) displays the item information.

![Inventory](https://user-images.githubusercontent.com/62644021/132125112-7ae6d4b7-06a9-4720-bb61-597296b36c9b.png)

### Differences to the planned implementation
Instead of controlling in the direction of the mouse, we have implemented WASD control, which is more conducive to the grid layout of the game.

Interactions with the objects in the room are not by mouse click but also by WASD as described above.

Blocks or shields as items are not implemented.

Exits are not randomly generated but always at the top, bottom, left and right.

Special boss rooms with more challenging enemies and special loot are not implemented.

Loot boxes do not appear independently in rooms, but only in the form of enemy loot.

# Elm App

This project is bootstrapped with [Create Elm App](https://github.com/halfzebra/create-elm-app).

## How to Start App

```sh
elm-app start
```

## Installing Elm packages

```sh
elm-app install <package-name>
```

## Credit Assets

Assets where taken from:  
https://pixel-boy.itch.io/ninja-adventure-asset-pack  
https://0x72.itch.io/dungeontileset-ii  
https://pixelfrog-assets.itch.io/pixel-adventure-1  
https://jeevo.itch.io/dungeoneering-eq-icon-pack

Pathfinding module taken from https://github.com/danneu/elm-hex-grid and adjusted to our needs
