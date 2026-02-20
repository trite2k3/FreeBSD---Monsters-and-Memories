#!/bin/sh

#export DXVK_HUD=memory,gpuload,api,version,fps
export WINEDEBUG=-all
#export DXVK_LOG_LEVEL=info
#export DXVK_LOG_PATH=$HOME/dxvk.log

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

export WINEPREFIX="$SCRIPT_DIR/prefix"
export PROTON_NO_ESYNC=1
export PULSE_LATENCY_MSEC=60

WINE=/usr/local/wine-proton/bin/wine
SYSDIR="${WINEPREFIX}/drive_c/windows/system32"
APPDIR="${WINEPREFIX}/drive_c/MnM"
LAUNCHER_EXE="${APPDIR}/MnMLauncher.exe"

# Initialize wine pfx
if [ ! -f "${WINEPREFIX}/.wineboot_done" ]; then
    echo "Initializing Wine prefix..."
    $WINE wineboot --init
    wineserver -w
    touch "${WINEPREFIX}/.wineboot_done"
fi

# winetricks
if [ ! -f "${WINEPREFIX}/.tricks_installed" ]; then
    echo "Installing winetricks components..."
    WINE=$WINE winetricks -q vcrun2022 corefonts
    touch "${WINEPREFIX}/.tricks_installed"
fi

# DXVK
if [ ! -f "${WINEPREFIX}/.dxvk_installed" ]; then
    echo "Installing DXVK..."
    DXVK_VERSION="2.4"
    curl -L "https://github.com/doitsujin/dxvk/releases/download/v${DXVK_VERSION}/dxvk-${DXVK_VERSION}.tar.gz" \
        -o "${SCRIPT_DIR}/dxvk.tar.gz"
    tar -xf "${SCRIPT_DIR}/dxvk.tar.gz" -C "${SCRIPT_DIR}"
    cp "${SCRIPT_DIR}/dxvk-${DXVK_VERSION}/x64/"*.dll "$SYSDIR/"
    WINE=$WINE WINEPREFIX=$WINEPREFIX $WINE reg add \
        "HKEY_CURRENT_USER\Software\Wine\DllOverrides" \
        /v d3d11 /t REG_SZ /d native /f
    WINE=$WINE WINEPREFIX=$WINEPREFIX $WINE reg add \
        "HKEY_CURRENT_USER\Software\Wine\DllOverrides" \
        /v dxgi /t REG_SZ /d native /f
    rm -rf "${SCRIPT_DIR}/dxvk.tar.gz" "${SCRIPT_DIR}/dxvk-${DXVK_VERSION}"
    touch "${WINEPREFIX}/.dxvk_installed"
fi

# ICU DLLs
if [ ! -f "${SYSDIR}/icuuc68.dll" ]; then
    echo "Fetching ICU DLLs..."
    curl -L "https://github.com/unicode-org/icu/releases/download/release-68-2/icu4c-68_2-Win64-MSVC2019.zip" \
        -o "${SCRIPT_DIR}/icu4c.zip"
    unzip -o "${SCRIPT_DIR}/icu4c.zip" -d "${SCRIPT_DIR}/icu_tmp"
    cp "${SCRIPT_DIR}/icu_tmp/bin64/icuuc68.dll" "$SYSDIR/"
    cp "${SCRIPT_DIR}/icu_tmp/bin64/icudt68.dll" "$SYSDIR/"
    cp "${SCRIPT_DIR}/icu_tmp/bin64/icuin68.dll" "$SYSDIR/"
    rm -rf "${SCRIPT_DIR}/icu4c.zip" "${SCRIPT_DIR}/icu_tmp"
fi

# Launcher
if [ ! -f "$LAUNCHER_EXE" ]; then
    echo "Fetching MnM Launcher..."
    mkdir -p "$APPDIR"
    curl -L "https://pub-f06cad9ebbcd412bb0f4ff64f0f6a3d7.r2.dev/launcher_v1/mnmlauncher.zip" \
        -o "${SCRIPT_DIR}/mnmlauncher.zip"
    unzip -o "${SCRIPT_DIR}/mnmlauncher.zip" -d "$APPDIR"
    rm -f "${SCRIPT_DIR}/mnmlauncher.zip"
fi

echo "Starting MnM Launcher..."
cd "$APPDIR"
$WINE "$LAUNCHER_EXE"
