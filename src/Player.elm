module Player exposing (Player, PlayerStatus(..), playerStatusToStanding, playerStatusToString)

import Direction exposing (Direction(..), directionToString)
import Svg.Attributes exposing (in_)
import Weapon exposing (Weapon)


type PlayerStatus
    = Walking
    | Standing


type alias Player =
    { level : Int
    , experience : Int
    , life : Int
    , inventory : List Weapon
    , currentWeapon : Weapon
    , position : ( Int, Int )
    , prevPosition : ( Int, Int )
    , lookDirection : Direction
    , playerStatus : PlayerStatus
    }



-- changeImgSrc : PlayerStatus -> Direction -> String
-- changeImgSrc status direction =
--     case status of
--         Standing ->
--             "assets/characters/player/player_" ++ directionToString direction ++ ".png"
--         Walking ->
--             "assets/characters/player/Walk.png"


playerStatusToString : PlayerStatus -> String
playerStatusToString status =
    case status of
        Standing ->
            "Standing"

        Walking ->
            "Walking"


playerStatusToStanding : Player -> Player
playerStatusToStanding player =
    { player
        | playerStatus = Standing
    }
