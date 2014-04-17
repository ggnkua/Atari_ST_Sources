******************************  colorep.s  ************************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/colorep.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/01/24 18:44:53 $     $Locker:  $
* =============================================================================
*
* $Log:	colorep.s,v $
* Revision 3.1  91/01/24  18:44:53  lozben
* Adjusted the code to work with the multiple linea variable structure.
* 
* Revision 3.0  91/01/03  15:06:33  lozben
* New generation VDI
* 
* Revision 2.4  90/03/01  11:32:22  lozben
* Moved STE equate into vdiincld.s file.
* 
* Revision 2.3  90/02/26  17:38:12  lozben
* Fixed the code to work with turbo assembler.
* 
* Revision 2.2  89/04/13  19:54:15  lozben
* Added conditional for st+. We now have more bits per gun to play with
* 
* Revision 2.1  89/02/21  17:18:38  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************

.include	"lineaequ.s"
.include	"vdiincld.s"

		.globl	_st_vs_color
		.globl	_st_vq_color
		.globl _INTIN,_INTOUT,_CONTRL,_v_planes,_REQ_COL,_MAP_COL

ifeq PAL4096
FIRST_INT	equ	67
LAST_INT	equ	934
endc

ifne PAL4096
INTERVAL	equ	143		; 1000/7
FIRST_INT	equ	142
LAST_INT	equ	858
ROUND_UP	equ	72		; INTERVAL/2
endc



LUT_ADDR	equ	$FF8240		; lookup table address

_st_vs_color:
	move.l  _lineAVar,a2		; a2 -> linea var struct
	movem.w	d3-d4,-(sp)		; save d3
	move.l	_INTIN(a2),a0
	move.w	(a0)+,d0		; d0 <- color index
	move.w	_v_planes(a2),d1	; a0 -> first intensity component

	move.b	max_ndx-1(pc,d1.w),d4	; is index in range?
	cmp.b	d4,d0
	bhi	vsc_out

	move.w	d0,d2
	mulu	#6,d2			; d2 <- offset into lut save areas

	lea	_REQ_COL(a2),a1
	add.w	d2,a1			; a1 -> component for given index (requePAL4096d)

	subq.w	#1,d1			; d1 <- # planes - 1
	beq	monochrome		; don't deal with monochrome case


*
*	color lookup table format	xxxx xRRR xGGG xBBB
*


	moveq.l	#2,d3			; process three intensities
	moveq.l	#0,d1			; initialize the color accumulator.

lut_loop:

	moveq.l	#0,d2
	move.w	(a0)+,d2
	move.w	d2,(a1)+		; save the set component %
	bge	hi_check

	clr.w	d2			; intensity < 0%  =>  intensity = min (0)

hi_check:

	cmp.w	#1000,d2
	ble	in_bounds
	move.w	#1000,d2		; intensity > 100% => max intensity


ifeq PAL4096
in_bounds:
	mulu	#15,d2			; do the numerator first
	add.w	#500,d2			; round up
	divu	#1000,d2		; d2 <- round(% * 15)
endc

ifne PAL4096
in_bounds:
	add.w	#ROUND_UP,d2		; round up
	divu	#INTERVAL,d2		; section off into 0 thru 7 (15 for ST+)
endc

	asl.w	#4,d1			; make room for new component

ifeq PAL4096
	move.w	d5,-(sp)
	move.w	d2,d5			; d4 <- color xxxx
	andi.w	#1,d5			; isolate least significant bit
	asl.w	#3,d5			; d4 <- 0xxx (ST+ has rotated nibles in luts)
	asr.w	#1,d2			; d2 <- x321 (lut entry shifted by one)
	or.w	d5,d2			; d2 <- color (bit order 0321)
	move.w	(sp)+,d5
endc

	or.w	d2,d1			; insert new component

	dbra	d3,lut_loop		; process next component


*
*	insert value into lookup table
*

into_lut:
	lea	_MAP_COL, a0		; Convert color index to a pel value,
	add.w	d0, d0			; this is the real lut entry we want
	move.w	(a0, d0.w), d0		; to stuff.

	and.b	d4, d0			; Limit to max pel value.

	lea	LUT_ADDR,a0		; a0 -> lookup table
	add.w	d0,d0			; index into word wide table
	move.w	d1,(a0,d0.w)		; load color into indexed slot in lut
	movem.w	(sp)+,d3-d4		; restore d3/d4
	rts


max_ndx:

	dc.b	1,3,0,15		; maximum index value for given resolution

*   funky monochrome case
*
*   the real color is always background:white  foreground:black
*
*

monochrome:

	move.w	(a0)+,d1		; transfer requested red comp.
	move.w	d1,(a1)+
	bsr	monopercent
	move.w	d1,d2

	move.w	(a0)+,d1		; transfer requested green comp.
	move.w	d1,(a1)+
	bsr	monopercent
	add.w	d1,d2

	move.w	(a0)+,d1		; transfer requested blue comp.
	move.w	d1,(a1)+
	bsr	monopercent
	add.w	d1,d2

	beq	monolut			; branch if black requested.
	cmp.w	#3000,d2
	bne	vsc_out
mononeg:
	not.w	d0			; fall through, if white requested.
monolut:
	move.w	d0,LUT_ADDR		; set the DRI KLUDGE bit.

vsc_out:
	movem.w	(sp)+,d3-d4		; restore d3/d4
	rts

monopercent:
	cmp.w	#FIRST_INT,d1		; 0?
	blt	mp0			; yes, branch.
	cmp.w	#LAST_INT,d1		; no, 7?
	blt	mp_out			; no, branch.
	move.w	#1000,d1		; yes, 1000.
mp_out:
	rts
mp0:
	moveq	#0,d1			; 0.
	rts






_st_vq_color:
	move.l  _lineAVar,a2		; a2 -> linea var struct
	move.l	d4,-(sp)
	move.l	_CONTRL(a2),a0
	move.w	#4,8(a0)		; contrl(4) <- length of intout array = 4

	move.l	_INTIN(a2),a0
	move.w	(a0)+,d0		; d0 <- color index
	move.w	(a0),d2			; d2 <- color value format flag

	move.l	_INTOUT(a2),a0		; a0 -> output array

	move.w	_v_planes(a2),d1		
	move.b	max_ndx-1(pc,d1.w),d4	; is index in range?
	cmp.b	d4, d0			; is index in range?
	bls	in_range

	move.w	#-1,(a0)		; intout(0) <- -1 (index out of range)
	bra	vqc_out


in_range:

	move.w	d0,(a0)+		; intout(0) <- color index

	tst.w	d2			; d2:0 => return realized color
	bne	vqc_real

	lea	_REQ_COL(a2),a1
	mulu	#6,d0			; d0 <- offset to color components
	add.w	d0,a1			; a1 -> saved color components for given index

	move.w	(a1)+,(a0)+		; intout(1) <- set red %
	move.w	(a1)+,(a0)+		; intout(2) <- set green %
	move.w	(a1),(a0)		; intout(3) <- det blue %
vqc_out:
	move.l	(sp)+, d4
	rts


vqc_real:
	subq.w	#1,d1			; monochrome?
	beq	vqc_mono		; yes, special case.

	lea	_MAP_COL, a1		; Convert color index to a pel value,
	add.w	d0, d0			; this is the real lut entry we want
	move.w	(a1, d0.w), d0		; to stuff.

	and.b	d4, d0			; Limit to max pel value.

	lea	LUT_ADDR,a1		; point to hardware look-up table.
	add.w	d0,d0			; word indexing.
	move.w	0(a1,d0.w),d0		; fetch RGB value.
	rol.w	#5,d0			; align R field to high nybble and word index.
	moveq	#2,d1			; loop 3 times.

vqcr_lp:
	rol.w	#4,d0			; put color field into low nyble.
	move.w	d0,d2			; d2 <- XXXX XXXX XXX0 321X col component

ifeq PAL4096
	move.w	d2,d4			; d4 <- XXXX XXXX XXX0 321X col component
	andi.w	#$e,d2			; d2 <- ____ ____ ____ 321_ col component
	asr.w	#4,d4			; d4 <- XXXX XXXX XXXX XXX0 col component
	andi.w	#1,d4			; d4 <- ____ ____ ____ ___0 col component
	or.w	d4,d2			; d2 <- ____ ____ ____ 3210 bits are proper
	add.w	d2,d2			; make d2 a word index
endc

ifne PAL4096
	and.w	#$000E,d2		; mask off other fields. (word indexing)
endc
	move.w	pcnt_tab(pc,d2.w),(a0)+ ; load INTOUT with percent*10.
	dbra	d1,vqcr_lp
	bra	vqc_out


vqc_mono:
	move.w	LUT_ADDR,d1
	eor.w	d1,d0			; decode the DRI bit ^ color index.
	moveq	#0,d1			; percent*10 = 0.
	btst	#0,d0
	beq	vqcm_cont
	move.w	#1000,d1		; yes, percent*10 = 1000.

vqcm_cont:
	move.w	d1,(a0)+		; load INTOUT.
	move.w	d1,(a0)+
	move.w	d1,(a0)
	bra	vqc_out	


ifeq PAL4096
pcnt_tab:
	dc.w	0000,0067,0133,0200,0267,0333,0400,0467
	dc.w	0533,0600,0667,0733,0800,0867,0933,1000
endc

ifne PAL4096
pcnt_tab:
	dc.w	0000,0142,0285,0428,0571,0714,0857,1000
endc

	end
