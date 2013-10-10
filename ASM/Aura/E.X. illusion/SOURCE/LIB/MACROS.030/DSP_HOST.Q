; Makros zur Handhabung des DSP-Port B von Hostseite.

; Start: September 1993
; Letztes Update: 7.1.1994
; AdressregisterÅbertragungen: 6.7.94

LEA_HOST_W	MACRO
	lea	$ffffa206.w,\1
	ENDM
LEA_HOST_L	MACRO
	lea	$ffffa204.w,\1
	ENDM

WAIT_DSP	MACRO		; Warten, bis DSP sendet.
	btst	#0,$ffffa202.w
	beq.s	*-6
	ENDM

WAIT_DSP_W	MACRO		; Warten, bis DSP emfangsbereit.
	btst	#1,$ffffa202.w
	beq.s	*-6
	ENDM


TX_DSP_W	MACRO		; Wort an DSP.
	move.w	\1,$ffffa206.w
	ENDM

TX_DSP_L	MACRO		; Langwort an DSP.
	move.l	\1,$ffffa204.w
	ENDM

TX_DSP_Wa	MACRO		; Word an DSP Åber ax-Reg.
	move.w	\1,(\2)
	ENDM

TX_DSP_La	MACRO		; Langwort an DSP Åber ax.
	move.l	\1,(\2)
	ENDM

TX_DSP_Whs	MACRO		; Wort mit Handshake Åbertragen
	WAIT_DSP_W
	TX_DSP_W \1 
	ENDM

TX_DSP_Lhs	MACRO		; Langwort mit Handshake
	WAIT_DSP_W
	TX_DSP_L \1
	ENDM

TX_DSP_Wahs	MACRO		; Wort mit Handshake Åbertragen
	WAIT_DSP_W
	TX_DSP_Wa \1,\2 
	ENDM

TX_DSP_Lahs	MACRO		; Langwort mit Handshake
	WAIT_DSP_W
	TX_DSP_La \1,\2
	ENDM


RX_DSP_W	MACRO		; Wort vom DSP.
	move.w	$ffffa206.w,\1
	ENDM

RX_DSP_L	MACRO		; Langwort vom DSP.
	move.l	$ffffa204.w,\1
	ENDM

RX_DSP_Whs	MACRO		; Wort mit Handshake holen.
	WAIT_DSP
	RX_DSP_W \1 
	ENDM

RX_DSP_Lhs	MACRO		; Langwort mit Handshake holen.
	WAIT_DSP
	RX_DSP_L \1
	ENDM

RX_DSP_Wa	MACRO		; Wort vom DSP.
	move.w	(\2),\1
	ENDM

RX_DSP_La	MACRO		; Langwort vom DSP.
	move.l	(\2),\1
	ENDM

RX_DSP_Wahs	MACRO		; Wort mit Handshake holen.
	WAIT_DSP
	RX_DSP_Wa \1,\2 
	ENDM

RX_DSP_Lahs	MACRO		; Langwort mit Handshake holen.
	WAIT_DSP
	RX_DSP_La \1,\2
	ENDM


TX_PNT2D_W	MACRO		; 2D-Punkt (word) Åbertragen.
	TX_DSP_W (\1)+	; Parameter: ax
	TX_DSP_W (\1)+
	ENDM

TX_PNT3D_W	MACRO		; 3D-Punkt (word) Åbertragen.
	TX_PNT2D_W \1	; Parameter: ax
	TX_DSP_W (\1)+
	ENDM

RX_PNT2D_W	MACRO		; 2D-Punkt (word) empfangen.
	RX_DSP_W (\1)+	; Parameter: ax
	RX_DSP_W (\1)+
	ENDM

RX_PNT3D_W	MACRO		; 3D-Punkt (word) empfangen.
	RX_PNT2D_W \1	; Parameter: ax
	RX_DSP_W (\1)+
	ENDM
