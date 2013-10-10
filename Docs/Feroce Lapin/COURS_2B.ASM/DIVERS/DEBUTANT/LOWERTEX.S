* AFFICHAGE DANS LE BAS DE L'ECRAN. METHODE
* EMPLOYEE PAR UDO (FROM TEX)
* COMMENTAIRE PAR LE FEROCE LAPIN (FROM 44E)
 
x:
	move.l #0,-(sp) passe classiquement en super.
	move.w #$20,-(sp)
	trap   #1
	addq.l #6,sp
	move.l d0,savereg  sauve ancienne pile
	
	move.l #$80000,a7
	dc.w   $a00a               ;mouse off

	move.w #4,-(sp)  sauve l'ancienne r‚solution
	trap   #14
	addq.l #2,sp
	move.w d0,oldrez

	move.l $44e,oldadr	sauve l'ancienne adresse ‚cran
	move.b $ffff820a.w,oldsync et l'ancienne synchro

	bsr    prepare        pr‚pare l'‚cran
	bsr    hblon          met une nouvelle HBL en place
	bsr    touche   	attend un appui sur ESC
	bsr    hbloff         supprime la HBL

goon	move.b oldsync,$ffff820a.w  remet ancienne synchro

	move.w oldrez,-(sp)      ancienne r‚solution  
	move.l oldadr,-(sp)      et ancienne adresse
	move.l oldadr,-(sp)      pour l'‚cran
	move.w #5,-(sp)
	trap   #14
	add.l  #12,sp

	dc.w	 $a009       remet la souris
	move.l savereg,-(sp)    retour en utilisateur
	move.w #$20,-(sp)
	trap   #1
	addq.l #6,sp

	clr.l -(sp)             bye bye
	trap  #1
*-----------------------------------*
touche	* attend un appui sur ESC
	move.w #7,-(sp)
	trap   #1
	addq.l #2,sp
	swap   d0
	cmp.b  #1,d0
	bne    touche
	rts
*-----------------------------------*
hblon	move.l $120.w,oldtb             ;save all registers
	move.l $118.w,oldkey
	move.l $118.w,newkey2+2
	move.l $70.w,old4
	move.l $70.w,new4b+2
	move.b $fffffa07.w,old07
	move.b $fffffa09.w,old09
	move.b $fffffa1b.w,old1b
	move.b $fffffa13.w,old13
	move.b $fffffa15.w,old15

	move.l #contr,a0
	and.b  #$df,$fffffa09.w
	and.b  #$fe,$fffffa07.w
	move.b (a0)+,d0
	cmp.b  #21,d0
	bne    noinst
	move.l #newtb,$120.w            ;install new vectors
	move.l #new4,$70.w
	move.l #newkey,$118.w
	or.b   #1,$fffffa07.w           ;allow timer b interrupt
	or.b   #1,$fffffa13.w
noinst:
	rts
*---------------------------------------*
hbloff:
	move.w sr,-(sp)
	move.w #$2700,sr
	move.b contr+1,d0
	cmp.b  #4,d0
	bne    noex
	move.b old07,$fffffa07.w        ;restore all registers
	move.b old09,$fffffa09.w
	move.b old13,$fffffa13.w
	move.b old15,$fffffa15.w
	move.b old1b,$fffffa1b.w

	move.l oldtb,$120.w             ;restore vectors
	move.l oldkey,$118.w
	move.l old4,$70.w
noex:
	move.w (sp)+,sr
	rts
*--------------------------------------*

new4:                           ;new level 4 interrupt
	clr.b  $fffffa1b.w              ;stop timer
	move.b #199,$fffffa21.w         ;set data register
	move.b #8,$fffffa1b.w           ;start timer
new4b:
	jmp    $000000

newkey:                         ;keyboard don't disturb!!!
	move.w #$2500,sr
newkey2:
	jmp    $000000

newtb:
	clr.b   $fffffa1b.w             ;timer stop
	movem.l d0/d3-d7/a0-a6,-(sp)
	move.w  #$fa21,a4
	move.b  #180,(a4)               ;set counter
	move.b  #8,-6(a4)

	moveq   #0,d0		;wait till middle of line
	mulu    d0,d0
	mulu    d0,d0
	move.b  #0,$ffff820a.w	;on to 60 Hz

	move.b  (a4),d0                 ;wait on right border
wait:
	cmp.b   (a4),d0
	beq     wait
	moveq   #0,d0		;wait on left border
	mulu    d0,d0
	mulu    d0,d0
	move.b  #2,$ffff820a.w	;back to 50 Hz

	movem.l (sp)+,d0/d3-d7/a0-a6
	bclr    #0,$fffffa0f.w          ;end of interrupt
	rte
*--------------------------------------*
prepare:
* d'abord on force en basse r‚solution, puis on
* impose une adresse pour Xbios2 et3. Ainsi l'‚cran
* sera dans une zone m‚moire libre, on pourra donc
* afficher 32Ko plus loin sans risque d'‚craser
* des donn‚es importantes.
	move.w #0,-(sp)        
	move.l #$70000,-(sp)
	move.l #$70000,-(sp)
	move.w #5,-(sp)
	trap   #14
	add.l  #12,sp

* Pour dessiner l'‚cran, ici pas de dessin, seulement des
* datas qui ne vont produire que des colonnes de couleurs.
	move.l $44e,a1    pr‚l‚ve adresse ‚cran
	move.l #data,a0   adresse du 'dessin'
	move.w #199,d0    compteur
* en route pour le remplissage!
loop	movem.l (a0),d1-d7/a2-a4
	movem.l d1-d7/a2-a4,(a1)
	movem.l 40(a0),d1-d7/a2-a4
	movem.l d1-d7/a2-a4,40(a1)
	movem.l 80(a0),d1-d7/a2-a4
	movem.l d1-d7/a2-a4,80(a1)
	movem.l 120(a0),d1-d7/a2-a4
	movem.l d1-d7/a2-a4,120(a1)
	add.l   #160,a1
	dbf     d0,loop

* L'‚cran ‚tant rempli,(200 lignes) il faut continuer
* pour la partie inf‚rieure.
	subq.l  #2,a1
	moveq   #63,d0    64 lignes
	
loop2	movem.l (a0),d1-d7/a2-a4
	movem.l d1-d7/a2-a4,(a1)
	movem.l 40(a0),d1-d7/a2-a4
	movem.l d1-d7/a2-a4,40(a1)
	movem.l 80(a0),d1-d7/a2-a4
	movem.l d1-d7/a2-a4,80(a1)
	movem.l 120(a0),d1-d7/a2-a4
	movem.l d1-d7/a2-a4,120(a1)
	add.l   #160,a1
	dbf     d0,loop2
	rts
*----------------------------------------------------------*
data:                           ;fill pattern
	dc.w    $0000,$0000,$0000,$0000,$0FFF,$0000,$0000,$0000
	dc.w    $FF00,$00FF,$0000,$0000,$000F,$FFFF,$0000,$0000
	dc.w    $FFFF,$FFFF,$0000,$0000,$0000,$0000,$FFFF,$0000
	dc.w    $0FFF,$0000,$FFFF,$0000,$FF00,$00FF,$FFFF,$0000
	dc.w    $000F,$FFFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000
	dc.w    $0000,$0000,$0000,$FFFF,$0FFF,$0000,$0000,$FFFF
	dc.w    $FF00,$00FF,$0000,$FFFF,$000F,$FFFF,$0000,$FFFF
	dc.w    $FFFF,$FFFF,$0000,$FFFF,$0000,$0000,$FFFF,$FFFF
	dc.w    $0FFF,$0000,$FFFF,$FFFF,$FF00,$00FF,$FFFF,$FFFF
	dc.w    $000F,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF

oldrez: 	dc.w 0
oldadr: 	dc.l 0
savereg: 	dc.l 0
oldsync: 	dc.w 0
old4: 	dc.l 0
oldtb: 	dc.l 0
oldkey: 	dc.l 0
old07: 	dc.b 0
old09: 	dc.b 0
old13: 	dc.b 0
old15: 	dc.b 0
old1b: 	dc.b 0
	even
contr: 	dc.b 21,4,15,06
