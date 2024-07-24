//
//  BluetoothVC.swift
//  OneDataTask
//
//  Created by Sundhar on 22/07/24.
//

import UIKit
import CoreBluetooth
import Combine

class BluetoothVC: UIViewController {
    
    
    @IBOutlet weak var lblView: UIView!
    @IBOutlet weak var connectedNameLbl: UILabel!
    
    @IBOutlet weak var refreshBtn: UIButton!
    
    @IBOutlet weak var connectedListTableView: UITableView!
    
    @IBOutlet weak var characterListBtn: UIButton!
    
    
    var bluetoothModel = BluetoothViewModel()
    var cancel: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        RegisterCell()
        callModelFunc()
        sizeControl()
        self.refreshBtn.addTarget(self, action: #selector(RefreshTapped), for: .touchUpInside)
        self.characterListBtn.addTarget(self, action: #selector(CharacterListTapped), for: .touchUpInside)
        
    }
  
    func RegisterCell(){
        
        self.connectedListTableView.delegate = self
        self.connectedListTableView.dataSource = self
        self.connectedListTableView.register(UINib(nibName: "ListedBluetoothTVC", bundle: nil), forCellReuseIdentifier: "ListedBluetoothTVC")
        self.connectedListTableView.reloadData()
        
    }
    
    @objc func CharacterListTapped(){

        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: CharacterListVC = mainStoryboard.instantiateViewController(withIdentifier: "CharacterListVC") as! CharacterListVC
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        vc.modalPresentationStyle = .overFullScreen
//        self.navigationController?.pushViewController(vc, animated: true)
        self.present(vc, animated: true)

    }
    
    
    
    
    func callModelFunc() {
        bluetoothModel.$discoveredDevices
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.connectedListTableView.reloadData()
            }
            .store(in: &cancel)
        
        bluetoothModel.$connectedDeviceName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.connectedNameLbl.text = name
            }
            .store(in: &cancel)
    }
        
    func sizeControl(){
        
        self.lblView.layer.cornerRadius = 10
        self.refreshBtn.layer.cornerRadius = 10
        self.characterListBtn.layer.cornerRadius = 10
//        self.connectedListTableView.backgroundColor = .green
    }
    
    @objc func RefreshTapped(){
        bluetoothModel.refresh()
        connectedListTableView.reloadData()
    }

}

extension BluetoothVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bluetoothModel.discoveredDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListedBluetoothTVC", for: indexPath) as! ListedBluetoothTVC
        let device = bluetoothModel.discoveredDevices[indexPath.row]
        cell.listedLbl.text = device.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Connected List TableView Cell...!")
        bluetoothModel.connectToDevice(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}
