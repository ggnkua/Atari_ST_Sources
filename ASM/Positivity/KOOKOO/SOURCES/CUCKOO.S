; ************************************************
; **			**
; **             COUCOU BOX demo.	**
; **         By Dracula on july 1993.	**
; **    J'en ai reve, Jhonny ne l'a pas fait.	**
; **			**
; ************************************************


; -------------------------------------------
; |  At first some little initialisations.  |
; -------------------------------------------

main_proggy:
  movem.l	d0-a7,old_registers
user_or_super:		; Determines in which mode we are.
  move.l	#$1,-(sp)
  move.w	#$20,-(sp)
  trap	#$1
  addq.l	#$6,sp
  move.l	d0,proc_mode	; Save the mode.
  cmp.b	#$0,d0
  bne.s	.already_super 	; Are we in user or super?
.switch_super:		; User mode,then switch to super.
  move.l	#$0,-(sp)
  move.w	#$20,-(sp)
  trap	#$1
  addq.l	#$6,sp
.already_super:		; Now we are in super mode.
  move.l	#$ff8240,a0	; At first save the colors.
  move.l	#old_colors,a1
  move.w	#$7,d0
save_one_col:
  move.l	(a0)+,(a1)+
  dbra	d0,save_one_col
  
; **  A nice fade to black for all the colors.  **

fade_to_black:
  moveq.l	#$7,d2	; d2 is the fading index.
.one_fade:  
  move.l	#$ff8240,a0	; Initial colors 
  move.l	#$ff8240,a1	; We will overwrite this old colors.
  move.w	d2,d0	; Fading index.
  moveq.l	#$1,d1	; Change all colors.
  jsr	fading

  rept	3  	; Wait the Vbl 3 times.
  move.w	#$25,-(sp)
  trap	#$e
  addq.l	#$2,sp
  endr
  
  subq.l	#$1,d2	; Decrement the fade.
  cmpi.l	#$0,d2	; Minimum fade already done?
  bpl.s	.one_fade

; **  Now change the screen features.  **

screen_features:
  move.w	#$2,-(sp)	; This xbios fonction returns
  trap	#$e	; the physbase in d0.
  addq.l	#$2,sp
  move.l	d0,old_physbase	; Let's store it.

  move.w	#$3,-(sp)	; This xbios fonction returns
  trap	#$e	; the logbase in d0.
  addq.l	#$2,sp
  move.l	d0,old_logbase
  
  move.w	#$4,-(sp)	; This xbios fonction returns
  trap	#$e	; the resolution in d0.
  addq.l	#$2,sp
  move.w	d0,old_res	
  
  moveq.l	#$0,d0	; Search the sync mode in $ff820a.
  move.b	$ff820a,d0
  move.w	d0,old_sync	; And store it.
  
new_features:
  move.w	#$25,-(sp)	; Wait the vertical sync.
  trap	#$e
  addq.l	#$2,sp
  move.b	#$2,$ff820a	; Then switch sync_mode to 50 Hz,
  move.b	#$0,$ff8260	; and resolution to 320*200.
  
  move.l	#screen1,d0	; Now we calculate the screens adresses,
  and.l	#$ffff00,d0	; and put them in the screen?_ad.
  add.l	#$100,d0
  move.l	d0,screen1_ad
  move.l	#screen2,d0
  and.l	#$ffff00,d0
  add.l	#$100,d0
  move.l	d0,screen2_ad
  	 
  move.l	screen1_ad,a0	; Clear the 2 screens.
  jsr	cls	; As colors are all black, the
  move.l	screen2_ad,a0	; user will see nufing.
  jsr	cls	

; **  Now, the very important part: system flush!  **

save_system:
  move.w	sr,old_sr  
  move.w	#$2700,sr	; Disable all ( maskable ) int.
  move.l	$70,old_vbl	; Save the old vbl rout.
  moveq.l	#$0,d0	; Save IERA and IERB.
  move.b	$fffa07,d0
  lsl.w	#$8,d0
  move.b	$fffa09,d0
  move.w	d0,old_mfp
  
change_int:		; Replace or disable interrupts.
  move.l	#vbl_rout,$70	; Put my own routine.
  move.b	#$00,$fffa07	; Stop the mfp.
  move.b	#$00,$fffa09
  moveq.l	#$0,d0
.set_soundchip
  move.b	d0,$ff8800	; Select register.
  move.b	#$0,$ff8802	; Clear every register between 0-5.
  addq.w	#$1,d0
  cmpi.w	#$6,d0
  bne.s	.set_soundchip
  move.b	#$7,$ff8800	; Register 7: disable tones and noises.
  move.b	#$ff,$ff8802
  move.b	#$08,$ff8800	; Put the volume to 0 on all 3 voices,
  move.b	#$00,$ff8802	; cos there could be a shitty noise.
  move.b	#$09,$ff8800
  move.b	#$00,$ff8802
  move.b	#$0a,$ff8800
  move.b	#$00,$ff8802
  move.w	#$2300,sr	; Inits are finished, so enable int.
  
  move.w	#$1f,d0	; Wait a bit, cos when you switch from 60 Hz
some_vbls:		; to 50 Hz you can have shitty stuff.
  stop	#$2300
  dbra	d0,some_vbls

; ---------------------------------
; |  The real chore of the demo!  |
; ---------------------------------

; *********  First, show the logo.  *********

show_logo:
  move.l	screen1_ad,a0
  stop	#$2300	; Wait the Vbl.
  move.l	a0,d0
  lsr.w	#$8,d0
  move.b	d0,$ff8203	; Mid base of the screen1.
  swap.w	d0
  move.b	d0,$ff8201	; High base.
  add.l	#$33e0,a0	; Adress where to put the logo.
  move.l	#dracula,a1
  move.w	#$26b,d0	; Nb of words in the logo.
.put_logo:
  move.w	(a1)+,(a0)
  addq.l	#$8,a0
  dbra	d0,.put_logo

  move.w	#$0,d0	; d0=color index.
.show_logo:
  stop	#$2300	; Wait the vbl.  
  move.w	d0,$ff8242	; New color.	
  add.w	#$111,d0
  cmpi.w	#$888,d0	; Maximum?	
  bne.s	.show_logo
  stop	#$2300	; Wait the vbl.  
  move.w	#$777,d0
  move.w	d0,$ff8242	; New color.	
  add.w	#$111,d0

.unshow_logo:
  stop	#$2300	; Wait the vbl.  
  stop	#$2300
  stop	#$2300
  stop	#$2300
  sub.w	#$111,d0
  move.w	d0,$ff8242	; New color.	
  cmpi.w	#$0,d0	; Minimum?	
  bne.s	.unshow_logo
  
  move.l	screen1_ad,a0	; Logo part is over, let's clear
  jsr	cls	; the screen again.

  move.w	#$1f,d0	; Wait a bit.
.some_vbls:
  stop	#$2300
  dbra	d0,.some_vbls

; *********  Second part: ATARI logo.  *********

atari_show:
  move.w	#$7,d0	; Put the good colors.
  move.l	#$ff8240,a0
  move.l	#atari_colors,a1
.one_color:
  move.l	(a1)+,(a0)+
  dbra	d0,.one_color
  
  move.w	#$100,d7	; 128 Vbl.
atari_screen1:
  stop	#$2300	; Wait the Vbl.
  move.l	screen1_ad,a6	; a6=adress of screen for the next Vbl.
  move.l	a6,d0	; Put the adress in the shifter.
  lsr.w	#$8,d0
  move.b	d0,$ff8203	; Mid base of the screen.
  swap.w	d0
  move.b	d0,$ff8201	; High base.

.next_bpl:		; Determines which bitplane to use.
  moveq.l	#$0,d0
  move.w	atari_bpl,d0
  addq.l	#$2,d0	; Next bitplane.
  cmpi.b	#$8,d0
  bne.s	.bpl_good
  moveq.l	#$0,d0	; Bitplane 8 is the same as bpl 0.
.bpl_good:
  move.w	d0,atari_bpl	; Save current bpl.
  add.l	d0,a6	; Add bpl to current adress.

.clear_bpl:		; We have to clear the bitplane.  
  move.l	a6,a0
  jsr	clsarea1

.calculate_angles:	; We have to do this.
  move.w	atari_alpha,d0
  addq.w	#$2,d0
  cmpi.w  	#$200,d0
  bmi.s	.alpha_ok
  sub.w  	#$200,d0
.alpha_ok:
  move.w	d0,atari_alpha
  move.w	atari_beta,d1
  addq.w	#$1,d1
  cmpi.w  	#$200,d1
  bmi.s	.beta_ok
  sub.w  	#$200,d1
.beta_ok:
  move.w	d1,atari_beta

.rotate_points:		; Calculate the new coords.
  move.l	#atari_dots,a0	; Adress of initial coords.
  move.l	#new_coords,a1	; ... final ...
  move.w	#$40,a2	; z translation is 0.
  move.w	atari_dots_nb,d2
  jsr	rotate 
   
.draw_lines:		; Now let's draw the lines.
  move.w	atari_lines_nb,d4
  move.l	#atari_lines,a5
  move.l	#new_coords,a4
  move.w	#$9f,d5	; For x centering.
  move.w	#$63,d6	; For y centering.
  subq.w	#$1,d4	; Cos of the dbra.
.one_line:
  move.w	(a5)+,d1	; Index of initial point.
  move.w	(a5)+,d3	; ... final ...
  subq.w	#$1,d1	; We want the position, not the index.
  subq.w	#$1,d3
  add.w	d1,d1	; 4 bytes per point.
  add.w	d1,d1
  add.w	d3,d3
  add.w	d3,d3
  move.w	(a4,d1.w),d0	; x1.
  move.w	$2(a4,d1.w),d1	; y1.
  move.w	(a4,d3.w),d2	; x2.
  move.w	$2(a4,d3.w),d3	; y2.
  add.w	d5,d0	; Re center the points.
  add.w	d6,d1
  add.w	d5,d2
  add.w	d6,d3
  move.l	a6,a0	; Ramvideo adress.
  jsr	fastline
  dbra	d4,.one_line

atari_screen2:
  stop	#$2300	; Wait the Vbl.
  move.l	screen2_ad,a6	; a6=adress of screen for the next Vbl.
  move.l	a6,d0	; Put the adress in the shifter.
  lsr.w	#$8,d0
  move.b	d0,$ff8203	; Mid base of the screen.
  swap.w	d0
  move.b	d0,$ff8201	; High base.

.next_bpl:		; Use same bpl as for screen1.
  moveq.l	#$0,d0
  move.w	atari_bpl,d0
  add.l	d0,a6	; Add bpl to current adress.

.clear_bpl:		; We have to clear the bitplane.  
  move.l	a6,a0
  jsr	clsarea1

.calculate_angles:	; We have to do this.
  move.w	atari_alpha,d0
  addq.w	#$2,d0
  cmpi.w  	#$200,d0
  bmi.s	.alpha_ok
  sub.w  	#$200,d0
.alpha_ok:
  move.w	d0,atari_alpha
  move.w	atari_beta,d1
  addq.w	#$1,d1
  cmpi.w  	#$200,d1
  bmi.s	.beta_ok
  sub.w  	#$200,d1
.beta_ok:
  move.w	d1,atari_beta

.rotate_points:		; Calculate the new coords.
  move.l	#atari_dots,a0	; Adress of initial coords.
  move.l	#new_coords,a1	; ... final ...
  move.w	#$40,a2	; z translation is 0.
  move.w	atari_dots_nb,d2
  jsr	rotate 
   
.draw_lines:		; Now let's draw the lines.
  move.w	atari_lines_nb,d4
  move.l	#atari_lines,a5
  move.l	#new_coords,a4
  move.w	#$9f,d5	; For x centering.
  move.w	#$63,d6	; For y centering.
  subq.w	#$1,d4	; Cos of the dbra.
.one_line:
  move.w	(a5)+,d1	; Index of initial point.
  move.w	(a5)+,d3	; ... final ...
  subq.w	#$1,d1	; We want the position, not the index.
  subq.w	#$1,d3
  add.w	d1,d1	; 4 bytes per point.
  add.w	d1,d1
  add.w	d3,d3
  add.w	d3,d3
  move.w	(a4,d1.w),d0	; x1.
  move.w	$2(a4,d1.w),d1	; y1.
  move.w	(a4,d3.w),d2	; x2.
  move.w	$2(a4,d3.w),d3	; y2.
  add.w	d5,d0	; Re center the points.
  add.w	d6,d1
  add.w	d5,d2
  add.w	d6,d3
  move.l	a6,a0	; Ramvideo adress.
  jsr	fastline
  dbra	d4,.one_line

  dbra	d7,atari_screen1

wait_a_while:		; Immediatly fading is not nice.
  moveq.l	#$1f,d7	; Wait more than one second.
.wait:
  stop	#$2300
  dbra	d7,.wait
    
end_2nd_part:		; 2nd part over, clear the screens.
  moveq.l	#$7,d2	; Let's make a nice fade to black.
.fade_black:  
  move.l	#atari_colors,a0; Initial colors 
  move.l	#$ff8240,a1
  move.w	d2,d0	; Fading index.
  moveq.l	#$1,d1	; Change all colors.
  jsr	fading

  rept	3  	; Wait the Vbl 3 times.
  stop	#$2300
  endr
  
  subq.l	#$1,d2	; Decrement the fade.
  cmpi.l	#$0,d2	; Minimum fade already done?
  bpl.s	.fade_black

  move.l	screen1_ad,a0	; Clear the screens.
  jsr	cls
  move.l	screen2_ad,a0
  jsr	cls

.wait_a_while:		; Immediatly fading is not nice.
  moveq.l	#$1f,d7	; Wait more than one second.
.wait:
  stop	#$2300
  dbra	d7,.wait

; *********  Third part: THE CUBE.  *********

  moveq.l	#$0,d7
box_screen1:		; Change the screen.
  stop	#$2300	; Wait the Vbl.
  move.l	screen1_ad,a6	; a6=adress of screen for the next Vbl.
  move.l	a6,d0	; Put the adress in the shifter.
  lsr.w	#$8,d0
  move.b	d0,$ff8203	; Mid base of the screen.
  swap.w	d0
  move.b	d0,$ff8201	; High base.

.colors:
  cmpi.w	#$8,d7	; Index higher than 7? (7=max fading.)
  bge.s	.clear_screen
  move.l	#box_colors,a0	; Colors which to fade to. 
  move.l	#$ff8240,a1
  move.w	d7,d0	; Fading index.
  moveq.l	#$0,d1	; Change only visible colors.
  jsr	fading
  
.clear_screen:		; Find out what we're doing now!
  move.l	a6,a0    
  jsr	clsarea
  
.calculate_angles:
  move.w	box_alpha,d0
  addq.w	#$2,d0
  cmpi.w  	#$200,d0
  bmi.s	.alpha_ok
  sub.w  	#$200,d0
.alpha_ok:
  move.w	d0,box_alpha
  move.w	box_beta,d1
  subq.w	#$1,d1
  bge.s	.beta_ok
  add.w  	#$200,d1
.beta_ok:
  move.w	d1,box_beta

.rotate_points:		; Calculate the new coords.
  move.l	#box_coords,a0	; Adress of initial coords.
  move.l	#new_coords,a1	; ... final ...
  move.w	#$0,a2	; z translation is 0.
  move.w	box_dots_nb,d2
  jsr	rotate 
  
.show_faces:
  move.w	box_faces_nb,d6	; How many faces?
  move.l	#box_faces,a5
  move.l	#new_coords,a4
.visibility:		; Is the face visible or not?
  move.w	(a5)+,a2	; a2=nb of brows-1.
  move.w	(a5)+,a3	; color.
  move.w	(a5)+,d1	; Index of first point. (*4)
  move.w	(a5)+,d3	; ... 2nd ...
  move.w	(a5)+,d5	; ... 3rd ...
  move.w	(a4,d1.w),d0	; x1.
  move.w	$2(a4,d1.w),d1	; y1.
  move.w	(a4,d3.w),d2	; x2.
  move.w	$2(a4,d3.w),d3	; y2.
  move.w	(a4,d5.w),d4	; x3.
  move.w	$2(a4,d5.w),d5	; y3.
  sub.w	d0,d2	; x2-x1.
  sub.w	d0,d4	; x3-x1.
  sub.w	d1,d3	; y2-y1.
  sub.w	d1,d5	; y3-y1.
  muls.w	d5,d2	; (y3-y1)*(x2-x1).
  muls.w	d4,d3	; (x3-x1)*(y2-y1).
  sub.l	d3,d2	; d2=(1;2)^(1;3).
  bgt.s	.unvisible
.visible:
  move.w	a3,d5
  ext.l	d5
  move.l	a6,a0
  add.l	d5,a0	; Adress where to draw the poly.
  subq.l	#$6,a5	; Beginning of the brows index.
  move.w	a2,d4
  move.l	#face_coords,a3
  move.w	#$9f,d2	; For x centering.
  move.w	#$63,d3	; For y centering.
.copy_coords:
  move.w	(a5)+,d1
  move.w	(a4,d1.w),d0
  move.w	$2(a4,d1.w),d1
  add.w	d2,d0
  add.w	d3,d1
  move.w	d0,(a3)+
  move.w	d1,(a3)+
  dbra	d4,.copy_coords
.draw_poly:
  move.l	#face_coords,a1
  moveq.l	#$0,d0
  move.w	a2,d0
  addq.l	#$1,d0
  jsr	fastpoly
  bra.s	.next_poly 

.unvisible:
  moveq.l	#$0,d0	; Pass all the index for this poly.
  move.w	a2,d0
  subq.l	#$2,d0
  add.w	d0,d0	; One word per point index.
  add.l	d0,a5

.next_poly:
  dbra	d6,.visibility	; Next polygone.

box_screen2:		; Change the screen.
  stop	#$2300	; Wait the Vbl.
  move.l	screen2_ad,a6	; a6=adress of screen for the next Vbl.
  move.l	a6,d0	; Put the adress in the shifter.
  lsr.w	#$8,d0
  move.b	d0,$ff8203	; Mid base of the screen.
  swap.w	d0
  move.b	d0,$ff8201	; High base.

.clear_screen:		; Find out what we're doing now!
  move.l	a6,a0    
  jsr	clsarea

.calculate_angles:
  move.w	box_alpha,d0
  addq.w	#$2,d0
  cmpi.w  	#$200,d0
  bmi.s	.alpha_ok
  sub.w  	#$200,d0
.alpha_ok:
  move.w	d0,box_alpha
  move.w	box_beta,d1
  subq.w	#$1,d1
  bge.s	.beta_ok
  add.w  	#$200,d1
.beta_ok:
  move.w	d1,box_beta
  
.rotate_points:		; Calculate the new coords.
  move.l	#box_coords,a0	; Adress of initial coords.
  move.l	#new_coords,a1	; ... final ...
  move.w	#$0,a2	; z translation is 0.
  move.w	box_dots_nb,d2
  jsr	rotate 
  
.show_faces:
  move.w	box_faces_nb,d6	; How many faces?
  move.l	#box_faces,a5
  move.l	#new_coords,a4
.visibility:		; Is the face visible or not?
  move.w	(a5)+,a2	; a2=nb of brows-1.
  move.w	(a5)+,a3	; color.
  move.w	(a5)+,d1	; Index of first point. (*4)
  move.w	(a5)+,d3	; ... 2nd ...
  move.w	(a5)+,d5	; ... 3rd ...
  move.w	(a4,d1.w),d0	; x1.
  move.w	$2(a4,d1.w),d1	; y1.
  move.w	(a4,d3.w),d2	; x2.
  move.w	$2(a4,d3.w),d3	; y2.
  move.w	(a4,d5.w),d4	; x3.
  move.w	$2(a4,d5.w),d5	; y3.
  sub.w	d0,d2	; x2-x1.
  sub.w	d0,d4	; x3-x1.
  sub.w	d1,d3	; y2-y1.
  sub.w	d1,d5	; y3-y1.
  muls.w	d5,d2	; (y3-y1)*(x2-x1).
  muls.w	d4,d3	; (x3-x1)*(y2-y1).
  sub.l	d3,d2	; d2=(1;2)^(1;3).
  bgt.s	.unvisible
.visible:
  move.w	a3,d5
  ext.l	d5
  move.l	a6,a0
  add.l	d5,a0	; Adress where to draw the poly.
  subq.l	#$6,a5	; Beginning of the brows index.
  move.w	a2,d4
  move.l	#face_coords,a3
  move.w	#$9f,d2	; For x centering.
  move.w	#$63,d3	; For y centering.
.copy_coords:
  move.w	(a5)+,d1
  move.w	(a4,d1.w),d0
  move.w	$2(a4,d1.w),d1
  add.w	d2,d0
  add.w	d3,d1
  move.w	d0,(a3)+
  move.w	d1,(a3)+
  dbra	d4,.copy_coords
.draw_poly:
  move.l	#face_coords,a1
  moveq.l	#$0,d0
  move.w	a2,d0
  addq.l	#$1,d0
  jsr	fastpoly
  bra.s	.next_poly 

.unvisible:
  moveq.l	#$0,d0	; Pass all the index for this poly.
  move.w	a2,d0
  subq.l	#$2,d0
  add.w	d0,d0	; One word per point index.
  add.l	d0,a5

.next_poly:
  dbra	d6,.visibility	; Next polygone.

  addq.l	#$1,d7
  cmpi.w	#$100,d7
  bne	box_screen1    
 
; *********  Fourth part: COUCOU BOX.  *********


copy_screen:
  move.w	#$7cff,d0	; Copy screen2 to screen1.
  move.l	screen1_ad,a0
  move.l	screen2_ad,a1
.copy:
  move.b	(a1)+,(a0)+
  dbra	d0,.copy

new_colors:
  move.w	#$7,d7
  move.l	#$ff8240,a0
  move.l	#egg_colors,a1
.one_color:
  move.l	(a1)+,(a0)+
  dbra	d7,.one_color
  



  move.w	#$2700,sr	; Disable interrupts.
  move.w	#0,d0
set_soundchip:
  move.b	d0,$ff8800	; Select register.
  move.b	#$0,$ff8802	; Clear every register between 0-5.
  addq.w	#$1,d0
  cmpi.w	#$6,d0
  bne.s	set_soundchip
  move.b	#$7,$ff8800	; Register 7: disable tones and noises.
  move.b	#$ff,$ff8802
  move.b	#$08,$ff8800	; Put the volume to 0 on all 3 voices,
  move.b	#$00,$ff8802	; cos there could be a shitty noise.
  move.b	#$09,$ff8800
  move.b	#$00,$ff8802
  move.b	#$0a,$ff8800
  move.b	#$00,$ff8802

save_timera:
  move.l	#timera_save,a0
  move.b	$fffa1f,(a0)+	; Save tadr.
  move.b	$fffa19,(a0)+	; Save tacr.
  move.b	$fffa13,(a0)+	; Save imra.
  move.b	$fffa17,(a0)+	; Save ivr.
  move.l	$134,(a0)+	; Save vector.
  
set_timera:
  move.l	#timera_rout,$134
  bset.b	#$5,$fffa13	; Demask timer a.
  bset.b	#$3,$fffa17	; Soft end of interrupt.
  move.b	#$0,$fffa19	; Timer a stopped.
  move.b	#$3,$fffa1f	; 3 ints before validation.
  move.b	#$5,$fffa19	; Delay mode, 1/64.
  
  move.w	#$2300,sr

sample1:  
  move.l	#ake,spl_ad	; Play the first sample.
  move.w	#19076,spl_length
  move.w	#$0,spl_pos
  move.w	#$0,spl_end
  
  bset.b	#$5,$fffa07	; Enable timer a.

wait_spl:
  cmpi.w	#$1,spl_end
  bne.s	wait_spl
  
  bclr.b	#$5,$fffa07	; Disable timer a.

sample2:  
  move.l	#coucou,spl_ad	; Play the second sample.
  move.w	#9590,spl_length
  move.w	#$0,spl_pos
  move.w	#$0,spl_end
  
  bset.b	#$5,$fffa07	; Enable timer a.


  move.w	#$6,d7	; Nb of vbls to be executed/2.
  move.l	#eggpos,a5
  move.l	#$0,vbl_nb	; This will serve for vsync.
coucou1:		; The little coucou goes out.
  cmp.l	#$0,vbl_nb	; One vbl?
  beq.s	coucou1
  move.l	screen1_ad,a6	; a6=adress of screen for the next Vbl.
  move.l	a6,d0	; Put the adress in the shifter.
  lsr.w	#$8,d0
  move.b	d0,$ff8203	; Mid base of the screen.
  swap.w	d0
  move.b	d0,$ff8201	; High base.
.egg_adress:
  move.w	(a5)+,d6	; Y line.
  moveq.l	#$0,d5	; Multiply it by $a0.
  move.w	d6,d5
  add.l	d5,d5
  add.l	d5,d5
  add.w	d6,d5
  lsl.w	#$5,d5
  add.l	d5,a6
  add.l	#$4c,a6	; Middle of the line.
  move.l	#oeuf,a4
  move.l	#$2f,d5	; 48 lines for the egg.
.copy_line:
  move.l	(a4)+,(a6)
  addq.l	#$8,a6
  move.l	(a4)+,(a6)
  add.l	#$98,a6
  addq.w	#$1,d6
  cmp.w	#63,d6
  bge.s	.copied    
  dbra	d5,.copy_line
.copied:
  move.l	#$0,vbl_nb	; This will serve for vsync.

coucou2:		; The little coucou goes out.
  cmp.l	#$0,vbl_nb	; One vbl?
  beq.s	coucou2
  move.w	#$0,vbl_nb	; This will serve for vsync.
  move.l	screen2_ad,a6	; a6=adress of screen for the next Vbl.
  move.l	a6,d0	; Put the adress in the shifter.
  lsr.w	#$8,d0
  move.b	d0,$ff8203	; Mid base of the screen.
  swap.w	d0
  move.b	d0,$ff8201	; High base.
.egg_adress:
  move.w	(a5)+,d6	; Y line.
  moveq.l	#$0,d5	; Multiply it by $a0.
  move.w	d6,d5
  add.l	d5,d5
  add.l	d5,d5
  add.w	d6,d5
  lsl.w	#$5,d5
  add.l	d5,a6
  add.l	#$4c,a6	; Middle of the line.
  move.l	#oeuf,a4
  move.l	#$2f,d5	; 48 lines for the egg.
.copy_line:
  move.l	(a4)+,(a6)
  addq.l	#$8,a6
  move.l	(a4)+,(a6)
  add.l	#$98,a6
  addq.w	#$1,d6
  cmp.w	#63,d6
  bge.s	.copied    
  dbra	d5,.copy_line
.copied:
  move.l	#$0,vbl_nb	; This will serve for vsync.
   
  dbra	d7,coucou1	; Next two frames.    

wait_spl2:
  cmpi.w	#$1,spl_end
  bne.s	wait_spl2
  
  bclr.b	#$5,$fffa07	; Disable timer a.

sample3:  
  move.l	#wooahaha,spl_ad; Play the third sample.
  move.w	#25808,spl_length
  move.w	#$0,spl_pos
  move.w	#$0,spl_end
  
  bset.b	#$5,$fffa07	; Enable timer a.

wait_spl3:
  cmpi.w	#$1,spl_end
  bne.s	wait_spl3
  
  bclr.b	#$5,$fffa07	; Disable timer a.

  
  move.w	#$2700,sr	; Disable interrupts.
restore_timera:
  move.l	#timera_save,a0
  move.b	(a0)+,$fffa1f	; Restore tadr.
  move.b	(a0)+,$fffa19	;  tacr.
  move.b	(a0)+,$fffa13	;  imra.
  move.b	(a0)+,$fffa17	;  ivr.
  move.l	(a0)+,$134	;  vector.

  move.w	#$2300,sr

wait_a_second:
  moveq.l	#$1f,d7	; Wait more than one second.
.wait:
  stop	#$2300
  dbra	d7,.wait
    
end_4th_part:		; 4th part over, clear the screens.
  moveq.l	#$7,d2	; Let's make a nice fade to black.
.fade_black:  
  move.l	#egg_colors,a0	; Initial colors 
  move.l	#$ff8240,a1
  move.w	d2,d0	; Fading index.
  moveq.l	#$1,d1	; Change all colors.
  jsr	fading

  rept	3  	; Wait the Vbl 3 times.
  stop	#$2300
  endr
  
  subq.l	#$1,d2	; Decrement the fade.
  cmpi.l	#$0,d2	; Minimum fade already done?
  bpl.s	.fade_black

  move.l	screen1_ad,a0	; Clear the screens.
  jsr	cls
  move.l	screen2_ad,a0
  jsr	cls

; *********  Fifth part: The Text.  *********

  move.l	#conv_table,a4
  move.l	#texte,a5
  move.w	pages_nb,d7

text_screen1:
  move.l	screen1_ad,a6	; a6=adress of screen for the next show.
  move.w	#$a,d6	; 11 textlines per page.
.print_line:
  move.w	#$13,d5	; 20 characters per line.
.one_char:
  moveq.l	#$0,d0
  move.b	(a5)+,d0	; Character to be printed.
  move.b	(a4,d0.w),d0	; Place of this char in the fonts.
  lsl.w	#$7,d0	; 128 bytes/char.
  move.l	#fonts,a3
  add.l	d0,a3	; a3 points on the good font.
  move.l	a6,a0
  add.l	#$8,a6	; Position for next char.
  move.w	#$f,d4	; 16 lines per char.
.print_char:
  move.l	(a3)+,(a0)+
  move.l	(a3)+,(a0)+
  add.l	#$98,a0
  dbra	d4,.print_char
  dbra	d5,.one_char
  add.l	#$a00,a6	; Next textline.
  dbra	d6,.print_line

  moveq.l	#$7,d2	; Let's make a nice fade to black.
.fade_black:  
  move.l	#text_col1,a0	; Initial colors 
  move.l	#$ff8240,a1
  move.w	d2,d0	; Fading index.
  moveq.l	#$1,d1	; Change all colors.
  jsr	fading

  rept	3  	; Wait the Vbl 3 times.
  stop	#$2300
  endr
  
  subq.l	#$1,d2	; Decrement the fade.
  cmpi.l	#$0,d2	; Minimum fade already done?
  bpl.s	.fade_black

.show_screen:
  move.l	screen1_ad,d0	; Put the adress in the shifter.
  lsr.w	#$8,d0
  move.b	d0,$ff8203	; Mid base of the screen.
  swap.w	d0
  move.b	d0,$ff8201	; High base.

  moveq.l	#$0,d2	; Let's make a nice fade to colors.
.fade_colors:  
  move.l	#text_col2,a0	; Initial colors 
  move.l	#$ff8240,a1
  move.w	d2,d0	; Fading index.
  moveq.l	#$1,d1	; Change all colors.
  jsr	fading

  rept	3  	; Wait the Vbl 3 times.
  stop	#$2300
  endr
  
  addq.l	#$1,d2	; Increment the fade.
  cmpi.l	#$8,d2	; Minimum fade already done?
  bmi.s	.fade_colors

.wait_a_lot:
  move.w	#$17f,d6	; Wait.
.wait:
  stop	#$2300
  dbra	d6,.wait

  subq.w	#$1,d7	; How many pages?
  beq	end_part5

text_screen2:
  move.l	screen2_ad,a6	; a6=adress of screen for the next show.
  move.w	#$a,d6	; 11 textlines per page.
.print_line:
  move.w	#$13,d5	; 20 characters per line.
.one_char:
  moveq.l	#$0,d0
  move.b	(a5)+,d0	; Character to be printed.
  move.b	(a4,d0.w),d0	; Place of this char in the fonts.
  lsl.w	#$7,d0	; 128 bytes/char.
  move.l	#fonts,a3
  add.l	d0,a3	; a3 points on the good font.
  move.l	a6,a0
  add.l	#$8,a6	; Position for next char.
  move.w	#$f,d4	; 16 lines per char.
.print_char:
  move.l	(a3)+,(a0)+
  move.l	(a3)+,(a0)+
  add.l	#$98,a0
  dbra	d4,.print_char
  dbra	d5,.one_char
  add.l	#$a00,a6	; Next textline.
  dbra	d6,.print_line

  moveq.l	#$7,d2	; Let's make a nice fade to black.
.fade_black:  
  move.l	#text_col2,a0	; Initial colors 
  move.l	#$ff8240,a1
  move.w	d2,d0	; Fading index.
  moveq.l	#$1,d1	; Change all colors.
  jsr	fading

  rept	3  	; Wait the Vbl 3 times.
  stop	#$2300
  endr
  
  subq.l	#$1,d2	; Decrement the fade.
  cmpi.l	#$0,d2	; Minimum fade already done?
  bpl.s	.fade_black

.show_screen:
  move.l	screen2_ad,d0	; Put the adress in the shifter.
  lsr.w	#$8,d0
  move.b	d0,$ff8203	; Mid base of the screen.
  swap.w	d0
  move.b	d0,$ff8201	; High base.

  moveq.l	#$0,d2	; Let's make a nice fade to colors.
.fade_colors:  
  move.l	#text_col1,a0	; Initial colors 
  move.l	#$ff8240,a1
  move.w	d2,d0	; Fading index.
  moveq.l	#$1,d1	; Change all colors.
  jsr	fading

  rept	3  	; Wait the Vbl 3 times.
  stop	#$2300
  endr
  
  addq.l	#$1,d2	; Increment the fade.
  cmpi.l	#$8,d2	; Minimum fade already done?
  bmi.s	.fade_colors

.wait_a_lot:
  move.w	#$17f,d6	; Wait.
.wait:
  stop	#$2300
  dbra	d6,.wait

  subq.w	#$1,d7	; How many pages?
  beq	end_part5

  bra	text_screen1

end_part5:

  move.l	screen1_ad,a0	; Clear the screens.
  jsr	cls
  move.l	screen2_ad,a0
  jsr	cls

; ----------------------------------
; |  The End: Back to the system.  |
; ----------------------------------

put_system:
  move.w	#$2700,sr	; Disable all interrupts.
  move.l	old_vbl,$70	; Restore old vbl,
  move.w	old_mfp,d0	; and the mfp IERs.
  move.b	d0,$fffa09
  lsr.w	#$8,d0
  move.b	d0,$fffa07
  move.w	old_sr,sr	; Restore status reg.

restore_screen:		; Back to the old features.  
  move.w	#$25,-(sp)	; Wait the vertical sync.
  trap	#$e
  addq.l	#$2,sp
  move.w	old_sync,d0
  move.b	d0,$ff820a	; Restore sync mode.
  move.w	old_res,-(sp)	; Restore resolution and screen bases.
  move.l	old_physbase,-(sp)
  move.l	old_logbase,-(sp)
  move.w	#$5,-(sp)
  trap	#$e
  add.l	#$c,sp
  
; **  A little fade to original colors.  **

fade_to_colors:
  moveq.l	#$0,d2	; d2 is the fading index.
.one_fade:  
  move.l	#old_colors,a0	; Initial colors 
  move.l	#$ff8240,a1
  move.w	d2,d0	; Fading index.
  moveq.l	#$1,d1	; Change all colors.
  jsr	fading

  rept	3  	; Wait the Vbl 3 times.
  move.w	#$25,-(sp)
  trap	#$e
  addq.l	#$2,sp
  endr
  
  add.l	#$1,d2	; Decrement the fade.
  cmpi.l	#$8,d2	; Minimum fade already done?
  blt.s	.one_fade
  

; **  Was the 68000 in user or super mode?  **

back_proc_mode:
  move.l	proc_mode,d0	; If d0 is nulm the 68k was in user.
  bne.s	.already_super	; Else he was in supervisor mode.  
.back_to_user:    
  move.l	#$0,-(sp)
  move.w	#$20,-(sp)
  trap	#$1
  addq.l	#$6,sp	; Here we have the same mode than on
.already_super:		; the beginning.
  movem.l	old_registers,d0-a7
  clr.w	-(sp)	; THE END!!!.......
  trap	#$1
  

; ----------------------------------
; |  The vbl rout: just for sync.  |
; ----------------------------------   

vbl_rout:		; The best vbl rout ever made.
  add.l	#$1,vbl_nb	; A little counter. 
  rte

; ---------------------------------------
; |  The Timer A rout: plays a sample.  |
; ---------------------------------------

timera_rout:
  movem.l	d0-d2/a0,-(sp)
  move.l	spl_ad,a0	; Adresse of the sample to be replayed.
  move.w	spl_pos,d0	; Where exactly must we take the digit.
  move.w	spl_length,d1	; We must take care of this.
  moveq.l	#$0,d2
  move.b	(a0,d0.w),d2	; The digit to be played.
  addq.w	#$1,d0
  cmp.w	d1,d0
  beq.s	.spl_end
  move.w	d0,spl_pos	; Save new position.
  move.l	#sndtable,a0	; Conversion table.
  lsl.w	#$3,d2	; digit*8.
  add.l	d2,a0	; Points on the good conversion parameters.
  move.w	(a0)+,d0
  move.w	(a0)+,d1
  move.w	(a0)+,d2
  move.l	#$ff8800,a0
  movep.w	d0,(a0)
  movep.w	d1,(a0)
  movep.w	d2,(a0)
  movem.l	(sp)+,d0-d2/a0
  bclr.b	#$5,$fffa0f	; Timer A no more in service.
  rte

.spl_end:
  move.w	#$1,spl_end
  movem.l	(sp)+,d0-d2/a0
  bclr.b	#$5,$fffa0f	; Timer A no more in service.
  rte
  
  
; *************************************
; **  All the interesting routines.  **
; *************************************

fading:
  include	'a:\sources\fading.s'
 Section TEXT
cls:
  include	'a:\sources\cls.s'
 Section TEXT
clsarea1:
  include	'a:\sources\clsarea1.s'
 Section TEXT
clsarea:
  include	'a:\sources\clsarea.s'
 Section TEXT
fastline:
  include	'a:\sources\fastline.s'
 Section TEXT
rotate:
  include	'a:\sources\rotate.s'
 Section TEXT
fastpoly:
  include	'a:\sources\fastpoly.s'

  
;************
 Section DATA

dracula:
  incbin	'a:\datas\dracula.obj'

atari_dots_nb:		; The coords and co for the atari logo
  dc.w	34	; are stocked here.
atari_dots:
  dc.w	-9,-60,0	; Points in the middle bar.
  dc.w	-9,60,0
  dc.w	9,60,0
  dc.w	9,-60,0

  dc.w	-15,-60,0	; Left brow.
  dc.w	-27,-60,0
  dc.w	-27,-6,0
  dc.w	-30,9,0
  dc.w	-36,15,0
  dc.w	-45,21,0
  dc.w	-57,24,0
  dc.w	-75,24,0
  dc.w	-75,60,0
  dc.w	-51,60,0
  dc.w	-39,57,0
  dc.w	-30,51,0
  dc.w	-24,45,0
  dc.w	-18,36,0
  dc.w	-15,24,0

  dc.w	15,-60,0	; Right brow.
  dc.w	27,-60,0
  dc.w	27,-6,0
  dc.w	30,9,0
  dc.w	36,15,0
  dc.w	45,21,0
  dc.w	57,24,0
  dc.w	75,24,0
  dc.w	75,60,0
  dc.w	51,60,0
  dc.w	39,57,0
  dc.w	30,51,0
  dc.w	24,45,0
  dc.w	18,36,0
  dc.w	15,24,0

atari_lines_nb:
  dc.w	34
atari_lines:
  dc.w	1,2,2,3,3,4,4,1
  dc.w	5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13
  dc.w	13,14,14,15,15,16,16,17,17,18,18,19,19,5
  dc.w	20,21,21,22,22,23,23,24,24,25,25,26,26,27,27,28
  dc.w	28,29,29,30,30,31,31,32,32,33,33,34,34,20
atari_colors:
  dc.w	$000,$211,$211,$322
  dc.w	$211,$322,$322,$433
  dc.w	$211,$322,$322,$433
  dc.w	$322,$433,$433,$544
atari_alpha:
  dc.w	$0
atari_beta:
  dc.w	$0
atari_bpl:
  dc.w	$0

box_dots_nb:
  dc.w	$8
box_coords:
  dc.w	$ffe0,$ffe0,$ffe0
  dc.w	$0020,$ffe0,$ffe0
  dc.w	$ffe0,$0020,$ffe0
  dc.w	$0020,$0020,$ffe0
  dc.w	$ffe0,$ffe0,$0020
  dc.w	$0020,$ffe0,$0020
  dc.w	$ffe0,$0020,$0020
  dc.w	$0020,$0020,$0020
box_faces_nb:
  dc.w	$5	; Nb of faces-1.
box_faces:
  dc.w	$3,$0	; Nb of dots constituting the face-1, color.
  dc.w	$4,$0,$8,$c	; Index of the brows*4.    
  dc.w	$3,$0
  dc.w	$14,$1c,$18,$10    
  dc.w	$3,$2
  dc.w	$10,$0,$4,$14    
  dc.w	$3,$2
  dc.w	$8,$18,$1c,$c    
  dc.w	$3,$4
  dc.w	$0,$10,$18,$8    
  dc.w	$3,$4
  dc.w	$14,$4,$c,$1c    
box_colors:
  dc.w	$000,$433,$211,$433
  dc.w	$322,$322,$322,$433
  dc.w	$000,$000,$000,$000
  dc.w	$000,$000,$000,$000
box_alpha:
  dc.w	$0
box_beta:
  dc.w	$0

sndtable:
  include	'a:\datas\sndtable.s'
 Section DATA

ake:
  incbin	'a:\datas\ake.spl'
coucou:
  incbin	'a:\datas\coucou.spl'
wooahaha:
  incbin	'a:\datas\wooahaha.spl'
oeuf:
  dc.l	$0,$0	; Four lines with 0s.
  dc.l	$0,$0
  dc.l	$0,$0
  dc.l	$0,$0
  incbin	'a:\datas\oeuf.obj'

eggpos:
  dc.w	45,35,26,20,17,15,15,16,18,19,19,18,17,16	

egg_colors:
  dc.w	$000,$433,$000,$000
  dc.w	$555,$555,$000,$000
  dc.w	$333,$333,$000,$000
  dc.w	$111,$111,$000,$000

text_col1:
  dc.w	$000,$100,$200,$300
  dc.w	$400,$500,$600,$700
  dc.w	$711,$722,$733,$744
  dc.w	$755,$766,$777,$777
text_col2:
  dc.w	$000,$110,$220,$330
  dc.w	$440,$550,$660,$770
  dc.w	$771,$772,$773,$774
  dc.w	$775,$776,$777,$777
fonts:
  incbin	'a:\datas\fonts.obj'
conv_table:
  dc.b	11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
  dc.b	11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
  dc.b	11,16,11,11,11,11,11,11,12,14,11,11,11,11,13,11
  dc.b	00,01,02,03,04,05,06,07,08,09,10,11,11,11,11,11
  dc.b	11,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
  dc.b	32,33,34,35,36,37,38,39,40,41,42,11,11,11,11,11
  dc.b	11,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
  dc.b	32,33,34,35,36,37,38,39,40,41,42,11,11,11,11,11
pages_nb:
  dc.w	14
texte:
  dc.b	'       dracula      '
  dc.b	'                    '
  dc.b	'  was proud to show '
  dc.b	' you his first demo '
  dc.b	'                    '
  dc.b	'   I know this is   '
  dc.b	' lame but you know, '
  dc.b	' this demo was only '
  dc.b	' released for a few '
  dc.b	'     reasons:       '
  dc.b	'                    '
  
  dc.b	'                    '
  dc.b	'                    '
  dc.b	'                    '
  dc.b	'                    '
  dc.b	'   J en ai reve!    '
  dc.b	'   Jhonny ne l a    '
  dc.b	'     pas fait!      '
  dc.b	'                    '
  dc.b	'                    '
  dc.b	'                    '
  dc.b	'                    '

  dc.b	' I want to give my  '
  dc.b	'     sources.       '
  dc.b	'                    '
  dc.b	' I want to show you '
  dc.b	'the first coucou box'
  dc.b	'  made in a demo!.  '
  dc.b	'                    '
  dc.b	'  I would like to   '
  dc.b	' have contacts with '
  dc.b	'     ST users.      '
  dc.b	'                    '

  dc.b	'                    '
  dc.b	'                    '
  dc.b	'                    '
  dc.b	'   For more infos   '
  dc.b	'  about the sources '
  dc.b	'   see ascii files  '
  dc.b	'    on the disk!    '
  dc.b	'                    '
  dc.b	'                    '
  dc.b	'                    '
  dc.b	'                    '

  dc.b	'  For the contacts  '
  dc.b	' i m interested in: '
  dc.b	'                    '
  dc.b	'1: sndtrk playrouts '
  dc.b	' (i have 30 percent '
  dc.b	'  of processor time '
  dc.b	'  left in this demo)'
  dc.b	'                    '
  dc.b	'2: Packers!.....    '
  dc.b	'                    '
  dc.b	'3: 3d stuff!....    '

  dc.b	'                    '
  dc.b	'                    '
  dc.b	'  I would also like '
  dc.b	'   to enter a crew  '
  dc.b	'                    '
  dc.b	' So if you think you'
  dc.b	'  can help me or i  '
  dc.b	'    can help you    '
  dc.b	'      write to:     '
  dc.b	'                    '
  dc.b	'                    '

  dc.b	'                    '
  dc.b	'  BROBECKER ALAIN   '
  dc.b	'  rte de dardagny   '
  dc.b	'   01630 challex    '
  dc.b	'      FRANCE        '
  dc.b	'                    '
  dc.b	'                    '
  dc.b	' (BTW i accept any  '
  dc.b	'   invitation for   '
  dc.b	' computer parties!) '
  dc.b	'                    '

  dc.b	'                    '
  dc.b	'     I send my      ' 
  dc.b	'  best regards to:  '
  dc.b	'                    '
  dc.b	'   Chris   Creeks   '
  dc.b	'    of mafiamiga    '
  dc.b	'    (amiga he!)     '
  dc.b	'  cos they are cool '  
  dc.b	'      friends.      '
  dc.b	'                    '
  dc.b	'                    '

  dc.b	'                    '
  dc.b	'                    '
  dc.b	'      Survivor      ' 
  dc.b	'    of mafiamiga    '
  dc.b	'  cos he is a cool  '  
  dc.b	' friend and he has  '
  dc.b	'   learned me the   '
  dc.b	'       68000        '
  dc.b	'                    '
  dc.b	'                    '
  dc.b	'                    '
    
  dc.b	'    Wann STc Sam    '  
  dc.b	'   of HMD (amiga)   '
  dc.b	'cos they are able to'
  dc.b	'code when everybody '
  dc.b	' is fooling around! '
  dc.b	'                    '
  dc.b	'   Tomcat Lector    '
  dc.b	'     Skyllion       '	 
  dc.b	'    of Steelers     '
  dc.b	'      (amiga)       '
  dc.b	'                    '
  
  dc.b	'   Zorgan and les   '
  dc.b	' Heretiques (amiga) '
  dc.b	'  I hope to be at   '
  dc.b	'  the garden 3!...  '
  dc.b	'                    '
  dc.b	'  Dobeman (ami..)   '
  dc.b	'Thanks for the docs!'
  dc.b	'                    '
  dc.b	'   Daniel (ST!!!)   '
  dc.b	'Hope to see you soon'
  dc.b	'                    '

  dc.b	'                    '
  dc.b	'Sync of dreamdealers'
  dc.b	'      (amiga)       '
  dc.b	'  Stormbringer of   '
  dc.b	'  the dark priests  '
  dc.b	'        (PC)        '
  dc.b	'                    '
  dc.b	'Fury of legacy (st) '
  dc.b	'have you still lotsa'  
  dc.b	'delay with your mail'
  dc.b	'                    '

  dc.b	' Chaos Inc for Neo  '
  dc.b	'  (Don t forget to  ' 
  dc.b	' send him money, he '
  dc.b	'really deserves it!)'
  dc.b	'                    '
  dc.b	'   Also greets to   '
  dc.b	'  all the computer  '
  dc.b	'   freaks who are   '
  dc.b	'       keeping      '
  dc.b	'   their computers  '
  dc.b	'       alive!       '

  dc.b	'                    '
  dc.b	'                    '
  dc.b	'                    '
  dc.b	'                    '
  dc.b	'                    '
  dc.b	'      The End       '
  dc.b	'                    '
  dc.b	'                    '
  dc.b	'                    '
  dc.b	'                    '
  dc.b	'                    '
  dc.b	'                    '
  
  
;***********
 Section BSS
 
old_registers:		; Here are saved all the things we change.
  ds.l	$10
proc_mode:
  ds.l	$1
old_colors:
  ds.w	$10 
old_physbase:
  ds.l	$1
old_logbase:
  ds.l	$1
old_res:
  ds.w	$1
old_sync:
  ds.w	$1   
old_vbl:
  ds.l	$1
old_mfp:
  ds.w	$1  
old_sr:
  ds.w	$1

timera_save:
  ds.l	$10

screen1:		; We had better not put the screens
  ds.b	$8000	; anywhere in memory, but take something
screen2:		; bigger than $7d00 cos the low base of
  ds.b	$8000  	; ramvideo must be zeroes.
screen1_ad:		; After calculations ( So that there are 0
  ds.l	$1	; in the low base. ), adresses are stored
screen2_ad:		; in this 2 buffers.
  ds.l	$1
vbl_nb:
  ds.l	$1
  
new_coords:		; For the storage of the coords.
  ds.l	$2a	; Up to 42 points. 
      
face_coords:
  ds.l	$2a	; Up to 42 points/face.
  
spl_ad:
  ds.l	$1
spl_pos:
  ds.w	$1
spl_length:
  ds.w	$1
spl_end:
  ds.w	$1  