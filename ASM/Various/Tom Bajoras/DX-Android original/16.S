;*****************************************************************************;
;   module 16  source file    Copyright 1986 Tom Bajoras
;      initdsc
;*****************************************************************************;

 .text

;*****************************************************************************;
;   initdsc
;      no entry conditions
;      y1.b = 0 ok, =1 failed
;*****************************************************************************;

 .global initdsc

initdsc 	movem.l 	#$FFFE,-(a7)	; save registers
			move.l  	x1,-(a7)		; and x1-x5
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)

.bigloop	jsr 		blnkscr 		; start by blanking screen
			move.b  	#10,x1  		; change colors
			jsr 		setcolor

			clr.w   	d4  	 ; color components
			clr.w   	d5
			move.w  	#7,d6

			move.l  	#messss,x1  	; heading
			add.l   	#1920,x1
			lea 		messsl,a0
			move.b  	48(a0),x5
			move.b  	xmax,d0
			sub.b   	48(a0),d0
			lsr.b   	#1,d0
			move.b  	d0,x2
			move.b  	#1,x3
			move.b  	cmenhed,x4
			jsr 		message
			move.l  	#messss,x1  	; heading
			add.l   	#1960,x1
			lea 		messsl,a0
			move.b  	49(a0),x5
			move.b  	#3,x3
			move.b  	cprompt,x4  	; please wait
			jsr 		message

			move.w  	#240,x1
			move.w  	#60,x2
			move.w  	#399,x3
			move.w  	#60,x4
			move.b  	coutlne,x5
			jsr 		line				; draw box (in 4 parts)
			move.w  	x3,x1
			move.w  	x4,x2
			move.w  	#399,x3
			move.w  	#139,x4
			jsr 		line
			move.w  	x3,x1
			move.w  	x4,x2
			move.w  	#240,x3
			move.w  	#139,x4
			jsr 		line
			move.w  	x3,x1
			move.w  	x4,x2
			move.w  	#240,x3
			move.w  	#60,x4
			jsr 		line

			move.w  	#240,x1
			move.w  	#60,x2
			move.w  	#399,x3
			move.w  	#60,x4  		; prepare to fill box
			move.b  	cmessge,x5

			clr.w   	d7  				; d7.w = track # = 0 to 79
.loop   	move.w  	#$E5E5,-(a7)		; virgin
			move.l  	#$87654321,-(a7)	; magic
			move.w  	#1,-(a7)			; interleave
			clr.w   	-(a7)   			; side # (A)
			move.w  	d7,-(a7)			; track #
			move.w  	#9,-(a7)			; sectors per track
			move.w  	currdrv,-(a7)   	; drive #
			clr.l   	-(a7)   			; filler
			move.l  	#diskbuf,-(a7)  	; buffer
			move.w  	#10,-(a7)   		; function # 10
			trap		#14 				; do it
			add.l   	#26,a7
			tst.l   	d0  				; worked?
			bne 		.error
			tst.w   	diskbuf 			; bad sector?
			bne 		.badsect

			tst.w   	d4  				; shift color
			bne 		.3
			cmpi.w  	#$70,d5
			beq 		.2
			cmpi.w  	#7,d6
			bne 		.2
			add.w   	#$10,d5
			bra 		.x

.2  		tst.w   	d6
			beq 		.3
			subq.w  	#1,d6
			bra 		.x

.3  		cmpi.w  	#$700,d4
			beq 		.4
			cmpi.w  	#$70,d5
			bne 		.6
			tst.w   	d6
			bne 		.6
			add.w   	#$100,d4
			bra 		.x

.4  		tst.w   	d5
			beq 		.5
			tst.w   	d6
			bne 		.5
			sub.w   	#$10,d5
			bra 		.x

.5  		tst.w   	d5
			bne 		.6
			cmpi.w  	#7,d6
			beq 		.6
			addq.w  	#1,d6
			bra 		.x

.6  		sub.w   	#$100,d4

.x  		move.w  	d4,d3
			add.w   	d5,d3
			add.w   	d6,d3

			move.w  	d3,-(a7)
			move.w  	#1,-(a7)
			move.w  	#7,-(a7)
			trap		#14
			addq.l  	#6,a7

			jsr 		line			; fill box: 1 line for each track
			addq.w  	#1,x2
			addq.w  	#1,x4

			addq.w  	#1,d7
			cmpi.w  	#80,d7  			; done?
			bne 		.loop

			lea 		diskbuf,a0  	; zero-out bootsector
			move.b  	#128,d0
.zero1  	clr.l   	(a0)+
			subq.b  	#1,d0
			bne 		.zero1

			clr.w   	-(a7)   	 ; create a boot sector
			move.w  	#2,-(a7)
			move.l  	#$1000000,-(a7)
			move.l  	#diskbuf,-(a7)
			move.w  	#18,-(a7)
			trap		#14
			add.l   	#14,a7

			move.w  	#1,-(a7)
			clr.w   	-(a7)
			clr.w   	-(a7)
			move.w  	#1,-(a7)
			move.w  	currdrv,-(a7)
			clr.l   	-(a7)
			move.l  	#diskbuf,-(a7)
			move.w  	#9,-(a7)
			trap		#14 		; write boot sector
			add.l   	#20,a7
			tst.l   	d0
			bne 		.error

			lea 		diskbuf,a0  	; zero-out sector again
			move.b  	#128,d0
.zero2  	clr.l   	(a0)+
			subq.b  	#1,d0
			bne 		.zero2
;  create pseudo-directory:
			move.l  	#dxmess1,x1
			addq.l  	#1,x1
			move.l  	#diskbuf,x2
			move.b  	dxmess1,x3
			jsr 		movemem
			move.l  	#dxmess2,x1
			addq.l  	#1,x1
			add.l   	#32,x2
			move.b  	dxmess2,x3
			jsr 		movemem
			move.l  	#dxmess3,x1
			addq.l  	#1,x1
			add.l   	#32,x2
			move.b  	dxmess3,x3
			jsr 		movemem

			move.w  	#1,-(a7)
			clr.w   	-(a7)
			move.w  	#1,-(a7)
			move.w  	#3,-(a7)
			move.w  	currdrv,-(a7)
			clr.l   	-(a7)
			move.l  	#diskbuf,-(a7)
			move.w  	#9,-(a7)
			trap		#14 		; write pseudo-directory
			add.l   	#20,a7
			tst.l   	d0
			bne 		.error

			clr.w   	nfiles  	 ; default info tables
			clr.w   	nfillok
			clr.w   	nfilind
			clr.b   	nbanks
			lea 		fileflg,a0
			lea 		indflg,a1
			lea 		fillock,a2
			lea 		revtabl,a3
			clr.w   	d7
.loop2  	clr.b   	0(a0,d7.w)
			clr.b   	0(a1,d7.w)
			clr.b   	0(a2,d7.w)
			clr.b   	0(a3,d7.w)
			addq.w  	#1,d7
			cmp.w   	maxfile,d7
			bne 		.loop2

			lea 		bankflg,a0
			lea 		bnamflg,a1
			clr.w   	d7
.loop3  	clr.b   	0(a0,d7.w)
			clr.b   	0(a1,d7.w)
			addq.w  	#1,d7
			cmp.b   	maxbank,d7
			bne 		.loop3

			clr.l   	d7
			move.w  	maxfile,d7
			mulu		#10,d7
			lea 		filenam,a0
.loop4  	clr.b   	(a0)+
			subq.w  	#1,d7
			bne 		.loop4

			clr.l   	d7
			move.b  	maxbank,d7
			mulu		#10,d7
			lea 		banknam,a0
.loop5  	clr.b   	(a0)+
			subq.w  	#1,d7
			bne 		.loop5

			clr.l   	d7
			move.b  	maxbank,d7
			mulu		#320,d7
			lea 		bslotnm,a0
.loop6  	clr.b   	(a0)+
			subq.w  	#1,d7
			bne 		.loop6

;   now write all this to disk: (and set y1)
			jsr 		writinfo

			bra 		.return
.error  	move.l  	#10,d7  	; d7.l= 10 means disk drive error
			bra 		.errorx
.badsect	move.l  	#42,d7  	; d7.l= 42 means bad sector(s) found
.errorx 	move.b  	#3,x1
			jsr 		blnkln  		; get rid of "please wait"
			move.w  	#$0777,-(a7)	; restore white in color register 1
			move.w  	#1,-(a7)
			move.w  	#7,-(a7)
			trap		#14
			addq.l  	#6,a7
			move.w  	#240,x1
			move.w  	#60,x2
			move.w  	#399,x3
			move.w  	#139,x4
			move.b  	coutlne,x5
			jsr 		line			; put an "X" through rectangle
			move.w  	#399,x1
			move.w  	#60,x2
			move.w  	#240,x3
			move.w  	#139,x4
			jsr 		line
			move.l  	#messss,x1
			move.l  	d7,d0
			mulu		#40,d0
			add.l   	d0,x1   		; error message
			move.b  	#1,x2
			move.b  	ymax,x3
			subq.b  	#1,x3
			move.b  	cmessge,x4
			lea 		messsl,a0
			move.b  	0(a0,d7.l),x5
			jsr 		message
			move.l  	#messss,x1
			add.l   	#1720,x1
			addq.b  	#1,x3
			move.b  	cprompt,x4
			move.b  	43(a0),x5   	; "Try again? (y/n)
			jsr 		message
.keyloop	jsr 		getkey
			move.b  	y1,d0
			cmp.b   	asciy,d0
			beq 		.bigloop
			cmp.b   	ascin,d0
			beq 		.no
			jsr 		bell
			bra 		.keyloop
.no 		move.b  	#1,y1
.return 	move.w  	#$0777,-(a7)	; restore white in color register 1
			move.w  	#1,-(a7)
			move.w  	#7,-(a7)
			trap		#14
			addq.l  	#6,a7
			move.l  	(a7)+,x5
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1			; restore x5-x1
			movem.l 	(a7)+,#$7FFF		; restore registers
			rts 							; return

;*****************************************************************************;
;   initpri6 -- part of primary initialization daisy chain
;   			set up menuaddr array
;*****************************************************************************;

 .global initpri6

initpri6:
			lea 		menuaddr,a0 	; set up menuaddr array:
			move.l  	#menu1,(a0)+	; menuaddr(0) --> main menu items
			move.l  	#menu2,(a0)+	; menuaddr(1) --> edit menu items
			move.l  	#menu3,(a0)+	; menuaddr(2) --> index menu items
			move.l  	#menu4,(a0)+	; menuaddr(3) --> catalog menu items
			move.l  	#menu5,(a0)+	; menuaddr(4) --> bank menu items
			move.l  	#menu6,(a0)+	; menuaddr(5) --> utility menu items
			move.l  	#menu7,(a0)+	; menuaddr(6) --> edit bank menu items
			move.l  	#menu8,(a0) 	; menuaddr(7) --> droid menu items

; chain on to next link
			jsr 		initpri7
			rts
