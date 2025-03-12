* STORM/GBP STOS EXTENSION - INTERPRETER VERSION 4.7
*
* WRITTEN BY NEIL HALLIDAY 1991/92/93/94
* (C) 1994 GBP SOFTWARE LTD.
* 
* FULL VERSION!

*
* USAGE:
*
* Lights on     : Turns drive lights A&B on
* Pready        : Is printer on line, true or false?
* Lights off    : Turns drive lights A&B off
* Paktype	: Return what mode file is packed with
* Paksize	: Return the uncompressed length of a file
* Fastwipe	: Fast clear screen
* Dacvolume	: Set the DAC's volume outputs
* Even		: Test if a number is even
* Setpal	: Set palette from a memory bank
* Setprt	: Set printer configuration
* D crunch	: Depack packed files
* Elite unpack	: Unpack a degas elite compressed piccy
* Estop		: Stop an STE sample from being played
* Mirror	: Mirrors a section of the screen...
* Tiny unpack	: Unpack a tiny compressed piccy
* Treble	: Adjust sound treble output
* Bass		: Adjust sound bass output
* Specialkey	: Get the current status of the special keys
* Foffset	: Returns the offset of a file in a GBP Bank
* Fstart	: Returns the start address of a file in a GBP Bank
* Flength	: Returns the length of a file in a GBP Bank
* Hcopy		: Turn the system HARDCOPY (ALT&HELP) on & off
* Ca unpack	: Unpack a Crack Art picture file 
* Ca pack	: Create a Crack Art picture file
* Bcls		: Clear a whole screen on 1 bitplane
* Eplay		: Play a sample under hardware STE interupt
* Eplace	: Return the current position in an STE sample replay 
* Jar		: Return if the cookie jar exists, TRUE/FALSE
* Cookie	: Return the value stored in desired cookie 
* Xpen		: Return x position of the light pen/gun
* Ypen		: Return y position of the light pen/gun
 
	bra	init
	dc.b	128
	
tokens:

	dc.b	"lights on",128
	dc.b	"pready",129
	dc.b	"lights off",130
	dc.b	"xpen",131
	dc.b	"fastwipe",132
	dc.b	"paktype",133
	dc.b	"dac volume",134
	dc.b	"even",135
	dc.b	"setpal",136
	dc.b	"setprt",137
	dc.b	"d crunch",138
	dc.b	"eplace",139
	dc.b	"elite unpack",140
	dc.b	"foffset",141
	dc.b	"estop",142
	dc.b	"jar",143
	dc.b	"mirror",144
	dc.b	"percent",145
	dc.b	"tiny unpack",146
	dc.b	"paksize",147
	dc.b	"treble",148
	dc.b	"special key",149
	dc.b	"bass",150
	dc.b	"fstart",151
	dc.b	"hcopy",152
	dc.b	"flength",153
	dc.b	"ca unpack",154
	dc.b	"ca pack",155
	dc.b	"bcls",156
	dc.b	"cookie",157
	dc.b	"eplay",158
	dc.b	"ypen",159
	dc.b	0
	even
	
jump:
	dc.w	32
	dc.l	lightson
	dc.l	pready
	dc.l	lightsoff
	dc.l	xpen
	dc.l	fastwipe
	dc.l	paktype
	dc.l	dacvolume
	dc.l	teven
	dc.l	setpal
	dc.l	setprt
	dc.l	d_crunch
	dc.l	eplace
	dc.l	elite_unpak
	dc.l	offset
	dc.l	estop
	dc.l	jar
	dc.l	mirror
	dc.l	percent
	dc.l	tiny_unpak
	dc.l	paksize
	dc.l	treble
	dc.l	special
	dc.l	bass
	dc.l	fstart
	dc.l	hardcopy
	dc.l	flength
	dc.l	ca_unpack
	dc.l	ca_pack
	dc.l	bcls
	dc.l	cookie
	dc.l	steplay
	dc.l	ypen

message:


	dc.b	10,$15,"** STORM/GBP Extension V4.7 (c)STORM '94 **",$12,0
	dc.b	10,$15,"** STORM/GBP Extension V4.7 (c)STORM '94 **",$12,0
	dc.b	0
	even
	
system:	dc.l	0
	
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
	
warm:	rts

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

	include	"h:\extensio.ns\gbp\gbpfull.ext\includes\fast_cls.s"

	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it


** Dac volume
	
dacvolume:
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 3 parameters?
	bne	syntax			; No, syntax error

	bsr	getint			; Volume
	move.w	d3,d1	

	move.w	#%11111111111,$ff8924	; Set mask
	move.w	#%10011000000,d2
	add.w	d1,d2			; Add m volume data
	move.w	d2,$ff8922		; Set m volume data
	
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
	
	include	'h:\extensio.ns\gbp\gbpfull.ext\includes\d_crunch.s'

elite_unpak:
	move.l	(a7)+,return		; Save return
	cmp	#2,d0			; 2 parameters
	bne	syntax			; No, syntax error
	bsr	getint			; Get integer
	move.l	d3,a1			; Save dest address
	bsr	getint			; Get integer
	move.l	d3,a0			; Save source address
	
	cmpi.b	#$80,(a0)		; check type flag									
	bne	notdone			; not compressed
	
	move.l	2(a0),32000(a1)		; Copy palette
	move.l	6(a0),32004(a1)		; To dest
	move.l	10(a0),32008(a1)
	move.l	14(a0),32012(a1)
	move.l	18(a0),32016(a1)
	move.l	22(a0),32020(a1)
	move.l	26(a0),32024(a1)
	move.l	30(a0),32028(a1)

	move.l	a0,-(a7)		; save pointer
	move.l 	a1,-(a7)
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

	movea.l (a7)+,a1
	movea.l	(a7)+,a0
	addq.l	#2,a0			; pointer to palette
	lea	32000(a1),a1

	move.w	#15,d0
palloop
	move.w	(a0)+,(a1)+
	dbra	d0,palloop
	
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it

** Xpen, get the x position of the light pen input

xpen:
	move.l	(a7)+,return		; Save return
	clr.l	d1
	move.w	$ff9220,d1		; Get x position
	andi.w	#1023,d1		; Mask data
	move.l	d1,d3
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


** Estop
	
estop	move.l	(a7)+,return		; Save return
	move.w	#0,$ff8900		; Start/stop sample
	move.l	return,a0
	jmp	(a0)			; Jump to it


** Set printer

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
	movem.l (a2),a3-a6/d1-d7
	movem.l a3-a6/d1-d7,(a1)
	movem.l 44(a2),a3-a6/d1-d7
	movem.l a3-a6/d1-d7,44(a1)
	movem.l 88(a2),a3-a6/d1-d7
	movem.l a3-a6/d1-d7,88(a1)
	movem.l 132(a2),d1-d7 
	movem.l d1-d7,132(a1) 

	lea     -160(a1),a1
	lea	160(a2),a2
	dbf     D0,strta

	bra	end_ref

strtb						; Half size mirror
	movem.l (a2),a3-a6/d1-d7
	movem.l a3-a6/d1-d7,(a1)
	movem.l 44(a2),a3-a6/d1-d7
	movem.l a3-a6/d1-d7,44(a1)
	movem.l 88(a2),a3-a6/d1-d7
	movem.l a3-a6/d1-d7,88(a1)
	movem.l 132(a2),d1-d7 
	movem.l d1-d7,132(a1) 

	lea.l	-160(a1),a1			; Move dest up Two Scanline
	lea.l	 320(a2),a2			; Move to source down a scan line
	dbf	d0,strtb 

	bra 	end_ref

strtc						; Double Size mirror
	movem.l (a2),a3-a6/d1-d7
	movem.l a3-a6/d1-d7,(a1)
	movem.l 44(a2),a3-a6/d1-d7
	movem.l a3-a6/d1-d7,44(a1)
	movem.l 88(a2),a3-a6/d1-d7
	movem.l a3-a6/d1-d7,88(a1)
	movem.l 132(a2),d1-d7 
	movem.l d1-d7,132(a1) 

	lea.l	-160(a1),a1			; Move dest up two Scan lines

	movem.l (a2),a3-a6/d1-d7
	movem.l a3-a6/d1-d7,(a1)
	movem.l 44(a2),a3-a6/d1-d7
	movem.l a3-a6/d1-d7,44(a1)
	movem.l 88(a2),a3-a6/d1-d7
	movem.l a3-a6/d1-d7,88(a1)
	movem.l 132(a2),d1-d7 
	movem.l d1-d7,132(a1) 

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

double
	move.w	d0,d2			; Make a copy of D0
	lsl.b	#1,d2			; Double Size 
	add.w	d2,d1
	bra 	main
	
tiny_unpak:

	move.l	(a7)+,return		; Save return
	cmp	#2,d0			; 2 parameters?
	bne	syntax
	
	bsr	getint			; Get integer
	move.l	d3,a1			; Save destination
	move.l	a1,(addr)
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

* Find out resolution and palette

t_getpal:

	cmpi.b	#2,(a0)+		; Color mode?
	ble.s	t_color
	addq.l	#4,a0
t_color:
	
	moveq	#31,d0			; install palette
	move.l	(addr),a2		; Memory bank
	lea	32000(a2),a2		; Increase for palette

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

addr	ds.l	1

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


** Treble

treble:

	move.l	(a7)+,return		; Save return value
	cmp	#1,d0			; 4 parameters passed?
	bne	syntax			; No, create syntax error
	
	bsr	getint			; Buffer
	move.w	d3,d1			; Save
	
	move.w	#%11111111111,$ff8924	; Set mask
	move.w	#%10010000000,d2
	add.w	d1,d2			; Add treble data
	move.w	d2,$ff8922		; Set treble data
	
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

** Bass, set STE bass

bass:	move.l	(a7)+,return		; Save return
	cmp	#1,d0			
	bne	syntax
		
	bsr	getint			; Buffer
	move.w	d3,d1			; Save
	
	move.w	#%11111111111,$ff8924	; Set mask
	move.w	#%10001000000,d2
	add.w	d1,d2			; Add bass data
	move.w	d2,$ff8922		; Set bass data

	move.l	return,a0		; Load return
	jmp	(a0)			; Jump


** Hardcopy, set system hardcopy on/off

hardcopy
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 param??
	bne	syntax
	bsr	getint
	
	cmp	#1,d3
	beq	turnon
	
	cmp	#0,d3
	beq	turnoff
	
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it

turnoff	move.w	#2,$4ee			; Turn off
	rts
	
turnon	move.w	#$FFFF,$4ee		; Turn on
	rts
	

ca_unpack
        move.l	(a7)+,return		; Save return
	cmp     #2,d0
	bne     syntax

	bsr     getint
	move.l	d3,a1			; Destination address
	bsr     getint
	move.l	d3,a0			; Source address

	movem.l	a0-a1,-(sp)		; Store addresses
	
	cmp.w 	#'CA',(a0)+		; Is it a crack-art picture
	bne	endmain			; no.

	bsr	get_ca_res		; Picture rez + offset
	
	bsr 	ca_start		; Call unpack picture

	movem.l	(sp)+,a0-a1		; get source & destination address
	
	lea	4(a0),a0		; Start of palette data
	lea	32000(a1),a1		; Destination for palette
	
ca_pal	move.w	(a0)+,(a1)+		; Copy palette over
	dbra	d1,ca_pal		
	
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it

get_ca_res
        cmp.w 	#$102,(a0)			
        beq 	high_rz			; High rez
        
        cmp.w 	#$101,(a0)
        beq 	medium_rz		; Medium rez
        
low_rez
	lea.l	34(a0),a0		; Low rez offset
	move.w	#15,d1			; No. cols for low res
	bra 	ca_return

medium_rz
	lea.l 	10(a0),a0		; Medium rez offset
	move.w	#3,d1			; No. cols for medium res	
	bra 	ca_return

high_rz	lea.l	2(a0),a0		; High rez offset
	move.w	#1,d1			; No. cols for high res

ca_return
	rts				; return from from subroutine

ca_start        
	movem.l	d1-a6,-(sp)		; Store the registers
        movea.l a1,a2			; copy Destination address
        lea     32000(a1),a3

        clr.w   d7
        clr.w   d6
        move.b  (a0)+,d7      ; ESC
        move.b  (a0)+,d6      ; DELTA

        move.w  (a0)+,d0      ; Offset
        and.l   #$7fff,d0
        movea.l d0,a5

        move.b  d6,d1         ; DELTA in Langwoerter bringen
        lsl.w   #8,d1
        move.b  d6,d1
        move.w  d1,d2
        swap    d1
        move.w  d2,d1
        move.l  d1,d2
        move.l  d1,d3
        move.l  d1,d4
        move.l  d1,d5

        movea.l a3,a6         ; Ziel mit DELTA fuellen
        move.w  #1599,d0
delta:  movem.l d1-d5,-(a6)
        dbra    d0,delta

        move.l    a5,d0         ; Offset
        subq.w    #1,d0         ; Durchlaeufe
        bmi.s     endmain
main1:   
	clr.w     d1
        move.b    (a0)+,d1      ; Erstes Byte holen
        cmp.b     d7,d1
        beq.s     esccode

writeone:
	move.b    d1,(a2)       ; Wenn kein ESC, dann gleich schreiben
        adda.l    a5,a2
        cmpa.l    a3,a2
        blt.s     main1
        addq.l    #1,a1
        movea.l   a1,a2
        dbra      d0,main1

endmain:
	movem.l	(sp)+,d1-a6
	rts
	
; Hier wurde ein ESC gefunden

esccode:
        move.b    (a0)+,d1      ; zweites Byte
        cmp.b     d7,d1
        beq.s     writeone      ; ESC schreiben

        tst.b     d1            ; COMP0
        bne.s     code1
        clr.w     d2            ; ESC 00 ANZAHL-1 BYTE
        move.b    (a0)+,d2      ; Anzahl 3-255 ist bedeutet 4-256
        move.b    (a0)+,d1      ; gleiche Bytes
loop0:  move.b    d1,(a2)
        adda.l    a5,a2
        cmpa.l    a3,a2
        blt.s     drin0
        addq.l    #1,a1
        movea.l   a1,a2
        subq.w    #1,d0         ; Ueberschlag gemacht
        bmi.s     endmain
drin0:  dbra      d2,loop0
        bra.s     main1

code1:  cmpi.b    #1,d1         ; COMP1
        bne.s     code2
        clr.w     d2            ; ESC 01 MULT REST-1 BYTE
        clr.w     d3
        move.b    (a0)+,d3      ; Multiplikator
        lsl.w     #8,d3
        move.b    (a0)+,d2      ; Anzahl 1-256
        add.w     d3,d2
        move.b    (a0)+,d1      ; komprimiertes Byte
loop1:  move.b    d1,(a2)
        adda.l    a5,a2
        cmpa.l    a3,a2
        blt.s     drin1
        addq.l    #1,a1
        movea.l   a1,a2
        subq.w    #1,d0         ; Ueberschlag gemacht
        bmi.s     endmain
drin1:  dbra      d2,loop1
        bra.s     main1

code2:  cmpi.b    #2,d1         ; SAME
        bne.s     multiple      ; Komprimiert 3<n<=256
        clr.w     d3
        move.b    (a0)+,d3      ; Multiplikator
        beq.s     endmain       ; Abbruchcode ESC 02 00
        lsl.w     #8,d3
        clr.w     d2            ; ESC 02 MULT REST-1
        move.b    (a0)+,d2      ; Anzahl 1-256
        add.w     d3,d2
loop2:  adda.l    a5,a2         ; DELTAs 'schreiben'
        cmpa.l    a3,a2
        blt.s     drin2
        addq.l    #1,a1
        movea.l   a1,a2
        subq.w    #1,d0         ; Ueberschlag gemacht
        bmi.s     endmain
drin2:  dbra      d2,loop2
        bra       main1

multiple:
	clr.w     d2            ; ESC ANZAHL-1 BYTE
        move.b    (a0)+,d2      ; Byte
loop3:  move.b    d2,(a2)
        adda.l    a5,a2
        cmpa.l    a3,a2
        blt.s     drin3
        addq.l    #1,a1
        movea.l   a1,a2
        subq.w    #1,d0         ; Ueberschlag gemacht
        bmi       endmain
drin3:  dbra      d1,loop3
        bra       main1

ca_pack
        move.l	(a7)+,return		; Save return
	cmp	#4,d0
	bne     syntax

	bsr	getint
	move.l	d3,d0			; Resolution
	bsr	getint
	move.l  d3,a2			; Palette address
	bsr     getint
	move.l	d3,a1			; Destination address
	bsr     getint
	move.l	d3,a0			; Source address
	
	bsr	ca_header		; Set up header information
	
; modified slightly to make it work from within STOS

        movem.l d1-a6,-(sp)
	movem.l a0-a1,-(sp)

        movea.l a1,a2           ; Platz fr die Byteh„ufigkeit vorbereiten
        move.w  #255,d0
init2   clr.w   (a2)+
        dbra    d0,init2

        movea.l a0,a2           ; Byteh„ufigkeit z„hlen
        move.w  #31999,d0       ; 32000 Bytes pro Bildschirm
zaehl:  clr.w   d1
        move.b  (a2)+,d1        ; Byte vom Quellbildschirm
        add.w   d1,d1
        addq.w  #1,0(a1,d1.w)   ; wortweise reicht
        dbra    d0,zaehl

; Das seltenste Byte finden, von hinten suchen, damit die Wahrscheinlichkeit,
; daž das ESC Byte mit dem Anzahl-Z„hler bereinstimmt, geringer wird
; (ESC 0 Anzahl-1 Byte) soll so selten wie m”glich auftreten

        movea.l a1,a2           ; Minimum finden
        lea     512(a2),a2      ; an das Ende der Z„hler
        move.w  #32500,d1       ; Minimum vorbelegen
        move.w  #252,d0         ; Bytes 0,1,2 sind reservierte Codes
minimum:
	move.w  -(a2),d2
        cmp.w   d1,d2           ; mit bisherigem Minimum vergleichen
        bge.s   nextmin         ; das erste Minimum behalten
        move.w  d0,d3           ; Z„hler merken
        move.w  d2,d1           ; neues Minimum merken
        beq.s   minend          ; d1=0 kein kleinerer Wert moeglich
nextmin:
        dbra    d0,minimum
minend: addq.w  #3,d3           ; das ist das Esc Byte
        move.w  d3,d7           ; ESC Byte merken

        movea.l a1,a2           ; Maximum finden
        move.w  #-1,d1          ; Maximum vorbelegen
        move.w  #255,d0
maximum:
	move.w  (a2)+,d2
        cmp.w   d1,d2           ; mit bisherigem Maximum vergleichen
        ble.s   nextmax         ; bei gleichh„ufigen Bytes das erste nehmen
                                ; damit ESC und DELTA niemals gleich sein koennen
        move.w  d0,d3           ; Z„hler merken
        move.w  d2,d1           ; neues Maximum merken
nextmax:        
	dbra    d0,maximum
        neg.w   d3
        addi.w  #255,d3         ; das ist das DELTA Byte
        move.w  d3,d6           ; DELTA Byte merken


; ======== Hier beginnt der Kompressionsalgorithmus

        movea.l (sp),a0       	; Quelladresse
        lea     32000(a0),a2    ; Endadresse

        move.w  #32000,d4       ; Vergleichsl„nge
        lea     offset2(pc),a6  ; Offsetliste

while:  movea.l (a6)+,a5        ; Offset holen
        cmpa.l  #0,a5
        beq.s   endwhile        ; Offset=0 ist Abbruchkriterium
        cmpa.l  #-1,a5
        beq.s   endprg          ; -1 ist Programmende

        movem.l (sp),a0/a3    	; Quelle/Ziel
        movea.l a0,a1           ; Workadresse
        move.b  d7,(a3)+        ; ESC auf Zielbildschirm merken
        move.b  d6,(a3)+        ; DELTA uebertragen
        move.w  a5,(a3)+        ; Offset
        move.w  #4,d3           ; L„nge des komprimierten Bildes
                                ; ESC.b + DELTA.b + Offset.w
        move.l  a5,d0           ; Offset als
        subq.w  #1,d0           ; Durchlaufz„hler

mainloop:
        tst.w   d0
        bmi.s   endcode         ; neuer Offset
        move.b  (a1),d1         ; erstes Byte holen
        clr.w   d2              ; gleiche Bytes z„hlen
testloop:                       ; N„chste Adresse errechnen
        adda.l  a5,a1           ; Offset addieren
        cmpa.l  a2,a1           ; Hinter dem Bildschirmende ?
        blt.s   nextok          ; wenn nicht, dann weiter
        addq.l  #1,a0           ; sonst Quelladresse einen weiter
        movea.l a0,a1           ; und neue Workadresse
        subq.w  #1,d0           ; ein šberschlag
        bmi.s   compress        ; Ende der Kompression anzeigen
nextok:
        cmp.b   (a1),d1
        bne.s   compress        ; Reihe abgebrochen
        addq.w  #1,d2
        bra.s   testloop

endcode:
  	addq.w  #1,d3           ; Code: ESC 2 0  (Endekennung)
        cmp.w   d4,d3
        bge.s   while
        move.b  d7,(a3)+        ; ESC
        addq.w  #1,d3
        cmp.w   d4,d3
        bge.s   while
        move.b  #2,(a3)+        ; 2
        addq.w  #1,d3
        cmp.w   d4,d3
        bge.s   while
        clr.b   (a3)+           ; 0

        move.w  d3,d4           ; neue L„nge
        move.l  a5,d5           ; Offset merken
        bra.s   while           ; und weiter

endwhile:
        cmp.w   #32000,d4
        bge.s   endprg
        move.w  #32000,d4
        lea     shortest(pc),a6
        move.l  d5,(a6)
        move.l  #-1,4(a6)
        bra.s   while

endprg: moveq   #0,d0
        move.w  d4,d0           ; L„nge des komprimierten Bildes
	
	movem.l (sp)+,a0-a1
        movem.l (sp)+,d1-a6
	move.l	d0,d3
	add.w	d1,d3
	move.w	#0,d2
	move.l	return,a0
	jmp	(a0)

; ========================================================= compress
; In d1.b ist das Byte, in d2.w die Anzahl
compress:
        tst.w   d0
        bpl.s   intern
        cmp.b   d6,d1           ; DELTA
        beq.s   endcode

intern: cmp.b   d7,d1
        bne.s   noesc

compesc:
	addq.w  #1,d3           ; Code: ESC ESC
        cmp.w   d4,d3
        bge     while           ; n„chste Kompression
        move.b  d7,(a3)+
        addq.w  #1,d3
        cmp.w   d4,d3
        bge     while
        move.b  d7,(a3)+
        dbra    d2,compesc      ; L„nge erh”hen
        bra     mainloop        ; und weiter

noesc:  cmp.w   #2,d2
        bgt.s   more            ; mehr als 3 Bytes gleich
uncomp: addq.w  #1,d3           ; Code: Byte
        cmp.w   d4,d3
        bge     while
        move.b  d1,(a3)+        ; Byte
        dbra    d2,uncomp
        bra     mainloop

more:   cmp.w   #255,d2
        bgt.s   evenmore
        addq.w  #1,d3           ; Code: ESC Anzahl-1 Byte
        cmp.w   d4,d3           ; oder: ESC 0 Anzahl-1 Byte
        bge     while
        move.b  d7,(a3)+        ; ESC
        cmp.b   d7,d2           ; zuf„llig Anzahl-1 = ESC ?
        bne.s   morenorm
        addq.w  #1,d3
        cmp.w   d4,d3
        bge     while
        clr.b   (a3)+           ; 00
morenorm:
        addq.w  #1,d3
        cmp.w   d4,d3
        bge     while
        move.b  d2,(a3)+        ; Anzahl-1
        addq.w  #1,d3
        cmp.w   d4,d3
        bge     while
        move.b  d1,(a3)+        ; Byte
        bra     mainloop

evenmore: 
        cmp.b   d6,d1           ; DELTA ?
        beq.s   moredelta
        addq.w  #1,d3           ; Code: ESC 1 Mult Rest-1 Byte
        cmp.w   d4,d3
        bge     while
        move.b  d7,(a3)+        ; ESC
        addq.w  #1,d3
        cmp.w   d4,d3
        bge     while
        move.b  #1,(a3)+        ; 1
        addq.w  #1,d3
        cmp.w   d4,d3
        bge     while
        movea.w d2,a4           ; sichern
        lsr.w   #8,d2           ; div 256
        move.b  d2,(a3)+        ; Mult
        addq.w  #1,d3
        cmp.w   d4,d3
        bge     while
        move.w  a4,d2
        and.w   #255,d2
        move.b  d2,(a3)+        ; Rest-1
        addq.w  #1,d3
        cmp.w   d4,d3
        bge     while
        move.b  d1,(a3)+        ; Byte
        bra     mainloop

moredelta:
        addq.w  #1,d3           ; Code: ESC 2 Mult Rest-1
        cmp.w   d4,d3
        bge     while
        move.b  d7,(a3)+
        addq.w  #1,d3
        cmp.w   d4,d3
        bge     while
        move.b  #2,(a3)+
        addq.w  #1,d3
        cmp.w   d4,d3
        bge     while
        movea.w d2,a4           ; sichern
        lsr.w   #8,d2           ; div 256
        move.b  d2,(a3)+
        addq.w  #1,d3
        cmp.w   d4,d3
        bge     while
        move.w  a4,d2
        and.w   #255,d2
        move.b  d2,(a3)+
        bra     mainloop

ca_header
	move.w	#$4341,(a1)+		; CA header

	cmp.w	#2,d0
	beq	ca_high
	
	cmp.w	#1,d0
	beq	ca_medium
	
	move.w  #$100,(a1)+		; Low res (for now!)
	move.w 	#15,d0			; 16 colours
	move.w	#36,d1
	jmp	ca_pal_lop

ca_medium
	move.w	#$101,(a1)+		; medium res
	move.w	#3,d0			; 4 colours
	move.w	#12,d1
	jmp	ca_pal_lop
	
ca_high
	move.w	#$102,(a1)+		; high res
	move.w	#4,d1
	rts

ca_pal_lop	
	move.w	(a2)+,(a1)+		; Copy palette over
	dbra	d0,ca_pal_lop
	rts

offset2 dc.l 160,8,80,1,2,4,320,640,480,0

shortest: dc.l 0,-1

bcls:	move.l	(a7)+,return		; Save return
	cmp	#2,d0			; Only 1 param
	bne	syntax			; Not even 1?

	bsr	getint			; Number of lines
	move.w	d3,d0
		
	bsr	getint			; Address of screen
	move.l	d3,a0			; 

.loop	move.w	#0,(a0)			; Clear 160 bytes of data
	move.w	#0,8(a0)
	move.w	#0,16(a0)
	move.w	#0,24(a0)
	move.w	#0,32(a0)
	move.w	#0,40(a0)
	move.w	#0,48(a0)
	move.w	#0,56(a0)
	move.w	#0,64(a0)
	move.w	#0,72(a0)
	move.w	#0,80(a0)
	move.w	#0,88(a0)
	move.w	#0,96(a0)
	move.w	#0,104(a0)
	move.w	#0,112(a0)
	move.w	#0,120(a0)
	move.w	#0,128(a0)
	move.w	#0,136(a0)
	move.w	#0,144(a0)
	move.w	#0,152(a0)
	lea	160(a0),a0
	dbf	d0,.loop
		
	move.l	return,a0		; Return to stos
	jmp	(a0)

** STE play

steplay	move.l	(a7)+,return		; Save return
	cmp	#5,d0			; 5 Params?
	bne	syntax
	
	bsr	getint			; Get playmode 0=stop,1=playone
	move.w	d3,playmode		; 3=loop
	
	bsr	getint			; Get stereo/mono 1=mono 0=stereo
	move.w	d3,stereo
	
	bsr	getint			; Get speed 0,1,2,3
	move.b	d3,espeed
	
	bsr	getint			; Get length of sample
	move.l	d3,samlength
	
	bsr	getint			; Get start address
	move.l	d3,samstart
	

	move.w	stereo,d0	
	mulu	#$80,d0			; Normalize stereo/mono mode
	move.w	d0,stereo
	
	move.w	#0,d0			; Combine frequency and mode
	move.b	espeed,d0		; Save frequency
	move.w	stereo,d1		; Save mono/stereo $80 = mono 
	or.w	d1,d0			; Combine data
	move.w	d0,$ff8920		; Store in DAC MODE address

	move.l	samstart,d0		; Store start address
	move.l	samstart,d1
	add.l	samlength,d1		; Create end address
	
	move.l	#$ff8902,a2		; Get frame start HIGH byte
	movep.w	d0,3(a2)		; Store mid & low bytes
	swap	d0			; Reverse data
	move.b	d0,1(a2)		; Store high byte
	
	move.l	#$ff890e,a2		; Get frame end HIGH byte
	movep.w	d1,3(a2)		; Store mid & low bytes
	swap	d1			; Reverse data
	move.b	d1,1(a2)		; Store high byte	

	move.w	playmode,$ff8900	; Start/stop sample
	
	move.l	return,a0		; Return to STOS
	jmp	(a0)

samlength	ds.l	1
samstart	ds.l	1
stereo		ds.w	1
playmode	ds.w	1
espeed		ds.b	1			; Space for 1 speed byte

** Eplace

eplace	move.l	(a7)+,return		; Save return
	
	move.l	#$ff8908,a0		; Get mixed address value
	move.b	1(a0),d0		; Get high byte
	move.b	3(a0),d1		; Get mid byte
	move.b	5(a0),d2		; Get low byte

	lea	.place,a0
	
	move.b	d0,1(a0)
	move.b	d1,2(a0)
	move.b	d2,3(a0)
	
	move.l	(a0),d3			; Store
	move.w	#0,d2			; Tell STOS to expect number
	
	move.l	return,a0
	jmp	(a0)			; Back to STOS

.place	ds.l	1

** Jar

jar	move.l	(a7)+,return		; Save return
	
	move.l	$5a0,a0			; Does cookie exists
	beq	.no_cookie		; no
	
	move.l	#-1,d3			; True, does exist
	bra	.end
	
.no_cookie	move.l	#0,d3		; False cookie not available
	
.end	move.w	#0,d2			; Tell STOS to expect variable
	move.l	return,a0
	jmp	(a0)			; Back to STOS

** Cookie

cookie	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter?
	bne	syntax			; No, syntax error
	
	bsr	getstring		; Get string
	move.l	d3,a0			; Save address of string
	move.w	(a0)+,d3		; Get length of string
	cmp	#4,d3			; String 4 bytes long?
	bne	.out			; No, out of routine, signal error 
	
	cmpi.l	#"_CPU",(a0)		; Processor type
	beq	.correct		; Valid
	
	cmpi.l	#"_VDO",(a0)		; Video shifter type
	beq	.correct		; Valid
	
	cmpi.l	#"_SND",(a0)		; Sound chips present
	beq	.correct		; Valid
	
	cmpi.l	#"_MCH",(a0)		; Machine type
	beq	.correct		; Valid
	
	cmpi.l	#"_SWI",(a0)		; Config switches
	beq	.correct		; Valid
	
	cmpi.l	#"_FRB",(a0)		; Fast ram Buffer
	beq	.correct		; Valid
	
.out	move.l	#-1,d3			; Invalid operation
	bra	.fin			; Branch to end of routine

.correct
	move.l	$5a0,a1			; Get address of cookie jar
	
.loop	move.l	(a1)+,d0		; Identifier
	move.l	(a1)+,d1		; Cookie value
	
	cmp.l	(a0),d0			; Found data yet?
	bne	.loop
	
	move.l	d1,d3
	
.fin	move.l	#0,d2			; Expect an integer
	move.l	return,a0		; Load return
	jmp	(a0)			; Back to STOS
	
	
** Ypen, get the y position of the light pen input

ypen:
	move.l	(a7)+,return		; Save return
	clr.l	d1
	move.w	$ff9222,d1		; Get y position
	andi.w	#1023,d1		; Mask data
	move.l	d1,d3
	move.w	#0,d2			; Tell stos to expect integer
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it


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
	movem.l	(a7)+,d2-d4		; Get parameter
	tst.b	d2			; Is the argument a string?
	bpl	illegal			; No!
	jmp	(a0)			; Return from routine
	
getint:

	move.l	(a7)+,a0		; Save return
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

