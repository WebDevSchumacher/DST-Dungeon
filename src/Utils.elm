module Utils exposing (Direction(..), Msg(..), RectangularRoom, playerBoundBox, screenHeight, screenWidth)

import Entity exposing (EnemyType)



-- 1x1 square Boundbox as player


playerBoundBox : Int
playerBoundBox =
    1



-- number of Tiles horizontal on Screen (its not actually the screensize, screensize is scaled with css)


screenWidth : Int
screenWidth =
    50 * playerBoundBox



--  number of Tiles vertical on Screen (its not actually the screensize, screensize is scaled with css)


screenHeight : Int
screenHeight =
    42 * playerBoundBox


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


type Msg
    = Direction Direction
    | Move
    | GenerateRoomsWidthAndHeight ( Int, Int ) NumberOfRooms InitialGeneration
    | GenerateRoom ( Int, Int ) InitialGeneration RectangularRoom
    | ConnectRooms
    | SpawnEnemies (List RectangularRoom)
    | PlaceEnemy ( Int, EnemyType, RectangularRoom )


type alias RectangularRoom =
    { upperLeftCoord : ( Int, Int )
    , width : Int
    , height : Int
    , downRightCoord : ( Int, Int )
    , center : ( Int, Int )
    , inner : List ( Int, Int )
    }
