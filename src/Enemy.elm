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
    | Flame
    | Snake
    | Slime
    | Mole
    | GoldRacoon


goldRacoon : Int -> ( Int, Int ) -> List Item -> Enemy
goldRacoon level position loot =
    { level = level
    , lifePoints = level * 5
    , attackDamage = level
    , strengthFactor = 1
    , experience = level * 50
    , loot = loot
    , enemyType = GoldRacoon
    , prevPosition = position
    , position = position
    , lookDirection = Right
    , enemyIMG = "assets/characters/enemies/GoldRacoon/Walk.png"
    , status = Walking
    }


slime : Int -> ( Int, Int ) -> List Item -> Enemy
slime level position loot =
    { level = level
    , lifePoints = level * 9
    , attackDamage = level
    , strengthFactor = 1.0
    , experience = level * 40
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
    , lifePoints = level * 11
    , attackDamage = level
    , strengthFactor = 1.3
    , experience = level * 50
    , loot = loot
    , enemyType = Mole
    , prevPosition = position
    , position = position
    , lookDirection = Right
    , enemyIMG = "assets/characters/enemies/Mole/Walk.png"
    , status = Walking
    }


flame : Int -> ( Int, Int ) -> List Item -> Enemy
flame level position loot =
    { level = level
    , lifePoints = level * 5
    , attackDamage = level * 2
    , strengthFactor = 1.5
    , experience = level * 80
    , loot = loot
    , enemyType = Flame
    , prevPosition = position
    , position = position
    , lookDirection = Right
    , enemyIMG = "assets/characters/enemies/Flame/Walk.png"
    , status = Walking
    }


snake : Int -> ( Int, Int ) -> List Item -> Enemy
snake level position loot =
    { level = level
    , lifePoints = level * 9
    , attackDamage = ceiling (toFloat level * 1.2)
    , strengthFactor = 1.5
    , experience = level * 80
    , loot = loot
    , enemyType = Snake
    , prevPosition = position
    , position = position
    , lookDirection = Right
    , enemyIMG = "assets/characters/enemies/Snake/Walk.png"
    , status = Walking
    }


cyclopes : Int -> ( Int, Int ) -> List Item -> Enemy
cyclopes level position loot =
    { level = level
    , lifePoints = level * 12
    , attackDamage = ceiling (toFloat level * 1.4)
    , strengthFactor = 1.8
    , experience = level * 100
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

                GoldRacoon ->
                    [ goldRacoon level position loot ]

                Snake ->
                    [ snake level position loot ]

                Flame ->
                    [ flame level position loot ]

                Cyclopes ->
                    [ cyclopes level position loot ]

        Nothing ->
            []


enemyTypeToString : EnemyType -> String
enemyTypeToString enemytype =
    case enemytype of
        Mole ->
            "Mole"

        GoldRacoon ->
            "GoldRacoon"

        Flame ->
            "Flame"

        Slime ->
            "Slime"

        Snake ->
            "Snake"

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
