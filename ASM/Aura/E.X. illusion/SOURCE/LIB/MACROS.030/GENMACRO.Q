; Allgemeine (kleine, hilfreiche) Makros fÅr den tÑglichen Bedarf.
; 1991-98 Jochen -BDC- Knaus

         IFND	FALSE
TRUE	EQU	1
FALSE	EQU	0
         ENDIF

; öbersicht:
; =====================================================================
; MULF_3	dx.w * 3 (Hilfsreg. benîtigt)		ST(E)/TT/F030
; MULF_3L	dx.l * 3 (         "		  )			  "
; MULF_6	dx.w * 6 (         "		  )			  "
; MULF_6L	dx.l * 6 (         "		  )			  "
; INDIC_ON	Hintergrundfarbezeitanzeige an.	F030
; INDIC_OFF		     "		  aus.  F030
; GET_TIME	ax					TT/F030
; GET_TIMEA	ax,ay					TT/F030
; =====================================================================

; Schnelle Multiplikation * 3.
; Parameter 1:	Dx/Ax, welches mit 3 (.w) mult. werden soll.
; Parameter 2:	Hilfsregister oder Adresse, enth. alten Wert.
MULF_3	MACRO					; Schnellmultiplikation * 3
	move.w	\1,\2				; \1 Para: Datenregister (*3)
	add.w	\1,\1				; \2 Para: Hilfsregister
	add.w	\2,\1
	ENDM

MULF_3L	MACRO					; * 3 mit Longs.
	move.l	\1,\2
	add.l	\1,\1
	add.l	\2,\1
	ENDM

MULF_6	MACRO					; Schnellmultiplikation * 6
	MULF_3	\1,\2
	add.w	\1,\1
	ENDM

MULF_6L	MACRO
	MULF_3L	\1,\2
	add.l	\1,\1
	ENDM

INDIC_ON	MACRO					; Zeitanzeige: rot
	move.l	#$ff000000,$ffff9800.w
	ENDM

INDIC_OFF	MACRO					; Zeitanzeige: weiû
	move.l	#$ffffffff,$ffff9800.w
	ENDM

; Holt Zeit in \1 und benutzt \2 (Adressreg.) als Hilfsreg.
GET_TIMEA	MACRO
	lea	$ffff8961.w,\2
	move.b	#4,(\2)	; Reg. 4: Stunden.
	move.b	2(\2),(\1)+
	move.b	#2,(\2)
	move.b	2(\2),(\1)+	; Reg. 2: Minuten.
	clr.b	(\2)
	move.b	2(\2),(\1)	; Reg. 0: Sekunden.
	ENDM

; Holt Zeit in \1
GET_TIME	MACRO
	move.b	#4,$ffff8961.w
	move.b	$ffff8963.w,(\1)+	; Stunden
	move.b	#2,$ffff8961.w
	move.b	$ffff8963.w,(\1)+	; Minuten
	clr.b	$ffff8961.w
	move.b	$ffff8963.w,(\1)+	; Sekunden
	ENDM

