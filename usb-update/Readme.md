# usb-update

## Script to update TwinCAT/BSD or Linux system from a USB drive

This script can be used to update your system offline from an USB drive.
It might be helpful in case your devices have no internet access but need an update.
In this case you need to prepare an USB drive upfront and download the requiredn repository to the drive. If you are using windows for download the repository, you can use the **[Backup-BhfRepo](../Backup-BhfRepo/Readme.md)** powershell module. On Linux you can use wget e.g.:

```
wget --recursive --timestamping --level=inf --no-cache --no-parent --no-cookies --no-host-directories --relative --directory-prefix /tmp/mirror https://tcbsd.beckhoff.com/TCBSD/14/stable/packages/
```


## TwinCAT/BSD

Download the repository to your USB drive:

https://tcbsd.beckhoff.com/TCBSD/14/stable/packages/ --> {USB drive}/**tcbsd**/

Thereafter you can insert the USB drive into your device and run the script with the device name of the usb drive as parameter e.g.:

```
doas ./usb-update.sh /dev/da0s1
```

To figure out the device name of your usb drive you can use ```gpart show``` command to see all block storage devices in your system:

```console
Administrator@CX-0C8432:~ $ gpart show
=>      40  15649120  ada0  GPT  (7.5G)
        40    532480     1  efi  (260M)
    532520      2008        - free -  (1.0M)
    534528   4194304     2  freebsd-swap  (2.0G)
   4728832  10919936     3  freebsd-zfs  (5.2G)
  15648768       392        - free -  (196K)

=>      63  62463937  da0  MBR  (30G)
        63      1985       - free -  (993K)
      2048  62459904    1  fat32lba  [active]  (30G)
  62461952      2048       - free -  (1.0M)

Administrator@CX-0C8432:~ $ ls /dev/da0*
/dev/da0        /dev/da0s1
Administrator@CX-0C8432:~ $
```

## Beckhoff RT Linux

Download the repositories to your USB drive:

https://deb.beckhoff.com --> {USB drive}/**deb**/

https://deb-mirror.beckhoff.com --> {USB drive}/**deb-mirror**/

Thereafter you can insert the USB drive into your device and run the script with the device name of the usb drive as parameter e.g.:

```
sudo ./usb-update.sh /dev/sda1
```

To figure out the device name of your usb drive you can use ```lsblk``` command to see all block storage devices in your system:

```console
Administrator@BTN-********:~$ lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda           8:0    1  983M  0 disk
`-sda1        8:1    1  982M  0 part
mmcblk0     179:0    0 14.9G  0 disk
|-mmcblk0p1 179:1    0   80M  0 part /boot/efi
`-mmcblk0p2 179:2    0 14.8G  0 part /
```