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
  bne	.already_super 	; Are we in user or super?
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

  rept	3  	; Wait the Vbl 7 times.
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
  dc.w	$a00a	; Bye little maus!
  move.l	$70,old_vbl	; Save the old vbl rout.
  moveq.l	#$0,d0	; Save IERA and IERB.
  move.b	$fffa07,d0
  lsl.w	#$8,d0
  move.b	$fffa09,d0
  move.w	d0,old_mfp
  move.w	sr,old_sr  
  
change_int:		; Replace or disable interrupts.
  move.w	#$2700,sr	; Disable all ( maskable ) int.
  move.l	#vbl_rout,$70	; Put my own routine.
  move.b	#$00,$fffa07	; Stop the mfp.
  move.b	#$00,$fffa09
  move.b	#$08,$ff8800	; Put the volume to 0 on all 3 voices,
  move.b	#$00,$ff8802	; cos there could be a shitty noise.
  move.b	#$09,$ff8800
  move.b	#$00,$ff8802
  move.b	#$0a,$ff8800
  move.b	#$00,$ff8802
  move.w	#$2300,sr	; Inits are finished, so enable int.
  
; ---------------------------------
; |  The real chore of the demo!  |
; ---------------------------------

main_demo:










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
  dc.w	$a009	; Supermouse is back.

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
  moveq.l	#$7,d2	; d2 is the fading index.
.one_fade:  
  move.l	#old_colors,a0	; Initial colors 
  move.l	#$ff8240,a1	; We will overwrite this old colors.
  move.w	d2,d0	; Fading index.
  moveq.l	#$1,d1	; Change all colors.
  jsr	fading

  rept	3  	; Wait the Vbl 7 times.
  move.w	#$25,-(sp)
  trap	#$e
  addq.l	#$2,sp
  endr
  
  addq.l	#$1,d2	; Decrement the fade.
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
  
; *************************************
; **  All the interesting routines.  **
; *************************************

fading:
  include	'a:\sources\fading.s'
cls:
  include	'a:\sources\cls.s'
  

  
;************
 Section DATA



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
      

