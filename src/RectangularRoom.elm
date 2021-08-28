module RectangularRoom exposing
    ( Gate
    , RectangularRoom
    , drawSVGRoom
    , generate
    , roomOffset
    , updateEnemies
    )

import Enemy exposing (Enemy)
import Environment
import List
import List.Extra
import Svg exposing (Svg, rect)
import Svg.Attributes exposing (fill, height, stroke, strokeWidth, width, x, x1, x2, y, y1, y2)
import Utils exposing (Direction(..))


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


drawSVGRoom : RectangularRoom -> List (Svg a)
drawSVGRoom room =
    drawTiles room.inner "white" ++ drawTiles (List.map (\gate -> gate.location) room.gates) "green"


drawTiles : List ( Int, Int ) -> String -> List (Svg a)
drawTiles ls color =
    case ls of
        ( x1, y1 ) :: ps ->
            rect
                [ x (String.fromInt x1)
                , y (String.fromInt y1)
                , width (String.fromInt Environment.playerBoundBox)
                , height (String.fromInt Environment.playerBoundBox)
                , fill color
                , stroke "black"
                , strokeWidth "0.05"
                ]
                []
                :: drawTiles ps color

        [] ->
            []


generate : ( Int, Int ) -> ( Int, Int ) -> List ( Int, Int ) -> Int -> RectangularRoom
generate coordinate ( width, height ) obstacles level =
    let
        ( offsetX, offsetY ) =
            roomOffset width height

        inner =
            pairOneWithAll offsetX (offsetX + width) (List.range offsetY (offsetY + height - 1))
    in
    { location = coordinate
    , width = width
    , height = height
    , center = ( Environment.screenWidth // 2, Environment.screenHeight // 2 )
    , inner =
        if coordinate == ( 0, 0 ) then
            inner

        else
            List.Extra.filterNot
                (\tile ->
                    List.member tile (addObstacles obstacles [])
                )
                inner
    , gates = addGates offsetX width offsetY height
    , level = level
    , enemies = []
    }


roomOffset : Int -> Int -> ( Int, Int )
roomOffset width height =
    ( Environment.screenWidth // 2 - width // 2, Environment.screenHeight // 2 - height // 2 )


addObstacles : List ( Int, Int ) -> List ( Int, Int ) -> List ( Int, Int )
addObstacles origins result =
    case origins of
        x :: xs ->
            generateObstacle x (modBy 2 (List.length origins)) ++ addObstacles xs result

        [] ->
            result


generateObstacle : ( Int, Int ) -> Int -> List ( Int, Int )
generateObstacle ( x, y ) direction =
    let
        range =
            List.range 0 (Environment.wallLength - 1)
    in
    List.map
        (\offset ->
            if direction == 0 then
                ( x + offset, y )

            else
                ( x, y + offset )
        )
        range


updateEnemies : RectangularRoom -> Enemy -> Enemy -> RectangularRoom
updateEnemies room target updated =
    if updated.lifePoints <= 0 then
        { room | enemies = List.Extra.remove target room.enemies }

    else
        { room | enemies = List.Extra.setIf (\enemy -> enemy == target) updated room.enemies }
