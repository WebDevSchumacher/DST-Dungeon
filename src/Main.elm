module Main exposing (..)

import Action
import Browser
import Browser.Events
import Entity exposing (Enemy, EnemyType(..))
import Environment
import GameMap exposing (GameMap)
import Html exposing (Attribute, Html, div, h1, text)
import Json.Decode as Decode
import List.Extra
import Player exposing (Player)
import Random
import RectangularRoom exposing (RectangularRoom)
import Svg exposing (Svg, image, line, rect, svg)
import Svg.Attributes exposing (fill, height, stroke, strokeWidth, viewBox, width, x, x1, x2, xlinkHref, y, y1, y2)
import Task
import Utils exposing (Direction(..), InitialGeneration, NumberOfRooms)
import Weapon exposing (Weapon(..))


type alias Model =
    { player : Player
    , gameMap : GameMap
    , enemies : List Enemy
    }


type Msg
    = Direction Direction
    | GenerateRoomsWidthAndHeight ( Int, Int ) NumberOfRooms InitialGeneration
    | GenerateRoom ( Int, Int ) InitialGeneration RectangularRoom
    | ConnectRooms
    | SpawnEnemies (List RectangularRoom)
    | PlaceEnemy ( Int, EnemyType, RectangularRoom )
    | AttackEnemy Enemy
    | AttackPlayer Enemy
    | GainExperience Enemy
    | LevelUp Player


init : Model
init =
    { player =
        { level = 2
        , experience = 0
        , life = 100
        , inventory = []
        , currentWeapon = Fist
        , position = ( 6, 6 )
        }
    , gameMap =
        { width = Environment.screenWidth
        , height = Environment.screenHeight
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
            let
                maybeEnemy =
                    List.Extra.find (\enemy -> enemy.position == newLocation) model.enemies

                newLocation =
                    movePoint direction model.player.position
            in
            case maybeEnemy of
                Nothing ->
                    ( { model
                        | player = movePlayer direction model
                      }
                    , Cmd.none
                    )

                Just enemy ->
                    ( model, Task.perform (always (AttackEnemy enemy)) (Task.succeed ()) )

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

        AttackEnemy target ->
            let
                attacked =
                    Action.hitEnemy model.player.currentWeapon target
            in
            if attacked.lifePoints <= 0 then
                ( { model
                    | enemies =
                        List.Extra.remove target model.enemies
                  }
                , Task.perform (always (GainExperience attacked)) (Task.succeed ())
                )

            else
                ( { model
                    | enemies =
                        List.Extra.setIf (\enemy -> enemy == target) attacked model.enemies
                  }
                , Task.perform (always (AttackPlayer target)) (Task.succeed ())
                )

        AttackPlayer enemy ->
            ( { model | player = Action.hitPlayer enemy model.player }, Cmd.none )

        GainExperience enemy ->
            let
                newXpPlayer =
                    Utils.gainExperience model.player enemy

                levelUp =
                    Utils.experienceToLevelUp newXpPlayer.level <= newXpPlayer.experience
            in
            ( { model | player = newXpPlayer }
            , if levelUp then
                Task.perform (always (LevelUp newXpPlayer)) (Task.succeed ())

              else
                Cmd.none
            )

        LevelUp player ->
            ( { model | player = Utils.levelUp model.player }, Cmd.none )


addEnemyToModel : ( Int, EnemyType, RectangularRoom ) -> Model -> Model
addEnemyToModel ( indexPos, enemyT, room ) model =
    { model
        | enemies =
            Entity.createEnemy model.player.level (List.Extra.getAt indexPos room.inner) enemyT ++ model.enemies
    }


connectRooms : List RectangularRoom -> List ( Int, Int )
connectRooms rooms =
    case rooms of
        [] ->
            []

        r1 :: rs ->
            case List.head rs of
                Just r2 ->
                    RectangularRoom.tunnelBetweenRooms r1.center r2.center ++ connectRooms rs

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


movePoint : Direction -> ( Int, Int ) -> ( Int, Int )
movePoint direction ( x, y ) =
    case direction of
        Left ->
            ( x - Environment.playerBoundBox, y )

        Up ->
            ( x, y - Environment.playerBoundBox )

        Right ->
            ( x + Environment.playerBoundBox, y )

        Down ->
            ( x, y + Environment.playerBoundBox )

        _ ->
            ( x, y )



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
        , width (String.fromInt Environment.playerBoundBox)
        , height (String.fromInt Environment.playerBoundBox)
        , fill "none"
        , stroke "black"
        , strokeWidth "1"

        -- , xlinkHref "http://www-archive.mozilla.org/projects/svg/lion.svg"
        ]
        []


generateGridlines : List (Svg Msg)
generateGridlines =
    drawHorizontalGridlines Environment.playerBoundBox ++ drawVerticalGridlines Environment.playerBoundBox


drawHorizontalGridlines : Int -> List (Svg Msg)
drawHorizontalGridlines height =
    if height <= Environment.screenHeight then
        line
            [ x1 "0"
            , y1 (String.fromInt height)
            , x2 (String.fromInt Environment.screenWidth)
            , y2 (String.fromInt height)
            , stroke "blue"
            , strokeWidth ".05"
            ]
            []
            :: drawHorizontalGridlines (height + Environment.playerBoundBox)

    else
        [ text "" ]


drawVerticalGridlines : Int -> List (Svg Msg)
drawVerticalGridlines width =
    if width <= Environment.screenWidth then
        line
            [ x1 (String.fromInt width)
            , y1 "0"
            , x2 (String.fromInt width)
            , y2 (String.fromInt Environment.screenHeight)
            , stroke "blue"
            , strokeWidth ".05"
            ]
            []
            :: drawVerticalGridlines (width + Environment.playerBoundBox)

    else
        [ text "" ]


playerToSvg : Player -> Svg Msg
playerToSvg { position } =
    case position of
        ( xp, yp ) ->
            image
                [ x (String.fromInt xp)
                , y (String.fromInt yp)
                , width (String.fromInt Environment.playerBoundBox)
                , height (String.fromInt Environment.playerBoundBox)
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
                        , width (String.fromInt Environment.playerBoundBox)
                        , height (String.fromInt Environment.playerBoundBox)
                        , fill "green"
                        , xlinkHref enemyIMG
                        ]
                        []
                        :: enemiesToSvg ems


svgCanvasStyle : List (Attribute msg)
svgCanvasStyle =
    [ width (String.fromInt Environment.screenWidth)
    , height (String.fromInt Environment.screenHeight)
    , viewBox ("0 0 " ++ String.fromInt Environment.screenWidth ++ " " ++ String.fromInt Environment.screenHeight)
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
                ++ RectangularRoom.drawRoomFloors model.gameMap.walkableTiles
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


roomGenerator : Int -> Int -> Random.Generator RectangularRoom
roomGenerator roomWidth roomHeight =
    Random.map
        -- (\startpoint width height -> defineRectangularRoom ( 5, 5 ) width height)
        (\startpoint -> RectangularRoom.defineRectangularRoom startpoint roomWidth roomHeight)
        (Random.pair (Random.int 1 (Environment.screenWidth - roomWidth - 1)) (Random.int 1 (Environment.screenHeight - roomHeight - 1)))


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
        (Random.pair (Random.int Environment.roomMinWidth Environment.roomMaxWidth) (Random.int Environment.roomMinHeight Environment.roomMaxHeight))



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
        , init = \_ -> ( init, generateRoomsWidthHeight Environment.numberRooms True )
        , update = update
        , subscriptions = subscriptions
        }
