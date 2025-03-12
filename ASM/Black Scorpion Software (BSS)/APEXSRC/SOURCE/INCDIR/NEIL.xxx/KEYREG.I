
;--------------------------------------------------------------------
; KEYBOARD / MIDI REGISTERS
;--------------------------------------------------------------------

K_KEY_STATUS	=	$FFFFFC00
K_KEY_CTRL	=	$FFFFFC00
K_KEY_DATA	=	$FFFFFC02
K_KEY_RXREADY	=	0
K_KEY_TXREADY	=	1
K_KEY_FRAMEERR	=	4
K_KEY_OVERRUN	=	5
K_KEY_PARITYERR	=	6

K_MIDI_STAT	=	$FFFFFC04
K_MIDI_CTRL	=	$FFFFFC04
K_MIDI_DATA	=	$FFFFFC06

;--------------------------------------------------------------------
; VECTOR
;--------------------------------------------------------------------

K_KEYVEC	=	$118
