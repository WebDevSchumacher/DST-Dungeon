module Player exposing (Player, PlayerStatus(..), changeImgSrc, playerChangeWeapon, playerStatusToAttacking, playerStatusToDead, playerStatusToStanding, playerStatusToString, playerUseFood, playerUsePotion)

import Direction exposing (Direction(..))
import Item exposing (Food, Item(..), Potion, Weapon)


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
    , currentWeapon : Maybe Weapon
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


playerChangeWeapon : Player -> Weapon -> Player
playerChangeWeapon player weapon =
    { player
        | currentWeapon = Just weapon
    }


playerUseFood : Player -> Food -> Player
playerUseFood player food =
    let
        newItemList =
            List.map
                (\item ->
                    case item of
                        Foods f ->
                            if f == food then
                                Foods { f | stack = f.stack - 1 }

                            else
                                item

                        _ ->
                            item
                )
                player.inventory
    in
    { player
        | inventory = Item.filterItem newItemList
        , life = player.life + food.healPoints
    }


playerUsePotion : Player -> Potion -> Player
playerUsePotion player potion =
    let
        newItemList =
            List.map
                (\item ->
                    case item of
                        Potions p ->
                            if p == potion then
                                Potions { p | stack = p.stack - 1 }

                            else
                                item

                        _ ->
                            item
                )
                player.inventory
    in
    { player
        | inventory = Item.filterItem newItemList
        , life = player.life + potion.healPoints
    }
