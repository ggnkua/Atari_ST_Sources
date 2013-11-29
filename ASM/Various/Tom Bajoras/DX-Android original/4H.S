;*****************************************************************************;
;   module 4h source file    Copyright 1986 Tom Bajoras
;   droid menu command branching routine: br8anch
;
;   describe -- edit disttabl
;*****************************************************************************;

 .text

;*****************************************************************************;
;   br8anch
;*****************************************************************************;

 .global br8anch
br8anch 	movem.l 	#$FFFE,-(a7)		; save registers
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)

			moveq   	#7,d6   		; d6.l = menux for branch routines
			move.l  	x1,d0   		; d0 = itemx
			beq 		.droidws		; branch according to itemx
			cmpi.b  	#1,d0
			beq 		.droidwb
			cmpi.b  	#2,d0
			beq 		.randws
			cmpi.b  	#3,d0
			beq 		.randwb
			cmpi.b  	#4,d0
			beq 		.cpwsfl
			cmpi.b  	#5,d0
			beq 		.cpwswb
			cmpi.b  	#6,d0
			beq 		.glwsfl
			cmpi.b  	#7,d0
			beq 		.glwswb
			cmpi.b  	#8,d0
			beq 		.avwsfl
			cmpi.b  	#9,d0
			beq 		.avwswb
			cmpi.b  	#10,d0
			beq 		.distort
			cmpi.b  	#11,d0
			beq 		.quick
			cmpi.b  	#12,d0
			beq 		.18droid
			cmpi.b  	#13,d0
			beq 		.18rand
			cmpi.b  	#14,d0
			beq 		.describe
			bra 		.returnx		; illegal itemx simply returns

.return 	tst.b   	monws
			beq 		.returnx
			jsr 		wstosyn
			jsr 		writdx7
			move.l  	#wkspace,x1
			add.l   	#145,x1
			jsr 		writfdx7
.returnx	move.l  	(a7)+,x5		; restore registers,x1-x5,return
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1
			movem.l 	(a7)+,#$7FFF
			rts

.droidws	jsr 		droidws
			bra 		.return

.droidwb	jsr 		droidwb
			clr.b   	lastbank
			bra 		.returnx

.randws 	jsr 		randws
			bra 		.return

.randwb 	jsr 		randwb
			clr.b   	lastbank
			bra 		.returnx

.18droid	clr.b   	d7  			; switch to intelligent random
.18x		move.l  	d6,x1
			jsr 		creturn
			move.l  	#-1,x1
			move.l  	#6,x2
			jsr 		getyn   		; are you sure?
			tst.b   	y1
			bne 		.18x1
			jsr 		branch5 		; if no, abort
.18x1   	tst.b   	nbanks
			beq 		.18x2
			jsr 		scrallb 		; scratch all banks (if some exist)
			clr.b   	lastbank
.18x2   	move.b  	#1,x1   		; loop bankx = 1 to 18
.18loop 	cmpi.b  	#1,d7
			beq 		.d7eq1
			jsr 		droidwb
			bra 		.either
.d7eq1  	jsr 		randwb
.either 	jsr 		savebnk
			tst.b   	y1
			beq 		.18x3
			jmp 		diskerr
.18x3   	addq.b  	#1,x1
			cmpi.b  	#18,x1
			ble 		.18loop
			jsr 		writinfo
			bra 		.returnx

.18rand 	moveq   	#1,d7   		; switch to wild-random
			bra 		.18x

.cpwsfl 	jsr 		wstoed  		; save w.s. into e.s.
			move.l  	#wksname,x1
			move.l  	#catbuf,x2
			move.b  	#10,x3
			jsr 		movemem 		; save w.s. name into catbuf
			tst.w   	nfiles
			bne 		.cpwsfl1
			move.l  	#7,x3   		; error if no files
			jsr 		branch1
.cpwsfl1	lea 		.cpwsfl2,a6 	; loop back to here if bad file name
.cpwsfl2	moveq   	#3,d7
			jsr 		branch8b
			jsr 		findfil 		; try to find the file
			move.w  	y1,d1   		; d1 = filex if found, else = 0
			bne 		.cpwsfl3
			move.l  	#9,x3   		; error if not found
			jsr 		branch2
.cpwsfl3	move.w  	d1,x1
			jsr 		usefile 		; use the file
			tst.b   	y1  		 ; all ok?
			beq 		.cpwsfl4
			jmp 		diskerr
.cpwsfl4	move.l  	#edspace,x1
			move.l  	#wkspace,x2
			move.l  	#catbuf,x3
			move.l  	#wksname,x4
			jsr 		compare
			jsr 		edtows  		; restore w.s.
			move.l  	#catbuf,x1
			move.l  	#wksname,x2
			move.b  	#10,x3
			jsr 		movemem 		; restore w.s. name from catbuf
			jsr 		branch13

.cpwswb 	move.l  	d6,x1
			jsr 		creturn 		; get slot #
			move.l  	#15,x1
			jsr 		getslot
			tst.b   	y2
			beq 		.cpwswb1
			jsr 		branch5
.cpwswb1	move.b  	y1,d1   	; d1.b = slot # = 1-32
			subq.b  	#1,d1   					= 0-31
			andi.l  	#$FF,d1
			mulu		#10,d1
			move.l  	#wkbname,x4
			add.l   	d1,x4
			mulu		#16,d1
			move.l  	#wkbank,x2
			add.l   	d1,x2
			move.l  	#wkspace,x1
			move.l  	#wksname,x3
			jsr 		compare
			jsr 		branch13

.glwsfl 	tst.w   	nfiles
			bne 		.glwsfl2
			move.l  	#7,x3
			jsr 		branch1 		; cannot if no files on disk
.glwsfl2	lea 		.glwsfl3,a6 	; loop back to here if bad file name
.glwsfl3	moveq   	#3,d7
			jsr 		branch8 		; prompt for file name
			jsr 		findfil 		; try to find the file
			move.w  	y1,d2   		; d1.w = filex if found, else=0
			bne 		.glwsfl4
			move.l  	#9,x3
			jsr 		branch2 		; error if not found
.glwsfl4	lea 		.glwsfl5,a6 	; loop back if bad #
.glwsfl5	moveq   	#21,d7  		; prompt for # of steps
			jsr 		branch9 		; get #
			jsr 		value
			move.l  	y1,d1
			ble 		.badnum
			cmpi.l  	#$7F,d1
			bgt 		.badnum
			cmp.b   	#16,d1
			bgt 		.badnum
			jsr 		wstoed  		; copy w.s. to e.s.
			move.l  	#wksname,x1
			move.l  	#wwkbank,x2
			move.b  	#10,x3
			jsr 		movemem 		; save from name
			move.w  	d2,x1
			jsr 		usefile 		; copy file to w.s.
			tst.b   	y1  		 ; everything ok?
			beq 		.glwsfl6
			jmp 		diskerr
.glwsfl6	move.l  	#wkspace,x1
			jsr 		checkws 		; check for mangled data
			move.l  	#wksname,x1
			move.l  	#wwkbank,x2
			add.l   	#10,x2
			move.b  	#10,x3
			jsr 		movemem 		; save to name
			move.b  	d1,x1
			trap		#11 			; key rpt on
			jsr 		glide
			trap		#10 			; key rpt off
			jsr 		edtows  		; copy e.s. to w.s.
			jsr 		branch13

.glwswb 	move.l  	d6,x1
			jsr 		creturn
			move.l  	#15,x1
			jsr 		getslot
			tst.b   	y2
			beq 		.glwswb2
			jsr 		branch5 	; cr aborts this
.glwswb2	move.b  	y1,d2
			lea 		.glwswb3,a6 	; loop back if bad #
.glwswb3	moveq   	#21,d7  		; prompt for # of steps
			jsr 		branch9 		; get #
			jsr 		value
			move.l  	y1,d1
			ble 		.badnum
			cmpi.l  	#$7F,d1
			bgt 		.badnum
			cmp.b   	#16,d1
			bgt 		.badnum
			jsr 		wstoed  		; copy w.s. to e.s.
			move.l  	#wksname,x1
			move.l  	#wwkbank,x2
			move.b  	#10,x3
			jsr 		movemem 		; save from name
			move.b  	d2,x1
			jsr 		wbtows  		; copy specified w.b. slot to w.s.
			move.l  	#wkbname,x1
			subq.b  	#1,d2
			andi.l  	#$FF,d2
			mulu		#10,d2
			add.l   	d2,x1
			move.l  	#wwkbank,x2
			add.l   	#10,x2
			move.b  	#10,x3
			jsr 		movemem 		; save to name
			move.b  	d1,x1
			trap		#11 			; key rpt on
			jsr 		glide
			trap		#10 			; key rpt off
			jsr 		edtows  		; copy e.s. to w.s.
			jsr 		branch13

.avwsfl 	tst.w   	nfiles
			bne 		.avwsfl1
			move.l  	#7,x3   		; error if no files
			jsr 		branch1
.avwsfl1	lea 		.avwsfl2,a6 	; loop back to here if bad file name
.avwsfl2	moveq   	#3,d7
			jsr 		branch8 		; prompt for a file name
			jsr 		findfil 		; try to find the file
			move.w  	y1,d1   		; d1 = filex if found, else = 0
			bne 		.avwsfl3
			move.l  	#9,x3   		; error if not found
			jsr 		branch2
.avwsfl3	jsr 		wstoed  		; save w.s. into e.s.
			move.w  	d1,x1
			jsr 		usefile 		; use the file
			tst.b   	y1  		 ; all ok?
			beq 		.avwsfl4
			jmp 		diskerr
.avwsfl4	move.l  	#wkspace,x1
			jsr 		checkws 		; check for mangled data
			lea 		edspace,a0  	; a0--> previous w.s.
			move.b  	144(a0),d7  	; d7.b = old transpose
			lea 		wkspace,a1  	; a1--> new w.s.
			move.w  	#160,d0 		; for d0.w = 160 to 1
.avwsfl5	move.b  	(a0)+,d1
			add.b   	(a1),d1
			lsr.b   	#1,d1
			move.b  	d1,(a1)+
			subq.w  	#1,d0
			bne 		.avwsfl5
.avname 	move.l  	#avname,x1
			move.l  	#wksname,x2
			move.b  	#10,x3
			jsr 		movemem 	; w.s. name = average name
			lea 		wkspace,a1  ; restore transpose
			move.b  	d7,144(a1)
			bra 		.return

.avwswb 	move.l  	d6,x1
			jsr 		creturn 		; get slot #
			move.l  	#15,x1
			jsr 		getslot
			tst.b   	y2
			beq 		.avwswb1
			jsr 		branch5
.avwswb1	move.b  	y1,d0   	; d0.b = slot # = 1-32
			subq.b  	#1,d0   					= 0-31
			andi.l  	#$FF,d0
			mulu		#160,d0
			lea 		wkbank,a0
			add.l   	d0,a0   	; a0 --> specified wb slot
			move.w  	#160,d0
			lea 		wkspace,a1
			move.b  	144(a1),d7  ; d7.b = old transpose
.avwswb2	move.b  	(a0)+,d1
			add.b   	(a1),d1
			lsr.b   	#1,d1
			move.b  	d1,(a1)+
			subq.w  	#1,d0
			bne 		.avwswb2
			bra 		.avname

.distort	jsr 		distort
			bra 		.return

.quick  	tst.b   	nbanks   ; error if no banks on disk
			bne 		.quick2
			move.l  	#22,x3
			jsr 		branch1
.quick2 	lea 		.quick3,a6  	   ; loop back if bad #
.quick3 	moveq   	#23,d7
			jsr 		branch9 			; get #
			jsr 		value
			move.l  	y1,d1   			; d1.l = #
			ble 		.badnum
			cmp.l   	#$7F,d1 			; bad # if < 1 or > 7
			bgt 		.badnum
			cmp.b   	#7,d1
			bgt 		.badnum
			move.b  	d1,txatten
			move.b  	#1,invtext  ; inverse cprompt
			trap		#11 		; key repeat on
			jsr 		quick
			trap		#10 		; key repeat off
			clr.b   	invtext 	; normal cprompt
			jsr 		branch13

.badnum 	move.l  	#1,x2
			jsr 		branch11

.describe   move.b  	#1,invtext  ; inverse cprompt
			jsr 		describe
			trap		#10 		; key repeat off
			clr.b   	invtext 	; normal cprompt
			jsr 		branch13

;******************************************************************************
;   describe -- edit disttabl
;******************************************************************************

 .global describe

describe	movem.l 	#$FFFE,-(a7)
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)

			jsr 		blnkscr 		; start with blank screen
			move.b  	#2,x1   		; change colors
			jsr 		setcolor

			move.l  	#disttabl,x1
			move.l  	#wwkbank,x2
			move.b  	#159,x3
			jsr 		movemem 		; save former disttabl for undo key

			move.l  	#setmous,-(a7)  ; allow mouse and mouse buttons
			move.w  	#3,-(a7)
			move.w  	#25,-(a7)
			trap		#14
			addq.l  	#8,a7
			move.b  	#1,allowms
			bra 		.descrbx
setmous 	.byte   	10,16,7,4

.descrbx	clr.l   	d7  			; d7.l = screen # (0-1)

			move.l  	#locmess,x1 	; heading
			lea 		locmesl,a0
			move.b  	xmax,d0
			sub.b   	(a0),d0
			lsr.b   	#1,d0
			addq.b  	#1,d0
			move.b  	d0,x2   		; center it
			move.b  	#1,x3
			move.b  	cmenu,x4
			move.b  	(a0),x5
			jsr 		message
			add.l   	#38,x1
			move.b  	#1,x2
			move.b  	1(a0),x5
			jsr 		message 		; Screen:
			add.l   	#38,x1
			move.b  	#1,x2
			move.b  	ymax,x3
			subq.b  	#2,x3
			move.b  	cmenu,x4
			move.b  	2(a0),x5
			jsr 		message 		; menu
			add.l   	#38,x1
			addq.b  	#1,x3
			move.b  	3(a0),x5
			jsr 		message
			add.l   	#38,x1
			addq.b  	#1,x3
			move.b  	4(a0),x5
			jsr 		message
			add.l   	#38,x1
			move.b  	#43,x2
			move.b  	ymax,x3
			subq.b  	#2,x3
			move.b  	5(a0),x5
			jsr 		message
			add.l   	#38,x1
			addq.b  	#1,x3
			move.b  	6(a0),x5
			jsr 		message
			add.l   	#38,x1
			addq.b  	#1,x3
			move.b  	7(a0),x5
			jsr 		message

			lea 		parmname,a5 	; a5 --> parameter names
			lea 		disttabl,a6 	; a6 --> distortion table

.scrloop	move.b  	d7,x1
			add.b   	#$31,x1
			move.b  	#9,x2
			move.b  	#1,x3
			move.b  	cmenu,x4
			jsr 		outchar
			move.l  	d7,d0
			mulu		#84,d0
			move.l  	d0,d1
			add.l   	#83,d1  		; for d0 to d1
			moveq   	#2,d2   		; for d2= 2 to 22 (y-coord)
			moveq   	#4,d3   		; for d3= 4,24,44,64 (x-coord)
.parloop	move.l  	a5,x1
			move.l  	d0,d4
			mulu		#11,d4
			add.l   	d4,x1
			move.b  	d3,x2
			move.b  	d2,x3
			move.b  	cmenkey,x4
			move.b  	#10,x5
			jsr 		message
			add.b   	#12,x2
			tst.b   	0(a6,d0.l)
			beq 		.not
			cmpi.l  	#158,d0
			bgt 		.not
			move.b  	#8,x1
			move.b  	cmessge,x4
			bra 		.doit
.not		move.b  	ascisp,x1
			move.b  	cbakgnd,x4
.doit   	jsr 		outchar
			addq.l  	#1,d0
			cmp.l   	d1,d0
			bgt 		.endscr
			addq.b  	#1,d2
			cmpi.b  	#22,d2
			ble 		.parloop
			move.b  	#2,d2
			add.b   	#20,d3
			bra 		.parloop

.endscr 	clr.w   	d4  			; cursorx = 0-3
			clr.w   	d5  			; cursory = 0-20
.cursloop   bsr 		cursor

.keyloop	jsr 		getkey
			trap		#11
			move.b  	y1,d0
			cmp.b   	ascis,d0
			beq 		.screen
			cmp.b   	ascicr,d0
			beq 		.return
			cmp.b   	ascirit,d0
			beq 		.right
			cmp.b   	ascilef,d0
			beq 		.left
			cmp.b   	asciup,d0
			beq 		.up
			cmp.b   	ascidwn,d0
			beq 		.down
			cmp.b   	ascisp,d0
			beq 		.mark
			cmp.b   	ascimrit,d0
			beq 		.mark
			cmp.b   	ascimlef,d0
			beq 		.mark
			cmp.b   	asciundo,d0
			beq 		.undo
			cmp.b   	asciins,d0
			beq 		.fill
			cmp.b   	ascihome,d0
			beq 		.clear
			jsr 		bell
			bra 		.keyloop

.undo   	move.l  	#wwkbank,x1
			move.l  	#disttabl,x2
			move.b  	#159,x3
			jsr 		movemem
			bra 		.scrloop

.fill   	moveq   	#1,d1
			bra 		fillclr
.clear  	clr.b   	d1
fillclr 	move.w  	#158,d0
			lea 		disttabl,a0
.fillx  	move.b  	d1,0(a0,d0.w)
			subq.w  	#1,d0
			bge 		.fillx
			bra 		.scrloop

.screen 	eor.w   	#1,d7
			bra 		.scrloop

.right  	cmpi.b  	#3,d4
			beq 		.keyloop
			tst.b   	d7
			beq 		.rightx
			cmpi.b  	#2,d4
			bne 		.rightx
			cmpi.b  	#11,d5
			bgt 		.keyloop
.rightx 	bsr 		xcursor
			addq.b  	#1,d4
			bra 		.cursloop

.left   	tst.b   	d4
			beq 		.keyloop
			bsr 		xcursor
			subq.b  	#1,d4
			bra 		.cursloop

.up 		tst.b   	d5
			beq 		.keyloop
			bsr 		xcursor
			subq.b  	#1,d5
			bra 		.cursloop

.down   	cmpi.b  	#20,d5
			beq 		.keyloop
			tst.b   	d7
			beq 		.downx
			cmpi.b  	#3,d4
			bne 		.downx
			cmpi.b  	#11,d5
			beq 		.keyloop
.downx  	bsr 		xcursor
			addq.b  	#1,d5
			bra 		.cursloop

.mark   	move.l  	d7,d0
			mulu		#84,d0
			move.l  	d4,d1
			mulu		#21,d1
			add.l   	d1,d0
			add.l   	d5,d0
			eori.b  	#1,0(a6,d0.l)
			bra 		.cursloop

.return 	move.l  	(a7)+,x5
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1
			movem.l 	(a7)+,#$7FFF
			rts

xcursor 	move.b  	cmenu,x4
			bra 		cursorx
cursor  	move.b  	cprompt,x4
cursorx 	move.l  	d7,d0
			mulu		#84,d0
			move.l  	d4,d1
			mulu		#21,d1
			add.l   	d1,d0
			add.l   	d5,d0   		; d0.l = parameter #
			tst.b   	0(a6,d0.l)
			beq 		cursnot
			move.b  	#8,x1
			bra 		cursdo
cursnot 	move.b  	ascisp,x1
cursdo  	move.l  	d4,d0
			mulu		#20,d0
			add.b   	#16,d0
			move.b  	d0,x2
			move.b  	d5,x3
			addq.b  	#2,x3
			jsr 		outchar
			rts

 .data

locmess 	.ascii  	"Modify Distort / Android-2 Functions "
			.ascii  	"Screen: xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
			.ascii  	"[s]  Toggle screen xxxxxxxxxxxxxxxxxx"
			.ascii  	"[cr] Go to android menu xxxxxxxxxxxxx"
			.ascii  	"arrows,mouse  move cursor xxxxxxxxxxx"
			.ascii  	"[sp],mouse buttons (un)mark parameter"
			.ascii  	"[Undo] Undo all modifications xxxxxxx"
			.ascii  	"[Insert],[Clr]  Set all, Clear all xx"
locmesl 	.byte   	36,7,18,23,25,37,29,34
