module Main exposing (main)

import Action
import Browser
import Browser.Events
import Dict exposing (Dict)
import Direction exposing (Direction(..))
import Enemy exposing (Enemy, EnemyType(..))
import Environment
import GameMap exposing (GameMap)
import Html exposing (Attribute, Html, div, h1, text)
import Html.Attributes exposing (class, id)
import Html.Events exposing (on)
import Json.Decode as Decode
import List.Extra
import Player exposing (Player, PlayerStatus(..))
import Process
import Random
import RectangularRoom exposing (Gate, RectangularRoom)
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Animated as Animated
import Simple.Animation.Property as P
import Svg exposing (Svg, image, line, rect, svg)
import Svg.Attributes exposing (fill, height, stroke, strokeWidth, viewBox, width, x, x1, x2, xlinkHref, y, y1, y2)
import Task
import Time
import Utils
import Weapon exposing (Weapon(..))


type alias Model =
    { player : Player
    , gameMap : GameMap
    , currentRoom : RectangularRoom
    , roomTransition : Maybe Direction
    , status : Status
    }


type Msg
    = None
    | Direction Direction
    | PlayerStatusToStanding
    | GenerateRoomWidthAndHeight ( Int, Int ) ( Int, Int )
    | PlaceEnemy ( Int, EnemyType, RectangularRoom )
    | AttackEnemy Enemy
    | AttackPlayer Enemy
    | GainExperience Enemy
    | LevelUp Player
    | EnterGate Gate
    | EnterRoom RectangularRoom
    | Die
    | Tick
    | Pause
    | MouseMove Float Float
    | TileClick ( Int, Int )
    | TileMouseOver ( Int, Int )
    | Click


type Status
    = Running
    | Paused
    | Dead


type JsVal
    = JsString String
    | JsInt Int
    | JsFloat Float
    | JsArray (List JsVal)
    | JsObject (Dict String JsVal)
    | JsNull


init : Model
init =
    let
        room =
            RectangularRoom.generate ( 0, 0 ) 3 3 1
    in
    { player =
        { level = 1
        , experience = 0
        , life = 10
        , inventory = []
        , currentWeapon = Fist
        , position = room.center
        , prevPosition = room.center
        , lookDirection = Down
        , playerStatus = Standing
        }
    , gameMap = [ room ]
    , currentRoom = room
    , roomTransition = Nothing
    , status = Running
    }



---- UPDATE ----


delayCmdMsg : Float -> Msg -> Cmd Msg
delayCmdMsg time msg =
    Process.sleep time
        |> Task.perform (\_ -> msg)


msgToCmdMsg : Msg -> Cmd Msg
msgToCmdMsg msg =
    Task.perform (always msg) (Task.succeed ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GenerateRoomWidthAndHeight location ( width, height ) ->
            let
                room =
                    RectangularRoom.generate location width height model.player.level
            in
            ( { model | gameMap = room :: model.gameMap }
            , msgToCmdMsg (EnterRoom room)
            )

        PlayerStatusToStanding ->
            ( { model
                | player = model.player |> Player.playerStatusToStanding
              }
            , Cmd.none
            )

        Direction direction ->
            case model.status of
                Running ->
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
                            ( { model | roomTransition = Just direction }, msgToCmdMsg (EnterGate gate) )

                        Nothing ->
                            case maybeEnemy of
                                Nothing ->
                                    ( { model
                                        | player = movePlayer direction model
                                      }
                                    , delayCmdMsg Action.walkingDuration PlayerStatusToStanding
                                    )

                                Just enemy ->
                                    ( model, msgToCmdMsg (AttackEnemy enemy) )

                Paused ->
                    ( model, Cmd.none )

                Dead ->
                    ( model, Cmd.none )

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
                    , msgToCmdMsg (EnterRoom room)
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
            ( updatePlayerLookDirection
                { model
                    | currentRoom = updatedRoom
                    , gameMap = List.Extra.setIf (\r -> r.location == updatedRoom.location) updatedRoom model.gameMap
                }
                target.position
            , msgToCmdMsg
                (if attacked.lifePoints <= 0 then
                    GainExperience attacked

                 else
                    AttackPlayer attacked
                )
            )

        AttackPlayer enemy ->
            let
                updatedPlayer =
                    Action.hitPlayer enemy model.player |> Player.playerStatusToAttacking

                newRoom =
                    RectangularRoom.updateEnemyLookDirectionInRoom enemy model.player.position model.currentRoom
            in
            ( { model
                | player = updatedPlayer
                , currentRoom = newRoom
              }
            , if updatedPlayer.life <= 0 then
                msgToCmdMsg Die

              else
                delayCmdMsg Action.attackDuration PlayerStatusToStanding
            )

        GainExperience enemy ->
            let
                newXpPlayer =
                    Utils.gainExperience model.player enemy

                levelUp =
                    Utils.experienceToLevelUp newXpPlayer.level <= newXpPlayer.experience
            in
            ( { model | player = newXpPlayer }
            , if levelUp then
                msgToCmdMsg (LevelUp newXpPlayer)

              else
                Cmd.none
            )

        LevelUp _ ->
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

                                player =
                                    model.player
                            in
                            ( { model
                                | currentRoom = room
                                , roomTransition = Nothing
                                , player =
                                    { player
                                        | position = playerPos
                                        , prevPosition = playerPos
                                        , lookDirection = Direction.oppositeDirection gate.direction
                                    }
                              }
                            , placeEnemy room
                            )

                        Nothing ->
                            ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        Die ->
            ( { model | status = Dead, player = Player.playerStatusToDead model.player }, Cmd.none )

        Tick ->
            updateOnTick model

        Pause ->
            ( { model
                | status =
                    case model.status of
                        Running ->
                            Paused

                        Paused ->
                            Running

                        Dead ->
                            Dead
              }
            , Cmd.none
            )

        MouseMove x y ->
            let
                _ =
                    Debug.log "x" x

                _ =
                    Debug.log "y" y
            in
            ( model, Cmd.none )

        Click ->
            let
                _ =
                    Debug.log "click" "message"
            in
            ( model, Cmd.none )

        TileClick point ->
            ( updatePlayerLookDirection model point, Cmd.none )

        TileMouseOver _ ->
            ( model, Cmd.none )


updatePlayerLookDirection : Model -> ( Int, Int ) -> Model
updatePlayerLookDirection ({ player } as model) point =
    let
        direction =
            Direction.changeLookDirection player.position point
    in
    case direction of
        Just dir ->
            { model
                | player =
                    { player
                        | lookDirection = dir
                    }
            }

        Nothing ->
            model


updateOnTick : Model -> ( Model, Cmd Msg )
updateOnTick ({ currentRoom } as model) =
    ( { model
        | currentRoom =
            { currentRoom | enemies = List.map (\enemy -> Action.updateEnemyOnTick enemy) currentRoom.enemies }
      }
    , Cmd.none
    )


addEnemyToModel : ( Int, EnemyType, RectangularRoom ) -> Model -> Model
addEnemyToModel ( indexPos, enemyT, room ) model =
    let
        updatedRoom =
            { room | enemies = Enemy.createEnemy room.level (List.Extra.getAt indexPos room.inner) enemyT ++ room.enemies }
    in
    { model
        | currentRoom = updatedRoom
        , gameMap = List.Extra.setIf (\r -> r.location == updatedRoom.location) updatedRoom model.gameMap
    }


movePlayer : Direction -> Model -> Player
movePlayer direction { player, currentRoom } =
    let
        changedPlayer =
            { player
                | prevPosition = player.position
                , position = movePoint direction player.position
                , lookDirection = direction
                , playerStatus = Walking
            }
    in
    if
        --outOfBounds currentRoom changedPlayer.position
        isPlayerPostionValid changedPlayer.position currentRoom
    then
        { player
            | lookDirection = direction
        }

    else
        changedPlayer


isPlayerPostionValid : ( Int, Int ) -> RectangularRoom -> Bool
isPlayerPostionValid position currentRoom =
    not (List.any (\walkableTile -> position == walkableTile) currentRoom.inner)
        || List.any (\enemy -> position == enemy.position) currentRoom.enemies


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
playerToSvg { position, prevPosition, lookDirection, playerStatus } =
    let
        idStr =
            "player_" ++ Player.playerStatusToString playerStatus ++ "_" ++ Direction.directionToString lookDirection

        srcLink =
            Player.changeImgSrc playerStatus lookDirection

        widthIMG =
            if playerStatus == Player.Dead then
                String.fromInt Environment.playerBoundBox

            else
                String.fromInt (Environment.playerBoundBox * 4)

        vwBox =
            if playerStatus == Player.Dead then
                "0 0 1 1"

            else
                Direction.getViewBoxFromDirection lookDirection
    in
    animatedG
        (walkAnim
            prevPosition
            position
        )
        []
        [ svg
            [ width (String.fromInt Environment.playerBoundBox)
            , viewBox vwBox
            , height (String.fromInt Environment.playerBoundBox)
            ]
            [ image
                [ clickPlayer
                , id idStr
                , width widthIMG
                , xlinkHref srcLink
                ]
                []
            ]
        ]



-- Simple animation usage


walkAnim : ( Int, Int ) -> ( Int, Int ) -> Animation
walkAnim ( prevX, prevY ) ( x, y ) =
    Animation.steps
        { startAt = [ P.x (toFloat prevX), P.y (toFloat prevY) ]
        , options = [ Animation.linear ]
        }
        [ Animation.step (round Action.walkingDuration) [ P.x (toFloat x), P.y (toFloat y) ]
        ]


animatedG : Animation -> List (Svg.Attribute msg) -> List (Svg msg) -> Svg msg
animatedG =
    animatedSvg Svg.g


animatedSvg : (List (Attribute msg) -> List (Html msg) -> Html msg) -> Animation -> List (Attribute msg) -> List (Html msg) -> Html msg
animatedSvg =
    Animated.svg
        { class = Svg.Attributes.class
        }



----


enemiesToSvg : List Enemy -> List (Svg Msg)
enemiesToSvg enemies =
    case enemies of
        [] ->
            []

        em :: ems ->
            let
                imgSrc =
                    Enemy.getEmenyLookDirImg em em.lookDirection
            in
            case em of
                { position } ->
                    image
                        [ x (String.fromInt (Tuple.first position))
                        , y (String.fromInt (Tuple.second position))
                        , width (String.fromInt Environment.playerBoundBox)
                        , height (String.fromInt Environment.playerBoundBox)
                        , fill "green"
                        , xlinkHref imgSrc
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


drawSVGRoom : RectangularRoom -> List (Svg Msg)
drawSVGRoom room =
    drawTiles room.inner "white" ++ drawTiles (List.map (\gate -> gate.location) room.gates) "green"


drawTiles : List ( Int, Int ) -> String -> List (Svg Msg)
drawTiles ls color =
    case ls of
        ( x1, y1 ) :: ps ->
            image
                [ clickTile ( x1, y1 )
                , mouseoverTile ( x1, y1 )
                , x (String.fromInt x1)
                , y (String.fromInt y1)
                , width (String.fromInt Environment.playerBoundBox)
                , height (String.fromInt Environment.playerBoundBox)
                , fill color
                , xlinkHref "assets/floor_1.png"
                , stroke "black"
                , strokeWidth "0.05"
                ]
                []
                :: drawTiles ps color

        [] ->
            []


statusDisplay : Status -> String
statusDisplay status =
    case status of
        Running ->
            "RUNNING"

        Paused ->
            "PAUSED"

        Dead ->
            "DEAD"


view : Model -> Html Msg
view model =
    div []
        [ div [ class "mainContainer" ]
            [ div [ class "gameContainer" ]
                [ svg
                    (id "gameCanvas" :: svgCanvasStyle)
                    (rect
                        (svgCanvasStyle ++ [ fill "#A9A9A9", stroke "black", strokeWidth "1" ])
                        []
                        :: generateGridlines
                        ++ drawSVGRoom model.currentRoom
                        ++ playerToSvg
                            model.player
                        :: enemiesToSvg model.currentRoom.enemies
                    )
                ]
            , div [ class "dialogContainer" ]
                [ div [ class "mapContainer" ] [ h1 [] [ text "World Map" ] ]

                --, div [ class "inventoryContainer" ] [ h1 [] [ text "Inventory" ] ]
                , div [ class "statusContainer" ] [ h1 [] [ text (statusDisplay model.status) ] ]
                ]
            ]
        ]


clickPlayer : Html.Attribute Msg
clickPlayer =
    on "click"
        (Decode.map toClick
            (Decode.field "target" jsValDecoder)
        )


clickTile : ( Int, Int ) -> Html.Attribute Msg
clickTile point =
    on "click" (Decode.succeed (TileClick point))


mouseoverTile : ( Int, Int ) -> Html.Attribute Msg
mouseoverTile point =
    on "mousehover" (Decode.succeed (TileMouseOver point))



---- SUBSCRIPTION EVENTS ----


keyDecoder : Decode.Decoder Msg
keyDecoder =
    Decode.map toKey (Decode.field "key" Decode.string)


toKey : String -> Msg
toKey string =
    case string of
        "ArrowUp" ->
            Direction Up

        "ArrowDown" ->
            Direction Down

        "ArrowRight" ->
            Direction Right

        "ArrowLeft" ->
            Direction Left

        "p" ->
            Pause

        _ ->
            None


toMouseMove : Float -> Float -> Msg
toMouseMove x y =
    MouseMove x y


jsValDecoder : Decode.Decoder JsVal
jsValDecoder =
    Decode.oneOf
        [ Decode.map JsString Decode.string
        , Decode.map JsInt Decode.int
        , Decode.map JsFloat Decode.float
        , Decode.list (Decode.lazy (\_ -> jsValDecoder)) |> Decode.map JsArray
        , Decode.dict (Decode.lazy (\_ -> jsValDecoder)) |> Decode.map JsObject
        , Decode.null JsNull
        ]



--(Decode.field "altKey" Decode.bool)


toClick : JsVal -> Msg
toClick str =
    let
        _ =
            Debug.log "str" str
    in
    Click


tickSubscription : Model -> Sub Msg
tickSubscription model =
    case model.status of
        Running ->
            Time.every 400 (\_ -> Tick)

        Paused ->
            Sub.none

        Dead ->
            Sub.none


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ if model.player.playerStatus == Standing then
            Browser.Events.onKeyDown keyDecoder

          else
            Sub.none

        --, Browser.Events.onMouseMove mousePositionDecoder
        , tickSubscription model

        --, Browser.Events.onClick clickDecoder
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
    Random.weighted ( 80, Slime ) [ ( 20, Cyclopes ), ( 40, Mole ) ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> ( init, Cmd.none )
        , update = update
        , subscriptions = subscriptions
        }
