module Environment exposing
    ( baseExperience
    , experienceIncreaseFactor
    , numberRooms
    , playerBoundBox
    , roomMaxHeight
    , roomMaxWidth
    , roomMinHeight
    , roomMinWidth
    , screenHeight
    , screenWidth
    )


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
