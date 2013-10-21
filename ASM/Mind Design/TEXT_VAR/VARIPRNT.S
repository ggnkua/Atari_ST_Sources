;
; Variable Size Text Writer 
;
; Original By Digi Tallis
;
; Modified & Optimised By The Viking 1998
;
; a0.l	Screen Adr
; a1.l	Text Adr (Null Ended)
; d0.l	X Start
; d1.l	Y Start
; d2.l	X Wrap
; d3.l	Y Wrap
; d4.l	Color (0-15)
;

print_text_varifont	
	movem.l	d0-d7/a0-a6,-(sp)	;shove em in..
	move.l	d4,ink_colour
	lsl.l	#3,d0	;*8
	lsl.l	#2,d1	;*4
	lsl.l	#3,d2	;*8
	lsl.l	#2,d3	;*4
	move.l	d0,vari_x_start
	move.l	d1,vari_y_start		;so we can do WINDOWS! ;)
	move.l	d2,vari_x_wrap
	move.l	d3,vari_y_wrap
	lea	varifont,a2
	lea	varifont_sizes,a3	
	lea	varifont_offsets,a4
	lea	mulu_160_table,a5
	lea	varifont_buffer,a6
.loop
	moveq.l	#0,d2			;clear it..
	move.b	(a1)+,d2		;the character
	cmp.b	#0,d2			;end of the text!!
	beq	.quit_printer
	cmp.b	#13,d2			;wrap counter
	beq	.wrap_line

	lsl.l	#2,d2			;*4 to get offset into tables..
	move.l	(a4,d2.l),d3		;offset into font bank..
	moveq.l	#0,d4			;clear it..
	lea	varifont_buffer,a6	;wheres that roll buffer?!
i	set	0
	rept	8
	move.w	i(a2,d3.l),(a6)+	;the font bit..
	move.w	d4,(a6)+		;extra 16 pix..
i	set	i+2
	endr				;copied letter into buffer..
	
	lea	vari_bounds,a6
	movem.l	(a6,d0.l),d3-d4		;x bound, pix num
	add.l	(a5,d1.l),d3		;down the screen too!

	cmp.l	#0,d4			;check if we need to roll it..
	blt.s	.no_need_roll
.roll_loop
	lea	varifont_buffer,a6
	rept	8
	roxr.w	(a6)+
	roxr.w	(a6)+			;rolled one line
	endr
	dbf	d4,.roll_loop
.no_need_roll
	lea	varifont_buffer,a6
	moveq.l	#7,d7
	move.l	ink_colour,d6
.let_loop
	move.w	(a6),d4			;first half of mask..
	swap	d4			;flip it
	move.w	(a6),d4			;bingo, one longword mask
	not.l	d4			;it is now..
	and.l	d4,(a0,d3.l)		;hole on 1-2. pix 0-15
	and.l	d4,4(a0,d3.l)		;hole on 3-4. pix 0-15

	move.w	(a6)+,d5		;the image..
	btst	#0,d6
	beq.s	.no_1_plane
	or.w	d5,(a0,d3.l)		;set the first plane..
.no_1_plane
	btst	#1,d6
	beq.s	.no_2_plane
	or.w	d5,2(a0,d3.l)		;set the second plane..
.no_2_plane
	btst	#2,d6
	beq.s	.no_3_plane
	or.w	d5,4(a0,d3.l)		;set the third plane..
.no_3_plane
	btst	#3,d6
	beq.s	.no_4_plane
	or.w	d5,6(a0,d3.l)		;set the fourth plane..
.no_4_plane
	move.w	(a6),d4			;first half of mask..
	swap	d4			;flip it
	move.w	(a6),d4			;bingo, one longword mask
	not.l	d4			;it is now..
	and.l	d4,8(a0,d3.l)		;hole on 1-2. pix 16-31
	and.l	d4,12(a0,d3.l)		;hole on 3-4. pix 16-31

	move.w	(a6)+,d5		;the image..
	btst	#0,d6
	beq.s	.no_1_plane2
	or.w	d5,8(a0,d3.l)		;set the first plane..
.no_1_plane2
	btst	#1,d6
	beq.s	.no_2_plane2
	or.w	d5,10(a0,d3.l)		;set the second plane..
.no_2_plane2
	btst	#2,d6
	beq.s	.no_3_plane2
	or.w	d5,12(a0,d3.l)		;set the third plane..
.no_3_plane2
	btst	#3,d6
	beq.s	.no_4_plane2
	or.w	d5,14(a0,d3.l)		;set the fourth plane..
.no_4_plane2
	add.l	#160,d3			;down the screen a line..
	dbf	d7,.let_loop

	add.l	(a3,d2.l),d0		;go across that screen
	cmp.l	vari_x_wrap,d0
	bge.s	.wrap_line		;wrap that sucker!!
	bra	.loop
.wrap_line
	move.l	vari_x_start,d0		;where we started..
	add.l	#8*4,d1	;down..			
	cmp.l	vari_y_wrap,d1
	bge.s	.quit_printer
	bra	.loop
.quit_printer
	movem.l	(sp)+,d0-d7/a0-a6	;get em back
	rts

get_varifont_text_length
	movem.l	d0-d7/a0-a6,-(sp)	;shove em in..
	moveq.l	#0,d0
	moveq.l	#0,d1
	lsl.l	#3,d2	;*8
	lsl.l	#2,d3	;*4
	move.l	d0,vari_x_start
	move.l	d1,vari_y_start		;so we can do WINDOWS! ;)
	move.l	d2,vari_x_wrap
	move.l	d3,vari_y_wrap
	
	lea	varifont,a2
	lea	varifont_sizes,a3	
.loop
	moveq.l	#0,d2			;clear it..
	move.b	(a1)+,d2		;the character
	cmp.b	#0,d2			;end of the text!!
	beq.s	.quit_printer
	cmp.b	#13,d2			;wrap counter
	beq.s	.wrap_line

	lsl.l	#2,d2			;*4 to get offset into tables..
	add.l	(a3,d2.l),d0		;go across that screen
	cmp.l	vari_x_wrap,d0
	bge.s	.wrap_line		;wrap that sucker!!
	bra.s	.loop
.wrap_line
	move.l	vari_x_start,d0		;where we started..
	add.l	#8*4,d1	;down..			
	cmp.l	vari_y_wrap,d1
	bge.s	.quit_printer
	bra.s	.loop
.quit_printer
	lsr.l	#3,d0			;divide it down by 8!
	move.l	d0,vari_text_len
	movem.l	(sp)+,d0-d7/a0-a6	;get em back
	rts
	even
vari_text_len	dc.l	0
varifont	incbin	e:\sources\fonts\varifont.fnt
varifont_sizes	incbin	e:\sources\fonts\varifont.siz
mulu_160_table
i       set     0
	rept    240
	dc.l    i
i       set     i+160
	endr
	even

varifont_offsets
i	set	0
	rept	255
	dc.l	i
i	set	i+16
	endr
vari_bounds
i	set	0
	rept	40
	dc.l	i,-1,i,0,i,1,i,2,i,3,i,4,i,5,i,6,i,7,i,8
	dc.l	i,9,i,10,i,11,i,12,i,13,i,14
i	set	i+8
	endr
	even
varifont_buffer	ds.l	64		;just enough to roll it.. ;)
ink_colour      dc.l    0       	;0-15.. ;)
vari_x_start	dc.l	0
vari_y_start	dc.l	0
vari_x_wrap	dc.l	0
vari_y_wrap	dc.l	0
*******************************
