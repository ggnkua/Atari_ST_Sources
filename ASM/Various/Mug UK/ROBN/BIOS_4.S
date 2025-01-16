;
; Bootsector Loader by MUG U.K for Eddie Bryan
; --------------------------------------------
;
; Uses Bios 4 (rwabs) and loads sectors to a specific address
; in memory and executes it there.  Ensure program to load has been
; relocated from a program file into a binary file to run at the
; specified address FIRST !!
;
; Program must NOT go into supervisor mode, as supervisor mode is
; already present.

	opt	p+

	bra.s	start
	dc.b	"Bootsector Loader by MUG U.K - 22/12/1991"


start	pea	text(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

loadsect	move.w	#0,-(sp)		; drive 0 or 1
	move.w	#1,-(sp)		; logical sector to start at
	move.w	#140,-(sp)	; number of sectors to be read
	move.l	#startaddr,-(sp)	; destination address
	move.w	#2,-(sp)		; mode = read + ignore (2)
	move.w	#4,-(sp)		; '_floprd'
	trap	#13		; BIOS
	lea	14(a7),sp 	; tidy stack

	jmp	startaddr		; call loaded program


text	dc.b	27,"Y",44,40
	dc.b	"Please Wait ..."
	dc.b	0

;
; Pad out rest of bootsector with zeros
;
; When you assemble this code from GenST, you will have to alter this
; figure below so that the assembled size equals 480 bytes !!
;

blanks	ds.b	366

startaddr	equ	$00030000