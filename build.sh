#!/bin/env bash
clear

echo "##### Setting Global Variables #####"

kernel_dir="${PWD}"
objdir="${kernel_dir}/out"
anykernel="${HOME}/anykernel"
kernel_name="phoeniX-Kernel" # Your kernel name
zip_name="${kernel_name}-$(date +"%Y%m%d-%H%M")-signed.zip" # Your kernel suffix name after compilation is complete

echo "##### Export Path and Environment Variables #####"

export CONFIG_FILE="vendor/kona-perf_defconfig" # Your device_defconfig please edit it
export ARCH="arm64" # Your device structure
export SUBARCH="arm64"
export CC="clang"
export LLVM="1"
export LLVM_IAS="1"
export CLANG_TRIPLE="aarch64-linux-gnu-"
export CROSS_COMPILE="aarch64-linux-gnu-"
export CROSS_COMPILE_ARM32="arm-linux-gnueabi-"
export LD="aarch64-linux-gnu-ld"
export KBUILD_BUILD_HOST=TermuxUbuntuProot # Your hos name
export KBUILD_BUILD_USER=Lixin # Your name

echo "##### Setting Parallel Jobs #####"
NPROC=$(nproc --all) # Use all cpu threads, reduce value if compile fails
echo "##### ${NPROC} Parallel Jobs #####"

echo "##### Generating Defconfig ######"
make ARCH="${ARCH}" O="${objdir}" "${CONFIG_FILE}" -j"${NPROC}"

if [[ $? -eq 0 ]]; then
  echo "##### Defconfig Generated Successfully #####"
else
  echo "##### Defconfig Generation Failed #####"
  exit 1
fi

echo "##### Starting Kernel Build #####"

make -j"${NPROC}" \
    O="${objdir}" \
    ARCH="${ARCH}" \
    LLVM="${LLVM}" \
    LLVM_IAS="${LLVM_IAS}" \
    CLANG_TRIPLE="${CLANG_TRIPLE}" \
    CROSS_COMPILE="${CROSS_COMPILE}" \
    CROSS_COMPILE_ARM32="${CROSS_COMPILE_ARM32}" \
    LD="${LD}" \
    2>&1 | tee build.log

if [[ $? -eq 0 ]]; then
  echo "##### Kernel Build Successfully #####"
else
  echo "##### Kernel Build Failed! Check build.log for errors #####"
  exit 1
fi

zipping() {
echo "Zipping kernel..."

COMPILED_IMAGE="${objdir}/arch/arm64/boot/Image"
COMPILED_DTBO="${objdir}/arch/arm64/boot/dtbo.img"
COMPILED_DTB="${objdir}/arch/arm64/boot/dtb"

if [[ ! -f "${COMPILED_IMAGE}" ]]; then
    echo "##### Error: Compiled Image not found at ${COMPILED_IMAGE} #####"
    exit 1
fi

if [[ ! -f "${COMPILED_DTBO}" ]]; then
    echo "##### Error: Compiled dtbo.img not found at ${COMPILED_DTBO} #####"
    exit 1
fi

if [ ! -d "${anykernel}" ]; then
  echo "##### Cloning Anykernel3 #####"
  git clone -q https://github.com/AndroidGeeksYT/AnyKernel3.git "${anykernel}"
  if [[ $? -ne 0 ]]; then
    echo "##### Failed to Clone Anykernel3 #####"
    exit 1
  fi
else
  echo "##### Anykernel3 already exists, updating #####"
  cd "${anykernel}" && git pull -q && cd "${kernel_dir}"
fi

echo "##### Moving Image, dtbo.img, and dtb to AnyKernel directory #####"
mv -f "${COMPILED_IMAGE}" "${anykernel}/"
mv -f "${COMPILED_DTBO}" "${anykernel}/"
mv -f "${COMPILED_DTB}" "${anykernel}/"

cd "${anykernel}" || exit 1

echo "##### Removing Existing Zip Files in AnyKernel Directory #####"
find . -maxdepth 1 -name "*.zip" -type f -delete

echo "##### Creating AnyKernel.zip #####"
zip -r AnyKernel.zip ./*

# Download zipsigner (if not already)
ZIPSIGNER_JAR="${HOME}/zipsigner-3.0.jar"
if [ ! -f "${ZIPSIGNER_JAR}" ]; then
  echo "##### Downloading Zipsigner #####"
  curl -sLo "${ZIPSIGNER_JAR}" https://github.com/Magisk-Modules-Repo/zipsigner/raw/master/bin/zipsigner-3.0-dexed.jar
fi

echo "##### Signing Zip File #####"
java -jar "${ZIPSIGNER_JAR}" AnyKernel.zip AnyKernel-signed.zip

if [[ $? -eq 0 ]]; then
  echo "##### Zip Signed Successfully #####"
else
  echo "##### Signing Failed #####"
  exit 1
fi

echo "########### Renaming and Moving Final Signed Zip ###########"
mv AnyKernel-signed.zip "${zip_name}"
mv "${zip_name}" "${HOME}/${zip_name}"

echo "Kernel packaged and signed successfully! Final ZIP: ${HOME}/${zip_name}"

echo "##### Cleaning Up AnyKernel Repository #####"
rm -rf "${anykernel}"

echo "##### All Done! #####"
}

zipping

