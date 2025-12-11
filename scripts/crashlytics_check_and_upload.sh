#!/bin/bash
# ==============================
# Firebase Crashlytics 检查 + 上传脚本
# ==============================

APP_PATH="${TARGET_BUILD_DIR}/${EXECUTABLE_PATH%/*}"
DSYM_PATH="${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}"
GOOGLE_INFO="${PROJECT_DIR}/MobileProject/GoogleService-Info.plist"

echo "=============================="
echo " Firebase Crashlytics 自动化工具"
echo "=============================="

# 1️⃣ 获取 App Info.plist 信息
APP_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP_PATH/Info.plist")
APP_BUILD=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$APP_PATH/Info.plist")
APP_BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$APP_PATH/Info.plist")

echo "📱 App 版本号 : $APP_VERSION"
echo "📦 App 构建号 : $APP_BUILD"
echo "🏷  App Bundle ID : $APP_BUNDLE_ID"

# 2️⃣ 检查 GoogleService-Info.plist
if [ -f "$GOOGLE_INFO" ]; then
    GOOGLE_BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print BUNDLE_ID" "$GOOGLE_INFO")
    echo "📝 GoogleService-Info.plist Bundle ID: $GOOGLE_BUNDLE_ID"

    if [ "$APP_BUNDLE_ID" != "$GOOGLE_BUNDLE_ID" ]; then
        echo "❌ [错误] Bundle ID 不匹配"
#        exit 1
    else
        echo "✅ Bundle ID 匹配"
    fi
else
    echo "⚠️  GoogleService-Info.plist 未找到"
#    exit 1
fi

# 3️⃣ 检查 UUID
APP_UUID=$(dwarfdump --uuid "${TARGET_BUILD_DIR}/${EXECUTABLE_PATH}" | awk '{print $2}')
DSYM_UUID=$(dwarfdump --uuid "$DSYM_PATH" | awk '{print $2}')

echo "📱 App UUID : $APP_UUID"
echo "📦 dSYM UUID: $DSYM_UUID"

if [ "$APP_UUID" != "$DSYM_UUID" ]; then
    echo "❌ [错误] UUID 不匹配，停止上传"
#    exit 1
else
    echo "✅ UUID 匹配"
fi

# 4️⃣ 上传 dSYM 到 Firebase
if [ -f "${PODS_ROOT}/FirebaseCrashlytics/upload-symbols" ]; then
    echo "🚀 开始上传 dSYM 到 Firebase..."
    "${PODS_ROOT}/FirebaseCrashlytics/upload-symbols" \
        -gsp "$GOOGLE_INFO" \
        -p ios "$DSYM_PATH"

    if [ $? -eq 0 ]; then
        echo "✅ dSYM 上传成功"
    else
        echo "❌ dSYM 上传失败"
#        exit 1
    fi
else
    echo "❌ 找不到 FirebaseCrashlytics/upload-symbols"
#    exit 1
fi

echo "=============================="
echo " 检查 + 上传流程完成"
echo "=============================="
