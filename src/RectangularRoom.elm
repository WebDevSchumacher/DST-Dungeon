module RectangularRoom exposing (RectangularRoom, defineRectangularRoom, drawRoomFloors, drawSVGRoom, intersect, tunnelBetweenRooms)

import Environment
import List exposing (range)
import Svg exposing (Svg, rect)
import Svg.Attributes exposing (fill, height, stroke, strokeWidth, width, x, x1, x2, y, y1, y2)


type alias RectangularRoom =
    { upperLeftCoord : ( Int, Int )
    , width : Int
    , height : Int
    , downRightCoord : ( Int, Int )
    , center : ( Int, Int )
    , inner : List ( Int, Int )
    , gates : List ( Int, Int )
    }


defineRectangularRoom : ( Int, Int ) -> Int -> Int -> RectangularRoom
defineRectangularRoom ( x, y ) width height =
    let
        x2 =
            x + width

        y2 =
            y + height
    in
    { upperLeftCoord = ( x, y )
    , width = width
    , height = height
    , downRightCoord = ( x2, y2 )
    , center = ( floor (toFloat (x + x2) / 2), floor (toFloat (y + y2) / 2) )

    -- inner area of room as List of Points. (x , y) e.g. [(1, 0), (1, 1), (1, 2), , (2, 0) ...]
    -- , inner = List.map2 Tuple.pair (range x x2) (range y y2)
    , inner = pairOneWithAll x x2 (range y (y2 - 1))
    , gates = addGates x x2 y y2
    }


pairOneWithAll : Int -> Int -> List Int -> List ( Int, Int )
pairOneWithAll start end ls2 =
    if start < end && ls2 /= [] then
        List.map2 Tuple.pair (List.repeat end start) ls2
            ++ pairOneWithAll (start + 1) end ls2

    else
        []


addGates : Int -> Int -> Int -> Int -> List ( Int, Int )
addGates x1 x2 y1 y2 =
    let
        xMid =
            floor (toFloat (x1 + x2) / 2)

        yMid =
            floor (toFloat (y1 + y2) / 2)
    in
    [ ( xMid, y1 - 1 ), ( xMid, y2 ), ( x1 - 1, yMid ), ( x2, yMid ) ]



-- check if Room intersect with the other Room


intersect : RectangularRoom -> RectangularRoom -> Bool
intersect recr1 recr2 =
    let
        innerIntersect ( x1, y1 ) ( x2, y2 ) ( ox1, oy1 ) ( ox2, oy2 ) =
            x2 >= ox1 && x1 <= ox2 && y1 <= oy2 && y2 >= oy1
    in
    innerIntersect recr1.upperLeftCoord recr1.downRightCoord recr2.upperLeftCoord recr2.downRightCoord


drawSVGRoom : RectangularRoom -> List (Svg a)
drawSVGRoom { inner } =
    drawRoomFloors inner


drawRoomFloors : List ( Int, Int ) -> List (Svg a)
drawRoomFloors ls =
    case ls of
        ( x1, y1 ) :: ps ->
            rect
                [ x (String.fromInt x1)
                , y (String.fromInt y1)
                , width (String.fromInt Environment.playerBoundBox)
                , height (String.fromInt Environment.playerBoundBox)
                , fill "white"
                , stroke "black"
                , strokeWidth "0.05"
                ]
                []
                :: drawRoomFloors ps

        [] ->
            []



-- getSlope : ( Int, Int ) -> ( Int, Int ) -> Float
-- getSlope ( x1, y1 ) ( x2, y2 ) =
--     -- mathematical slope between two point
--     toFloat (x2 - x1) / toFloat (y2 - y1)


tunnelBetweenRooms : ( Int, Int ) -> ( Int, Int ) -> List ( Int, Int )
tunnelBetweenRooms ( x1, y1 ) ( x2, by ) =
    if x1 == x2 then
        verticalLine x1 y1 by

    else if y1 == by then
        horizontalLine y1 x1 x2

    else
        horizontalLine y1 x1 x2
            ++ verticalLine x2 y1 by


verticalLine : Int -> Int -> Int -> List ( Int, Int )
verticalLine x y0 y1 =
    -- get vertical line (use if slope is 0)
    if y1 < y0 then
        List.reverse (verticalLine x y1 y0)

    else
        List.map (\y -> ( x, y )) (List.range y0 y1)


horizontalLine : Int -> Int -> Int -> List ( Int, Int )
horizontalLine y x0 x1 =
    -- get horizontal line (use if slope is 0)
    if x1 < x0 then
        List.reverse (horizontalLine y x1 x0)

    else
        List.map (\x -> ( x, y )) (List.range x0 x1)
