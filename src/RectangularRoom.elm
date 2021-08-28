module RectangularRoom exposing
    ( Gate
    , RectangularRoom
    , Wall
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
    , outerWalls : Wall
    }


type alias Gate =
    { location : ( Int, Int ), direction : Direction }


type alias Wall =
    -- seems over the top, but must differentiate walls for applying assets
    { leftUpCorner : ( Int, Int )
    , leftDownCorner : ( Int, Int )
    , rightUpCorner : ( Int, Int )
    , rightDownCorner : ( Int, Int )
    , upWalls : List ( Int, Int )
    , downWalls : List ( Int, Int )
    , leftWalls : List ( Int, Int )
    , rightWalls : List ( Int, Int )
    , rightGateWalls : Maybe ( Int, Int )
    , leftGateWalls : Maybe ( Int, Int )
    , upGateWalls : Maybe ( Int, Int )
    , downGateWalls : Maybe ( Int, Int )
    }


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

        addedGates =
            addGates offsetX width offsetY height
    in
    { location = coordinate
    , width = width
    , height = height
    , center = ( Environment.screenWidth // 2, Environment.screenHeight // 2 )
    , inner = inner
    , gates = addedGates
    , level = level
    , enemies = []
    , outerWalls = generateWalls addedGates ( offsetX - 1, offsetY - 1 ) ( (Environment.screenWidth // 2 + width // 2) + 1, (Environment.screenHeight // 2 + height // 2) + 1 )
    }



-- function for upperWall lowerWall rightWall & leftWall


generateWalls : List Gate -> ( Int, Int ) -> ( Int, Int ) -> Wall
generateWalls gates ( leftUpX, leftUpY ) ( rightDownX, rightDownY ) =
    { leftUpCorner = ( leftUpX, leftUpY )
    , leftDownCorner = ( leftUpX, rightDownY )
    , rightUpCorner = ( rightDownX, leftUpY )
    , rightDownCorner = ( rightDownX, rightDownY )
    , upWalls = getHorizontalCoords leftUpY (leftUpX + 1) (rightDownX - 1)
    , downWalls = getHorizontalCoords rightDownY (leftUpX + 1) (rightDownX - 1)
    , leftWalls = getVerticalCoords leftUpX (leftUpY + 1) (rightDownY - 1)
    , rightWalls = getVerticalCoords rightDownX (leftUpY + 1) (rightDownY - 1)
    , rightGateWalls = getDirectionGateWall gates Right
    , leftGateWalls = getDirectionGateWall gates Left
    , upGateWalls = getDirectionGateWall gates Up
    , downGateWalls = getDirectionGateWall gates Down
    }


getDirectionGateWall : List Gate -> Direction -> Maybe ( Int, Int )
getDirectionGateWall gates dir =
    let
        foundgate =
            List.Extra.find (\g -> g.direction == dir) gates
    in
    case foundgate of
        Just gate ->
            Just gate.location

        _ ->
            Nothing


getVerticalCoords : Int -> Int -> Int -> List ( Int, Int )
getVerticalCoords x y0 y1 =
    List.map (\y -> ( x, y )) (List.range y0 y1)


getHorizontalCoords : Int -> Int -> Int -> List ( Int, Int )
getHorizontalCoords y x0 x1 =
    List.map (\x -> ( x, y )) (List.range x0 x1)


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
