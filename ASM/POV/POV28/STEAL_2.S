; STEAL program

; This will remove the logo from the top right hand corner of the screens
; Use:
;     Change the FILENAME to 1.DAT and PIC to  1.PI1
;			     2.DAT	       2.PI1
;			     3.DAT	       3.PI1
;			     4.DAT	       4.PI1
;			     5.DAT	       5.PI1
;			     6.DAT	       6.PI1
;			     7.DAT	       7.PI1
;			     8.DAT	       8.PI1
;
; In each case do a change then assemble the code and run.
;  then.... do the changes again until all pictures have been processed
;

		bra	skip
filename	dc.b	"1.dat",0	;destination name
	even
pic		incbin	"1.pi1"	;source picture
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
	
	lea	buffer,a1
	move.l	screen_base,a0
	add.w	#96,a0
	move.l	#-1,d1
	move.w	#(72+72)-1,d0	;down
.loop:	move.l	(a0),(a1)+
	move.l	d1,(a0)+
	move.l	(a0),(a1)+
	move.l	d1,(a0)+

	move.l	(a0),(a1)+
	move.l	d1,(a0)+
	move.l	(a0),(a1)+
	move.l	d1,(a0)+

	move.l	(a0),(a1)+
	move.l	d1,(a0)+
	move.l	(a0),(a1)+
	move.l	d1,(a0)+

	move.l	(a0),(a1)+
	move.l	d1,(a0)+
	move.l	(a0),(a1)+
	move.l	d1,(a0)+

	move.l	(a0),(a1)+
	move.l	d1,(a0)+
	move.l	(a0),(a1)+
	move.l	d1,(a0)+

	move.l	(a0),(a1)+
	move.l	d1,(a0)+
	move.l	(a0),(a1)+
	move.l	d1,(a0)+

	move.l	(a0),(a1)+
	move.l	d1,(a0)+
	move.l	(a0),(a1)+
	move.l	d1,(a0)+

	move.l	(a0),(a1)+
	move.l	d1,(a0)+
	move.l	(a0),(a1)+
	move.l	d1,(a0)+

	bsr	pause
	add.w	#160-8*8,a0
	dbf	d0,.loop

	move.l	a1,eob
	lea	buffer,a2
	sub.l	a2,a1
	move.l	a1,length

;now save
	bsr	f_create
	bsr	f_write
	bsr	f_close

wait:	bsr	get_key

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

scroll:
	move.l	screen_base,a0
	move.w	#72-1,d0
.loop:
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	roxr.w	56(a0)
	roxr.w	64(a0)

	add.w	#2,a0
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	roxr.w	56(a0)
	roxr.w	64(a0)

	add.w	#2,a0
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	roxr.w	56(a0)
	roxr.w	64(a0)

	add.w	#2,a0
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	roxr.w	56(a0)
	roxr.w	64(a0)

	add.w	#160-6,a0
	dbf	d0,.loop
	rts
f_create:
	move.w	#0,-(sp)
	pea	filename
	move.w	#$3c,-(sp)
	trap	#1
	add.l	#8,sp
	move.w	d0,handle
	rts

f_write:
	pea	buffer
	move.l	length,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	rts

f_close:
	move.w	handle,-(sp)
	trap	#1
	addq.l	#2,sp
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

****************
* DATA SECTION *
****************
stack_save:	dc.l	0
screen_base	dc.l	0
original_rez:	dc.w	0
handle:		dc.w	0
eob:		dc.l	0
length:		dc.l	0
old_palette:	ds.w	16
	even
	SECTION BSS
buffer:	ds.l	1

