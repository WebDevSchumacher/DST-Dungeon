module Player exposing
    ( Player
    , PlayerStatus(..)
    , changeImgSrc
    , hasItemInStats
    , heal
    , playerStatusToAttacking
    , playerStatusToDead
    , playerStatusToStanding
    , playerStatusToString
    )

import Direction exposing (Direction(..))
import Item exposing (Item)
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
    , inventory : List Item
    , currentWeapon : Maybe Item
    , currentArmor : Maybe Item
    , position : ( Int, Int )
    , prevPosition : ( Int, Int )
    , lookDirection : Direction
    , playerStatus : PlayerStatus
    , currentInfoItem : Maybe Item
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


heal : Player -> Item -> Player
heal player item =
    let
        newItemList =
            if item.stack > 1 then
                List.Extra.updateIf (\i -> i == item) (\i -> { i | stack = i.stack - 1 }) player.inventory

            else
                List.Extra.filterNot (\i -> i == item) player.inventory
    in
    { player
        | inventory = newItemList
        , life = player.life + item.value
    }


hasItemInStats : Item -> Maybe Item -> Bool
hasItemInStats item currentItem =
    case currentItem of
        Nothing ->
            False

        Just w ->
            if w == item then
                True

            else
                False
