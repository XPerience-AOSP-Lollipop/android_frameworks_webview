#
# Copyright (C) 2012 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This package provides the 'glue' layer between Chromium and WebView.

LOCAL_PATH := $(call my-dir)
CHROMIUM_PATH := external/chromium_org

# Prebuilt com.google.android.webview apk
include $(CLEAR_VARS)

LOCAL_MODULE := webview
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_MODULE_CLASS := APPS
LOCAL_CERTIFICATE := PRESIGNED

ifeq ($(TARGET_ARCH),arm64)
        LOCAL_SRC_FILES := prebuilt/arm64/webview.apk

        # Primary arch
        $(shell mkdir -p $(TARGET_OUT_SHARED_LIBRARIES))
        $(shell cp $(LOCAL_PATH)/prebuilt/arm64/lib/arm64-v8a/libwebviewchromium.so $(TARGET_OUT_SHARED_LIBRARIES))

        $(shell mkdir -p $(TARGET_OUT_APPS)/webview/lib/arm64)
        $(shell ln -sf ../../../../lib64/libwebviewchromium.so $(TARGET_OUT_APPS)/webview/lib/arm64/libwebviewchromium.so)
        ALL_DEFAULT_INSTALLED_MODULES += $(TARGET_OUT_APPS)/webview/lib/arm64/libwebviewchromium.so

        # Secondary arch
        $(shell mkdir -p $($(TARGET_2ND_ARCH_VAR_PREFIX)TARGET_OUT_SHARED_LIBRARIES))
        $(shell cp $(LOCAL_PATH)/prebuilt/arm64/lib/armeabi-v7a/libwebviewchromium.so $($(TARGET_2ND_ARCH_VAR_PREFIX)TARGET_OUT_SHARED_LIBRARIES))

        $(shell mkdir -p $(TARGET_OUT_APPS)/webview/lib/arm)
        $(shell ln -sf ../../../../lib/libwebviewchromium.so $(TARGET_OUT_APPS)/webview/lib/arm/libwebviewchromium.so)
        ALL_DEFAULT_INSTALLED_MODULES += $(TARGET_OUT_APPS)/webview/lib/arm/libwebviewchromium.so
else ifeq ($(TARGET_ARCH),arm)
        LOCAL_SRC_FILES := prebuilt/arm/webview.apk

        $(shell mkdir -p $(TARGET_OUT_SHARED_LIBRARIES))
        $(shell cp $(LOCAL_PATH)/prebuilt/arm/lib/armeabi-v7a/libwebviewchromium.so $(TARGET_OUT_SHARED_LIBRARIES))

        $(shell mkdir -p $(TARGET_OUT_APPS)/webview/lib/arm)
        $(shell ln -sf ../../../../lib/libwebviewchromium.so $(TARGET_OUT_APPS)/webview/lib/arm/libwebviewchromium.so)
        ALL_DEFAULT_INSTALLED_MODULES += $(TARGET_OUT_APPS)/webview/lib/arm/libwebviewchromium.so
else ifeq ($(TARGET_ARCH),x86)
        LOCAL_SRC_FILES := prebuilt/x86/webview.apk

        $(shell mkdir -p $(TARGET_OUT_SHARED_LIBRARIES))
        $(shell cp $(LOCAL_PATH)/prebuilt/x86/lib/x86/libwebviewchromium.so $(TARGET_OUT_SHARED_LIBRARIES))

        $(shell mkdir -p $(TARGET_OUT_APPS)/webview/lib/x86)
        $(shell ln -sf ../../../../lib/libwebviewchromium.so $(TARGET_OUT_APPS)/webview/lib/x86/libwebviewchromium.so)
        ALL_DEFAULT_INSTALLED_MODULES += $(TARGET_OUT_APPS)/webview/lib/x86/libwebviewchromium.so
else
        # Huh? You MIPS, bro?
        $(error Prebuilt WebView: unsupported architecture - $(TARGET_ARCH))
endif

include $(BUILD_PREBUILT)

# Native support library (libwebviewchromium_plat_support.so) - does NOT link
# any native chromium code.
include $(CLEAR_VARS)

LOCAL_MODULE:= libwebviewchromium_plat_support

LOCAL_SRC_FILES:= \
        plat_support/draw_gl_functor.cpp \
        plat_support/jni_entry_point.cpp \
        plat_support/graphics_utils.cpp \
        plat_support/graphic_buffer_impl.cpp \

LOCAL_C_INCLUDES:= \
        $(CHROMIUM_PATH) \
        external/skia/include/core \
        frameworks/base/core/jni/android/graphics \
        frameworks/native/include/ui \

LOCAL_SHARED_LIBRARIES += \
        libandroid_runtime \
        liblog \
        libcutils \
        libskia \
        libui \
        libutils \

LOCAL_MODULE_TAGS := optional

# To remove warnings from skia header files
LOCAL_CFLAGS := -Wno-unused-parameter

include $(BUILD_SHARED_LIBRARY)


# Loader library which handles address space reservation and relro sharing.
# Does NOT link any native chromium code.
include $(CLEAR_VARS)

LOCAL_MODULE:= libwebviewchromium_loader

LOCAL_SRC_FILES := \
        loader/loader.cpp \

LOCAL_CFLAGS := \
        -Werror \

LOCAL_SHARED_LIBRARIES += \
        libdl \
        liblog \

LOCAL_MODULE_TAGS := optional

include $(BUILD_SHARED_LIBRARY)

# Build other stuff
include $(call first-makefiles-under,$(LOCAL_PATH))
