TRUE 	= -1
FALSE	= 0


	rsset 0

SHOW_SCREEN	rs.l	1	; active screen
WORK_SCREEN	rs.l	1	; next screen to display
EXTRA_SCREEN	rs.l	1
SCREEN_COUNT	rs.w	1	; number of screens
SCREEN_SWAP	rs.w	1	; if set true, screens are swapped next vbl

PALETTE		rs.l	1	; pointer to 256 color palette
PALETTE_UPDATE	rs.w	1	; if set true, palette is updated next vbl

COUNTER_ABS	rs.l	1	; vbl-counter since music started
COUNTER_REL	rs.l	1	; vbl-counter since procedure init

SCRMODE		rs.l	1
SCRMODE_UPDATE	rs.w	1

parameters	dc.l	0

demo_swapscreens MACRO
	move.l	parameters,a0
	move.w	#TRUE,SCREEN_SWAP(a0)
	ENDM

RETURN MACRO
*	jmp	\1
	clr.w	-(sp)
	move.l	#\1,-(sp)
	move.w	#$2300,-(sp)
	jmp	task_switch
	ENDM