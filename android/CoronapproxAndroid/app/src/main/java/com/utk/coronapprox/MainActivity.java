package com.utk.coronapprox;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import android.Manifest;
import android.content.pm.PackageManager;
import android.util.Log;
import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

import ch.uepaa.p2pkit.AlreadyEnabledException;
import ch.uepaa.p2pkit.P2PKit;
import ch.uepaa.p2pkit.P2PKitStatusListener;
import ch.uepaa.p2pkit.StatusResult;
import ch.uepaa.p2pkit.discovery.DiscoveryInfoTooLongException;
import ch.uepaa.p2pkit.discovery.DiscoveryListener;
import ch.uepaa.p2pkit.discovery.DiscoveryPowerMode;
import ch.uepaa.p2pkit.discovery.Peer;
import ch.uepaa.p2pkit.discovery.ProximityStrength;

public class MainActivity extends AppCompatActivity {
    private static final String APP_KEY = "";
    private final Set<Peer> nearbyPeers = new HashSet<>();
    private final ArrayList<String> test_list = new ArrayList<>();
    private static int total_num_peers = 0;
    private Date lastUpdated = new Date();
    private Button toggleP2PKit;
    private TextView detailedError;

    public void enableP2PKit() {
        try {
            toggleP2PKit.setClickable(false);
            toggleP2PKit.setText("P2PKit Already Enabled");
            Log.d("P2PKit", "Enabling p2pkit");
            P2PKit.enable(this, APP_KEY, mStatusListener);
        } catch (AlreadyEnabledException e) {
            Log.d("P2PKit", "p2pkit is already enabled " + e.getLocalizedMessage());
            toggleP2PKit.setClickable(false);
            toggleP2PKit.setText("P2PKit Already Enabled");
        }
    }

    public void disableP2PKit() {
        Log.d("P2PKit", "Disable p2pkit");

        if (P2PKit.isEnabled()) {
            P2PKit.disable();
            toggleP2PKit.setClickable(true);
            toggleP2PKit.setText("Enable P2PKit");
        }
    }


    public void startDiscovery() {
        byte[] ownDiscoveryData = "Test".getBytes();

        try {
            P2PKit.enableProximityRanging();
            P2PKit.startDiscovery(ownDiscoveryData, DiscoveryPowerMode.HIGH_PERFORMANCE, mDiscoveryListener);
        } catch (DiscoveryInfoTooLongException e) {
            Log.d("P2PKit", "Can not start discovery, discovery info is to long " + e.getLocalizedMessage());
        }
    }

    public void stopDiscovery() {
        Log.d("P2PKit", "Stop discovery");
        P2PKit.stopDiscovery();

        for (Peer peer : nearbyPeers) {
            handlePeerLost(peer);
        }

        nearbyPeers.clear();
    }

    private void handlePeerLost(final Peer peer) {
        UUID peerId = peer.getPeerId();
    }

    private void updateP2PTextStatus(final String status) {
        TextView p2pkitstatus = findViewById(R.id.textView9);
        p2pkitstatus.setText(status);
    }

    // Handles P2PKit's status callbacks (enable, disable, and error cases)
    // Tells if the package is actually properly loaded in before discoverying
    private final P2PKitStatusListener mStatusListener = new P2PKitStatusListener() {
        @Override
        public void onEnabled() {
            // ready to start discovery
            updateP2PTextStatus("True");
            toggleP2PKit.setClickable(false);
            toggleP2PKit.setText("P2PKit Already Enabled");
            detailedError.setText("");
            startDiscovery();
        }

        @Override
        public void onDisabled() {
            // p2pkit has been disabled
            Log.d("P2PKitStatusListener", "p2pkit disabled");
            updateP2PTextStatus("False");
            toggleP2PKit.setClickable(true);
            toggleP2PKit.setText("Enable P2PKit");
            if (P2PKit.isEnabled()) {
                stopDiscovery();
            }
        }

        @Override
        public void onError(StatusResult statusResult) {
            // an error occured, handle statusResult
            Log.d("P2PKitStatusListener", "Error on P2PKit!" + statusResult.toString());
            toggleP2PKit.setClickable(true);
            toggleP2PKit.setText("Enable P2PKit");
            updateP2PTextStatus("False");
        }

        @Override
        public void onException(Throwable throwable) {
            // an exception was thrown, reenable p2pkit
            Log.d("P2PKitStatusListener", "p2pkit threw an exception: " + Log.getStackTraceString(throwable));
            toggleP2PKit.setClickable(true);
            toggleP2PKit.setText("Enable P2PKit");
            updateP2PTextStatus("False");
        }
    };

    private void ResetListArr() {
        // Reset array and update with Set;
        ArrayAdapter adapter = new ArrayAdapter<String>(this, R.layout.list_item, test_list);
        ListView list = findViewById(R.id.main_list);
        list.setAdapter(adapter);

        test_list.clear();
        for(Peer iter: nearbyPeers) {
            String output = "UID: " + iter.getPeerId().toString() + " Strength: " + iter.getProximityStrength();
            Log.d("ResetListArr", output);
            test_list.add(output);
        }
    }

    // Handles discovery:
    private final DiscoveryListener mDiscoveryListener = new DiscoveryListener() {
        @Override
        public void onStateChanged(final int state) {
            Log.d("DiscoveryListener", "State changed: " + state);
            if(state != 0) {
                toggleP2PKit.setClickable(true);
                toggleP2PKit.setText("Enable P2PKit");
                if(state == DiscoveryListener.STATE_BLE_DISCOVERY_SUSPENDED || state == DiscoveryListener.STATE_BLE_DISCOVERY_UNSUPPORTED) {
                    updateP2PTextStatus("False");
                    disableP2PKit();
                }

                if(state == DiscoveryListener.STATE_BLE_DISCOVERY_UNSUPPORTED) {
                    detailedError.setText("BLE not supported!");
                }

                if(state == DiscoveryListener.STATE_BLE_DISCOVERY_SUSPENDED) {
                    detailedError.setText("BLE discovery was suspended");
                }
            }
        }

        @Override
        public void onPeerDiscovered(final Peer peer) {
            Log.d("DiscoveryListener", "Peer discovered: " + peer.getPeerId() + " with info: " + new String(peer.getDiscoveryInfo()));
            Log.d("DiscoveryListener", String.valueOf(peer.getProximityStrength()));
            if(peer.getProximityStrength() >= ProximityStrength.MEDIUM) {
                if (!nearbyPeers.contains(peer)) {
                    TextView test = findViewById(R.id.textView2);
                    total_num_peers += 1;
                    test.setText(String.valueOf(total_num_peers));

                    // Grab last updated:
                    TextView lastUpdate = findViewById(R.id.lastUpdatedText);
                    lastUpdate.setText(String.valueOf(lastUpdated.getTime()));

                }
                Log.d("DiscoveryListener", "Adding to nearbyPeers");
                nearbyPeers.add(peer);
                ResetListArr();
            } else {
                Log.d("DiscoveryListener", "Peer found but strength was not great so ignored!");
            }
        }

        @Override
        public void onPeerLost(final Peer peer) {
            Log.d("DiscoveryListener", "Peer lost: " + peer.getPeerId());
            nearbyPeers.remove(peer);
            ResetListArr();
        }

        @Override
        public void onPeerUpdatedDiscoveryInfo(Peer peer) {
            Log.d("DiscoveryListener", "Peer updated: " + peer.getPeerId() + " with new info: " + new String(peer.getDiscoveryInfo()));
            if(peer.getProximityStrength() < ProximityStrength.MEDIUM) {
                nearbyPeers.remove(peer);
                // Rest array:
                ResetListArr();
            } else {
                nearbyPeers.remove(peer);
                nearbyPeers.add(peer);
                ResetListArr();
            }
        }

        @Override
        public void onProximityStrengthChanged(Peer peer) {
            Log.d("DiscoveryListener", "Peer " + peer.getPeerId() + " changed proximity strength: " + peer.getProximityStrength());
            // When changed, check if peer is within proximity strength tolerance

            // Remove if too weak:
            // MEDIUM is just a guess:
            if(peer.getProximityStrength() < ProximityStrength.MEDIUM) {
                nearbyPeers.remove(peer);
                // Rest array:
                ResetListArr();
            } else {
                nearbyPeers.remove(peer);
                nearbyPeers.add(peer);
                ResetListArr();
            }
        }
    };


    // MAIN EXECUTION HAPPENS HERE:
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        TextView test = findViewById(R.id.textView2);
        test.setText(String.valueOf(total_num_peers));

        ArrayAdapter adapter = new ArrayAdapter<String>(this, R.layout.list_item, test_list);
        ListView list = findViewById(R.id.main_list);
        list.setAdapter(adapter);

        toggleP2PKit = findViewById(R.id.toggleStatus);
        toggleP2PKit.setText("Enable P2PKit");

        toggleP2PKit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                enableP2PKit();
            }
        });

        detailedError = findViewById(R.id.detailedStatusText);
        ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.BLUETOOTH}, 2);
        if(ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH) != PackageManager.PERMISSION_GRANTED) {
            Log.d("Permissions", "Bluetooth not allowed yet!");
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.BLUETOOTH}, 2);
        }

        if(ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_ADMIN) != PackageManager.PERMISSION_GRANTED) {
            Log.d("Permissions", "Bluetooth Admin not allowed yet!");
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.BLUETOOTH_ADMIN}, 3);
        }

        if(ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_PRIVILEGED) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.BLUETOOTH_PRIVILEGED}, 2);
        }
            enableP2PKit();
    }

    // MAIN EXECUTION EXITS HERE:
    @Override
    public void onDestroy() {
        disableP2PKit();
        super.onDestroy();
    }
}