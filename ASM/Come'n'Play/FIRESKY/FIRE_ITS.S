; 128 bytes intro: Fire in the sky
; by calimero / come'n'play

;              e-mail: ddcc@net.yu

;basic of this intro is:
;  a1    a1=(a1+a2+a3+a4)/4
;a2a5a3
;
;  a4

Start:

fire_size	=	160*48

	move.w	#$20,-(a7)
	trap	#1			;supervisor mode
	move.w	#2,-(sp)
	trap	#14			;video memory in d0
	addq	#4,sp
	move.l	d0,a5

next_frame:

;this will fill line with "random" pixels
	lea		640*44(a5),a2
	lea		640*47(a5),a3
	move.w	#320-1,d4
rnd:
	move.w	(a2)+,d5
	roxr	#8,d5
	move.w	d5,(a3)+	
	dbra	d4,rnd
	
;here we set pointers in video memory
	lea		-2(a5),a1
	lea		fire_size*4+1280(a1),a2
	lea		fire_size*4+1280(a2),a3
	lea		fire_size*4+1280(a3),a4

	move.l	#fire_size*2,d5		;do xx lines

do_screen:
	move.w	-640(a1),d7
	add.w	-2(a1),d7
	add.w	2(a1),d7
	add.w	640*2(a1),d7
	move.w	d7,d1
	
	lsr.w	#2,d1
	and		#%1111111111100000,d1
	move.w	d1,-640(a1)

	ror		#7,d7
	move.w	d7,(a2)+

	and		#%0000000000111111,d7
	move.w	d7,(a3)+

	asr.w	#3,d1
	and		#%1111111111100000,d1
	move.w	d1,(a4)+

	addq.w	#2,a1
	dbra	d5,do_screen
	cmp.b	#$39,$fffffc02.w	;space pressed?
	bne.s	next_frame			;if not repeat

	clr.w	-(sp)	
	trap	#1		;end of program

