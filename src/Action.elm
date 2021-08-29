module Action exposing
    ( attackDuration
    , hitEnemy
    , hitPlayer
    , movementDelay
    , updateEnemyOnTick
    , walkingDuration
    )

import Enemy exposing (Enemy)
import Path
import Player exposing (Player)
import RectangularRoom exposing (RectangularRoom)
import Weapon exposing (Weapon)


hitEnemy : Weapon -> Enemy -> Enemy
hitEnemy weapon enemy =
    { enemy | lifePoints = enemy.lifePoints - Weapon.weaponDamage weapon }


hitPlayer : Enemy -> Player -> Player
hitPlayer enemy player =
    { player | life = player.life - enemy.attackDamage }


updateEnemyOnTick : Enemy -> Player -> RectangularRoom -> Maybe ( Enemy, ( Int, Int ) )
updateEnemyOnTick enemy player room =
    let
        maybeTarget =
            List.head (Path.pathfind enemy.position player.position room)
    in
    case maybeTarget of
        Just target ->
            Just ( enemy, target )

        Nothing ->
            Nothing



-- in millisecond


movementDelay : Float
movementDelay =
    0


walkingDuration : Float
walkingDuration =
    300


attackDuration : Float
attackDuration =
    200
