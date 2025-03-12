* GBP STOS EXTENSION - COMPILER VERSION 4.2
*
* FULL VERSION!
*
* WRITTEN BY NEIL HALLIDAY 1991/92/93
* (C) 1993 GBP SOFTWARE LTD.

* SET UP SYSTEM VARIABLES

device	equ	$446			; Compiler protection
debut	equ	$92c
error	equ	$93c
gemflag	equ	$9a0

* Define extension addresses

start	dc.l	para-start		; parameter definitions
	dc.l	data-start		; reserve data area for program
	dc.l	lib1-start		; start of library
	
catalog	dc.w	lib2-lib1		; length of routine 1  (lights on)
	dc.w	lib3-lib2		; length of routine 2  (pready)
	dc.w	lib4-lib3		; length of routine 3  (lights off)
	dc.w	lib5-lib4		; length of routine 4  (hardscrl)
	dc.w	lib6-lib5		; length of routine 5  (wipe)
	dc.w	lib7-lib6		; length of routine 6  (paktype)
	dc.w	lib8-lib7		; length of routine 7  (procline)
	dc.w	lib9-lib8		; length of routine 8  (even)
	dc.w	lib10-lib9		; length of routine 9  (setpal)
	dc.w	lib11-lib10		; length of rountie 10 (setprt)
	dc.w	lib12-lib11		; length of routine 11 (d crunch)
	dc.w	lib13-lib12		; length of routine 12 (pc palt)
	dc.w	lib14-lib13		; length of routine 13 (unpak deg)
	dc.w	lib15-lib14		; length of routine 14 (foffset)
	dc.w	lib16-lib15		; length of routine 15 (holdkey)
	dc.w	lib17-lib16		; length of routine 16 (tny pal)
	dc.w	lib18-lib17		; length of routine 17 (mirror)
	dc.w	lib19-lib18		; length of routine 18 (percent)
	dc.w	lib20-lib19		; length of routine 19 (unpak tny) 
	dc.w	lib21-lib20		; length of routine 20 (paksize)
	dc.w	lib22-lib21		; length of routine 21 (produce boot)
	dc.w	lib23-lib22		; length of routine 22 (special key)
	dc.w	lib24-lib23		; length of routine 23 (recolour)	
	dc.w	lib25-lib24		; length of routine 24 (fstart)
	dc.w	lib26-lib25		; length of routine 25 (DUMMY)
	dc.w	libex-lib26		; length of routine 26 (flength)
			
para	dc.w	26			; number of library routines
	dc.w	26			; number of extension commands
	dc.w	lson-para		; offset for lights on
	dc.w	prdy-para		; offset for pready
	dc.w	loff-para		; offset for lights off
	dc.w	hard-para		; offset for hardscrl
	dc.w	fwip-para		; offset for fast cls
	dc.w	pkty-para		; offset for paktype
	dc.w	proc-para		; offset for procline
	dc.w	even-para		; offset for even
	dc.w	stal-para		; offset for setpal
	dc.w	sprt-para		; offset for setprt
	dc.w	dcrn-para		; offset for d crunch
	dc.w	palt-para		; offset for pc palt
	dc.w	unde-para		; offset for unpak deg
	dc.w	offs-para		; offset for foffset
	dc.w	hold-para		; offset for holdkey
	dc.w	tnyp-para		; offset for tny pal
	dc.w	mirr-para		; offset for mirror
	dc.w	perc-para		; offset for percentage
	dc.w	untn-para		; offset for unpak tny
	dc.w	paks-para		; offset for paksize
	dc.w	prod-para		; offset for produce boot
	dc.w	spec-para		; offset for special key
	dc.w	reco-para		; offset for recolour
	dc.w	fsta-para		; offset for fstart
	dc.w	DMMY-para		; offset for DUMMY
	dc.w	flen-para		; offset for flength
	
* Parameter defininitions

I	equ	0
F	equ	$40
S	equ	$80

* "," forces a comma between any commands
* 1   indicates the end of one set of parameters for an instrucion
* 1,0 indicates the end of the commands entire parameter definition

lson	dc.b	0,1,1,0			; dummy for lights on
prdy	dc.b	I,1,1,0			; pready
loff	dc.b	0,1,1,0			; dummy for lights off
hard	dc.b	I,I,",",I,1,1,0		; hardscrl
fwip	dc.b	0,I,1,1,0		; fastwipe
pkty	dc.b	I,I,1,1,0		; paktype
proc	dc.b	0,I,1,1,0		; procline
even	dc.b	I,I,1,1,0		; even
stal	dc.b	0,I,1,1,0		; setpal
sprt	dc.b	0,I,1,1,0		; setprt
dcrn	dc.b	0,I,1,1,0		; d crunch
palt	dc.b	0,I,1,1,0		; pc palt
unde	dc.b	0,I,",",I,1,1,0		; unpak deg
offs	dc.b	I,I,",",I,1,1,0		; foffset
hold	dc.b	0,I,1,1,0		; holdkey
tnyp	dc.b	0,I,1,1,0		; tny pal
mirr	dc.b	0,I,",",I,","
	dc.b	I,",",I,",",I
	dc.b	",",I,1,1,0		; mirror
perc	dc.b	I,I,",",I,1,1,0		; percentage
untn	dc.b	0,I,",",I,1,1,0		; unpak tny
paks	dc.b	I,I,1,1,0		; paksize
prod	dc.b	0,I,",",I,",",I
	dc.b	",",I,1,1,0		; produce boot
spec 	dc.b	I,I,1,1,0		; special key
reco	dc.b	0,I,",",I,1,1,0		; recolour
fsta	dc.b	I,I,",",I,1,1,0		; fstart
DMMY	dc.b	0,1,1,0			; DUMMY
flen	dc.b	I,I,",",I,1,1,0		; flength

* End of parameter definition

	even
	
* Initialisation section
* This code is loaded into memory during initialisation
* It can be accessed using address placed in the DEBUT variable

data	bra	init

init	lea	end(pc),a2		; load position of end into A2
	rts
	
end	rts

* Extension library

* Lights on, Turn lights on

lib1	dc.w	0			; no library calls
	movem.l	a0-a6,-(a7)		; save registers
	
	cmp	#10,device		; Run from interpreter?
	bne	exlib1			; No, quitty!
	
	move.b	#14,$ff8800		; send info to sound chip
	move.b	$40,$ff8802		; send info to sound chip

exlib1	movem.l	(a7)+,a0-a6		; restore registers
	rts				; Save registers				
	
* Pready

lib2	dc.w	0			; no library calls
	moveq	#0,d1			; zero d1
	move.w	#0,-(a7)		; printer ready?
	move.w	#8,-(a7)		; bcostat
	trap	#13			; call bios
	addq.l	#4,a7			; reset stack
	move.l	d0,d1			; result in d1
	move.l	d1,-(a6)		; return an integer
	rts

* Lights off

lib3	dc.w	0			; no library calls
	movem.l	a0-a6,-(a7)		; save registers
	cmp	#10,device		; Run from interpreter?
	bne	exlib3			; No, quitty!
	move.b	#14,$ff8800		; send info to sound chip
	move.b	#06,$ff8802		; send info to sound chip
exlib3	movem.l	(a7)+,a0-a6		; restore registers
	rts

* Hardscrl

lib4	dc.w	0			; no library calls
	move.l	(a6)+,d1		; get integer
	move.l	d1,d2			; save function
	move.l	(a6)+,d1		; get integer
	move.l	d1,a0			; save screen address
	
	cmp	#1,d2			; check function
	beq	yup			; increase
	
	sub.l	#1280,a0		; decrease by 1280 bytes
	bra	fin
		
yup	add.l	#1280,a0		; increase by 1280 bytes

fin	move.l	a0,d1			; save new address in d1
	move.l	d1,-(a6)		; new address on stack
	rts
	
* Fastwipe

lib5	dc.w	0			; no library calls
	move.l	(a6)+,d1		; get integer
	move.l	d1,a0			; save screen address
	
	cmp	#10,device		; Run from interpreter?
	bne	exlib5			; No, quitty!

	include	"a:\source\includes\fast_cls.s"

exlib5	rts

* Paktype

lib6	dc.w	0			; No library calls
	move.l	(a6)+,d0		; Get integer
	move.l	d0,a0			; Store address of file
	
	cmp	#10,device		; Run from interpreter?
	bne	exlib6			; No, quitty!

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
	
	cmp.l   #'SPv3',(a0)		; Speed V3.0
	beq	spd3
	
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
	bra.s	ret
	
spd3	move.l	#7,d3			; Speed v3
	
ret	move.l	d3,d1			; store in d1
	move.l	d1,-(a6)		; d1 on stack
exlib6	rts

* Procline

lib7	dc.w	0			; no library calls
	move.l	(a6)+,d0		; get integer from stack
	
	lea	$ff8240,a0		; Load address
	move.w	(a0),d1			; Store old value
	move.w	d0,(a0)			; Load new colour
	move.w	d1,(a0)			; Load old colour	

	rts
	
* Even

lib8	dc.w	0			; No library calls
	move.l	(a6)+,d0		; Get integer

	cmp	#10,device		; Run from interpreter?
	bne	exlib8			; No, quitty!

* Check number

	btst	#0,d0			; Test bit 0 of d0
	beq	yesev			; Number is even
	
	move.l	#0,d1			; Store false 
	bra	leav			; Branch to leave

yesev	move.l	#-1,d1			; Store true

leav	move.l	d1,-(a6)		; expect integer	
exlib8	rts
	
* Setpal

lib9	dc.w	0			; no library calls
	move.l	(a6)+,d3		; get palette address
	move.l	d3,a0			; store as address

	cmp	#10,device		; Run from interpreter?
	bne	exlib9			; No, quitty!
	
	move.l	a0,-(a7)		; palette pointer
	move.w	#6,-(a7)		; setpalette
	trap	#14			; call xbios
	addq.l	#6,a7			; restore stack
	move.l  #0,-(a6)
exlib9	rts
	
* Setprt

lib10	dc.w	0			; no library calls
	move.l	(a6)+,d1		; config

	cmp	#10,device		; Run from interpreter?
	bne	exlib10			; No, quitty!

	move.w	d1,-(a7)		; config on stack
	move.w	#33,-(a7)		; setprt
	trap	#14
	addq.l	#4,a7			; reset stack
exlib10	rts
	
* D crunch

lib11	dc.w	0			; no library calls
	move.l	(a6)+,a0		; address

	cmp	#10,device		; Run from interpreter?
	bne	exlib11			; No, quitty!
	
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
	
	cmp.l	#'SPv3',(a0)
	beq	sped3
	
exlib11	rts
	
sped3:	movea.l	a0,a1
	bra	speed3
	rts

	include	'a:\source\includes\d_crunch.s'

* Pc palt

lib12	dc.w	0			; no library calls
	move.l	(a6)+,d1		; get integer
	move.l	d1,a0			; save as address
	
	cmp	#10,device		; Run from interpreter?
	bne	exlib12			; No, quitty!

	addq.l	#2,a0			; add 2 to address
	
	move.l	a0,-(a7)		; palette pointer
	move.w	#6,-(a7)		; setpalette
	trap	#14			; call xbios
	addq.l	#6,a7			; restore stack
	move.l  #0,-(a6)
exlib12	rts				; return
	
* Un pak

lib13	dc.w	0			; no library calls
	move.l	(a6)+,d1		; destination address
	move.l	d1,a1
	move.l	(a6)+,d1		; source address
	move.l	d1,a0
	
	cmp	#10,device		; Run from interpreter?
	bne	stop			; No, quitty!

	cmpi.b	#$80,(a0)		; check type flag									
	bne	stop			; not compressed

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

stop	rts

* Offset

lib14	dc.w	0			; no library calls
	move.l	(a6)+,d1		; get address
	move.l	d1,a1			; store as address
	move.l	(a6)+,d1		; get filenumber
	
	cmp	#10,device		; Run from interpreter?
	bne	exlib14			; No, quitty!

	add.l	#2,a1			; bypass header
	
	cmp	#0,d1			; file zero?
	beq	.no			; yes
	
	sub.l	#1,d1			; rectify value
	
.floop	add.l	#8,a1			; add 8 to address
	dbf	d1,.floop		; for d1 times
	
.no	add.l	#4,a1			; increase for file offset

	move.l	(a1),d3			; Move offset value
	move.l	d3,-(a6)		; Into return place
exlib14	rts
	
* Holdkey

lib15	dc.w	0			; no library calls
	move.l	(a6)+,d1		; ascii code
check	bsr	keypress		; call routine
	cmp	d1,d0			; is it correct?
	beq	yep			; yes
	bsr	check
yep	rts

keypress
	move	#8,-(a7)		; function 8
	trap	#1			; call Gem
	addq.l	#2,a7			; restore stack
	rts				; return

* Tny pal

lib16	dc.w	0			; no library calls
	move.l	(a6)+,d1		; get source bank
	move.l	d1,a0			; store address

	cmp	#10,device		; Run from interpreter?
	bne	exlib16			; No, quitty!

	movem.l	d1-d6/a2-a5,-(sp)

upt_getpal:
	cmpi.b	#2,(a0)+		; Color mode?
	ble.s	upt_color
	addq.l	#4,a0
upt_color:
	lea	tnypal(pc),a1
	move.w	#15,d1
upt_copypal:
	move.w	#0,d0
	move.b	(a0)+,d0
	mulu	#256,d0
	add.b	(a0)+,d0
	move.w	d0,(a1)+
	dbf	d1,upt_copypal		; Past col reg 0?
	
	movem.l	(sp)+,d1-d6/a2-a5

	lea	tnypal(pc),a0	
	move.l	a0,-(a7)		; palette pointer
	move.w	#6,-(a7)		; setpalette
	trap	#14			; call xbios
	addq.l	#6,a7			; restore stack
	
	move.l  #0,-(a6) 
exlib16	rts

tnypal	ds.w	16
	
* mirror

lib17	dc.w	0			; no library calls
	move.l	(a6)+,d0		; Get Number Of Lines
	move.l	(a6)+,d1		; Get Destination Y 
	move.l	(a6)+,a1		; Get Destination Address
	move.l	(a6)+,d5		; Get Source Y
	move.l	(a6)+,a2		; Get Source Address
	move.l	(a6)+,d6		; Get Option

	muls.w	#160,d5			; Convert Y pos to Scan Line pos
	add.l	d5,a2			; Add to start address

	cmp	#1,d6			; Function 1?
	beq	normal			; Calculate Normal end Y
	
	cmp 	#2,d6			; Function 2?
	beq	half			; Calculate Half end Y

	cmp	#3,d6			; Function 3?
	beq	double			; Calculate Double end Y 

main
	muls.w	#160,d1			; y position
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
	rts

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
	
* Percentage

lib18	dc.w	0			; no library calls
	move.l	(a6)+,d1
	move.l	(a6)+,d0
	
	move.l	#0,d4			; Zero d4
	move.l	#99,d3			; Loop value
	
addlp:	add.l	d0,d4			; Add val1 to d4
	dbra	d3,addlp		; loop
	
	move.l	#1,d6			; One in d6
	move.l	#0,d5			; Zero d5
	bra	divlp
	
divlp2:	add.l	#1,d6			; Increase Counter

divlp:	add.l	d1,d5			; add val 1
	cmp	d4,d5
	blo	divlp2			; Loop
	
	move.l	d6,-(a6)		; Store in return value pos
	rts
	
* Unpak tny

lib19	dc.w	0			; no library calls

	move.l	(a6)+,d1		; get integer
	move.l	d1,a1			; store dest address
	move.l	(a6)+,d1		; get integer
	move.l	d1,a0			; store source address
	
	cmp	#10,device		; Run from interpreter?
	bne	exlib19			; No, quitty!

	bsr	tiny			; de-pack
exlib19	rts
	
* The de-packing code !

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

* find out resolution and palette

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
	movea.l	a0,a5		; beginning of Data
	ext.l	d1
	adda.l	d1,a0
	movea.l	a0,a4		; end of Data
	moveq	#1,d0
	rts

tinpal:	ds.w	16

* Paksize

lib20	dc.w	0			; no library calls
	move.l	(a6)+,a0		; get address
	
	cmp	#10,device		; Run from interpreter?
	bne	exlib20			; No, quitty!

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
	
	cmp.l	#'SPv3',(a0)
	beq	spd2
	
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
	
ret2	move.l	d3,-(a6)		; Store num
exlib20	rts

* Produce boot

lib21	dc.w	0			; no library calls
	move.l	(a6)+,a1		; Buffer
	move.l	(a6)+,a0		; 24 Bit serial number
	move.w	(a6)+,d5		; Disktype
	move.w	(a6)+,d4		; Execflag

	move.w	d4,-(sp)		; Execflag
	move.w	d5,-(sp)		; Disktype
	move.l	a0,-(sp)		; Serial number
	move.l	a1,-(sp)		; Buffer
	move.w	#18,-(sp)		; Protobt
	trap	#14			; Call XBIOS
	add.l	#14,sp			; Restore stackpoint
	rts

* Special key

lib22	dc.w	0			; No library calls
	move.l	(a6)+,d3		; Save return

	cmp	#10,device		; Run from interpreter?
	bne	exlib22			; No, quitty!

	move.w	d3,-(sp)		; Shift status
	move.w	#11,-(sp)		; Function KBSHIFT
	trap	#13			; Call BIOS
	lea	4(sp),sp		; Restore Stack
	
	move.l	d0,-(a6)		; Return value
exlib22	rts

* Recolour

lib23	dc.w	0			; No library calls
	move.l	(a6)+,d3		; address of remap values
	move.l	d3,a1
	move.l	(a6)+,d3		; screen address
	move.l	d3,a0			
	
	bsr	x_color			; call routine
	
	rts
	
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

* Fstart

lib24	dc.w	0			; No library calls
	move.l	(a6)+,d1		; get address
	move.l	d1,a1			; store as address
	move.l	(a6)+,d1		; get filenumber
	
	cmp	#10,device		; Run from interpreter?
	bne	exlib24			; No, quitty!

	move.l	a1,a2			; copy address
	add.l	#2,a1			; bypass header
	
	cmp	#0,d1			; file zero?
	beq	.no2			; yes
	
	sub.l	#1,d1			; rectify value
	
.floop2	add.l	#8,a1			; add 8 to address
	dbf	d1,.floop2		; for d1 times
	
.no2	add.l	#4,a1			; increase for file offset

	move.l	(a1),d3			; Move offset value
	add.l	a2,d3			; Add address to find start
	
	move.l	d3,-(a6)		; Into return place
exlib24	rts
	
* DUMMY ROUTINE

lib25	dc.w	0			; No library calls
	rts
	
* Flength

lib26	dc.w	0			; no library calls
	move.l	(a6)+,d1		; get address
	move.l	d1,a1			; store as address
	move.l	(a6)+,d1		; get filenumber
	
	cmp	#10,device		; Run from interpreter?
	bne	exlib26			; No, quitty!

	add.l	#2,a1			; bypass header
	
	cmp	#0,d1			; file zero?
	beq	.no3			; yes
	
	sub.l	#1,d1			; rectify value
	
.floop3	add.l	#8,a1			; add 8 to address
	dbf	d1,.floop3		; for d1 times
	
.no3	move.l	(a1),d3			; Move offset value
	move.l	d3,-(a6)		; Into return place
exlib26	rts

libex	dc.w	0			; end of library  
