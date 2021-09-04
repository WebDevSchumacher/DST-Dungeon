module Item exposing
    ( Armor
    , Heal
    , Item
    , ItemName(..)
    , ItemType(..)
    , Loot(..)
    , Weapon
    , addLoot
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
    , maxInventory
    , maxStack
    , medipack
    , milkPot
    , nonWeaponDamage
    , onigiri
    , pierog
    , shrimp
    , stick
    , superBow
    , sushi
    , sword
    )

import List.Extra


nonWeaponDamage : Int
nonWeaponDamage =
    5


maxStack : Int
maxStack =
    99


maxInventory : Int
maxInventory =
    -- columns * rows
    8 * 5


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
    | Heal


type alias Item a =
    { a
        | item : ItemName
        , itemType : ItemType
        , stack : Int
        , info : String
        , itemLevel : Int
    }


type alias Heal =
    Item { healPoints : Int }


type alias Weapon =
    Item { damage : Int }


type alias Armor =
    Item { armor : Int }


beef : Item Heal
beef =
    { item = Beef
    , itemType = Heal
    , healPoints = 3
    , stack = 1
    , itemLevel = 2
    , info = "Roast beef is a traditional dish of beef which is roasted. Essentially prepared as a main meal, the leftovers are often used in sandwiches and sometimes are used to make hash."
    }


sushi : Item Heal
sushi =
    { item = Sushi
    , itemType = Heal
    , healPoints = 3
    , stack = 1
    , itemLevel = 2
    , info = "Sushi is traditionally made with medium-grain white rice, though it can be prepared with brown rice or short-grain rice. It is very often prepared with seaheal, such as squid, eel, yellowtail, salmon, tuna or imitation crab meat. Many types of sushi are vegetarian. It is often served with pickled ginger (gari), wasabi, and soy sauce. Daikon radish or pickled daikon (takuan) are popular garnishes for the dish."
    }


onigiri : Item Heal
onigiri =
    { item = Onigiri
    , itemType = Heal
    , healPoints = 4
    , stack = 1
    , itemLevel = 3
    , info = "Onigiri, also known as omusubi, nigirimeshi, or rice ball, is a Japanese heal made from white rice formed into triangular or cylindrical shapes and often wrapped in nori."
    }


shrimp : Item Heal
shrimp =
    { item = Shrimp
    , itemType = Heal
    , healPoints = 2
    , stack = 1
    , itemLevel = 1
    , info = "Shrimp and prawn are types of seaheal that are consumed worldwide. Although shrimp and prawns belong to different suborders of Decapoda, they are very similar in appearance and the terms are often used interchangeably in commercial farming and wild fisheries."
    }


pierog : Item Heal
pierog =
    { item = Pierog
    , itemType = Heal
    , healPoints = 2
    , stack = 1
    , itemLevel = 1
    , info = "Pierogi are filled dumplings made by wrapping unleavened dough around a savoury or sweet filling and cooking in boiling water. They are often then pan-fried before serving. "
    }


lifePot : Item Heal
lifePot =
    { item = LifePot
    , itemType = Heal
    , healPoints = 20
    , stack = 1
    , itemLevel = 8
    , info = "This is the simplest form healing Potion, it regenerates some Health"
    }


medipack : Item Heal
medipack =
    { item = Medipack
    , itemType = Heal
    , healPoints = 40
    , stack = 1
    , itemLevel = 10
    , info = "This pack contains several tool for threating injuries"
    }


milkPot : Item Heal
milkPot =
    { item = MilkPot
    , itemType = Heal
    , healPoints = 40
    , stack = 1
    , itemLevel = 10
    , info = "Milk (also known in unfermented form as sweet milk) is a nutrient-rich liquid food produced by the mammary glands of mammals."
    }


stick : Item Weapon
stick =
    { item = Stick
    , itemType = Weapon
    , damage = 6
    , stack = 1
    , itemLevel = 3
    , info = "A simple stick, a pretty bad waepon but stil better then your own fist"
    }


bow : Item Weapon
bow =
    { item = Bow
    , itemType = Weapon
    , damage = 10
    , stack = 1
    , itemLevel = 5
    , info = "A bow is a ranged weapon"
    }


sword : Item Weapon
sword =
    { item = Sword
    , itemType = Weapon
    , damage = 15
    , stack = 1
    , itemLevel = 8
    , info = "A sword is a good weapon to defend yourself against monsters"
    }


axe : Item Weapon
axe =
    { item = Axe
    , itemType = Weapon
    , damage = 30
    , stack = 1
    , itemLevel = 12
    , info = "An axe is an implement that has been used for millennia to shape, split and cut wood, to harvest timber, as a weapon, and as a ceremonial or heraldic symbol. The axe has many forms and specialised uses but generally consists of an axe head with a handle, or helve. LET'S GO AND AXE YOU ENEMIES DOWN !!!"
    }


hammer : Item Weapon
hammer =
    { item = Hammer
    , itemType = Weapon
    , damage = 40
    , stack = 1
    , itemLevel = 14
    , info = "A war hammer is a weapon that was used by both foot-soldiers and cavalry. It is a very ancient weapon and gave its name, owing to its constant use, to Judah Maccabee, a 2nd-century BC Jewish rebel, and to Charles Martel, one of the rulers of France."
    }


superBow : Item Weapon
superBow =
    { item = SuperBow
    , itemType = Weapon
    , damage = 40
    , stack = 1
    , itemLevel = 14
    , info = "This is an enhanced version of the Bow, it deals way more damge then a regular one"
    }


bigSword : Item Weapon
bigSword =
    { item = BigSword
    , itemType = Weapon
    , damage = 40
    , stack = 1
    , itemLevel = 14
    , info = "An enhanced version of the sword, it is a sword that is only used by skilled warriors"
    }


katana : Item Weapon
katana =
    { item = Katana
    , itemType = Weapon
    , damage = 55
    , stack = 1
    , itemLevel = 18
    , info = "A katana is a Japanese sword characterized by a curved, single-edged blade with a circular or squared guard and long grip to accommodate two hands. Developed later than the tachi, it was used by samurai in feudal Japan and worn with the blade facing upward."
    }


itemNameToString : Item a -> String
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


isItemInList : Item a -> List (Item a) -> Bool
isItemInList item itemList =
    case List.filter (\i -> i.item == item.item) itemList of
        _ :: _ ->
            True

        [] ->
            False


itemTypeToString : Item a -> String
itemTypeToString item =
    case item.itemType of
        Heal ->
            "Heal"

        Weapon ->
            "Weapon"

        Armor ->
            "Armor"


type Loot
    = H Heal
    | W Weapon
    | A Armor


items : List Loot
items =
    [ H shrimp
    , H beef
    , H sushi
    , H onigiri
    , H pierog
    , H lifePot
    , H medipack
    , H milkPot
    , W stick
    , W axe
    , W bow
    , W sword
    , W hammer
    , W bigSword
    , W superBow
    , W katana
    ]


itemLevel : Loot -> Int
itemLevel loot =
    case loot of
        H heal ->
            heal.itemLevel

        W weapon ->
            weapon.itemLevel

        A armor ->
            armor.itemLevel


lootTable : Int -> List Loot
lootTable level =
    List.filter
        (\item ->
            itemLevel item <= level
        )
        items


lootTableLevel : List Loot -> Int -> Int
lootTableLevel loot acc =
    case loot of
        item :: rest ->
            lootTableLevel rest (acc + itemLevel item)

        [] ->
            acc


lootToItem : Loot -> Item a
lootToItem loot =
    case loot of
        H heal ->
            heal

        W weapon ->
            weapon

        A armor ->
            armor


itemToLoot : Item a -> Loot
itemToLoot item =
    case item.itemType of
        Weapon ->
            W item

        Armor ->
            A item

        Heal ->
            H item


addLoot : List Loot -> List Loot -> List Loot
addLoot inventory loot =
    case loot of
        i :: is ->
            let
                item =
                    lootToItem i
            in
            if isItemInList item (List.map (\invLoot -> lootToItem invLoot) inventory) then
                List.Extra.updateIf (\invLoot -> (lootToItem invLoot).item == item.item)
                    (\invLoot ->
                        let
                            invItem =
                                lootToItem invLoot
                        in
                        itemToLoot { invItem | stack = invItem.stack + 1 }
                    )
                    inventory

            else
                i :: addLoot inventory is

        [] ->
            inventory



{--
This is the most stupid thing, but idk how to do it better.
I tried to make a Type Item and the subtypes Potions, Foods & Weapons which are in Item
(Something like Inheretance in OOP, but that works the opposite way in elm, now I have to declare everything for every case, I
have to write a function that does the almost some just for all subtypes Foods, Potions & Weapons.

Should have just put the ItemType as a property one Single Item class, but the Problem is that we
have properties in Item that are for example from Weapons, but that we dont need in Potions and Foods vice versa)
--}
--
--filterItem : List Item -> List Item
--filterItem itemList =
--    List.filter
--        (\item ->
--            case item of
--                Foods f ->
--                    f.stack > 0
--
--                Potions p ->
--                    p.stack > 0
--
--                Weapons w ->
--                    w.stack > 0
--        )
--        itemList
--
--
--addPotion : List Item -> Potion -> List Item
--addPotion itemList potion =
--    List.map
--        (\item ->
--            case item of
--                Potions p ->
--                    if p.item == potion.item then
--                        Potions { p | stack = p.stack + 1 }
--
--                    else
--                        item
--
--                _ ->
--                    item
--        )
--        itemList
--
--
--addWeapon : List Item -> Weapon -> List Item
--addWeapon itemList weapon =
--    List.map
--        (\item ->
--            case item of
--                Weapons w ->
--                    if w.item == weapon.item then
--                        Weapons { w | stack = w.stack + 1 }
--
--                    else
--                        item
--
--                _ ->
--                    item
--        )
--        itemList
--
--
--addFood : List Item -> Food -> List Item
--addFood itemList food =
--    List.map
--        (\item ->
--            case item of
--                Foods f ->
--                    if f.item == food.item then
--                        Foods { f | stack = f.stack + 3 }
--
--                    else
--                        item
--
--                _ ->
--                    item
--        )
--        itemList
--
--
--addLoot : List Item -> List Item -> List Item
--addLoot inventory loot =
--    case loot of
--        [] ->
--            inventory
--
--        l :: ls ->
--            let
--                newInventory =
--                    case l of
--                        Potions p ->
--                            if isPotionInList inventory p then
--                                addPotion inventory p
--
--                            else
--                                l :: inventory
--
--                        Foods f ->
--                            if isFoodInList inventory f then
--                                addFood inventory f
--
--                            else
--                                l :: inventory
--
--                        Weapons w ->
--                            if isWeaponInList inventory w then
--                                addWeapon inventory w
--
--                            else
--                                l :: inventory
--            in
--            addLoot newInventory ls
--
--
--isFoodInList : List Item -> Food -> Bool
--isFoodInList inventory food =
--    List.any
--        (\item ->
--            case item of
--                Foods f ->
--                    food.item == f.item
--
--                _ ->
--                    False
--        )
--        inventory
--
--
--isWeaponInList : List Item -> Weapon -> Bool
--isWeaponInList inventory weapon =
--    List.any
--        (\item ->
--            case item of
--                Weapons w ->
--                    weapon.item == w.item
--
--                _ ->
--                    False
--        )
--        inventory
--
--
--isPotionInList : List Item -> Potion -> Bool
--isPotionInList inventory potion =
--    List.any
--        (\item ->
--            case item of
--                Potions p ->
--                    potion.item == p.item
--
--                _ ->
--                    False
--        )
--        inventory
