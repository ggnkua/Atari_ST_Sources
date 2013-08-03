; *************************************************************************
; *****	   Routine which draws a filled rectangle.            *****
; *************************************************************************
; Parameters:	a0.l = adress of the ramvideo.
;	d0.w = x1. (On the left)
;	d1.w = y1. (Up)
;	d2.w = x2. (Right)
;	d3.w = y2. (Down)
; Important note: Some of the blitter registers must be already initialised
; when you call this routine... They are: Endmask 2, Dest x increments,
; Halftone & Logical ops registers.

  Section TEXT

.box_visibility:
  tst.w	d2	; Is x2<0?
  ble.s	.invisible	; Then the box is not in the screen.
  tst.w	d3	; The same if y2<0.
  ble.s	.invisible
  cmp.w	#319,d0	; The same if x1>319.
  bge.s	.invisible
  cmp.w	#199,d1	; And also if y1>199.
  blt.s	.visible
.invisible:
  rts
  
.visible:		; The box is (partly) visible.
  movem.l	d0-d3/a0-a1,-(sp)
.clipping:		; Cut the parts who are out of the screen.
  tst.w	d0	; Is x1<0?
  bge.s	.no_left_clip
.left_clip:		; Yes, then cut the part out of the screen
  moveq.l	#$0,d0	; by putting x1 to 0.
.no_left_clip:
  tst.w	d1	; Is y1<0?
  bge.s	.no_up_clip
.up_clip:		; Yes, then cut the part out of the screen
  moveq.l	#$0,d1	; by putting y1 to 0.
.no_up_clip:
  cmp.w	#319,d2	; Is x2>319?
  ble.s	.no_right_clip
.right_clip:
  move.w	#319,d2	; Cut <=> x2=319.
.no_right_clip:
  cmp.w	#199,d3	; Is y2>199?
  ble.s	.no_down_clip
.down_clip:
  move.w	#199,d3	; Cut <=> y2=319.
.no_down_clip:

; The clipping is finished. Now we can print the box!

  sub.w	d1,d3	; d3=y2-y1.
  addq.w	#$1,d3	; d3=nb of lines to draw.
  move.w	d3,$ffff8a38.w	; Lines per bit-block.
.y_conversion:
  move.l	#.y_conv,a1	; The faster method?
  add.w	d1,d1	; One word per y.
  add.w	(a1,d1.w),a0	; a0 points on the first line.
.x_conversions:
  move.l	#.x_left_conv,a1
  lsl.w	#$2,d0	; Two words per x.
  move.l	(a1,d0.w),d0	; Upperword=mask Lowerword=offset.
  add.w	d0,a0	; a0 points on the first word.
  move.l	a0,$ffff8a32.w	; Dest adress.
  move.l	#.x_right_conv,a1
  lsl.w	#$2,d2
  move.l	(a1,d2.w),d2	; Upperword=mask Lowerword=offset.
  sub.w	d0,d2	; d2=right offset-left offset.
  beq.s	.melted	; Only one word?
.normal:
  swap.w	d0
  move.w	d0,$ffff8a28.w	; Endmask 1.
  lsr.w	#$3,d2
  addq.w	#$1,d2	; lowerword(d2)=nb of words per line.
  move.w	d2,$ffff8a36.w	; Words per line.
  add.w	d2,d2
  move.l	#.dest_y_inc,a1
  move.w	(a1,d2.w),$ffff8a30.w ; Dest y increment.
  swap.w	d2
  move.w	d2,$ffff8a2c.w	; Endmask 3.
  move.b	#$c0,$ffff8a3c.w ; Go for it.
  movem.l	(sp)+,d0-d3/a0-a1
  rts

.melted:
  swap.w	d0
  swap.w	d2
  and.w	d0,d2	; Mask=mask1 and mask2.
  move.w	d2,$ffff8a28.w	; Endmask 1.
  move.w	#$1,$ffff8a36.w	; One word per line.
  move.w	#160,$ffff8a30.w ; Dest y inc.
  move.b	#$c0,$ffff8a3c.w ; Go for it.
  movem.l	(sp)+,d0-d3/a0-a1
  rts
  
; *************************************************************************
  Section DATA
  
.y_conv:
N set 0
 rept	200
  dc.w	N
N set N+160
 endr
  
.x_left_conv:
N set 0
 rept	20
  dc.w	$ffff,N,$7fff,N,$3fff,N,$1fff,N
  dc.w	$0fff,N,$07ff,N,$03ff,N,$01ff,N
  dc.w	$00ff,N,$007f,N,$003f,N,$001f,N
  dc.w	$000f,N,$0007,N,$0003,N,$0001,N
N set N+8
 endr

.x_right_conv:
N set 0
 rept	20
  dc.w	$8000,N,$c000,N,$e000,N,$f000,N
  dc.w	$f800,N,$fc00,N,$fe00,N,$ff00,N
  dc.w	$ff80,N,$ffc0,N,$ffe0,N,$fff0,N
  dc.w	$fff8,N,$fffc,N,$fffe,N,$ffff,N
N set N+8
 endr
 
.dest_y_inc:
N set 168
 rept	21
  dc.w	N
N set N-8
 endr
     