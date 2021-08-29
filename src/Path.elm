{--
Utility module used for enemies to find paths around obstacles to get towards the player
This is taken from https://github.com/danneu/elm-hex-grid and adjusted to Elm 0.19 and square tiles
--}


module Path exposing (pathfind)

import Dict exposing (Dict)
import RectangularRoom exposing (RectangularRoom)
import Set exposing (Set)


pathfind : ( Int, Int ) -> ( Int, Int ) -> RectangularRoom -> List ( Int, Int )
pathfind start end room =
    let
        obstacles =
            Set.fromList room.walls

        graph =
            pathGraph start end obstacles room

        accum point path =
            case Dict.get point graph of
                Nothing ->
                    --path
                    [ start ]

                Just maybeNext ->
                    case maybeNext of
                        Nothing ->
                            List.append path [ end ]

                        Just next ->
                            accum next (next :: path)
    in
    if Set.member start obstacles then
        []

    else
        List.drop 1 (accum end [])


pathGraph : ( Int, Int ) -> ( Int, Int ) -> Set ( Int, Int ) -> RectangularRoom -> Dict ( Int, Int ) (Maybe ( Int, Int ))
pathGraph start end obstacles room =
    let
        accum : List ( Int, Int ) -> Dict ( Int, Int ) (Maybe ( Int, Int )) -> Dict ( Int, Int ) (Maybe ( Int, Int ))
        accum frontier cameFrom =
            case frontier of
                [] ->
                    cameFrom

                curr :: rest ->
                    -- Short-circuit if we encounter our target ( Int, Int ).
                    -- No ( Int, Int ) in building the graph further.
                    if curr == end then
                        cameFrom

                    else
                        let
                            ( frontier_, cameFrom_ ) =
                                List.foldl
                                    (pathGraphHelp room curr)
                                    ( rest, cameFrom )
                                    (neighbors curr
                                        |> List.filter (\p -> not <| Set.member p obstacles)
                                    )
                        in
                        accum frontier_ cameFrom_
    in
    accum [ start ] (Dict.singleton start Nothing)


neighbors : ( Int, Int ) -> List ( Int, Int )
neighbors ( x, y ) =
    [ ( x + 1, y )
    , ( x, y - 1 )
    , ( x - 1, y )
    , ( x, y + 1 )
    ]


pathGraphHelp :
    RectangularRoom
    -> ( Int, Int )
    -> ( Int, Int )
    -> ( List ( Int, Int ), Dict ( Int, Int ) (Maybe ( Int, Int )) )
    -> ( List ( Int, Int ), Dict ( Int, Int ) (Maybe ( Int, Int )) )
pathGraphHelp room curr next ( frontier, cameFrom ) =
    if Dict.member next cameFrom then
        ( frontier, cameFrom )

    else if not <| List.member next room.inner then
        ( frontier, cameFrom )

    else
        ( List.append frontier [ next ]
        , Dict.insert next (Just curr) cameFrom
        )
