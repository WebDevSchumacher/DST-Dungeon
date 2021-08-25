module Enemy exposing
    ( Enemy
    , EnemyType(..)
    , createEnemy
    , cyclopes
    , mole
    , slime
    )


type alias Enemy =
    { level : Int
    , lifePoints : Int
    , attackDamage : Int
    , strengthFactor : Float
    , experience : Int
    , enemyType : EnemyType
    , position : ( Int, Int )
    , enemyIMG : String
    }


type EnemyType
    = Troll
    | Orc
    | Warrior
    | Cyclopes
    | Slime
    | Mole


slime : Int -> ( Int, Int ) -> Enemy
slime level position =
    { level = level
    , lifePoints = level * 10
    , attackDamage = level
    , strengthFactor = 1.0
    , experience = level * 100
    , enemyType = Slime
    , position = position
    , enemyIMG = "assets/characters/enemies/slime/Slime_front.png"
    }


mole : Int -> ( Int, Int ) -> Enemy
mole level position =
    { level = level
    , lifePoints = level * 15
    , attackDamage = level
    , strengthFactor = 1.1
    , experience = level * 120
    , enemyType = Mole
    , position = position
    , enemyIMG = "assets/characters/enemies/mole/Mole_front.png"
    }


cyclopes : Int -> ( Int, Int ) -> Enemy
cyclopes level position =
    { level = level
    , lifePoints = level * 20
    , attackDamage = level * 2
    , strengthFactor = 1.5
    , experience = level * 200
    , enemyType = Cyclopes
    , position = position
    , enemyIMG = "assets/characters/enemies/cyclopes/Cyclopes_front.png"
    }


createEnemy : Int -> Maybe ( Int, Int ) -> EnemyType -> List Enemy
createEnemy level pos enemyT =
    case pos of
        Just position ->
            case enemyT of
                Slime ->
                    [ slime level position ]

                Mole ->
                    [ mole level position ]

                _ ->
                    [ cyclopes level position ]

        Nothing ->
            []
