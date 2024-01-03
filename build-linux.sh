#!/bin/sh


if test "`whoami`" != "root" ; then
	echo "You must be logged in as root to build (for loopback mounting)"
	echo "Enter 'su' or 'sudo bash' to switch to root"
	exit
fi


if [ ! -e disk_images/jrdpdos.flp ]
then
	echo ">>> Creating new JRDPDOS floppy image..."
	mkdosfs -C disk_images/jrdpdos.flp 1440 || exit
fi


echo ">>> Assembling bootloader..."

nasm -O0 -w+orphan-labels -f bin -o os/bootloader/bootloader.bin os/bootloader/bootloader.asm || exit


echo ">>> Assembling JRDPDOS kernel..."

cd os
nasm -O0 -w+orphan-labels -f bin -o kernel.bin kernel.asm || exit
cd ..


echo ">>> Assembling programs..."

cd programs

for i in *.asm
do
	nasm -O0 -w+orphan-labels -f bin $i -o `basename $i .asm`.bin || exit
done

cd ..


echo ">>> Adding bootloader to floppy image..."

dd status=noxfer conv=notrunc if=os/bootloader/bootloader.bin of=disk_images/jrdpdos.flp || exit


echo ">>> Copying JRDPDOS kernel and programs..."

rm -rf tmp-loop

mkdir tmp-loop
mount -o loop -t vfat disk_images/jrdpdos.flp tmp-loop

cp os/kernel.bin tmp-loop/
cp programs/*.bin programs/*.bas tmp-loop

sleep 0.2

echo ">>> Unmounting loopback floppy..."

umount tmp-loop || exit

rm -rf tmp-loop


echo ">>> Creating CD-ROM ISO image..."

rm -f disk_images/JRDP-DOS_6.0.iso
mkisofs -quiet -V 'JRDPDOS' -input-charset iso8859-1 -o disk_images/JRDP-DOS_6.0.iso -b jrdpdos.flp disk_images/ || exit

echo '>>> Done!'

