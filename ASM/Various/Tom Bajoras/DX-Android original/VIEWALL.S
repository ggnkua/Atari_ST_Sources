;*****************************************************************************;
;   viewall -- view up to 6 operator eg's simultaneously
;   		   Copyright 1986 Tom Bajoras
;   no entry conditions, no exit conditions
;*****************************************************************************;

 .text

 .global viewall

viewall 	movem.l 	#$FFFE,-(a7)		; save registers
			move.l  	x1,-(a7)			; and x1-x5
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)

			jsr 		blnkscr 		; start with blank screen
			move.b  	#1,x1   		; change colors
			jsr 		setcolor

; use same axes system as scaling editor:
			jsr 		drawaxes

;   put up screen:
			lea 		locmesl,a0  	; a0 --> lengths of local text
			move.l  	#locmess,x1
			move.b  	#5,x2
			move.b  	#1,x3
			move.b  	cmenhed,x4
			move.b  	(a0),x5
			jsr 		message 			; title
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.l  	#wksname,x1
			move.b  	cmessge,x4
			move.b  	#10,x5
			jsr 		message 		; append w.s. name

			move.l  	#locmess,x1
			add.l   	#40,x1
			move.b  	xmax,d0
			sub.b   	#11,d0
			sub.b   	1(a0),d0
			move.b  	d0,x2
			move.b  	#1,x3
			move.b  	cmenhed,x4
			move.b  	1(a0),x5
			jsr 		message 		; "currently viewing:"

; nice line above menu

			clr.w   	x1
			move.w  	#639,x3
			move.w  	#170,x2
			move.w  	#170,x4
			move.b  	coutlne,x5
			jsr 		line

; put up menu:
			move.l  	#locmess,x1
			add.l   	#80,x1
			move.b  	#10,x2
			move.b  	ymax,x3
			subq.b  	#2,x3
			move.b  	cmenkey,x4
			lea 		locmesl,a0
			move.b  	2(a0),x5
			jsr 		message 		; [w]
			add.l   	#40,x1
			addq.b  	#1,x3
			move.b  	3(a0),x5
			jsr 		message 		; [e]
			add.l   	#40,x1
			addq.b  	#1,x3
			move.b  	4(a0),x5
			jsr 		message 		; [1]-[6]

			move.b  	xmax,x2
			sub.b   	#35,x2
			move.b  	ymax,x3
			subq.b  	#2,x3
			add.l   	#40,x1
			move.b  	5(a0),x5
			jsr 		message 		; [cr]
			add.l   	#40,x1
			addq.b  	#1,x3
			move.b  	6(a0),x5
			jsr 		message 		; [help]
			add.l   	#40,x1
			addq.b  	#1,x3
			move.b  	7(a0),x5
			jsr 		message 		;p

			add.l   	#40,x1
			move.b  	#19,x2
			move.b  	ymax,x3
			subq.b  	#2,x3
			move.b  	cmenu,x4
			move.b  	8(a0),x5
			jsr 		message 		; display original
			add.l   	#40,x1
			addq.b  	#1,x3
			move.b  	9(a0),x5
			jsr 		message 		; display edited
			add.l   	#40,x1
			addq.b  	#1,x3
			move.b  	10(a0),x5
			jsr 		message 		; curves on/off

			add.l   	#40,x1
			move.b  	xmax,x2
			sub.b   	#26,x2
			move.b  	ymax,x3
			subq.b  	#2,x3
			move.b  	11(a0),x5
			jsr 		message 		; go to edit menu
			add.l   	#40,x1
			addq.b  	#1,x3
			move.b  	12(a0),x5
			jsr 		message 		; hardcopy
			add.l   	#40,x1
			addq.b  	#1,x3
			move.b  	13(a0),x5
			jsr 		message 		; view attack/release

; register variables
			lea 		edspace,a2  	; start with edited version
			clr.b   	d7  			; d7.b =0 edited, =1 original
			clr.b   	d6  			; d6.b =0 attack, =1 release
			lea 		colors,a4   	; a4--> colors for curves
			lea 		opflag,a6   	; a6.l --> curve on/off flags
			clr.b   	(a6)		 ; start with none showing
			clr.b   	1(a6)
			clr.b   	2(a6)
			clr.b   	3(a6)
			clr.b   	4(a6)
			clr.b   	5(a6)

.bigloop:

;  operator #s in upper rh corner / set up colors array
			move.b  	xmax,x2
			sub.b   	#10,x2
			move.b  	#1,x3
			moveq   	#1,d1   	; color
			clr.l   	d0  		; for d0.l = 0 to 5
.oploop 	tst.b   	0(a6,d0.l)
			beq 		.off
			move.b  	d0,x1
			add.b   	#$31,x1
			move.b  	d1,x4
			jsr 		outchar
			move.b  	d1,0(a4,d0.l)
			addq.b  	#1,d1
			cmpi.b  	#3,d1
			ble 		.nextop
			moveq   	#1,d1   		; wrap colors around
			bra 		.nextop
.off		move.b  	ascisp,x1
			move.b  	cbakgnd,x4
			jsr 		outchar
.nextop 	addq.b  	#2,x2
			addq.l  	#1,d0
			cmpi.l  	#5,d0
			ble 		.oploop

;  append "(edited)" or "(original)" to w.s. name
			lea 		locmesl,a0
			move.l  	#locmess,x1
			add.l   	#560,x1
			move.b  	(a0),x2
			add.b   	#17,x2
			move.b  	#1,x3
			move.b  	cmenu,x4
			move.b  	15(a0),x5
			tst.b   	d7
			beq 		.doit
			add.l   	#40,x1
.doit   	jsr 		message

;  put up "attack" or "release" between x-axis and menu

			move.l  	#locmess,x1
			add.l   	#640,x1
			move.b  	#29,x2
			move.b  	#19,x3
			move.b  	cmessge,x4
			move.b  	16(a0),x5
			tst.b   	d6
			beq 		.doit2
			add.l   	#40,x1
.doit2  	jsr 		message

;  put up display
			jsr 		renew
			tst.b   	d6
			beq 		.attack
			bsr 		drawrel
			jsr 		drawaxes
			bra 		.keyloop
.attack 	bsr 		drawatt
			jsr 		drawaxes

;   get a key
.keyloop	jsr 		getkey
			move.b  	y1,d4   		; d4.b = gotten key

;   branch according to key
			cmp.b   	asciw,d4
			beq 		.w
			cmp.b   	ascie,d4
			beq 		.e
			cmp.b   	ascicr,d4
			beq 		.return
			cmp.b   	ascihelp,d4
			beq 		.help
			cmp.b   	ascip,d4
			beq 		.p
			sub.b   	#$30,d4
			cmp.b   	#1,d4
			blt 		.badkey
			cmp.b   	#6,d4
			ble 		.number
.badkey 	jsr 		bell
			bra 		.keyloop

.w  		lea 		wkspace,a2
			moveq   	#1,d7
			bra 		.bigloop

.p  		eori.b  	#1,d6   	 ; toggle d6.b
			bra 		.bigloop

.e  		lea 		edspace,a2
			clr.b   	d7
			bra 		.bigloop

.number 	subq.b  	#1,d4
			andi.l  	#$FF,d4 	; d4.l = op # (0-5)
			eori.b  	#1,0(a6,d4.l)
			bra 		.bigloop

.help   	jsr 		hardcopy
			bra 		.keyloop

.return 	move.l  	(a7)+,x5	; restore x5-x1
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1
			movem.l 	(a7)+,#$7FFF	; restore registers
			rts 						; return

;******************************************************************************
;   drawatt  --  local routine to superimpose attack segments
;   a2 --> ed/wk space, a6--> op flags, note: clobbers x1-x5
;******************************************************************************

 .global drawatt
drawatt 	movem.l 	#$FFFE,-(a7)	; save registers

			movea.l 	a2,a3   		; save a2 for below
			clr.l   	d7  			; initialize maxsum
			lea 		times,a5		; a5 --> times array
			add.l   	#105,a2 		; a2 --> op 1 eg data
			clr.w   	d6  			; for d6.w = 0 to 5 = opx
.loop   	tst.b   	0(a6,d6.w)   ; skip this operator?
			beq 		.next

			clr.w   	d0
			clr.w   	d1
			move.b  	4(a2),d0		; d0.w = L1(opx)
			move.b  	0(a2),d1		; d1.w = R1(opx)
			jsr 		locrise 		; d0.l = rise time (ms)
			move.l  	d0,0(a5)		; T1(opx)
			clr.w   	d0
			clr.w   	d1
			clr.w   	d2
			move.b  	1(a2),d1		; d1.w = R2(opx)
			move.b  	4(a2),d0		; d0.w = L1(opx)
			move.b  	5(a2),d2		; d2.w = L2(opx)
			cmp.w   	d0,d2
			bgt 		.L2gtL1
			sub.w   	d2,d0
			jsr 		locfall 		; d0.l = fall time (ms)
			bra 		.1
.L2gtL1 	sub.w   	d0,d2
			move.w  	d2,d0
			jsr 		locrise 		; d0.l = rise time (ms)
.1  		move.l  	d0,4(a5)		; T2(opx)
			clr.w   	d0
			clr.w   	d1
			clr.w   	d2
			move.b  	2(a2),d1		; d1.w = R3(opx)
			move.b  	5(a2),d0		; d0.w = L2(opx)
			move.b  	6(a2),d2		; d2.w = L3(opx)
			cmp.w   	d0,d2
			bgt 		.L3gtL2
			sub.w   	d2,d0
			jsr 		locfall 		; d0.l = fall time (ms)
			bra 		.2
.L3gtL2 	sub.w   	d0,d2
			move.w  	d2,d0
			jsr 		locrise 		; d0.l = rise time (ms)
.2  		move.l  	d0,8(a5)		; T3(opx)

			move.l  	(a5),d0
			add.l   	4(a5),d0
			add.l   	8(a5),d0
			cmp.l   	d0,d7
			bgt 		.next
			move.l  	d0,d7   		; update maxsum

.next   	sub.l   	#21,a2  		; a2 --> next operator's eg data
			add.l   	#16,a5  		; a5 --> next row in times array
			addq.b  	#1,d6
			cmpi.b  	#5,d6
			ble 		.loop

			lea 		times,a5
			tst.l   	d7
			beq 		.skip
			cmpi.l  	#583,d7
			ble 		.le583
			divu		#583,d7
			addq.w  	#1,d7   		; d7.w = xscaling factor
			move.b  	#24,d0  		; divide every entry in times array
.divloop	move.l  	(a5),d1
			divu		d7,d1
			move.w  	d1,(a5)
			addq.l  	#4,a5
			subq.b  	#1,d0
			bne 		.divloop
			bra 		.skip
.le583  	move.l  	#583,d0
			divu		d7,d0   		; d0.w = xscaling factor
			move.b  	#24,d7  		; multiply every entry in times array
.multloop   move.l  	(a5),d1
			mulu		d0,d1
			move.w  	d1,(a5)
			addq.l  	#4,a5
			subq.b  	#1,d7
			bne 		.multloop

.skip   	lea 		times,a5		; a5 --> times array
			add.l   	#105,a3 		; a3 --> op 1 eg data
			clr.w   	d6  			; for d6.w = 0 to 5 = opx
.loopl  	tst.b   	0(a6,d6.w)   ; skip this operator?
			beq 		.nextl
			move.b  	0(a4,d6.w),x5   ; color
			move.w  	#28,x1
			move.w  	#28,x3
			move.w  	#116,x2
			move.w  	(a5),d0
			add.w   	d0,x3
			move.w  	#116,d0
			sub.b   	4(a3),d0
			move.w  	d0,x4
			jsr 		line
			move.w  	x3,x1
			move.w  	x4,x2
			move.w  	4(a5),d0
			add.w   	d0,x3
			move.w  	#116,d0
			sub.b   	5(a3),d0
			move.w  	d0,x4
			jsr 		line
			move.w  	x3,x1
			move.w  	x4,x2
			move.w  	8(a5),d0
			add.w   	d0,x3
			move.w  	#116,d0
			sub.b   	6(a3),d0
			move.w  	d0,x4
			jsr 		line
			cmpi.w  	#611,x3
			beq 		.nextl  		; no room for tail?
			tst.b   	6(a3)   	 ; add tail?
			beq 		.nextl
			move.w  	x3,x1
			move.w  	x4,x2
			move.w  	#611,x3
			jsr 		line
.nextl  	add.l   	#16,a5  		; --> next row in times array
			sub.l   	#21,a3  		; --> next operator's eg data
			addq.b  	#1,d6
			cmpi.b  	#5,d6
			ble 		.loopl

			movem.l 	(a7)+,#$7FFF	; restore registers
			rts

;******************************************************************************
;   drawrel  --  local routine to superimpose release segments
;   a2 --> ed/wk space, a6--> op flags, note: clobbers x1-x5
;******************************************************************************

 .global drawrel
drawrel 	movem.l 	#$FFFE,-(a7)	; save registers

			movea.l 	a2,a3   		; save a2 for below
			clr.l   	d7  			; initialize maxsum
			lea 		times,a5		; a5 --> times array
			add.l   	#105,a2 		; a2 --> op 1 eg data
			clr.w   	d6  			; for d6.w = 0 to 5 = opx
.loop   	tst.b   	0(a6,d6.w)   ; skip this operator?
			beq 		.next

			clr.w   	d0
			clr.w   	d1
			clr.w   	d2
			move.b  	3(a2),d1		; d1.w = R4(opx)
			move.b  	6(a2),d0		; d0.w = L3(opx)
			move.b  	7(a2),d2		; d2.w = L4(opx)
			cmp.w   	d0,d2
			bgt 		.L4gtL3
			sub.w   	d2,d0
			jsr 		locfall 		; d0.l = fall time (ms)
			bra 		.1
.L4gtL3 	sub.w   	d0,d2
			move.w  	d2,d0
			jsr 		locrise 		; d0.l = rise time (ms)
.1  		move.l  	d0,(a5) 		; T4(opx)

			cmp.l   	d0,d7
			bgt 		.next
			move.l  	d0,d7   		; update maxsum

.next   	sub.l   	#21,a2  		; a2 --> next operator's eg data
			add.l   	#4,a5   		; a5 --> next row in times array
			addq.b  	#1,d6
			cmpi.b  	#5,d6
			ble 		.loop

			lea 		times,a5
			tst.l   	d7
			beq 		.skip
			cmpi.l  	#583,d7
			ble 		.le583
			divu		#583,d7
			addq.w  	#1,d7   		; d7.w = xscaling factor
			move.b  	#6,d0   		; divide every entry in times array
.divloop	move.l  	(a5),d1
			divu		d7,d1
			move.w  	d1,(a5)
			addq.l  	#4,a5
			subq.b  	#1,d0
			bne 		.divloop
			bra 		.skip
.le583  	move.l  	#583,d0
			divu		d7,d0   		; d0.w = xscaling factor
			move.b  	#6,d7   		; multiply every entry in times array
.multloop   move.l  	(a5),d1
			mulu		d0,d1
			move.w  	d1,(a5)
			addq.l  	#4,a5
			subq.b  	#1,d7
			bne 		.multloop

.skip   	lea 		times,a5		; a5 --> times array
			add.l   	#105,a3 		; a3 --> op 1 eg data
			clr.w   	d6  			; for d6.w = 0 to 5 = opx
.loopl  	tst.b   	0(a6,d6.w)   ; skip this operator?
			beq 		.nextl
			move.b  	0(a4,d6.w),x5   ; color
			move.w  	#28,x1
			move.w  	#116,d0
			sub.b   	6(a3),d0
			move.w  	d0,x2
			move.w  	x1,x3
			move.w  	(a5),d0
			add.w   	d0,x3
			move.w  	#116,d0
			sub.b   	7(a3),d0
			move.w  	d0,x4
			jsr 		line
			cmpi.w  	#611,x3
			beq 		.nextl  		; no room for tail?
			tst.b   	7(a3)   	 ; add L4>0 tail?
			beq 		.nextl
			move.w  	x3,x1
			move.w  	x4,x2
			move.w  	#611,x3
			jsr 		line
.nextl  	add.l   	#4,a5   		; --> next row in times array
			sub.l   	#21,a3  		; --> next operator's eg data
			addq.b  	#1,d6
			cmpi.b  	#5,d6
			ble 		.loopl

			movem.l 	(a7)+,#$7FFF	; restore registers
			rts

locrise 	jsr 		t_rise  		; get rise time
			cmpi.l  	#10,d0  		; disregard any time < 10 ms
			bge 		locret
			clr.l   	d0
			bra 		locret
locfall 	jsr 		t_fall  		; get fall time
			cmpi.l  	#10,d0  		; disregard any time < 10 ms
			bge 		locret
			clr.l   	d0
locret  	rts

;******************************************************************************

 .data

locmess 	.ascii  	"View Operator EG's for: xxxxxxxxxxxxxxx"   ;0
			.ascii  	"Currently viewing: xxxxxxxxxxxxxxxxxxxx"   ;1
			.ascii  	"[w] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;2
			.ascii  	"[e] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;3
			.ascii  	"[1]-[6] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;4
			.ascii  	"[cr] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;5
			.ascii  	"[help] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;6
			.ascii  	"[p] xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;7
			.ascii  	"display original xxxxxxxxxxxxxxxxxxxxxx"   ;8
			.ascii  	"display edited xxxxxxxxxxxxxxxxxxxxxxxx"   ;9
			.ascii  	"curves on/off xxxxxxxxxxxxxxxxxxxxxxxxx"   ;10
			.ascii  	"go to edit menu xxxxxxxxxxxxxxxxxxxxxxx"   ;11
			.ascii  	"hardcopy this screen xxxxxxxxxxxxxxxxxx"   ;12
			.ascii  	"view attack/release xxxxxxxxxxxxxxxxxxx"   ;13
			.ascii  	"(edited)  xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;14
			.ascii  	"(original)xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ;15
			.ascii  	"viewing attack segments xxxxxxxxxxxxxxx"   ;16
			.ascii  	"viewing release segments xxxxxxxxxxxxxx"   ;17

locmesl 	.byte   	23,18, 3, 3, 7, 4, 6, 3,16,14
			.byte   	13,15,20,19, 8,10,24,24

 .bss

opflag  	.space  	6
colors  	.space  	6
times   	.space  	96
