		IFND	_HLINE4_HH
_HLINE4_HH		EQU		$0200

; H16_BUILD:
H16_ROUTBUF		EQUR	a0		; Buffer fÅr HLine-Coder (16*260 Bytes)
H16_OFFBUF		EQUR	a1		; Adress- unf Planetab (16*16 Bytes)

; H16_OFF_TAB
H16_LOFF		EQUR	a0		; Linkes Offsetarray
H16_ROFF		EQUR	a1		; Rechtes	  "
H16_LINOFF		EQUR	a2		; Scanlineoffsettab.
		ENDIF