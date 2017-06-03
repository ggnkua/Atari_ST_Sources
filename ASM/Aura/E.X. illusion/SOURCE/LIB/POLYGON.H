		IFND	_RAW_POLYGON
_RAW_POLYGON	EQU		$0313

.pg_base:		INLINE	"POLYGON.INC"

PG_CLIPP_INIT	EQU		.pg_base+2		; Clipping initialisieren.
PG_CALC			EQU		.pg_base		; Polygonkanten berechnen.

; PG_CLIPP_INIT:
PGC_X0			EQUR	d0				; Clippbox: x-min
PGC_X1			EQUR	d1				;			x-max
PGC_Y0			EQUR	d2				;			y-min
PGC_Y1			EQUR	d3				;			y-max

; PG_CALC:
PG_EDGES		EQUR	a6				; Nummern der Eckpunkte
PG_POINTS		EQUR	a5				; Punktearray
PG_RIGHT		EQUR	a4				; Rechtes Koordinatenarray
PG_LEFT			EQUR	a3				; Linkes		"
PG_ANZ_EDG		EQUR	d7				; Anzahl Eckpunkte
; Return:
PG_INOUT		EQUR	d0				; Polygon komplett ausserhalb-Flag.
PG_MIN			EQUR	a2				; Polygon-min-y
PG_MAX			EQUR	a3				; Polygon-max-y
		ENDIF