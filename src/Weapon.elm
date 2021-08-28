module Weapon exposing (Damage, Weapon(..), weaponDamage)


type alias Damage =
    Int


type Weapon
    = Fist
    | Axe
    | Stick
    | Bow
    | Sword
    | Hammer
    | BigSword
    | SuperBow
    | Katana


weaponDamage : Weapon -> Damage
weaponDamage weapon =
    case weapon of
        Fist ->
            5

        Stick ->
            6

        Bow ->
            10

        Sword ->
            15

        Axe ->
            30

        Hammer ->
            35

        BigSword ->
            40

        SuperBow ->
            40

        Katana ->
            55
