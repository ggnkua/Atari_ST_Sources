; *************************************************************************
; *****				      *****
; *****	      Totally Realtime Rotative Zoomer.	      *****
; *****				      *****
; *************************************************************************
; *****	             By Alain BROBECKER.	      *****
; *****        Coded on 20th and 21st of June 1994. (No hurry.)       *****
; *************************************************************************

time	equ 1599
xmid_end	equ 224
ymid_end	equ 192
zoom_end	equ 128
rotation_end	equ 512
loop	equ 24

supervisor_mode:
  move.l	#$0,-(sp)
  move.w	#$20,-(sp)
  trap	#$1	; Fucking user mode...
  addq.l	#$6,sp

fuck_system:
  dc.w	$a00a	; The cat was here...
  move.b	#$12,$fffffc02.w
  bchg.b	#$5,$fffffa09.w	; Disable timerc.
  
.save_old_features:	; Save the screen coords and co.
  move.b	$ffff8201.w,old_screen
  move.b	$ffff8203.w,old_screen+1
  move.b	$ffff820d.w,old_screen+2
  move.b	$ffff8260.w,old_screen+3

  jsr	wait_vbl
  move.b	#$0,$ffff8260.w	; Low resolution.
  move.l	#colors,a0	; The good colors.
  move.w	#$8240,a1
 rept	8
  move.l	(a0)+,(a1)+
 endr
 
; *************************************************************************

  jsr	planar_2_linear	; Convert the image.

; *************************************************************************

  move.l	#$0,$466.w
  
vbl_one:
  jsr	wait_vbl
  move.l	#screen1,a0

.xmid:
  move.w	xmid_pos,d0	; Position in the table.
  addq.w	#$1,d0
  cmp.w	#xmid_end,d0	; The end is reached?
  bne.s	.xmid_ok
  moveq.l	#loop,d0	; Then loop.
.xmid_ok:
  move.w	d0,xmid_pos
  add.w	d0,d0
  move.l	#xmid,a1
  move.w	(a1,d0.w),d0	; d0=xmid.

.ymid:
  move.w	ymid_pos,d1	; Position in the table.
  addq.w	#$1,d1
  cmp.w	#ymid_end,d1	; The end is reached?
  bne.s	.ymid_ok
  moveq.l	#loop,d1	; Then loop.
.ymid_ok:
  move.w	d1,ymid_pos
  add.w	d1,d1
  move.l	#ymid,a1
  move.w	(a1,d1.w),d1	; d1=ymid.

.zoom:
  move.w	zoom_pos,d2	; Position in the table.
  addq.w	#$1,d2
  cmp.w	#zoom_end,d2	; The end is reached?
  bne.s	.zoom_ok
  moveq.l	#loop,d2	; Then loop.
.zoom_ok:
  move.w	d2,zoom_pos
  add.w	d2,d2
  move.l	#zoom,a1
  move.w	(a1,d2.w),d2	; d2=zoom.
  move.w	d2,d3  

.rotation:
  move.w	rotation_pos,d4	; Position in the table.
  addq.w	#$1,d4
  cmp.w	#rotation_end,d4 ; The end is reached?
  bne.s	.rotation_ok
  moveq.l	#loop,d4	; Then loop.
.rotation_ok:
  move.w	d4,rotation_pos
  add.w	d4,d4
  move.l	#rotation,a1
  move.w	(a1,d4.w),d4	; d4=rotation.
  
  jsr	rotative_zoomer	; Go for it.
  
.show_screen:
  move.l	a0,d0
  move.w	d0,d1
  swap.w	d0
  move.b	d0,$ffff8201.w
  swap.w	d0
  ror.w	#$8,d0
  move.b	d0,$ffff8203.w
  move.b	d1,$ffff820d.w

vbl_two:
  jsr	wait_vbl
  move.l	#screen2,a0

.xmid:
  move.w	xmid_pos,d0	; Position in the table.
  addq.w	#$1,d0
  cmp.w	#xmid_end,d0	; The end is reached?
  bne.s	.xmid_ok
  moveq.l	#loop,d0	; Then loop.
.xmid_ok:
  move.w	d0,xmid_pos
  add.w	d0,d0
  move.l	#xmid,a1
  move.w	(a1,d0.w),d0	; d0=xmid.

.ymid:
  move.w	ymid_pos,d1	; Position in the table.
  addq.w	#$1,d1
  cmp.w	#ymid_end,d1	; The end is reached?
  bne.s	.ymid_ok
  moveq.l	#loop,d1	; Then loop.
.ymid_ok:
  move.w	d1,ymid_pos
  add.w	d1,d1
  move.l	#ymid,a1
  move.w	(a1,d1.w),d1	; d1=ymid.

.zoom:
  move.w	zoom_pos,d2	; Position in the table.
  addq.w	#$1,d2
  cmp.w	#zoom_end,d2	; The end is reached?
  bne.s	.zoom_ok
  moveq.l	#loop,d2	; Then loop.
.zoom_ok:
  move.w	d2,zoom_pos
  add.w	d2,d2
  move.l	#zoom,a1
  move.w	(a1,d2.w),d2	; d2=zoom.
  move.w	d2,d3  

.rotation:
  move.w	rotation_pos,d4	; Position in the table.
  addq.w	#$1,d4
  cmp.w	#rotation_end,d4 ; The end is reached?
  bne.s	.rotation_ok
  moveq.l	#loop,d4	; Then loop.
.rotation_ok:
  move.w	d4,rotation_pos
  add.w	d4,d4
  move.l	#rotation,a1
  move.w	(a1,d4.w),d4	; d4=rotation.
  
  jsr	rotative_zoomer	; Go for it.
  
.show_screen:
  move.l	a0,d0
  move.w	d0,d1
  swap.w	d0
  move.b	d0,$ffff8201.w
  swap.w	d0
  ror.w	#$8,d0
  move.b	d0,$ffff8203.w
  move.b	d1,$ffff820d.w

  move.l	$466.w,d0
  cmp.w	#time,d0
  ble	vbl_one

fade_colors:		; Now fade to black.
  move.l	#fade,a0
  moveq.l	#$f,d0	; 16 tables.
.fade_one:
  jsr	wait_vbl
  jsr	wait_vbl
  move.w	#$8240,a1
 rept	8
  move.l	(a0)+,(a1)+
 endr
  dbra	d0,.fade_one

; *************************************************************************
system_friendly:
  jsr	wait_vbl
  move.b	old_screen+3,$ffff8260.w
  move.b	old_screen,$ffff8201.w
  move.b	old_screen+1,$ffff8203.w
  move.b	old_screen+2,$ffff820d.w

  bchg.b	#$5,$fffffa09.w	; Enable timerc.
  dc.w	$a009	; Burp... Indigestion..
  move.b	#$8,$fffffc02.w

  move.w	#$445,$ffff8246.w ; In case of gem.
  move.w	#$445,$ffff825e.w  

  clr.w	-(sp)	; That' s all folks.
  trap	#$1

; *************************************************************************
; *************************************************************************
; *************************************************************************
; Convert the image into linear mode and "expand" it.

planar_2_linear:
  movem.l	d0-d5/a0-a3,-(sp)
  
  move.l	#image,a0
  move.l	a0,a1
  add.l	#10368,a1	; Points on the linear full image.
  move.w	#1295,d0	; 1296 set of 16 pixies.
.one_set:
  movem.w	(a0)+,d1-d4
 rept	16
  add.w	d4,d4	; 1st bitplane
  addx.b	d5,d5	; 1st bit of this pixie.
  add.w	d3,d3	; 2nd plane.
  addx.b	d5,d5
  add.w	d2,d2	; 3rd..
  addx.b	d5,d5
  add.w	d1,d1	; 4th..
  addx.b	d5,d5
  lsl.b	#$4,d5	; Put the color in the upper bits of d5.b
  move.b	d5,(a1)+	; Save it.
 endr
  dbra	d0,.one_set

; Now, we have to copy parts of the linear image up and down of it, so that
; we have the impression there are a lot of images. (an Infinity)
.expand_image:
  move.w	#10368,d0
  move.l	#image,a0	; a0 points before the linear image.
  move.l	a0,a1
  add.w	d0,a1	; a1=linear image.
  move.l	a1,a2
  add.w	d0,a2	; a2=middle of the linear image.
  move.l	a2,a3
  add.w	d0,a3	; a3=just after the linear image.
  subq.w	#$1,d0	; 10368 points to copy.
.copy_one:
  move.b	(a1)+,(a3)+	; Copy after the image.
  move.b	(a2)+,(a0)+	; Copy before the image.
  dbra	d0,.copy_one
   
  movem.l	(sp)+,d0-d5/a0-a3
  rts

; *************************************************************************
; *************************************************************************
; *************************************************************************
; **    Routine which draws the rotated-zoomed image in the 64*64 box.   **
; *************************************************************************
; Parameters:	a0.l = ramvideo adress.
;	d0.w = xmid.
;	d1.w = ymid.
;	d2.w = x_zoom. (Between 128-256).
;	d3.w = y_zoom. ( Between 128-256).
;	d4.w = rotation. (Between 0-511).

rotative_zoomer:
  movem.l	d0-a6,-(sp)

; First, we must know the source point corresponding to each brow of the
; destination image.
.calculate_brows:
  move.l	#sinus,a1
  add.w	d4,d4	; One word per sinus.
  add.w	d4,a1	; a1 points on sin(teta).
  move.w	(a1),d4	; d4=d5=sin(teta).
  move.w	d4,d5
  muls.w	d2,d4	; d4=x_zoom*sin.
  swap.w	d4	; d4=32*x_zoom*sin.
  muls.w	d3,d5	; d5=y_zoom*sin.
  swap.w	d5	; d5=32*y_zoom*sin.
  move.w	$100(a1),d6	; d6=cos(teta).
  muls.w	d6,d2	; d2=x_zoom*cos.
  swap.w	d2	; d2=32*x_zoom*cos.
  muls.w	d6,d3	; d3=y_zoom*cos.
  swap.w	d3	; d3=32*y_zoom*cos.
  move.l	#brows,a1
  move.w	d0,d6
  add.w	d2,d6
  sub.w	d5,d6	; d6=x1=xmid+32*(x_zoom*cos-y_zoom*sin).
  move.w	d1,d7
  add.w	d4,d7
  add.w	d3,d7	; d7=y1=ymid+32*(x_zoom*sin+y_zoom*cos).
  move.w	d6,(a1)+	; Store x1 and y1.
  move.w	d7,(a1)+
  move.w	d0,d6
  sub.w	d2,d6
  sub.w	d5,d6	; d6=x2=xmid+32*(-x_zoom*cos-y_zoom*sin).
  move.w	d1,d7
  sub.w	d4,d7
  add.w	d3,d7	; d7=y2=ymid+32*(-x_zoom*sin+y_zoom*cos).
  move.w	d6,(a1)+	; Store x2 and y2.
  move.w	d7,(a1)+
  move.w	d0,d6
  sub.w	d2,d6
  add.w	d5,d6	; d6=x3=xmid+32*(-x_zoom*cos+y_zoom*sin).
  move.w	d1,d7
  sub.w	d4,d7
  sub.w	d3,d7	; d7=y3=ymid+32*(-x_zoom*sin-y_zoom*cos).
  move.w	d6,(a1)+	; Store x3 and y3.
  move.w	d7,(a1)+
  move.w	d0,d6
  add.w	d2,d6
  add.w	d5,d6	; d6=x4=xmid+32*(x_zoom*cos+y_zoom*sin).
  move.w	d1,d7
  add.w	d4,d7
  sub.w	d3,d7	; d7=y4=ymid+32*(x_zoom*sin-y_zoom*cos).
  move.w	d6,(a1)+	; Store x4 and y4.
  move.w	d7,(a1)+
  
; Then, for each h_line, we have to know the source point corresponding
; to its min & max extremities. We use a linear interpolation.

.min_sourcepos:		; Let' s begin with the min extremities.
  move.l	#brows,a1
  move.l	#pos_table,a2
  move.w	(a1),d0	; d0=x1.
  move.w	$2(a1),d1	; d1=y1.
  move.w	$c(a1),d2	; d2=x4.
  move.w	$e(a1),d4	; d4=y4.
  sub.w	d0,d2	; d2=x4-x1.
  muls.w	#1040,d2	; d2=65536*(x4-x1)/63.
  move.w	d2,d3	; d3=regular part of 65536*(x4-x1)/63.
  swap.w	d2	; d2=integer part of it.

.min_dy:		; Now calculate dy.
  sub.w	d1,d4	; d4=y4-y1.
  muls.w	#1040,d4	; d4=65536*(y4-y1)/63.
  move.w	d4,d5	; d5=regular part of (y4-y1)/63.
  swap.w	d4	; d4=integer part of it.
  moveq.l	#$0,d6	; Errors set to 0 at the beginning.
  moveq.l	#$0,d7
 rept	63	; The linear interpolation.
  move.w	d0,(a2)+	; Store xmin and ymin.
  move.w	d1,(a2)+
  addq.l	#$4,a2	; Space for the xmax.
  add.w	d3,d6	; error1=error1+reg((x4-x1)/63).
  addx.w	d2,d0	; xmin=xmin+int((x4-x1)/63)+eXtend.
  add.w	d5,d7	; error2=error2+reg((y4-y1)/63).
  addx.w	d4,d1	; ymin=ymin+int((y4-y1)/63)+eXtend.
 endr
  move.w	d0,(a2)+	; Store 64th xmin and ymin.
  move.w	d1,(a2)+

.max_sourcepos:		; Continue with the max extremities.
  move.l	#pos_table+$4,a2
  move.w	$4(a1),d0	; d0=x2.
  move.w	$6(a1),d1	; d1=y2.
  move.w	$8(a1),d2	; d2=x3.
  move.w	$a(a1),d4	; d4=y3.
  sub.w	d0,d2	; d2=x3-x2.
  muls.w	#1040,d2	; d2=65536*(x3-x2)/63.
  move.w	d2,d3	; d3=regular part of 65536*(x3-x2)/63.
  swap.w	d2	; d2=integer part of it.

.max_dy:		; Now calculate dy.
  sub.w	d1,d4	; d4=y3-y2.
  muls.w	#1040,d4	; d4=65536*(y3-y2)/63.
  move.w	d4,d5	; d5=regular part of (y3-y2)/63.
  swap.w	d4	; d4=integer part of it.
  moveq.l	#$0,d6	; Errors set to 0 at the beginning.
  moveq.l	#$0,d7
 rept	63	; The linear interpolation.
  move.w	d0,(a2)+	; Store xmax and ymax.
  move.w	d1,(a2)+
  addq.l	#$4,a2	; Space for the xmax.
  add.w	d3,d6	; error1=error1+reg((x3-x2)/63).
  addx.w	d2,d0	; xmax=xmax+int((x3-x2)/63)+eXtend.
  add.w	d5,d7	; error2=error2+reg((y3-y2)/63).
  addx.w	d4,d1	; ymax=ymax+int((y3-y2)/63)+eXtend.
 endr
  move.w	d0,(a2)+	; Store 64th xmax and ymax.
  move.w	d1,(a2)+

; Now, draw each h_line. To know which source pixie to use, we will
; make the same kind of linear interpolations.

  add.w	#10784,a0	; Center a0 in the dest screen.
  move.l	#linear_image,a1
  move.l	#pos_table,a2
  move.w	#63,d0
    
.one_line:
  move.w	d0,-(sp)	; Save the counter.
  move.w	(a2)+,d0	; d0=xmin.
  move.w	(a2)+,d1	; d1=ymin.
  move.w	(a2)+,d2	; d2=xmax.
  move.w	(a2)+,d3	; d3=ymax.
  sub.w	d0,d2	; d2=xmax-xmin.
  muls.w	#1040,d2	; d2=65536*(xmax-xmin)/63.
  sub.w	d1,d3	; d3=ymax-ymin.
  muls.w	#1040,d3	; d3=65536*(ymax-ymin)/63.
  add.w	d1,d1	; One word per y.
  move.l	#y_table,a6
  move.w	(a6,d1.w),d7	; d7=ymin*144.
  add.w	d0,d7	; d7=ymin*144+xmin=offset of 1st pixie.
  move.w	d2,a3	; a3=regular part of dx/63.
  swap.w	d2
  move.w	d2,a4	; a4=integer part of dx/63.
  move.w	d3,a5	; a5=regular part of dy/63.
  swap.w	d3
  add.w	d3,d3	; One word per y.
  move.w	(a6,d3.w),a6	; a6=144*(integer part of dy/63).
  move.l	a2,-(sp)	; Not enough registers.
  move.w	#144,a2
  moveq.l	#$0,d5	; Errors set to 0.
  moveq.l	#$0,d6
  
 rept	16
  move.b	(a1,d7.w),d0	; Pixie to convert.
  add.b	d0,d0	; Convert in bitplanes.
  addx.w	d4,d4
  add.b	d0,d0
  addx.w	d3,d3
  add.b	d0,d0
  addx.w	d2,d2
  add.b	d0,d0
  addx.w	d1,d1
  move.w	a4,d0	; d0=integer part of (dx/63).
  add.w	a3,d5	; error1=error1+regular part of (dx/63).
  addx.w	d0,d7	; offset=offset+(int(dx/63))+eXtend.
  add.w	a5,d6	; error2=error2+regular part of (dy/63).
  dc.w	$6402	; Pass next instruction if carry clear.
  add.w	a2,d7
  add.w	a6,d7	; offset=offset+144*((int(dy/63)+eXtend).
 endr
  movem.w	d1-4,(a0)	; Store the bitplanes.
  addq.l	#$8,a0  

 rept	16
  move.b	(a1,d7.w),d0	; Pixie to convert.
  add.b	d0,d0	; Convert in bitplanes.
  addx.w	d4,d4
  add.b	d0,d0
  addx.w	d3,d3
  add.b	d0,d0
  addx.w	d2,d2
  add.b	d0,d0
  addx.w	d1,d1
  move.w	a4,d0	; d0=integer part of (dx/63).
  add.w	a3,d5	; error1=error1+regular part of (dx/63).
  addx.w	d0,d7	; offset=offset+(int(dx/63))+eXtend.
  add.w	a5,d6	; error2=error2+regular part of (dy/63).
  dc.w	$6402	; Pass next instruction if carry clear.
  add.w	a2,d7
  add.w	a6,d7	; offset=offset+144*((int(dy/63)+eXtend).
 endr
  movem.w	d1-4,(a0)	; Store the bitplanes.
  addq.l	#$8,a0  

 rept	16
  move.b	(a1,d7.w),d0	; Pixie to convert.
  add.b	d0,d0	; Convert in bitplanes.
  addx.w	d4,d4
  add.b	d0,d0
  addx.w	d3,d3
  add.b	d0,d0
  addx.w	d2,d2
  add.b	d0,d0
  addx.w	d1,d1
  move.w	a4,d0	; d0=integer part of (dx/63).
  add.w	a3,d5	; error1=error1+regular part of (dx/63).
  addx.w	d0,d7	; offset=offset+(int(dx/63))+eXtend.
  add.w	a5,d6	; error2=error2+regular part of (dy/63).
  dc.w	$6402	; Pass next instruction if carry clear.
  add.w	a2,d7
  add.w	a6,d7	; offset=offset+144*((int(dy/63)+eXtend).
 endr
  movem.w	d1-4,(a0)	; Store the bitplanes.
  addq.l	#$8,a0  
    
 rept	16
  move.b	(a1,d7.w),d0	; Pixie to convert.
  add.b	d0,d0	; Convert in bitplanes.
  addx.w	d4,d4
  add.b	d0,d0
  addx.w	d3,d3
  add.b	d0,d0
  addx.w	d2,d2
  add.b	d0,d0
  addx.w	d1,d1
  move.w	a4,d0	; d0=integer part of (dx/63).
  add.w	a3,d5	; error1=error1+regular part of (dx/63).
  addx.w	d0,d7	; offset=offset+(int(dx/63))+eXtend.
  add.w	a5,d6	; error2=error2+regular part of (dy/63).
  dc.w	$6402	; Pass next instruction if carry clear.
  add.w	a2,d7
  add.w	a6,d7	; offset=offset+144*((int(dy/63)+eXtend).
 endr
  movem.w	d1-4,(a0)	; Store the bitplanes.
  add.w	#136,a0	; Next line.

  move.l	(sp)+,a2	; Restore the adress of the table.
  move.w	(sp)+,d0	; How many lines?..
  dbra	d0,.one_line      

  movem.l	(sp)+,d0-a6
  rts

; *************************************************************************
wait_vbl:
  move.l	d0,-(sp)
  move.l	$466.w,d0
.wait:
  cmp.l	$466.w,d0
  beq.s	.wait
  move.l	(sp)+,d0
  rts
  
; *************************************************************************
; *************************************************************************
; *************************************************************************
  Section DATA

fade:
  incbin	'..\rotazoom\fade.xxx'
  
xmid:
  incbin	'..\rotazoom\xmid.xxx'
ymid:
  incbin	'..\rotazoom\ymid.xxx'
rotation:
  incbin	'..\rotazoom\rotation.xxx'
zoom:
  incbin	'..\rotazoom\zoom.xxx'

xmid_pos:
  dc.w	0
ymid_pos:
  dc.w	0
rotation_pos:
  dc.w	0
zoom_pos:
  dc.w	0
  
colors:
  dc.w	$000,$776,$754,$743
  dc.w	$732,$621,$067,$037
  dc.w	$007,$004,$772,$760
  dc.w	$740,$745,$723,$777
  
N set -10368		; Table for the conversion y->adress.
 rept	72	; The negative y exist too, so we put
  dc.w	N	; them just before the table.
N set N+144
 endr
y_table:
 rept	216
  dc.w	N
N set N+144
 endr

sinus:
  incbin	'..\rotazoom\sinus.xxx'
    
image:		; This MUST be the last Data.
  incbin	'..\rotazoom\girlie.xxx'
; *************************************************************************
  Section BSS

linear_image:		; And this MUST be the first Bss, so that
  ds.b	31104	; it' s just after image.

brows:
  ds.w	8
  
pos_table:
  ds.w	4*64  

  
screen1:		; Double buffering is it...
  ds.w	16000
screen2:
  ds.w	16000

old_screen:
  ds.l	1  