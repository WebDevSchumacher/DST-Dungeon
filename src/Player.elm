module Player exposing (Player)

import Direction exposing (Direction)
import Weapon exposing (Weapon)


type alias Player =
    { level : Int
    , experience : Int
    , life : Int
    , inventory : List Weapon
    , currentWeapon : Weapon
    , position : ( Int, Int )
    , lookDirection : Direction
    }
