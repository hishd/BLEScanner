//
//  ContentViewModel.swift
//  BLEScanner
//
//  Created by Hishara Dilshan on 2024-01-08.
//

import Foundation
import CoreBluetooth

class ContentViewModel: ObservableObject {
    private lazy var bleHelper: BLEHelper = BLEHelper()
    private var scanResultsDictionary: [String: ScanResult] = [:]
    @Published var scanResults: [ScanResult] = []
    @Published var selectedId1: String = ""
    @Published var selectedId2: String = ""
    var selectionType: SelectedBleType = .first
    
    init() {
        bleHelper.setDelegate(delegate: self)
    }
    
    func handleSelectedItem(item: ScanResult) {
        switch selectionType {
        case .first:
            selectedId1 = item.identifier
            break;
        case .second:
            selectedId2 = item.identifier
            break;
        }
    }
}

enum SelectedBleType {
    case first
    case second
}

extension ContentViewModel: BLEOperationCallback {
    func onScanResults(scanResult: [ScanResult]) {
        DispatchQueue.main.async {
            self.scanResults.removeAll()
            let results = scanResult.sorted {
                return $0.rssi > $1.rssi
            }
            self.scanResults.append(contentsOf: results)
        }
    }
}

class BLEHelper: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager?
    private var isbluetoothOn: Bool = false
    private var results: [String: ScanResult] = [:]
    private var delegate: BLEOperationCallback?
    private var scanTimer: Timer?
    private let queue = DispatchQueue(label: "BLEQueue")
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.scanTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { [weak self] timer in
            self?.handleTimer(timer)
        })
    }
    
    private func handleTimer(_ timer: Timer) {
        guard let central = centralManager else {
            return
        }
        
        results.removeAll()
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil)
        }
        
        queue.asyncAfter(deadline: .now() + 2) { [weak self] in
            let scanResults = self?.results.values.map {
                return $0
            }
            
            self?.delegate?.onScanResults(scanResult: scanResults ?? [])
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil)
        }
    }
    
    func setDelegate(delegate: BLEOperationCallback) {
        self.delegate = delegate
        let scanResults = results.values.map {
            return $0
        }
        self.delegate?.onScanResults(scanResult: scanResults)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let result = ScanResult(
            name: peripheral.name,
            identifier: peripheral.identifier.uuidString,
            rssi: RSSI.doubleValue
        )
        results[peripheral.identifier.uuidString] = result
    }
}

protocol BLEOperationCallback {
    func onScanResults(scanResult: [ScanResult])
}

struct ScanResult: Hashable {
    let name: String?
    let identifier: String
    let rssi: Double
}
