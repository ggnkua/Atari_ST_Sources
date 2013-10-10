*adresse des differentes donnees
screens	=	$90000
sizscr	=	200*160
dekrast	=	screens+2*sizscr
curve1	=	dekrast+16*32
curve2	=	curve1+2048*2
*parametre de la courbe
amp1	=	110
phi1	=	2
amp2	=	40
phi2        =	12
*essayer aussi 110,2,40,256;130,2,16,16,...
*parametres de la routine de rasters
nbrast	=	85
rastoff	=	1
hborder	=	0
bltline	reg d0-d6/a2-a6
*
	section text
*superviseur
	pea	0
	move	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	lea	save(pc),a6
	move.l	d0,(a6)+
*sauver/installer palette
	lea	oldpal(pc),a0
	lea	newpal(pc),a1
	lea	$ffff8240.w,a2
	movem.l	(a2),d0-d7
	movem.l	d0-d7,(a0)
	movem.l	(a1),d0-d7
	movem.l	d0-d7,(a2)
*couper les it 68000
	move	#$2700,sr
*sauver les registres shifter/mfp
*et vecteurs vbl
	move.b	$ffff8260.w,(a6)+
	move.b	$ffff820a.w,(a6)+
	move.b	$ffff8201.w,(a6)+
	move.b	$ffff8203.w,(a6)+
	move.l	$fffffa06.w,(a6)+ *iera/b
	move.l	$fffffa12.w,(a6)+ *imra/b
	move.l	$70.w,(a6)+
*couper les it mfp
	moveq	#0,d0
	move.l	d0,$fffffa06.w	*iera
	move.l	d0,$fffffa12.w	*imra
*nouvelles valeurs shifter
	stop	#$2300
	stop	#$2300
	move.b	screen+1(pc),$ffff8201.w
	move.b	screen+2(pc),$ffff8203.w
	move.b	#0,$ffff8260.w
*a retirer sur tt
	move.b	#2,$ffff820a.w
	
*recouper it 68000
	move	#$2700,sr
main
*effacer les ecrans
	lea	screens,a0
	moveq	#0,d0
	move	#((sizscr*2)/4)-1,d7
.cls
	move.l	d0,(a0)+
	dbf	d7,.cls
*precalculer les tables sinus
	bsr	fixsintab
*predecaler les rasters
	bsr	vrastshift
*nouveau vecteur vbl
	move.l	#installvbl,$70.w
*valider it 68000 interessantes
	move	#$2300,sr
*attendre barre d'espace
*appuy‚e et lach‚e
.wait0
	cmpi.b	#$39,$fffffc02.w
	bne.s	.wait0
.wait1
	cmpi.b	#$39+$80,$fffffc02.w
	bne.s	.wait1
exit
	move	#$2700,sr
*couper it mfp
	moveq	#0,d0
	move.l	d0,$fffffa06.w	*iera
	move.l	d0,$fffffa12.w	*imra
*annuler routine vbl
	move.l	#dummy_it,$70.w
*restaurer registres shifter
	lea	save+4,a6
	stop	#$2300
	stop	#$2300
	move.b	(a6)+,$ffff8260.w
*a retirer sur tt
	move.b	(a6)+,$ffff820a.w
	
	move.b	(a6)+,$ffff8201.w
	move.b	(a6)+,$ffff8203.w
*restaurer registres mfp et
*vecteurs vbl
	move	#$2700,sr
	move.l	(a6)+,$fffffa06.w
	move.l	(a6)+,$fffffa12.w
	move.l	(a6)+,$70.w
*replacer palette
	lea	oldpal(pc),a0
	lea	$ffff8240.w,a2
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a2)
*vider le buffer clavier
*on ne sait jamais
.kflush
	btst.b	#0,$fffffc00.w
	beq.s	.kfok
	move.b	$fffffc02.w,d0
	bra.s	.kflush
.kfok
	move	#$2300,sr
*utilisateur
	move.l	save,-(sp)
	move	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
*pterm0
	clr	-(sp)
	trap	#1
*donnees inits
save	ds.l	5
oldpal	ds.w	16
newpal	dc.w	$000,$111,$222,$333,$444,$555,$666,$777
	dc.w	$776,$766,$655,$544,$433,$322,$211,$100
screen	dc.l	screens
dummy_it
	rte
installvbl
	move.l	#vgtvbl,$70.w
	rte
*on premultipli ici la table de
*sinus originale par les amplitudes
*donnees en debut de listing,on
*evite ainsi les muls en cours
*de vbl
fixsintab
	lea	sintab,a0
	lea	curve1,a1
	lea	curve2,a2
	moveq	#0,d1
	moveq	#0,d2
	move	#512-1,d0
.fix
	moveq	#0,d1
	moveq	#0,d2
	move	(a0)+,d1
	move	d1,d2
	muls	#amp1,d1
	muls	#amp2,d2
	move.l	d1,(a1)
	move.l	d1,2048(a1)
	lea	4(a1),a1
	move.l	d2,(a2)
	move.l	d2,2048(a2)
	lea	4(a2),a2
	dbf	d0,.fix
	rts
*
*ici on decale les petits sprites
*et on calcule leurs masques
vrastshift
	lea	dekrast,a0
	moveq	#0,d6
	move	#16-1,d7
.rastshift
	lea	rast,a1
*d0-d3 contiennent les donnees du
*sprite, et d4 le mot de masque,
*le meme sur les 4 plans.
	movem.l	zero,d0-d4
	move	(a1)+,d0
	move	(a1)+,d1
	move	(a1)+,d2
	move	(a1)+,d3
*calcul du masque
	move	d0,d4
	or	d1,d4
	or	d2,d4
	or	d3,d4
	not.l	d4
*decalage et sauvegarde de la
*premiere moitie du sprite. on
*interlace le masque et les
*donnees pour pouvoir les caser
*2 plans par 2 plans avec des .l
	ror.l	d6,d0
	ror.l	d6,d1
	ror.l	d6,d2
	ror.l	d6,d3
	ror.l	d6,d4
	move	d4,(a0)+
	move	d4,(a0)+
	move	d0,(a0)+
	move	d1,(a0)+
	move	d4,(a0)+
	move	d4,(a0)+
	move	d2,(a0)+
	move	d3,(a0)+
*on swappe et on sauve la
*deuxieme moitie...
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	swap	d4
	move	d4,(a0)+
	move	d4,(a0)+
	move	d0,(a0)+
	move	d1,(a0)+
	move	d4,(a0)+
	move	d4,(a0)+
	move	d2,(a0)+
	move	d3,(a0)+
	addq	#1,d6
	dbf	d7,.rastshift
	rts
vgtvbl
*switcher les ecrans pour la
*prochaine vbl
	lea	scradr,a0
	movem.l	(a0),d0-d1
	exg.l	d0,d1
	movem.l	d0-d1,(a0)
	move.b	1(a0),$ffff8201.w
	move.b	2(a0),$ffff8203.w
*afficher les rasters
	move	#0,$ffff8240.w
	bsr.s	vrast
	move	#$321,$ffff8240.w
	rte
vrast
	movea.l	scradr,a1
	lea	hborder*160(a1),a1
*effacer la ligne a afficher
	lea linebuf,a0
	moveq	#0,d0
	rept	40
	move.l	d0,(a0)+
	endr
*charger les valeurs courantes
*des angles
	move	ang1,curang1
	move	ang2,curang2
*calcul et affichage...
	move	#nbrast-1,d7
.aff
*calcul de l'abscisse du sprite
	lea	dekrast,a2
	lea	linebuf,a0
	move	#10,d6
	moveq	#0,d0
	moveq	#0,d2
	lea	curve1,a5
	move	curang1,d0
	move.l	0(a5,d0.w),d0
	add.w	#phi1*4,curang1
	lea	curve2,a5
	move	curang2,d2
	move.l	0(a5,d2.w),d2
	add.w	#phi1*4,curang1
	lea	curve2,a5
	move	curang2,d2
	move.l	0(a5,d2.w),d2
	add.w	#phi2*4,curang2
	andi.w	#511*4,curang2
	add.l	d2,d0
	asr.l	d6,d0
	addi.w	#160,d0
	move	d0,d1
	andi	#$f,d1
	andi	#$fff0,d0
	lsr.w	#1,d0
	adda.w	d0,a0
	lsl.w	#5,d1
	adda.w	d1,a2
*affiche le bout de raster
	movem.l	(a0),d0-d3
	and.l	(a2)+,d0
	or.l	(a2)+,d0
	and.l	(a2)+,d1
	or.l	(a2)+,d1
	and.l	(a2)+,d2
	or.l	(a2)+,d2
	and.l	(a2)+,d3
	or.l	(a2)+,d3
	movem.l	d0-d3,(a0)
*afficher la ligne
	lea	linebuf,a0
	movem.l	(a0),bltline
n set 0
	rept	rastoff
	movem.l	bltline,n(a1)
m set n+160
	endr
	movem.l	48(a0),bltline
n set 0
	rept rastoff
	movem.l	bltline,n+48(a1)
n set n+160
	endr
	movem.l	96(a0),bltline
n set 0
	rept rastoff
	movem.l	bltline,n+96(a1)
n set n+160
	endr
	movem.l	144(a0),d0-d3
n set 0
	rept	rastoff
	movem.l	d0-d3,n+144(a1)
n set n+160
	endr
	lea	rastoff*160(a1),a1
	dbf	d7,.aff
*et on remplit la fin de l'ecran
	lea linebuf,a0
	movem.l	(a0),bltline
n set 0
	rept	200-(nbrast*rastoff)-hborder)
	movem.l	bltline,n(a1)
n set n+160
	endr
	movem.l	48(a0),bltline
n set 0
	rept	200-(nbrast*rastoff)-hborder)
	movem.l	bltline,n+48(a1)
n set n+160
	endr
	movem.l	96(a0),bltline
n set 0
	rept	200-(nbrast*rastoff)-hborder)
	movem.l	bltline,n+96(a1)
n set n+160
	endr
	movem.l	144(a0),d0-d3
n set 0
	rept	200-(nbrast*rastoff)-hborder)
	movem.l	d0-d3,n+144(a1)
n set n+160
	endr
	add.w	#2*4,ang1
	andi.w	#511*4,ang1
	add.w	#3*4,ang2
	andi.w	#511*4,ang2
	rts
	section data
scradr	dc.l	screens
	dc.l	screens+sizscr
linebuf	ds.b	160
sintab	incbin	a:\sin1024.vgt
ang1	dc.w	0
curang1	dc.w	0
ang2	dc.w	0
curang2	dc.w	0
rast	dc.w	%101010101010101
	dc.w	%011001100110011
	dc.w	%000111100001111
	dc.w	%000000011111111
zero	ds.l	15
	end
							