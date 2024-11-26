* XBIOS shells
*  by James Ingram, July 1993


	ifd	link_library
	MODULE	MOUSE
	XDEF	init_mouse
	endc

init_mouse:
	init_mouse	a0,a1,d0
	rts


	ifd	link_library
	MODULE	SSBRK
	XDEF	ssbrk
	endc

ssbrk:
	ssbrk	d0
	rts



	ifd	link_library
	MODULE	XBIOS_SCREEN_STUFF
	XDEF	get_physbase
	XDEF	get_logbase
	XDEF	get_res,set_screen
	XDEF	set_palette
	XDEF	set_colour
	endc

get_physbase:
	get_physbase
	rts

get_logbase:
	get_logbase
	rts

get_res:
	get_res
	rts

set_screen:
	set_screen	d0,a0,a1
	rts

set_palette:
	set_palette	a0
	rts

set_colour:
	set_colour	d0,d1
	rts


	ifd	link_library
	MODULE	XBIOS_DISK_STUFF
	XDEF	floprd,flopwr
	XDEF	flopfmt
	XDEF	protobt
	XDEF	flopver
	endc


floprd:
	floprd	d0,d1,d2,d3,d4,a0
	rts

flopwr:
	flopwr	d0,d1,d2,d3,d4,a0
	rts

flopfmt:
	flopfmt	d0,d1,d2,d3,d4,d5,d6,a0
	rts

protobt:
	protobt	d0,d1,d2,a0
	rts

flopver:
	flopver	d0,d1,d2,d3,d4,a0
	rts



	ifd	link_library
	MODULE	XBIOS_MISC
	XDEF	midiws
	XDEF	random
	XDEF	cursconf,puntaes,blitmode
	endc

midiws:
	midiws	a0,d0
	rts

random:
	random
	rts

cursconf:
	cursconf	d0,d1
	rts

puntaes:
	puntaes
	rts

blitmode:
	blitmode	d0
	rts



	ifd	link_library
	MODULE	XBIOS_MFP
	XDEF	mfpint
	XDEF	jdisint
	XDEF	jenabint
	XDEF	xbtimer
	endc

mfpint:
	mfpint	a0,d0
	rts

jdisint:
	jdisint	d0
	rts

jenabint:
	jenabint	d0
	rts

xbtimer:
	xbtimer	a0,d0,d1,d2
	rts



	ifd	link_library
	MODULE	XBIOS_IO
	XDEF	iorec
	XDEF	rsconf
	endc

iorec:
	iorec	d0
	rts

rsconf:
	rsconf	d0,d1,d2,d3,d4,d5
	rts


	ifd	link_library
	MODULE	XBIOS_KEYBOARD
	XDEF	keytbl
	XDEF	bioskeys
	XDEF	ikbdws,kbdvbase,kbrate
	endc

keytbl:
	keytbl	a0,a1,a2
	rts


bioskeys:
	bioskeys
	rts

ikbdws:
	ikbdws	a0,d0
	rts

kbdvbase:
	kbdvbase
	rts

kbrate:
	kbrate	d0,d1
	rts

	ifd	link_library
	MODULE	XBIOS_PRINTER
	XDEF	scrdmp,setprt,prtblk
	endc


scrdmp:
	scrdmp
	rts

setprt:
	setprt	d0
	rts

prtblk:
	prtblk	a0
	rts



	ifd	link_library
	MODULE	XBIOS_TIME
	XDEF	settime,gettime
	endc


settime:
	settime	d0
	rts


gettime:
	gettime
	rts


	ifd	link_library
	MODULE	XBIOS_SOUND
	XDEF	giaccess
	XDEF	offgibit,ongibit,dosound
	endc

giaccess:
	giaccess	d0,d1
	rts

offgibit:
	offgibit	d0
	rts

ongibit:
	ongibit		d0
	rts


dosound:
	dosound	a0
	rts



	ifd	link_library
	MODULE	XBIOS_MISC2
	XDEF	vsync,supexec
	endc


vsync:
	vsync
	rts

supexec:
	supexec	a0
	rts


