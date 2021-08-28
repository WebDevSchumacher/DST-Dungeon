module Item exposing (Item, ItemName, getItemInfo)


type ItemName
    = Beaf
    | Sushi
    | Onigiri
    | Shrimp
    | LifePot
    | Medipack
    | MilkPot



-- type Itemtype
--     = HealItem
--     | Weapon


type ItemType
    = Heal


type alias Item =
    { item : ItemName
    , itemTye : ItemType
    , damage : Int
    , healPoints : Int
    , maxStack : Int
    }


getItemInfo : ItemName -> Item
getItemInfo itemName =
    case itemName of
        Beaf ->
            beaf

        Sushi ->
            sushi

        Onigiri ->
            onigiri

        Shrimp ->
            shrimp

        LifePot ->
            lifePot

        Medipack ->
            medipack

        MilkPot ->
            milkPot


beaf : Item
beaf =
    { itemTye = Heal
    , item = Beaf
    , healPoints = 3
    , damage = 0
    , maxStack = 99
    }


sushi : Item
sushi =
    { itemTye = Heal
    , item = Sushi
    , healPoints = 3
    , damage = 0
    , maxStack = 99
    }


onigiri : Item
onigiri =
    { itemTye = Heal
    , item = Onigiri
    , healPoints = 4
    , damage = 0
    , maxStack = 99
    }


shrimp : Item
shrimp =
    { itemTye = Heal
    , item = Shrimp
    , healPoints = 2
    , damage = 0
    , maxStack = 99
    }


lifePot : Item
lifePot =
    { itemTye = Heal
    , item = LifePot
    , healPoints = 20
    , damage = 0
    , maxStack = 99
    }


medipack : Item
medipack =
    { itemTye = Heal
    , item = Medipack
    , healPoints = 40
    , damage = 0
    , maxStack = 99
    }


milkPot : Item
milkPot =
    { itemTye = Heal
    , item = Medipack
    , healPoints = 40
    , damage = 0
    , maxStack = 99
    }
