;
; Sabre Team - hacked by MUG U.K
;
; This music is relocated to $a8c2c
;

	opt	d+

super	clr.l	-(a7)		; set TAB to 8
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp

	lea	mdata,a0
	lea	$a8c2c,a1
	move	#(m_end-mdata)-1,d0
rltm	move.b	(a0)+,(a1)+
	dbf	d0,rltm

start	jsr	play

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

play	bclr	#0,$484.w
	jsr	$a9258
	move.l	#$a8c2c,$4d6.w
	rts

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

mdata	incbin "sabre_1.mus"
m_end

; List of files
; -------------
;
; SABRE_1.MUS  -  Intro music
; SABRE_2.MUS  -  Loading music
;
; Both pieces of music were hacked by MUG U.K
;
; I recognise the format as Matt Furniss, but I could easily be
; mistaken .............. or could I ??
;
; MUG U.K(tm) - 11/12/1992
