; ROCKY.ONE			pour MI-3 et MI-9		19.06.2016
; 
;				FADING 
;				------
;
; Fade		buffer 512 bytes (at fist, the image's palette)
;
; Calc% 	1 calculate and display palettes
;		0 dislay only the palettes
;
; black_white%	0 calculate black fading 
;		1 calculate white fading
;
; direction%	0 fading direction ( palette  0 to  15 )
;		1 		   ( palette 15 to   0 )
; 
;Speed%         Number of repeat Vsync betwenn each palette display
;		0 is fast  3 is slow
;
;  	Call  fading(L Fade, calc%, blak_white%, direction%, speed%)
;	------------------------------------------------------------
;	
;------------------------------------------------------------------------	
;a4 buffer
;d0 calculate
;d1 black_white  
;d2 direction
;.......


	movem.l	d0-d7/a0-a6,-(a7)	 
	movea.l	64(sp),a4
	movem.w	68(sp),d0-d2

	tst.b	d0			; calculate palette ?
	beq	pal_direction		; no

	lea.l	fad_table(pc),a5
					
	lsl	#4,d1			; calculate back or white
	adda.l	d1,a5			;            0        16
	moveq.l	#15,d3			; 16 colors

;...................................calcul new palette for fading......
	moveq.l	#0,d5
	moveq.l	#0,d6
	moveq.l	#0,d7
read_color:
	movea.l	a4,a6
	move.w	(a4)+,d5	; read RVB

	move.b	d5,d7
	andi.b	#$f,d7		; B
	lsr.w	#4,d5
	move.b	d5,d6
	andi.b	#$f,d6		; V
	lsr.w	#4,d5
	andi.b	#$f,d5		; R

	moveq.l	#14,d4		; 15  new palette

new_color:
	move.b	0(a5,d5.w),d5	
	move.b	0(a5,d6.w),d6
	move.b	0(a5,d7.w),d7

	moveq.l	#0,d0
	move.b	d5,d0		; +R
	lsl.b	#4,d0		;  
	add.b	d6,d0		; +V
	lsl.w	#4,d0
	add.b	d7,d0		; +B

write_color:
	lea.l	32(a6),a6	; adr of the next palette
	move.w	d0,(a6)		; write new RVB

	dbra	d4,new_color
	dbra	d3,read_color
;
;........................................Palette direction............
;
pal_direction:
	movea.l	64(sp),a4		; Early buffer 16 palettes
	moveq.l	#14,d6			; 16 palettes		
	moveq.l	#4,d5			; Jump 2 words
	movea.l	#$ff8240,a5		; Adr. palette system
	lea.l	32(a4),a4		; Adr.of the second palette 
;					  because the first is dispayed
	tst.b	d2		  	; Direction  ?
	beq.s	display_palette		; palette 1 to 15 

;					; Dernier L_Word  de l'avant 
;					; derniere palette  $ff8240+476
	lea.l	508-64(a4),a4		; Adr. before last palette because
;					  the last palette is displayed
	lea.l	28(a5),a5		; adr the last two colors
	neg.l	d5			; jump -2 words

;........................................display palette..........
display_palette:
	moveq.l	#7,d7			; 16 color
	movea.l	a5,a6
	move.w	74(sp),d4		; number of repeat Vsynv

vsync:
	move.w	#37,-(sp)		; Vsync 
	trap	#14
	addq.l	#2,sp
	dbra.w	d4,vsync
	
copy_color:
	move.l	(a4),(a6)
	adda.l	d5,a4
	adda.l	d5,a6
	dbra.w	d7,copy_color

	dbra	d6,display_palette
;........................................

end_prg:
	movem.l	(a7)+,d0-d7/a0-a6
	rts

	even
fad_table:	
	dc.b	$0,$8,$9,$A,$B,$C,$D,$E,$0,$1,$2,$3,$4,$5,$6,$7	
	dc.b	$8,$9,$A,$B,$C,$D,$E,$f,$1,$2,$3,$4,$5,$6,$7,$f 	
	even
	end
;-------------------------------------------------------------------------