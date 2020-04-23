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
import UserNotifications

class ViewController: UIViewController, CBPeripheralManagerDelegate, CLLocationManagerDelegate {
    
    var peripheralManager: CBPeripheralManager!

    var locationManager: CLLocationManager?
    var regionCorona: CLBeaconRegion!
    var dailyNumber: Int!

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
    @IBOutlet weak var dailyNum: UILabel!
    
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
        dailyNumber = 0;
    }

    func startBroadcastingBeacon() {
        if peripheralManager.state == .poweredOn {
            peripheralManager.stopAdvertising()
            if on.isOn {
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
            locationManager!.startMonitoring(for: regionCorona)
    }
    func addInteraction()
    {
        dailyNumber += 1
        dailyNum.text = String(dailyNumber)
        let content = UNMutableNotificationContent()
        content.title = "Device detected within 6ft!"
        content.body = "Make sure you are social distancing"
        content.sound = UNNotificationSound.default
        let identifier = "coronaprox"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        let notificationCenter = UNUserNotificationCenter.current()

        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        if beacons.count > 0
        {
            let nearestBeacon = beacons.first!
            switch nearestBeacon.proximity {
                
            case .near:
                addInteraction()
            case .immediate:
                addInteraction()
                break
            default:
                print("other distance")
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
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
        locationManager!.stopMonitoring(for: regionCorona)
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        //Nothing for now
    }
}

