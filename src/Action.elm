module Action exposing
    ( attackDuration
    , enemyWalkingDuration
    , hitEnemy
    , hitPlayer
    , movementDelay
    , playerWalkingDuration
    , updateEnemyOnTick
    )

import Enemy exposing (Enemy)
import Environment
import Item exposing (Item)
import Path
import Player exposing (Player)
import RectangularRoom exposing (RectangularRoom)


hitEnemy : Player -> Enemy -> Enemy
hitEnemy player enemy =
    case player.currentWeapon of
        Nothing ->
            { enemy | lifePoints = enemy.lifePoints - (Environment.nonWeaponDamage + player.level) }

        Just w ->
            { enemy | lifePoints = enemy.lifePoints - (w.value + player.level) }


hitPlayer : Enemy -> Player -> Player
hitPlayer enemy player =
    let
        defence =
            case player.currentArmor of
                Just armor ->
                    armor.value

                Nothing ->
                    0
    in
    { player | life = player.life - max 0 (enemy.attackDamage - defence) }


updateEnemyOnTick : Enemy -> Player -> RectangularRoom -> Maybe ( ( Int, Int ), Enemy )
updateEnemyOnTick enemy player room =
    let
        maybeTarget =
            List.head (Path.pathfind enemy.position player.position room)
    in
    case maybeTarget of
        Just target ->
            Just ( target, enemy )

        Nothing ->
            Nothing



-- in millisecond


movementDelay : Float
movementDelay =
    0


playerWalkingDuration : Float
playerWalkingDuration =
    300


attackDuration : Float
attackDuration =
    200


enemyWalkingDuration : Float
enemyWalkingDuration =
    500
