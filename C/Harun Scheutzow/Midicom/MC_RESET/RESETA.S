		.EXPORT do_reset
MIDSTAT			EQU $FFFFFC04   ;STATUS UND STEUERREGISTER ACIA(MIDI)
MIDDATA			EQU $FFFFFC06
IKBDSTAT		EQU	$FFFFFC00
IKBDDATA        EQU	$FFFFFC02

do_reset:		move.b  MIDSTAT,D0
				btst    #$07,D0      ; interrupt durch MIDI?
				beq.s	midein1
				move.b  MIDDATA,D0
				bra.s	do_reset
midein1:		move.b  IKBDSTAT,D0
				btst    #$07,D0      ; interrupt durch MIDI?
				beq.s	IKBDEIN
				move.b  IKBDDATA,D0
				bra.s	do_reset
IKBDEIN:		rts		