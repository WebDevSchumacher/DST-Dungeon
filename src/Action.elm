module Action exposing
    ( attackDuration
    , enemyWalkDelay
    , hitEnemy
    , hitPlayer
    , movementDelay
    , updateEnemyOnTick
    , walkingDuration
    )

import Enemy exposing (Enemy)
import Item exposing (Weapon)
import Path
import Player exposing (Player)
import RectangularRoom exposing (RectangularRoom)


hitEnemy : Maybe Weapon -> Enemy -> Enemy
hitEnemy weapon enemy =
    case weapon of
        Nothing ->
            { enemy | lifePoints = enemy.lifePoints - Item.nonWeaponDamge }

        Just w ->
            { enemy | lifePoints = enemy.lifePoints - w.damage }


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


enemyWalkDelay : Float
enemyWalkDelay =
    200
