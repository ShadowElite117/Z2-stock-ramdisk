#!/system/bin/sh
# ********************************************************
# * Copyright 2011 (C) Sony Mobile Communications Inc.   *
# * All rights, including trade secret rights, reserved. *
# ********************************************************

# use product specific script if exist.
if [ -f '/init.usbmode.product.sh' ]; then
	exit `/init.usbmode.product.sh`
fi

TAG="usb"
VENDOR_ID=0FCE
PID_PREFIX=0

get_pid_prefix()
{
	case $1 in
		"mass_storage")
			PID_PREFIX=E
		;;

		"mass_storage,adb")
			PID_PREFIX=6
		;;

		"mtp")
			PID_PREFIX=0
		;;

		"mtp,adb")
			PID_PREFIX=5
		;;

		"mtp,cdrom")
			PID_PREFIX=4
		;;

		"mtp,cdrom,adb")
			PID_PREFIX=4
			# Don't enable ADB for PCC mode.
			USB_FUNCTION="mtp,cdrom"
		;;

		"rndis")
			PID_PREFIX=7
		;;

		"rndis,adb")
			PID_PREFIX=8
		;;

		"ncm")
			PID_PREFIX=1
		;;

		"ncm,adb")
			PID_PREFIX=2
		;;

		"midi")
			PID_PREFIX=C
		;;

		"midi,adb")
			PID_PREFIX=F
		;;

		*)
			/system/bin/log -t ${TAG} -p e "unsupported composition: $1"
			return 1
		;;
	esac

	return 0
}

set_engpid()
{
	# use platform script to do eng related setup if exist
	if [ -f '/init.usbmode.platform.sh' ]; then
		RET=$(/system/bin/sh /init.usbmode.platform.sh "eng_setup" ${1})
		if [ $? -eq 0 ]; then
			set - ${RET}
			PID=${1}
			USB_FUNCTION=${2}
			# eng related setup is done, skip default setup
			return 0
		fi
	fi

	SUPPORT_RMNET=1
	case $1 in
		"mass_storage,adb") PID_PREFIX=6 ;;
		"mtp,adb") PID_PREFIX=5 ;;
		"rndis,adb")
			PID_PREFIX=D
			SUPPORT_RMNET=0
		;;

		*)
			/system/bin/log -t ${TAG} -p i "No eng PID for: $1"
			return 1
		;;
	esac

	PID=${PID_PREFIX}146
	USB_FUNCTION=${1},serial,diag
	echo diag > /sys/class/android_usb/android0/f_diag/clients
	echo smd,tty > /sys/class/android_usb/android0/f_serial/transports
	if [ ${SUPPORT_RMNET} -eq 1 ]; then
		USB_FUNCTION=${USB_FUNCTION},rmnet
		echo smd,bam > /sys/class/android_usb/android0/f_rmnet/transports
	fi

	return 0
}

PID_SUFFIX_PROP=$(/system/bin/getprop ro.usb.pid_suffix)
USB_FUNCTION=$(/system/bin/getprop sys.usb.config)
ENG_PROP=$(/system/bin/getprop persist.usb.eng)

get_pid_prefix ${USB_FUNCTION}
if [ $? -eq 1 ]; then
	exit 1
fi

PID=${PID_PREFIX}${PID_SUFFIX_PROP}

echo 0 > /sys/class/android_usb/android0/enable
echo ${VENDOR_ID} > /sys/class/android_usb/android0/idVendor

if [ ${ENG_PROP} -eq 1 ]; then
	set_engpid ${USB_FUNCTION}
fi

echo ${PID} > /sys/class/android_usb/android0/idProduct
/system/bin/log -t ${TAG} -p i "usb product id: ${PID}"

echo ${USB_FUNCTION} > /sys/class/android_usb/android0/functions
/system/bin/log -t ${TAG} -p i "enabled usb functions: ${USB_FUNCTION}"

echo 1 > /sys/class/android_usb/android0/enable

exit 0
