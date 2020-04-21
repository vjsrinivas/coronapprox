package com.utk.coronapprox;

import androidx.appcompat.app.AppCompatActivity;
import android.util.Log;
import android.os.Bundle;

import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

import ch.uepaa.p2pkit.AlreadyEnabledException;
import ch.uepaa.p2pkit.P2PKit;
import ch.uepaa.p2pkit.P2PKitStatusListener;
import ch.uepaa.p2pkit.StatusResult;
import ch.uepaa.p2pkit.discovery.DiscoveryInfoTooLongException;
import ch.uepaa.p2pkit.discovery.DiscoveryInfoUpdatedTooOftenException;
import ch.uepaa.p2pkit.discovery.DiscoveryListener;
import ch.uepaa.p2pkit.discovery.DiscoveryPowerMode;
import ch.uepaa.p2pkit.discovery.Peer;
import ch.uepaa.p2pkit.discovery.ProximityStrength;

public class MainActivity extends AppCompatActivity {
    private static final String APP_KEY = "ccdae0d705cd4f2d83540bc5a0c0b766";
    private final Set<Peer> nearbyPeers = new HashSet<>();

    public void enableP2PKit() {
        try {
            Log.d("P2PKit", "Enabling p2pkit");
            P2PKit.enable(this, APP_KEY, mStatusListener);
        } catch (AlreadyEnabledException e) {
            Log.d("P2PKit", "p2pkit is already enabled " + e.getLocalizedMessage());
        }
    }

    public void disableP2PKit() {
        Log.d("P2PKit", "Disable p2pkit");

        if (P2PKit.isEnabled()) {
            P2PKit.disable();
            //teardownPeers();
        }
    }


    public void startDiscovery() {
        //byte[] ownDiscoveryData = loadOwnDiscoveryData();
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

    // Handles P2PKit's status callbacks (enable, disable, and error cases)
    // Tells if the package is actually properly loaded in before discoverying
    private final P2PKitStatusListener mStatusListener = new P2PKitStatusListener() {
        @Override
        public void onEnabled() {
            // ready to start discovery
            //UUID ownNodeId = P2PKit.getMyPeerId();
            //setupPeers(ownNodeId);
            startDiscovery();
        }

        @Override
        public void onDisabled() {
            // p2pkit has been disabled
            Log.d("P2PKitStatusListener", "p2pkit disabled");
            stopDiscovery();
        }

        @Override
        public void onError(StatusResult statusResult) {
            // an error occured, handle statusResult
            stopDiscovery();
        }

        @Override
        public void onException(Throwable throwable) {
            // an exception was thrown, reenable p2pkit
            //teardownPeers();
            Log.d("P2PKitStatusListener", "p2pkit threw an exception: " + Log.getStackTraceString(throwable));
        }
    };


    // Handles discovery:
    private final DiscoveryListener mDiscoveryListener = new DiscoveryListener() {
        @Override
        public void onStateChanged(final int state) {
            Log.d("DiscoveryListener", "State changed: " + state);
        }

        @Override
        public void onPeerDiscovered(final Peer peer) {
            Log.d("DiscoveryListener", "Peer discovered: " + peer.getPeerId() + " with info: " + new String(peer.getDiscoveryInfo()));
            nearbyPeers.add(peer);
            // Later for proximity:
            //handlePeerDiscovered(peer);
        }

        @Override
        public void onPeerLost(final Peer peer) {
            Log.d("DiscoveryListener", "Peer lost: " + peer.getPeerId());
        }

        @Override
        public void onPeerUpdatedDiscoveryInfo(Peer peer) {
            Log.d("DiscoveryListener", "Peer updated: " + peer.getPeerId() + " with new info: " + new String(peer.getDiscoveryInfo()));
        }

        @Override
        public void onProximityStrengthChanged(Peer peer) {
            Log.d("DiscoveryListener", "Peer " + peer.getPeerId() + " changed proximity strength: " + peer.getProximityStrength());
        }
    };


    // MAIN EXECUTION HAPPENS HERE:
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        enableP2PKit();
    }

    // MAIN EXECUTION EXITS HERE:
    @Override
    public void onDestroy() {
        disableP2PKit();
        super.onDestroy();
    }
}