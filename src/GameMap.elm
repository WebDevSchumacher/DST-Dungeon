module GameMap exposing (GameMap, roomCoords)

import RectangularRoom exposing (Gate, RectangularRoom)
import Utils exposing (Direction(..))


type alias GameMap =
    List RectangularRoom


roomCoords : ( Int, Int ) -> Direction -> ( Int, Int )
roomCoords ( x, y ) direction =
    case direction of
        Up ->
            ( x, y - 1 )

        Left ->
            ( x - 1, y )

        Right ->
            ( x + 1, y )

        Down ->
            ( x, y + 1 )
