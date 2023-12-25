#!/bin/bash
source ./scripts/coverity/userInfo.sh

TOOLCHAIN_PATH='/opt/m68k-ataritos/aout/bin/'
TOOLCHAIN_VER=9.3.1
CONFIG_NAME=release
CPU_ARCH=m68020-40
CPU_ARCH_NAME='020-40'

COV_PATH='./scripts/coverity/cov-analysis-win64/bin/'
DATESTAMP=`date +%d_%m_%Y`
GITHEAD=`git rev-parse HEAD`

# tool config (run once on coverity installation )
${COV_PATH}cov-configure --gcc --comptype gcc --compiler ${TOOLCHAIN_PATH}m68k-atari-mint-gcc-${TOOLCHAIN_VER}
${COV_PATH}cov-configure -co ${TOOLCHAIN_PATH}m68k-atari-mint-gcc-${TOOLCHAIN_VER}.exe -- -${CPU_ARCH} -std=c99 -fno-pic -fno-plt -ffast-math

echo Clean build..
rm -rf ./cov-int
scons --sconstruct=buildconfigs/SConstruct_${CPU_ARCH_NAME}_${CONFIG_NAME}.scons -c

echo Launching Coverity Scan
${COV_PATH}cov-build --dir cov-int bash -c "scons --sconstruct=buildconfigs/SConstruct_${CPU_ARCH_NAME}_${CONFIG_NAME}.scons"

FILENAME=amidilib_gcc_${TOOLCHAIN_VER}_${CPU_ARCH_NAME}_${CONFIG_NAME}_${DATESTAMP}_${GITHEAD}.tgz

echo Packing output archive
tar czvf ./${FILENAME} ./cov-int

echo Uploading to Coverity Scan file: ${FILENAME}
curl --form token=$coverityToken \
  --form email=$coverityEmail \
  --form file=@${FILENAME} \
  --form version=$GITHEAD \
  --form description="AMIDILIB atari tos gcc ${TOOLCHAIN_VER} ${CPU_ARCH_NAME} ${CONFIG_NAME}" \
  $coverityUrl