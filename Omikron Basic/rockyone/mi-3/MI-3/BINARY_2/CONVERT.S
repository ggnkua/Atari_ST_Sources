;rockyone			Pour MI-3 & MI-9		06/12/2017
;
;correction palette						19/02/2018
;
;			conversion resolution
;			---------------------
;		     haute en moyenne et iversement
;
;
; Source 	format PI1-3 l'image a convertir
; Temp		32034 octet, buffer de conversion
; pic_res 	resolution image
; new_res2 	nouvelle resolution	
;
;				
;     	call	convert_resol( L source, L temp, W pic_res, W new_res )
;		------------------------------------------------
;
; l'image convertie est remise dans Source
; les cycles de couleur ne sont pas converties 
;		
;-------------------------------------------------------------------------
; utilis‚ d0-d3/a0-a4
		movem.l d0-d7/a0-a6,-(sp) 
		movem.l	64(sp),a0-a1
		movem.w	72(sp),d0-d1
		move.w	d1,(a1)			; new resol
		
;...............................................clean up buffer conversion
		lea.l	34(a1),a3
		moveq.l	#0,d2

		lea.l	32000(a3),a4		; end buffer conversion
cls:		move.l	d2,(a3)+
		cmpa.l	a3,a4
		bhi.s	cls
;...............................................
*		tst.b	d1
*		beq	resol_0
		cmpi.b	#1,d1
		beq	resol_1
*		cmpi.b	#2,d1
*		beq.s	resol_2

;----------------------------CONVERT IN HIGH RESOLUSION--------------------
		tst.b	d0	; resol source ?
		bne.s	m_h

;......................................low to high........................
b_h:		move	2(a0),d0
		move	32(a0),d0
		bsr	new_pal
		move.w	d2,2(a1)
		move.w	d3,4(a1)
		adda.w	#34,a1

		move.l	#$c0000000,d7  ; bits tournant

low_high:	lea.l	80(a1),a2
		movea.l	a2,a3			; a3 fin d'une ligne

loop0:		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		move.w	#15,d4

		move.l	(a0)+,d5
		move.l	(a0)+,d6

plan_0:		btst.b	d4,d5
		beq.s	plan_2
		add.l	d7,d0

plan_2		btst.b	d4,d6
		beq.s	plan_1
		add.l	d7,d2
plan_1		
		swap 	d5
		swap	d6
		btst.b	d4,d5
		beq.s	plan_3
		add.l	d7,d1

plan_3		btst.b	d4,d6
		beq.s	next_bit
		add.l	d7,d3
	
next_bit:	swap	d5
		swap	d6
		ror.l	#2,d7
		dbra.w	d4,plan_0

		move.l	d0,(a1)
		move.l	d1,(a2)
		eor.l	d3,(a1)+
		eor.l	d2,(a2)+
		cmpa.l	a1,a3
		bhi.s	loop0
		movea.l	a2,a1	
		cmpa.l	a1,a4
		bhi.s	low_high
		bra.s	recopy_image
;......................................medium to high.....................
m_h		move.w	2(a0),d0
		move.w	4(a0),d1
		bsr.s	new_pal
		move.w	d2,2(a1)
		move.w	d3,4(a1)
		adda.w	#34,a1
medium_high:	lea.l	80(a1),a2
		movea.l	a2,a3
loop1:		move.w	(a0)+,(a1)+	; plan 1 line 0,2,4,6...
		move.w	(a0)+,(a2)+	; plan 2 line 1,3,5,7...
		cmpa.l	a1,a3		; end line ?
		bhi.s	loop1
		movea.l	a2,a1
		cmpa.l	a1,a4		; end pic ?
		bhi.s	medium_high
		bra.s	recopy_image

;.......................................palette high an medium..........
new_pal:	adda.w	#34,a0		; source point to image data
		andi.w	#$fff,d0
		andi.w	#$fff,d1
**		moveq.l	#0,d2		; already equal to zero	
		move.l	#$fff,d3
		cmp.w	d0,d1
		bmi.s	inverse
		rts
inverse:	exg.l	d2,d3
		rts

;----------------------------CONVERT IN MEDIUM RESOLUSION------------------
resol_1:	
high:		move.w	2(a0),d0
		move.w	4(a0),d1
		bsr.s	new_pal
		move.w	d2,2(a1)		; firs color
		move.w	d3,8(a1)		; last color
		move.l	#$aaa0aaa,4(a1)
		adda.w	#34,a1

;a0 line : 0 2 4 6 8...
;a4 line : 1 3 5 7 9...
high_medium:	lea.l	80(a0),a2		; point to end of a line
		movea.l	a2,a3
loop6:		move.w	(a0)+,(a1)+		;      plan 1
		move.w	(a3)+,d1		    
		eor.w	d1,(a1)+		;      plan 2
		cmpa.l  a0,a2			; end of a line ?
		bhi.s	loop6
		movea.l	a3,a0			; point to line 2,4,6,8...
		cmpa.l	a1,a4			; end buffer ?
		bhi.s	high_medium
;-------------------------------------------------------------------------
recopy_image:	movem.l	64(sp),a0-a1
on_source:	move.l	(a1)+,(a0)+
		cmpa.l	a1,a4
		bhi.s	on_source
		
end_prg:	movem.l (sp)+,d0-d7/a0-a6 
		rts 
		end
;*************************************************************************
