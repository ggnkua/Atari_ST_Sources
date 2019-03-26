*
* 	ST Format - Assembly Work Shop
*
*	"Palette Picture Fade"
*
*	by Andrew T Gisby 
*
* This short assembly language program will perform the
* following;
*
*	1.	Set Resolution to Low
*	2.	Set all colours to zero (black)
*   3.	Print a multi-coloured message
*   4.  Fade to another palette a few times
*	5.  Fade the palette to black
*	6.  Restore pre program screen mode
*   7.  Exit
*
* Caveats
* SUPERVISOR Program execution
* The Picture file is assumed to be Degas Elite Low resolution
* compressed. No validation of picture file format is performed.
* Step 7 (restore resolution) may be unstable on Falcon030 
* machines that started with non ST (VGA & compatibility) screen
* modes.
*  
* ==========================================================

start

* STANDARD PROGRAM ENTRY CODE

		MOVE.L	A7,A5			* Release Memory & Program Stack
		MOVE.L	#USTK,A7
		MOVE.L	4(A5),A5
		MOVE.L	$C(A5),D0
		ADD.L	$14(A5),D0
		ADD.L	$1C(A5),D0
		ADD.L	#$100,D0
		MOVE.L	D0,-(SP)
		MOVE.L	A5,-(SP)
		MOVE.W	D0,-(SP)
		MOVE.W	#$4A,-(SP)

		TRAP	#1
		LEA	12(SP),SP

* SUPERVISOR mode...

		move.l	#0,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,oldstack

* Get entry screen mode...

		move.w	#4,-(sp)		* XBIOS get current screen mode
		TRAP	#14
		move.w	d0,old_mode
		LEA		2(sp),sp

* Set to low resolution...

		move.w	#0,-(Sp)		* XBIOS set screen
		move.l	#-1,-(Sp)
		move.l	#-1,-(Sp)
		move.w	#5,-(sp)
		TRAP	#14
		LEA		12(sp),sp

* Save default palette...

		LEA		$FFFF8240,a0
		LEA		old_pal,a1
		moveq.l	#15,d0
.save_old
		move.w	(a0)+,(a1)+
		DBRA	d0,.save_old	

* Set all the colours to Black (Zero)...

		PEA		zero_pal
		move.w	#6,-(sp)		* XBIOS set palette
		TRAP	#14
		LEA		6(sp),sp

* 1st VT52 compliant message...

		PEA		message1
		move.w	#9,-(sp)
		TRAP	#1
		LEA		6(sp),sp
		LEA		blue_pal,a0
		move.l	#25,d0			; Assume 50 Htz Display (0.5 secs)
		BSR		Transform_Palette
		BSR		Delay			; 3 second pause
		LEA		zero_pal,a0
		move.l	#25,d0			; Assume 50 Htz Display (0.5 secs)
		BSR		Transform_Palette

* 2nd VT52 compliant message...

		PEA		message2
		move.w	#9,-(sp)
		TRAP	#1
		LEA		6(sp),sp
		LEA		red_pal,a0
		move.l	#25,d0			; Assume 50 Htz Display (0.5 secs)
		BSR		Transform_Palette
		BSR		Delay			; 3 second pause
		LEA		zero_pal,a0
		move.l	#25,d0			; Assume 50 Htz Display (0.5 secs)
		BSR		Transform_Palette

* 3rd VT52 compliant message...

		PEA		message3
		move.w	#9,-(sp)
		TRAP	#1
		LEA		6(sp),sp
		LEA		white_pal,a0
		move.l	#25,d0			; Assume 50 Htz Display (0.5 secs)
		BSR		Transform_Palette
		BSR		Delay			; 3 second pause
		LEA		zero_pal,a0
		move.l	#25,d0			; Assume 50 Htz Display (0.5 secs)
		BSR		Transform_Palette

* 4th VT52 compliant message...

		PEA		message4
		move.w	#9,-(sp)
		TRAP	#1
		LEA		6(sp),sp
		LEA		white_pal,a0
		move.l	#25,d0			; Assume 50 Htz Display (0.5 secs)
		BSR		Transform_Palette
		BSR		Delay			; 3 second pause
		LEA		zero_pal,a0
		move.l	#25,d0			; Assume 50 Htz Display (0.5 secs)
		BSR		Transform_Palette

* Back to Old Screen Mode...

		move.w	old_mode,-(Sp)	* XBIOS set screen
		move.l	#-1,-(Sp)
		move.l	#-1,-(Sp)
		move.w	#5,-(sp)
		TRAP	#14
		LEA		12(sp),sp

* Old palette...

		PEA		old_pal
		move.w	#6,-(sp)
		TRAP	#14
		add.l	#6,sp

* USER mode...

		move.l	oldstack,-(sp)
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
		
* ---------------------------
EXIT
		move.w	#0,-(sp)		* GEMDOS Terminate & return
		TRAP	#1				  to parent.
* ---------------------------
Delay
		move.l	#50*3,d7
.wait	move.w	#37,-(sp)
		TRAP	#14
		LEA		2(sp),sp
		DBRA	d7,.wait
		RTS

* =====================================================

			include	"a:\assembly\stf0002a.s"

message1	dc.b	27,"E",13,10,13,10,13,10,13,10,27,"b",1
			dc.b	"    Fade up the blue...",0,0

message2	dc.b	27,"E",13,10,13,10,13,10,13,10,27,"b",1
			dc.b	"    Fade up the red...",0,0

message3	dc.b	27,"E",13,10,13,10,13,10,13,10,27,"b",1
			dc.b	"    Fade up the white...",0,0

message4	dc.b	27,"E",13,10,13,10,13,10,13,10,27,"b",1
			dc.b	"    Bye bye...",0,0


old_pal		ds.w	16

zero_pal	dc.w	0,0,0,0,0,0,0,0
			dc.w	0,0,0,0,0,0,0,0

blue_pal	dc.w	0
			rept	15
			dc.w	$02F
			endr

red_pal		dc.w	0
			rept	15
			dc.w	$F20
			endr

white_pal	dc.w	0
			rept	15
			dc.w	$FFF
			endr

old_mode	dc.w	0


oldstack		dc.l	0
				ds.l	128
USTK			dc.l	0
