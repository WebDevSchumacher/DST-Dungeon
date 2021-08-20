module Main exposing (..)

import Action
import Browser
import Browser.Events
import Entity exposing (Enemy, EnemyType(..))
import Environment
import GameMap exposing (GameMap)
import Html exposing (Attribute, Html, div, h1, text)
import Html.Attributes exposing (class)
import Json.Decode as Decode
import List.Extra
import Player exposing (Player)
import Random
import RectangularRoom exposing (Gate, RectangularRoom)
import Svg exposing (Svg, image, line, rect, svg)
import Svg.Attributes exposing (fill, height, stroke, strokeWidth, viewBox, width, x, x1, x2, xlinkHref, y, y1, y2)
import Task
import Utils exposing (Direction(..), InitialGeneration, NumberOfRooms)
import Weapon exposing (Weapon(..))


type alias Model =
    { player : Player
    , gameMap : GameMap
    , currentRoom : RectangularRoom
    , roomTransition : Maybe Direction
    }


type Msg
    = None
    | Direction Direction
    | GenerateRoomWidthAndHeight ( Int, Int ) ( Int, Int )
      --| SpawnEnemies (List RectangularRoom)
    | PlaceEnemy ( Int, EnemyType, RectangularRoom )
    | AttackEnemy Enemy
    | AttackPlayer Enemy
    | GainExperience Enemy
    | LevelUp Player
    | EnterGate Gate
    | EnterRoom RectangularRoom


init : Model
init =
    let
        room =
            RectangularRoom.generate ( 0, 0 ) 3 3 1
    in
    { player =
        { level = 1
        , experience = 0
        , life = 100
        , inventory = []
        , currentWeapon = Fist
        , position = room.center
        }
    , gameMap = room :: []
    , currentRoom = room
    , roomTransition = Nothing
    }



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GenerateRoomWidthAndHeight location ( width, height ) ->
            let
                room =
                    RectangularRoom.generate location width height model.player.level
            in
            ( { model | gameMap = room :: model.gameMap }
            , Task.perform (always (EnterRoom room)) (Task.succeed ())
            )

        Direction direction ->
            let
                maybeEnemy =
                    List.Extra.find (\enemy -> enemy.position == newLocation) model.currentRoom.enemies

                newLocation =
                    movePoint direction model.player.position

                maybeGate =
                    List.Extra.find (\gate -> gate.location == newLocation) model.currentRoom.gates
            in
            case maybeGate of
                Just gate ->
                    ( { model | roomTransition = Just direction }, Task.perform (always (EnterGate gate)) (Task.succeed ()) )

                Nothing ->
                    case maybeEnemy of
                        Nothing ->
                            ( { model
                                | player = movePlayer direction model
                              }
                            , Cmd.none
                            )

                        Just enemy ->
                            ( model, Task.perform (always (AttackEnemy enemy)) (Task.succeed ()) )

        EnterGate gate ->
            let
                roomCoords =
                    GameMap.roomCoords model.currentRoom.location gate.direction

                maybeRoom =
                    List.Extra.find (\room -> room.location == roomCoords) model.gameMap
            in
            case maybeRoom of
                Just room ->
                    ( model
                    , Task.perform (always (EnterRoom room)) (Task.succeed ())
                    )

                Nothing ->
                    ( model
                    , generateRoomWidthHeight roomCoords
                    )

        PlaceEnemy ( indexPosition, enemyType, room ) ->
            ( if not (room.location == ( 0, 0 )) then
                addEnemyToModel ( indexPosition, enemyType, room ) model

              else
                model
            , Cmd.none
            )

        AttackEnemy target ->
            let
                attacked =
                    Action.hitEnemy model.player.currentWeapon target

                updatedRoom =
                    RectangularRoom.updateEnemies model.currentRoom target attacked
            in
            ( { model
                | currentRoom = updatedRoom
                , gameMap = List.Extra.setIf (\r -> r.location == updatedRoom.location) updatedRoom model.gameMap
              }
            , Task.perform
                (always
                    (if attacked.lifePoints <= 0 then
                        GainExperience attacked

                     else
                        AttackPlayer target
                    )
                )
                (Task.succeed ())
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

        None ->
            ( model, Cmd.none )

        EnterRoom room ->
            case model.roomTransition of
                Just direction ->
                    let
                        entrance =
                            List.Extra.find (\gate -> Utils.oppositeDirection gate.direction == direction) room.gates
                    in
                    case entrance of
                        Just gate ->
                            let
                                playerPos =
                                    movePoint direction gate.location
                            in
                            ( { model | currentRoom = room, roomTransition = Nothing, player = setPlayerPosition model.player playerPos }
                            , placeEnemy room
                            )

                        Nothing ->
                            ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )


addEnemyToModel : ( Int, EnemyType, RectangularRoom ) -> Model -> Model
addEnemyToModel ( indexPos, enemyT, room ) model =
    let
        updatedRoom =
            { room | enemies = Entity.createEnemy room.level (List.Extra.getAt indexPos room.inner) enemyT ++ room.enemies }
    in
    { model
        | currentRoom = updatedRoom
        , gameMap = List.Extra.setIf (\r -> r.location == updatedRoom.location) updatedRoom model.gameMap
    }


addRoom : RectangularRoom -> Model -> Model
addRoom room model =
    case model of
        { gameMap, player } ->
            { model
                | gameMap = room :: model.gameMap
                , player =
                    if List.length gameMap == 0 then
                        { player | position = room.center }

                    else
                        player
            }


movePlayer : Direction -> Model -> Player
movePlayer direction { player, currentRoom } =
    let
        changedPlayer =
            { player
                | position = movePoint direction player.position
            }
    in
    if
        --outOfBounds currentRoom changedPlayer.position
        not (List.any (\walkableTile -> changedPlayer.position == walkableTile) currentRoom.inner)
            || List.any (\enemy -> changedPlayer.position == enemy.position) currentRoom.enemies
    then
        player

    else
        changedPlayer


setPlayerPosition : Player -> ( Int, Int ) -> Player
setPlayerPosition player position =
    { player | position = position }


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



---- VIEW ----


outOfBounds : RectangularRoom -> ( Int, Int ) -> Bool
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
        , div [ class "mainContainer" ]
            [ div [ class "gameContainer" ]
                [ svg svgCanvasStyle
                    (rect
                        (svgCanvasStyle ++ [ fill "#A9A9A9", stroke "black", strokeWidth "1" ])
                        []
                        :: generateGridlines
                        ++ RectangularRoom.drawSVGRoom model.currentRoom
                        ++ playerToSvg
                            model.player
                        :: enemiesToSvg model.currentRoom.enemies
                    )
                ]
            , div [ class "dialogContainer" ]
                [ div [ class "mapContainer" ] [ h1 [] [ text "World Map" ] ]
                , div [ class "inventoryContainer" ] [ h1 [] [ text "Inventory" ] ]
                ]
            ]
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
            None


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onKeyDown (keyDecoder model)
        ]



---- GENERATE ROOM ----


generateRoomWidthHeight : ( Int, Int ) -> Cmd Msg
generateRoomWidthHeight location =
    -- before we create a room we need to generate to Width and the Height of the Room
    Random.generate
        (\( width, height ) ->
            GenerateRoomWidthAndHeight location
                -- adjust size to uneven tiles in order to place gates in centers of walls
                ( if modBy 2 width == 0 then
                    width + 1

                  else
                    width
                , if modBy 2 height == 0 then
                    height + 1

                  else
                    height
                )
        )
        (Random.pair (Random.int Environment.roomMinWidth Environment.roomMaxWidth) (Random.int Environment.roomMinHeight Environment.roomMaxHeight))



---- PLACE ENEMIES ----


placeEnemy : RectangularRoom -> Cmd Msg
placeEnemy room =
    Random.generate (\x -> PlaceEnemy x) (enemyGenerator room)


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
        , init = \_ -> ( init, Cmd.none )
        , update = update
        , subscriptions = subscriptions
        }
