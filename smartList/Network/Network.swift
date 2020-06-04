//
//  Network.swift
//  smartList
//
//  Created by Steven Dito on 6/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Alamofire

class Network {
    
    var ingredients: [String] = []
    var tags: [String] = []
    var nextUrl: String?
    static let shared = Network()
    private init() {}
    
    enum RequestType {
        case recipe
        case tags
        case ingredients
    }
    
    private func req(reqType: RequestType, params: Parameters?) -> DataRequest {
        let headers: HTTPHeaders = ["Authorization": Network.key]
        
        var path: String {
            switch reqType {
            case .recipe:
                return Network.searchPath
            case .tags:
                return Network.tagsPath
            case .ingredients:
                return Network.ingredientsPath
            }
        }
        
        let request = AF.request(Network.baseUrl + path, parameters: params, headers: headers)
        return request
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
    
    func setTags() {
        if tags.isEmpty {
            let request = req(reqType: .tags, params: nil)
            request.responseJSON { (response) in
                switch response.result {
                    case .success(let json):
                        if let tags = self.getElementFromJsonArray(json: json, key: "display") {
                            self.tags = tags
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
                            self.ingredients = ingredients
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
        let nextUrl: String? = json["next_block"] as? String
        var recipes: [Recipe] = []
        if let recipesJson = json["recipes"] as? [[String:Any]] {
            for r in recipesJson {
                let recipe = Recipe(name: r["name"] as! String,
                                    recipeType: [],
                                    cuisineType: "",
                                    cookTime: r["cook_time"] as? Int ?? 0,
                                    prepTime: r["prep_time"] as? Int ?? 0,
                                    ingredients: r["ingredients"] as! [String],
                                    instructions: r["instructions"] as! [String],
                                    calories: r["calories"] as? Int,
                                    numServes: r["servings"] as? Int ?? 0,
                                    userID: nil,
                                    numReviews: nil,
                                    numStars: nil,
                                    notes: r["notes"] as? String,
                                    tagline: r["tagline"] as? String,
                                    recipeImage: nil,
                                    mainImage: r["main_image"] as? String,
                                    reviewImagePaths: nil)
                recipes.append(recipe)
            }
        }
        
        
        return (recipes, nextUrl)
        
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
    
    
    
}
