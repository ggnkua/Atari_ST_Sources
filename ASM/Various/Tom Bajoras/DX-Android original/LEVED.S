;*****************************************************************************;
;   leved -- graphical level / vel sens editor
;   		   Copyright 1986 Tom Bajoras
;   no entry conditions, no exit conditions
;*****************************************************************************;

 .text

 .global leved

leved   	movem.l 	#$FFFE,-(a7)	; save registers
			move.l  	x1,-(a7)		; and x1-x5
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)

;   put up screen:
			jsr 		blnkscr 		; start with a blank screen
			move.b  	#5,x1   		; change colors
			jsr 		setcolor

			lea 		edspace,a6  	; a6 --> edited sound
			lea 		wkspace,a5  	; a5 --> original sound

;   if (monedit <2) send e.s. non-f-pars to synth
			cmpi.b  	#2,monedit
			beq 		.f_only
			jsr 		edtosyn
			jsr 		writdx7

;   if (monedit <>1) send e.s. f-pars to synth
.f_only 	cmpi.b  	#1,monedit
			beq 		.skip_f
			move.l  	#edspace,x1
			add.l   	#145,x1
			jsr 		writfdx7

.skip_f 	lea 		editmesl,a0 	; a0 --> lengths of edit mess's
			move.l  	#editmess,x1
			add.l   	#1120,x1
			clr.l   	d0
			move.b  	xmax,d0
			sub.b   	28(a0),d0
			sub.b   	#11,d0
			lsr.b   	#1,d0
			move.b  	d0,x2
			move.b  	#1,x3
			move.b  	cmenhed,x4
			move.b  	28(a0),x5
			jsr 		message 			; title
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.l  	#wksname,x1
			move.b  	cmessge,x4
			move.b  	#10,x5
			jsr 		message 		; append w.s. name

			move.l  	#editmess,x1
			add.l   	#1360,x1
			move.b  	#1,x2
			move.b  	#9,x3
			move.b  	cmenkey,x4
			move.b  	34(a0),x5
			jsr 		message 		; "edited"
			move.l  	#editmess,x1
			add.l   	#1400,x1
			move.b  	xmax,x2
			addq.b  	#1,x2
			move.b  	35(a0),d0
			sub.b   	d0,x2
			move.b  	35(a0),x5
			jsr 		message 		; "original"

			move.l  	#editmess,x1
			add.l   	#1240,x1
			move.b  	#37,x2
			move.b  	#17,x3
			move.b  	cmenkey,x4
			move.b  	31(a0),x5
			jsr 		message 		; operator
			move.l  	#editmess,x1
			add.l   	#1280,x1
			move.b  	#38,x2
			addq.b  	#2,x3
			move.b  	32(a0),x5
			jsr 		message 		; level
			move.l  	#editmess,x1
			add.l   	#1320,x1
			move.b  	#37,x2
			addq.b  	#1,x3
			move.b  	33(a0),x5
			jsr 		message 		; vel sens

;  write op #'s
			move.b  	cmenkey,x4
			move.b  	#17,x3
			move.b  	#12,d0  	; for d0 = 12 to 32 by 4
			move.b  	asci0,x1
.oploop 	addq.b  	#1,x1
			move.b  	d0,x2
			jsr 		outchar
			add.b   	#36,x2
			jsr 		outchar
			addq.b  	#4,d0
			cmpi.b  	#32,d0
			ble 		.oploop

;  write all e.s. parameters
			clr.l   	d5
			move.l  	#121,d7
			move.b  	cmessge,d0
.parloope   bsr 		outleve
			subq.l  	#1,d7
			bsr 		outvele
			sub.l   	#20,d7
			add.l   	#1,d5
			cmpi.l  	#5,d5
			ble 		.parloope

;  put up e.s. display
			clr.l   	d5  		; for d5.l = 0 to 5
.esloop 	bsr 		bar_e
			add.l   	#1,d5
			cmpi.l  	#5,d5
			ble 		.esloop

;  write all w.s. parameters
			clr.l   	d5
			move.l  	#121,d7
			move.b  	cmessge,d0
.parloopw   bsr 		outlevw
			subq.l  	#1,d7
			bsr 		outvelw
			sub.l   	#20,d7
			add.l   	#1,d5
			cmpi.l  	#5,d5
			ble 		.parloopw

; put up w.s. display
			clr.l   	d5  		; for d5.l = 0 to 5
.wsloop 	bsr 		bar_w
			add.l   	#1,d5
			cmpi.l  	#5,d5
			ble 		.wsloop

;  put up menu:
			jsr 		edmenu

;  initialize cursor
			clr.l   	d5  		; cursor-x
			clr.l   	d6  		; cursor-y

;  calculate current parameter #
.cursloop   move.l  	#121,d7
			sub.l   	d6,d7
			move.l  	d5,d0
			mulu		#21,d0
			sub.l   	d0,d7   	; d7.l = parameter #

;   make parameter at cursor red
			move.b  	cprompt,d0
			tst.l   	d6
			beq 		.curslev
			bsr 		outvele
			bra 		.keyloop
.curslev	bsr 		outleve

;   get a key
.keyloop	jsr 		getkey
			trap		#11 			; key repeat on
			move.b  	y1,d4   		; d4.b = gotten key

;   branch according to key
.keyloop2   cmp.b   	asciup,d4
			beq 		.down_up
			cmp.b   	ascidwn,d4
			beq 		.down_up
			cmp.b   	ascilef,d4
			beq 		.left
			cmp.b   	ascirit,d4
			beq 		.right
			cmp.b   	ascihelp,d4
			beq 		.help
			cmp.b   	asciplus,d4
			beq 		.plus
			cmp.b   	ascidash,d4
			beq 		.minus
			cmp.b   	asciu,d4
			beq 		.undo
			cmp.b   	asciw,d4
			beq 		.w
			cmp.b   	ascie,d4
			beq 		.e
			cmp.b   	ascicr,d4
			beq 		.return
			cmp.b   	ascidel,d4
			beq 		.del
			cmp.b   	ascitab,d4
			beq 		.tab
			cmp.b   	ascibs,d4
			beq 		.bs
			cmp.b   	asci0,d4
			blt 		.badkey
			cmp.b   	asci9,d4
			ble 		.number
.badkey 	jsr 		bell
			bra 		.keyloop

.down_up	move.b  	cmessge,d0
			tst.l   	d6
			beq 		.down_up1
			bsr 		outvele 	; unprompt vel
			clr.l   	d6  	 ; and move cursor to level
			bra 		.cursloop
.down_up1   bsr 		outleve 	 ; or unprompt lev
			move.l  	#1,d6   	; and move cursor to vel
			bra 		.cursloop

.left   	move.b  	cmessge,d0
			tst.l   	d6
			beq 		.left1
			bsr 		outvele
			bra 		.left2
.left1  	bsr 		outleve 	 ; or unprompt outleve
.left2  	subq.l  	#1,d5   	; move cursor to left
			bge 		.cursloop
			move.l  	#5,d5   	; wrap around
			bra 		.cursloop

.right  	move.b  	cmessge,d0
			tst.l   	d6
			beq 		.right1
			bsr 		outvele 	 ; unprompt vel
			bra 		.right2
.right1 	bsr 		outleve 	 ; or unprompt outleve
.right2 	addq.l  	#1,d5   	; move cursor to right
			cmpi.l  	#5,d5
			ble 		.cursloop
			clr.l   	d5  	 ; wrap around
			bra 		.cursloop

.help   	jsr 		hardcopy
			bra 		.keyloop

.plus   	bsr 		xbar_e  		; blank out es bar
			lea 		parminfo,a0 	; increment es par, with wraparound
			move.l  	d7,d0
			mulu		#8,d0
			addq.b  	#1,0(a6,d7.l)
			move.b  	1(a0,d0.l),d1   ; d1.b = high mark
			cmp.b   	0(a6,d7.l),d1   ; have we gone over the high mark?
			bge 		.update
			move.b  	0(a0,d0.l),0(a6,d7.l)   ; yes: wraparound
.update 	move.b  	cprompt,d0
			tst.l   	d6
			beq 		.pluslev
			bsr 		outvele
			bra 		.plus2
.pluslev	bsr 		outleve
.plus2  	cmpi.b  	#2,monedit
			beq 		.plus3
			jsr 		sendpar
.plus3  	bsr 		bar_e   		; update es display
			bra 		.keyloop

.minus  	bsr 		xbar_e  		; blank out es bar
			lea 		parminfo,a0 	; decrement es par, with wraparound
			move.l  	d7,d0
			mulu		#8,d0
			subq.b  	#1,0(a6,d7.l)
			move.b  	0(a0,d0.l),d1   ; d1.b = low mark
			cmp.b   	0(a6,d7.l),d1   ; have we gone under the low mark?
			ble 		.update
			move.b  	1(a0,d0.l),0(a6,d7.l)   ; yes: wraparound
			bra 		.update

.tab		move.b  	0(a6,d7.l),d1   ; d1.b= value to be tabbed
			move.l  	d7,d0
			mulu		#8,d0
			lea 		parminfo,a0
			add.b   	3(a0,d0.l),d1   ; tab the value
			cmp.b   	1(a0,d0.l),d1   ; overflow
			bgt 		.badkey
			bsr 		xbar_e  		; blank out previous
			move.b  	d1,0(a6,d7.l)
			bra 		.update

.bs 		move.b  	0(a6,d7.l),d1   ; d1.b = value to be tabbed
			move.l  	d7,d0
			mulu		#8,d0
			lea 		parminfo,a0
			sub.b   	3(a0,d0.l),d1   ; tab the value
			cmp.b   	0(a0,d0.l),d1   ; underflow
			blt 		.badkey
			bsr 		xbar_e  		; blank out previous
			move.b  	d1,0(a6,d7.l)
			bra 		.update

.undo   	jsr 		getkey  	; get 2 more keys: n and d
			move.b  	y1,d4
			cmp.b   	ascin,d4
			bne 		.badkey
			jsr 		getkey
			move.b  	y1,d4
			cmp.b   	ascid,d4
			bne 		.badkey
			move.l  	d5,-(a7)
			move.l  	d6,-(a7)	; save cursor
			clr.l   	d5
.unloop1	bsr 		xbar_e  	 ; blank es display
			addq.l  	#1,d5
			cmpi.l  	#5,d5
			ble 		.unloop1
			move.b  	121(a5),121(a6) ; unedit all 12 parameters
			move.b  	100(a5),100(a6)
			move.b  	79(a5),79(a6)
			move.b  	58(a5),58(a6)
			move.b  	37(a5),37(a6)
			move.b  	16(a5),16(a6)
			move.b  	120(a5),120(a6)
			move.b  	99(a5),99(a6)
			move.b  	78(a5),78(a6)
			move.b  	57(a5),57(a6)
			move.b  	36(a5),36(a6)
			move.b  	15(a5),15(a6)
			clr.l   	d5
			move.l  	#121,d7
			move.b  	cmessge,d0
.parloopu   bsr 		outleve
			subq.l  	#1,d7
			bsr 		outvele
			sub.l   	#20,d7
			add.l   	#1,d5
			cmpi.l  	#5,d5
			ble 		.parloopu
			cmpi.b  	#2,monedit
			beq 		.undox
			move.l  	#121,d7
.sendloop   jsr 		sendpar 		; send all undone pars to synth
			subq.l  	#1,d7   		; if monedit allows it
			jsr 		sendpar
			sub.l   	#20,d7
			cmpi.l  	#16,d7
			bge 		.sendloop
.undox  	clr.l   	d5
.unloop2	bsr 		bar_e   	; redo es display
			addq.l  	#1,d5
			cmpi.l  	#5,d5
			ble 		.unloop2
			move.l  	(a7)+,d6
			move.l  	(a7)+,d5	; restore cursor
			bra 		.cursloop

;   if (monedit <2) send w.s. non-f-pars to synth
.w  		cmpi.b  	#2,monedit
			beq 		.f_only2
			jsr 		wstosyn
			jsr 		writdx7

;   if (monedit <>1) send w.s. f-pars to synth

.f_only2	cmpi.b  	#1,monedit
			beq 		.keyloop
			move.l  	#wkspace,x1
			add.l   	#145,x1
			jsr 		writfdx7
			bra 		.keyloop

;   if (monedit <2) send e.s. non-f-pars to synth
.e  		cmpi.b  	#2,monedit
			beq 		.f_only3
			jsr 		edtosyn
			jsr 		writdx7

;   if (monedit <>1) send e.s. f-pars to synth

.f_only3	cmpi.b  	#1,monedit
			beq 		.keyloop
			move.l  	#edspace,x1
			add.l   	#145,x1
			jsr 		writfdx7
			bra 		.keyloop

.del		bsr 		xbar_e  				; blank out es bar
			move.b  	0(a5,d7.l),0(a6,d7.l)   	; unedit parameter
			bra 		.update

.number 	cmpi.l  	#1,d6   ; cannot directly enter vel sens
			beq 		.badkey
			bsr 		xbar_e  ; blank out es bar
			clr.l   	d0
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
			move.b  	cprompt,d0
			bsr 		outleve
			bsr 		bar_e   	; update es display
			cmpi.b  	#2,monedit
			beq 		.skipsend
			jsr 		sendpar
.skipsend   jsr 		getkey  	 ; get another key
			move.b  	y1,d4   	 ; d4.b = gotten key
			cmp.b   	asci0,d4
			blt 		.keyloop2
			cmp.b   	asci9,d4
			bgt 		.keyloop2
			bsr 		xbar_e  	 ; blank out es bar
			clr.l   	d0
			move.b  	0(a6,d7.l),d0
			divu		#10,d0
			andi.l  	#$FFFF,d0
			mulu		#10,d0
			add.b   	d4,d0
			sub.b   	#$30,d0
			move.b  	d0,0(a6,d7.l)
			bra 		.update

.return 	move.l  	(a7)+,x5	; restore x5-x1
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1
			movem.l 	(a7)+,#$7FFF	; restore registers
			rts 						; return

;******************************************************************************
;   outleve,outlevw,outvele,outvelw
;      entry conditions: d5.l=0-5 cursorx, d7.l = par #,  d0.b = color
;******************************************************************************

outleve 	move.l  	a6,a2
			clr.b   	d3
			bra 		outlevx
outlevw 	move.l  	a5,a2
			move.b  	#36,d3
outlevx 	move.b  	d0,x4   	; color
			clr.w   	d1
			move.b  	0(a2,d7.l),d1
			move.w  	d1,x1
			jsr 		encode
			cmpi.w  	#9,d1
			bgt 		.gt9
			lea 		namebuf,a1  	; convert 0-9 into 00-09 form
			move.b  	(a1),1(a1)
			move.b  	asci0,(a1)
.gt9		move.l  	#namebuf,x1
			move.b  	d5,d1
			lsl.b   	#2,d1
			add.b   	#12,d1
			move.b  	d1,x2   		; x-coord for level
			move.b  	#19,x3  		; y-coord for level
			move.b  	#2,x5
			add.b   	d3,x2
			jsr 		message
			move.b  	ascisp,x1   	; followed by space if es=ws
			move.b  	0(a5,d7.l),d1
			cmp.b   	0(a2,d7.l),d1
			beq 		.eqlev
			move.b  	asciast,x1  	;  followed by * if es <> ws
.eqlev  	addq.b  	#2,x2
			jsr 		outchar
			rts

outvele 	move.l  	a6,a2
			clr.b   	d3
			bra 		outvelx
outvelw 	move.l  	a5,a2
			move.b  	#36,d3
outvelx 	move.b  	d0,x4   	; color
			clr.w   	d1
			move.b  	0(a2,d7.l),d1
			move.w  	d1,x1
			jsr 		encode
			move.l  	#namebuf,x1
			move.b  	d5,d1
			lsl.b   	#2,d1
			add.b   	#12,d1
			move.b  	d1,x2   		; x-coord for vel
			move.b  	#20,x3  		; y-coord for vel
			move.b  	#1,x5
			add.b   	d3,x2
			jsr 		message
			move.b  	ascisp,x1   	; followed by space if es=ws
			move.b  	0(a5,d7.l),d1
			cmp.b   	0(a2,d7.l),d1
			beq 		.eqvel
			move.b  	asciast,x1  	;  followed by * if es <> ws
.eqvel  	addq.b  	#1,x2
			jsr 		outchar
			rts

;******************************************************************************
;   bar_e,bar_w,xbar_e
;   entry conditions: d5.l = cursorx
;******************************************************************************

bar_e   	movem.l 	#$FFFE,-(a7)	; save registers
			move.b  	cmessge,d0  	; color 1
			move.b  	cmenkey,d1  	; color 2
			move.w  	#80,d2  		; offset
			move.l  	a6,a2   		; a2 --> edspace
			bra 		bar_x
bar_w   	movem.l 	#$FFFE,-(a7)	; save registers
			move.b  	cmessge,d0  	; color 1
			move.b  	cmenkey,d1  	; color 2
			move.w  	#368,d2 		; offset
			move.l  	a5,a2   		; a2 --> wkspace
			bra 		bar_x
xbar_e  	movem.l 	#$FFFE,-(a7)	; save registers
			move.b  	cbakgnd,d0  	; color 1
			move.b  	cbakgnd,d1  	; color 2
			move.w  	#80,d2  		; offset
			move.l  	a6,a2   		; a2 --> edspace
;   		bra 		bar_x

bar_x   	move.l  	#120,d7
			move.l  	d5,d3
			mulu		#21,d3
			sub.b   	d3,d7   		; d7.l = vel #
			mulu		#32,d5
			add.w   	d5,d2   		; d2 = left x
			move.w  	d2,d3
			add.w   	#24,d3  		; d3 = right x
			move.w  	#120,d4
			sub.b   	1(a2,d7.l),d4   ; d4.w = level y
			clr.l   	d5
			move.b  	0(a2,d7.l),d5
			clr.l   	d6
			move.b  	1(a2,d7.l),d6
			mulu		d6,d5
			divu		#14,d5
			add.w   	#120,d5
			sub.b   	1(a2,d7.l),d5   	; d5.w = vel y

			move.w  	d2,x1
			move.w  	#120,x2
			move.w  	d3,x3
			move.w  	#120,x4
			move.b  	d0,x5
			jsr 		line				; base line
			cmpi.w  	#120,d5
			beq 		.bar_1
			move.w  	d2,x1
			move.w  	#120,x2
			move.w  	d2,x3
			move.w  	d5,x4
			jsr 		line			; side line left
			move.w  	d3,x1
			move.w  	d3,x3
			jsr 		line			; side line right
.bar_1  	cmp.w   	d4,d5
			beq 		.bar_2
			move.b  	d1,x5
			move.w  	d2,x1
			move.w  	d5,x2
			move.w  	d2,x3
			move.w  	d4,x4
			jsr 		line			; vel box
			move.w  	d4,x2
			move.w  	d3,x3
			jsr 		line
			move.w  	d3,x1
			move.w  	d5,x2
			jsr 		line
.bar_2  	move.w  	d2,x1
			move.w  	d5,x2
			move.w  	d3,x3
			move.w  	d5,x4
			move.b  	d0,x5
			jsr 		line			; vel line
			cmpi.w  	#21,d4
			beq 		.bar_3
			move.w  	d2,x1
			move.w  	#21,x2
			move.w  	d3,x3
			move.w  	#21,x4
			jsr 		line			; top line
.bar_3  	movem.l 	(a7)+,#$7FFF	; restore registers
			rts 						; return

;*****************************************************************************;
;   initpri7 -- part of primary initialization daisy chain
;   			set up pointers to non-numerics in parminfo table
;*****************************************************************************;

 .global initpri7

initpri7:
			lea 		parminfo,a0 		; set up pointers to non-numerics
			move.l  	#val_lrc,92(a0) 	; lc/rc
			move.l  	#val_lrc,100(a0)
			move.l  	#val_lrc,260(a0)
			move.l  	#val_lrc,268(a0)
			move.l  	#val_lrc,428(a0)
			move.l  	#val_lrc,436(a0)
			move.l  	#val_lrc,596(a0)
			move.l  	#val_lrc,604(a0)
			move.l  	#val_lrc,764(a0)
			move.l  	#val_lrc,772(a0)
			move.l  	#val_lrc,932(a0)
			move.l  	#val_lrc,940(a0)
			move.l  	#val_bp,68(a0)  	; bp
			move.l  	#val_bp,236(a0)
			move.l  	#val_bp,404(a0)
			move.l  	#val_bp,572(a0)
			move.l  	#val_bp,740(a0)
			move.l  	#val_bp,908(a0)
			move.l  	#val_md,140(a0) 	; op mode
			move.l  	#val_md,308(a0)
			move.l  	#val_md,476(a0)
			move.l  	#val_md,644(a0)
			move.l  	#val_md,812(a0)
			move.l  	#val_md,980(a0)
			move.l  	#val_dtn,164(a0)	; detune
			move.l  	#val_dtn,332(a0)
			move.l  	#val_dtn,500(a0)
			move.l  	#val_dtn,668(a0)
			move.l  	#val_dtn,836(a0)
			move.l  	#val_dtn,1004(a0)
			move.l  	#val_sync,1092(a0)  ; op sync
			move.l  	#val_sync,1132(a0)  ; lfo sync
			move.l  	#val_wave,1140(a0)  ; lfo wave
			move.l  	#val_tr,1156(a0)	; transpose
			move.l  	#val_sync,1196(a0)  ; gliss
			move.l  	#val_sync,1164(a0)  ; mono/poly
			move.l  	#val_mw,1220(a0)	; mw assign
			move.l  	#val_mw,1236(a0)	; fc assign
			move.l  	#val_mw,1252(a0)	; bc assign
			move.l  	#val_mw,1268(a0)	; at assign

; chain on to next link
			jsr 		initpri8
			rts
