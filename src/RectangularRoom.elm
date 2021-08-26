module RectangularRoom exposing
    ( Gate
    , RectangularRoom
    , generate
    , updateEnemies
    , updateEnemyLookDirectionInRoom
    )

import Direction exposing (Direction(..))
import Enemy exposing (Enemy)
import Environment
import List
import List.Extra


type alias RectangularRoom =
    { location : ( Int, Int )
    , width : Int
    , height : Int
    , center : ( Int, Int )
    , inner : List ( Int, Int )
    , gates : List Gate
    , level : Int
    , enemies : List Enemy
    }


type alias Gate =
    { location : ( Int, Int ), direction : Direction }


pairOneWithAll : Int -> Int -> List Int -> List ( Int, Int )
pairOneWithAll start end ls2 =
    if start < end && ls2 /= [] then
        List.map2 Tuple.pair (List.repeat end start) ls2
            ++ pairOneWithAll (start + 1) end ls2

    else
        []


addGates : Int -> Int -> Int -> Int -> List Gate
addGates x1 x2 y1 y2 =
    let
        xMid =
            x1 + (x2 // 2)

        yMid =
            y1 + (y2 // 2)
    in
    [ { location = ( xMid, y1 - 1 ), direction = Up }
    , { location = ( xMid, y1 + y2 ), direction = Down }
    , { location = ( x1 - 1, yMid ), direction = Left }
    , { location = ( x1 + x2, yMid ), direction = Right }
    ]


generate : ( Int, Int ) -> Int -> Int -> Int -> RectangularRoom
generate coordinate width height level =
    let
        inner =
            pairOneWithAll offsetX (offsetX + width) (List.range offsetY (offsetY + height - 1))

        offsetX =
            Environment.screenWidth // 2 - width // 2

        offsetY =
            Environment.screenHeight // 2 - height // 2
    in
    { location = coordinate
    , width = width
    , height = height
    , center = ( Environment.screenWidth // 2, Environment.screenHeight // 2 )
    , inner = inner
    , gates = addGates offsetX width offsetY height
    , level = level
    , enemies = []
    }


updateEnemies : RectangularRoom -> Enemy -> Enemy -> RectangularRoom
updateEnemies room target updated =
    if updated.lifePoints <= 0 then
        { room | enemies = List.Extra.remove target room.enemies }

    else
        { room | enemies = List.Extra.setIf (\enemy -> enemy == target) updated room.enemies }


updateEnemyLookDirectionInRoom : Enemy -> ( Int, Int ) -> RectangularRoom -> RectangularRoom
updateEnemyLookDirectionInRoom enemy pos currentRoom =
    { currentRoom
        | enemies =
            List.Extra.setIf (\en -> en.position == enemy.position) (Enemy.updateEnemyLookDirection enemy pos) currentRoom.enemies
    }
