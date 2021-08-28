module Player exposing (Player, PlayerStatus(..), changeImgSrc, playerStatusToAttacking, playerStatusToDead, playerStatusToStanding, playerStatusToString)

import Direction exposing (Direction(..), directionToString)
import Weapon exposing (Weapon)


type PlayerStatus
    = Walking
    | Standing
    | Attacking
    | Dead


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


changeImgSrc : PlayerStatus -> Direction -> String
changeImgSrc status direction =
    case status of
        Standing ->
            -- "assets/characters/player/player_" ++ directionToString direction ++ ".png"
            "assets/characters/player/Walk.png"

        Walking ->
            "assets/characters/player/Walk.png"

        Attacking ->
            -- "assets/characters/player/Attacker_" ++ directionToString direction ++ ".png"
            "assets/characters/player/Attack.png"

        Dead ->
            "assets/characters/player/Dead.png"


playerStatusToString : PlayerStatus -> String
playerStatusToString status =
    case status of
        Standing ->
            "Standing"

        Walking ->
            "Walking"

        Attacking ->
            "Attacking"

        Dead ->
            "Dead"


playerStatusToStanding : Player -> Player
playerStatusToStanding player =
    { player
        | playerStatus = Standing
    }


playerStatusToAttacking : Player -> Player
playerStatusToAttacking player =
    { player
        | playerStatus = Attacking
    }


playerStatusToDead : Player -> Player
playerStatusToDead player =
    { player
        | playerStatus = Dead
    }
