;*****************************************************************************;
;   android menu cmd processors   Copyright 1986 Tom Bajoras
;*****************************************************************************;

 .text

;*****************************************************************************;
;   droidws  --  intelligently randomize w.s.
;*****************************************************************************;

 .global droidws

droidws 	movem.l 	#$FFFE,-(a7)		; save registers
			move.l  	x1,-(a7)			; and x1-x3
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)

			move.l  	#wkspace,x1 	; --> area to be randomized
			jsr 		droid

			move.l  	#and1name,x1
			move.l  	#wksname,x2
			move.b  	#10,x3
			jsr 		movemem 		; name = and1name

			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1		; restore x3-x1
			movem.l 	(a7)+,#$7FFF		; restore registers
			rts 							; return

;*****************************************************************************;
;   droidwb  --  intelligently randomize entire w.b.
;*****************************************************************************;

 .global droidwb

droidwb 	movem.l 	#$FFFE,-(a7)		; save registers
			move.l  	x1,-(a7)			; and x1-x3
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)

			move.b  	#32,x2  		; loop: x2 = 32 to 1
			move.l  	#wkbank,x1     ; --> area to be randomized
.loop1  	jsr 		droid
			add.l   	#160,x1
			subq.b  	#1,x2
			bne 		.loop1

			move.l  	#and1name,x1
			move.l  	#wkbname,x2
			move.b  	#10,x3
			move.b  	#32,d0  		; loop: d0.b=32 to 1
.loop2  	jsr 		movemem 		; name = and1name
			add.l   	#10,x2
			subq.b  	#1,d0
			bne 		.loop2

			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1		; restore x3-x1
			movem.l 	(a7)+,#$7FFF		; restore registers
			rts 							; return

;*****************************************************************************;
;   randws  --  un-intelligently randomize w.s.
;*****************************************************************************;

 .global randws

randws  	movem.l 	#$FFFE,-(a7)		; save registers
			move.l  	x1,-(a7)			; and x1-x3
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)

			move.l  	#wkspace,x1 	; --> area to be randomized
			jsr 		rand

			move.l  	#and2name,x1
			move.l  	#wksname,x2
			move.b  	#10,x3
			jsr 		movemem 		; name = and2name

			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1		; restore x3-x1
			movem.l 	(a7)+,#$7FFF		; restore registers
			rts 							; return

;*****************************************************************************;
;   randwb  --  un-intelligently randomize entire w.b.
;*****************************************************************************;

 .global randwb

randwb  	movem.l 	#$FFFE,-(a7)		; save registers
			move.l  	x1,-(a7)			; and x1-x3
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)

			move.b  	#32,x2  		; loop: x2 = 32 to 1
			move.l  	#wkbank,x1     ; --> area to be randomized
.loop1  	jsr 		rand
			add.l   	#160,x1
			subq.b  	#1,x2
			bne 		.loop1

			move.l  	#and2name,x1
			move.l  	#wkbname,x2
			move.b  	#10,x3
			move.b  	#32,d0  		; loop: d0.b=32 to 1
.loop2  	jsr 		movemem 		; name = and2name
			add.l   	#10,x2
			subq.b  	#1,d0
			bne 		.loop2

			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1		; restore x3-x1
			movem.l 	(a7)+,#$7FFF		; restore registers
			rts 							; return

;*****************************************************************************;
;   droid  --  routine to intelligently randomize ws or wb slot
;   input: x1.l --> area to be randomized
;*****************************************************************************;

 .global droid

droid   	move.l  	x1,a6   	   ; a6 --> area to be randomized

			move.l  	a6,a5   		; e.g. area
			clr.b   	d7  			; do this 6 times

.1  		bsr 		random1 		; R1 = 99 50% of the time
			cmpi.b  	#1,d0
			beq 		.2
			move.b  	#99,d0
			bra 		.3
.2  		bsr 		random31
			add.b   	#68,d0  		; R1 = 68-99 50% of the time
.3  		move.b  	d0,(a5)
			bsr 		random99		; R2-R3 are totally random
			move.b  	d0,1(a5)
			bsr 		random99
			move.b  	d0,2(a5)
			bsr 		random63
			add.b   	#36,d0
			move.b  	d0,3(a5)		; R4 = 36-99
			bsr 		random99
			move.b  	d0,d6   		; d6 is L1
			bsr 		random99
			move.b  	d0,d5   		; d5 is L2
			bsr 		random99		; d0 is L3
			move.b  	d0,d4   		; collect max(L1,L2,L3) in d4
			cmp.b   	d6,d4
			bgt 		.4
			move.b  	d6,d4
.4  		cmp.b   	d5,d4
			bgt 		.5
			move.b  	d5,d4
.5  		neg.b   	d4
			add.b   	#99,d4  		; d4 = 99 - max(L1,L2,L3)
			add.b   	d4,d6
			add.b   	d4,d5
			add.b   	d4,d0   		; scale so that largest L is 99
			move.b  	d6,4(a5)
			move.b  	d5,5(a5)
			move.b  	d0,6(a5)
			clr.b   	7(a5)   	 ; L4 = 0
			add.l   	#21,a5  		; a5 --> next e.g. area
			addq.b  	#1,d7
			cmpi.b  	#6,d7
			bne 		.1

			move.l  	a6,a5   		; parameters not randomized
			clr.b   	d7  			; for each operator:
.6  		clr.b   	8(a5)   	 ;   break point
			clr.b   	9(a5)   	 ;   left depth
			clr.b   	10(a5)  	 ;   right depth
			clr.b   	11(a5)  	 ;   left curve
			clr.b   	12(a5)  	 ;   right curve
			clr.b   	13(a5)  	 ;   kb rate scaling
			clr.b   	15(a5)  	 ;   velocity sensitivity
			move.b  	#7,20(a5)   	;   detuning
			add.l   	#21,a5
			addq.b  	#1,d7
			cmpi.b  	#6,d7
			bne 		.6

			move.l  	a6,a5
			add.l   	#14,a5  		; A.M. sensitivity
			clr.b   	d7  			; do 6 times
.7  		bsr 		random1 		; = 0 50% of the time
			tst.b   	d0
			beq 		.8
			clr.b   	(a5)
			bra 		.9
.8  		bsr 		random3
			move.b  	d0,(a5)
.9  		add.l   	#21,a5
			addq.b  	#1,d7
			cmpi.b  	#6,d7
			bne 		.7

			move.l  	a6,a5
			add.l   	#134,a5 		; algorithm
			bsr 		random31		; totally random
			move.b  	d0,(a5)
			andi.l  	#$FF,d0
			mulu		#6,d0
			lea 		dx7algs,a4
			add.l   	d0,a4   		; a4 --> algorithm descriptor

			move.l  	a6,a5
			add.l   	#16,a5  		; output level
			clr.l   	d7  			; do this 6 times
.10 		tst.b   	0(a4,d7.l)   ; Is this operator a carrier?
			bne 		.11
			bsr 		random63
			add.b   	#36,d0
			move.b  	d0,(a5) 		; not a carrier: 36-99
			bra 		.12
.11 		bsr 		random31
			add.b   	#68,d0
			move.b  	d0,(a5) 		; a carrier: level = 68-99
.12 		add.l   	#21,a5  		; a5 --> next operator's output level
			addq.l  	#1,d7
			cmpi.l  	#6,d7
			bne 		.10

			move.l  	a6,a5
			add.l   	#17,a5  		; mode
			clr.b   	d7  			; do this 6 times
.13 		bsr 		random7
			tst.b   	d0  		 ; fixed freq 1 out of 8 times
			bne 		.14
			move.b  	#1,(a5)
			bsr 		random99
			move.b  	d0,2(a5)		; fine freq totally random with F.F.
			bra 		.15
.14 		clr.b   	(a5)
			clr.b   	2(a5)   	 ; fine freq = 0 with F.R.
.15 		add.l   	#21,a5  		; a5 --> next operator's frequency info
			addq.b  	#1,d7
			cmpi.b  	#6,d7
			bne 		.13

			move.l  	a6,a5
			add.l   	#18,a5  		; coarse tuning
			clr.l   	d7  			; do this 6 times
.16 		cmpi.b  	#1,0(a4,d7.l)   ; Is this operator a carrier?
			beq 		.18
			bsr 		random3 		; not a carrier:
			tst.b   	d0  		 ; 66% of the time freq = .5-6
			beq 		.17
			bsr 		random7
			move.b  	d0,(a5)
			bra 		.19
.17 		bsr 		random31		; 33% of the time freq = .5-31
			move.b  	d0,(a5)
			bra 		.19
.18 		bsr 		random1 		; carrier:
			move.b  	d0,d6
			bsr 		random1
			add.b   	d6,d0   		; .5,1,1,2
			move.b  	d0,(a5)
.19 		add.l   	#21,a5
			addq.l  	#1,d7
			cmpi.l  	#6,d7
			bne 		.16

			add.l   	#126,a6 	; pitch eg
			bsr 		random7
			tst.b   	d0  	 ; 1 out of 8 times it's totally random
			bne 		.21
			clr.b   	d7  		; do this 8 times
.20 		bsr 		random99
			move.b  	d0,(a6)+
			addq.b  	#1,d7
			cmpi.b  	#8,d7
			bne 		.20
			bra 		.24
.21 		clr.b   	d7    ; 7 out of 8 times it's 99,99,99,99,50,50,50,50
.22 		move.b  	#99,(a6)+
			addq.b  	#1,d7
			cmpi.b  	#4,d7
			bne 		.22
			clr.b   	d7
.23 		move.b  	#50,(a6)+
			addq.b  	#1,d7
			cmpi.b  	#4,d7
			bne 		.23

.24 		addq.l  	#1,a6   	; skip  algorithm (already done)
			bsr 		random7
			move.b  	d0,(a6)+	; totally random feedback
			bsr 		random1
			move.b  	d0,(a6)+	; totally random operator sync
			bsr 		random99
			move.b  	d0,(a6)+	; totally random LFO speed
			clr.b   	(a6)+    ; no LFO delay
			bsr 		random99
			move.b  	d0,(a6)+	; totally random PMD
			bsr 		random99
			move.b  	d0,(a6)+	; totally random AMD
			bsr 		random1
			move.b  	d0,(a6)+	; totally random LFO sync
			bsr 		random5
			move.b  	d0,(a6)+	; totally random LFO waveform
			bsr 		random3 	; 75% of the time PMS is zero
			tst.b   	d7
			bne 		.25
			bsr 		random7 	; 25% of the time PMS is totally random
			move.b  	d0,(a6)+
			bra 		.26
.25 		clr.b   	(a6)+
.26 		move.b  	#24,(a6)	; transposition: = C3
									; note: function parameters are unchanged

			rts 					; return

;*****************************************************************************;
;   rand  --  routine to un-intelligently randomize ws or wb slot
;   input: x1.l --> area to be randomized
;*****************************************************************************;

 .global rand

rand		movem.l 	#$FFFE,-(a7)

			move.l  	x1,a6   		; a6 --> area to be randomized
			lea 		disttabl,a5 	; a5 --> distortion table
			lea 		parminfo,a4 	; a4 --> parminfo

			move.l  	#158,d7 		; counter: 158 to 0
.loop   	tst.b   	0(a5,d7.l)
			beq 		.next
			move.w  	d7,d0
			mulu		#8,d0
			move.b  	1(a4,d0.w),d0   ; d0.b = high mark
			cmpi.b  	#1,d0
			bne 		.3
			bsr 		random1
			bra 		.x
.3  		cmpi.b  	#3,d0
			bne 		.5
			bsr 		random3
			bra 		.x
.5  		cmpi.b  	#5,d0
			bne 		.7
			bsr 		random5
			bra 		.x
.7  		cmpi.b  	#7,d0
			bne 		.12
			bsr 		random7
			bra 		.x
.12 		cmpi.b  	#12,d0
			bne 		.14
.12x		bsr 		random15
			subq.b  	#3,d0
			blt 		.12x
			bra 		.x
.14 		cmpi.b  	#14,d0
			bne 		.31
.14x		bsr 		random15
			subq.b  	#1,d0
			blt 		.14x
			bra 		.x
.31 		cmpi.b  	#31,d0
			bne 		.48
			bsr 		random31
			bra 		.x
.48 		cmpi.b  	#48,d0
			bne 		.99
.48x		bsr 		random63
			sub.b   	#15,d0
			blt 		.48x
			bra 		.x
.99 		bsr 		random99

.x  		move.b  	d0,0(a6,d7.l)

.next   	subq.l  	#1,d7
			bge 		.loop

			movem.l 	(a7)+,#$7FFF
			rts

;******************************************************************************
;   distort  --  mess up w.s. by a random amount
;******************************************************************************

 .global distort

distort 	movem.l 	#$FFFE,-(a7)	; save registers
			move.l  	x1,-(a7)		; save x1,x2,x3
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)

			lea 		wkspace,a5  	; a5 --> w.s.
			lea 		parminfo,a6 	; a6 --> parminfo
			lea 		disttabl,a4 	; a4 --> distort table
			move.w  	#158,d6 		; parameter counter

.loop   	tst.b   	0(a4,d6.w)  	; skip par if distort flag not set
			beq 		.next
			bsr 		random3
			move.b  	d0,d7   		; d7.b = distortion amount
			bsr 		random1 		; distort up or down?
			tst.b   	d0
			beq 		.plus
			neg.b   	d7
.plus   	add.b   	0(a5,d6.w),d7   ; d7.b = distorted parameter
			move.w  	d6,d0
			mulu		#8,d0   		; d0.l = ptr into parminfo array
			cmp.b   	0(a6,d0.l),d7   ; clamp to >= low mark
			bge 		.gelow
			move.b  	0(a6,d0.l),d7
.gelow  	cmp.b   	1(a6,d0.l),d7   ; clamp to <= high mark
			ble 		.lehigh
			move.b  	1(a6,d0.l),d7
.lehigh 	move.b  	d7,0(a5,d6.w)   ; distort the parameter

.next   	subq.w  	#1,d6
			bgt 		.loop

			move.l  	#distname,x1
			move.l  	#wksname,x2
			move.b  	#10,x3
			jsr 		movemem

			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1		; restore x1-x3
			movem.l 	(a7)+,#$7FFF	; restore registers
			rts 						; return

;*****************************************************************************;
;   quick  --  TX quick loader
;*****************************************************************************;

 .global quick

quick   	movem.l 	#$FFFE,-(a7)		; save registers
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)

			jsr 		blnkscr 		 ; start with a blank screen
			move.b  	#13,x1  		 ; change colors
			jsr 		setcolor

			move.l  	#attnmess,x1
			move.b  	#1,x2
			move.b  	#1,x3
			move.b  	cmenhed,x4
			move.b  	#15,x5
			jsr 		message 		; attenuation
			clr.w   	d0
			move.b  	txatten,d0
			move.w  	d0,x1
			jsr 		encode
			move.l  	y1,x1
			move.b  	#17,x2
			move.b  	#1,x5
			jsr 		message

			move.l  	#qumess,x1
			move.b  	xmax,d0
			lea 		qumesl,a0
			sub.b   	(a0),d0
			lsr.b   	#1,d0
			subq.b  	#1,d0
			move.b  	d0,x2   		; sort of center heading
			move.b  	#1,x3
			move.b  	cmenhed,x4
			move.b  	(a0),x5
			jsr 		message

			add.l   	#25,x1
			addq.b  	#2,x3
			move.b  	#18,x2
			move.b  	1(a0),x5
			jsr 		message 		; column headings
			add.l   	#25,x1
			move.b  	#35,x2
			move.b  	2(a0),x5
			jsr 		message
			add.l   	#25,x1
			move.b  	#56,x2
			move.b  	3(a0),x5
			jsr 		message

			add.l   	#25,x1  		; put up menu
			move.b  	#6,x2
			move.b  	ymax,x3
			subq.b  	#1,x3
			move.b  	cmenu,x4
			move.b  	4(a0),x5
			jsr 		message
			add.l   	#25,x1
			addq.b  	#1,x3
			move.b  	5(a0),x5
			jsr 		message

			add.l   	#25,x1
			move.b  	#36,x2
			move.b  	ymax,x3
			subq.b  	#1,x3
			move.b  	6(a0),x5
			jsr 		message
			add.l   	#25,x1
			addq.b  	#1,x3
			move.b  	7(a0),x5
			jsr 		message

			add.l   	#25,x1
			move.b  	#56,x2
			move.b  	ymax,x3
			subq.b  	#1,x3
			move.b  	8(a0),x5
			jsr 		message
			add.l   	#25,x1
			addq.b  	#1,x3
			move.b  	9(a0),x5
			jsr 		message

			lea 		qustat,a6     ; a6 --> send status flags
			lea 		midichs,a5     ; a5 --> midi channels for quick send

			moveq   	#0,d7   		; for row = 0 to 17
			move.b  	cmessge,x4  	; put up row in cmessge
.rowloop	bsr 		putrow
			addq.b  	#1,d7
			cmpi.b  	#17,d7
			ble 		.rowloop

			moveq   	#0,d7   		; init cursor to row 0

.cursloop   move.b  	cprompt,x4
			bsr 		putrow

.keyloop	jsr 		getkey
			move.b  	y1,d4   		; d4.b = gotten key

			cmp.b   	asciup,d4
			beq 		.up
			cmp.b   	ascidwn,d4
			beq 		.down
			cmp.b   	ascis,d4
			beq 		.send
			cmp.b   	ascicr,d4
			beq 		.return
			cmp.b   	ascidel,d4
			beq 		.del
			cmp.b   	asciplus,d4
			beq 		.plus
			cmp.b   	ascidash,d4
			beq 		.dash

.bell   	jsr 		bell			; illegal key: ring bell, loop
			bra 		.keyloop

.up 		move.b  	cmessge,x4
			bsr 		putrow
			subq.b  	#1,d7
			bge 		.cursloop
			moveq   	#17,d7
			bra 		.cursloop

.down   	move.b  	cmessge,x4
			bsr 		putrow
			addq.b  	#1,d7
			cmpi.b  	#17,d7
			ble 		.cursloop
			moveq   	#0,d7
			bra 		.cursloop

.send   	move.w  	#2560,d0		; save w.b. and w.b.names
			lea 		wkbank,a0
			lea 		wwkbank,a1
.wloop1 	move.w  	(a0)+,(a1)+
			subq.w  	#1,d0
			bne 		.wloop1
			move.w  	#160,d0
			lea 		wkbname,a0
			lea 		wwkbname,a1
.wloop2 	move.w  	(a0)+,(a1)+
			subq.w  	#1,d0
			bne 		.wloop2
			move.b  	midich,d1   	; save midi channel

			move.b  	cmessge,x4
			bsr 		putrow  		; unprompt current cursor line
			move.l  	kbaddr,a2
			move.w  	6(a2),d0
			cmp.w   	8(a2),d0
			beq 		.sendx
			jsr 		inkey
			move.b  	y1,d0
			cmp.b   	ascia,d0
			beq 		.abort
.sendx  	lea 		bankflg,a0  	; a0--> bank existence flags
			moveq   	#0,d7   		; for cursor = 0 to 17 do
.sendloop   move.b  	cprompt,x4
			bsr 		putrow  		; prompt this line
			tst.b   	0(a0,d7.l)   ; skip it if it doesn't exist
			beq 		.skip
			tst.b   	0(a6,d7.l)   ; skip it if qustat = 0
			beq 		.skip
			move.b  	0(a5,d7.l),midich   ; channel for this one
			move.b  	d7,x1
			addq.b  	#1,x1
			jsr 		usebank 		; read this bank into w.b.
			tst.b   	y1  		 ; successful?
			bne 		.error  		; if not: go to error return
			jsr 		gobank  		; copy w.b. to synbuf
			jsr 		writbdx7
			jsr 		wbftosyn
			jsr 		writbftx
.skip   	move.b  	cmessge,x4  	; unprompt this line
			bsr 		putrow
			move.w  	6(a2),d0
			cmp.w   	8(a2),d0
			beq 		.skipx
			jsr 		inkey
			move.b  	y1,d0
			cmp.b   	ascia,d0
			beq 		.abort
.skipx  	addq.b  	#1,d7
			cmpi.b  	#17,d7
			ble 		.sendloop
.abort  	clr.b   	y1  			; no error
.error  	lea 		wkbank,a0   	; restore w.b. and w.b. names
			lea 		wwkbank,a1
			move.w  	#2560,d0
.wloop3 	move.w  	(a1)+,(a0)+
			subq.w  	#1,d0
			bne 		.wloop3
			move.w  	#160,d0
			lea 		wkbname,a0
			lea 		wwkbname,a1
.wloop4 	move.w  	(a1)+,(a0)+
			subq.w  	#1,d0
			bne 		.wloop4
			move.b  	d1,midich   	; restore midi channel

			clr.l   	d7  			; reset cursor
			tst.b   	y1
			beq 		.cursloop
			jsr 		blnkscr 		; error return
			clr.b   	x1  		 ; restore colors
			jsr 		setcolor
			move.l  	#qumess,x1  	; error message
			add.l   	#300,x1
			move.b  	#1,x2
			move.b  	#1,x3
			move.b  	cmessge,x4
			lea 		qumesl,a0
			move.b  	12(a0),x5
			jsr 		message
			clr.b   	invtext 		; normal cprompt for this
			add.l   	#25,x1
			addq.b  	#1,x3
			move.b  	cprompt,x4
			move.b  	13(a0),x5
			jsr 		message
			jsr 		getkey  		; wait for a key
			bra 		.return

.del		tst.b   	0(a6,d7.l)   ; toggle qustat
			beq 		.del0
			clr.b   	0(a6,d7.l)
			bra 		.cursloop
.del0   	move.b  	#1,0(a6,d7.l)
			bra 		.cursloop

.plus   	cmpi.b  	#16,0(a5,d7.l)
			blt 		.plus1
			move.b  	#1,0(a5,d7.l)
			bra 		.cursloop
.plus1  	addq.b  	#1,0(a5,d7.l)
			bra 		.cursloop

.dash   	cmpi.b  	#1,0(a5,d7.l)
			bgt 		.dash1
			move.b  	#16,0(a5,d7.l)
			bra 		.cursloop
.dash1  	subq.b  	#1,0(a5,d7.l)
			bra 		.cursloop

.return 	move.l  	(a7)+,x5		; restore registers,x1-x5,return
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1
			movem.l 	(a7)+,#$7FFF
			rts

;*****************************************************************************;
;   putrow  --  local routine to put up a row on quick screen
;   entry conditions: x4.b = color, d7.l = row (0-17), a6--> qustat
;   				  a5.l --> midichs
;*****************************************************************************;

putrow  	movem.l 	#$FFFE,-(a7)	; save registers
			lea 		bankflg,a0  	; a0 --> bank existence flags
			move.b  	#5,x3
			add.b   	d7,x3   		; y-coord

			move.w  	d7,x1
			addq.w  	#1,x1
			jsr 		encode
			move.l  	y1,x1
			move.b  	#19,x2
			move.b  	#2,x5
			jsr 		message 		; bank #
			tst.b   	0(a0,d7.l)
			bne 		putrow1
			move.b  	ascilpr,x1  	; bank doesn't exist
			subq.b  	#1,x2
			jsr 		outchar
			move.b  	ascirpr,x1
			addq.b  	#2,x2
			cmp.b   	#9,d7
			blt 		putrow0
			addq.b  	#1,x2
putrow0 	jsr 		outchar

putrow1 	clr.w   	d0
			move.b  	0(a5,d7.l),d0
			move.w  	d0,x1
			jsr 		encode
			move.l  	y1,x1
			move.b  	#38,x2
			move.b  	#2,x5
			jsr 		message 		; midi channel #

			move.l  	#qumess,x1
			move.b  	#57,x2
			lea 		qumesl,a0
			move.b  	10(a0),x5
			tst.b   	0(a6,d7.l)
			beq 		.off
			add.l   	#275,x1
			bra 		.offon
.off		add.l   	#250,x1
.offon  	jsr 		message 		; yes/no

			movem.l 	(a7)+,#$7FFF	; restore registers
			rts

;******************************************************************************
;  local routines to generate random #'s
;******************************************************************************

random1 	move.l  	#23,-(a7)   ; subroutines to generate random number
			bra 		randomx 	; (number = a power of 2 minus 1)
random3 	move.l  	#22,-(a7)
			bra 		randomx
random7 	move.l  	#21,-(a7)
			bra 		randomx
random15	move.l  	#20,-(a7)
			bra 		randomx
random31	move.l  	#19,-(a7)
			bra 		randomx
random63	move.l  	#18,-(a7)
			bra 		randomx
randm127	move.l  	#17,-(a7)
;   		bra 		randomx
randomx 	move.w  	#17,-(a7)
			trap		#14
			move.l  	d0,d1   		; d1.l = random #
			move.l  	#8,d0
			jsr 		getlong 		; d0.l = 2 (hopefully)
			add.l   	d0,a7
			move.l  	(a7)+,d0
			lsr.l   	d0,d1
			move.l  	d1,d0
			rts

random5 	bsr 		random7 	; d0.b = 0-7
			subq.b  	#2,d0   	; d0.b = -2 to 5
			blt 		random5
			rts 					; return d0.b = 0 to 5

random99	bsr 		randm127
			sub.b   	#28,d0  	; d0.b = -28 to 99
			blt 		random99
			rts 					; return d0.b = 0 to 99

;*****************************************************************************;
;   glide  --  glide e.s. toward w.s. in x1.b steps
;*****************************************************************************;

 .global glide

glide   	movem.l 	#$FFFE,-(a7)	; save registers
			move.l  	x1,-(a7)		; and x1-x5
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)

;   register variables:
			clr.l   	d6  			; current step # starts at 0
			clr.l   	d5
			move.b  	x1,d5   		; d5.l = total # of steps
			move.l  	#edspace,x1
			move.l  	#wwkbank,x2
			add.l   	#100,x2
			move.b  	#160,x3
			jsr 		movemem 		; save source voice
			lea 		edspace,a6
			lea 		wkspace,a5
			lea 		delta,a4
			move.b  	#1,d3   		; d3.b=1 alg enabled, =0 disabled

			jsr 		blnkscr
			move.b  	#14,x1
			jsr 		setcolor

			move.l  	#glmess,x1
			move.b  	xmax,d0
			lea 		glmesl,a0
			sub.b   	(a0),d0
			lsr.b   	#1,d0
			addq.b  	#1,d0
			move.b  	d0,x2
			move.b  	#1,x3
			move.b  	cmenhed,x4
			move.b  	(a0),x5
			jsr 		message 		; heading

			move.b  	#32,x2
			addq.b  	#2,x3
			add.l   	#30,x1
			move.b  	1(a0),x5
			jsr 		message
			move.w  	d5,x1
			jsr 		encode
			move.l  	y1,x1
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.b  	#2,x5
			jsr 		message 		"step 0  out of xx"
			move.l  	#glmess,x1
			add.l   	#180,x1
			move.b  	#1,x2
			move.b  	#1,x3
			move.b  	cmessge,x4
			lea 		glmesl,a0
			move.b  	6(a0),x5
			jsr 		message 		; alg enabled
			move.l  	#glmess,x1
			add.l   	#240,x1
			move.b  	#65,x2
			move.b  	8(a0),x5
			jsr 		message 		; from
			move.l  	#wwkbank,x1
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.b  	#10,x5
			jsr 		message
			addq.b  	#1,x3
			move.l  	#glmess,x1
			add.l   	#270,x1
			move.b  	#67,x2
			move.b  	9(a0),x5
			jsr 		message 		; to
			move.l  	#wwkbank,x1
			add.l   	#10,x1
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.b  	#10,x5
			jsr 		message

			move.w  	#66,x2
			move.w  	#66,x4
			move.l  	d5,d0
			mulu		#20,d0
			move.w  	#640,x1
			sub.w   	d0,x1
			lsr 		x1  			; divide x1 by 2
			move.w  	x1,horiz
			move.w  	x1,x3
			add.w   	d0,x3
			move.b  	cprompt,x5
			jsr 		line
			move.w  	#134,x2
			move.w  	#134,x4
			jsr 		line

			bsr 		vertical

			move.l  	#glmess,x1
			add.l   	#60,x1  		; menu
			move.b  	xmax,d0
			sub.b   	3(a0),d0
			lsr.b   	#1,d0
			addq.b  	#1,d0
			move.b  	d0,x2
			move.b  	ymax,x3
			subq.b  	#3,x3
			move.b  	cmenu,x4
			move.b  	2(a0),x5
			jsr 		message 		; sp
			add.l   	#30,x1
			addq.b  	#1,x3
			move.b  	3(a0),x5
			jsr 		message 		; cr
			add.l   	#30,x1
			addq.b  	#1,x3
			move.b  	4(a0),x5
			jsr 		message 		; bs
			add.l   	#30,x1
			addq.b  	#1,x3
			move.b  	5(a0),x5
			jsr 		message 		; a

			move.l  	#edspace,x1
			move.l  	#wwkbank,x2
			move.b  	#160,x3
			jsr 		movemem 		; save edspace
			lea 		wwkbank,a3     ; a3 --> saved edspace

			bsr 		sendeds 		; start things off

;  calculate delta array:
			moveq   	#0,d0   			; for i=0 to 159
.delloop	move.b  	0(a5,d0.w),d1   	;   delta[i] =
			sub.b   	0(a6,d0.w),d1   	;   (ws[i]-es[i]) + or - 1
			ext.w   	d1
			ext.l   	d1
			divu		d5,d1
			cmpi.w  	#0,d1
			blt 		.neg
			addq.w  	#1,d1
			bra 		.nextdel
.neg		subq.w  	#1,d1
.nextdel	move.b  	d1,0(a4,d0.w)
			addq.l  	#1,d0
			cmpi.l  	#159,d0
			ble 		.delloop

.keyloop	jsr 		getkey
			move.b  	y1,d4

			cmp.b   	ascisp,d4
			beq 		.sp
			cmp.b   	ascicr,d4
			beq 		.return
			cmp.b   	ascibs,d4
			beq 		.bs
			cmp.b   	ascia,d4
			beq 		.a

.bell   	jsr 		bell
			bra 		.keyloop

.sp 		cmp.l   	d6,d5
			beq 		.bell   		; no wraparound
			addq.l  	#1,d6
			move.b  	cprompt,x5
			bsr 		vertical
			moveq   	#0,d7
.sploop 	cmpi.l  	#134,d7 		; algorithm?
			bne 		.algsp
			tst.b   	d3  		 ; algorithm enabled?
			beq 		.nextsp
.algsp  	move.b  	0(a6,d7.l),d1   ; d1.b = e.s. value
			move.b  	0(a4,d7.l),d2   ; d2.b = delta
			bge 		.plussp
			add.b   	d2,d1   		; es is gliding down to ws
			cmp.b   	0(a5,d7.l),d1   ; glided down past ws?
			blt 		.gtltsp
			move.b  	d1,0(a6,d7.l)
			bra 		.nextsp
.plussp 	add.b   	d2,d1   		; es is gliding up to ws
			tst.b   	d1
			blt 		.gtltsp
			cmp.b   	0(a5,d7.l),d1   ; glided up past ws?
			bgt 		.gtltsp
			move.b  	d1,0(a6,d7.l)
			bra 		.nextsp
.gtltsp 	move.b  	0(a5,d7.l),0(a6,d7.l)   ; clamping for gliding past
.nextsp 	addq.l  	#1,d7
			cmpi.l  	#159,d7
			ble 		.sploop
			bsr 		sendeds
			subq.l  	#1,d6
			move.b  	cbakgnd,x5
			bsr 		vertical
			addq.l  	#1,d6
			move.w  	d6,x1   	; update screen's current step number
			jsr 		encode
			move.l  	y1,x1
			move.b  	#37,x2
			move.b  	#3,x3
			move.b  	cmenhed,x4
			move.b  	#2,x5
			jsr 		message
			bra 		.keyloop

.bs 		tst.l   	d6
			beq 		.bell   		; no wraparound
			subq.l  	#1,d6
			move.b  	cprompt,x5
			bsr 		vertical
			moveq   	#0,d7
.bsloop 	cmpi.l  	#134,d7 		; algorithm?
			bne 		.algbs
			tst.b   	d3  		 ; algorithm enabled?
			beq 		.nextbs
.algbs  	move.b  	0(a6,d7.l),d1   ; d1.b = e.s. value
			move.b  	0(a4,d7.l),d2   ; d2.b = delta
			bge 		.plusbs
			sub.b   	d2,d1   		; es is gliding back up to wws
			tst.b   	d1
			blt 		.gtltbs
			cmp.b   	0(a3,d7.l),d1   ; glided up past wss?
			bgt 		.gtltbs
			move.b  	d1,0(a6,d7.l)
			bra 		.nextbs
.plusbs 	sub.b   	d2,d1   		; es is gliding back down to wws
			cmp.b   	0(a3,d7.l),d1   ; glided down past wws?
			blt 		.gtltbs
			move.b  	d1,0(a6,d7.l)
			bra 		.nextbs
.gtltbs 	move.b  	0(a3,d7.l),0(a6,d7.l)   ; clamping for gliding past
.nextbs 	addq.l  	#1,d7
			cmpi.l  	#159,d7
			ble 		.bsloop
			bsr 		sendeds
			addq.l  	#1,d6
			move.b  	cbakgnd,x5
			bsr 		vertical
			subq.l  	#1,d6
			move.w  	d6,x1   	; update screen's current step number
			jsr 		encode
			move.l  	y1,x1
			move.b  	#37,x2
			move.b  	#3,x3
			move.b  	cmenhed,x4
			move.b  	#2,x5
			jsr 		message
			bra 		.keyloop

.a  		move.l  	#glmess,x1
			move.b  	#1,x2
			move.b  	#1,x3
			move.b  	cmessge,x4
			lea 		glmesl,a0
			tst.b   	d3
			bne 		.a1to0
			move.b  	#1,d3   	; enable alg
			add.l   	#180,x1
			move.b  	6(a0),x5
			jsr 		message
			bra 		.keyloop
.a1to0  	clr.b   	d3  		; disable alg
			add.l   	#210,x1
			move.b  	7(a0),x5
			jsr 		message
			bra 		.keyloop

.return 	move.l  	#glname,x1
			move.l  	#wksname,x2
			move.b  	#10,x3
			jsr 		movemem
			move.l  	(a7)+,x5	; restore x5-x1
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1
			movem.l 	(a7)+,#$7FFF	; restore registers
			rts 						; return

sendeds 	jsr 		edtosyn
			jsr 		writdx7
			move.l  	#edspace,x1
			add.l   	#145,x1
			jsr 		writfdx7
			rts

vertical	move.w  	#67,x2
			move.w  	#133,x4
			move.l  	d6,d0
			mulu		#20,d0
			add.w   	horiz,d0
			move.w  	d0,x1
			move.w  	d0,x3
			jsr 		line
			rts

;*****************************************************************************;
;   local data
;*****************************************************************************;

 .data

;   algorithm descriptors (1=carrier, 0=not a carrier)
dx7algs 	.byte   	0,0,0,1,0,1,	0,0,0,1,0,1 	; 1,2
			.byte   	0,0,1,0,0,1,	0,0,1,0,0,1 	; 3,4
			.byte   	0,1,0,1,0,1,	0,1,0,1,0,1 	; 5,6
			.byte   	0,0,0,1,0,1,	0,0,0,1,0,1 	; 7,8
			.byte   	0,0,0,1,0,1,	0,0,1,0,0,1 	; 9,10
			.byte   	0,0,1,0,0,1,	0,0,0,1,0,1 	; 11,12
			.byte   	0,0,0,1,0,1,	0,0,0,1,0,1 	; 13,14
			.byte   	0,0,0,1,0,1,	0,0,0,0,0,1 	; 15,16
			.byte   	0,0,0,0,0,1,	0,0,0,0,0,1 	; 17,18
			.byte   	0,1,1,0,0,1,	0,0,1,0,1,1 	; 19,20
			.byte   	0,1,1,0,1,1,	0,1,1,1,0,1 	; 21,22
			.byte   	0,1,1,0,1,1,	0,1,1,1,1,1 	; 23,24
			.byte   	0,1,1,1,1,1,	0,0,1,0,1,1 	; 25,26
			.byte   	0,0,1,0,1,1,	1,0,0,1,0,1 	; 27,28
			.byte   	0,1,0,1,1,1,	1,0,0,1,1,1 	; 29,30
			.byte   	0,1,1,1,1,1,	1,1,1,1,1,1 	; 31,32

qumess  	.ascii  	"Quick Load xxxxxxxxxxxxx"  	; 0
			.ascii  	"Bank xxxxxxxxxxxxxxxxxxx"  	; 1
			.ascii  	"MIDI Ch xxxxxxxxxxxxxxxx"  	; 2
			.ascii  	"Send? xxxxxxxxxxxxxxxxxx"  	; 3
			.ascii  	"arrows move cursor xxxxx"  	; 4
			.ascii  	" [del]  yes/no xxxxxxxxx"  	; 5
			.ascii  	"[s] send xxxxxxxxxxxxxxx"  	; 6
			.ascii  	"[a] abort send xxxxxxxxx"  	; 7
			.ascii  	"[+][-] change MIDI Ch xx"  	; 8
			.ascii  	"[cr] go to android menu "  	; 9
			.ascii  	"no xxxxxxxxxxxxxxxxxxxxx"  	; 10
			.ascii  	"yes xxxxxxxxxxxxxxxxxxxx"  	; 11
			.ascii  	"Disk i/o error! xxxxxxxx"  	; 12
			.ascii  	"Type any key to return to android menu."   ;13
attnmess	.ascii  	"TX Attenuation:"
qumesl  	.byte   	10,4,7,5,18,14,8,14,21,23,3,3,15,39

glmess  	.ascii  	"Glide xxxxxxxxxxxxxxxxxxxxxxx" 	; 0
			.ascii  	"Step 0  out of xxxxxxxxxxxxxx" 	; 1
			.ascii  	"[sp] step forward xxxxxxxxxxx" 	; 2
			.ascii  	"[cr] go to android menu xxxxx" 	; 3
			.ascii  	"[bs] step backward xxxxxxxxxx" 	; 4
			.ascii  	"[a]  enable/disable algorithm" 	; 5
			.ascii  	"algorithm enabled xxxxxxxxxxx" 	; 6
			.ascii  	"algorithm disabledxxxxxxxxxxx" 	; 7
			.ascii  	"From: xxxxxxxxxxxxxxxxxxxxxxx" 	; 8
			.ascii  	"To: xxxxxxxxxxxxxxxxxxxxxxxxx" 	; 9
glmesl  	.byte   	5,14,17,23,18,29,18,18,5,3

 .bss

delta   	.space  	160 		; for glide functions
horiz   	.space  	2   		; x1 for graphical thing
