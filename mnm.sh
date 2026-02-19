#!/bin/sh

#export DXVK_HUD=memory,gpuload,api,version,fps
export WINEDEBUG=-all

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

export WINEPREFIX="$SCRIPT_DIR"
export PROTON_NO_ESYNC=1
export PULSE_LATENCY_MSEC=60

SYSDIR="${WINEPREFIX}/drive_c/windows/system32"
LAUNCHER_EXE="${WINEPREFIX}/MnMLauncher.exe"

# winetricks
if [ ! -f "${WINEPREFIX}/.tricks_installed" ]; then
    WINE=/usr/local/wine-proton/bin/wine winetricks vcrun2022 corefonts
    touch "${WINEPREFIX}/.tricks_installed"
fi

# ICU DLLs
if [ ! -f "${SYSDIR}/icuuc68.dll" ]; then
    fetch "https://github.com/unicode-org/icu/releases/download/release-68-2/icu4c-68_2-Win64-MSVC2019.zip" -o "${SCRIPT_DIR}/icu4c.zip"
    unzip -o "${SCRIPT_DIR}/icu4c.zip" -d "${SCRIPT_DIR}/icu_tmp"
    cp "${SCRIPT_DIR}/icu_tmp/bin64/icuuc68.dll" "$SYSDIR/"
    cp "${SCRIPT_DIR}/icu_tmp/bin64/icudt68.dll" "$SYSDIR/"
    cp "${SCRIPT_DIR}/icu_tmp/bin64/icuin68.dll" "$SYSDIR/"
    rm -rf "${SCRIPT_DIR}/icu4c.zip" "${SCRIPT_DIR}/icu_tmp"
fi

# Launcher
if [ ! -f "$LAUNCHER_EXE" ]; then
    fetch "https://pub-f06cad9ebbcd412bb0f4ff64f0f6a3d7.r2.dev/launcher_v1/mnmlauncher.zip" -o "${SCRIPT_DIR}/mnmlauncher.zip"
    unzip -o "${SCRIPT_DIR}/mnmlauncher.zip" -d "${WINEPREFIX}"
    rm -f "${SCRIPT_DIR}/mnmlauncher.zip"
fi

/usr/local/wine-proton/bin/wine "$LAUNCHER_EXE"
