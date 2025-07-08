#!/bin/sh

# SPDX-License-Identifier: 0BSD
# Copyright (c) 2025 Beckhoff Automation GmbH & Co. KG
#
# Description:
# This script will update the system from a USB drive.
# Therefore you need to download the repositories upfront
# from a different PC to the USB drive.
# Please make sure you have the necessary repositories on
# the drive:
#
# For Beckhoff RT Linux:
#
# https://deb.beckhoff.com
# https://deb-mirror.beckhoff.com
#
# Each repository should be downloaded into a different
# folder on the USB drive: "/deb" & "/deb-mirror"
#
# For TwinCAT/BSD:
# 
# Depending on the version you want to update e.g.:
# https://tcbsd.beckhoff.com/TCBSD/14/stable/packages/
# 
# folder on the USB drive: "/tcbsd"

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script with sudo or as root."
    exit 1
fi

# Check if a device was passed as a parameter
if [ -z "$1" ]; then
    echo "Please provide the device as a parameter (e.g., /dev/sda1)."
    exit 1
fi

DEVICE=$1
MOUNT_POINT="/mnt/usbupdate"
# Detect the operating system
OS=$(uname)

if [ "$OS" = "Linux" ]; then
    REPO_FILE="/etc/apt/sources.list.d/usb-repo.list"
    DEB_REPO="deb"
    DEB_MIRROR_REPO="deb-mirror"

    # Mount the USB device
    echo "Attempting to mount the device $DEVICE..."
    mkdir -p $MOUNT_POINT

    # Check the filesystem and mount
    FILESYSTEM=$(blkid -o value -s TYPE "$DEVICE")
    if [ "$FILESYSTEM" = "exfat" ]; then
        mount -t exfat "$DEVICE" "$MOUNT_POINT"
    elif [ "$FILESYSTEM" = "vfat" ]; then
        mount -t vfat "$DEVICE" "$MOUNT_POINT"
    else
        echo "Unknown filesystem. Only FAT or exFAT are supported."
        exit 1
    fi

    if [ $? -ne 0 ]; then
        echo "Error mounting the device."
        exit 1
    fi

    # Add temporary repository
    echo "Adding temporary repository..."
    if [ -d "$MOUNT_POINT/$DEB_REPO" ]; then
    	echo "deb [signed-by=/usr/share/keyrings/bhf.asc] file://$MOUNT_POINT/$DEB_REPO/debian bookworm-unstable main" > "$REPO_FILE"
    else
	echo "Could not find repo directory: $MOUNT_POINT/$DEB_REPO/debian"
        exit 1
    fi
    if [ -d "$MOUNT_POINT/$DEB_REPO" ]; then
	echo "deb [signed-by=/usr/share/keyrings/bhf.asc] file://$MOUNT_POINT/$DEB_MIRROR_REPO/debian bookworm-unstable main" >> "$REPO_FILE"
    else
	echo "Could not find repo directory: $MOUNT_POINT/$DEB_REPO"
	exit 1
    fi

    # Perform update
    echo "Performing apt update and upgrade..."
    apt update
    apt upgrade -y

    # Remove temporary repository
    echo "Removing temporary repository..."
    rm -f "$REPO_FILE"

    # Unmount the USB device
    echo "Unmounting the device..."
    umount "$MOUNT_POINT"

elif [ "$OS" = "FreeBSD" ]; then
    # Mount the USB device
    echo "Attempting to mount the device $DEVICE..."
    mkdir -p $MOUNT_POINT

    # Check the filesystem and mount
    FILESYSTEM=$(file -s "$DEVICE" | grep -o "FAT")
    case "$FILESYSTEM" in
    *FAT*) mount -t msdosfs "$DEVICE" "$MOUNT_POINT";;
    *    ) echo "Unknown filesystem. Only FAT is supported."
	   exit 1;;
    esac

    if [ $? -ne 0 ]; then
        echo "Error mounting the device."
        exit 1
    fi

    # Install packages from USB drive
    echo "Add temporarily USB repository - will be gone after reboot"

    # Extract the current repository URL from pkg to recover
    URL=$(awk -F'"' '/url/ {print $2}' "/etc/pkg/TCBSD.conf")

    # Print the extracted URL for verification
    echo "Extracted URL: $URL"

    sh /usr/local/share/examples/bhf/pkgrepo-set.sh file://$MOUNT_POINT/tcbsd
    echo "Updating packages from USB..."
    pkg update && pkg upgrade

    # Reset the package server URL and remove USB drive
    sh /usr/local/share/examples/bhf/pkgrepo-set.sh $URL
    
    # Unmount the USB device
    echo "Unmounting the device..."
    umount "$MOUNT_POINT"
else
    echo "Unsupported operating system: $OS"
    exit 1
fi

echo "Update completed."
