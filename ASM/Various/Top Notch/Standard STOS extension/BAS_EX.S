;
;	Standard STOS extension (BASIC).
;	(C) Top Notch. July 1992/April 1993.
;
;	Tabs originally set to 10.
;
;	This source file if for the BASIC extensions only.
;	There is an equivalent one for the Compiler, but if you
;	want it then you should send œ10 sterling to:
;
;	Billy Allan,
;	66 Highmains Ave,
;	Dumbarton,
;	Scotland,
;	G82 2PT.
;
;	If you think that œ10 is a lot, then you can go buy
;	"The Gamemakers Manual" for œ12.95 and then discover that
;	the information it gives you is entirely wrong... Why do you
;	think there are so many BASIC-only extensions around?
;
;	Also, think on the shareware fees you could recieve from your
;	extension... Our first ever extension - Misty (only œ5, send
;	to the above address!) has made us over œ1200 pounds so far, and
;	is still coming in at œ10 to œ20 a week over nine months later!
;
;	As we have some room to waste, we'll now give a new member-list:
;
;	Colin Watt	: Coder, Project co-ordinator, product
;			  distribution, Market Research.
;	Billy Allan 	: Coder, Project Manager, Treasurer, 
;			  Publicity Agent.
;	Stephan Lingdell	: Musician, Overseas Market 
;			  Development (Swedish office). 
;
;
;	Hellos to: Douglas, Neil, Michael, Michael, Poor-guy Tony, Paul,
;	Iain, Peter, Nice Kevin (my bestest friend in the whole world -
;	any sign of that job yet?), Waldo, Noel, Graham, Leon, Robert,
;	Duncan, Rob, Eddie, Bruno, Chris Holland, Neil, Mark, Oskar,
;	Andei, The Pure Bollocks Team, Patrick, Julie, Cubase John,
;	Nick Harper, Jake of Caledonia PDL, Steve of Floppyshop,
;	Page 6 (nice Misty review!) and finally Stale Loseth (one of
;	the best graphics artists on the ST, if not *the* best).
;
;
;	Notes:
;	1. You usually don't need to save the registers, but it's
;	   advisable if you're using TRAPs (or any of the following
;	   registers : d5-d7 or a3/5/6/7 (I think)
;	2. Be very careful!  STOS really is quite easy to crash!
;	3. Remember that STOS sets up it's own interrupts, so be nice
;	   to them!  The WAIT XX and INKEY$ are especially prone to
;	   failure as they both use the HBL.  STOS also does strange
;	   things with the VBL queue.
;	4. Choose your command name carefully.  Try not to make your
;	   command have anything in it which can be construed(?) as
;	   a STOS command.  For example, a command "PIXEL" is changed
;	   by STOS to "PI xel".
;	5. You should always try to use PC-relative, even though
;	   the BASIC one doesn't need it.  It makes the Compiler
;	   extensions a *lot* easier to do.
;	6. Although you can access any variables and other commands
;	   in the BASIC extension, you can't really do it in the Compiler
;	   version.  Any variables you do use, you should place between
;	   the end of the commands code and the start of the next one.
;	7. The extension letter "B" cannot be used.
;	8. Command slot 161 cannot be used either.
;

	output	c:\stos\test.ext
	opt	o+,w-

**********************************************************************
*
*  Error EQUates
*
**********************************************************************

Address	EQU	32		; address error
BadFile	EQU	1		; bad file format
BadName	EQU	53		; bad filename
BadScr	EQU	43		; bad screen address
DiskErr	EQU	52		; disk error
FNotFnd	EQU	48		; file not found
IllFunc	EQU	13		; illegal function call
Syntax	EQU	12		; syntax error (everyones friend)
TypeMis	EQU	19		; type-mismatch

**********************************************************************
*
*  Hardware EQUates
*
**********************************************************************

;-------> Blitter registers

blitter	equ	$ffff8a00
halftone	equ	blitter+0
src_xinc	equ	blitter+$20
src_yinc	equ	blitter+$22
src_addr	equ	blitter+$24
endmask1	equ	blitter+$28
endmask2	equ	blitter+$2a
endmask3	equ	blitter+$2c
dst_xinc	equ	blitter+$2e
dst_yinc	equ	blitter+$30
dst_addr	equ	blitter+$32
x_count	equ	blitter+$36
y_count	equ	blitter+$38
hop	equ	blitter+$3a	;half-tone operation
op	equ	blitter+$3b	;logical operation
BlitStat	equ	blitter+$3c
skew	equ	blitter+$3d

;-------> Screen registers

PixelOfs	equ	$ffff8264
ScrWidth	equ	$ffff820e
s_low	equ	$ffff820d
s_medium	equ	$ffff8203
s_high	equ	$ffff8201

;-------> DAC registers

dma_control	equ	$ff8900
fba_high		equ	$ff8902
fba_middle	equ	$ff8904
fba_low		equ	$ff8906
fac_high		equ	$ff8908
fac_middle	equ	$ff890a
fac_low		equ	$ff890c
fea_high		equ	$ff890e
fea_middle	equ	$ff8910
fea_low		equ	$ff8912
smc		equ	$ff8920
mdr		equ	$ff8922
mmr		equ	$ff8924

;-------> Miscellaneous hardware EQUates

syncmode	EQU	$ffff820a
Palette	EQU	$ffff8240
colour0	EQU	Palette+0
colour1	EQU	Palette+2
colour2	EQU	Palette+4
colour3	EQU	Palette+6
colour4	EQU	Palette+8
colour5	EQU	Palette+10
colour6	EQU	Palette+12
colour7	EQU	Palette+14
colour8	EQU	Palette+16
colour9	EQU	Palette+18
colour10	EQU	Palette+20
colour11	EQU	Palette+22
colour12	EQU	Palette+24
colour13	EQU	Palette+26
colour14	EQU	Palette+28
colour15	EQU	Palette+30
res	EQU	$ffff8260
VBL	EQU	$70
ACIA	EQU	$fffffc02
YM2149	EQU	$ffff8800

**********************************************************************
*
* Useful Macro's
*
**********************************************************************

CheckPar	MACRO	Number		; check number of
	cmpi.w	\1,d0		; parameters.
	beq.s	.ItsOk
	Error	#Syntax
.ItsOk	
	ENDM

SaveRet	MACRO			; Save return address
	move.l	(sp)+,Return
	ENDM

SaveRegs	MACRO			; save STOS registers
	lea	SaveReg(pc),a0
	movem.l	d5-d6/a1-a6,-(a0)
	ENDM

RestRegs	MACRO			; and restore them...
	lea	LoadReg(pc),a0
	movem.l	(a0)+,d5-d6/a1-a6
	ENDM

GoBack	MACRO			; jump back to STOS (yippee!)
	move.l	Return(pc),a0
	jmp	(a0)
	ENDM

GetInt	MACRO	Register		; read an integer.
	move.l	(sp)+,d7
	move.l	(sp)+,\1
	addq.l	#4,sp
	tst.b	D7		; d7 destroyed.
	bne	Mismatch
	ENDM

Error	MACRO	ErrorNum		; return a STOS error
	move.l	\1,d0
	movea.l	System(PC),A0
	movea.l	$14(A0),A0
	jmp	(A0)
	ENDM

VSync	MACRO
	movem.l	d0-d2/a0-a2,-(sp)
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d2/a0-a2
	ENDM

**************************************************************************
;
; Blitter macros
;
**************************************************************************
blit_nice	macro
	lea	BlitStat,a5
	moveq	#7,d7
	move.b	#128,(a5)

.wait
	bset.b	d7,(a5)
	bne.s	.wait	
	endm

BlitNasty	macro
	move.b	#192,BlitStat
	endm	

**********************************************************************
*
*  Header info.  Start of extension proper.
*
**********************************************************************

	EVEN

	bra	Init

	DC.B	128	; first command number

**********************************************************************
*
*  The token list is a list of all the commands as they will appear in
*  a STOS listing.  Be careful when choosing your command names!  For
*  instance, a command called "pixel" will be turned into "pi XEL" in
*  a STOS listing...
*
**********************************************************************

Tokens	DC.B	"strobe",128	; even numbers are procedures
	DC.B	"boundary",129	; odd's are functions
	DC.B	"mouse off",130
	DC.B	"hard key",131
	DC.B	"mouse on",132
	DC.B	"res on",133
	DC.B	"silence",134
	DC.B	"palt",135
	DC.B	"flood pal",136
	DC.B	"brightest",137
	DC.B	"reboot",138
	DC.B	0		; End list with "DC.B 0"

	EVEN

Jumps	DC.W	11		; Number of commands
	DC.L	Strobe
	DC.L	Round		; routine labels
	DC.L	MouseOff
	DC.L	HardKey
	DC.L	MouseOn
	DC.L	ResValid
	DC.L	Silence
	DC.L	palt
	DC.L	FloodPal
	DC.L	brightest
	DC.L	ReBoot
	
Welcome	DC.B	"English extension name"	; if you go over 1 line
	dc.b	0
	DC.B	"French extention name"	; it will NOT be centred
	dc.b	0

	EVEN

System	DC.L	0		; Variable for system calls
Return	DC.L	0		; Holds return address for STOS

Init	lea	Exit,A0		; End of whole extension
	lea	ColdSt,A1		; The cold-start routine
	rts

**********************************************************************
*
*  The cold-start routine is called when the extension is first loaded.
*  Handy for screen flashes, long pauses, logo's...
*
**********************************************************************
ColdSt	move.l	A0,System
	lea	Welcome,A0
	lea	WarmSt,A1
	lea	Tokens,A2
	lea	Jumps,A3
	movem.l	d0-a6,-(sp)

;-------> Put your routine here (this one flashes the screen).

	VSync
	lea	$ffff8240.w,a0
	lea	.ColTab(pc),a1
	move.w	(a0),d1
.DoFlash	move.w	(a1)+,d0
	cmpi.w	#$FFFF,d0
	beq.s	.AllDone
	VSync
	VSync
	move.w	d0,(a0)
	bra.s	.DoFLash
.AllDone	move.w	d1,(a0)

;-------> End of your routine.

	movem.l	(sp)+,d0-a6
	rts

.ColTab	dc.w	$000,$100,$200,$300,$400,$500,$600,$700
	dc.w	$711,$722,$733,$744,$755,$766,$777
	dc.w	$776,$775,$774,$773,$772,$771,$770
	dc.w	$670,$570,$470,$370,$270,$170,$070
	dc.w	$060,$050,$030,$020,$010,$000
	dc.w	$FFFF

**********************************************************************
*
*  A warm start occurs when you load, save, run, entering a line,
*  changing program area, typing CLEAR and anything else like that.
*  It does NOT occur when you UNDO-UNDO or DEFAULT. (Francois - you DICK!)
*  It can be very useful for turning off interrupts you've set up,
*  restoring the mouse, restoring the palette and various other bits
*  and pieces.
*
**********************************************************************

WarmSt	movem.l	d0-a6,-(sp)
;-------> Start of your routine

	move.b	#8,$fffffc02.w	; turn mouse on
	move.w	Colour0,d0
	move.w	d0,d1
	not.w	d1
	VSync
	move.w	d1,Colour0
	VSync
	move.w	d0,Colour0
	VSync

;-------> End of your routine
	movem.l	(sp)+,d0-a6
	rts

**********************************************************************
*
*  This is just for the "GetInt" macro.  It isn't really used otherwise.
*
**********************************************************************

Mismatch	Error	#TypeMis

**********************************************************************
*
*  Start of command code
*
**********************************************************************

Strobe	SaveRet		; Store return address
	CheckPar	#2	; two paremters passed?
	SaveRegs

	GetInt	d1	; the colour to flash
	GetInt	d0	; number of times to do it

	move.w	Colour0,d2
.Flashy	move.w	d1,Colour0
	VSync
	move.w	d2,Colour0
	VSync
	dbf	d0,.Flashy

	VSync
	move.w	d2,Colour0

	RestRegs
	GoBack

**********************************************************************

Round	SaveRet		; store return address
	CheckPar	#1
	GetInt	d0

	andi.w	#$fff0,d0

	move.l	d0,d3	; return value must be in D3
	moveq.l	#0,D2	; and a 0 in D2 (integer code)

	GoBack

**********************************************************************

MouseOff	
	SaveRet
	CheckPar	#0
	move.b	#$12,ACIA
	GoBack

**********************************************************************

HardKey	SaveRet
	CheckPar	#0

	moveq	#0,D3
	moveq	#0,D2
	move.b	ACIA,D3

	GoBack

**********************************************************************

MouseOn	SaveRet
	CheckPar	#0

	move.b	#8,ACIA

	GoBack

**********************************************************************

ResValid	SaveRet
	CheckPar	#0
	
	moveq	#0,D2
	moveq	#0,D3
	move.l	$0426,D0
	cmpi.l	#$31415926,D0
	bne.s	.NotValid
	move.l	#-1,D3

.NotValid	GoBack

**********************************************************************

Silence	SaveRet
	CheckPar	#0

	move.l	#$08000000,YM2149
	move.l	#$09000000,YM2149
	move.l	#$0A000000,YM2149

	GoBack

**********************************************************************

palt	SaveRet
	CheckPar	#1
	GetInt	a0

;routine to grab palette from a STOS sprite bank
;by C A Watt of TN

;areg(0)=bank

	cmpi.l	#$19861987,(a0)
	bne.s	.paltend

	move.l	#128*1024,d0	; check through 256k
	moveq.l	#0,d2
	move.l	d2,d3

.sloop
	cmp.l	#"PALT",(a0)	;ckeck for "PALT" string
	beq.s	.getpalt		;if found then get it
	lea	2(a0),a0		;if not found then 
	dbf.w	d0,.sloop		;re-iterate loop

	bra.s	.paltend		;if end of loop and no palette then not done error

.getpalt
	lea	Palette,a1
	move.l	a0,d3
	VSync
	REPT	8
	move.l	(a0)+,(a1)+
	ENDR

.paltend	GoBack

**********************************************************************

FloodPal	SaveRet
	CheckPar	#1

	GetInt	d3

	moveq.l	#15,d0
	lea	.PalBuff(pc),a0
.CopyPal	move.w	d3,(a0)+
	dbra	d0,.CopyPal
	lea	.PalBuff(pc),a0
	move.l	a0,$45a

	GoBack

.PalBuff	dc.l	0,0,0,0,0,0,0,0

**********************************************************************

brightest	SaveRet
	CheckPar	#1
	GetInt	a0

	SaveRegs

	moveq	#15,d0
	moveq	#$f,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
.coloop
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	(a0)+,d1
	andi.w	#%0000011101110111,d1

	move.w	d1,d2
	and.w	d4,d2	;get blue

	lsr.w	#4,d1
	move.w	d1,d3
	and.w	d4,d3
	add.w	d3,d2	;add green

	lsr.w	#4,d1
	and.w	d4,d1	
	add.w	d1,d2	;add red

	cmp.w	d5,d2
	ble.s	.notbrighter
	move.w	d2,d5
	move.w	d6,d7
.notbrighter
	addq	#1,d6
	dbf.w	d0,.coloop

	move.w	d7,d3
	moveq	#0,d2

	RestRegs
	GoBack

**********************************************************************

reboot	SaveRet
	CheckPar	#0

	lea	.QuestStr(pc),a0
	moveq.l	#1,d7
	trap	#3
.GetKey	cmpi.b	#21,$fffc02	; Y
	beq.s	.doBoot
	cmpi.b	#$31,$fffc02	; N
	beq.s	.ExitBoot
	bra.s	.GetKey
.doBoot	clr.l	$420.w
	clr.l	$426.w
	movea.l	0.w,sp
	movea.l	4.w,a0
	jmp	(a0)

.ExitBoot GoBack

.QuestStr
	dc.b	"This action is the software equivalent",10,13
	dc.b	"of an enema!",10,13
	dc.b	"Are you sure that you wish to proceed?",10,13
	dc.b	"press Y or N.",10,13
	dc.b	0

**********************************************************************
*
*  End of commands
*
**********************************************************************
**********************************************************************
*
*  Storage space
*
**********************************************************************

LoadReg	DS.L	8	; Area to save registers
SaveReg

Par1	DC.L	0	; temporary storage for the
Par2	DC.L	0	; parameters in case you need lot's
Par3	DC.L	0	; of them!

**********************************************************************
*
*  End of extension
*
**********************************************************************

	DC.L	0
Exit
