
# Build script for Arsenic Kernel
# By- Nimit Mehta (CheckYourScreen)

# For Time Calculation
BUILD_START=$(date +"%s")
echo "enter version name for zip name (only number) :" 
read VER
# Housekeeping
KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/arch/arm/boot/zImage-dtb
KERN_DTB=$KERNEL_DIR/arch/arm/boot/dt.img
OUT_DIR=$KERNEL_DIR/anykernel/
mkdir -p $KERNEL_DIR/anykernel/modules
MODULES_DIR=$KERNEL_DIR/anykernel/modules
STRIP="/home/nimit/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-strip"

blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

make clean && make mrproper
export ARCH=arm
export CROSS_COMPILE="/home/nimit/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"

compile_kernel ()
{
echo -e "**********************************************************************************************"
echo "                    "
echo "                              Compiling Arsenic.Kernel for OOS with GCC 4.9                  "
echo "                    "
echo -e "**********************************************************************************************"
make onyx_defconfig
make -j8
if ! [ -a $KERN_IMG ];
then
echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
# dtb  //No more seprate dtb for 3.x bootloader
strip_modules
zipping
}

dtb() {
tools_sk/dtbtool -o $KERN_DTB -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/

}

strip_modules ()
{
echo "Copying modules"
rm -rf $MODULES_DIR/*
find . -name '*.ko' -exec cp {} $MODULES_DIR/ \;
cd $MODULES_DIR
echo "Stripping modules for size"
$STRIP --strip-unneeded *.ko
# zip -9 modules * //dump integrity check for future use
cd $KERNEL_DIR
}

zipping() {
rm -rf $OUT_DIR/arsenic*.zip
rm -rf $OUT_DIR/zImage
rm -rf $OUT_DIR/dtb
cp $KERN_IMG $OUT_DIR/zImage
# cp $KERN_DTB $OUT_DIR/dtb   //farewell <3
cd $OUT_DIR
echo "is it a test build ..? (y/n) :"
read buildtype
if [ $buildtype == 'y' ]
then
echo "test build number?:"
read BN
zip -r arsenic.kernel-onyx_OOS.V$VER-test-$BN.zip *
else
zip -r arsenic.kernel-onyx_OOS.V$VER-$(date +"%Y%m%d").zip *
fi
}

compile_kernel
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
