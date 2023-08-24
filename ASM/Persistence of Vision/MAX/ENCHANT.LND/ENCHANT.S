;
; Enchanted Lands by Jochen Hippel - Hacked by MUG U.K
;
; I hacked the main menu music using my own Disk Grabber a long
; long time ago - but I had to cheat and use the Ultimate Ripper
; to get the others out !!
;

super	clr.l	-(a7)		; set TAB to 8
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp

start	moveq	#1,d0
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

play	cmp.b	#2,d0
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

data	incbin "gameover.mus"

; Files in this folder:-
;
; MAINMENU.MUS  -  Intro screen with amazing scorlling
; IN_GAME.MUS   -  In Game tune
; GAMEOVER.MUS  -  Game Over tune
;
; Credit me for using these music-rips !!
;
; MUG U.K - 15/11/1991
