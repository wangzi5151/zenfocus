#!/usr/bin/env bash
set -e

MF=android/app/src/main/AndroidManifest.xml

grep -q "POST_NOTIFICATIONS" "$MF" || sed -i 's#</manifest>#    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>\n    <uses-permission android:name="android.permission.VIBRATE"/>\n</manifest>#' "$MF"

sed -i 's/android:label="zenfocus"/android:label="ZenFocus"/' "$MF"

echo "manifest patched"
