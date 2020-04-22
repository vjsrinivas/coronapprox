//
//  ViewController.swift
//  coronapprox
//
//  Created by Daniel Sylwestrowicz on 4/22/20.
//  Copyright © 2020 JADV. All rights reserved.
//

import CoreLocation
import CoreBluetooth
import UIKit

class ViewController: UIViewController, CBPeripheralManagerDelegate {
    var peripheralManager: CBPeripheralManager!
    @IBAction func enabled(_ sender: UISwitch) {
        if(sender.isOn)
        {
            startBroadcastingBeacon()
        }
        else
        {
            stopBroadcastingBeacon()
        }
    }
    @IBOutlet weak var on: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheralManager = CBPeripheralManager( delegate: self, queue: nil )
    }

    func startBroadcastingBeacon() {
        if peripheralManager.state == .poweredOn {
            peripheralManager.stopAdvertising()
            if on.isOn {
                print( "Broadcasting Beacon" )
                let proximityUUID = UUID( uuidString: "D61CD492-9264-4915-8C68-A1E490A354A3" ) ?? UUID()
                let beaconId = "edu.utk.Force-Field"
                let region = CLBeaconRegion( uuid: proximityUUID, identifier: beaconId )
                let peripheralData = region.peripheralData( withMeasuredPower: nil )

                // Start broadcasting the beacon identity characteristics.
                peripheralManager.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
            }
        } else {
            on.isOn = false
            let alert = UIAlertController(title: "Bluetooth must be enabled to configure your device as a beacon.",
                                          message: nil,
                                          preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true)
        }


    }

    func stopBroadcastingBeacon() {
        peripheralManager.stopAdvertising()
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        //Nothing for now
    }
}

