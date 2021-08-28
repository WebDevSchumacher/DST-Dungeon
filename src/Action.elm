module Action exposing
    ( attackDuration
    , hitEnemy
    , hitPlayer
    , movementDelay
    , updateEnemyOnTick
    , walkingDuration
    )

import Enemy exposing (Enemy)
import Player exposing (Player)
import Weapon exposing (Weapon)


hitEnemy : Weapon -> Enemy -> Enemy
hitEnemy weapon enemy =
    { enemy | lifePoints = enemy.lifePoints - Weapon.weaponDamage weapon }


hitPlayer : Enemy -> Player -> Player
hitPlayer enemy player =
    { player | life = player.life - enemy.attackDamage }


updateEnemyOnTick : Enemy -> Enemy
updateEnemyOnTick enemy =
    enemy



-- in millisecond


movementDelay : Float
movementDelay =
    0


walkingDuration : Float
walkingDuration =
    400


attackDuration : Float
attackDuration =
    200
