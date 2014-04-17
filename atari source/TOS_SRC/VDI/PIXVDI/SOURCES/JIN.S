***********************************  jin.s  ***********************************
*
* $Revision: 3.3 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/jin.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/08/06 14:14:48 $     $Locker:  $
* =============================================================================
*
* $Log:	jin.s,v $
* Revision 3.3  91/08/06  14:14:48  lozben
* Made some changes to the xbios trap handler. We now preserve the
* registers that the caller needs to be preserved.
* 
* Revision 3.2  91/07/29  14:46:34  lozben
* Made adjustments in vdi_check().
* 
* Revision 3.1  91/02/19  15:29:43  lozben
* Made the file work with multiple linea var structures.
* 
* Revision 3.0  91/01/03  15:11:56  lozben
* New generation VDI
* 
* Revision 2.7  90/04/30  18:07:29  lozben
* Fixed a bug in CursConf(). It did not cleanup the stack.
* 
* Revision 2.6  90/04/27  15:09:10  lozben
* Trap 2 handler now handles code of -1 in d0. This call returns the
* address of _GSX_ENTRY. It's an undocumented call (GDOS uses it).
* 
* Revision 2.5  90/03/01  11:31:04  lozben
* Moved TT equate into vdiincld.s file.
* 
* Revision 2.4  90/02/16  12:22:58  lozben
* Fixed some of the code so that it can be assembled with mas.
* 
* Revision 2.3  89/10/26  15:27:42  lozben
* Added SetShift() for the TT. This routine must be intercepted
* to call esc_init().
* 
* Revision 2.2  89/04/13  19:47:48  lozben
* Fixed SetScreen() to set rez before going back to the old
* guy (original XBIOS trap vector). Also added equate for TT.
* 
* Revision 2.1  89/02/21  17:23:11  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************

.include	"vdiincld.s"

	.globl	_FindDevice
	.globl	_SetCurDevice
	.globl	_GSX_ENTRY
	.globl	line1010		; for LINE "A".  MSH  4/23/85
	.globl	_asc_out		; raw con out
	.globl	conout
	.globl	_GETBLT
	.globl	_SETBLT
	.globl	blink
	.globl	_jmptb2			; jump table for second set of GDP'S
	.globl	myvq_key_s
	.globl	_VsetRGB

TRAP2		=	$88
TRAP14		=	$B8
LINEA		=	$28

*--- look under "soft" console vectors for system vars
CONOUT		=	$586		; "soft" conout vector
ASCIIOUT	=	$592		; "soft" _asc_out vector
SSHIFTMD	=	$44c		; soft shadow reg

TTSHIFTMD	=	$ff8262		; TT shift mode register

GEMDOS		=	$01
CCONWS		=	$09
SUPER		=	$20
PTERMRES	=	$31

XBIOS		=	$0E
LOGBASE		=	$03
GETREZ		=	$04
SETSCREEN	=	$05
CURSCONF	=	$15
BLITMODE	=	$40


gin:	move.w	d0,-(sp)		; doesn't matter what value
	clr.w	-(sp)			; function - hide cursor
	move.w	#CURSCONF,-(sp)		; push func #
	trap	#XBIOS
	addq.l	#6,sp			; clean stack

*   Go into supervisor mode

	clr.l	-(sp)
	move.w	#SUPER,-(sp)
	trap	#GEMDOS
	addq.l	#6,sp			; d0 -> original user stack
	move.l	d0,-(sp)		; Build return to user mode on stack

	move.l	#conout,CONOUT		; set so that BCONOUT uses soft vdi
	move.l	#_asc_out,ASCIIOUT	; set so that BCONOUT uses to soft vdi

	move.l	#line1010,LINEA		; init the LINE "A" vector.

	move.l	TRAP2,old_vdi		; save old trap 2 vector
	move.l	#vdi_check,TRAP2	; install VDI vector
	move.l	TRAP14,old_xbios	; save old trap 14 vector
	move.l	#xbios_check,TRAP14	; install XBIOS vector

	moveq.l	#0,d1			; clear upper bits
	move.b	SSHIFTMD,d1		; d1 <- current rez (TT, ST modes)
	cmp.w	#3,d1			; see if we are in sparrow mode
	beq	gin0			; if so do sparrow device init
	addq.w	#2,d1			; d1 <- device id
	move.w	d1,-(sp)		; pass parameter on the stack
	jsr	_FindDevice		; find device
	addq.w	#2,sp			; cleanup stack
	jsr	esc_init		; go to escape init
	bra	gin1

gin0:	move.w	#-1,-(sp)		; get current video mode
	move.w	#3,-(sp)		; make sure its the mode call
	move.l	#-1,-(sp)		; don't change physbase/logbase
	move.l	#-1,-(sp)		; "	"	"	"
	move.w	#SETSCREEN,-(sp)	; push funct #
	trap	#XBIOS			; do the xbios call
	add.w	#14,sp			; cleanup stack

	move.w	d0,-(sp)		; push current mode on stack
	move.w	#3,-(sp)		; make sure its the mode call
	move.l	#-1,-(sp)		; don't change physbase/logbase
	move.l	#-1,-(sp)		; "	"	"	"
	move.w	#SETSCREEN,-(sp)	; push funct #
	trap	#XBIOS			; do the xbios call
	add.w	#14,sp			; cleanup stack

*   Go back to user mode

gin1:	move.l	_vblqueue,a0		; insert the blink routine
	move.l	#blink,4(a0)		;    as second entry in the queue

	move.w	#SUPER,-(sp)
	trap	#GEMDOS			; return to user mode
	addq.l	#6,sp			; clean super mode call off the stack

*+
* Install our function that returns Shift, Control, Alt State
* remember we are not linked in with bios so we must do this
* because we don't have direct access to var 'kbshift'
*-
	move.l	#myvq_key_s,_jmptb2+112	; where adr of old vq_key_s() used to be

* Convert the address of the entry point to a string

		move.l	#gin,d0
 		lea	tail,a1

convert:	move.b	d0,d1
		and.w	#$000F,d1
		cmp.w	#9,d1
		ble	digit

		add.w	#55,d1
		bra	loop

digit:		add.w	#$30,d1

loop:		move.b	d1,-(a1)
		lsr.l	#4,d0
		bne	convert

* Now print it

		pea	string
		move.w	#CCONWS,-(sp)
		trap	#GEMDOS
		addq.l	#6,sp


* terminate and stay resident

		move.l	4(sp),a0		; a0 -> base page
		clr.w	-(sp)			; return code is zero

		move.l	$0C(a0),d0
		add.l	$14(a0),d0
		add.l	$1C(a0),d0
		add.l	#$100,d0
		move.l	d0,-(sp)		; push the amnt of mem to keep
		move.w	#PTERMRES,-(sp)
		trap	#GEMDOS


*+
*	New VDI handler: got here via trap 2
*-
vdi_check:	cmp.w	#115,d0			; is this a call to VDI?
		bne	vc_1
		jsr	_GSX_ENTRY		; yes, call our guy
		rte				; and ret from TRAP2 exception

vc_1:		cmp.w	#-1,d0			; if -1 ret adr of vdi entry
		bne	vc_2
		move.l	#_GSX_ENTRY,d0		; this is for GDOS (yuk !)
		rte

vc_2:		move.l	old_vdi,-(sp)		; chain to old guy
		rts



*+
*   New XBIOS handler: got here via trap 14
*-
xbios_check:	move.l	USP,a0			; a0 -> USP
		btst.b	#5,(sp)			; should we use USP or SSP ?
		beq	user_stack		; use USP if not super mode
		movea.l	sp,a0			; a0 -> SSP
.ifeq P68030
		addq.w	#8,a0			; a0 -> funct #
.endc
.ifne P68030
		addq.w	#6,a0			; a0 -> funct #
.endc

user_stack:	cmp.w	#5,(a0)			; check if SetScreen() funct #
		beq	SetScreen		; call SetScreen() funct
		cmp.w	#21,(a0)		; check if CursConf() funct #
		beq	CursConf		; call CursConf() funct
		cmp.w	#64,(a0)		; check if BlitMode() funct #
		beq	BlitMode		; call BlitMode() funct
		cmp.w	#80,(a0)		; check if ShiftMode() funct #
		beq	SetShift		; call SetShift() funct
		cmp.w	#93,(a0)		; check if SetRGB funct #
		beq	SetRGB			; call setRGB funct()
		move.l	old_xbios(pc),a0	; go back to the old guy
		jmp	(a0)

*+
* JSR to esc_init if needed.
*-
SetScreen:	cmp.w	#3,10(a0)		; see if mode is special case
		bne	SS0			; if not then skip
		movem.l	d0-d2/a0-a2,-(sp)	; save registers
		move.w	12(a0),-(sp)		; pass optional argument
		move.w	10(a0),-(sp)		; pass mode parameter
		move.l	#NewScreen,d0		; d0 -> new screen area
		add.l	#256,d0			; add a buffer
		and.l	#$ffffff00,d0		; need to be on 256 byte bndry
		move.l	d0,-(sp)		; pass physical adr
		move.l	d0,-(sp)		; pass logical adr
		jsr	_setscreen		; do sparrow setscreen
		add.w	#12,sp			; cleanup stack
		movem.l	(sp)+,d0-d2/a0-a2	; restore registers
		rte				; done for sparrow case

SS0:		move.w	12(a0),-(sp)		; pass optional argument
		move.w	10(a0),-(sp)		; pass mode parameter
		move.l	6(a0),-(sp)		; pass physical adr
		move.l	2(a0),-(sp)		; pass logical adr
		move.w	(a0),-(sp)		; pass function #
.ifeq P68030
		move.w	#0,-(sp)		; vector offset
.endc
		move.l	#SSComeback,-(sp)	; put return value for rte
.ifeq P68030
		move.w	20(sp),-(sp)		; push old sr
.endc
.ifne P68030
		move.w	18(sp),-(sp)		; push old sr
.endc
		ori.w	#$2000,(sp)		; remain in super mode on rte
		move.l	old_xbios(pc),a0	; go back to the old guy
		jmp	(a0)

SSComeback:
.ifeq P68030
		add.w	#14,sp			; cleanup stack
.endc
.ifne P68030
		add.w	#12,sp			; cleanup stack
.endc
		movem.l	a3-a6/d3-d7,-(sp)	; save registers
		moveq.l	#0,d0			; clear unneeded bits
		move.b	SSHIFTMD,d0		; d0 <- desired res
		move.w	d0,-(sp)		; pass rez parameter on stack
		jsr	_SetCurDevice		; set to desired device
		addq.w	#2,sp			; cleanup stack
		jsr	esc_init		; inititalize glass tty
		movem.l	(sp)+,a3-a6/d3-d7	; restore registers
		rte				; go back to caller


*+
* Call CursConf() don't go through the xbios
*-
CursConf:	movem.l	a3-a5/d3-d7,-(sp)	; save registers
		move.w	4(a0),-(sp)		; push operand onto stack
		move.w	2(a0),-(sp)		; push function onto stack
		jsr	_cursconf		; configure cursor
		addq.l	#4,sp			; cleanup the stack
		movem.l	(sp)+,a3-a5/d3-d7	; restore registers
		rte				; go back to caller

*+
*
*  BIOS call to test for / configure blitter;
*
*    Synopsis:	WORD BlitMode(mode)
*		WORD mode;
*
*    If 'mode' is non-negative (greater than or equal to zero) then
*    set the current graphics mode to 'mode' (see bit field definitions
*    below).  Regardless of 'mode''s value, return the old graphics
*    mode (the state before any set).
*
*    Bit fields in mode are defined as:
*
*      Bit#	Name
*      ------	----------------
*	0	 BLITMODE: 0=soft mode, 1=hard mode
*	1	 BLITCHIP: 0=no blit chip, 1=blit chip exists
*	2..5	 reserved for future use
*	6	 unused, may be 0 or 1
*	7..14	 reserved for future use
*	15	 must be 0
*
*    If an attempt is made to place the machine in hard blit mode
*    and no blit chip exists (BLITCHIP is zero) then the mode is
*    forced to soft.
*
*    The reserved fields are for future blitter capabilities and
*    other graphics chips.  They should be treated as "don't cares"
*    and should be maintained (intact) because they will acquire
*    meaning in the future.
*
*-
BlitMode:	move.w	d3,-(sp)	; save d3
		jsr	_TEST_BLT	; test for blit chip
		move.w	d0,d1		; save blt chip status
		move.w	d0,d2		; save blt chip status
		lsr.w	#1,d2		; blit chip installed mask (0 or 1)
		or.w	#$fffe,d2	
		jsr	_GETBLT		; get current blit mode
		move.w	d0,d3		;    into a safe register
		move.w	2(a0),d0	; get request mode
		bmi	Bmd_1		; (don't set if mode is negative)
		and.w	d2,d0		; force to soft mode if no chip
		or.w	d1,d0		; replace installed status
		jsr	_SETBLT		; set blit mode

Bmd_1:		move.w	d3,d0		; return "old" blit mode
		move.w	(sp)+,d3	; restore d3
		rte

*+
*
*  Test for blit chip
*
*	==> D0 = 0, no chip
*		 2, chip exists
*
*  We momentarily subvert the bus-error vector, so interrupts
*  are disabled during the test.
*
*-

BLASTER	equ	$ffff8a00

_TEST_BLT:	move.l	a0,-(sp)	; save a0 (BlitMode uses it)
		move.w	sr,d1		; save IPL
		move.w	#0,d0		; D0 = 0, assume no chip
		movea.l #0,a0		; A0 -> zero
		move.l	sp,a2		; A2 = SP on entry

		or.w	#$0700,sr	; turn off interrupts
		move.l	8(a0),a1	; A1 -> old bus error handler
		move.l	#TB_e,8(a0)	; install temp bus error handler
		tst.w	BLASTER(a0)	; touch blitter
		moveq	#2,d0		; no bus error: indicate chip exists

TB_e:		move.l	a1,8(a0)	; restore original bus error vector
		move.w	d1,sr		; restore IPL

		move.l	a2,sp		; restore SP
		move.l	(sp)+,a0	; restore a0
		rts			; and return

*+
* _EsetShift: - Set the TT shift mode register
*-
SetShift:	move.w	TTSHIFTMD,-(sp)		; save return value
		move.w	2(a0),TTSHIFTMD		; set shift mode register
		move.b	TTSHIFTMD,d0		; d0 <- curr rez
		and.w	#7,d0			; mask off unwanted bits
		move.b	d0,SSHIFTMD		; set software shadow
		movem.l	a3-a6/d3-d7,-(sp)	; save registers
		move.w	d0,-(sp)		; pass rez parameter on stack
		jsr	_SetCurDevice		; set to desired device
		addq.w	#2,sp			; cleanup stack
		jsr	esc_init		; re-init
		movem.l	(sp)+,a3-a6/d3-d7	; restore registers
		move.w	(sp)+,d0		; d0 <- gets old shft mode val
		rte

*+
* SetRGB:    VOID SetRGB(colorNum, count, palettePtr)
*            WORD colorNum, count;
*            LONG palettePtr;
*                 Set the contents of a contiguous set of hardware
*                 palette registers with the longs pointed to by 'palettePtr'.
*                 'palettePtr' must fall on a word boundary. The set of
*                 registers loaded begins with LUT register 'colorNum'
*                 and extends for 'count' words. The function sets the
*                 pallete immediately (in roms at vblank).
*-
SetRGB:		move.l	6(a0),-(sp)		; push palettPtr
		move.w	4(a0),-(sp)		; push count
		move.w	2(a0),-(sp)		; push colorNum
		jsr	_VsetRGB		; call actual function
		addq.w	#8,sp			; cleanup stack
		rte	

save_return:	dc.l	0		; store return adr for set screen
save_sr:	dc.w	0		; space for saving statuse register
old_vdi:	dc.l	0		; ptr to old vdi trap vector
old_xbios:	dc.l	0		; ptr to old bios trap vector
string:		dc.b	'GEM VDI loaded at 00000000',13,10,0
tail		equ	string+26

	.bss
NewScreen:	ds.w	350000			; memory for the screen
	.end
