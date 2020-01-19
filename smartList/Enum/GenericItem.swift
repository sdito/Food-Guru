//
//  ItemName.swift
//  smartList
//
//  Created by Steven Dito on 10/8/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation


enum GenericItem: String, CaseIterable {
    case alfredoSauce
    case almond
    case almondButter
    case almondExtract
    case almondMilk
    case americanCheese
    case anchovy
    case apple
    case appleButter
    case appleCiderVinegar
    case appleJuice
    case appleSauce
    case apricot
    case arborioRice
    case artichoke
    case artichokeHeart
    case asiagoCheese
    case asparagus
    case avocado
    case avocadoOil
    case babySpinach
    case bacon
    case bagel
    case bakedBeans
    case bakingPowder
    case bakingSoda
    case balsamicVinegar
    case banana
    case barley
    case basil
    case bayLeaf
    case bbqSauce
    case beef
    case beefJerky
    case beer
    case bellPepper
    case bison
    case blackBeans
    case blackberry
    case blackOlive
    case blackPepper
    case bleuCheese
    case blueberries
    case bread
    case breadCrumbs
    case breadFlour
    case breakfastSausage
    case broccoli
    case broth
    case brownSugar
    case brusselsSprouts
    case butter
    case buttermilk
    case cabbage
    case cannedTomato
    case cannelliniBeans
    case canolaOil
    case cantaloupe
    case capers
    case carrot
    case catfish
    case cashew
    case cashewButter
    case cauliflower
    case cayenne
    case celery
    case cereal
    case champagne
    case cheddar
    case cheese
    case cherries
    case chicken
    case chickenWings
    case chili
    case chiliPowder
    case chips
    case chives
    case chocolate
    case cilantro
    case cinnamon
    case clam
    case coconutMilk
    case cod
    case coffee
    case cookingWine
    case corn
    case cornedBeef
    case cornbread
    case cornmeal
    case cornstarch
    case cottageCheese
    case crab
    case cracker
    case cranberry
    case cranberrySauce
    case cream
    case creamCheese
    case creamOfChickenSoup
    case creamOfMushroomSoup
    case cucumber
    case cumin
    case curryPowder
    case dip
    case dijonMustard
    case dillWeed
    case driedBasil
    case driedMango
    case driedParsley
    case duck
    case egg
    case eggNoodles
    case eggplant
    case favaBeans
    case fennelSeeds
    case feta
    case flounder
    case flour
    case garlic
    case garlicBread
    case garlicPowder
    case gin
    case ginger
    case gingerRoot
    case goatCheese
    case grahamCracker
    case granola
    case granolaBars
    case grapefruit
    case grape
    case greekYogurt
    case greenBeans
    case greenOlive
    case greenOnion
    case groundBeef
    case groundTurkey
    case gruyere
    case guava
    case haddock
    case halfAndHalf
    case halibut
    case ham
    case hamburgerBuns
    case hamburgerPatties
    case heavyCream
    case honey
    case honeydew
    case hotDogs
    case hotDogBuns
    case hotSauce
    case hummus
    case iceCream
    case icing
    case italianSeasoning
    case jalapeno
    case jelly
    case juice
    case kale
    case ketchup
    case kidneyBeans
    case kiwi
    case lamb
    case lasagnaNoodles
    case lemon
    case lemonJuice
    case lentil
    case lettuce
    case limaBeans
    case lime
    case limeJuice
    case lobster
    case macAndCheese
    case mahiMahi
    case mango
    case margarine
    case marinara
    case melon
    case mayonnaise
    case milk
    case montereyJackCheese
    case mozzarella
    case mushroom
    case mussels
    case mustard
    case nectarine
    case nutmeg
    case nutella
    case oatmeal
    case oats
    case oil
    case oliveOil
    case onion
    case onionPowder
    case orange
    case oregano
    case oreoCookies
    case oyster
    case oysterSauce
    case paprika
    case parmesan
    case parsley
    case pasta
    case pastrami
    case peach
    case peanutButter
    case peanut
    case peanutOil
    case pear
    case peas
    case pecan
    case pepper
    case pepperoni
    case pestoSauce
    case pickle
    case pineapple
    case pintoBeans
    case pitaBread
    case pizza
    case plum
    case pomegranate
    case popcorn
    case poppySeed
    case pork
    case portobelloMushroom
    case potRoast
    case potato
    case powderedSugar
    case provolone
    case quinoa
    case raisin
    case ranch
    case raspberry
    case ravioli
    case redPepper
    case redWine
    case relish
    case rice
    case ricotta
    case romanoCheese
    case rosemary
    case rum
    case sage
    case saladDressing
    case salami
    case salmon
    case salsa
    case salt
    case saltines
    case sardine
    case sausage
    case scallops
    case sesame
    case sesameOil
    case shallot
    case sherry
    case shrimp
    case snapper
    case soda
    case sole
    case sourCream
    case soyMilk
    case soySauce
    case sparklingWater
    case spinach
    case squash
    case steakSauce
    case strawberry
    case sugar
    case sunDriedTomato
    case sunflowerButter
    case sunflowerSeeds
    case sweetPotato
    case swiss
    case swordfish
    case syrup
    case taterTots
    case tartarSauce
    case tea
    case teriyakiSauce
    case thyme
    case tilapia
    case tofu
    case tomato
    case tomatoPaste
    case tomatoSauce
    case tortellini
    case tortilla
    case trout
    case tuna
    case turkey
    case turkeyJerky
    case turmeric
    case vanilla
    case vegetableOil
    case venison
    case vinegar
    case vodka
    case walnuts
    case water
    case watermelon
    case whippedCream
    case whiskey
    case whiteWine
    case worcestershireSauce
    case yeast
    case yogurt
    case zucchini
    case other
    
    var description: String {
        switch self {
        case .alfredoSauce:
            return "Alfredo Sauce"
        case .almond:
            return "Almonds"
        case .almondButter:
            return "Almond butter"
        case .almondMilk:
            return "Almond milk"
        case .anchovy:
            return "Anchovies"
        case .apple:
            return "Apples"
        case .appleButter:
            return "Apple butter"
        case .appleCiderVinegar:
            return "Apple cider vinegar"
        case .appleJuice:
            return "Apple juice"
        case .appleSauce:
            return "Applesauce"
        case .apricot:
            return "Apricots"
        case .arborioRice:
            return "Arborio rice"
        case .artichoke:
            return "Artichokes"
        case .artichokeHeart:
            return "Artichoke Hearts"
        case .asiagoCheese:
            return "Asiago cheese"
        case .asparagus:
            return "Asparagus"
        case .avocado:
            return "Avocados"
        case .avocadoOil:
            return "Acocado oil"
        case .babySpinach:
            return "Baby spinach"
        case .bacon:
            return "Bacon"
        case .bagel:
            return "Bagels"
        case .bakedBeans:
            return "Baked beans"
        case .bakingPowder:
            return "Baking powder"
        case .bakingSoda:
            return "Baking soda"
        case .balsamicVinegar:
            return "Balsamic vinegar"
        case .banana:
            return "Bananas"
        case .barley:
            return "Barley"
        case .basil:
            return "Basil"
        case .bayLeaf:
            return "Bay leaf"
        case .bbqSauce:
            return "Barbeque Sauce"
        case .beef:
            return "Beef"
        case .beer:
            return "Beer"
        case .bellPepper:
            return "Bell pepper"
        case .blackBeans:
            return "Black beans"
        case .blackberry:
            return "Blackberries"
        case .blackOlive:
            return "Black olives"
        case .blackPepper:
            return "Black pepper"
        case .bleuCheese:
            return "Blue cheese"
        case .blueberries:
            return "Blueberries"
        case .bread:
            return "Bread"
        case .breadCrumbs:
            return "Bread crumbs"
        case .breadFlour:
            return "Bread flour"
        case .breakfastSausage:
            return "Breakfast sausage"
        case .broccoli:
            return "Broccoli"
        case .broth:
            return "Broth"
        case .brownSugar:
            return "Brown sugar"
        case .brusselsSprouts:
            return "Brussels sprouts"
        case .butter:
            return "Butter"
        case .buttermilk:
            return "Buttermilk"
        case .cabbage:
            return "Cabbage"
        case .cannedTomato:
            return "Canned tomato"
        case .cannelliniBeans:
            return "Cannellini beans"
        case .canolaOil:
            return "Canola oil"
        case .capers:
            return "Capers"
        case .carrot:
            return "Carrots"
        case .catfish:
            return "Catfish"
        case .cashew:
            return "Cashews"
        case .cashewButter:
            return "Cashew butter"
        case .cauliflower:
            return "Cauliflower"
        case .cayenne:
            return "Cayenne"
        case .celery:
            return "Celery"
        case .cereal:
            return "Cereal"
        case .champagne:
            return "Champagne"
        case .cheddar:
            return "Cheddar cheese"
        case .cheese:
            return "Cheese"
        case .cherries:
            return "Cherries"
        case .chicken:
            return "Chicken"
        case .chili:
            return "Chili"
        case .chiliPowder:
            return "Chili powder"
        case .chips:
            return "Chips"
        case .chives:
            return "Chives"
        case .chocolate:
            return "Chocolate"
        case .cilantro:
            return "Cilantro"
        case .cinnamon:
            return "Cinnamon"
        case .clam:
            return "Clam"
        case .coconutMilk:
            return "Coconut milk"
        case .cod:
            return "Cod"
        case .coffee:
            return "Coffee"
        case .corn:
            return "Corn"
        case .cornstarch:
            return "Cornstarch"
        case .cottageCheese:
            return "Cottage cheese"
        case .crab:
            return "Crab"
        case .cracker:
            return "Cracker"
        case .cranberry:
            return "Cranberry"
        case .cranberrySauce:
            return "Cranberry sauce"
        case .cream:
            return "Cream"
        case .creamOfChickenSoup:
            return "Cream of chicken soup"
        case .creamOfMushroomSoup:
            return "Cream of mushroom soup"
        case .cucumber:
            return "Cucumber"
        case .cumin:
            return "Cumin"
        case .curryPowder:
            return "Curry powder"
        case .dip:
            return "Dip"
        case .dijonMustard:
            return "Dijon mustard"
        case .dillWeed:
            return "Dill weed"
        case .driedBasil:
            return "Dried basil"
        case .driedParsley:
            return "Dried parsley"
        case .duck:
            return "Duck"
        case .egg:
            return "Egg"
        case .eggNoodles:
            return "Egg noodles"
        case .eggplant:
            return "Eggplant"
        case .favaBeans:
            return "Fava beans"
        case .fennelSeeds:
            return "Fennel seeds"
        case .feta:
            return "Feta"
        case .flounder:
            return "Flounder"
        case .flour:
            return "Flour"
        case .garlic:
            return "Garlic"
        case .garlicPowder:
            return "Garlic powder"
        case .gin:
            return "Gin"
        case .ginger:
            return "Ginger"
        case .gingerRoot:
            return "Ginger root"
        case .goatCheese:
            return "Goat cheese"
        case .granola:
            return "Granola"
        case .granolaBars:
            return "Granola bars"
        case .grapefruit:
            return "Grapefruit"
        case .grape:
            return "Grapes"
        case .greekYogurt:
            return "Greek yogurt"
        case .greenBeans:
            return "Green beans"
        case .greenOlive:
            return "Green olives"
        case .greenOnion:
            return "Green onions"
        case .groundBeef:
            return "Ground beef"
        case .groundTurkey:
            return "Ground turkey"
        case .gruyere:
            return "Gruyere"
        case .guava:
            return "Guava"
        case .haddock:
            return "Haddock"
        case .halfAndHalf:
            return "Half & half"
        case .halibut:
            return "Halibut"
        case .ham:
            return "Ham"
        case .heavyCream:
            return "Heavy cream"
        case .honey:
            return "Honey"
        case .hotDogs:
            return "Hot dogs"
        case .hotSauce:
            return "Hot sauce"
        case .hummus:
            return "Hummus"
        case .iceCream:
            return "Ice cream"
        case .icing:
            return "Icing"
        case .italianSeasoning:
            return "Italian seasoning"
        case .jalapeno:
            return "Jalapeño"
        case .jelly:
            return "Jelly"
        case .juice:
            return "Juice"
        case .kale:
            return "Kale"
        case .ketchup:
            return "Ketchup"
        case .kidneyBeans:
            return "Kidney beans"
        case .kiwi:
            return "Kiwi"
        case .lamb:
            return "Lamb"
        case .lasagnaNoodles:
            return "Lasagna noodles"
        case .lemon:
            return "Lemon"
        case .lemonJuice:
            return "Lemon juice"
        case .lentil:
            return "Lentils"
        case .lettuce:
            return "Lettuce"
        case .limaBeans:
            return "Lima beans"
        case .lime:
            return "Limes"
        case .limeJuice:
            return "Lime juice"
        case .lobster:
            return "Lobster"
        case .macAndCheese:
            return "Mac and cheese"
        case .mahiMahi:
            return "Mahi mahi"
        case .mango:
            return "Mangos"
        case .margarine:
            return "Margarine"
        case .marinara:
            return "Marinara"
        case .melon:
            return "Melon"
        case .mayonnaise:
            return "Mayonnaise"
        case .milk:
            return "Milk"
        case .mozzarella:
            return "Mozzarella"
        case .mushroom:
            return "Mushroom"
        case .mussels:
            return "Mussels"
        case .mustard:
            return "Mustard"
        case .nectarine:
            return "Nectarine"
        case .nutmeg:
            return "Nutmeg"
        case .oatmeal:
            return "Oatmeal"
        case .oats:
            return "Oats"
        case .oil:
            return "Oil"
        case .oliveOil:
            return "Olive oil"
        case .onion:
            return "Onions"
        case .onionPowder:
            return "Onion powder"
        case .orange:
            return "Orange"
        case .oregano:
            return "Oregano"
        case .oyster:
            return "Oysters"
        case .oysterSauce:
            return "Oyster sauce"
        case .paprika:
            return "Paprika"
        case .parmesan:
            return "Parmesan"
        case .parsley:
            return "Parsley"
        case .pasta:
            return "Pasta"
        case .peach:
            return "Peaches"
        case .peanutButter:
            return "Peanut butter"
        case .peanut:
            return "Peanuts"
        case .peanutOil:
            return "Peanut oil"
        case .pear:
            return "Pears"
        case .peas:
            return "Peas"
        case .pecan:
            return "Pecans"
        case .pepper:
            return "Pepper"
        case .pestoSauce:
            return "Pesto sauce"
        case .pickle:
            return "Pickle"
        case .pineapple:
            return "Pineapple"
        case .pintoBeans:
            return "Pinto beans"
        case .pitaBread:
            return "Pita bread"
        case .pizza:
            return "Pizza"
        case .plum:
            return "Plums"
        case .pomegranate:
            return "Pomegranate"
        case .popcorn:
            return "Popcorn"
        case .poppySeed:
            return "Poppy seeds"
        case .pork:
            return "Pork"
        case .portobelloMushroom:
            return "Portobello mushrooms"
        case .potRoast:
            return "Pot roast"
        case .potato:
            return "Potato"
        case .provolone:
            return "Provolone"
        case .quinoa:
            return "Quinoa"
        case .raisin:
            return "Raisins"
        case .ranch:
            return "Ranch"
        case .raspberry:
            return "Raspberry"
        case .ravioli:
            return "Ravioli"
        case .redPepper:
            return "Red pepper"
        case .redWine:
            return "Red wine"
        case .relish:
            return "Relish"
        case .rice:
            return "Rice"
        case .ricotta:
            return "Ricotta"
        case .romanoCheese:
            return "Romano cheese"
        case .rosemary:
            return "Rosemary"
        case .rum:
            return "Rum"
        case .sage:
            return "Sage"
        case .saladDressing:
            return "Salad dressing"
        case .salami:
            return "Salami"
        case .salmon:
            return "Salmon"
        case .salsa:
            return "Salsa"
        case .salt:
            return "Salt"
        case .sardine:
            return "Sardines"
        case .sausage:
            return "Sausage"
        case .scallops:
            return "Scallops"
        case .sesame:
            return "Sesame"
        case .sesameOil:
            return "Sesame oil"
        case .shallot:
            return "Shallots"
        case .sherry:
            return "Sherry"
        case .shrimp:
            return "Shrimp"
        case .snapper:
            return "Snapper"
        case .soda:
            return "Soda"
        case .sole:
            return "Sole"
        case .sourCream:
            return "Sour cream"
        case .soyMilk:
            return "Soy milk"
        case .soySauce:
            return "Soy sauce"
        case .spinach:
            return "Spinach"
        case .squash:
            return "Squash"
        case .steakSauce:
            return "Steak sauce"
        case .strawberry:
            return "Strawberries"
        case .sugar:
            return "Sugar"
        case .sunDriedTomato:
            return "Sun dried tomatoes"
        case .sunflowerButter:
            return "Sunflower butter"
        case .sunflowerSeeds:
            return "Sunflower seeds"
        case .sweetPotato:
            return "Sweet potato"
        case .swiss:
            return "Swiss"
        case .swordfish:
            return "Swordfish"
        case .syrup:
            return "Syrup"
        case .taterTots:
            return "Tater tots"
        case .tea:
            return "Tea"
        case .thyme:
            return "Thyme"
        case .tilapia:
            return "Tilapia"
        case .tofu:
            return "Tofu"
        case .tomato:
            return "Tomatoes"
        case .tomatoPaste:
            return "Tomato paste"
        case .tomatoSauce:
            return "Tomato sauce"
        case .tortellini:
            return "Tortellini"
        case .tortilla:
            return "Tortilla"
        case .trout:
            return "Trout"
        case .tuna:
            return "Tuna"
        case .turkey:
            return "Turkey"
        case .turmeric:
            return "Turmeric"
        case .vanilla:
            return "Vanilla"
        case .vegetableOil:
            return "Vegetable oil"
        case .venison:
            return "Venison"
        case .vinegar:
            return "Vinegar"
        case .vodka:
            return "Vodka"
        case .walnuts:
            return "Walnuts"
        case .water:
            return "Water"
        case .watermelon:
            return "Watermelon"
        case .whippedCream:
            return "Whipped cream"
        case .whiskey:
            return "Whiskey"
        case .whiteWine:
            return "White wine"
        case .worcestershireSauce:
            return "Worcestershire Sauce"
        case .yeast:
            return "Yeast"
        case .yogurt:
            return "Yogurt"
        case .zucchini:
            return "Zucchini"
        case .other:
            return "Other"
        case .hotDogBuns:
            return "Hot dog buns"
        case .hamburgerPatties:
            return "Hamburger patties"
        case .hamburgerBuns:
            return "Hamburger buns"
        case .creamCheese:
            return "Cream cheese"
        case .americanCheese:
            return "American cheese"
        case .pastrami:
            return "Pastrami"
        case .pepperoni:
            return "Pepperoni"
        case .tartarSauce:
            return "Tartar sauce"
        case .teriyakiSauce:
            return "Teriyaki sauce"
        case .bison:
            return "Bison"
        case .cornedBeef:
            return "Corned beef"
        case .montereyJackCheese:
            return "Monterey jack cheese"
        case .almondExtract:
            return "Almond extract"
        case .cornmeal:
            return "Cornmeal"
        case .powderedSugar:
            return "Powdered sugar"
        case .beefJerky:
            return "Beef jerky"
        case .turkeyJerky:
            return "Turkey jerky"
        case .grahamCracker:
            return "Graham crackers"
        case .oreoCookies:
            return "Oreo cookies"
        case .saltines:
            return "Saltines"
        case .sparklingWater:
            return "Sparkling water"
        case .driedMango:
            return "Dried mango"
        case .nutella:
            return "Nutella"
        case .chickenWings:
            return "Chicken wings"
        case .cornbread:
            return "Cornbread"
        case .garlicBread:
            return "Garlic bread"
        case .cantaloupe:
            return "Cantaloupe"
        case .honeydew:
            return "Honeydew"
        case .cookingWine:
            return "Cooking wine"
        }
    }
    
    static let all = GenericItem.allCases.map({$0.description})
    
    #warning("could think about having this stored somewhere, and have the user the option to persist changes i.e. if they always want oranges to be in fridge and not pantry, or if they want specific expiration dates for items")
    
    static func getStorageType(item: GenericItem, words: [String]) -> FoodStorageType {
        if words.contains("canned") {
            return .pantry
        } else if words.contains("frozen") {
            return .freezer
        } else {
            switch item {
            case .alfredoSauce:
                return .fridge
            case .almond:
                return .pantry
            case .almondButter:
                return .pantry
            case .almondExtract:
                return .pantry
            case .almondMilk:
                return .fridge
            case .americanCheese:
                return .fridge
            case .anchovy:
                return .pantry
            case .apple:
                return .pantry
            case .appleButter:
                return .pantry
            case .appleCiderVinegar:
                return .pantry
            case .appleJuice:
                return .fridge
            case .appleSauce:
                return .fridge
            case .apricot:
                return .pantry
            case .arborioRice:
                return .pantry
            case .artichoke:
                return .fridge
            case .artichokeHeart:
                return .fridge
            case .asiagoCheese:
                return .fridge
            case .asparagus:
                return .fridge
            case .avocado:
                return .pantry
            case .avocadoOil:
                return .pantry
            case .babySpinach:
                return .fridge
            case .bacon:
                return .fridge
            case .bagel:
                return .pantry
            case .bakedBeans:
                return .pantry
            case .bakingPowder:
                return .pantry
            case .bakingSoda:
                return .pantry
            case .balsamicVinegar:
                return .pantry
            case .banana:
                return .pantry
            case .barley:
                return .pantry
            case .basil:
                return .pantry
            case .bayLeaf:
                return .pantry
            case .bbqSauce:
                return .fridge
            case .beef:
                return .fridge
            case .beer:
                return .fridge
            case .bellPepper:
                return .fridge
            case .bison:
                return .fridge
            case .blackBeans:
                return .pantry
            case .blackberry:
                return .fridge
            case .blackOlive:
                return .pantry
            case .blackPepper:
                return .pantry
            case .bleuCheese:
                return .fridge
            case .blueberries:
                return .fridge
            case .bread:
                return .pantry
            case .breadCrumbs:
                return .pantry
            case .breadFlour:
                return .pantry
            case .breakfastSausage:
                return .fridge
            case .broccoli:
                return .fridge
            case .broth:
                return .pantry
            case .brownSugar:
                return .pantry
            case .brusselsSprouts:
                return .fridge
            case .butter:
                return .fridge
            case .buttermilk:
                return .fridge
            case .cabbage:
                return .fridge
            case .cannedTomato:
                return .pantry
            case .cannelliniBeans:
                return .pantry
            case .canolaOil:
                return .pantry
            case .capers:
                return .fridge
            case .carrot:
                return .fridge
            case .catfish:
                return .fridge
            case .cashew:
                return .pantry
            case .cashewButter:
                return .pantry
            case .cauliflower:
                return .fridge
            case .cayenne:
                return .pantry
            case .celery:
                return .fridge
            case .cereal:
                return .pantry
            case .champagne:
                return .fridge
            case .cheddar:
                return .fridge
            case .cheese:
                return .fridge
            case .cherries:
                return .fridge
            case .chicken:
                return .fridge
            case .chili:
                return .pantry
            case .chiliPowder:
                return .pantry
            case .chips:
                return .pantry
            case .chives:
                return .fridge
            case .chocolate:
                return .pantry
            case .cilantro:
                return .fridge
            case .cinnamon:
                return .pantry
            case .clam:
                return .fridge
            case .coconutMilk:
                return .pantry
            case .cod:
                return .fridge
            case .coffee:
                return .pantry
            case .corn:
                return .fridge
            case .cornedBeef:
                return .fridge
            case .cornmeal:
                return .pantry
            case .cornstarch:
                return .pantry
            case .cottageCheese:
                return .fridge
            case .crab:
                return .fridge
            case .cracker:
                return .pantry
            case .cranberry:
                return .fridge
            case .cranberrySauce:
                return .pantry
            case .cream:
                return .fridge
            case .creamCheese:
                return .fridge
            case .creamOfChickenSoup:
                return .pantry
            case .creamOfMushroomSoup:
                return .pantry
            case .cucumber:
                return .pantry
            case .cumin:
                return .pantry
            case .curryPowder:
                return .pantry
            case .dip:
                return .fridge
            case .dijonMustard:
                return .fridge
            case .dillWeed:
                return .pantry
            case .driedBasil:
                return .pantry
            case .driedParsley:
                return .pantry
            case .duck:
                return .fridge
            case .egg:
                return .fridge
            case .eggNoodles:
                return .pantry
            case .eggplant:
                return .pantry
            case .favaBeans:
                return .pantry
            case .fennelSeeds:
                return .pantry
            case .feta:
                return .fridge
            case .flounder:
                return .fridge
            case .flour:
                return .pantry
            case .garlic:
                return .pantry
            case .garlicPowder:
                return .pantry
            case .gin:
                return .pantry
            case .ginger:
                return .pantry
            case .gingerRoot:
                return .pantry
            case .goatCheese:
                return .fridge
            case .granola:
                return .pantry
            case .granolaBars:
                return .pantry
            case .grapefruit:
                return .pantry
            case .grape:
                return .pantry
            case .greekYogurt:
                return .fridge
            case .greenBeans:
                return .fridge
            case .greenOlive:
                return .pantry
            case .greenOnion:
                return .pantry
            case .groundBeef:
                return .fridge
            case .groundTurkey:
                return .fridge
            case .gruyere:
                return .fridge
            case .guava:
                return .pantry
            case .haddock:
                return .fridge
            case .halfAndHalf:
                return .fridge
            case .halibut:
                return .fridge
            case .ham:
                return .fridge
            case .hamburgerBuns:
                return .pantry
            case .hamburgerPatties:
                return .fridge
            case .heavyCream:
                return .fridge
            case .honey:
                return .pantry
            case .hotDogs:
                return .fridge
            case .hotDogBuns:
                return .pantry
            case .hotSauce:
                return .fridge
            case .hummus:
                return .fridge
            case .iceCream:
                return .freezer
            case .icing:
                return .fridge
            case .italianSeasoning:
                return .pantry
            case .jalapeno:
                return .fridge
            case .jelly:
                return .pantry
            case .juice:
                return .fridge
            case .kale:
                return .fridge
            case .ketchup:
                return .fridge
            case .kidneyBeans:
                return .pantry
            case .kiwi:
                return .fridge
            case .lamb:
                return .fridge
            case .lasagnaNoodles:
                return .pantry
            case .lemon:
                return .pantry
            case .lemonJuice:
                return .pantry
            case .lentil:
                return .pantry
            case .lettuce:
                return .fridge
            case .limaBeans:
                return .pantry
            case .lime:
                return .pantry
            case .limeJuice:
                return .pantry
            case .lobster:
                return .fridge
            case .macAndCheese:
                return .pantry
            case .mahiMahi:
                return .fridge
            case .mango:
                return .pantry
            case .margarine:
                return .fridge
            case .marinara:
                return .fridge
            case .melon:
                return .pantry
            case .mayonnaise:
                return .fridge
            case .milk:
                return .fridge
            case .montereyJackCheese:
                return .fridge
            case .mozzarella:
                return .fridge
            case .mushroom:
                return .fridge
            case .mussels:
                return .fridge
            case .mustard:
                return .fridge
            case .nectarine:
                return .pantry
            case .nutmeg:
                return .pantry
            case .oatmeal:
                return .pantry
            case .oats:
                return .pantry
            case .oil:
                return .pantry
            case .oliveOil:
                return .pantry
            case .onion:
                return .pantry
            case .onionPowder:
                return .pantry
            case .orange:
                return .pantry
            case .oregano:
                return .pantry
            case .oyster:
                return .fridge
            case .oysterSauce:
                return .fridge
            case .paprika:
                return .pantry
            case .parmesan:
                return .fridge
            case .parsley:
                return .pantry
            case .pasta:
                return .pantry
            case .pastrami:
                return .fridge
            case .peach:
                return .pantry
            case .peanutButter:
                return .pantry
            case .peanut:
                return .pantry
            case .peanutOil:
                return .pantry
            case .pear:
                return .pantry
            case .peas:
                return .fridge
            case .pecan:
                return .pantry
            case .pepper:
                return .pantry
            case .pepperoni:
                return .fridge
            case .pestoSauce:
                return .fridge
            case .pickle:
                return .fridge
            case .pineapple:
                return .pantry
            case .pintoBeans:
                return .pantry
            case .pitaBread:
                return .pantry
            case .pizza:
                return .freezer
            case .plum:
                return .pantry
            case .pomegranate:
                return .fridge
            case .popcorn:
                return .pantry
            case .poppySeed:
                return .pantry
            case .pork:
                return .fridge
            case .portobelloMushroom:
                return .fridge
            case .potRoast:
                return .fridge
            case .potato:
                return .pantry
            case .powderedSugar:
                return .pantry
            case .provolone:
                return .fridge
            case .quinoa:
                return .pantry
            case .raisin:
                return .pantry
            case .ranch:
                return .fridge
            case .raspberry:
                return .fridge
            case .ravioli:
                return .fridge
            case .redPepper:
                return .pantry
            case .redWine:
                return .pantry
            case .relish:
                return .fridge
            case .rice:
                return .pantry
            case .ricotta:
                return .fridge
            case .romanoCheese:
                return .fridge
            case .rosemary:
                return .pantry
            case .rum:
                return .fridge
            case .sage:
                return .pantry
            case .saladDressing:
                return .fridge
            case .salami:
                return .fridge
            case .salmon:
                return .fridge
            case .salsa:
                return .fridge
            case .salt:
                return .pantry
            case .sardine:
                return .pantry
            case .sausage:
                return .fridge
            case .scallops:
                return .fridge
            case .sesame:
                return .pantry
            case .sesameOil:
                return .pantry
            case .shallot:
                return .pantry
            case .sherry:
                return .fridge
            case .shrimp:
                return .fridge
            case .snapper:
                return .fridge
            case .soda:
                return .pantry
            case .sole:
                return .fridge
            case .sourCream:
                return .fridge
            case .soyMilk:
                return .fridge
            case .soySauce:
                return .pantry
            case .spinach:
                return .fridge
            case .squash:
                return .pantry
            case .steakSauce:
                return .fridge
            case .strawberry:
                return .fridge
            case .sugar:
                return .pantry
            case .sunDriedTomato:
                return .fridge
            case .sunflowerButter:
                return .pantry
            case .sunflowerSeeds:
                return .pantry
            case .sweetPotato:
                return .pantry
            case .swiss:
                return .fridge
            case .swordfish:
                return .fridge
            case .syrup:
                return .fridge
            case .taterTots:
                return .freezer
            case .tartarSauce:
                return .fridge
            case .tea:
                return .pantry
            case .teriyakiSauce:
                return .fridge
            case .thyme:
                return .pantry
            case .tilapia:
                return .fridge
            case .tofu:
                return .fridge
            case .tomato:
                return .fridge
            case .tomatoPaste:
                return .pantry
            case .tomatoSauce:
                return .fridge
            case .tortellini:
                return .fridge
            case .tortilla:
                return .pantry
            case .trout:
                return .fridge
            case .tuna:
                return .pantry
            case .turkey:
                return .fridge
            case .turmeric:
                return .pantry
            case .vanilla:
                return .pantry
            case .vegetableOil:
                return .pantry
            case .venison:
                return .fridge
            case .vinegar:
                return .pantry
            case .vodka:
                return .fridge
            case .walnuts:
                return .pantry
            case .water:
                return .pantry
            case .watermelon:
                return .pantry
            case .whippedCream:
                return .fridge
            case .whiskey:
                return .fridge
            case .whiteWine:
                return .fridge
            case .worcestershireSauce:
                return .fridge
            case .yeast:
                return .pantry
            case .yogurt:
                return .fridge
            case .zucchini:
                return .pantry
            case .other:
                return .unsorted
            case .beefJerky:
                return .pantry
            case .turkeyJerky:
                return .pantry
            case .grahamCracker:
                return .pantry
            case .oreoCookies:
                return .pantry
            case .saltines:
                return .pantry
            case .sparklingWater:
                return .pantry
            case .driedMango:
                return .pantry
            case .nutella:
                return .pantry
            case .chickenWings:
                return .fridge
            case .cornbread:
                return .pantry
            case .garlicBread:
                return .pantry
            case .cantaloupe:
                return .pantry
            case .honeydew:
                return .pantry
            case .cookingWine:
                return .pantry
            }
        }
        
    }
    
    static func getCategory(item: GenericItem, words: [String]) -> Category {
        if words.contains("frozen") {
            return .frozenFoods
        } else if words.contains("canned") {
            return .canned
        } else {
            switch item {
            case .alfredoSauce:
                return .grainsPastaSides
            case .almond:
                return .snacks
            case .almondButter:
                return .condimentsAndDressings
            case .anchovy:
                return .canned
            case .apple:
                return .produce
            case .appleButter:
                return .condimentsAndDressings
            case .appleCiderVinegar:
                return .condimentsAndDressings
            case .appleJuice:
                return .beverages
            case .appleSauce:
                return .snacks
            case .apricot:
                return .produce
            case .arborioRice:
                return .grainsPastaSides
            case .artichoke:
                return .produce
            case .artichokeHeart:
                return .canned
            case .asiagoCheese:
                return .dairy
            case .asparagus:
                return .produce
            case .avocado:
                return .produce
            case .avocadoOil:
                return .condimentsAndDressings
            case .babySpinach:
                return .produce
            case .bacon:
                return .meat
            case .bagel:
                return .bakery
            case .bakedBeans:
                return .canned
            case .bakingPowder:
                return .cookingBakingSpices
            case .bakingSoda:
                return .cookingBakingSpices
            case .balsamicVinegar:
                return .condimentsAndDressings
            case .banana:
                return .produce
            case .barley:
                return .grainsPastaSides
            case .basil:
                return .produce
            case .bayLeaf:
                return .cookingBakingSpices
            case .bbqSauce:
                return .condimentsAndDressings
            case .beef:
                return .meat
            case .beer:
                return .beverages
            case .bellPepper:
                return .produce
            case .blackBeans:
                return .canned
            case .blackberry:
                return .produce
            case .blackOlive:
                return .canned
            case .blackPepper:
                return .cookingBakingSpices
            case .bleuCheese:
                return .dairy
            case .blueberries:
                return .produce
            case .bread:
                return .bakery
            case .breadCrumbs:
                return .cookingBakingSpices
            case .breakfastSausage:
                return .breakfast
            case .broccoli:
                return .produce
            case .broth:
                return .cookingBakingSpices
            case .brownSugar:
                return .cookingBakingSpices
            case .brusselsSprouts:
                return .produce
            case .butter:
                return .dairy
            case .cabbage:
                return .produce
            case .cannedTomato:
                return .canned
            case .cannelliniBeans:
                return .canned
            case .canolaOil:
                return .cookingBakingSpices
            case .capers:
                return .condimentsAndDressings
            case .carrot:
                return .produce
            case .catfish:
                return .seafood
            case .cashew:
                return .snacks
            case .cashewButter:
                return .condimentsAndDressings
            case .cauliflower:
                if words.contains("frozen") {
                    return .frozenFoods
                } else {
                    return .produce
                }
            case .cayenne:
                return .cookingBakingSpices
            case .celery:
                return .produce
            case .cereal:
                return .breakfast
            case .champagne:
                return .beverages
            case .cheddar:
                return .dairy
            case .cheese:
                return .dairy
            case .cherries:
                return .produce
            case .chicken:
                return .meat
            case .chili:
                return .cookingBakingSpices
            case .chiliPowder:
                return .cookingBakingSpices
            case .chips:
                return .snacks
            case .chives:
                return .produce
            case .chocolate:
                return .snacks
            case .cilantro:
                return .cookingBakingSpices
            case .cinnamon:
                return .cookingBakingSpices
            case .clam:
                return .seafood
            case .coconutMilk:
                return .canned
            case .cod:
                return .seafood
            case .coffee:
                return .beverages
            case .corn:
                if words.contains("canned") || words.contains("can") {
                    return .canned
                } else {
                    return .produce
                }
            case .cornstarch:
                return .cookingBakingSpices
            case .cottageCheese:
                return .dairy
            case .crab:
                return .seafood
            case .cracker:
                return .snacks
            case .cranberry:
                return .produce
            case .cranberrySauce:
                return .condimentsAndDressings
            case .cream:
                return .dairy
            case .creamOfChickenSoup:
                return .canned
            case .creamOfMushroomSoup:
                return .canned
            case .cucumber:
                return .produce
            case .cumin:
                return .cookingBakingSpices
            case .curryPowder:
                return .cookingBakingSpices
            case .dip:
                return .condimentsAndDressings
            case .dijonMustard:
                return .condimentsAndDressings
            case .dillWeed:
                return .cookingBakingSpices
            case .driedBasil:
                return .cookingBakingSpices
            case .driedParsley:
                return .cookingBakingSpices
            case .duck:
                return .meat
            case .egg:
                return .dairy
            case .eggNoodles:
                return .grainsPastaSides
            case .eggplant:
                return .produce
            case .favaBeans:
                return .canned
            case .fennelSeeds:
                return .cookingBakingSpices
            case .feta:
                return .dairy
            case .flounder:
                return .seafood
            case .flour:
                return .cookingBakingSpices
            case .garlic:
                return .cookingBakingSpices
            case .garlicPowder:
                return .cookingBakingSpices
            case .gin:
                return .beverages
            case .ginger:
                return .cookingBakingSpices
            case .gingerRoot:
                return .cookingBakingSpices
            case .goatCheese:
                return .dairy
            case .granola:
                return .snacks
            case .granolaBars:
                return .snacks
            case .grapefruit:
                return .produce
            case .grape:
                return .produce
            case .greekYogurt:
                return .dairy
            case .greenBeans:
                if words.contains("can") || words.contains("canned") {
                    return .canned
                } else {
                    return .produce
                }
            case .greenOlive:
                return .canned
            case .greenOnion:
                return .produce
            case .groundBeef:
                return .meat
            case .groundTurkey:
                return .meat
            case .gruyere:
                return .dairy
            case .guava:
                return .produce
            case .haddock:
                return .seafood
            case .halfAndHalf:
                return .dairy
            case .halibut:
                return .seafood
            case .ham:
                return .deli
            case .heavyCream:
                return .dairy
            case .honey:
                return .condimentsAndDressings
            case .hotDogs:
                return .meat
            case .hotSauce:
                return .condimentsAndDressings
            case .hummus:
                return .condimentsAndDressings
            case .iceCream:
                return .frozenFoods
            case .icing:
                return .bakery
            case .italianSeasoning:
                return .cookingBakingSpices
            case .jalapeno:
                return .produce
            case .jelly:
                return .condimentsAndDressings
            case .juice:
                return .beverages
            case .kale:
                return .produce
            case .ketchup:
                return .condimentsAndDressings
            case .kidneyBeans:
                return .canned
            case .kiwi:
                return .produce
            case .lamb:
                return .meat
            case .lasagnaNoodles:
                return .grainsPastaSides
            case .lemon:
                return .produce
            case .lemonJuice:
                return .cookingBakingSpices
            case .lentil:
                return .grainsPastaSides
            case .lettuce:
                return .produce
            case .limaBeans:
                return .canned
            case .lime:
                return .produce
            case .limeJuice:
                return .cookingBakingSpices
            case .lobster:
                return .seafood
            case .macAndCheese:
                return .grainsPastaSides
            case .mahiMahi:
                return .seafood
            case .mango:
                return .produce
            case .margarine:
                return .cookingBakingSpices
            case .marinara:
                return .condimentsAndDressings
            case .melon:
                return .produce
            case .mayonnaise:
                return .condimentsAndDressings
            case .milk:
                return .dairy
            case .mozzarella:
                return .dairy
            case .mushroom:
                return .produce
            case .mussels:
                return .seafood
            case .mustard:
                return .condimentsAndDressings
            case .nectarine:
                return .produce
            case .nutmeg:
                return .cookingBakingSpices
            case .oatmeal:
                return .breakfast
            case .oats:
                return .grainsPastaSides
            case .oil:
                return .cookingBakingSpices
            case .oliveOil:
                return .cookingBakingSpices
            case .onion:
                return .produce
            case .onionPowder:
                return .cookingBakingSpices
            case .orange:
                return .produce
            case .oregano:
                return .cookingBakingSpices
            case .oyster:
                return .seafood
            case .oysterSauce:
                return .condimentsAndDressings
            case .paprika:
                return .cookingBakingSpices
            case .parmesan:
                return .dairy
            case .parsley:
                return .cookingBakingSpices
            case .pasta:
                return .grainsPastaSides
            case .peach:
                return .produce
            case .peanutButter:
                return .condimentsAndDressings
            case .peanut:
                return .snacks
            case .peanutOil:
                return .cookingBakingSpices
            case .pear:
                return .produce
            case .peas:
                if words.contains("frozen") {
                    return .frozenFoods
                } else if words.contains("can") || words.contains("canned") {
                    return .canned
                } else {
                    return .produce
                }
            case .pecan:
                return .snacks
            case .pepper:
                return .cookingBakingSpices
            case .pestoSauce:
                return .condimentsAndDressings
            case .pickle:
                return .condimentsAndDressings
            case .pineapple:
                if words.contains("can") || words.contains("canned") {
                    return .canned
                } else {
                    return .produce
                }
            case .pintoBeans:
                return .canned
            case .pitaBread:
                return .bakery
            case .pizza:
                return .frozenFoods
            case .plum:
                return .produce
            case .pomegranate:
                return .produce
            case .popcorn:
                return .snacks
            case .poppySeed:
                return .cookingBakingSpices
            case .pork:
                return .meat
            case .portobelloMushroom:
                return .produce
            case .potRoast:
                return .meat
            case .potato:
                return .produce
            case .provolone:
                return .dairy
            case .quinoa:
                return .grainsPastaSides
            case .raisin:
                return .snacks
            case .raspberry:
                return .produce
            case .ravioli:
                return .grainsPastaSides
            case .redPepper:
                return .cookingBakingSpices
            case .redWine:
                return .beverages
            case .relish:
                return .condimentsAndDressings
            case .rice:
                return .grainsPastaSides
            case .ricotta:
                return .dairy
            case .romanoCheese:
                return .dairy
            case .rosemary:
                return .cookingBakingSpices
            case .rum:
                return .beverages
            case .sage:
                return .cookingBakingSpices
            case .salami:
                return .deli
            case .salmon:
                return .seafood
            case .salsa:
                return .condimentsAndDressings
            case .salt:
                return .cookingBakingSpices
            case .sardine:
                return .canned
            case .sausage:
                return .meat
            case .scallops:
                return .seafood
            case .sesame:
                return .cookingBakingSpices
            case .sesameOil:
                return .cookingBakingSpices
            case .shallot:
                return .produce
            case .sherry:
                return .beverages
            case .shrimp:
                return .seafood
            case .snapper:
                return .seafood
            case .soda:
                return .beverages
            case .sole:
                return .seafood
            case .sourCream:
                return .dairy
            case .soySauce:
                return .condimentsAndDressings
            case .spinach:
                if words.contains("frozen") {
                    return .frozenFoods
                } else {
                    return .produce
                }
            case .squash:
                return .produce
            case .steakSauce:
                return .condimentsAndDressings
            case .strawberry:
                return .produce
            case .sugar:
                return .cookingBakingSpices
            case .sunDriedTomato:
                return .produce
            case .sunflowerButter:
                return .condimentsAndDressings
            case .sunflowerSeeds:
                return .snacks
            case .sweetPotato:
                return .produce
            case .swiss:
                return .dairy
            case .swordfish:
                return .seafood
            case .syrup:
                return .condimentsAndDressings
            case .taterTots:
                return .frozenFoods
            case .tea:
                return .beverages
            case .thyme:
                return .cookingBakingSpices
            case .tilapia:
                return .seafood
            case .tofu:
                return .produce
            case .tomato:
                return .produce
            case .tomatoPaste:
                return .canned
            case .tomatoSauce:
                return .canned
            case .tortellini:
                return .grainsPastaSides
            case .tortilla:
                return .grainsPastaSides
            case .trout:
                return .seafood
            case .tuna:
                if words.contains("can") || words.contains("canned") {
                    return .canned
                } else {
                    return .seafood
                }
            case .turkey:
                return .meat
            case .turmeric:
                return .cookingBakingSpices
            case .vanilla:
                return .cookingBakingSpices
            case .vegetableOil:
                return .cookingBakingSpices
            case .venison:
                return .meat
            case .vinegar:
                return .cookingBakingSpices
            case .vodka:
                return .beverages
            case .walnuts:
                return .snacks
            case .watermelon:
                return .produce
            case .whippedCream:
                return .dairy
            case .whiskey:
                return .beverages
            case .whiteWine:
                return .beverages
            case .worcestershireSauce:
                return .condimentsAndDressings
            case .yeast:
                return .cookingBakingSpices
            case .yogurt:
                return .dairy
            case .zucchini:
                return .produce
            case .other:
                return .other
            case .water:
                return .beverages
            case .breadFlour:
                return .cookingBakingSpices
            case .buttermilk:
                return .dairy
            case .almondMilk:
                return .beverages
            case .soyMilk:
                return .beverages
            case .ranch:
                return .condimentsAndDressings
            case .saladDressing:
                return .condimentsAndDressings
            case .hotDogBuns:
                return .bakery
            case .hamburgerPatties:
                return .meat
            case .hamburgerBuns:
                return .bakery
            case .creamCheese:
                return .dairy
            case .americanCheese:
                return .dairy
            case .pastrami:
                return .deli
            case .pepperoni:
                return .deli
            case .tartarSauce:
                return .condimentsAndDressings
            case .teriyakiSauce:
                return .condimentsAndDressings
            case .bison:
                return .meat
            case .cornedBeef:
                return .deli
            case .montereyJackCheese:
                return .dairy
            case .almondExtract:
                return .cookingBakingSpices
            case .cornmeal:
                return .cookingBakingSpices
            case .powderedSugar:
                return .cookingBakingSpices
            case .beefJerky:
                return .snacks
            case .turkeyJerky:
                return .snacks
            case .grahamCracker:
                return .snacks
            case .oreoCookies:
                return .snacks
            case .saltines:
                return .snacks
            case .sparklingWater:
                return .beverages
            case .driedMango:
                return .snacks
            case .nutella:
                return .snacks
            case .chickenWings:
                return .meat
            case .cornbread:
                return .bakery
            case .garlicBread:
                return .bakery
            case .cantaloupe:
                return .produce
            case .honeydew:
                return .produce
            case .cookingWine:
                return .beverages
            }
        }
        
    }
    
    

    static func getSuggestedExpirationDate(item: GenericItem, storageType: FoodStorageType) -> Int {
        let day = 86_400
        let week = 604_800
        let month = 2_592_000
        let year = 31_536_000
        switch item {
        case .alfredoSauce:
            return week
        case .almond:
            return year + (month*3)
        case .almondButter:
            return month*3
        case .almondExtract:
            return year + (month*3)
        case .almondMilk:
            return day*10
        case .americanCheese:
            return week*3
        case .anchovy:
            if storageType == .fridge {
                return month*2
            } else {
                return year
            }
        case .apple:
            switch storageType {
            case .fridge:
                return month*2
            case .freezer:
                return month*11
            default:
                return week*2
            }
        case .appleButter:
            if storageType == .freezer {
                return month*6
            } else {
                return month
            }
        case .appleCiderVinegar:
            return year*2
        case .appleJuice:
            return month*9
        case .appleSauce:
            if storageType == .fridge {
                return week*2
            } else if storageType == .freezer {
                return month*2
            } else {
                return month
            }
        case .apricot:
            if storageType == .freezer {
                return month*11
            } else {
                return day*5
            }
        case .arborioRice:
            return year*3
        case .artichoke:
            if storageType == .freezer {
                return month*10
            } else {
                return week
            }
        case .artichokeHeart:
            if storageType == .freezer {
                return month*2
            } else {
                return day*4
            }
        case .asiagoCheese:
            if storageType == .freezer {
                return year
            } else {
                return week*6
            }
        case .asparagus:
            if storageType == .freezer {
                return month*11
            } else {
                return day*4
            }
        case .avocado:
            return day*5
        case .avocadoOil:
            return month*20
        case .babySpinach:
            if storageType == .freezer {
                return year
            } else {
                return week
            }
        case .bacon:
            if storageType == .freezer {
                return month*8
            } else {
                return week*2
            }
        case .bagel:
            if storageType == .freezer {
                return month*3
            } else {
                return day*6
            }
        case .bakedBeans:
            return year*4
        case .bakingPowder:
            return month*9
        case .bakingSoda:
            return year*2
        case .balsamicVinegar:
            return year*3
        case .banana:
            if storageType == .freezer {
                return month*3
            } else {
                return week
            }
        case .barley:
            return year
        case .basil:
            if storageType == .fridge {
                return day*4
            } else {
                return (year*2) + (month*6)
            }
        case .bayLeaf:
            return year*3
        case .bbqSauce:
            return month*9
        case .beef:
            if storageType == .freezer {
                return month*9
            } else {
                return day*6
            }
        case .beefJerky:
            return year*2
        case .beer:
            return month*9
        case .bellPepper:
            return week*2
        case .bison:
            if storageType == .freezer {
                return month*9
            } else {
                return day*6
            }
        case .blackBeans:
            return year*3
        case .blackberry:
            if storageType == .freezer {
                return month*11
            } else {
                return day*5
            }
        case .blackOlive:
            return year*2
        case .blackPepper:
            return year*4
        case .bleuCheese:
            return week*4
        case .blueberries:
            if storageType == .freezer {
                return year
            } else {
                return week*2
            }
        case .bread:
            if storageType == .freezer {
                return month*6
            } else {
                return week
            }
        case .breadCrumbs:
            if storageType == .freezer {
                return month*6
            } else {
                return week
            }
        case .breadFlour:
            return month*8
        case .breakfastSausage:
            if storageType == .freezer {
                return month*2
            } else {
                return day*5
            }
        case .broccoli:
            if storageType == .freezer {
                return month*8
            } else {
                return week*2
            }
        case .broth:
            if storageType == .freezer {
                return month*6
            } else {
                return day*5
            }
        case .brownSugar:
            return year*2
        case .brusselsSprouts:
            if storageType == .freezer {
                return month*16
            } else if storageType == .pantry {
                return day*5
            } else {
                return week*4
            }
        case .butter:
            return month*9
        case .buttermilk:
            return week*2
        case .cabbage:
            return month*2
        case .cannedTomato:
            return year*2
        case .cannelliniBeans:
            return year*2
        case .canolaOil:
            return year*2
        case .capers:
            return year*1
        case .carrot:
            if storageType == .freezer {
                return month*11
            } else {
                return week*5
            }
        case .catfish:
            if storageType == .freezer {
                return month*8
            } else {
                return day*3
            }
        case .cashew:
            return month*6
        case .cashewButter:
            return month*6
        case .cauliflower:
            if storageType == .freezer {
                return month*8
            } else {
                return week*3
            }
        case .cayenne:
            return year*3
        case .celery:
            if storageType == .freezer {
                return month*18
            } else {
                return week*2
            }
        case .cereal:
            return month*7
        case .champagne:
            return year
        case .cheddar:
            return week*6
        case .cheese:
            return week*6
        case .cherries:
            return day*5
        case .chicken:
            switch storageType {
            case .unsorted:
                return day*3
            case .fridge:
                return day*3
            case .freezer:
                return month*9
            case .pantry:
                return year*2
            }
        case .chili:
            return year*2
        case .chiliPowder:
            return year*3
        case .chips:
            return month*3
        case .chives:
            return week*2
        case .chocolate:
            return year*2
        case .cilantro:
            if storageType == .freezer {
                return month*6
            } else {
                return day*10
            }
        case .cinnamon:
            return year*3
        case .clam:
            if storageType == .freezer {
                return month*3
            } else {
                return day*3
            }
        case .coconutMilk:
            return day*10
        case .cod:
            if storageType == .freezer {
                return month*8
            } else {
                return day*3
            }
        case .coffee:
            return month*5
        case .corn:
            if storageType == .pantry {
                return year*3
            } else if storageType == .pantry {
                return year*2
            } else {
                return day*5
            }
        case .cornedBeef:
            return day*4
        case .cornmeal:
            return year
        case .cornstarch:
            return year*4
        case .cottageCheese:
            if storageType == .freezer {
                return month*3
            } else {
                return day*3
            }
        case .crab:
            if storageType == .freezer {
                return month*3
            } else {
                return day*5
            }
        case .cracker:
            return month*9
        case .cranberry:
            if storageType == .freezer {
                return month*11
            } else {
                return week*4
            }
        case .cranberrySauce:
            return month*2
        case .cream:
            return day*10
        case .creamCheese:
            return week*2
        case .creamOfChickenSoup:
            return year*4
        case .creamOfMushroomSoup:
            return year*4
        case .cucumber:
            return week*1
        case .cumin:
            return year*3
        case .curryPowder:
            return year*3
        case .dip:
            return week*2
        case .dijonMustard:
            return month*15
        case .dillWeed:
            return year*2
        case .driedBasil:
            return year*3
        case .driedMango:
            return year
        case .driedParsley:
            return year*3
        case .duck:
            if storageType == .freezer {
                return year*2
            } else {
                return week*2
            }
        case .egg:
            return week*5
        case .eggNoodles:
            return year*2
        case .eggplant:
            return day*10
        case .favaBeans:
            return year*2
        case .fennelSeeds:
            return year*3
        case .feta:
            if storageType == .freezer {
                return month*6
            } else {
                return week*6
            }
        case .flounder:
            if storageType == .freezer {
                return month*8
            } else {
                return day*3
            }
        case .flour:
            return month*8
        case .garlic:
            return month*5
        case .garlicPowder:
            return year*3
        case .gin:
            return year
        case .ginger:
            if storageType == .freezer {
                return month*3
            } else {
                return week*4
            }
        case .gingerRoot:
            return month
        case .goatCheese:
            if storageType == .freezer {
                return month*6
            } else {
                return week*2
            }
        case .grahamCracker:
            return month*9
        case .granola:
            return month*6
        case .granolaBars:
            return month*8
        case .grapefruit:
            return week*6
        case .grape:
            if storageType == .freezer {
                return month*11
            } else {
                return week*2
            }
        case .greekYogurt:
            if storageType == .freezer {
                return month*1
            } else {
                return week*3
            }
        case .greenBeans:
            if storageType == .freezer {
                return month*18
            } else {
                return day*5
            }
        case .greenOlive:
            return year*3
        case .greenOnion:
            if storageType == .freezer {
                return month*10
            } else {
                return day*10
            }
        case .groundBeef:
            if storageType == .freezer {
                return month*4
            } else {
                return day*3
            }
        case .groundTurkey:
            if storageType == .freezer {
                return month*3
            } else {
                return day*4
            }
        case .gruyere:
            return month
        case .guava:
            return week
        case .haddock:
            if storageType == .freezer {
                return month*3
            } else {
                return day*4
            }
        case .halfAndHalf:
            return week
        case .halibut:
            if storageType == .freezer {
                return month*3
            } else {
                return day*4
            }
        case .ham:
            if storageType == .freezer {
                return month*4
            } else {
                return day*4
            }
        case .hamburgerBuns:
            if storageType == .freezer {
                return month*3
            } else {
                return day*7
            }
        case .hamburgerPatties:
            if storageType == .freezer {
                return month*6
            } else {
                return week
            }
        case .heavyCream:
            return day*8
        case .honey:
            return year*5
        case .hotDogs:
            if storageType == .freezer {
                return month*2
            } else {
                return week
            }
        case .hotDogBuns:
            if storageType == .freezer {
                return month*3
            } else {
                return day*7
            }
        case .hotSauce:
            return year*3
        case .hummus:
            return week
        case .iceCream:
            return month*3
        case .icing:
            return month*15
        case .italianSeasoning:
            return year*3
        case .jalapeno:
            return week*2
        case .jelly:
            return year
        case .juice:
            return month*3
        case .kale:
            if storageType == .freezer {
                return year
            } else {
                return day*6
            }
        case .ketchup:
            return month*18
        case .kidneyBeans:
            return month
        case .kiwi:
            return week*4
        case .lamb:
            if storageType == .freezer {
                return month*9
            } else {
                return day*5
            }
        case .lasagnaNoodles:
            return year*2
        case .lemon:
            return week*3
        case .lemonJuice:
            return month*18
        case .lentil:
            return year*3
        case .lettuce:
            return day*10
        case .limaBeans:
            return year
        case .lime:
            return week*2
        case .limeJuice:
            return month*18
        case .lobster:
            if storageType == .freezer {
                return month*3
            } else {
                return day*4
            }
        case .macAndCheese:
            return year*2
        case .mahiMahi:
            if storageType == .freezer {
                return month*11
            } else {
                return day*5
            }
        case .mango:
            if storageType == .freezer {
                return year
            } else if storageType == .fridge {
                return week
            } else {
                return day*5
            }
        case .margarine:
            return month*5
        case .marinara:
            return month*10
        case .melon:
            return week*2
        case .mayonnaise:
            return year
        case .milk:
            switch storageType {
            case .unsorted:
                return day*7
            case .fridge:
                return day*7
            case .freezer:
                return month*6
            case .pantry:
                return year + (month*6)
            }
        case .montereyJackCheese:
            if storageType == .freezer {
                return month*6
            } else {
                return week*5
            }
        case .mozzarella:
            if storageType == .freezer {
                return month*5
            } else {
                return week*2
            }
        case .mushroom:
            if storageType == .freezer {
                return month*11
            } else {
                return day*6
            }
        case .mussels:
            if storageType == .freezer {
                return month*3
            } else {
                return day*2
            }
        case .mustard:
            return month*18
        case .nectarine:
            return day*5
        case .nutmeg:
            return year*4
        case .nutella:
            return month*2
        case .oatmeal:
            return month*20
        case .oats:
            return month*18
        case .oil:
            return year*2
        case .oliveOil:
            return year*2
        case .onion:
            return month*2
        case .onionPowder:
            return year*4
        case .orange:
            return week*3
        case .oregano:
            return year*1
        case .oreoCookies:
            return week*3
        case .oyster:
            if storageType == .freezer {
                return month*3
            } else {
                return day*3
            }
        case .oysterSauce:
            return month*6
        case .paprika:
            return year*2
        case .parmesan:
            return month*9
        case .parsley:
            if storageType == .freezer {
                return month*6
            } else {
                return day*10
            }
        case .pasta:
            return year*2
        case .pastrami:
            if storageType == .freezer {
                return month*2
            } else {
                return day*5
            }
        case .peach:
            return day*5
        case .peanutButter:
            return month*4
        case .peanut:
            return month*2
        case .peanutOil:
            return month*6
        case .pear:
            if storageType == .freezer {
                return year
            } else if storageType == .fridge {
                return week
            } else {
                return day*4
            }
        case .peas:
            if storageType == .freezer {
                return year*1
            } else {
                return day*5
            }
        case .pecan:
            if storageType == .freezer {
                return year*2
            } else if storageType == .fridge {
                return month*9
            } else {
                return week*2
            }
        case .pepper:
            return month*5
        case .pepperoni:
            return week*3
        case .pestoSauce:
            if storageType == .freezer {
                return year
            } else {
                return month
            }
        case .pickle:
            return month*14
        case .pineapple:
            if storageType == .freezer {
                return year
            } else if storageType == .fridge {
                return day*5
            } else {
                return day*2
            }
        case .pintoBeans:
            return year*2
        case .pitaBread:
            if storageType == .freezer {
                return month*13
            } else {
                return week
            }
        case .pizza:
            return month*18
        case .plum:
            if storageType == .freezer {
                return year
            } else if storageType == .fridge {
                return day*5
            } else {
                return day*3
            }
        case .pomegranate:
            return month*2
        case .popcorn:
            return year
        case .poppySeed:
            return month
        case .pork:
            if storageType == .freezer {
                return month*6
            } else {
                return day*6
            }
        case .portobelloMushroom:
            return week
        case .potRoast:
            if storageType == .freezer {
                return month*6
            } else {
                return day*6
            }
        case .potato:
            if storageType == .fridge {
                return month*4
            } else {
                return week*5
            }
        case .powderedSugar:
            return year*2
        case .provolone:
            return week*3
        case .quinoa:
            return month*18
        case .raisin:
            return month*6
        case .ranch:
            return month*9
        case .raspberry:
            if storageType == .freezer {
                return year
            } else {
                return day*4
            }
        case .ravioli:
            if storageType == .freezer {
                return month*2
            } else {
                return day*5
            }
        case .redPepper:
            return year*3
        case .redWine:
            return year
        case .relish:
            return year
        case .rice:
            return year*5
        case .ricotta:
            return week*2
        case .romanoCheese:
            return month*8
        case .rosemary:
            if storageType == .freezer {
                return month*6
            } else {
                return week*2
            }
        case .rum:
            return year
        case .sage:
            return year
        case .saladDressing:
            return month*4
        case .salami:
            return day*8
        case .salmon:
            if storageType == .freezer {
                return month*3
            } else {
                return day*2
            }
        case .salsa:
            return week*2
        case .salt:
            return year*5
        case .saltines:
            return month*4
        case .sardine:
            return year*5
        case .sausage:
            if storageType == .freezer {
                return month*2
            } else {
                return day*5
            }
        case .scallops:
            if storageType == .freezer {
                return month*6
            } else {
                return day*2
            }
        case .sesame:
            return month*6
        case .sesameOil:
            return month*7
        case .shallot:
            if storageType == .freezer {
                return year
            } else {
                return month
            }
        case .sherry:
            return year
        case .shrimp:
            if storageType == .freezer {
                return month*3
            } else {
                return day*4
            }
        case .snapper:
            if storageType == .freezer {
                return month*8
            } else {
                return day*2
            }
        case .soda:
            return year
        case .sole:
            if storageType == .freezer {
                return month*11
            } else {
                return day*8
            }
        case .sourCream:
            return week*3
        case .soyMilk:
            return day*10
        case .soySauce:
            return year*3
        case .sparklingWater:
            return year*4
        case .spinach:
            if storageType == .freezer {
                return year
            } else {
                return week
            }
        case .squash:
            if storageType == .freezer {
                return year
            } else {
                return day*5
            }
        case .steakSauce:
            return year*2
        case .strawberry:
            if storageType == .freezer {
                return year
            } else {
                return day*6
            }
        case .sugar:
            return year*2
        case .sunDriedTomato:
            return month*7
        case .sunflowerButter:
            return month*7
        case .sunflowerSeeds:
            return month*3
        case .sweetPotato:
            if storageType == .freezer {
                return year
            } else {
                return week*2
            }
        case .swiss:
            if storageType == .freezer {
                return month*8
            } else {
                return week*4
            }
        case .swordfish:
            if storageType == .freezer {
                return month*3
            } else {
                return day*2
            }
        case .syrup:
            return year*2
        case .taterTots:
            return month*13
        case .tartarSauce:
            return month*6
        case .tea:
            return year*2
        case .teriyakiSauce:
            return year
        case .thyme:
            return day*13
        case .tilapia:
            if storageType == .freezer {
                return month*8
            } else {
                return day*2
            }
        case .tofu:
            if storageType == .freezer {
                return month*6
            } else {
                return day*12
            }
        case .tomato:
            return day*8
        case .tomatoPaste:
            return month*6
        case .tomatoSauce:
            return month*8
        case .tortellini:
            if storageType == .freezer {
                return month*2
            } else {
                return day*5
            }
        case .tortilla:
            if storageType == .freezer {
                return month*3
            } else {
                return week*3
            }
        case .trout:
            if storageType == .freezer {
                return month*4
            } else {
                return day*4
            }
        case .tuna:
            if storageType == .pantry {
                return year*3
            } else {
                return week*2
            }
        case .turkey:
            if storageType == .freezer {
                return month*9
            } else {
                return day*6
            }
        case .turkeyJerky:
            return year*2
        case .turmeric:
            return year*4
        case .vanilla:
            return year*2
        case .vegetableOil:
            return year*2
        case .venison:
            if storageType == .freezer {
                return month*9
            } else {
                return day*5
            }
        case .vinegar:
            return year*5
        case .vodka:
            return year
        case .walnuts:
            if storageType == .freezer {
                return year*2
            } else if storageType == .fridge {
                return year
            } else {
                return week*4
            }
        case .water:
            return year*7
        case .watermelon:
            return week*2
        case .whippedCream:
            return month*3
        case .whiskey:
            return year
        case .whiteWine:
            return year
        case .worcestershireSauce:
            return year*3
        case .yeast:
            return month*4
        case .yogurt:
            return week*2
        case .zucchini:
            if storageType == .freezer {
                return month*11
            } else {
                return day*5
            }
        case .chickenWings:
            if storageType == .freezer {
                return month*8
            } else {
                return day*5
            }
        case .cornbread:
            if storageType == .freezer {
                return month*6
            } else {
                return week
            }
        case .garlicBread:
            if storageType == .freezer {
                return month*6
            } else {
                return week
            }
        case .cantaloupe:
            if storageType == .freezer {
                return month*11
            } else {
                return day*6
            }
        case .honeydew:
            if storageType == .freezer {
                return month*11
            } else {
                return day*6
            }
        case .cookingWine:
            return year
        case .other:
            return 0
        }
    }
}
