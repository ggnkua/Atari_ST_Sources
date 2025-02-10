;rockyone			Pour MI-3 & MI-9		06/12/2017
;
;correction palette						19/02/2018
;Modif low to high						22.04.2019
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
		bne	m_h

;......................................low to high........................
b_h:		move.w	2(a0),d0
		move.w	32(a0),d1
		move.w	34(a0),d2
		andi.w	#$777,d0
		andi.w	#$777,d1
		andi.w	#$777,d2
		adda.w	#34,a0
		
		cmp.w	d0,d2
		beq.s	w_b	; =
		cmp.w	d1,d2
		beq.s	w_b

		tst.w	d0
		bne.s	w_b	; <>
		cmp.w	d0,d2
		ble.s	w_b	; >=

		move.l	#$00000fff,2(a1)
		bra.s	suit
w_b:		move.l	#$fff0000,2(a1)
		
*		bsr	new_pal
*		move.w	d2,2(a1)
*		move.w	d3,4(a1)
suit:		adda.w	#34,a1

all_line:	lea.l	80(a1),a2
		movea.l	a2,a3		; end of a line

read_words:	movem.w	(a0)+,d0-d3
		andi.l	#$ffff,d0	
		andi.l	#$ffff,d1
		andi.l	#$ffff,d2
		andi.l	#$ffff,d3
		move.l	#$8000,d4	; bit mask for conversion

bytes:		moveq.l	#0,d5		; regiters for conversion
		moveq.l	#0,d6		; "	"      "      "
		moveq.l	#15,d7

w0:		cmp.l	d0,d4
		bgt.s	w2		; <
		bset.b	d7,d5		; bit 15,13,11...1
		sub.w	d4,d0				

w2:		cmp.l	d2,d4
		bgt.s	w1
		bset.b	d7,d6
		sub.w	d4,d2

w1:		subq.b	#1,d7

		cmp.l	d1,d4
		bgt.s	w3
		bset.b	d7,d5		; bit 14,12,10...0
		sub.w	d4,d1

w3:		cmp.l	d3,d4
		bgt.s	next_bits
		bset.b	d7,d6
		sub.w	d4,d3

next_bits	lsr.w	#1,d4		; $4000...$80 Next $40...$0
		subq.b	#1,d7		; 13,11,......-1
		bhi.s	w0

		move.w	d5,(a1)+
		move.w	d6,(a2)+
	
		tst.w	d4		; loop once ? D4=$80
		bhi.s	bytes	

		cmpa.l	a1,a3		; end of the line .
		bhi.s	read_words

		movea.l	a2,a1
		cmpa.l	a1,a4		; end of the pic ?
		bhi.s	all_line
		bra.s	recopy_image

;......................................medium to high.....................
m_h		move.w	4(a0),d1
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
new_pal:	move.w 2(a0),d0
		andi.w	#$fff,d0
		andi.w	#$fff,d1
*		moveq.l	#0,d2		; already equal to zero	
		move.l	#$fff,d3
		adda.w	#34,a0		; source point to image data
		cmp.w	d0,d1
		bmi.s	inverse
		rts
inverse:	exg.l	d2,d3
		rts

;----------------------------CONVERT IN MEDIUM RESOLUSION------------------
resol_1:	
high:		move.w	4(a0),d1
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
