//
//  ItemName.swift
//  smartList
//
//  Created by Steven Dito on 10/8/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation


enum GenericItem: String {
    
    case alfredoSauce
    case almond
    case almondButter
    case almondMilk
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
    case cornstarch
    case cottageCheese
    case crab
    case cracker
    case cranberry
    case cranberrySauce
    case cream
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
    case heavyCream
    case honey
    case hotDogs
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
    case peach
    case peanutButter
    case peanut
    case peanutOil
    case pear
    case peas
    case pecan
    case pepper
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
    case tea
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
        }
    }
}
