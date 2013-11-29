;*****************************************************************************;
;   miscellaneous and added routines  --  Copyright 1986 Tom Bajoras
;*****************************************************************************;

 .text

;*****************************************************************************;
;   dxtotx, txtodx  --  routines to convert between dx and tx controller
;   					ranges (dx ranges from 0-99 while tx ranges from 0-15)
;   setdx7,unsetdx7  --  routines to set-up or un-set-up dx7
;   match   		 --  finds matches in workbank
;   compare 		 --  compares 2 voices
;*****************************************************************************;

 .global dxtotx

dxtotx  	clr.b   	y1
			cmpi.b  	#7,x1
			blt 		.return

			move.b  	#1,y1
			cmpi.b  	#14,x1
			blt 		.return

			move.b  	#2,y1
			cmpi.b  	#20,x1
			blt 		.return

			move.b  	#3,y1
			cmpi.b  	#27,x1
			blt 		.return

			move.b  	#4,y1
			cmpi.b  	#33,x1
			blt 		.return

			move.b  	#5,y1
			cmpi.b  	#40,x1
			blt 		.return

			move.b  	#6,y1
			cmpi.b  	#46,x1
			blt 		.return

			move.b  	#7,y1
			cmpi.b  	#53,x1
			blt 		.return

			move.b  	#8,y1
			cmpi.b  	#60,x1
			blt 		.return

			move.b  	#9,y1
			cmpi.b  	#66,x1
			blt 		.return

			move.b  	#10,y1
			cmpi.b  	#73,x1
			blt 		.return

			move.b  	#11,y1
			cmpi.b  	#79,x1
			blt 		.return

			move.b  	#12,y1
			cmpi.b  	#86,x1
			blt 		.return

			move.b  	#13,y1
			cmpi.b  	#92,x1
			blt 		.return

			move.b  	#14,y1
			cmpi.b  	#99,x1
			blt 		.return

			move.b  	#15,y1
.return 	rts

 .global txtodx

txtodx  	clr.b   	y1
			tst.b   	x1
			beq 		.return

			move.b  	#7,y1
			cmpi.b  	#1,x1
			beq 		.return

			move.b  	#14,y1
			cmpi.b  	#2,x1
			beq 		.return

			move.b  	#20,y1
			cmpi.b  	#3,x1
			beq 		.return

			move.b  	#27,y1
			cmpi.b  	#4,x1
			beq 		.return

			move.b  	#33,y1
			cmpi.b  	#5,x1
			beq 		.return

			move.b  	#40,y1
			cmpi.b  	#6,x1
			beq 		.return

			move.b  	#46,y1
			cmpi.b  	#7,x1
			beq 		.return

			move.b  	#53,y1
			cmpi.b  	#8,x1
			beq 		.return

			move.b  	#60,y1
			cmpi.b  	#9,x1
			beq 		.return

			move.b  	#66,y1
			cmpi.b  	#10,x1
			beq 		.return

			move.b  	#73,y1
			cmpi.b  	#11,x1
			beq 		.return

			move.b  	#79,y1
			cmpi.b  	#12,x1
			beq 		.return

			move.b  	#86,y1
			cmpi.b  	#13,x1
			beq 		.return

			move.b  	#92,y1
			cmpi.b  	#14,x1
			beq 		.return

			move.b  	#99,y1
.return 	rts

;*****************************************************************************;
;   checkws  --  clamp w.s. pars to legal ranges
;   x1.l --> 159 bytes to check
;*****************************************************************************;

 .global checkws

checkws 	movem.l 	#$FFFE,-(a7)	; save registers
			move.l  	x1,a0   		; a0--> 159 bytes to check
			lea 		parminfo,a1 	; a1--> 8 bytes per byte to be checked

			move.w  	#159,d0 		; d0.w = 159 to 0
.loop   	move.b  	(a0),d7 		; d7.b = byte to be checked
			cmp.b   	(a1),d7 		; clamp >= low mark
			blt 		.toolow
			cmp.b   	1(a1),d7
			bgt 		.toohigh
			bra 		.next   		; ok

.toolow 	move.b  	(a1),(a0)
			bra 		.next

.toohigh	move.b  	1(a1),(a0)

.next   	addq.l  	#1,a0
			addq.l  	#8,a1
			subq.w  	#1,d0
			bgt 		.loop

			movem.l 	(a7)+,#$7FFF	; restore registers
			rts

;*****************************************************************************;
;   setdx7, unsetdx7  --  no entry or exit conditions
;*****************************************************************************;

 .global setdx7
 .global unsetdx7

setdx7  	movem.l 	#$FFFE,-(a7)		; save all registers
			move.l  	x1,-(a7)			; and x1-x3
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)

			move.l  	#dxsetup,x1
			move.l  	#synbuf,x2
			move.w  	dxsetl,d0
			addq.b  	#1,d0
			move.b  	d0,x3
			jsr 		movemem 	; copy set-up sequence to synbuf

			lea 		synbuf,a0
			move.b  	midich,d0
			subq.b  	#1,d0   		; d0 = $0 - $F
			add.b   	d0,2(a0)		; channelize set-up sequence
			add.b   	d0,9(a0)
			add.b   	d0,16(a0)
			add.b   	d0,23(a0)
			add.b   	d0,30(a0)
			add.b   	d0,35(a0)
			add.b   	d0,40(a0)
			add.b   	d0,47(a0)
			add.b   	d0,52(a0)
			add.b   	d0,57(a0)

			move.w  	dxsetl,d0   	; # bytes in sequence - 1
			bra 		doit			; branch to setdx7/unsetdx7 common code

unsetdx7	movem.l 	#$FFFE,-(a7)	; save all registers
			move.l  	x1,-(a7)		; and x1-x3
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)

			move.l  	#dxunset,x1
			move.l  	#synbuf,x2
			move.w  	dxunl,d0
			addq.b  	#1,d0
			move.b  	d0,x3
			jsr 		movemem 	; copy un-set-up sequence to synbuf

			lea 		synbuf,a0
			move.b  	midich,d0
			subq.b  	#1,d0   		; d0 = $0 - $F
			add.b   	d0,2(a0)		; channelize un-set-up sequence
			add.b   	d0,9(a0)
			add.b   	d0,16(a0)
			add.b   	d0,23(a0)

			move.w  	dxunl,d0	   ; # bytes in sequence - 1

doit		move.l  	#synbuf,-(a7)   ; send sequence to synth
			move.w  	d0,-(a7)
			move.w  	#12,-(a7)
			trap		#14
			move.l  	#24,d0
			jsr 		getlong 		; d0.l = 8
			add.l   	d0,a7

			move.l  	(a7)+,x3			; restore x3-x1
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1
			movem.l 	(a7)+,#$7FFF		; restore registers
			rts 							; return

;*****************************************************************************;
;   match -- finds matches in workbank
;      x1.w = maximum # of different parameters (0-159)
;      x2.b = slot # (1-32)
;*****************************************************************************;

 .global match
match   	movem.l 	#$FFFE,-(a7)		; save registers
			move.l  	x1,-(a7)			; and x1-x5
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)

			move.w  	x1,d7   			; d7.w = max differ
			clr.l   	d6
			move.b  	x2,d6
			subq.l  	#1,d6   			; d6.l = slot to be matched (0-31)
			lea 		wkbank,a6
			move.l  	d6,d0
			mulu		#160,d0
			add.l   	d0,a6   			; a6 --> data to be matched
			move.b  	cmenu,d3			; weird way to invert red text
			move.b  	#2,cmenu
			move.b  	#1,invtext

			clr.l   	d5  				; for d5.l = 0 to 31
bigloop 	lea 		wkbank,a5
			move.l  	d5,d0
			mulu		#160,d0
			add.l   	d0,a5   			; a5 --> slot
			move.l  	a6,a0
			clr.w   	d1  				; d1.w = # differ
			move.w  	#159,d2 			; d2 = counter (159 times)
cmploop 	cmpm.b  	(a0)+,(a5)+
			beq 		.eq
			addq.w  	#1,d1
.eq 		subq.w  	#1,d2
			bgt 		cmploop
			cmp.w   	d7,d1
			bgt 		endbig
			move.l  	d5,x1
			jsr 		redisbnk
endbig  	addq.w  	#1,d5
			cmpi.w  	#31,d5
			ble 		bigloop

			move.b  	d3,cmenu
			clr.b   	invtext
			move.l  	#6,x1
			jsr 		creturn
			move.l  	#done,x1
			move.b  	#1,x2
			move.b  	cursory,x3
			move.b  	cprompt,x4
			move.b  	donelng,x5
			jsr 		message
			jsr 		getkey
			jsr 		unpromp
			jsr 		disbank 			; repair screen
			move.l  	(a7)+,x5			; restore x5-x1
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1
			movem.l 	(a7)+,#$7FFF		; restore registers
			rts

;*****************************************************************************;
;   compare -- compare 2 voices
;      x1.l --> data 1, x2.l --> data 2, x3.l --> name 1, x4.l --> name 2
;*****************************************************************************;

 .global compare
compare 	movem.l 	#$FFFE,-(a7)		; save registers
			move.l  	x1,a3   			; a3 --> data 1
			move.l  	x2,a4   			; a4 --> data 2
			move.l  	x3,a5   			; a5 --> name 1
			move.l  	x4,a6   			; a6 --> name 2

			jsr 		blnkscr 			; start with a blank screen
			move.b  	#12,x1  			; change colors
			jsr 		setcolor

			move.l  	#cmpmess,x1 		; center heading
			move.b  	xmax,d0
			lea 		cmpmesl,a0
			sub.b   	(a0),d0
			lsr.b   	#1,d0
			addq.b  	#1,d0
			move.b  	d0,x2
			move.b  	#1,x3
			move.b  	cmenhed,x4
			move.b  	(a0),x5
			jsr 		message

			move.l  	a5,x1   			; voice names
			move.b  	#20,x2
			move.b  	#10,x5
			jsr 		message
			move.l  	a6,x1
			move.b  	#50,x2
			jsr 		message
			move.l  	#cmpmess,x1
			add.l   	#125,x1
			move.b  	#71,x2
			move.b  	5(a0),x5
			jsr 		message 			; difference column heading

			move.b  	coutlne,x5  		; nice lines
			move.w  	#86,x1
			move.w  	#12,x2
			move.w  	#631,x3
			move.w  	#12,x4
			jsr 		line
			move.w  	#186,x2
			move.w  	#186,x4
			jsr 		line
			move.w  	#12,x2
			move.w  	#186,x4
			move.w  	#86,x1
			move.w  	#86,x3
			jsr 		line
			move.w  	#319,x1
			move.w  	#319,x3
			jsr 		line
			move.w  	#559,x1
			move.w  	#559,x3
			jsr 		line
			move.w  	#631,x1
			move.w  	#631,x3
			jsr 		line

			move.l  	#cmpmess,x1 			; menu
			lea 		cmpmesl,a0
			move.b  	cmenu,x4
			move.b  	ymax,x3
			add.l   	#25,x1
			move.b  	#4,x2
			move.b  	1(a0),x5
			jsr 		message
			add.l   	#25,x1
			move.b  	#28,x2
			move.b  	2(a0),x5
			jsr 		message
			add.l   	#25,x1
			move.b  	#54,x2
			move.b  	3(a0),x5
			jsr 		message

			clr.w   	d7  				; d7.w = screen # (0-7)
.scrloop	move.l  	#cmpmess,x1
			add.l   	#100,x1
			move.b  	#1,x2
			move.b  	#1,x3
			move.b  	cmenhed,x4
			lea 		cmpmesl,a0
			move.b  	4(a0),x5
			jsr 		message 			; screen #
			move.b  	d7,d0
			add.b   	#$31,d0 			; encoded
			move.b  	d0,x1
			addq.b  	#8,x2
			jsr 		outchar

			move.w  	d7,d2
			mulu		#21,d2  			; d2.l --> starting par #
			move.w  	d2,d0
			mulu		#11,d0
			lea 		parmname,a0
			add.l   	d0,a0   			; a0 --> parameter names
			clr.l   	d0  				; d0 = 0 to 20
.parloop	move.l  	a0,x1
			move.l  	d0,d1
			mulu		#11,d1
			add.l   	d1,x1
			move.b  	#1,x2
			move.b  	d0,x3
			addq.b  	#3,x3
			move.b  	cmessge,x4
			move.b  	#10,x5
			jsr 		message
			move.l  	d2,d1
			add.l   	d0,d1
			move.b  	#25,d5
			move.b  	x3,d6
			move.l  	a3,a5
			move.l  	a3,a1
			bsr 		.outparc
			move.b  	#55,d5
			move.l  	a4,a5
			move.l  	a4,a1
			bsr 		.outparc
			cmpi.w  	#158,d1
			ble 		.do_dif
			move.l  	#blank12,x1
			move.b  	cbakgnd,x4
			bra 		.skipdif
.do_dif 	move.b  	0(a3,d1.l),d3   		; put up difference
			sub.b   	0(a4,d1.l),d3
			bge 		.ge
			neg.b   	d3
.ge 		andi.w  	#$7f,d3
			beq 		.zero
			move.w  	d3,x1
			jsr 		encode
			move.l  	y1,x1
			bra 		.zerox
.zero   	move.l  	#zeromess,x1
.zerox  	move.b  	cmessge,x4
			tst.b   	d3
			bne 		.skipdif
			move.b  	cprompt,x4
.skipdif	move.b  	#74,x2
			move.b  	d6,x3
			move.b  	#3,x5
			jsr 		message
			addq.l  	#1,d0
			cmpi.l  	#20,d0
			ble 		.parloop

.keyloop	jsr 		getkey
			move.b  	y1,d0
			cmp.b   	ascin,d0
			beq 		.next
			cmp.b   	ascip,d0
			beq 		.prev
			cmp.b   	ascicr,d0
			beq 		.return
			jsr 		bell
			bra 		.keyloop

.next   	addq.w  	#1,d7
			cmp.w   	#7,d7
			ble 		.scrloop
			clr.w   	d7
			bra 		.scrloop
.prev   	subq.w  	#1,d7
			bge 		.scrloop
			moveq   	#7,d7
			bra 		.scrloop

.return 	movem.l 	(a7)+,#$7FFF		; restore registers
			rts

.outparc	movem.l 	#$FFFE,-(a7)
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)

			move.l  	#blank12,x1
			move.b  	d5,x2
			move.b  	d6,x3
			move.b  	cbakgnd,x4
			move.b  	#12,x5
			jsr 		message 			; blank out previous parameter
			cmpi.l  	#158,d1
			bgt 		.outret

			move.b  	cmessge,x3
			jmp 		outparc

.outret 	move.l  	(a7)+,x5
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1
			movem.l 	(a7)+,#$7FFF
			rts

;******************************************************************************
; local data and variables
;******************************************************************************

 .data

blank12 	.byte   	32,32,32,32,32,32,   32,32,32,32,32,32
cmpmess 	.ascii  	"<-- Compare --> xxxxxxxx"  	; 0
			.ascii  	"[n] next screen xxxxxxxx"  	; 1
			.ascii  	"[p] previous screen xxxx"  	; 2
			.ascii  	"[cr] go to Android menu "  	; 3
			.ascii  	"Screen: xxxxxxxxxxxxxxxx"  	; 4
			.ascii  	"Difference xxxxxxxxxxxxx"  	; 5
cmpmesl 	.byte   	15,15,19,23,7,10
zeromess	.ascii  	"---"
done		.ascii  	"Type any key to exit from Find Matches mode."
donelng 	.byte   	44
 .global parmname
parmname	.ascii  	"OP 6 EG R1"			; screen 1
			.ascii  	"OP 6 EG R2"
			.ascii  	"OP 6 EG R3"
			.ascii  	"OP 6 EG R4"
			.ascii  	"OP 6 EG L1"
			.ascii  	"OP 6 EG L2"
			.ascii  	"OP 6 EG L3"
			.ascii  	"OP 6 EG L4"
			.ascii  	"OP 6 SC BP"
			.ascii  	"OP 6 SC LD"
			.ascii  	"OP 6 SC RD"
			.ascii  	"OP 6 SC LC"
			.ascii  	"OP 6 SC RC"
			.ascii  	"OP 6 Krate"
			.ascii  	"OP 6 AMS  "
			.ascii  	"OP 6 VEL  "
			.ascii  	"OP 6 Level"
			.ascii  	"OP 6 Mode "
			.ascii  	"OP 6 CFQ  "
			.ascii  	"OP 6 FFQ  "
			.ascii  	"OP 6 DTN  "
			.ascii  	"OP 5 EG R1"			; screen 2
			.ascii  	"OP 5 EG R2"
			.ascii  	"OP 5 EG R3"
			.ascii  	"OP 5 EG R4"
			.ascii  	"OP 5 EG L1"
			.ascii  	"OP 5 EG L2"
			.ascii  	"OP 5 EG L3"
			.ascii  	"OP 5 EG L4"
			.ascii  	"OP 5 SC BP"
			.ascii  	"OP 5 SC LD"
			.ascii  	"OP 5 SC RD"
			.ascii  	"OP 5 SC LC"
			.ascii  	"OP 5 SC RC"
			.ascii  	"OP 5 Krate"
			.ascii  	"OP 5 AMS  "
			.ascii  	"OP 5 VEL  "
			.ascii  	"OP 5 Level"
			.ascii  	"OP 5 Mode "
			.ascii  	"OP 5 CFQ  "
			.ascii  	"OP 5 FFQ  "
			.ascii  	"OP 5 DTN  "
			.ascii  	"OP 4 EG R1"			; screen 3
			.ascii  	"OP 4 EG R2"
			.ascii  	"OP 4 EG R3"
			.ascii  	"OP 4 EG R4"
			.ascii  	"OP 4 EG L1"
			.ascii  	"OP 4 EG L2"
			.ascii  	"OP 4 EG L3"
			.ascii  	"OP 4 EG L4"
			.ascii  	"OP 4 SC BP"
			.ascii  	"OP 4 SC LD"
			.ascii  	"OP 4 SC RD"
			.ascii  	"OP 4 SC LC"
			.ascii  	"OP 4 SC RC"
			.ascii  	"OP 4 Krate"
			.ascii  	"OP 4 AMS  "
			.ascii  	"OP 4 VEL  "
			.ascii  	"OP 4 Level"
			.ascii  	"OP 4 Mode "
			.ascii  	"OP 4 CFQ  "
			.ascii  	"OP 4 FFQ  "
			.ascii  	"OP 4 DTN  "
			.ascii  	"OP 3 EG R1"			; screen 4
			.ascii  	"OP 3 EG R2"
			.ascii  	"OP 3 EG R3"
			.ascii  	"OP 3 EG R4"
			.ascii  	"OP 3 EG L1"
			.ascii  	"OP 3 EG L2"
			.ascii  	"OP 3 EG L3"
			.ascii  	"OP 3 EG L4"
			.ascii  	"OP 3 SC BP"
			.ascii  	"OP 3 SC LD"
			.ascii  	"OP 3 SC RD"
			.ascii  	"OP 3 SC LC"
			.ascii  	"OP 3 SC RC"
			.ascii  	"OP 3 Krate"
			.ascii  	"OP 3 AMS  "
			.ascii  	"OP 3 VEL  "
			.ascii  	"OP 3 Level"
			.ascii  	"OP 3 Mode "
			.ascii  	"OP 3 CFQ  "
			.ascii  	"OP 3 FFQ  "
			.ascii  	"OP 3 DTN  "
			.ascii  	"OP 2 EG R1"			; screen 5
			.ascii  	"OP 2 EG R2"
			.ascii  	"OP 2 EG R3"
			.ascii  	"OP 2 EG R4"
			.ascii  	"OP 2 EG L1"
			.ascii  	"OP 2 EG L2"
			.ascii  	"OP 2 EG L3"
			.ascii  	"OP 2 EG L4"
			.ascii  	"OP 2 SC BP"
			.ascii  	"OP 2 SC LD"
			.ascii  	"OP 2 SC RD"
			.ascii  	"OP 2 SC LC"
			.ascii  	"OP 2 SC RC"
			.ascii  	"OP 2 Krate"
			.ascii  	"OP 2 AMS  "
			.ascii  	"OP 2 VEL  "
			.ascii  	"OP 2 Level"
			.ascii  	"OP 2 Mode "
			.ascii  	"OP 2 CFQ  "
			.ascii  	"OP 2 FFQ  "
			.ascii  	"OP 2 DTN  "
			.ascii  	"OP 1 EG R1"			; screen 6
			.ascii  	"OP 1 EG R2"
			.ascii  	"OP 1 EG R3"
			.ascii  	"OP 1 EG R4"
			.ascii  	"OP 1 EG L1"
			.ascii  	"OP 1 EG L2"
			.ascii  	"OP 1 EG L3"
			.ascii  	"OP 1 EG L4"
			.ascii  	"OP 1 SC BP"
			.ascii  	"OP 1 SC LD"
			.ascii  	"OP 1 SC RD"
			.ascii  	"OP 1 SC LC"
			.ascii  	"OP 1 SC RC"
			.ascii  	"OP 1 Krate"
			.ascii  	"OP 1 AMS  "
			.ascii  	"OP 1 VEL  "
			.ascii  	"OP 1 Level"
			.ascii  	"OP 1 Mode "
			.ascii  	"OP 1 CFQ  "
			.ascii  	"OP 1 FFQ  "
			.ascii  	"OP 1 DTN  "
			.ascii  	"Pitch R1  "			; screen 7
			.ascii  	"Pitch R2  "
			.ascii  	"Pitch R3  "
			.ascii  	"Pitch R4  "
			.ascii  	"Pitch L1  "
			.ascii  	"Pitch L2  "
			.ascii  	"Pitch L3  "
			.ascii  	"Pitch L4  "
			.ascii  	"Algorithm "
			.ascii  	"Feedback  "
			.ascii  	"Oper Sync "
			.ascii  	"LFO Speed "
			.ascii  	"LFO Delay "
			.ascii  	"LFO  PMD  "
			.ascii  	"LFO  AMD  "
			.ascii  	"LFO  Sync "
			.ascii  	"LFO  Wave "
			.ascii  	"P Mod Sens"
			.ascii  	"Transpose "
			.ascii  	"Monophonic"
			.ascii  	"PB Range  "
			.ascii  	"PB  Step  "			; screen 8
			.ascii  	"Port Mode "
			.ascii  	"Glissando "
			.ascii  	"Port Time "
			.ascii  	"MW  Range "
			.ascii  	"MW Assign "
			.ascii  	"FC  Range "
			.ascii  	"FC Assign "
			.ascii  	"BC  Range "
			.ascii  	"BC Assign "
			.ascii  	"AT  Range "
			.ascii  	"AT Assign "
			.byte   	32,32,32,32,32,32,32,32,32,32,32
			.byte   	32,32,32,32,32,32,32,32,32,32,32
			.byte   	32,32,32,32,32,32,32,32,32,32,32
			.byte   	32,32,32,32,32,32,32,32,32,32,32
			.byte   	32,32,32,32,32,32,32,32,32,32,32
			.byte   	32,32,32,32,32,32,32,32,32,32,32
			.byte   	32,32,32,32,32,32,32,32,32,32,32
			.byte   	32,32,32,32,32,32,32,32,32,32,32
			.byte   	32,32,32,32,32,32,32,32,32,32,32
