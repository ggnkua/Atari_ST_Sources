**
** Trisound timer C replay routine example - gwEm 2005
**

		section	text
;................................................................
test_player:	clr.l	-(sp)			; supervisor mode
		move.w	#$20,-(sp)		;
		trap	#1			;
		addq.l	#6,sp			;
		move.l	d0,oldusp		; store old user stack pointer

		move.l	$114.w,oldtc		; store old timer C vector

		lea	voice_set(pc),a0	
		lea	song,a1
		bsr	MUSIC			; init music

		move.l	#timerc,$114.w		; steal timer C

		move.w	#7,-(sp)		; wait for a key
		trap	#1			;
		addq.l	#2,sp			;

		move.l	oldtc,$114.w		; restore timer c

		bsr	MUSIC+8			; de-init music

		move.l	oldusp(pc),-(sp)	; user mode
		move.w	#$20,-(sp)		;
		trap	#1			;
		addq.l	#6,sp			;

		clr.w   -(sp)                   ; pterm()
		move.w	#$4c,-(sp)		;
		trap    #1      		;


timerc:		move.w	sr,-(sp)		; store status register
		move.w  #$2500,sr		; enable interrupts except vbl (allows timer effects)
		sub.w	#50,fiftycount		; 50Hz replay
		bne.s	.noplay
		move.w	#200,fiftycount
		bsr 	MUSIC+4			; call music
.noplay		move.w	(sp)+,sr		; restore status register
	        move.l  oldtc(pc),-(sp)		; go to old vector (system friendly ;) )
	        rts

oldtc:		ds.l	1
oldusp:		ds.l	1
fiftycount:	dc.w	200

;.......................................................
MUSIC:		incbin	'trisound.drv'
		even
voice_set:      incbin 	'insignia.tvs'
            	even
song:		incbin 	'axelfoly.tri'
                even

;.......................................................
		end