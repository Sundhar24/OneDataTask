//
//  BluetoothViewModel.swift
//  OneDataTask
//
//  Created by Sundhar on 22/07/24.
//

import Foundation
import CoreBluetooth
import Alamofire

class BluetoothViewModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
     @Published var discoveredDevices: [BluetoothDevices] = []
     @Published var connectedDeviceName: String = "Not Connected"
    
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func refresh() {
        discoveredDevices.removeAll()
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth is not available.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = BluetoothDevices(name: peripheral.name ?? "Unknown", peripheral: peripheral)
        if !discoveredDevices.contains(where: { $0.peripheral.identifier == peripheral.identifier }) {
            discoveredDevices.append(device)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        connectedDeviceName = peripheral.name ?? "Unknown"
        centralManager.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if connectedPeripheral == peripheral {
            connectedPeripheral = nil
            connectedDeviceName = "Not Connected"
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func connectToDevice(at index: Int) {
        let peripheral = discoveredDevices[index].peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
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

}

