; STEAL font program
; 32 x 24 pixels
	bra	skip
filename:	dc.b	"32x24.fnt",0	;destination name
	even
pic:	incbin	"32x24fnt.pi1"	;source picture
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

	move.l	#-1,d6
	move.l	a0,a6
	lea	buffer,a1
	move.w	#10-1,d1
across:
	move.w	#24-1,d0
shift:
	move.l	(a0),(a1)+
	move.l	d6,(a0)
	move.l	4(a0),(a1)+
	move.l	d6,4(a0)
	move.l	8(a0),(a1)+
	move.l	d6,8(a0)
	move.l	12(a0),(a1)+
	move.l	d6,12(a0)
	add.w	#160,a0
	bsr	pause
	dbf	d0,shift
	sub.w	#160*24,a0
	add.w	#16,a0
	dbf	d1,across

	add.w	#160*24,a6
	move.l	a6,a0
	move.w	#10-1,d1
.loop2:
	move.w	#24-1,d0
.loop:
	move.l	(a0),(a1)+
	move.l	d6,(a0)
	move.l	4(a0),(a1)+
	move.l	d6,4(a0)
	move.l	8(a0),(a1)+
	move.l	d6,8(a0)
	move.l	12(a0),(a1)+
	move.l	d6,12(a0)

	add.w	#160,a0
	bsr	pause
	dbf	d0,.loop
	sub.w	#160*24,a0
	add.w	#16,a0
	dbf	d1,.loop2

	add.w	#160*24,a6
	move.l	a6,a0
	move.w	#10-1,d1
.loop4:
	move.w	#24-1,d0
.loop3:
	move.l	(a0),(a1)+
	move.l	d6,(a0)
	move.l	4(a0),(a1)+
	move.l	d6,4(a0)
	move.l	8(a0),(a1)+
	move.l	d6,8(a0)
	move.l	12(a0),(a1)+
	move.l	d6,12(a0)

	add.w	#160,a0
	bsr	pause
	dbf	d0,.loop3
	sub.w	#160*24,a0
	add.w	#16,a0
	dbf	d1,.loop4

	add.w	#160*24,a6
	move.l	a6,a0
	move.w	#10-1,d1
.loop5:
	move.w	#24-1,d0
.loop6:
	move.l	(a0),(a1)+
	move.l	#-1,(a0)
	move.l	4(a0),(a1)+
	move.l	d6,4(a0)
	move.l	8(a0),(a1)+
	move.l	d6,8(a0)
	move.l	12(a0),(a1)+
	move.l	d6,12(a0)

	add.w	#160,a0
	bsr	pause
	dbf	d0,.loop6
	sub.w	#160*24,a0
	add.w	#16,a0
	dbf	d1,.loop5

	add.w	#160*24,a6
	move.l	a6,a0
	move.w	#10-1,d1
.loop7:
	move.w	#24-1,d0
.loop8:
	move.l	(a0),(a1)+
	move.l	d6,(a0)
	move.l	4(a0),(a1)+
	move.l	d6,4(a0)
	move.l	8(a0),(a1)+
	move.l	d6,8(a0)
	move.l	12(a0),(a1)+
	move.l	d6,12(a0)

	add.w	#160,a0
	bsr	pause
	dbf	d0,.loop8
	sub.w	#160*24,a0
	add.w	#16,a0
	dbf	d1,.loop7

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

f_create	move.w	#0,-(sp)
		pea	filename
		move.w	#$3c,-(sp)
		trap	#1
		add.l	#8,sp
		move.w	d0,handle
		rts

f_write		move.l	#buffer,-(sp)
		move.l	#eob-buffer,-(sp)
		move.w	handle,-(sp)
		move.w	#$40,-(sp)
		trap	#1
		add.l	#12,sp
		rts

f_close		move.w	handle,-(sp)
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp
		rts

pause:	move.w	d0,-(sp)
	move.w	#3000,d0
pau:	nop
	dbf	d0,pau
	move.w	(sp)+,d0
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
	lea	pic+2,a0
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


	SECTION BSS

stack_save:	ds.l	1
screen_base	ds.l	1
original_rez:	ds.w	1
handle:		ds.w	1
old_palette:	ds.w	16
	even
buffer:	ds.b	(16*24)*10
	ds.b	(16*24)*10
	ds.b	(16*24)*10
	ds.b	(16*24)*10
	ds.b	(16*24)*10
eob:
