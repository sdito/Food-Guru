//
//  Search.swift
//  smartList
//
//  Created by Steven Dito on 10/8/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import Foundation
import FirebaseFirestore


#warning("not used at all for anything yet, probably dont need this function to be in here also")
struct Search {
    static func turnIntoSystemItem(string: String) -> GenericItem {
        let descriptors: Set<String> = ["chopped", "minced", "chunks", "cut into", "cubed", "shredded", "melted", "diced", "divided", "to taste", "or more to taste", "or more as needed", "grated", "crushed", "pounded", "boneless", "skinless", "fresh", "sliced", "thinly", "halves", "half"]
        let measurements: Set<String> = ["pound", "pounds", "envelope", "cup", "tablespoons", "packet", "ounce", "large", "small", "medium", "package", "teaspoons", "teaspoon", "tablespoon", "pinch", "t.", "ts.", "tspn", "tbsp", "tbls", "bag", "seeded", "cubes", "cube", "clove", "cloves", "can", "cans", "ounces"]
        
        let lower = string.lowercased()
        var words: [Substring] {
            return lower.split{ !$0.isLetter }
        }
        var item = words.map { (sStr) -> String in
            return String(sStr)
        }
        
        // first need to trim the item from the amount
        var index: Int?
        for word in item {
            if measurements.contains(word) {
                index = item.firstIndex(of: word)
                index! += 1
            }
        }
        
        if index != nil {
            let splice = item[index!...]
            item = Array(splice)
        }
        
        
        
        // second need to trim the item from the description, i.e. cubed or grated
        item = item.filter({descriptors.contains($0) == false})
        if item.contains("chicken") {
            if item.contains("soup") == false {
                return .chicken
            } else if item.contains("cream") {
                return .creamOfChickenSoup
            }
        } else if item.contains("bread") {
            if item.contains("crumbs") {
                return .breadCrumbs
            } else if item.contains("pita") {
                return .pitaBread
            } else {
                return .bread
            }
        }
        else if item.contains("beef") {
            if item.contains("ground") {
                return .groundBeef
            } else {
                return .beef
            }
        } else if item.contains("pork") {
            return .pork
        } else if item.contains("pasta") || item.contains("macaroni") || item.contains("spaghetti") {
            return .pasta
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
        } else if item.contains("crab") {
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
            return .ginger
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
        } else if item.contains("onion") {
            if item.contains("powder") {
                return .onionPowder
            } else {
                return .onion
            }
            
        } else if item.contains("mushroom") {
            if item.contains("cream") && item.contains("soup") {
                return .creamOfMushroomSoup
            } else {
                return .mushroom
            }
        } else if item.contains("garlic") {
            if item.contains("salt") {
                return .salt
            } else if item.contains("powder") {
                return .garlicPowder
            } else {
                return .garlic
            }
        } else if item.contains("olive") || item.contains("olives") {
            if item.contains("black") {
                return .blackOlive
            } else if item.contains("green") {
                return .greenOlive
            }
        } else if item.contains("haddock") {
            return .haddock
        } else if item.contains("avocado") {
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
        } else if item.contains("plum") || item.contains("plums") {
            return .plum
        } else if item.contains("salami") {
            return .salami
        } else if item.contains("parmesan") {
            return .parmesan
        } else if item.contains("lemon") || item.contains("lemons") {
            if item.contains("juice") {
                return .lemonJuice
            } else {
                return .lemon
            }
        } else if item.contains("lime") || item.contains("limes") {
            if item.contains("juice") {
                return .limeJuice
            } else {
                return .lime
            }
        }
        
        else if item.contains("juice") {
            return .juice
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
            return .parsley
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
            }
        } else if item.contains("gelato") || item.contains("sorbet") {
            return .iceCream
        }
        else if item.contains("sauce") {
            if item.contains("worcestershire") {
                return .worcestershireSauce
            } else if item.contains("apple") {
                return .appleSauce
            } else if item.contains("bbq") {
                return .bbqSauce
            } else if item.contains("hot") {
                return .hotSauce
            } else if item.contains("soy") {
                return .soySauce
            } else if item.contains("steak") {
                return .steakSauce
            }
        } else if item.contains("apple") {
            return .apple
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
        } else if item.contains("potato") || item.contains("potatos") {
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
            } else {
                return .tomato
            }
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
        }
        
        
        else {
            return .other
        }
        return .other
    }
}
