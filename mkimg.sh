#/bin/bash

LINEAGEVERSION=lineage-16.0
DATE=`date +%Y%m%d`
IMGNAME=$LINEAGEVERSION-$DATE-rpi3.img
IMGSIZE=4
OUTDIR=${ANDROID_PRODUCT_OUT:="../../../out/target/product/rpi3"}

if [ `id -u` != 0 ]; then
	echo "Must be root to run script!"
	exit
fi

if [ -f $IMGNAME ]; then
	echo "File $IMGNAME already exists!"
else
	echo "Creating image file $IMGNAME..."
	dd if=/dev/zero of=$IMGNAME bs=512k count=$(echo "$IMGSIZE*1024*2" | bc)
	sync
	echo "Creating partitions..."
	(
	echo o
	echo n
	echo p
	echo 1
	echo
	echo +128M
	echo n
	echo p
	echo 2
	echo
	echo +1024M
	echo n
	echo p
	echo 3
	echo
	echo +256M
	echo n
	echo p
	echo
	echo
	echo t
	echo 1
	echo c
	echo a
	echo 1
	echo w
	) | fdisk $IMGNAME
	sync
	LOOPDEV=`kpartx -av $IMGNAME | awk 'NR==1{ sub(/p[0-9]$/, "", $3); print $3 }'`
	sync
	if [ -z "$LOOPDEV" ]; then
		echo "Unable to find loop device!"
		kpartx -d $IMGNAME
		exit
	fi
	echo "Image mounted as $LOOPDEV"
	sleep 5
	mkfs.fat -F 32 /dev/mapper/${LOOPDEV}p1
	mkfs.ext4 /dev/mapper/${LOOPDEV}p4
	resize2fs /dev/mapper/${LOOPDEV}p4 687868
	echo "Copying system..."
	dd if=$OUTDIR/system.img of=/dev/mapper/${LOOPDEV}p2 bs=1M
	echo "Copying vendor..."
	dd if=$OUTDIR/vendor.img of=/dev/mapper/${LOOPDEV}p3 bs=1M
	echo "Copying boot..."
	mkdir -p sdcard/boot
	sync
	mount /dev/mapper/${LOOPDEV}p1 sdcard/boot
	sync
	cp boot/* sdcard/boot
	cp ../../../vendor/brcm/rpi3/proprietary/boot/* sdcard/boot
	cp $OUTDIR/obj/KERNEL_OBJ/arch/arm/boot/zImage sdcard/boot
	cp -R $OUTDIR/obj/KERNEL_OBJ/arch/arm/boot/dts/* sdcard/boot
	cp $OUTDIR/ramdisk.img sdcard/boot
	sync
	umount /dev/mapper/${LOOPDEV}p1
	rm -rf sdcard
	kpartx -d $IMGNAME
	sync
	echo "Done, created $IMGNAME!"
fi
