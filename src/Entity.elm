module Entity exposing (Enemy, EnemyType(..), createEnemy, pirate, troll)


type alias Enemy =
    { level : Int
    , lifePoints : Int
    , attackDamage : Int
    , experience : Int
    , enemyType : EnemyType
    , position : ( Int, Int )
    , enemyIMG : String
    }


type EnemyType
    = Troll
    | Orc
    | Warrior
    | Pirate


pirate : Int -> ( Int, Int ) -> Enemy
pirate level position =
    { level = 1
    , lifePoints = level * 10
    , attackDamage = level
    , experience = level * 100
    , enemyType = Pirate
    , position = position
    , enemyIMG = "pirate.svg"
    }


troll : Int -> ( Int, Int ) -> Enemy
troll level position =
    { level = 3
    , lifePoints = level * 20
    , attackDamage = level * 2
    , experience = level * 200
    , enemyType = Troll
    , position = position
    , enemyIMG = "troll.svg"
    }


createEnemy : Int -> Maybe ( Int, Int ) -> EnemyType -> List Enemy
createEnemy level pos enemyT =
    case pos of
        Just position ->
            case enemyT of
                Pirate ->
                    [ pirate level position ]

                _ ->
                    [ troll level position ]

        Nothing ->
            []
