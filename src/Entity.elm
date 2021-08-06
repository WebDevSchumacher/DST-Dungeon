module Entity exposing (Enemy, EnemyType(..), pirate, troll)


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
    { lifePoints = 1
    , attackDamage = 1
    , enemyType = Pirate
    , position = position
    , enemyIMG = "pirate.svg"
    }


troll : ( Int, Int ) -> Enemy
troll position =
    { lifePoints = 2
    , attackDamage = 1
    , enemyType = Troll
    , position = position
    , enemyIMG = "troll.svg"
    }
