; ***********************************
; **		   **
; **  Polygone routine by Dracula  **
; **        made on june 93	   **
; **   commercial use prohibited   **
; **		   **
; ***********************************
; Parameters:
;     d0.l = number of brows.
;     a0.l = ramvideo adress.
;     a1.l = brows coords adress. 
; Uses no register, uses no customchips!...
;   ( Who needs a blitter anyway?... )

;************
 Section TEXT
 
  movem.l	d1-d7/a2-a6,-(sp)
 
;***************
.search_extremes:	; At first we search the extremals brows.
  moveq.l	#$0,d1	; d1 is the point counter.
  move.l	a1,a2	; We use a2 to go in the table.
  addq.l	#$2,a2	; Only intersted in the y coord.
  move.w	(a2),d2	; d2 is the ymin coord.
  move.w	d2,d3	; d3 is the ymax coord.
  move.l	d1,d4	; d4 is the number of the min brow.
.search:
  addq.l	#$1,d1	; Go to the next brow.
  cmp.l	d0,d1	; All the brows were seen?
  beq.s	.min_max_ok	
  addq.l	#$4,a2	; No, so we look the next brow.
  move.w	(a2),d5	; d5 is the current brow's y coord.
  cmp.w	d2,d5	; Current y < ymin?
  bge.s	.not_ymin
.new_ymin:
  move.w	d5,d2	; Yes! So it' s the new min.
  move.l	d1,d4	; Position in the table.
  bra.s	.search

.not_ymin:
  cmp.w	d3,d5	; Current y > ymax?
  ble.s	.search
.new_ymax:
  move.w	d5,d3	; Yes, so it' s the new max.
  bra.s	.search

.min_max_ok:
  move.w	d2,.firstline	; firstline contains y min.
  move.w	d3,d6
  sub.w	d2,d6
  move.w	d6,.hlines_nb	; hlines_nb contains y max-y min.
 
;************** 
.lines_min_calc:	; Now create the lines_mins_table.
  move.l	#.lines_min,a3
  moveq.l	#$0,d6	; d6 is the nb of lines_min.
  move.l	a1,a2
  move.l	d4,d2	; d4 is the position of min brow.
  add.l	d2,d2	; We multiply it by 4, cos
  add.l	d2,d2	; there are 4 bytes per brow.
  add.l	d2,a2	; a2 points on the min brow's coords.
  move.l	d4,d2	; d2 is the current brow position.
  move.w	(a2)+,(a3)+	; Copy the first coords.
  move.w	(a2)+,(a3)+
.next_line_min:
  addq.l	#$1,d6	; One more line, one more line...
  addq.l	#$1,d2	; Go to the next point.
  cmp.l	d0,d2	; Are we out of the table?
  bne.s	.line_min_in
.line_min_out:
  move.l	a1,a2	; Yes, then we shall jump to the
  moveq.l	#$0,d2	; beginning of the table.
.line_min_in:
  move.w	(a2)+,(a3)+	; Copy the coords.
  move.w	(a2)+,d1
  move.w	d1,(a3)+
  cmp.w	d1,d3	; Is this brow have the same y 
  bne.s	.next_line_min	; as the max brow? 
  move.l	d6,.lines_min_nb

;************** 
.lines_max_calc:	; Now create the lines_maxs_table.
  move.l	#.lines_max,a3
  moveq.l	#$0,d6	; d6 is the nb of lines_min.
  move.l	a1,a2
  move.l	d4,d2	; d4 is the position of min brow.
  add.l	d2,d2	; We multiply it by 4, cos
  add.l	d2,d2	; there are 4 bytes per brow.
  add.l	d2,a2	; a2 points on the min brow's coords.
  move.l	d0,d5
  add.l	d0,d0	; Multiplication by 4.
  add.l	d0,d0
  add.l	d0,a1	; a1 points on the last brow's coords.
  move.l	d4,d2	; d2 is the current brow position.
  move.w	(a2)+,(a3)+	; Copy the first coords.
  move.w	(a2)+,(a3)+
.next_line_max:
  addq.l	#$1,d6	; One more line, one more line...
  subq.l	#$1,d2	; Go to the next point.
  bge.s	.line_max_in	; Out of the table?
.line_max_out:
  move.l	a1,a2	; Yes, then we shall jump to the
  move.l	d5,d2	; end of the table.
  addq.l	#$4,a2	; Because of the subq.l #$8,a2.
.line_max_in:
  subq.l	#$8,a2	; Go to the previous brow's coords.
  move.w	(a2)+,(a3)+	; Copy the coords.
  move.w	(a2)+,d1
  move.w	d1,(a3)+
  cmp.w	d1,d3	; Is this brow have the same y 
  bne.s	.next_line_max	; as the max brow? 
  move.l	d6,.lines_max_nb

;**********
.xmins_calc:		; Now creating the xmins table.
  move.l	#.xmins,a1
  move.l	#.lines_min,a2
  move.l	a2,a3
  addq.l	#$4,a3
  move.l	.lines_min_nb,d7
.xmin_one_line:
  move.w	(a2)+,d0	; d0=x1.
  move.w	(a2)+,d1	; d1=y1.
  move.w	(a3)+,d2	; d2=x2.
  move.w	(a3)+,d3	; d3=y2.
  sub.w	d1,d3	; d3=y2-y1=dx, always positive.
  beq.s	.xmin_hline
  moveq.l	#$2,d1	; d1=sx*2.
  sub.w	d0,d2	; d2=x2-x1.
  beq.s	.xmin_vline
  bpl.s	.xmin_dxpos
.xmin_dxneg:		; d2 is negative.
  neg.l	d1	; Then sx=-1, d1=sx*2.
  neg.w	d2	; d2=dx=abs(x2-x1).
.xmin_dxpos:
  add.w	d0,d0	; Multiplication by 2.
  move.w	d3,d5	; Number of xmins for this line.
  cmp.w	d3,d2	; Big or low slope?
  bmi.s	.xmin_big_slope

.xmin_low_slope:
  add.w	d3,d3	; d3=2*dy.
  move.w	d3,d4
  sub.w	d2,d4	; Error=2dy-dx.
  add.w	d2,d2	; d2=2*dx.
  sub.w	d3,d2	; d2=2dx-2dy.
  move.w	d0,(a1)+	; Save the xmin.  
  tst.w	d4	; Error is positive?
  bpl.s	.xmin_low_epos
.xmin_low_eneg:
  add.w	d1,d0	; x=x+sx.
  add.w	d3,d4	; Error=Error+2dy.
  ble.s	.xmin_low_eneg
.xmin_low_epos:
  add.w	d1,d0	; x=x+sx.
  move.w	d0,(a1)+	; Save the xmin.  
  subq.w	#$1,d5	; One y less.
  beq.s	.xmin_next_line
  sub.w	d2,d4	; Error=Error-2dx+2dy.
  ble.s	.xmin_low_eneg
  bra.s	.xmin_low_epos

.xmin_big_slope:
  add.w	d2,d2	; d2=2*dx.
  move.w	d2,d4
  sub.w	d3,d4	; Error=2dx-dy.
  add.w	d3,d3	; d3=2*dy.
  sub.w	d2,d3	; d3=2dy-2dx.
  move.w	d0,(a1)+	; Save the xmin.  
  tst.w	d4	; Error is positive?
  bpl.s	.xmin_big_epos
.xmin_big_eneg:
  move.w	d0,(a1)+	; Save the xmin.  
  subq.w	#$1,d5	; One y less.
  beq.s	.xmin_next_line
  add.w	d2,d4	; Error=Error+2dx.
  ble.s	.xmin_big_eneg
.xmin_big_epos:
  add.w	d1,d0	; x=x+sx.
  move.w	d0,(a1)+	; Save the xmin.  
  subq.w	#$1,d5	; One y less.
  beq.s	.xmin_next_line
  sub.w	d3,d4	; Error=Error-2dy+2dx.
  ble.s	.xmin_big_eneg
  bra.s	.xmin_big_epos

.xmin_hline:
  cmp.w	d0,d2	; Take the left pixel.
  bgt.s	.xmin_h_ok
  exg.l	d0,d2
.xmin_h_ok:
  add.w	d0,d0
  move.w	d0,(a1)+	; Put it in the table.
  bra.s	.xmin_next_line
 
.xmin_vline:		; Here it' s very simple,
  add.w	d0,d0	; just have to repeat the motif.
  addq.w	#$1,d3
.xmin_v_rept:
  move.w	d0,(a1)+
  subq.w	#$1,d3	; One y less.
  bne.s	.xmin_v_rept
.xmin_next_line:
  subq.l	#$2,a1	; Don't save the brows twice.
  subq.l	#$1,d7	; One line less...
  beq.s	.xmaxs_calc
  bra	.xmin_one_line 

;**********
.xmaxs_calc:		; Now creating the xmaxs table.
  move.l	#.xmaxs,a1
  move.l	#.lines_max,a2
  move.l	a2,a3
  addq.l	#$4,a3
  move.l	.lines_max_nb,d7
.xmax_one_line:
  move.w	(a2)+,d0	; d0=x1.
  move.w	(a2)+,d1	; d1=y1.
  move.w	(a3)+,d2	; d2=x2.
  move.w	(a3)+,d3	; d3=y2.
  sub.w	d1,d3	; d3=y2-y1=dx, always positive.
  beq.s	.xmax_hline
  moveq.l	#$2,d1	; d1=sx*2.
  sub.w	d0,d2	; d2=x2-x1.
  beq.s	.xmax_vline
  bpl.s	.xmax_dxpos
.xmax_dxneg:		; d2 is negative.
  neg.l	d1	; Then sx=-1, d1=sx*2.
  neg.w	d2	; d2=dx=abs(x2-x1).
.xmax_dxpos:
  add.w	d0,d0	; Multiplication by 2.
  move.w	d3,d5	; Number of xmins for this line.
  cmp.w	d3,d2	; Big or low slope?
  bmi.s	.xmax_big_slope

.xmax_low_slope:
  add.w	d3,d3	; d3=2*dy.
  move.w	d3,d4
  sub.w	d2,d4	; Error=2dy-dx.
  add.w	d2,d2	; d2=2*dx.
  sub.w	d3,d2	; d2=2dx-2dy.
  move.w	d0,(a1)+	; Save the xmin.  
  tst.w	d4	; Error is positive?
  bpl.s	.xmax_low_epos
.xmax_low_eneg:
  add.w	d1,d0	; x=x+sx.
  add.w	d3,d4	; Error=Error+2dy.
  ble.s	.xmax_low_eneg
.xmax_low_epos:
  add.w	d1,d0	; x=x+sx.
  move.w	d0,(a1)+	; Save the xmin.  
  subq.w	#$1,d5	; One y less.
  beq.s	.xmax_next_line
  sub.w	d2,d4	; Error=Error-2dx+2dy.
  ble.s	.xmax_low_eneg
  bra.s	.xmax_low_epos

.xmax_big_slope:
  add.w	d2,d2	; d2=2*dx.
  move.w	d2,d4
  sub.w	d3,d4	; Error=2dx-dy.
  add.w	d3,d3	; d3=2*dy.
  sub.w	d2,d3	; d3=2dy-2dx.
  move.w	d0,(a1)+	; Save the xmin.  
  tst.w	d4	; Error is positive?
  bpl.s	.xmax_big_epos
.xmax_big_eneg:
  move.w	d0,(a1)+	; Save the xmin.  
  subq.w	#$1,d5	; One y less.
  beq.s	.xmax_next_line
  add.w	d2,d4	; Error=Error+2dx.
  ble.s	.xmax_big_eneg
.xmax_big_epos:
  add.w	d1,d0	; x=x+sx.
  move.w	d0,(a1)+	; Save the xmin.  
  subq.w	#$1,d5	; One y less.
  beq.s	.xmax_next_line
  sub.w	d3,d4	; Error=Error-2dy+2dx.
  ble.s	.xmax_big_eneg
  bra.s	.xmax_big_epos

.xmax_hline:
  cmp.w	d0,d2	; Take the right pixel.
  blt.s	.xmax_h_ok
  exg.l	d0,d2
.xmax_h_ok:
  add.w	d0,d0
  move.w	d0,(a1)+	; Put it in the table.
  bra.s	.xmax_next_line
 
.xmax_vline:		; Here it' s very simple,
  add.w	d0,d0	; just have to repeat the motif.
  addq.w	#$1,d3
.xmax_v_rept:
  move.w	d0,(a1)+
  subq.w	#$1,d3	; One y less.
  bne.s	.xmax_v_rept
.xmax_next_line:
  subq.l	#$2,a1	; Don't save the brows twice.
  subq.l	#$1,d7	; One line less...
  beq.s	.draw_poly
  bra	.xmax_one_line 
 
;*********
.draw_poly: 
  move.l	#.xmins,a1
  move.l	#.xmaxs,a2
  move.w	.hlines_nb,d7	; d7 is the counter.
  moveq.l	#$0,d0	; We must extend the adress of the
  move.w	.firstline,d0	; firstline to a longword.
  move.l	d0,d1	; Multiplication by $a0.
  add.l	d0,d0
  add.l	d0,d0
  add.l	d1,d0
  lsl.w	#$5,d0
  add.l	d0,a0	; a0 points on the first line.
  move.l	#.xmins_conv,a3
  move.l	#.xmaxs_conv,a4
  move.w	#$ffff,d4	; d4 is the internal motif.
  move.l	#$ffe0,d5	; d5 is the mask for the adresses,d5=$ffe0.
  move.l	#$a0,a5	; a5=$a0 length of a line.
.one_hline:
  move.l	a0,a6	; a6 will serve to fill the hline.
  add.l	a5,a0	; adress of the next line.
  move.w	(a1)+,d0	; d0=current xmin.
  move.w	(a2)+,d1	; d1=current xmax.
  move.w	(a3,d0.w),d2	; d2 is the xmin motif.
  move.w	(a4,d1.w),d3	; xmax motif.
  and.w	d5,d0	; d0=(xmin mod(16))*2.
  and.w	d5,d1	; d1=(xmax mod(16))*2.
  sub.w	d0,d1	; d1=(xmax(16)-xmin(16))*2.
  beq.s	.melted_words
  lsr.w	#$2,d0	; d0=(xmin mod(16))/2=adress for xmin.
  lsr.w	#$2,d1	; a1=(xmax(16)-xmin(16))/2. 
  add.l	d0,a6	; a6 points on the xmin word.
  subq.l	#$8,d1	; Don't count extremals points.
  beq.s	.near_words
  or.w	d2,(a6)	; Print xmin motif.
  addq.l	#$8,a6	; Next word.
.fill_word:
  move.w	d4,(a6)
  addq.l	#$8,a6
  subq.l	#$8,d1	; One word is done. 
  bne.s	.fill_word
  or.w	d3,(a6)	; Print xmax motif.
  subq.l	#$1,d7
  bpl.s	.one_hline
  movem.l	(sp)+,d1-d7/a2-a6
  rts
 
.melted_words:
  lsr.w	#$2,d0	; d0=(xmin mod(16))/2=adress for xmin.
  add.l	d0,a6	; a6 points on the xmin word.
  and.w	d3,d2
  or.w	d2,(a6)
  subq.l	#$1,d7
  bpl.s	.one_hline
  movem.l	(sp)+,d1-d7/a2-a6
  rts
   	
.near_words:
  or.w	d2,(a6)	; Print xmin motif.
  addq.l	#$8,a6	; Next word.
  or.w	d3,(a6)	; Print xmax motif.
  subq.l	#$1,d7
  bpl.s	.one_hline
  movem.l	(sp)+,d1-d7/a2-a6
  rts
 
;************
 Section DATA

.xmins_conv:
  rept	20
  dc.w	$ffff,$7fff,$3fff,$1fff
  dc.w	$0fff,$07ff,$03ff,$01ff
  dc.w	$00ff,$007f,$003f,$001f
  dc.w	$000f,$0007,$0003,$0001
  endr
.xmaxs_conv:
  rept	20
  dc.w	$8000,$c000,$e000,$f000
  dc.w	$f800,$fc00,$fe00,$ff00
  dc.w	$ff80,$ffc0,$ffe0,$fff0
  dc.w	$fff8,$fffc,$fffe,$ffff
  endr
    
;***********
  Section  BSS

.hlines_nb:
  ds.w	1
.firstline:
  ds.w	1
.lines_min_nb:
  ds.l	1
.lines_max_nb:
  ds.l	1
.lines_min:
  ds.l	42
.lines_max:
  ds.l	42
.xmins:
  ds.w	200
.xmaxs:
  ds.w	200
