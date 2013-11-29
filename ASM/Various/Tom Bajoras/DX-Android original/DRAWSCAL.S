;*****************************************************************************;
;   routines to draw keyboard scaling curve display
;   Copyright 1986 Tom Bajoras
;   entry condition: x5.b = color, d6.l = op #
;*****************************************************************************;

 .text

 .global drawsce
 .global drawscw

drawsce 	movem.l 	#$FFFE,-(a7)	; save registers
			move.l  	x1,-(a7)		; save x1-x5
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)
			movea.l 	#0,a3   		; curves will be solid
			lea 		edspace,a2  	; a2 --> edited version
			bra 		drawscx
drawscw 	movem.l 	#$FFFE,-(a7)	; save registers
			move.l  	x1,-(a7)		; save x1-x5
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)
			movea.l 	#1,a3   		 ;curves will be dotted
			lea 		wkspace,a2  	; a2 --> original version

drawscx 	move.b  	cmessge,x5  	; color for all scaling curves
			move.l  	#113,d7
			move.l  	d6,d1
			mulu		#21,d1
			sub.l   	d1,d7   	; d7.l --> bp
			move.l  	#21,d0
			add.b   	0(a2,d7.l),d0   ; d0.l = key # (0-127)
			bsr 		convert 		; convert d0 into d1.l = x-coord
			clr.w   	d0
			move.b  	8(a2,d7.l),d0   	; d0.w = level = 0-99
			beq 		.skipbp
			move.w  	#116,x2
			move.w  	#116,x4
			sub.w   	d0,x4
			move.w  	d1,x1
			move.w  	d1,x3
			bsr 		loc_line
; arguments for curve-drawing
.skipbp 	move.b  	0(a2,d7.l),x1   	; bp
			move.b  	8(a2,d7.l),x2   	; level
			move.b  	1(a2,d7.l),x3   	; left depth
; x5.b = color
			lea 		.next1,a6   		; a6 --> return address
			tst.b   	3(a2,d7.l)  	 ; -L?
			beq 		l_min_l
			cmpi.b  	#1,3(a2,d7.l)
			beq 		l_min_e
			cmpi.b  	#2,3(a2,d7.l)
			beq 		l_plu_e
			bra 		l_plu_l
; arguments for curve-drawing
.next1  	move.b  	0(a2,d7.l),x1   	; bp
			move.b  	8(a2,d7.l),x2   	; level
			move.b  	2(a2,d7.l),x3   	; right depth
; x5.b = color
			lea 		.next2,a6   		 ; a6 --> return address
			tst.b   	4(a2,d7.l)  	  ; -L?
			beq 		r_min_l
			cmpi.b  	#1,4(a2,d7.l)
			beq 		r_min_e
			cmpi.b  	#2,4(a2,d7.l)
			beq 		r_plu_e
			bra 		r_plu_l

; repair axes system
.next2  	jsr 		drawaxes

.return 	move.l  	(a7)+,x5		; restore x5-x1
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1
			movem.l 	(a7)+,#$7FFF	; restore registers
			rts 					;   return

;*****************************************************************************;
;   routine to convert d0.l=key # into d1.l = x-pixel value
;*****************************************************************************;

 .global convert

convert 	move.l  	d0,-(a7)	; save d0
			move.l  	d2,-(a7)	; and d2

			divu		#12,d0
			clr.l   	d1
			move.w  	d0,d1   	; d1.l = octave (0-10)
			lsr.l   	#8,d0
			lsr.l   	#8,d0   	; d0.l = key (0-11)
			mulu		#56,d1
			add.l   	#23,d1
			move.l  	d0,d2
			mulu		#4,d2
			add.l   	d2,d1
			cmpi.l  	#3,d0
			ble 		.conv_ret
			addq.l  	#2,d1
			cmpi.l  	#4,d0
			ble 		.conv_ret
			addq.l  	#2,d1
			cmpi.l  	#10,d0
			ble 		.conv_ret
			addq.l  	#2,d1
.conv_ret   move.l  	(a7)+,d2
			move.l  	(a7)+,d0	; restore d2 and d0
			rts

;*****************************************************************************;
;   routines to draw curves
;   x1.b=bp (0-99), x2.b=level (0-99), x3.b = scaling depth (0-99)
;   a6--> return addres
;*****************************************************************************;

 .global l_min_l
 .global l_min_e
 .global l_plu_e
 .global l_plu_l
 .global r_min_l
 .global r_min_e
 .global r_plu_e
 .global r_plu_l

l_min_l 	movem.l 	#$FFFE,-(a7)	; save registers
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)	; save x1-x5

			clr.l   	d5
			move.b  	x1,d5   	; d5.l = bp
			add.l   	#21,d5  	; d5.l = bp (key #)
			clr.l   	d6
			move.b  	x2,d6   	; d6.l = level (0-99)
			clr.l   	d7
			move.b  	x3,d7   	; d7.l = depth (0-99)

			move.l  	d5,d0
			bsr 		convert
			move.w  	d1,x1   	; x1
			move.w  	#116,x2
			sub.w   	d6,x2   	; y1
			tst.l   	d7
			beq 		.lml1
			tst.l   	d6
			beq 		.lml1
			move.l  	#10000,d0   ; d and L both nonzero
			divu		d7,d0
			andi.l  	#$FFFF,d0
			mulu		d6,d0
			divu		#292,d0
			andi.l  	#$FFFF,d0
			move.l  	d5,d1
			sub.l   	d0,d1   	; d1.l = b - 10000L/d/292
			ble 		.lml2
			move.w  	#116,x4 	; line doesn't hit left margin
			move.l  	d1,d0
			bsr 		convert
			move.w  	d1,x3
			bra 		.doit
.lml2   	move.l  	d1,d0
			sub.l   	d5,d1   	; d1.l = k'-b
			neg.l   	d1  		; d1.l = b-k'
			neg.l   	d0
			mulu		d6,d0   	; d0.l = -k'L
			divu		d1,d0   	; d0.l = -k'L / (b-k')
			andi.l  	#$FFFF,d0   ; discard remainder
			move.w  	#116,x4
			sub.w   	d0,x4
			clr.l   	d0
			bsr 		convert
			move.w  	d1,x3
			bra 		.doit
.lml1   	clr.l   	d0  	  ; d or L is 0
			bsr 		convert
			move.w  	d1,x3
			move.w  	#116,x4
			sub.w   	d6,x4
.doit   	bsr 		loc_line
			bra 		return

l_min_e 	movem.l 	#$FFFE,-(a7)	; save registers
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)	; save x1-x5
			movea.l 	#0,a0   	   ; a0.l = 0 means -exp curve
			bra 		left_exp

l_plu_e 	movem.l 	#$FFFE,-(a7)	; save registers
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)	; save x1-x5
			movea.l 	#1,a0   	; a0.l=1 means +exp curve

left_exp	clr.l   	d5  		; common code for l_min_e / l_plu_e
			move.b  	x1,d5   	; d5.l = bp
			add.l   	#21,d5  	; d5.l = bp (key #)
			clr.l   	d6
			move.b  	x2,d6   	; d6.l = level (0-99)
			clr.l   	d7
			move.b  	x3,d7   	; d7.l = depth (0-99)

			move.l  	d5,d0
			bsr 		convert
			move.w  	d1,x1   	; x1
			move.w  	#116,x2
			sub.w   	d6,x2   	; y1

			lea 		exptable,a5 	; a5.l --> table of L'(x,20,d)

			move.l  	d5,d4
			addq.l  	#5,d4
			divu		#3,d4
			andi.l  	#$FFFF,d4   ; d4.l = b-group

			move.l  	d6,d3
			sub.l   	#20,d3
			cmpi.l  	#15,d6
			bge 		.delta
			add.l   	d6,d3
			sub.l   	#15,d3
			cmpi.l  	#3,d6
			bge 		.delta
			add.l   	d6,d3
			add.l   	d6,d3
			subq.l  	#6,d3
.delta  	move.l  	d5,d2   	; d3.l = delta
.loop   	subq.l  	#1,d2   	; for d2.l = (b-1) to 0
			blt 		return
			move.l  	d2,d0
			bsr 		convert
			move.w  	d1,x3   	; x2
			move.l  	d2,d0
			addq.l  	#5,d0
			divu		#3,d0
			andi.l  	#$FFFF,d0   ; d0.l = k-group
			neg.l   	d0
			add.l   	d4,d0   	; d0.l = b-group  -  k-group
			cmpi.l  	#27,d0
			ble 		.le27
			move.l  	#27,d0  	; d0.l = min(27,bg-kg)
.le27   	move.l  	d7,d1
			mulu		#28,d1
			add.l   	d1,d0   	; d0.l = index into exptable
			clr.w   	d1
			move.b  	0(a5,d0.l),d1
			add.w   	d3,d1   	; d1.w = L'(x,L,d)
			cmpa.l  	#1,a0
			beq 		.plu		; switch according to a0
			move.w  	d6,d0
			add.w   	d6,d0
			sub.w   	d1,d0
			bge 		.ge01
			clr.w   	d0
.ge01   	cmp.w   	d6,d0
			ble 		.lel1
			move.w  	d6,d0
.lel1   	move.w  	#116,x4
			sub.w   	d0,x4
			bra 		.plu_min
.plu		cmpi.w  	#99,d1
			ble 		.le99
			move.w  	#99,d1  	; clamp L' to <100
.le99   	cmp.w   	d6,d1   	; clamp L' to >= L
			bge 		.gel2
			move.w  	d6,d1
.gel2   	move.w  	#116,x4
			sub.w   	d1,x4   	; y2
.plu_min	bsr 		loc_line
			move.w  	x3,x1
			move.w  	x4,x2   	; prepare to connect to next section
			bra 		.loop   	; end for

l_plu_l 	movem.l 	#$FFFE,-(a7)	; save registers
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)	; save x1-x5

			clr.l   	d5
			move.b  	x1,d5   	; d5.l = bp
			add.l   	#21,d5  	; d5.l = bp (key #)
			clr.l   	d6
			move.b  	x2,d6   	; d6.l = level (0-99)
			clr.l   	d7
			move.b  	x3,d7   	; d7.l = depth (0-99)

			move.l  	d5,d0
			bsr 		convert
			move.w  	d1,x1   	; x1
			move.w  	#116,x2
			sub.w   	d6,x2   	; y1
			cmpi.l  	#2,d7
			ble 		.lpl1
			move.l  	d7,d1   	; d>2
			mulu		#389,d1
			sub.l   	#860,d1 	; d1.l = 389d-860
			move.l  	#99,d0
			sub.l   	d6,d0   	; d0.l = 99-L
			mulu		#17000,d0   ; d0.l = 17000(99-L)
			divu		d1,d0
			andi.l  	#$FFFF,d0   ; d0.l = 17000(99-L)/(389-860)
			neg.l   	d0
			add.l   	d5,d0   	; d0.l = k' (99-intercept)
			cmpi.l  	#0,d0
			ble 		.lpl2
			bsr 		convert 	; line does not touch leftt margin
			move.w  	d1,x3
			move.w  	#17,x4
			bra 		.doit
.lpl2   	neg.l   	d0
			add.l   	d5,d0   	; d0.l = b-k'
			move.l  	#99,d1
			sub.l   	d6,d1   	; d1.l = 99-L
			mulu		d5,d1   	; d1.l = (99-L)b
			divu		d0,d1   	; d1.l = (99-L)b/(b-k')
			andi.l  	#$FFFF,d1
			add.l   	d6,d1
			move.w  	#116,x4
			sub.w   	d1,x4
			clr.l   	d0
			bsr 		convert
			move.w  	d1,x3
			bra 		.doit
.lpl1   	clr.l   	d0     ; d <3
			bsr 		convert
			move.w  	d1,x3
			move.w  	#116,x4
			sub.w   	d6,x4
.doit   	move.w  	x3,d2
			cmp.w   	x1,d2
			beq 		.doit2
			bsr 		loc_line
.doit2  	clr.l   	d0
			bsr 		convert
			cmp.w   	x3,d1
			beq 		return
			move.w  	x3,x1
			move.w  	x4,x2
			move.w  	d1,x3
			bsr 		loc_line
			bra 		return

r_min_l 	movem.l 	#$FFFE,-(a7)	; save registers
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)	; save x1-x5

			clr.l   	d5
			move.b  	x1,d5   	; d5.l = bp
			add.l   	#21,d5  	; d5.l = bp (key #)
			clr.l   	d6
			move.b  	x2,d6   	; d6.l = level (0-99)
			clr.l   	d7
			move.b  	x3,d7   	; d7.l = depth (0-99)

			move.l  	d5,d0
			bsr 		convert
			move.w  	d1,x1   	; x1
			move.w  	#116,x2
			sub.w   	d6,x2   	; y1
			tst.l   	d7
			beq 		.rml1
			tst.l   	d6
			beq 		.rml1
			move.l  	#10000,d0   ; d and L both nonzero
			divu		d7,d0
			andi.l  	#$FFFF,d0
			mulu		d6,d0
			divu		#292,d0
			andi.l  	#$FFFF,d0
			add.l   	d5,d0   	; d0.l = x-intercept
			cmpi.l  	#127,d0
			bgt 		.rml2
			move.w  	#116,x4 	; line doesn't hit right margin
			bsr 		convert
			move.w  	d1,x3
			bra 		.doit
.rml2   	move.l  	d0,d1   	; line hits right margin
			sub.l   	#127,d0 	; calculate L' for x=127
			mulu		d6,d0   	; L' = (k'-127)*L/(k'-BP)
			sub.l   	d5,d1
			divu		d1,d0
			move.w  	#116,x4
			sub.w   	d0,x4
			move.l  	#127,d0
			bsr 		convert
			move.w  	d1,x3
			bra 		.doit
.rml1   	move.l  	#127,d0 	; d or L is 0
			bsr 		convert
			move.w  	d1,x3
			move.w  	#116,x4
			sub.w   	d6,x4
.doit   	bsr 		loc_line
			bra 		return

r_min_e 	movem.l 	#$FFFE,-(a7)	; save registers
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)	; save x1-x5
			movea.l 	#0,a0   	   ; a0.l = 0 means -exp curve
			bra 		rit_exp

r_plu_e 	movem.l 	#$FFFE,-(a7)	; save registers
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)	; save x1-x5
			movea.l 	#1,a0   	; a0.l=1 means +exp curve

rit_exp 	clr.l   	d5
			move.b  	x1,d5   	; d5.l = bp
			add.l   	#21,d5  	; d5.l = bp (key #)
			clr.l   	d6
			move.b  	x2,d6   	; d6.l = level (0-99)
			clr.l   	d7
			move.b  	x3,d7   	; d7.l = depth (0-99)

			move.l  	d5,d0
			bsr 		convert
			move.w  	d1,x1   	; x1
			move.w  	#116,x2
			sub.w   	d6,x2   	; y1

			lea 		exptable,a5 	; a5.l --> table of L'(x,20,d)

			move.l  	d5,d4
			addq.l  	#5,d4
			divu		#3,d4
			andi.l  	#$FFFF,d4   ; d4.l = b-group

			move.l  	d6,d3
			sub.l   	#20,d3
			cmpi.l  	#15,d6
			bge 		.delta
			add.l   	d6,d3
			sub.l   	#15,d3
			cmpi.l  	#3,d6
			bge 		.delta
			add.l   	d6,d3
			add.l   	d6,d3
			subq.l  	#6,d3
.delta  	move.l  	d5,d2   	; d3.l = delta
.loop   	addq.l  	#1,d2   	; for d2.l = (b+1) to 127
			cmpi.l  	#127,d2
			bgt 		return
			move.l  	d2,d0
			bsr 		convert
			move.w  	d1,x3   	; x2
			move.l  	d2,d0
			addq.l  	#5,d0
			divu		#3,d0
			andi.l  	#$FFFF,d0   ; d0.l = k-group
			sub.l   	d4,d0   	; d0.l = k-group  -  b-group
			cmpi.l  	#27,d0
			ble 		.le27
			move.l  	#27,d0  	; d0.l = min(27,kg-bg)
.le27   	move.l  	d7,d1
			mulu		#28,d1
			add.l   	d1,d0   	; d0.l = index into exptable
			clr.w   	d1
			move.b  	0(a5,d0.l),d1
			add.w   	d3,d1   	; d1.b = L'(x,L,d)
			cmpa.l  	#1,a0   	; switch according to a0
			beq 		.plu
			move.w  	d6,d0
			add.w   	d6,d0
			sub.w   	d1,d0
			bge 		.ge02
			clr.w   	d0
.ge02   	cmp.w   	d6,d0
			ble 		.lel2
			move.w  	d6,d0
.lel2   	move.w  	#116,x4
			sub.w   	d0,x4
			bra 		.plu_min
.plu		cmpi.w  	#99,d1
			ble 		.le99
			move.w  	#99,d1  	; clamp L' to <100
.le99   	cmp.w   	d6,d1   	; clamp L' to >= L
			bge 		.gel2
			move.w  	d6,d1
.gel2   	move.w  	#116,x4
			sub.w   	d1,x4   	; y2
.plu_min	bsr 		loc_line
			move.w  	x3,x1
			move.w  	x4,x2   	; prepare to connect to next section
			bra 		.loop   	; end for

r_plu_l 	movem.l 	#$FFFE,-(a7)	; save registers
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)	; save x1-x5

			clr.l   	d5
			move.b  	x1,d5   	; d5.l = bp
			add.l   	#21,d5  	; d5.l = bp (key #)
			clr.l   	d6
			move.b  	x2,d6   	; d6.l = level (0-99)
			clr.l   	d7
			move.b  	x3,d7   	; d7.l = depth (0-99)

			move.l  	d5,d0
			bsr 		convert
			move.w  	d1,x1   	; x1
			move.w  	#116,x2
			sub.w   	d6,x2   	; y1
			cmpi.l  	#2,d7
			ble 		.rpl1
			move.l  	d7,d1   	; d>2
			mulu		#389,d1
			sub.l   	#860,d1 	; d1.l = 389d-860
			move.l  	#99,d0
			sub.l   	d6,d0   	; d0.l = 99-L
			mulu		#17000,d0   ; d0.l = 17000(99-L)
			divu		d1,d0
			andi.l  	#$FFFF,d0   ; d0.l = 17000(99-L)/(389-860)
			add.l   	d5,d0   	; d0.l = k' (99-intercept)
			cmpi.l  	#127,d0
			bge 		.rpl2
			bsr 		convert 	; line does not touch right margin
			move.w  	d1,x3
			move.w  	#17,x4
			bra 		.doit
.rpl2   	sub.l   	d5,d0   	; d0.l = k'-b
			move.l  	#99,d1
			sub.l   	d6,d1   	; d1.l = 99-L
			move.l  	#127,d2
			sub.l   	d5,d2   	; d2.l = 127-b
			mulu		d2,d1   	; d1.l = (99-L)(127-b)
			divu		d0,d1
			andi.l  	#$FFFF,d1
			add.l   	d6,d1
			move.w  	#116,x4
			sub.w   	d1,x4
			move.l  	#127,d0
			bsr 		convert
			move.w  	d1,x3
			bra 		.doit
.rpl1   	move.l  	#127,d0 	; d <3
			bsr 		convert
			move.w  	d1,x3
			move.w  	#116,x4
			sub.w   	d6,x4
.doit   	move.w  	x3,d2
			cmp.w   	x1,d2
			beq 		.doit2
			bsr 		loc_line
.doit2  	move.l  	#127,d0
			bsr 		convert
			cmp.w   	x3,d1
			beq 		return
			move.w  	x3,x1
			move.w  	x4,x2
			move.w  	d1,x3
			bsr 		loc_line
			bra 		return

loc_line	cmpa.l  	#1,a3   		; dotted or solid?
			beq 		.dot
			jsr 		line
			rts
.dot		jsr 		dotline
			rts

return  	move.l  	(a7)+,x5	; restore x5-x1
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1
			movem.l 	(a7)+,#$7FFF	; restore registers
			jmp 		(a6)			; return

;*****************************************************************************;
;   data:  exptable contains L'(x,20,d) for +E curves
;   	   x=0 to 27 , d=0 to 99
;*****************************************************************************;

 .data
exptable:

	.byte   20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20
	.byte   20,20,20,20,20,20,20,20
	.byte   20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20
	.byte   20,20,20,21,21,21,21,21
	.byte   20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,21,21
	.byte   21,21,22,22,23,23,24,24
	.byte   20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,21,21,21,21
	.byte   22,22,23,23,24,25,26,26
	.byte   20,20,20,20,20,20,20,20,20,20,20,20,20,20,21,21,21,21,22,22
	.byte   23,23,24,25,26,27,28,29
	.byte   20,20,20,20,20,20,20,20,20,20,20,20,20,21,21,21,21,22,22,23
	.byte   23,24,25,26,27,28,30,31
	.byte   20,20,20,20,20,20,20,20,20,20,20,20,21,21,21,21,22,22,23,23
	.byte   24,25,26,27,29,31,33,34
	.byte   20,20,20,20,20,20,20,20,20,20,20,21,21,21,21,22,22,23,24,24
	.byte   25,26,27,29,31,33,35,37
	.byte   20,20,20,20,20,20,20,20,20,20,21,21,21,21,22,22,23,23,24,25
	.byte   26,27,28,30,32,34,37,39
	.byte   20,20,20,20,20,20,20,20,20,20,21,21,21,22,22,22,23,24,25,26
	.byte   27,28,30,32,34,37,40,42
	.byte   20,20,20,20,20,20,20,20,20,21,21,21,21,22,22,23,23,24,25,26
	.byte   27,29,31,33,35,38,41,44
	.byte   20,20,20,20,20,20,20,20,20,21,21,21,22,22,23,23,24,25,26,27
	.byte   28,30,32,34,37,40,44,47
	.byte   20,20,20,20,20,20,20,20,21,21,21,21,22,22,23,23,24,25,26,27
	.byte   29,31,33,36,38,42,46,49
	.byte   20,20,20,20,20,20,20,21,21,21,21,22,22,22,23,24,25,26,27,28
	.byte   30,32,34,37,40,44,48,52
	.byte   20,20,20,20,20,20,20,21,21,21,21,22,22,23,23,24,25,26,28,29
	.byte   31,33,35,38,42,46,51,55
	.byte   20,20,20,20,20,20,21,21,21,21,22,22,22,23,24,24,25,26,28,29
	.byte   31,34,36,39,43,48,53,57
	.byte   20,20,20,20,20,20,21,21,21,21,22,22,23,23,24,25,26,27,29,30
	.byte   32,35,38,41,45,50,55,60
	.byte   20,20,20,20,20,21,21,21,21,21,22,22,23,23,24,25,26,27,29,31
	.byte   33,35,38,42,46,51,57,62
	.byte   20,20,20,20,20,21,21,21,21,21,22,22,23,24,24,25,27,28,30,32
	.byte   34,37,40,44,48,54,60,65
	.byte   20,20,20,20,20,21,21,21,21,22,22,23,23,24,25,26,27,28,30,32
	.byte   35,37,41,45,50,55,62,67
	.byte   20,20,20,20,20,21,21,21,21,22,22,23,23,24,25,26,27,29,31,33
	.byte   35,38,42,46,51,57,64,70
	.byte   20,20,20,20,21,21,21,21,21,22,22,23,24,24,25,26,28,29,32,34
	.byte   36,40,43,48,53,60,67,73
	.byte   20,20,20,20,21,21,21,21,21,22,23,23,24,25,26,27,28,30,32,34
	.byte   37,40,44,49,55,61,67,75
	.byte   20,20,20,20,21,21,21,21,22,22,23,23,24,25,26,27,28,30,33,35
	.byte   38,41,46,50,56,63,71,78
	.byte   20,20,20,20,21,21,21,21,22,22,23,23,24,25,26,27,29,31,33,35
	.byte   39,42,46,51,58,65,73,81
	.byte   20,20,20,21,21,21,21,22,22,22,23,24,24,25,27,28,29,31,34,36
	.byte   40,43,48,53,60,67,76,83
	.byte   20,20,20,21,21,21,21,22,22,22,23,24,24,26,27,28,30,32,34,37
	.byte   40,44,49,55,61,67,78,86
	.byte   20,20,20,21,21,21,21,22,22,22,23,24,25,26,27,28,30,32,35,38
	.byte   41,45,50,56,63,71,81,88
	.byte   20,20,20,21,21,21,21,22,22,23,23,24,25,26,27,29,30,32,36,38
	.byte   42,46,51,57,65,73,83,91
	.byte   20,20,20,21,21,21,22,22,22,23,24,24,25,26,28,29,31,32,36,39
	.byte   43,47,52,58,66,74,84,93
	.byte   20,20,20,21,21,21,22,22,22,23,24,24,25,26,28,29,31,34,37,40
	.byte   44,48,53,60,68,77,87,96
	.byte   20,20,20,21,21,21,22,22,22,23,24,24,25,27,28,30,32,34,37,40
	.byte   44,49,54,61,69,78,89,98
	.byte   20,20,20,21,21,21,22,22,22,23,24,25,26,27,28,30,32,35,38,41
	.byte   45,50,56,62,71,81,91,103
	.byte   20,20,20,21,21,21,22,22,22,23,24,25,26,27,29,30,32,35,38,42
	.byte   46,51,57,64,73,83,94,107
	.byte   20,20,21,21,21,22,22,22,23,23,24,25,26,27,29,31,33,35,39,42
	.byte   47,52,58,65,74,84,96,109
	.byte   20,20,21,21,21,22,22,22,23,23,25,25,26,28,29,31,33,36,40,43
	.byte   48,53,59,67,76,86,98,111
	.byte   20,20,21,21,21,22,22,22,23,23,25,25,26,28,30,31,34,36,40,44
	.byte   48,54,60,68,77,88,99,112
	.byte   20,20,21,21,21,22,22,22,23,24,25,25,27,28,30,32,34,37,41,44
	.byte   49,55,61,69,80,90,101,114
	.byte   20,20,21,21,21,22,22,23,23,24,25,26,27,28,30,32,34,37,41,45
	.byte   50,55,62,70,81,91,103,117
	.byte   20,20,21,21,21,22,22,23,23,24,25,26,27,28,30,32,35,38,42,46
	.byte   51,57,64,72,82,94,107,122
	.byte   20,20,21,21,22,22,22,23,23,24,25,26,27,29,31,33,35,38,42,46
	.byte   52,58,65,73,84,96,109,124
	.byte   20,20,21,21,22,22,22,23,23,24,25,26,27,29,31,33,35,39,43,47
	.byte   52,58,66,74,85,97,110,125
	.byte   20,20,21,21,22,22,22,23,23,24,25,26,28,29,31,33,36,39,44,48
	.byte   53,60,67,76,87,99,113,129
	.byte   20,20,21,21,22,22,23,23,23,24,26,26,28,29,32,34,36,40,44,48
	.byte   54,60,68,77,88,99,114,130
	.byte   20,20,21,21,22,22,23,23,23,24,26,27,28,30,32,34,37,40,45,49
	.byte   55,61,69,80,90,102,116,132
	.byte   20,20,21,21,22,22,23,23,24,24,26,27,28,30,32,34,37,41,45,50
	.byte   56,63,71,81,92,103,118,134
	.byte   20,20,21,21,22,22,23,23,24,25,26,27,28,30,32,35,37,41,46,50
	.byte   56,63,72,81,93,106,121,138
	.byte   20,20,21,21,22,22,23,23,24,25,26,27,28,30,33,35,38,42,46,51
	.byte   57,64,73,83,95,108,123,140
	.byte   20,20,21,21,22,22,23,23,24,25,26,27,29,31,33,35,38,42,47,52
	.byte   58,65,74,84,96,109,124,141
	.byte   20,20,21,21,22,22,23,23,24,25,26,27,29,31,33,36,39,43,48,52
	.byte   59,66,75,85,97,110,125,143
	.byte   20,21,21,22,22,23,23,24,24,25,27,28,29,31,34,37,39,43,48,53
	.byte   60,67,76,87,99,113,128,146
	.byte   20,21,21,22,22,23,23,24,24,25,27,28,29,31,34,36,39,44,49,54
	.byte   60,68,77,88,99,114,129,147
	.byte   20,21,21,22,22,23,23,24,24,25,27,28,29,32,34,37,40,44,49,55
	.byte   61,69,80,90,102,117,133,151
	.byte   20,21,21,22,22,23,23,24,24,25,27,28,30,32,34,37,40,44,50,55
	.byte   62,70,81,91,103,118,134,152
	.byte   20,21,21,22,22,23,23,24,24,25,27,28,30,32,35,37,41,45,50,56
	.byte   63,71,81,92,104,118,134,152
	.byte   20,21,21,22,22,23,23,24,24,26,27,28,30,32,35,38,41,45,51,56
	.byte   64,72,82,93,105,119,135,153
	.byte   20,21,21,22,22,23,23,24,25,26,27,29,30,32,35,38,41,46,52,57
	.byte   65,73,83,95,108,122,139,158
	.byte   20,21,21,22,22,23,23,24,25,26,27,29,30,33,35,38,42,46,52,58
	.byte   65,74,84,96,109,125,142,162
	.byte   20,21,21,22,22,23,24,24,25,26,28,29,31,33,36,39,42,47,53,58
	.byte   66,75,85,97,110,125,143,162
	.byte   20,21,21,22,22,23,24,24,25,26,28,29,31,33,36,39,42,47,53,59
	.byte   67,76,87,98,111,126,143,163
	.byte   20,21,21,22,23,23,24,24,25,26,28,29,31,33,36,39,43,48,54,60
	.byte   69,77,87,99,112,127,144,164
	.byte   20,21,21,22,23,23,24,24,25,26,28,29,31,34,37,40,43,48,54,61
	.byte   69,78,89,101,114,130,147,167
	.byte   20,21,21,22,23,23,24,24,25,26,28,29,31,34,37,40,44,49,55,61
	.byte   69,80,90,102,117,133,151,172
	.byte   20,21,21,22,23,23,24,25,25,26,28,30,32,34,37,40,44,49,56,62
	.byte   70,81,91,103,118,134,152,173
	.byte   20,21,21,22,23,23,24,25,25,27,29,30,32,34,38,41,45,50,56,63
	.byte   71,81,92,104,118,134,152,173
	.byte   20,21,21,22,23,23,24,25,25,27,29,30,32,35,38,41,45,50,57,63
	.byte   72,81,93,106,121,137,156,178
	.byte   20,21,21,22,23,23,24,25,25,27,29,30,32,35,38,41,45,51,57,64
	.byte   73,83,95,108,124,141,161,183
	.byte   20,21,22,22,23,24,24,25,26,27,29,30,32,35,38,42,46,51,58,65
	.byte   73,83,95,108,122,141,161,183
	.byte   20,21,22,22,23,24,24,25,26,27,29,30,32,35,39,42,46,52,58,65
	.byte   74,84,97,111,127,145,165,189
	.byte   20,21,22,22,23,24,24,25,26,27,29,31,33,35,39,42,46,52,59,66
	.byte   75,85,98,112,128,146,166,189
	.byte   20,21,22,22,23,24,24,25,26,27,29,31,33,36,39,43,47,53,60,67
	.byte   76,86,98,112,128,146,166,189
	.byte   20,21,22,22,23,24,25,25,26,27,30,31,33,36,40,43,47,53,60,69
	.byte   77,87,98,112,128,146,166,189
	.byte   20,21,22,22,23,24,25,25,26,27,30,31,33,36,40,43,48,53,61,69
	.byte   77,88,99,112,128,146,166,189
	.byte   20,21,22,22,23,24,25,25,26,28,30,31,33,36,40,44,48,54,61,69
	.byte   78,89,101,114,130,147,167,189
	.byte   20,21,22,22,23,24,25,25,26,28,30,31,34,37,40,44,48,54,62,69
	.byte   80,90,102,115,131,148,167,190
	.byte   20,21,22,23,23,24,25,26,26,28,30,32,34,37,41,44,49,55,62,70
	.byte   81,91,103,118,134,152,173,196
	.byte   20,21,22,23,23,24,25,26,26,28,30,32,34,37,41,45,49,55,63,71
	.byte   81,92,104,118,134,152,173,196
	.byte   20,21,22,23,23,24,25,26,26,28,30,32,34,37,41,45,50,56,64,71
	.byte   81,93,105,119,135,153,173,196
	.byte   20,21,22,23,23,24,25,26,27,28,30,32,34,38,41,45,50,56,64,72
	.byte   82,94,107,121,138,157,178,203
	.byte   20,21,22,23,23,24,25,26,27,28,31,32,35,38,42,46,50,57,65,73
	.byte   83,95,108,122,139,158,179,203
	.byte   20,21,22,23,24,24,25,26,27,28,31,32,35,38,42,46,51,57,65,73
	.byte   84,96,109,125,142,161,184,209
	.byte   20,21,22,23,24,24,25,26,27,28,31,33,35,38,42,46,51,58,66,74
	.byte   85,97,110,125,143,162,184,210
	.byte   20,21,22,23,24,24,25,26,27,29,31,33,35,38,43,47,52,58,66,75
	.byte   85,98,112,128,146,166,189,216
	.byte   20,21,22,23,24,24,25,26,27,29,31,33,35,39,43,47,52,59,67,75
	.byte   86,98,112,128,146,166,189,216
	.byte   20,21,22,23,24,25,25,26,27,29,31,33,36,39,43,47,52,59,68,76
	.byte   87,99,113,128,146,166,189,216
	.byte   20,21,22,23,24,25,25,26,27,29,31,33,36,39,43,48,53,60,68,77
	.byte   88,100,114,129,147,167,189,216
	.byte   20,21,22,23,24,25,26,26,27,29,32,33,36,39,44,48,53,60,69,77
	.byte   89,102,116,132,151,172,196,223
	.byte   20,21,22,23,24,25,26,27,27,29,32,34,36,40,44,48,54,61,69,78
	.byte   90,102,117,133,151,172,196,223
	.byte   20,21,22,23,24,25,26,27,27,29,32,34,36,40,44,49,54,61,70,80
	.byte   90,102,117,133,151,172,196,223
	.byte   20,21,22,23,24,25,26,27,28,29,32,34,36,40,45,49,54,62,70,80
	.byte   91,103,118,134,152,173,196,223
	.byte   20,21,22,23,24,25,26,27,28,29,32,34,37,40,45,49,55,62,71,81
	.byte   92,105,120,137,156,178,203,231
	.byte   20,21,22,23,24,25,26,27,28,30,32,34,37,41,45,50,55,62,72,81
	.byte   93,106,122,140,160,183,209,240
	.byte   20,21,22,23,24,25,26,27,28,30,32,34,37,41,45,50,56,63,72,82
	.byte   94,107,123,140,160,183,209,240
	.byte   20,21,22,23,24,25,26,27,28,30,33,34,37,41,46,50,56,63,73,82
	.byte   94,107,123,140,160,183,209,240
	.byte   20,21,22,23,24,25,26,27,28,30,33,35,37,41,46,51,56,64,73,83
	.byte   95,107,123,140,160,183,209,240
	.byte   20,21,22,23,24,25,26,27,28,30,33,35,38,41,46,51,57,64,74,83
	.byte   96,110,126,144,165,189,216,247
	.byte   20,21,22,23,24,25,26,27,28,30,33,35,38,42,47,51,57,65,74,84
	.byte   97,111,127,146,167,191,218,250
	.byte   20,21,22,23,24,25,26,27,28,30,33,35,38,42,47,52,58,65,74,85
	.byte   98,112,129,148,169,194,223,255
	.byte   20,21,22,23,24,25,26,27,28,30,33,35,38,42,47,52,58,66,76,85
	.byte   98,112,129,148,169,194,223,255
	.byte   20,21,22,23,24,25,26,27,28,30,33,35,38,42,47,52,58,66,76,86
	.byte   98,112,129,148,169,194,223,255
