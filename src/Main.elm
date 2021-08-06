module Main exposing (..)

import Browser
import Browser.Events
import Entity exposing (Enemy, EnemyType(..))
import Html exposing (Attribute, Html, div, h1, text)
import Json.Decode as Decode
import List.Extra exposing (getAt)
import Random
import RectangularRoom exposing (defineRectangularRoom, drawRoomFloors, drawSVGRoom, tunnelBetweenRooms)
import Svg exposing (Svg, image, line, rect, svg)
import Svg.Attributes exposing (fill, height, stroke, strokeWidth, viewBox, width, x, x1, x2, xlinkHref, y, y1, y2)
import Task
import Tile exposing (TileCoordinate)
import Utils exposing (Direction(..), Msg(..), RectangularRoom, playerBoundBox, screenHeight, screenWidth)


type alias Model =
    { player : Player
    , gameMap : GameMap
    , enemies : List Enemy
    }


type alias GameMap =
    { width : Int
    , height : Int
    , rooms : List RectangularRoom
    , walkableTiles : List ( Int, Int )
    , tunnels : List ( Int, Int )
    , tiles : List TileCoordinate
    }


type alias Damage =
    Int


type Weapon
    = Fist
    | Bow
    | NormalSword
    | Excalibur


type alias Player =
    { life : Int
    , inventory : List Weapon
    , currentWeapon : Weapon
    , position : ( Int, Int )
    }


weaponDamage : Weapon -> Damage
weaponDamage weapon =
    case weapon of
        Fist ->
            5

        Bow ->
            10

        NormalSword ->
            15

        Excalibur ->
            40


init : Model
init =
    { player =
        { life = 100
        , inventory = []
        , currentWeapon = Fist
        , position = ( 6, 6 )
        }
    , gameMap =
        { width = screenWidth
        , height = screenHeight
        , rooms = []
        , walkableTiles = []
        , tunnels = []
        , tiles = []
        }
    , enemies = []
    }



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Direction direction ->
            ( { model
                | player = movePlayer direction model
              }
            , Cmd.none
            )

        GenerateRoomsWidthAndHeight roomWidthAndHeight numberOfRooms initial ->
            -- First generate the random With and Height of the Room then genereta it with (roomGen roomWidthAndHeight initial)
            if numberOfRooms <= 0 then
                ( model
                , Task.perform (always ConnectRooms) (Task.succeed ())
                )

            else
                ( model
                , Cmd.batch
                    [ generateRoomsWidthHeight (numberOfRooms - 1) False
                    , roomGen roomWidthAndHeight initial
                    ]
                )

        GenerateRoom roomWidthAndHeight initial room ->
            -- check if room overlaps with other rooms
            if List.any (\otherRoom -> RectangularRoom.intersect room otherRoom) model.gameMap.rooms then
                if initial then
                    ( model
                    , roomGen roomWidthAndHeight True
                    )

                else
                    ( model
                      -- , roomGen roomWidthAndHeight False
                    , Cmd.none
                    )

            else
                ( addRoom room model initial
                , Cmd.none
                )

        ConnectRooms ->
            ( addTunnelsToModel model
            , Task.perform (always (SpawnEnemies model.gameMap.rooms)) (Task.succeed ())
            )

        SpawnEnemies rooms ->
            case rooms of
                [] ->
                    ( model, Cmd.none )

                room :: rs ->
                    ( model
                    , Cmd.batch
                        [ placeEnemy room
                        , Task.perform (always (SpawnEnemies rs)) (Task.succeed ())
                        ]
                    )

        PlaceEnemy ( indexPosition, enemyType, room ) ->
            ( addEnemyToModel ( indexPosition, enemyType, room ) model
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


addEnemyToModel : ( Int, EnemyType, RectangularRoom ) -> Model -> Model
addEnemyToModel ( indexPos, enemyT, room ) model =
    { model
        | enemies =
            createEnemy (List.Extra.getAt indexPos room.inner) enemyT ++ model.enemies
    }


createEnemy : Maybe ( Int, Int ) -> EnemyType -> List Enemy
createEnemy pos enemyT =
    case pos of
        Just position ->
            case enemyT of
                Pirate ->
                    [ Entity.pirate position ]

                _ ->
                    [ Entity.troll position ]

        Nothing ->
            []


connectRooms : List RectangularRoom -> List ( Int, Int )
connectRooms rooms =
    case rooms of
        [] ->
            []

        r1 :: rs ->
            case List.head rs of
                Just r2 ->
                    tunnelBetweenRooms r1.center r2.center ++ connectRooms rs

                Nothing ->
                    []


addTunnelsToModel : Model -> Model
addTunnelsToModel model =
    -- add connection Points to the walkable tiles in model
    let
        tunnels =
            connectRooms model.gameMap.rooms
    in
    case model of
        { gameMap } ->
            { model
                | gameMap =
                    { gameMap
                        | walkableTiles = gameMap.walkableTiles ++ tunnels
                        , tunnels = tunnels
                    }
            }


addRoom : RectangularRoom -> Model -> Bool -> Model
addRoom room model initial =
    case model of
        { gameMap, player } ->
            case gameMap of
                { rooms } ->
                    { model
                        | gameMap =
                            { gameMap
                                | rooms = room :: rooms
                                , walkableTiles = gameMap.walkableTiles ++ room.inner
                            }
                        , player =
                            if initial then
                                { player | position = room.center }

                            else
                                player
                    }


movePoint : Direction -> ( Int, Int ) -> ( Int, Int )
movePoint direction ( x, y ) =
    case direction of
        Left ->
            ( x - playerBoundBox, y )

        Up ->
            ( x, y - playerBoundBox )

        Right ->
            ( x + playerBoundBox, y )

        Down ->
            ( x, y + playerBoundBox )

        _ ->
            ( x, y )


movePlayer : Direction -> Model -> Player
movePlayer direction { player, gameMap, enemies } =
    let
        changedPlayer =
            { player
                | position = movePoint direction player.position
            }
    in
    if
        outOfBounds gameMap changedPlayer.position
            || not (List.any (\walkableTile -> changedPlayer.position == walkableTile) gameMap.walkableTiles)
            || List.any (\enemy -> changedPlayer.position == enemy.position) enemies
    then
        player

    else
        changedPlayer



---- VIEW ----


outOfBounds : GameMap -> ( Int, Int ) -> Bool
outOfBounds { width, height } position =
    case position of
        ( x1, y1 ) ->
            x1 >= width || y1 >= height || x1 < 0 || y1 < 0


tile : ( Int, Int ) -> Svg Msg
tile ( px, py ) =
    rect
        [ x (String.fromInt px)
        , y (String.fromInt py)
        , width (String.fromInt playerBoundBox)
        , height (String.fromInt playerBoundBox)
        , fill "none"
        , stroke "black"
        , strokeWidth "1"

        -- , xlinkHref "http://www-archive.mozilla.org/projects/svg/lion.svg"
        ]
        []


generateGridlines : List (Svg Msg)
generateGridlines =
    drawHorizontalGridlines playerBoundBox ++ drawVerticalGridlines playerBoundBox


drawHorizontalGridlines : Int -> List (Svg Msg)
drawHorizontalGridlines height =
    if height <= screenHeight then
        line
            [ x1 "0"
            , y1 (String.fromInt height)
            , x2 (String.fromInt screenWidth)
            , y2 (String.fromInt height)
            , stroke "blue"
            , strokeWidth ".05"
            ]
            []
            :: drawHorizontalGridlines (height + playerBoundBox)

    else
        [ text "" ]


drawVerticalGridlines : Int -> List (Svg Msg)
drawVerticalGridlines width =
    if width <= screenWidth then
        line
            [ x1 (String.fromInt width)
            , y1 "0"
            , x2 (String.fromInt width)
            , y2 (String.fromInt screenHeight)
            , stroke "blue"
            , strokeWidth ".05"
            ]
            []
            :: drawVerticalGridlines (width + playerBoundBox)

    else
        [ text "" ]


playerToSvg : Player -> Svg Msg
playerToSvg { position } =
    case position of
        ( xp, yp ) ->
            image
                [ x (String.fromInt xp)
                , y (String.fromInt yp)
                , width (String.fromInt playerBoundBox)
                , height (String.fromInt playerBoundBox)
                , fill "green"
                , xlinkHref "8-Bit-Character-1.svg"
                ]
                []


enemiesToSvg : List Enemy -> List (Svg Msg)
enemiesToSvg enemies =
    case enemies of
        [] ->
            []

        em :: ems ->
            case em of
                { position, enemyIMG } ->
                    image
                        [ x (String.fromInt (Tuple.first position))
                        , y (String.fromInt (Tuple.second position))
                        , width (String.fromInt playerBoundBox)
                        , height (String.fromInt playerBoundBox)
                        , fill "green"
                        , xlinkHref enemyIMG
                        ]
                        []
                        :: enemiesToSvg ems


svgCanvasStyle : List (Attribute msg)
svgCanvasStyle =
    [ width (String.fromInt screenWidth)
    , height (String.fromInt screenHeight)
    , viewBox ("0 0 " ++ String.fromInt screenWidth ++ " " ++ String.fromInt screenHeight)
    , fill "none"
    ]


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Elm Rougelike" ]
        , svg svgCanvasStyle
            (rect
                (svgCanvasStyle ++ [ fill "#A9A9A9", stroke "black", strokeWidth "1" ])
                []
                :: generateGridlines
                -- ++ List.concat (List.map drawSVGRoom model.gameMap.rooms)
                ++ drawRoomFloors model.gameMap.walkableTiles
                ++ playerToSvg
                    model.player
                :: enemiesToSvg model.enemies
            )
        ]



---- SUBSCRIPTION EVENTS ----


keyDecoder : Model -> Decode.Decoder Msg
keyDecoder model =
    Decode.map (toKey model) (Decode.field "key" Decode.string)


toKey : Model -> String -> Msg
toKey model string =
    case string of
        "ArrowUp" ->
            Direction Up

        "ArrowDown" ->
            Direction Down

        "ArrowRight" ->
            Direction Right

        "ArrowLeft" ->
            Direction Left

        _ ->
            Direction Other


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onKeyDown (keyDecoder model)
        ]



---- GENERATE ROOM ----


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
    20


roomGenerator : Int -> Int -> Random.Generator RectangularRoom
roomGenerator roomWidth roomHeight =
    Random.map
        -- (\startpoint width height -> defineRectangularRoom ( 5, 5 ) width height)
        (\startpoint -> defineRectangularRoom startpoint roomWidth roomHeight)
        (Random.pair (Random.int 1 (screenWidth - roomWidth - 1)) (Random.int 1 (screenHeight - roomHeight - 1)))


roomGen : ( Int, Int ) -> Bool -> Cmd Msg
roomGen roomWidthAndHeight initial =
    case roomWidthAndHeight of
        ( roomWidth, roomHeight ) ->
            Random.generate (\p -> GenerateRoom roomWidthAndHeight initial p) (roomGenerator roomWidth roomHeight)


generateRoomsWidthHeight : Int -> Bool -> Cmd Msg
generateRoomsWidthHeight numberOfRooms initial =
    -- before we create a room we need to generate to Width and the Height of the Room
    Random.generate
        (\roomWidthAndHeight -> GenerateRoomsWidthAndHeight roomWidthAndHeight numberOfRooms initial)
        (Random.pair (Random.int roomMinWidth roomMaxWidth) (Random.int roomMinHeight roomMaxHeight))



---- PLACE ENEMIES ----


placeEnemy : RectangularRoom -> Cmd Msg
placeEnemy rooms =
    Random.generate (\x -> PlaceEnemy x) (enemyGenerator rooms)


enemyGenerator : RectangularRoom -> Random.Generator ( Int, EnemyType, RectangularRoom )
enemyGenerator room =
    -- return random index of a coord for roomPosition and a Enemy type
    Random.map2 (\position enemytype -> ( position, enemytype, room )) (Random.int 0 (List.length room.inner)) randomEnemy


randomEnemy : Random.Generator EnemyType
randomEnemy =
    Random.weighted ( 80, Pirate ) [ ( 20, Troll ) ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> ( init, generateRoomsWidthHeight numberRooms True )
        , update = update
        , subscriptions = subscriptions
        }
