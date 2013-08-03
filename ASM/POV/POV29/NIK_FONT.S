*************************************************************************
*			Nik font from PI1 program			*
*			-------------------------			*
*									*
* Use inconjunction with POV 29						*
*									*
* Written by: Mac Sys Data of Persistence Of Vision			*
*									*
* Written with: Devpac developer (the best)				*
*									*
*************************************************************************
*
* Assemble with GENST 2.08 or higher
*
*

		bsr	set_super	;set supervisor mode
		dc.w	$a00a		;hide mouse
		bsr	get_screen_base
		bsr	get_old_palette
		bsr	set_new_palette
		bsr	get_original_rez
		bsr	set_low_rez

;show picture to visible screen so we can see what we are stealing
		move.l	screen_base,a1
		lea	pic+34,a0	;get start of picture date
		move.w	#32000/4-1,d0
loop		move.l	(a0)+,(a1)+
		dbf	d0,loop
	
FONT_DEPTH	equ	30		;alter this for your font
;do the stealing
		move.l	screen_base,a0	;get base
		move.l	a0,a6		;store this
		lea	buffer,a1	;get destination store
		bsr	remove_data
		move.l	screen_base,a5
		lea	pic2+34,a0
		move.w	#32000/4-1,d0
loop2		move.l	(a0)+,(a5)+
		dbf	d0,loop2

		move.l	screen_base,a0	;get base
		move.l	a0,a6		;store this
		bsr	remove_data
* now save
		bsr	f_create	;create the file
		bsr	f_write		;save all the data
		bsr	f_close		;close it off

		bsr	set_old_palette
		bsr	set_org_rez
		dc.w	$a009		;show mouse
		bsr	set_user	;back to user mode

		clr.w	-(sp)		; RETURN TO GEM DESKTOP.
		trap	#1

remove_data
		move.w	#6-1,d2		;6 lines of font down screen
down		move.w	#6-1,d1		;6 characters across
across		rept	FONT_DEPTH
		move.w	(a0),(a1)+	;get 1st word
		move.w	#$ffff,2(a0)	;show what we've nicked
		move.w	8(a0),(a1)+	;get 2nd word
		move.w	#$ffff,10(a0)	;
		move.w	16(a0),(a1)+	;get 3rd word
		move.w	#$ffff,18(a0)
		lea	160(a0),a0	;drop down a line
		bsr	pause		;do a pause
		endr

		sub.w	#160*FONT_DEPTH,a0	;goto top of a character
		add.w	#24,a0		;goto next character
		dbf	d1,across	;do across

		add.w	#32*160,a6	;drop a line of characters down
		move.l	a6,a0		;get last stored start address
		dbf	d2,down		;drop down a line
		rts

f_create	move.w	#0,-(sp)
		pea	filename
		move.w	#$3c,-(sp)
		trap	#1
		add.l	#8,sp
		move.w	d0,handle
		rts

f_write		lea	buffer,a0
		sub.l	a0,a1
		move.l	#buffer,-(sp)
		move.l	a1,-(sp)
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

pause		move.w	d0,-(sp)
		move.w	#1000,d0
.pau		nop
		dbf	d0,.pau
		move.w	(sp)+,d0
		rts

set_super	clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp		;correct stack
		move.l	d0,stack_save	;save old supervisor stack value
		rts

set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1		;back to user
		addq.l	#6,sp		;correct stack
		rts

get_old_palette	movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_palette
		rts

set_new_palette	movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
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

set_low_rez	clr.w	-(sp)
		bra	set_rez
set_med_rez	move.w	#1,-(sp)
		bra	set_rez
set_org_rez	move.w	original_rez,-(sp)
set_rez		move.l	#-1,-(sp)
		move.l	#-1,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		rts


	SECTION DATA
filename	dc.b	"font.dat",0	;destination name
		even
pic		incbin	"qs_start.pi1"	;source picture
pic2		incbin	"qs_end.pi1"	;source picture


	SECTION BSS
stack_save	ds.l	1
screen_base	ds.l	1
original_rez	ds.w	1
handle		ds.w	1
old_palette	ds.w	16
		even
buffer		ds.l	1
