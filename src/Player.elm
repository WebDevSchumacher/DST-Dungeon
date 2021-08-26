module Player exposing (Player, changeImgSrc)

import Direction exposing (Direction(..), directionToString)
import Weapon exposing (Weapon)


type alias Player =
    { level : Int
    , experience : Int
    , life : Int
    , inventory : List Weapon
    , currentWeapon : Weapon
    , position : ( Int, Int )
    , nextPositionFlag : ( Int, Int )
    , lookDirection : Direction
    }


changeImgSrc : Direction -> String
changeImgSrc direction =
    "assets/characters/player/player_" ++ directionToString direction ++ ".png"
