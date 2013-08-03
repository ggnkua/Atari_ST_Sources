begin	
  lea	stackend(pc),sp	; Reserve uniquement la memoire
  move.l	sp,d0	; necessaire! (Libere le reste.)
  subi.l	#begin-$120,d0
  move.l	d0,-(sp)
  pea	begin-$100(pc)
  clr.w	-(sp)
  move.w	#$4a,-(sp)
  trap	#1
  adda.l	#$c,sp

super:
  move.l	#$0,-(sp)	; Supervisor mode.
  move.w	#$20,-(sp)
  trap	#$1
  addq.l	#$6,sp

  dc.w	$a00a	; Stop the mouse.

  move.b	$484.w,conterm	; Sauve ce bidule.
  clr.b	$484.w	; No bip,no repeat.

  move.l	$114.w,timer_c	; Enlever le timer C.
  move.l	#null_rout,$114.w
  
machine_test:
  move.l	$5a0,a0
  cmp.l	#$0,a0
  beq	stf	; Pas de cookie_jar donc un vieux st.
  move.l	$14(a0),d0
  cmp.l	#$0,d0	; _MCH=0 alors c' est un ST-STf.
  beq	stf
  cmp.l	#$30000,d0	; _MCH=$30000 alors c' est un Falcon.
  beq.s	.falcon	

.ste:		; STe then play the music.
  moveq.l	#$1,d0	; Run the music.
  jsr	music
  move.l	#music+$8,$4d2.w

.falcon:		; Chip music crashes on a Falcon.

  move.l	#colors,a0	; Save the colors.
  move.w	#$8240,a1	; And put every color to $0aa. 
  move.l	#$aa00aa,d0
  rept	8
  move.l	(a1),(a0)+
  move.l	d0,(a1)+
  endr

  moveq.l	#$0,d0	; Clear the screen.
  move.b	$ffff8201.w,d0
  swap.w	d0
  move.b	$ffff8203.w,d0
  lsl.w	#$8,d0
  move.l	d0,a0
  moveq.l	#$0,d0
  move.w	#7999,d1
.clear:
  move.l	d0,(a0)+
  dbra	d1,.clear

  pea	file_data(pc)
  pea	file_data(pc)
  pea	part1	; Lance la partie 1.
  clr.w	-(sp)
  move.w	#$4b,-(sp)
  trap	#1
  lea	16(sp),sp

  pea	file_data(pc)
  pea	file_data(pc)
  pea	part2	; Lance la partie 2.
  clr.w	-(sp)
  move.w	#$4b,-(sp)
  trap	#1
  lea	16(sp),sp
  
  pea	file_data(pc)
  pea	file_data(pc)
  pea	part3	; Lance la partie 3.
  clr.w	-(sp)
  move.w	#$4b,-(sp)
  trap	#1
  lea	16(sp),sp
  
  pea	file_data(pc)
  pea	file_data(pc)
  pea	part4	; Lance la partie 4.
  clr.w	-(sp)
  move.w	#$4b,-(sp)
  trap	#1
  lea	16(sp),sp
  
  pea	file_data(pc)
  pea	file_data(pc)
  pea	part5	; Lance la partie 5.
  clr.w	-(sp)
  move.w	#$4b,-(sp)
  trap	#1
  lea	16(sp),sp
  
  pea	file_data(pc)
  pea	file_data(pc)
  pea	part6	; Lance la partie 6.
  clr.w	-(sp)
  move.w	#$4b,-(sp)
  trap	#1
  lea	16(sp),sp

stop_chip_music:
  clr.l	$4d2.w	; Stop the music player.
  lea	$ffff8800,a0	; Stop the noise.
  move.l	#$8080000,(a0)
  move.l	#$9090000,(a0)
  move.l	#$a0a0000,(a0)

  pea	file_data(pc)
  pea	file_data(pc)
  pea	part7	; Lance la partie 7.
  clr.w	-(sp)
  move.w	#$4b,-(sp)
  trap	#1
  lea	16(sp),sp

end_proggy:	
  move.l	#colors,a0	; Restore the colors.
  move.w	#$8240,a1
  rept	8
  move.l	(a0)+,(a1)+
  endr

  move.l	timer_c,$114.w	; Remettre le timer c.
  move.b	conterm,$484.w	; Remettre ce bidule.

  dc.w	$a009	; Restore mouse.

  clr.w	-(sp)	; Stop.
  trap	#1

stf:
  pea	stf_text
  move.w	#$09,-(sp)
  trap	#$1
  addq.l	#$6,sp
  
  move.w	#$7,-(sp)
  trap	#$1
  addq.l	#$2,sp
  
  bra.s	end_proggy

null_rout:		; Routine nulle pou le bidule.
  addq.l	#$1,$4ba	; Compteur d' interruptions.
  bclr.b	#$5,$fffffa11.w	; Interrupt no more in service.
  rte

conterm:
  ds.w	1 
timer_c:
  ds.l	1
file_data:
  dc.l	0
stf_text:
  dc.b	'Sorry, this demo does not work on a STf',0
part1:
  dc.b	'intro.xxx',0
part2:
  dc.b	'balls.xxx',0
part3:
  dc.b	'stelex.xxx',0
part4:
  dc.b	'glenz.xxx',0
part5:
  dc.b	'bubbles.xxx',0
part6:
  dc.b	'exocet.xxx',0
part7:
  dc.b	'endpart.xxx',0

  even
music:
  incbin	'a:\shell\big_alec.mus'

  even

colors:
  ds.l	8

  ds.b	128
stackend:
  ds.b	10
