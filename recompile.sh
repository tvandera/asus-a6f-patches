#! /bin/sh

set -x

KVER=$(uname -r)
KBASE=$(echo $KVER | sed 's/\([0-9]*\.[0-9]*\.[0-9]*\).*/\1/')
KPKG=$(dpkg-query -f='${Version}' -W linux-image | tail -n 1)

rm -rf linux*
apt-get source linux-image-`uname -r`
cd linux-${KBASE}
cp /boot/config-${KVER} .config
cp /usr/src/linux-headers-${KVER}/Module.symvers .
make oldconfig
make prepare
make modules_prepare

# i915
patch -p0 drivers/gpu/drm/i915/intel_bios.c <../i915_paneltype.patch
make modules M=drivers/gpu/drm/i915
strip -g drivers/gpu/drm/i915/i915.ko
sudo cp drivers/gpu/drm/i915/i915.ko /lib/modules/${KVER}/kernel/drivers/gpu/drm/i915/i915.ko

# m5602
patch -p0 drivers/media/video/gspca/m5602/m5602_ov9650.c <../m5602_ov9650_flip.patch
make modules M=drivers/media/video/gspca/m5602
strip -g drivers/media/video/gspca/m5602/gspca_m5602.ko
sudo cp drivers/media/video/gspca/m5602/gspca_m5602.ko /lib/modules/${KVER}/kernel/drivers/media/video/gspca/m5602/gspca_m5602.ko

sudo update-initramfs -u

