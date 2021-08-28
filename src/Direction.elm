module Direction exposing (Direction(..), changeLookDirection, directionToString, getViewBoxFromDirection, oppositeDirection)


type Direction
    = Left
    | Up
    | Right
    | Down


oppositeDirection : Direction -> Direction
oppositeDirection direction =
    case direction of
        Left ->
            Right

        Right ->
            Left

        Up ->
            Down

        Down ->
            Up


directionToString : Direction -> String
directionToString direction =
    case direction of
        Left ->
            "left"

        Right ->
            "right"

        Up ->
            "up"

        Down ->
            "down"


changeLookDirection : ( Int, Int ) -> ( Int, Int ) -> Maybe Direction
changeLookDirection ( entityX, entityY ) ( x, y ) =
    let
        diffX =
            entityX - x

        diffY =
            entityY - y
    in
    if entityY == y && diffX > 0 then
        Just Left

    else if entityY == y && diffX < 0 then
        Just Right

    else if entityX == x && diffY > 0 then
        Just Up

    else if entityX == x && diffY < 0 then
        Just Down

    else
        Nothing


getViewBoxFromDirection : Direction -> String
getViewBoxFromDirection dir =
    case dir of
        Down ->
            "0 0 1 1"

        Up ->
            "1 0 1 1"

        Left ->
            "2 0 1 1"

        Right ->
            "3 0 1 1"
