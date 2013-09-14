.include	"mfp.h"
.include	"ide.h"

	clr.l	-(sp)			; it's a bird...
	move.w	#$20,-(sp)		;    ... it's a plane ...
	trap	#1			;      ... no, its:
	addq.l	#6,sp			; SOOUPERUSER!

loop:	move.b	#READ,IDECR
	bra.s	loop

