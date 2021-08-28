module Environment exposing
    ( baseExperience
    , entityOffsetY
    , experienceIncreaseFactor
    , floorAssetPath
    , gateAssetPath
    , numberRooms
    , playerBoundBox
    , roomMaxHeight
    , roomMaxWidth
    , roomMinHeight
    , roomMinWidth
    , screenHeight
    , screenWidth
    , wallAssetPath
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


floorAssetPath : String
floorAssetPath =
    "assets/floor_1.png"


wallAssetPath : String
wallAssetPath =
    "assets/wall_1.png"


gateAssetPath : String
gateAssetPath =
    "assets/gate_1.png"
