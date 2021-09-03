module Main exposing (main)

import Action
import Browser
import Browser.Events
import Chest exposing (Chest)
import Direction exposing (Direction(..))
import Enemy exposing (Enemy, EnemyType(..))
import Environment
import GameMap exposing (GameMap)
import Html exposing (Attribute, Html, div, h1, h2, img, p, table, td, text, tr)
import Html.Attributes exposing (class, id, src, style)
import Html.Events exposing (on)
import Item exposing (Food, Item(..), Potion, Weapon, WeaponName(..))
import Json.Decode as Decode
import List
import List.Extra
import Player exposing (Player, PlayerStatus(..))
import Process
import Random
import RectangularRoom exposing (Gate, RectangularRoom)
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Animated as Animated
import Simple.Animation.Property as P
import String
import Svg exposing (Svg, image, line, rect, svg)
import Svg.Attributes exposing (fill, height, stroke, strokeWidth, viewBox, width, x, x1, x2, xlinkHref, y, y1, y2)
import Task
import Time
import Utils


type alias Model =
    { player : Player
    , gameMap : GameMap
    , currentRoom : RectangularRoom
    , roomTransition : Maybe Direction
    , status : Status
    , zone : Maybe Time.Zone
    , history : List ( Time.Posix, String )
    }


type Msg
    = None
    | Direction Direction
    | GenerateRoom ( Int, Int ) ( Int, Int ) (List ( Int, Int ))
    | EnemyMovement Enemy ( Int, Int )
    | PlayerStatusToStanding
    | PlaceEnemy ( Int, EnemyType, RectangularRoom ) (List Item)
    | AttackEnemy Enemy
    | AttackPlayer Enemy
    | GainExperience Enemy
    | LevelUp Player
    | EnterGate Gate
    | EnterRoom RectangularRoom (List Item)
    | Die
    | Tick
    | Pause
    | TileClick ( Int, Int )
    | ClickChangeInfoItem Item
    | RemoveItem Item
    | UseItem Item
    | TileMouseOver ( Int, Int )
    | GetTimeZone Time.Zone
    | AddToHistory String Time.Posix
    | Loot Chest


type Status
    = Running
    | Paused
    | Dead


init : Model
init =
    let
        room =
            RectangularRoom.generate ( 0, 0 ) ( 3, 3 ) [] 1
    in
    { player =
        { level = 1
        , experience = 0
        , life = 10
        , inventory = [ Foods Item.pierog, Weapons Item.stick, Potions Item.milkPot, Foods Item.beef ]
        , currentWeapon = Nothing
        , position = room.center
        , prevPosition = room.center
        , lookDirection = Down
        , playerStatus = Standing
        , currentInfoItem = Just (Foods Item.onigiri)
        }
    , zone = Nothing
    , gameMap = [ room ]
    , currentRoom = room
    , roomTransition = Nothing
    , status = Running
    , history = []
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
update msg ({ player, gameMap, currentRoom, roomTransition, status } as model) =
    case msg of
        GenerateRoom location size obstacles ->
            if List.length obstacles < Environment.wallCount then
                ( model, generateObstacleCoord location size obstacles )

            else
                let
                    room =
                        RectangularRoom.generate location size obstacles player.level
                in
                ( { model | gameMap = room :: model.gameMap }
                , msgToCmdMsg (EnterRoom room [])
                )

        PlayerStatusToStanding ->
            ( { model
                | player = player |> Player.playerStatusToStanding
              }
            , Cmd.none
            )

        Direction direction ->
            case status of
                Running ->
                    let
                        maybeEnemy =
                            List.Extra.find (\enemy -> enemy.position == newLocation) currentRoom.enemies

                        newLocation =
                            movePoint direction player.position

                        maybeGate =
                            List.Extra.find (\gate -> gate.location == newLocation) currentRoom.gates

                        maybeChest =
                            List.Extra.find (\chest -> chest.location == newLocation) currentRoom.chests
                    in
                    case maybeGate of
                        Just gate ->
                            ( { model | roomTransition = Just direction }, msgToCmdMsg (EnterGate gate) )

                        Nothing ->
                            case maybeEnemy of
                                Nothing ->
                                    case maybeChest of
                                        Just chest ->
                                            ( model, msgToCmdMsg (Loot chest) )

                                        Nothing ->
                                            ( { model
                                                | player = movePlayer direction model
                                              }
                                            , delayCmdMsg Action.playerWalkingDuration PlayerStatusToStanding
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
                    GameMap.roomCoords currentRoom.location gate.direction

                maybeRoom =
                    List.Extra.find (\room -> room.location == roomCoords) gameMap
            in
            case maybeRoom of
                Just room ->
                    ( model
                    , msgToCmdMsg (EnterRoom room [])
                    )

                Nothing ->
                    ( model
                    , generateRoomWidthHeight roomCoords
                    )

        PlaceEnemy ( indexPosition, enemyType, room ) loot ->
            ( if not (room.location == ( 0, 0 )) then
                addEnemyToModel indexPosition enemyType room loot model

              else
                model
            , Cmd.none
            )

        AttackEnemy target ->
            let
                attacked =
                    Action.hitEnemy player.currentWeapon target

                updatedRoom =
                    RectangularRoom.updateEnemies currentRoom target attacked
            in
            ( updatePlayerLookDirection
                { model
                    | currentRoom = updatedRoom
                    , gameMap = List.Extra.setIf (\r -> r.location == updatedRoom.location) updatedRoom gameMap
                }
                target.position
            , Cmd.batch
                (if attacked.lifePoints <= 0 then
                    [ msgToCmdMsg (GainExperience attacked)
                    , Task.perform (AddToHistory ("Player kills " ++ Enemy.enemyTypeToString target.enemyType)) Time.now
                    ]

                 else
                    [ msgToCmdMsg (AttackPlayer attacked)
                    , Task.perform (AddToHistory ("Player attacks " ++ Enemy.enemyTypeToString target.enemyType)) Time.now
                    ]
                )
            )

        AttackPlayer enemy ->
            let
                updatedPlayer =
                    Action.hitPlayer enemy player |> Player.playerStatusToAttacking

                newRoom =
                    RectangularRoom.updateEnemyLookDirectionInRoom enemy player.position currentRoom
            in
            ( { model
                | player = updatedPlayer
                , currentRoom = newRoom
              }
            , Cmd.batch
                (if updatedPlayer.life <= 0 then
                    [ msgToCmdMsg Die ]

                 else
                    [ delayCmdMsg Action.attackDuration PlayerStatusToStanding, Task.perform (AddToHistory (Enemy.enemyTypeToString enemy.enemyType ++ " attacks Player")) Time.now ]
                )
            )

        GainExperience enemy ->
            let
                updatedPlayer =
                    Utils.gainExperience player enemy

                levelUp =
                    Utils.experienceToLevelUp updatedPlayer.level <= updatedPlayer.experience

                updatedRoom =
                    { currentRoom | chests = { location = enemy.position, loot = enemy.loot } :: currentRoom.chests }
            in
            ( { model
                | player = updatedPlayer
                , currentRoom = updatedRoom
                , gameMap = List.Extra.setIf (\r -> r.location == updatedRoom.location) updatedRoom gameMap
              }
            , if levelUp then
                msgToCmdMsg (LevelUp updatedPlayer)

              else
                Cmd.none
            )

        LevelUp _ ->
            ( { model | player = Utils.levelUp player }, Cmd.none )

        None ->
            ( model, Cmd.none )

        EnterRoom room items ->
            let
                lootLevel =
                    Item.lootTableLevel items 0
            in
            if lootLevel < room.level then
                ( model, generateItem room items lootLevel )

            else
                case roomTransition of
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
                                , placeEnemy room items
                                )

                            Nothing ->
                                ( model, Cmd.none )

                    Nothing ->
                        ( model, Cmd.none )

        Die ->
            ( { model | status = Dead, player = Player.playerStatusToDead player }, Task.perform (AddToHistory "Player Died") Time.now )

        Tick ->
            updateOnTick model

        Pause ->
            ( { model
                | status =
                    case status of
                        Running ->
                            Paused

                        Paused ->
                            Running

                        Dead ->
                            Dead
              }
            , Cmd.none
            )

        TileClick point ->
            if status == Running then
                ( updatePlayerLookDirection model point, Cmd.none )

            else
                ( model, Cmd.none )

        TileMouseOver _ ->
            ( model, Cmd.none )

        EnemyMovement enemy target ->
            if target == player.position then
                ( model, msgToCmdMsg (AttackPlayer enemy) )

            else
                let
                    updatedRoom =
                        { currentRoom
                            | enemies =
                                List.map
                                    (\e ->
                                        if e == enemy then
                                            Enemy.updateLookDirectionOnWalk { enemy | prevPosition = enemy.position, position = target }

                                        else
                                            e
                                    )
                                    currentRoom.enemies
                        }
                in
                ( { model
                    | currentRoom = updatedRoom
                    , gameMap =
                        List.map
                            (\room ->
                                if room.location == updatedRoom.location then
                                    updatedRoom

                                else
                                    room
                            )
                            gameMap
                  }
                , Cmd.none
                )

        ClickChangeInfoItem item ->
            ( { model
                | player =
                    { player
                        | currentInfoItem = Just item
                    }
              }
            , Cmd.none
            )

        RemoveItem item ->
            ( { model
                | player =
                    { player
                        | inventory = List.Extra.remove item model.player.inventory
                        , currentInfoItem =
                            case model.player.currentInfoItem of
                                Just it ->
                                    if it == item then
                                        Nothing

                                    else
                                        model.player.currentInfoItem

                                _ ->
                                    Nothing
                    }
              }
            , Cmd.none
            )

        UseItem item ->
            case item of
                Potions p ->
                    ( { model
                        | player = Player.playerUsePotion model.player p
                      }
                    , Task.perform (AddToHistory ("Player drinks " ++ Item.potionToString p)) Time.now
                    )

                Foods f ->
                    ( { model
                        | player = Player.playerUseFood model.player f
                      }
                    , Task.perform (AddToHistory ("Player eats " ++ Item.foodToString f)) Time.now
                    )

                Weapons w ->
                    ( { model
                        | player =
                            Player.playerChangeWeapon model.player w
                      }
                    , Task.perform (AddToHistory ("Player equips " ++ Item.weaponToString w)) Time.now
                    )

        AddToHistory his time ->
            let
                history =
                    model.history

                ativity =
                    ( time, his )
            in
            ( { model
                | history =
                    if List.length history >= Environment.historyLimit then
                        ativity :: List.Extra.removeAt (Environment.historyLimit - 1) history

                    else
                        ativity :: history
              }
            , Cmd.none
            )

        Loot chest ->
            let
                updatedRoom =
                    { currentRoom | chests = List.Extra.filterNot (\c -> c.location == chest.location) currentRoom.chests }
            in
            ( { model
                | player = { player | inventory = Item.addLoot player.inventory chest.loot }
                , currentRoom = updatedRoom
                , gameMap = List.Extra.setIf (\r -> r.location == updatedRoom.location) updatedRoom gameMap
              }
            , Cmd.none
            )

        GetTimeZone zone ->
            ( { model | zone = Just zone }, Task.perform (AddToHistory "Game Started...") Time.now )


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
updateOnTick ({ currentRoom, player } as model) =
    let
        maybeEnemyMovements =
            List.map (\enemy -> Action.updateEnemyOnTick enemy player currentRoom) currentRoom.enemies

        enemyMovements =
            List.filterMap identity maybeEnemyMovements
    in
    ( model
    , Cmd.batch (List.map (\( enemy, target ) -> msgToCmdMsg (EnemyMovement enemy target)) enemyMovements)
    )


addEnemyToModel : Int -> EnemyType -> RectangularRoom -> List Item -> Model -> Model
addEnemyToModel indexPos enemyT room loot model =
    let
        updatedRoom =
            { room | enemies = Enemy.createEnemy room.level (List.Extra.getAt indexPos room.inner) enemyT loot ++ room.enemies }
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
    if isPlayerPostionValid changedPlayer.position currentRoom then
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
            Action.playerWalkingDuration
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
                [ --clickPlayer
                  id idStr
                , width widthIMG
                , xlinkHref srcLink
                ]
                []
            ]
        ]


enemiesToSvg : Status -> List Enemy -> List (Svg Msg)
enemiesToSvg status enemies =
    case enemies of
        [] ->
            []

        em :: ems ->
            let
                imgSrc =
                    Enemy.imgSrc em em.lookDirection

                widthIMG =
                    String.fromInt (Environment.playerBoundBox * 4)

                vwBox =
                    Direction.getViewBoxFromDirection em.lookDirection

                emClass =
                    if status == Running then
                        "enemy_Walking"

                    else
                        "enemy_Standing"
            in
            case em of
                { position, prevPosition } ->
                    animatedG
                        (walkAnim
                            Action.enemyWalkingDuration
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
                                [ Svg.Attributes.class emClass
                                , width widthIMG
                                , xlinkHref imgSrc
                                ]
                                []
                            ]
                        ]
                        :: enemiesToSvg status ems



-- Draw outer Walls


drawOuterWalls : RectangularRoom.Wall -> List (Svg Msg)
drawOuterWalls { leftUpCorner, leftDownCorner, rightUpCorner, rightDownCorner, upWalls, downWalls, leftWalls, rightWalls, rightGateWalls, leftGateWalls, upGateWalls, downGateWalls } =
    drawCornerWall leftUpCorner Left Up
        :: drawCornerWall leftDownCorner Left Down
        :: drawCornerWall rightUpCorner Right Up
        :: drawCornerWall rightDownCorner Right Down
        :: wallsToSvg upWalls Up
        ++ drawGateWalls rightGateWalls Right
        ++ drawGateWalls leftGateWalls Left
        ++ drawGateWalls upGateWalls Up
        ++ drawGateWalls downGateWalls Down
        ++ wallsToSvg downWalls Down
        ++ wallsToSvg leftWalls Left
        ++ wallsToSvg rightWalls Right


wallsToSvg : List ( Int, Int ) -> Direction -> List (Svg Msg)
wallsToSvg list dir =
    case list of
        [] ->
            []

        p :: ps ->
            case p of
                ( wx, wy ) ->
                    image
                        [ x (String.fromInt wx)
                        , y (String.fromInt wy)
                        , width (String.fromInt Environment.playerBoundBox)
                        , height (String.fromInt Environment.playerBoundBox)
                        , xlinkHref ("assets/tiles/Walls/" ++ Direction.directionToString dir ++ "Wall.png")
                        ]
                        []
                        :: wallsToSvg ps dir


drawCornerWall : ( Int, Int ) -> Direction -> Direction -> Svg Msg
drawCornerWall ( wx, wy ) dir dir2 =
    image
        [ x (String.fromInt wx)
        , y (String.fromInt wy)
        , width (String.fromInt Environment.playerBoundBox)
        , height (String.fromInt Environment.playerBoundBox)
        , xlinkHref ("assets/tiles/Walls/" ++ Direction.directionToString dir ++ Direction.directionToString dir2 ++ "Corner.png")
        ]
        []


drawGateWalls : Maybe ( Int, Int ) -> Direction -> List (Svg Msg)
drawGateWalls gateCoord dir =
    case gateCoord of
        Nothing ->
            []

        Just ( x1, y1 ) ->
            let
                ( srcImg1, srcImg2 ) =
                    if dir == Right || dir == Left then
                        ( "Up", "Down" )

                    else
                        ( "Right", "Left" )

                ( ( xw1, yw1 ), ( xw2, yw2 ) ) =
                    if dir == Right || dir == Left then
                        ( ( x1, y1 - 1 ), ( x1, y1 + 1 ) )

                    else
                        ( ( x1 + 1, y1 ), ( x1 - 1, y1 ) )
            in
            [ image
                [ x (String.fromInt xw1)
                , y (String.fromInt yw1)
                , width (String.fromInt Environment.playerBoundBox)
                , height (String.fromInt Environment.playerBoundBox)
                , xlinkHref ("assets/tiles/Walls/" ++ srcImg1 ++ "Wall.png")
                ]
                []
            , image
                [ x (String.fromInt xw2)
                , y (String.fromInt yw2)
                , width (String.fromInt Environment.playerBoundBox)
                , height (String.fromInt Environment.playerBoundBox)
                , xlinkHref ("assets/tiles/Walls/" ++ srcImg2 ++ "Wall.png")
                ]
                []
            ]



-- Simple animation usage


walkAnim : Float -> ( Int, Int ) -> ( Int, Int ) -> Animation
walkAnim walkingDuration ( prevX, prevY ) ( x, y ) =
    Animation.steps
        { startAt = [ P.x (toFloat prevX), P.y (toFloat prevY - Environment.entityOffsetY) ]
        , options = [ Animation.linear ]
        }
        [ Animation.step (round walkingDuration) [ P.x (toFloat x), P.y (toFloat y - Environment.entityOffsetY) ]
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


svgCanvasStyle : List (Attribute msg)
svgCanvasStyle =
    [ width (String.fromInt Environment.screenWidth)
    , height (String.fromInt Environment.screenHeight)
    , viewBox ("0 0 " ++ String.fromInt Environment.screenWidth ++ " " ++ String.fromInt Environment.screenHeight)
    , fill "none"
    ]


drawSVGRoom : RectangularRoom -> List (Svg Msg)
drawSVGRoom room =
    drawTiles room.inner Environment.floorAssetPath
        -- ++ drawTiles (List.map (\gate -> gate.location) room.gates) Environment.gateAssetPath
        ++ drawGates room.gates
        ++ drawTiles room.walls Environment.obstacleAssetPath
        ++ drawTiles (List.map (\chest -> chest.location) room.chests) Environment.chestAssetPath


drawGates : List Gate -> List (Svg Msg)
drawGates gates =
    case gates of
        [] ->
            []

        g :: gs ->
            drawTiles [ g.location ] (Environment.gateAssetPath ++ Direction.directionToString g.direction ++ ".png")
                ++ drawGates gs


drawTiles : List ( Int, Int ) -> String -> List (Svg Msg)
drawTiles ls path =
    case ls of
        ( x1, y1 ) :: ps ->
            image
                [ clickTile ( x1, y1 )
                , mouseoverTile ( x1, y1 )
                , x (String.fromInt x1)
                , y (String.fromInt y1)
                , width (String.fromInt Environment.playerBoundBox)
                , height (String.fromInt Environment.playerBoundBox)
                , xlinkHref path
                , stroke "black"
                , strokeWidth "0.05"
                ]
                []
                :: drawTiles ps path

        [] ->
            []


createItemInformation : Maybe Item -> List (Html Msg)
createItemInformation maybeItem =
    case maybeItem of
        Nothing ->
            [ h2 [] [ text "Item Info" ] ]

        Just item ->
            case item of
                Foods f ->
                    itemInformationFood f

                Potions p ->
                    itemInformationPotion p

                Weapons w ->
                    itemInformationWeapon w


itemInformationFood : Food -> List (Html Msg)
itemInformationFood f =
    [ h2 [] [ text "Item Info" ]
    , img
        [ class "itemDescIMG"
        , src ("assets/items/Food/" ++ Item.foodToString f ++ ".png")
        ]
        []
    , div [ class "itemDescription" ]
        [ div [] [ text ("Name: " ++ Item.foodToString f) ]
        , div [] [ text "Type: Food" ]
        , div [] [ text ("Healpoints: " ++ String.fromInt f.healPoints) ]
        , div [] [ text ("Stack: " ++ String.fromInt f.stack) ]
        , div [ class "itemDesc" ] [ text ("Description: " ++ f.info) ]
        ]
    ]


itemInformationWeapon : Weapon -> List (Html Msg)
itemInformationWeapon w =
    [ h2 [] [ text "Item Info" ]
    , img
        [ class "itemDescIMG"
        , src ("assets/items/Weapons/" ++ Item.weaponToString w ++ "/Sprite.png")
        ]
        []
    , div [ class "itemDescription" ]
        [ div [] [ text ("Name: " ++ Item.weaponToString w) ]
        , div [] [ text "Type: Weapon" ]
        , div [] [ text ("Damage: " ++ String.fromInt w.damage) ]
        , div [] [ text ("Stack: " ++ String.fromInt w.stack) ]
        , div [ class "itemDesc" ] [ text ("Description: " ++ w.info) ]
        ]
    ]


itemInformationPotion : Potion -> List (Html Msg)
itemInformationPotion p =
    [ h2 [] [ text "Item Info" ]
    , img
        [ class "itemDescIMG"
        , src ("assets/items/Potion/" ++ Item.potionToString p ++ ".png")
        ]
        []
    , div [ class "itemDescription" ]
        [ div [] [ text ("Name: " ++ Item.potionToString p) ]
        , div [] [ text "Type: Potion" ]
        , div [] [ text ("Healpoints: " ++ String.fromInt p.healPoints) ]
        , div [] [ text ("Stack: " ++ String.fromInt p.stack) ]
        , div [ class "itemDesc" ] [ text ("Description: " ++ p.info) ]
        ]
    ]


createItemList : Int -> List Item -> List (Html Msg)
createItemList maxinventory items =
    case items of
        [] ->
            if maxinventory <= 0 then
                []

            else
                div [ class "item" ]
                    []
                    :: createItemList (maxinventory - 1) []

        x :: xs ->
            (case x of
                Potions p ->
                    div [ class "item" ]
                        [ img [ clickChangeInfoItem x, class "itemIMG", src ("assets/items/Potion/" ++ Item.potionToString p ++ ".png") ] []
                        , div [ class "itemText" ] [ text (Item.potionToString p ++ " (" ++ String.fromInt p.stack ++ ")") ]
                        , div [ class "itemUsage" ]
                            [ img [ clickUseItem x, class "usage itemUse", src "assets/usage/drink.png" ] []
                            , img [ clickChangeInfoItem x, class "usage itemInfo", src "assets/usage/info.png" ] []
                            , img [ clickRemoveItem x, class "usage itemRemoveAll", src "assets/usage/delete.png" ] []
                            ]
                        ]

                Foods f ->
                    div [ class "item" ]
                        [ img [ clickChangeInfoItem x, class "itemIMG", src ("assets/items/Food/" ++ Item.foodToString f ++ ".png") ] []
                        , div [ class "itemText" ] [ text (Item.foodToString f ++ " (" ++ String.fromInt f.stack ++ ")") ]
                        , div [ class "itemUsage" ]
                            [ img [ clickUseItem x, class "usage itemUse", src "assets/usage/eat.png" ] []
                            , img [ clickChangeInfoItem x, class "usage itemInfo", src "assets/usage/info.png" ] []
                            , img [ clickRemoveItem x, class "usage itemRemoveAll", src "assets/usage/delete.png" ] []
                            ]
                        ]

                Weapons w ->
                    div [ class "item" ]
                        [ img [ clickChangeInfoItem x, class "itemIMG", src ("assets/items/Weapons/" ++ Item.weaponToString w ++ "/Sprite.png") ] []
                        , div [ class "itemText" ] [ text (Item.weaponToString w ++ " (" ++ String.fromInt w.stack ++ ")") ]
                        , div [ class "itemUsage" ]
                            [ img [ clickUseItem x, class "usage itemUse", src "assets/usage/hand.png" ] []
                            , img [ clickChangeInfoItem x, class "usage itemInfo", src "assets/usage/info.png" ] []
                            , img [ clickRemoveItem x, class "usage itemRemoveAll", src "assets/usage/delete.png" ] []
                            ]
                        ]
            )
                :: createItemList (maxinventory - 1) xs


displayPlayerStats : Status -> Player -> Html Msg
displayPlayerStats status player =
    div
        [ class "statsContainer" ]
        [ Html.h3 [] [ text "Character Stats" ]
        , div [ class "faceSetBox" ] [ img [ src "assets/HUD/Face.png" ] [] ]
        , table []
            [ tr [] [ td [] [ text "Level:" ], td [] [ text (String.fromInt player.level) ] ]
            , tr [] [ td [] [ text "Health: " ], td [] [ text (String.fromInt player.life) ] ]
            , tr []
                [ td [] [ text "Atk: " ]
                , td []
                    [ text
                        (case player.currentWeapon of
                            Nothing ->
                                String.fromInt Item.nonWeaponDamage

                            Just weapon ->
                                String.fromInt weapon.damage
                        )
                    ]
                ]
            , tr []
                [ td [] [ text "Experience: " ]
                , td [] [ text (String.fromInt player.experience) ]
                ]
            , tr []
                [ td [] [ text "Weapon: " ]
                , td []
                    [ text
                        (case player.currentWeapon of
                            Nothing ->
                                "Fist (No Weapon)"

                            Just weapon ->
                                Item.weaponToString weapon
                        )
                    ]
                ]
            , tr []
                [ td [] [ text "Status: " ]
                , td []
                    [ text
                        (if status == Dead then
                            "Dead"

                         else
                            "Alive"
                        )
                    ]
                ]
            ]
        ]


timeToString : Time.Zone -> Time.Posix -> String
timeToString zone time =
    String.fromInt (Time.toHour zone time)
        ++ ":"
        ++ String.fromInt (Time.toMinute zone time)
        ++ ":"
        ++ String.fromInt (Time.toSecond zone time)


displayHistory : Model -> Html Msg
displayHistory model =
    div
        [ class "historyContainer" ]
        [ Html.h3 []
            [ text "History" ]
        , div [ class "historyDisplayer" ] [ table [] (displayHistoryHelper model.zone model.history) ]
        ]


displayHistoryHelper : Maybe Time.Zone -> List ( Time.Posix, String ) -> List (Html Msg)
displayHistoryHelper zone history =
    case history of
        [] ->
            []

        h :: hs ->
            case h of
                ( time, activity ) ->
                    tr []
                        [ td [ class "historyTime" ]
                            [ text
                                (case zone of
                                    Nothing ->
                                        ""

                                    Just z ->
                                        timeToString z time
                                )
                            ]
                        , td [ class "historyActivity" ] [ text activity ]
                        ]
                        :: displayHistoryHelper zone hs


view : Model -> Html Msg
view model =
    div []
        [ div [ class "mainContainer" ]
            [ div [ class "gameContainer" ]
                [ svg
                    (id "gameCanvas" :: svgCanvasStyle)
                    (rect
                        (svgCanvasStyle
                            ++ [ fill "rgb(25,25,25)"

                               --, fill "#A9A9A9"
                               , stroke "black"
                               , strokeWidth "1"
                               ]
                        )
                        []
                        :: generateGridlines
                        ++ drawOuterWalls model.currentRoom.outerWalls
                        ++ drawSVGRoom model.currentRoom
                        ++ playerToSvg
                            model.player
                        :: enemiesToSvg model.status model.currentRoom.enemies
                    )
                ]
            , div [ class "dialogContainer" ]
                [ div [ class "statsAndHistoryContainer" ]
                    [ displayPlayerStats model.status model.player
                    , displayHistory model
                    ]
                , div [ class "itemContainer" ]
                    [ h1 []
                        [ text "Inventory"
                        ]
                    , div
                        [ style "display" "flex"
                        , style "flex-direction" "row"
                        ]
                        [ div [ class "inventory" ]
                            ([]
                                ++ createItemList Item.maxInventory model.player.inventory
                            )
                        , div [ class "itemInformation" ]
                            (createItemInformation model.player.currentInfoItem)
                        ]
                    ]
                ]
            ]
        ]


clickRemoveItem : Item -> Html.Attribute Msg
clickRemoveItem item =
    on "click" (Decode.succeed (RemoveItem item))


clickChangeInfoItem : Item -> Html.Attribute Msg
clickChangeInfoItem item =
    on "click" (Decode.succeed (ClickChangeInfoItem item))


clickUseItem : Item -> Html.Attribute Msg
clickUseItem item =
    on "click" (Decode.succeed (UseItem item))


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


tickSubscription : Model -> Sub Msg
tickSubscription model =
    case model.status of
        Running ->
            Time.every 700 (\_ -> Tick)

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
            GenerateRoom location
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
                []
        )
        (Random.pair (Random.int Environment.roomMinWidth Environment.roomMaxWidth) (Random.int Environment.roomMinHeight Environment.roomMaxHeight))


generateObstacleCoord : ( Int, Int ) -> ( Int, Int ) -> List ( Int, Int ) -> Cmd Msg
generateObstacleCoord location ( width, height ) coords =
    let
        ( offsetX, offsetY ) =
            RectangularRoom.roomOffset width height
    in
    Random.generate (\coord -> GenerateRoom location ( width, height ) (coord :: coords))
        (Random.pair (Random.int (offsetX + 1) (offsetX + width // 2)) (Random.int (offsetY + 1) (offsetY + height // 2)))



---- PLACE ENEMIES ----


placeEnemy : RectangularRoom -> List Item -> Cmd Msg
placeEnemy room items =
    Random.generate
        (\x -> PlaceEnemy x items)
        (enemyGenerator room)


enemyGenerator : RectangularRoom -> Random.Generator ( Int, EnemyType, RectangularRoom )
enemyGenerator room =
    -- return random index of a coord for roomPosition and a Enemy type
    Random.map2 (\position enemytype -> ( position, enemytype, room )) (Random.int 0 (List.length room.inner)) randomEnemy


randomEnemy : Random.Generator EnemyType
randomEnemy =
    Random.weighted ( 80, Slime ) [ ( 20, Cyclopes ), ( 40, Mole ) ]


generateItem : RectangularRoom -> List Item -> Int -> Cmd Msg
generateItem room loot level =
    let
        maybeItemGenerator =
            randomItem (room.level - level)
    in
    case maybeItemGenerator of
        Just generator ->
            Random.generate (\item -> EnterRoom room (item :: loot)) generator

        Nothing ->
            msgToCmdMsg (EnterRoom room loot)


randomItem : Int -> Maybe (Random.Generator Item)
randomItem level =
    let
        loot =
            Item.lootTable level
    in
    case loot of
        item :: rest ->
            Just (Random.uniform item rest)

        [] ->
            Nothing



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> ( init, Task.perform GetTimeZone Time.here )
        , update = update
        , subscriptions = subscriptions
        }
