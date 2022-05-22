FadeinFloor	LEA Floorfadeto_vars(pc),a5
		MOVE.L #currfloorpal,fadeto_curptr(a5)
		MOVE.L #destfloorpal,fadeto_palptr(a5)
		MOVE.W #7,fadeto_nocols(a5)
		MOVE.W #8,fadeto_cnt(a5)
		MOVE.B #2,fadeto_tim(a5)
		MOVE.B #2,fadeto_spd(a5)
		ST.B fadetoflag(a5)
.notfaded	TST.B fadetoflag(a5)
		BNE.S .notfaded
		RTS

; Nice 'n' flexible rout to fade from one palette to another.
; A5 -> fade variables structure as below :-

		rsreset
fadeto_curptr	rs.l 1			; current palette(from -> dest)
fadeto_palptr	rs.l 1			; destination palette
fadeto_nocols	rs.w 1			; no of colours in palette
fadeto_cnt	rs.w 1			; count until fade is done.
fadeto_tim	rs.b 1			; vbl count
fadeto_spd	rs.b 1			; vbl fade delay speed
fadetoflag:	rs.b 1			; fade flag(true if fading)
fadeto_varsize	rs.b 1			; structure size

Fade_to		tst.b fadetoflag(a5)	; fading ?
		beq .nofadeto	
		subq.b #1,fadeto_tim(a5) ; vbl count-1
		bgt.s .nofadeto
		move.b fadeto_spd(a5),fadeto_tim(a5)   ; reset speed (vbl count)
		subq #1,fadeto_cnt(a5)	; faded -> totally?
		bne.s .okstillfade
		sf.b fadetoflag(a5)	; yes signal fade done.
		move #8,fadeto_cnt(a5)  ; and reset for next fade. 
.okstillfade	move.l fadeto_curptr(a5),a0 	; pal to fade FROM
		move.l fadeto_palptr(a5),a1	; ptr to pal to fade TO.
		move  #$700,d4		; R mask
		moveq #$070,d5		; G mask
		moveq #$007,d6		; B mask
		move.w fadeto_nocols(a5),d7
		subq #1,d7
.col_lp		move.w (a0),d0		; curr value
		move.w (a1)+,d1
		move.w d0,d2
		move.w d1,d3
		and.w d4,d2
		and.w d4,d3
		cmp.w d3,d2
		beq.s .R_done
		blt.s .R_add
		sub.w #$100,d0
		bra.s .R_done
.R_add		add.w #$100,d0
.R_done		move.w d0,d2
		move.w d1,d3
		and.w d5,d2
		and.w d5,d3
		cmp.w d3,d2
		beq.s .G_done
		blt.s .G_add
		sub.w #$010,d0
		bra.s .G_done
.G_add		add.w #$010,d0
.G_done 	move.w d0,d2
		move.w d1,d3
		and.w d6,d2
		and.w d6,d3
		cmp.w d3,d2
		beq.s .B_done
		blt.s .B_add
		subq.w #$001,d0
		bra.s .B_done
.B_add		addq.w #$001,d0
.B_done		move.w D0,(a0)+
		dbf d7,.col_lp
.nofadeto	rts

Floorfadeto_vars:
		ds.b fadeto_varsize
		even
currfloorpal	ds.w 16
destfloorpal	dc.w $001,$002,$003,$004,$005,$006,$007
