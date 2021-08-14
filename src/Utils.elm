module Utils exposing (Direction(..), InitialGeneration, NumberOfRooms, gainExperience)

import Entity exposing (Enemy)
import Player exposing (Player)


type Direction
    = Left
    | Up
    | Right
    | Down
    | Other


type alias NumberOfRooms =
    Int


type alias InitialGeneration =
    Bool


gainExperience : Player -> Enemy -> Player
gainExperience player enemy =
    let
        factor =
            1 - toFloat (player.level - enemy.level) / 10

        xp =
            floor (toFloat enemy.experience * factor)
    in
    { player | experience = player.experience + xp }
