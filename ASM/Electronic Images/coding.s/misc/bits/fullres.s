;
		output c:\auto\tv_to_vga.prg

; SetVideo() equates.

VERTFLAG_BIT	EQU $0008	
STMODES_BIT	EQU $0007	
OVERSCAN_BIT	EQU $0006	
PAL_BIT		EQU $0005	
VGA_BIT		EQU $0004	
COL80_BIT	EQU $0003	
VERTFLAG	EQU $0100	; double-line on VGA, interlace on ST/TV ;
STMODES		EQU $0080	; ST compatible ;
OVERSCAN	EQU $0040	; Multiply X&Y rez by 1.2, ignored on VGA ;
PAL		EQU $0020	; PAL if set, else NTSC ;
VGA		EQU $0010	; VGA if set, else TV mode ;
COL80		EQU $0008	; 80 column if set, else 40 column ;
BPS16		EQU $0004
BPS8		EQU $0003
BPS4		EQU $0002
BPS2		EQU $0001
BPS1		EQU $0000



; Falcon video register equates

vwrap           EQU $FFFF8210
_spshift        EQU $FFFF8266
hht             EQU $FFFF8282
hbb             EQU $FFFF8284
hbe             EQU $FFFF8286
hdb             EQU $FFFF8288
hde             EQU $FFFF828A
hss             EQU $FFFF828C
hfs             EQU $FFFF828E
hee             EQU $FFFF8290
vft             EQU $FFFF82A2
vbb             EQU $FFFF82A4
vbe             EQU $FFFF82A6
vdb             EQU $FFFF82A8
vde             EQU $FFFF82AA
vss             EQU $FFFF82AC
vco             EQU $FFFF82C2

progstart:	move.l	#$100,d5
		addi.l	#progend,d5
		subi.l	#progstart,d5
		pea	start_text(pc)
		move.w	#9,-(a7)
		trap	#1
		addq.w	#6,a7
		move.w	#$59,-(a7)
		trap	#14
		addq.w	#2,a7
		btst	#0,d0
		bne	l13C6FA
		clr.l	-(a7)
		move.w	#$20,-(a7)
		trap	#1
		move.l	d0,2(a7)
		move.l	$B8.w,l13C832
		move.l	#l13C836,$B8.w
		trap	#1
		addq.w	#6,a7
		clr.w	-(a7)
		move.l	d5,-(a7)
		move.w	#$31,-(a7)
		trap	#1

l13C6FA		pea	wrong_mon(pc)
		move.w	#9,-(a7)
		trap	#1
		addq.w	#6,a7
		clr.w	-(a7)
		trap	#1

		DC.L 	"XBRA"
		DC.L	"TVGA"

l13C832		dc.l	0
l13C836		move.l	usp,a0
		btst	#5,(a7)
		beq	l13C850
		lea	6(a7),a0
		tst.w	$59E.w
		beq	l13C850
		lea	8(a7),a0
l13C850		move.w	(a0),d0
l13C864		cmpi.w	#$58,d0
		bne.s	.notvid
		lea	handle_setvideo_exit(pc),a1
		move.w	2(a0),d0
		btst	#VGA_BIT,d0	;	
		bne.s	.GO		; leave VGA modes as they are
		bclr	#PAL_BIT,d0	; clear PAL(TV)
		bset	#VGA_BIT,d0	; FORCE VGA
		bchg	#VERTFLAG_BIT,d0 ; toggle interlace/double line.
		move.w	d0,2(a0)
		bra.s	.GO

.notvid:	cmpi.w	#$59,d0
		bne.s	.handlenone
		lea	handle_getmonit_exit(pc),a1
.GO:		move.l	$C(a0),-(a7)
		move.l	8(a0),-(a7)
		move.l	4(a0),-(a7)
		move.l	(a0),-(a7)
		tst.w	$59E.w
		beq	.not020
		clr.w	-(a7)
.not020:	pea	(a1)
		move	sr,-(a7)
.handlenone:	move.l	l13C832,-(a7)
		rts


handle_setvideo_exit:
		lea	$10(a7),a7
		rte
handle_getmonit_exit:
		lea	$10(a7),a7
		moveq	#3,d0		; return TV monitor
		rte


start_text:	DC.B	10,13,"TV to VGA By GRIFF September 1994.",10,13,10,13,0
wrong_mon:	DC.B	"This program is for VGA only!",10,13,0
		even
progend:
		

