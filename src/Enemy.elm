module Enemy exposing
    ( Enemy
    , EnemyType(..)
    , createEnemy
    , cyclopes
    , imgSrc
    , mole
    , slime
    , updateLookDirectionOnTarget
    , updateLookDirectionOnWalk
    )

import Direction exposing (Direction(..))


type EnemyStatus
    = Walking
    | Attacking
    | Standing


type alias Enemy =
    { level : Int
    , lifePoints : Int
    , attackDamage : Int
    , strengthFactor : Float
    , experience : Int
    , enemyType : EnemyType
    , prevPosition : ( Int, Int )
    , position : ( Int, Int )
    , lookDirection : Direction
    , enemyIMG : String
    , status : EnemyStatus
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
    , prevPosition = position
    , position = position
    , lookDirection = Right
    , enemyIMG = "assets/characters/enemies/slime/Walk.png"
    , status = Walking
    }


mole : Int -> ( Int, Int ) -> Enemy
mole level position =
    { level = level
    , lifePoints = level * 15
    , attackDamage = level
    , strengthFactor = 1.1
    , experience = level * 120
    , enemyType = Mole
    , prevPosition = position
    , position = position
    , lookDirection = Right
    , enemyIMG = "assets/characters/enemies/mole/Walk.png"
    , status = Walking
    }


cyclopes : Int -> ( Int, Int ) -> Enemy
cyclopes level position =
    { level = level
    , lifePoints = level * 20
    , attackDamage = level * 2
    , strengthFactor = 1.5
    , experience = level * 200
    , enemyType = Cyclopes
    , prevPosition = position
    , position = position
    , lookDirection = Right
    , enemyIMG = "assets/characters/enemies/cyclopes/Walk.png"
    , status = Walking
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


enemyTypeToString : EnemyType -> String
enemyTypeToString enemytype =
    case enemytype of
        Mole ->
            "mole"

        Slime ->
            "slime"

        _ ->
            "cyclopes"


enemyStatusToString : EnemyStatus -> String
enemyStatusToString status =
    case status of
        Attacking ->
            "Attacking"

        Standing ->
            "Standing"

        Walking ->
            "Walking"


imgSrc : Enemy -> Direction -> String
imgSrc enemy direction =
    "assets/characters/enemies/" ++ enemyTypeToString enemy.enemyType ++ "/Walk.png"


updateLookDirectionOnTarget : Enemy -> ( Int, Int ) -> Enemy
updateLookDirectionOnTarget enemy point =
    let
        direction =
            Direction.changeLookDirection enemy.position point
    in
    case direction of
        Just dir ->
            { enemy
                | lookDirection = dir
            }

        Nothing ->
            enemy


updateLookDirectionOnWalk : Enemy -> Enemy
updateLookDirectionOnWalk enemy =
    let
        direction =
            Direction.changeLookDirection enemy.prevPosition enemy.position
    in
    case direction of
        Just dir ->
            { enemy
                | lookDirection = dir
            }

        Nothing ->
            enemy
