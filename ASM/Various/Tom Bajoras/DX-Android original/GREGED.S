;*****************************************************************************;
;   greged -- graphical operator e.g. editor
;   edmenu -- put up greged/leved/scaled menu
;   		   Copyright 1986 Tom Bajoras
;   no entry conditions, no exit conditions
;*****************************************************************************;

 .text

 .global greged

greged  	movem.l 	#$FFFE,-(a7)		; save registers
			move.l  	x1,-(a7)			; and x1-x5
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)

			jsr 		blnkscr 		; start with blank screen
			move.b  	#4,x1
			jsr 		setcolor

;  NOTE: register variables: a6--> edspace, a5--> wkspace , d6.l = operator #
;   	 d7.l = parameter #, d4.b = key, d5.l = cursorx, d3.l = cursory

			lea 		edspace,a6  	; a6 --> edited sound
			lea 		wkspace,a5  	; a5 --> original sound
			clr.l   	d6  		 ; operator # to start with

; use same axes system as scaling editor:
			jsr 		drawaxes

;   if (monedit <2) send e.s. non-f-pars to synth
			cmpi.b  	#2,monedit
			beq 		.f_only
			jsr 		edtosyn
			jsr 		writdx7

;   if (monedit <>1) send e.s. f-pars to synth
			cmpi.b  	#1,monedit
			beq 		.skip_f
.f_only 	move.l  	#edspace,x1
			add.l   	#145,x1
			jsr 		writfdx7

.skip_f:
;   put up screen:
			lea 		editmesl,a0 	; a0 --> lengths of edit mess's
			move.l  	#editmess,x1
			add.l   	#1480,x1
			move.b  	#5,x2
			move.b  	#1,x3
			move.b  	cmenhed,x4
			move.b  	37(a0),x5
			jsr 		message 			; title
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.l  	#wksname,x1
			move.b  	cmessge,x4
			move.b  	#10,x5
			jsr 		message 		; append w.s. name

			move.l  	#editmess,x1
			add.l   	#1240,x1
			move.b  	xmax,d0
			subq.b  	#4,d0
			sub.b   	31(a0),d0
			move.b  	d0,x2
			move.b  	#1,x3
			move.b  	cmenhed,x4
			move.b  	31(a0),x5
			jsr 		message 		; "operator _"

;  operator # in upper rh corner
			move.b  	xmax,x2
			subq.b  	#3,x2
			move.b  	#$31,x1
			add.b   	d6,x1
			move.b  	cmessge,x4
			jsr 		outchar

;   put up L1-L4 parameter names
			move.l  	#parmes2,x1
			add.l   	#75,x1
			move.b  	#11,x2
			move.b  	#18,x3
			move.b  	cmenkey,x4
			lea 		parmes2l,a0
			add.l   	#5,a0
			clr.l   	d0
.namloop1   move.b  	0(a0,d0.l),x5
			jsr 		message
			add.b   	#32,x2
			jsr 		message
			add.l   	#15,x1
			sub.b   	#25,x2
			addq.l  	#1,d0
			cmpi.l  	#3,d0
			ble 		.namloop1

; put up R1-R4 parameter names
			move.l  	#parmes2,x1
			add.l   	#15,x1
			move.b  	#11,x2
			move.b  	#19,x3
			move.b  	cmenkey,x4
			lea 		parmes2l,a0
			add.l   	#1,a0
			clr.l   	d0
.namloop2   move.b  	0(a0,d0.l),x5
			jsr 		message
			add.b   	#32,x2
			jsr 		message
			add.l   	#15,x1
			sub.b   	#25,x2
			addq.l  	#1,d0
			cmpi.l  	#3,d0
			ble 		.namloop2

;  put up "edited"
			move.l  	#editmess,x1
			add.l   	#1360,x1
			move.b  	#1,x2
			move.b  	#18,x3
			move.b  	cmenkey,x4
			lea 		editmesl,a0
			move.b  	34(a0),x5
			jsr 		message

;  put up "original"
			add.l   	#40,x1
			move.b  	#71,x2
			move.b  	35(a0),x5
			jsr 		message

;  write parameters
			clr.l   	d3
.parloop1   clr.l   	d5
			move.b  	cmessge,x4
.parloop2   bsr 		out_e
			bsr 		out_w
			addq.l  	#1,d5
			cmpi.l  	#3,d5
			ble 		.parloop2
			addq.l  	#1,d3
			cmpi.l  	#1,d3
			ble 		.parloop1

;  put up display
			jsr 		renew
			jsr 		drawegw
			jsr 		drawege

;  put up menu
			bsr 		edmenu
			move.l  	#editmess,x1
			add.l   	#1760,x1
			move.b  	#1,x2
			move.b  	#22,x3
			move.b  	cmenkey,x4
			lea 		editmesl,a0
			move.b  	44(a0),x5
			jsr 		message 			; sp
			move.l  	#editmess,x1
			add.l   	#1800,x1
			move.b  	#8,x2
			move.b  	cmenu,x4
			move.b  	45(a0),x5
			jsr 		message 			; next operator

;  initialize cursor
			clr.l   	d5  		; cursor-x
			clr.l   	d3  		; cursor-y

;  d7.l = par # = 21(5-d6) + 4(1-d3) + d5
.cursloop   move.l  	d5,d7
			moveq   	#1,d0
			sub.l   	d3,d0
			lsl.l   	#2,d0
			add.l   	d0,d7
			moveq   	#5,d0
			sub.l   	d6,d0
			mulu		#21,d0
			add.l   	d0,d7

;   mark parameter at cursor
			move.b  	cprompt,x4
			bsr 		out_e

;   get a key
.keyloop	jsr 		getkey
			trap		#11 			; key repeat on
			move.b  	y1,d4   		; d4.b = gotten key

;   branch according to key
.keyloop2   cmp.b   	ascilef,d4
			beq 		.left
			cmp.b   	ascirit,d4
			beq 		.right
			cmp.b   	ascidwn,d4
			beq 		.downup
			cmp.b   	asciup,d4
			beq 		.downup
			cmp.b   	ascihelp,d4
			beq 		.help
			cmp.b   	asciplus,d4
			beq 		.plus
			cmp.b   	ascidash,d4
			beq 		.minus
			cmp.b   	asciu,d4
			beq 		.undo
			cmp.b   	ascitab,d4
			beq 		.tab
			cmp.b   	ascibs,d4
			beq 		.bs
			cmp.b   	asciw,d4
			beq 		.w
			cmp.b   	ascie,d4
			beq 		.e
			cmp.b   	ascisp,d4
			beq 		.sp
			cmp.b   	ascicr,d4
			beq 		.return
			cmp.b   	ascidel,d4
			beq 		.del
			cmp.b   	asci0,d4
			blt 		.badkey
			cmp.b   	asci9,d4
			ble 		.number
.badkey 	jsr 		bell
			bra 		.keyloop

.left   	move.b  	cmessge,x4
			bsr 		out_e
			subq.l  	#1,d5   	; move cursor to left
			bge 		.cursloop
			moveq   	#3,d5   	; wrap around
			bra 		.cursloop

.right  	move.b  	cmessge,x4
			bsr 		out_e
			addq.l  	#1,d5   	; move cursor to right
			cmpi.l  	#3,d5
			ble 		.cursloop
			clr.l   	d5  	 ; wrap around
			bra 		.cursloop

.downup 	move.b  	cmessge,x4
			bsr 		out_e
			tst.l   	d3
			beq 		.down
			clr.l   	d3
			bra 		.cursloop
.down   	moveq   	#1,d3
			bra 		.cursloop

.help   	jsr 		hardcopy
			bra 		.keyloop

.tab		move.b  	0(a6,d7.l),d0   ; par value to be tabbed
			add.b   	#10,d0  		; assume all greged tabs=10
			cmp.b   	#99,d0  		; assume all greged high marks = 99
			bgt 		.badkey 		; overflow
			move.b  	d0,0(a6,d7.l)   ; ok
			bra 		.update 		; update display, loop for next key

.bs 		move.b  	0(a6,d7.l),d0   ; par value to be tabbed
			sub.b   	#10,d0  		; assume all greged tabs=10
			blt 		.badkey 		; underflow? (assume all low marks=0)
			move.b  	d0,0(a6,d7.l)   ; ok
			bra 		.update

.plus   	addq.b  	#1,0(a6,d7.l)
			cmpi.b  	#99,0(a6,d7.l)  ; have we gone over the high mark?
			ble 		.update
			clr.b   	0(a6,d7.l)   ; yes: wraparound
.update 	jsr 		renew
			jsr 		drawegw
			jsr 		drawege 		; re-do display
			move.b  	cprompt,x4
			bsr 		out_e
			cmpi.b  	#2,monedit
			beq 		.keyloop
			jsr 		sendpar
			bra 		.keyloop

.minus  	subq.b  	#1,0(a6,d7.l)
			cmp.b   	#0,0(a6,d7.l)   ; have we gone under the low mark?
			bge 		.update
			move.b  	#99,0(a6,d7.l)  ; yes: wraparound
			bra 		.update

.undo   	jsr 		getkey  			; get 2 more keys: n and d
			move.b  	y1,d4
			cmp.b   	ascin,d4
			bne 		.badkey
			jsr 		getkey
			move.b  	y1,d4
			cmp.b   	ascid,d4
			bne 		.badkey
			move.l  	#105,d7
			move.l  	d6,d0
			mulu		#21,d0
			sub.l   	d0,d7
			move.b  	0(a5,d7.l),0(a6,d7.l)   ; unedit the 8 parameters
			move.b  	1(a5,d7.l),1(a6,d7.l)
			move.b  	2(a5,d7.l),2(a6,d7.l)
			move.b  	3(a5,d7.l),3(a6,d7.l)
			move.b  	4(a5,d7.l),4(a6,d7.l)
			move.b  	5(a5,d7.l),5(a6,d7.l)
			move.b  	6(a5,d7.l),6(a6,d7.l)
			move.b  	7(a5,d7.l),7(a6,d7.l)
; re-output 5 parameters
			move.l  	d5,-(a7)		; save cursorx
			move.l  	d3,-(a7)		; save cursory
			move.b  	cmessge,x4
			clr.l   	d3
.undloop1   clr.l   	d5
.undloop2   bsr 		out_e
			addq.l  	#1,d5
			cmpi.l  	#3,d5
			ble 		.undloop2
			addq.l  	#1,d3
			cmpi.l  	#1,d3
			ble 		.undloop1
			move.l  	(a7)+,d3		; restore cursory
			move.l  	(a7)+,d5		; restore cursorx
; if monedit<>2 send 8 parameters to synth
			cmpi.b  	#2,monedit
			beq 		.undo2
			clr.l   	d1  		; for d1.l=0 to 7
.sendloop   jsr 		sendpar
			addq.l  	#1,d7
			addq.l  	#1,d1
			cmpi.l  	#7,d1
			ble 		.sendloop
.undo2  	jsr 		renew
			jsr 		drawegw
			jsr 		drawege 		; re-do display
			bra 		.cursloop

; if monedit <> 2 send w.s. non-f-pars to synth
.w  		cmpi.b  	#2,monedit
			beq 		.f_onlyw
			jsr 		wstosyn
			jsr 		writdx7
;   if (monedit <>1) send w.s. f-pars to synth
			cmpi.b  	#1,monedit
			beq 		.keyloop
.f_onlyw	move.l  	#wkspace,x1
			add.l   	#145,x1
			jsr 		writfdx7
			bra 		.keyloop

; if monedit <> 2 send e.s. non-f-pars to synth
.e  		cmpi.b  	#2,monedit
			beq 		.f_onlye
			jsr 		edtosyn
			jsr 		writdx7
;   if (monedit <>1) send e.s. f-pars to synth
			cmpi.b  	#1,monedit
			beq 		.keyloop
.f_onlye	move.l  	#edspace,x1
			add.l   	#145,x1
			jsr 		writfdx7
			bra 		.keyloop

.del		move.b  	0(a5,d7.l),0(a6,d7.l)   	; unedit parameter
			bra 		.update

.number 	clr.l   	d0
			move.b  	0(a6,d7.l),d0
			divu		#10,d0
			lsr.l   	#8,d0
			lsr.l   	#8,d0
			clr.l   	d1
			move.b  	d4,d1
			sub.b   	#$30,d1
			mulu		#10,d1
			add.b   	d1,d0
			move.b  	d0,0(a6,d7.l)
			move.b  	cprompt,x4
			bsr 		out_e
			jsr 		renew
			jsr 		drawegw
			jsr 		drawege 		; re-do display
			cmpi.b  	#2,monedit
			beq 		.skipsend
			jsr 		sendpar
.skipsend   jsr 		getkey  	 ; get another key
			move.b  	y1,d4   	 ; d4.b = gotten key
			cmp.b   	asci0,d4
			blt 		.keyloop2
			cmp.b   	asci9,d4
			bgt 		.keyloop2
			clr.l   	d0
			move.b  	0(a6,d7.l),d0
			divu		#10,d0
			andi.l  	#$FFFF,d0
			mulu		#10,d0
			add.b   	d4,d0
			sub.b   	#$30,d0
			move.b  	d0,0(a6,d7.l)
			bra 		.update

.sp 		addq.l  	#1,d6
			cmpi.l  	#5,d6
			ble 		.spx
			clr.l   	d6
;  update # in upper righthand corner
.spx		move.b  	d6,x1
			add.b   	#$31,x1
			move.b  	xmax,x2
			subq.b  	#3,x2
			move.b  	#1,x3
			move.b  	cmessge,x4
			jsr 		outchar
			jsr 		renew
			jsr 		drawegw
			jsr 		drawege 		; re-do display
; re-output all parameters
			move.l  	d5,-(a7)		; save cursorx
			move.l  	d3,-(a7)		; save cursory
			move.b  	cmessge,x4
			clr.l   	d3
.sploop1	clr.l   	d5
.sploop2	bsr 		out_e
			bsr 		out_w
			addq.l  	#1,d5
			cmpi.l  	#3,d5
			ble 		.sploop2
			addq.l  	#1,d3
			cmpi.l  	#1,d3
			ble 		.sploop1
			move.l  	(a7)+,d3		; restore cursory
			move.l  	(a7)+,d5		; restore cursorx
			bra 		.cursloop

.return 	move.l  	(a7)+,x5	; restore x5-x1
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1
			movem.l 	(a7)+,#$7FFF	; restore registers
			rts 						; return

;******************************************************************************
;   local routines to output a parameter value
;   entry conditions: d5.l = cursorx, d6.l = 0-5 op # , x4.b = color
;******************************************************************************

out_w   	movem.l 	#$FFFE,-(a7)	; save registers
			lea 		wkspace,a2  	; a2 --> original version
			move.b  	#32,d4  		; offset for x-coord
			bra 		out_x

out_e   	movem.l 	#$FFFE,-(a7)	; save registers
			lea 		edspace,a2  	; a2 --> edited version
			clr.b   	d4  		 ; offset for x-coord

out_x   	move.l  	d5,d7
			moveq   	#1,d0
			sub.l   	d3,d0
			lsl.l   	#2,d0
			add.l   	d0,d7
			moveq   	#5,d0
			sub.l   	d6,d0
			mulu		#21,d0
			add.l   	d0,d7   	; d7.l = parameter #

			clr.l   	d2
			move.b  	0(a2,d7.l),d2   ; d2.l = value
			move.w  	d2,x1
			jsr 		encode
			lea 		namebuf,a0
			cmpi.b  	#9,d2
			bgt 		.gt9
			move.b  	(a0),1(a0)  	; convert 0-9 to 00-09
			move.b  	asci0,(a0)
.gt9		move.l  	#namebuf,x1
			move.b  	#2,x5

			move.b  	d3,x3
			add.b   	#18,x3
			mulu		#7,d5
			add.b   	#14,d5
			add.b   	d4,d5
			move.b  	d5,x2
			jsr 		message
			move.b  	ascisp,x1
			move.b  	0(a2,d7.l),d2
			cmp.b   	0(a5,d7.l),d2   ; equal to w.s. parameter?
			beq 		.eq
			move.b  	asciast,x1
.eq 		move.b  	x5,d0
			add.b   	d0,x2
			jsr 		outchar

			movem.l 	(a7)+,#$7FFF	; restore registers
			rts 						; return



;******************************************************************************
;   routine to put up scaled/greged/leved menu
;******************************************************************************

 .global edmenu

edmenu:

;  nice line above menu
			clr.w   	x1
			move.w  	#164,x2
			move.w  	#639,x3
			move.w  	#164,x4
			move.b  	coutlne,x5
			jsr 		line

;  put up menu
			lea 		editmesl,a0 		; *** 1st column of keys
			move.l  	#editmess,x1
			add.l   	#920,x1
			move.b  	#1,x2
			move.b  	#23,x3
			move.b  	cmenkey,x4
			move.b  	23(a0),x5
			jsr 		message 			; [e]
			move.l  	#editmess,x1
			add.l   	#200,x1
			addq.b  	#1,x3
			move.b  	5(a0),x5
			jsr 		message 			; plus,minus
			move.l  	#editmess,x1
			add.l   	#440,x1
			addq.b  	#1,x3
			move.b  	11(a0),x5
			jsr 		message 			; w

			move.b  	#26,x2
			move.b  	#23,x3
			move.l  	#editmess,x1
			add.l   	#680,x1
			move.b  	17(a0),x5
			jsr 		message 			; cr
			move.l  	#editmess,x1
			add.l   	#760,x1
			addq.b  	#1,x3
			move.b  	19(a0),x5
			jsr 		message 			; del
			move.l  	#editmess,x1
			add.l   	#280,x1
			addq.b  	#1,x3
			move.b  	7(a0),x5
			jsr 		message 			; undo

			move.l  	#editmess,x1			; *** 3rd column of keys
			add.l   	#1920,x1
			move.b  	#53,x2
			move.b  	#22,x3
			move.b  	48(a0),x5
			jsr 		message 			; tab,bs
			move.l  	#editmess,x1
			add.l   	#600,x1
			addq.b  	#1,x3
			move.b  	15(a0),x5
			jsr 		message 			; 0-9
			move.l  	#editmess,x1
			add.l   	#120,x1
			addq.b  	#1,x3
			move.b  	3(a0),x5
			jsr 		message 			; arrows
			move.l  	#editmess,x1
			add.l   	#520,x1
			addq.b  	#1,x3
			move.b  	13(a0),x5
			jsr 		message 			; help

			move.l  	#editmess,x1			; *** 1st column of items
			add.l   	#1040,x1
			move.b  	#8,x2
			move.b  	#23,x3
			move.b  	cmenu,x4
			move.b  	26(a0),x5
			jsr 		message 			; edited to synth
			move.l  	#editmess,x1
			add.l   	#240,x1
			addq.b  	#1,x3
			move.b  	6(a0),x5
			jsr 		message 			; increment,decrement
			move.l  	#editmess,x1
			add.l   	#1000,x1
			addq.b  	#1,x3
			move.b  	25(a0),x5
			jsr 		message 			; original to synth

			move.b  	#33,x2
			move.b  	#23,x3
			move.l  	#editmess,x1
			add.l   	#720,x1
			move.b  	18(a0),x5
			jsr 		message 			; return
			move.l  	#editmess,x1
			add.l   	#800,x1
			addq.b  	#1,x3
			move.b  	20(a0),x5
			jsr 		message 			; unedit
			move.l  	#editmess,x1
			add.l   	#1080,x1
			addq.b  	#1,x3
			move.b  	27(a0),x5
			jsr 		message 			; undo

			move.l  	#editmess,x1			; *** 3rd column of items
			add.l   	#1960,x1
			move.b  	#63,x2
			move.b  	#22,x3
			move.b  	49(a0),x5
			jsr 		message 			; tab up/down
			move.l  	#editmess,x1
			add.l   	#640,x1
			addq.b  	#1,x3
			move.b  	16(a0),x5
			jsr 		message 			; direct entry
			move.l  	#editmess,x1
			add.l   	#160,x1
			addq.b  	#1,x3
			move.b  	4(a0),x5
			jsr 		message 			; move cursor
			move.l  	#editmess,x1
			add.l   	#560,x1
			addq.b  	#1,x3
			move.b  	14(a0),x5
			jsr 		message 			; hardcopy

			rts
