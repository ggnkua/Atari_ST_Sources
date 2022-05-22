;----------------------------------------------------------
; Fade routs.

currpal		DS.W 16
blank_pal	DS.W 16

; Set off a fade in
; A0 -> currpal A1 -> fade in palette

SetFadein	LEA fadein_vars(pc),a5
		MOVE.L #currpal,fadein_curptr(a5)
		MOVE.L A1,fadein_palptr(a5)
		MOVE.W #16,fadein_nocols(a5)
		MOVE.B #3,fadein_tim(a5)
		MOVE.B #3,fadein_spd(a5)
		ST.B fadeinflag(a5)
		RTS

; Set off a fade out

SetFadeout	LEA fadeout_vars(pc),a5
		MOVE.L #currpal,fadeout_curptr(a5)
		MOVE.W #16,fadeout_nocols(a5)
		MOVE.B #3,fadeout_tim(a5)
		MOVE.B #3,fadeout_spd(a5)
		ST.B fadeoutflag(a5)
		RTS

; Nice fade in routine. 
; ->Fade variables structure as below :-

		rsreset
fadein_curptr	rs.l 1			; current palette(from -> dest)
fadein_palptr	rs.l 1			; destination palette
fadein_nocols	rs.w 1			; no of colours in palette
fadein_tim	rs.b 1			; vbl count
fadein_spd	rs.b 1			; vbl fade delay speed
fadeinflag	rs.b 1			; fade flag(true if fading)
fadein_varsize	rs.b 1			; structure size

NiceFadein	LEA fadein_vars(pc),a5
		TST.B fadeinflag(a5)		; fading ?
		BEQ .nofadein	
		SUBQ.B #1,fadein_tim(a5) 	; vbl count-1
		BGT.S .nofadein
		MOVE.B fadein_spd(a5),fadein_tim(a5)    ; reset speed (vbl count)
.okstillfade	MOVE.L fadein_curptr(a5),a0 	; pal to fade FROM
		MOVE.L fadein_palptr(a5),a1	; ptr to pal to fade TO.
		MOVE.W fadein_nocols(a5),d7
		SUBQ #1,d7
		MOVE.L A0,A2
		MOVE.L A1,A3
		BSR.S dfadein
		MOVE.L A0,A2
		MOVE.L A1,A3
		MOVE.W fadein_nocols(a5),d0
		SUBQ #1,D0
.lp		MOVE.W (A2)+,D1
		MOVE.W (A3)+,D2
		ANDI.W #$777,D1
		ANDI.W #$777,D2
		CMP.W D1,D2
		BNE.S .nofadein
.ok		DBF D0,.lp
		SF.B fadeinflag(a5)		; yes signal fade done.
.nofadein	RTS

dfadein		MOVE.W	(A2),D0
		MOVE.W	(A3),D1
		ANDI.W	#7,D0
		ANDI.W	#7,D1
		CMP.W	D0,D1
		BEQ.S	L22CCE
		ADDI.W	#1,D0
		MOVE.W	(A2),D1
		ANDI.W	#$FFF8,D1
		OR.W	D0,D1
		MOVE.W	D1,(A2)
		BRA.S	L22D0E
L22CCE		MOVE.W	(A2),D0
		MOVE.W	(A3),D1
		ANDI.W	#$700,D0
		ANDI.W	#$700,D1
		CMP.W	D0,D1
		BEQ.S	L22CEE
		ADDI.W	#$100,D0
		MOVE.W	(A2),D1
		ANDI.W	#$F8FF,D1
		OR.W	D0,D1
		MOVE.W	D1,(A2)
		BRA.S	L22D0E
L22CEE		MOVE.W	(A2),D0
		MOVE.W	(A3),D1
		ANDI.W	#$70,D0
		ANDI.W	#$70,D1
		CMP.W	D0,D1
		BEQ	L22D0E
		ADDI.W	#$10,D0
		MOVE.W	(A2),D1
		ANDI.W	#$FF8F,D1
		OR.W	D0,D1
		MOVE.W	D1,(A2)
L22D0E		ADDQ.L	#2,A2
		ADDQ.L	#2,A3
		DBF	D7,dfadein
		RTS

fadein_vars:	ds.b fadein_varsize
		even

; Nice fade OUT routine. 
; ->Fade variables structure as below :-

		rsreset
fadeout_curptr	rs.l 1			; current palette(from -> dest)
fadeout_nocols	rs.w 1			; no of colours in palette
fadeout_tim	rs.b 1			; vbl count
fadeout_spd	rs.b 1			; vbl fade delay speed
fadeoutflag	rs.b 1			; fade flag(true if fading)
fadeout_varsize	rs.b 1			; structure size

NiceFadeout	LEA fadeout_vars(pc),a5
		TST.B fadeoutflag(a5)		; fading ?
		BEQ .nofadeout	
		SUBQ.B #1,fadeout_tim(a5) 	; vbl count-1
		BGT.S .nofadeout
		MOVE.B fadeout_spd(a5),fadeout_tim(a5)    ; reset speed (vbl count)
.okstillfade	MOVE.L fadeout_curptr(a5),a0 	; pal to fade FROM
		MOVE.W fadeout_nocols(a5),d7
		SUBQ #1,D7
		MOVE.L A0,A2
	 	BSR.S dfadeout
		MOVE.L A0,A2
		MOVE.W fadeout_nocols(a5),d0
		SUBQ #1,D0
.lp		MOVE.W (A2)+,D1
		ANDI.W #$777,D1
		BNE.S .nofadeout
		DBF D0,.lp
		SF.B fadeoutflag(a5)		; yes signal fade done.
.nofadeout	RTS

dfadeout	MOVE.W	(A2),D0
		ANDI.W	#$70,D0
		BEQ.S	L22D50
		SUBI.W	#$10,D0
		MOVE.W	(A2),D1
		ANDI.W	#$FF8F,D1
		OR.W	D0,D1
		MOVE.W	D1,(A2)
		BRA.S	L22D80
L22D50		MOVE.W	(A2),D0
		ANDI.W	#$700,D0
		BEQ.S	L22D68
		SUBI.W	#$100,D0
		MOVE.W	(A2),D1
		ANDI.W	#$F8FF,D1
		OR.W	D0,D1
		MOVE.W	D1,(A2)
		BRA.S	L22D80
L22D68		MOVE.W	(A2),D0
		ANDI.W	#7,D0
		BEQ	L22D80
		SUBI.W	#1,D0
		MOVE.W	(A2),D1
		ANDI.W	#$FFF8,D1
		OR.W	D0,D1
		MOVE.W	D1,(A2)
L22D80		ADDQ.L	#2,A2
		DBF	D7,dfadeout
		RTS

fadeout_vars	DS.B fadeout_varsize	
		EVEN
