module Chest exposing (Chest)

import Item exposing (Item)


type alias Chest =
    { location : ( Int, Int )
    , loot : List Item
    }
