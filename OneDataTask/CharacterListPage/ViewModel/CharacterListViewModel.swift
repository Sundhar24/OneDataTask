//
//  CharacterListViewModel.swift
//  OneDataTask
//
//  Created by Sundhar on 24/07/24.
//

import Foundation
import Alamofire


class CharacterListViewModel{
    
    static let shared = CharacterListViewModel()
    
    var charaterlist : CharacterListModel?
    var results: [DataItem] = []

    func characterListAPI(completion: @escaping (Result<CharacterListModel, Error>) -> Void) {
        let url = "https://rickandmortyapi.com/api/character/?page=22"
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        let characterListModel = CharacterListModel(json: json)
                        completion(.success(characterListModel))
                    } else {
                        let error = NSError(domain: "ParsingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON"])
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    print("Error fetching data: \(error)")
                    completion(.failure(error))
                }
            }
    }        

    func callAPI(completion: @escaping () -> Void) {
            CharacterListViewModel.shared.characterListAPI { [weak self] response in
                guard let self = self else { return }
                switch response {
                case .success(let characterList):
                    self.charaterlist = characterList
                    self.results = characterList.results
                    completion()
                case .failure(let error):
                    print("Error fetching character list: \(error)")
                    completion()
                }
            }
        }

    
}
