; *************************************************************************
; ****				       ****
; ****	     Balls Intersection using Z-buffer method.	       ****
; ****	     	 By Alain BROBECKER	       ****
; ****	     Coded Between 11th and 13th of july 1994.	       ****
; ****				       ****
; *************************************************************************
time	equ 1024

supervisor:
  move.l	#$0,-(sp)
  move.w	#$20,-(sp)
  trap	#$1
  addq.l	#$6,sp

initialisations:	
  dc.w	$a00a	; Fuck the mouse.
  move.b	#$12,$fffffc02.w
  move.b	$484.w,old_conterm
  clr.b	$484.w	; No bip, no repeat.
  move.l	$114.w,old_timerc ; Unusefull for a demo.
  move.l	#null_timerc,$114.w ; Put a "null" routine.
  move.l	$70.w,old_vbl	; I have to use my own Vbl.
  move.l	#null_vbl,$70.w	; A "null" vbl for the moment.

  move.w	#$25,-(sp) 
  trap	#$e	; Vsync
  addq.l	#$2,sp
  move.b	$ffff8260.w,old_rez ; Save screen features.
  move.b	$ffff8201.w,old_screen
  move.b	$ffff8203.w,old_screen+1
  move.b	$ffff820d.w,old_screen+2
  move.w	#$25,-(sp) 
  trap	#$e	; Vsync
  addq.l	#$2,sp

  move.b	#$0,$ffff8260.w

; Put our colors:
  move.l	#colors,a0
  move.w	#$8240,a1
 rept	8
  move.l	(a0)+,(a1)+
 endr

  jsr	prepare_all
    
; *************************************************************************

  move.l	#$0,$466.w

vbl_one:
  jsr	wait_vbl
  move.l	#screen1,a6

.clear_box:
  move.l	a6,a0
  move.l	#old_box1,a1
  move.w	(a1)+,d0	; Extremities of the box to clear.
  move.w	(a1)+,d1
  move.w	(a1)+,d2
  move.w	(a1)+,d3
  jsr	clear_4_bpl

.parameters:
  move.w	z_pos,d0
  move.w	z_pos_inc,d1
  add.w	d1,d0
  bne.s	.z_pos_ok1
  neg.w	d1
.z_pos_ok1:
  cmp.w	#64,d0
  bne.s	.z_pos_ok2
  neg.w	d1
.z_pos_ok2:
  move.w	d0,z_pos
  move.w	d0,sferes_pos+8
  move.w	d1,z_pos_inc

  move.w	t_parameter2,d0
  addq.w	#$1,d0
  andi.w	#$1ff,d0
  move.w	d0,t_parameter2

  move.w	t_parameter,d0
  addq.w	#$2,d0
  andi.w	#$1ff,d0
  move.w	d0,t_parameter

.calc_x96_y96:
  move.w	d0,d1
  add.w	d0,d0
  add.w	d0,d1
  andi.w	#$1ff,d0	; d0=2*t.
  andi.w	#$1ff,d1	; d1=3*t.
  add.w	d0,d0
  add.w	d1,d1
  move.l	#sinus,a0
  move.w	(a0,d0.w),d0	; d0=sin(2t).
  muls.w	#60,d0
  rol.l	#$2,d0
  swap.w	d0
  add.w	#111,d0	; Recenter.
  move.w	d0,sferes_pos	; x96=100*sin(2t).
  add.w	#$80,a0
  move.w	(a0,d1.w),d1	; d1=cos(3t).
  muls.w	#30,d1
  rol.l	#$2,d1
  swap.w	d1
  add.w	#51,d1	; Recenter.
  move.w	d1,sferes_pos+2	; y96=50*cos(3t).

.calc_x48_y48_z48:
  move.l	#sinus,a0
  move.w	t_parameter2,d0
  move.w	d0,d1
  add.w	d1,d1
  add.w	d1,d1
  add.w	d0,d1	; d1=5*t.
  andi.w	#$1ff,d1
  add.w	d0,d0
  add.w	d1,d1
  move.w	(a0,d1.w),d1	; d1=sin(5*t).
  add.w	#$80,a0
  move.w	(a0,d0.w),d0	; d0=cos(t).
  muls.w	#30,d1
  rol.l	#$2,d1
  swap.w	d1
  muls.w	#30,d0
  rol.l	#$2,d0
  swap.w	d0
  add.w	sferes_pos,d0
  add.w	#24,d0
  move.w	d0,sferes_pos+4
  add.w	sferes_pos+2,d1
  add.w	#24,d1
  move.w	d1,sferes_pos+6
  
.search_box:
  move.w	sferes_pos,d0
  move.w	sferes_pos+2,d2
  move.w	d0,d1
  add.w	#110,d1
  move.w	d2,d3
  add.w	#110,d3
  sub.w	#10,d0
  sub.w	#10,d2
  move.l	#old_box1,a0
  movem.w	d0-d3,(a0)
  
.print_them:
  move.l	a6,a0
  move.l	#sferes_pos,a1
  jsr	eat_my_balls

  move.l	a6,d0
  move.l	d0,d1
  swap.w	d0
  move.b	d0,$ffff8201.w
  swap.w	d0
  rol.w	#$8,d0
  move.b	d0,$ffff8203.w
  move.b	d1,$ffff820d.w

vbl_two:
  jsr	wait_vbl
  move.l	#screen2,a6

.clear_box:
  move.l	a6,a0
  move.l	#old_box2,a1
  move.w	(a1)+,d0	; Extremities of the box to clear.
  move.w	(a1)+,d1
  move.w	(a1)+,d2
  move.w	(a1)+,d3
  jsr	clear_4_bpl

.parameters:
  move.w	z_pos,d0
  move.w	z_pos_inc,d1
  add.w	d1,d0
  bne.s	.z_pos_ok1
  neg.w	d1
.z_pos_ok1:
  cmp.w	#64,d0
  bne.s	.z_pos_ok2
  neg.w	d1
.z_pos_ok2:
  move.w	d0,z_pos
  move.w	d0,sferes_pos+8
  move.w	d1,z_pos_inc

  move.w	t_parameter2,d0
  addq.w	#$1,d0
  andi.w	#$1ff,d0
  move.w	d0,t_parameter2

  move.w	t_parameter,d0
  addq.w	#$2,d0
  andi.w	#$1ff,d0
  move.w	d0,t_parameter

.calc_x96_y96:
  move.w	d0,d1
  add.w	d0,d0
  add.w	d0,d1
  andi.w	#$1ff,d0	; d0=2*t.
  andi.w	#$1ff,d1	; d1=3*t.
  add.w	d0,d0
  add.w	d1,d1
  move.l	#sinus,a0
  move.w	(a0,d0.w),d0	; d0=sin(2t).
  muls.w	#60,d0
  rol.l	#$2,d0
  swap.w	d0
  add.w	#111,d0	; Recenter.
  move.w	d0,sferes_pos	; x96=100*sin(2t).
  add.w	#$80,a0
  move.w	(a0,d1.w),d1	; d1=cos(3t).
  muls.w	#30,d1
  rol.l	#$2,d1
  swap.w	d1
  add.w	#51,d1	; Recenter.
  move.w	d1,sferes_pos+2	; y96=50*cos(3t).

.calc_x48_y48_z48:
  move.l	#sinus,a0
  move.w	t_parameter2,d0
  move.w	d0,d1
  add.w	d1,d1
  add.w	d1,d1
  add.w	d0,d1	; d1=5*t.
  andi.w	#$1ff,d1
  add.w	d0,d0
  add.w	d1,d1
  move.w	(a0,d1.w),d1	; d1=sin(5*t).
  add.w	#$80,a0
  move.w	(a0,d0.w),d0	; d0=cos(t).
  muls.w	#30,d1
  rol.l	#$2,d1
  swap.w	d1
  muls.w	#30,d0
  rol.l	#$2,d0
  swap.w	d0
  add.w	sferes_pos,d0
  add.w	#24,d0
  move.w	d0,sferes_pos+4
  add.w	sferes_pos+2,d1
  add.w	#24,d1
  move.w	d1,sferes_pos+6
  
.search_box:
  move.w	sferes_pos,d0
  move.w	sferes_pos+2,d2
  move.w	d0,d1
  add.w	#110,d1
  move.w	d2,d3
  add.w	#110,d3
  sub.w	#10,d0
  sub.w	#10,d2
  move.l	#old_box2,a0
  movem.w	d0-d3,(a0)
  
.print_them:
  move.l	a6,a0
  move.l	#sferes_pos,a1
  jsr	eat_my_balls

  move.l	a6,d0
  move.l	d0,d1
  swap.w	d0
  move.b	d0,$ffff8201.w
  swap.w	d0
  rol.w	#$8,d0
  move.b	d0,$ffff8203.w
  move.b	d1,$ffff820d.w

  cmpi.b	#$39,$fffffc02.w
  bne	vbl_one

; *************************************************************************
the_end:
  move.w	#$25,-(sp) 
  trap	#$e	; Vsync
  addq.l	#$2,sp

  move.b	old_rez,$ffff8260.w ; Restore screen features.
  move.b	old_screen,$ffff8201.w
  move.b	old_screen+1,$ffff8203.w
  move.b	old_screen+2,$ffff820d.w

  move.l	old_vbl,$70.w	; Restore the Vbl.
  move.l	old_timerc,$114.w ; Restore old timerC rout.
  move.b	old_conterm,$484.w
  move.b	#$8,$fffffc02.w ; Restore mouse.
  dc.w	$a009

  move.w	#$25,-(sp) 
  trap	#$e	; Vsync
  addq.l	#$2,sp

  move.w	#$000,$ffff8240.w ; Devpac does not restore colors.
  move.w	#$445,$ffff8242.w
  move.w	#$445,$ffff8244.w
  move.w	#$445,$ffff8246.w
    
  clr.w	-(sp)
  trap	#$1

; ************************************************************************
null_timerc:		; "Null" routine for the timerC.
  addq.l	#$1,$4ba.w	; Increment interrupt counter.
  bclr.b	#$5,$fffffa11.w	; Interrupt no more in service.
  rte

; ************************************************************************
null_vbl:		; "Null" vbl routine.
  addq.l	#$1,$466.w	; Increment _frclock.
  cmp.l	#$0,$4d2.w	; A music routine?
  beq.s	.no_music
.music:		; Yes, so execute it.
  move.l	a0,-(sp)
  move.l	$4d2.w,a0
  jsr	(a0)
  move.l	(sp)+,a0
.no_music:
  rte

; *************************************************************************
; More or less (Certainly less) interesting routines.
wait_vbl:
  move.w	d0,-(sp)
  move.w	$468.w,d0
.wait:
  cmp.w	$468.w,d0
  beq.s	.wait
  move.w	(sp)+,d0
  rts

; *************************************************************************
; Routine which clears a box in 4 planes.
; Parameters:	a0.l = ramvideo adress.
;	d0.w = x1.
;	d1.w = x2.
;	d2.w = y1.
;	d3.w = y2.

clear_4_bpl:		; First see if the box is visible.
  movem.l	d0-3/a0-1,-(sp)
  tst.w	d3	; y2<0?
  blt.s	.end
  cmp.w	#199,d2	; y1>199.
  ble.s	.clipping
.end:
  movem.l	(sp)+,d0-3/a0-1
  rts
.clipping:
  tst.w	d2	; y1<0?
  bge.s	.no_clip_up
  moveq.l	#$0,d2	; Then y1=0.
.no_clip_up:
  cmp.w	#199,d3	; y2>199?
  ble.s	.no_clip_down
  move.w	#199,d3	; Then y2=199
.no_clip_down:
  sub.w	d2,d3	; d3=y2-y1=dy.
  addq.w	#$1,d3
  move.w	d3,$ffff8a38.w	; Lines per bit-block.
  move.l	#y_table,a1	
  add.w	d2,d2
  add.w	(a1,d2.w),a0	; a0 points on good line.
  move.w	#$fff0,d2
  and.w	d2,d0	; d0=x1 mod(16).
  and.w	d2,d1	; d1=x2 mod(16).
  add.w	#$10,d1	; d1=x2 mod(16)+16.
  sub.w	d0,d1	; d1=x2 mod(16)+16-x1 mod(16).
  lsr.w	#$1,d0
  add.w	d0,a0	; a0 points on good word.
  move.l	a0,$ffff8a32.w	; Dest adress.
  lsr.w	#$2,d1	; d2=nb of words.
  move.w	d1,$ffff8a36.w	; Words per line.
  move.w	#$2,$ffff8a2e.w ; Dest x inc.
  add.w	d1,d1
  move.w	#162,d3
  sub.w	d1,d3
  move.w	d3,$ffff8a30.w	; Dest y inc.
  moveq.l	#-1,d0
  move.l	d0,$ffff8a28.w	; Endmasks set to ones.
  move.w	d0,$ffff8a2c.w
  move.w	#$200,$ffff8a3a.w ; Fill with zeroes.
  move.b	#$c0,$ffff8a3c.w
  movem.l	(sp)+,d0-3/a0-1
  rts

; *************************************************************************
; *
; * Routine which prepares the 96*96 sfere's sprite and Z table.
; *
; *************************************************************************

prepare_all:
  movem.l	d0-a6,-(sp)
  
; At first, I must add 3 words at the end of each line in the sprites becoz
; the blitter sucks and read an extra word...
.convert_96_sfere:
  move.l	#sfere96,a0
  move.l	#sprite96,a1
  moveq.l	#95,d0	; 96 lines.
  move.l	#$0,a4	; Last 3 words filled with zeroes.
.96_one_line:
  movem.l	(a0)+,d1-d7/a2-a3 ; Load 18 words.
  movem.l	d1-d7/a2-a4,(a1) ; Save 20 words.
  add.w	#40,a1
  move.w	a4,(a1)+	; Saved 21 words.
  dbra	d0,.96_one_line
  
.prepare_z_table:	; Put the 96*96 z table of the sfere into
  move.l	#zsfere96,a0	; a big 192*192 z table.
  move.l	#big_ztable+9264,a1 ; Points on pos (47;47) in the big table.
  moveq.l	#95,d0
.z96_one_line:
  movem.l	(a0)+,d1-d7/a2-a6 ; Load 48 bytes.
  movem.l	d1-d7/a2-a6,(a1) ; Copy them.
  add.w	#48,a1
  movem.l	(a0)+,d1-d7/a2-a6 ; Load 48 bytes.
  movem.l	d1-d7/a2-a6,(a1) ; Copy them.
  add.w	#144,a1	; Next line.
  dbra	d0,.z96_one_line

.prepare_blitter:	; No use of the endmasks.
  moveq.l	#-1,d0
  move.l	d0,$ffff8a28.w
  move.w	d0,$ffff8a2c.w
    
  movem.l	(sp)+,d0-a6
  rts

; *************************************************************************
; *
; * Routine which draws the balls with Z buffer.
; *
; *************************************************************************
; Parameters:	a0.l = ramvideo adress.
;	a1.l = adress where are stored (in this order):
;	  x96.w / y96.w / x48.w / y48.w / z48.w
; By the way, z96 is always 0. Also note that the x and y are not the
; coords of the centers of each balls, but their upper left corner.

eat_my_balls:		; What a nice name.
  movem.l	d0-a6,-(sp)

; *
; * At first we draw the big sphere without doing anything else.
; *
.print_big_sphere:
  move.w	(a1),d0	; d0=x96.
  move.w	$2(a1),d1	; d1=y96.
  move.l	a0,a2
  move.l	#y_table,a3	; Fast conversion y->y*160.
  add.w	d1,d1	; One word per y.
  add.w	(a3,d1.w),a2	; a2 points on first line.
  move.l	#x_table,a3
  add.w	d0,d0	; Two words per x.
  add.w	d0,d0
  add.w	(a3,d0.w),a2	; a2 points on 1st dest word.
  move.l	a2,$ffff8a32.w	; Dest adress.
  move.b	$2(a3,d0.w),$ffff8a3d.w ; Source skew.
  move.l	#$80070,$ffff8a2e.w ; Dest X&Y inc.
  move.w	#7,$ffff8a36.w	; 7 words per line.
  move.w	#95,$ffff8a38.w	; 95 lines.
  move.l	#sprite96,$ffff8a24.w ; Source adress.
  move.l	#$60006,$ffff8a20.w ; Source X&Y inc.
  move.w	#$203,$ffff8a3a.w ; Source.
  move.b	#$c0,$ffff8a3c.w ; Launch.
.plane2:
  move.l	#sprite96+2,$ffff8a24.w
  addq.w	#$2,a2
  move.l	a2,$ffff8a32.w
  move.w	#95,$ffff8a38.w	; 95 lines.
  move.b	#$c0,$ffff8a3c.w ; Launch.
.plane3:
  move.l	#sprite96+4,$ffff8a24.w
  addq.w	#$2,a2
  move.l	a2,$ffff8a32.w
  move.w	#95,$ffff8a38.w	; 95 lines.
  move.b	#$c0,$ffff8a3c.w ; Launch.

; *
; * Now, the interesting part. We will compare the z of the 48sfere + z48
; * and the z in the big_ztable and with this we will create the mask to
; * use for doing the good sphere intersection.
; *

.calculate_mask:
  move.w	(a1)+,d0	; d0=x96.
  move.w	(a1)+,d1	; d1=y96.
  moveq.l	#48,d2	; d2=48=xpos of 96sfere in the big_ztable.
  moveq.l	#48,d3	; d3=48=ypos of 96sfere in big_ztable.
  sub.w	d0,d2
  sub.w	d1,d3
  add.w	(a1),d2	; d2=x48pos=xpos of 48sfere in big_ztable.
  add.w	$2(a1),d3	; d3=y48pos=ypos of 48sfere in big_ztable.
; * If the 48sfere is partly or entirely out of the big_ztable, the result
; * is the same as when (x48pos;y48pos)=(0;0), so if this happens make
; * the 48sfere point on the edge of the big_ztable.
  cmp.w	#$0,d2	; x48pos<0?
  bge.s	.its_ok1
  moveq.l	#$0,d2	; Yes, then it' s out.
  bra.s	.good_48pos
.its_ok1:
  cmp.w	#$0,d3	; y48pos<0?
  bge.s	.its_ok2
  moveq.l	#$0,d3	; Yes, then it' s out.
  bra.s	.good_48pos
.its_ok2:
  cmp.w	#144,d2	; x48pos>144?
  ble.s	.its_ok3
  moveq.l	#$0,d2	; Yes, then it' s out.
  bra.s	.good_48pos
.its_ok3:
  cmp.w	#144,d3	; y48pos>144?
  ble.s	.good_48pos
  moveq.l	#$0,d3	; Yes, then it' s out.
.good_48pos:		; Ok, now 48sfere is in the big_ztable.

  move.l	#big_ztable,a2
  move.l	#z_y_table,a3	; Table y->y*192.
  add.w	d3,d3
  add.w	(a3,d3.w),a2
  add.w	d2,a2	; a2 points on (x48pos;y48pos).
  move.l	#zsfere48,a3	; ztable for the 48*48 sfere.
  move.l	#mask48,a4
  moveq.l	#46,d0	; 47 lines.
  move.w	$4(a1),d1	; d1=z48.
 
.one_line:
  moveq.l	#$0,d4	; Go for 16 points.
N set 15
 rept	16  
  move.b	(a2)+,d2	; d2=z of background.
  move.b	(a3)+,d3
  add.b	d1,d3	; d3=z of 48sfere.
  cmp.b	d2,d3	; Which z is nearer than other?
  dc.w	$6f04	; "ble.s  +4". Pass next instruction if <=.
  bset.l	#N,d4
N set N-1
 endr
  move.w	d4,(a4)+	; Save the mask.
  move.w	d4,(a4)+
  move.w	d4,(a4)+
  moveq.l	#$0,d4	; Points 16 to 31.
N set 15
 rept	16  
  move.b	(a2)+,d2	; d2=z of background.
  move.b	(a3)+,d3
  add.b	d1,d3	; d3=z of 48sfere.
  cmp.b	d2,d3	; Which z is nearer than other?
  dc.w	$6f04	; "ble.s  +4". Pass next instruction if <=.
  bset.l	#N,d4
N set N-1
 endr
  move.w	d4,(a4)+	; Save the mask.
  move.w	d4,(a4)+
  move.w	d4,(a4)+
  moveq.l	#$0,d4	; Points 32 to 47.
N set 15
 rept	16  
  move.b	(a2)+,d2	; d2=z of background.
  move.b	(a3)+,d3
  add.b	d1,d3	; d3=z of 48sfere.
  cmp.b	d2,d3	; Which z is nearer than other?
  dc.w	$6f04	; "ble.s  +4". Pass next instruction if <=.
  bset.l	#N,d4
N set N-1
 endr
  move.w	d4,(a4)+	; Save the mask.
  move.w	d4,(a4)+
  move.w	d4,(a4)+
  moveq.l	#$0,d4
  move.l	d4,(a4)+	; Three lasts words of the mask set to 1.
  move.w	d4,(a4)+
  add.w	#144,a2	; Next line.
  dbra	d0,.one_line

; *
; * Now fuck the pixels not to be seen in the already drawn image.
; *

  move.w	(a1),d0	; d0=x48.
  move.w	$2(a1),d1	; d1=y48.
  move.l	a0,a2
  move.l	#y_table,a3	; Fast conversion y->y*160.
  add.w	d1,d1	; One word per y.
  add.w	(a3,d1.w),a2	; a2 points on first line.
  move.l	#x_table,a3
  add.w	d0,d0	; Two words per x.
  add.w	d0,d0
  add.w	(a3,d0.w),a2	; a2 points on 1st dest word.
  move.l	a2,$ffff8a32.w	; Dest adress.
  move.b	$2(a3,d0.w),$ffff8a3d.w ; Source skew.
  move.l	#$80088,$ffff8a2e.w ; Dest X&Y inc.
  move.w	#4,$ffff8a36.w	; 7 words per line.
  move.w	#47,$ffff8a38.w	; 47 lines.
  move.l	#mask48,$ffff8a24.w ; Source adress.
  move.l	#$60006,$ffff8a20.w ; Source X&Y inc.
  move.w	#$204,$ffff8a3a.w ; Not source and dest.
  move.b	#$c0,$ffff8a3c.w ; Launch.
.mask_plane2:
  move.l	#mask48+2,$ffff8a24.w
  addq.w	#$2,a2
  move.l	a2,$ffff8a32.w
  move.w	#47,$ffff8a38.w	; 47 lines.
  move.b	#$c0,$ffff8a3c.w ; Launch.
.mask_plane3:
  move.l	#mask48+4,$ffff8a24.w
  addq.w	#$2,a2
  move.l	a2,$ffff8a32.w
  move.w	#47,$ffff8a38.w	; 47 lines.
  move.b	#$c0,$ffff8a3c.w ; Launch.
.put_plane4:
  move.w	#$203,$ffff8a3a.w ; Source.
  move.l	#mask48+4,$ffff8a24.w
  addq.w	#$2,a2
  move.l	a2,$ffff8a32.w
  move.w	#47,$ffff8a38.w	; 47 lines.
  move.b	#$c0,$ffff8a3c.w ; Launch.

; *
; * Put 48sfere and mask48 in the mask48 buffer, and then draw the sphere.
; *

  move.l	#sfere48,$ffff8a24.w ; Source.
  move.l	#mask48,$ffff8a32.w ; Dest
  move.l	#$20002,$ffff8a20.w ; Source X&Y inc.
  move.l	#$20008,$ffff8a2e.w ; Dest X&Y inc.
  move.w	#9,$ffff8a36.w	; 9 words per line.
  move.w	#47,$ffff8a38.w	; 47 lines.
  move.w	#$201,$ffff8a3a.w ; Source and dest.
  move.b	#$0,$ffff8a3d.w	; No skew.
  move.b	#$c0,$ffff8a3c.w ; Go!

  move.w	(a1)+,d0	; d0=x48.
  move.w	(a1)+,d1	; d1=y48.
  move.l	#y_table,a3	; Fast conversion y->y*160.
  add.w	d1,d1	; One word per y.
  add.w	(a3,d1.w),a0	; a0 points on first line.
  move.l	#x_table,a3
  add.w	d0,d0	; Two words per x.
  add.w	d0,d0
  add.w	(a3,d0.w),a0	; a0 points on 1st dest word.
  move.l	a0,$ffff8a32.w	; Dest adress.
  move.b	$2(a3,d0.w),$ffff8a3d.w ; Source skew.
  move.l	#$80088,$ffff8a2e.w ; Dest X&Y inc.
  move.w	#4,$ffff8a36.w	; 4 words per line.
  move.w	#47,$ffff8a38.w	; 47 lines.
  move.l	#mask48,$ffff8a24.w ; Source adress.
  move.l	#$60006,$ffff8a20.w ; Source X&Y inc.
  move.w	#$207,$ffff8a3a.w ; Source or dest.
  move.b	#$c0,$ffff8a3c.w ; Launch.
.48_plane2:
  move.l	#mask48+2,$ffff8a24.w
  addq.w	#$2,a0
  move.l	a0,$ffff8a32.w
  move.w	#47,$ffff8a38.w	; 47 lines.
  move.b	#$c0,$ffff8a3c.w ; Launch.
.48_plane3:
  move.l	#mask48+4,$ffff8a24.w
  addq.w	#$2,a0
  move.l	a0,$ffff8a32.w
  move.w	#47,$ffff8a38.w	; 47 lines.
  move.b	#$c0,$ffff8a3c.w ; Launch.
      
  movem.l	(sp)+,d0-a6
  rts

; *************************************************************************
  Section DATA

sinus:
  incbin	'e:\demos\positivi.ty\passion\rotazoom\sinus.xxx'
  
sfere96:
  incbin	'e:\demos\positivi.ty\passion\z_buffer\96_sfere.xxx'

sfere48:  
	incbin	'e:\demos\positivi.ty\passion\z_buffer\48_sfere.xxx'

zsfere96:
  incbin	'e:\demos\positivi.ty\passion\z_buffer\96_sfere.z'

zsfere48:
  incbin	'e:\demos\positivi.ty\passion\z_buffer\48_sfere.z'

y_table:
N set 0
 rept	200
  dc.w	N
N set N+160
 endr

x_table:
N set 0
 rept	20
  dc.w	N,$0000,N,$0100,N,$0200,N,$0300 ; Offset and skew.
  dc.w	N,$0400,N,$0500,N,$0600,N,$0700
  dc.w	N,$0800,N,$0900,N,$0a00,N,$0b00
  dc.w	N,$0c00,N,$0d00,N,$0e00,N,$0f00
N set N+8
 endr

z_y_table:
N set 0
 rept	144
  dc.w	N
N set N+192
 endr

colors:
  dc.w	$000,$111,$222,$333
  dc.w	$444,$555,$666,$777
  dc.w	$0,$1,$2,$3,$4,$5,$6,$7

z_pos:
  dc.w	20
z_pos_inc:
  dc.w	1
  
; *************************************************************************
 Section BSS

sprite96:		; The 96*96 sfere as a 112*96 3 planes
  ds.w	112*96*3/16	; sprite.

big_ztable:		; The z of the 96*96 sfere are in the
  ds.b	192*192	; middle of this big ztable.
  
mask48:		; Space for the mask calculated using
  ds.w	54*48*3/16	; z buffer and then for masked 48*48
		; sfere as a 64*48 3 planes sprite.
  ds.w	1000
screen1:
  ds.b	32000
screen2:
  ds.b	32000

old_box1:		; Coords of the box which contain the cube.
  ds.w	4
old_box2:		; The same for vbl2.
  ds.w	4

old_vbl:		; All the parameters for screen,
  ds.l	1	; and interrupts...
old_timerc:
  ds.l	1
old_conterm:
  ds.w	1 
old_rez:
  ds.w	1
old_screen:
  ds.l	1

sferes_pos:
  ds.w	5

t_parameter:
  ds.w	1
t_parameter2:
  ds.w	1
  