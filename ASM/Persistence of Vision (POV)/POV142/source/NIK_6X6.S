n	bra	skip
filename:	dc.b	"font.dat",0	;destination name
	even
pic:	incbin	"font_6x6.pi1"	;source picture
	even

skip	bsr	set_super
	dc.w	$a00a
	bsr	get_screen_base
	bsr	get_old_palette
	bsr	set_new_palette
	bsr	get_original_rez
	bsr	set_low_rez

	move.l	screen_base,a1
	lea	pic+34,a0
	move.w	#32000/4-1,d0
loop:	move.l	(a0)+,(a1)+
	dbf	d0,loop
	
	move.l	screen_base,a0
	lea	buffer,a1

	move.b	#-1,d1
	move.w	#3-1,d2
nik2	move.w	#20-1,d0
nik	move.b	160(a0),(a1)+
	move.b	162(a0),(a1)+
	move.b	164(a0),(a1)+
	move.b	166(a0),(a1)+
	move.b	d1,160(a0)
	move.b	d1,162(a0)
	move.b	d1,164(a0)
	move.b	d1,166(a0)

	move.b	320(a0),(a1)+
	move.b	322(a0),(a1)+
	move.b	324(a0),(a1)+
	move.b	326(a0),(a1)+
	move.b	d1,320(a0)
	move.b	d1,322(a0)
	move.b	d1,324(a0)
	move.b	d1,326(a0)

	move.b	480(a0),(a1)+
	move.b	482(a0),(a1)+
	move.b	484(a0),(a1)+
	move.b	486(a0),(a1)+
	move.b	d1,480(a0)
	move.b	d1,482(a0)
	move.b	d1,484(a0)
	move.b	d1,486(a0)

	move.b	640(a0),(a1)+
	move.b	642(a0),(a1)+
	move.b	644(a0),(a1)+
	move.b	646(a0),(a1)+
	move.b	d1,640(a0)
	move.b	d1,642(a0)
	move.b	d1,644(a0)
	move.b	d1,646(a0)

	move.b	800(a0),(a1)+
	move.b	802(a0),(a1)+
	move.b	804(a0),(a1)+
	move.b	806(a0),(a1)+
	move.b	d1,800(a0)
	move.b	d1,802(a0)
	move.b	d1,804(a0)
	move.b	d1,806(a0)

	move.b	960(a0),(a1)+
	move.b	962(a0),(a1)+
	move.b	964(a0),(a1)+
	move.b	966(a0),(a1)+
	move.b	d1,960(a0)
	move.b	d1,962(a0)
	move.b	d1,964(a0)
	move.b	d1,966(a0)

	move.b	1120(a0),(a1)+
	move.b	1122(a0),(a1)+
	move.b	1124(a0),(a1)+
	move.b	1126(a0),(a1)+
	move.b	d1,1120(a0)
	move.b	d1,1122(a0)
	move.b	d1,1124(a0)
	move.b	d1,1126(a0)

	bsr	pause

	move.b	161(a0),(a1)+
	move.b	163(a0),(a1)+
	move.b	165(a0),(a1)+
	move.b	167(a0),(a1)+
	move.b	d1,161(a0)
	move.b	d1,163(a0)
	move.b	d1,165(a0)
	move.b	d1,167(a0)

	move.b	321(a0),(a1)+
	move.b	323(a0),(a1)+
	move.b	325(a0),(a1)+
	move.b	327(a0),(a1)+
	move.b	d1,321(a0)
	move.b	d1,323(a0)
	move.b	d1,325(a0)
	move.b	d1,327(a0)

	move.b	481(a0),(a1)+
	move.b	483(a0),(a1)+
	move.b	485(a0),(a1)+
	move.b	487(a0),(a1)+
	move.b	d1,481(a0)

	move.b	641(a0),(a1)+
	move.b	643(a0),(a1)+
	move.b	645(a0),(a1)+
	move.b	647(a0),(a1)+
	move.b	d1,641(a0)

	move.b	801(a0),(a1)+
	move.b	803(a0),(a1)+
	move.b	805(a0),(a1)+
	move.b	807(a0),(a1)+
	move.b	d1,801(a0)

	move.b	961(a0),(a1)+
	move.b	963(a0),(a1)+
	move.b	965(a0),(a1)+
	move.b	967(a0),(a1)+
	move.b	d1,961(a0)

	move.b	1121(a0),(a1)+
	move.b	1123(a0),(a1)+
	move.b	1125(a0),(a1)+
	move.b	1127(a0),(a1)+
	move.b	d1,1121(a0)
	move.b	d1,1123(a0)
	move.b	d1,1125(a0)
	move.b	d1,1127(a0)

	bsr	pause
	add.w	#8,a0
	dbf	d0,nik

	add.w	#9*160,a0
	dbf	d2,nik2

	move.l	a1,a6
;now save
	bsr	f_create
	bsr	f_write
	bsr	f_close

	bsr	set_old_palette
	bsr	set_med_rez
	dc.w	$a009
	bsr	set_user

	MOVE.W	#$0,-(SP)	; RETURN TO GEM DESKTOP.
	TRAP	#1
	RTS

***********************
* SUBROUTINES SECTION *
***********************

f_create:
	move.w	#0,-(sp)
	pea	filename
	move.w	#$3c,-(sp)
	trap	#1
	add.l	#8,sp
	move.w	d0,handle
	rts

f_write:
	lea	buffer,a0
	move.l	a0,-(sp)
	sub.l	a0,a6
	move.l	a6,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	rts

f_close:
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

pause:	move.w	d0,-(sp)
	move.w	#15000,d0
pau:	nop
	dbf	d0,pau
	move.w	(sp)+,d0
	rts

get_key		move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp
		rts

set_super	clr.l	-(sp)		;Set super stack equal
		move.w	#$20,-(sp)	; to user stack before call
		trap	#1
		addq.l	#6,sp		;correct stack
		move.l	d0,stack_save	;save old supervisor stack value
		rts

set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1		;back to user
		addq.l	#6,sp		;correct stack
		rts

get_old_palette	move.w	#8-1,d0
		lea	$ffff8240.w,a0
		lea	old_palette,a1
get_old		move.l	(a0)+,(a1)+
		dbf	d0,get_old
		rts

set_new_palette	lea	pic+2,a0
		bra	set_pal
set_old_palette	lea	old_palette,a0
set_pal		lea	$ffff8240.w,a1
		move.w	#8-1,d0
set_p		move.l	(a0)+,(a1)+
		dbf	d0,set_p
		rts

get_screen_base	move.w	#3,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,screen_base
		rts

get_original_rez	move.w	#4,-(sp)
			trap	#14
			addq.l	#2,sp
			move.w	d0,original_rez
			rts

set_low_rez	clr.w	-(sp)
		bra	set_rez
set_med_rez	move.w	#1,-(sp)
set_rez		move.l	#-1,-(sp)
		move.l	#-1,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		rts

****************
* DATA SECTION *
****************
stack_save:	dc.l	0
screen_base	dc.l	0
original_rez:	dc.w	0
handle:		dc.w	0
old_palette:	ds.w	16
	even
buffer	ds.b	1
