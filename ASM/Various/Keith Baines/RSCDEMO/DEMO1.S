*
* Using External and Embedded Resource files in Assembler
* Demo for Ictari by Keith Baines, January 1995
*

* Version 1 - External Resource
*

	INCLUDE	GEMMACRO.I		HiSoft GEM macros
	INCLUDE	DEMO.I		RSC header file from Wercs

; Set up stack and shrink memory

	MOVEA.L	A7,A6		Save original stack
	LEA	MyStack,A7		Set stack in kept area
	MOVEA.L	4(A6),A6		Ax=address of base page
	MOVE.L	$C(A6),D0		D0=length of text
	ADD.L	$14(A6),D0	  	+ length of data
	ADD.L	$1C(A6),D0	  	+ length of BSS
	ADDI.L	#$100,D0	   	+ length of base-page

	MOVE.L	D0,-(A7)		Size to keep
	MOVE.L	A6,-(A7)		Address to keep
	CLR.W	-(A7)		Zero word
	move.w	#$4A,-(A7)		mem shrink call
	trap	#1
	lea	12(A7),A7

	appl_init
	bsr	load_rsc
	tst.w	D0
	beq.s	bad_rsc

	move.l	#FirstDialog,D0
	bsr	do_dialog
	move.l	#SecondDialog,D0
	bsr	do_dialog
	appl_exit

	clr.w	-(A7)
	trap	#1

bad_rsc	form_alert	#1,#cant_load
	clr.w	-(A7)
	trap	#1

	* Load the resource file
load_rsc	rsrc_load	#rsc_name
	rts


	* Display the dialog
do_dialog	rsrc_gaddr	#0,D0
	move.l	addr_out,A5

	form_center	A5
	move.w	int_out+2,D4
	move.w	int_out+4,D5
	move.w	int_out+6,D6
	move.w	int_out+8,D7

	form_dial	#0,D4,D5,D6,D7,D4,D5,D6,D7
	objc_draw	A5,#0,#9,D4,D5,D6,D7
	graf_mouse	#0
	form_do	A5,#0
	form_dial	#3,D4,D5,D6,D7,D4,D5,D6,D7

	rts


	INCLUDE	AESLIB.S		HiSoft AES calling code

	SECTION DATA
rsc_name	DC.B	"DEMO.RSC",0

cant_load	DC.B	"[3][ Can't load DEMO.RSC ][QUIT]",0

	SECTION BSS
	DS.L	100
MyStack