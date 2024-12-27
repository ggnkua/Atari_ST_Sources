*************************************************************************
*			GEM link Filer test program			*
*			---------------------------			*
*									*
*									*
* Written by: Machine System Data of Persistence Of Vision (MSD/POV)	*
*									*
*									*
*									*
*									*
*									*
*									*
*									*
* Version: 1.0   1st December 1992					*
*									*
*									*
*		½ Brown Beer Bottle Development¿ 1993			*
*									*
*************************************************************************
*
* This program is designed to show how V1.7+ of the link filer works (WITH
* filename extensions).
*
* Stand alone this program would try to load files from various paths
* and a non existant drive.
*
* When this program is run from the link filer the files resides in
* one link file and the filer strips all the drive:path details off
* the filename then searches a filename table. If the filename is found
* in the lookup table the file is loaded from the link file, if not it
* will jump into the ROM and let TOS find the file on the relavant
* drive:path.
*
		bsr	set_super		;set supervisor
		move.b	#$12,$fffffc02.w	;DI mouse
		bsr	get_screen_base
		bsr	get_old_palette
		bsr	get_original_rez
		bsr	set_low_rez
		bsr	set_up			;set screen

		lea	pic1,a6			;our 4 pics
		bsr	load

		lea	pic2,a6
		bsr	load

		lea	pic3,a6
		bsr	load

		lea	pic4,a6
		bsr	load

		bsr	get_key			;when done wait for a key
		bsr	set_old_palette
		bsr	set_org_rez
		move.b	#$8,$fffffc02.w		;mouse back on
		bsr	set_user

		clr.w	-(sp)
		trap	#1

*************************************************************************
load		move.w	#2,-(sp)
		move.l	a6,-(sp)
		move.w	#$3d,-(sp)
		trap	#1
		addq.l	#8,sp
		move.l	d0,d7
		tst.l	d0
		bmi	error

		pea	buffer
		move.l	#32034,-(sp)
		move.w	d7,-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		lea	12(sp),sp
		move.w	d7,-(sp)
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp

		movem.l	buffer+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.l	scr_now,a0
		lea	buffer+34,a1
		move.w	#32000/4-1,d0
.loop		move.l	(a1)+,(a0)+
		dbf	d0,.loop
		rts

error		bsr	set_org_rez
		pea	error_message
		move.w	#9,-(sp)
		trap	#1
		lea	6(sp),sp
		move.w	#$2700,sr
here		eor.w	#$f00,$ffff8240.w
		bra.s	here


*************************************************************************
v_sync		movem.l	d0-d3/a0-a3,-(sp)
		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		movem.l	(sp)+,d0-d3/a0-a3
		rts

get_key		move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp
		rts

set_super	clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		rts

set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts

get_old_palette	movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_palette
		rts

set_old_palette	movem.l	old_palette,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts

get_screen_base	move.w	#3,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,screen_base
		rts

get_original_rez
		move.w	#4,-(sp)
		trap	#14
		addq.l	#2,sp
		move.w	d0,original_rez
		rts

set_org_rez	move.w	original_rez,-(sp)
		bra.s	set_rez
set_low_rez	clr.w	-(sp)
		bra.s	set_rez
set_med_rez	move.w	#1,-(sp)
set_rez		move.l	screen_base,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		rts

set_up		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
set_screen	move.l	scr_now,d6
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts

	SECTION DATA
;Our 4 filenames
pic1		dc.b	"a:\1.pi1",0
	even
pic2		dc.b	"a:\1.pic",0
	even
pic3		dc.b	"a:\123\lotus\link.dat\3.pi1",0
	even
pic4		dc.b	"m:\false\4.pi1",0
	even


error_message	dc.b	27,'E',27,'Y',32+8,32+17,"ERROR"
		dc.b	27,'Y',32+10,32+13,"File not found"
		dc.b	27,'Y',32+13,32+5,"Check filename is in link file"
		dc.b	27,'Y',32+14,32+3,"or at least on the disk specified."
		dc.b	27,'Y',32+18,32+8,"Could this be a bug?????"
		dc.b	0

   SECTION BSS
stack_save	ds.l	1
screen_base	ds.l	1
original_rez	ds.w	1
old_palette	ds.w	16
scr_now		ds.l	1
scr_xor		ds.l	1

		ds.b	256
screens		ds.b	32000
		ds.b	32000

buffer		ds.b	32034
