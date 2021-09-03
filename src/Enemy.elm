module Enemy exposing
    ( Enemy
    , EnemyType(..)
    , createEnemy
    , cyclopes
    , enemyTypeToString
    , imgSrc
    , mole
    , slime
    , updateLookDirectionOnTarget
    , updateLookDirectionOnWalk
    )

import Direction exposing (Direction(..))
import Item exposing (Item)


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
    , loot : List Item
    , status : EnemyStatus
    }


type EnemyType
    = Cyclopes
    | Slime
    | Mole


slime : Int -> ( Int, Int ) -> List Item -> Enemy
slime level position loot =
    { level = level
    , lifePoints = level * 10
    , attackDamage = level
    , strengthFactor = 1.0
    , experience = level * 100
    , loot = loot
    , enemyType = Slime
    , prevPosition = position
    , position = position
    , lookDirection = Right
    , enemyIMG = "assets/characters/enemies/Slime/Walk.png"
    , status = Walking
    }


mole : Int -> ( Int, Int ) -> List Item -> Enemy
mole level position loot =
    { level = level
    , lifePoints = level * 15
    , attackDamage = level
    , strengthFactor = 1.1
    , experience = level * 120
    , loot = loot
    , enemyType = Mole
    , prevPosition = position
    , position = position
    , lookDirection = Right
    , enemyIMG = "assets/characters/enemies/Mole/Walk.png"
    , status = Walking
    }


cyclopes : Int -> ( Int, Int ) -> List Item -> Enemy
cyclopes level position loot =
    { level = level
    , lifePoints = level * 20
    , attackDamage = level * 2
    , strengthFactor = 1.5
    , experience = level * 200
    , loot = loot
    , enemyType = Cyclopes
    , prevPosition = position
    , position = position
    , lookDirection = Right
    , enemyIMG = "assets/characters/enemies/Cyclopes/Walk.png"
    , status = Walking
    }


createEnemy : Int -> Maybe ( Int, Int ) -> EnemyType -> List Item -> List Enemy
createEnemy level pos enemyT loot =
    case pos of
        Just position ->
            case enemyT of
                Slime ->
                    [ slime level position loot ]

                Mole ->
                    [ mole level position loot ]

                Cyclopes ->
                    [ cyclopes level position loot ]

        Nothing ->
            []


enemyTypeToString : EnemyType -> String
enemyTypeToString enemytype =
    case enemytype of
        Mole ->
            "Mole"

        Slime ->
            "Slime"

        Cyclopes ->
            "Cyclopes"


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
imgSrc enemy _ =
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
