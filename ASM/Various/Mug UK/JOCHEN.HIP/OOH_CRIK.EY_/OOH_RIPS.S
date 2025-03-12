;
; 'Ooh Crikey - Wot A Scorcher' - Music by Mad Max
;
; Hacked by MUG U.K - 13/9/1991 (Friday the 13th !!!)
;

super	clr.l	-(a7)		; set TAB to 8
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp

start	moveq	#1,d0	;1 tune per file ??
	jsr	play

wait	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	jsr	stop

exit	move.l	#old_sp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(a7)
	trap	#1

play	cmp.l	#3,d0
	bge	exitpl
	bclr	#0,$484.w
	jsr	data
	move.l	#data+8,$4d6.w
exitpl	rts

stop	clr.l	$4d6.w
	move.w	#2,d0
	move.l	#8,d1
stop1	move.b	d1,$ff8800
	clr.b	$ff8802
	addq.l	#1,d1
	dbf	d0,stop1
	bset	#0,$484.w
	rts

old_sp	dc.l	1

data	incbin "ashtray.mus"


; Files in this folder:-
;
; LOADER.MUS  -  DMA Loader screen
; ASHTRAY.MUS -  'Your Mind Is An Ashtray' screen
; NOSHEEP.MUS -  'No Sheep In Outer Mongolia' screen
;
; Credit me for using these music-rips !!
;
; MUG U.K - 13/11/1991