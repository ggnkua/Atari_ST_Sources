* GBP STOS EXTENSION - INTERPRETER VERSION 4.2
*
* WRITTEN BY NEIL HALLIDAY 1991/92/93
* (C) 1993 GBP SOFTWARE LTD.
* 
* SHAREWARE DEMO VERSION...  Gives 10 message checks and then locks up
*
* USAGE:
*
* Lights on     : Turns drive lights A&B on
* Pready        : Is printer on line, true or false?
* Lights off    : Turns drive lights A&B off
* Paktype	: Return what mode file is packed with
* Paksize	: Return the uncompressed length of a file
* Fastwipe	: Fast clear screen
* Hardsclr	: Increase screen address by 1280 bytes
* Procline	: Show amount of time left
* Even		: Test if a number is even
* Setpal	: Set palette from a memory bank
* Setprt	: Set printer configuration
* D crunch	: Depack packed files
* Pcpal		: Get the palette from a PC? picture
* Unpak deg	: Unpack a degas compressed piccy
* Holdkey	: Wait until a specific key is pressed (uses ascii)
* Mirror	: Mirrors a section of the screen...
* Unpak tny	: Unpack a tiny compressed piccy
* Produce_boot	: Produce a bootsector in a memory bank
* Specialkey	: Get the current status of the special keys
* Recolour	: Reconstruct the colour table from a PI1 picture
* Foffset	: Returns the offset of a file in a GBP Bank
* Fstart	: Returns the start address of a file in a GBP Bank
* Flength	: Returns the length of a file in a GBP Bank
  
	bra	init
	dc.b	128
	
tokens:

	dc.b	"lights on",128
	dc.b	"pready",129
	dc.b	"lights off",130
	dc.b	"hardscrl",131
	dc.b	"fastwipe",132
	dc.b	"paktype",133
	dc.b	"procline",134
	dc.b	"even",135
	dc.b	"setpal",136
	dc.b	"setprt",137
	dc.b	"d crunch",138
	dc.b	"degpal",139
	dc.b	"unpak deg",140
	dc.b	"foffset",141
	dc.b	"holdkey",142
	dc.b	"tinypal",143
	dc.b	"mirror",144
	dc.b	"percent",145
	dc.b	"unpak tny",146
	dc.b	"paksize",147
	dc.b	"produce boot",148
	dc.b	"special key",149
	dc.b	"recolour",150
	dc.b	"fstart",151
	dc.b	"flength",153
	dc.b	0
	even
	
jump:
	dc.w	26
	dc.l	lightson
	dc.l	pready
	dc.l	lightsoff
	dc.l	hardscrl
	dc.l	fastwipe
	dc.l	paktype
	dc.l	procline
	dc.l	teven
	dc.l	setpal
	dc.l	setprt
	dc.l	d_crunch
	dc.l	pcpal
	dc.l	unpak
	dc.l	offset
	dc.l	holdkey
	dc.l	tinypal
	dc.l	mirror
	dc.l	percent
	dc.l	unpak_tiny
	dc.l	paksize
	dc.l	produce_boot
	dc.l	special
	dc.l	recolour
	dc.l	fstart
	dc.l	dummy
	dc.l	flength

message:


	dc.b	10,$15,"** GBP Extension V4.2 SHAREWARE RELEASE (c)GBP 1993 **",$12,0
	dc.b	10,$15,"** GBP Extension V4.2 SHAREWARE RELEASE (c)GBP 1993 **",$12,0
	dc.b	0
	even
	
system:	dc.l	0
protect	dc.l	0			; Protection variable	
final:	dc.l	0			; Final protection variable
return:	dc.l	0
	
init:	
	lea	exit,a0
	lea	coldst,a1
	rts
	
coldst:
	move.l	a0,system
	lea 	message,a0
	lea	warm,a1
	lea	tokens,a2
	lea	jump,a3

	move.l	#$31415926,$426			; Oopps there goes the
	move.l	#finito,$42a			; reset vector
	
	move.w	#10,$446			; 10 to Gem device boot
	
	
;	bsr	colourloop			; Bugger up screen colours
		
warm:	bsr	protection			; Call protection
	rts

dummy:	rts
	
lightson:
	
	move.l	(a7)+,return		; Save return
	movem.l	a0-a6,-(a7)		; Save registers
	move.b	#14,$ff8800		; Send info to sound chip
	move.b	$40,$ff8802		; Send info to sound chip
	movem.l	(a7)+,a0-a6		; Restore registers
	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it

pready:
	move.l	(a7)+,return		; save return
	moveq	#0,d3			; Zero d3
	move.w	#0,-(sp)		; Printer ready?
	move.w	#8,-(sp)		; Bcostat
	trap	#13			; Call Bios
	addq.l	#4,sp			; Restore stack
	move.w	#0,d2			; Tell stos to expect integer
	move.l	d0,d3			; Save result in d3 ready for STOS
	move.l	return,a0		; Load return
	jmp	(a0)			; jump to it
	
lightsoff:
	
	move.l	(a7)+,return		; Save return
	movem.l	a0-a6,-(a7)		; Save registers
	move.b	#14,$ff8800		; Send info to sound chip
	move.b	#6,$ff8802		; Send info to sound chip
	movem.l	(a7)+,a0-a6		; Restore registers
	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it

fastwipe:

	move.l	(a7)+,return		; Save return
	cmpi.w	#1,d0			; One paramter?
	bne	syntax			; No, syntax error!
	bsr	getint			; Get integer
	move.l	d3,a0			; Save address into a0

	include	"a:\source\includes\fast_cls.s"

	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it
	
procline:
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 2 parameters?
	bne	syntax			; No, syntax error
	
	bsr	getint			; Get integer
	move.w	d3,d0			; Save for later
	lea	$ff8240,a0		; Load colour address
	
	move.w	(a0),d1			; Save original colour	
	move.w	d0,(a0)			; Load raster colour
	move.w	d1,(a0)			; Load original colour
	
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it

setpal:
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; Set palette
	bne	syntax			; No, syntax error
	bsr	getint			; Get integer
	move.l	d3,a0			; Store as address

	move.l  a0,$45A

	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it

d_crunch:
	
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter?
	bsr	getint			; Get integer
	move.l	d3,a0			; Store source address
	
	cmp.l	#'SP20',(a0)		; Speed header
	beq	speed			; Call routine
	
	cmp.l	#'ATM5',(a0)		; Atomik header
	beq	atomik			; Call routine
	
	cmp.l	#'Ice!',(a0)		; Ice header
	beq	ice			; Call routine
	
	cmp.l	#'AU5!',(a0)		; Automation header
	beq	auto			; Call routine
	
	cmp.l	#'ICE!',(a0)		; Ice V2.40 header
	beq	ice2
	
	cmp.l	#'FIRE',(a0)		; Fire V2.0
	beq	fire_decrunch_2
	
	cmp.l	#'SPv3',(a0)		; Speed V3
	beq	spe3			
	
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it

spe3	move.l	a0,a1			; Transfer addresses
	bra	speed3
	rts
	
	include	'a:\source\includes\d_crunch.s'

unpak:	move.l	(a7)+,return		; Save return
	cmp	#2,d0			; 2 parameters
	bne	syntax			; No, syntax error
	bsr	getint			; Get integer
	move.l	d3,a1			; Save dest address
	bsr	getint			; Get integer
	move.l	d3,a0			; Save source address
	
	cmpi.b	#$80,(a0)		; check type flag									
	bne	notdone			; not compressed

	move.l	a0,-(a7)		; save pointer
	lea	$22(a0),a0		; pointer to pic image

	clr.w	d0
	clr.w	d1
	clr.w	d2
	moveq	#1,d3
.dec1
	move.b	(a0)+,d4
	bmi.s	.dec3

	ext.w	d4
	add.w	d4,d2
.dec2
	move.b	(a0)+,(a1)
	lea	0(a1,d3.w),a1
	eori.w	#6,d3
	dbra	d4,.dec2
	
	bra.s	.dec5
.dec3
	neg.b	d4
	ext.w	d4
	add.w	d4,d2
	move.b	(a0)+,d5
.dec4
	move.b	d5,(a1)
	lea	0(a1,d3.w),a1
	eori.w	#6,d3
	dbra	d4,.dec4
.dec5
	addq.w	#1,d2
	cmp.w	#$28,d2
	bne.s	.dec6

	clr.w	d2
	lea	-$9e(a1),a1
	addq.w	#1,d1
	cmp.w	#4,d1
	bne.s	.dec6
	clr.w	d1
	lea	$98(a1),a1
	addq.w	#1,d0
.dec6
	cmp.w	#$c8,d0
	bne.s	.dec1

	movea.l	(a7)+,a0
	addq.l	#2,a0			; pointer to palette
	rts
	
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it

hardscrl:
	move.l	(a7)+,return		; Save return
	cmp	#2,d0			; 2 parameters?
	bne 	syntax			; No, syntax
	bsr	getint			; Get integer
	move.l	d3,d1			; Store function
	bsr	getint			; Get integer
	move.l	d3,a0			; Store address
	
	cmp	#1,d1			; Function 1?
	beq	yup

	sub.l	1280,a0			; Subtract 1280 bytes or 8 scans
	bra	fin
		
yup	add.l	#1280,a0		; Add 1280 bytes or 8 scan lines
	
fin	move.l	a0,d3			; Save address
	move.w	#0,d2			; Tell stos to expect integer
	
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it

* Get type of packer used

paktype	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter?
	bne	syntax			; No, syntax error
	bsr	getint			; Get integer
	move.l	d3,a0			; Store address of file
	
	cmp.l	#'SP20',(a0)		; Speed header
	beq	spd			; Call routine
	
	cmp.l	#'ATM5',(a0)		; Atomik header
	beq	atmk			; Call routine
	
	cmp.l	#'Ice!',(a0)		; Ice header
	beq	ic			; Call routine
	
	cmp.l	#'AU5!',(a0)		; Automation header
	beq	aut			; Call routine
	
	cmp.l	#'ICE!',(a0)		; Ice V2.40 header
	beq	ic2
	
	cmp.l	#'FIRE',(a0)		; Fire V2.0
	beq	fire
	
	cmp.l	#'SPv3',(a0)		; Speed V3
	beq	sped3
	
	move.l	#0,d3			; Return value 
	bra.s	ret			; Return
		
spd	move.l	#1,d3			; Speed found
	bra.s	ret			; Return

atmk	move.l	#2,d3			; Atomik found
	bra.s	ret			; Return
	
ic	move.l	#3,d3			; Ice found
	bra.s	ret			; Return
	
aut	move.l	#4,d3			; Automation found
	bra.s	ret			; Return
	
ic2	move.l	#5,d3			; Ice V2.40 found
	bra.s	ret			; Return

fire	move.l	#6,d3			; Fire V2.0 found
	bra.s	ret			; Return
	
sped3	move.l	#7,d3			; Speed V3 found
	
ret	move.w	#0,d2			; Expect integer
	move.l	return,a0		; Load return
	jmp	(a0)

* Get upacked size of unpacked file

paksize	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameters?
	bne	syntax			; No, syntax error
	
	bsr	getint			; Get integer
	move.l	d3,a0			; Store address of file
	
	cmp.l	#'SP20',(a0)		; Speed header
	beq	spd2			; Call routine
	
	cmp.l	#'ATM5',(a0)		; Atomik header
	beq	atmk2			; Call routine
	
	cmp.l	#'Ice!',(a0)		; Ice header
	beq	ic_2			; Call routine
	
	cmp.l	#'AU5!',(a0)		; Automation header
	beq	aut2			; Call routine
	
	cmp.l	#'ICE!',(a0)		; Ice V2.40 header
	beq	ic22
	
	cmp.l	#'FIRE',(a0)		; Fire V2.0
	beq	fire2
	
	cmp.l   #'SPv3',(a0)		; Speed V3
	beq	spd3
	
	move.l	#0,d3			; Return value 
	bra.s	ret2			; Return
		
spd2	move.l	12(a0),d3		; Store file length
	bra.s	ret2			; Return

atmk2	move.l	4(a0),d3		; Store file length
	bra.s	ret2			; Return
	
ic_2	move.l	8(a0),d3		; Store file length
	bra.s	ret2			; Return
	
aut2	move.l	8(a0),d3		; Store file length
	bra.s	ret2			; Return
	
ic22	move.l	8(a0),d3		; Store file length
	bra.s	ret2			; Return

fire2	move.l	8(a0),d3		; Store file length
	bra.s	ret2

spd3    move.l  12(a0),d3		; Store file length
	
ret2	move.w	#0,d2			; Expect integer
	move.l	return,a0		; Load return
	jmp	(a0)

* Final protection routine

finito	move	#1,d7			; Print text
	lea	fintxt(pc),a0		;
	trap	#3
.loop	bra	.loop			; Never stop

* Improved EVEN command, allows control over positive and negative
* numbers, improved by Neil 28/01/1993 now uses bittest

teven	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter?
	bne	syntax			; No, syntax error
	bsr	getint			; Get integer
	move.l	d3,d0			; Store in d0

* Check number

	btst	#0,d0			; Test bit 0 of d0
	beq	yesev			; Number is even
	
	move.l	#0,d3			; Store false 
	bra	leav			; Branch to leave

yesev	move.l	#-1,d3			; Store true

leav	move.l	#0,d2			; Return value
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it
	
holdkey	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter?
	bne	syntax			; No, syntax error
	bsr	getint			; Get integer
	move.w	d3,d1			; Store as d1
	
check	bsr	keypress		; Call routine
	cmp	d1,d0			; Is it the number?
	beq	yep			; Yes, leave
	bsr	check			; Re-loop
	
yep	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it

keypress
	move	#8,-(a7)		; Function 8
	trap	#1			; Call Gem
	addq.l	#2,a7			; Restore stack
	rts				; Return

setprt	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter?
	bne	syntax			; No, syntax error
	bsr	getint			; get integer
	move.w	d3,d0			; Store in d0
	
	move.w	d3,-(a7)		; Config
	move.w	#33,-(a7)		; Setprt
	trap	#14			; Call Xbios
	addq.l	#4,a7			; Restore stack
	
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it

pcpal	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter?
	bne	syntax			; No, syntax error
	bsr	getint			; Get integer
	move.l	d3,a0			; Store as address
	
	lea	2(a0),a0		; add 2 to address
	
	move.l	a0,-(a7)		; Palette pointer
	move.w	#6,-(a7)		; Setpalette
	trap	#14			; Call Xbios
	addq.l	#6,a7			; Restore stack
	
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it

offset	move.l	(a7)+,return		; Save return
	cmp	#2,d0			; 2 parameters?
	bne	syntax			; No, syntax error
	
	bsr	getint			; Get integer
	move.l	d3,a1			; Store bank address
	
	bsr	getint			; Get integer
	move.w	d3,d1			; Store file number
	
	add.l	#2,a1			; Increase a1
	
	cmp	#0,d1			; File 0?
	beq	.no			; Yes	

	sub.l	#1,d1			; Dec d1
	
.floop	add.l	#8,a1			; Add 8 to address
	dbf	d1,.floop		; Loop number of times
	
.no	add.l	#4,a1			; Increase for offset
	
	move.l	(a1),d3			; Move value	

endoff	move.l	#0,d2			; Expect integer
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it


fstart	move.l	(a7)+,return		; Save return
	cmp	#2,d0			; 2 parameters?
	bne	syntax			; No, syntax error
	
	bsr	getint			; Get integer
	move.l	d3,a1			; Store bank address
	
	bsr	getint			; Get integer
	move.w	d3,d1			; Store file number
	
	move.l	a1,a2			; Copy address
	add.l	#2,a1			; Increase a1
	
	cmp	#0,d1			; File 0?
	beq	.no2			; Yes	

	sub.l	#1,d1			; Dec d1
	
.floop2	add.l	#8,a1			; Add 8 to address
	dbf	d1,.floop2		; Loop number of times
	
.no2	add.l	#4,a1			; Increase for offset
	
	move.l	(a1),d3			; Move value	
	add.l	a2,d3			; Add address

	move.l	#0,d2			; Expect integer
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it


flength move.l	(a7)+,return		; Save return
	cmp	#2,d0			; 2 parameters?
	bne	syntax			; No, syntax error
	
	bsr	getint			; Get integer
	move.l	d3,a1			; Store bank address
	
	bsr	getint			; Get integer
	move.w	d3,d1			; Store file number
	
	add.l	#2,a1			; Increase a1
	
	cmp	#0,d1			; File 0?
	beq	.no3			; Yes	

	sub.l	#1,d1			; Dec d1
	
.floop3	add.l	#8,a1			; Add 8 to address
	dbf	d1,.floop3		; Loop number of times
	
.no3	move.l	(a1),d3			; Move value	

endoff3	move.l	#0,d2			; Expect integer
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it

* Finito text

fintxt	dc.b	10,13
	dc.b	$15,"** GBP STOS Extension V4.1 SHAREWARE **",$12,10,13
	dc.b	$15,"                                       ",$12,10,13
	dc.b	$15,"  Ok bud..  You've had long enough to  ",$12,10,13
	dc.b	$15,"   have a look at the GBP extension!   ",$12,10,13
	dc.b	$15,"                                       ",$12,10,13
	dc.b	$15," Your STOS basic has now been rendered ",$12,10,13
	dc.b	$15," ************** USELESS ************** ",$12,10,13
	dc.b	$15," You must reset to get back into STOS! ",$12,10,13
	dc.b	$15,"                                       ",$12,10,13
	dc.b	$15," Don't forget to register this program ",$12,10,13
	dc.b	$15," if you want continued use, and to get ",$12,10,13
	dc.b	$15," rid of this little protection routine ",$12,10,13
	dc.b	$15,"                                       ",$12,10,13
	dc.b	$15," >> READ THE DOC FILE FOR MORE INFO << ",$12,10,13 
	dc.b	$15,"                                       ",$12,10,13
	dc.b	$15,"   (C) GBP SOFTWARE & N.HALLIDAY '93   ",$12,10,13,0 
	even
	
mirror
	move.l	(a7)+,return		; Save return
	cmp	#6,d0
	bne	syntax
	bsr	getint
	move.w	d3,d0			; Get Number Of Lines
	bsr	getint
	move.w	d3,d1			; Get Destination Y 
	bsr	getint
	move.l	d3,a1			; Get Destination Address
	bsr	getint
	move.w	d3,d5			; Get Source Y
	bsr	getint
	move.l	d3,a2			; Get Source Address
	bsr	getint
	move.w	d3,d6			; Get Option

	muls.w	#160,d5			; Convert Y pos to Scan Line pos
	add.l	d5,a2			; Add to start address

	cmp	#1,d6			; Function 1?
	beq	normal			; Calculate Normal end Y
	
	cmp 	#2,d6			; Function 2?
	beq	half			; Calculate Half end Y

	cmp	#3,d6			; Function 3?
	beq	double			; Calculate Double end Y 

main
	mulu.w	#160,d1			; y position
	add.l	d1,a1			; Add to Dest Address
	
	movem.l a1-a6/d1-d7,-(a7)
	
	cmp	#2,d6			; Function 2?
	beq	strtb			; Half Size mirror

	cmp	#3,d6			; Function 3?
	beq	strtc			; Double Size mirror

strta					; Normal Size mirror
	MOVEM.L (A2),A3-A6/D1-D7
	MOVEM.L A3-A6/D1-D7,(A1)
	MOVEM.L 44(A2),A3-A6/D1-D7
	MOVEM.L A3-A6/D1-D7,44(A1)
	MOVEM.L 88(A2),A3-A6/D1-D7
	MOVEM.L A3-A6/D1-D7,88(A1)
	MOVEM.L 132(A2),D1-D7 
	MOVEM.L D1-D7,132(A1) 

	LEA     -160(A1),A1
	LEA	160(A2),A2
	DBF     D0,strta

	bra	end_ref

strtb						; Half size mirror
	MOVEM.L (A2),A3-A6/D1-D7
	MOVEM.L A3-A6/D1-D7,(A1)
	MOVEM.L 44(A2),A3-A6/D1-D7
	MOVEM.L A3-A6/D1-D7,44(A1)
	MOVEM.L 88(A2),A3-A6/D1-D7
	MOVEM.L A3-A6/D1-D7,88(A1)
	MOVEM.L 132(A2),D1-D7 
	MOVEM.L D1-D7,132(A1) 

	lea.l	-160(a1),a1			; Move dest up Two Scanline
	lea.l	 320(a2),a2			; Move to source down a scan line
	dbf	d0,strtb 

	bra 	end_ref

strtc						; Double Size mirror
	MOVEM.L (A2),A3-A6/D1-D7
	MOVEM.L A3-A6/D1-D7,(A1)
	MOVEM.L 44(A2),A3-A6/D1-D7
	MOVEM.L A3-A6/D1-D7,44(A1)
	MOVEM.L 88(A2),A3-A6/D1-D7
	MOVEM.L A3-A6/D1-D7,88(A1)
	MOVEM.L 132(A2),D1-D7 
	MOVEM.L D1-D7,132(A1) 
	
	lea.l	-160(a1),a1			; Move dest up two Scan lines

	MOVEM.L (A2),A3-A6/D1-D7
	MOVEM.L A3-A6/D1-D7,(A1)
	MOVEM.L 44(A2),A3-A6/D1-D7
	MOVEM.L A3-A6/D1-D7,44(A1)
	MOVEM.L 88(A2),A3-A6/D1-D7
	MOVEM.L A3-A6/D1-D7,88(A1)
	MOVEM.L 132(A2),D1-D7 
	MOVEM.L D1-D7,132(A1) 

	lea.l	-160(a1),a1
	lea.l    160(a2),a2
	dbf	d0,strtc 

end_ref
	movem.l (a7)+,a1-a6/d1-d7
	move.l  #0,d3	
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it

* For mirror

normal					
	add.w	d0,d1			; Add mirror Size to start Y
	bra 	main

half
	lsr.b	#1,d0			; Divide Size by two
	add.w	d0,d1			; Add it to start Y
	bra	main

print_text				; Print text message

	move	#1,d7			; Printstring
	lea	prot(pc),a0		; Load text
	trap	#3

	move.l	#0,protect		; zero protect routine
	add.l	#1,final		; Add 1 to final value
	rts
	
double
	move.w	d0,d2			; Make a copy of D0
	lsl.b	#1,d2			; Double Size 
	add.w	d2,d1
	bra 	main
	
unpak_tiny:

	move.l	(a7)+,return		; Save return
	cmp	#2,d0			; 2 parameters?
	bne	syntax
	
	bsr	getint			; Get integer
	move.l	d3,a1			; Save destination
	bsr	getint			; Get integer
	move.l	d3,a0			; Save source
	
	bsr	tiny			; de-pack

	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it

* The tiny picture file de-packing code - by axe of delight

tiny:	movem.l	d1-d6/a2-a5,-(sp)
	bsr	t_getpal		; read resolution and palette
	move.l	a4,d5
	move.l	a1,d6
	addi.l	#$7d00,d6
	move.l	a1,d4
	addi.l	#$a0,d4
	bra.s	t17a0a
t179be:	moveq	#0,d0
	move.b	(a5)+,d0
	beq.s	t179ce
	cmpi.b	#1,d0
	beq.s	t179d6
	ext.w	d0
	bra.s	t179de
t179ce:	move.b	(a5)+,d0
	lsl.w	#8,d0
	move.b	(a5)+,d0
	bra.s	t179de
t179d6:	move.b	(a5)+,d0
	lsl.w	#8,d0
	move.b	(a5)+,d0
	neg.w	d0
t179de:	tst.w	d0
	bmi.s	t179ea
	move.b	(a4)+,d3
	lsl.w	#8,d3
	move.b	(a4)+,d3
	bra.s	t17a2e
t179ea:	neg.w	d0
	bra.s	t17a06
t179ee:	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	lea	$9e(a1),a1
	cmpa.l	d6,a1
	blt.s	t17a06
	lea	$ffff8308(a1),a1
	cmp.l	d4,a1
	blt.s	t17a06
	lea	$ffffff62(a1),a1
t17a06:	dbra	d0,t179ee
t17a0a:	cmp.l	d5,a5
	blt.s	t179be
	moveq	#1,d0
t_end:	movem.l	(sp)+,d1-d6/a2-a5
	rts
t17a18:	move.w	d3,(a1)+
	lea	$9e(a1),a1
	cmp.l	d6,a1
	blt.s	t17a2e
	lea	$ffff8308(a1),a1
	cmp.l	d4,a1
	blt.s	t17a2e
	lea	$ffffff62(a1),a1
t17a2e:	dbra	d0,t17a18
	cmpa.l	d5,a5
	blt.s	t179be
	moveq	#1,d0
	movem.l	(sp)+,d1-d6/a2-a5
	rts

* Protection text

prot	dc.b	10,13
	dc.b	"-----------------------------------------",10,13
	dc.b	" >> GBP STOS Extension V4.1 SHAREWARE << ",10,13
	dc.b	"-----------------------------------------",10,13
	dc.b	"   This is an unregistered copy!  Read   ",10,13
	dc.b	"     the doc file for info on how to     ",10,13
	dc.b	"   register with the authors..........   ",10,13
	dc.b	"-----------------------------------------",10,13,0
	dc.b	0	
	even
		
* Find out resolution and palette

t_getpal:

	cmpi.b	#2,(a0)+		; Color mode?
	ble.s	t_color
	addq.l	#4,a0
t_color:
	
	moveq	#31,d0			; install palette
	lea	tinpal(pc),a2

t_copypal:
	
	move.b	(a0)+,(a2)+
	dbra	d0,t_copypal
	move.b	(a0)+,d1
	lsl.w	#8,d1
	move.b	(a0)+,d1
	addq.l	#2,a0
	movea.l	a0,a5			; beginning of Data
	ext.l	d1
	adda.l	d1,a0
	movea.l	a0,a4			; end of Data
	moveq	#1,d0
	rts

tinpal:	ds.w	16

tinypal:
	move.l	(a7)+,return		; Save return

	cmp	#1,d0			; 1 pram?
	bne 	syntax			; No, Syntax error
	
	bsr	getint			; Get integer
	move.l	d3,a0			; Store as address

	movem.l	d1-d6/a2-a5,-(sp)	
	bsr	t_getpal
	movem.l	(sp)+,d1-d6/a2-a5

	lea	tinpal(pc),a2	
	move.l	a2,$45A
	
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it

percent:
	move.l	(a7)+,return		; Save return
	cmp	#2,d0			; 2 params?
	bne	syntax			; No, syntax error
	
	bsr	getint			; Get val2
	move.l	d3,d1			; Store
	
	bsr	getint			; Get val1
	move.l	d3,d0			; Store
	
	move.l	#0,d4			; Zero d4
	move.l	#99,d3			; Loop value
	
addlp:	add.l	d0,d4			; Add val1 to d4
	dbra	d3,addlp		; loop
	
	move.l	#1,d6			; One in d6
	move.l	#0,d5			; Zero d5
	bra	divlp
	
divlp2:	add.l	#1,d6			; Increase Counter

divlp:	add.l	d1,d5			; Add val 1
	cmp	d4,d5
	blo	divlp2			; Loop
	
	move.l	d6,d3			; Store in return value pos
	move.l	#0,d2			; Expect integer

	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it


produce_boot	

	move.l	(a7)+,return		; Save return value
	cmp	#4,d0			; 4 parameters passed?
	bne	syntax			; No, create syntax error
	
	bsr	getint			; Buffer
	move.l	d3,a1			; Save in address reg 1
	
	bsr	getint			; 24bit Serial number
	move.l	d3,a0			; Save in address reg 0
	
	bsr	getint			; Disktype
	move.w	d3,d5			; Save in data reg 5
	
	bsr	getint			; Execflag
	move.w	d3,d4			; Save in data reg 4
	
	move.w	d4,-(sp)		; Execflag
	move.w	d5,-(sp)		; Disktype
	move.l	a0,-(sp)		; Serial number
	move.l	a1,-(sp)		; Buffer
	move.w	#18,-(sp)		; Protobt
	trap	#14			; Call XBIOS
	add.l	#14,sp			; Restore stackpoint
	
	move.l	return,a0		; Load return address
	jmp	(a0)			; Jump to it


special	move.l	(a7)+,return		; Save return
	cmp     #1,d0
	bne     syntax
	
	bsr     getint
	move.w	d3,-(sp)		; Shift status
	move.w	#11,-(sp)		; Function KBSHIFT
	trap	#13			; Call BIOS
	lea	4(sp),sp		; Restore Stack
	
	move.l	d0,d3			; Load to return
	move.w	#0,d2			; Expect integer
	
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it
	
recolour
	move.l	(a7)+,return		; Save return
	cmp	#2,d0			
	bne	syntax
	
	bsr	getint			; Remap values
	move.l	d3,a1			
	
	bsr	getint			; Screen address
	move.l	d3,a0		
	
	cmp.w	#-1,(a0)		; Dummy check to make it look good
	bhi	do_col			; Will always do this

protection				; Protection routine
	
	cmp.l	#3,protect		; Check variable
	bhi	print_text		; Print the text
	
	cmp.l	#10,final		; Has it happend 10 times?
	bhi	finito			; YES...
	
	add.l	#1,protect		; Increase protection counter
	rts		
		
do_col	bsr	x_color			; Call routine
	
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump
	
x_color:
	move.l	#(32000/8)-1,d7
	moveq.w	#0,d4
	move.l	a0,a2
.sloop	moveq	#16-1,d6
.no_mask
	movem.w	(a0)+,d0-d3		; Get 4 planes
.bloop	lsr.w	d3			; Read colour
	roxl	d4
	lsr.w	d2
	roxl	d4
	lsr.w	d1
	roxl	d4
	lsr.w	d0
	roxl	d4
	move.b	0(a1,d4.w),d4		; Get new colour
	lsr.w	d4			; Set new colour
	bcc.s	.plane_0
	or.w	#$8000,d0
.plane_0
	lsr.w	d4
	bcc.s	.plane_1
	or.w	#$8000,d1
.plane_1
	lsr.w	d4
	bcc.s	.plane_2
	or.w	#$8000,d2
.plane_2
	lsr.w	d4
	bcc.s	.plane_3
	or.w	#$8000,d3
.plane_3
	dbf	d6,.bloop
	move.w	d0,(a2)+		; Copy 4 planes back to screen
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.w	d3,(a2)+
	dbf	d7,.sloop
	rts

conv2tos:
	movem.l	a1-a2,-(a7)		; Save registers
	move.l	d3,a1
	move.w	(a1)+,d2		; Get length of string
	move.w	d2,d1			; Save in d1
	move.l	d3,a2
strl1:	move.b	(a1)+,(a2)+		; Create space for chr$(0)
	dbra	d2,strl1		; Loop through string
	move.w	#0,(a2)+		; Copy 0 to end
	movem.l	(a7)+,a1-a2		; Restore registers
	rts
		

getstring:

	move.l	(a7)+,a0		; Save return
	bsr	protection		; Call prot routine
	movem.l	(a7)+,d2-d4		; Get parameter
	tst.b	d2			; Is the argument a string?
	bpl	illegal			; No!
	jmp	(a0)			; Return from routine
	
getint:

	move.l	(a7)+,a0		; Save return
	bsr	protection		; Call prot routine
	move.w	#10,$446		; Harrr!
	movem.l	(a7)+,d2-d4		; Get parameter
	tst.b	d2			; Is it an integer?
	bne	typemis			; No, type mismatch
	jmp	(a0)			; Return

* Errors


eof:	moveq	#64,d0			; Error 64 (End of file)
	bra.s	error			
	
diskerror:

	moveq	#52,d0			; Error 52 (Disk Error)
	bra.s	error
	
badfile:

	moveq	#1,d0			; Error 1 (Bad file format)
	bra.s	error
	
notdone:

	moveq	#0,d0			; Error 0 (Not done)
	bra.s	error

sfailed:
	
	moveq	#5,d0			; Error 5 (Search failed)
	bra.s	error	
fnf:

	moveq	#48,d0			; Error 48 (File not found)
	bra.s	error
	
overflow:

	moveq	#21,d0			; Error 21 (Overflow error)
	bra.s	error

syntax:

	moveq	#12,d0			; Error 12 (Syntax error)
	bra.s	error

typemis:

	moveq	#19,d0			; Error 19 (Type Mismatch)
	bra.s	error

illegal:

	moveq	#13,d0			; Error 13 (Illegal function call)
	
error:

	move.l	system(pc),a0
	move.l	$14(a0),a0
	jmp	(a0)

exit	equ	*

