#!/bin/sh
#
#	setup 3.6 - install a Minix distribution	Author: Kees J. Bot
#								20 Dec 1994
# (An external program can use the X_* hooks to add
# a few extra actions.  It needs to use a sed script to change
# them though, the shell doesn't get it otherwise.)

PATH=/bin:/usr/bin
export PATH

case "$1" in
-*)	set x x		# We don't do options.
esac

# Installing a floppy set?
case $# in
0)	# No, all of Minix.
	;;
1)
	cd "$1" || exit

	# Annoying message still there?
	grep "'setup /usr'" /etc/issue >/dev/null 2>&1 && rm -f /etc/issue

	size=bad
	while [ "$size" = bad ]
	do
		echo -n "\
What is the size of the images on the diskettes? [all] "; read size

		case $size in
		''|360|720|1200|1440)
			;;
		*)	echo "Sorry, I don't believe \"$size\", try again." >&2
			size=bad
		esac
	done

	drive=
	while [ -z "$drive" ]
	do
		echo -n "What floppy drive to use? [0] "; read drive

		case $drive in
		'')	drive=0
			;;
		[01])
			;;
		*)	echo "It must be 0 or 1, not \"$drive\"."
			drive=
		esac
	done

	vol -r $size /dev/fd$drive | uncompress | tar xvfp -

	echo Done.
	exit
	;;
*)
	echo "Usage: setup [dir]  # Install Minix, or a floppy set in 'dir'" >&2
	exit 1
esac

# Installing Minix on the hard disk.
# Must be in / or we can't mount or umount.
case "`pwd`" in
/?*)	echo "Please type 'cd /', you are locking up `pwd`" >&2	
	exit 1
esac
case "$0" in
/tmp/*)
	rm -f "$0"
	;;
*)	cp -p "$0" /tmp/setup
	exec /tmp/setup
esac

# Find out what we are running from.
exec 9<&0 </etc/mtab			# Mounted file table.
read thisroot rest			# Current root (/dev/ram or /dev/fd?)
read fdusr rest				# USR (/dev/fd? or /dev/fd?c)
exec 0<&9 9<&-

# What do we know about ROOT?
case $thisroot:$fdusr in
/dev/ram:/dev/fd0c)	fdroot=/dev/fd0		# Combined ROOT+USR in drive 0
			;;
/dev/ram:/dev/fd1c)	fdroot=/dev/fd1		# Combined ROOT+USR in drive 1
			;;
/dev/ram:/dev/fd*)	fdroot=unknown		# ROOT is some other floppy
			;;
/dev/fd*:/dev/fd*)	fdroot=$thisroot	# ROOT is mounted directly
			;;
*)			fdroot=$thisroot	# ?
	echo -n "\
It looks like Minix has been installed on disk already.  Are you sure you
know what you are doing? [y] "
	read yn
	case "$yn" in
	''|[yY]*|sure)	;;
	*)	exit
	esac
esac

echo -n "\
This is the Minix installation script.

Note 1: If the screen blanks suddenly then hit F3 to select \"software
        scrolling\".

Note 2: If things go wrong then hit DEL and start over.

Note 3: The installation procedure is described in the manual page
        usage(8).  It will be hard without it.

Note 4: Some questions have default answers, like this: [y]
	Simply hit RETURN (or ENTER) if you want to choose that answer.

Note 5: If you see a colon (:) then you should hit RETURN to continue.
:"
read ret

echo "
What type of keyboard do you have?  You can choose one of:
"
ls -C /usr/lib/keymaps | sed -e 's/\.map//g' -e 's/^/    /'
echo -n "
Keyboard type? [us-std] "; read keymap
case "$keymap" in
?*)	loadkeys "/usr/lib/keymaps/$keymap.map"
esac

echo -n "
Minix needs one primary partition of at least 30 Mb (it fits in 20 Mb, but
it needs 30 Mb if fully recompiled.  Add more space to taste.)

If there is no free space on your disk then you have to back up one of the
other partitions, shrink, and reinstall.  See the appropriate manuals of the
the operating systems currently installed.  Restart your Minix installation
after you have made space.

To make this partition you will be put in the editor \"part\".  Follow the
advice under the '!' key to make a new partition of type MINIX.  Do not
touch an existing partition unless you know precisely what you are doing!
Please note the name of the partition (hd1, hd2, ..., hd9, sd1, sd2, ...
sd9) you make.  (See the devices section in usage(8) on Minix device names.)
:"
read ret

primary=
while [ -z "$primary" ]
do
	part || exit

	echo -n "
Please finish the name of the primary partition you have created:
(Just type RETURN if you want to rerun \"part\")                   /dev/"
	read primary
done

root=${primary}a
usr=${primary}c

echo -n "
You have created a partition named:	/dev/$primary
The following subpartitions are about to be created on /dev/$primary:

	Root subpartition:	/dev/$root	1440 kb
	/usr subpartition:	/dev/$usr	rest of $primary

Hit return if everything looks fine, or hit DEL to bail out if you want to
think it over.  The next step will destroy /dev/$primary.
:"
read ret
					# Secondary master bootstrap.
installboot -m /dev/$primary /usr/mdec/masterboot >/dev/null || exit

					# Partition the primary.
partition /dev/$primary 1 81:2880* 0:0 81:0+ >/dev/null || exit

echo "
Migrating from floppy to disk...
"

mkfs /dev/$usr
echo "\
Scanning /dev/$usr for bad blocks.  (Hit DEL to stop the scan if are absolutely
sure that there can not be any bad blocks.  Otherwise just wait.)"
trap ': nothing' 2
readall -b /dev/$usr | sh
echo "Scan done"
sleep 2
trap 2

mount /dev/$usr /mnt || exit		# Mount the intended /usr.

cpdir -v /usr /mnt || exit		# Copy the usr floppy.

umount /dev/$usr || exit		# Unmount the intended /usr.

umount $fdusr				# Unmount the /usr floppy.

mount /dev/$usr /usr || exit		# A new /usr

if [ $fdroot = unknown ]
then
	echo "
By now the floppy USR has been copied to /dev/$usr, and it is now in use as
/usr.  Please insert the installation ROOT floppy in a floppy drive."

	drive=
	while [ -z "$drive" ]
	do
		echo -n "What floppy drive is it in? [0] "; read drive

		case $drive in
		'')	drive=0
			;;
		[01])
			;;
		*)	echo "It must be 0 or 1, not \"$drive\"."
			drive=
		esac
	done
	fdroot=/dev/fd$drive
fi

echo "
Copying $fdroot to /dev/$root
"

mkfs /dev/$root || exit
mount /dev/$root /mnt || exit
if [ $thisroot = /dev/ram ]
then
	# Running from the RAM disk, root image is on a floppy.
	mount $fdroot /root || exit
	cpdir -v /root /mnt || exit
	umount $fdroot || exit
	cpdir -f /dev /mnt/dev		# Copy any extra MAKEDEV'd devices
else
	# Running from the floppy itself.
	cpdir -vx / /mnt || exit
	chmod 555 /mnt/usr
fi

					# Change /etc/fstab.
echo >/mnt/etc/fstab "\
# Poor man's File System Table.

root=/dev/$root
usr=/dev/$usr"

					# How to install further?
echo >/mnt/etc/issue "\
Login as root and run 'setup /usr' to install floppy sets."

					# National keyboard map.
case "$keymap" in
?*)	cp -p "/usr/lib/keymaps/$keymap.map" /mnt/etc/keymap
esac

eval "$X_ROOT1"
umount /dev/$root || exit		# Unmount the new root.

# Compute size of the second level file block cache.
ram=
echo -n "
What is the memory size of this system in kilobytes? [4096 or more] "
read ram
case "$ram" in '') ram=4096;; esac
case `arch` in
i86)	cache=`expr "0$ram" - 1024`
	test $cache -lt 32 && cache=0
	test $cache -gt 512 && cache=512
	;;
*)	cache=`expr "0$ram" - 2560`
	test $cache -lt 64 && cache=0
	test $cache -gt 1024 && cache=1024
esac
echo "Second level file system block cache set to $cache kb."
if [ $cache -eq 0 ]; then cache=; else cache="ramsize=$cache"; fi

					# Make bootable.
installboot -d /dev/$root /usr/mdec/bootblock /boot >/dev/null || exit
edparams /dev/$root "rootdev=$root; ramimagedev=$root; $cache; save" || exit
eval "$X_ROOT2"

echo "
Please insert the installation ROOT floppy and type 'halt' to exit Minix.
You can type 'boot $primary' to try the newly installed Minix system.  See
\"TESTING\" in the usage manual."
