//
//  ContentModel.swift
//  Force Field
//
//  Created by Daniel Sylwestrowicz on 4/19/20.
//  Copyright © 2020 Daniel Sylwestrowicz. All rights reserved.
//

import CoreLocation
import CoreBluetooth
import UIKit

class ContentModel: UIViewController, CBPeripheralManagerDelegate {
    
    var enabled: Bool = false {
        willSet {
            if (!enabled)
            {
                startBroadcastingBeacon()
            }
            else
            {
                stopBroadcastingBeacon()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func startBroadcastingBeacon() {
        let proximityUUID = UUID( uuidString: "D61CD492-9264-4915-8C68-A1E490A354A3" ) ?? UUID()
        let beaconId = "edu.utk.Force-Field"
        let region = CLBeaconRegion( uuid: proximityUUID, identifier: beaconId )
        let peripheralManager = CBPeripheralManager( delegate: self, queue: nil )
        let peripheralData = region.peripheralData( withMeasuredPower: nil )
        
        peripheralManager.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))

    }

    func stopBroadcastingBeacon() {
        //Add this
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        //Nothing for now
    }
}



