		IFND	D_GOURAUD
D_GOURAUD		EQU		$0099

		IFND	SCR_H							
SCR_H			EQU		256					; UNVERŽNDERBAR ohne Neuass. des
		ENDIF								; Moduls !!!

_gouraud_base:	INLINE	"GOURAUD.INC"

DRAW_GOURAUD	EQU		_gouraud_base		; Polygonausgabe
INIT_GOURAUD	EQU		_gouraud_base+4		; Routineninitialisierung
BUILD_SC_OFFS	EQU		_gouraud_base+8		; Generiert Scanoffsettabelle

; Initialisierungsroutine INIT_GOURAUD
IG_SCR_WIDE		EQUR	d0
IG_SCR_HIGH		EQUR	d1
IG_ANZ_COLS		EQUR	d2
IG_SCAN_OFF		EQUR	a0
IG_LEFT_KOO		EQUR	a1
IG_COL_DIST		EQUR	a2
IG_COL_DIST_PO	EQUR	a3
IG_CLIPPING		EQUR	a4

; Ausgaberoutine DRAW_GOURAUD
DG_SCR_BASE		EQUR	a0					; Videoramadresse
DG_POINTS		EQUR	a5					; Randpunkte (inkl. Farben)
DG_POLY_STRUCT	EQUR	a6					; Polygonstruktur

; Generierung einer Scanlinetabelle BUILD_SC_OFFS
IG_BYTES_SCAN	EQUR	d0
IG_SCR_OFFS		EQUR	a0
		ENDIF