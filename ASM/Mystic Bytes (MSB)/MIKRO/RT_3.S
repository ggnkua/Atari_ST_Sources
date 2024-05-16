		OPT	P=68040				; 68040 code allowed
		COMMENT	HEAD=%100111			; Super,MallocInTT-RAM,LoadInTT-RAM,Fastload off
		OUTPUT	.TOS
		OPT	D-
		
SCR_W:		EQU	320				; width  (x - in pixels)
SCR_H:		EQU	192				; height (y - in pixels)

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

begin:		clr.l	-(sp)				; super()
		move.w	#$20,-(sp)			;
		trap	#1				;
		;addq.l	#6,sp				;
		
		movea.l	$44e.w,a6
		add.w	#SCR_W*2*10,a6
		
		;move.w	#$134,-(sp)			; vsetmode() (320x200/hc VGA)
		;move.w	#$58,-(sp)
		move.l	#$00580134,-(sp)
		trap	#14
		;addq.l	#4,sp

		move.w	#SCR_W*2*2/2,d0			; "next" right adder & left adder << 1
		;clr.w	d4
		move.w	#SCR_H*2/2,d5			; screen height / 2 in init << 1
		moveq	#6-1,d7				; six divisions
		
.outloop:	tst.w	d7
		beq.b	.last0
		
		lsr.w	#1,d0				; left adder /= 2 & "next" right adder /= 2
		lsr.w	#1,d5				; hight /= 2

.last0:		move.w	d5,d6
		subq.w	#1,d6
		


.inloop:	tst.w	d7
		beq.b	.last
		adda.w	d0,a6

.last:		move.w	d0,d3
		subq.w	#1,d3
		
.innerloop:	not.b	(a6)+
		dbra	d3,.innerloop
		
		adda.w	d4,a6				; d4.w = 0 in init
		dbra	d6,.inloop
		
		
		
		add.w	d0,d4
		
.skip:		dbra	d7,.outloop
		
		bra.b	*
		