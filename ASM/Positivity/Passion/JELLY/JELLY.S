; ************************************************************************
; *****                                                              *****
; *****		MAPPED JELLY		     *****
; *****                                                              *****
; ************************************************************************
; *****            A Jelly cube with a x-zoomed image on it.         *****
; *****                      By Alain BROBECKER.                     *****
; *****   Coded between 6th and 10th of June 1994. (No hurry!...)    *****
; ************************************************************************
; At the beginning all colors must be black, cos this are the initials
; colors of the fade.

time	equ	499
;249
end_pos	equ	64*6
rezo    equ     5000

supervisor:
  move.l	#$0,-(sp)
  move.w	#$20,-(sp)
  trap	#$1	; User mode is shit....
  addq.l	#$6,sp

Memorisation_pile:
  move.l	d0,-(sp)

Get_resolution:
  move.w	#-1,-(sp)
  move.w	#88,-(sp)
  trap		#14
  addq.l	#4,sp
  move.w	d0,rezo	


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
  trap		#14	
  addq.l	#2,sp

;  move.w	#%100010,-(sp)
;  move.w	#3,-(sp)
  move.w	#-1,-(sp)
  move.w	#-1,-(sp)
  move.w	#5,-(sp)
  trap		#14
  add.l		#8,sp
		

;  move.b	#$0,$ffff8260.w

; ************************************************************************
; Generate the zooming routines.

  move.l	#zoom_code,a0
  move.l	#zoom_adr,a1
  jsr	generate


; ************************************************************************
; ************************************************************************
; The demo itself runs now....

  move.l	#$0,$466.w	; _frclock=0.
  move.l	#demo_vbl,$70.w
  move.l	#$0,position

init_timer_b:
  bclr.b	#$0,$fffffa07.w	; Timer B disabled!..
  bset.b	#$0,$fffffa13.w ; Timer B demasked.
  bset.b	#$3,$fffffa17.w	; Soft end of interrupt.
  move.l	#timer_b,$120
  move.b	#$0,$fffffa1b.w	; Timer B stoppe.
  bset.b	#$0,$fffffa07.w	; Timer B enabled.

  move.b	#$0,$ffff8a3d.w	; No skew register.
  move.l	#-1,$ffff8a28.w ; No masks.
  move.w	#-1,$ffff8a2c.w
      
vbl_one:
  jsr	wait_vbl
  move.l	#screen1,a6

  move.b	#$0,$ffff8a3b.w	; Fill with zeroes.

.clear_old_cube:
  move.l	a6,a5
  add.w	#7736,a5	; a5 points on the first word to clear.
  move.l	a5,$ffff8a32.w	; Dest adress.
  move.l	#$20072,$ffff8a2e.w ; Dest x inc and dest y inc.
  move.l	#$180060,$ffff8a36.w ; 24 words per line and 96 lines.
  move.b	#$c0,$ffff8a3c.w ; Go.
  
.clear_old_logo:
  move.l	#y_conv_table,a0
  move.w	old_logo_y1,d0
  add.w	d0,d0
  move.l	a6,a5
  add.w	(a0,d0.w),a5	; a5 points on the first word to clear.
  move.l	a5,$ffff8a32.w	; Dest adress.
  move.l	#$20092,$ffff8a2e.w ; Dest x inc and dest y inc.
  move.l	#$8000a,$ffff8a36.w ; 8 words per line and 10 lines.
  move.b	#$c0,$ffff8a3c.w ; Go.

  move.l	#movements,a5
  move.l	position,d7
  add.l	d7,a5
  addq.l	#6,d7
  cmp.l	#end_pos,d7
  bne.s	.pos_ok
  moveq.l	#$0,d7
.pos_ok:
  move.l	d7,position

  move.w	#$203,$ffff8a3a.w ; Source.

.print_logo:
  move.w	(a5)+,d0	; Y of the logo.
  move.w	d0,old_logo_y1
  add.w	d0,d0
  move.l	a6,a4
  add.w	(a0,d0.w),a4	; a4 points on the dest adress.
  move.l	a4,$ffff8a32.w	; Dest adress.
  move.l	#$20092,$ffff8a2e.w ; Dest x inc and dest y inc.
  move.l	#$8000a,$ffff8a36.w ; 8 words per line and 10 lines.
  move.l	#logo,$ffff8a24.w ; Source adress.
  move.l	#$20002,$ffff8a20.w ; Source x inc and y inc.
  move.b	#$c0,$ffff8a3c.w ; Go.

.print_cube:
  move.w	(a5)+,d4	; y1.
  move.w	#144,d5	; y2.
  move.w	(a5)+,d6	; Jelly coef.
  move.l	a6,a3	; Ramvideo adress.
  move.l	#image,d7	; Source image.
  move.l	#zoom_adr,a4	; Zoom routs adresses table.
  jsr	jelly_cube

.put_ramvideo_adress:
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

  move.b	#$0,$ffff8a3b.w	; Fill with zeroes.

.clear_old_cube:
  move.l	a6,a5
  add.l	#7736,a5	; a5 points on the first word to clear.
  move.l	a5,$ffff8a32.w	; Dest adress.
  move.l	#$20072,$ffff8a2e.w ; Dest x inc and dest y inc.
  move.l	#$180060,$ffff8a36.w ; 24 words per line and 96 lines.
  move.b	#$c0,$ffff8a3c.w ; Go.
  
.clear_old_logo:
  move.l	#y_conv_table,a0
  move.w	old_logo_y2,d0
  add.w	d0,d0
  move.l	a6,a5
  add.w	(a0,d0.w),a5	; a5 points on the first word to clear.
  move.l	a5,$ffff8a32.w	; Dest adress.
  move.l	#$20092,$ffff8a2e.w ; Dest x inc and dest y inc.
  move.l	#$8000a,$ffff8a36.w ; 8 words per line and 10 lines.
  move.b	#$c0,$ffff8a3c.w ; Go.

  move.l	#movements,a5
  move.l	position,d7
  add.l	d7,a5
  addq.l	#6,d7
  cmp.l	#end_pos,d7
  bne.s	.pos_ok
  moveq.l	#$0,d7
.pos_ok:
  move.l	d7,position

  move.w	#$203,$ffff8a3a.w ; Source.

.print_logo:
  move.w	(a5)+,d0	; Y of the logo.
  move.w	d0,old_logo_y2
  add.w	d0,d0
  move.l	a6,a4
  add.w	(a0,d0.w),a4	; a4 points on the dest adress.
  move.l	a4,$ffff8a32.w	; Dest adress.
  move.l	#$20092,$ffff8a2e.w ; Dest x inc and dest y inc.
  move.l	#$8000a,$ffff8a36.w ; 8 words per line and 10 lines.
  move.l	#logo,$ffff8a24.w ; Source adress.
  move.l	#$20002,$ffff8a20.w ; Source x inc and y inc.
  move.b	#$c0,$ffff8a3c.w ; Go.

.print_cube:
  move.w	(a5)+,d4	; y1.
  move.w	#144,d5	; y2.
  move.w	(a5)+,d6	; Jelly coef.
  move.l	a6,a3	; Ramvideo adress.
  move.l	#image,d7	; Source image.
  move.l	#zoom_adr,a4	; Zoom routs adresses table.
  jsr	jelly_cube

.put_ramvideo_adress:
  move.l	a6,d0   
  move.l	d0,d1
  swap.w	d0
  move.b	d0,$ffff8201.w
  swap.w	d0
  rol.w	#$8,d0
  move.b	d0,$ffff8203.w
  move.b	d1,$ffff820d.w

;  cmpi.b	#$39,$fffffc02.w
;  beq.s	the_end
.no_key:
  move.l	$466.w,d0
  cmp.w	#time-1,d0
  ble	vbl_one

  move.l	old_vbl,$70.w	; Restore the Vbl.

; ************************************************************************
; ************************************************************************
the_end:
  move.w	#$25,-(sp) 
  trap	#$e	; Vsync
  addq.l	#$2,sp

  move.w	#$25,-(sp)
  trap		#14	
  addq.l	#2,sp

  move.w	#rezo,-(sp)
;  move.w	#3,-(sp)
;  move.l	#-1,-(sp)
;  move.l	#-1,-(sp)
  move.w	#88,-(sp)
  trap		#14
  addq.l	#4,sp

;  move.b	old_rez,$ffff8260.w ; Restore screen features.
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

;  move.w	#$000,$ffff8240.w ; Devpac does not restore colors.
;  move.w	#$445,$ffff8242.w
;  move.w	#$445,$ffff8244.w
;  move.w	#$445,$ffff8246.w
  		
  move.w	#37,-(sp)
  trap		#14	

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
demo_vbl:		; "Null" vbl routine.
  movem.l	d0/a0-a1,-(sp)
  move.l	$466.w,d0
  addq.l	#$1,d0	; Increment _frclock.
  move.l	d0,$466.w
  cmp.w	#time-28,d0
  bge.s	.near_end
.put_colors:
  cmp.w	#$1f,d0	; Less than 32 vbls have passed.
  ble.s	.ok1
  move.w	#$1f,d0
.ok1:
  bclr.l	#$0,d0
  lsl.w	#$4,d0	; 32 bytes per set of colors.
  move.w	d0,color_offset
  move.l	#colors1,a0
  add.w	d0,a0
  move.w	#$8240,a1
 rept	8
  move.l	(a0)+,(a1)+
 endr  

.timer_b:
  move.b	#$0,$fffffa1b.w	; Stop the timer.
  move.b	#128,$fffffa21.w ; Wait 128 lines.
  move.b	#$8,$fffffa1b.w	; Event count mode.

  cmp.l	#$0,$4d2.w	; A music routine?
  beq.s	.no_music
.music:		; Yes, so execute it.
  move.l	$4d2.w,a0
  jsr	(a0)
.no_music:
  movem.l	(sp)+,d0/a0-a1
  rte

.near_end
  move.w	#time+3,a0
  sub.w	d0,a0	; a0=time-(_frclock).
  move.w	a0,d0
  bclr.l	#$0,d0
  lsl.w	#$4,d0	; 32 bytes per set of colors.
  move.w	d0,color_offset
  move.l	#colors1,a0
  add.w	d0,a0
  move.w	#$8240,a1
 rept	8
  move.l	(a0)+,(a1)+
 endr  
  bra.s	.timer_b
  
;**************************************************************************
timer_b:
  move.b	#$0,$fffffa1b.w	; Stop the timer.
  move.l	a0,-(sp)
  move.l	a1,-(sp)
  move.l	#colors2,a0
  add.w	color_offset,a0
  move.w	#$8240,a1	; Couleurs du bas.
 rept	8
  move.l 	(a0)+,(a1)+
 endr
  move.l	(sp)+,a1
  move.l	(sp)+,a0
  bclr.b	#$0,$fffffa0f.w	; Interruption finie.
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
; * The interesting routines.
; ************************************************************************

generate:
  include	'E:\demos\positivi.ty\passion\jelly\generate.s'
  
jelly_cube:
  include	'E:\demos\positivi.ty\passion\jelly\gel_cube.s'
  
; ************************************************************************
  Section DATA
  
colors1:
  incbin	'E:\demos\positivi.ty\passion\jelly\fade1.xxx'

colors2:
  incbin	'E:\demos\positivi.ty\passion\jelly\fade2.xxx'

movements:
  incbin	'E:\demos\positivi.ty\passion\jelly\movement.xxx'

y_conv_table:		; Conv table for logo position ->adress.
N set 72
 rept	200
  dc.w	N
N set N+160
 endr

logo:
  incbin	'E:\demos\positivi.ty\passion\jelly\pstvt.xxx'

image:
  incbin	'E:\demos\positivi.ty\passion\jelly\brune2.xxx'
  
; ************************************************************************
get_rezo
	dc.w	1

 section BSS
  
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

zoom_code:		; Space for the zooming routs.
  ds.b	35000
zoom_adr:
  ds.l	50	; Will contain the adresses of them.

position:		; Adress in the movements.
  	ds.l	1
  
old_logo_y1:
  ds.w	1
old_logo_y2:
  ds.w	1
color_offset:
  ds.w	1

ecran	ds.l	1
        
      
        end 
  
  
  