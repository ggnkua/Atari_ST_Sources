#!/bin/sh
#
# DESCRIBE 1.19 - Describe the given devices.		Author: Kees J. Bot
#
# BUGS
# - Arguments may not contain shell metacharacters.

case $# in
0)	flag=; set -$- /dev ;;
*)	flag=d ;;
esac

ls -l$flag $* | \
sed	-e '/^total/d' \
	-e '/^[^bc]/s/.* /BAD BAD /' \
	-e '/^[bc]/s/.* \([0-9][0-9]*\), *\([0-9][0-9]*\).* /\1 \2 /' \
| {
ex=0	# exit code

while read major minor path
do
	case $path in
	/*)	name=`expr $path : '.*/\\(.*\\)$'`
		;;
	*)	name=$path
	esac

	case $major,$minor in
	1,0)	des="RAM disk" dev=ram
		;;
	1,1)	des="memory" dev=mem
		;;
	1,2)	des="kernel memory" dev=kmem
		;;
	1,3)	des="null device, data sink" dev=null
		;;
	2,*)	drive=`expr $minor % 4`
		case `expr $minor - $drive` in
		0)	des='auto density' dev="fd$drive"
			;;
		4)	des='360k, 5.25"' dev="pc$drive"
			;;
		8)	des='1.2M, 5.25"' dev="at$drive"
			;;
		12)	des='360k in 720k, 5.25"' dev="qd$drive"
			;;
		16)	des='720k, 3.5"' dev="ps$drive"
			;;
		20)	des='360k in 1.2M, 5.25"' dev="pat$drive"
			;;
		24)	des='720k in 1.2M, 5.25"' dev="qh$drive"
			;;
		28)	des='1.44M, 3.5"' dev="PS$drive"
			;;
		112)	des='auto partition 0' dev="fd${drive}a"
			;;
		116)	des='auto partition 1' dev="fd${drive}b"
			;;
		120)	des='auto partition 2' dev="fd${drive}c"
			;;
		124)	des='auto partition 3' dev="fd${drive}d"
			;;
		*)	dev=BAD
		esac
		des="floppy drive $drive ($des)"
		;;
	3,[05]|3,[123][05])
		drive=`expr $minor / 5`
		des="hard disk drive $drive" dev=hd$minor
		;;
	3,?|3,[123]?)
		drive=`expr $minor / 5`
		par=`expr $minor % 5`
		des="hard disk $drive, partition $par" dev=hd$minor
		;;
	3,12[89]|3,1[3-9]?|3,2??)
		drive=`expr \\( $minor - 128 \\) / 16`
		par=`expr \\( \\( $minor - 128 \\) / 4 \\) % 4 + 1`
		sub=`expr \\( $minor - 128 \\) % 4 + 1`
		des="hard disk $drive, partition $par, subpartition $sub"
		par=`expr $drive '*' 5 + $par`
		case $sub in
		1)	dev=hd${par}a ;;
		2)	dev=hd${par}b ;;
		3)	dev=hd${par}c ;;
		4)	dev=hd${par}d ;;
		esac
		;;
	4,0)	des="console device" dev=console
		;;
	4,[1-7])des="virtual console $minor" dev=ttyc$minor
		;;
	4,15)	des="diagnostics device" dev=log
		;;
	4,1[6-9])
		line=`expr $minor - 16`
		des="serial line $line" dev=tty0$line
		;;
	4,12[89]|4,1[3-8]?|4,19[01])
		p=`expr \\( $minor - 128 \\) / 16 | tr '0123' 'pqrs'`
		n=`expr $minor % 16`
		test $n -ge 10 && n=`expr $n - 10 | tr '012345' 'abcdef'`
		des="pseudo tty `expr $minor - 128`" dev=tty$p$n
		;;
	4,???)
		p=`expr \\( $minor - 192 \\) / 16 | tr '0123' 'pqrs'`
		n=`expr $minor % 16`
		test $n -ge 10 && n=`expr $n - 10 | tr '012345' 'abcdef'`
		des="controller of tty$p$n" dev=pty$p$n
		;;
	5,0)	des="anonymous tty" dev=tty
		;;
	6,0)	des="line printer, parallel port" dev=lp
		;;
	7,1)	des="raw ethernet #0"
		if [ $name = eth ]; then dev=eth; else dev=eth0; fi
		;;
	7,2)	des="raw IP #0"
		if [ $name = ip ]; then dev=ip; else dev=ip0; fi
		;;
	7,3)	des="TCP/IP #0"
		if [ $name = tcp ]; then dev=tcp; else dev=tcp0; fi
		;;
	7,4)	des="UDP #0"
		if [ $name = udp ]; then dev=udp; else dev=udp0; fi
		;;
	7,17)	des="raw ethernet #1"
		if [ $name = eth ]; then dev=eth; else dev=eth1; fi
		;;
	7,18)	des="raw IP #1"
		if [ $name = ip ]; then dev=ip; else dev=ip1; fi
		;;
	7,19)	des="TCP/IP #1"
		if [ $name = tcp ]; then dev=tcp; else dev=tcp1; fi
		;;
	7,20)	des="UDP #1"
		if [ $name = udp ]; then dev=udp; else dev=udp1; fi
		;;
	7,33)	des="pseudo IP #2"
		if [ $name = ip ]; then dev=ip; else dev=psip2; fi
		;;
	7,34)	des="raw IP #2"
		if [ $name = ip ]; then dev=ip; else dev=ip2; fi
		;;
	7,35)	des="TCP/IP #2"
		if [ $name = tcp ]; then dev=tcp; else dev=tcp2; fi
		;;
	7,36)	des="UDP #2"
		if [ $name = udp ]; then dev=udp; else dev=udp2; fi
		;;
	7,49)	des="pseudo IP #3"
		if [ $name = ip ]; then dev=ip; else dev=psip3; fi
		;;
	7,50)	des="raw IP #3"
		if [ $name = ip ]; then dev=ip; else dev=ip3; fi
		;;
	7,51)	des="TCP/IP #3"
		if [ $name = tcp ]; then dev=tcp; else dev=tcp3; fi
		;;
	7,52)	des="UDP #3"
		if [ $name = udp ]; then dev=udp; else dev=udp3; fi
		;;
	8,0)	des="CD-ROM" dev=cd0
		;;
	8,[1-4])
		des="CD-ROM, partition $minor" dev=cd$minor
		;;
	8,12[89]|8,13?|8,14[0-3])
		par=`expr \\( $minor - 128 \\) / 4 + 1`
		sub=`expr \\( $minor - 128 \\) % 4 + 1`
		des="CD-ROM, partition $par, subpartition $sub"
		case $sub in
		1)	dev=cd${par}a ;;
		2)	dev=cd${par}b ;;
		3)	dev=cd${par}c ;;
		4)	dev=cd${par}d ;;
		esac
		;;
	10,[05]|10,[123][05])
		drive=`expr $minor / 5`
		des="scsi disk drive $drive" dev=sd$minor
		;;
	10,?|10,[123]?)
		drive=`expr $minor / 5`
		par=`expr $minor % 5`
		des="scsi disk $drive, partition $par" dev=sd$minor
		;;
	10,12[89]|10,1[3-9]?|10,2??)
		drive=`expr \\( $minor - 128 \\) / 16`
		par=`expr \\( \\( $minor - 128 \\) / 4 \\) % 4 + 1`
		sub=`expr \\( $minor - 128 \\) % 4 + 1`
		des="scsi disk $drive, partition $par, subpartition $sub"
		par=`expr $drive '*' 5 + $par`
		case $sub in
		1)	dev=sd${par}a ;;
		2)	dev=sd${par}b ;;
		3)	dev=sd${par}c ;;
		4)	dev=sd${par}d ;;
		esac
		;;
	10,6[4-9]|10,7?)
		tape=`expr \\( $minor - 64 \\) / 2`
		case $minor in
		*[02468])
			des="scsi tape $tape (non-rewinding)" dev=nrst$tape
			;;
		*[13579])
			des="scsi tape $tape (rewinding)" dev=rst$tape
		esac
		;;
	12,[05]|12,[123][05])
		drive=`expr $minor / 5`
		des="DOS virtual disk $drive" dev=dosd$minor
		;;
	12,?|12,[123]?)
		drive=`expr $minor / 5`
		par=`expr $minor % 5`
		des="DOS virtual disk $drive, partition $par" dev=dosd$minor
		;;
	13,0)
		des="audio" dev=audio
		;;
	14,0)
		des="audio mixer" dev=mixer
		;;
	BAD,BAD)
		des= dev=
		;;
	*)	dev=BAD
	esac

	case $name:$dev in
	*:)
		echo "$path: not a device" >&2
		ex=1
		;;
	*:*BAD*)
		echo "$path: cannot describe: major=$major, minor=$minor" >&2
		ex=1
		;;
	$dev:*)
		echo "$path: $des"
		;;
	*:*)	echo "$path: nonstandard name for $dev: $des"
	esac
done

exit $ex
}
