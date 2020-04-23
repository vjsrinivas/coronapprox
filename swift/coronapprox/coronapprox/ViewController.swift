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

class ViewController: UIViewController, CBPeripheralManagerDelegate, CLLocationManagerDelegate {
    
    var peripheralManager: CBPeripheralManager!
    
    var locationManager: CLLocationManager?
    var regionCorona: CLBeaconRegion!
    
    @IBAction func enabled(_ sender: UISwitch) {
        if(sender.isOn)
        {
            startBroadcastingBeacon()
            startMonitoringBeacons()
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
        let proximityUUID = UUID( uuidString: "D61CD492-9264-4915-8C68-A1E490A354A3" ) ?? UUID()
        let beaconId = "edu.jadv.coronapprox"
        let major = CLBeaconMajorValue( 0 )
        let minor = CLBeaconMinorValue( 0 )
        regionCorona = CLBeaconRegion(proximityUUID: proximityUUID, major: major, minor: minor, identifier: beaconId)

        locationManager = CLLocationManager()
        locationManager!.requestWhenInUseAuthorization()

        locationManager!.delegate = self

    }

    func startBroadcastingBeacon() {
        if peripheralManager.state == .poweredOn {
            peripheralManager.stopAdvertising()
            if on.isOn {
                print( "Broadcasting Beacon" )
                let peripheralData = regionCorona.peripheralData( withMeasuredPower: nil )

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
    func startMonitoringBeacons() {
            print( "Monitoring for beacons!" )
            locationManager!.startMonitoring(for: regionCorona)
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("Detected person!")

        if beacons.count > 0
        {
            let nearestBeacon = beacons.first!
            switch nearestBeacon.proximity {
                
            case .near:
                print("Detecter person near!")
                break
            case .immediate:
                print("Detected person immediate")
                break
            case .far:
                print("Detected person far!")
                break
            default:
                print("Detected other!")
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("Detected region!")
        if state == .inside {
            // Start ranging when inside a region.
            locationManager!.startRangingBeacons(in: regionCorona)
        } else {
            // Stop ranging when not inside a region.
            locationManager!.stopRangingBeacons(in: regionCorona)
        }
    }
    

    func stopBroadcastingBeacon() {
        peripheralManager.stopAdvertising()
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        //Nothing for now
    }
}

