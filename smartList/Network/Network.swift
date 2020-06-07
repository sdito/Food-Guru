//
//  Network.swift
//  smartList
//
//  Created by Steven Dito on 6/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Alamofire
import AlamofireImage
import PDFKit


class Network {
    
    var ingredients: [NetworkSearch] = []
    var tags: [NetworkSearch] = []
    var nextUrl: String?
    static let shared = Network()
    
    private init() {}
    
    enum RequestType {
        case recipe
        case tags
        case ingredients
        case pdf
        case singleRecipe
    }
    
    private func req(reqType: RequestType, params: Parameters?, recipeID: Int? = nil) -> DataRequest {
        let headers: HTTPHeaders = ["Authorization": Network.key]
        var path: String {
            switch reqType {
            case .recipe:
                return Network.searchPath
            case .tags:
                return Network.tagsPath
            case .ingredients:
                return Network.ingredientsPath
            case .pdf:
                return Network.pdfPath + "\(recipeID!)"
            case .singleRecipe:
                return Network.searchPath + "\(recipeID!)/"
            
            }
        }
        
        let request = AF.request(Network.baseUrl + path, parameters: params, headers: headers)
        return request
    }
    
    private func req(url: String) -> DataRequest {
        let headers: HTTPHeaders = ["Authorization": Network.key]
        let request = AF.request(url, headers: headers)
        return request
    }
    
    func openPDF(recipeID: Int, pdfDataReturned: @escaping (Data) -> Void) {
        
        if recipeID != -1 {
            let request = req(reqType: .pdf, params: nil, recipeID: recipeID)
            request.response { (response) in
                switch response.result {
                case .success(let data):
                    if let data = data {
                        pdfDataReturned(data)
                        
                    }
                    
                case .failure(let error):
                    print(error)
                    #warning("need to handle case")
                }
            }
        }
    }
    
    func getImage(url: String?, imageReturned: @escaping (UIImage) -> Void) {
        
        if let url = url {
            AF.request(url).responseImage { (response) in
                if let data = response.data {
                    if let image = UIImage(data: data) {
                        imageReturned(image)
                    }
                }
            }
        }
    }
    
    func getRecipes(searches: [NetworkSearch]?, recipesReturned: @escaping ([Recipe]?) -> Void) {
        let params = getParams(from: searches)
        let request = req(reqType: .recipe, params: params)
        request.responseJSON { (response) in
            switch response.result {
            case .success(let json):
                let (recipes, nextUrl) = self.getRecipesAndUrlFromJson(json: json)
                self.nextUrl = nextUrl
                recipesReturned(recipes)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getRecipes(url: String, recipesReturned: @escaping ([Recipe]?) -> Void) {
        let request = req(url: url)
        request.responseJSON { (response) in
            switch response.result {
            case .success(let json):
                let (recipes, nextUrl) = self.getRecipesAndUrlFromJson(json: json)
                self.nextUrl = nextUrl
                recipesReturned(recipes)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getSingleRecipe(id: Int, recipeReturned: @escaping (Recipe?) -> Void) {
        #warning("need to finish this and also implement")
        if id != -1 {
            let request = req(reqType: .singleRecipe, params: nil, recipeID: id)
            request.responseJSON { (response) in
                switch response.result {
                case .success(let json):
                    if let dict = json as? [String:Any] {
                        print(dict)
                        let recipe = self.getOneRecipeFromJson(r: dict)
                        recipeReturned(recipe)
                    }
                case .failure(let error):
                    print(error)
                    #warning("need to handle this")
                }
            }
        }
    }
    
    func setTags() {
        if tags.isEmpty {
            let request = req(reqType: .tags, params: nil)
            request.responseJSON { (response) in
                switch response.result {
                    case .success(let json):
                        if let tags = self.getElementFromJsonArray(json: json, key: "display") {
                            self.tags = tags.map({NetworkSearch(text: $0, type: .tag)})
                        }
                    case .failure(let error):
                        print(error)
                        #warning("need to handle this")
                }
            }
        }
    }
    
    func setIngredients() {
        if ingredients.isEmpty {
            let request = req(reqType: .ingredients, params: nil)
            request.responseJSON { (response) in
                switch response.result {
                    case .success(let json):
                        if let ingredients = self.getElementFromJsonArray(json: json, key: "display") {
                            self.ingredients = ingredients.map({NetworkSearch(text: $0, type: .ingredient)})
                        }
                    case .failure(let error):
                        print(error)
                        #warning("need to handle this")
                }
            }
        }
    }
    private func getRecipesAndUrlFromJson(json: Any) -> ([Recipe]?, String?) {
        
        guard let json = json as? [String:Any] else { return (nil, nil) }
        let nextUrl = json["next_block"] as? String
        var recipes: [Recipe] = []
        
        if let recipesJson = json["recipes"] as? [[String:Any]] {
            for r in recipesJson {
                let recipe = getOneRecipeFromJson(r: r)
                recipes.append(recipe)
            }
        }
        
        
        return (recipes, nextUrl)
        
    }
    
    private func getOneRecipeFromJson(r: [String:Any]) -> Recipe {
        let strServings = r["servings"] as? String
        var recipe = Recipe(djangoID: r["id"] as! Int,
                            name: r["name"] as! String,
                            authorName: r["author"] as? String,
                            cookTime: r["cook_time"] as? Int,
                            prepTime: r["prep_time"] as? Int,
                            ingredients: r["ingredients"] as! [String],
                            instructions: r["instructions"] as! [String],
                            calories: r["calories"] as? Int,
                            numServes: Int(strServings ?? "4") ?? 4, // set recipe to 4 servings so user can change the ratio, if it doesn't have a servings
                            notes: r["notes"] as? String,
                            tagline: r["tagline"] as? String,
                            recipeImage: nil,
                            mainImage: r["main_image"] as? String,
                            thumbImage: r["thumb_image"] as? String)

        return recipe
    }
    
    private func getElementFromJsonArray(json: Any, key: String) -> [String]? {
        var arr: [String] = []
        guard let jsonArray = json as? [[String:Any]] else { return nil }
        for a in jsonArray {
            if let str = a[key] as? String {
                arr.append(str)
            }
        }
        return arr
    }
    
    
    
    private func getParams(from searches: [NetworkSearch]?) -> Parameters? {
        guard let searches = searches else { return nil }
        var params: Parameters = [:]
        for t in NetworkSearch.NetworkSearchType.allCases {
            let matchingSearches = searches.filter({$0.type == t})
            if matchingSearches.count > 0 {
                var paramValue = ""
                switch t.takesMultiple() {
                case true:
                    var matchingSearchesText: [String] = []
                    for s in matchingSearches {
                        // surround with double quotes if contains a comma
                        let text = s.text.contains(",") ? "\"\(s.text)\"" : s.text
                        matchingSearchesText.append(text)
                    }
                    paramValue = matchingSearchesText.joined(separator: ",")
                case false:
                    let s = matchingSearches[0]
                    // surround with double quotes if contains a comma
                    paramValue = s.text.contains(",") ? "\"\(s.text)\"" : s.text
                }
                params[t.getParam()] = paramValue
            }
        }
        return params
    }
    
    
    static func getSearchesFromText(text: String, currSearches: [NetworkSearch]) -> [NetworkSearch] {
        // Will be sorted so unknown will be last
        var currSearchesCopy: [NetworkSearch] = currSearches
        var newSearches: [NetworkSearch] = []
        
        let textSearches = text.splitCommaAndQuotes()
        
        for textSearch in textSearches {
            let txt = textSearch.trimmingCharacters(in: .whitespacesAndNewlines)
            // if there are still searches that could have a match
            if currSearchesCopy.count > 0 {
                var match = false
                var indexesToRemove: [Int] = []
                for (i, s) in currSearchesCopy.enumerated() {
                    // if there is a match, remove from currSearchesCopy and add to newSearches, set found to true
                    if txt == s.text {
                        if s.type == .unknown {
                            // add at the back
                            newSearches.append(s)
                        } else {
                            // add at the front
                            newSearches.insert(s, at: 0)
                        }
                        
                        // remove the element from currSearchesCopy
                        currSearchesCopy.remove(at: i)
                        indexesToRemove.append(i)
                        match = true
                        break
                    }
                }
                if !match {
                    newSearches.append(NetworkSearch(text: txt, type: .unknown))
                }
                
            } else {
                
                newSearches.append(NetworkSearch(text: txt, type: .unknown))
            }
        }
        
        for s in newSearches {
            print("\(s.text): \(s.type)")
        }
        
        return newSearches
        
    }
    
}
