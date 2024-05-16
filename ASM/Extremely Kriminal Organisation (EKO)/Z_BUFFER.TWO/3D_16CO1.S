	opt	d+

fill_color0
	move.l	#0,d0
	move.l	#0,d1
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	not.w	d7
	and.w	d7,(a6)+
	and.w	d7,(a6)+
	and.w	d7,(a6)+
	and.w	d7,(a6)+
	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	swap	d6
	not.w	d6
	and.w	d6,(a6)+
 	and.w	d6,(a6)+
 	and.w	d6,(a6)+
 	and.w	d6,(a6)+


	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	swap	d7
	not.w	d7
.adr_fill_poly
	and.w	d7,(a6)+
	and.w	d7,(a6)+
	and.w	d7,(a6)+
	and.w	d7,(a6)+
.bug
	lea	192(a1),a1		
	dbf	d2,.re_lign
	rts


fill_color1
	move.l	#$ffff0000,d0
	move.l	#0,d1
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	or.w	d7,(a6)+
	not.w	d7
	and.w	d7,(a6)+
	and.w	d7,(a6)+
	and.w	d7,(a6)+
	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	swap	d6
 	or.w	d6,(a6)+
	not.w	d6
 	and.w	d6,(a6)+
 	and.w	d6,(a6)+
 	and.w	d6,(a6)+


	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	swap	d7
	or.w	d7,(a6)+
.adr_fill_poly
	not.w	d7
	and.w	d7,(a6)+
	and.w	d7,(a6)+
	and.w	d7,(a6)+
.bug
	lea	192(a1),a1		
	dbf	d2,.re_lign
	rts

fill_color2
	move.l	#$ffff,d0
	move.l	#0,d1
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	move.w	d7,d6
	not.w	d6
	and.w	d6,(a6)+
	or.w	d7,(a6)+
	and.w	d6,(a6)+
	and.w	d6,(a6)+
	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	
	swap	d6
	move.w	d6,d3
	not.w	d3 
	and.w	d3,(a6)+
 	or.w	d6,(a6)+
 	and.w	d3,(a6)+
 	and.w	d3,(a6)+


	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	swap	d7
	move.w	d7,d3
.adr_fill_poly
	not.w	d3
	and.w	d3,(a6)+
	or.w	d7,(a6)+
	and.w	d3,(a6)+
	and.w	d3,(a6)+
.bug
	lea	192(a1),a1		
	dbf	d2,.re_lign
	rts


fill_color3
	move.l	#$ffffffff,d0
	move.l	#0,d1
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	or.w	d7,(a6)+
	or.w	d7,(a6)+
	not.w	d7
	and.w	d7,(a6)+
	and.w	d7,(a6)+
	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	
	swap	d6
	or.w	d6,(a6)+
 	or.w	d6,(a6)+
	not.w	d6 
 	and.w	d6,(a6)+
 	and.w	d6,(a6)+


	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	swap	d7
	or.w	d7,(a6)+
.adr_fill_poly
	or.w	d7,(a6)+
	not.w	d7
	and.w	d7,(a6)+
	and.w	d7,(a6)+
.bug
	lea	192(a1),a1		
	dbf	d2,.re_lign
	rts


fill_color4
	move.l	#$0,d0
	move.l	#$ffff0000,d1
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	move.w	d7,d6
	not.w	d6
	and.w	d6,(a6)+
	and.w	d6,(a6)+
	or.w	d7,(a6)+
	and.w	d6,(a6)+
	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	
	swap	d6
	move.w	d6,d3
	not.w	d3 
	and.w	d3,(a6)+
	and.w	d3,(a6)+
 	or.w	d6,(a6)+
 	and.w	d3,(a6)+


	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	swap	d7
	move.w	d7,d3
.adr_fill_poly
	not.w	d3
	and.w	d3,(a6)+
	and.w	d3,(a6)+
	or.w	d7,(a6)+
	and.w	d3,(a6)+
.bug
	lea	192(a1),a1		
	dbf	d2,.re_lign
	rts


fill_color5
	move.l	#$ffff0000,d0
	move.l	#$ffff0000,d1
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	move.w	d7,d6
	not.w	d6
	or.w	d7,(a6)+
	and.w	d6,(a6)+
	or.w	d7,(a6)+
	and.w	d6,(a6)+
	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	
	swap	d6
	move.w	d6,d3
	not.w	d3 
 	or.w	d6,(a6)+
	and.w	d3,(a6)+
 	or.w	d6,(a6)+
 	and.w	d3,(a6)+


	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	swap	d7
	move.w	d7,d3
.adr_fill_poly
	not.w	d3
	or.w	d7,(a6)+
	and.w	d3,(a6)+
	or.w	d7,(a6)+
	and.w	d3,(a6)+
.bug
	lea	192(a1),a1		
	dbf	d2,.re_lign
	rts

fill_color6
	move.l	#$ffff,d0
	move.l	#$ffff0000,d1
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	move.w	d7,d6
	not.w	d6
	and.w	d6,(a6)+
	or.w	d7,(a6)+
	or.w	d7,(a6)+
	and.w	d6,(a6)+
	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	
	swap	d6
	move.w	d6,d3
	not.w	d3 
	and.w	d3,(a6)+
 	or.w	d6,(a6)+
 	or.w	d6,(a6)+
 	and.w	d3,(a6)+


	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	swap	d7
	move.w	d7,d3
.adr_fill_poly
	not.w	d3
	and.w	d3,(a6)+
	or.w	d7,(a6)+
	or.w	d7,(a6)+
	and.w	d3,(a6)+
.bug
	lea	192(a1),a1		
	dbf	d2,.re_lign
	rts

fill_color7
	move.l	#$ffffffff,d0
	move.l	#$ffff0000,d1
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	or.w	d7,(a6)+
	or.w	d7,(a6)+
	or.w	d7,(a6)+
	not.w	d7
	and.w	d7,(a6)+
	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	swap	d6
 	or.w	d6,(a6)+
 	or.w	d6,(a6)+
 	or.w	d6,(a6)+
	not.w	d6
 	and.w	d6,(a6)+


	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	swap	d7
	or.w	d7,(a6)+
.adr_fill_poly
	or.w	d7,(a6)+
	or.w	d7,(a6)+
	not.w	d7
	and.w	d7,(a6)+
.bug
	lea	192(a1),a1		
	dbf	d2,.re_lign
	rts

fill_color8
	move.l	#$0,d0
	move.l	#$ffff,d1
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	move.w	d7,d6
	not.w	d6
	and.w	d6,(a6)+
	and.w	d6,(a6)+
	and.w	d6,(a6)+
	or.w	d7,(a6)+
	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	
	swap	d6
	move.w	d6,d3
	not.w	d3 
	and.w	d3,(a6)+
	and.w	d3,(a6)+
	and.w	d3,(a6)+
 	or.w	d6,(a6)+

	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	swap	d7
	move.w	d7,d3
.adr_fill_poly
	not.w	d3
	and.w	d3,(a6)+
	and.w	d3,(a6)+
	and.w	d3,(a6)+
	or.w	d7,(a6)+
.bug
	lea	192(a1),a1		
	dbf	d2,.re_lign
	rts

fill_color9
	move.l	#$ffff0000,d0
	move.l	#$ffff,d1
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	move.w	d7,d6
	not.w	d6
	or.w	d7,(a6)+
	and.w	d6,(a6)+
	and.w	d6,(a6)+
	or.w	d7,(a6)+
	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	
	swap	d6
	move.w	d6,d3
	not.w	d3 
 	or.w	d6,(a6)+
	and.w	d3,(a6)+
	and.w	d3,(a6)+
 	or.w	d6,(a6)+

	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	swap	d7
	move.w	d7,d3
.adr_fill_poly
	not.w	d3
	or.w	d7,(a6)+
	and.w	d3,(a6)+
	and.w	d3,(a6)+
	or.w	d7,(a6)+
.bug
	lea	192(a1),a1		
	dbf	d2,.re_lign
	rts

fill_color10
	move.l	#$ffff,d0
	move.l	#$ffff,d1
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	move.w	d7,d6
	not.w	d6
	and.w	d6,(a6)+
	or.w	d7,(a6)+
	and.w	d6,(a6)+
	or.w	d7,(a6)+
	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	
	swap	d6
	move.w	d6,d3
	not.w	d3 
	and.w	d3,(a6)+
 	or.w	d6,(a6)+
	and.w	d3,(a6)+
 	or.w	d6,(a6)+

	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	swap	d7
	move.w	d7,d3
.adr_fill_poly
	not.w	d3
	and.w	d3,(a6)+
	or.w	d7,(a6)+
	and.w	d3,(a6)+
	or.w	d7,(a6)+
.bug
	lea	192(a1),a1		
	dbf	d2,.re_lign
	rts

fill_color11
	move.l	#$ffffffff,d0
	move.l	#$ffff,d1
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	move.w	d7,d6
	not.w	d6
	or.w	d7,(a6)+
	or.w	d7,(a6)+
	and.w	d6,(a6)+
	or.w	d7,(a6)+
	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	
	swap	d6
	move.w	d6,d3
	not.w	d3 
 	or.w	d6,(a6)+
 	or.w	d6,(a6)+
	and.w	d3,(a6)+
 	or.w	d6,(a6)+

	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	swap	d7
	move.w	d7,d3
.adr_fill_poly
	not.w	d3
	or.w	d7,(a6)+
	or.w	d7,(a6)+
	and.w	d3,(a6)+
	or.w	d7,(a6)+
.bug
	lea	192(a1),a1		
	dbf	d2,.re_lign
	rts

fill_color12
	move.l	#$0,d0
	move.l	#$ffffffff,d1
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	move.w	d7,d6
	not.w	d6
	and.w	d6,(a6)+
	and.w	d6,(a6)+
	or.w	d7,(a6)+
	or.w	d7,(a6)+
	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	
	swap	d6
	move.w	d6,d3
	not.w	d3 
	and.w	d3,(a6)+
	and.w	d3,(a6)+
 	or.w	d6,(a6)+
 	or.w	d6,(a6)+

	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	swap	d7
	move.w	d7,d3
.adr_fill_poly
	not.w	d3
	and.w	d3,(a6)+
	and.w	d3,(a6)+
	or.w	d7,(a6)+
	or.w	d7,(a6)+
.bug
	lea	192(a1),a1		
	dbf	d2,.re_lign
	rts

fill_color13
	move.l	#$ffff0000,d0
	move.l	#$ffffffff,d1
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	move.w	d7,d6
	not.w	d6
	or.w	d7,(a6)+
	and.w	d6,(a6)+
	or.w	d7,(a6)+
	or.w	d7,(a6)+
	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	
	swap	d6
	move.w	d6,d3
	not.w	d3 
 	or.w	d6,(a6)+
	and.w	d3,(a6)+
 	or.w	d6,(a6)+
 	or.w	d6,(a6)+

	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	swap	d7
	move.w	d7,d3
.adr_fill_poly
	not.w	d3
	or.w	d7,(a6)+
	and.w	d3,(a6)+
	or.w	d7,(a6)+
	or.w	d7,(a6)+
.bug
	lea	192(a1),a1		
	dbf	d2,.re_lign
	rts


fill_color14
	move.l	#$ffff,d0
	move.l	#$ffffffff,d1
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	move.w	d7,d6
	not.w	d6
	and.w	d6,(a6)+
	or.w	d7,(a6)+
	or.w	d7,(a6)+
	or.w	d7,(a6)+
	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	
	swap	d6
	move.w	d6,d3
	not.w	d3 
	and.w	d3,(a6)+
 	or.w	d6,(a6)+
 	or.w	d6,(a6)+
 	or.w	d6,(a6)+

	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	swap	d7
	move.w	d7,d3
.adr_fill_poly
	not.w	d3
	and.w	d3,(a6)+
	or.w	d7,(a6)+
	or.w	d7,(a6)+
	or.w	d7,(a6)+
.bug
	lea	192(a1),a1		
	dbf	d2,.re_lign
	rts

fill_color15
	moveq.l	#-1,d0
	moveq.l	#-1,d1
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	or.w	d7,(a6)+
	or.w	d7,(a6)+
	or.w	d7,(a6)+
	or.w	d7,(a6)+
	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	swap	d6
 	or.w	d6,(a6)+
 	or.w	d6,(a6)+
 	or.w	d6,(a6)+
 	or.w	d6,(a6)+


	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	move.l	d0,(a6)+
	move.l	d1,(a6)+
	swap	d7
	or.w	d7,(a6)+
.adr_fill_poly
	or.w	d7,(a6)+
	or.w	d7,(a6)+
	or.w	d7,(a6)+
.bug
	lea	192(a1),a1		
	dbf	d2,.re_lign
	rts

********* remplissage 1 plan ************

fill_color16
	moveq.l	#-1,d0
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	or.w	d7,(a6)
.bug	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	swap	d6
 	or.w	d6,(a6)

	jmp	.adr_fill_poly(pc,d7.w)

	move.w	d0,176(a6)
	move.w	d0,168(a6)
	move.w	d0,160(a6)
	move.w	d0,152(a6)
	move.w	d0,144(a6)
	move.w	d0,136(a6)
	move.w	d0,128(a6)
	move.w	d0,120(a6)
	move.w	d0,112(a6)
	move.w	d0,104(a6)
	move.w	d0,96(a6)
	move.w	d0,88(a6)
	move.w	d0,80(a6)
	move.w	d0,72(a6)
	move.w	d0,64(a6)
	move.w	d0,56(a6)
	move.w	d0,48(a6)
	move.w	d0,40(a6)
	move.w	d0,32(a6)
	move.w	d0,24(a6)
	move.w	d0,16(a6)
	move.w	d0,8(a6)
	lea	192(a1),a1		
.adr_fill_poly
	neg.w	d7
	lea	(a6,d7.w*2),a6
	swap	d7
	or.w	d7,(a6)
	dbf	d2,.re_lign
	rts

fill_color17
	addq	#2,a1
	moveq.l	#-1,d0
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	or.w	d7,(a6)
.bug	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	swap	d6
 	or.w	d6,(a6)

	jmp	.adr_fill_poly(pc,d7.w)

	move.w	d0,176(a6)
	move.w	d0,168(a6)
	move.w	d0,160(a6)
	move.w	d0,152(a6)
	move.w	d0,144(a6)
	move.w	d0,136(a6)
	move.w	d0,128(a6)
	move.w	d0,120(a6)
	move.w	d0,112(a6)
	move.w	d0,104(a6)
	move.w	d0,96(a6)
	move.w	d0,88(a6)
	move.w	d0,80(a6)
	move.w	d0,72(a6)
	move.w	d0,64(a6)
	move.w	d0,56(a6)
	move.w	d0,48(a6)
	move.w	d0,40(a6)
	move.w	d0,32(a6)
	move.w	d0,24(a6)
	move.w	d0,16(a6)
	move.w	d0,8(a6)
	lea	192(a1),a1		
.adr_fill_poly
	neg.w	d7
	lea	(a6,d7.w*2),a6
	swap	d7
	or.w	d7,(a6)
	dbf	d2,.re_lign
	rts


fill_color18
	addq	#4,a1
	moveq.l	#-1,d0
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	or.w	d7,(a6)
.bug	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	swap	d6
 	or.w	d6,(a6)

	jmp	.adr_fill_poly(pc,d7.w)

	move.w	d0,176(a6)
	move.w	d0,168(a6)
	move.w	d0,160(a6)
	move.w	d0,152(a6)
	move.w	d0,144(a6)
	move.w	d0,136(a6)
	move.w	d0,128(a6)
	move.w	d0,120(a6)
	move.w	d0,112(a6)
	move.w	d0,104(a6)
	move.w	d0,96(a6)
	move.w	d0,88(a6)
	move.w	d0,80(a6)
	move.w	d0,72(a6)
	move.w	d0,64(a6)
	move.w	d0,56(a6)
	move.w	d0,48(a6)
	move.w	d0,40(a6)
	move.w	d0,32(a6)
	move.w	d0,24(a6)
	move.w	d0,16(a6)
	move.w	d0,8(a6)
	lea	192(a1),a1		
.adr_fill_poly
	neg.w	d7
	lea	(a6,d7.w*2),a6
	swap	d7
	or.w	d7,(a6)
	dbf	d2,.re_lign
	rts


fill_color19
	addq	#6,a1
	moveq.l	#-1,d0
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	or.w	d7,(a6)
.bug	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	swap	d6
 	or.w	d6,(a6)

	jmp	.adr_fill_poly(pc,d7.w)

	move.w	d0,176(a6)
	move.w	d0,168(a6)
	move.w	d0,160(a6)
	move.w	d0,152(a6)
	move.w	d0,144(a6)
	move.w	d0,136(a6)
	move.w	d0,128(a6)
	move.w	d0,120(a6)
	move.w	d0,112(a6)
	move.w	d0,104(a6)
	move.w	d0,96(a6)
	move.w	d0,88(a6)
	move.w	d0,80(a6)
	move.w	d0,72(a6)
	move.w	d0,64(a6)
	move.w	d0,56(a6)
	move.w	d0,48(a6)
	move.w	d0,40(a6)
	move.w	d0,32(a6)
	move.w	d0,24(a6)
	move.w	d0,16(a6)
	move.w	d0,8(a6)
	lea	192(a1),a1		
.adr_fill_poly
	neg.w	d7
	lea	(a6,d7.w*2),a6
	swap	d7
	or.w	d7,(a6)
	dbf	d2,.re_lign
	rts



********** remplissage 2 plans ***********

fill_color20
	move.l	#$ffff0000,d0
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	or.w	d7,(a6)
	not.w	d7
	and.w	d7,2(a6)
.bug	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	swap	d6
 	or.w	d6,(a6)
	not.w	d6
	and.w	d6,2(a6)

	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,176(a6)
	move.l	d0,168(a6)
	move.l	d0,160(a6)
	move.l	d0,152(a6)
	move.l	d0,144(a6)
	move.l	d0,136(a6)
	move.l	d0,128(a6)
	move.l	d0,120(a6)
	move.l	d0,112(a6)
	move.l	d0,104(a6)
	move.l	d0,96(a6)
	move.l	d0,88(a6)
	move.l	d0,80(a6)
	move.l	d0,72(a6)
	move.l	d0,64(a6)
	move.l	d0,56(a6)
	move.l	d0,48(a6)
	move.l	d0,40(a6)
	move.l	d0,32(a6)
	move.l	d0,24(a6)
	move.l	d0,16(a6)
	move.l	d0,8(a6)
	lea	192(a1),a1		
.adr_fill_poly
	neg.w	d7
	lea	(a6,d7.w*2),a6
	swap	d7
	or.w	d7,(a6)
	not.w	d7
	and.w	d7,2(a6)
	dbf	d2,.re_lign
	rts

fill_color21
	move.l	#$ffff,d0
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	or.w	d7,2(a6)
	not.w	d7
	and.w	d7,(a6)
.bug	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	swap	d6
 	or.w	d6,2(a6)
	not.w	d6
	and.w	d6,(a6)

	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,176(a6)
	move.l	d0,168(a6)
	move.l	d0,160(a6)
	move.l	d0,152(a6)
	move.l	d0,144(a6)
	move.l	d0,136(a6)
	move.l	d0,128(a6)
	move.l	d0,120(a6)
	move.l	d0,112(a6)
	move.l	d0,104(a6)
	move.l	d0,96(a6)
	move.l	d0,88(a6)
	move.l	d0,80(a6)
	move.l	d0,72(a6)
	move.l	d0,64(a6)
	move.l	d0,56(a6)
	move.l	d0,48(a6)
	move.l	d0,40(a6)
	move.l	d0,32(a6)
	move.l	d0,24(a6)
	move.l	d0,16(a6)
	move.l	d0,8(a6)
	lea	192(a1),a1		
.adr_fill_poly
	neg.w	d7
	lea	(a6,d7.w*2),a6
	swap	d7
	or.w	d7,2(a6)
	not.w	d7
	and.w	d7,(a6)
	dbf	d2,.re_lign
	rts

fill_color22
	moveq.l	#-1,d0
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	or.w	d7,(a6)
	or.w	d7,2(a6)
.bug	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	swap	d6
 	or.w	d6,(a6)
 	or.w	d6,2(a6)

	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,176(a6)
	move.l	d0,168(a6)
	move.l	d0,160(a6)
	move.l	d0,152(a6)
	move.l	d0,144(a6)
	move.l	d0,136(a6)
	move.l	d0,128(a6)
	move.l	d0,120(a6)
	move.l	d0,112(a6)
	move.l	d0,104(a6)
	move.l	d0,96(a6)
	move.l	d0,88(a6)
	move.l	d0,80(a6)
	move.l	d0,72(a6)
	move.l	d0,64(a6)
	move.l	d0,56(a6)
	move.l	d0,48(a6)
	move.l	d0,40(a6)
	move.l	d0,32(a6)
	move.l	d0,24(a6)
	move.l	d0,16(a6)
	move.l	d0,8(a6)
	lea	192(a1),a1		
.adr_fill_poly
	neg.w	d7
	lea	(a6,d7.w*2),a6
	swap	d7
	or.w	d7,(a6)
	or.w	d7,2(a6)
	dbf	d2,.re_lign
	rts

********** remplissage 2 plans  mais plans 3 et 4***********

fill_color23
	addq	#4,a1
	move.l	#$ffff0000,d0
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	or.w	d7,(a6)
	not.w	d7
	and.w	d7,2(a6)
.bug	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	swap	d6
 	or.w	d6,(a6)
	not.w	d6
	and.w	d6,2(a6)

	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,176(a6)
	move.l	d0,168(a6)
	move.l	d0,160(a6)
	move.l	d0,152(a6)
	move.l	d0,144(a6)
	move.l	d0,136(a6)
	move.l	d0,128(a6)
	move.l	d0,120(a6)
	move.l	d0,112(a6)
	move.l	d0,104(a6)
	move.l	d0,96(a6)
	move.l	d0,88(a6)
	move.l	d0,80(a6)
	move.l	d0,72(a6)
	move.l	d0,64(a6)
	move.l	d0,56(a6)
	move.l	d0,48(a6)
	move.l	d0,40(a6)
	move.l	d0,32(a6)
	move.l	d0,24(a6)
	move.l	d0,16(a6)
	move.l	d0,8(a6)
	lea	192(a1),a1		
.adr_fill_poly
	neg.w	d7
	lea	(a6,d7.w*2),a6
	swap	d7
	or.w	d7,(a6)
	not.w	d7
	and.w	d7,2(a6)
	dbf	d2,.re_lign
	rts

fill_color24
	addq	#4,a1	
	move.l	#$ffff,d0
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	or.w	d7,2(a6)
	not.w	d7
	and.w	d7,(a6)
.bug	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	swap	d6
 	or.w	d6,2(a6)
	not.w	d6
	and.w	d6,(a6)

	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,176(a6)
	move.l	d0,168(a6)
	move.l	d0,160(a6)
	move.l	d0,152(a6)
	move.l	d0,144(a6)
	move.l	d0,136(a6)
	move.l	d0,128(a6)
	move.l	d0,120(a6)
	move.l	d0,112(a6)
	move.l	d0,104(a6)
	move.l	d0,96(a6)
	move.l	d0,88(a6)
	move.l	d0,80(a6)
	move.l	d0,72(a6)
	move.l	d0,64(a6)
	move.l	d0,56(a6)
	move.l	d0,48(a6)
	move.l	d0,40(a6)
	move.l	d0,32(a6)
	move.l	d0,24(a6)
	move.l	d0,16(a6)
	move.l	d0,8(a6)
	lea	192(a1),a1		
.adr_fill_poly
	neg.w	d7
	lea	(a6,d7.w*2),a6
	swap	d7
	or.w	d7,2(a6)
	not.w	d7
	and.w	d7,(a6)
	dbf	d2,.re_lign
	rts

fill_color25
	addq	#4,a1	
	moveq.l	#-1,d0
	bra.s	.re_lign

.meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	or.w	d7,(a6)
	or.w	d7,2(a6)
.bug	lea	192(a1),a1
	dbf	d2,.re_lign
	rts

.re_lign
	move.w	(a0)+,d6
	move.w	(a3)+,d7

	move.l	(a4,d6.w*4),d6
	move.l	(a2,d7.w*4),d7

 	lea	(a1,d6.w*2),a6
	add.w	d6,d7                               

	beq.s	.meme_mot		
	bpl.s	.bug

	swap	d6
 	or.w	d6,(a6)
 	or.w	d6,2(a6)

	jmp	.adr_fill_poly(pc,d7.w)

	move.l	d0,176(a6)
	move.l	d0,168(a6)
	move.l	d0,160(a6)
	move.l	d0,152(a6)
	move.l	d0,144(a6)
	move.l	d0,136(a6)
	move.l	d0,128(a6)
	move.l	d0,120(a6)
	move.l	d0,112(a6)
	move.l	d0,104(a6)
	move.l	d0,96(a6)
	move.l	d0,88(a6)
	move.l	d0,80(a6)
	move.l	d0,72(a6)
	move.l	d0,64(a6)
	move.l	d0,56(a6)
	move.l	d0,48(a6)
	move.l	d0,40(a6)
	move.l	d0,32(a6)
	move.l	d0,24(a6)
	move.l	d0,16(a6)
	move.l	d0,8(a6)
	lea	192(a1),a1		
.adr_fill_poly
	neg.w	d7
	lea	(a6,d7.w*2),a6
	swap	d7
	or.w	d7,(a6)
	or.w	d7,2(a6)
	dbf	d2,.re_lign
	rts

