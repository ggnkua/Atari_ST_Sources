*
* 	ST Format - Assembly Work Shop
*
*	"Degas Elite Compressed Picture File Decode"
*
*	by Andrew T Gisby 
*
* This short assembly language program will perform the
* following;
*
*	1.		Set Resolution to Low
*	2.		Set all colours to zero (black)
*	3.		Decompress a picture into physical screen memory
*   4.		Set all colours to match picture palette
*   5.      Wait for a Key Press
*	6.      Restore pre program screen mode
*   7.      Exit
*
* Caveats
* The Picture file is assumed to be Degas Elite Low resolution
* compressed. No validation of picture file format is performed.
* Step 6 (restore resolution) may be unstable on Falcon030 
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

* ---------------------------

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

* Get screen base...

		move.w	#2,-(sp)		* XBIOS get screen base 
		TRAP	#14
		LEA		2(sp),sp
		move.l	d0,sbase

* Set all the colours to Black (Zero)...

		PEA		zero_pal
		move.w	#6,-(sp)		* XBIOS set palette
		TRAP	#14
		LEA		6(sp),sp

* Decode Picture to screen...

		LEA		picture,a0
		move.l	sbase,a1
		BSR		Degas_PC1_Decode

* Set Picture Palette

		PEA		picture+2
		move.w	#6,-(sp)		* XBIOS set palette
		TRAP	#14
		LEA		6(sp),sp

* Wait for a key press...

		move.w	#1,-(sp)		* GEMDOS Get char from std input
		TRAP	#1
		LEA		2(sp),sp

* Back to Old Screen Mode...

		move.w	old_mode,-(Sp)	* XBIOS set screen
		move.l	#-1,-(Sp)
		move.l	#-1,-(Sp)
		move.w	#5,-(sp)
		TRAP	#14
		LEA		12(sp),sp
		
* ---------------------------
EXIT
		move.w	#0,-(sp)		* GEMDOS Terminate & return
		TRAP	#1				  to parent.

* =====================================================

			include	"a:\assembly\stf0001a.s"

zero_pal	dc.w	0,0,0,0,0,0,0,0
			dc.w	0,0,0,0,0,0,0,0

picture		incbin	"a:\assembly\stf0001.pc1"

old_mode	dc.w	0

sbase		dc.l	0

oldstack		dc.l	0
				ds.l	128
USTK			dc.l	0
