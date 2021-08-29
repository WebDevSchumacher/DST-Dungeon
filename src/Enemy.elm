module Enemy exposing
    ( Enemy
    , EnemyType(..)
    , createEnemy
    , cyclopes
    , getEnemyLookDirImg
    , mole
    , slime
    , updateEnemyLookDirection
    )

import Direction exposing (Direction(..))


type alias Enemy =
    { level : Int
    , lifePoints : Int
    , attackDamage : Int
    , strengthFactor : Float
    , experience : Int
    , enemyType : EnemyType
    , position : ( Int, Int )
    , lookDirection : Direction
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
    , lookDirection = Right
    , enemyIMG = "assets/characters/enemies/slime/Slime_down.png"
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
    , lookDirection = Right
    , enemyIMG = "assets/characters/enemies/mole/Mole_down.png"
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
    , lookDirection = Right
    , enemyIMG = "assets/characters/enemies/cyclopes/Cyclopes_down.png"
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


changeLookDirImgSlime : Direction -> String
changeLookDirImgSlime direction =
    "assets/characters/enemies/slime/Slime_" ++ Direction.directionToString direction ++ ".png"


changeLookDirImgCyclopes : Direction -> String
changeLookDirImgCyclopes direction =
    "assets/characters/enemies/cyclopes/Cyclopes_" ++ Direction.directionToString direction ++ ".png"


changeLookDirImgMole : Direction -> String
changeLookDirImgMole direction =
    "assets/characters/enemies/mole/Mole_" ++ Direction.directionToString direction ++ ".png"


updateEnemyLookDirection : Enemy -> ( Int, Int ) -> Enemy
updateEnemyLookDirection enemy point =
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


getEnemyLookDirImg : Enemy -> Direction -> String
getEnemyLookDirImg enemy dir =
    case enemy.enemyType of
        Mole ->
            changeLookDirImgMole dir

        Cyclopes ->
            changeLookDirImgCyclopes dir

        Slime ->
            changeLookDirImgSlime dir

        _ ->
            changeLookDirImgCyclopes dir
