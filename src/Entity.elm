module Entity exposing (Enemy, EnemyType(..), createEnemy, pirate, troll)


type alias Enemy =
    { lifePoints : Int
    , attackDamage : Int
    , enemyType : EnemyType
    , position : ( Int, Int )
    , enemyIMG : String
    }


type EnemyType
    = Troll
    | Orc
    | Warrior
    | Pirate


pirate : ( Int, Int ) -> Enemy
pirate position =
    { lifePoints = 10
    , attackDamage = 1
    , enemyType = Pirate
    , position = position
    , enemyIMG = "pirate.svg"
    }


troll : ( Int, Int ) -> Enemy
troll position =
    { lifePoints = 20
    , attackDamage = 1
    , enemyType = Troll
    , position = position
    , enemyIMG = "troll.svg"
    }


createEnemy : Maybe ( Int, Int ) -> EnemyType -> List Enemy
createEnemy pos enemyT =
    case pos of
        Just position ->
            case enemyT of
                Pirate ->
                    [ pirate position ]

                _ ->
                    [ troll position ]

        Nothing ->
            []
