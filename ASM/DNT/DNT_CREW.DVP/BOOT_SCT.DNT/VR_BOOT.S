;                    Ze Vertical-Rasters Bootsector
;
;                     (C)oderight NulloS//DNT 1992
;
TEST	equ	1

	IFEQ	TEST
MAIN	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,2(sp)
	move.l	$432.w,-(sp)
	move.l	#buffer,$432.w
	bsr.w	DEBUT
	move.l	(sp)+,$432.w
	trap	#1
	addq.l	#6,sp
	clr.w	(sp)
	trap	#1
	ENDC




DEBUT
	tst.b	$44c.w
	bne	Exit
boot_ok	movea.l	$432.w,a5
	lea	sinus_tab(pc),a4
mak_sincos	lea	sin+32(a5),a0	;
	movea.l	a0,a3		;
	moveq	#15,d7		;Recopier 16 valeurs
sin_bcl1	move.b	(a4)+,d5		;
	move.w	d5,-(a0)		;
	move.w	d5,(a3)+		;
	dbf	d7,sin_bcl1	;on a donc sin pour ]0..PI[
	movea.l	a0,a6		;conserve trace de la table
	moveq	#95+20,d7		;copie sur 96 valeurs
sin_bcl2	move.w	(a0)+,(a3)		;On obtient 2 tables cons‚cutives
	neg.w	(a3)+		;de sinus + une broutille pour
	dbf	d7,sin_bcl2	;la courbe du texte
;en sortie,A4=motif binaire des rasters
;          A3=debut table de rasters
;          A6=debut table sinus
;          A5=variables du boot
;          D7=0.w|-1.w
	move.l	a3,a0
	move.w	#80*64*2/4-1,d0
clr_bcl	clr.l	(a0)+
	dbf	d0,clr_bcl

	moveq	#0,d0		;base de sinus
rast_bcl0	move.w	d0,d1		;demarrage de la courbe
	moveq	#15,d2		;16 bandes de rasters par courbe
	move.w	#(64-(-00))*4,d3	;256=(Z_fuite-Z_point)*4
rast_bcl1	movea.w	#-48*4,a1		;48=(d‚calage x)*4

rast_bcl2	move.w	0(a6,d1.w),d5	;sinus (-128<x<128)=4*(-32<x<32)
	add.w	a1,d5		;Donc on obtient 4*(-80<x<80)
	asl.w	#6,d5		;*64=Z_fuite -->256*(-80<x<80)
	ext.l	d5		;pour la division
	divs	d3,d5		;x*Z_fuite/(Z_fuite-Z_point)
	addi.w	#152,d5		;centrage
	ror.l	#4,d5		;conserve 4 bits de rotation
	lsl.w	#3,d5		;prendre l'offset ecran
	movea.l	a3,a0		;...
	adda.w	d5,a0		;que l'on utilise
	rol.l	#4,d5		;reprend les 4 bit de rotation
	moveq	#-1,d6		;Confectionne le masque
	clr.w	d6		;du raster
	ror.l	d5,d6		;Yeah,c'est fait
	movea.l	a4,a2		;

	moveq	#2,d4		;
put_plane	moveq	#0,d7		;pose d'un plan de raster
	move.w	(a2)+,d7		;recupere data
	ror.l	d5,d7		;rotationne
	and.w	d6,(a0)		;maskage
	or.w	d7,(a0)+		;et hop
	swap	d6		;partie droite du plan
	and.w	d6,6(a0)		;
	swap	d6		;
	swap	d7		;
	or.w	d7,6(a0)		;or et passe au plan suivant
	dbf	d4,put_plane	;(3 en tout)
	adda.w	#47*4,a1		;bande suivante
	cmpa.w	#48*4,a1		;fini ?
	ble.s	rast_bcl2		;non,roulez jeunesse
	addq.b	#4,d1		;evolue dans la courbe du raster
	subq.w	#8,d3		;On augmente Z_point
	dbf	d2,rast_bcl1	;niveau de raster suivant

	lea	160(a3),a3		;ligne suivante
	addq.b	#2,d0		;une etape de plus
	bpl.s	rast_bcl0		;ok


;Maintenant,on a A6=table sinus
;                A3=debut gfx du texte
;                A2=palette1
;                D0=0
;                D2=D4=0.w|-1.w
get_texte	clr.l	(a5)+		;init le swapping & compteur
	move.l	$44e.w,-(sp)	;adresse ecran actuel
	move.l	(sp),d6		;
	move.l	d6,(a5)+		;stocke
	bsr.s	aff_ecran		;affichage (cls+print)
	lea	160*24+256(a3),a0	;fin du buffer gfx=>debut ecran
	move.l	a0,d6		;
	clr.b	d6		;multiple de 256
	move.l	d6,(a5)+		;stocke
	bsr.s	aff_ecran		;affichage
	movea.l	d6,a4		;prepare l'adresse du message
	lea	11*8*160(a4),a0	;voil… c'est fait
	move.w	#20*8*3-1,d0	;8*3 lignes … relever (20 colonnes)
gt_bcl	move.w	(a0),(a3)+		;on stocke le bitmap du texte
	addq.l	#8,a0		;pour l'affichage plus tard
	dbf	d0,gt_bcl		;
	move.l	$70.w,-(sp)	;pr‚pare les ITs
	bclr	#5,$fffffa09.w	;plus de Timer C
	pea	VBL(pc)		;
	move.l	(sp)+,$70.w	;
waiting	tst.b	$fffffc02.w	;
	ble.s	waiting		;
	bset	#5,$fffffa09.w	;remet le Timer C
	move.l	(sp)+,$70.w	;
	move.l	(sp)+,d6		;
aff_ecran	clr.w	-(sp)
	move.l	d6,-(sp)
	move.l	d6,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
Exit	pea	message(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
the_end	rts
;Modification de derniŠre minute:afin que le boot signale sa pr‚sence
;mˆme s'il ne s'ex‚cute pas (p.ex,boot en monochrome),par un message,
;j'ai enlev‚ une optimisation: au lieu de lea 12(sp),sp puis addq.l #6,sp
;on pourrait n'utiliser qu'un seul lea 18(sp), mais cela empŠcherait de
;mettre Exit comme sous-routine.

VBL	move.l	$432.w,a6		;adresse des variables
	move.w	(a6),d0		;avanc‚e dans le sinus
	move.w	sin+40(a6,d0.w),d0	;(+40 -> mvt d‚cal‚)
	asr.w	#1,d0		;divise par 2
	addi.w	#64+30-1,d0	;centre … l'‚cran
	mulu.w	#160,d0		;
	lea	texte(a6),a6	;adresse du texte
	adda.w	d0,a4		;
	addq.w	#6,a4		;
	move.w	#20*3*8-1,d7	;
put_texte	move.w	(a6)+,(a4)		;affichage proprement
	addq.l	#8,a4		;dit...
	dbf	d7,put_texte	;

	movem.l	palette(pc),d0-4	;les derniŠres couleurs de
	move.l	d4,d5		;la palette sont ‚gales,on
	move.l	d4,d6		;ne les stocke pas.
	move.l	d4,d7		;
	movem.l	d0-7,$ffff8240.w	;
	movea.l	$432.w,a5		;
	lea	rasters(a5),a6	;
	addq.b	#2,1(a5)		;une VBL de plus
	move.w	(a5)+,d0		;
	eori.w	#4,(a5)		;swap les ‚crans
	adda.w	(a5)+,a5		;on va sur la bonne adresse
	movea.l	(a5),a4		;Nb: quand on fait une instruction
	move.l	a4,d1		;avec (An)+,An le 68000 d‚compose
	lsr.w	#8,d1		;cela en .lire X=(An)
	move.l	d1,$ffff8200.w	;        .incr‚mente An
	andi.w	#$7e,d0		;        .ajouter X … An
	mulu.w	#80,d0		;*80 seulement car le compteur va
	adda.w	d0,a6		;de 2 en 2
	moveq	#3,d7		;4 parties de lignes
put_rast0	move.l	a4,a5		;...
	move.w	#199,d6		;de 199 de haut
	movem.l	(a6)+,d0-5/a0-3	;
put_rast1	movem.l	d0-5/a0-3,(a5)	;
	lea	160(a5),a5		;
	dbf	d6,put_rast1	;
	lea	40(a4),a4		;
	dbf	d7,put_rast0	;
	rte			;
	
		
	


	RSRESET
compteur	rs.w	1
swapping	rs.w	1
ecran1	rs.l	1
ecran2	rs.l	1
sin	rs.w	128+20
rasters	rs.w	80*64
texte	rs.w	20*8*3
screen	rs.b	32256


sinus_tab
	dc.b	128,127,124,121
	dc.b	116,110,103,095
	dc.b	086,076,066,055
	dc.b	043,031,019,006
rast_motif	dc.w	%0101010110101010
	dc.w	%0011001111001100
	dc.w	%0000111111110000
message	dc.b	27,'Y',43,45,"THE RASTA BOOT"
	dc.b	27,'Y',45,50,190,"DNT",$d,$a
palette	dc.w	$000,$100,$200,$310,$420,$531,$641,$752
	dc.w	$fff,$fff

FIN

	IFEQ	TEST
	SECTION	BSS
buffer	ds.l	40000
	ENDC