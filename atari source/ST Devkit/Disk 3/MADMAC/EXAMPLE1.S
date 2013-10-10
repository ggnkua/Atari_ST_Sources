
;------------------------------------------------------------------------
;									:
;	Example #1							:
;									:
;------------------------------------------------------------------------

	pea	string(pc)		; Cconws(&string)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	clr.w	-(sp)			; Pterm0()
	trap	#1
	illegal				; "cannot return"


string:	dc.b	"Hello, world!\r\n",0
