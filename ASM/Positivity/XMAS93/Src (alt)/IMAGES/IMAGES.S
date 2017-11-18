;**************************************************************************
;**	           Le programme principal!	         **
;**************************************************************************

script_length	equ	92

supervisor_mode:	; INDISPENSABLE.
  move.l	#$0,-(sp)
  move.w	#$20,-(sp)
  trap	#$1
  addq.l	#$6,sp

  dc.w	$a00a	; Bye bye la souris.
  move.b	#$12,$fffffc02.w
  bclr.b	#$0,$484.w
  
save_old_features:	
  move.w	$ffff8260.w,old_res
  move.b	$ffff820a.w,old_sync
  moveq.l	#$0,d0
  move.b	$ffff8201.w,d0	; Base haute.
  swap.w	d0
  move.b	$ffff8203.w,d0	; Moyenne.
  lsl.w	#$8,d0
  move.b	$ffff820d.w,d0	; Basse.( N' existe pas sur ST-STf)
  move.l	d0,old_screen
  move.l	#$7,d0	; Sauver les couleurs qu'on va modifier.
  move.l	#old_colors,a0
  move.w	#$8240,a1
.save_cols:
  move.l 	(a1)+,(a0)+
  dbra	d0,.save_cols

screen_features:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp
  move.w	#$0,$ffff8260.w	; Basse resolution.
  move.b	#$2,$ffff820a.w	; Sync=50Hz.
  move.l	#screen,d0	; Mettre l' adresse de l' ecran.
  lsr.w	#$8,d0
  move.b	d0,$ffff8203.w
  swap.w	d0
  move.b	d0,$ffff8201.w
  move.b	#$0,$ffff820d.w
  moveq.l	#$7,d0	
  move.w	#$8240,a0	; Mettre les couleurs a $0aa.
  move.l	#$aa00aa,d1
.put_cols:
  move.l 	d1,(a0)+
  dbra	d0,.put_cols
  
;**************************************************************************

  move.l	#script,a6
  moveq.l	#$0,d7	; Position dans le script.

vbl1:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp

  move.l	#image+34,d0	; Ecran de travail.
  move.w	(a6),d1
  move.w	d1,d2
  add.w	d1,d1
  add.w	d1,d1
  add.w	d2,d1
  lsl.w	#$5,d1
  ext.l	d1
  add.l	d1,d0	; d0 points on the adress to put.
  
  move.b	d0,$ffff8209.w	; Put the adress.
  lsr.w	#$8,d0
  move.b	d0,$ffff8207.w
  swap.w	d0
  move.b	d0,$ffff8205.w

  bclr.b	#$0,$fffffa07.w	; Timer B disabled!..
  bset.b	#$0,$fffffa13.w ; Timer B demasked.
  bset.b	#$3,$fffffa17.w	; Soft end of interrupt.
  move.l	#timer_b1,$120
  move.b	#$0,$fffffa1b.w	; Timer B stoppe.
  bset.b	#$0,$fffffa07.w	; Timer B enabled.
  move.b	#$1,$fffffa21.w ; Wait 1 line.
  move.b	#$8,$fffffa1b.w	; Event count mode.

  moveq.l	#$0,d0
  move.l	d0,d1
  move.l	d0,d2
  move.l	d0,d3
  move.l	d0,a0
  move.l	d0,a1
  move.l	d0,a2
  move.l	d0,a3
  move.w	#$8240,a4

  move.b	#$0,timerb_flag
  
.wait_last_timerb:
  move.b	timerb_flag,d6
  cmp.b  	#$1,d6
  bne.s	.wait_last_timerb

  addq.l	#$2,a6	; Next position.

  addq.l	#$1,d7
  cmp.l	#script_length,d7
  beq.s	goto_vbl2
  
  bra	vbl1 
    
goto_vbl2:
  move.l	#$200,d7
vbl2:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp

  move.l	#image+34,d0	; Ecran de travail.
  move.w	(a6),d1
  move.w	d1,d2
  add.w	d1,d1
  add.w	d1,d1
  add.w	d2,d1
  lsl.w	#$5,d1
  ext.l	d1
  add.l	d1,d0	; d0 points on the adress to put.
  
  move.b	d0,$ffff8209.w	; Put the adress.
  lsr.w	#$8,d0
  move.b	d0,$ffff8207.w
  swap.w	d0
  move.b	d0,$ffff8205.w

  bclr.b	#$0,$fffffa07.w	; Timer B disabled!..
  bset.b	#$0,$fffffa13.w ; Timer B demasked.
  bset.b	#$3,$fffffa17.w	; Soft end of interrupt.
  move.l	#timer_b1,$120
  move.b	#$0,$fffffa1b.w	; Timer B stoppe.
  bset.b	#$0,$fffffa07.w	; Timer B enabled.
  move.b	#$1,$fffffa21.w ; Wait 1 line.
  move.b	#$8,$fffffa1b.w	; Event count mode.

  moveq.l	#$0,d0
  move.l	d0,d1
  move.l	d0,d2
  move.l	d0,d3
  move.l	d0,a0
  move.l	d0,a1
  move.l	d0,a2
  move.l	d0,a3
  move.w	#$8240,a4

  move.b	#$0,timerb_flag
  
.wait_last_timerb:
  move.b	timerb_flag,d6
  cmp.b  	#$1,d6
  bne.s	.wait_last_timerb

  cmpi.b	#$39,$fffffc02.w
  beq.s	goto_vbl3

  dbra	d7,vbl2

goto_vbl3:
  moveq.l	#$0,d7  
vbl3:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp

  move.l	#image+34,d0	; Ecran de travail.
  move.w	(a6),d1
  move.w	d1,d2
  add.w	d1,d1
  add.w	d1,d1
  add.w	d2,d1
  lsl.w	#$5,d1
  ext.l	d1
  add.l	d1,d0	; d0 points on the adress to put.
  
  move.b	d0,$ffff8209.w	; Put the adress.
  lsr.w	#$8,d0
  move.b	d0,$ffff8207.w
  swap.w	d0
  move.b	d0,$ffff8205.w

  bclr.b	#$0,$fffffa07.w	; Timer B disabled!..
  bset.b	#$0,$fffffa13.w ; Timer B demasked.
  bset.b	#$3,$fffffa17.w	; Soft end of interrupt.
  move.l	#timer_b1,$120
  move.b	#$0,$fffffa1b.w	; Timer B stoppe.
  bset.b	#$0,$fffffa07.w	; Timer B enabled.
  move.b	#$1,$fffffa21.w ; Wait 1 line.
  move.b	#$8,$fffffa1b.w	; Event count mode.

  moveq.l	#$0,d0
  move.l	d0,d1
  move.l	d0,d2
  move.l	d0,d3
  move.l	d0,a0
  move.l	d0,a1
  move.l	d0,a2
  move.l	d0,a3
  move.w	#$8240,a4

  move.b	#$0,timerb_flag
  
.wait_last_timerb:
  move.b	timerb_flag,d6
  cmp.b  	#$1,d6
  bne.s	.wait_last_timerb

  subq.l	#$2,a6	; Next position.

  addq.l	#$1,d7
  cmp.l	#script_length,d7
  beq.s	sortie
  
  bra	vbl3    

;**************************************************************************
sortie:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp
  move.w	old_res,$ffff8260.w
  move.b	old_sync,$ffff820a.w
  move.l	old_screen,d0
  swap.w	d0
  move.b	d0,$ffff8201.w	; Le pire c' est qu'il faut mettre
  swap.w	d0	; $ff820d en dernier.
  rol.w	#$8,d0	
  move.b	d0,$ffff8203.w
  rol.w	#$8,d0	
  move.b	d0,$ffff820d.w
  move.l	#$7,d0	
  move.w	#$8240,a0	; Mettre les couleurs a $334.
  move.l	#old_colors,a1
.restore_cols:
  move.l 	(a1)+,(a0)+
  dbra	d0,.restore_cols

  bset.b	#$0,$484.w
  move.b	#$8,$fffffc02.w
  dc.w	$a009	; Le tank est de retour!
  
  clr.w	-(sp)
  trap	#$1

;**************************************************************************
timer_b1:
  move.b	#$0,$fffffa1b.w	; Stop the timer.
  movem.l	d0-3/a0-3,(a4)	; Put the colors.
  move.l	#image+2,a4	; Prepare colors for the next hbl.
  movem.l	(a4),d0-3/a0-3
  move.w	#$8240,a4
  move.l	#timer_b2,$120	; Next rout.
  move.b	#$1,$fffffa21.w	; Wait only one line.
  move.b	#$8,$fffffa1b.w	; Event count mode.
  bclr.b	#$0,$fffffa0f.w	; Interruption finie.
  rte

timer_b2:
  move.b	#$0,$fffffa1b.w	; Stop the timer.
  movem.l	d0-3/a0-3,(a4)	; Put the colors.
  moveq.l	#$0,d0	; Prepare colors for the next vbl.
  move.l	d0,d1
  move.l	d0,d2
  move.l	d0,d3
  move.l	d0,a0
  move.l	d0,a1
  move.l	d0,a2
  move.l	d0,a3
  move.l	#timer_b3,$120	; Next rout.
  move.w	#198,d4
  sub.w	(a6),d4
  cmp.w	#197,d4
  ble.s	.ok
  move.w	#197,d4  
.ok:
  cmp.w	#1,d4
  bge.s	.ok2
  move.w	#1,d4  
.ok2:
  move.b	d4,$fffffa21.w	; Wait y-2 lines.
  move.b	#$8,$fffffa1b.w	; Event count mode.
  bclr.b	#$0,$fffffa0f.w	; Interruption finie.
  rte

timer_b3:
  move.b	#$0,$fffffa1b.w	; Stop the timer.
  movem.l	d0-3/a0-3,(a4)	; Put the colors.
  move.l	#$aa00aa,d0	; Prepare colors for the next vbl.
  move.l	d0,d1
  move.l	d0,d2
  move.l	d0,d3
  move.l	d0,a0
  move.l	d0,a1
  move.l	d0,a2
  move.l	d0,a3
  move.l	#timer_b4,$120	; Next rout.
  move.b	#$1,$fffffa21.w	; Wait y-2 lines.
  move.b	#$8,$fffffa1b.w	; Event count mode.
  bclr.b	#$0,$fffffa0f.w	; Interruption finie.
  rte

timer_b4:
  move.b	#$0,$fffffa1b.w	; Stop the timer.
  movem.l	d0-3/a0-3,(a4)	; Put the colors.
  move.b	#$1,timerb_flag	; Interrupts are finished.
  bclr.b	#$0,$fffffa0f.w	; Interruption finie.
  rte


;**************************************************************************
  Section DATA
  
script:		; Le script.
  incbin	'a:\images\table.xxx'

image:
  incbin	'a:\images\stelex.pi1'

;**************************************************************************
  Section BSS

screen:
  ds.l	8000


buffer:
  ds.w	16

timerb_flag:
  ds.w	1
  
old_res:
  ds.w	1
old_sync:
  ds.w	1
old_screen:
  ds.l	1
old_colors:
  ds.l	8

