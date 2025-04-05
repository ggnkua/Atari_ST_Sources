; *************************************************************************
; ****				       ****
; ****		Texture Mapped cube.	       ****
; ****	     	 By Alain BROBECKER	       ****
; ****	     Coded Between 27th and 29th of june 1994.	       ****
; ****				       ****
; *************************************************************************
nb_brows	equ 8

  pea	text
  move.w	#$9,-(sp)
  trap	#$1
  addq.l	#$6,sp

supervisor:
  move.l	#$0,-(sp)
  move.w	#$20,-(sp)
  trap	#$1
  addq.l	#$6,sp

.wait_key:
  jsr	wait_vbl
  cmpi.b	#$b9,$fffffc02.w
  bne.s	.wait_key
  
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
  move.b	$ffff8201.w,old_screen
  move.b	$ffff8203.w,old_screen+1
  move.b	$ffff820d.w,old_screen+2

  move.l	#screen1,d0
  move.l	d0,d1
  swap.w	d0
  move.b	d0,$ffff8201.w
  swap.w	d0
  rol.w	#$8,d0
  move.b	d0,$ffff8203.w
  move.b	d1,$ffff820d.w
  
; *************************************************************************
	
  move.l	#$0,$466.w

re_begin:
  clr.w	angle1
  move.w	#$2,angle2
  clr.w	x_mov_pos
  move.w	#250,y_pos
  
vbl_one:
  jsr	wait_vbl
  move.l	#screen1,a6

  cmpi.b	#$38,$fffffc02.w
  bne.s	.oh_no
  move.l	#$4f004f4f,$ffff9800
.oh_no:
  
.clear_box:
  move.l	a6,a0
  move.l	#old_box1,a1
  move.w	(a1)+,d0	; Extremities of the box to clear.
  move.w	(a1)+,d1
  move.w	(a1)+,d2
  move.w	(a1)+,d3
  jsr	clear_4_bpl

.angles:
  subq.w	#$1,y_pos
  move.w	angle1,d0
  addq.w	#$1,d0
  and.w	#$ff,d0
  move.w	d0,angle1
  move.w	angle2,d1
  addq.w	#$2,d1
  and.w	#$ff,d1
  move.w	d1,angle2

.rotation:
  move.l	#object_brows,a0
  move.l	#new_coords,a1
  jsr	rotation

.calc_depth:
  move.l	#new_coords,a0
  move.l	a0,a1
  moveq.l	#nb_brows,d0
  subq.w	#$1,d0
  move.l	#x_movements,a2	; For x recentering.
  move.w	x_mov_pos,d6
  add.w	d6,a2
  addq.w	#$2,d6	; Next x_mov.
  cmp.w	#84,d6
  blt.s	.x_mov_ok
  moveq.l	#$0,d6
.x_mov_ok:
  move.w	d6,x_mov_pos
  move.w	(a2),d6
  move.w	y_pos,d7	; For y recentering.
  move.l	#inverses,a2
.one_brow:
  move.w	(a0)+,d1	; d1=x.
  move.w	(a0)+,d2	; d2=y.
  move.w	(a0)+,d3	; d3=z.
  add.w	#$100,d3	; d3=z+256.
  add.w	d3,d3
  move.w	(a2,d3.w),d3	; d3=16384/(z+256).
  muls.w	d3,d1
  lsr.l	#$6,d1	; d1=x*256/(z+256).
  add.w	d6,d1	; Recenter.
  move.w	d1,(a1)+	; Save.
  muls.w	d3,d2
  lsr.l	#$6,d2	; d2=y*256/(z+256).
  add.w	d7,d2	; Recenter.
  move.w	d2,(a1)+	; Save.
  dbra	d0,.one_brow
  
.search_box:
  move.l	#new_coords,a0
  move.w	(a0)+,d0
  move.w	d0,d1	; x1=x2=first x.
  move.w	(a0)+,d2
  move.w	d2,d3	; y1=y2=first y.
  moveq.l	#nb_brows,d7
  subq.l	#$2,d7
.search:
  move.w	(a0)+,d4	; d4=x.
  move.w	(a0)+,d5	; d5=y.
  cmp.w	d0,d4	; x<x1?
  bge.s	.no_x1
  move.w	d4,d0
.no_x1:
  cmp.w	d1,d4	; x>x2?
  ble.s	.no_x2
  move.w	d4,d1
.no_x2:
  cmp.w	d2,d5	; y<y1?
  bge.s	.no_y1
  move.w	d5,d2
.no_y1:
  cmp.w	d3,d5	; y>y2?
  ble.s	.no_y2
  move.w	d5,d3
.no_y2:
  dbra	d7,.search
  move.l	#old_box1,a0
  addq.w	#$1,d3
  movem.w	d0-3,(a0)	; Save the box.

.print_cube:
  move.l	a6,a0
  move.l	#faces_adr,a5
  move.l	#object_faces,a4
  move.l	#new_coords,a3
  move.w	(a4)+,d7	; Nb of faces.
  subq.w	#$1,d7
.one_face:
  moveq.w	#$4,d6	; Always 4 points per face.
  move.w	d6,d0
  move.l	#face_coords,a1
.copy_coords:
  move.w	(a4)+,d1	; Nb of the brow.
  move.l	(a3,d1.w),(a1)+	; Copy x and y.
  move.l	#$0,(a1)+	; x&y of source1.
  move.w	(a4)+,d1	; Nb of the brow.
  move.l	(a3,d1.w),(a1)+	; Copy x and y.
  move.l	#$7f,(a1)+	; x&y of source2.
  move.w	(a4)+,d1	; Nb of the brow.
  move.l	(a3,d1.w),(a1)+	; Copy x and y.
  move.l	#$7f007f,(a1)+	; x&y of source3.
  move.w	(a4)+,d1	; Nb of the brow.
  move.l	(a3,d1.w),(a1)+	; Copy x and y.
  move.l	#$7f0000,(a1)+	; x&y of source4.
.test_visibility:
  move.l	#face_coords,a1
  move.w	(a1)+,d1	; x1.
  move.w	(a1)+,d2	; y1.
  addq.w	#$4,a1
  move.w	(a1)+,d3	; x2.
  move.w	(a1)+,d4	; y2.
  addq.w	#$4,a1
  move.w	(a1)+,d5	; x3.
  move.w	(a1)+,d6	; y3.
  sub.w	d3,d1	; d1=x1-x2.
  sub.w	d4,d2	; d2=y1-y2.
  sub.w	d3,d5	; d5=x3-x2.
  sub.w	d4,d6	; d6=y3-y2.
  muls.w	d1,d6
  muls.w	d2,d5
  move.l	(a5)+,a2
  sub.l	d5,d6	; d6=(x1-x2)*(y3-y2)-(y1-y2)*(x3-x2).
  ble.s	.next_face
.visible:
  move.l	#face_coords,a1
  jsr	mapped_poly
.next_face:
  dbra	d7,.one_face

  cmpi.b	#$38,$fffffc02.w
  bne.s	.oh_no2
  move.l	#$2f002f2f,$ffff9800
.oh_no2:

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

  cmpi.b	#$38,$fffffc02.w
  bne.s	.oh_no
  move.l	#$4f004f4f,$ffff9800
.oh_no:

.clear_box:
  move.l	a6,a0
  move.l	#old_box2,a1
  move.w	(a1)+,d0	; Extremities of the box to clear.
  move.w	(a1)+,d1
  move.w	(a1)+,d2
  move.w	(a1)+,d3
  jsr	clear_4_bpl

.angles:
  subq.w	#$1,y_pos
  move.w	angle1,d0
  addq.w	#$1,d0
  and.w	#$ff,d0
  move.w	d0,angle1
  move.w	angle2,d1
  addq.w	#$2,d1
  and.w	#$ff,d1
  move.w	d1,angle2

.rotation:
  move.l	#object_brows,a0
  move.l	#new_coords,a1
  jsr	rotation

.calc_depth:
  move.l	#new_coords,a0
  move.l	a0,a1
  moveq.l	#nb_brows,d0
  subq.w	#$1,d0
  move.l	#x_movements,a2	; For x recentering.
  move.w	x_mov_pos,d6
  add.w	d6,a2
  addq.w	#$2,d6	; Next x_mov.
  cmp.w	#84,d6
  blt.s	.x_mov_ok
  moveq.l	#$0,d6
.x_mov_ok:
  move.w	d6,x_mov_pos
  move.w	(a2),d6
  move.w	y_pos,d7	; For y recentering.
  move.l	#inverses,a2
.one_brow:
  move.w	(a0)+,d1	; d1=x.
  move.w	(a0)+,d2	; d2=y.
  move.w	(a0)+,d3	; d3=z.
  add.w	#$100,d3	; d3=z+256.
  add.w	d3,d3
  move.w	(a2,d3.w),d3	; d3=16384/(z+256).
  muls.w	d3,d1
  lsr.l	#$6,d1	; d1=x*256/(z+256).
  add.w	d6,d1	; Recenter.
  move.w	d1,(a1)+	; Save.
  muls.w	d3,d2
  lsr.l	#$6,d2	; d2=y*256/(z+256).
  add.w	d7,d2	; Recenter.
  move.w	d2,(a1)+	; Save.
  dbra	d0,.one_brow
  
.search_box:
  move.l	#new_coords,a0
  move.w	(a0)+,d0
  move.w	d0,d1	; x1=x2=first x.
  move.w	(a0)+,d2
  move.w	d2,d3	; y1=y2=first y.
  moveq.l	#nb_brows,d7
  subq.l	#$2,d7
.search:
  move.w	(a0)+,d4	; d4=x.
  move.w	(a0)+,d5	; d5=y.
  cmp.w	d0,d4	; x<x1?
  bge.s	.no_x1
  move.w	d4,d0
.no_x1:
  cmp.w	d1,d4	; x>x2?
  ble.s	.no_x2
  move.w	d4,d1
.no_x2:
  cmp.w	d2,d5	; y<y1?
  bge.s	.no_y1
  move.w	d5,d2
.no_y1:
  cmp.w	d3,d5	; y>y2?
  ble.s	.no_y2
  move.w	d5,d3
.no_y2:
  dbra	d7,.search
  move.l	#old_box2,a0
  addq.w	#$1,d3
  movem.w	d0-3,(a0)	; Save the box.

.print_cube:
  move.l	a6,a0
  move.l	#faces_adr,a5
  move.l	#object_faces,a4
  move.l	#new_coords,a3
  move.w	(a4)+,d7	; Nb of faces.
  subq.w	#$1,d7
.one_face:
  moveq.w	#$4,d6	; Always 4 points per face.
  move.w	d6,d0
  move.l	#face_coords,a1
.copy_coords:
  move.w	(a4)+,d1	; Nb of the brow.
  move.l	(a3,d1.w),(a1)+	; Copy x and y.
  move.l	#$0,(a1)+	; x&y of source1.
  move.w	(a4)+,d1	; Nb of the brow.
  move.l	(a3,d1.w),(a1)+	; Copy x and y.
  move.l	#$7f,(a1)+	; x&y of source2.
  move.w	(a4)+,d1	; Nb of the brow.
  move.l	(a3,d1.w),(a1)+	; Copy x and y.
  move.l	#$7f007f,(a1)+	; x&y of source3.
  move.w	(a4)+,d1	; Nb of the brow.
  move.l	(a3,d1.w),(a1)+	; Copy x and y.
  move.l	#$7f0000,(a1)+	; x&y of source4.
.test_visibility:
  move.l		#face_coords,a1
  move.w	(a1)+,d1	; x1.
  move.w	(a1)+,d2	; y1.
  addq.w	#$4,a1
  move.w	(a1)+,d3	; x2.
  move.w	(a1)+,d4	; y2.
  addq.w	#$4,a1
  move.w	(a1)+,d5	; x3.
  move.w	(a1)+,d6	; y3.
  sub.w	d3,d1	; d1=x1-x2.
  sub.w	d4,d2	; d2=y1-y2.
  sub.w	d3,d5	; d5=x3-x2.
  sub.w	d4,d6	; d6=y3-y2.
  muls.w	d1,d6
  muls.w	d2,d5
  move.l	(a5)+,a2
  sub.l	d5,d6	; d6=(x1-x2)*(y3-y2)-(y1-y2)*(x3-x2).
  ble.s	.next_face
.visible:
  move.l	#face_coords,a1
  jsr	mapped_poly
.next_face:
  dbra	d7,.one_face

  cmpi.b	#$38,$fffffc02.w
  bne.s	.oh_no2
  move.l	#$2f002f2f,$ffff9800
.oh_no2:

  move.l	a6,d0
  move.l	d0,d1
  swap.w	d0
  move.b	d0,$ffff8201.w
  swap.w	d0
  rol.w	#$8,d0
  move.b	d0,$ffff8203.w
  move.b	d1,$ffff820d.w

  move.w	y_pos,d0
  cmp.w	#-50,d0
  bgt.s	continue
  bra	re_begin
  
continue:  
  cmpi.b	#$39,$fffffc02.w
  bne	vbl_one

; ************************************************************************

the_end:
  move.w	#$25,-(sp) 
  trap	#$e	; Vsync
  addq.l	#$2,sp

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
  move.l	$466.w,d0
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
  move.w	#$2,$ffff8a2e.w ; Dest x inc.
  move.l	#y_table,a1	
  add.l	(a1,d2.w*4),a0	; a0 points on good line.
  add.w	d0,a0
  add.w	d0,a0	; a0 points on good word.
  move.l	a0,$ffff8a32.w	; Dest adress.
  moveq.l	#-1,d0
  move.l	d0,$ffff8a28.w	; Endmasks set to ones.
  move.w	d0,$ffff8a2c.w
  move.w	#$200,$ffff8a3a.w ; Fill with zeroes.

  sub.w	d0,d1	; d1=x2-x1=dx.
  lsr.w	#$1,d1
  move.w	#640,d3
  add.w	d1,d1
  sub.w	d1,d3
  move.w	d3,$ffff8a30.w	; Dest y inc.
  lsr.w	#1,d1
  addq.w	#$1,d1
  move.w	d1,$ffff8a36.w	; Words per line.
  move.b	#$c0,$ffff8a3c.w
  movem.l	(sp)+,d0-3/a0-1
  rts

; *************************************************************************
; The interesting routines.

rotation:
  include	'rotation.s'

  Section TEXT
  
mapped_poly:
  include	'map.s'
    
; *************************************************************************
  Section DATA

object_brows:		; Definition of the cube.
  dc.w	4,28*256
  dc.w	28*256,28*256
  dc.w	-28*256,28*256
  dc.w	-28*256,-28*256
  dc.w	28*256,-28*256
  dc.w	4,-28*256
  dc.w	28*256,28*256
  dc.w	-28*256,28*256
  dc.w	-28*256,-28*256
  dc.w	28*256,-28*256
  dc.w	0

object_faces:
  dc.w	6	; 6 faces, Clockwise cycle.
  dc.w	0*4,1*4,2*4,3*4
  dc.w	0*4,3*4,7*4,4*4
  dc.w	0*4,4*4,5*4,1*4
  dc.w	6*4,7*4,3*4,2*4
  dc.w	4*4,7*4,6*4,5*4
  dc.w	1*4,5*4,6*4,2*4

y_table:		; Convert y->y*160.
N set 0
 rept	200
  dc.l	N
N set N+640
 endr

inverses:
  incbin	'inverses.xxx'

x_movements:
  incbin	'x_mov.xxx'
  
y_pos:
  dc.w	250

zoom:
  dc.w	70
zoom_inc:
  dc.w	4
angle:
  dc.w	0
angle_inc:
  dc.w	7

sinus2:
  incbin	'sinus_2.xxx' 

faces_adr:
  dc.l	img1,img2,img3,img4,img5,img6
  
img1:
  incbin	im1.tc
img2:
  incbin	im2.tc
img3:
  incbin	im3.tc
img4:
  incbin	im4.tc
img5:
  incbin	im5.tc
img6:
  incbin	im6.tc
  
angle1:		; Well...
  dc.w	0
angle2:
  dc.w	2  

text:
  dc.b	27,'E'
 dc.b '            Kooookoooooo !',$d,$a
 dc.b $d,$a
 dc.b ' Positivity present you its 1st little-',$d,$a
 dc.b '  mini-micro-pico-nano Falcon screen:',$d,$a
 dc.b $d,$a
 dc.b '      "Mama was a FUZION" (Arf!)',$d,$a
 dc.b $d,$a 
 dc.b ' This screen is shit coz it is a mere',$d,$a
 dc.b ' adaptation of my STe mapping, it was',$d,$a
 dc.b ' converted in 2~3 hours and it''s not',$d,$a
 dc.b ' optimised. Also, I don''t know how to',$d,$a
 dc.b ' change the resolution, so change to',$d,$a
 dc.b ' 320*200 TrueColor before running this.',$d,$a
 dc.b $d,$a
 dc.b ' Moral support (and asskicks) by Kasar.',$d,$a
 dc.b '     Code and Cookies by Dracula.',$d,$a
 dc.b '       Images by Boris Valejo.',$d,$a
 dc.b '          Music by DeafMan.',$d,$a
 dc.b '           Falcon by Kasar',$d,$a
 dc.b '     Kasar by Charly and Christiane',$d,$a
 dc.b '   DSP Code by "Sorry it''s too hard".',$d,$a
 dc.b $d,$a
 dc.b '   Hi to "les demomakers boutonneux".',$d,$a
 dc.b '  Press alt to be disgusted Maxx-Out.',$d,$a
 dc.b '             (Hey, joke!)',0
 
; *************************************************************************
  Section BSS


new_coords:		; Coords after rotation.
  ds.w	21*4
face_coords:
  ds.w	21*4
  ds.w	21*4
  ds.w	21*4
  
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
old_screen:
  ds.l	1

x_mov_pos:
  ds.w	1

source_pos:
  ds.l	4
  

screen1:
  ds.b	640*200*2
screen2:
  ds.b	640*200*2

  