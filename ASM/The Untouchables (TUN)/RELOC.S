*-------------------------------------------------------------------------*
* CODE RELOCATION ROUTINE FOR RELOCATABLE FILES.   	    THE HIGHLANDER.
*-------------------------------------------------------------------------*
* This is a really useful routine I picked up a while back. I think it
* actually came from an old ST NEWS. What it does is to relocate, any
* relocatable file to the current memory location.
*
* You call the function "RELOCATE" with a6 pointing to the start of the
* program file.This then relocates the code to the correct memory address
* to allow it to be run by you. You can then call the code by just jumping
* to the start address of it.
*
* EXAMPLE:
*
*	MAIN:	clr.l	-(sp)
*		move.w	#$20,-(sp)
*		trap	#1
*		addq.l	#6,sp
*
*		move.l	#MUSIC_PLAY,a6
*		bsr	RELOCATE
*
*		jmp	MUSIC_PLAY	; run it as if the program
*					; were just double clicked!
*
* 	MUSIC_PLAY:
*		incbin	"crap.tos"
*-------------------------------------------------------------------------*

RELOCATE:
		move.l	a6,a0
		move.l  2(a0),d0 ;	Length of PROGRAM 
		add.l   6(a0),d0      
		add.l   14(a0),d0;	Length of SYMBOL TABLE

; d0 contains relative position of RELOCATION TABLE

		add.l   #$1C,a0  ;	A0 Points to programs start adress
		move.l  a0,a1         
		move.l  a1,a2         
		move.l	a6,d1
		add.l	#$1c,d1

		add.l   d0,a1   ;	Get adress of RELOCATION TABLE
		move.l  (a1)+,d0;	Get the Long Word
		add.l   d0,a2         
		add.l   d1,(a2) ;	Relocate it
		clr.l   d0            
mRELO:		move.B  (a1)+,d0;	Get next byte from table
		beq     mRELEND ;	Is it the end (zero)
		cmp.b   #1,d0   ;	1 is a 254 jump
		beq     mJUMP   ;	If it is then do it
		add.l   d0,a2   ;	If not find next absolute adress
		add.l   d1,(a2) ;	and relocate it
		bra     mRELO   ;	Continue until the zero is found
mJUMP:		add.l   #254,a2 ;	Jump 254 bytes
		bra     mRELO	; 	and continue
mRELEND:	rts
		