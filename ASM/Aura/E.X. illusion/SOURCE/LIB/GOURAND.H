; Kantenberechnung und Farbinterpolation entlang des Polygonrandes.
; (C) 1994 Jochen Knaus (BDCannibal/AURA/Independent)

			IFND	_GOURAND
_GOURAND		EQU		1

	IFND	SCR_H							
SCR_H		EQU		256						; UNVERŽNDERBAR ohne Neuass. des
	ENDIF									; Moduls !!!

_gourandbase:
				INLINE	"F:\LIB\GOURAND.INC"	; Polygonroutine.

GOURAND			EQU	_gourandbase+4			; Routinenadressen
INIT_CLIPPING	EQU	_gourandbase

; GOURAND-Call-Parameter:
DG_ECKPUNKTE	EQUR	a6		; Eckpunktarray
DG_PUNKTE		EQUR	a5		; Projezierte Punkt (X/Y/Farbe/0)
DG_R_KOORDS		EQUR	a4		; Rechtes Koordinatenarray
DG_L_KOORDS		EQUR	a3		; Linkes Koordinatenarray
DG_R_LIGHTS		EQUR	a2		; Rechtes Farbenarray
DG_L_LIGHTS		EQUR	a1		; Linkes Farbarray
DG_ANZ_PNTS		EQUR	d7		; Anzahl Eckpunkte

; GOURAND-Return-Parameter:
DG_MIN_Y		EQUR	a2		; min_y (word)
DG_MAX_Y		EQUR	a3		; max_y (word)
DG_INOUT		EQUR	d0		; 0 = in / 1 = aus.

; INIT_CLIPPING-Call-Paramater:
IC_CLIPPBOX		EQUR	a0		; Array: minx/maxx/miny/maxy
			ENDIF