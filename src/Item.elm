module Item exposing
    ( Item
    , ItemName(..)
    , ItemType(..)
    , addLoot
    , artificerArmor
    , assetSrc
    , axe
    , beef
    , bigSword
    , bow
    , cloth
    , hammer
    , isItemInList
    , itemNameToString
    , itemTypeToString
    , katana
    , leather
    , lifePot
    , lootTable
    , lootTableLevel
    , lootToString
    , magicArmor
    , mail
    , medipack
    , milkPot
    , onigiri
    , pierog
    , plate
    , reinforcedLeather
    , reinforcedPlate
    , shrimp
    , stick
    , superBow
    , superiorArmor
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
    | Cloth
    | Leather
    | ReinforcedLeather
    | Mail
    | Plate
    | ReinforcedPlate
    | SuperiorArmor
    | MagicArmor
    | ArtificerArmor


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


shrimp : Item
shrimp =
    { item = Shrimp
    , itemType = Food
    , value = 2
    , stack = 1
    , itemLevel = 1
    , info = "Shrimp and prawn are types of seafood that are consumed worldwide. Although shrimp and prawns belong to different suborders of Decapoda, they are very similar in appearance and the terms are often used interchangeably in commercial farming and wild fisheries."
    }


pierog : Item
pierog =
    { item = Pierog
    , itemType = Food
    , value = 4
    , stack = 1
    , itemLevel = 2
    , info = "Pierogi are filled dumplings made by wrapping unleavened dough around a savoury or sweet filling and cooking in boiling water. They are often then pan-fried before serving. "
    }


beef : Item
beef =
    { item = Beef
    , itemType = Food
    , value = 7
    , stack = 1
    , itemLevel = 3
    , info = "Roast beef is a traditional dish of beef which is roasted. Essentially prepared as a main meal, the leftovers are often used in sandwiches and sometimes are used to make hash."
    }


sushi : Item
sushi =
    { item = Sushi
    , itemType = Food
    , value = 11
    , stack = 1
    , itemLevel = 4
    , info = "Sushi is traditionally made with medium-grain white rice, though it can be prepared with brown rice or short-grain rice. It is very often prepared with seafood, such as squid, eel, yellowtail, salmon, tuna or imitation crab meat. Many types of sushi are vegetarian. It is often served with pickled ginger (gari), wasabi, and soy sauce. Daikon radish or pickled daikon (takuan) are popular garnishes for the dish."
    }


onigiri : Item
onigiri =
    { item = Onigiri
    , itemType = Food
    , value = 16
    , stack = 1
    , itemLevel = 5
    , info = "Onigiri, also known as omusubi, nigirimeshi, or rice ball, is a Japanese heal made from white rice formed into triangular or cylindrical shapes and often wrapped in nori."
    }


lifePot : Item
lifePot =
    { item = LifePot
    , itemType = Potion
    , value = 25
    , stack = 1
    , itemLevel = 8
    , info = "This is the simplest form healing Potion, it regenerates some Health"
    }


medipack : Item
medipack =
    { item = Medipack
    , itemType = Potion
    , value = 45
    , stack = 1
    , itemLevel = 12
    , info = "This pack contains several tool for treating injuries"
    }


milkPot : Item
milkPot =
    { item = MilkPot
    , itemType = Potion
    , value = 80
    , stack = 1
    , itemLevel = 17
    , info = "Milk (also known in unfermented form as sweet milk) is a nutrient-rich liquid food produced by the mammary glands of mammals."
    }


stick : Item
stick =
    { item = Stick
    , itemType = Weapon
    , value = 6
    , stack = 1
    , itemLevel = 1
    , info = "A simple stick, a pretty bad weapon but stil better then your own fist"
    }


bow : Item
bow =
    { item = Bow
    , itemType = Weapon
    , value = 8
    , stack = 1
    , itemLevel = 3
    , info = "A bow is a ranged weapon"
    }


sword : Item
sword =
    { item = Sword
    , itemType = Weapon
    , value = 12
    , stack = 1
    , itemLevel = 5
    , info = "A sword is a good weapon to defend yourself against monsters"
    }


axe : Item
axe =
    { item = Axe
    , itemType = Weapon
    , value = 18
    , stack = 1
    , itemLevel = 8
    , info = "An axe is an implement that has been used for millennia to shape, split and cut wood, to harvest timber, as a weapon, and as a ceremonial or heraldic symbol. The axe has many forms and specialised uses but generally consists of an axe head with a handle, or helve. LET'S GO AND AXE YOU ENEMIES DOWN !!!"
    }


hammer : Item
hammer =
    { item = Hammer
    , itemType = Weapon
    , value = 27
    , stack = 1
    , itemLevel = 11
    , info = "A war hammer is a weapon that was used by both foot-soldiers and cavalry. It is a very ancient weapon and gave its name, owing to its constant use, to Judah Maccabee, a 2nd-century BC Jewish rebel, and to Charles Martel, one of the rulers of France."
    }


superBow : Item
superBow =
    { item = SuperBow
    , itemType = Weapon
    , value = 38
    , stack = 1
    , itemLevel = 14
    , info = "This is an enhanced version of the Bow, it deals way more damge then a regular one"
    }


bigSword : Item
bigSword =
    { item = BigSword
    , itemType = Weapon
    , value = 50
    , stack = 1
    , itemLevel = 18
    , info = "An enhanced version of the sword, it is a sword that is only used by skilled warriors"
    }


katana : Item
katana =
    { item = Katana
    , itemType = Weapon
    , value = 65
    , stack = 1
    , itemLevel = 23
    , info = "A katana is a Japanese sword characterized by a curved, single-edged blade with a circular or squared guard and long grip to accommodate two hands. Developed later than the tachi, it was used by samurai in feudal Japan and worn with the blade facing upward."
    }


cloth : Item
cloth =
    { item = Cloth
    , itemType = Armor
    , value = 1
    , stack = 1
    , itemLevel = 1
    , info = "A shirt. Don't expect much from a shirt"
    }


leather : Item
leather =
    { item = Leather
    , itemType = Armor
    , value = 3
    , stack = 1
    , itemLevel = 2
    , info = "Cured leather suit. About as robust as it looks"
    }


reinforcedLeather : Item
reinforcedLeather =
    { item = ReinforcedLeather
    , itemType = Armor
    , value = 5
    , stack = 1
    , itemLevel = 4
    , info = "Cured leather suit with a piece of metal tied to it. Might keep a knife out of your skin"
    }


mail : Item
mail =
    { item = Mail
    , itemType = Armor
    , value = 8
    , stack = 1
    , itemLevel = 5
    , info = "A chainmail suit is heavy and unwieldy but might just save your life"
    }


plate : Item
plate =
    { item = Plate
    , itemType = Armor
    , value = 11
    , stack = 1
    , itemLevel = 7
    , info = "Tough and sturdy. Any self-respecting adventurer should ask for no less"
    }


reinforcedPlate : Item
reinforcedPlate =
    { item = ReinforcedPlate
    , itemType = Armor
    , value = 15
    , stack = 1
    , itemLevel = 10
    , info = "Thicker than regular plate. Useful for heavy duty monster slaying"
    }


superiorArmor : Item
superiorArmor =
    { item = SuperiorArmor
    , itemType = Armor
    , value = 19
    , stack = 1
    , itemLevel = 14
    , info = "A quality piece of armor. Guaranteed to keep claws out and your organs inside"
    }


magicArmor : Item
magicArmor =
    { item = MagicArmor
    , itemType = Armor
    , value = 24
    , stack = 1
    , itemLevel = 19
    , info = "Quality material infused with ancient magic. A rare sight to see and worth a fortune"
    }


artificerArmor : Item
artificerArmor =
    { item = ArtificerArmor
    , itemType = Armor
    , value = 30
    , stack = 1
    , itemLevel = 24
    , info = "Forged by the fines smiths from the purest metals. Artfully designed and assembled to perfection."
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

        Cloth ->
            "Cloth"

        Leather ->
            "Leather"

        ReinforcedLeather ->
            "ReinforcedLeather"

        Mail ->
            "Mail"

        Plate ->
            "Plate"

        ReinforcedPlate ->
            "ReinforcedPlate"

        SuperiorArmor ->
            "SuperiorArmor"

        MagicArmor ->
            "MagicArmor"

        ArtificerArmor ->
            "ArtificerArmor"


lootToString : List Item -> String
lootToString loot =
    case loot of
        i :: is ->
            let
                delimiter =
                    case is of
                        _ :: _ ->
                            ","

                        [] ->
                            ""
            in
            itemNameToString i ++ delimiter ++ lootToString is

        [] ->
            ""


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
    , cloth
    , leather
    , reinforcedLeather
    , mail
    , plate
    , reinforcedPlate
    , superiorArmor
    , magicArmor
    , artificerArmor
    ]


consumables : List Item
consumables =
    [ shrimp
    , beef
    , sushi
    , onigiri
    , pierog
    , lifePot
    , medipack
    , milkPot
    ]


lootTable : Int -> List Item
lootTable level =
    let
        possibleLoot =
            if modBy 2 level == 0 then
                items

            else
                consumables
    in
    List.filter
        (\item ->
            item.itemLevel <= level
        )
        possibleLoot


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
