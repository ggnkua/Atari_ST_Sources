; ROCKYONE 			pour MI-3 et Mi9		16/11/2015
; Source SHADOW 
;
;
;modifi‚ pour MI-9: 	ajout recopie sur ‚cran avec limit%
;			ajout table dans la routine
;
;	rotation verticale basse moyenne et haute r‚solution 
;
;			   a0		a1	   d0     d2
;	CALL Invx_0_1( L Source, L Destination, Plan%, limit%)
;
;-------------------------------------------------------------------------
;
;A0 / a4	source
;A1 / A5	destination
;A2		tableau d'‚quivalance
;d0		masque de plans a retourner   %1111 celons resolution
;                                      plan    4321
;d1		resol puis nombre de ligne
;d2 		nombre de word par line/ pus limit% pour copy_on_screen
;d3 		cpt de d2
;d4		ecart entre deux word
;d5 d6 		byte a retourner
;d7 ..
;-------------------------------------------------------------------------

		movem.l	d0-d7/a0-a6,-(sp)
		movem.l	64(sp),a0-a2
		move.w	72(sp),d0
*		beq 	fin		; aucun plan a retourner

		moveq.l	#0,d5
		lea.l	table_rh(pc),a2		; table de conversion
	
		move.b	($44c),d1		; r‚solution ?
		cmpi.b	#2,d1
		beq.s	haute_resol

		moveq.l	#20,d2			; Nombre de bloc par plan
		lsl.b	d1,d2			; sur une ligne : 20  40
		subq.b	#1,d2			: -1 pour dbra

		moveq.l	#8,d4			; ecart entre deux bloc 	
		lsr.b	d1,d4			; d'un plan  : 8  4  2

		moveq.l	#0,d6
		adda.w	#160,a0			; droite de l'‚cran
		suba.w	d4,a0			; 152 156
;-------------------------------------------------------------------------
* basse et moyenne resolution

plane:		btst.b	#0,d0			; retourner ce plan ?
		beq.s	plan_suivant
	
		move.w	#199,d1			; nombre de ligne
		movea.l	a0,a4
		movea.l	a1,a5

ligne:		move.w	d2,d3			; 20 40  bloc  par ligne

bloc_plan:	move.b	(a4),d5
		move.b	1(a4),d6
		move.b	0(a2,d6.w),(a5)
		move.b	0(a2,d5.w),1(a5)
		suba.w	d4,a4			
		adda.w	d4,a5			

		dbra.w	d3,bloc_plan
		lea.l	320(a4),a4

		dbra.w	d1,ligne

plan_suivant:	addq.l	#2,a0
		addq.l	#2,a1
		lsr.b	#1,d0
		bne.s	plane

		bra.s	copy
;-------------------------------------------------------------------------

haute_resol:	move.w	#399,d1
		lea.l	80(a0),a0
ligne_hr:	move.w	#79,d2			; 80 byte par ligne	
	
byte_ligne:	move.b	-(a0),d5
		move.b	0(a2,d5.w),(a1)+
		dbra.w	d2,byte_ligne
		lea.l	160(a0),a0		; source fin ligne suivante
		dbra.w	d1,ligne_hr

;------------------------------------------------------------------------

copy:		movem.l	64(sp),a0-a1
		lea.l	32000(a0),a2
r_copy:		move.l	(a1)+,(a0)+
		cmpa.l	a0,a2
		bhi.s	r_copy

on_screen:	move.l	64(sp),a0
		movea.l	a0,a2
		adda.w	74(sp),a2
		move.l	$44e,a1
recopy:		move.l	(a0)+,(a1)+
		cmpa.l	a0,a2
		bhi.s	recopy

;------------------------------------------------------------------------
		movem.l	(sp)+,d0-d7/a0-a6
		rts
table_rh:	
	even
;	 0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
 dc.b	$00,$80,$40,$C0,$20,$A0,$60,$E0,$10,$90,$50,$D0,$30,$B0,$70,$F0
 dc.b	$08,$88,$48,$C8,$28,$A8,$68,$E8,$18,$98,$58,$D8,$38,$B8,$78,$F8
 dc.b	$04,$84,$44,$C4,$24,$A4,$64,$E4,$14,$94,$54,$D4,$34,$B4,$74,$F4
 dc.b	$0C,$8C,$4C,$CC,$2C,$AC,$6C,$EC,$1C,$9C,$5C,$DC,$3C,$BC,$7C,$FC
 dc.b	$02,$82,$42,$C2,$22,$A2,$62,$E2,$12,$92,$52,$D2,$32,$B2,$72,$F2
 dc.b	$0A,$8A,$4A,$CA,$2A,$AA,$6A,$EA,$1A,$9A,$5A,$DA,$3A,$BA,$7A,$FA
 dc.b	$06,$86,$46,$C6,$26,$A6,$66,$E6,$16,$96,$56,$D6,$36,$B6,$76,$F6
 dc.b	$0E,$8E,$4E,$CE,$2E,$AE,$6E,$EE,$1E,$9E,$5E,$DE,$3E,$BE,$7E,$FE
 dc.b	$01,$81,$41,$C1,$21,$A1,$61,$E1,$11,$91,$51,$D1,$31,$B1,$71,$F1
 dc.b	$09,$89,$49,$C9,$29,$A9,$69,$E9,$19,$99,$59,$D9,$39,$B9,$79,$F9
 dc.b	$05,$85,$45,$C5,$25,$A5,$65,$E5,$15,$95,$55,$D5,$35,$B5,$75,$F5
 dc.b	$0D,$8D,$4D,$CD,$2D,$AD,$6D,$ED,$1D,$9D,$5D,$DD,$3D,$BD,$7D,$FD
 dc.b	$03,$83,$43,$C3,$23,$A3,$63,$E3,$13,$93,$53,$D3,$33,$B3,$73,$F3
 dc.b	$0B,$8B,$4B,$CB,$2B,$AB,$6B,$EB,$1B,$9B,$5B,$DB,$3B,$BB,$7B,$FB
 dc.b	$07,$87,$47,$C7,$27,$A7,$67,$E7,$17,$97,$57,$D7,$37,$B7,$77,$F7
 dc.b	$0F,$8F,$4F,$CF,$2F,$AF,$6F,$EF,$1F,$9F,$5F,$DF,$3F,$BF,$7F,$FF
	even
	end
;------------------------------------------------------------------------

