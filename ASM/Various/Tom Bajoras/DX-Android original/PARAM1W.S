;*****************************************************************************;
;   paramed -- parametric editor, screen 1w
;   edmenu2 -- generate menus for screens 1e and 2e
;   		   Copyright 1986 Tom Bajoras
;   no entry conditions, no exit conditions
;*****************************************************************************;

 .text

 .global _para1w

_para1w:
			move.l  	#remouse,-(a7)
			move.w  	#1,-(a7)
			move.w  	#25,-(a7)
			trap		#14
			addq.l  	#8,a7
			clr.b   	allowms
			bra 		.para1w
remouse 	.byte   	8,0

;  put up screen:
.para1w 	jsr 		blnkscr 		; start with a blank screen
			move.b  	coutlne,x5  	; color for all lines
			clr.w   	x1  		 ; lines make it look nice
			move.w  	#13,x2
			move.w  	#639,x3
			move.w  	#13,x4
			jsr 		line
			move.w  	#324,x1
			move.w  	#324,x3
			move.w  	#199,x4
			jsr 		line
			move.w  	#104,x2
			move.w  	#639,x3
			move.w  	#104,x4
			jsr 		line
			move.b  	ascidash,x1
			move.b  	#4,x3
			move.b  	coutlne,x4
			move.b  	#1,x2
.dashloop   jsr 		outchar
			addq.b  	#1,x2
			cmpi.b  	#40,x2
			ble 		.dashloop

;   top line on screen
			move.b  	xmax,d0
			lea 		editmesl,a0
			sub.b   	(a0),d0
			sub.b   	#11,d0
			lsr.b   	#2,d0
			addq.b  	#1,d0
			move.b  	d0,x2
			move.l  	#editmess,x1
			move.b  	#1,x3
			move.b  	cmenhed,x4
			move.b  	(a0),x5
			jsr 		message 		; screen title
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.l  	#wksname,x1
			move.b  	cmessge,x4
			move.b  	#10,x5
			jsr 		message 			; append w.s. name
			move.b  	xmax,d0
			addq.b  	#1,d0
			sub.b   	22(a0),d0
			move.b  	d0,x2
			move.l  	#editmess,x1
			add.l   	#880,x1
			move.b  	22(a0),x5
			jsr 		message 		; original version

;   put up parameter names
			move.l  	#parmess,x1
			move.b  	#1,x2
			move.b  	cmenkey,x4
			clr.l   	d1
			move.b  	parmesl,d1
			move.b  	parmesl,x5
			move.b  	#5,x3   	; for x3 = 5 to 25
.nameloop   jsr 		message
			add.l   	d1,x1
			addq.b  	#1,x3
			cmpi.b  	#25,x3
			ble 		.nameloop

;  put up operator #'s
			jsr 		putopnum

;   put up parameters
			move.b  	#1,noblank  	; no blank5 in outparw
			clr.b   	x2  		 ; for x2 = 0 to 20
.parloop1   clr.b   	x1  		 ;    for x1 = 0 to 5
			move.b  	cmessge,x3
.parloop2   jsr 		outparw
			addq.b  	#1,x1
			cmpi.b  	#5,x1
			ble 		.parloop2
			addq.b  	#1,x2
			cmpi.b  	#20,x2
			ble 		.parloop1
			clr.b   	noblank

;   write menu
			bsr 		edmenu3

			move.b  	134(a5),x1
			move.b  	cmessge,x2
			jsr 		algorith

;   get a key:
.keyloop	jsr 		getkey
			move.b  	y1,d4   	; d4.b = gotten key

;   branch according to key:
			cmp.b   	ascis,d4
			beq 		.para2w
			cmp.b   	ascie,d4
			beq 		.para1e
			cmp.b   	ascihelp,d4
			beq 		.help
			cmp.b   	ascicr,d4
			beq 		.return
			jsr 		bell		; bad key: ring bell, get another key
			bra 		.keyloop

.help   	move.b  	ymax,x1
			jsr 		hardtext
			bra 		.keyloop

.return 	jmp 		edreturn

.para2w 	jmp 		_para2w
;  when going to screen 1e:
;  if (monedit<2) send es non-f-pars to synth
;  if (monedit<>1) send es f-pars to synth

.para1e 	cmpi.b  	#2,monedit
			beq 		.f_only
			jsr 		edtosyn
			jsr 		writdx7
			jsr 		sendmute
			cmpi.b  	#1,monedit
			beq 		.no_f
.f_only 	move.l  	#edspace,x1
			add.l   	#145,x1
			jsr 		writfdx7

.no_f   	jmp 		_para1e

;  routine to generate menus for param1w / param2w

 .global edmenu3

edmenu3 	move.b  	#1,ghostch  	; none of this will hardcopy
			lea 		editmesl,a0
			move.b  	xmax,d0
			lsr.b   	#1,d0
			addq.b  	#3,d0
			move.b  	d0,x2
			move.b  	cmenkey,x4
			move.l  	#editmess,x1
			add.l   	#360,x1
			move.b  	#15,x3
			move.b  	9(a0),x5
			jsr 		message 		; s
			move.l  	#editmess,x1
			add.l   	#920,x1
			addq.b  	#1,x3
			move.b  	23(a0),x5
			jsr 		message 		; e
			move.l  	#editmess,x1
			add.l   	#520,x1
			addq.b  	#1,x3
			move.b  	13(a0),x5
			jsr 		message 		; help
			move.l  	#editmess,x1
			add.l   	#680,x1
			addq.b  	#1,x3
			move.b  	17(a0),x5
			jsr 		message 		; cr

			add.b   	#10,x2  		; menu items:
			move.b  	cmenu,x4
			move.b  	#15,x3
			move.l  	#editmess,x1
			add.l   	#400,x1
			move.b  	10(a0),x5
			jsr 		message 		; go to screen 2
			move.l  	#editmess,x1
			add.l   	#2040,x1
			addq.b  	#1,x3
			move.b  	51(a0),x5
			jsr 		message 		; display edited version
			move.l  	#editmess,x1
			add.l   	#560,x1
			addq.b  	#1,x3
			move.b  	14(a0),x5
			jsr 		message 		; hardcopy this screen
			move.l  	#editmess,x1
			add.l   	#720,x1
			addq.b  	#1,x3
			move.b  	18(a0),x5
			jsr 		message 		; return to edit menu

			clr.b   	ghostch 		; re-allow hardcopying of text
			rts

;******************************************************************************
;   routine to generate menu for param1e or param2e
;******************************************************************************

 .global edmenu2

edmenu2 	move.b  	#1,ghostch  	; none of this will hardcopy
			jsr 		renew2  		; blank out previous menu

			lea 		editmesl,a0
			move.b  	xmax,d0
			lsr.b   	#1,d0
			addq.b  	#3,d0
			move.b  	d0,x2
			move.b  	#15,x3
			move.b  	cmenkey,x4
			tst.b   	edmenflg
			bne 		.keys2

			move.l  	#editmess,x1	; page 1 keys
			add.l   	#480,x1
			move.b  	12(a0),x5
			jsr 		message 		; arrows
			move.l  	#editmess,x1
			add.l   	#960,x1
			addq.b  	#1,x3
			move.b  	24(a0),x5
			jsr 		message 		; +,-
			move.l  	#editmess,x1
			add.l   	#280,x1
			addq.b  	#1,x3
			move.b  	7(a0),x5
			jsr 		message 		; u-n-d
			move.l  	#editmess,x1
			add.l   	#360,x1
			addq.b  	#1,x3
			move.b  	9(a0),x5
			jsr 		message 		; s
			move.l  	#editmess,x1
			add.l   	#440,x1
			addq.b  	#1,x3
			move.b  	11(a0),x5
			jsr 		message 		; w
			move.l  	#editmess,x1
			add.l   	#520,x1
			addq.b  	#1,x3
			move.b  	13(a0),x5
			jsr 		message 		; help
			move.l  	#editmess,x1
			add.l   	#600,x1
			addq.b  	#1,x3
			move.b  	15(a0),x5
			jsr 		message 		; 0-9
			move.l  	#editmess,x1
			add.l   	#680,x1
			addq.b  	#1,x3
			move.b  	17(a0),x5
			jsr 		message 		; cr
			move.l  	#editmess,x1
			add.l   	#760,x1
			addq.b  	#1,x3
			move.b  	19(a0),x5
			jsr 		message 		; del
			bra 		.items

.keys2  	move.l  	#editmess,x1	; page 2 keys
			add.l   	#2160,x1
			move.b  	54(a0),x5
			jsr 		message 		; *
			addq.b  	#1,x3
			move.l  	#editmess,x1
			add.l   	#2240,x1
			move.b  	56(a0),x5
			jsr 		message 		; c
			addq.b  	#1,x3
			move.l  	#editmess,x1
			add.l   	#2320,x1
			move.b  	58(a0),x5
			jsr 		message 		; x
			move.l  	#editmess,x1
			add.l   	#2400,x1
			addq.b  	#1,x3
			move.b  	60(a0),x5
			jsr 		message 		; a
			move.l  	#editmess,x1
			add.l   	#2480,x1
			addq.b  	#1,x3
			move.b  	62(a0),x5
			jsr 		message 		; z
			move.l  	#editmess,x1
			add.l   	#1920,x1
			addq.b  	#1,x3
			move.b  	48(a0),x5
			jsr 		message 		; tab/bs
			move.l  	#editmess,x1
			add.l   	#2560,x1
			addq.b  	#1,x3
			move.b  	64(a0),x5
			jsr 		message 		; m

.items  	add.b   	#17,x2
			move.b  	cmenu,x4
			move.b  	#15,x3
			tst.b   	edmenflg
			bne 		.items2

			move.l  	#editmess,x1		; page 1 items
			add.l   	#160,x1
			move.b  	4(a0),x5
			jsr 		message 		; arrows
			move.l  	#editmess,x1
			add.l   	#240,x1
			addq.b  	#1,x3
			move.b  	6(a0),x5
			jsr 		message 			; increment/decrement
			move.l  	#editmess,x1
			add.l   	#320,x1
			addq.b  	#1,x3
			move.b  	8(a0),x5
			jsr 		message 			; undo all editing
			move.l  	#editmess,x1
			add.l   	#400,x1
			addq.b  	#1,x3
			move.b  	10(a0),x5
			jsr 		message 		; go to screen 2
			move.l  	#editmess,x1
			add.l   	#2000,x1
			addq.b  	#1,x3
			move.b  	50(a0),x5
			jsr 		message 		; display original version
			move.l  	#editmess,x1
			add.l   	#560,x1
			addq.b  	#1,x3
			move.b  	14(a0),x5
			jsr 		message 		; hardcopy this screen
			move.l  	#editmess,x1
			add.l   	#640,x1
			addq.b  	#1,x3
			move.b  	16(a0),x5
			jsr 		message 		; direct data entry
			move.l  	#editmess,x1
			add.l   	#720,x1
			addq.b  	#1,x3
			move.b  	18(a0),x5
			jsr 		message 		; return to edit menu
			move.l  	#editmess,x1
			add.l   	#800,x1
			addq.b  	#1,x3
			move.b  	20(a0),x5
			jsr 		message 		; unedit a parameter
			bra 		.return

.items2 	move.l  	#editmess,x1	; page 2 items
			add.l   	#2200,x1
			move.b  	55(a0),x5
			jsr 		message 		; mark an op
			move.l  	#editmess,x1
			add.l   	#2280,x1
			addq.b  	#1,x3
			move.b  	57(a0),x5
			jsr 		message 		; copy eg
			move.l  	#editmess,x1
			add.l   	#2360,x1
			addq.b  	#1,x3
			move.b  	59(a0),x5
			jsr 		message 		; exchange eg's
			move.l  	#editmess,x1
			add.l   	#2440,x1
			addq.b  	#1,x3
			move.b  	61(a0),x5
			jsr 		message 		; copy column
			move.l  	#editmess,x1
			add.l   	#2520,x1
			addq.b  	#1,x3
			move.b  	63(a0),x5
			jsr 		message 		; exchange columns
			move.l  	#editmess,x1
			add.l   	#1960,x1
			addq.b  	#1,x3
			move.b  	49(a0),x5
			jsr 		message 		; tab forward/backward
			move.l  	#editmess,x1
			add.l   	#2600,x1
			addq.b  	#1,x3
			move.b  	65(a0),x5
			jsr 		message 		; mute/un-mute operator

.return 	clr.b   	ghostch 		; allow hardcopying of text
			rts
