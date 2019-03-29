* Sample player
* Modularised (huh?) by Agrajag

; Press ESC to quit.

		opt	s-		no labels

sample		MACRO
		movea.l	\1,a0		Filename
		moveq.l	\2,d0		Sample-rate
		moveq.l	\3,d1		1=packed,0=normal
		moveq.l	\4,d2		0=loop,1=end
		bsr	Replay
		ENDM

go	move.l	4(a7),a0	Get start of TEXT segment
	move.l	#end_of_code,d0	End of program
	sub.l	a0,d0		Get length of what we DO need
	move.l	d0,-(a7)	Push length on stack.
	move.l	a0,-(a7)	Push start address on stack
	clr.w	-(sp)		Dummy thingy!
	move.w	#$4a,-(sp)	Call MSHRINK function
	trap	#1		ZAP! Memory shrunk!
	add.l	#12,sp		Tidy stack
	tst	d0		Any errors? (Very unlikely!)
	bmi	bye		WHAT? YES?

		sample	#filename,#2,#1,#0
bye		clr	-(sp)
		trap	#1

filename	dc.b	'a:\sam_pack\test.spl',0

	include	samplay.lib

*********************************************************************

end_of_code