; *************************************************************************
; ****         Routine which draws text with the nice fonts.           ****
; ****                   Dracula / Positivity.		       ****
; *************************************************************************
; Parameters:	a0.l = adress of the line where to draw.
;	a1.l = adress of the text.
; Note that the text must ends with a null character.

  movem.l	d0-d2/a0-a5,-(sp)
  move.l	a1,a4
  move.l	#.conv_table,a2
  move.l	#.lengths,a3
  moveq.l	#$0,d0
  moveq.l	#$0,d1
.calc_length:
  move.b	(a4)+,d0	; The ascii value of the char.
  tst.b	d0	; Null char at the end of the text.
  beq.s	.end_calc  
  move.b	(a2,d0.w),d0	; It's position in a "normal" table.
  move.b	(a3,d0.w),d0	; And finally its length.
  add.w	d0,d1 	; Add it to the string length.
  bra.s	.calc_length	; Next char.

.end_calc:		; d1 contains the length.
  move.w	#$140,d0
  sub.w	d1,d0
  lsr.w	#$1,d0	; d0=(320-length)/2=x_pos for current char.
.init_blitter:
  move.l	#-$1,$ffff8a28.w ; Endmasks.
  move.w	#-$1,$ffff8a2c.w
  move.w	#$207,$ffff8a3a.w ; Source only.
  move.w	#$2,$ffff8a20.w ; X source inc.
  move.w	#$4,$ffff8a22.w	; Y source inc.
  move.w	#$8,$ffff8a2e.w	; X dest inc.
  move.w	#$98,$ffff8a30.w ; Y dest inc.
  
  move.l	#.x_conv,a4
  
.print_one:
  moveq.l	#$0,d1
  move.b	(a1)+,d1	; The char to print.
  tst.b	d1	; Null char?
  beq.s	.finished
  move.b	(a2,d1.w),d1	; Pos of the char in my table.

  move.l	a0,a5	; a5 for the adress of dest.
  move.w	d0,d2
  add.w	d2,d2
  add.w	d2,d2	; d2=x_pos*4.
  add.w	(a4,d2.w),a5	; Add offset of the x_pos.
  move.l	a5,$ffff8a32.w	; Destination adress.
  move.b	$3(a4,d2.w),$ffff8a3d.w ; eXtra source read and skew.

  moveq.l	#$0,d2
  move.b	(a3,d1.w),d2
  add.w	d2,d0	; x_pos for next char.
  muls.w	#152,d1	; To point in the font_table.
  add.l	#.fonts,d1	; d1 points on the source adress.
  move.l	d1,$ffff8a24.w
    
  move.w	#$2,$ffff8a36.w	; Two words per line.
  move.w	#$13,$ffff8a38.w ; Nb of lines.
  move.b	#$c0,$ffff8a3c.w ; Launch the blitter.
  
  addq.w	#$2,a5	; Next bitplane.
  move.l	a5,$ffff8a32.w	; Destination adress.
  addq.l	#$4,d1
  move.l	d1,$ffff8a24.w

  move.w	#$2,$ffff8a36.w	; Two words per line.
  move.w	#$13,$ffff8a38.w ; Nb of lines.
  move.b	#$c0,$ffff8a3c.w ; Launch the blitter.
  bra.s	.print_one

.finished:  
  movem.l	(sp)+,d0-d2/a0-a5
  rts

.x_conv:
N set 0
 rept	20
  dc.w	N,$80,N,$81,N,$82,N,$83,N,$84,N,$85,N,$86,N,$87
  dc.w	N,$88,N,$89,N,$8a,N,$8b,N,$8c,N,$8d,N,$8e,N,$8f
N set N+8
 endr  
    
.conv_table:
  dc.b	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  dc.b	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  dc.b	00,68,00,00,00,00,53,69,54,55,00,00,00,00,70,56
  dc.b	57,58,59,60,61,62,63,64,65,66,00,00,00,00,00,67
  dc.b	00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15
  dc.b	16,17,18,19,20,21,22,23,24,25,26,00,00,00,00,00
  dc.b	00,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41
  dc.b	42,43,44,45,46,47,48,49,50,51,52,00,00,00,00,00
      
.lengths:
  dc.b	8,12,13,13,14,10,16,13,16,13,12,11,12,16,15,12,12
  dc.b	13,15,15,15,12,15,16,16,11,16,8,7,6,7,7,7,8,8,5
  dc.b	6,8,6,11,7,7,10,9,7,6,6,8,8,11,8,8,7,9,6,7,9,9,7
  dc.b	8,8,9,8,8,9,8,8,7,5,4,4

  even
  
.fonts:
  dc.w	0
  incbin	'a:\datas\fonts.xxx'
