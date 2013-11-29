;*****************************************************************************;
;   routines to set and/or send test tones to synth
;   also: protect() copy protection
;   Copyright 1986 Tom Bajoras
;*****************************************************************************;

 .text

;*****************************************************************************;
;   sendtone
;*****************************************************************************;

 .global sendtone

sendtone	movem.l 	#$FFFE,-(a7)	; save registers
			lea 		synbuf,a6   	; init string pointer

			tst.b   	toneflag
			beq 		.noteon
			clr.b   	d1  		 ; d1.b = 0 velocity = "note off"
			clr.b   	toneflag		; toggle toneflag state for next time
			bra 		.1
.noteon 	move.b  	#64,d1  		; d1.b = 64 velocity = "note on"
			move.b  	#1,toneflag 	; toggle toneflag state for next time

.1  		move.b  	midich,(a6)
			subq.b  	#1,(a6)
			add.b   	#$90,(a6)+  ; d0.b = note-on cmd including midi ch

			moveq   	#16,d7  	; loop through testones array
			moveq   	#0,d6   	; init # of bytes to send (minus 1)
			lea 		testones,a5
			lea 		tonestat,a4
.loop   	move.b  	(a5)+,d0	; note #
			tst.b   	(a4)+
			beq 		.skipit 	; skip tones that are off
			move.b  	d0,(a6)+	; append note # to string
			move.b  	d1,(a6)+	; append velocity to string
			addq.w  	#2,d6   	; increment # bytes to send
.skipit 	subq.b  	#1,d7
			bgt 		.loop

			move.l  	#synbuf,-(a7)
			move.w  	d6,-(a7)
			move.w  	#12,-(a7)
			trap		#14 		; midiws
			move.l  	#24,d0
			jsr 		getlong 	; d0.l = 8
			add.l   	d0,a7

			movem.l 	(a7)+,#$7FFF
			rts

;*****************************************************************************;
;   settone
;*****************************************************************************;

 .global settone

settone 	movem.l 	#$FFFE,-(a7)		; save registers
			move.l  	x1,-(a7)
			move.l  	x2,-(a7)
			move.l  	x3,-(a7)
			move.l  	x4,-(a7)
			move.l  	x5,-(a7)

			jsr 		blnkscr 		; start with a blank screen
			move.b  	#12,x1  		 ; change colors
			jsr 		setcolor

			move.l  	#tonemess,x1
			move.b  	xmax,d0
			lea 		tonemesl,a0
			sub.b   	(a0),d0
			lsr.b   	#1,d0
			addq.b  	#1,d0
			move.b  	d0,x2   		; center heading
			move.b  	#1,x3
			move.b  	cmenhed,x4
			move.b  	(a0),x5
			jsr 		message

			add.l   	#40,x1
			addq.b  	#2,x3
			move.b  	#10,x2
			move.b  	1(a0),x5
			jsr 		message 		; column headings
			add.l   	#40,x1
			move.b  	#26,x2
			move.b  	2(a0),x5
			jsr 		message
			add.l   	#40,x1
			move.b  	#45,x2
			move.b  	3(a0),x5
			jsr 		message
			add.l   	#40,x1
			move.b  	#65,x2
			move.b  	4(a0),x5
			jsr 		message

			clr.w   	x1
			move.w  	#170,x2
			move.w  	#639,x3
			move.w  	#170,x4
			move.b  	coutlne,x5
			jsr 		line			; draw line above menu

			move.l  	#tonemess,x1
			add.l   	#280,x1 		; put up menu
			move.b  	#7,x2
			move.b  	ymax,x3
			subq.b  	#2,x3
			move.b  	cmenu,x4
			lea 		tonemesl,a0
			move.b  	7(a0),x5
			jsr 		message
			add.l   	#40,x1
			addq.b  	#1,x3
			move.b  	8(a0),x5
			jsr 		message
			add.l   	#40,x1
			addq.b  	#1,x3
			move.b  	9(a0),x5
			jsr 		message

			add.l   	#40,x1
			move.b  	#49,x2
			move.b  	ymax,x3
			subq.b  	#2,x3
			move.b  	10(a0),x5
			jsr 		message
			add.l   	#40,x1
			addq.b  	#1,x3
			move.b  	11(a0),x5
			jsr 		message

			lea 		tonestat,a6 	; a6 --> tone status flags
			lea 		testones,a5 	; a5 --> test tone array

			moveq   	#0,d7   		; for row = 0 to 15
			move.b  	cmessge,x4  	; put up row in cmessge
.rowloop	bsr 		putrow
			addq.b  	#1,d7
			cmpi.b  	#15,d7
			ble 		.rowloop

			moveq   	#0,d7   		; init cursor to row 0

.cursloop   move.b  	cprompt,x4
			bsr 		putrow

.keyloop	jsr 		getkey
			trap		#11 			; key repeat on
			move.b  	y1,d4   		; d4.b = gotten key

			cmp.b   	asciup,d4
			beq 		.up
			cmp.b   	ascidwn,d4
			beq 		.down
			cmp.b   	ascicr,d4
			beq 		.return
			cmp.b   	ascidel,d4
			beq 		.del
			cmp.b   	asciplus,d4
			beq 		.plus
			cmp.b   	ascidash,d4
			beq 		.dash
			cmp.b   	ascisp,d4
			beq 		.sp
			cmp.b   	ascibs,d4
			beq 		.bs

.bell   	jsr 		bell			; illegal key: ring bell, loop
			bra 		.keyloop

.up 		move.b  	cmessge,x4
			bsr 		putrow
			subq.b  	#1,d7
			bge 		.cursloop
			moveq   	#15,d7
			bra 		.cursloop

.down   	move.b  	cmessge,x4
			bsr 		putrow
			addq.b  	#1,d7
			cmpi.b  	#15,d7
			ble 		.cursloop
			moveq   	#0,d7
			bra 		.cursloop

.del		tst.b   	0(a6,d7.l)   ; toggle tonestat
			beq 		.del0
			clr.b   	0(a6,d7.l)
			bra 		.cursloop
.del0   	move.b  	#1,0(a6,d7.l)
			bra 		.cursloop

.plus   	cmpi.b  	#126,0(a5,d7.l)
			ble 		.plus1
			clr.b   	0(a5,d7.l)
			bra 		.cursloop
.plus1  	addq.b  	#1,0(a5,d7.l)
			bra 		.cursloop

.dash   	tst.b   	0(a5,d7.l)
			bne 		.dash1
			move.b  	#127,0(a5,d7.l)
			bra 		.cursloop
.dash1  	subq.b  	#1,0(a5,d7.l)
			bra 		.cursloop

.sp 		cmpi.b  	#115,0(a5,d7.l)
			bgt 		.bell
			add.b   	#12,0(a5,d7.l)
			bra 		.cursloop

.bs 		cmpi.b  	#12,0(a5,d7.l)
			blt 		.bell
			sub.b   	#12,0(a5,d7.l)
			bra 		.cursloop

.return 	move.l  	(a7)+,x5		; restore registers,x1-x5,return
			move.l  	(a7)+,x4
			move.l  	(a7)+,x3
			move.l  	(a7)+,x2
			move.l  	(a7)+,x1
			movem.l 	(a7)+,#$7FFF
			rts

;*****************************************************************************;
;   putrow  --  local routine to put up a row on settone screen
;   entry conditions: x4.b = color, d7.l = row (0-15), a6--> tonestat
;   				  a5.l --> testones
;*****************************************************************************;

putrow  	movem.l 	#$FFFE,-(a7)	; save registers

			move.b  	#5,x3
			add.b   	d7,x3   		; y-coord

			move.w  	d7,x1
			jsr 		encode
			move.l  	y1,x1
			move.b  	#13,x2
			move.b  	#2,x5
			jsr 		message 		; tone #

			clr.w   	d0
			move.b  	0(a5,d7.l),d0
			move.w  	d0,x1
			jsr 		encode
			move.l  	y1,x1
			move.b  	#30,x2
			move.b  	#3,x5
			jsr 		message 		; midi note #

			move.l  	#tonemess,x1
			move.b  	#47,x2
			lea 		tonemesl,a0
			move.b  	5(a0),x5
			tst.b   	0(a6,d7.l)
			beq 		.off
			add.l   	#200,x1
			bra 		.offon
.off		add.l   	#240,x1
.offon  	jsr 		message 		; off/on

			move.l  	#notename,x1
			clr.l   	d0
			move.b  	0(a5,d7.l),d0
			divu		#12,d0
			clr.l   	d1
			move.w  	d0,d1
			lsr.l   	#8,d0
			lsr.l   	#7,d0
			add.l   	d0,x1
			move.b  	#65,x2
			move.b  	#2,x5
			jsr 		message 		; midi note name
			move.l  	#octname,x1
			lsl.l   	#1,d1
			add.l   	d1,x1
			addq.b  	#2,x2
			move.b  	#2,x5
			jsr 		message 		; midi octave name

			movem.l 	(a7)+,#$7FFF	; restore registers
			rts

;*****************************************************************************;
;   protect -- copy protection: check for A-Lock or STync box
;      entry conditions:  a6 --> 0L --> mazetabl
;   							 4L --> errcnt.w
;   							 8L --> chrcnt.w
;   							12L --> crc.w
;   							16L --> Buf (512 bytes)
;   							20L --> Serial .ascii "100002"
;*****************************************************************************;

 .global protect
; note: keep everything between protect and protectx non-relocatable
protect:		move.l  	#$426,a0			; system reset will
				move.l  	#$31415926,d0   	; be VERY messy
				bsr 		setlong
				move.l  	#$42a,a0
				clr.l   	d0
				bsr 		setlong

; do a CRC on the 15 delta's from mazetabl
				clr.l   	d1  			; d1.l= CRC accumulator
				move.l  	(a6),a0
				addq.l  	#2,a0   		; a0 --> addresses, by 6
				move.l  	(a0),d2 		; d2 = previous address
				move.b  	#15,d0  		; d0 = counter (15 times)
mazeloop		add.l   	#6,a0
				move.l  	(a0),d3 		; this address
				sub.l   	d2,d3   		; d3.l = delta
				moveq   	#7,d7   		; count
				move.w  	d1,d6   		; old value
mloop2  		lsl.b   	#1,d3
				roxl.w  	#1,d6
				bcc 		mskip
				eori.w  	#$8550,d6
mskip   		dbf 		d7,mloop2
				move.w  	d6,d1
				move.l  	(a0),d2 		; set up next previous address
				subq.b  	#1,d0
				bgt 		mazeloop

; if d1.w isn't right, the following loop will probably hang:
				clr.l   	d7
				move.w  	d1,d7   		; d7.l = 176 (hopefully)
				sub.l   	#168,d7 		; d7.l = 8 (hopefully)
				move.l  	#$308,a0
moveloop		move.l  	d7,d0
				bsr 		getlong
				bsr 		setlong
				addq.l  	#4,a0
				addq.l  	#4,d7
				cmpi.l  	#$28,d7
				bne 		moveloop

; Start of Plover(), written by Joe Fitzpatrick, modified by Tom Bajoras
	bsr 	clrcrc  		; clear CRC accumulator
	move.l  4(a6),a0		; a0 --> errcnt
	move	#0,(a0) 		; clear error counter
	move.l  8(a6),a0		; a0 --> chrcnt
	move	#36,(a0)		; init character count

	move	#-1,-(a7)   	; configure RS-232 port
	move	#1,-(a7)
	move	#1,-(a7)
	move	#$88,-(a7)
	move	#0,-(a7)
	move	#1,-(a7)
	move	#15,-(a7)
	trap	#14
	add.l   #14,a7

	move	#24,-(a7)   	; clear DTR and RTS
	move	#30,-(a7)
	trap	#14
	addq.l  #4,a7

	move	#$1b,d0 		; send ESC to stop all box activity
	bsr 	xmit

	move	#10000,d0   	; waste enough time for box to respond
dumb:
	nop
	subq.w  #1,d0
	bgt 	dumb

rubbish:
	bsr 	rcvstat 		; clean out RS232 buffer
	tst 	d0
	beq 	empty
	bsr 	recv
	bra 	rubbish

empty:
	move.w  #63,d0  		; send '?' to request copyright msg from box
	bsr 	xmit

copywait:
	bsr 	crwait  		; wait for start of copyright
	tst.b   d0  			; time-out?
	beq 	timeout
	cmpi.b  #$3a,d0 		; start of cr msg? (':')
	bne 	copywait		; no

docrc:
	bsr 	crwait  		; do CRC check on copyright message
	bsr 	addcrc
	move.l  8(a6),a0		; a0 --> chrcnt
	sub.w   #1,(a0) 		; decrement character count
	bne 	docrc
	bsr 	fincrc
	move.l  12(a6),a0   	; a0 --> crc
	move	(a0),d0

timeout:
	andi.l  #$F,d0  		; d0.l should = $F
	mulu	#6,d0   		; d0.l = index into mazetabl
	move.l  (a6),a0 		; a0 --> mazetabl
	addq.l  #2,a0
	move.l  0(a0,d0.l),a0
	jmp 	(a0)			; jump into maze (to protect1 or protect2)

; note: nothing between protect1 and protect2 (inclusive) can be changed:
;   	It will alter the correct CRC of delta-mazetabl

 .global protect1
protect1:
	move.l  	(a6),a0 	; a0 --> mazetabl
	clr.b   	5(a0)   	; clear stync flag

; Start of A-Lock (d0.l=F ok, =0 fail)
; Written by Robert Polic (Allenbach Industries), modified by Tom Bajoras

	moveq.l 	#2,d6   		; d6 - current try (2 or 1)
	moveq.l 	#2,d5   		; d5 - read twice flag
	move.w  	#$19,-(a7)  	; get current drive
	trap		#1  			; *BIOS* d_getdrv()
	addq.l  	#2,a7   		; restore the stack
	move.w  	d0,d7   		; d7 - default device number
	cmpi.w  	#2,d7   		; device not a floppy?
	blt 		L0  			; no? then don't worry about it
	clr.w   	d7  			; floppies only (for right now anyways)

; read signature sector: track 0, side 0, sector 0
L0:
	move.w  	#1,-(a7)		; read one sector
	clr.w   	-(a7)   		; side 0
	clr.w   	-(a7)   		; track 0
	clr.w   	-(a7)   		; sector 0
	move.w  	d7,-(a7)		; device (0-A:,1-B:)
	clr.l   	-(a7)   		; filler (not used)
	move.l  	16(a6),-(a7)	; pointer to 512 byte buffer
	move.w  	#8,-(a7)		; read sector
	trap		#14 			; *BIOS* _floprd
	add.l   	#20,a7  		; restore the stack

; check results
	tst.w   	d0  			; no error? (stupid fix for ROM OS)
	beq 		L3  			; then ok (ROM can't see EDC error!!)
	cmp.w   	#-4,d0  		; EDC error
	beq 		L3  			; yea? then it's ok
L1  subq.w  	#1,d6   		; next device
	beq 		L2  			; no more? then quit
	moveq.l 	#2,d5   		; set read twice flag
	addq.w  	#1,d7   		; next device
	cmpi.w  	#2,d7   		; go to far?
	bne 		L0  			; no? then try that device
	clr.w   	d7  			; yes? set device to 0
	bra 		L0  			; and retry

L2  clr.l   	d0  			; send bad verify flag
	bra 		exit			; and exit

; verify signature
L3  clr.w   	d0  			; clear accumulator register
	move.l  	16(a6),a0   	; --> buffer
	move.l  	20(a6),a1   	; --> serial number
	cmp.l   	(a0)+,(a1)+ 	; compare first 4 bytes of serial no.
	bne 		L1  			; don't match? bad disk
	cmp.w   	(a0)+,(a1)+ 	; compare last 2 bytes of serial no.
	bne 		L1  			; don't compare? bad disk
	move.w  	#505,d1 		; check remaining 506 bytes
L4  move.w  	#7,d2   		; check all bits
	move.b  	(a0)+,d3		; byte in d3
L5  asr.w   	#1,d3   		; shift bit into carry
	bcc 		L6  			; carry set? no? then next bit
	addq.w  	#1,d0   		; increment accumulator
L6  dbra		d2,L5   		; loop through
	dbra		d1,L4   		; loop through
	subq.w  	#1,d5   		; did we read it twice
	beq 		L7  			; yea? check results
	move.w  	d0,d4   		; save this result
	bra 		L0  			; and read it again
L7  sub.w   	d4,d0   		; both read the same
	beq 		L1  			; oh oh, naughty naughty
	move.l  	#$5A,d0 		; set good flag
	bra 		exit

 .global protect2
protect2:
	move.l  	(a6),a0 		; a0 --> mazetabl
	move.b  	#1,5(a0)		; set stync flag
exit:
	sub.l   	#$58,d0 		; d0.l = 2 (hopefully)
	move.l  	#8,a0
	move.l  	d0,d1
	bsr 		setlong 		; move.l	#2,$8
	add.l   	d1,d0
	addq.l  	#4,a0
	bsr 		setlong 		; move.l	#4,$C
	add.l   	d1,d0
	addq.l  	#8,a0
	bsr 		setlong 		; move.l	#6,$14
	add.l   	d1,d0
	addq.l  	#4,a0
	bsr 		setlong 		; move.l	#8,$18
	add.l   	d1,d0
	addq.l  	#4,a0
	bsr 		setlong 		; move.l	#10,$1C
	add.l   	d1,d0
	addq.l  	#4,a0
	bsr 		setlong 		; move.l	#12,$20
	rts 						; exit from protect()

;******************
; rs232 routines
;******************
; xmit - send char in d0 to serial port
; recv - get char from serial port to d0
; rcvstat - get port status d0=0 no char, d0=-1 char
; crwait - get char w/timeout error checking

xmit:
	move		d0,-(a7)		; char to send
	move		#1,-(a7)		; dev=aux
	move		#3,-(a7)		; bconout
	trap		#13
	addq.l  	#6,a7
	rts

;**********
recv:
	move		#1,-(a7)		; dev=aux
	move		#2,-(a7)		; bconin
	trap		#13
	addq.l  	#4,a7
	rts

;**********
rcvstat:
	move		#1,-(a7)		; dev=aux
	move		#1,-(a7)		; bconstat
	trap		#13
	addq.l  	#4,a7
	rts

;**********
crwait:
	bsr 		rcvstat
	tst 		d0
	beq 		nogo			; no char
	move.l  	4(a6),a0		; a0 --> errcnt
	move		#0,(a0) 		; clear counter
	bra 		recv			; get char

nogo:
	move.l  	4(a6),a0		; a0 --> errcnt
	move		(a0),d0
	addq		#1,d0   		; inc error counter
	cmpi		#5000,d0		; overflow?
	bne 		stillgo 		; keep trying
	clr.l   	d0  			; 'no box' message (time-out)
	rts
stillgo:
	move.l  	4(a6),a0		; a0 --> errcnt
	move		d0,(a0)
	bra 		crwait  		; keep lookin'

;***************
; CRC routines
;***************
; clrcrc	- clear the CRC accumulator
; addcrc	- add a byte to the CRC, call w/d0=byte
; fincrc	- calculate final CRC

clrcrc:
	move.l  	12(a6),a0   	; a0 --> crc
	move.w  	#0,(a0)
	rts

;**********
addcrc:
	moveq   	#7,d1   		; count
	move.l  	12(a6),a0   	; a0 --> crc
	move.w  	(a0),d2 		; old value
crcloop:
	lsl.b   	#1,d0
	roxl.w  	#1,d2
	bcc 		skipit
	eori.w  	#$8005,d2
skipit:
	dbf 		d1,crcloop
	move.l  	12(a6),a0   	; a0 --> crc
	move.w  	d2,(a0)
	rts

;**********
fincrc:
	moveq.l 	#0,d0
	bsr 		addcrc
	moveq.l 	#0,d0
	bsr 		addcrc
	rts

 .global protectx
protectx:
	rts 				; this marks the end of code that will be CRC'd

 .global setlong
setlong:					  ; equivalent to    move.l d0,(a0)
			movem.l 	#$FFFE,-(a7)
			move.l  	d0,saved0
			move.l  	a0,savea0
			move.l  	#setcode,-(a7)
			move.w  	#38,-(a7)
			trap		#14
			addq.l  	#6,a7
			movem.l 	(a7)+,#$7FFF
			rts
setcode 	move.l  	saved0,d0
			move.l  	savea0,a0
			move.l  	d0,(a0)
			rts

 .global getlong
getlong:					 ; equivalent to	move.l (d0),d0
			movem.l 	#$7FFE,-(a7)
			move.l  	d0,saved0
			move.l  	#getcode,-(a7)
			move.w  	#38,-(a7)
			trap		#14
			addq.l  	#6,a7
			move.l  	saved0,d0
			movem.l 	(a7)+,#$7FFE
			rts
getcode 	move.l  	saved0,a0
			move.l  	(a0),saved0
			rts

 .bss
 .even

saved0  .space  	4   		   ; for setlong() and getlong()
savea0  .space  	4   		   ; for setlong()

;*****************************************************************************;
;   local data:  midi note names and messages
;*****************************************************************************;

 .data

notename	.ascii  	"C C#D D#E F F#G G#A A#B "
octname 	.ascii  	"-2-10 1 2 3 4 5 6 7 8 "
tonemess	.ascii  	"Set Test Tonesxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 0
			.ascii  	"Tone #xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 1
			.ascii  	"MIDI Note #xxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 2
			.ascii  	"On/Offxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 3
			.ascii  	"Notexxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 4
			.ascii  	"on xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 5
			.ascii  	"offxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 6
			.ascii  	"arrows  move cursor xxxxxxxxxxxxxxxxxxx"   ; 7
			.ascii  	"[+][-]  +/- note # xxxxxxxxxxxxxxxxxxxx"   ; 8
			.ascii  	"[sp][bs] +/- octave xxxxxxxxxxxxxxxxxxx"   ; 9
			.ascii  	"[del]  note on/off xxxxxxxxxxxxxxxxxxxx"   ;10
			.ascii  	" [cr]  go to utility menu xxxxxxxxxxxxx"   ;11
tonemesl	.byte   	14,6,11,6,4,3,3,19,18
			.byte   	19,18,25
