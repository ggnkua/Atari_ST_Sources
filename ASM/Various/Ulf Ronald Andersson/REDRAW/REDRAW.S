;----------------------------------------------------------------------------
;File name:	REDRAW.S			Revision date:	1996.02.10
;Creator:	Ulf Ronald Andersson		Creation date:	1995.08.20
;Version:	1.0
;----------------------------------------------------------------------------
;
	output	.PRG
;
	include	URAn_APP.S
;
;----------------------------------------------------------------------------
;
		data
;
acc_name:	dc.b	'  Redraw screen ',NUL
		even
;
;----------------------------------------------------------------------------
		bss
;
mystack_data:	ds.l	$100
mystack:	ds.w	1	;User defined stack (goes backwards).
message:	ds.b	16	;Message pipe.
intin:		ds.w	30
intout:		ds.w	45
ptsin:		ds.w	30
ptsout:		ds.w	12
;
;----------------------------------------------------------------------------
;
	text
;
;----------------------------------------------------------------------------
;
init_app:
	rts
;
;
exec_app:
	tst	d7
	bmi.s	TOS_app
GEM_app:
	aes_redraw
TOS_app:
	clr.l	d0
	rts	;This is the program exit, back to caller (or desktop)
;
;
;----------------------------------------------------------------------------
;
	make	GEM_links
;
;----------------------------------------------------------------------------
; End of file:	REDRAW.S
;----------------------------------------------------------------------------
