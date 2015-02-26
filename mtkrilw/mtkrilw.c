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
#include <sys/socket.h>
#include <sys/un.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "ril.h"
#include "hardware/qemu_pipe.h"

#define LOG_TAG "RIL"
#include <utils/Log.h>

#define RIL_CMD_PROXY_5     RIL_CMD_4 
#define RIL_CMD_PROXY_1     RIL_CMD_3
#define RIL_CMD_PROXY_2     RIL_CMD_2
#define RIL_CMD_PROXY_3     RIL_CMD_1
#define RIL_CMD_PROXY_4     RIL_URC
#define RIL_CMD_PROXY_6     RIL_ATCI

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
    0,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
};

static RIL_RadioFunctions s_callbacks = {
    0,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
};

typedef struct {
    void (*OnRequestComplete)(RIL_Token t, RIL_Errno e,
                           void *response, size_t responselen);

    void (*OnUnsolicitedResponseMTK)(int unsolResponse, const void *data, size_t datalen, RILId id);

    void (*RequestTimedCallback) (RIL_TimedCallback callback,
                                   void *param, const struct timeval *relativeTime);
    void (*RequestProxyTimedCallback) (RIL_TimedCallback callback, void *param,
    					const struct timeval *relativeTime, int proxyId);

    RILChannelId (*QueryMyChannelId) (RIL_Token t);

    int (*QueryMyProxyIdByThread)();
} RIL_EnvMTK;

static RIL_EnvMTK s_rilenvmtk;

void (*OnUnsolicitedResponse)(int unsolResponse, const void *data, size_t datalen);

static void RIL_onUnsolicitedResponseMTK(int unsolResponse, const void *data, size_t datalen, RILId id)
{
    OnUnsolicitedResponse(unsolResponse, data, datalen);
}

RIL_RadioState onStateRequest()
{
  return s_callbacksmtk.onStateRequest(MTK_RIL_SOCKET_1, 0);
}

int android_register_control_socket(const char* name)
{
   int sfd;
   struct sockaddr_un my_addr;

   sfd = socket(AF_UNIX, SOCK_STREAM, 0);
   if (sfd == -1) {
        RLOGD("register control socket socket FAIL: %s\n", strerror(errno));
        return -1;
   }

   memset(&my_addr, 0, sizeof(struct sockaddr_un));
   my_addr.sun_family = AF_UNIX;
   strncpy(my_addr.sun_path, "/dev/radio/",
            sizeof(my_addr.sun_path) - 1);
   strncat(my_addr.sun_path, name,
            sizeof(my_addr.sun_path) - 1);

   if (bind(sfd, (struct sockaddr *) &my_addr,
            sizeof(struct sockaddr_un)) == -1) {
        RLOGD("register control socket bind FAIL %s: %s\n", my_addr.sun_path, strerror(errno));
        return -1;
   }

   return android_set_control_socket(name, sfd);
}

int android_set_control_socket(const char* name, int sfd)
{
   char key[64] = {0};
   char value[64] = {0};

   strncpy(key, ANDROID_SOCKET_ENV_PREFIX, sizeof(key) - 1);
   strncat(key, name, sizeof(key) - 1);

   snprintf(value, sizeof(value), "%d", sfd);

   if(setenv(key, value, 1) == -1) {
     RLOGD("register control socket FAIL %s %s: %s\n", key, value, strerror(errno));
     return -1;
   }

   return sfd;
}

const RIL_RadioFunctions *RIL_Init(const struct RIL_Env *env, int argc, char **argv)
{
    const RIL_RadioFunctionsMTK *funcs;

    void *dlHandle;
    void *dlHandle2;

    const RIL_RadioFunctionsMTK *(*rilInit)(const RIL_EnvMTK *, int, char **);
    void (*rilRegister)(const RIL_RadioFunctionsMTK *);

    const char *rilLibPath = "/system/lib/mtk-ril.so";
    const char *rilLibPath2 = "/system/lib/librilmtk.so";

    dlHandle = dlopen(rilLibPath, RTLD_NOW);
    if (dlHandle == NULL) {
        RLOGE("dlopen failed: %s", dlerror());
        exit(EXIT_FAILURE);
    }

    dlHandle2 = dlopen(rilLibPath2, RTLD_NOW);
    if (dlHandle2 == NULL) {
        RLOGE("dlopen failed: %s", dlerror());
        exit(EXIT_FAILURE);
    }

    OnUnsolicitedResponse = env->OnUnsolicitedResponse;

    rilInit = (const RIL_RadioFunctionsMTK *(*)(const RIL_EnvMTK *, int, char **))dlsym(dlHandle, "RIL_Init");
    if (rilInit == NULL) {
        RLOGE("RIL_Init not defined or exported in %s\n", rilLibPath);
        exit(EXIT_FAILURE);
    }

    rilRegister = (void (*)(const RIL_RadioFunctionsMTK *))dlsym(dlHandle2, "RIL_register");
    if (rilRegister == NULL) {
        RLOGE("RIL_register not defined or exported in %s\n", rilLibPath2);
        exit(EXIT_FAILURE);
    }

    memcpy(&s_rilenvmtk, env, sizeof(struct RIL_Env));

    // replace librilmtk calls
    s_rilenvmtk.OnRequestComplete = (void (*)(RIL_Token t, RIL_Errno e,void *response, size_t responselen))dlsym(dlHandle2, "RIL_onRequestComplete");
    s_rilenvmtk.OnUnsolicitedResponseMTK = (void (*)(int unsolResponse, const void *data, size_t datalen, RILId id))dlsym(dlHandle2, "RIL_onUnsolicitedResponse");
    s_rilenvmtk.RequestTimedCallback = (void(*)(RIL_TimedCallback callback,void *param, const struct timeval *relativeTime))dlsym(dlHandle2, "RIL_requestTimedCallback");

    // original librilmtk calls
    s_rilenvmtk.RequestProxyTimedCallback = (void (*) (RIL_TimedCallback callback, void *param,const struct timeval *relativeTime, int proxyId))dlsym(dlHandle2, "RIL_requestProxyTimedCallback");
    s_rilenvmtk.QueryMyChannelId = (RILChannelId (*)(RIL_Token ))dlsym(dlHandle2, "RIL_queryMyChannelId");
    s_rilenvmtk.QueryMyProxyIdByThread = (int (*)(void))dlsym(dlHandle2, "RIL_queryMyProxyIdByThread");

    // fake libril calls
    //s_rilenvmtk.OnUnsolicitedResponseMTK = &RIL_onUnsolicitedResponseMTK;

    funcs = rilInit(&s_rilenvmtk, argc, argv);

    memcpy(&s_callbacksmtk, funcs, sizeof(s_callbacksmtk));
    memcpy(&s_callbacks, funcs, sizeof(s_callbacks));

    s_callbacks.onStateRequest = onStateRequest;

    int rild = android_get_control_socket("rild");
    int rild2 = android_register_control_socket("rild2");

    android_set_control_socket("rild", rild2);
    android_set_control_socket("rild2", rild);

    android_register_control_socket("rild-atci");
    android_register_control_socket("rild-oem");
    android_register_control_socket("rild-mtk-ut");
    android_register_control_socket("rild-mtk-ut-2");
    android_register_control_socket("rild-mtk-modem");

    rilRegister(&s_callbacksmtk);

    // disable libril RIL_register call
    return NULL;

    //return &s_callbacks;
}

