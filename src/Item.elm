module Item exposing
    ( Item
    , ItemName(..)
    , ItemType(..)
    , addLoot
    , assetSrc
    , axe
    , beef
    , bigSword
    , bow
    , hammer
    , isItemInList
    , itemNameToString
    , itemTypeToString
    , katana
    , lifePot
    , lootTable
    , lootTableLevel
    , medipack
    , milkPot
    , onigiri
    , pierog
    , shrimp
    , stick
    , superBow
    , sushi
    , sword
    )

import List.Extra


type ItemName
    = Beef
    | Sushi
    | Onigiri
    | Shrimp
    | Pierog
    | Axe
    | Stick
    | Bow
    | Sword
    | Hammer
    | BigSword
    | SuperBow
    | Katana
    | LifePot
    | Medipack
    | MilkPot


type ItemType
    = Weapon
    | Armor
    | Food
    | Potion


type alias Item =
    { item : ItemName
    , itemType : ItemType
    , stack : Int
    , info : String
    , itemLevel : Int
    , value : Int
    }


beef : Item
beef =
    { item = Beef
    , itemType = Food
    , value = 3
    , stack = 1
    , itemLevel = 2
    , info = "Roast beef is a traditional dish of beef which is roasted. Essentially prepared as a main meal, the leftovers are often used in sandwiches and sometimes are used to make hash."
    }


sushi : Item
sushi =
    { item = Sushi
    , itemType = Food
    , value = 3
    , stack = 1
    , itemLevel = 2
    , info = "Sushi is traditionally made with medium-grain white rice, though it can be prepared with brown rice or short-grain rice. It is very often prepared with seaheal, such as squid, eel, yellowtail, salmon, tuna or imitation crab meat. Many types of sushi are vegetarian. It is often served with pickled ginger (gari), wasabi, and soy sauce. Daikon radish or pickled daikon (takuan) are popular garnishes for the dish."
    }


onigiri : Item
onigiri =
    { item = Onigiri
    , itemType = Food
    , value = 4
    , stack = 1
    , itemLevel = 3
    , info = "Onigiri, also known as omusubi, nigirimeshi, or rice ball, is a Japanese heal made from white rice formed into triangular or cylindrical shapes and often wrapped in nori."
    }


shrimp : Item
shrimp =
    { item = Shrimp
    , itemType = Food
    , value = 2
    , stack = 1
    , itemLevel = 1
    , info = "Shrimp and prawn are types of seaheal that are consumed worldwide. Although shrimp and prawns belong to different suborders of Decapoda, they are very similar in appearance and the terms are often used interchangeably in commercial farming and wild fisheries."
    }


pierog : Item
pierog =
    { item = Pierog
    , itemType = Food
    , value = 2
    , stack = 1
    , itemLevel = 1
    , info = "Pierogi are filled dumplings made by wrapping unleavened dough around a savoury or sweet filling and cooking in boiling water. They are often then pan-fried before serving. "
    }


lifePot : Item
lifePot =
    { item = LifePot
    , itemType = Potion
    , value = 20
    , stack = 1
    , itemLevel = 8
    , info = "This is the simplest form healing Potion, it regenerates some Health"
    }


medipack : Item
medipack =
    { item = Medipack
    , itemType = Potion
    , value = 40
    , stack = 1
    , itemLevel = 10
    , info = "This pack contains several tool for threating injuries"
    }


milkPot : Item
milkPot =
    { item = MilkPot
    , itemType = Potion
    , value = 40
    , stack = 1
    , itemLevel = 10
    , info = "Milk (also known in unfermented form as sweet milk) is a nutrient-rich liquid food produced by the mammary glands of mammals."
    }


stick : Item
stick =
    { item = Stick
    , itemType = Weapon
    , value = 6
    , stack = 1
    , itemLevel = 3
    , info = "A simple stick, a pretty bad waepon but stil better then your own fist"
    }


bow : Item
bow =
    { item = Bow
    , itemType = Weapon
    , value = 10
    , stack = 1
    , itemLevel = 5
    , info = "A bow is a ranged weapon"
    }


sword : Item
sword =
    { item = Sword
    , itemType = Weapon
    , value = 15
    , stack = 1
    , itemLevel = 8
    , info = "A sword is a good weapon to defend yourself against monsters"
    }


axe : Item
axe =
    { item = Axe
    , itemType = Weapon
    , value = 30
    , stack = 1
    , itemLevel = 12
    , info = "An axe is an implement that has been used for millennia to shape, split and cut wood, to harvest timber, as a weapon, and as a ceremonial or heraldic symbol. The axe has many forms and specialised uses but generally consists of an axe head with a handle, or helve. LET'S GO AND AXE YOU ENEMIES DOWN !!!"
    }


hammer : Item
hammer =
    { item = Hammer
    , itemType = Weapon
    , value = 40
    , stack = 1
    , itemLevel = 14
    , info = "A war hammer is a weapon that was used by both foot-soldiers and cavalry. It is a very ancient weapon and gave its name, owing to its constant use, to Judah Maccabee, a 2nd-century BC Jewish rebel, and to Charles Martel, one of the rulers of France."
    }


superBow : Item
superBow =
    { item = SuperBow
    , itemType = Weapon
    , value = 40
    , stack = 1
    , itemLevel = 14
    , info = "This is an enhanced version of the Bow, it deals way more damge then a regular one"
    }


bigSword : Item
bigSword =
    { item = BigSword
    , itemType = Weapon
    , value = 40
    , stack = 1
    , itemLevel = 14
    , info = "An enhanced version of the sword, it is a sword that is only used by skilled warriors"
    }


katana : Item
katana =
    { item = Katana
    , itemType = Weapon
    , value = 55
    , stack = 1
    , itemLevel = 18
    , info = "A katana is a Japanese sword characterized by a curved, single-edged blade with a circular or squared guard and long grip to accommodate two hands. Developed later than the tachi, it was used by samurai in feudal Japan and worn with the blade facing upward."
    }


itemNameToString : Item -> String
itemNameToString item =
    case item.item of
        Beef ->
            "Beef"

        Sushi ->
            "Sushi"

        Onigiri ->
            "Onigiri"

        Shrimp ->
            "Shrimp"

        Pierog ->
            "Pierog"

        Axe ->
            "Axe"

        Stick ->
            "Stick"

        Bow ->
            "Bow"

        Sword ->
            "Sword"

        Hammer ->
            "Hammer"

        BigSword ->
            "BigSword"

        SuperBow ->
            "SuperBow"

        Katana ->
            "Katana"

        LifePot ->
            "LifePot"

        Medipack ->
            "Medipack"

        MilkPot ->
            "MilkPot"


isItemInList : Item -> List Item -> Bool
isItemInList item itemList =
    case List.filter (\i -> i.item == item.item) itemList of
        _ :: _ ->
            True

        [] ->
            False


itemTypeToString : Item -> String
itemTypeToString item =
    case item.itemType of
        Food ->
            "Food"

        Weapon ->
            "Weapon"

        Armor ->
            "Armor"

        Potion ->
            "Potion"


items : List Item
items =
    [ shrimp
    , beef
    , sushi
    , onigiri
    , pierog
    , lifePot
    , medipack
    , milkPot
    , stick
    , axe
    , bow
    , sword
    , hammer
    , bigSword
    , superBow
    , katana
    ]



--itemLevel : Loot -> Int
--itemLevel loot =
--    case loot of
--        H heal ->
--            heal.itemLevel
--
--        W weapon ->
--            weapon.itemLevel
--
--        A armor ->
--            armor.itemLevel


lootTable : Int -> List Item
lootTable level =
    List.filter
        (\item ->
            item.itemLevel <= level
        )
        items


lootTableLevel : List Item -> Int -> Int
lootTableLevel loot acc =
    case loot of
        item :: rest ->
            lootTableLevel rest (acc + item.itemLevel)

        [] ->
            acc


addLoot : List Item -> List Item -> List Item
addLoot inventory loot =
    case loot of
        i :: is ->
            if isItemInList i inventory then
                List.Extra.updateIf (\invItem -> invItem.item == i.item)
                    (\invItem -> { invItem | stack = invItem.stack + 1 })
                    inventory

            else
                i :: addLoot inventory is

        [] ->
            inventory


assetSrc : Item -> String
assetSrc item =
    case item.itemType of
        Weapon ->
            let
                suffix =
                    ""
            in
            "assets/items/" ++ itemTypeToString item ++ "/" ++ itemNameToString item ++ "/Sprite" ++ suffix ++ ".png"

        Armor ->
            "assets/items/" ++ itemTypeToString item ++ "/" ++ itemNameToString item ++ ".png"

        Food ->
            "assets/items/" ++ itemTypeToString item ++ "/" ++ itemNameToString item ++ ".png"

        Potion ->
            "assets/items/" ++ itemTypeToString item ++ "/" ++ itemNameToString item ++ ".png"
