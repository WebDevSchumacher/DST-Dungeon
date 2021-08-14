module Weapon exposing (Damage, Weapon(..), weaponDamage)


type alias Damage =
    Int


type Weapon
    = Fist
    | Bow
    | NormalSword
    | Excalibur


weaponDamage : Weapon -> Damage
weaponDamage weapon =
    case weapon of
        Fist ->
            5

        Bow ->
            10

        NormalSword ->
            15

        Excalibur ->
            40
