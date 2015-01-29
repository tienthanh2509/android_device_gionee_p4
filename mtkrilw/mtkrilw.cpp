/* //device/system/reference-ril/reference-ril.c
**
** Copyright (c) 2012-2013, The Linux Foundation. All rights reserved.
** Not a Contribution
** Copyright 2006 The Android Open Source Project
**
** Licensed under the Apache License, Version 2.0 (the "License");
** you may not use this file except in compliance with the License.
** You may obtain a copy of the License at
**
**     http://www.apache.org/licenses/LICENSE-2.0
**
** Unless required by applicable law or agreed to in writing, software
** distributed under the License is distributed on an "AS IS" BASIS,
** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
** See the License for the specific language governing permissions and
** limitations under the License.
*/

#include <telephony/ril_cdma_sms.h>
#include <telephony/librilutils.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <pthread.h>
#include <alloca.h>
#include <getopt.h>
#include <sys/socket.h>
#include <cutils/sockets.h>
#include <termios.h>
#include <sys/system_properties.h>
#include <stdio.h>
#include <dlfcn.h>

#include "ril.h"
#include "hardware/qemu_pipe.h"

#define LOG_TAG "RIL"
#include <utils/Log.h>

typedef enum {
    MTK_RIL_SOCKET_1,
    MTK_RIL_SOCKET_2,
    MTK_RIL_SOCKET_3,
    MTK_RIL_SOCKET_4,
    MTK_RIL_SOCKET_NUM
} RILId;

typedef enum {
    RIL_URC,
    RIL_CMD_1,
    RIL_CMD_2,
    RIL_CMD_3,
    RIL_CMD_4, /* ALPS00324111 split data and nw command channel */
    RIL_PPPDATA = RIL_CMD_4,
    RIL_ATCI,
    RIL_SUPPORT_CHANNELS
} RILChannelId;

typedef RIL_RadioState (*RIL_RadioStateRequestMTK)(RILId rid, int *sim_status);

typedef struct {
    int version;        /* set to RIL_VERSION */
    RIL_RequestFunc onRequest;
    RIL_RadioStateRequestMTK onStateRequest;
    RIL_Supports supports;
    RIL_Cancel onCancel;
    RIL_GetVersion getVersion;
} RIL_RadioFunctionsMTK;

static RIL_RadioFunctionsMTK s_callbacksmtk = {
    RIL_VERSION,
    0,
    0,
    0,
    0,
    0
};

static RIL_RadioFunctions s_callbacks = {
    RIL_VERSION,
    0,
    0,
    0,
    0,
    0
};

struct RIL_EnvMTK {
    void (*OnRequestComplete)(RIL_Token t, RIL_Errno e,
                           void *response, size_t responselen);

    void (*OnUnsolicitedResponseMTK)(int unsolResponse, const void *data, size_t datalen, RILId id);

    void (*RequestTimedCallback) (RIL_TimedCallback callback,
                                   void *param, const struct timeval *relativeTime);
    void (*RequestProxyTimedCallback) (RIL_TimedCallback callback, void *param,
    					const struct timeval *relativeTime, int proxyId);

    RILChannelId (*QueryMyChannelId) (RIL_Token t);

    int (*QueryMyProxyIdByThread)();
};

static RIL_EnvMTK s_rilenvmtk;

void (*OnUnsolicitedResponse)(int unsolResponse, const void *data, size_t datalen);

static void RIL_onUnsolicitedResponseMTK(int unsolResponse, const void *data, size_t datalen, RILId id)
{
    OnUnsolicitedResponse(unsolResponse, data, datalen);
}

RILChannelId QueryMyChannelId (RIL_Token t)
{
   return RIL_URC;
}

int QueryMyProxyIdByThread()
{
   return 0;
}

RIL_RadioState onStateRequest()
{
  return s_callbacksmtk.onStateRequest(MTK_RIL_SOCKET_1, 0);
}

const RIL_RadioFunctions *RIL_Init(const struct RIL_Env *env, int argc, char **argv)
{
    const RIL_RadioFunctionsMTK *funcs;
    void *dlHandle;
    const RIL_RadioFunctionsMTK *(*rilInit)(const struct RIL_EnvMTK *, int, char **);
    const char *rilLibPath = "/system/lib/mtk-ril.so";

    dlHandle = dlopen(rilLibPath, RTLD_NOW);

    if (dlHandle == NULL) {
        RLOGE("dlopen failed: %s", dlerror());
        exit(EXIT_FAILURE);
    }

    OnUnsolicitedResponse = env->OnUnsolicitedResponse;

    memcpy(&s_rilenvmtk, env, sizeof(RIL_Env));
    s_rilenvmtk.QueryMyChannelId = QueryMyChannelId;
    s_rilenvmtk.QueryMyProxyIdByThread = QueryMyProxyIdByThread;
    s_rilenvmtk.OnUnsolicitedResponseMTK = &RIL_onUnsolicitedResponseMTK;

    rilInit = (const RIL_RadioFunctionsMTK *(*)(const struct RIL_EnvMTK *, int, char **))dlsym(dlHandle, "RIL_Init");

    if (rilInit == NULL) {
        RLOGE("RIL_Init not defined or exported in %s\n", rilLibPath);
        exit(EXIT_FAILURE);
    }

    funcs = rilInit(&s_rilenvmtk, argc, argv);

    memcpy(&s_callbacksmtk, funcs, sizeof(s_callbacksmtk));
    memcpy(&s_callbacks, funcs, sizeof(s_callbacks));

    s_callbacks.onStateRequest = onStateRequest;

    return &s_callbacks;
}

