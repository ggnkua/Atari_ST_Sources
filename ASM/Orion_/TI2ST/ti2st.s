;---------------------------------------->
; TI68k to ST Experiment - Orion_ 07/2013

	section	text

BOOTMODE	equ	0
LCD_MEM		equ	$4C00

HEAP_START      EQU     TIRAM
HEAP_END	EQU	TIRAMe
HANDLE_MAX	EQU	2000

	include	"mylib.s"		; My Init Atari ST Lib

	; Save Screen Space Data and Put a Fake Home Screen
	lea	HomeScr+$AC,a0
	lea	LCD_MEM.w,a1
	lea	TIScreenSave,a2
	move.w	#((240*128)/4)-1,d0
.copyhomescr:
	move.l	(a1),(a2)+		; Save Data from ST memory
	move.l	(a0)+,(a1)+		; Put our Screen
	dbra	d0,.copyhomescr

	; Save Vectors
	move.l	$C8.w,SaveRCPtr
	move.l	$2C.w,SaveLineF
	move.l	$8C.w,SaveTrap3
	move.l	$A4.w,SaveTrap9

	; Setup Vectors/Romcall Table
	lea	ROMCalls,a0
	move.l	a0,$C8.w	; Set ROMCalls Table Pointer
	move.l	#TILineF,$2C.w	; Set LineF Emulator
	move.l	#Trap_3,$8C.w		; Heap
	move.l	#Dummy_Trap,$A4.w	; Trap 9

	; Init Pedrom Routines
	bsr	HeapInit
	bsr	ReInitGraphSystem

	; Black and White Palette
	move.l	#$0FFF0000,PALETTE.w

	; Screen Conversion routine in VBL
	move.l	#MyVBL,VECT_VBL.w

	; Relocate and Start 89z program
	move.l	#MyPrgm,a0
	bsr	RelocAndJump

	; Restore Vectors
	move.l	SaveRCPtr,$C8.w
	move.l	SaveLineF,$2C.w
	move.l	SaveTrap3,$8C.w
	move.l	SaveTrap9,$A4.w

	; Restore Screen Space Data
	lea	LCD_MEM.w,a1
	lea	TIScreenSave,a2
	move.w	#((240*128)/4)-1,d0
.resthomescr:
	move.l	(a2)+,(a1)+
	dbra	d0,.resthomescr

	; Call Exit from my ST Lib
	bra	exit


;---------------------------------------->
; Screen Emulation

MyVBL:
	movem.l	a0-a1/d0-d1,-(a7)

	lea	LCD_MEM.w,a0	; TI Screen
	move.l	next,a1
	add.l	#5760+24,a1	; Center

	moveq	#128-1,d0	; 240x128 on 320x200
.loop:
OFFSET	SET	0
	REPT	15
	move.w	(a0)+,OFFSET(a1)
OFFSET	SET	OFFSET+8
	ENDR

	lea	160(a1),a1
	dbra	d0,.loop

	bsr	flip

	movem.l	(a7)+,a0-a1/d0-d1
	rte

;---------------------------------------->

	; Rom Calls Routine (mainly taken from Pedrom Sources)

	include	romcall.s
	include	rcgraph.s
	include	rcmemstr.s
	include	rcheap.s
	include	rcmath.s


;---------------------------------------->
; LineF ROM Call Emulator (maybe not clean but it works !)

TILineF:
	subq.l	#4,a7		; Add space for ROMCall Return
	move.w	4(a7),(a7)	; Shift SR from stack

	movem.l	a0/d0,-(a7)	; Save Regs

	move.l	14(a7),a0	; Get Address from where the Exception Occured
	move.w	(a0)+,d0	; Get the $F000 data
	move.l	a0,14(a7)	; Patch Stack with new return address after ROM Call
	andi.w	#$7FF,d0	; Keep the Data ($F800 + ROM Call ID)
	lsl.w	#2,d0		; *long
	lea	ROMCalls,a0	; ROMCalls Table
	move.l	(a0,d0.w),10(a7)	; Patch Stack for AutoJump to ROM Call after RTE !

	movem.l	(a7)+,a0/d0	; Restore Regs

Dummy_Trap:
	rte


;---------------------------------------->
; Relocate and Start a TI program from a .89z file

RelocAndJump:			; a0 = 9xz/89z file pointer
	lea	$40(a0),a1

	move.b	-(a1),d0	; Get data offset (little endian)
	lsl.w	#8,d0
	move.b	-(a1),d0
	swap	d0
	move.b	-(a1),d0
	lsl.w	#8,d0
	move.b	-(a1),d0

	adda.l	d0,a0		; Add offset to base
	addq.l	#4,a0		; skip some header
	move.w	(a0)+,d0	; Size of program

	move.l	a0,a1
	subq.w	#1,d0
	adda.w	d0,a1		; End of program

	; EX_Patch: Reloc Table is at End (a1)
.loop:
	move.b	-(a1),-1(a7)	; Get Offset to Patch
	move.b	-(a1),-(a7)
	moveq	#0,d0
	move.w	(a7)+,d0
	beq.s	.exit		; End of Reloc Table ?
	move.b	-(a1),-1(a7)	; Get Patch Value
	move.b	-(a1),-(a7)
	moveq	#0,d1
	move.w	(a7)+,d1
	add.l	a0,d1		; Add Program Start Pointer
	move.l	d1,(a0,d0)	; Patch
	bra.s	.loop
.exit:

;	DBUG			; Stop STeem Emulation for debugging purpose

	jmp	(a0)		; Jump to Program Start


;---------------------------------------->
; Datas

	section	data

	even
MyPrgm:	incbin	"89z/mlaby68k.89z"	; Our program to "emulate" (TODO: Load from file/parameter like: ti2st.ttp file.89z)
	even

HomeScr:
	incbin	"home.tif"
	even

HeapPtr:	dc.l	TIRAM
ROMCalls:
	include	"rctable.s"


;---------------------------------------->
; Bss

	section	bss

	even

SaveLineF:	ds.l	1
SaveRCPtr:	ds.l	1
SaveTrap3:	ds.l	1
SaveTrap9:	ds.l	1

	; Pedrom Variables

FloatReg1:		ds.b	FLOAT.sizeof			;// Float register : it is used mainly by internal Floatting Point functions to overides the lack of FPU
FloatReg2:		ds.b	FLOAT.sizeof
FloatReg3:		ds.b	FLOAT.sizeof
FloatReg4:		ds.b	FLOAT.sizeof
FloatPreCalculMultTab:	ds.b	FLOAT.sizeof*10		;// Table used by FloatMult/FLoatDivide functions to precalculted the multiplication of a floatr by the finger 0, 1, 2 ... 9.

CURRENT_SCREEN:		ds.l	1			;// Target screen of the Graph functions.
STRTOK_PTR:		ds.l	1

HEAP_PTR:		ds.l	1

CURRENT_ATTR:		ds.w	1			;// Default Attribute (A_NORMAL, A_REVERSE, A_XOR)
CURRENT_POINT_X:	ds.w	1			;// Current Pen X location 
CURRENT_POINT_Y:	ds.w	1			;// Current Pen Y location 
CURRENT_INCY:		ds.w	1			;// Internal: Current increment of a row to go to the next row in bytes.
CURRENT_SIZEX:		ds.w	1			;// Current Horizontal Size of the screen
CURRENT_SIZEY:		ds.w	1			;// Current Vertical Size of the screen
CLIP_MIN_X:		ds.w	1			;// Some graph functions use a clip area. Minimum X position of the rect clipping area.
CLIP_MIN_Y:		ds.w	1			;// Minimum Y position of the rect clipping area.
CLIP_MAX_X:		ds.w	1			;// Maximum X position of the rect clipping area.
CLIP_MAX_Y:		ds.w	1			;// Maximum Y position of the rect clipping area.
CLIP_TEMP_RECT:		ds.l	1

CURRENT_FONT:		ds.b	1			;// Default Font when no font is defined. (Small, Medium, Large)
CURRENT_GRAPH_UNALIGNED:	ds.b	1
DRAW_CHAR:		ds.b	1			;// DrawChar uses it to display one char.
NULL_CHAR:		ds.b	1			;// Null char for draw char (It uses DrawStr) and cur_folder_str !

	even
HEAP_TABLE:	ds.l	HANDLE_MAX

	; 256k of RAM

TIRAM:		ds.b	256*1024
TIRAMe:
	even

TIScreenSave:	ds.b	240*128
