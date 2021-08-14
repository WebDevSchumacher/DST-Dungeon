module Environment exposing (numberRooms, playerBoundBox, roomMaxHeight, roomMaxWidth, roomMinHeight, roomMinWidth, screenHeight, screenWidth)


roomMinWidth : Int
roomMinWidth =
    4


roomMinHeight : Int
roomMinHeight =
    4


roomMaxHeight : Int
roomMaxHeight =
    8


roomMaxWidth : Int
roomMaxWidth =
    8


numberRooms : Int
numberRooms =
    10


playerBoundBox : Int
playerBoundBox =
    1


screenWidth : Int
screenWidth =
    50 * playerBoundBox


screenHeight : Int
screenHeight =
    50 * playerBoundBox
