; ************************************************************************
; *****                                                              *****
; *****	 	SCROLLTEXT ZOOMER	     *****
; *****                                                              *****
; ************************************************************************
; *****                 One plane textscroller zoomer.               *****
; *****                       By Alain BROBECKER.                    *****
; *****       Coded between 12th and 14th of June 1994.(Slowly)      *****
; ************************************************************************

nb_points	equ 120
dist	equ 256
dist2	equ 8

supervisor:
  move.l	#$0,-(sp)
  move.w	#$20,-(sp)
  trap	#$1	; User mode is shit....
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
  move.b	#$0,$ffff8260.w ; Low res rules.

  move.l	#colors,a0
  move.w	#$8240,a1
 rept	8
  move.l	(a0)+,(a1)+
 endr
 
; ************************************************************************
; ************************************************************************

convert_text:
  move.l	#text,a0
  move.l	#conv_text,a1
  move.l	#fonts,a2
  moveq.l	#$0,d0	; d0=nb of v_lines.
.conv_one_char:
  moveq.l	#$0,d1
  move.b	(a0)+,d1
  beq.s	.end_conv
  sub.w	#$41,d1	; Fucking ASCII table...
  add.w	d1,d1
  add.w	d1,d1
  move.l	a2,a3
  adda.l	(a2,d1.w),a3	; a3 points on this letter.
  moveq.l	#$5,d1	; 6 v_lines to copy.
.one_v_line:
  move.w	(a3)+,d2	; d2=nb_boxes.
  move.w	d2,(a1)+
.one_box:
  cmp.w	#$0,d2
  beq.s	.end_v_line
  move.w	(a3)+,(a1)+	; Copy the box coords.
  move.w	(a3)+,(a1)+
  sub.w	#$1,d2
  bra.s	.one_box
.end_v_line:
  addq.l	#$1,d0	; One v_line more.
  dbra	d1,.one_v_line
  bra.s	.conv_one_char
.end_conv:

  move.l	d0,d7	; Nb of v lines.
  sub.l	#nb_points,d7
  move.l	#conv_text,a6	; The text.

  move.w	#$ffff,$ffff8a2a.w ; Endmask 2 always set.
  move.w	#0,z_pos
  move.w	#$10,z_inc
    
vbl_one:
  jsr	wait_vbl
  move.l	#screen1,a0	; Ramvideo adress.

  move.w	#$002,$ffff8240.w
  
.clear_old:		; Clear the screen.
  move.w	#$ffff,$ffff8a28.w ; Endmasks 1 & 3 set.
  move.w	#$ffff,$ffff8a2c.w
  move.l	#$80008,$ffff8a2e.w ; Dest x & y increments.
  move.l	a0,$ffff8a32.w	; Dest adress.
  add.l	#50*160,$ffff8a32.w ; Max height is 100 lines.
  move.l	#$140064,$ffff8a36.w ; 20 words per line and 100 lines.
  move.w	#$000,$ffff8a3a.w ; Fill with zeroes.
  move.b	#$c0,$ffff8a3c.w ; Clear the screen.
  
.calculate:
  move.w	#nb_points,d0
  subq.w	#$1,d0	; Beware the dbra.
  move.l	#points,a1
  move.l	#new_points,a2
  move.w	z_pos,d1
  add.w	#dist,d1	; d1=dist+z_pos
  move.l	#65536,d2
  divs.w	d1,d2	; d2=65536/(dist+z_pos).
.one_point:    
  move.w	(a1)+,d1
  muls.w	d2,d1	; d1=y*65536/(dist+z_pos).
  lsr.l	#dist2,d1	; d1=y*dist/(dist+z_pos).
  move.w	d1,(a2)+
  dbra	d0,.one_point

.next_z:
  move.w	z_pos,d1
  move.w	z_inc,d2
  add.w	d2,d1	; z_pos=z_pos+z_inc.
  cmp.w	#0,d1	; z_pos=0?
  bne.s	.z_ok1
  neg.w	d2	; Then inc=-inc.
.z_ok1:
  cmp.w	#1024,d1	; z_pos=1024?
  bne.s	.z_ok2
  neg.w	d2	; Then inc=-inc.
.z_ok2:
  move.w	d1,z_pos
  move.w	d2,z_inc
  
  move.w	#$20f,$ffff8a3a.w ; Fill with ones.

.print:
  move.w	#nb_points,d6	; Nb of v_lines to draw. 
  subq.w	#$1,d6
  move.l	#new_points,a1
  move.l	a1,a2
  add.w	#114,a2	; a2 for the y.
  move.l	a6,a3	; a3 points on the text.
.one_v_line:
  move.w	(a1)+,d0	; x1.
  move.w	(a1),d2	; x2.
  add.w	#159,d0	; Re centering.
  add.w	#159,d2
  move.w	(a3)+,d4	; d4=nb_boxes.
.one_box:
  cmp.w	#$0,d4
  beq.s	.end_v_line
  move.w	(a3)+,d1
  add.w	d1,d1
  move.w	(a2,d1.w),d1	; d1=y1.
  move.w	(a3)+,d3
  add.w	d3,d3
  move.w	(a2,d3.w),d3	; d3=y2.
  add.w	#99,d1	; Recentering.
  add.w	#99,d3
  jsr	print_box
  subq.w	#$1,d4
  bra.s	.one_box
.end_v_line:
  dbra	d6,.one_v_line

.scroll_it:
  move.w	(a6)+,d0
  add.w	d0,d0
  add.w	d0,d0
  add.w	d0,a6
  subq.w	#$1,d7	; Scrolled of one v_line.

  move.l	a0,d0
  move.l	d0,d1
  swap.w	d0
  move.b	d0,$ffff8201.w
  swap.w	d0
  lsr.w	#$8,d0
  move.b	d0,$ffff8203.w
  move.b	d1,$ffff820d.w

  move.w	#$000,$ffff8240.w
  	    
vbl_two:
  jsr	wait_vbl
  move.l	#screen2,a0	; Ramvideo adress.

  move.w	#$002,$ffff8240.w

.clear_old:		; Clear the screen.
  move.w	#$ffff,$ffff8a28.w ; Endmasks 1 & 3 set.
  move.w	#$ffff,$ffff8a2c.w
  move.l	#$80008,$ffff8a2e.w ; Dest x & y increments.
  move.l	a0,$ffff8a32.w	; Dest adress.
  add.l	#50*160,$ffff8a32.w ; Max height is 100 lines.
  move.l	#$140064,$ffff8a36.w ; 20 words per line and 100 lines.
  move.w	#$000,$ffff8a3a.w ; Fill with zeroes.
  move.b	#$c0,$ffff8a3c.w ; Clear the screen.
  
.calculate:
  move.w	#nb_points,d0
  subq.w	#$1,d0	; Beware the dbra.
  move.l	#points,a1
  move.l	#new_points,a2
  move.w	z_pos,d1
  add.w	#dist,d1	; d1=dist+z_pos
  move.l	#65536,d2
  divs.w	d1,d2	; d2=65536/(dist+z_pos).
.one_point:    
  move.w	(a1)+,d1
  muls.w	d2,d1	; d1=y*65536/(dist+z_pos).
  lsr.l	#dist2,d1	; d1=y*dist/(dist+z_pos).
  move.w	d1,(a2)+
  dbra	d0,.one_point

.next_z:
  move.w	z_pos,d1
  move.w	z_inc,d2
  add.w	d2,d1	; z_pos=z_pos+z_inc.
  cmp.w	#0,d1	; z_pos=0?
  bne.s	.z_ok1
  neg.w	d2	; Then inc=-inc.
.z_ok1:
  cmp.w	#1024,d1	; z_pos=1024?
  bne.s	.z_ok2
  neg.w	d2	; Then inc=-inc.
.z_ok2:
  move.w	d1,z_pos
  move.w	d2,z_inc

  move.w	#$20f,$ffff8a3a.w ; Fill with ones.
  
.print:
  move.w	#nb_points,d6	; Nb of v_lines to draw. 
  subq.w	#$1,d6
  move.l	#new_points,a1
  move.l	a1,a2
  add.w	#114,a2	; a2 for the y.
  move.l	a6,a3	; a3 points on the text.
.one_v_line:
  move.w	(a1)+,d0	; x1.
  move.w	(a1),d2	; x2.
  add.w	#159,d0	; Re centering.
  add.w	#159,d2
  move.w	(a3)+,d4	; d4=nb_boxes.
.one_box:
  cmp.w	#$0,d4
  beq.s	.end_v_line
  move.w	(a3)+,d1
  add.w	d1,d1
  move.w	(a2,d1.w),d1	; d1=y1.
  move.w	(a3)+,d3
  add.w	d3,d3
  move.w	(a2,d3.w),d3	; d3=y2.
  add.w	#99,d1	; Recentering.
  add.w	#99,d3
  jsr	print_box
  subq.w	#$1,d4
  bra.s	.one_box
.end_v_line:
  dbra	d6,.one_v_line

.scroll_it:
  move.w	(a6)+,d0
  add.w	d0,d0
  add.w	d0,d0
  add.w	d0,a6
  subq.w	#$1,d7	; Scrolled of one v_line.

  move.l	a0,d0
  move.l	d0,d1
  swap.w	d0
  move.b	d0,$ffff8201.w
  swap.w	d0
  lsr.w	#$8,d0
  move.b	d0,$ffff8203.w
  move.b	d1,$ffff820d.w

  move.w	#$000,$ffff8240.w
  
  cmp.w	#$0,d7	; It was the last v_line?
  bge	vbl_one

; ************************************************************************
; ************************************************************************
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

; ************************************************************************
wait_vbl:
  move.w	d0,-(sp)
  move.w	$468.w,d0
.wait:
  cmp.w	$468.w,d0
  beq.s	.wait
  move.w	(sp)+,d0
  rts

; ************************************************************************
; The interesting routine.

print_box:
  include	'..\scr_zoom\box.s'
      
; ************************************************************************
  Section DATA

colors:
  dc.w	$000,$445,$000,$000
  dc.w	$000,$000,$000,$000
  dc.w	$000,$000,$000,$000
  dc.w	$000,$000,$000,$000
  
text:
  dc.b	'[[[[[[[[[[[[[[[[POSITIVITY[[WELCOMES[[YOU[[[[[[[[[[[[[HOPE[[YOU[[LIKE[[THIS[[DEMO[[[[[[[[[[[[[[[[[[',0

 even

fonts:
  incbin	'..\scr_zoom\fonts.xxx'

points:
N set -(nb_points*8)
 rept	nb_points
  dc.w	N
N set N+16
 endr

; ************************************************************************
  Section BSS

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

screen1:
  ds.b	32000

screen2:
  ds.b	32000

z_pos:		; The z position of the whole text.
  ds.w	1
  
z_inc:		; The increment for the z_pos.
  ds.w	1 

new_points:
  ds.w	nb_points
  
conv_text:
  ds.b	32000