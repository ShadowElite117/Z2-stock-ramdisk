#!/bin/bash
# Repacks a ramdisk for use inside a boot.img
# Rewritten for my needs.
# ShadowElite@XDA Developers <lefelite@gmail.com>

menu()
{
	echo -e "Repack ramdisk utility for Z2 by ShadowElite from XDA developers \n"

	echo "1) Compress Z2 clean ramdisk."
	echo "2) Compress Luis ramdisk."		# Ramdisk for my device
	echo "3) Compress JP ramdisk."			# Ramdisk for my other Z2
	echo "4) Compress Papa ramdisk."		# Ramdisk for my father's Z2
	echo "5) Compress DRM fix ramdisk."		# DRM fix ramdisk
	echo -e "6) Exit \n"

	echo "Choose an option: "
}

# I created this function to ensure that the correct permissions are
# given before a ramdisk is compressed, and this avoid that the device
# doesn't boot because exist a file or files with wrong permissions.
set_permissions()
{
	echo "Setting correct permissions"

	chmod 644 crashtag
	chmod 755 data
	chmod 644 default.prop
	chmod 755 dev
	chmod 644 file_contexts
	chmod 640 fstab.qcom
	chmod 750 init
	chmod 750 init.class_main.sh
	chmod 750 init.environ.rc
	chmod 750 init.mdm.sh
	chmod 750 init.qcom.class_core.sh
	chmod 750 init.qcom.early_boot.sh
	chmod 750 init.qcom.factory.sh
	chmod 750 init.qcom.rc
	chmod 750 init.qcom.sh
	chmod 750 init.qcom.ssr.sh
	chmod 750 init.rc
	chmod 750 init.sony-device-common.rc
	chmod 750 init.sony-device.rc
	chmod 750 init.sony-platform.rc
	chmod 750 init.sony.rc
	chmod 750 init.sony.usb.rc
	chmod 750 init.target.rc
	chmod 750 init.trace.rc
	chmod 750 init.usb.configfs.rc
	chmod 750 init.usbmode.sh
	chmod 750 init.usb.rc
	chmod 750 init.zygote32.rc
	chmod 644 logo.rle
	chmod 755 oem
	chmod 755 proc
	chmod 644 property_contexts
	chmod -R 755 res
	chmod 644 res/images/charger/*
	chmod -R 750 sbin
	chmod 644 seapp_contexts
	chmod 644 selinux_version
	chmod 644 sepolicy
	chmod 644 service_contexts
	chmod 755 sys
	chmod 755 system
	chmod 644 ueventd.qcom.rc
	chmod 644 ueventd.rc

	if [ TA == 1 ]; then
		chmod 750 init.ta_poc.sh
		chmod 750 init.ua_modem_switcher.sh
		chmod 644 sbin/TA.img
	fi

	if [ DRM == 1 ]; then
		chmod 750 init.vendor_ovl.sh
		chmod 755 vendor
		chmod -R 755 vendor/bin
		chmod -R 755 vendor/lib
		chmod 644 vendor/lib/libdrmfix.so
	fi

	echo "Deleting EMTYP_DIRECTORY files..."
	find . -name EMPTY* -exec rm -f {} \;
	echo "Done!"
}

question()
{
	echo
	echo "Do you want to continue?? (Y/N):"
	read b
	if [ "$b" == "Y" ] || [ "$b" == "y" ]; then
		clear
		continue
	elif [ "$b" == "N" ] || [ "$b" == "n" ]; then
		break
	fi

	if ! [ "$b" == "Y" ] || ! [ "$b" == "y" ]; then
		question
	fi
}

while true; do
	menu

	while true; do
		read n
		if ! [[ "$n" =~ ^[1-6]+$ ]]; then
			clear
			echo -e "That is not a valid choice, try again.\n"
			menu
		else
			break
		fi
	done

	case $n in
		1)
			DRM=0
			TA=0
			mkdir tmp
			cp -R Z2/* tmp
			cd tmp
			set_permissions
			find . | cpio --owner root:root -o -H newc | gzip > ../Z2.cpio.gz
		;;

		2)
			DRM=0
			TA=1
			mkdir tmp
			cp -R Luis/* tmp
			cd tmp
			set_permissions
			find . | cpio --owner root:root -o -H newc | gzip > ../Z2_L.cpio.gz
		;;

		3)
			DRM=0
			TA=1
			mkdir tmp
			cp -R JP/* tmp
			cd tmp
			set_permissions
			find . | cpio --owner root:root -o -H newc | gzip > ../Z2_JP.cpio.gz
		;;

		4)
			DRM=0
			TA=1
			cp -R Papa/* tmp
			cd Papa
			set_permissions
			find . | cpio --owner root:root -o -H newc | gzip > ../Z2_P.cpio.gz
		;;

		5)
			DRM=1
			TA=0
			mkdir tmp
			cp -R DRM/* tmp
			cd tmp
			set_permissions
			find . | cpio --owner root:root -o -H newc | gzip > ../Z2_DRM.cpio.gz
		;;

		6)
			break
		;;
	esac

	cd ..
	rm -R tmp
	question
done
