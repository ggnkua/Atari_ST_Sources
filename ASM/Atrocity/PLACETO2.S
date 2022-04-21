***   Ecran EUROPARK Demo   ***
*** ZANAK / ATROCITY - 8/94 ***

	opt	o+

Resolution	equ	$62	;63 pour 256c
Taille_ecran	equ	$5a080
Points	equ	20
Cos	equ	64
Centre_X	equ	384
Centre_Y	equ	120
Save_size	equ	3001
Ligne_seq	equ	%1111101101101111

	section text
Mshrink:
	move.l	4(sp),a0
	move.l	12(a0),d0
	add.l	20(a0),d0
	add.l	28(a0),d0
	addi.l	#256,d0
	addi.l	#256,d0
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	move.w	#0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi	Bye
	
Superviseur:	
	pea	0.w
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

Memorisation_des_ecrans:
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,Old_ecran_physique
	
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,Old_ecran_logique

Get_old_resolution:
	move.w	#-1,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	move.w	d0,Old_rez

Switch_off_keyboard:
	move.b	$484.w,keyboard_buffer
	clr.b	$484.w
	
Switch_off_and_hide_mouse_cursor:
	dc.w	$a00a
	move.b	#$12,$fffffc02.w

Put_screen_in_white:
	pea	Text(pc)
	move.w	#$9,-(sp)
	trap	#1
	addq.l	#6,sp

Create_screen1:
	move.l	#Size1,d0
	addi.l	#256,d0
	clr.b	d0
	move.l	d0,Screen1
	
Create_screen2:
	move.l	#Size2,d0
	addi.l	#256,d0
	clr.b	d0
	move.l	d0,Screen2

set_screens:
	move.w	#Resolution,-(sp)
	move.w	#3,-(sp)
	move.l	Screen1,-(sp)
	move.l	Screen2,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#14,sp

;Initialisation_3D:
;	clr.w	(a5)+
;	clr.w	(a5)+
;	move.l	Screen1,d6
;	move.l	d6,-(sp)
;	move.l	d6,(a5)+
;	clr.l	(a5)
;	bsr	Eff_ecran
;	
;	move.l	Screen2,d6
;	clr.b	d6
;	move.l	d6,(Save_size-1)*4(a5)
;	clr.l	Save_size*4(a5)
;	bsr	Eff_ecran
	
************************************************************
	bsr.s	Initialisation_des_256_couleurs
;	bsr.s	Big_alec_init
;	bsr.s	Fade_screen_blanc_noir
;	bsr	Affiche_ATROCITY
;	bsr	Affiche_un_fond_en_couleur		
;	bsr.s	Swap
;	bsr	Fade_fond_noir_bleu

	bsr	Generation_du_Sin_et_Cos			
	bsr	Trois_D
		
Press_bar:	cmpi.b	#$39+$80,$fffffc02.w
	bne.s	Press_bar
	
;	bsr	Fade_screen_noir_blanc
;	bsr.s	Big_alec_stop
	bsr	Bye

************************************************************

Initialisation_des_256_couleurs:
	lea	$ffff9800.w,a0
	move.l	#$ff,d0
couleurs	clr.l	(a0)+
	dbf	d0,couleurs
	rts
	
Big_alec_init:
	moveq	#1,d0
	bsr	Big_alec_music
	
Call_big_alec_music:
	move.l	#big_alec_music+8,$4d2.w
	rts
	
Big_alec_stop:
Clear_three_voices:
	clr.l	$4d2.w
	moveq	#0,d0
	bsr	big_alec_music
	movea.w	#$8800,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts
	
swap:	movea.l	screen2,a0
	movea.l	screen1,a1
	move.l	#Taille_ecran,d0
swapp:	move.l	(a0)+,(a1)+
	dbf	d0,swapp
	rts
	
Fade_screen_blanc_noir:
	move.b	#$ff,d6
Fade_bn:	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	move.b	d6,$ffff9800.w
	move.b	d6,$ffff9801.w
	move.b	d6,$ffff9803.w
	sub.b	#1,d6
	cmp.b	#0,d6
	bne	Fade_bn
	rts
	
Affiche_un_Fond_en_couleur:
	clr.l	d1
	move.b	d1,$ffff9bfc.w
	move.b	d1,$ffff9bfd.w
	move.b	d1,$ffff9bff.w
	move.l	#Taille_ecran,d0
	move.l	#$ff,d1
	movea.l	screen1,a0
	move.l	$466.w,d2
Fond:	move.b	d1,(a0)+
vbl:	cmp.l	$466.w,d2
	beq.b	vbl	
	sub.l	#1,d0
	cmp.l	#0,d0
	bne	Fond
	rts

Fade_fond_noir_bleu:
	move.b	#$ff,d6
	move.w	#0,d5
Fade_fond_nb:	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	move.b	d5,$ffff9bfc.w
;	move.b	d5,$ffff9bfd.w
;	move.b	d5,$ffff9bff.w
	add.w	#1,d5
	cmp.b	d5,d6
	bne	Fade_fond_nb
	rts

Fade_screen_noir_blanc:
	move.b	#$ff,d6
	move.w	#0,d5
Fade_nb:	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	move.b	d5,$ffff9800.w
	move.b	d5,$ffff9801.w
	move.b	d5,$ffff9803.w
	add.w	#1,d5
	cmp.w	d5,d6
	bne	Fade_nb
	rts

Affiche_ATROCITY
	move.l	#$ff0f,$ffff9800.w
	lea	image+1664,a0
	movea.l	screen1,a1
;	sub.w	#1664,a1
	move.w	#32000,d1
Aff_image	move.w	(a0)+,(a1)+
	dbf	d1,aff_image
	rts	
	
Generation_du_Sin_et_Cos:
	lea	SIN(pc),a2
Make:	lea	Sincos+64(a5),a1
	
	movea.l	a1,a0
	moveq	#31,d7
Sin_1:	move.b	(a2)+,d5
	move.w	d5,-(a1)
	move.w	d5,(a0)+
	dbf	d7,Sin_1
	
	movea.l	a1,a6
	moveq	#95,d7
Sin_2:	move.w	(a1)+,(a0)
	neg.w	(a0)+
	dbf	d7,Sin_2
	rts
	
Trois_D:	movea.l	$432.w,a5
	addq.b	#2,(a5)
	moveq	#0,d7
	move.b	(a5)+,d7
	movea.l	a6,a0
	adda.w	d7,a0
	addq.b	#3,(a5)
	move.b	(a5)+,d7
	andi.w	#$00fe,d7
	movea.l	a6,a1
	adda.w	d7,a1

	lea	Fin_coord(pc),a3
	moveq	#Points,d6

Calcul_des_points:
	move.b	-(a3),d1
	move.b	-(a3),d0
	ext.w	d0
	ext.w	d1
	
	move.w	d0,d2
	muls.w	Cos(a0),d0
	muls.w	(a0),d2
	asl.w	#7,d1
	
	move.w	d1,d3
	move.w	d2,d4
	muls.w	(a1),d4
	muls.w	Cos(a1),d1
	sub.l	d4,d1
	
	muls.w	(a1),d3
	muls.w	Cos(a1),d2
	add.l	d3,d2
	
	asr.l	#7,d1
	asr.l	#7,d2
	
	moveq	#127,d4
	asr.w	#8,d2
	sub.w	d2,d4
	divs	d4,d0
	divs	d4,d1
	addi.w	#Centre_X,d0
	addi.w	#Centre_Y,d1
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	subq.w	#1,d6
	bne.s	Calcul_des_points	
	
Affichage:
	eori.w	#Size1*4,(a5)
;	movea.l	Screen1,a5
	adda.w	(a5)+,a5
	movea.l	a5,a4
	movea.l	a5,a3
Cls:	move.l	(a3)+,d0
	beq.s	Ligne
	movea.l	d0,a2
	move.w	d6,(a2)
	bra.s	Cls
	
Ligne:	move.l	a4,d5
	lsr.w	#8,d5
	move.l	d5,$ffff8200.w
	move.w	#Ligne_seq,d6
	
Tra‡age_de_la_ligne:
	bcs.s	Lbcl
	move.w	(sp)+,d0
	move.w	(sp)+,d1
Lbcl:	move.w	(sp)+,d2
	move.w	(sp)+,d3

Traces:	movem.w	d0-3/d6,-(sp)
	move.l	d0,d4
	sub.w	d2,d4
	bpl.s	Traces_1
	neg.w	d4
	exg	d1,d3
	move.w	d2,d0
	
Traces_1:	move.w	#160,d6
	sub.w	d1,d3
	bpl.s	Traces_2
	neg.w	d3
	neg.w	d6
	
Traces_2	mulu.w	#160,d1
	move.l	a4,a0
	ror.l	#4,d0
	lsl.w	#3,d0
	add.w	d0,d1
	adda.w	d1,a0
	rol.l	#4,d0
	not.w	d0
	moveq	#0,d1
	bset	d0,d1
	swap	d1
	cmp.w	d4,d3
	bgt.s	Traces_suite_1
	
	move.w	d4,d2
	move.w	d4,d5
	lsr.w	#1,d2
	
Traces_3:	or.w	d1,(a0)
	move.l	a0,(a5)+
	rol.w	#1,d1
	bcc.s	Traces_4
	subq.l	#8,a0
	
Traces_4:	sub.w	d3,d2
	bgt.s	Traces_5
	adda.w	d6,a0
	add.w	d4,d2
	
Traces_5:	subq.w	#1,d5
	bgt.s	Traces_3
	
Traces_fin:	movem.w	(sp)+,d0-3/d6
	move.w	d3,d1
	move.w	d2,d0
	add.w	d6,d6
	bne.s	Tra‡age_de_la_ligne
	clr.l	(a5)
	rts
	
Traces_suite_1:
	move.w	d3,d2
	move.w	d3,d5
	lsr.w	#1,d2
Traces_suite_2:
	or.w	d1,(a0)
	move.l	a0,(a5)+
	adda.w	d6,a0
	sub.w	d4,d2
	bgt.s	Traces_suite_3
	add.w	d3,d2
	rol.w	#1,d1
	bcc.s	Traces_suite_3
	subq.l	#8,a0
Traces_suite_3:
	subq.w	#1,d5
	bpl.s	Traces_suite_2
	bra.s	Traces_fin
	
Eff_ecran:	clr.w	-(sp)
	move.l	d6,-(sp)
	move.l	d6,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	rts
Wait	tst.b	$fffffc02.w
	ble.s	Wait
	move.l	(sp)+,$70.w
	move.l	(sp)+,d6
	rts	
	
************************************************

Bye:	
Switch_on_and_show_mouse_cursor:
	dc.w	$a009
	move.b	#$08,$fffffc02.w
	
Switch_on_interrupts_keyboard:
	move.b	Keyboard_buffer,$484.w
	
Restaure_old_ecrans_et_resolutions:
	move.w	Old_rez,-(sp)
	move.w	#3,-(sp)
	move.l	Old_ecran_physique,-(sp)
	move.l	Old_ecran_logique,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#14,sp
	
User:
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#2,sp
	
Pterm:
	clr.w	-(sp)
	trap	#1
	
************************************************************
	section data
Debut_Coord:
	dc.b	-50,-20
	dc.b	-30,15
	dc.b	-20,-2
	dc.b	-20,15
	dc.b	15,15
	dc.b	25,5
	dc.b	30,15
	dc.b	40,15
	dc.b	20,-20
	dc.b	10,-20
	dc.b	20,-5
	dc.b	10,5
	dc.b	-10,5
	dc.b	-10,-10
	dc.b	5,-10
	dc.b	5,-20
	dc.b	-20,-20
	dc.b	-30,-3
	dc.b	-40,-20
	dc.b	-50,-20
Fin_coord:

SIN:	dc.b	128,128,127,126,125,123,122,119
	dc.b	117,117,111,108,105,101,097,093
	dc.b	088,084,079,074,068,063,058,052
	dc.b	046,040,034,028,022,016,009,003	
		
Sincos:	rs.w	160

Big_alec_music:
	incbin	e:\totf\bigalec.snd

Text:
	dc.b	$1b,"E"
	dc.b	0
Image:	incbin	e:\totf\atrocity.tpi
	even
		
************************************************************
	section bss

x1:	ds.w	1
x2:	ds.w	1
y1:	ds.w	1
y2:	ds.w	1

Old_ecran_physique:
	ds.w	2
Old_ecran_logique:
	ds.w	2
Old_rez:
	ds.w	1
Keyboard_buffer:
	ds.b	1
Size1:
	ds.w	768*240+128
Size2:
	ds.w	768*240+128
Screen1:
	ds.w	2
Screen2:
	ds.w	2
			
	end
		
		
		
	