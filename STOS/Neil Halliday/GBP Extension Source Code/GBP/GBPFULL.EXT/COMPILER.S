* GBP STOS EXTENSION - COMPILER VERSION 4.7
*
* FULL VERSION!
*
* WRITTEN BY NEIL HALLIDAY 1991/92/93/94
* (C) 1994 GBP SOFTWARE LTD.

* SET UP SYSTEM VARIABLES

debut	equ	$92c
error	equ	$93c
flagem	equ	$9a0

* Define extension addresses

start	dc.l	para-start		; parameter definitions
	dc.l	data-start		; reserve data area for program
	dc.l	lib1-start		; start of library
	
catalog	dc.w	lib2-lib1		; length of routine 1  (lights on)
	dc.w	lib3-lib2		; length of routine 2  (pready)
	dc.w	lib4-lib3		; length of routine 3  (lights off)
	dc.w	lib5-lib4		; length of routine 4  (xpen)
	dc.w	lib6-lib5		; length of routine 5  (wipe)
	dc.w	lib7-lib6		; length of routine 6  (paktype)
	dc.w	lib8-lib7		; length of routine 7  (dacvolume)
	dc.w	lib9-lib8		; length of routine 8  (even)
	dc.w	lib10-lib9		; length of routine 9  (setpal)
	dc.w	lib11-lib10		; length of rountie 10 (setprt)
	dc.w	lib12-lib11		; length of routine 11 (d crunch)
	dc.w	lib13-lib12		; length of routine 12 (eplace)
	dc.w	lib14-lib13		; length of routine 13 (unpak deg)
	dc.w	lib15-lib14		; length of routine 14 (foffset)
	dc.w	lib16-lib15		; length of routine 15 (estop)
	dc.w	lib17-lib16		; length of routine 16 (jar)
	dc.w	lib18-lib17		; length of routine 17 (mirror)
	dc.w	lib19-lib18		; length of routine 18 (percent)
	dc.w	lib20-lib19		; length of routine 19 (unpak tny) 
	dc.w	lib21-lib20		; length of routine 20 (paksize)
	dc.w	lib22-lib21		; length of routine 21 (treble)
	dc.w	lib23-lib22		; length of routine 22 (special key)
	dc.w	lib24-lib23		; length of routine 23 (bass)	
	dc.w	lib25-lib24		; length of routine 24 (fstart)
	dc.w	lib26-lib25		; length of routine 25 (hcopy)
	dc.w	lib27-lib26		; length of routine 26 (flength)
	dc.w	lib28-lib27		; length of routine 27 (ca unpack)
	dc.w	lib29-lib28		; length of routine 28 (ca pack)
	dc.w	lib30-lib29		; length of routine 29 (bcls)
	dc.w	lib31-lib30		; length of routine 30 (cookie)
	dc.w	lib32-lib31		; length of routine 31 (eplay)
	dc.w	libex-lib32		; length of routine 32 (ypen)
			
para	dc.w	32			; number of library routines
	dc.w	32			; number of extension commands
	dc.w	lson-para		; offset for lights on
	dc.w	prdy-para		; offset for pready
	dc.w	loff-para		; offset for lights off
	dc.w	xpen-para		; offset for xpen
	dc.w	fwip-para		; offset for fast cls
	dc.w	pkty-para		; offset for paktype
	dc.w	dacv-para		; offset for dac volume
	dc.w	even-para		; offset for even
	dc.w	stal-para		; offset for setpal
	dc.w	sprt-para		; offset for setprt
	dc.w	dcrn-para		; offset for d crunch
	dc.w	eplc-para		; offset for eplace
	dc.w	unde-para		; offset for unpak deg
	dc.w	offs-para		; offset for foffset
	dc.w	estp-para		; offset for estop
	dc.w	cjar-para		; offset for jar
	dc.w	mirr-para		; offset for mirror
	dc.w	perc-para		; offset for percentage
	dc.w	untn-para		; offset for unpak tny
	dc.w	paks-para		; offset for paksize
	dc.w	treb-para		; offset for treble
	dc.w	spec-para		; offset for special key
	dc.w	bass-para		; offset for bass
	dc.w	fsta-para		; offset for fstart
	dc.w	hdcp-para		; offset for hardcopy off
	dc.w	flen-para		; offset for flength
	dc.w	caup-para		; offset for ca_unpack
	dc.w	capk-para		; offset for ca_pack
	dc.w	bcls-para		; offset for bcls
	dc.w	cook-para		; offset for cookie
	dc.w	eply-para		; offset for eplay
	dc.w	ypen-para		; offset for ypen	

* Parameter defininitions

I	equ	0
F	equ	$40
S	equ	$80

* "," forces a comma between any commands
* 1   indicates the end of one set of parameters for an instrucion
* 1,0 indicates the end of the commands entire parameter definition

lson	dc.b	0,1,1,0			; lights on
prdy	dc.b	I,1,1,0			; pready
loff	dc.b	0,1,1,0			; lights off
xpen	dc.b	I,1,1,0			; xpen
fwip	dc.b	0,I,1,1,0		; fastwipe
pkty	dc.b	I,I,1,1,0		; paktype
dacv	dc.b	0,I,1,1,0		; procline
even	dc.b	I,I,1,1,0		; even
stal	dc.b	0,I,1,1,0		; setpal
sprt	dc.b	0,I,1,1,0		; setprt
dcrn	dc.b	0,I,1,1,0		; d crunch
eplc	dc.b	I,1,1,0			; eplace
unde	dc.b	0,I,",",I,1,1,0		; unpak deg
offs	dc.b	I,I,",",I,1,1,0		; foffset
estp	dc.b	0,1,1,0			; estop
cjar	dc.b	I,1,1,0			; jar
mirr	dc.b	0,I,",",I,","
	dc.b	I,",",I,",",I
	dc.b	",",I,1,1,0		; mirror
perc	dc.b	I,I,",",I,1,1,0		; percentage
untn	dc.b	0,I,",",I,1,1,0		; unpak tny
paks	dc.b	I,I,1,1,0		; paksize
treb	dc.b	0,I,1,1,0		; treble
spec 	dc.b	I,I,1,1,0		; special key
bass	dc.b	0,I,1,1,0		; bass
fsta	dc.b	I,I,",",I,1,1,0		; fstart
hdcp	dc.b	0,I,1,1,0		; hardcopy off
flen	dc.b	I,I,",",I,1,1,0		; flength
caup	dc.b	0,I,",",I,1,1,0		; ca unpack
capk	dc.b	I,I,",",I,",",I
	dc.b	",",I,1,1,0		; ca pack
bcls	dc.b	0,I,",",I,1,1,0		; bcls
cook	dc.b	I,S,1,1,0		; cookie
eply	dc.b	0,I,",",I,",",I,","	; eplay
	dc.b	I,",",I,1,1,0
ypen	dc.b	I,1,1,0			; ypen		

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
	move.b	#14,$ff8800		; send info to sound chip
	move.b	$40,$ff8802		; send info to sound chip
	movem.l	(a7)+,a0-a6		; restore registers
	rts
	
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
	move.b	#14,$ff8800		; send info to sound chip
	move.b	#06,$ff8802		; send info to sound chip
	movem.l	(a7)+,a0-a6		; restore registers
	rts

* Xpen

lib4	dc.w	0			; no library calls
	clr.l	d1			; Clear d1
	move.w	$ff9220,d1		; Get value
	andi.w	#1023,d1		; Mask unwanted data
	move.l	d1,-(a6)		; Send to STOS
	rts
	
* Fastwipe

lib5	dc.w	0			; no library calls
	move.l	(a6)+,d1		; get integer
	move.l	d1,a0			; save screen address
	
	include	"h:\gbpfull.ext\includes\fast_cls.s"

	rts

* Paktype

lib6	dc.w	0			; No library calls
	move.l	(a6)+,d0		; Get integer
	move.l	d0,a0			; Store address of file
	
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
	rts

* Dac Volume

lib7	dc.w	0			; no library calls
	move.l	(a6)+,d0		; Volume value
	move.w	#%11111111111,$ff8924	; Set mask value
	move.w	#%10011000000,d1	; Set volume data
	add.w	d0,d1			; Add data
	move.w	d1,$ff8922		; Set volume 
	rts
	
* Even

lib8	dc.w	0			; No library calls
	move.l	(a6)+,d0		; Get integer

* Check number

	btst	#0,d0			; Test bit 0 of d0
	beq	yesev			; Number is even
	
	move.l	#0,d1			; Store false 
	bra	leav			; Branch to leave

yesev	move.l	#-1,d1			; Store true

leav	move.l	d1,-(a6)		; expect integer	
	rts
	
* Setpal

lib9	dc.w	0			; no library calls
	move.l	(a6)+,d3		; get palette address
	move.l	d3,a0			; store as address

	move.l	a0,-(a7)		; palette pointer
	move.w	#6,-(a7)		; setpalette
	trap	#14			; call xbios
	addq.l	#6,a7			; restore stack
	move.l  #0,-(a6)
	rts
	
* Setprt

lib10	dc.w	0			; no library calls
	move.l	(a6)+,d1		; config
	move.w	d1,-(a7)		; config on stack
	move.w	#33,-(a7)		; setprt
	trap	#14
	addq.l	#4,a7			; reset stack
	rts
	
* D crunch

lib11	dc.w	0			; no library calls
	move.l	(a6)+,a0		; address
	
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
	
	rts
	
sped3:	movea.l	a0,a1
	bra	speed3
	rts

	include	'h:\gbpfull.ext\includes\d_crunch.s'

* Eplace

lib12	dc.w	0			; no library calls
	
	move.l	#$ff8908,a0		; Get mixed address value
	move.b	1(a0),d0		; Get high byte
	move.b	3(a0),d1		; Get mid byte
	move.b	5(a0),d2		; Get low byte

	lea	.place,a0
	
	move.b	d0,1(a0)
	move.b	d1,2(a0)
	move.b	d2,3(a0)
	
	move.l	(a0),-(a6)		; Store
	rts
	
.place	ds.l	1
	
* Un pak

lib13	dc.w	0			; no library calls
	move.l	(a6)+,d1		; destination address
	move.l	d1,a1
	move.l	(a6)+,d1		; source address
	move.l	d1,a0
	
	cmpi.b	#$80,(a0)		; check type flag									
	bne	stop			; not compressed

	move.l	a0,-(a7)		; save pointer

	move.l	2(a0),32000(a1)		; Copy palette
	move.l	6(a0),32004(a1)		; To dest
	move.l	10(a0),32008(a1)
	move.l	14(a0),32012(a1)
	move.l	18(a0),32016(a1)
	move.l	22(a0),32020(a1)
	move.l	26(a0),32024(a1)
	move.l	30(a0),32028(a1)
	
	lea	$22(a0),a0		; Pointer to pic data

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
	
	add.l	#2,a1			; bypass header
	
	cmp	#0,d1			; file zero?
	beq	.no			; yes
	
	sub.l	#1,d1			; rectify value
	
.floop	add.l	#8,a1			; add 8 to address
	dbf	d1,.floop		; for d1 times
	
.no	add.l	#4,a1			; increase for file offset

	move.l	(a1),d3			; Move offset value
	move.l	d3,-(a6)		; Into return place
	rts
	
* Estop

lib15	dc.w	0			; no library calls
	move.w	#0,$ff8900		; Start/stop sample
	rts

* Jar 

lib16	dc.w	0			; no library calls
	
	move.l	$5a0,a0			; Does cookie exists
	beq	.no_cookie		; no
	
	move.l	#-1,-(a6)		; True, does exist
	bra	.end
	
.no_cookie	move.l	#0,-(a6)	; False cookie not available
	
.end	rts
	
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
	move.l	a1,(addr)		; save dest addr
	move.l	(a6)+,d1		; get integer
	move.l	d1,a0			; store source address
	bsr	tiny			; de-pack
	rts
	
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
	move.l	(addr),a2
	lea	32000(a2),a2
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

addr	ds.l	1

* Paksize

lib20	dc.w	0			; no library calls
	move.l	(a6)+,a0		; get address
	
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
	rts

* Treble

lib21	dc.w	0			; No library calls
	move.l	(a6)+,d0		; Treble value
	move.w	#%11111111111,$ff8924	; Set mask value
	move.w	#%10010000000,d1	; Set treble data
	add.w	d0,d1			; Add data
	move.w	d1,$ff8922		; Set treble 
	rts

* Special key

lib22	dc.w	0			; No library calls
	move.l	(a6)+,d3		; Save return

	move.w	d3,-(sp)		; Shift status
	move.w	#11,-(sp)		; Function KBSHIFT
	trap	#13			; Call BIOS
	lea	4(sp),sp		; Restore Stack
	
	move.l	d0,-(a6)		; Return value
	rts

* Bass

lib23	dc.w	0			; No library calls
	move.l	(a6)+,d0		; Bass value
	move.w	#%11111111111,$ff8924	; Set mask value
	move.w	#%10001000000,d1	; Set bass data
	add.w	d0,d1			; Add data
	move.w	d1,$ff8922		; Set bass 
	rts

* Fstart

lib24	dc.w	0			; No library calls
	move.l	(a6)+,d1		; get address
	move.l	d1,a1			; store as address
	move.l	(a6)+,d1		; get filenumber
	
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
	rts

* hardcopy off	

lib25	dc.w	0
	move.l	(a6)+,d1
	
	cmp	#1,d1
	beq	turnon
	
	cmp	#0,d1
	beq	turnoff

	rts
	
turnon	move.w	#$FFFF,$4ee
	rts

turnoff	move.w	#2,$4ee
	rts
	
* Flength

lib26	dc.w	0			; no library calls
	move.l	(a6)+,d1		; get address
	move.l	d1,a1			; store as address
	move.l	(a6)+,d1		; get filenumber
	
	add.l	#2,a1			; bypass header
	
	cmp	#0,d1			; file zero?
	beq	.no3			; yes
	
	sub.l	#1,d1			; rectify value
	
.floop3	add.l	#8,a1			; add 8 to address
	dbf	d1,.floop3		; for d1 times
	
.no3	move.l	(a1),d3			; Move offset value
	move.l	d3,-(a6)		; Into return place
	rts

* ca_unpack

lib27	dc.w	0			; No library calls
	move.l	(a6)+,a1		; Destination address
	move.l	(a6)+,a0		; Source address

	movem.l	a0-a1,-(sp)		; Store addresses
	lea	2(a0),a0
		
	bra	get_ca_res		; Picture rez + offset
	
ca_end
	movem.l	(sp)+,a0-a1		; get source & destination address
	
	lea	4(a0),a0		; Start of palette data
	lea	32000(a1),a1		; Destination for palette
	
ca_pal	move.w	(a0)+,(a1)+		; Copy palette over
	dbra	d1,ca_pal		
	rts				; return to stos

* Subroutines

get_ca_res
        cmp.w 	#$102,(a0)			
        beq 	high_rz			; High rez
        
        cmp.w 	#$101,(a0)
        beq 	medium_rz		; Medium rez
        
low_rez
	lea.l	34(a0),a0		; Low rez offset
	move.w	#15,d1			; No. cols for low res
	bra 	ca_start

medium_rz
	lea.l 	10(a0),a0		; Medium rez offset
	move.w	#3,d1			; No. cols for medium res	
	bra 	ca_start

high_rz	lea.l	2(a0),a0		; High rez offset
	move.w	#1,d1			; No. cols for high res

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
	bra	ca_end
	
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

* Crack art picture compacter

lib28	dc.w	0
	move.l	(a6)+,d0		; Resolution
	move.l	(a6)+,a2		; Palette address
	move.l	(a6)+,a1		; Destination address
	move.l	(a6)+,a0		; Source address

	move.w	#$4341,(a1)+		; CA header

	cmp.w	#2,d0
	beq	ca_high
	
	cmp.w	#1,d0
	beq	ca_medium
	
	move.w  #$100,(a1)+		; Low res 
	move.w 	#15,d0			; 16 colours
	move.w	#36,d1
	bra	ca_pal_lop

ca_medium
	move.w	#$101,(a1)+		; medium res
	move.w	#3,d0			; 4 colours
	move.w	#12,d1
	bra	ca_pal_lop
	
ca_high
	move.w	#$102,(a1)+		; high res
	move.w	#0,d0
	move.w	#4,d1
	bra	ca_packstart

ca_pal_lop	
	move.w	(a2)+,(a1)+		; Copy palette over
	dbra	d0,ca_pal_lop
	
ca_packstart:
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
	add.w	d1,d0
	move.l	d0,-(a6)
	rts

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

offset2 dc.l 160,8,80,1,2,4,320,640,480,0
shortest dc.l 0,-1

lib29	dc.w	0		; no library calls
	move.l	(a6)+,d0	; number of lines
	move.l	(a6)+,a0	; get address

.loop	move.w	#0,(a0)		; Clear 160 bytes of data
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
	rts

* Cookie

lib30	dc.w	0
	move.l	(a6)+,a0
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
	
.out	move.l	#-1,-(a6)		; Invalid operation
	bra	.fin			; Branch to end of routine

.correct
	move.l	$5a0,a1			; Get address of cookie jar
	
.loop	move.l	(a1)+,d0		; Identifier
	move.l	(a1)+,d1		; Cookie value
	
	cmp.l	(a0),d0			; Found data yet?
	bne	.loop
	
	move.l	d1,-(a6)
	
.fin	rts
	
** STE play

lib31	dc.w	0
	move.l	(a6)+,d0		; Get playvar 0=stop etc..
	move.l	(a6)+,d1		; Get stereo/mono 1=mono 0=stereo
	move.l	(a6)+,d2		; Get speed 0,1,2,3
	move.l	(a6)+,a0		; Get length of sample
	move.l	(a6)+,a1		; Get start address

	move.w	d0,playmode
	move.w	d1,stereo
	move.b	d2,espeed
	move.l	a0,samlength
	move.l	a1,samstart
	
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
	rts

samlength	ds.l	1
samstart	ds.l	1
stereo		ds.w	1
playmode	ds.w	1
espeed		ds.b	1			; Space for 1 speed byte


* Ypen

lib32	dc.w	0			; no library calls
	clr.l	d1			; Clear d1
	move.w	$ff9222,d1		; Get value
	andi.w	#1023,d1		; Mask unwanted data
	move.l	d1,-(a6)		; Send to STOS
	rts

libex	dc.w	0			; end of library  
