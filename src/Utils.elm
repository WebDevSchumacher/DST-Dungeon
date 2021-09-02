module Utils exposing
    ( experienceToLevelUp
    , gainExperience
    , itemsToInventory
    , levelUp
    , oppositeDirection
    )

import Direction exposing (Direction(..))
import Enemy exposing (Enemy)
import Environment
import Item exposing (Item(..))
import List.Extra
import Player exposing (Player)


oppositeDirection : Direction -> Direction
oppositeDirection dir =
    case dir of
        Up ->
            Down

        Left ->
            Right

        Right ->
            Left

        Down ->
            Up


gainExperience : Player -> Enemy -> Player
gainExperience player enemy =
    let
        levelFactor =
            1 - toFloat (player.level - enemy.level) / 10

        xp =
            floor (toFloat enemy.experience * levelFactor * enemy.strengthFactor)
    in
    { player | experience = player.experience + xp }


experienceToLevelUp : Int -> Int
experienceToLevelUp level =
    floor (Environment.baseExperience * Environment.experienceIncreaseFactor ^ toFloat level)


levelUp : Player -> Player
levelUp player =
    { player | experience = player.experience - experienceToLevelUp player.level, level = player.level + 1 }


itemsToInventory : List Item -> List Item -> List Item
itemsToInventory inventory loot =
    case loot of
        item :: rest ->
            if List.member item inventory then
                itemsToInventory
                    (List.Extra.updateIf
                        (\invItem ->
                            invItem == item
                        )
                        (\invItem -> stackItem invItem)
                        inventory
                    )
                    rest

            else
                itemsToInventory (item :: inventory) rest

        [] ->
            inventory


stackItem : Item -> Item
stackItem item =
    case item of
        Foods f ->
            Foods { f | stack = f.stack + 1 }

        Potions p ->
            Potions { p | stack = p.stack + 1 }

        Weapons w ->
            Weapons { w | stack = w.stack + 1 }
