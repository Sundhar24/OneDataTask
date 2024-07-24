//
//  CharacterListModel.swift
//  OneDataTask
//
//  Created by Sundhar on 24/07/24.
//

import Foundation

class CharacterListModel{
    var info: Info
        var results: [DataItem]
        
        init(json: [String: Any]) {
            self.info = Info(json: json["info"] as? [String: Any] ?? [:])
            self.results = []
            if let resultsArray = json["results"] as? [[String: Any]] {
                self.results = resultsArray.map { DataItem(json: $0) }
            }
        }
    }

    struct Info {
        var count: Int
        var pages: Int
        var next: String
        var prev: String
        
        init(json: [String: Any]) {
            self.count = json["count"] as? Int ?? 0
            self.pages = json["pages"] as? Int ?? 0
            self.next = json["next"] as? String ?? ""
            self.prev = json["prev"] as? String ?? ""
        }
}
class DataItem {
    var id: Int
    var name: String
    var status: String
    var species: String
    var type: String
    var gender: String
    var origin: Location
    var location: Location
    var image: String
    var episode: [String]
    var url: String
    var created: String
    
    init(json: [String: Any]) {
        self.id = json["id"] as? Int ?? 0
        self.name = json["name"] as? String ?? ""
        self.status = json["status"] as? String ?? ""
        self.species = json["species"] as? String ?? ""
        self.type = json["type"] as? String ?? ""
        self.gender = json["gender"] as? String ?? ""
        self.origin = Location(json: json["origin"] as? [String: Any] ?? [:])
        self.location = Location(json: json["location"] as? [String: Any] ?? [:])
        self.image = json["image"] as? String ?? ""
        self.episode = json["episode"] as? [String] ?? []
        self.url = json["url"] as? String ?? ""
        self.created = json["created"] as? String ?? ""
    }
}

struct Location {
    var name: String
    var url: String
    
    init(json: [String: Any]) {
        self.name = json["name"] as? String ?? ""
        self.url = json["url"] as? String ?? ""
    }
}


struct CharacterModel: Codable {
    let id: Int
    let name: String
    let image: String
}
