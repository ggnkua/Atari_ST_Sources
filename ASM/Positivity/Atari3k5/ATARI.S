; ************************************************
; **			**
; **             ATARI mini- demo.	**
; **         By Dracula on july 1993.	**
; **			**
; ************************************************

; -------------------------------------------
; |  At first some little initialisations.  |
; -------------------------------------------

main_proggy:
  move.l	#$0,-(sp)
  move.w	#$20,-(sp)	; Supervisor.
  trap	#$1
  addq.l	#$6,sp

  move.w	#$8240,a0	; At first save the colors.
  move.l	#old_colors,a1
  move.l	#atari_colors,a2
  move.w	#$7,d0
save_one_col:
  move.l	(a0),(a1)+
  move.l	(a2)+,(a0)+
  dbra	d0,save_one_col
  
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
  	 
; ---------------------------------
; |  The real chore of the demo!  |
; ---------------------------------

atari_screen1:
  move.w	#$25,-(sp)	; Wait the vbl.
  trap	#$e
  addq.l	#$2,sp

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
  move.w	#$25,-(sp)	; Wait the vbl.
  trap	#$e
  addq.l	#$2,sp

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

  cmpi.b	#$39,$fffffc02.w
  bne	atari_screen1

; ----------------------------------
; |  The End: Back to the system.  |
; ----------------------------------

  move.w	#$8240,a0	; At first save the colors.
  move.l	#old_colors,a1
  move.w	#$7,d0
restore_one_col:
  move.l	(a1)+,(a0)+
  dbra	d0,restore_one_col

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
  
  clr.w	-(sp)	; THE END!!!.......
  trap	#$1
  

; *************************************
; **  All the interesting routines.  **
; *************************************

clsarea1:
  include	'c:\sources\atari\clsarea.s'
 Section TEXT
fastline:
  include	'c:\sources\atari\fastline.s'
 Section TEXT
rotate:
  include	'c:\sources\atari\rotate.s'
 Section TEXT
  
;************
 Section DATA

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

;***********
 Section BSS
 
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
      
