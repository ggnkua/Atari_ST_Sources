;*********************************************************
;
;              routines modified from
;
;                   Music Analyzer
;               by Roel van de Kraats
;                       1995
;
;*********************************************************

	EXPORT	draw_scope
	EXPORT	draw_spectrum
	EXPORT	draw_vu

	IMPORT	xm,ym,bitplanes

;;len_of_scr	equ	153600
len_scopebuf	equ	128*256/8*4
len_vubuf	equ	44*80/8*4
len_iconsbuf	equ	32/8*4*32*22
len_mstxtbuf	equ	12*64/8*4
len_lrbuf	equ	80*(80/8*4+2*8/8*4)
;;b_line		equ	320	; # of bytes on line
points		equ	256



;*********************************************************

		TEXT

;---------------------------------------------------------
;*********************************************************

draw_vu:
		movem.l	d0-a6,-(a7)	;save registers

		;clear vu background
		move.l	vubuf,a0
		move.l	scr,a1
;		adda.l	#b_line*45+(48/8*4)+40,a1
		move.w	#43,d0
loop_clrvu:
		movem.l (a0)+,d1-d7/a2-a4
		movem.l d1-d7/a2-a4,-(a1)
		adda.w	#232+40,a1
		movem.l d1-d7/a2-a4,-(a1)
;		adda.w	#b_line-232+40,a1
		dbra	d0,loop_clrvu

		;draw vu's
		move.w	#88,d0
		move.w	leftvu,d1
		lsr.w	#8,d1
		bsr	put_vu
		move.w	#552,d0
		move.w	rightvu,d1
		lsr.w	#8,d1
		bsr	put_vu
		
		movem.l	(a7)+,d0-a6	;restore registers
		rts



;*********************************************************

;d0=x, d1=angle
put_vu:
		lea	vu_x,a0
		ext.w	d1
		move.w	(a0,d1*2),d2	;x
		move.w	d2,d5		;dx
		add.w	d0,d2
		lea	vu_y,a0
		move.w	(a0,d1*2),d3	;y
		move.w	d3,d4		;dy
		add.w	#96,d3

		ext.l	d5
		lsl.l	#8,d5		;dx*256
		divs	d4,d5		;dx*256/dy
		ext.l	d5
		ext.l	d2
		lsl.l	#8,d2		;x*256

		move.l	scr,a0
		move.w	d3,d0
;		mulu.w	#b_line,d0
		add.l	d0,a0		;addr of 1st line

loop_pvu:
		cmp.w	#89-2,d3	;shadow still in range?
		bge	cont_pvu	;no

		move.l	a0,a1
		move.l	d2,d0
		sub.l	#256*2,d0
		lsr.l	#8,d0
		move.w	d0,d1
		lsr.w	#4,d0
		lsl.w	#3,d0
		add.w	d0,a1
		and.w	#$f,d1
		moveq	#0,d7
		neg.w	d1
		add.w	#15,d1
		bset	d1,d7

		move.w	d7,d6
		not.w	d6

;		move.w	(b_line*2,a1),d0
;		or.w	(b_line*2+2,a1),d0
;		or.w	(b_line*2+4,a1),d0
;		or.w	(b_line*2+6,a1),d0
		and.w	d7,d0
		bne	cont_pvu		;not on white background

;		and.w	d6,(b_line*2,a1)
;		or.w	d7,(b_line*2+2,a1)
;		or.w	d7,(b_line*2+4,a1)
;		or.w	d7,(b_line*2+6,a1)
cont_pvu:
		move.l	a0,a1
		move.l	d2,d0
		lsr.l	#8,d0
		move.w	d0,d1
		lsr.w	#4,d0
		lsl.w	#3,d0
		add.w	d0,a1
		and.w	#$f,d1
		moveq	#0,d7
		neg.w	d1
		add.w	#15,d1
		bset	d1,d7

		or.w	d7,(a1)
		or.w	d7,2(a1)
		or.w	d7,4(a1)
		or.w	d7,6(a1)

;		add.w	#b_line,a0
		add.l	d5,d2

		addq.w	#1,d3
		cmp.w	#89,d3
		bne	loop_pvu

		rts	;from put_vu



;---------------------------------------------------------
;*********************************************************

draw_spectrum:
		movem.l	d0-a6,-(a7)	;save registers

		;clear spectrum analyzer bars
		move.l	scr,a0
;		adda.l	#b_line*160+4*8+112,a0
		move.l	a0,a1
		adda.w	#18*8,a1
		moveq	#0,d1
		move.l	d1,d2
		move.l	d1,d3
		move.l	d1,d4
		move.l	d1,d5
		move.l	d1,d6
		move.l	d1,d7
		move.l	d1,a2
		move.l	d1,a3
		move.l	d1,a4
		move.w	#113,d0
loop_clrsp:	movem.l d1-d7/a2-a3,-(a0)
		movem.l d1-d7/a2-a3,-(a0)
		movem.l d1-d7/a2-a4,-(a0)
		movem.l d1-d7/a2-a3,-(a1)
		movem.l d1-d7/a2-a3,-(a1)
		movem.l d1-d7/a2-a4,-(a1)
;		adda.w	#b_line+112,a0
;		adda.w	#b_line+112,a1
		dbra	d0,loop_clrsp


		;put spectrum analyzer bars
		move.w	#13,d2
		lea	buf2,a1
		lea	left_bars,a3
		lea	log2,a2
		move.w	#4,d3
loop_putlbars:
		move.w	(a1)+,d1
		addq.l	#1,a1
		and.w	#$7ff,d1
		move.b	(a2,d1),d1
		and.w	#$ff,d1
		move.w	(a3),d4
		sub.w	d4,d1
		asr.w	#1,d1			;slow it down a little
		add.w	d4,d1
		move.w	d1,(a3)+

		move	d3,d0
		bsr	draw_bar
		addq.w	#1,d3
		dbra	d2,loop_putlbars


		move.w	#13,d2
		;lea	buf2+14*3,a1
		lea	right_bars,a3
		;lea	log2,a2
		move.w	#22,d3
loop_putrbars:
		move.w	(a1)+,d1
		addq.l	#1,a1
		and.w	#$7ff,d1
		move.b	(a2,d1),d1
		and.w	#$ff,d1
		move.w	(a3),d4
		sub.w	d4,d1
		asr.w	#1,d1
		add.w	d4,d1
		move.w	d1,(a3)+

		move	d3,d0
		bsr	draw_bar
		addq.w	#1,d3
		dbra	d2,loop_putrbars

		bra	no_freeze

freeze2:


		;put spectrum analyzer bars
		move.w	#13,d2
		lea	left_bars,a3
		move.w	#4,d3
loop_putlbars2:
		move.w	(a3)+,d1
		move	d3,d0
		bsr	draw_bar
		addq.w	#1,d3
		dbra	d2,loop_putlbars2

		move.w	#13,d2
		lea	right_bars,a3
		move.w	#22,d3
loop_putrbars2:
		move.w	(a3)+,d1
		move	d3,d0
		bsr	draw_bar
		addq.w	#1,d3
		dbra	d2,loop_putrbars2

no_freeze:

		movem.l	(a7)+,d0-a6	;restore registers
		rts  	;from draw_spectrum



;*********************************************************

;draw bar for spectrum analyzer
;d0=x, d1=h
draw_bar:
		move.l	scr,a0
;		adda.l	#272*b_line,a0
		lsl.w	#3,d0
		adda.w	d0,a0
		moveq	#$00000000,d4
		move.l	#$00003ffc,d5
		move.l	#$3ffc3ffc,d6
		move.l	#$3ffc0000,d7
		move.l	d5,(a0)
		move.l	d4,4(a0)
;		sub.w	#b_line,a0
		subq.w	#1,d1
		bge	cont_db
		rts
cont_db:
loop_db:	move.l	d6,(a0)
		move.l	d7,4(a0)
;		move.l	d5,-b_line(a0)
;		move.l	d4,4-b_line(a0)
;		sub.w	#b_line*2,a0
		dbra	d1,loop_db
		rts



;---------------------------------------------------------
;*********************************************************
; -> A0: data to show
; -> D0: X-position on screen
; -> D1: Y-position on screen

draw_scope:
		movem.l	d0-a6,-(a7)	;save registers

		move.l	a0,dataptr	;save data pointer
		and.w	#$FFF0,d0 	;X = N x 16 pixels
		move.w	d0,x
		move.w	d1,y

		move.w	#3,-(a7)	;Logbase()
		trap 	#14		;XBIOS
		add.l	#2,a7
		move.l	d0,scr	;save pointer to video memory

		;compute line length in bytes
		move.w	bitplanes,d3
		mulu.w	xm,d3
		lsr.l	#3,d3	;/8
		move.l	d3,linelen

		move.l	scr,a2
		move.w	y,d3
		mulu.w	linelen+2,d3
		add.l	d3,a2
		move.w	x,d1
		mulu.w	bitplanes,d1
		lsr.l	#3,d1	;X x bitplanes / 8 = X in bytes
		add.l	d1,a2
		move.l	a2,scr	;correct scr

;*** clear scope background ***
		move.l	a2,a0
		move.w	bitplanes,d2
		add.w	d2,d2
		ext.l	d2
		move.l	linelen,d3	;D3 = line length
		move.w	#128,d0		;height
loop_clrsc:
		move.l	a0,a1
		move.w	#256/16-1,d1	;width in words
loop_clrx:
		clr.w	(a1)
		add.l  	d2,a1	;add 2 * num. of bitplanes
		dbra		d1,loop_clrx

		add.l	d3,a0	;increment Y
		dbra		d0,loop_clrsc

;*** show samples ***
		move.w	x,d0
		move.w	y,d1
		move.l	dataptr,a0
		bsr  	put_scope

		movem.l	(a7)+,d0-a6	;restore registers
		rts  	;from draw_scope



;*********************************************************

; heavily optimized 10.2.1996 by Martin Hejral;
; now works in ANY bitplane resolutions (ugly screen constants
; removed), free positioning is possible

; -> D0.w = start x
; -> D1.w = start y
; -> A0.l point to sound data

put_scope:
		clr.l	d4
		bset 	#15,d4	;D4: bit on X-position is SET

		move.b	(a0),d7	;D7 = first data point
		ext.w	d7
		asr.w	d7
		neg.w	d7
;;		add.w	#64,d7

		move.l	scr,a2
		move.w	d7,d3	;Ydata
		add.w	#64,d3	;+ axis offs.
		mulu.w	linelen+2,d3
		add.l	d3,a2
;		move.w	d0,d1	;X
;		mulu.w	bitplanes,d1
;		lsr.l	#2,d1	;X x bitplanes / 4 = X in bytes
;		add.l	d1,a2	;A2: point to screen memory
		move.l	a2,a1	;A1: point to first location for output

		move.w	#254,d1	;X counter
loop_ps:
		;*** for all samples ***
		addq.w	#2*2,a0		;increment data pointer (if 1 stereo channel is used)
		move.b	(a0),d2		;D2 = next data point
		ext.w	d2
		asr.w	d2
		neg.w	d2
;;		add.w	#64,d2

		move.l	linelen,d6	;D6 = - size of screen line in B
		neg.l	d6
		move.w	d7,d3		;D3 = previous data (Y)
		sub.w	d2,d7		;D7 -= D2 -> Y difference between 2 points
		bpl  	cont_ps		;go if plus

		neg.w	d6	;change sign of number
		neg.w	d7	;change sign of number
cont_ps:
		move.w	d7,d0
		lsr.w	#1,d7		;Y difference / 2
		sub.w	d7,d0
		sub.w	#1,d0		;for DBRA
		bge  	draw_col		;if D0 counter >= 0 draw column

		or.w 	d4,(a1)		;draw point and don't change Y
		bra  	skip_col
draw_col:
		;*** 1. column with height = Y diff. / 2 ***
		or.w 	d4,(a1)
		adda.w	d6,a1		;next Y
		dbra 	d0,draw_col
skip_col:
		ror.w	d4			;increment X
		bpl  	cont_ps2

		add.w	bitplanes,a1	;next word in bitplane
		add.w	bitplanes,a1	;next word in bitplane
cont_ps2:
		move.w	d7,d0		;Y difference / 2
		sub.w	#1,d0		;for DBRA
		blt  	skip_col2
col2:
		;*** 2. column with height = Y diff. / 2 ***
		or.w 	d4,(a1)
		adda.w	d6,a1		;next Y
		dbra 	d0,col2
skip_col2:
		move.w	d2,d7		;D7 = previous data (sample) is current in this loop
		dbra 	d1,loop_ps	;next X (get next sample)

		rts  	;from put_scope



;---------------------------------------------------------
;*********************************************************

;d0=x,d1=y,a6=scr
	MACRO	draw_point
		ext.l	d1
		lsl.l	#6,d1			;
		move.l	d1,d2			;* b_line
		lsl.l	#2,d1			;
		add.l	d1,d2			;
		move.w	d0,d1
		and.w	#$f,d1
		and.b	#$f0,d0
		lsr.w	#1,d0
		ext.l	d0
		add.l	d0,d2
		moveq	#0,d0
		neg.w	d1
		add.w	#15,d1
		bset	d1,d0
		;move.w	d0,d1
		;not.w	d1

		;color 10 : green

		;and.w	d1,(a6,d2.l)		;these bitplanes don't change
		or.w	d0,2(a6,d2.l)
		;and.w	d1,4(a6,d2.l)
		or.w	d0,6(a6,d2.l)
	ENDM



;Draw line using Bresenham line plot algorithm:
;
;	..
;	..
;	e:=2*deltay-deltax;
;	for i:=0 to deltax do begin
;		Plot(x,y);
;		if e>0 then begin
;			y:=y+1;
;			e:=e+2*deltay-2*deltax;
;		end
;		else
;			e:=e+2*deltay;
;		x:=x+1;
;	end;
;	..
;	..
;
;d0=x1,d1=y1,d2=x2,d3=y2
;a6=screen address (used in macro draw_point)
draw_line:
		cmp.w	d2,d0		;x2,x1
		ble	cont_dl1	;x2>=x1
		move.w	d2,d7		;x2
		move.w	d0,d2
		move.w	d7,d0
		move.w	d3,d7		;y2
		move.w	d1,d3
		move.w	d7,d1
cont_dl1:
		move.w	d2,d6		;x2
		sub.w	d0,d6		;x2-x1=deltax
		move.w	d3,d7		;y2
		sub.w	d1,d7		;y2-y1=deltay

		cmp.w	d3,d1		;y2,y1
		ble	cont_dl2	;y2>=y1

		neg.w	d7		;deltay=-deltay
		cmp.w	d7,d6		;deltay,deltax
		bge	cont_dl3	;deltay<=deltax

		move.w	d0,a0		;x1
		move.w	d1,a1		;y1
		move.w	d6,d3		;e=deltax
		add.w	d3,d3		;*2
		sub.w	d7,d3		;-deltay
		move.w	d7,d4		;deltay

		add.w	d6,d6		;2*deltax
		add.w	d7,d7		;2*deltay
loop_dl1:
		move.w	a0,d0		;x
		move.w	a1,d1		;y
		draw_point
		tst.w	d3		;e
		ble	cont_dl5	;e<=0
		addq.w	#1,a0		;x+=1
		add.w	d6,d3		;e=e+(2*deltax-2*deltay)
		sub.w	d7,d3
		bra	cont_dl6
cont_dl5:				;e<=0
		add.w	d6,d3		;e=e+2*deltax
cont_dl6:
		subq.w	#1,a1		;y-=1

		dbra	d4,loop_dl1

		rts


cont_dl3:				;deltay<=deltax

		move.w	d0,a0		;x1
		move.w	d1,a1		;y1
		move.w	d7,d3		;e=deltay
		add.w	d3,d3		;*2
		sub.w	d6,d3		;-deltax
		move.w	d6,d4		;deltax

		add.w	d6,d6		;2*deltax
		add.w	d7,d7		;2*deltay
loop_dl2:
		move.w	a0,d0		;x
		move.w	a1,d1		;y
		draw_point
		tst.w	d3		;e
		ble	cont_dl7	;e<=0
		subq.w	#1,a1		;y-=1
		add.w	d7,d3		;e=e+(2*deltay-2*deltax)
		sub.w	d6,d3
		bra	cont_dl8
cont_dl7:				;e<=0
		add.w	d7,d3		;e=e+2*deltay
cont_dl8:
		addq.w	#1,a0		;x+=1

		dbra	d4,loop_dl2

		rts
cont_dl2:				;y2>=y1
		cmp.w	d7,d6		;deltay,deltax
		bge	cont_dl4	;deltay<=deltax


		move.w	d0,a0		;x1
		move.w	d1,a1		;y1
		move.w	d6,d3		;e=deltax
		add.w	d3,d3		;*2
		sub.w	d7,d3		;-deltay
		move.w	d7,d4		;deltay

		add.w	d6,d6		;2*deltax
		add.w	d7,d7		;2*deltay
loop_dl3:
		move.w	a0,d0		;x
		move.w	a1,d1		;y
		draw_point
		tst.w	d3		;e
		ble	cont_dl9	;e<=0
		addq.w	#1,a0		;x+=1
		add.w	d6,d3		;e=e+(2*deltax-2*deltay)
		sub.w	d7,d3
		bra	cont_dl10
cont_dl9:				;e<=0
		add.w	d6,d3		;e=e+2*deltax
cont_dl10:
		addq.w	#1,a1		;y+=1

		dbra	d4,loop_dl3

		rts
cont_dl4:				;deltay<=deltax

		move.w	d0,a0		;x1
		move.w	d1,a1		;y1
		move.w	d7,d3		;e=deltay
		add.w	d3,d3		;*2
		sub.w	d6,d3		;-deltax
		move.w	d6,d4		;deltax

		add.w	d6,d6		;2*deltax
		add.w	d7,d7		;2*deltay
loop_dl4:
		move.w	a0,d0		;x
		move.w	a1,d1		;y
		draw_point
		tst.w	d3		;e
		ble	cont_dl11	;e<=0
		addq.w	#1,a1		;y+=1
		add.w	d7,d3		;e=e+(2*deltay-2*deltax)
		sub.w	d6,d3
		bra	cont_dl12
cont_dl11:				;e<=0
		add.w	d7,d3		;e=e+2*deltay
cont_dl12:
		addq.w	#1,a0		;x+=1

		dbra	d4,loop_dl4

		rts



;*********************************************************
;*********************************************************
;*********************************************************

		DATA

; ------------ 'log_spec.s' ---------------

		EVEN

log2:	;33 dB, with cutoff. for spectrum analyzer
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,1,2,3,3,4,5,6,6,7
		dc.b	7,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15
		dc.b	16,16,16,17,17,18,18,18,19,19,19,20,20,20,21,21
		dc.b	21,22,22,22,23,23,23,23,24,24,24,25,25,25,25,26
		dc.b	26,26,26,27,27,27,27,28,28,28,28,29,29,29,29,29
		dc.b	30,30,30,30,30,31,31,31,31,31,32,32,32,32,32,33
		dc.b	33,33,33,33,33,34,34,34,34,34,34,35,35,35,35,35
		dc.b	35,36,36,36,36,36,36,37,37,37,37,37,37,37,38,38
		dc.b	38,38,38,38,38,39,39,39,39,39,39,39,40,40,40,40
		dc.b	40,40,40,40,41,41,41,41,41,41,41,41,41,42,42,42
		dc.b	42,42,42,42,42,43,43,43,43,43,43,43,43,43,44,44
		dc.b	44,44,44,44,44,44,44,44,45,45,45,45,45,45,45,45
		dc.b	45,45,46,46,46,46,46,46,46,46,46,46,47,47,47,47
		dc.b	47,47,47,47,47,47,47,48,48,48,48,48,48,48,48,48
		dc.b	48,48,48,49,49,49,49,49,49,49,49,49,49,49,49,50
		dc.b	50,50,50,50,50,50,50,50,50,50,50,50,51,51,51,51
		dc.b	51,51,51,51,51,51,51,51,51,52,52,52,52,52,52,52
		dc.b	52,52,52,52,52,52,52,53,53,53,53,53,53,53,53,53
		dc.b	53,53,53,53,53,53,54,54,54,54,54,54,54,54,54,54
		dc.b	54,54,54,54,54,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55
		dc.b	55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55;		even

;mainscrdat:	incbin	'mainscr.img'


; ------------ 'log_vu.s' ---------------

		EVEN

log:		;20 dB, for vu
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,1,1,1,2,2,2,3,3,4
		dc.b	4,4,5,5,5,6,6,6,7,7,7,7,8,8,8,9
		dc.b	9,9,10,10,10,11,11,11,11,12,12,12,13,13,13,13
		dc.b	14,14,14,14,15,15,15,15,16,16,16,16,17,17,17,17
		dc.b	18,18,18,18,19,19,19,19,20,20,20,20,20,21,21,21
		dc.b	21,22,22,22,22,22,23,23,23,23,24,24,24,24,24,25
		dc.b	25,25,25,25,26,26,26,26,26,27,27,27,27,27,28,28
		dc.b	28,28,28,28,29,29,29,29,29,30,30,30,30,30,30,31
		dc.b	31,31,31,31,31,32,32,32,32,32,32,33,33,33,33,33
		dc.b	33,34,34,34,34,34,34,35,35,35,35,35,35,36,36,36
		dc.b	36,36,36,36,37,37,37,37,37,37,37,38,38,38,38,38
		dc.b	38,38,39,39,39,39,39,39,39,40,40,40,40,40,40,40
		dc.b	41,41,41,41,41,41,41,41,42,42,42,42,42,42,42,43
		dc.b	43,43,43,43,43,43,43,44,44,44,44,44,44,44,44,45
		dc.b	45,45,45,45,45,45,45,46,46,46,46,46,46,46,46,46
		dc.b	47,47,47,47,47,47,47,47,47,48,48,48,48,48,48,48
		dc.b	48,48,49,49,49,49,49,49,49,49,49,50,50,50,50,50
		dc.b	50,50,50,50,51,51,51,51,51,51,51,51,51,51,52,52
		dc.b	52,52,52,52,52,52,52,52,53,53,53,53,53,53,53,53
		dc.b	53,53,54,54,54,54,54,54,54,54,54,54,55,55,55,55
		dc.b	55,55,55,55,55,55,55,56,56,56,56,56,56,56,56,56
		dc.b	56,56,57,57,57,57,57,57,57,57,57,57,57,58,58,58
		dc.b	58,58,58,58,58,58,58,58,58,59,59,59,59,59,59,59
		dc.b	59,59,59,59,59,60,60,60,60,60,60,60,60,60,60,60
		dc.b	60,61,61,61,61,61,61,61,61,61,61,61,61,62,62,62
		dc.b	62,62,62,62,62,62,62,62,62,62,63,63,63,63,63,63
		dc.b	63,63,63,63,63,63,63,64,64,64,64,64,64,64,64,64
		dc.b	64,64,64,64,64,65,65,65,65,65,65,65,65,65,65,65
		dc.b	65,65,65,66,66,66,66,66,66,66,66,66,66,66,66,66
		dc.b	66,67,67,67,67,67,67,67,67,67,67,67,67,67,67,68
		dc.b	68,68,68,68,68,68,68,68,68,68,68,68,68,68,69,69
		dc.b	69,69,69,69,69,69,69,69,69,69,69,69,69,69,70,70
		dc.b	70,70,70,70,70,70,70,70,70,70,70,70,70,71,71,71
		dc.b	71,71,71,71,71,71,71,71,71,71,71,71,71,72,72,72
		dc.b	72,72,72,72,72,72,72,72,72,72,72,72,72,72,73,73
		dc.b	73,73,73,73,73,73,73,73,73,73,73,73,73,73,73,74
		dc.b	74,74,74,74,74,74,74,74,74,74,74,74,74,74,74,74
		dc.b	75,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75
		dc.b	75,75,76,76,76,76,76,76,76,76,76,76,76,76,76,76
		dc.b	76,76,76,76,77,77,77,77,77,77,77,77,77,77,77,77
		dc.b	77,77,77,77,77,77,77,78,78,78,78,78,78,78,78,78
		dc.b	78,78,78,78,78,78,78,78,78,78,79,79,79,79,79,79
		dc.b	79,79,79,79,79,79,79,79,79,79,79,79,79,79,80,80
		dc.b	80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80
		dc.b	80,80,80,81,81,81,81,81,81,81,81,81,81,81,81,81
		dc.b	81,81,81,81,81,81,81,82,82,82,82,82,82,82,82,82
		dc.b	82,82,82,82,82,82,82,82,82,82,82,82,82,83,83,83
		dc.b	83,83,83,83,83,83,83,83,83,83,83,83,83,83,83,83
		dc.b	83,83,83,84,84,84,84,84,84,84,84,84,84,84,84,84
		dc.b	84,84,84,84,84,84,84,84,84,85,85,85,85,85,85,85
		dc.b	85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85
		dc.b	86,86,86,86,86,86,86,86,86,86,86,86,86,86,86,86
		dc.b	86,86,86,86,86,86,86,86,87,87,87,87,87,87,87,87
		dc.b	87,87,87,87,87,87,87,87,87,87,87,87,87,87,87,87
		dc.b	88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88
		dc.b	88,88,88,88,88,88,88,88,88,89,89,89,89,89,89,89
		dc.b	89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89
		dc.b	89,89,90,90,90,90,90,90,90,90,90,90,90,90,90,90



; ------------ relative coordinates for vu ------------
;0 to 90 degrees

		EVEN

vu_x:	DC.W	-31,-31,-30,-29,-29,-28,-28,-27
		DC.W	-26,-26,-25,-25,-24,-23,-23,-22
		DC.W	-21,-21,-20,-19,-19,-18,-17,-16
		DC.W	-16,-15,-14,-14,-13,-12,-11,-11
		DC.W	-10,-9,-8,-8,-7,-6,-5,-5
		DC.W	-4,-3,-2,-2,-1, 0, 1, 2
		DC.W	 2, 3, 4, 5, 5, 6, 7, 8
		DC.W	 8, 9, 10, 11, 11, 12, 13, 14
		DC.W	 14, 15, 16, 16, 17, 18, 19, 19
		DC.W	 20, 21, 21, 22, 23, 23, 24, 25
		DC.W	 25, 26, 26, 27, 28, 28, 29, 29
		DC.W	 30, 31, 31
vu_y:	DC.W	-31,-32,-32,-33,-33,-34,-34,-35
		DC.W	-35,-36,-36,-36,-37,-37,-38,-38
		DC.W	-38,-39,-39,-40,-40,-40,-41,-41
		DC.W	-41,-41,-42,-42,-42,-42,-43,-43
		DC.W	-43,-43,-43,-43,-43,-44,-44,-44
		DC.W	-44,-44,-44,-44,-44,-44,-44,-44
		DC.W	-44,-44,-44,-44,-44,-44,-43,-43
		DC.W	-43,-43,-43,-43,-43,-42,-42,-42
		DC.W	-42,-41,-41,-41,-41,-40,-40,-40
		DC.W	-39,-39,-38,-38,-38,-37,-37,-36
		DC.W	-36,-36,-35,-35,-34,-34,-33,-33
		DC.W	-32,-32,-31



;*********************************************************

		BSS

		EVEN

x:			ds.w	1
y:			ds.w	1

scr:			ds.l	1	;pointer to video memory
linelen:		ds.l	1	;size of screen line in bytes

scopebuf:		ds.l	1
vubuf:		ds.l	1
lrbuf:		ds.l	1
lr_filter:	ds.w	2
lr_coor:	ds.w	258*2


dataptr:	ds.l	1
buf:		ds.b	6
buf2:		ds.b	14*3*2


left_bars:	ds.w	14
right_bars:	ds.w	14
leftvu: 	ds.w	1
rightvu:	ds.w	1


		END
