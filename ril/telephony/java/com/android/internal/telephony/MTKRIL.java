/*
 * Copyright (c) 2012-2013, The Linux Foundation. All rights reserved.
 * Not a Contribution.
 *
 * Copyright (C) 2006 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.android.internal.telephony;

import static com.android.internal.telephony.RILConstants.*;
import static android.telephony.TelephonyManager.NETWORK_TYPE_UNKNOWN;
import static android.telephony.TelephonyManager.NETWORK_TYPE_EDGE;
import static android.telephony.TelephonyManager.NETWORK_TYPE_GPRS;
import static android.telephony.TelephonyManager.NETWORK_TYPE_UMTS;
import static android.telephony.TelephonyManager.NETWORK_TYPE_HSDPA;
import static android.telephony.TelephonyManager.NETWORK_TYPE_HSUPA;
import static android.telephony.TelephonyManager.NETWORK_TYPE_HSPA;
import static android.telephony.TelephonyManager.NETWORK_TYPE_HSPAP;
import static android.telephony.TelephonyManager.NETWORK_TYPE_DCHSPAP;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Resources;
import android.net.ConnectivityManager;
import android.net.LocalSocket;
import android.net.LocalSocketAddress;
import android.os.AsyncResult;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.os.Parcel;
import android.os.PowerManager;
import android.os.SystemProperties;
import android.os.PowerManager.WakeLock;
import android.provider.Settings.SettingNotFoundException;
import android.telephony.CellInfo;
import android.telephony.NeighboringCellInfo;
import android.telephony.PhoneNumberUtils;
import android.telephony.Rlog;
import android.telephony.SignalStrength;
import android.telephony.SmsManager;
import android.telephony.SmsMessage;
import android.text.TextUtils;
import android.util.SparseArray;

import com.android.internal.telephony.gsm.SmsBroadcastConfigInfo;
import com.android.internal.telephony.gsm.SsData;
import com.android.internal.telephony.gsm.SuppServiceNotification;
import com.android.internal.telephony.uicc.IccCardApplicationStatus;
import com.android.internal.telephony.uicc.IccCardStatus;
import com.android.internal.telephony.uicc.IccIoResult;
import com.android.internal.telephony.uicc.IccRefreshResponse;
import com.android.internal.telephony.uicc.IccUtils;
import com.android.internal.telephony.cdma.CdmaCallWaitingNotification;
import com.android.internal.telephony.cdma.CdmaInformationRecords;
import com.android.internal.telephony.cdma.CdmaSmsBroadcastConfigInfo;
import com.android.internal.telephony.dataconnection.DcFailCause;
import com.android.internal.telephony.dataconnection.DataCallResponse;
import com.android.internal.telephony.dataconnection.DataProfileOmh;
import com.android.internal.telephony.dataconnection.DataProfile;

import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.FileDescriptor;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.ArrayList;
import java.util.Collections;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.Random;

/**
 * RIL implementation of the CommandsInterface.
 *
 * {@hide}
 */
public class MTKRIL extends RIL {

    static final int RIL_REQUEST_MTK_BASE = 2000;
    static final int RIL_REQUEST_DUAL_SIM_MODE_SWITCH = (RIL_REQUEST_MTK_BASE + 12);
    static final int RIL_REQUEST_SET_FD_MODE = (RIL_REQUEST_MTK_BASE + 73);
    static final int RIL_REQUEST_GET_CALIBRATION_DATA = (RIL_REQUEST_MTK_BASE + 55);
    static final int RIL_68_REQUEST = 0x68;
    static final int RIL_REQUEST_QUERY_ICCID = (RIL_REQUEST_MTK_BASE + 29);

    static final int RIL_UNSOL_MTK_BASE = 3000;
    static final int RIL_UNSOL_CALL_PROGRESS_INFO = (RIL_UNSOL_MTK_BASE + 4);
    static final int RIL_UNSOL_INCOMING_CALL_INDICATION = (RIL_UNSOL_MTK_BASE + 14);
    static final int RIL_REQUEST_SET_CALL_INDICATION = (RIL_REQUEST_MTK_BASE + 36);

    public MTKRIL(Context context, int preferredNetworkType, int cdmaSubscription) {
        this(context, preferredNetworkType, cdmaSubscription, null);
    }

    public MTKRIL(Context context, int preferredNetworkType,
            int cdmaSubscription, Integer instanceId) {
        super(context, preferredNetworkType, cdmaSubscription, instanceId);

        mtk();
    }

    void mtk() {
        if (RILJ_LOGD) {
            riljLog("MTKRIL Class");
        }

        setRadioMode(2, null);
        setFDMode(0,0,0,null);
        getCalibrationData(null);
        get68Request(null);
        queryIccId(null);
    }

    public void
    setRadioMode(int mode, Message result) {
        RILRequest rr = RILRequest.obtain(RIL_REQUEST_DUAL_SIM_MODE_SWITCH,
                                        result);

        if (RILJ_LOGD) riljLog(rr.serialString() + "> " + requestToString(rr.mRequest));

        rr.mParcel.writeInt(1);
        rr.mParcel.writeInt(mode);

        send(rr);
    }

    public void
    setFDMode(int mode, int parameter1, int parameter2, Message response) {
	    RILRequest rr
		= RILRequest.obtain(RIL_REQUEST_SET_FD_MODE, response);

	    //AT+EFD=<mode>[,<param1>[,<param2>]]
	    //mode=0:disable modem Fast Dormancy; mode=1:enable modem Fast Dormancy
	    //mode=3:inform modem the screen status; parameter1: screen on or off
	    //mode=2:Fast Dormancy inactivity timer; parameter1:timer_id; parameter2:timer_value
	    if (RILJ_LOGD) riljLog(rr.serialString() + "> " + requestToString(rr.mRequest));

	    if (mode == 0 || mode == 1) {
		rr.mParcel.writeInt(1);
		rr.mParcel.writeInt(mode);
	    } else if (mode == 3) {
		rr.mParcel.writeInt(2);
		rr.mParcel.writeInt(mode);
		rr.mParcel.writeInt(parameter1);			
	    } else if (mode == 2) {
		rr.mParcel.writeInt(3);
		rr.mParcel.writeInt(mode);
		rr.mParcel.writeInt(parameter1);
		rr.mParcel.writeInt(parameter2);
	    }
	    send(rr);    
    }

    public void getCalibrationData(Message result) {
        RILRequest rr = RILRequest.obtain(RIL_REQUEST_GET_CALIBRATION_DATA, result);

        if (RILJ_LOGD) riljLog(rr.serialString() + "> :::" + requestToString(rr.mRequest));

        send(rr);
    }

    public void get68Request(Message result) {
        RILRequest rr = RILRequest.obtain(RIL_68_REQUEST, result);

        if (RILJ_LOGD) riljLog(rr.serialString() + "> :::" + requestToString(rr.mRequest));

        rr.mParcel.writeInt(1);
        rr.mParcel.writeInt(1);

        send(rr);
    }

    public void queryIccId(Message result){
        RILRequest rr = RILRequest.obtain(RIL_REQUEST_QUERY_ICCID, result);

        if (RILJ_LOGD) riljLog(rr.serialString() + "> " + requestToString(rr.mRequest));

        send(rr);   
    }

    @Override
    protected void
    processUnsolicited (Parcel p) {
        int response;
        Object ret;

        int pos = p.dataPosition();

        response = p.readInt();

        switch(response) {
            case RIL_UNSOL_CALL_PROGRESS_INFO: ret = responseStrings(p); break;
            case RIL_UNSOL_INCOMING_CALL_INDICATION: ret = responseStrings(p); break;
           default:
            p.setDataPosition(pos);
            super.processUnsolicited(p);
            return;
        }
        switch(response) {
            case RIL_UNSOL_CALL_PROGRESS_INFO:
                if (RILJ_LOGD) unsljLog(response);

                mCallStateRegistrants
                    .notifyRegistrants(new AsyncResult(null, null, null));
                break;
            case RIL_UNSOL_INCOMING_CALL_INDICATION: {
                if (RILJ_LOGD) unsljLog(response);

		AsyncResult ar = new AsyncResult(null, ret, null);
		String[] incomingCallInfo = (String[]) ar.result;
		int callId = Integer.parseInt(incomingCallInfo[0]);
		int callMode = Integer.parseInt(incomingCallInfo[3]);
		int seqNumber = Integer.parseInt(incomingCallInfo[4]);

                setCallIndication(callMode, callId, seqNumber, null);

                mCallStateRegistrants
                    .notifyRegistrants(ar);
                break;
	    }
        }
    }

    public void setCallIndication(int mode, int callId, int seqNumber, Message result) {
        RILRequest rr
                = RILRequest.obtain(RIL_REQUEST_SET_CALL_INDICATION, result);

        rr.mParcel.writeInt(3);
        rr.mParcel.writeInt(mode);
        rr.mParcel.writeInt(callId);
        rr.mParcel.writeInt(seqNumber);

        if (RILJ_LOGD) riljLog(rr.serialString() + "> " + requestToString(rr.mRequest)
                + " " + mode + ", " + callId + ", " + seqNumber);

        send(rr);
    }

}
