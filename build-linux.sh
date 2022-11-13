#!/bin/sh

# This script assembles the LAJOS bootloader, kernel and programs
# with NASM, and then creates floppy and CD images (on Linux)



if test "`whoami`" != "root" ; then
	echo "You must be logged in as root to build (for loopback mounting)"
	echo "Enter 'su' or 'sudo bash' to switch to root"
	exit
fi


if [ ! -e disk_images/lajos.flp ]
then
	echo ">>> Creating new lajos floppy image..."
	mkdosfs -C disk_images/lajos.flp 1440 || exit
fi


echo ">>> Assembling bootloader..."

nasm -O0 -w+orphan-labels -f bin -o source/bootload/bootload.bin source/bootload/bootload.asm || exit


echo ">>> Assembling lajos kernel..."

cd source
nasm -O0 -w+orphan-labels -f bin -o kernel.bin kernel.asm || exit
cd ..


echo ">>> Assembling programs..."





echo ">>> Adding bootloader to floppy image..."

dd status=noxfer conv=notrunc if=source/bootload/bootload.bin of=disk_images/lajos.flp || exit


echo ">>> Copying LAJ_OS kernel and programs..."

rm -rf tmp-loop

mkdir tmp-loop && mount -o loop -t vfat disk_images/lajos.flp tmp-loop && cp source/kernel.bin tmp-loop/



sleep 0.2

echo ">>> Unmounting loopback floppy..."

umount tmp-loop || exit

rm -rf tmp-loop


echo ">>> Creating CD-ROM ISO image..."

rm -f disk_images/lajos.iso
mkisofs -quiet -V 'LAJOS' -input-charset iso8859-1 -o disk_images/lajos.iso -b lajos.flp disk_images/ || exit

echo '>>> Done!'
