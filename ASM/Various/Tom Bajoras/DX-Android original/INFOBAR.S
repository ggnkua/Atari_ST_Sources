;*****************************************************************************;
;   infobar --  Copyright 1986 Tom Bajoras
;      x1.l = menux (0-6), no exit conditions
;*****************************************************************************;

 .text

 .global infobar

infobar 	movem.l 	#$FFFE,-(a7)		; save registers
			move.l  	x1,-(a7)		; and x1-x5
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)
			move.l  	x1,d7   		; d7.l = menux

			lea 		infomesl,a5 	; a5 --> info message length array
			lea 		namebuf,a4  	; a4 --> encode output
			lea 		nmline,a0
			move.b  	0(a0,d7.l),d6
			addq.b  	#2,d6   		; d6.b = 1st line for infobar

			tst.l   	d7
			beq 		.menu0
			cmpi.l  	#1,d7
			beq 		.menu1
			cmpi.l  	#2,d7
			beq 		.menu2
			cmpi.l  	#3,d7
			beq 		.menu3
			cmpi.l  	#5,d7
			beq 		.menu5
			bra 		.return 	; illegal menux

.menu0  	move.l  	#infomess,x1
			move.b  	#1,x2
			move.b  	d6,x3
			move.b  	cmenkey,x4
			move.b  	(a5),x5
			jsr 		message 	; "Workspace name:"
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.l  	#wksname,x1
			move.b  	cmenu,x4
			move.b  	#10,x5
			jsr 		message 	; append w.s. name

			move.l  	#infomess,x1
			add.l   	#25,x1
			move.b  	#1,x2
			addq.b  	#1,x3
			move.b  	cmenkey,x4
			move.b  	1(a5),x5
			jsr 		message 		; "workspace monitoring"
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.l  	#infomess,x1
			tst.b   	monws
			bne 		.on
			add.l   	#75,x1
			move.b  	3(a5),x5
			bra 		.1
.on 		add.l   	#50,x1
			move.b  	2(a5),x5
.1  		jsr 		message 		; 'off' or 'on'

			clr.l   	d5
			move.b  	xmax,d5
			sub.b   	4(a5),d5
			lsr.b   	#1,d5   		; x-coord for 2nd column
			subq.b  	#3,d5   	; fudge factor for centering
			move.b  	d5,x2
			move.l  	#infomess,x1
			add.l   	#100,x1
			move.b  	d6,x3
			move.b  	cmenkey,x4
			move.b  	4(a5),x5
			jsr 		message 		; 'files used'
			move.w  	nfiles,x1
			jsr 		encode
			move.l  	a4,x1
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.b  	cmenu,x4
			move.b  	#4,x5
			jsr 		message

			move.b  	d5,x2
			addq.b  	#1,x3
			move.l  	#infomess,x1
			add.l   	#125,x1
			move.b  	cmenkey,x4
			move.b  	5(a5),x5
			jsr 		message 		; " files unused"
			move.w  	maxfile,d0
			sub.w   	nfiles,d0
			move.w  	d0,x1
			jsr 		encode
			move.l  	a4,x1
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.b  	cmenu,x4
			move.b  	#4,x5
			jsr 		message

			move.b  	xmax,d5
			sub.b   	#20,d5  	; assumes 20 chars needed for 3rd column
			move.b  	d5,x2
			move.b  	d6,x3
			move.l  	#infomess,x1
			add.l   	#150,x1
			move.b  	cmenkey,x4
			move.b  	6(a5),x5
			jsr 		message 		; 'files locked'
			move.w  	nfillok,x1
			jsr 		encode
			move.l  	a4,x1
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.b  	cmenu,x4
			move.b  	#4,x5
			jsr 		message

			move.b  	d5,x2
			addq.b  	#1,x3
			move.l  	#infomess,x1
			add.l   	#175,x1
			move.b  	cmenkey,x4
			move.b  	7(a5),x5
			jsr 		message 		; " files unlocked"
			move.w  	nfiles,d0
			sub.w   	nfillok,d0
			move.w  	d0,x1
			jsr 		encode
			move.l  	a4,x1
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.b  	cmenu,x4
			move.b  	#4,x5
			jsr 		message

			bra 		.return

.menu1  	move.l  	#infomess,x1
			add.l   	#200,x1
			move.b  	xmax,d0 		; center based on first of 2 lines
			sub.b   	8(a5),d0
			move.b  	9(a5),d1
			add.b   	10(a5),d1
			lsr.b   	#1,d1
			add.b   	11(a5),d1
			lsr.b   	#1,d1   		; average of 3 choices
			sub.b   	d1,d0
			lsr.b   	#1,d0
			move.b  	d0,x2
			move.b  	d6,x3
			move.b  	cmenkey,x4
			move.b  	8(a5),x5
			jsr 		message 	; "edit monitoring"
			move.l  	#infomess,x1
			move.b  	x5,d1
			add.b   	d1,x2
			addq.b  	#1,x2
			tst.b   	monedit
			beq 		.mode0
			cmpi.b  	#1,monedit
			beq 		.mode1
			add.l   	#275,x1
			move.b  	11(a5),x5
			bra 		.2
.mode0  	add.l   	#225,x1
			move.b  	9(a5),x5
			bra 		.2
.mode1  	add.l   	#250,x1
			move.b  	10(a5),x5
.2  		jsr 		message 	; append mode

			move.b  	d0,x2
			addq.b  	#1,x3
			move.b  	cmenkey,x4
			move.l  	#infomess,x1
			add.l   	#300,x1
			move.b  	12(a5),x5
			jsr 		message 	; current midi ch
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			clr.w   	d0
			move.b  	midich,d0
			move.w  	d0,x1
			jsr 		encode
			move.l  	a4,x1
			move.b  	cmenu,x4
			move.b  	#2,x5
			jsr 		message

			bra 		.return

.menu2  	clr.l   	d5
			move.b  	xmax,d5
			divu		#5,d5   		; d5= x-coord for first column
			move.b  	d5,x2
			move.l  	#infomess,x1
			add.l   	#100,x1
			move.b  	d6,x3
			move.b  	cmenkey,x4
			move.b  	4(a5),x5
			jsr 		message 		; 'files used'
			move.w  	nfiles,x1
			jsr 		encode
			move.l  	a4,x1
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.b  	cmenu,x4
			move.b  	#4,x5
			jsr 		message 		; append files used

			move.b  	d5,x2
			addq.b  	#1,x3
			move.l  	#infomess,x1
			add.l   	#125,x1
			move.b  	cmenkey,x4
			move.b  	5(a5),x5
			jsr 		message 		; " files unused"
			move.w  	maxfile,d0
			sub.w   	nfiles,d0
			move.w  	d0,x1
			jsr 		encode
			move.l  	a4,x1
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.b  	cmenu,x4
			move.b  	#4,x5
			jsr 		message

			mulu		#3,d5   		; x-coord for 2nd column
			move.b  	d5,x2
			move.b  	d6,x3
			move.l  	#infomess,x1
			add.l   	#325,x1
			move.b  	cmenkey,x4
			move.b  	13(a5),x5
			jsr 		message 		; 'files indexed'
			move.w  	nfilind,x1
			jsr 		encode
			move.l  	a4,x1
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.b  	cmenu,x4
			move.b  	#4,x5
			jsr 		message

			move.b  	d5,x2
			addq.b  	#1,x3
			move.l  	#infomess,x1
			add.l   	#350,x1
			move.b  	cmenkey,x4
			move.b  	14(a5),x5
			jsr 		message 		; " files unindexed
			move.w  	nfiles,d0
			sub.w   	nfilind,d0
			move.w  	d0,x1
			jsr 		encode
			move.l  	a4,x1
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.b  	cmenu,x4
			move.b  	#4,x5
			jsr 		message

			bra 		.return

.menu3  	move.b  	#1,x2
			move.l  	#infomess,x1
			add.l   	#100,x1
			move.b  	d6,x3
			move.b  	cmenkey,x4
			move.b  	4(a5),x5
			jsr 		message 		; 'files used'
			move.w  	nfiles,x1
			jsr 		encode
			move.l  	a4,x1
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.b  	cmenu,x4
			move.b  	#4,x5
			jsr 		message

			move.b  	#1,x2
			addq.b  	#1,x3
			move.l  	#infomess,x1
			add.l   	#125,x1
			move.b  	cmenkey,x4
			move.b  	5(a5),x5
			jsr 		message 		; " files unused"
			move.w  	maxfile,d0
			sub.w   	nfiles,d0
			move.w  	d0,x1
			jsr 		encode
			move.l  	a4,x1
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.b  	cmenu,x4
			move.b  	#4,x5
			jsr 		message

			clr.l   	d5
			move.b  	xmax,d5
			sub.b   	6(a5),d5
			lsr.b   	#1,d5
			subq.b  	#3,d5   		; fudge factor for centering
			move.b  	d5,x2   		; x-coord for 2nd column
			move.b  	d6,x3
			move.l  	#infomess,x1
			add.l   	#150,x1
			move.b  	cmenkey,x4
			move.b  	6(a5),x5
			jsr 		message 		; 'files locked'
			move.w  	nfillok,x1
			jsr 		encode
			move.l  	a4,x1
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.b  	cmenu,x4
			move.b  	#4,x5
			jsr 		message

			move.b  	d5,x2
			addq.b  	#1,x3
			move.l  	#infomess,x1
			add.l   	#175,x1
			move.b  	cmenkey,x4
			move.b  	7(a5),x5
			jsr 		message 		; " files unlocked"
			move.w  	nfiles,d0
			sub.w   	nfillok,d0
			move.w  	d0,x1
			jsr 		encode
			move.l  	a4,x1
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.b  	cmenu,x4
			move.b  	#4,x5
			jsr 		message

			move.b  	xmax,d5
			sub.b   	#21,d5  		; assumes 21 chars needed for 3rd col
			move.b  	d5,x2
			move.b  	d6,x3
			move.l  	#infomess,x1
			add.l   	#325,x1
			move.b  	cmenkey,x4
			move.b  	13(a5),x5
			jsr 		message 		; 'files indexed'
			move.w  	nfilind,x1
			jsr 		encode
			move.l  	a4,x1
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.b  	cmenu,x4
			move.b  	#4,x5
			jsr 		message

			move.b  	d5,x2
			addq.b  	#1,x3
			move.l  	#infomess,x1
			add.l   	#350,x1
			move.b  	cmenkey,x4
			move.b  	14(a5),x5
			jsr 		message 		; " files unindexed
			move.w  	nfiles,d0
			sub.w   	nfilind,d0
			move.w  	d0,x1
			jsr 		encode
			move.l  	a4,x1
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.b  	cmenu,x4
			move.b  	#4,x5
			jsr 		message

			bra 		.return

.menu5  	move.b  	xmax,d1 	; center based on 2nd line
			sub.b   	1(a5),d1
			move.b  	2(a5),d0
			add.b   	3(a5),d0
			lsr.b   	#1,d0   	; average of 2nd choice
			sub.b   	d0,d1
			lsr.b   	#1,d1
			move.b  	d1,x2
			move.b  	d6,x3
			move.b  	cmenkey,x4
			move.l  	#infomess,x1
			add.l   	#300,x1
			move.b  	12(a5),x5
			jsr 		message 	; current midi ch
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			clr.w   	d0
			move.b  	midich,d0
			move.w  	d0,x1
			jsr 		encode
			move.l  	a4,x1
			move.b  	cmenu,x4
			move.b  	#2,x5
			jsr 		message

			move.l  	#infomess,x1
			add.l   	#25,x1
			move.b  	d1,x2
			addq.b  	#1,x3
			move.b  	cmenkey,x4
			move.b  	1(a5),x5
			jsr 		message 		; "workspace monitoring"
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.l  	#infomess,x1
			tst.b   	monws
			bne 		.on2
			add.l   	#75,x1
			move.b  	3(a5),x5
			bra 		.3
.on2		add.l   	#50,x1
			move.b  	2(a5),x5
.3  		jsr 		message 		; 'off' or 'on'
			move.l  	#infomess,x1
			add.l   	#375,x1
			move.b  	d1,x2
			addq.b  	#1,x3
			move.b  	15(a5),x5
			jsr 		message
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.l  	#infomess,x1
			tst.b   	thruflag
			bne 		.on3
			add.l   	#75,x1
			move.b  	3(a5),x5
			bra 		.4
.on3		add.l   	#50,x1
			move.b  	2(a5),x5
.4  		jsr 		message

.return 	move.l  	(a7)+,x5		; restore x5-x1
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1
			movem.l 	(a7)+,#$7FFF	; restore registers
			rts 						; return
