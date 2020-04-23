//
//  ViewController.swift
//  coronapprox
//
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

    //  React to the event of changing the on/off switch
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
    //  Variable for the state of the switch
    @IBOutlet weak var on: UISwitch!
    //  Variable for the label which holds the daily # of interactions
    //  TODO - implement resetting of this variable daily
    @IBOutlet weak var dailyNum: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  Initialize peripheral manager to allow advertising when switch is on
        peripheralManager = CBPeripheralManager( delegate: self, queue: nil )
        //  Set the UUID that was randomly generated specifically for this app
        let proximityUUID = UUID( uuidString: "D61CD492-9264-4915-8C68-A1E490A354A3" ) ?? UUID()
        //  beaconId is just the package name
        let beaconId = "edu.jadv.coronapprox"
        //  Since we are not using the major and minor values they are set to 0.
        let major = CLBeaconMajorValue( 0 )
        let minor = CLBeaconMinorValue( 0 )
        //  Define the social distancing region based on the values above
        regionCorona = CLBeaconRegion(proximityUUID: proximityUUID, major: major, minor: minor, identifier: beaconId)

        //  Since we can only range when the app is on request in use permissions
        //  for the location manager.
        locationManager = CLLocationManager()
        locationManager!.requestWhenInUseAuthorization()

        locationManager!.delegate = self
        //  Set the dailyNumber to 0, but this should be reset everyday in the future
        dailyNumber = 0;
    }

    func startBroadcastingBeacon() {
        //  Check if bluetooth is on before starting to advertise beacon data
        if peripheralManager.state == .poweredOn {
            if on.isOn {
                //  Use the social distancing region defined before as the data
                let peripheralData = regionCorona.peripheralData( withMeasuredPower: nil )

                //  Start advertising the data using bluetooth
                peripheralManager.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
            }
        } else {
            //  If bluetooth is off disable the switch and notify user they need to
            //  enable it
            on.isOn = false
            let alert = UIAlertController(title: "Enable bluetooth to detect nearby devices using coronaprox",
                                          message: nil,
                                          preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true)
        }


    }
    func startMonitoringBeacons() {
            //  To monitor for nearby devices we start monitoring the region
            locationManager!.startMonitoring(for: regionCorona)
    }
    func addInteraction()
    {
        //  Called when a nearby or immediate interaction is detected.
        //  Add to the daily count and send a notification to the user
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
        //  Once a beacon is ranged in the region, check for near or immediate
        //  proximity and call addInteraction to record it.
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
        //  Once we are inside the region, start scanning for beacons.
        if state == .inside {
            // Scan for beacons when inside
            locationManager!.startRangingBeacons(in: regionCorona)
        } else {
            // Stop scanning once we're outside.
            locationManager!.stopRangingBeacons(in: regionCorona)
        }
    }
    
    func stopBroadcastingBeacon() {
        //  Disable broadcasting and monitoring the region
        peripheralManager.stopAdvertising()
        locationManager!.stopMonitoring(for: regionCorona)
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        //Nothing for now
    }
}

