*
* Using External and Embedded Resource files in Assembler
* Demo for Ictari by Keith Baines, January 1995
*

* Version 2 - Resource Included as Assembler File
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
	bsr	fix_rsc
	move.l	#FirstDialog,D0
	bsr	do_dialog
	move.l	#SecondDialog,D0
	bsr	do_dialog
	appl_exit

	clr.w	-(A7)
	trap	#1


	* Fix-up resource co-ordinates
fix_rsc	lea	TheResource,A3	' start of rsc data
	move.w	18(A3),D3		' offset to list of trees
	lea	(A3,D3.W),A4	' address of list
	move.w	22(A3),D4		' number of trees
	bra.w	end_fix_lp

fix_loop	move.l	(A4)+,A5		' address of first tree
	move.w	#0,D5		' object number in tree

next_obj	rsrc_obfix	A5,D5
	move.w	D5,D0
	mulu	#24,D0
	btst	#5,9(A5,D0.L)	' last object in tree?
	bne.s	end_fix_lp

	addq.w	#1,D5
	bra.s	next_obj	
	
end_fix_lp	dbra	D4,fix_loop		' any more trees to do?

	rts


	* Display the dialog
do_dialog	lea	TheResource,A0	' start of resource data
	move.w	18(A0),D1		' offset to list of trees
	lea	(A0,D1.W),A0	' address of list
	asl.l	#2,D0		' entry size = 4
	move.l	(A0,D0.L),A5	' address of our tree

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
TheResource	INCLUDE	"DEMO.RS"

	SECTION BSS
	DS.L	100
MyStack