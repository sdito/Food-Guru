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
    case corn
    case cornedBeef
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
    case garlicPowder
    case gin
    case ginger
    case gingerRoot
    case goatCheese
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
    case mozzarella
    case mushroom
    case mussels
    case mustard
    case nectarine
    case nutmeg
    case oatmeal
    case oats
    case oil
    case oliveOil
    case onion
    case onionPowder
    case orange
    case oregano
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
            return "Apple sauce"
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
        }
    }
    
    static let all = GenericItem.allCases.map({$0.description})
    
    static func getCategory(item: GenericItem, words: [String]) -> Category {
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
        }
    }
    
    
    
}
