;---------------------------------------------------------------------;
;	     Ecran pour la Transbeauce demo II		;
;	          ska from Futur Minds		;
; 					;
; 	  (avec scrolling hardware, version 2.4)		;
; Version 2.2: compatible STE+STF sauf roms 85 et 85/86 (et 87 chaud)	;
; Version 2.3: compatible STE+STF sauf roms 85/86 seulement	;
; Version 2.4: compatible STE+STF sans excep.(stabilit‚ 100% parfaite);
;---------------------------------------------------------------------;
; Tourne sans le systŠme: pas de TRAP, pas de variables systŠmes etc..;
; termine par un ILLEGAL. Utilise 406000 octets.		;
;---------------------------------------------------------------------;

	TEXT

degrade	MACRO
mac	set	\1
	rept	8
	dcb.w	18,mac
mac	set	mac+\2
	endr
	ENDM

	dc.w	$a00a	; … enlever

	clr.l	-(a7)	; 
	move.w	#$20,-(a7)	; un trap ici et
	trap	#1	; seulement ici.
	addq	#6,a7	;
	move.l	d0,-(a7)	;

	clr.b	$fffffc02.w	; plus de buffer pour le 6301.

	clr.w	sunylogo+2+7*2
	clr.w	sunylogo+2+8*2

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,sauve_pal

	move.w	$ffff8260.w,sauve_reso
	move.b	$ffff8201.w,v_bas_ad
	move.b	$ffff8203.w,v_bas_ad+1

	clr.l	$ffff8240.w
	clr.l	$ffff8244.w
	clr.l	$ffff8248.w
	clr.l	$ffff824c.w
	clr.l	$ffff8250.w
	clr.l	$ffff8254.w
	clr.l	$ffff8258.w
	clr.l	$ffff825c.w

	move.b	startecr+3,d0		; en cas de STF:
	tst.b	d0		; octet faible
	beq.s	not_ff820d		; addresse ecran
	clr.b	startecr+3		; toujours = 0
	add.b	#1,startecr+2

not_ff820d	move.b	startecr+2,$ffff8203.w
	move.b	startecr+1,$ffff8201.w
	clr.b	$ffff820d.w		; STE => 820D=00

	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d0
	lea	text,a1
	lea	largeur,a2
	movem.l	d0-d7/a0-a5,stxtpil

	lea	mvmnt,a3		; pile sprites
	lea	message_box+11160,a4
	movem.l	d0-d7/a0-a6,sprite_pil

;---------------------------------------------------------------------;
;	Presentation, initialisations....		;
;---------------------------------------------------------------------;

main_prog	lea	pleezwet,a0
	move.l	startecr,a1

	move.w	#20*170-1,d0
copie_wet	move.w	(a0)+,6(a1)
	lea	8(a1),a1
	dbf	d0,copie_wet

	jsr	presentation		; La presentation!

	move.l	startecr,a1

	move.w	#18-1,d1		; 18 logos
	lea	sunylogo+34,a0	; Logos pr‚d‚cal‚s
aff_logo	move.w	#20*100-1,d0
predecale	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	addq.w	#2,a1
	dbf	d0,predecale
	lea	sunylogo+34,a0
	dbf	d1,aff_logo

	move.l	startecr,a0
	adda.l	#16000,a0
	moveq	#-1,d3
	rept	17
	addq	#1,d3
	move.w	d3,d4
	move.l	a0,a1
	bsr	decalrox
	move.l	a1,a0
	adda.l	#16000,a0
	move.w	d4,d3
	endr

	lea	colors_intro+378,a0
	move.w	#$0,(a0)+
	move.w	#$222,(a0)+
	move.w	#$333,(a0)+
	move.w	#$444,(a0)+
	move.w	#$555,(a0)+
	move.w	#$666,(a0)+
	move.w	#$777,(a0)+
	move.w	#$777,(a0)+
	move.w	#$777,(a0)

wait_pause	cmpi.b	#$b9,$fffffc02.w
	bne.s	wait_pause

	lea	colors_intro,a0
	move.w	#99,d0
efface_rast	bsr	synchro
	clr.l	(a0)+
	dbf	d0,efface_rast

	move.l	startecr,a0
	move.l	a0,a1
	adda.l	#9*32000-8,a0
	adda.l	#32000,a1
	move.w	#26-1,d0
bloc16	move.w	#20-1,d1
line16	move.l	(a1)+,(a0)+
	dbf	d1,line16
	dbf	d0,bloc16

	not.w	flag_2
	move.b	#8,$ffff8800.w
	clr.b	$ffff8802.w
	move.b	#9,$ffff8800.w
	clr.b	$ffff8802.w
	move.b	#10,$ffff8800.w
	clr.b	$ffff8802.w

	move.w	#50,d0
yiipie3	bsr	synchro
	dbf	d0,yiipie3

	move.l	sauve_vblz,$70.w
	moveq	#0,d0
	jsr	zik_2

	move.l	sauve_hbl,$120.w
	move.b	mfp_7,$fffffa07.w
	move.b	mfp_9,$fffffa09.w

	bra	ca_y_est

decalrox	move.l	a1,a0
	move.w	#100-1,d1
decimg	moveq	#0,d2
	roxl	#1,d2
pixdec1	set	156
	rept	20
	roxl	pixdec1(a0)
pixdec1	set	pixdec1-8
	endr
	move.w	#-1,156(a0)
	roxl	#1,d2
pixdec2	set	154
	rept	20
	roxl	pixdec2(a0)
pixdec2	set	pixdec2-8
	endr
	move.w	#-1,154(a0)
	roxl	#1,d2
pixdec3	set	152
	rept	20
	roxl	pixdec3(a0)
pixdec3	set	pixdec3-8
	endr
	move.w	#-1,152(a0)
	roxl	#1,d2
	adda.l	#160,a0
	dbf	d1,decimg
	dbf	d3,decalrox
	rts
	
ca_y_est	move.w	#$2700,sr		; Plus d'interruptions

	move.l	$70.w,vbl		; On sauve la VBL
	lea	vsync,a0		; puis on met la notre
	move.l	a0,$70.w

	lea	$fffffa00.w,a0	; On sauve les registres
	move.b	7(a0),mfp_7		; du MFP
	move.b	9(a0),mfp_9
	clr.b	7(a0)		; plus de Timers
	clr.b	9(a0)		;

	moveq	#1,d0
	jsr	zik

	moveq	#0,d0
	moveq	#2,d1

	lea	$ffff820a.w,a0	; 60/50 Hz
	lea	$ffff8260.w,a1	; Monochrome/couleur

	move.b	d1,(a0)
	move.b	d0,(a1)


	move.w	#$2700,sr
	move.l	startecr,current_adr


; Routine principale de fullscreen.

	lea	linewidth,a2

	moveq	#0,d3	; et oui, on est oblig‚ de
	moveq	#0,d2	; mettre le premier calcul
	moveq	#0,d4	; hardscroll ici...
	move.l	(a2)+,d2
	cmp.l	#-1,d2
	bne.s	ceypanul0
	lea	linewidth,a2
	move.l	(a2)+,d2

ceypanul0	add.l	startecr,d2
	move.l	d2,cur_adr
	move.b	d2,d3
	lsl.l	#5,d3
	lea	table,a3
	adda.l	d3,a3
	move.l	(a3)+,d4
	lsr.l	#8,d2
	sub.w	d4,d2
	lea	un,a5

	rept	15
	addq	#2,a5
	move.l	(a3)+,(a5)+
	endr

	move.b	d2,$ffff8203.w	; toute premiŠre
	lsr.w	#8,d2		; addresse ‚cran.
	move.b	d2,$ffff8201.w

	move.w	#$e7c,d2
	lea	$ffff825e.w,a6

	stop	#$2300		; Synchronisation VBL
full	stop	#$2300
	
	jsr	sprites		; 20

	move.l	#0,$ffff8240.w
	move.l	#0,$ffff8244.w
	move.l	#0,$ffff8248.w
	move.l	#0,$ffff824c.w
	move.l	#0,$ffff8250.w
	move.l	#0,$ffff8254.w
	move.l	#0,$ffff8258.w
	move.l	#0,$ffff825c.w

	lea	colors,a4

	dcb.w	4295-48-2-3799-5-226-20-3,$4e71

	move.b	d0,(a0)
	dcb.w	18,$4e71
	move.b	d1,(a0)
	dcb.w	15,$4e71

	moveq	#24,d0		; synchronisation
	sub.b	$ffff8209.w,d0	; parfaite
	lsr.l	d0,d0

	dcb.w	79-5,$4e71		; bord droit 1ere ligne non supprim‚

un	jsr	b
deuw	jsr	a
trois	jsr	a
quatre	jsr	a
cinq	jsr	a
six	jsr	a
sept	jsr	a		; routine hard
huit	jsr	a		; en .... 15 lignes...
neuf	jsr	a
dix	jsr	a
onze	jsr	a
douze	jsr	a
treize	jsr	a
quatorze	jsr	a
quinze	jsr	a

	bsr	transfer

main_rout	moveq	#0,d3
	moveq	#0,d2
	moveq	#0,d4
	move.l	(a2)+,d2		; exemple: d2=E89A0
	cmp.l	#-1,d2
	bne.s	ceypanul
	lea	linewidth,a2
	move.l	(a2)+,d2

ceypanul	add.l	startecr,d2
	move.l	d2,cur_adr
	move.b	d2,d3		; d3=A0
	lsl.l	#5,d3		; d3=d3x32=$1400
	lea	table,a3
	adda.l	d3,a3
	move.l	(a3)+,d4		; d4.b=D
	lsr.l	#8,d2		; d2.b=89	
	sub.w	d4,d2		; d2=d2-d4=7C
	lea	un,a5

	rept	15
	addq	#2,a5
	move.l	(a3)+,(a5)+
	endr

hop	move.b	d2,$ffff8203.w
	lsr.w	#8,d2
	move.b	d2,$ffff8201.w

	jsr	scrol

	movem.l	d0-d7/a0-a6,sauvreg
	jsr	remet
	movem.l	sauvreg,d0-d7/a0-a6

	jsr	zik+6

	cmpi.b	#$52,$fffffc02.w	; temps machine:
	beq.s	cpu_time		; -Insert-
	cmpi.b	#$39,$fffffc02.w
	beq	fin

	bra	full

cpu_time	move.w	#$7,$ffff8240.w
	bra	full

;---------------------------------------------------------------------;
;      Routines de lignes Hard. Certifi‚es 100% hyper-stables	;
;	 (Note: c'est aussi hyper-secret, hum ?)		;
;---------------------------------------------------------------------;

a	dcb.w	119,$4e71
	rts

b	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	dcb.w	12,$4e71
	move.b	d1,(a1)
	nop
	nop
	nop
	move.b	d0,(a1)
	dcb.w	95,$4e71
	rts

c	dcb.w	15+3+4+89,$4e71
	move.b	d0,(a0)
	move.b	d1,(a0)
	dcb.w	4,$4e71
	rts

e	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	dcb.w	12,$4e71
	move.b	d1,(a1)
	nop
	nop
	nop
	move.b	d0,(a1)
	dcb.w	87,$4e71
	move.b	d0,(a0)
	move.b	d1,(a0)
	dcb.w	4,$4e71
	rts

;---------------------------------------------------------------------;
;	Fin de la d‚mo, on restaure quelques trucs	;
;---------------------------------------------------------------------;

fin	move.l	vbl,$70.w		; on restaure la VBL
	move.b	mfp_7,$fffffa07.w	; les Timers
	move.b	mfp_9,$fffffa09.w

	moveq	#0,d0
	jsr	zik

	move.b	#8,$ffff8800.w
	clr.b	$ffff8802.w
	move.b	#9,$ffff8800.w
	clr.b	$ffff8802.w
	move.b	#10,$ffff8800.w
	clr.b	$ffff8802.w

	move.w	#$2300,sr		; on remet les interrptions

	movem.l	sauve_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.w	sauve_reso,$ffff8260.w
	move.b	v_bas_ad,$ffff8201.w
	move.b	v_bas_ad+1,$ffff8203.w


	illegal


;---------------------------------------------------------------------;
;	      Routine scrollers du fond		;
;---------------------------------------------------------------------;

scrol	movem.l	d0-d7/a0-a5,sauvreg
	movem.l	stxtpil,d0-d7/a0-a5

	move.l	sauvecol,a4
	tst.b	d1
	beq	scrolc

	cmp.b	d2,d1
	bhi	scrolb
	bsr	decal
	move.w	(a4)+,(a6)
	add.w	#36,a4
	bsr	decal
	move.w	(a4)+,(a6)
	add.w	#36,a4
	bsr	decal
	move.w	(a4)+,(a6)
	add.w	#36,a4
	bsr	decal
	move.w	(a4)+,(a6)
	bra	scrolc

scrolb	bsr	decal
	move.w	(a4)+,(a6)
	add.w	#36,a4
	bsr	decal
	move.w	(a4)+,(a6)
	add.w	#36,a4
	bsr	decal
	move.w	(a4)+,(a6)
	add.w	#36,a4
	bsr	decal
	move.w	(a4)+,(a6)
	add.b	#1,d2
	bra	scrol2

scrolc	move.w	#1,d2
	lea	buffer,a3
	lea	fontes,a0
	move.b	(a1)+,d0			* 65 < d0 < 108
	tst.b	d0
	bne	conti
	lea	text,a1
	move.b	(a1)+,d0

conti
	lea	largeur,a2
	move.b	-65(a2,d0.w),d1			*largeur du caractere?

rang_5	cmp.b	#105,d0
	blo	rang_4
	sub.b	#105,d0
	lsl.w	#4,d0
	adda.l	d0,a0
	adda.l	#160*20,a0
	bra	scrol2

rang_4	cmp.b	#95,d0
	blo	rang_3
	sub.b	#95,d0
	lsl.w	#4,d0
	adda.l	d0,a0
	addq.w	#6,a0
	bra	scrol2

rang_3	cmp.b	#85,d0				* 85 < d0 < 94
	blo	rang_2
	sub.b	#85,d0				*  0 < d0 < 9
	lsl.w	#4,d0				* d0*16 ( x32 pixels)
	adda.l	d0,a0
	addq.w	#4,a0
	bra	scrol2
		
rang_2	cmp.b	#75,d0
	blo	rang_1
	sub.b	#75,d0
	lsl.w	#4,d0
	adda.l	d0,a0
	addq.w	#2,a0
	bra	scrol2

rang_1	sub.b	#65,d0
	lsl.w	#4,d0
	adda.l	d0,a0
	
scrol2	cmp.b	#1,d2
	beq	affich1
	cmp.b	#2,d2
	beq	affich2
	cmp.b	#3,d2
	beq	affich3
	cmp.b	#4,d2
	beq	affich4
	cmp.b	#5,d2
	beq	affich5
	cmp.b	#6,d2
	beq	affich6
	cmp.b	#7,d2
	beq	affich7
	bra	affich8

affich1
cc	set	0
	rept	20
	move.b	cc(a0),d3
	lsr.b	#4,d3
	and.b	#240,cc+39(a3)
	or.b	d3,cc+39(a3)
cc	set	cc+40
	lea	120(a0),a0
	endr
	sub.w	#2400,a0
	movem.l	d0-d7/a0-a5,stxtpil
	movem.l	sauvreg,d0-d7/a0-a5
	rts

affich2
dd	set	0
	rept	20
	move.b	dd(a0),d3
	and.b	#240,dd+39(a3)
	or.b	d3,dd+39(a3)
dd	set	dd+40
	lea	120(a0),a0
	endr
	sub.w	#2400,a0
	movem.l	d0-d7/a0-a5,stxtpil
	movem.l	sauvreg,d0-d7/a0-a5
	rts

affich3
ee	set	0
	rept	20
	move.b	ee+1(a0),d3
	lsr.b	#4,d3
	and.b	#240,ee+39(a3)
	or.b	d3,ee+39(a3)
ee	set	ee+40
	lea	120(a0),a0
	endr
	sub.w	#2400,a0
	movem.l	d0-d7/a0-a5,stxtpil
	movem.l	sauvreg,d0-d7/a0-a5
	rts

affich4
ff	set	0
	rept	20
	move.b	ff+1(a0),d3
	and.b	#240,ff+39(a3)
	or.b	d3,ff+39(a3)
ff	set	ff+40
	lea	120(a0),a0
	endr
	sub.w	#2400,a0
	movem.l	d0-d7/a0-a5,stxtpil
	movem.l	sauvreg,d0-d7/a0-a5
	rts

affich5
gg	set	0
	rept	20
	move.b	gg+8(a0),d3
	lsr.b	#4,d3
	and.b	#240,gg+39(a3)
	or.b	d3,gg+39(a3)
gg	set	gg+40
	lea	120(a0),a0
	endr
	sub.w	#2400,a0
	movem.l	d0-d7/a0-a5,stxtpil
	movem.l	sauvreg,d0-d7/a0-a5
	rts

affich6
hh	set	0
	rept	20
	move.b	hh+8(a0),d3
	and.b	#240,hh+39(a3)
	or.b	d3,hh+39(a3)
hh	set	hh+40
	lea	120(a0),a0
	endr
	sub.w	#2400,a0
	movem.l	d0-d7/a0-a5,stxtpil
	movem.l	sauvreg,d0-d7/a0-a5
	rts

affich7
ii	set	0
	rept	20
	move.b	ii+9(a0),d3
	lsr.b	#4,d3
	and.b	#240,ii+39(a3)
	or.b	d3,ii+39(a3)
ii	set	ii+40
	lea	120(a0),a0
	endr
	sub.w	#2400,a0
	movem.l	d0-d7/a0-a5,stxtpil
	movem.l	sauvreg,d0-d7/a0-a5
	rts

affich8
jj	set	0
	rept	20
	move.b	jj+9(a0),d3
	and.b	#240,jj+39(a3)
	or.b	d3,jj+39(a3)
jj	set	jj+40
	lea	120(a0),a0
	endr
	sub.w	#2400,a0
	movem.l	d0-d7/a0-a5,stxtpil
	movem.l	sauvreg,d0-d7/a0-a5
	rts

decal	clr.l	d7
ba	set	0
	rept	20
	roxl	ba+38(a3)
	roxl	ba+36(a3)
	roxl	ba+34(a3)
	roxl	ba+32(a3)
	roxl	ba+30(a3)
	roxl	ba+28(a3)
	roxl	ba+26(a3)
	roxl	ba+24(a3)
	roxl	ba+22(a3)
	roxl	ba+20(a3)
	roxl	ba+18(a3)
	roxl	ba+16(a3)
	roxl	ba+14(a3)
	roxl	ba+12(a3)
	roxl	ba+10(a3)
	roxl	ba+8(a3)
	roxl	ba+6(a3)
	roxl	ba+4(a3)
	roxl	ba+2(a3)
	roxl	ba(a3)
ba	set	ba+40
	roxl.l	#1,d7
	endr
	rts

;---------------------------------------------------------------------;
;     Routine exclusivement pour l'AFFICHAGE des scrollers du fond	;
;---------------------------------------------------------------------;

transfer	move.l	a2,sauve_a2
	move.l	a3,sauve_a3
	move.l	a4,sauve_a4

	move.l	moving_scrol,a4

	moveq	#0,d6
	moveq	#0,d7
	move.w	(a4)+,d7
	cmpi.w	#-1,d7
	bne.s	daccord

	lea	moving_data,a4
	move.w	(a4)+,d7

daccord	lea	buffer,a2
	move.l	cur_adr,a3
	suba.l	#160*5,a3		; ca marche!
	move.w	d7,d6
	adda.l	d7,a3

	move.w	(a4)+,d7
	move.l	a4,moving_scrol
	move.l	sauve_a4,a4
	add.w	d7,a4

transfer_b2	moveq	#20,d7		; 12 pffff....
transfer_22
tr2	set	0
	rept	20
	move.w	(a2)+,tr2+6(a3)
tr2	set	tr2+8
	endr
	lea	160(a3),a3
	dbf	d7,transfer_22

	lea	buffer,a2
	move.l	cur_adr,a3
	move.l	a3,efface_adr
	adda.l	#160*(21-5),a3	; -5<valeur<15
	adda.l	d6,a3

	movem.l	d0-d7,sauvreg
	movem.l	sunylogo+2,d0-d7
	move.w	(a4)+,d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	sauvreg,d0-d7

	move.w	#10-1,d6
transfer_b	move.w	#20,d7
transfer_2
tr	set	0
	rept	20
	move.w	(a2)+,tr+6(a3)
tr	set	tr+8
	endr
	lea	160(a3),a3
	move.w	(a4)+,(a6)
	dbf	d7,transfer_2
	lea	buffer,a2
	dbf	d6,transfer_b

	add.w	#36,a4
	move.l	a4,sauvecol
	move.l	sauve_a2,a2
	move.l	sauve_a3,a3
	rts

;---------------------------------------------------------------------;
;        Routine de restauration du fond sous la Bouncing-box	;
;---------------------------------------------------------------------;

remet	move.l	addresses,a4	; on restore le fond
	lea.l	rewrite,a5		; avant tout. 12

	rept	17		; 16
	move.l	(a5)+,(a4)+		; 16*(11*(20+12+8)+8)=7168
	move.w	(a5)+,(a4)+		; 20 12
	addq.w	#2,a4		; 8
	move.l	(a5)+,(a4)+
	move.w	(a5)+,(a4)+		; 7168+12+16+20+20=7236
	addq.w	#2,a4
	move.l	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	addq.w	#2,a4
	move.l	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	addq.w	#2,a4
	move.l	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	addq.w	#2,a4
	move.l	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	addq.w	#2,a4
	move.l	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	addq.w	#2,a4
	move.l	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	addq.w	#2,a4
	move.l	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	addq.w	#2,a4
	move.l	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	addq.w	#2,a4
	move.l	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	addq.w	#2,a4
	lea	72(a4),a4
	endr
	rts			;16

;---------------------------------------------------------------------;
;  Routine d'affichage de la Bouncing-box, et m‚morisation du fond	;
;---------------------------------------------------------------------;

sprites	movem.l	d0-d7/a0-a6,sauvreg	; 136  le tout=15272 (3818)
	movem.l	sprite_pil,d0-d7/a0-a6	; 140

	moveq	#0,d0		; 4
	move.w	(a3)+,d0		; 8  mvmnt
	cmpi.w	#$ff,d0		; 8
	bne.s	it_is_ok		; taken:12 not:8
	lea	mvmnt,a3		; 12
	move.w	(a3)+,d0		; 8
	bra.s	ccc		; 12 8+12+8+12=40

it_is_ok	dcb.w	7,$4e71

ccc	move.l	cur_adr,a2		; 20 addresse ‚cran actuel.
	adda.w	d0,a2		; 8
	adda.w	#32,a2		; 12
	move.l	a2,addresses	; 20
	lea	rewrite,a0		; 12
	
	; On m‚morise le fond dans un buffer.

	rept	17		; 7168 (16) 17=7616
	move.l	(a2)+,(a0)+
	move.w	(a2)+,(a0)+
	addq.w	#2,a2
	move.l	(a2)+,(a0)+
	move.w	(a2)+,(a0)+
	addq.w	#2,a2
	move.l	(a2)+,(a0)+
	move.w	(a2)+,(a0)+
	addq.w	#2,a2
	move.l	(a2)+,(a0)+
	move.w	(a2)+,(a0)+
	addq.w	#2,a2
	move.l	(a2)+,(a0)+
	move.w	(a2)+,(a0)+
	addq.w	#2,a2
	move.l	(a2)+,(a0)+
	move.w	(a2)+,(a0)+
	addq.w	#2,a2
	move.l	(a2)+,(a0)+
	move.w	(a2)+,(a0)+
	addq.w	#2,a2
	move.l	(a2)+,(a0)+
	move.w	(a2)+,(a0)+
	addq.w	#2,a2
	move.l	(a2)+,(a0)+
	move.w	(a2)+,(a0)+
	addq.w	#2,a2
	move.l	(a2)+,(a0)+
	move.w	(a2)+,(a0)+
	addq.w	#2,a2
	move.l	(a2)+,(a0)+
	move.w	(a2)+,(a0)+
	addq.w	#2,a2
	lea	72(a2),a2
	endr

	move.l	addresses,a0	; 20
	lea	sprites_fm,a2	; 12

	move.l	(a2)+,(a0)+		; 7296 (a6)
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	lea	0(a2),a2
	lea	72(a0),a0

	; Rajout de 17 nops:

	move.l	(a4)+,a2		; 3 nops
	cmpa.l	#-1,a2		; 3 nops
	bne.s	on_continue		; not/yes:2/3
	lea	message_box,a4	; 3 nops
	move.l	(a4)+,a2		; 3 nops
	bra.s	ensuite		; 3 nops=11 nops
on_continue	dcb.w	8,$4e71		; 8+3=11 nops

ensuite	adda.l	#sprites_fm,a2	; 12
	rept	15		; 7752 (pour 17)
	move.l	(a2)+,(a0)+		; 7296 (a6)
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	lea	0(a2),a2
	lea	72(a0),a0
	endr

	lea	sprites_fm,a2	; 12

	move.l	(a2)+,(a0)+		; 7296 (a6)
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	lea	0(a2),a2
	lea	72(a0),a0

	movem.l	d0-d7/a0-a6,sprite_pil	; 136
	movem.l	sauvreg,d0-d7/a0-a6	; 140
	rts			; 16

;---------------------------------------------------------------------;
;	         Routines VBLs diverses		;
;---------------------------------------------------------------------;

synchro	move.w	flag,d6
synchro_2	cmp.w	flag,d6
	beq.s	synchro_2
	rts

	even
vsync	rte

	even
vsync_2	not.w	flag
	rte

;---------------------------------------------------------------------;
;		Pr‚sentation			;
;---------------------------------------------------------------------;

presentation	lea	fontesz,a0
	lea	textz,a1
	moveq	#0,d2
	lea	$ffff8250.w,a3
	movem.l	d0-d7/a0-a6,intro_pil
	move.w	#$555,(a3)

	move.b	$fffffa07.w,mfp_7
	move.b	$fffffa09.w,mfp_9
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w

	moveq	#1,d0
	jsr	zik_2

	clr.w	flag_2
	move.l	$70.w,sauve_vblz
	move.l	#debut,$70.w

	move.l	#colors_intro,sauvreg
	jsr	synchro
	lea	colors_intro,a6
	move.l	$120.w,sauve_hbl
	move.l	#hbl_present,$120.w

	move.b	#8,$fffffa1b.w
	move.b	#1,$fffffa21.w
	bset.b	#0,$fffffa07.w
	bset.b	#0,$fffffa13.w

	rts

;---------------------------------------------------------------------;
;	Routine Timer B de la pr‚sentation		;
;---------------------------------------------------------------------;

	even
hbl_present	move.l	sauvreg,a6
	move.w	(a6)+,d5
	move.w	d5,(a3)
	move.w	d5,2(a3)
	move.w	d5,4(a3)
	move.w	d5,8(a3)
	move.w	d5,6(a3)
	move.w	d5,$a(a3)
	move.w	d5,$e(a3)
	move.w	d5,$c(a3)
	move.l	a6,sauvreg
	bclr.b	#0,$fffffa0f.w
	rte

;---------------------------------------------------------------------;
;	Routine VBL de la pr‚sentation		;
;---------------------------------------------------------------------;

debut	movem.l	d0-d7/a0-a5,-(sp)
	movem.l	intro_pil,d0-d7/a0-a5

	not.w	flag

	move.l	#colors_intro,sauvreg

	lea	buffer_scrol,a4
	move.l	startecr,a5
	adda.l	#24*8*160-160,a5
	moveq	#8-1,d4
transcrol
bs	set	0
	rept	20
	move.w	bs+6(a4),bs+6(a5)
bs	set	bs+8
	endr
	lea	168(a4),a4
	lea	160(a5),a5
	dbf	d4,transcrol


	bsr	decal_scrol
	bsr	decal_scrol

	cmpi.b	#4,d2
	beq.s	lis_texte

	addq.w	#1,d2

	movem.l	d0-d7/a0-a5,intro_pil
	tst.w	flag_2
	bne.s	no_music
	jsr	zik_2+8
no_music	movem.l	(sp)+,d0-d7/a0-a5
	rte

lis_texte	moveq	#0,d0
	moveq	#0,d2
	move.b	(a1)+,d0
	cmpi.b	#255,d0
	bne.s	next_char
	lea	textz,a1
	move.b	(a1)+,d0

next_char	lea	fontesz,a0
	subi.b	#65,d0	; 65<val<91 => 0<val<26

	cmpi.b	#39,d0
	bls.s	pas_2_rang
	adda.w	#7*160,a0

pas_2_rang	btst	#0,d0
	beq.s	pair
	addq.w	#1,a0

pair	andi.b	#254,d0
	lsl.w	#2,d0
	add.w	d0,a0

	lea	buffer_scrol,a2
letter	set	0
letter2	set	0
	rept	8
	move.b	letter2(a0),167+letter(a2)
letter	set	letter+168
letter2	set	letter2+160
	endr

	addq.w	#1,d2

	movem.l	d0-d7/a0-a5,intro_pil
	tst.w	flag_2
	bne.s	no_music2
	jsr	zik_2+8
no_music2	movem.l	(sp)+,d0-d7/a0-a5
	rte


decal_scrol	lea	buffer_scrol,a2
k	set	0
	rept	8
	roxl	166+k(a2)
	roxl	158+k(a2)
	roxl	150+k(a2)
	roxl	142+k(a2)
	roxl	134+k(a2)
	roxl	126+k(a2)
	roxl	118+k(a2)
	roxl	110+k(a2)
	roxl	102+k(a2)
	roxl	94+k(a2)
	roxl	86+k(a2)
	roxl	78+k(a2)
	roxl	70+k(a2)
	roxl	62+k(a2)
	roxl	54+k(a2)
	roxl	46+k(a2)
	roxl	38+k(a2)
	roxl	30+k(a2)
	roxl	22+k(a2)
	roxl	14+k(a2)
	roxl	6+k(a2)
k	set	k+168
	moveq	#0,d3
	roxl	#1,d3
	endr
	rts

;---------------------------------------------------------------------;
;	Table pour le scrolling hardware		;
;---------------------------------------------------------------------;

	even
table	dc.l	$e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,c	;00
	dc.l	$d,e,e,e,e,e,e,e,e,e,e,e,a,a,a,a	;02
	dc.l	$d,e,e,e,e,e,e,c,c,c,c,c,c,c,c,a	;04
	dc.l	$c,e,e,e,c,c,c,c,c,c,c,a,a,a,a,a	;06
	dc.l	$b,c,c,c,c,c,c,a,a,a,a,a,a,a,a,a	;08
	dc.l	$d,b,b,b,e,e,e,e,e,e,e,e,e,e,a,a	;0a
	dc.l	$d,e,e,e,e,e,e,e,e,c,c,c,c,c,a,a	;0c
	dc.l	$c,e,e,e,e,e,c,c,c,c,a,a,a,a,a,a	;0e
	dc.l	$c,c,c,c,c,c,c,c,c,c,c,c,c,a,a,a	;10
	dc.l	$d,b,b,b,b,b,b,e,e,e,e,e,e,e,e,e	;12
	dc.l	$d,e,e,e,e,e,e,e,e,e,e,c,c,a,a,a	;14
	dc.l	$d,e,e,e,e,e,c,c,c,c,c,c,c,c,c,c	;16
	dc.l	$c,e,e,c,c,c,c,c,c,c,c,c,a,a,a,a	;18
	dc.l	$e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e	;1a
	dc.l	$d,b,e,e,e,e,e,e,e,e,e,e,e,a,a,a	;1c
	dc.l	$d,e,e,e,e,e,e,e,c,c,c,c,c,c,c,a	;1e
	dc.l	$c,e,e,e,e,c,c,c,c,c,c,a,a,a,a,a	;20
	dc.l	$b,e,c,c,c,c,c,a,a,a,a,a,a,a,a,a	;22
	dc.l	$d,b,b,b,b,e,e,e,e,e,e,e,e,e,e,a	;24
	dc.l	$d,e,e,e,e,e,e,e,e,e,c,c,c,c,a,a	;26
	dc.l	$c,e,e,e,e,e,e,c,c,c,a,a,a,a,a,a	;28
	dc.l	$c,e,c,c,c,c,c,c,c,c,c,c,c,a,a,a	;2a
	dc.l	$a,c,a,a,a,a,a,a,a,a,a,a,a,a,a,a	;2c
	dc.l	$d,e,e,e,e,e,e,e,e,e,e,e,c,a,a,a	;2e
	dc.l	$d,e,e,e,e,e,e,c,c,c,c,c,c,c,c,c	;30
	dc.l	$c,e,e,e,c,c,c,c,c,c,c,c,a,a,a,a	;32
	dc.l	$b,c,c,c,c,c,c,c,a,a,a,a,a,a,a,a	;34
	dc.l	$d,b,b,e,e,e,e,e,e,e,e,e,e,e,a,a	;36
	dc.l	$d,e,e,e,e,e,e,e,e,c,c,c,c,c,c,a	;38
	dc.l	$c,e,e,e,e,e,c,c,c,c,c,a,a,a,a,a	;3a
	dc.l	$c,c,c,c,c,c,c,c,c,c,c,c,c,c,a,a	;3c
	dc.l	$d,b,b,b,b,b,e,e,e,e,e,e,e,e,e,e	;3e
	dc.l	$d,e,e,e,e,e,e,e,e,e,e,c,c,c,a,a	;40
	dc.l	$c,e,e,e,e,e,e,e,c,c,a,a,a,a,a,a	;42
	dc.l	$c,e,e,c,c,c,c,c,c,c,c,c,c,a,a,a	;44
	dc.l	$a,e,a,a,a,a,a,a,a,a,a,a,a,a,a,a	;46
	dc.l	$d,e,e,e,e,e,e,e,e,e,e,e,e,a,a,a	;48
	dc.l	$d,e,e,e,e,e,e,e,c,c,c,c,c,c,c,c	;4a
	dc.l	$c,e,e,e,e,c,c,c,c,c,c,c,a,a,a,a	;4c
	dc.l	$b,e,c,c,c,c,c,c,a,a,a,a,a,a,a,a	;4e
	dc.l	$d,b,b,b,e,e,e,e,e,e,e,e,e,e,e,a	;50 -
	dc.l	$d,e,e,e,e,e,e,e,e,e,c,c,c,c,c,a	;52
	dc.l	$c,e,e,e,e,e,e,c,c,c,c,a,a,a,a,a	;54
	dc.l	$c,e,c,c,c,c,c,c,c,c,c,c,c,c,a,a	;56
	dc.l	$a,c,c,a,a,a,a,a,a,a,a,a,a,a,a,a	;58
	dc.l	$d,e,e,e,e,e,e,e,e,e,e,e,c,c,a,a	;5a
	dc.l	$c,e,e,e,e,e,e,e,e,c,a,a,a,a,a,a	;5c
	dc.l	$c,e,e,e,c,c,c,c,c,c,c,c,c,a,a,a	;5e
	dc.l	$b,c,c,c,c,c,c,c,c,a,a,a,a,a,a,a	;60
	dc.l	$d,b,e,e,e,e,e,e,e,e,e,e,e,e,a,a	;62
	dc.l	$d,e,e,e,e,e,e,e,e,c,c,c,c,c,c,c	;64
	dc.l	$c,e,e,e,e,e,c,c,c,c,c,c,a,a,a,a	;66
	dc.l	$c,c,c,c,c,c,c,c,c,c,c,c,c,c,c,a	;68
	dc.l	$d,b,b,b,b,e,e,e,e,e,e,e,e,e,e,e	;6a
	dc.l	$d,e,e,e,e,e,e,e,e,e,e,c,c,c,c,a	;6c
	dc.l	$c,e,e,e,e,e,e,e,c,c,c,a,a,a,a,a	;6e
	dc.l	$c,e,e,c,c,c,c,c,c,c,c,c,c,c,a,a	;70
	dc.l	$a,e,c,a,a,a,a,a,a,a,a,a,a,a,a,a	;72
	dc.l	$d,e,e,e,e,e,e,e,e,e,e,e,e,c,a,a	;74
	dc.l	$c,e,e,e,e,e,e,e,e,e,a,a,a,a,a,a	;76
	dc.l	$c,e,e,e,e,c,c,c,c,c,c,c,c,a,a,a	;78
	dc.l	$b,e,c,c,c,c,c,c,c,a,a,a,a,a,a,a	;7a
	dc.l	$d,b,b,e,e,e,e,e,e,e,e,e,e,e,e,a	;7c
	dc.l	$d,e,e,e,e,e,e,e,e,e,c,c,c,c,c,c	;7e
	dc.l	$c,e,e,e,e,e,e,c,c,c,c,c,a,a,a,a	;80
	dc.l	$c,e,c,c,c,c,c,c,c,c,c,c,c,c,c,a	;82
	dc.l	$a,c,c,c,a,a,a,a,a,a,a,a,a,a,a,a	;84
	dc.l	$d,e,e,e,e,e,e,e,e,e,e,e,c,c,c,a	;86
	dc.l	$c,e,e,e,e,e,e,e,e,c,c,a,a,a,a,a	;88
	dc.l	$c,e,e,e,c,c,c,c,c,c,c,c,c,c,a,a	;8a
	dc.l	$b,c,c,c,c,c,c,c,c,c,a,a,a,a,a,a	;8c
	dc.l	$d,e,e,e,e,e,e,e,e,e,e,e,e,e,a,a	;8e
	dc.l	$c,b,e,e,e,e,e,e,e,e,e,a,a,a,a,a	;90
	dc.l	$c,e,e,e,e,e,c,c,c,c,c,c,c,a,a,a	;92
	dc.l	$c,c,c,c,c,c,c,c,c,c,c,c,c,c,c,c	;94
	dc.l	$d,b,b,b,e,e,e,e,e,e,e,e,e,e,e,e	;96
	dc.l	$d,e,e,e,e,e,e,e,e,e,e,c,c,c,c,c	;98
	dc.l	$c,e,e,e,e,e,e,e,c,c,c,c,a,a,a,a	;9a
	dc.l	$c,e,e,c,c,c,c,c,c,c,c,c,c,c,c,a	;9c
	dc.l	$a,e,c,c,a,a,a,a,a,a,a,a,a,a,a,a	;9e
	dc.l	$d,e,e,e,e,e,e,e,e,e,e,e,e,c,c,a	;a0
	dc.l	$c,e,e,e,e,e,e,e,e,e,c,a,a,a,a,a	;a2
	dc.l	$c,e,e,e,e,c,c,c,c,c,c,c,c,c,a,a	;a4
	dc.l	$b,e,c,c,c,c,c,c,c,c,a,a,a,a,a,a	;a6
	dc.l	$d,b,e,e,e,e,e,e,e,e,e,e,e,e,e,a	;a8
	dc.l	$c,b,b,e,e,e,e,e,e,e,e,e,a,a,a,a	;aa
	dc.l	$c,e,e,e,e,e,e,c,c,c,c,c,c,a,a,a	;ac
	dc.l	$c,e,c,c,c,c,c,c,c,c,c,c,c,c,c,c	;ae
	dc.l	$a,c,c,c,c,a,a,a,a,a,a,a,a,a,a,a	;b0
	dc.l	$d,e,e,e,e,e,e,e,e,e,e,e,c,c,c,c	;b2
	dc.l	$c,e,e,e,e,e,e,e,e,c,c,c,a,a,a,a	;b4
	dc.l	$c,e,e,e,c,c,c,c,c,c,c,c,c,c,c,a	;b6
	dc.l	$b,c,c,c,c,c,c,c,c,c,c,a,a,a,a,a	;b8
	dc.l	$d,e,e,e,e,e,e,e,e,e,e,e,e,e,c,a	;ba
	dc.l	$c,e,e,e,e,e,e,e,e,e,e,a,a,a,a,a	;bc
	dc.l	$c,e,e,e,e,e,c,c,c,c,c,c,c,c,a,a	;be
	dc.l	$b,e,e,c,c,c,c,c,c,c,a,a,a,a,a,a	;c0
	dc.l	$d,b,b,e,e,e,e,e,e,e,e,e,e,e,e,e	;c2
	dc.l	$c,b,b,b,e,e,e,e,e,e,e,e,e,a,a,a	;c4
	dc.l	$c,e,e,e,e,e,e,e,c,c,c,c,c,a,a,a	;c6
	dc.l	$c,e,e,c,c,c,c,c,c,c,c,c,c,c,c,c	;c8
	dc.l	$a,e,c,c,c,a,a,a,a,a,a,a,a,a,a,a	;ca
	dc.l	$d,e,e,e,e,e,e,e,e,e,e,e,e,c,c,c	;cc
	dc.l	$c,e,e,e,e,e,e,e,e,e,c,c,a,a,a,a	;ce
	dc.l	$c,e,e,e,e,c,c,c,c,c,c,c,c,c,c,a	;d0
	dc.l	$b,e,c,c,c,c,c,c,c,c,c,a,a,a,a,a	;d2
	dc.l	$d,e,e,e,e,e,e,e,e,e,e,e,e,e,e,a	;d4
	dc.l	$c,b,e,e,e,e,e,e,e,e,e,e,a,a,a,a	;d6
	dc.l	$c,e,e,e,e,e,e,c,c,c,c,c,c,c,a,a	;d8
	dc.l	$b,e,e,e,c,c,c,c,c,c,a,a,a,a,a,a	;da
	dc.l	$a,c,c,c,c,c,a,a,a,a,a,a,a,a,a,a	;dc
	dc.l	$c,b,b,b,b,e,e,e,e,e,e,e,e,e,a,a	;de
	dc.l	$c,e,e,e,e,e,e,e,e,c,c,c,c,a,a,a	;e0
	dc.l	$c,e,e,e,c,c,c,c,c,c,c,c,c,c,c,c	;e2
	dc.l	$b,c,c,c,c,c,c,c,c,c,c,c,a,a,a,a	;e4
	dc.l	$d,e,e,e,e,e,e,e,e,e,e,e,e,e,c,c	;e6
	dc.l	$c,e,e,e,e,e,e,e,e,e,e,c,a,a,a,a	;e8
	dc.l	$c,e,e,e,e,e,c,c,c,c,c,c,c,c,c,a	;ea
	dc.l	$b,e,e,c,c,c,c,c,c,c,c,a,a,a,a,a	;ec
	dc.l	$d,b,e,e,e,e,e,e,e,e,e,e,e,e,e,e	;ee
	dc.l	$c,b,b,e,e,e,e,e,e,e,e,e,e,a,a,a	;f0 ;
	dc.l	$c,e,e,e,e,e,e,e,c,c,c,c,c,c,a,a	;f2
	dc.l	$b,e,e,e,e,c,c,c,c,c,a,a,a,a,a,a	;f4
	dc.l	$a,e,c,c,c,c,a,a,a,a,a,a,a,a,a,a	;f6
	dc.l	$c,b,b,b,b,b,e,e,e,e,e,e,e,e,e,a	;f8
	dc.l	$c,e,e,e,e,e,e,e,e,e,c,c,c,a,a,a	;fa
	dc.l	$c,e,e,e,e,c,c,c,c,c,c,c,c,c,c,c	;fc
	dc.l	$b,e,c,c,c,c,c,c,c,c,c,c,a,a,a,a	;fe

;---------------------------------------------------------------------;
	DATA
;---------------------------------------------------------------------;

largeur	dc.b	5,6,5,6,5,5,6,7,4,6,7,4,8,7,5,6,5,6,6,5,6,5,8,7,6,6,5,4,5,6,5,6,5,6,6,5,4,4,4,4,2,2,3,2,6

	even
moving_scrol	dc.l	moving_data

addresses	dc.l	buffer		; valeur bidon.
addresses2	dc.l	buffer

cur_adr	dc.l	$e8600
efface_adr	dc.l	$e8600
startecr	dc.l	buffer_ecrans

colors_intro	dcb.w	8,0
	dc.w	$111,$222,$333,$444,$555,$666,$777
	dc.w	$777,$777,$777
	dc.w	$777,$666,$555,$444,$333,$222,$111
	dcb.w	13,0
	dc.w	$11,$22,$33,$44,$55,$66,$77
	dcb.w	12,$77
	dc.w	$77,$66,$55,$44,$33,$22,$11
	dcb.w	25,0
	dcb.w	21,$222
	dcb.w	22,$333
	dcb.w	22,$444
	dcb.w	15,$555
	dcb.w	20,0
	dc.w	0,$22,$33,$44,$55,$66,$77,$77,$77
	dcb.w	10,0

colors	degrade	+$7,-$1	; bleu => noir
	degrade	+0,+$100	; noir => rouge
	degrade	+$700,-$100	; rouge => noir
	degrade	+0,+$010	; noir => vert
	degrade	+$070,-$010	; vert => noir
	degrade	+0,+$101	; noir => violet
	degrade	+$707,-$101	; violet => noir
	degrade	+0,+$011	; noir => cyan
	degrade	+$077,-$011	; cyan => noir
	degrade	+0,+$110	; noir => jaune
	degrade	+$770,-$110	; jaune => noir
	degrade	+0,+$001	; noir => bleu
	degrade	+$007,-$001	; bleu => noir
	degrade	+0,+$111	; noir => blanc

fontesz	incbin	amigafnt.bin
sunylogo	incbin	sunylog.bin
pleezwet	incbin	pleezwet.bin
text	incbin	texte.dem
fontes	incbin	font2pak.img
sprites_fm	incbin	sprites.bin
zik	incbin	dz4.mus
zik_2	incbin	warp.snd
moving_data	incbin	movescrl.bin
	dc.w	-1
mvmnt	incbin	v_dist.bin
	dc.w	255
message_box	incbin	messabox.bin
	dc.l	-1
linewidth	incbin	courbe.bin
	dc.l	-1
textz	incbin	smaltext.dem
	dc.b	255

;---------------------------------------------------------------------;
	BSS
;---------------------------------------------------------------------;

pile0	ds.l	128
pile	ds.l	1
sauve_a2	ds.l	1
sauve_a3	ds.l	1
sauve_a4	ds.l	1
sauvecol	ds.l	1
sprite_pil	ds.l	16
rewrite	ds.l	308+2
sauve_pal	ds.l	8
stxtpil	ds.l	16
sauvreg	ds.l	16
vbl	ds.l	1
sauve_hbl	ds.l	1
current_adr	ds.l	1
intro_pil	ds.l	16
sauve_vblz	ds.l	1
v_bas_ad	ds.w	1
flag	ds.w	1
flag_2	ds.w	1
sauve_reso	ds.w	1
buffer_scrol	ds.b	8*168
buffer0	ds.b	160
buffer	ds.b	160*25
mfp_7	ds.b	1
mfp_9	ds.b	1
	even
buffer_ecrans	ds.b	260096