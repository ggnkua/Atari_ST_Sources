;**************************************************************************
;
; SNDBIND.s	Example "C" style binding routines to the Atari SOUND
;		Extended Bios routines and assembly lauguage interface.
;
;		Started: 	07/7/92		Mike Schmal
;		Last Update:	07/7/92
;
;	MATRIX HG 30 Sept '93
;
;**************************************************************************


	.export	SOUND


;**************************************************************************
;
; SOUND		"C" interface for the Atari SOUND Extended Bios.
;
;**************************************************************************
;long	SOUND (int Num, ...);

SOUND:
	move.l	(sp)+,savsp
	trap	#14
	move.l	savsp,-(sp)
	rts


	.bss
savsp:	.ds.l	1	; Save calling routines return address
	.end
