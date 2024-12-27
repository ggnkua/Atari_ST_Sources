*******
* Write loader of POVERTY DEMO (STE version)
******
*

	org	$20000
		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,oldstack


START_TRACK	equ	6
SECTORS	equ	10	;number of sectors on each track
		lea	loadercode(pc),a6	;load address
		move.w	#START_TRACK,d7	;track number
		move.w	#1,d6		;start sector
		move.l	#loadercodeend,d5
		move.l	#loadercode,d4
		sub.l	d4,d5
		divu	#SECTORS*512,d5
;		add.w	#1,d5

write_loop	move.w	#SECTORS,-(sp)	;no. sectors to write
		move.w	#0,-(sp)	;side
		move.w	d7,-(sp)	;track
		move.w	d6,-(sp)	;sector
		clr.w	-(sp)		;floppy drive A
		clr.l	-(sp)		;reserved
		move.l	a6,-(sp)	;buffer to write from
		move.w	#9,-(sp)
		trap	#14
		lea	20(sp),sp

		add.l	#SECTORS*512,a6
		add.w	#1,d7
		dbf	d5,write_loop

		move.l	oldstack,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp

		clr.w	-(sp)
		trap	#1

oldstack	dc.l	0

loadercode
	include	e:\poverty\loader\l_part1.s
		dcb.l	10,-1		;"POV!"
loadercodeend
