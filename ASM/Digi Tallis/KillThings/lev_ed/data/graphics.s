*******************************
** graphics.s - (C) 1994 Digi Tallis
**      everything 16 colour masked, fully optimised
**      used registers stacked on execution of routine
**      all code by ()rm of Digi Tallis
**      polygons/polylines MUST be defined as such (going clockwise)
**              point 1, point 2, point 4, point 3
**              topleft, toprght, botleft, botrght...
** 
** line_draw  
**      d0=x1, d1=y1, d2=x2, d3=y2, ink_colour  
** polygon
**      d0=x1, d1=y1 ,d2=x2, d3=y2, d4=x3, d5=y3, d6=x4, d7=y4, ink_colour
** polyline
**      d0=x1, d1=y1, d2=x2, d3=y2, d4=x3, d5=y3, d6=x4, d7=y4, ink_colour
** plot_point
**      d0=x1, d1=y1, ink_colour
**
**      if ink_colour not set, it takes last value
**      you will need to set 'graphic_workscreen' to the address of the
**              screen you are wanting to draw to. ie
**              move.l  #$70000,graphic_workscreen
********************************
	opt     o+,w-

draw_horizontal         macro
	move.l  d2,d1           ;temp store
	sub.l   d0,d1           ;how big is the line?!
	cmp.l   #32,d1          ;HAS to have a 16 fill!!
	bgt.s   .big_line
.small_line
	lsl.l   #3,d0           ;mult by 8..
	move.l  ink_colour,d2
	lsl.l   #2,d2
.loop_a
		movem.l (a4,d0.l),d3-d4         ;x offset and into bank.
		add.l   (a5,d2.l),d4            ;into bank
		movem.l (a3,d4.l),d5-d7         ;mask and image..
		and.l   d5,(a2,d3.l)
		and.l   d5,4(a2,d3.l)
		or.l    d6,(a2,d3.l)
		or.l    d7,4(a2,d3.l)
	addq.l  #8,d0
	dbf     d1,.loop_a
	bra     .quit_horiz
.big_line
	move.l  d0,temp_x1
	move.l  d2,temp_x2      ;draw between em!
	add.l   #16,d0  ;next one along..
	lsr.l   #4,d0
	lsl.l   #4,d0   ;boundries...
	lsr.l   #4,d2
	lsl.l   #4,d2   ;boundries
	move.l  d0,temp_x1_bound
	move.l  d2,temp_x2_bound
.left_big_line
	move.l  temp_x1_bound,d1
	sub.l   temp_x1,d1      ;how many?!
	subq.l  #1,d1   ;its right now!!
	move.l  temp_x1,d0      ;x pos..
	lsl.l   #3,d0           ;mult by 8..
	move.l  ink_colour,d2
	lsl.l   #2,d2
	movem.l (a4,d0.l),d3-d4         ;x offset and into bank.
	add.l   (a5,d2.l),d4            ;into bank
	moveq.l #0,d5
	move.l  d5,d6
	move.l  d6,d7
	not.l   d5      ;invert it!
.loop_b
		and.l   (a3,d4.l),d5    ;mask
		or.l    4(a3,d4.l),d6   ;im1
		or.l    8(a3,d4.l),d7   ;im2
	add.l   #12,d4  ;sneaky...
	dbf     d1,.loop_b
		and.l   d5,(a2,d3.l)
		and.l   d5,4(a2,d3.l)   ;holes
		or.l    d6,(a2,d3.l)
		or.l    d7,4(a2,d3.l)   ;put it down
.big_line_middle
	move.l  temp_x2_bound,d1
	sub.l   temp_x1_bound,d1        ;how many
	lsr.l   #4,d1   ;down from muts of 16..
	sub.l   #1,d1
	
	move.l  temp_x1_bound,d0
	lsl.l   #3,d0   ;mult by 8..
	move.l  (a4,d0.l),d0    ;x offset
	move.l  ink_colour,d2
	lsl.l   #3,d2   ;*8
	movem.l (a6,d2.l),d2-d3
.loop_d
		movem.l d2-d3,(a2,d0.l) ;fill with that ffff...
	add.l   #8,d0
	dbf     d1,.loop_d
.big_line_right
	move.l  temp_x2,d1
	sub.l   temp_x2_bound,d1        ;how many?!

	move.l  temp_x2_bound,d0        ;x pos..
	lsl.l   #3,d0           ;mult by 8..
	move.l  ink_colour,d2
	lsl.l   #2,d2
	movem.l (a4,d0.l),d3-d4         ;x offset and into bank.
	add.l   (a5,d2.l),d4            ;into bank
	moveq.l #0,d5
	move.l  d5,d6
	move.l  d6,d7
	not.l   d5      ;invert it!!!
.loop_c
		and.l   (a3,d4.l),d5    ;mask
		or.l    4(a3,d4.l),d6   ;im1
		or.l    8(a3,d4.l),d7   ;im2
	add.l   #12,d4
	dbf     d1,.loop_c
		and.l   d5,(a2,d3.l)
		and.l   d5,4(a2,d3.l)   ;holes!
		or.l    d6,(a2,d3.l)
		or.l    d7,4(a2,d3.l)   ;actually put it down..
.quit_horiz
	endm
draw_lines_into_buffer
	move.l  d2,a1   ;destination X
	move.l  d3,a2   ;destination Y

	sub.l   d0,d2                   ;dx = x2-x1
	sub.l   d1,d3                   ;dy = y2-y1

	moveq.l #0,d4                   ;c = 0
	moveq.l #0,d5                   ;m = 0
	moveq.l #0,d6                   ;d = 0
	
	move.l  #1,a3                   ;xinc = 1
	move.l  #1,a4                   ;yinc = 1

	cmp.l   #0,d2                   ;if dx < 0
	bgt.s   .d_b_next
	move.l  #-1,a3                  ;xinc = -1
	neg.l   d2                      ;dx = -dx
.d_b_next       
	cmp.l   #0,d3                   ;if dy < 0
	bgt.s   .d_b_next_2
	move.l  #-1,a4                  ;yinc = -1
	neg.l   d3                      ;dy = -dy
.d_b_next_2
	cmp.l   d3,d2                   ;if dy < dx
	bgt.s   .d_b_draw_2
.d_b_draw_1
	move.l  d3,d4
	add.l   d4,d4                   ;c = 2*dy

	move.l  d2,d5
	add.l   d5,d5                   ;m = 2*dx
.d_b_no_quit
	cmp.l   poly_clip_y1,d1 ;clip y
	blt.s   .d_b_not_on_screen
	cmp.l   poly_clip_y2,d1 
	bgt.s   .d_b_not_on_screen
	cmp.l   poly_clip_x1,d0
	bgt.s   .d_b_try_right
	move.l  poly_clip_x2,(a0)+
	move.l  d1,(a0)+
	add.l   #1,a5
	bra     .d_b_not_on_screen
.d_b_try_right
	cmp.l   poly_clip_x2,d0
	blt.s   .d_b_its_fine
	move.l  poly_clip_x2,(a0)+
	move.l  d1,(a0)+
	add.l   #1,a5
	bra     .d_b_not_on_screen
.d_b_its_fine
	move.l  d0,(a0)+
	move.l  d1,(a0)+
	add.l   #1,a5   ;num_points_in_polygon
.d_b_not_on_screen
	add.l   a4,d1                   ;y = y+yinc
	add.l   d5,d6                   ;d = d+m

	cmp.l   d6,d3                   ;if d > dy
	bgt.s   .d_b_nope
	add.l   a3,d0                   ;x = x+xinc
	sub.l   d4,d6                   ;d = d-c
.d_b_nope
	cmp.l   a2,d1                   ;if y <> y2
	bne.s   .d_b_no_quit
	rts
.d_b_draw_2
	move.l  d2,d4
	add.l   d4,d4                   ;c = 2*dx
	
	move.l  d3,d5
	add.l   d5,d5                   ;m = 2*dy
.d_b_no_quit_2  
	cmp.l   poly_clip_y1,d1 ;clip y
	blt.s   .d_b_not_on_screen2
	cmp.l   poly_clip_y2,d1 
	bgt.s   .d_b_not_on_screen2
	cmp.l   poly_clip_x1,d0
	bgt.s   .d_b_try_right2
	move.l  poly_clip_x1,(a0)+
	move.l  d1,(a0)+
	add.l   #1,a5
	bra     .d_b_not_on_screen2
.d_b_try_right2
	cmp.l   poly_clip_x2,d0
	blt.s   .d_b_its_fine2
	move.l  poly_clip_x2,(a0)+
	move.l  d1,(a0)+
	add.l   #1,a5
	bra     .d_b_not_on_screen2
.d_b_its_fine2
	move.l  d0,(a0)+
	move.l  d1,(a0)+
	add.l   #1,a5   ;num_points_in_polygon
.d_b_not_on_screen2
	add.l   a3,d0                   ;x = x+xinc
	add.l   d5,d6                   ;d = d+m

	cmp.l   d6,d2                   ;if d > dx
	bgt.s   .d_b_nope_2
	add.l   a4,d1                   ;y = y+yinc
	sub.l   d4,d6                   ;d = d-c
.d_b_nope_2             
	cmp.l   a1,d0                   ;if x <> x2
	bne.s   .d_b_no_quit_2
	rts

polygon
	movem.l d0-d7/a0-a6,-(sp)       ;stack them..
	lea     poly_x1,a0
	movem.l d0-d7,(a0)      ;gets them all.. ;)

	lea     poly_buffer,a0
	move.l  #0,a5   ;num points in polygon!

	move.l  poly_x1,d0
	move.l  poly_y1,d1
	move.l  poly_x2,d2
	move.l  poly_y2,d3
	jsr     draw_lines_into_buffer  ;x1,y1 > x2,y2

	move.l  poly_x2,d0
	move.l  poly_y2,d1
	move.l  poly_x4,d2
	move.l  poly_y4,d3
	jsr     draw_lines_into_buffer  ;x2,y2 > x4,y4

	move.l  poly_x4,d0
	move.l  poly_y4,d1
	move.l  poly_x3,d2
	move.l  poly_y3,d3
	jsr     draw_lines_into_buffer  ;x4,y4 > x3,y3

	move.l  poly_x3,d0
	move.l  poly_y3,d1
	move.l  poly_x1,d2
	move.l  poly_y1,d3
	jsr     draw_lines_into_buffer  ;x3,y3 > x1,y1

	lea     poly_200_line_flag,a0   ;clear buffer
	move.l  #0,d0
	rept    400
	move.l  d0,(a0)+
	endr

	move.l  a5,d0   ;num_points_in_polygon,d0
	subq.l  #1,d0   ;filling the 200 buffer...
	lea     poly_buffer,a0
	lea     poly_200_line,a1
	lea     poly_200_line_flag,a2
.loop
	movem.l (a0)+,d1-d2     ;x,y
	lsl.l   #3,d2   ;mult by 8      
.its_fine
	cmp.l   #1,(a2,d2.l)    ;check stat(1)
	beq.s   .check_left
	move.l  d1,(a1,d2.l)    ;put in the value
	move.l  #1,(a2,d2.l)    ;set stat(1)
	bra     .the_right_checks
.check_left
	cmp.l   (a1,d2.l),d1    ;d1 < current?
	bgt.s   .the_right_checks       ;nope.. do the right checks..
	move.l  d1,(a1,d2.l)    ;put d1 into current..
	move.l  #1,(a2,d2.l)    ;set stat(1)
.the_right_checks
	cmp.l   #1,4(a2,d2.l)   ;check stat(2)
	beq.s   .check_right
	move.l  d1,4(a1,d2.l)   ;put value in..
	move.l  #1,4(a2,d2.l)   ;set stat(2)
.check_right
	cmp.l   4(a1,d2.l),d1   ;d1 > current
	blt.s   .done
	move.l  d1,4(a1,d2.l)   ;d1 into current..
	move.l  #1,4(a2,d2.l)   ;set stat(2)
.done
	dbf     d0,.loop

	lea     poly_200_line_flag,a1
	moveq.l #0,d1
	move.l  d1,d2
	move.l  #199,d0
.find_low_loop
	cmp.l   #0,(a1,d1.l)
	beq     .low_unused
	move.l  d1,poly_lowstart
	move.l  d2,poly_low160
	bra     .low_getout
.low_unused
	add.l   #160,d2
	addq.l  #8,d1
	dbf     d0,.find_low_loop
.low_getout                     ;got the lowest one!
	move.l  #199*8,d1
	move.l  #199,d0
.find_high_loop
	cmp.l   #0,(a1,d1.l)
	beq     .high_unused
	move.l  d1,poly_highend
	bra     .high_getout
.high_unused
	subq.l  #8,d1
	dbf     d0,.find_high_loop
.high_getout                    ;got highest..
	
	lea     poly_200_line,a0
	move.l  graphic_workscreen,a2                   ;screen
	lea     point_16_data,a3        
	lea     point_16_offsets,a4
	lea     point_16_col_mulu,a5
	lea     poly_fill_quick,a6

	add.l   poly_low160,a2          ;into the screen
	move.l  poly_highend,d1         ;where do we end polygon?
	sub.l   poly_lowstart,d1        ;how many lines.
	lsr.l   #3,d1   ;div by 8...
	add.l   poly_lowstart,a0        ;into the bank
	add.l   poly_lowstart,a1        ;and again..
.fill_loop
	move.l  (a0)+,d0        ;xcoord one
	move.l  (a0)+,d2        ;xcoord two
	movem.l d1,-(sp)        ;stack
	draw_horizontal         ;hohoh..
	movem.l (sp)+,d1        ;getback
	lea     160(a2),a2      ;down the screen
	dbf     d1,.fill_loop

	movem.l (sp)+,d0-d7/a0-a6       ;get them back
	rts


polyline
	movem.l d0-d7/a0,-(sp)  ;stack them
	lea     poly_x1,a0
	movem.l d0-d7,(a0)      ;gets them all.. ;)

	move.l  poly_x1,d0
	move.l  poly_y1,d1
	move.l  poly_x2,d2
	move.l  poly_y2,d3
	jsr     line_draw       ;x1,y1 > x2,y2

	move.l  poly_x2,d0
	move.l  poly_y2,d1
	move.l  poly_x4,d2
	move.l  poly_y4,d3
	jsr     line_draw       ;x2,y2 > x4,y4

	move.l  poly_x4,d0
	move.l  poly_y4,d1
	move.l  poly_x3,d2
	move.l  poly_y3,d3
	jsr     line_draw       ;x4,y4 > x3,y3

	move.l  poly_x3,d0
	move.l  poly_y3,d1
	move.l  poly_x1,d2
	move.l  poly_y1,d3
	jsr     line_draw       ;x3,y3 > x1,y1

	movem.l (sp)+,d0-d7/a0  ;get them back
	rts

line_draw       
	movem.l a0-a4/d0-d7,-(sp)       ;stack them!
	move.l  graphic_workscreen,a0                   ;screen
	lea     point_16_data,a1        
	lea     point_16_offsets,a2
	lea     point_16_col_mulu,a3
	lea     mulu_p160_table,a4      ;*160..

	lsl.l   #3,d0   ;to get faster access to tables!
	lsl.l   #3,d1   ;we mulu all the inputted values by eight!
	lsl.l   #3,d2   ;sneaky..
	lsl.l   #3,d3
	move.l  d0,line_draw_X1         ;x
	move.l  d1,line_draw_Y1         ;y
	move.l  d2,line_draw_X2
	move.l  d3,line_draw_Y2

	sub.l   d0,d2                   ;dx = x2-x1
	sub.l   d1,d3                   ;dy = y2-y1

	moveq.l #0,d4                   ;c = 0
	moveq.l #0,d5                   ;m = 0
	moveq.l #0,d6                   ;d = 0
	
	move.l  #8,a5                   ;xinc = 8
	move.l  #8,a6                   ;yinc = 8...speedy now!

	cmp.l   #0,d2                   ;if dx < 0
	bgt.s   .next
	move.l  #-8,a5                  ;xinc = -8
	neg.l   d2                      ;dx = -dx
.next   
	cmp.l   #0,d3                   ;if dy < 0
	bgt.s   .next_2
	move.l  #-8,a6                  ;yinc = -8
	neg.l   d3                      ;dy = -dy
.next_2
	cmp.l   d3,d2                   ;if dy < dx
	bgt     .draw_2
.draw_1
	move.l  d3,d4
	add.l   d4,d4                   ;c = 2*dy

	move.l  d2,d5
	add.l   d5,d5                   ;m = 2*dx

.no_quit
	cmp.l   line_clip_x1,d0
	blt.s   .no_draw
	cmp.l   line_clip_x2,d0
	bgt.s   .no_draw
	cmp.l   line_clip_y1,d1
	blt.s   .no_draw
	cmp.l   line_clip_y2,d1
	bgt.s   .no_draw

	movem.l d0-d7,-(sp)     ;stack everything.
	move.l  ink_colour,d2   ;d2 free now!
	lsl.l   #2,d2           
	movem.l (a2,d0.l),d3-d4         ;x offset and into bank.
	add.l   (a4,d1.l),d3            ;into screen..
	add.l   (a3,d2.l),d4            ;into bank

	movem.l (a0,d3.l),d0-d1         ;the screen data..
	movem.l (a1,d4.l),d5-d7         ;mask and image..
	and.l   d5,d0                   ;
	and.l   d5,d1                   ;create holes
	or.l    d6,d0                   ;
	or.l    d7,d1                   ;drop image in
	movem.l d0-d1,(a0,d3.l)         ;put it all back on the screen

	movem.l (sp)+,d0-d7     ;get em back..
.no_draw        
	add.l   a6,d1                   ;y = y+yinc
	add.l   d5,d6                   ;d = d+m

	cmp.l   d6,d3                   ;if d > dy
	bgt.s   .nope
	add.l   a5,d0                   ;x = x+xinc     
	sub.l   d4,d6                   ;d = d-c
.nope
	cmp.l   line_draw_Y2,d1         ;if y <> y2
	bne     .no_quit
	bra     .quit_drawing
.draw_2
	move.l  d2,d4
	add.l   d4,d4                   ;c = 2*dx
	
	move.l  d3,d5
	add.l   d5,d5                   ;m = 2*dy
.no_quit_2      
	cmp.l   line_clip_x1,d0
	blt.s   .no_draw2
	cmp.l   line_clip_x2,d0
	bgt.s   .no_draw2
	cmp.l   line_clip_y1,d1
	blt.s   .no_draw2
	cmp.l   line_clip_y2,d1
	bgt.s   .no_draw2

	movem.l d0-d7,-(sp)     ;stack everything...
	move.l  ink_colour,d2   ;d2 free now!
	lsl.l   #2,d2           
	movem.l (a2,d0.l),d3-d4         ;x offset and into bank.
	add.l   (a4,d1.l),d3            ;into screen..
	add.l   (a3,d2.l),d4            ;into bank

	movem.l (a0,d3.l),d0-d1         ;the screen data..
	movem.l (a1,d4.l),d5-d7         ;mask and image..
	and.l   d5,d0                   ;
	and.l   d5,d1                   ;create holes
	or.l    d6,d0                   ;
	or.l    d7,d1                   ;drop image in
	movem.l d0-d1,(a0,d3.l)         ;put it all back on the screen

	movem.l (sp)+,d0-d7
.no_draw2
	add.l   a5,d0                   ;x = x+xinc
	add.l   d5,d6                   ;d = d+m

	cmp.l   d6,d2                   ;if d > dx
	bgt.s   .nope_2
	add.l   a6,d1                   ;y = y+yinc
	sub.l   d4,d6                   ;d = d-c
.nope_2         
	cmp.l   line_draw_X2,d0         ;if x <> x2
	bne     .no_quit_2
.quit_drawing
	movem.l (sp)+,a0-a4/d0-d7       ;get them back!
	rts

plot_16_colour_point
;       cmp.l   poly_clip_x1,d0
;       blt.s   .quit
;       cmp.l   poly_clip_x2,d0
;       bgt.s   .quit
;       cmp.l   poly_clip_y1,d1
;       blt.s   .quit
;       cmp.l   poly_clip_y2,d1
;       bgt.s   .quit
	
	movem.l d0-d7/a0-a4,-(sp)       ;stack the regs we use
	move.l  graphic_workscreen,a0                   ;screen
	lea     point_16_data,a1        
	lea     point_16_offsets,a2
	lea     point_16_col_mulu,a3
	lea     poly_mulu_160_table,a4  ;*160..

	lsl.l   #3,d0                   ;*8     
	lsl.l   #2,d1                   ;*4
	move.l  ink_colour,d2
	lsl.l   #2,d2                   ;*4

	movem.l (a2,d0.l),d3-d4         ;x offset and into bank.
	add.l   (a4,d1.l),d3            ;into screen..
	add.l   (a3,d2.l),d4            ;into bank

	movem.l (a0,d3.l),d0-d1         ;the screen data..
	movem.l (a1,d4.l),d5-d7         ;mask and image..
	and.l   d5,d0                   ;
	and.l   d5,d1                   ;create holes
	or.l    d6,d0                   ;
	or.l    d7,d1                   ;drop image in
	movem.l d0-d1,(a0,d3.l)         ;put it all back on the screen

	movem.l (sp)+,d0-d7/a0-a4       ;get the regs back
.quit
	rts

point_16_data
	incbin  d:\16colour.pnt
	even
point_16_offsets
i       set     0
	rept    21
	dc.l    i,00,i,12,i,24,i,36,i,48,i,60,i,72,i,84
	dc.l    i,96,i,108,i,120,i,132,i,144,i,156,i,168,i,180
i       set     i+8
	endr
	even
point_16_col_mulu
	dc.l    0,192,384,576,768,960,1152,1344,1536
	dc.l    2112,2304,2496,2688,2880
mulu_p160_table
i       set     0
	rept    200
	dc.l    i,0
i       set     i+160
	endr
	even
poly_fill_quick 
	dc.w    $0000,$0000,$0000,$0000
	dc.w    $ffff,$0000,$0000,$0000
	dc.w    $0000,$ffff,$0000,$0000
	dc.w    $ffff,$ffff,$0000,$0000
	dc.w    $0000,$0000,$ffff,$0000
	dc.w    $ffff,$0000,$ffff,$0000
	dc.w    $0000,$ffff,$ffff,$0000
	dc.w    $ffff,$ffff,$ffff,$0000
	dc.w    $0000,$0000,$0000,$ffff
	dc.w    $ffff,$0000,$0000,$ffff
	dc.w    $0000,$ffff,$0000,$ffff
	dc.w    $ffff,$ffff,$0000,$ffff
	dc.w    $0000,$0000,$ffff,$ffff
	dc.w    $ffff,$0000,$ffff,$ffff
	dc.w    $0000,$ffff,$ffff,$ffff
	dc.w    $ffff,$ffff,$ffff,$ffff
	even
graphic_workscreen      dc.l    0       ;where to draw dude!
temp_x1         dc.l    0
temp_x2         dc.l    0
temp_x1_bound   dc.l    0
temp_x2_bound   dc.l    0
ink_colour      dc.l    0       ;0-15.. ;)
line_draw_X1    dc.l    0
line_draw_Y1    dc.l    0
line_draw_X2    dc.l    0
line_draw_Y2    dc.l    0
line_draw_xinc  dc.l    0
line_draw_yinc  dc.l    0
line_clip_x1    dc.l    0*8
line_clip_y1    dc.l    0*8
line_clip_x2    dc.l    319*8
line_clip_y2    dc.l    199*8
poly_x1                 dc.l    0
poly_y1                 dc.l    0
poly_x2                 dc.l    0
poly_y2                 dc.l    0
poly_x3                 dc.l    0
poly_y3                 dc.l    0
poly_x4                 dc.l    0
poly_y4                 dc.l    0
poly_clip_x1            dc.l    0
poly_clip_y1            dc.l    0
poly_clip_x2            dc.l    319
poly_clip_y2            dc.l    199
poly_lowstart           dc.l    0
poly_low160             dc.l    0
poly_highend            dc.l    0
poly_200_line           ds.l    400     ;2*200 ;)
poly_200_line_flag      ds.l    400     ;2*200 ;)
poly_buffer             ds.l    (320*2)*4       ;x,y mult by num lines per poly
			even
poly_mulu_160_table
i       set     0
	rept    200
	dc.l    i
i       set     i+160
	endr
	even
point_offset_table
i       set     0
	rept    40
	dc.l    i,i,i,i,i,i,i,i,i,i,i,i,i,i,i,i
i       set     i+8
	endr
	even
point_plot_data
	rept    40
	dc.w    32768,0
	dc.w    16384,0
	dc.w    8192,0
	dc.w    4096,0
	dc.w    2048,0
	dc.w    1024,0
	dc.w    512,0
	dc.w    256,0
	dc.w    128,0
	dc.w    64,0
	dc.w    32,0
	dc.w    16,0
	dc.w    8,0
	dc.w    4,0
	dc.w    2,0
	dc.w    1,0
	endr
	even

	opt     o+,w+
**************************
