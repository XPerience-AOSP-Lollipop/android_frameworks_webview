#!/bin/bash

# Update prebuilt WebView library with com.google.android.webview apk
# This script will automatically detect different architectures
# Usage : ./extract.sh /path/to/com.google.android.webview.apk
#
# http://www.apkmirror.com/apk/google-inc/android-system-webview/

if ! apktool d -f -s "$@" 1>/dev/null; then
echo "Failed to extract with apktool!"
exit 1
fi
WEBVIEWDIR=$(\ls -d com.google.android.webview* || (echo "Input file is not a WebView apk!" ; exit 1))

if [ -e $WEBVIEWDIR/lib/arm64-v8a ]; then
ARCH="64-bit ARM"
ARCHDIR="arm64"
ARCHABI="arm64-v8a"
elif [ -e $WEBVIEWDIR/lib/armeabi-v7a ]; then
ARCH="32-bit ARM"
ARCHDIR="arm"
ARCHABI="armeabi-v7a"
elif [ -e $WEBVIEWDIR/lib/x86 ]; then
ARCH="x86"
ARCHDIR="x86"
ARCHABI="x86"
fi

WEBVIEWVERSION=$(cat $ARCHDIR/VERSION)
NEWWEBVIEWVERSION=$(cat $WEBVIEWDIR/apktool.yml | grep versionName | awk '{print $2}')
if [[ $NEWWEBVIEWVERSION != $WEBVIEWVERSION ]]; then
echo "$ARCH - Updating current WebView $WEBVIEWVERSION to $NEWWEBVIEWVERSION ..."
rm -rf $ARCHDIR
mkdir -p $ARCHDIR/lib
echo $NEWWEBVIEWVERSION > $ARCHDIR/VERSION
mv $WEBVIEWDIR/lib/* $ARCHDIR/lib/
rm -rf $WEBVIEWDIR
7z x -otmp "$@" 1>/dev/null
cd tmp
rm -rf lib
7z a -tzip -mx0 ../tmp.zip . 1>/dev/null
cd ..
rm -rf tmp
zipalign -v 4 tmp.zip $ARCHDIR/webview.apk 1>/dev/null
rm tmp.zip
else
echo "$ARCH - Input WebView apk is the same version as before."
echo "Not updating ..."
fi
rm -rf $WEBVIEWDIR
