module Utils exposing (Direction(..), InitialGeneration, NumberOfRooms)


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
