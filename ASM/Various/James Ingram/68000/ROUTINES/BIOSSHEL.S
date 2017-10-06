* BIOS shell
* by James Ingram, April 1993
*
* may be INCLUDED or GST linked using MK_LIB.S
*
*



	ifd	link_library
	MODULE	GETMPB
	
	XDEF	getmpb
	endc

getmpb:
	pea	(a0)
	clr.w	-(a7)
	trap	#13
	addq.l	#6,a7
	rts


	ifd	link_library
	MODULE	IN_CONSTAT
	
	XDEF	in_constat
	XDEF	in_aux_stat,in_con_stat,in_midi_stat
	endc


in_aux_stat:
	moveq	#1,d0
	bra.s	in_constat

in_con_stat:
	moveq	#2,d0
	bra.s	in_constat

in_midi_stat:
	moveq	#3,d0

in_constat:
	move.w	d0,-(a7)
	move.w	#1,-(a7)
	trap	#13
	addq.l	#4,a7
	rts


	ifd	link_library
	MODULE	BCONIN
	
	XDEF	bconin
	XDEF	get_prt_in,get_aux_in,get_con_in,get_midi_in
	endc


get_prt_in:
	moveq	#0,d0
	bra.s	bconin

get_aux_in:
	moveq	#1,d0
	bra.s	bconin

get_con_in:
	moveq	#2,d0
	bra.s	bconin

get_midi_in:
	moveq	#3,d0

bconin:
	move.w	d0,-(a7)
	move.w	#2,-(a7)
	trap	#13
	addq.l	#4,a7
	rts



	ifd	link_library
	MODULE	BCONOUT

	XDEF	bconout
	XDEF	out_prt,out_aux,out_con,out_midi,out_all_char
	endc


out_prt:
	moveq	#0,d1
	bra.s	bconout

out_aux:
	moveq	#1,d1
	bra.s	bconout

out_con:
	moveq	#2,d1
	bra.s	bconout

out_midi:
	moveq	#3,d1
	bra.s	bconout

out_ikbd:
	moveq	#4,d1
	bra.s	bconout

out_all_char:
	moveq	#5,d1

bconout:
	move.w	d0,-(a7)
	move.w	d1,-(a7)
	move.w	#3,-(a7)
	trap	#13
	addq.l	#6,a7
	rts


	ifd	link_library
	MODULE	RWABS

	XDEF	rwabs
	endc

rwabs:
* d0 = device
* d1 = sector no
* d2 = number of secs
* d3 = r/w flag
* a0 = buffer addr

	move.w	d0,-(a7)
	move.w	d1,-(a7)
	move.w	d2,-(a7)
	pea	(a0)
	move.w	d3,-(a7)
	move.w	#4,-(a7)
	trap	#13
	lea	14(a7),a7
	rts


	ifd	link_library
	MODULE	SETEXEC
	
	XDEF	set_exec
	endc

set_exec:
* a0 = vector addr
* d1 = exception vector no

	pea	(a0)
	move.w	d1,-(a7)
	move.w	#5,-(a7)
	trap	#13
	addq.l	#8,a7
	rts



	ifd	link_library
	MODULE	TICKCAL
	
	XDEF	tickcal
	endc

tickcal:
	move.w	#6,-(a7)
	trap	#13
	addq.l	#2,a7
	rts


	ifd	link_library
	MODULE	GETBPB
	
	XDEF	getbpb
	endc


getbpb:
* d0 = device

	move.w	d0,-(a7)
	move.w	#7,-(a7)
	trap	#13
	addq.l	#4,a7
	rts


	ifd	link_library
	MODULE	out_constat
	
	XDEF	out_constat
	XDEF	out_prt_stat,out_aux_stat,out_con_stat,out_midi_stat,out_ikbd_stat
	endc


out_prt_stat:
	moveq	#0,d0
	bra.s	out_constat

out_aux_stat:
	moveq	#1,d0
	bra.s	out_constat

out_con_stat:
	moveq	#2,d0
	bra.s	out_constat

out_midi_stat:
	moveq	#3,d0
	bra.s	out_constat

out_ikbd_stat:
	moveq	#4,d0

out_constat:
	move.w	d0,-(a7)
	move.w	#8,-(a7)
	trap	#13
	addq.l	#4,a7
	rts


	ifd	link_library
	MODULE	MEDIACH
	
	XDEF	mediach
	endc


mediach:
* d0 = device
	move.w	d0,-(a7)
	move.w	#9,-(a7)
	trap	#13
	addq.l	#4,a7
	rts


	ifd	link_library
	MODULE	DRVMAP
	
	XDEF	drvmap
	endc

drvmap:
	move.w	#10,-(a7)
	trap	#13
	addq.l	#2,a7
	rts


	ifd	link_library
	MODULE	KBSHIFT
	
	XDEF	kbshift
	XDEF	get_shift
	endc


get_shift:
	moveq	#-1,d0

kbshift:
	move.w	d0,-(a7)
	move.w	#11,-(a7)
	trap	#13
	addq.l	#4,a7
	rts


* return bits of d0:
*	0 = R shift key
*	1 = L shift key
*	2 = CNTRL
*	3 = ALT
*	4 = CAPS LOCK
*	5 = R mouse button
*	6 = L mouse button
*	7 = unused



