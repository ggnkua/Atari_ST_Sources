;
; Bootsector Loader by MUG U.K for Eddie Bryan
; --------------------------------------------
;
; Uses Xbios 8 (_floprd) and loads sectors to a specific address
; in memory and executes it there.  Ensure program to load has been
; relocated from a program file into a binary file to run at the
; specified address FIRST !!
;
; Program must NOT go into supervisor mode, as supervisor mode is
; already present.


	bra.s	setup
	dc.b	"Bootsector Loader by MUG U.K - 22/12/1991"


setup	pea	text(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	MOVE #140,-(SP)		; read 140 sectors
	MOVE #00,-(SP)		; side 0
	CLR -(SP)		; track 0
	MOVE #01,-(SP)		; sector 1
	MOVE $446.W,-(SP)	; boot device
	CLR.L -(SP)		; filler
	PEA $30000		; address to load
	MOVE #$08,-(SP)		; _floprd
	TRAP #14		; xbios
	LEA 20(SP),SP		; correct stack

	jmp	$30000		; call loaded program


;
; Variables used
;

text	dc.b	27,"Y",40,46
	dc.b	"Please Wait ..."
	dc.b	0

;
; Pad out rest of bootsector with zeros
;
; When you assemble this code from GenST, you will have to alter this
; figure below so that the assembled size equals 480 bytes !!
;

blanks	ds.b	362

