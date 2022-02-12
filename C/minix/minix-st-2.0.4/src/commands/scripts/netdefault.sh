#!/bin/sh
#
# netdefault 1.2 - Select the default TCP/IP network.
#							Author: Kees J. Bot
#								27 Jul 1993

case "$1" in
-n)	n=':'; shift
	;;
*)	n=
esac

case "$#:$1" in
1:eth[01] | 1:psip[23] | 1:ip[0-3] | 1:tcp[0-3] | 1:udp[0-3])
	sel=`expr $1 : '[^0-9]*\\(.*\\)'`
	;;
*)	echo "Usage: netdefault [-n] <sample-device>" >&2
	echo "       # samples: eth[01] psip[23] ip[0-3] tcp[0-3] udp[0-3]" >&2
	exit 1
esac

case $sel in
0|1)	# Ethernet.
	this=eth
	other=psip
	;;
2|3)	# Pseudo IP.
	this=psip
	other=eth
esac

# Get rid of the "other" device.
if [ -c /dev/$other ]
then
	echo rm /dev/$other
	exec </dev/null
	$n rm /dev/$other || exit
fi

# Make links from the chosen devices to the default names.
echo ln -f /dev/$this$sel /dev/$this
$n ln -f /dev/$this$sel /dev/$this || exit
echo ln -f /dev/ip$sel /dev/ip
$n ln -f /dev/ip$sel /dev/ip || exit
echo ln -f /dev/tcp$sel /dev/tcp
$n ln -f /dev/tcp$sel /dev/tcp || exit
echo ln -f /dev/udp$sel /dev/udp
$n ln -f /dev/udp$sel /dev/udp || exit
