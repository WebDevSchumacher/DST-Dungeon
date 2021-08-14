module Player exposing (Player)

import Weapon exposing (Weapon)


type alias Player =
    { life : Int
    , inventory : List Weapon
    , currentWeapon : Weapon
    , position : ( Int, Int )
    }
