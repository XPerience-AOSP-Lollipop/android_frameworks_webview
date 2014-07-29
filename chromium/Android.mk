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

# Don't include most modules if the product is using a prebuilt webviewchromium.
ifneq ($(PRODUCT_PREBUILT_WEBVIEWCHROMIUM),yes)

# Java glue layer JAR, calls directly into the chromium AwContents Java API.
include $(CLEAR_VARS)

LOCAL_PACKAGE_NAME := webviewchromium

LOCAL_MANIFEST_FILE := AndroidManifest.xml

LOCAL_PRIVILEGED_MODULE := true

LOCAL_MODULE_TAGS := optional

LOCAL_STATIC_JAVA_LIBRARIES += android_webview_java_with_new_resources

LOCAL_SRC_FILES := $(call all-java-files-under, java)

LOCAL_JARJAR_RULES := $(CHROMIUM_PATH)/android_webview/build/jarjar-rules.txt

include $(CHROMIUM_PATH)/android_webview/build/resources_config.mk
LOCAL_RESOURCE_DIR := \
    $(LOCAL_PATH)/res \
    $(android_webview_resources_dirs)
LOCAL_AAPT_FLAGS := $(android_webview_aapt_flags)
LOCAL_AAPT_FLAGS += --extra-packages com.android.webview.chromium
LOCAL_AAPT_FLAGS += --shared-lib

LOCAL_JNI_SHARED_LIBRARIES += libwebviewchromium

LOCAL_MULTILIB := both

# TODO: filter webviewchromium_webkit_strings based on PRODUCT_LOCALES.
LOCAL_REQUIRED_MODULES := \
        libwebviewchromium \
        libwebviewchromium_loader \
        libwebviewchromium_plat_support \
        webviewchromium_pak \
        webviewchromium_webkit_strings_am.pak \
        webviewchromium_webkit_strings_ar.pak \
        webviewchromium_webkit_strings_bg.pak \
        webviewchromium_webkit_strings_bn.pak \
        webviewchromium_webkit_strings_ca.pak \
        webviewchromium_webkit_strings_cs.pak \
        webviewchromium_webkit_strings_da.pak \
        webviewchromium_webkit_strings_de.pak \
        webviewchromium_webkit_strings_el.pak \
        webviewchromium_webkit_strings_en-GB.pak \
        webviewchromium_webkit_strings_en-US.pak \
        webviewchromium_webkit_strings_es-419.pak \
        webviewchromium_webkit_strings_es.pak \
        webviewchromium_webkit_strings_et.pak \
        webviewchromium_webkit_strings_fa.pak \
        webviewchromium_webkit_strings_fil.pak \
        webviewchromium_webkit_strings_fi.pak \
        webviewchromium_webkit_strings_fr.pak \
        webviewchromium_webkit_strings_gu.pak \
        webviewchromium_webkit_strings_he.pak \
        webviewchromium_webkit_strings_hi.pak \
        webviewchromium_webkit_strings_hr.pak \
        webviewchromium_webkit_strings_hu.pak \
        webviewchromium_webkit_strings_id.pak \
        webviewchromium_webkit_strings_it.pak \
        webviewchromium_webkit_strings_ja.pak \
        webviewchromium_webkit_strings_kn.pak \
        webviewchromium_webkit_strings_ko.pak \
        webviewchromium_webkit_strings_lt.pak \
        webviewchromium_webkit_strings_lv.pak \
        webviewchromium_webkit_strings_ml.pak \
        webviewchromium_webkit_strings_mr.pak \
        webviewchromium_webkit_strings_ms.pak \
        webviewchromium_webkit_strings_nb.pak \
        webviewchromium_webkit_strings_nl.pak \
        webviewchromium_webkit_strings_pl.pak \
        webviewchromium_webkit_strings_pt-BR.pak \
        webviewchromium_webkit_strings_pt-PT.pak \
        webviewchromium_webkit_strings_ro.pak \
        webviewchromium_webkit_strings_ru.pak \
        webviewchromium_webkit_strings_sk.pak \
        webviewchromium_webkit_strings_sl.pak \
        webviewchromium_webkit_strings_sr.pak \
        webviewchromium_webkit_strings_sv.pak \
        webviewchromium_webkit_strings_sw.pak \
        webviewchromium_webkit_strings_ta.pak \
        webviewchromium_webkit_strings_te.pak \
        webviewchromium_webkit_strings_th.pak \
        webviewchromium_webkit_strings_tr.pak \
        webviewchromium_webkit_strings_uk.pak \
        webviewchromium_webkit_strings_vi.pak \
        webviewchromium_webkit_strings_zh-CN.pak \
        webviewchromium_webkit_strings_zh-TW.pak

LOCAL_PROGUARD_ENABLED := full
LOCAL_PROGUARD_FLAG_FILES := proguard.flags

LOCAL_JAVACFLAGS := -Xlint:unchecked -Werror

include $(BUILD_PACKAGE)

ifneq ($(strip $(LOCAL_JARJAR_RULES)),)
# Add build rules to check that the jarjar'ed jar only contains whitelisted
# packages. Only enable this when we are running jarjar.
LOCAL_JAR_CHECK_WHITELIST := $(LOCAL_PATH)/jar_package_whitelist.txt

jar_check_ok := $(intermediates.COMMON)/jar_check_ok
$(jar_check_ok): PRIVATE_JAR_CHECK := $(LOCAL_PATH)/tools/jar_check.py
$(jar_check_ok): PRIVATE_JAR_CHECK_WHITELIST := $(LOCAL_JAR_CHECK_WHITELIST)
$(jar_check_ok): $(full_classes_jarjar_jar) $(LOCAL_PATH)/tools/jar_check.py $(LOCAL_JAR_CHECK_WHITELIST)
	@echo Jar check: $@
	$(hide) $(PRIVATE_JAR_CHECK) $< $(PRIVATE_JAR_CHECK_WHITELIST)
	$(hide) touch $@

$(LOCAL_BUILT_MODULE): $(jar_check_ok)
endif

endif # PRODUCT_PREBUILT_WEBVIEWCHROMIUM

# Native support library (libwebviewchromium_plat_support.so) - does NOT link
# any native chromium code. This is built from source even if the product has
# a prebuilt webviewchromium to ensure ABI compatibility.
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
