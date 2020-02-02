#!/bin/bash
# Repacks a ramdisk for use inside a boot.img
# Rewritten for my needs.
# ShadowElite@XDA Developers <lefelite@gmail.com>

# I created this function to ensure that the correct permissions are
# given before a ramdisk is compressed, and this avoid that the device
# doesn't boot because exist a file or files with wrong permissions.
set_permissions()
{
	echo "Setting correct permissions"

	cd tmp

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

	echo "Deleting EMPTY_DIRECTORY files..."
	find . -name EMPTY* -exec rm -f {} \;
	echo "Done!"
}

menu()
{
	clear

	echo "#######################################"
	echo "#    Repack ramdisk utility for Z2    #"
	echo "# by ShadowElite from XDA developers. #"
	echo "#######################################"
	echo
	echo "Press 1 to compress Z2 clean ramdisk."
	echo "Press 2 to compress Luis ramdisk."		# Ramdisk for my device
	echo "Press 3 to compress JP ramdisk."			# Ramdisk for my other Z2
	echo "Press 4 to compress Papa ramdisk."		# Ramdisk for my father's Z2
	echo "Press 5 to compress DRM fix ramdisk."		# DRM fix ramdisk
	echo -e "Press q to exit.\n"

	read -n 1 -p "Make your selection: " menuinput
	echo -e "\n"
}

menu_options()
{
	if [ "$menuinput" = "1" ]; then
		DRM=0
		TA=0
		cp -R Z2/* tmp
		set_permissions
		find . | cpio --owner root:root -o -H newc | gzip > ../Z2.cpio.gz
	elif [ "$menuinput" = "2" ]; then
		DRM=0
		TA=1
		cp -R Luis/* tmp
		set_permissions
		find . | cpio --owner root:root -o -H newc | gzip > ../Z2_L.cpio.gz
	elif [ "$menuinput" = "3" ]; then
		DRM=0
		TA=1
		cp -R JP/* tmp
		set_permissions
		find . | cpio --owner root:root -o -H newc | gzip > ../Z2_JP.cpio.gz
	elif [ "$menuinput" = "4" ]; then
		DRM=0
		TA=1
		cp -R Papa/* tmp
		set_permissions
		find . | cpio --owner root:root -o -H newc | gzip > ../Z2_P.cpio.gz
	elif [ "$menuinput" = "5" ]; then
		DRM=1
		TA=0
		cp -R DRM/* tmp
		set_permissions
		find . | cpio --owner root:root -o -H newc | gzip > ../Z2_DRM.cpio.gz
	elif [ "$menuinput" = "Q" ] || [ "$menuinput" = "q" ]; then
		break
	else
		continue
	fi
}

question()
{
	echo
	read -n 1 -p "Do you want to continue?? (Y/N): " answer
	if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
		continue
	elif [ "$answer" == "N" ] || [ "$answer" == "n" ]; then
		echo
		break
	else
		clear

		echo "You have entered an invalid answer!"
		echo "Please try again!"
		question
	fi
}

while true; do
	menu

	# This verifies if the tmp folder exists and deletes it.
	if [ -e tmp ]; then
		rm -R tmp
	fi
	# Now this creates the temporary folder.
	mkdir tmp

	menu_options

	cd ..
	rm -R tmp
	question
done
