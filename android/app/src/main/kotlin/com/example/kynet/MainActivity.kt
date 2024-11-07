package com.example.kynet


import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.os.Bundle
import android.telephony.*
import android.telephony.CellSignalStrengthNr
import android.widget.TextView
import org.json.JSONObject

class MainActivity: FlutterActivity() {
  private val CHANNEL = "com.example.methodchannel"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
      call, result ->


        // Get TelephonyManager instance
        val telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager

        // Initialize the main map to hold data
        val signalInfoMap = mutableMapOf<String, MutableMap<String, Any>>()

        // Fetch all available cell info
        if (telephonyManager.allCellInfo != null) {
            for (cellInfo in telephonyManager.allCellInfo) {
                when (cellInfo) {
                    is CellInfoGsm -> {
                        val gsmStrength: CellSignalStrengthGsm = cellInfo.cellSignalStrength
                        val gsmData = mutableMapOf<String, Any>()
                        val cellIdentity: CellIdentityGsm = cellInfo.cellIdentity
                        gsmData["rssi"] = gsmStrength.dbm
                        gsmData["asuLevel"] = gsmStrength.asuLevel
                        gsmData["level"] = gsmStrength.level
                        signalInfoMap["gsm"] = gsmData
                    }
                    is CellInfoCdma -> {
                        val cdmaStrength: CellSignalStrengthCdma = cellInfo.cellSignalStrength
                        val cdmaData = mutableMapOf<String, Any>()
                        val cellIdentity: CellIdentityCdma = cellInfo.cellIdentity
                        cdmaData["cdmaDbm"] = cdmaStrength.cdmaDbm
                        cdmaData["cdmaEcio"] = cdmaStrength.cdmaEcio
                        cdmaData["evdoDbm"] = cdmaStrength.evdoDbm
                        cdmaData["evdoEcio"] = cdmaStrength.evdoEcio
                        cdmaData["evdoSnr"] = cdmaStrength.evdoSnr
                        cdmaData["cdmaLevel"] = cdmaStrength.cdmaLevel
                        cdmaData["evdoLevel"] = cdmaStrength.evdoLevel
                        cdmaData["level"] = cdmaStrength.level
                        cdmaData["asuLevel"] = cdmaStrength.asuLevel
                        signalInfoMap["cdma"] = cdmaData
                    }
                    is CellInfoLte -> {
                        val lteStrength: CellSignalStrengthLte = cellInfo.cellSignalStrength
                        val cellIdentity: CellIdentityLte = cellInfo.cellIdentity
                        val lteData = mutableMapOf<String, Any>()
                        lteData["rsrp"] = lteStrength.dbm
                        lteData["bands"] = cellIdentity.getBands()[0];
                        lteData["rsrq"] = lteStrength.rsrq
                        lteData["rssnr"] = lteStrength.rssnr
                        lteData["asuLevel"] = lteStrength.getAsuLevel();
                        lteData["level"] = lteStrength.level
                        lteData["cqi"] = lteStrength.cqi
                        lteData["cqiTableIndex"] = lteStrength.cqiTableIndex
                        signalInfoMap["lte"] = lteData
                    }
                    is CellInfoNr -> {
                      val nrStrength: CellSignalStrengthNr =  cellInfo.cellSignalStrength as CellSignalStrengthNr;
                      val nrData = mutableMapOf<String, Any>()
                      val cellIdentity: CellIdentityNr = cellInfo.cellIdentity as CellIdentityNr
                      
                      nrData["ssRsrp"] = nrStrength.ssRsrp
                      nrData["ssRsrq"] = nrStrength.ssRsrq
                      nrData["ssSinr"] = nrStrength.ssSinr
                      nrData["dbm"] = nrStrength.dbm
                      nrData["level"] = nrStrength.level
                      nrData["csiRsrp"] = nrStrength.getCsiRsrp()
                      nrData["csiRsrq"] = nrStrength.getCsiRsrq()
                      nrData["csiSinr"] = nrStrength.getCsiSinr()
                      nrData["csiCqiReport"] = nrStrength.getCsiCqiReport()
                      nrData["csiCqiTableIndex"] = nrStrength.getCsiCqiTableIndex()
                      nrData["timingAdvanceMicros"] = nrStrength.getTimingAdvanceMicros()
                      nrData["bands"] = cellIdentity.getBands()[0];
                      signalInfoMap["nr"] = nrData
                    }
                }
            }

            // Convert the map structure to JSON for displaying
            val jsonResult = JSONObject(signalInfoMap as Map<*, *>).toString(2)

            print(jsonResult);

            result.success(signalInfoMap);

        } else {
          print("summ")
        }
     
    }
  }
}
