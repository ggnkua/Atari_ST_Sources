;*****************************************************************************;
;   module 15 source file    Copyright 1986 Tom Bajoras
;   synth i/o routines:
;      readdx7,readbdx7,writdx7,writfdx7,writbdx7,readftx,readbftx,writbftx
;      readtx7,readbtx7
;*****************************************************************************;

 .text

;*****************************************************************************;
;   readdx7
;      x1.b = slotx = 1-32, y1.b = 0 ok, =1 timeout, =2 bad format
;*****************************************************************************;

 .global readdx7

readdx7 	movem.l 	#$FFFE,-(a7)	; save registers

			lea 		synbuf,a6
			move.b  	#$C0,(a6)     ; build dump request
			move.b  	x1,1(a6)
			subq.b  	#1,1(a6)		; program # = 0-31
			move.b  	midich,d0
			subq.b  	#1,d0
			add.b   	d0,(a6)

			move.l  	#synbuf,-(a7)
			move.w  	#1,-(a7)
			move.w  	#12,-(a7)
			trap		#14 			; send dump request
			addq.l  	#8,a7
			move.l  	midiaddr,a5 	; a5 --> midi input buffer
			clr.b   	d5  			; set switch for readdx7
			move.w  	#155,d6 		; # data bytes expected
			bra 		readit  		; go to readdx7/readbdx7 common code

;*****************************************************************************;
;   readtx7
;      no entry conditions, y1.b=0 ok, =1 timeout, =2 bad data format
;*****************************************************************************;

 .global readtx7

readtx7 	movem.l 	#$FFFE,-(a7)	; save registers

			lea 		synbuf,a6
			move.w  	#$F043,(a6)   ; build dump request
			move.w  	#$2000,2(a6)
			move.b  	midich,d0
			subq.b  	#1,d0
			add.b   	d0,2(a6)
			move.b  	#$F7,4(a6)

			move.l  	#synbuf,-(a7)
			move.w  	#4,-(a7)
			move.w  	#12,-(a7)
			trap		#14 			; send dump request
			addq.l  	#8,a7
			move.l  	midiaddr,a5 	; a5 --> midi input buffer
			clr.b   	d5  			; set switch for readdx7
			move.w  	#155,d6 		; # data bytes expected
			bra 		readit  		; go to readdx7/readbdx7 common code

;*****************************************************************************;
;   readbdx7
;      y1.b = 0 ok, =1 timeout, =2 bad format
;*****************************************************************************;

 .global readbdx7

readbdx7	movem.l 	#$FFFE,-(a7)	; save registers

			lea 		synbuf,a6
			move.w  	#$B060,(a6) 	; build dump request ('yes' command)
			move.b  	#$7F,2(a6)
			move.b  	midich,d0
			subq.b  	#1,d0
			add.b   	d0,(a6)

			move.l  	#synbuf,-(a7)
			move.w  	#2,-(a7)
			move.w  	#12,-(a7)
			trap		#14 			; send dump request
			addq.l  	#8,a7
			moveq   	#1,d5   		; set switch for readbdx7
			move.w  	#4096,d6		; # data bytes expected
			move.l  	midiaddr,a5 	; a5 --> midi input buffer
			bra 		readit  		; branch to readdx7/bdx7 common code

;*****************************************************************************;
;   readbtx7
;      y1.b = 0 ok, =1 timeout, =2 bad format
;*****************************************************************************;

 .global readbtx7

readbtx7	movem.l 	#$FFFE,-(a7)	; save registers

			lea 		synbuf,a6
			move.w  	#$F043,(a6) 	; build dump request
			move.w  	#$2009,2(a6)
			move.b  	midich,d0
			subq.b  	#1,d0
			add.b   	d0,2(a6)
			move.b  	#$F7,4(a6)

			move.l  	#synbuf,-(a7)
			move.w  	#4,-(a7)
			move.w  	#12,-(a7)
			trap		#14 			; send dump request
			addq.l  	#8,a7
			moveq   	#1,d5   		; set switch for readbdx7
			move.w  	#4096,d6		; # data bytes expected
			move.l  	midiaddr,a5 	; a5 --> midi input buffer

; readdx7/readbdx7 common code:
readit  	lea 		synbuf,a6   	; initialize synbuf stack
			clr.w   	6(a5)
			clr.w   	8(a5)   		; clean out midi input buffer

			move.w  	#$7FFF,d7   	; time-out counter
.loop1  	move.w  	6(a5),d0
			cmp.w   	8(a5),d0		; wait for midi byte
			bne 		.got1
.next1  	subq.w  	#1,d7   		; decrement time-out counter
			bgt 		.loop1
			bra 		.timeout
.got1   	move.w  	#3,-(a7)		; incoming midi byte: get it
			move.w  	#2,-(a7)
			trap		#13
			addq.l  	#4,a7
			cmpi.b  	#$F0,d0 		; still waiting for start of dump?
			bne 		.next1
			move.b  	d0,(a6)+		; got an F0 : put it on synbuf stack

			moveq   	#50,d7  		; time-out counter for restarts
.loop2  	move.w  	6(a5),d0
			cmp.w   	8(a5),d0		; wait for midi byte
			bne 		.got2
			bra 		.loop2
.got2   	move.w  	#3,-(a7)		; incoming midi byte: get it
			move.w  	#2,-(a7)
			trap		#13
			addq.l  	#4,a7
			move.b  	d0,(a6)+
			cmpi.b  	#$43,d0 		; Yamaha i.d. ?
			bne 		.done   		; if not: we're done (weird error)

.loop3  	move.w  	6(a5),d0
			cmp.w   	8(a5),d0
			bne 		.got3   		; wait for midi byte
			bra 		.loop3
.got3   	move.w  	#3,-(a7)		; incoming midi byte: get it
			move.w  	#2,-(a7)
			trap		#13
			addq.l  	#4,a7
			move.b  	d0,(a6)+		; got a byte: put it on synbuf stack
			cmpi.b  	#$F0,d0 		; starting over? ($F0,$43,$F0...)
			bne 		.loop4
.restart	lea 		synbuf,a6
			move.b  	d0,(a6)+
			subq.b  	#1,d7
			bne 		.loop2
			bra 		.timeout

.loop4  	move.w  	6(a5),d0
			cmp.w   	8(a5),d0
			bne 		.got4   		; incoming midi byte?
			bra 		.loop4
.got4   	move.w  	#3,-(a7)		; incoming midi byte: get it
			move.w  	#2,-(a7)
			trap		#13
			addq.l  	#4,a7
			move.b  	d0,(a6)+		; got a byte: put it on synbuf stack
			cmpi.b  	#$F0,d0 		; starting over? ($F0,$43,$??,$F0...)
			beq 		.restart
			cmpi.b  	#1,d0
			beq 		readit  		; stupid TX is sending F-par data

.loop5  	move.w  	6(a5),d0
			cmp.w   	8(a5),d0
			bne 		.got5   		; incoming midi byte?
			bra 		.loop5
.got5   	move.w  	#3,-(a7)		; incoming midi byte: get it
			move.w  	#2,-(a7)
			trap		#13
			addq.l  	#4,a7
			move.b  	d0,(a6)+		; got a byte: put it on synbuf stack
			blt 		.done   		; any status byte ends dump
			bra 		.loop5  		; loop until end of dump

.done   	lea 		synbuf,a0
			cmpi.b  	#$F0,(a0)      ; valid header?
			bne 		.badfmt
			cmpi.b  	#$43,1(a0)
			bne 		.badfmt
			andi.b  	#$F0,2(a0)  ; allow any MIDI channel (modified synth?)
			cmpi.b  	#$00,2(a0)
			bne 		.badfmt
			tst.b   	d5
			beq 		.sw1
			cmpi.b  	#$09,3(a0)
			bne 		.badfmt
			cmpi.b  	#$20,4(a0)
			bne 		.badfmt
			cmpi.b  	#$00,5(a0)
			bne 		.badfmt
			bra 		.cheksum
.sw1		cmpi.b  	#$00,3(a0)
			bne 		.badfmt
			cmpi.b  	#$01,4(a0)
			bne 		.badfmt
			cmpi.b  	#$1B,5(a0)

.cheksum	addq.l  	#6,a0
			clr.l   	d0
			clr.w   	d1
.sumloop	add.b   	0(a0,d1.w),d0
			addq.w  	#1,d1
			cmp.w   	d6,d1
			bne 		.sumloop
			neg.b   	d0
			andi.l  	#$7F,d0 			; d0.b = checksum
			cmp.b   	0(a0,d6.w),d0
			bne 		.badfmt 			; everything's ok?
			clr.b   	y1  				; non-error code

.return 	movem.l 	(a7)+,#$7FFF	; restore registers
			rts 						; and return

.badfmt 	move.b  	#2,y1   	; error codes
			bra 		.return
.timeout	move.b  	#1,y1
			bra 		.return

;*****************************************************************************;
;   writdx7
;      no entry conditions, no exit conditions
;      write a single voice to the synth
;*****************************************************************************;

 .global writdx7

writdx7 	movem.l 	#$FFFE,-(a7)
			move.l  	#synbuf,-(a7)
			move.w  	#162,-(a7)
			move.w  	#12,-(a7)
			trap		#14
			addq.l  	#8,a7
			movem.l 	(a7)+,#$7FFF
			rts

;*****************************************************************************;
;   writfdx7
;      x1.l --> first function parameter value to be sent
;*****************************************************************************;

 .global writfdx7

writfdx7	movem.l 	#$FFFE,-(a7)		; save registers

			move.l  	x1,a6   			; a6 --> start of data to be sent
			lea 		synbuf,a5   		; a5 --> buffer for synth i/o

			move.w  	#$F043,(a5)+
			move.b  	#$10,d0
			add.b   	midich,d0
			subq.b  	#1,d0
			move.b  	d0,(a5)+
			move.b  	#$08,(a5)+  	; prepare for send f-par command

			moveq   	#$40,d7 		; for d7 = $40 to $4D
.1  		move.b  	d7,(a5) 		; a5 --> parameter #
			move.b  	(a6)+,1(a5) 	; a5+1 --> parameter value
			move.l  	#synbuf,-(a7)
			move.w  	#5,-(a7)
			move.w  	#12,-(a7)
			trap		#14 			; send a function parameter
			addq.l  	#8,a7

			addq.l  	#1,d7
			cmpi.l  	#$4D,d7
			ble 		.1
			movem.l 	(a7)+,#$7FFF	; restore registers
			rts 						; restore

;*****************************************************************************;
;   writbdx7
;      no entry conditions, no exit conditions
;*****************************************************************************;

 .global writbdx7

writbdx7	movem.l 	#$FFFE,-(a7)
			move.l  	#synbuf,-(a7)
			move.w  	#4104,-(a7)
			move.w  	#12,-(a7)
			trap		#14
			addq.l  	#8,a7
			movem.l 	(a7)+,#$7FFF
			rts

;*****************************************************************************;
;   readftx
;      no entry conditions, y1.b = 0 ok, = 1 time-out, =2 bad format
;*****************************************************************************;

 .global readftx

readftx 	movem.l 	#$FFFE,-(a7)	; save registers

			lea 		synbuf,a6   	; initialize synbuf stack
			move.l  	midiaddr,a5
			clr.w   	6(a5)
			clr.w   	8(a5)   		; clean out midi input buffer

			move.w  	#$F043,(a6) 	; build dump request
			move.b  	#$20,2(a6)
			move.b  	midich,d0
			subq.b  	#1,d0
			add.b   	d0,2(a6)
			move.b  	#1,3(a6)
			move.b  	#$F7,4(a6)

			move.l  	#synbuf,-(a7)
			move.w  	#4,-(a7)
			move.w  	#12,-(a7)
			trap		#14 			; send dump request
			addq.l  	#8,a7

.loop1x 	move.w  	#2000,d7		; time-out counter
.loop1  	move.w  	6(a5),d0
			cmp.w   	8(a5),d0		; look for incoming midi byte
			bne 		.got1
			subq.w  	#1,d7   		; decrement time-out counter
			bne 		.loop1
			bra 		.timeout

.got1   	move.w  	#3,-(a7)		; incoming midi byte: get it
			move.w  	#2,-(a7)
			trap		#13
			addq.l  	#4,a7
			cmpi.b  	#$F0,d0
			bne 		.loop1x 		; still waiting for start of dump
			move.b  	d0,(a6)+		; got an F0 : put it on synbuf stack

.loop2  	move.w  	6(a5),d0
			cmp.w   	8(a5),d0		; look for incoming midi byte
			bne 		.got2
			bra 		.loop2

.got2   	move.w  	#3,-(a7)		; incoming midi byte: get it
			move.w  	#2,-(a7)
			trap		#13
			addq.l  	#4,a7
			move.b  	d0,(a6)+
			bge 		.loop2  		; any status byte ends dump

			lea 		synbuf,a0
			cmpi.b  	#$F0,(a0)      ; valid header?
			bne 		.badfmt
			cmpi.b  	#$43,1(a0)
			bne 		.badfmt
			andi.b  	#$F0,2(a0)  ; allow any MIDI channel (modified synth?)
			cmpi.b  	#$00,2(a0)
			bne 		.badfmt
			cmpi.b  	#$01,3(a0)
			bne 		.badfmt
			cmpi.b  	#$00,4(a0)
			bne 		.badfmt
			cmpi.b  	#$5E,5(a0)
			bne 		.badfmt
			cmpi.b  	#$F7,101(a0)   ; valid last byte?
			bne 		.badfmt

			addq.l  	#6,a0   		;  check the checksum
			clr.l   	d0
			clr.w   	d1
.sumloop	add.b   	0(a0,d1.w),d0
			addq.w  	#1,d1
			cmp.w   	#94,d1
			bne 		.sumloop
			neg.b   	d0
			andi.l  	#$7F,d0 			; d0.b = checksum
			cmp.b   	94(a0),d0
			bne 		.badfmt 			; everything's ok?
			clr.b   	y1  				; yep
			bra 		.return
.timeout	move.b  	#1,y1
			bra 		.return
.badfmt 	move.b  	#2,y1
.return 	movem.l 	(a7)+,#$7FFF	; restore registers
			rts 						; return

;*****************************************************************************;
;   readbftx
;      no entry conditions, y1.b = 0 ok, =1 time-out, =2 bad format
;*****************************************************************************;

 .global readbftx

readbftx	movem.l 	#$FFFE,-(a7)	; save registers

			lea 		synbuf,a6   	; initialize synbuf stack
			move.l  	midiaddr,a5
			clr.w   	6(a5)
			clr.w   	8(a5)   		; clean out midi input buffer

			move.w  	#$F043,(a6) 	; build dump request
			move.b  	#$20,2(a6)
			move.b  	midich,d0
			subq.b  	#1,d0
			add.b   	d0,2(a6)
			move.b  	#2,3(a6)
			move.b  	#$F7,4(a6)

			move.l  	#synbuf,-(a7)
			move.w  	#4,-(a7)
			move.w  	#12,-(a7)
			trap		#14 			; send dump request
			addq.l  	#8,a7

.loop1x 	move.w  	#2000,d7		; time-out counter
.loop1  	move.w  	6(a5),d0
			cmp.w   	8(a5),d0		; look for incoming midi byte
			bne 		.got1
			subq.w  	#1,d7   		; decrement time-out counter
			bne 		.loop1
			bra 		.timeout

.got1   	move.w  	#3,-(a7)		; incoming midi byte: get it
			move.w  	#2,-(a7)
			trap		#13
			addq.l  	#4,a7
			cmpi.b  	#$F0,d0
			bne 		.loop1x 		; still waiting for start of dump
			move.b  	d0,(a6)+		; got an F0 : put it on synbuf stack

.loop2  	move.w  	6(a5),d0
			cmp.w   	8(a5),d0		; look for incoming midi byte
			bne 		.got2
			bra 		.loop2

.got2   	move.w  	#3,-(a7)		; incoming midi byte: get it
			move.w  	#2,-(a7)
			trap		#13
			addq.l  	#4,a7
			move.b  	d0,(a6)+
			bge 		.loop2  		; any status byte ends dump

			lea 		synbuf,a0
			cmpi.b  	#$F0,(a0)      ; valid header?
			bne 		.badfmt
			cmpi.b  	#$43,1(a0)
			bne 		.badfmt
			andi.b  	#$F0,2(a0)  ; allow any MIDI channel (modified synth?)
			cmpi.b  	#$00,2(a0)
			bne 		.badfmt
			cmpi.b  	#$02,3(a0)
			bne 		.badfmt
			cmpi.b  	#$20,4(a0)
			bne 		.badfmt
			cmpi.b  	#$00,5(a0)
			bne 		.badfmt
			cmpi.b  	#$F7,4103(a0)   ; valid last byte?
			bne 		.badfmt

			addq.l  	#6,a0   		;  check the checksum
			clr.l   	d0
			clr.w   	d1
.sumloop	add.b   	0(a0,d1.w),d0
			addq.w  	#1,d1
			cmp.w   	#4096,d1
			bne 		.sumloop
			neg.b   	d0
			andi.l  	#$7F,d0 			; d0.b = checksum
			cmp.b   	4096(a0),d0
			bne 		.badfmt 			; everything's ok?
			clr.b   	y1  				; yep
			bra 		.return

.timeout	move.b  	#1,y1
			bra 		.return
.badfmt 	move.b  	#2,y1
.return 	movem.l 	(a7)+,#$7FFF	; restore registers
			rts 						; return

;*****************************************************************************;
;   writbftx
;      no entry conditions, no exit conditions
;*****************************************************************************;

 .global writbftx

writbftx	movem.l 	#$FFFE,-(a7)

			move.l  	#$15000,d0  	 ; pause
.loop   	subq.l  	#1,d0
			bgt 		.loop

			move.l  	#synbuf,-(a7)
			move.w  	#4103,-(a7)
			move.w  	#12,-(a7)
			trap		#14
			addq.l  	#8,a7
			movem.l 	(a7)+,#$7FFF
			rts
