;*****************************************************************************;
;   module 4e source file    Copyright 1986 Tom Bajoras
;   bank menu command branching routine: br5anch
;*****************************************************************************;

 .text

;*****************************************************************************;
;   br5anch
;      x1 = itemx
;*****************************************************************************;

 .global br5anch

br5anch 	movem.l 	#$FFFE,-(a7)		; save registers and x1-x5
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)

			move.l  	x1,d0   			; d0 = itemx = 0-11 (l)
			move.l  	#4,d6   			; d6.l = 4 for branch routines
			tst.b   	d0  			 ; branch according to itemx
			beq 		.initwb
			cmpi.b  	#6,d0
			beq 		.wbtosyn
			cmpi.b  	#4,d0
			beq 		.syntowb
			cmpi.b  	#2,d0
			beq 		.save
			cmpi.b  	#1,d0
			beq 		.use
			cmpi.b  	#9,d0
			beq 		.scratch
			cmpi.b  	#8,d0
			beq 		.list
			cmpi.b  	#3,d0
			beq 		.execwb
			cmpi.b  	#10,d0
			beq 		.rename
			cmpi.b  	#11,d0
			beq 		.btosyn
			cmpi.b  	#5,d0
			beq 		.ftowb
			cmpi.b  	#7,d0
			beq 		.ftosyn
			bra 		.returnx		; simply return if illegal itemx

.return 	jsr 		disbnm  			; update bank names display
.returnx	move.l  	(a7)+,x5			; restore registers,x1-x5,return
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1
			movem.l 	(a7)+,#$7FFF
			rts

.initwb 	move.l  	d6,x1
			jsr 		creturn
			move.l  	#-1,x1
			move.l  	#6,x2
			jsr 		getyn   			; are you sure?
			tst.b   	y1
			bne 		.initwb2
			jsr 		branch5
.initwb2	jsr 		initwb  			; re-init w.b.
			clr.b   	lastbank			; no most recently selected bank
			bra 		.return

.wbtosyn	jsr 		gobank  			; copy w.b. to synbuf
			jsr 		writbdx7			; write synbuf to synth
			bra 		.returnx			; restore registers,x1-x5,return

.syntowb	jsr 		readbdx7
			tst.b   	y1
			beq 		.success			; check for error
			cmpi.b  	#2,y1
			beq 		synerr
			jsr 		readbtx7
			tst.b   	y1
			bne 		synerr
.success	jsr 		fetchb  			; copy from buffer to workbank
			clr.b   	lastbank	 ; no most recently selected bank
			move.l  	d6,x1
			jsr 		creturn
			move.l  	#-1,x1
			move.l  	#39,x2
			jsr 		getyn      ; default all w.b. f-pars? (y/n)
			tst.b   	y1
			beq 		.syntowb3
			move.l  	#initsnd,x1
			move.l  	#wkbank,x2
			add.l   	#145,x1 		; if y: default all w.b. slot f-pars
			add.l   	#145,x2
			move.l  	#15,x3
			clr.b   	d0  			; d0 = 1 to 32
.syntowb2   jsr 		movemem
			add.l   	#160,x2
			addq.b  	#1,d0
			cmpi.b  	#32,d0
			bne 		.syntowb2
.syntowb3   bsr 		checkwb
			bra 		.return 			; restore registers,x1-x5,return

.save   	lea 		.save2,a6   	   ; loop back if bad #
.save2  	moveq   	#6,d7
			jsr 		branch9 			; get a #
			jsr 		value
			move.l  	y1,d1   			; d1.l = #
			bgt 		.save4
.badnum 	move.l  	#1,x2   			; bad # if <1 or >maxbank
			jsr 		branch11
.save4  	cmp.l   	#$7F,d1
			bgt 		.badnum
			cmp.b   	maxbank,d1
			bgt 		.badnum
			lea 		bankflg,a1
			subq.l  	#1,a1
			tst.b   	0(a1,d1.w)
			beq 		.save5
			move.l  	d6,x1   			; if bank already exists:
			jsr 		creturn 			; replace it ? (y/n)
			move.l  	#27,x1
			move.l  	#2,x2
			jsr 		getyn
			tst.b   	y1
			bne 		.save5
			jsr 		branch6 			; if n: try again
.save5  	move.b  	d1,x1
			jsr 		savebnk 			; save bank
			tst.b   	y1  			 ; all ok?
			bne 		.diskerr
			move.b  	d1,lastbank 	; update most recently selected bank
.nameloop   clr.b   	x5
			move.l  	d6,x1
			jsr 		creturn
			move.l  	#14,x1
			jsr 		getit   		; prompt for name
			tst.b   	y2  		 ; aborted?
			bne 		.noname
			move.l  	y1,x1
			jsr 		parsnam
			tst.b   	y1
			beq 		.okname
			clr.l   	x2
			move.l  	d6,x1
			jsr 		errmess 		; bad name, try again
			bra 		.nameloop
.okname 	move.b  	d1,x1
			jsr 		namebnk 			; (re)name bank
			bra 		.save6
.noname 	lea 		bnamflg,a0
			subq.l  	#1,a0
			tst.b   	0(a0,d1.w)  	 ; bank already unnamed?
			beq 		.save6
			move.b  	d1,x1
			jsr 		unnmbnk
.save6  	jsr 		writinfo
			bra 		.return 			; restore registers,x1-x5,return

.use		tst.b   	nbanks
			bne 		.use2   			; if no banks on disk: error
			move.l  	#22,x3
			jsr 		branch1
.use2   	lea 		.use3,a6		  ; loop back if bad #
.use3   	moveq   	#6,d7
			jsr 		branch9 			; get #
			jsr 		value
			move.l  	y1,d1   			; d1.l = #
			ble 		.badnum
			cmp.l   	#$7F,d1 			; bad # if #<1 or >maxbank
			bgt 		.badnum
			cmp.b   	maxbank,d1
			bgt 		.badnum
			lea 		bankflg,a1
			subq.l  	#1,a1
			tst.b   	0(a1,d1.w)
			bne 		.use4
			move.l  	#24,x3  			; error if bank doesn't exist
			jsr 		branch2
.use4   	move.b  	d1,x1
			jsr 		usebank
			tst.b   	y1  			 ; all ok?
			bne 		.diskerr
			move.b  	d1,lastbank 	; update most recently selected bank
			bsr 		checkwb
			bra 		.return 			; restore registers,x1-x5,return

.scratch	tst.b   	nbanks
			bne 		.scratch2   		; if no banks on disk: error
			move.l  	#22,x3
			jsr 		branch1
.scratch2   lea 		.scratch3,a6		  ; loop back if bad #
.scratch3   moveq   	#6,d7
			jsr 		branch9 			; get #
			jsr 		value
			move.l  	y1,d1   			; d1.l = #
			ble 		.badnum
			cmp.l   	#$7F,d1 			; bad # if #<1 or >maxbank
			bgt 		.badnum
			cmp.b   	maxbank,d1
			bgt 		.badnum
			lea 		bankflg,a1
			subq.l  	#1,a1
			tst.b   	0(a1,d1.w)
			bne 		.scratch4
			move.l  	#24,x3  			; error if bank doesn't exist
			jsr 		branch2
.scratch4   move.b  	d1,x1
			jsr 		scrbank
			jsr 		writinfo
			cmp.b   	lastbank,d1
			bne 		.return
			clr.b   	lastbank	 ; you just scratched your most recent
			bra 		.return 			; restore registers,x1-x5,return

.list   	tst.b   	nbanks
			bne 		.list2  			; if no banks on disk: error
			move.l  	#22,x3
			jsr 		branch1
.list2  	lea 		.list3,a6   	   ; loop back if bad #
.list3  	moveq   	#6,d7
			jsr 		branch9 			; get #
			jsr 		value
			move.l  	y1,d1   			; d1.l = #
			ble 		.badnum
			cmp.l   	#$7F,d1 			; bad # if #<1 or >maxbank
			bgt 		.badnum
			cmp.b   	maxbank,d1
			bgt 		.badnum
			lea 		bankflg,a1
			subq.l  	#1,a1
			tst.b   	0(a1,d1.w)
			bne 		.list4
			move.l  	#24,x3  			; error if bank doesn't exist
			jsr 		branch2
.list4  	move.b  	d1,x1
			jsr 		listbnk
			jsr 		branch13			; restore registers,x1-x5,return

.rename 	tst.b   	nbanks
			bne 		.rename2			; if no banks on disk: error
			move.l  	#22,x3
			jsr 		branch1
.rename2	lea 		.rename3,a6 		 ; loop back if bad #
.rename3	moveq   	#6,d7
			jsr 		branch9 			; get #
			jsr 		value
			move.l  	y1,d1   			; d1.l = #
			ble 		.badnum
			cmp.l   	#$7F,d1 			; bad # if #<1 or >maxbank
			bgt 		.badnum
			cmp.b   	maxbank,d1
			bgt 		.badnum
			lea 		bankflg,a1
			subq.l  	#1,a1
			tst.b   	0(a1,d1.w)
			bne 		.nameloop
			move.l  	#24,x3  			; error if bank doesn't exist
			jsr 		branch2

.execwb 	move.l  	d6,x1
			jsr 		creturn
			move.l  	#38,x1
			jsr 		getabc  		; with,without,only f-pars?
			move.b  	y1,x1
			jsr 		execbnk 			; execute w.b.
			jsr 		branch13			; re-init screen, return

.ftowb  	jsr 		readbftx
			tst.b   	y1  		 ; all ok?
			bne 		synerr
			jsr 		synftowb
			bsr 		checkwb
			bra 		.returnx

.ftosyn 	lea 		.ftosyn2,a6 		; loop back if bad #
.ftosyn2	moveq   	#23,d7
			jsr 		branch9 			; get #
			jsr 		value
			move.l  	y1,d1   			; d1.l = #
			ble 		.badnum
			cmp.l   	#$7F,d1 			; bad # if #<1 or >maxbank
			bgt 		.badnum
			cmp.b   	#7,d1
			bgt 		.badnum
			move.b  	d1,txatten
			jsr 		wbftosyn
			jsr 		writbftx
			bra 		.returnx

.btosyn 	tst.b   	nbanks
			bne 		.btosyn2			; if no banks on disk: error
			move.l  	#22,x3
			jsr 		branch1
.btosyn2	lea 		.btosyn3,a6 		 ; loop back if bad #
.btosyn3	moveq   	#6,d7
			jsr 		branch9 			; get #
			jsr 		value
			move.l  	y1,d1   			; d1.l = #
			ble 		.badnum
			cmp.l   	#$7F,d1 			; bad # if #<1 or >maxbank
			bgt 		.badnum
			cmp.b   	maxbank,d1
			bgt 		.badnum
			lea 		bankflg,a1
			subq.l  	#1,a1
			tst.b   	0(a1,d1.w)
			bne 		.btosyn4
			move.l  	#24,x3  			; error if bank doesn't exist
			jsr 		branch2
.btosyn4	move.b  	d1,x1
			jsr 		usebank
			tst.b   	y1  			 ; all ok?
			bne 		.diskerr
			move.b  	d1,lastbank
			lea 		.btosyn5,a6 		; loop back if bad #
.btosyn5	moveq   	#23,d7
			jsr 		branch9 			; get #
			jsr 		value
			move.l  	y1,d1   			; d1.l = #
			ble 		.badnum
			cmp.l   	#$7F,d1
			bgt 		.badnum
			cmp.b   	#7,d1
			bgt 		.badnum
			move.b  	d1,txatten
			bsr 		checkwb
			jsr 		gobank  			; copy w.b. to synbuf
			jsr 		writbdx7			; write synbuf to synth
			jsr 		wbftosyn
			jsr 		writbftx
			bra 		.return 			; restore registers,x1-x5,return

; local routine to call checkws for each w.b. slot

checkwb 	move.l  	#wkbank,x1
			move.b  	#32,d1  	; for d1.b = 32 to 1
.chloop 	jsr 		checkws
			add.l   	#160,x1
			subq.b  	#1,d1
			bgt 		.chloop
			rts

; common code to process y1.b <> 0 passed back from readbdx7 or readbftx
synerr  	move.b  	y1,d1   		; protect y1
			move.l  	d6,x1
			jsr 		creturn
			move.l  	#messss,x1
			move.b  	#1,x2
			move.b  	cursory,x3
			move.b  	cmessge,x4
			lea 		messsl,a0
			cmpi.b  	#1,d1
			bne 		synerr2
			add.l   	#600,x1 		; time-out error
			move.b  	15(a0),x5
			bra 		synerrx

synerr2 	add.l   	#1360,x1		; format error
			move.b  	34(a0),x5

synerrx 	jsr 		message
			bra 		.returnx

; branch to jump to diskerr routine

.diskerr	jmp 		diskerr
