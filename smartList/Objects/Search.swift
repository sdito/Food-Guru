//
//  Search.swift
//  smartList
//
//  Created by Steven Dito on 10/8/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Search {
    static func recipeSearchSuggested(buttonName: String, db: Firestore) {
        let reference = db.collection("recipes")
        print("search recipes with: \(buttonName)")
        switch buttonName {
        case "By ingredient":
            print("by ingredient")
        case "Recommended":
            print("Recommended")
        case "Breakfast":
            print("Breakfast")
        case "Lunch":
            print("Lunch")
        case "Dinner":
            print("Dinner")
        case "Low calorie":
            print("Low calorie")
        case "Chicken":
            print("Chicken")
            reference.whereField("has_chicken", isEqualTo: true).getDocuments { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error retrieving documents: \(error)")
                    return
                }
                
            }
        case "Pasta":
            print("Pasta")
        case "Healthy":
            print("Healthy")
        case "Dessert":
            print("Dessert")
        case "Salad":
            print("Salad")
        case "Beef":
            print("Beef")
        case "Seafood":
            print("Seafood")
        case "Casserole":
            print("Casserole")
        case "Vegetarian":
            print("Vegetarian")
        case "Vegan":
            print("Vegan")
        case "Italian":
            print("Italian")
        case "Snack":
            print("Snack")
        case "Simple":
            print("Simple")
        case "Quick":
            print("Quick")
        case "Slow cooker":
            print("Slow cooker")
        default:
            print("default")
        }
    }
    
    static func turnIntoSystemItem(string: String) -> GenericItem {
        let descriptors: Set<String> = ["chopped", "minced", "chunks", "cut into", "cubed", "shredded", "melted", "diced", "divided", "to taste", "or more to taste", "or more as needed", "grated", "crushed", "pounded", "boneless", "skinless", "fresh", "sliced", "thinly", "halves", "half", "halved", "seeded", "with", "and", "finely", "optional", "taste"]
        let measurements: Set<String> = ["pound", "pounds", "envelope", "cup", "cups", "tablespoons", "packet", "ounce", "large", "small", "medium", "package", "teaspoons", "teaspoon", "tablespoon", "pinch", "t.", "ts.", "tspn", "tbsp", "tbls", "bag", "cubes", "cube", "clove", "cloves", "ounces", "quart"]
        
        let lower = string.lowercased()
        var words: [Substring] {
            return lower.split{ !$0.isLetter }
        }
        
        var item = words.map { (sStr) -> String in
            return String(sStr)
        }
        // first need to trim the item from the amount
        var index: Int?
        
        var measurementUsed = false
        for word in item {
            if measurementUsed == false {
                if measurements.contains(word) {
                    index = item.firstIndex(of: word)
                    index! += 1
                    measurementUsed = true
                }
            }
        }
        
        if index != nil {
            let splice = item[index!...]
            item = Array(splice)
        }
        
        // second need to trim the item from the description, i.e. cubed or grated
        item = item.filter({descriptors.contains($0) == false})
        if item.contains("chicken") {
            if item.contains("soup") && item.contains("cream") {
                return .creamOfChickenSoup
            } else if  item.contains("stock") || item.contains("broth") || item.contains("bouillon") {
                return .broth
            } else {
                return .chicken
            }
        } else if item.contains("bread") || item.contains("roll") || item.contains("bun") {
            if item.contains("crumbs") {
                return .breadCrumbs
            } else if item.contains("pita") {
                return .pitaBread
            } else {
                return .bread
            }
        } else if item.contains("salt") {
            return .salt
        } else if item.contains("beef") {
            if item.contains("ground") {
                return .groundBeef
            } else if item.contains("broth") || item.contains("broth") || item.contains("bouillon") {
                return .broth
            } else {
                return .beef
            }
        } else if item.contains("pork") {
            return .pork
        } else if item.contains("pasta") || item.contains("macaroni") || item.contains("spaghetti") {
            if item.contains("sauce") {
                return .marinara
            } else {
                return .pasta
            }
            
        } else if item.contains("tofu") {
            return .tofu
        } else if item.contains("sausage") {
            if item.contains("breakfast") {
                return .breakfastSausage
            } else {
                return .sausage
            }
        } else if item.contains("milk") {
            if item.contains("coconut") {
                return .coconutMilk
            } else {
                return .milk
            }
        } else if item.contains("crab") || item.contains("crabmeat") {
            return .crab
        } else if item.contains("egg") || item.contains("eggs") {
            if item.contains("noodle") || item.contains("noodles") {
                return .eggNoodles
            } else {
                return .egg
            }
        } else if item.contains("kale") {
            return .kale
        } else if item.contains("cod") {
            return .cod
        } else if item.contains("cilantro") {
            return .cilantro
        } else if item.contains("cinnamon") {
            return .cinnamon
        } else if item.contains("honey") {
            return .honey
        } else if item.contains("jam") || item.contains("jelly") || item.contains("preserves") {
            return .jelly
        } else if item.contains("halibut") {
            return .halibut
        } else if item.contains("ginger") {
            if item.contains("root") {
                return .gingerRoot
            } else {
                return .ginger
            }
        } else if item.contains("mozzarella") {
            return .mozzarella
        } else if item.contains("provolone") {
            return .provolone
        } else if item.contains("ricotta") {
            return .ricotta
        } else if item.contains("cheddar") {
            return .cheddar
        } else if item.contains("swiss") {
            return .swiss
        }
        else if item.contains("celery") {
            return .celery
        } else if item.contains("cauliflower") {
            return .cauliflower
        } else if item.contains("butter") {
            if item.contains("peanut") {
                return .peanutButter
            } else if item.contains("almond") {
                return .almondButter
            } else if item.contains("cashew") {
                return .cashewButter
            } else if item.contains("apple") {
                return .appleButter
            } else if item.contains("sunflower") {
                return .sunflowerButter
            } else {
                return .butter
            }
        } else if item.contains("turkey") {
            if item.contains("ground") {
                return .groundTurkey
            } else if item.contains("stock") || item.contains("broth") {
                return .broth
            } else if item.contains("liver") {
                return .other
            } else {
                return .turkey
            }
        } else if item.contains("tuna") {
            return .tuna
        } else if item.contains("trout") {
            return .trout
        } else if item.contains("spinach") {
            if item.contains("baby") {
                return .babySpinach
            } else {
                return .spinach
            }
        } else if item.contains("shrimp") {
            return .shrimp
        } else if item.contains("tilapia") {
            return .tilapia
        } else if item.contains("onion") || item.contains("onions") {
            if item.contains("powder") {
                return .onionPowder
            } else if item.contains("green") {
                return .greenOnion
            } else {
                return .onion
            }
            
        } else if item.contains("mushroom") || item.contains("mushrooms") {
            if item.contains("cream") && item.contains("soup") {
                return .creamOfMushroomSoup
            } else if item.contains("portobello") {
                return .portobelloMushroom
            } else {
                return .mushroom
            }
        } else if item.contains("garlic") {
            if item.contains("salt") {
                return .salt
            } else if item.contains("powder") {
                return .garlicPowder
            } else if item.contains("pepper") {
                return .other
            } else {
                return .garlic
            }
        } else if (item.contains("olive") || item.contains("olives")) && item.contains("oil") == false {
            if item.contains("black") {
                return .blackOlive
            } else if item.contains("green") {
                return .greenOlive
            }
        } else if item.contains("haddock") {
            return .haddock
        } else if item.contains("avocado") || item.contains("avocados") {
            if item.contains("oil") {
                return .avocadoOil
            } else {
                return .avocado
            }
        } else if item.contains("bacon") {
            return .bacon
        } else if item.contains("broccoli") {
            return .broccoli
        } else if item.contains("broth") {
            return .broth
        } else if item.contains("snapper") {
            return .snapper
        } else if item.contains("salmon") {
            return .salmon
        } else if item.contains("sole") {
            return .sole
        } else if item.contains("venison") {
            return .venison
        } else if item.contains("watermelon") {
            return .watermelon
        } else if item.contains("zucchini") {
            return .zucchini
        } else if item.contains("quinoa") {
            return .quinoa
        } else if item.contains("salami") {
            return .salami
        } else if item.contains("parmesan") {
            return .parmesan
        } else if item.contains("lemon") || item.contains("lemons") {
            if item.contains("juice") {
                return .lemonJuice
            } else if !item.contains("herb") {
                return .lemon
            }
        } else if item.contains("lime") || item.contains("limes") {
            if item.contains("juice") {
                return .limeJuice
            } else {
                return .lime
            }
        } else if item.contains("mahi") {
            return .mahiMahi
        } else if item.contains("marinara") {
            return .marinara
        }
        
        else if item.contains("juice") {
            if item.contains("apple") {
                return .appleJuice
            } else {
                return .juice
            }
            
        } else if item.contains("lamb") {
            return .lamb
        } else if item.contains("orange") || item.contains("oranges") {
            return .orange
        } else if item.contains("oregano") {
            return .oregano
        } else if item.contains("mayonnaise") || item.contains("mayo") {
            return .mayonnaise
        } else if item.contains("margarine") {
            return .margarine
        } else if item.contains("parsley") {
            if item.contains("dried") {
                return .driedParsley
            } else {
                return .parsley
            }
        } else if item.contains("turmeric") {
            return .turmeric
        } else if item.contains("swordfish") {
            return .swordfish
        } else if item.contains("syrup") {
            return .syrup
        } else if item.contains("cream") {
            if item.contains("whipped") {
                return .whippedCream
            } else if item.contains("heavy") {
                return .heavyCream
            } else if item.contains("ice") {
                return .iceCream
            } else if item.contains("sour") {
                return .sourCream
            } else {
                return .cream
            }
        } else if item.contains("gelato") || item.contains("sorbet") {
            return .iceCream
        }
        else if item.contains("sauce") {
            if item.contains("worcestershire") {
                return .worcestershireSauce
            } else if item.contains("apple") {
                return .appleSauce
            } else if item.contains("bbq") || item.contains("barbeque") {
                return .bbqSauce
            } else if item.contains("hot") {
                return .hotSauce
            } else if item.contains("soy") {
                return .soySauce
            } else if item.contains("steak") {
                return .steakSauce
            } else if item.contains("tomato") {
                return .tomatoSauce
            } else if item.contains("alfredo") {
                return .alfredoSauce
            } else if item.contains("pesto") {
                return .pestoSauce
            } else if item.contains("oyster") {
                return .oysterSauce
            }
        } else if item.contains("apple") {
            if item.contains("vinegar") {
                return .appleCiderVinegar
            } else {
                return .apple
            }
        } else if item.contains("beans") {
            if item.contains("baked") {
                return .bakedBeans
            } else if item.contains("black") {
                return .blackBeans
            } else if item.contains("pinto") {
                return .pintoBeans
            } else if item.contains("kidney") {
                return .kidneyBeans
            } else if item.contains("lima") {
                return .limaBeans
            } else if item.contains("cannellini") || item.contains("white") {
                return .cannelliniBeans
            } else if item.contains("fava") {
                return .favaBeans
            } else if item.contains("green") {
                return .greenBeans
            }
        } else if item.contains("wine") {
            if item.contains("white") {
                return .whiteWine
            } else {
                return .redWine
            }
        } else if item.contains("sugar") {
            if item.contains("brown") {
                return .brownSugar
            } else {
                return .sugar
            }
        } else if item.contains("potato") || item.contains("potatoes") {
            if item.contains("sweet") {
                return .sweetPotato
            } else {
                return .potato
            }
        } else if item.contains("yam") || item.contains("yams") {
            return .sweetPotato
        } else if item.contains("salsa") || (item.contains("gallo") && item.contains("pico")) {
            return .salsa
        } else if item.contains("rosemary") {
            return .rosemary
        } else if item.contains("peach") || item.contains("peaches") {
            return .peach
        } else if item.contains("strawberry") || item.contains("strawberries") {
            return .strawberry
        } else if item.contains("banana") || item.contains("bananas") {
            return .banana
        } else if item.contains("grapes") {
            return .grape
        } else if item.contains("kiwi") || item.contains("kiwis") {
            return .kiwi
        } else if item.contains("pear") || item.contains("pears") {
            return .pear
        } else if item.contains("apricot") {
            return .apricot
        } else if item.contains("blackberries") {
            return .blackberry
        } else if item.contains("blueberries") {
            return .blueberries
        } else if item.contains("capers") {
            return .capers
        } else if item.contains("cherries") || item.contains("cherry") {
            if item.contains("tomatoes") {
                return .tomato
            } else {
                return .cherries
            }
        } else if item.contains("cranberry") || item.contains("cranberries") {
            if item.contains("sauce") {
                return .cranberrySauce
            } else {
                return .cranberry
            }
        } else if item.contains("grapefruit") {
            return .grapefruit
        } else if item.contains("guava") {
            return .guava
        } else if item.contains("mango") || item.contains("mangoes") {
            return .mango
        } else if item.contains("melon") {
            return .melon
        } else if item.contains("pineapple") {
            return .pineapple
        } else if item.contains("pomegranate") {
            return .pomegranate
        } else if item.contains("raspberry") {
            return .raspberry
        } else if item.contains("tomato") || item.contains("tomatoes") {
            if item.contains("paste") {
                return .tomatoPaste
            } else if item.contains("can") || item.contains("cans") || item.contains("canned") {
                return .cannedTomato
            } else if item.contains("sun") && item.contains("dried") {
                return .sunDriedTomato
            }
            else {
                return .tomato
            }
        } else if item.contains("plum") || item.contains("plums") {
            return .plum
        } else if item.contains("tortilla") || item.contains("tortillas") {
            if item.contains("chips") {
                return .chips
            } else {
                return .tortilla
            }
        } else if item.contains("duck") {
            return .duck
        } else if item.contains("feta") {
            return .feta
        } else if item.contains("flour") {
            return .flour
        } else if item.contains("flounder") {
            return .flounder
        } else if item.contains("ham") {
            return .ham
        } else if item.contains("gruyere") {
            return .gruyere
        }
        else if item.contains("cheese") {
            if item.contains("goat") {
                return .goatCheese
            } else if item.contains("mac") || item.contains("macaroni") {
                return .macAndCheese
            } else if item.contains("asiago") {
                return .asiagoCheese
            } else if item.contains("bleu") {
                return .bleuCheese
            } else if item.contains("cottage") {
                return .cottageCheese
            } else if item.contains("romano") {
                return .romanoCheese
            }
            else {
                return .cheese
            }
        } else if item.contains("pizza") {
            return .pizza
        } else if item.contains("pickle") || item.contains("pickles") {
            return .pickle
        } else if item.contains("pepper") || item.contains("peppers") {
            if item.contains("bell") {
                return .bellPepper
            } else if item.contains("red") {
                return .redPepper
            } else if item.contains("black") {
                return .blackPepper
            } else if item.contains("jalapeno") || item.contains("jalapeño") {
                return .jalapeno
            } else if item.contains("cayenne") {
                return .cayenne
            } else {
                return .pepper
            }
        } else if item.contains("peanut") || item.contains("peanuts") {
            if item.contains("oil") {
                return .peanutOil
            } else {
                return .peanut
            }
        } else if item.contains("relish") {
            return .relish
        } else if item.contains("rice") {
            if item.contains("arborio") {
                return .arborioRice
            } else {
                return .rice
            }
        } else if item.contains("squash") {
            return .squash
        } else if item.contains("oil") {
            if item.contains("vegetable") {
                return .vegetableOil
            } else if item.contains("olive") {
                return .oliveOil
            } else if item.contains("canola") {
                return .canolaOil
            } else if item.contains("sesame") {
                return .sesameOil
            } else {
                return .oil
            }
        } else if item.contains("rum") {
            return .rum
        } else if item.contains("sage") {
            return .sage
        } else if item.contains("vodka") {
            return .vodka
        } else if item.contains("whiskey") {
            return .whiskey
        } else if item.contains("yeast") {
            return .yeast
        } else if item.contains("yogurt") {
            if item.contains("greek") {
                return .greekYogurt
            } else {
                return .yogurt
            }
            
        } else if item.contains("gin") {
            return .gin
        } else if item.contains("cumin") {
            return .cumin
        } else if item.contains("cucumber") || item.contains("cucumbers") {
            return .cucumber
        } else if item.contains("coffee") {
            return .coffee
        } else if item.contains("corn") {
            return .corn
        } else if item.contains("chocolate") {
            return .chocolate
        } else if item.contains("chili") {
            if item.contains("powder") {
                return .chiliPowder
            } else {
                return .chili
            }
        } else if item.contains("cabbage") {
            return .cabbage
        } else if item.contains("basil") {
            if item.contains("dried") {
                return .driedBasil
            } else {
                return .basil
            }
        } else if item.contains("vinegar") {
            if item.contains("balsamic") {
                return .balsamicVinegar
            } else {
                return .vinegar
            }
        } else if item.contains("vanilla") {
            return .vanilla
        } else if item.contains("almond") || item.contains("almonds") {
            return .almond
        } else if item.contains("baking") && item.contains("soda") {
            return .bakingSoda
        } else if item.contains("baking") && item.contains("powder") {
            return .bakingPowder
        } else if item.contains("bay") && (item.contains("leaf") || item.contains("leaves")) {
            return .bayLeaf
        } else if item.contains("beer") {
            return .beer
        } else if item.contains("asparagus") {
            return .asparagus
        } else if item.contains("anchovy") || item.contains("anchovies") {
            return .anchovy
        } else if item.contains("bagel") || item.contains("bagels") {
            return .bagel
        } else if item.contains("barley") {
            return .barley
        } else if item.contains("carrot") || item.contains("carrots") {
            return .carrot
        } else if item.contains("cayenne") {
            return .cayenne
        } else if item.contains("catfish") {
            return .catfish
        } else if item.contains("cereal") {
            return .cereal
        } else if item.contains("champagne") {
            return .champagne
        } else if item.contains("curry") || item.contains("powder") {
            return .curryPowder
        } else if item.contains("jalapeno") || item.contains("jalapeño") {
            return .jalapeno
        } else if item.contains("ketchup") {
            return .ketchup
        } else if item.contains("lobster") {
            return .lobster
        } else if item.contains("lettuce") {
            return .lettuce
        } else if item.contains("lasagna") && item.contains("noodles") {
            return .lasagnaNoodles
        } else if item.contains("mustard") {
            if item.contains("dijon") {
                return .dijonMustard
            } else {
                return .mustard
            }
        } else if item.contains("nutmeg") {
            return .nutmeg
        } else if item.contains("oysters") || item.contains("oyster") {
            return .oyster
        } else if item.contains("paprika") {
            return .paprika
        } else if item.contains("granola") {
            if item.contains("bar") || item.contains("bars") {
                return .granolaBars
            } else {
                return .granola
            }
        } else if item.contains("cashew") || item.contains("cashews") {
            return .cashew
        } else if item.contains("tea") {
            return .tea
        } else if item.contains("thyme") {
            return .thyme
        } else if item.contains("sardine") || item.contains("sardines") {
            return .sardine
        } else if item.contains("soda") || item.contains("pop") || item.contains("cola") || item.contains("coke") {
            return .soda
        } else if item.contains("pot") || item.contains("roast") {
            return .potRoast
        } else if item.contains("popcorn") {
            return .popcorn
        } else if item.contains("oats") || item.contains("oat") {
            return .oats
        } else if item.contains("oatmeal") {
            return .oatmeal
        } else if item.contains("mussels") {
            return .mussels
        } else if item.contains("nectarines") {
            return .nectarine
        } else if item.contains("italian") || item.contains("seasoning") {
            return .italianSeasoning
        } else if item.contains("hummus"){
            return .hummus
        } else if item.contains("dip") {
            return .dip
        } else if item.contains("tater") || item.contains("tots") {
            return .taterTots
        } else if item.contains("hot") && (item.contains("dog") || item.contains("dogs")) {
            return .hotDogs
        } else if item.contains("icing") {
            return .icing
        } else if item.contains("crackers") {
            return .cracker
        } else if item.contains("fennel") {
            return .fennelSeeds
        } else if item.contains("half") && item.count > 1 {
            return .halfAndHalf
        } else if item.contains("pecan") || item.contains("pecans") {
            return .pecan
        } else if item.contains("walnut") || item.contains("walnuts") {
            return .walnuts
        } else if item.contains("raisins") {
            return .raisin
        } else if item.contains("sunflower") && item.contains("seeds") {
            return .sunflowerSeeds
        } else if item.contains("sesame") {
            if item.contains("oil") {
                return .sesameOil
            } else {
                return .sesame
            }
        } else if item.contains("eggplant") || item.contains("eggplants") {
            return .eggplant
        } else if item.contains("lentil") || item.contains("lentils") {
            return .lentil
        } else if item.contains("cornstarch") {
            return .cornstarch
        } else if item.contains("sherry") {
            return .sherry
        } else if item.contains("sprouts") && (item.contains("brussels") || item.contains("brussel")) {
            return .brusselsSprouts
        } else if item.contains("artichoke") || item.contains("artichokes") {
            if item.contains("heart") || item.contains("hearts") {
                return .artichokeHeart
            } else {
                return .artichoke
            }
        } else if item.contains("poppy") && item.contains("seeds") {
            return .poppySeed
        } else if item.contains("dill") && item.contains("weed") {
            return .dillWeed
        } else if item.contains("tortellini") {
            return .tortellini
        } else if item.contains("ravioli") {
            return .ravioli
        } else if item.contains("peas") {
            return .peas
        } else if item.contains("chives") {
            return .chives
        } else if item.contains("shallot") || item.contains("shallots") {
            return .shallot
        } else if item.contains("alfredo") {
            return .alfredoSauce
        } else if item.contains("pesto") {
            return .pestoSauce
        } else if item.contains("scallops") {
            return .scallops
        } else if item.contains("clams") {
            return .clam
        }
        
        
        else {
            return .other
        }
        return .other
    }
}
