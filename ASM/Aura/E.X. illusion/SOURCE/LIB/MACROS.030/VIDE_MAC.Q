; Makros zur Behandlung des Videosystems.
; šbersicht:
; SAVE_VID	- Sichert Videosystem in Bufferarray	[FALCON]
; SET_VID	- Setzt Videosystem aus Buffer		[FALCON]
; SET_V_ADR	- Setzt Videoadresse				[ST>>]

; ==================================
; Sichert Falcon Videosystem.
; ==================================
SAVE_VID	MACRO
	movem.l	a0-a1,-(sp)
	move.l	\1,a0
	lea	$ffff8200.w,a1	; Videobase.
	move.w	$60(A1),(A0)+
	move.w	$66(A1),(A0)+
	move.l  $C0(A1),(A0)+

	move.w  $0A(A1),(A0)+
	move.w  $0E(A1),(A0)+
	move.w  $10(A1),(A0)+
	move.l  $82(A1),(A0)+
	move.l  $86(A1),(A0)+
	move.l  $8A(A1),(A0)+
	move.l  $A2(A1),(A0)+
	move.l  $A6(A1),(A0)+
	move.l  $AA(A1),(A0)+
	movem.l	(sp)+,a0-a1
	ENDM

; Setz Videosystem, Block als Para.
SET_VID	MACRO
	movem.l	a0-a1,-(sp)
	move.l	\1,a0
	lea	$ffff8200.w,a1	; Videobase.
	move.w	(a0)+,$60(A1)
	move.w	(a0)+,$66(A1)
	move.l  (a0)+,$C0(A1)

	move.w  (a0)+,$0A(A1)
	move.w  (a0)+,$0E(A1)
	move.w  (a0)+,$10(A1)
	move.l  (a0)+,$82(A1)
	move.l  (a0)+,$86(A1)
	move.l  (a0)+,$8A(A1)
	move.l  (a0)+,$A2(A1)
	move.l  (a0)+,$A6(A1)
	move.l  (a0)+,$AA(A1)
	movem.l	(sp)+,a0-a1
	ENDM

; ==================================
; Videoadresse setzen.
; \1 = Datenregister mit Adresse.
; \2 = Ax || dx, Hilfsregister (crash).
; ==================================
SET_V_ADR	MACRO
	move.b	\1,\2
	lsr.w	#8,\1
	move.l	\1,$ffff8200.w
	move.b	\2,$ffff820d.w
	ENDM