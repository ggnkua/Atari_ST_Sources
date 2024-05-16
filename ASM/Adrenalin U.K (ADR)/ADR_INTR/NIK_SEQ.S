	jmp	skip
filename:	dc.b	"sequence.adr",0	;destination name
	even
pic1	incbin	"1.pi1"	;source picture
pic2	incbin	"2.pi1"	;source picture
pic3	incbin	"3.pi1"	;source picture
pic4	incbin	"4.pi1"	;source picture
pic5	incbin	"5.pi1"	;source picture
	even

skip	bsr	set_super
	dc.w	$a00a
	bsr	get_screen_base
	bsr	get_old_palette
	bsr	set_new_palette
	bsr	get_original_rez
	bsr	set_low_rez

	move.l	screen_base,a1
	lea	pic1+34,a0
	move.w	#32000/4-1,d0
loop:	move.l	(a0)+,(a1)+
	dbf	d0,loop
	
	move.l	screen_base,a0
	lea	160(a0),a0
	move.l	a0,a6

	lea	buffer,a5
	bsr	take_off

	move.l	screen_base,a1
	lea	pic2+34,a0
	move.w	#32000/4-1,d0
.sh2	move.l	(a0)+,(a1)+
	dbf	d0,.sh2
	move.l	screen_base,a0
	bsr	take_off

	move.l	screen_base,a1
	lea	pic3+34,a0
	move.w	#32000/4-1,d0
.sh3	move.l	(a0)+,(a1)+
	dbf	d0,.sh3
	move.l	screen_base,a0
	bsr	take_off

	move.l	screen_base,a1
	lea	pic4+34,a0
	move.w	#32000/4-1,d0
.sh4	move.l	(a0)+,(a1)+
	dbf	d0,.sh4
	move.l	screen_base,a0
	bsr	take_off

	move.l	screen_base,a1
	lea	pic5+34,a0
	move.w	#32000/4-1,d0
.sh5	move.l	(a0)+,(a1)+
	dbf	d0,.sh5
	move.l	screen_base,a0
	bsr	take_off


	move.l	a5,a6
;now save
	bsr	f_create
	bsr	f_write
	bsr	f_close

wait
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
take_off	move.w	#6-1,d7
.down
		move.w	#29-1,d0
.loop		REPT	20
		move.l	(a0),(a5)+
		move.l	#0,(a0)+
		move.l	(a0),(a5)+
		move.l	#0,(a0)+
		ENDR
		bsr	pause
		dbf	d0,.loop
		lea	160*3(a0),a0
		dbf	d7,.down
		rts

f_create
	move.w	#0,-(sp)
	pea	filename
	move.w	#$3c,-(sp)
	trap	#1
	add.l	#8,sp
	move.w	d0,handle
	rts

f_write	lea	buffer,a0
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
	move.w	#5000,d0
pau:	nop
	dbf	d0,pau
	move.w	(sp)+,d0
	rts

get_key:
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

set_super:
	clr.l	-(sp)		;Set super stack equal
	move.w	#$20,-(sp)	; to user stack before call
	trap	#1
	addq.l	#6,sp		;correct stack
	move.l	d0,stack_save	;save old supervisor stack value
	rts
set_user:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1		;back to user
	addq.l	#6,sp		;correct stack
	rts

get_old_palette:
	move.w	#8-1,d0
	lea	$ff8240,a0
	lea	old_palette,a1
get_old:
	move.l	(a0)+,(a1)+
	dbf	D0,get_old
	rts

set_new_palette:
	lea	pic1+2,a0
	bra	set_pal
set_old_palette:
	lea	old_palette,a0
set_pal:
	lea	$ff8240,a1
	move.w	#8-1,d0
set_p:	move.l	(a0)+,(a1)+
	dbf	d0,set_p
	rts

get_screen_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen_base
	rts

get_original_rez:
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,original_rez
	rts

set_low_rez:
	clr.w	-(sp)
	bra	set_rez
set_med_rez:
	move.w	#1,-(sp)
set_rez:
	move.l	#-1,-(sp)
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
buffer:	ds.b	(16*8)*20
	ds.b	(16*8)*20
	ds.b	(16*8)*20
eob:
