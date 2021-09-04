module Player exposing
    ( Player
    , PlayerStatus(..)
    , changeImgSrc
    , heal
    , playerChangeWeapon
    , playerStatusToAttacking
    , playerStatusToDead
    , playerStatusToStanding
    , playerStatusToString
    )

import Direction exposing (Direction(..))
import Item exposing (Armor, Heal, Loot(..), Weapon)
import List.Extra


type PlayerStatus
    = Walking
    | Standing
    | Attacking
    | Dead


type alias Player =
    { level : Int
    , experience : Int
    , life : Int
    , inventory : List Loot
    , currentWeapon : Maybe Weapon
    , currentArmor : Maybe Armor
    , position : ( Int, Int )
    , prevPosition : ( Int, Int )
    , lookDirection : Direction
    , playerStatus : PlayerStatus
    , currentInfoItem : Maybe Loot
    }


changeImgSrc : PlayerStatus -> Direction -> String
changeImgSrc status direction =
    case status of
        Standing ->
            "assets/characters/player/Walk.png"

        Walking ->
            "assets/characters/player/Walk.png"

        Attacking ->
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


playerChangeWeapon : Player -> Weapon -> Player
playerChangeWeapon player weapon =
    { player
        | currentWeapon = Just weapon
    }


heal : Player -> Loot -> Player
heal player (H item) =
    let
        newItemList =
            if item.stack > 1 then
                List.Extra.updateIf (\(H i) -> i == item) (\i -> i) player.inventory

            else
                List.Extra.filterNot (\(H i) -> i == item) player.inventory
    in
    { player
        | inventory = newItemList
        , life = player.life + item.healPoints
    }
