module Action exposing (hitEnemy, hitPlayer)

import Entity exposing (Enemy)
import Player exposing (Player)
import Weapon exposing (Weapon)


hitEnemy : Weapon -> Enemy -> Enemy
hitEnemy weapon enemy =
    { enemy | lifePoints = enemy.lifePoints - Weapon.weaponDamage weapon }


hitPlayer : Enemy -> Player -> Player
hitPlayer enemy player =
    { player | life = player.life - enemy.attackDamage }
