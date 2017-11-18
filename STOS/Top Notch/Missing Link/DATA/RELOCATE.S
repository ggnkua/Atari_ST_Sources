;Small test program for use in the 'relocate' command demonstration.
;Assemble using Devpac 2 (or greater)

	output	relocate.prg

test				;remove this label when 
				;assembling for use with
				;STOS.

	ifd	test
	pea	0
	move.w	#32,-(sp)		;supervisor mode
	trap	#1
	addq	#6,sp
	endc

	lea	cols,a5
keyloop
	move.w	#37,-(sp)		;wait vbl
	trap	#14
	addq	#2,sp

	move.w	(a5)+,$ffff8240.w	;flash colours

	cmpi.w	#$ffff,(a5)	;check for end of colours
	bne.s	notrestart	;
	lea	cols,a5		;

notrestart
	cmpi.b	#57,$fffffc02.w	;chech for space (badly)
	bne.s	keyloop

	ifd	test

	move.w	#$777,$ffff8240.w	;restore colours
	move.w	#0,$ffff8242.w	;

	pea	0		;user mode
	move.w	#32,-(sp)		;
	trap	#1		;
	addq	#6,sp		;

	clr.l	-(sp)		;return to gem/devpac
	trap	#1		;
	endc

	rts			;return to STOS

cols
	dc.w	0,$111,$2222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111
	dc.w	0,$11,$22,$33,$44,$55,$66,$77,$66,$55,$44,$33,$22,$11
	dc.w	0,$1,$2,$3,$4,$5,$6,$7,$6,$5,$4,$3,$2,$1	
	dc.w	$ffff