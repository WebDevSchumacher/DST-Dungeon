module GameMap exposing (GameMap)

import RectangularRoom exposing (RectangularRoom)
import Tile exposing (TileCoordinate)


type alias GameMap =
    { width : Int
    , height : Int
    , rooms : List RectangularRoom
    , walkableTiles : List ( Int, Int )
    , tunnels : List ( Int, Int )
    , tiles : List TileCoordinate
    }
