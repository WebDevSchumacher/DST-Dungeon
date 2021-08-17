module Utils exposing (Direction(..), InitialGeneration, NumberOfRooms, experienceToLevelUp, gainExperience, levelUp)

import Entity exposing (Enemy)
import Environment
import Player exposing (Player)


type Direction
    = Left
    | Up
    | Right
    | Down
    | Other


type alias NumberOfRooms =
    Int


type alias InitialGeneration =
    Bool


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
