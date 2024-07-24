//
//  CharacterListVC.swift
//  OneDataTask
//
//  Created by Sundhar on 24/07/24.
//

import UIKit

class CharacterListVC: UIViewController {
    
    @IBOutlet weak var searchTxt: UITextField!
    
    @IBOutlet weak var characterListCollectionView: UICollectionView!
    
    @IBOutlet weak var backBtn: UIButton!
        
    var filteredResults: [DataItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SetUpViews()
    }
    
    func SetUpViews(){
        registerCell()
        self.searchTxt.delegate = self
        CharacterListViewModel.shared.callAPI {
                   DispatchQueue.main.async {
                       self.characterListCollectionView.reloadData()
                   }
        }
        self.backBtn.addTarget(self, action: #selector(BackTapped), for: .touchUpInside)
        self.characterListCollectionView.reloadData()
    }
    
    func registerCell(){
        
        self.characterListCollectionView.delegate = self
        self.characterListCollectionView.dataSource = self
        self.characterListCollectionView.register(UINib(nibName: "CharacterListCVC", bundle: nil), forCellWithReuseIdentifier: "CharacterListCVC")
        self.characterListCollectionView.reloadData()
    }
    
    @objc func BackTapped(){
        
        self.dismiss(animated: true)
    }

}

extension CharacterListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredResults.isEmpty ? CharacterListViewModel.shared.results.count : filteredResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterListCVC", for: indexPath) as! CharacterListCVC
        let character = filteredResults.isEmpty ? CharacterListViewModel.shared.results[indexPath.item] : filteredResults[indexPath.item]
        
        cell.listNameLbl.text = character.name
        if let imageUrl = URL(string: character.image) {
            URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                if let error = error {
                    print("Error loading image: \(error)")
                    DispatchQueue.main.async {
                        cell.listImg.image = UIImage(named: "placeholder")
                    }
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.listImg.image = image
                    }
                }
            }.resume()
        } else {
            cell.listImg.image = UIImage(named: "placeholder")
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let character = filteredResults.isEmpty ? CharacterListViewModel.shared.results[indexPath.item] : filteredResults[indexPath.item]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let characterDetailsVC = storyboard.instantiateViewController(withIdentifier: "CharacterDetailsVC") as? CharacterDetailsVC else {
            fatalError("Unable to instantiate CharacterDetailsVC from storyboard")
        }
        
        characterDetailsVC.characterID = "\(character.id)"
        characterDetailsVC.characterName = character.name
        characterDetailsVC.characterImageURL = character.image
        characterDetailsVC.modalPresentationStyle = .overFullScreen
        self.present(characterDetailsVC, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width/2) - 10, height: 200)
    }

}

extension CharacterListVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let text = textField.text else { return true }
            let searchText = (text as NSString).replacingCharacters(in: range, with: string)
            filterCharacters(for: searchText)
            return true
        }
        
        func filterCharacters(for searchText: String) {
            if searchText.isEmpty {
                filteredResults = CharacterListViewModel.shared.results
            } else if let id = Int(searchText) {
                filteredResults = CharacterListViewModel.shared.results.filter { $0.id == id }
            } else {
                filteredResults = CharacterListViewModel.shared.results.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            }
            characterListCollectionView.reloadData()
        }
}
