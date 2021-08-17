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
    3


roomMinHeight : Int
roomMinHeight =
    3


roomMaxHeight : Int
roomMaxHeight =
    4


roomMaxWidth : Int
roomMaxWidth =
    4


numberRooms : Int
numberRooms =
    1


playerBoundBox : Int
playerBoundBox =
    1


screenWidth : Int
screenWidth =
    50 * playerBoundBox


screenHeight : Int
screenHeight =
    50 * playerBoundBox


baseExperience : Float
baseExperience =
    300.0


experienceIncreaseFactor : Float
experienceIncreaseFactor =
    1.3
