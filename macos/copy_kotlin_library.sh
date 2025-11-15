#!/bin/bash
set -e

# Script to copy Kotlin Native library and fix its install name for macOS distribution

echo "Copying Kotlin Native library..."

# Determine the build configuration (Debug or Release)
if [ "${CONFIGURATION}" == "Release" ]; then
    LIBRARY_PATH="${PROJECT_DIR}/../account_ledger_lib_kotlin_native/lib/build/bin/macosArm64/releaseShared/libaccount_ledger_lib.dylib"
else
    LIBRARY_PATH="${PROJECT_DIR}/../account_ledger_lib_kotlin_native/lib/build/bin/macosArm64/debugShared/libaccount_ledger_lib.dylib"
fi

# Create Frameworks directory if it doesn't exist
FRAMEWORKS_DIR="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
mkdir -p "${FRAMEWORKS_DIR}"

# Copy the library
if [ -f "${LIBRARY_PATH}" ]; then
    cp -f "${LIBRARY_PATH}" "${FRAMEWORKS_DIR}/libaccount_ledger_lib.dylib"
    echo "Copied library from ${LIBRARY_PATH}"
    
    # Fix the library's install name to use @rpath
    install_name_tool -id "@rpath/libaccount_ledger_lib.dylib" "${FRAMEWORKS_DIR}/libaccount_ledger_lib.dylib"
    echo "Updated library install name to use @rpath"
    
    # Code sign the library if required
    if [ -n "${EXPANDED_CODE_SIGN_IDENTITY}" ] && [ "${CODE_SIGNING_REQUIRED}" == "YES" ]; then
        codesign --force --sign "${EXPANDED_CODE_SIGN_IDENTITY}" --timestamp=none "${FRAMEWORKS_DIR}/libaccount_ledger_lib.dylib"
        echo "Code signed the library"
    fi
else
    echo "ERROR: Kotlin Native library not found at ${LIBRARY_PATH}"
    echo "Make sure to build the Kotlin Native library first using: ./gradlew linkReleaseSharedMacosArm64"
    exit 1
fi

echo "Kotlin Native library setup completed"
