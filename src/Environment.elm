module Environment exposing
    ( baseExperience
    , chestAssetPath
    , entityOffsetY
    , experienceIncreaseFactor
    , floorAssetPath
    , gateAssetPath
    , historyLimit
    , maxInventory
    , maxStack
    , nonWeaponDamage
    , numberRooms
    , obstacleAssetPath
    , playerBoundBox
    , roomMaxHeight
    , roomMaxWidth
    , roomMinHeight
    , roomMinWidth
    , screenHeight
    , screenWidth
    , wallCount
    , wallLength
    )


entityOffsetY : Float
entityOffsetY =
    toFloat playerBoundBox * 0


roomMinWidth : Int
roomMinWidth =
    10


roomMinHeight : Int
roomMinHeight =
    10


roomMaxHeight : Int
roomMaxHeight =
    20


roomMaxWidth : Int
roomMaxWidth =
    20


numberRooms : Int
numberRooms =
    1


playerBoundBox : Int
playerBoundBox =
    1


screenWidth : Int
screenWidth =
    30 * playerBoundBox


screenHeight : Int
screenHeight =
    30 * playerBoundBox


baseExperience : Float
baseExperience =
    300.0


experienceIncreaseFactor : Float
experienceIncreaseFactor =
    1.3


wallCount : Int
wallCount =
    6


wallLength : Int
wallLength =
    7


historyLimit : Int
historyLimit =
    50


floorAssetPath : String
floorAssetPath =
    "assets/tiles/floor.png"


obstacleAssetPath : String
obstacleAssetPath =
    "assets/tiles/obstacle.png"


gateAssetPath : String
gateAssetPath =
    "assets/tiles/gate.png"


chestAssetPath : String
chestAssetPath =
    "assets/tiles/chest.png"


nonWeaponDamage : Int
nonWeaponDamage =
    5


maxStack : Int
maxStack =
    99


maxInventory : Int
maxInventory =
    8 * 5
