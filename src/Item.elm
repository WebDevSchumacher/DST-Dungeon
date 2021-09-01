module Item exposing
    ( Food
    , Item(..)
    , Potion
    , Weapon
    , WeaponName(..)
    , axe
    , beef
    , bigSword
    , bow
    , foodToString
    , hammer
    , isItemInList
    , isWeapon
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
    , potionToString
    , shrimp
    , stick
    , superBow
    , sushi
    , sword
    , weaponDamage
    , weaponToString
    )


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


type Item
    = Foods Food
    | Potions Potion
    | Weapons Weapon


type alias Weapon =
    { item : WeaponName
    , damage : Int
    , stack : Int
    , info : String
    , itemLevel : Int
    }


type alias Food =
    { item : FoodName
    , healPoints : Int
    , stack : Int
    , info : String
    , itemLevel : Int
    }


type alias Potion =
    { item : PotionName
    , healPoints : Int
    , stack : Int
    , info : String
    , itemLevel : Int
    }


type PotionName
    = LifePot
    | Medipack
    | MilkPot


type WeaponName
    = Axe
    | Stick
    | Bow
    | Sword
    | Hammer
    | BigSword
    | SuperBow
    | Katana


type FoodName
    = Beef
    | Sushi
    | Onigiri
    | Shrimp


type alias Damage =
    Int


isItemInList : Item -> List Item -> Bool
isItemInList item itemList =
    List.member item itemList


itemTypeToString : Item -> String
itemTypeToString item =
    case item of
        Potions _ ->
            "Potion"

        Foods _ ->
            "Food"

        Weapons _ ->
            "Weapon"


potionToString : Potion -> String
potionToString potion =
    case potion.item of
        LifePot ->
            "LifePot"

        Medipack ->
            "Medipack"

        MilkPot ->
            "MilkPot"


weaponToString : Weapon -> String
weaponToString weapon =
    case weapon.item of
        Stick ->
            "Stick"

        Bow ->
            "Bow"

        Sword ->
            "Sword"

        Axe ->
            "Axe"

        Hammer ->
            "Hammer"

        BigSword ->
            "BigSword"

        SuperBow ->
            "SuperBow"

        Katana ->
            "Katana"


foodToString : Food -> String
foodToString food =
    case food.item of
        Beef ->
            "Beef"

        Sushi ->
            "Sushi"

        Onigiri ->
            "Onigiri"

        Shrimp ->
            "Shrimp"


isWeapon : Item -> Bool
isWeapon item =
    case item of
        Weapons _ ->
            True

        _ ->
            False


weaponDamage : Weapon -> Damage
weaponDamage weapon =
    case weapon.item of
        Stick ->
            stick.damage

        Bow ->
            bow.damage

        Sword ->
            sword.damage

        Axe ->
            axe.damage

        Hammer ->
            hammer.damage

        BigSword ->
            bigSword.damage

        SuperBow ->
            superBow.damage

        Katana ->
            katana.damage


beef : Food
beef =
    { item = Beef
    , healPoints = 3
    , stack = 1
    , itemLevel = 2
    , info = "Roast beef is a traditional dish of beef which is roasted. Essentially prepared as a main meal, the leftovers are often used in sandwiches and sometimes are used to make hash."
    }


sushi : Food
sushi =
    { item = Sushi
    , healPoints = 3
    , stack = 1
    , itemLevel = 2
    , info = "Sushi is traditionally made with medium-grain white rice, though it can be prepared with brown rice or short-grain rice. It is very often prepared with seafood, such as squid, eel, yellowtail, salmon, tuna or imitation crab meat. Many types of sushi are vegetarian. It is often served with pickled ginger (gari), wasabi, and soy sauce. Daikon radish or pickled daikon (takuan) are popular garnishes for the dish."
    }


onigiri : Food
onigiri =
    { item = Onigiri
    , healPoints = 4
    , stack = 1
    , itemLevel = 3
    , info = "Onigiri, also known as omusubi, nigirimeshi, or rice ball, is a Japanese food made from white rice formed into triangular or cylindrical shapes and often wrapped in nori."
    }


shrimp : Food
shrimp =
    { item = Shrimp
    , healPoints = 2
    , stack = 1
    , itemLevel = 1
    , info = "Shrimp and prawn are types of seafood that are consumed worldwide. Although shrimp and prawns belong to different suborders of Decapoda, they are very similar in appearance and the terms are often used interchangeably in commercial farming and wild fisheries."
    }


lifePot : Potion
lifePot =
    { item = LifePot
    , healPoints = 20
    , stack = 1
    , itemLevel = 8
    , info = "This is the simplest form healing Potion, it regenerates some Health"
    }


medipack : Potion
medipack =
    { item = Medipack
    , healPoints = 40
    , stack = 1
    , itemLevel = 10
    , info = "This pack contains several tool for threating injuries"
    }


milkPot : Potion
milkPot =
    { item = MilkPot
    , healPoints = 40
    , stack = 1
    , itemLevel = 10
    , info = "Milk (also known in unfermented form as sweet milk) is a nutrient-rich liquid food produced by the mammary glands of mammals."
    }


stick : Weapon
stick =
    { item = Stick
    , damage = 6
    , stack = 1
    , itemLevel = 3
    , info = "A simple stick, a pretty bad waepon but stil better then your own fist"
    }


bow : Weapon
bow =
    { item = Bow
    , damage = 10
    , stack = 1
    , itemLevel = 5
    , info = "A bow is a ranged weapon"
    }


sword : Weapon
sword =
    { item = Sword
    , damage = 15
    , stack = 1
    , itemLevel = 8
    , info = "A sword is a good weapon to defend yourself against monsters"
    }


axe : Weapon
axe =
    { item = Axe
    , damage = 30
    , stack = 1
    , itemLevel = 12
    , info = "An axe is an implement that has been used for millennia to shape, split and cut wood, to harvest timber, as a weapon, and as a ceremonial or heraldic symbol. The axe has many forms and specialised uses but generally consists of an axe head with a handle, or helve. LET'S GO AND AXE YOU ENEMIES DOWN !!!"
    }


hammer : Weapon
hammer =
    { item = Hammer
    , damage = 40
    , stack = 1
    , itemLevel = 14
    , info = "A war hammer is a weapon that was used by both foot-soldiers and cavalry. It is a very ancient weapon and gave its name, owing to its constant use, to Judah Maccabee, a 2nd-century BC Jewish rebel, and to Charles Martel, one of the rulers of France."
    }


superBow : Weapon
superBow =
    { item = SuperBow
    , damage = 40
    , stack = 1
    , itemLevel = 14
    , info = "This is an enhanced version of the Bow, it deals way more damge then a regular one"
    }


bigSword : Weapon
bigSword =
    { item = BigSword
    , damage = 40
    , stack = 1
    , itemLevel = 14
    , info = "An enhanced version of the sword, it is a sword that is only used by skilled warriors"
    }


katana : Weapon
katana =
    { item = Katana
    , damage = 55
    , stack = 1
    , itemLevel = 18
    , info = "A katana is a Japanese sword characterized by a curved, single-edged blade with a circular or squared guard and long grip to accommodate two hands. Developed later than the tachi, it was used by samurai in feudal Japan and worn with the blade facing upward."
    }


items : List Item
items =
    [ Foods shrimp
    , Foods beef
    , Foods sushi
    , Foods onigiri
    , Potions lifePot
    , Potions medipack
    , Potions milkPot
    , Weapons axe
    , Weapons stick
    , Weapons bow
    , Weapons sword
    , Weapons hammer
    , Weapons bigSword
    , Weapons superBow
    , Weapons katana
    ]


itemLevel item =
    case item of
        Foods food ->
            food.itemLevel

        Potions potion ->
            potion.itemLevel

        Weapons weapon ->
            weapon.itemLevel


lootTable : Int -> List Item
lootTable level =
    List.filter
        (\item ->
            itemLevel item <= level
        )
        items


lootTableLevel : List Item -> Int -> Int
lootTableLevel loot acc =
    case loot of
        item :: rest ->
            lootTableLevel rest (acc + itemLevel item)

        [] ->
            acc
