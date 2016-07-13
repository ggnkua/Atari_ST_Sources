;**************************************************************************
;**	           Le programme principal!	         **
;**************************************************************************

x	equ	159
y	equ	138

supervisor_mode:	; INDISPENSABLE.
  move.l	#$0,-(sp)
  move.w	#$20,-(sp)
  trap	#$1
  addq.l	#$6,sp

  dc.w	$a00a	; Bye bye la souris.
  move.b	#$12,$fffffc02.w
  bclr.b	#$0,$484.w
  
  move.w	#$0,$452	; Verouiller la vbl.
    
screens_adresses:  	; Calcul des adresses des ecrans.
  move.l	#screens,d0
  and.l	#$ffffff00,d0	; S' aligner sur un multiple de 256.
  add.l	#$100,d0
  move.l	d0,screen1_ad	; Adresse de l' ecran 1.
  add.l	#$7d00,d0
  move.l	d0,screen2_ad	; Ecran 2.

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
  move.l	screen2_ad,d0	; Mettre l' adresse de l' ecran 2.
  lsr.w	#$8,d0
  move.b	d0,$ffff8203.w
  swap.w	d0
  move.b	d0,$ffff8201.w
  move.b	#$0,$ffff820d.w
  moveq.l	#$7,d0	
  move.w	#$8240,a0	; Mettre les couleurs a $334.
  move.l	#colors,a1
.put_cols:
  move.l 	(a1)+,(a0)+
  dbra	d0,.put_cols
  
prepare_screens:	; Copier le "texte" dans les ecrans.
  move.l	screen1_ad,a0
  move.l  	#text,a1
  move.l	#919,d0	; 3680 octets a copier.
  add.l	#28320,a0	; A mettre a la ligne 177.
.copy1:
  move.l	(a1)+,(a0)+
  dbra	d0,.copy1	; Ca me dbeqt!....
  move.l	screen2_ad,a0
  move.l  	#text,a1
  move.l	#919,d0
  add.l	#28320,a0
.copy2:
  move.l	(a1)+,(a0)+
  dbra	d0,.copy2

machine_test:
  move.l	$5a0,a0
  cmp.l	#$0,a0
  beq.s	.st_stf_ste	; Pas de cookie_jar donc un vieux st.
  move.l	$14(a0),d0
  cmp.l	#$0,d0	; _MCH=0 alors c' est un ST-STf.
  beq.s	.st_stf_ste	
  cmp.l	#$10000,d0	; _MCH=$10000 alors c' est un STe.
  beq.s	.st_stf_ste	
  cmp.l	#$10010,d0	; _MCH=$10010 alors c' est un Mega STe.
  beq.s	.st_stf_ste
  bra.s	.other_compy
  
.st_stf_ste:		; Si on a une de ces machines, on peut
  move.w	#$1,music_flag  ; rejouer la music.
  moveq.l	#$0,d0	; Mais d' abord il faut l' initialiser.
  bsr	music
  bsr	music+18
 
.other_compy:		; Sinon on laisse le music flag a 0.
  
;**************************************************************************
  move.w	#1000,script_pos

init_timer_b:
  bclr.b	#$0,$fffffa07.w	; Timer B disabled!..
  bset.b	#$0,$fffffa13.w ; Timer B demasked.
  bset.b	#$3,$fffffa17.w	; Soft end of interrupt.
  move.l	#timer_b,$120
  move.b	#$0,$fffffa1b.w	; Timer B stoppe.
  bset.b	#$0,$fffffa07.w	; Timer B enabled.
    
vbl1:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp

  cmp.w	#$0,music_flag	; Rejouer la music?
  beq.s	.no_music
  bsr	music+26	; Oui.
.no_music:
    
  moveq.l	#$7,d0	
  move.w	#$8240,a0	; Couleurs du haut.
  move.l	#colors,a1
.put_cols:
  move.l 	(a1)+,(a0)+
  dbra	d0,.put_cols

.timer_b:
  move.b	#$0,$fffffa1b.w	; Stop the timer.
  move.b	#y+7,$fffffa21.w ; Wait y lignes.
  move.b	#$8,$fffffa1b.w	; Event count mode.

  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test
  add.w	#$111,$ffff8240.w
.no_test:

  move.l	screen1_ad,a6

  move.l	#new_coords,a0
  move.l	#script,a5
  move.w	script_pos,d0
  move.w	d0,d1
  ext.l	d0
  add.w	d0,d0
  add.w	d1,d0
  add.w	d0,d0	; d0=script_pos*3.
  add.l	d0,a5	; a5 pointe sur les 3 parametres.
  addq.w	#$1,d1	; Prochaine position.
  cmp.w	script_length,d1; Script fini?
  ble.s	.script_ok
  moveq.l	#$0,d1	; Oui, alors recommencer.
.script_ok:
  move.w	d1,script_pos
.calc:
  move.w	#$ffd1,(a0)	; -47.
  add.w	#x,(a0)+
  move.l	#$ffffd100,d0	; -47*256.
  divs.w	#$14f,d0	; d0=-47*256/(256+90).
  add.w	#x,d0
  move.w	d0,(a0)+
  move.w	#$2f+x,(a0)+	; 47.
  move.l	#$2f00,d0	; 47*256.
  divs.w	#$14f,d0	; d0=47*256/(256+90).
  add.w	#x,d0
  move.w	d0,(a0)+
  move.w	(a5)+,d0	; y.
  add.w	#y,d0
  move.w	d0,(a0)+
  sub.w	#y,d0
  ext.l	d0
  lsl.w	#$8,d0
  divs.w	#$14f,d0	; d0=y*256/(256+90).
  add.w	#y,d0
  move.w	d0,(a0)+
  move.w	#$20+y,(a0)+	; yend=32.
  move.l	#$2000,d0
  divs.w	#$14f,d0	; d0=yend*256/(256+90).
  add.w	#y,d0
  move.w	d0,(a0)+
  move.w	(a5)+,d0	; coef.
  move.w	d0,(a0)+
  ext.l	d0
  lsl.w	#$8,d0
  divs.w	#$14f,d0	; d0=coef*256/(256+90).
  move.w	d0,(a0)+
  
.clear:
  move.l	a6,a0
  move.w	old_main1,d0
  jsr	cls_main  
  move.l	a6,a0
  move.w	old_y1,d0
  move.w	old_yend1,d1
  jsr	cls128

  move.w	new_coords+$8,old_y1
  move.w	new_coords+$c,old_yend1
  
.print_jelly_cube:
  move.w	new_coords+$2,d0
  move.w	new_coords+$a,d1
  move.w	new_coords+$6,d2
  move.w	new_coords+$e,d3
  move.w	new_coords+$12,a1
  move.l	a6,a0
  add.l	#$4,a0	; Jelly du fond sur le plan 2.
  jsr	jelly
  
  move.l	#buffer,a0
  move.w	new_coords+$2,(a0)+
  move.w	new_coords+$e,(a0)+
  move.w	new_coords,(a0)+
  move.w	new_coords+$c,(a0)+
  move.w	new_coords+$4,(a0)+
  move.w	new_coords+$c,(a0)+
  move.w	new_coords+$6,(a0)+
  move.w	new_coords+$e,(a0)+
  move.l	a6,a0
  add.l	#$2,a0	; Poly sur le plan 1.
  move.l	#buffer,a1
  move.w	#$4,d0
  jsr	polygone

  move.l	#buffer,a0
  move.w	new_coords,(a0)+
  move.w	new_coords+$8,(a0)+
  move.w	new_coords+$2,(a0)+
  move.w	new_coords+$a,(a0)+
  move.w	new_coords+$6,(a0)+
  move.w	new_coords+$a,(a0)+
  move.w	new_coords+$4,(a0)+
  move.w	new_coords+$8,(a0)+
  move.l	a6,a0
  add.l	#$2,a0	; Poly sur le plan 1.
  move.l	#buffer,a1
  move.w	#$4,d0
  jsr	polygone
      
  move.w	new_coords,d0
  move.w	new_coords+$8,d1
  move.w	new_coords+$4,d2
  move.w	new_coords+$c,d3
  move.w	new_coords+$10,a1
  move.l	a6,a0
  jsr	jelly
    
.print_la_main:
  move.w	(a5)+,d0
  move.w	d0,old_main1
  move.l	a6,a0
  jsr	main

  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test2
  sub.w	#$111,$ffff8240.w
.no_test2:

  move.l	screen1_ad,d0	; Ecran de travail.
  lsr.w	#$8,d0
  move.b	d0,$ffff8203.w
  swap.w	d0
  move.b	d0,$ffff8201.w

vbl2:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp

  cmp.w	#$0,music_flag	; Rejouer la music?
  beq.s	.no_music
  bsr	music+26	; Oui.
.no_music:

  moveq.l	#$7,d0	
  move.w	#$8240,a0	; Couleurs du haut.
  move.l	#colors,a1
.put_cols:
  move.l 	(a1)+,(a0)+
  dbra	d0,.put_cols

.timer_b:
  move.b	#$0,$fffffa1b.w	; Stop the timer.
  move.b	#y+7,$fffffa21.w ; Wait y lignes.
  move.b	#$8,$fffffa1b.w	; Event count mode.

  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test
  add.w	#$111,$ffff8240.w
.no_test:

  move.l	screen2_ad,a6

  move.l	#new_coords,a0
  move.l	#script,a5
  move.w	script_pos,d0
  move.w	d0,d1
  ext.l	d0
  add.w	d0,d0
  add.w	d1,d0
  add.w	d0,d0	; d0=script_pos*3.
  add.l	d0,a5	; a5 pointe sur les 3 parametres.
  addq.w	#$1,d1	; Prochaine position.
  cmp.w	script_length,d1; Script fini?
  ble.s	.script_ok
  moveq.l	#$0,d1	; Oui, alors recommencer.
.script_ok:
  move.w	d1,script_pos
.calc:
  move.w	#$ffd1,(a0)	; -47.
  add.w	#x,(a0)+
  move.l	#$ffffd100,d0	; -47*256.
  divs.w	#$14f,d0	; d0=-47*256/(256+90).
  add.w	#x,d0
  move.w	d0,(a0)+
  move.w	#$2f+x,(a0)+	; 47.
  move.l	#$2f00,d0	; 47*256.
  divs.w	#$14f,d0	; d0=47*256/(256+90).
  add.w	#x,d0
  move.w	d0,(a0)+
  move.w	(a5)+,d0	; y.
  add.w	#y,d0
  move.w	d0,(a0)+
  sub.w	#y,d0
  ext.l	d0
  lsl.w	#$8,d0
  divs.w	#$14f,d0	; d0=y*256/(256+90).
  add.w	#y,d0
  move.w	d0,(a0)+
  move.w	#$20+y,(a0)+	; yend=32.
  move.l	#$2000,d0
  divs.w	#$14f,d0	; d0=yend*256/(256+90).
  add.w	#y,d0
  move.w	d0,(a0)+
  move.w	(a5)+,d0	; coef.
  move.w	d0,(a0)+
  ext.l	d0
  lsl.w	#$8,d0
  divs.w	#$14f,d0	; d0=coef*256/(256+90).
  move.w	d0,(a0)+
  
.clear:
  move.l	a6,a0
  move.w	old_main2,d0
  jsr	cls_main  
  move.l	a6,a0
  move.w	old_y2,d0
  move.w	old_yend2,d1
  jsr	cls128

  move.w	new_coords+$8,old_y2
  move.w	new_coords+$c,old_yend2
  
.print_jelly_cube:
  move.w	new_coords+$2,d0
  move.w	new_coords+$a,d1
  move.w	new_coords+$6,d2
  move.w	new_coords+$e,d3
  move.w	new_coords+$12,a1
  move.l	a6,a0
  add.l	#$4,a0	; Jelly du fond sur le plan 2.
  jsr	jelly
  
  move.l	#buffer,a0
  move.w	new_coords+$2,(a0)+
  move.w	new_coords+$e,(a0)+
  move.w	new_coords,(a0)+
  move.w	new_coords+$c,(a0)+
  move.w	new_coords+$4,(a0)+
  move.w	new_coords+$c,(a0)+
  move.w	new_coords+$6,(a0)+
  move.w	new_coords+$e,(a0)+
  move.l	a6,a0
  add.l	#$2,a0	; Poly sur le plan 1.
  move.l	#buffer,a1
  move.w	#$4,d0
  jsr	polygone

  move.l	#buffer,a0
  move.w	new_coords,(a0)+
  move.w	new_coords+$8,(a0)+
  move.w	new_coords+$2,(a0)+
  move.w	new_coords+$a,(a0)+
  move.w	new_coords+$6,(a0)+
  move.w	new_coords+$a,(a0)+
  move.w	new_coords+$4,(a0)+
  move.w	new_coords+$8,(a0)+
  move.l	a6,a0
  add.l	#$2,a0	; Poly sur le plan 1.
  move.l	#buffer,a1
  move.w	#$4,d0
  jsr	polygone
      
  move.w	new_coords,d0
  move.w	new_coords+$8,d1
  move.w	new_coords+$4,d2
  move.w	new_coords+$c,d3
  move.w	new_coords+$10,a1
  move.l	a6,a0
  jsr	jelly
    
.print_la_main:
  move.w	(a5)+,d0
  move.w	d0,old_main2
  move.l	a6,a0
  jsr	main

  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test2
  sub.w	#$111,$ffff8240.w
.no_test2:

  move.l	screen2_ad,d0	; Ecran de travail.
  lsr.w	#$8,d0
  move.b	d0,$ffff8203.w
  swap.w	d0
  move.b	d0,$ffff8201.w
  
  cmpi.b	#$39,$fffffc02.w
  bne	vbl1

stop_music:
  cmp.w	#$0,music_flag	; La music etait active?
  beq.s	.music_not_played
  moveq.l	#-$1,d0
  bsr	music
  bsr	music+22
.music_not_played:
  
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

  move.w	#$1,$452	; Deverouiller la vbl.
  
  bset.b	#$0,$484.w
  move.b	#$8,$fffffc02.w
  dc.w	$a009	; Le tank est de retour!
  
  clr.w	-(sp)
  trap	#$1

;**************************************************************************
timer_b:
  move.b	#$0,$fffffa1b.w	; Stop the timer.
  move.l	a0,-(sp)
  move.l	a1,-(sp)
  move.w	#$8240,a0	; Couleurs du bas.
  move.l	#low_colors,a1
  move.l 	(a1)+,(a0)+
  move.l 	(a1)+,(a0)+
  move.l 	(a1)+,(a0)+
  move.l 	(a1)+,(a0)+
  move.l 	(a1)+,(a0)+
  move.l 	(a1)+,(a0)+
  move.l 	(a1)+,(a0)+
  move.l 	(a1)+,(a0)+
  move.l	(sp)+,a1
  move.l	(sp)+,a0
  bclr.b	#$0,$fffffa0f.w	; Interruption finie.
  rte
  
;**************************************************************************
main:
  include	'c:\sources\dp6reset\main.s'
  Section TEXT
cls_main:
  include	'c:\sources\dp6reset\cls_main.s'
  Section TEXT
cls128:
  include	'c:\sources\dp6reset\cls128.s'
  Section TEXT
jelly:
  include	'c:\sources\dp6reset\jelly.s'
  Section TEXT
polygone:
  include	'c:\sources\dp6reset\polygone.s'
  
;**************************************************************************
  Section DATA
  
text:
  incbin	'c:\sources\dp6reset\text.xxx'
colors:
  dc.w	$334,$253,$000,$142
  dc.w	$000,$132,$000,$132
  dc.w	$223,$122,$420,$130
  dc.w	$532,$130,$754,$351

low_colors:
  dc.w	$aab,$95a,$000,$8b9
  dc.w	$000,$8a9,$000,$8a9
  dc.w	$99a,$223,$000,$000
  dc.w	$000,$000,$66f,$000
script_length:
  dc.w	1023
script:
  incbin	'c:\sources\dp6reset\courbes.xxx'
music_flag:
  dc.w	0
music:
  incbin	'c:\sources\dp6reset\groovy.mus'
  
;**************************************************************************
  Section BSS

buffer:
  ds.w	16
old_main1:
  ds.w	1  
old_y1:
  ds.w	1  
old_yend1:
  ds.w	1  
old_main2:
  ds.w	1  
old_y2:
  ds.w	1  
old_yend2:
  ds.w	1  
script_pos:
  ds.w	1  
new_coords:
  ds.w	10  
old_res:
  ds.w	1
old_sync:
  ds.w	1
old_screen:
  ds.l	1
old_colors:
  ds.l	8
  
screen1_ad:
  ds.l	1
screen2_ad:
  ds.l	1
screens:
  ds.l	16064
  