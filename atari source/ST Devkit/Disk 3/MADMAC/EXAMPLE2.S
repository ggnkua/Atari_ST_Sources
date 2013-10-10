
;------------------------------------------------------------------------
;									:
;	Example #2							:
;									:
;------------------------------------------------------------------------

	.include atari			; include "atari.s" ST definitions

	Puts	#string
	Pterm0


string:	dc.b	"Hello again, world!\r\n",0
