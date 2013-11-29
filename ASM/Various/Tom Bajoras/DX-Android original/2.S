;*****************************************************************************;
;   module 2 source file	Copyright 1986 Tom Bajoras
;   menu processing routines:
;   initscr,prtmenu,getmenu,disbank,redisbnk,findmen,disbnm,redisbnm
;*****************************************************************************;

 .text

;*****************************************************************************;
;   initscr
;      x1.l = menux , x2.l = recentx (-1 for no recentx)
;*****************************************************************************;

 .global initscr

initscr 	movem.l 	#$FFFE,-(a7)  ; save registers and x1-x5
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)
			move.l  	x1,d0   			; d0.l = menux
			move.l  	x2,d7   			; d7.l = recentx

			jsr 		blnkscr 			; blank screen
			clr.b   	x1  				; (re)set colors
			jsr 		setcolor
			bsr 		prtmenu 			; call prtmenu(menux,recentx)
			lea 		lastmenu,a1
			move.b  	d7,0(a1,d0.l)   	; store recentx

			lea 		nmline,a1   	; 1st line is drawn 3 pixels below
			move.b  	0(a1,d0.l),d1   ; bottom edge of menu area
			andi.l  	#$FF,d1
			lsl.l   	#3,d1
			addq.l  	#3,d1
			move.w  	d1,x2
			move.w  	d1,x4
			clr.w   	x1  		  ; draw line from one end of screen
			move.w  	#639,x3 	  ; to the other
			move.b  	coutlne,x5
			jsr 		line

			cmpi.l  	#4,d0   	; bank menu?
			bne 		.notbank
			bsr 		disbnm  	; display bank names
			add.w   	#56,x2  	; y-positions for 2nd line
			add.w   	#56,x4
			bra 		.2ndline
.notbank	cmpi.l  	#6,d0   	; edit-wb menu?
			bne 		.notedbk
			bsr 		disbank 	; display w.b. slot names
			add.w   	#72,x2  	; y-positions for 2nd line
			add.w   	#72,x4
			bra 		.2ndline
.notedbk	cmpi.l  	#7,d0   	; droid menu has no info area
			beq 		.skip
			move.l  	d0,x1
			jsr 		infobar 	; put up info bar
			add.w   	#24,x2
			add.w   	#24,x4
			cmpi.l  	#5,d0   	; utility menu?
			bne 		.2ndline
			addq.w  	#8,x2
			addq.w  	#8,x4
.2ndline	jsr 		line			; draw 2nd divider line

.skip   	lea 		ncline,a0
			move.b  	ymax,d1
			sub.b   	0(a0,d0.l),d1   	; initialize cursor
			move.b  	d1,cursory

			move.l  	#versmess,x1		; put up bottom line on screen
			move.b  	#1,x2
			move.b  	ymax,x3
			move.b  	cmessge,x4
			lea 		versmesl,a0
			move.b  	(a0),x5
			jsr 		message
			add.l   	#40,x1
			move.b  	xmax,d0
			sub.b   	1(a0),d0
			lsr.b   	#1,d0
			addq.b  	#1,d0
			move.b  	d0,x2
			move.b  	1(a0),x5
			jsr 		message
			add.l   	#40,x1
			move.b  	xmax,d0
			sub.b   	2(a0),d0
			move.b  	d0,x2
			addq.b  	#1,x2
			move.b  	2(a0),x5
			jsr 		message

			move.l  	(a7)+,x5
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1		; restore x5-x1
			movem.l 	(a7)+,#$7FFF  ; restore registers and return
			rts

;*****************************************************************************;
;   prtmenu
;      x1 = menux 0-6 (l) , x2 = recentx -1,0-19 (l)
;*****************************************************************************;

 .global prtmenu

prtmenu 	movem.l 	#$FFFE,-(a7)	; save registers and x1-x5
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)

; set up register variables:
			move.l  	x1,d6   	  ; d6.l = menux
			move.l  	x2,d7   	  ; d7.l = recentx (-1 for no recentx)

			move.l  	#menuhed,x1
			lea 		menuhedl,a1
			lea 		menuflg,a0
			move.b  	#1,x3
			move.b  	#5,x2
			clr.l   	d0  			; for d0.l = 0 to 9
.loop1  	tst.b   	0(a0,d0.l)
			beq 		.skipit
			cmp.l   	d0,d6
			beq 		.thismenu
			move.b  	cmenu,x4
			bra 		.doit
.thismenu   move.b  	ccurmen,x4
			move.b  	#1,forceinv
.doit   	move.b  	0(a1,d0.l),x5
			jsr 		message
			clr.b   	forceinv
.skipit 	add.l   	#20,x1
			cmpi.b  	#1,x3
			beq 		.goto2
			move.b  	#1,x3
			add.b   	#16,x2
			bra 		.next
.goto2  	move.b  	#2,x3
.next   	addq.b  	#1,d0
			cmpi.b  	#9,d0
			ble 		.loop1

; line
			clr.w   	x1
			move.w  	#639,x3
			move.w  	#19,x2
			move.w  	#19,x4
			move.b  	coutlne,x5
			jsr 		line

; set up more register variables:
			lea 		menulen,a6
			move.l  	d6,d0
			mulu		#20,d0
			adda.l  	d0,a6   		; a6 --> menu item lengths
			move.l  	d6,d0
			mulu		#4,d0
			lea 		menuaddr,a0
			movea.l 	0(a0,d0.l),a5   ; a5 --> menu items
			lea 		nmenu,a3	  ; a3 --> # menu items - 1

			clr.l   	d1  			; for d1.l = 0 to nmenu
.loop2  	move.l  	d1,x1
			move.l  	d6,x2
			bsr 		findmen 		;  get coords of menu item
			move.b  	y1,x2
			move.b  	y2,x3
			move.l  	a5,x1
			cmp.l   	d7,d1
			bne 		.notrec
			move.b  	#1,forceinv
			move.b  	ccurmen,x4
			bra 		.printit
.notrec 	move.b  	cmenu,x4
.printit	move.b  	0(a6,d1.l),x5
			jsr 		message 	  ; print menu item
			clr.b   	forceinv
			adda.l  	#20,a5  	  ; point to next menu item
			addq.b  	#1,d1
			cmp.b   	0(a3,d6.l),d1
			ble 		.loop2

			move.l  	(a7)+,x5	; restore x1-x5
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1
			movem.l 	(a7)+,#$7FFF		; restore registers
			rts 							; and return

;*****************************************************************************;
;   getmenu
;      x1.l = menux , y1.l = itemx for function key code
;*****************************************************************************;

 .global getmenu

getmenu 	movem.l 	#$FFFE,-(a7)  ;  save registers and x1-x5
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)

;   set up register variables
			move.l  	x1,d7   		; d7.l = menux
			lea 		nmenu,a6		; a6 --> nmenu
			lea 		menufmt,a5  	; a5 --> # columns
			lea 		nmline,a0
			move.b  	0(a0,d7.l),d6
			subq.b  	#3,d6   		; d6.b = # rows
			lea 		nmencol1,a0
			move.b  	0(a0,d7.l),d5
			addq.b  	#1,d5   		; d5.b = # in 1st column
			lea 		nmencol2,a1
			move.b  	0(a1,d7.l),d4
			sub.b   	0(a0,d7.l),d4   ; d4.b = # in 2nd column
			move.b  	0(a6,d7.l),d3
			sub.b   	0(a1,d7.l),d3   ; d3.b = # in 3rd column
			lea 		lastmenu,a0
			clr.l   	d2
			move.b  	0(a0,d7.l),d2   ; init mouse position
			bge 		.restart
			moveq   	#0,d2   		; mouse defaults to itemx=0

.restart	move.l  	d7,x1
			jsr 		creturn 	  ;  move cursor to start of next line
			move.l  	#menuprp,x1
			move.b  	#1,x2
			move.b  	cursory,x3
			move.b  	cprompt,x4
			move.b  	mprlen,x5
			jsr 		message 	; write "select from"
			move.b  	x5,d0
			add.b   	d0,x2
			addq.b  	#1,x2
			move.l  	#menuphed,x1
			move.l  	d7,d0
			mulu		#16,d0
			add.l   	d0,x1
			lea 		mhedlen,a0
			move.b  	0(a0,d7.l),x5
			jsr 		message 		; append menu heading
			move.l  	#menuprp,x1
			add.l   	#31,x1
			move.b  	x5,d0
			add.b   	d0,x2
			lea 		mprlen,a0
			move.b  	1(a0),x5
			jsr 		message 		; append "function key to..."

			movem.l 	#$FFFE,-(a7)
			move.l  	#setmous,-(a7)  ; enable mouse
			move.w  	#3,-(a7)
			move.w  	#25,-(a7)
			trap		#14
			move.l  	#24,d0
			jsr 		getlong 		; d0.l = 8 (hopefully)
			add.l   	d0,a7
			movem.l 	(a7)+,#$7FFF
			move.b  	#1,allowms
			bra 		.cursloop
setmous 	.byte   	10,39,7,4

.cursloop   move.l  	d2,x1
			move.l  	d7,x2
			bsr 		findmen
			move.b  	#3,x1
			move.b  	y1,x2
			subq.b  	#2,x2
			move.b  	y2,x3
			move.b  	cprompt,x4
			jsr 		outchar 		; put up mouse

.keyloop	jsr 		getkey  	  ;  wait for a key
			move.b  	y1,d1   	  ;  d1.b = key
			cmp.b   	ascif10,d1
			beq 		.exit
			cmp.b   	ascif1,d1
			blt 		.notf
			cmp.b   	ascif10,d1
			ble 		.function
.notf   	cmp.b   	ascilef,d1
			beq 		.left
			cmp.b   	ascirit,d1
			beq 		.right
			cmp.b   	asciup,d1
			beq 		.up
			cmp.b   	ascidwn,d1
			beq 		.down
			cmp.b   	ascimlef,d1
			beq 		.select
			cmp.b   	ascimrit,d1
			beq 		.select
			cmp.b   	ascisp,d1
			beq 		.select

.badkey 	jsr 		bell				; illegal key
			bra 		.keyloop

.function   sub.b   	ascif1,d1     ;    d1 = menux of the requested menu
			andi.l  	#$FF,d1 	  ;    if reqested menux = current menux
			lea 		menuflg,a0
			tst.b   	0(a0,d1.l)
			beq 		.badkey    ; illegal key if requested menu is inactive
			cmp.b   	d1,d7   	  ;    clean up scrolling area
			bne 		.notsame
			move.l  	d7,x1
			lea 		lastmenu,a0
			clr.l   	d0
			move.b  	0(a0,d7.l),d0
			move.l  	d0,x2
			bsr 		initscr
			bra 		.restart
.notsame	cmpi.l  	#1,d7   	  ;    if (leaving edit menu) then
			bne 		.nomonws
			lea 		wkspace,a0    ;   compare edspace and wkspace
			lea 		edspace,a1
			move.w  	#159,d0
.cmpwsed	cmpm.b  	(a0)+,(a1)+
			bne 		.ask
			subq.w  	#1,d0
			bne 		.cmpwsed
			bra 		.skipask	 ; they are identical, so don't ask
.ask		jsr 		unpromp 	  ;    change menu prompt to color cmessge
			movem.l 	#$FFFE,-(a7)
			move.l  	#remouse,-(a7)  ; disable mouse
			move.w  	#2,-(a7)
			move.w  	#25,-(a7)
			trap		#14
			move.l  	#24,d0
			jsr 		getlong 		; d0.l = 8 (hopefully)
			add.l   	d0,a7
			movem.l 	(a7)+,#$7FFF
			clr.b   	allowms
			move.l  	d7,x1
			jsr 		creturn 	  ;    move cursor to start of next line
			move.l  	#-1,x1
			move.l  	#23,x2
			jsr 		getyn   	  ; 'save editing? (y/n)'
			tst.b   	y1
			beq 		.skipask	  ; no: don't save editing
			jsr 		edtows  	  ; yes: save editing
.skipask	tst.b   	monws   	  ; if leaving edit menu, send w.s. to
			beq 		.nomonws		; dx7 (if monws=1)
			jsr 		wstosyn
			jsr 		writdx7
			move.l  	#wkspace,x1
			add.l   	#145,x1
			jsr 		writfdx7
.nomonws	addi.l  	#100,d1 	  ;  return y1 = 100 + menux of the
			move.l  	d1,y1   	  ;  the requested menu
			bra 		.return

.left   	cmpi.b  	#1,0(a5,d7.l)   ; can't if only 1 column
			beq 		.keyloop
			cmp.b   	d5,d2   		; can't if currently in 1st column
			blt 		.keyloop
			bsr 		unmouse
			sub.b   	d5,d2
			bra 		.cursloop

.right  	cmpi.b  	#1,0(a5,d7.l)   ; can't if only 1 column
			beq 		.keyloop
			cmp.b   	#3,0(a5,d7.l)
			beq 		.right3
			cmp.b   	d5,d2   		; can't if in 2nd of 2 columns
			bge 		.keyloop
.right2 	move.b  	d2,d0   		; temporary mousex
			add.b   	d5,d0
			cmp.b   	0(a6,d7.l),d0
			bgt 		.keyloop		; forbidden zone violation
			bsr 		unmouse
			add.b   	d5,d2
			bra 		.cursloop
.right3 	lea 		nmencol2,a0
			cmp.b   	0(a0,d7.l),d2
			bgt 		.keyloop		; can't if in 3rd of 3 columns
			cmp.b   	d5,d2
			blt 		.right2 		; in 1st of 3 columns
			move.b  	d2,d0   		; temporary mousex
			add.b   	d4,d0   		; in 2nd of 3 columns
			cmp.b   	0(a6,d7.l),d0
			bgt 		.keyloop
			bsr 		unmouse
			add.b   	d4,d2
			bra 		.cursloop

.up 		cmp.b   	#1,d6   		; can't if only 1 row
			beq 		.keyloop
			tst.b   	d2  		 ; can't if at top of 1st row
			beq 		.keyloop
			cmp.b   	#1,0(a5,d7.l)
			beq 		.upx
			cmp.b   	d5,d2
			beq 		.keyloop
			cmp.b   	#2,0(a5,d7.l)
			beq 		.upx
			lea 		nmencol2,a0
			move.b  	0(a0,d7.l),d0
			addq.b  	#1,d0
			cmp.b   	d0,d2
			beq 		.keyloop
.upx		bsr 		unmouse
			subq.b  	#1,d2
			bra 		.cursloop

.down   	cmp.b   	#1,d6   		; can't if only 1 row
			beq 		.keyloop
			lea 		nmencol1,a0
			cmp.b   	0(a0,d7.l),d2
			beq 		.keyloop		; can't if at bottom of any row
			cmp.b   	#1,0(a5,d7.l)
			beq 		.downx
			lea 		nmencol2,a0
			cmp.b   	0(a0,d7.l),d2
			beq 		.keyloop
			cmp.b   	#2,0(a5,d7.l)
			beq 		.downx
			cmp.b   	0(a6,d7.l),d2
			beq 		.keyloop
.downx  	bsr 		unmouse
			addq.b  	#1,d2
			bra 		.cursloop

.exit   	jsr 		unpromp 	  ;    change menu prompt to color cmessge
			movem.l 	#$FFFE,-(a7)
			move.l  	#remouse,-(a7)  ; disable mouse
			move.w  	#2,-(a7)
			move.w  	#25,-(a7)
			trap		#14
			move.l  	#24,d0
			jsr 		getlong 		; d0.l = 8 (hopefully)
			add.l   	d0,a7
			movem.l 	(a7)+,#$7FFF
			clr.b   	allowms
			bra 		.exitx
remouse 	.byte   	18,8,0
.exitx  	move.l  	d7,x1
			jsr 		f10proc 	  ;    try to exit
			bra 		.restart	  ;    if failed/aborted, get another key

.select 	lea 		menuaddr,a0
			move.l  	d7,d0
			lsl.l   	#2,d0
			move.l  	0(a0,d0.l),a0   ; a0 --> items for this menu
			lea 		menulen,a2
			move.l  	d7,d0
			mulu		#20,d0
			add.l   	d0,a2   		; a2 --> menu lengths

			lea 		lastmenu,a1
			clr.l   	d1
			move.b  	0(a1,d7.l),d1    ; d1.l = recentx for this menu
			blt 		.skipech		 ; skip un-echo if no recentx
			move.l  	d1,x1
			move.l  	d7,x2
			bsr 		findmen
			move.b  	y1,x2
			move.b  	y2,x3
			move.l  	a0,x1
			move.l  	d1,d0
			mulu		#20,d0
			add.l   	d0,x1
			move.b  	cmenu,x4
			move.b  	0(a2,d1.l),x5
			jsr 		message 	  ; unecho recent
.skipech	move.b  	d2,0(a1,d7.l)   	; mousex becomes new recentx
			move.l  	d2,x1
			move.l  	d7,x2
			bsr 		findmen
			move.b  	y1,x2
			move.b  	y2,x3
			move.l  	a0,x1
			move.l  	d2,d0
			mulu		#20,d0
			add.l   	d0,x1
			move.b  	ccurmen,x4
			move.b  	#1,forceinv
			move.b  	0(a2,d2.l),x5
			jsr 		message 	; echo new recent
			clr.b   	forceinv
			jsr 		unpromp 	  ;  change menu prompt to color cmessge

			move.b  	ascisp,d0
			move.b  	xmax,x1
			move.b  	cursory,x2    ;  search for end of menu prompt
.echloop	jsr 		getchar
			cmp.b   	y1,d0
			beq 		.next
			tst.b   	y1
			bne 		.found
.next   	subq.b  	#1,x1
			bne 		.echloop
			bra 		.nofind
.found  	move.b  	x1,x2
			addq.b  	#2,x2   	; x-coord for echo
			move.b  	cursory,x3  ; y-coord for echo
			move.b  	ccurmen,x4  ; color for echo
			move.l  	a0,x1   	; --> selected item
			move.l  	d2,d0
			mulu		#20,d0
			add.l   	d0,x1
			move.b  	0(a2,d2.l),x5   ; length of selected item
			jsr 		message

.nofind 	move.l  	d2,y1   	; pass back selection

.return 	move.l  	#remouse,-(a7)  ; disable mouse
			move.w  	#2,-(a7)
			move.w  	#25,-(a7)
			trap		#14
			move.l  	#24,d0
			jsr 		getlong 		; d0.l = 8 (hopefully)
			add.l   	d0,a7
			clr.b   	allowms
			move.l  	(a7)+,x5	  ; restore x1-x5
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1
			movem.l 	(a7)+,#$7FFF	 ; restore registers and return
			rts

unmouse 	move.l  	d2,x1
			move.l  	d7,x2
			bsr 		findmen
			move.b  	y1,x2
			subq.b  	#2,x2
			move.b  	y2,x3
			move.b  	ascisp,x1
			move.b  	cbakgnd,x4
			jsr 		outchar
			rts

;*****************************************************************************;
;   disbank
;      no entry conditions , no exit conditions
;*****************************************************************************;

 .global disbank

disbank 	move.l  	x1,-(a7)			; save x1

			clr.l   	x1  				; for x.l = 0 to 31
.loop   	bsr 		redisbnk
			add.l   	#1,x1
			cmpi.l  	#31,x1
			ble 		.loop

			move.l  	(a7)+,x1			; restore x1
			rts 							; and return

;*****************************************************************************;
;   disbnm
;      no entry conditions , no exit conditions
;*****************************************************************************;

 .global disbnm

disbnm  	move.l  	d0,-(a7)		; save d0
			move.l  	x1,-(a7)		; and x1

			move.b  	maxbank,d0
			move.b  	#1,x1   			; for x.b = 1 to maxbank
disbnm2 	bsr 		redisbnm
			addq.b  	#1,x1
			cmp.b   	x1,d0
			bge 		disbnm2

			move.l  	(a7)+,x1			; restore x1
			move.l  	(a7)+,d0			; and d0
			rts 							; and return

;*****************************************************************************;
;   redisbnk
;      x1 = slotx 0-31 (l)
;*****************************************************************************;

 .global redisbnk

redisbnk	movem.l 	#$FFFE,-(a7)		; save registers
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)

			move.l  	x1,d1
			move.l  	x1,d0   		; d0 = slotx 0-31 (l)
			mulu		#10,d1
			lea 		wkbname,a0
			adda.l  	d1,a0   		; a0 --> w.b. slot name
			move.l  	a0,x1   		; x1 --> w.b. slot name

			move.l  	d0,d1   		; d1= slotx = 0-31 (l)
			lsr.l   	#3,d1   		; d1 = 0,1,2,3 (l)
			lea 		wkbnx,a1
			move.b  	0(a1,d1.l),d2   ; d2 = x-coord
			move.b  	d2,x2
			lsl.l   	#3,d1   		; d1 = 0,8,16,24 (l)
			move.l  	d0,d2   		; d2 = 0-31 (l)
			sub.l   	d1,d2   		; d2 = 0-7 (l)
			lea 		nmline,a2
			move.b  	6(a2),d3		; d3 = # lines in editbank menu
			addq.b  	#2,d3
			add.b   	d2,d3   		; d3 = y-coord
			move.b  	d3,x3

			move.b  	cmenu,d3		; w.b. area is in color cmenu
			move.b  	d3,x4

			move.b  	#10,x5  		; w.b. slot name is 10 chars long
			jsr 		message 		; write w.b. slot name

			lea 		bankkey,a2
			move.b  	0(a2,d0.l),d1   ; d1 = bankkey for this slot
			move.b  	d1,x1
			sub.b   	#7,x2
			move.b  	cmenkey,x4
			jsr 		outchar 		; write bankkey just to left of name

			move.l  	#bankkeyn,x1
			mulu		#5,d0
			add.l   	d0,x1   		; --> numeric bankkey for this slot
			addq.b  	#2,x2
			move.b  	#4,x5
			jsr 		message

			move.l  	(a7)+,x5		; restore x1-x5
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1
			movem.l 	(a7)+,#$7FFF		; restore registers
			rts 							; and return

;*****************************************************************************;
;   redisbnm
;      x1.b = bankx (1-maxbank)
;*****************************************************************************;

 .global redisbnm

redisbnm	movem.l 	#$FFFE,-(a7)		; save registers
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)

			clr.l   	d0
			move.b  	x1,d0
			subq.b  	#1,d0   		; d0.l = bankx-1 (0 - maxbank-1)
			move.l  	d0,d7   		; d7.l = bankx-1 also
			lea 		banknam,a1  	; a1 --> bank names
			lea 		bankflg,a2  	; a2 --> bank existence flags
			lea 		bnamflg,a3  	; a3 --> bank named flags
			lea 		bnkmess,a4
			add.l   	#280,a4 		; a4 --> "not named"
			clr.l   	d1
			move.b  	xmax,d1
			sub.b   	#42,d1
			divu		#4,d1
			lea 		nmline,a5
			move.b  	4(a5),x3
			addq.b  	#2,x3
			move.l  	d0,d2
			divu		#6,d2
			clr.l   	d3
			move.w  	d2,d3
			move.w  	#14,d4
			add.w   	d1,d4
			mulu		d3,d4
			add.w   	d4,d1
			lsr.l   	#8,d2
			lsr.l   	#8,d2
			add.b   	d2,x3   		; y-coord
			move.b  	d1,x2
			subq.b  	#1,x2

			tst.b   	0(a2,d0.w)   ; this bank exists?
			bne 		.1
			move.b  	ascilpr,x1  	; no: parentheses
			move.b  	cmenu,x4
			jsr 		outchar
			bra 		.2
.1  		move.b  	ascisp,x1   	; yes: no parentheses
			move.b  	cmenkey,x4
			jsr 		outchar
.2  		move.l  	d0,d2
			addq.w  	#1,d2
			cmpi.w  	#9,d2
			bgt 		.twodig
			move.b  	d2,x1
			add.b   	#$30,x1
			addq.b  	#1,x2
			jsr 		outchar
			bra 		.3
.twodig 	move.b  	#$31,x1
			addq.b  	#1,x2
			jsr 		outchar
			sub.b   	#10,d2
			move.b  	d2,x1
			add.b   	#$30,x1
			addq.b  	#1,x2
			jsr 		outchar
.3  		addq.b  	#1,x2
			tst.b   	0(a2,d0.w)
			bne 		.31
			move.b  	ascirpr,x1
			jsr 		outchar
			bra 		.4
.31 		move.b  	ascisp,x1
			jsr 		outchar

.4  		tst.b   	0(a3,d7.w)   ; named (and exists)?
			bne 		.15
			tst.b   	0(a2,d7.w)   ; exists? (and unnamed)?
			bne 		.14
			lea 		namebuf,a0
			move.b  	#10,d0
.13 		move.b  	ascisp,(a0)+
			subq.b  	#1,d0
			bne 		.13
			move.l  	#namebuf,x1 	  ; blank name if it doesn't exist
			move.b  	d7,d0
			bra 		.16

.14 		move.l  	a4,x1
			lea 		bnkmesl,a6
			move.b  	7(a6),x5	; "not named" if it exists and isn't named
			move.b  	d7,d0
			bra 		.16

.15 		move.l  	a1,x1
			move.b  	d7,d0
			mulu		#10,d7
			add.l   	d7,x1   	; x1.l --> bank name
.16 		addq.b  	#3,x2
			addq.b  	#1,d0
			cmp.b   	lastbank,d0
			bne 		.notlast
			move.b  	cmenkey,x4
			move.b  	#1,forceinv
			bra 		.17
.notlast	move.b  	cmenu,x4
.17 		move.b  	#10,x5
			jsr 		message 		; bank name
			clr.b   	forceinv

			move.l  	(a7)+,x5
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1		; restore x5-x1
			movem.l 	(a7)+,#$7FFF	; and registers
			rts 						; return

;*****************************************************************************;
;   findmen
;      x1 = itemx 0-19 (l) , x2 = menux 0-6 (l)
;      y1 = startx (b) , y2 = line (b)
;*****************************************************************************;

 .global findmen

findmen 	movem.l 	#$FFFE,-(a7)		; save registers

			move.l  	x1,d0   			; d0 = itemx 0-19 (l)
			move.l  	x2,d1   			; d1 = menux 0-6 (l)
			lea 		menufmt,a0
			cmpi.b  	#1,0(a0,d1.l)
			bgt 		findmen1

			move.b  	mencol2x,d2 		; 1-col menu:
			bra 		findmen2			; x-coord = mencol2x

findmen1	lea 		nmencol1,a1
			cmp.b   	0(a1,d1.l),d0
			bgt 		findmen3
			move.b  	mencol1x,d2
			cmp.b   	#2,0(a0,d1.l)
			bne 		findmen2
											;  in 1st col in a 2-col menu:
			add.b   	menmargn,d2 		;  x-coord = mencol1x+menmargn

findmen2	clr.b   	d7
			bra 		findmen7

findmen3	lea 		nmencol2,a2
			cmp.b   	0(a2,d1.l),d0
			bgt 		findmen6
			cmpi.b  	#2,0(a0,d1.l)
			bgt 		findmen4

			move.b  	mencol3x,d2 		;  in 2nd col in a 2-col menu:
			sub.b   	menmargn,d2 		;  x-coord = mencol3x-menmargn
			bra 		findmen5

findmen4	move.b  	mencol2x,d2 		; in 2nd col in a 3-col menu:
											; x-coord = mencol2x
findmen5	move.b  	0(a1,d1.l),d7
			addq.b  	#1,d7
			bra 		findmen7

findmen6	move.b  	mencol3x,d2 		; in 3rd col in a 3-col menu:
			move.b  	0(a2,d1.l),d7   	; x-coord = mencol3x
			addq.b  	#1,d7

findmen7	move.b  	d2,y1
			addq.b  	#5,d0
			sub.b   	d7,d0
			move.b  	d0,y2

			movem.l 	(a7)+,#$7FFF		; restore registers
			rts 							; and return
