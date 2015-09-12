************************************************************************
**                                                                    **      
**    Roller text , marche sur stf/e , utilise des datas codes en     **      
**     G.F.A basic (sources dans le dossier \ROLLER\ .....)           **      
**  Code Genere (Interressant pour les demos makers st mais inutile   **
**  pour les autres,car il y a le cache sur FALCON )                  **
**                                                                    **      
**     Les sprites sont en 4 plans si vous ameliore cette routine     **
**  vous pouvez nous l'envoyer , please ...                           **      
**                                                                    **      
**                WONDERFULL CODE PAR MAD'VISION 92                   **      
**            sur FALCON maintemant sous le nom " E.K.O "             **      
**               Extremly Kollective Organisation !!!!                **      
**                                                                    **      
** Attention la prochaine fois je balance les sources du MAGIC CUBE 2 **      
** Code par EXP... Et la ya un code encore plus tare !!!              **      
**                                                                    **      
************************************************************************

	Section text

ecart	equ 8

	move.l	#0,-(a7)
	move.w	#$20,-(a7)
	trap	#1
	move.l	d0,s_ssp

	move.l	#scr2,d0
	add.w	#256,d0
	sf	d0
	move.l	d0,scradr
	move.l	$44e.w,scradr+4
	move.l	$44e.w,a0
	move.w	#7999,d0
cls	clr.l	(a0)+		* Efface la memoire video
	dbra	d0,cls
	lea	cl_list,a0
	lea	scr2,a1
	moveq	#13,d0
cl_init	move.l	a1,(a0)+	* Initialise la liste des adresses
	dbra	d0,cl_init	* utilisees pour effacer le fond
				* evite l'effacement de tout l'ecran
	
	move.b	$ffff8260.w,s_shiftmd
	move.b	$ffff820a.w,s_syncmd
	move.b	$ffff8201.w,s_vbaseh
	move.b	$ffff8203.w,s_vbasem
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,s_pal
	movem.l	pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	$70.w,s_vbl
	move.w	#$2700,sr
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820a.w
	move.l	#vbl,$70.w

	bsr	init_tabs	* Genere le code des routines de points

	move.w	#$2300,sr
wait
	cmpi.b	#$39,$fffffc02.w
	bne.s	wait

exit
	move.w	#$2700,sr
	move.l	s_vbl,$70.w
	move.b	s_shiftmd,$ffff8260.w
	move.b	s_syncmd,$ffff820a.w
	move.b	s_vbaseh,$ffff8201.w
	move.b	s_vbasem,$ffff8203.w
	movem.l	s_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.l	s_ssp,-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	clr.w	-(a7)
	trap	#1

vbl
	lea	scradr,a0	* echange les ram video
	move.l	(a0)+,d0
	move.l	(a0),d1
	move.l	d0,(a0)
	move.l	d1,-(a0)	  * 56 cycles (= c) 
	move.b	1(a0),$ffff8201.w
	move.b	2(a0),$ffff8203.w *40 c
	bsr	demo
	move.w	#7,$ffff8240.w
	clr.w	$ffff8240.w
	rte

distort:			* Distord d1
	movem.l	a5-a6,-(a7)
	lea	buffer,a0	* a0=buffer pour deformation
	movem.l	zero,d0-d7
	movem.l	d0-d7,(a0)
	movem.l	d0-d7,32(a0)
	movem.l	d0-d7,64(a0)
	movem.l	d0-d7,96(a0)	*300 cy
	lea	fonte,a1	*a1=fonte
	add.l	#matrice,a2	*a2=matrice de def.
	lea	couleur,a3	*tableau contenant des pointeurs
	lea	ret,a5

*sur les tables de 256 ptr sur 256 routines (1 par point)

	add.w	char,a1		* a1=adr. car. ds la fonte
	move.w	#143,d0		* 144 pts
lp	move.b	(a1)+,d1	* 4*couleur pt courant
	move.l	(a3,d1.w),a4	* index 1ier tableau
	move.w	(a2)+,d2	* 4*no pt de destination
	move.l	(a4,d2.w),a4	* index 2ieme tableau

	jmp	(a4)		* saut routine point
ret	dbra	d0,lp		* ret adresse de retour
	movem.l	(a7)+,a5-a6
	rts

demo		
l1	lea	cl_list+28,a5
	bsr	clear

	move.w	l1+4,d0		* Automodifie pour inverser les buffers
	move.w	l2+4,d1		* d'effacage...TRES deconseiller sur FALCON
	move.w	d0,l2+4
	move.w	d1,l1+4 	* 64 cy

l2	lea	cl_list,a5	
	
	*pour noter les adresses ou on devra effacer a la prochaine vbl
	
	lea	trajet,a6	*courbe
	add.w	pos,a6		*offset actuel
	move.w	4(a6),a2
	move.w	#('I'-'A')*144,char	
	
 * Pas d'utilisation de la table des offsets de la fonte
	
 	bsr	distort		* distortion
	bsr	sprite		* affichage
	add.w	#ecart*6,a6
	move.w	4(a6),a2
	move.w	#('R'-'A')*144,char
	bsr	distort
	bsr	sprite
	add.w	#ecart*6,a6
	move.w	4(a6),a2
	move.w	#('A'-'A')*144,char
	bsr	distort
	bsr	sprite
	add.w	#ecart*6,a6
	move.w	4(a6),a2
	move.w	#('T'-'A')*144,char
	bsr	distort
	bsr	sprite
	add.w	#ecart*6,a6
	move.w	4(a6),a2
	move.w	#('A'-'A')*144,char
	bsr	distort
	bsr	sprite

	move.w	pos,d0
	addq.w	#6,d0
	cmp.w	#1200,d0
	bne.s	non
	clr.w	d0
non	move.w	d0,pos
	rts

clear
	moveq	#0,d0
	moveq	#6,d7
cl_
	move.l	(a5)+,a1
	rept 16
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	lea	160-16(a1),a1
	endr			* 16*56->896
	dbra	d7,cl_
	rts

sprite	
	*Routine de sprite 16*16 avec calcul du masque
	*et effacement du font
	*La routine est a amelioree ...
	*C'est franchement optimisable ...
	lea	buffer,a0
	move.l	scradr,a1
	add.w	(a6),a1
	move.l	a1,(a5)+
	move.w	2(a6),d6
	move.w	d6,d0
	and.w	#$fff0,d0
	lsr.w	#1,d0
	add.w	d0,a1
	and.w	#$f,d6

	moveq	#15,d7
spr
	moveq	#0,d0		* Clear REG
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	(a0)+,d0	* Rempli REG
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.l	d0,d4		* Cacule MASQUE
	or.l	d1,d4
	or.l	d2,d4
	or.l	d3,d4
	not.l	d4
	ror.l	d6,d0		* Decale Sprite et maske
	ror.l	d6,d1
	ror.l	d6,d2
	ror.l	d6,d3
	ror.l	d6,d4
	and.w	d4,(a1)		* Masque decor et affiche sprite
	or.w	d0,(a1)+
	and.w	d4,(a1)
	or.w	d1,(a1)+
	and.w	d4,(a1)
	or.w	d2,(a1)+
	and.w	d4,(a1)
	or.w	d3,(a1)+
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	swap	d4
	and.w	d4,(a1)
	or.w	d0,(a1)+
	and.w	d4,(a1)
	or.w	d1,(a1)+
	and.w	d4,(a1)
	or.w	d2,(a1)+
	and.w	d4,(a1)
	or.w	d3,(a1)+
	add.w	#160-16,a1
	dbra	d7,spr		* 16*576->726=9216->11616 (delire)
	rts

init_tabs
	lea	couleur,a0	* Init 1er tableau
	lea	16*4(a0),a1	* (reference aux plans valides)
	moveq	#15,d0
i1_lp	move.l	a1,(a0)+	* Ce tableau contient 16 pointeurs
	add.w	#256*4,a1	* sur 16 tableau (1/couleur)pointant sur 256
	dbra	d0,i1_lp	* routines chacun: 1 par point

	lea	putpix,a1
	moveq	#0,d6
	moveq	#15,d0
i2_lp	moveq	#15,d1
	moveq	#0,d3
i21_lp	moveq	#15,d2
i221_lp move.l	a1,(a0)+

	btst	#0,d6
	beq.s	pas1
	move.w	#$0068,(a1)+	* opcode pour ori.w #$xxxx,d(a0)
	move.w	#1,d4		* a0 contenant l'adresse du buffer
	lsl.w	d2,d4		* dans lequel se font les distortions
	move.w	d4,(a1)+	* calcul la constante
	move.w	d3,(a1)+	* puis le deplacement
pas1	btst	#1,d6
	beq.s	pas2
	move.w	#$0068,(a1)+	* idem si necessaire pour le 2ieme plan
	move.w	#1,d4
	lsl.w	d2,d4
	move.w	d4,(a1)+
	move.w	d3,(a1)+
	addq.w	#2,-2(a1)
pas2	btst	#2,d6
	beq.s	pas3
	move.w	#$0068,(a1)+	* id.
	move.w	#1,d4
	lsl.w	d2,d4
	move.w	d4,(a1)+
	move.w	d3,(a1)+
	addq.w	#4,-2(a1)
pas3	btst	#3,d6
	beq.s	pas4
	move.w	#$0068,(a1)+
	move.w	#1,d4
	lsl.w	d2,d4
	move.w	d4,(a1)+
	move.w	d3,(a1)+
	addq.w	#6,-2(a1)
pas4	
	* Genere un jmp (a5) a5 contient le symbole ret
	
	move.w	#$4ed5,(a1)+	
	dbra	d2,i221_lp
	addq.w	#8,d3
	dbra	d1,i21_lp
	addq.w	#1,d6
	dbra	d0,i2_lp
	rts

	SECTION DATA

scradr	dc.l 0,0
char	dc.w 0
pos	dc.w 0
pal	* By NEOchrome V2.24 by Chaos, Inc.
	dc.w $000,$010,$110,$111,$221,$222,$332,$333
	dc.w $443,$444,$554,$555,$665,$666,$776,$777
fntfile	incbin \roller\font.dat

fonte	equ fntfile+512

matrice	incbin \roller\rotate_5.dat

trajet	incbin \roller\lemnisca.dat

	Section Bss

s_ssp	ds.l 1
s_shiftmd ds.b 1
s_syncmd ds.b 1
s_vbaseh ds.b 1
s_vbasem ds.b 1
s_pal	ds.w 32
s_vbl	ds.l 1
cl_list	ds.l 14
zero	ds.l 16
buffer	ds.w 16*4
couleur	ds.l 16
	ds.l 16*256
putpix	ds.b 57344
scr2	ds.b 32256
	end
