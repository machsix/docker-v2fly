#!/bin/sh

# Set ARG
PLATFORM=$1
TAG=$2
if [ -z "$PLATFORM" ]; then
    ARCH="64"
else
    case "$PLATFORM" in
        linux/386)
            ARCH="32"
            ;;
        linux/amd64)
            ARCH="64"
            ;;
        linux/arm/v6)
            ARCH="arm32-v6"
            ;;
        linux/arm/v7)
            ARCH="arm32-v7a"
            ;;
        linux/arm64|linux/arm64/v8)
            ARCH="arm64-v8a"
            ;;
        *)
            ARCH=""
            ;;
    esac
fi
[ -z "${ARCH}" ] && echo "Error: Not supported OS Architecture" && exit 1

# Download files
V2RAY_FILE="v2ray-linux-${ARCH}.zip"
DGST_FILE="v2ray-linux-${ARCH}.zip.dgst"
echo "Downloading binary file: ${V2RAY_FILE}"
echo "Downloading binary file: ${DGST_FILE}"

curl -L -o ${PWD}/v2ray.zip https://github.com/v2fly/v2ray-core/releases/download/${TAG}/${V2RAY_FILE} > /dev/null 2>&1
curl -L -o ${PWD}/v2ray.zip.dgst https://github.com/v2fly/v2ray-core/releases/download/${TAG}/${DGST_FILE} > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Error: Failed to download binary file: ${V2RAY_FILE} ${DGST_FILE}" && exit 1
fi
echo "Download binary file: ${V2RAY_FILE} ${DGST_FILE} completed"

# Check SHA512
V2RAY_ZIP_HASH=$(sha512sum v2ray.zip | cut -f1 -d' ')
V2RAY_ZIP_DGST_HASH=$(cat v2ray.zip.dgst | grep -e 'SHA512' -e 'SHA2-512' | head -n1 | cut -f2 -d' ')

if [ "${V2RAY_ZIP_HASH}" = "${V2RAY_ZIP_DGST_HASH}" ]; then
    echo " Check passed" && rm -fv v2ray.zip.dgst
else
    echo "V2RAY_ZIP_HASH: ${V2RAY_ZIP_HASH}"
    echo "V2RAY_ZIP_DGST_HASH: ${V2RAY_ZIP_DGST_HASH}"
    echo " Check have not passed yet " && exit 1
fi

# Install
V2RAY_LOCATION_ASSETS="${V2RAY_LOCATION_ASSETS:-/usr/local/share/v2ray}"
V2RAY_LOCATION_CONFIG="${V2RAY_LOCATION_CONFIG:-/etc/v2ray}"
echo "Prepare to use"
unzip v2ray.zip
install -m 755 v2ray /usr/bin/v2ray
install -d "${V2RAY_LOCATION_ASSETS}"
install -d "${V2RAY_LOCATION_CONFIG}"
curl -L https://raw.githubusercontent.com/Loyalsoldier/geoip/release/geoip.dat  -o geoip.dat
install -m 644 geoip.dat geosite.dat "${V2RAY_LOCATION_ASSETS}"
install -m 644 vpoint_vmess_freedom.json "${V2RAY_LOCATION_CONFIG}/config.json"

# Clean
rm -rf ${PWD}/*
echo "Done"
