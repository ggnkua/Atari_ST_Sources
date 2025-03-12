*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
|                                                                           |
*                    Sources de sprites 32*32 au BLITTER (II)               *
|                     Par    CREATEUR   /   Association Eko                 |
*                                                                           *
|                                                                           |
*       Voici les sources accompagnant l'article sur le blitter.Pour que ca * 
|  marche il faut mettre  en moyenne  r‚solution. Il n' y a pas  de test de | 
*  sorti,en effet CREATEUR et un grand f‚niant.Tapez lui dessus sur minitel *
|  3614 RTEL1 bal CREATEUR.                                                 |
*                                                                           *
|                                                                           |
*   Pour avoir les sources vous pouvez les d‚compacter et les d‚cryter avec *
|  ST-ZIP. Pour cel… regardez l' article DISKETTE si vous ne connaissez pas |
*  bien  ST-ZIP et  pour connaitre le mode d‚crytage de  cet utilitaire  ou *
|  alors faites crypt ON avec MARCUS comme mot de passe pour le d‚cryptage. |
*  Les sources de cet article sont dans le fichier BLITTER.                 *
|                                                                           |
*                                                                           *
|                                                                           |
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


	opt	c-

DEBUT:	
	PEA	0.W
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP	

	include	ste.s			; On inclu les MACRO

	MOVE.L	#BUFFERSCR,D0
	MOVE.L	D0,SCREEN1
	ADD.L	#32000,D0
	MOVE.L	D0,SCREEN2

				        ; comme d'habitude,on quitte 
					; par reset ...
	move.l	$4.w,d0
	move.l	d0,$8.w
	move.l	d0,$c.w
	move.l	d0,$10.w
	move.l	d0,$14.w
	move.l	d0,$18.w
	move.l	d0,$1c.w
	move.l	d0,$20.w
*	move	#$2300,sr

	CLR	-(sp)
	PEA	-1.W
	PEA	-1.W
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	adrecran	screen2


	move.l	#clavier,$118.w


	* prepare le masque
mask:	
	move.w	#32-1,d0
	lea	sprite,a0
	lea	masque,a1
.syva		
	rept	2
	move.w	(a0)+,d7
	or.w	(a0)+,d7
	or.w	(a0)+,d7
	or.w	(a0)+,d7
	not.w	d7
	move.w	d7,(a1)+
	endr
	lea	16-2*8(a0),a0
	dbra	d0,.syva

	MOVE.B	#$12,$FFFFFC02.W
	move.l	#vblbidon,$70.w

*la palette...

	lea	pal,a0
	lea	$ffff8240,a1
	move.w	#8-1,d0
.a	move.l	(a0)+,(a1)+
	dbra	d0,.a

a
	bsr	prg
	move.w	com,d0

.lo	cmp.w	com,d0
	beq.s	.lo
	bra	a


com	dc.w	0

vblbidon
	addq.w	#1,com
	rte

prg:	
	sf	$ffff8240.w
	MOVEA.L	SCREEN2,A6
 				; on efface 4 plans <=> ‚norme perte 
                                ; de temps.
	mask1		#-1
	mask2		#-1
	mask3		#-1
	oplog		#0
	offsetxd	#2
	offsetyd	#160-(80*2)+2
	hauteur		#200
	longueur	#80
	destination	a6	
	startblitinter
	addq.w		#2,a6	
	
					; On g‚re le clavier:
	move.b	ancien,d0
	move.w	x,d1
	move.w	y,d2
	
	cmp.b	#$48,d0
	bne.s	.suit
	sub.w	#1,d2
	bra.s	.fin
.suit
	cmp.b	#$50,d0
	bne.s	.suit1
	add.w	#1,d2
	bra.s	.fin
.suit1
	cmp.b	#$4b,d0
	bne.s	.suit2
	sub.w	#1,d1
	bra.s	.fin
.suit2
	cmp.b	#$4d,d0
	bne.s	.fin
	add.w	#1,d1
.fin
	tst.w	d1
	bgt.s	.clip
	moveq	#0,d1
.clip
	tst.w	d2
	bgt.s	.clip2
	moveq	#0,d2
.clip2
	cmp.w	#319-32,d1
	blt.s	.clip3
	move.w	#319-32,d1
.clip3
	cmp.w	#199-32,d2
	blt.s	.clip4
	move.w	#199-32,d2
.clip4

	move.w	d1,x
	move.w	d2,y




				; l… , la routine a tester.
	move.l	screen2,a0
	bsr	affsprite
	
	move.l	SCREEN2,d0
	move.l	SCREEN1,SCREEN2
	move.l	d0,SCREEN1
	adrecran	screen1

NO_CONT2	CMPI.B	#$38,$FFFFFC02.w
	bne.s	cool
	not	$ffff8240.w
	

cool	RTs


x	dc.w	0
y	dc.w	0


affsprite
				; 12 avec inter,15 sans.
	move.w	x,d0
	move.w	y,d1
				; d0=x d1=y a0=adresse 
				; ecran destination
	lea	sprite,a1
	lea	masque,a2
	moveq	#32,d7	hauteur
	moveq	#2+1,d6	longueur
	
				; Calcul adr et skew.
	mulu	#160,d1
	add.w	d1,a0
	move.w	d0,d1
	and.w	#$fff0,d0
	and.w	#$f,d1
	lsr.w	#1,d0
	add.w	d0,a0
	or.w	#$40,d1
	skew	d1
	moveq	#-1,d0
	mask2	d0
	lsr.w	d1,d0
	mask1	d0
	not	d0
	mask3	d0

				; Affiche masque
	op	#2
	oplog	#1	and

	offsetxd	#8
	offsetyd	#160-(3*8)+8
				 ; On ne varie pas en destination...
	offsetxs	#2
	offsetys	#4-(2*2)+2
				 ; Varie en source.
	rept	4
	source	a2
	longueur	d6
	hauteur	d7
	destination	a0
	startblitinter
	lea	2(a0),a0
	endr
	lea	-8(a0),a0

				 ; Affiche sprite
	oplog	#6	or
	offsetxs	#8
	offsetys	#16-(2*8)+8

	rept	4
	source	a1
	longueur	d6
	hauteur	d7
	destination	a0
	startblitinter
	lea	2(a0),a0
	lea	2(a1),a1
	endr

	rts

ancien	dc.b	0
	dc.b	0
clavier
	move.b	$fffffc02.w,ancien

	bclr	#6,$fffffa11.w		* end of interupt
	rte	



SCREEN1	dcb.L	1
SCREEN2	dcb.L	1


*
*  NEOchrome V2.24 cut buffer contents (left justified):
*  by Chaos, Inc. of the Delta Force (member of The Union)
*
*    pixels/scanline    = $0020 (bytes/scanline: $0010)
*  # scanlines (height) = $0020
*
*  Hardware color pallet  (color 0 to 15):
*
pal	dc.w	$0000,$0101,$0323,$0212,$0101,$0434,$0545,$0312
	dc.w	$0423,$0534,$0201,$0656,$0767,$0756,$0645,$0745
*
*
sprite	dc.w	$0006,$0007,$0008,$0000,$E000,$E000,$1000,$0000
	dc.w	$0007,$007D,$0002,$0000,$F600,$FE00,$0000,$0000
	dc.w	$00F1,$010F,$00FC,$0000,$F780,$FF80,$0000,$0000
	dc.w	$0278,$01F7,$0388,$0070,$75C0,$C5C0,$3A00,$0000
	dc.w	$050E,$0379,$06F6,$0188,$6AA0,$AAE0,$5500,$0000
	dc.w	$0C47,$0476,$0BB9,$07CF,$A5C0,$6640,$DBB0,$8000
	dc.w	$0106,$1809,$0FFF,$07F0,$6C00,$EA00,$97F8,$4000
	dc.w	$33CF,$2971,$1FBE,$07C1,$F278,$7C78,$8F84,$C000
	dc.w	$314F,$2871,$1FBE,$07C1,$F278,$FC78,$8F84,$C000
	dc.w	$150B,$2D77,$5AFD,$0783,$8700,$78CA,$FF34,$800A
	dc.w	$51AF,$6BBA,$1E57,$05EE,$A454,$6576,$9B8C,$0002
	dc.w	$4CDC,$7BE3,$1734,$08D8,$6B80,$EAB8,$1544,$0002
	dc.w	$45B1,$3B4F,$F670,$0180,$BA02,$F5F2,$0E03,$000C
	dc.w	$73C7,$5F3F,$A5E8,$0300,$A602,$D9F7,$3E0A,$0005
	dc.w	$BF3C,$ACF3,$534F,$0600,$18D3,$E8FF,$F702,$000C
	dc.w	$EFF4,$DA27,$37D9,$0FE0,$0083,$FCCF,$E303,$003C
	dc.w	$43C8,$BD3B,$66F5,$0340,$30AB,$D2F9,$ED29,$0016
	dc.w	$70C6,$97BF,$6871,$0040,$6127,$93FD,$EC25,$001A
	dc.w	$8C07,$ED7E,$12B9,$0000,$E046,$11DF,$EE06,$0039
	dc.w	$400F,$7EF4,$8139,$0002,$86E6,$6EE7,$82E6,$1919
	dc.w	$45FE,$6601,$19FE,$0000,$05CE,$D4FA,$04CA,$2B34
	dc.w	$13F0,$500F,$2FF0,$0001,$0314,$40F2,$8010,$7FEE
	dc.w	$6000,$77E8,$0813,$0004,$0208,$80EA,$4008,$BFF6
	dc.w	$1400,$38C8,$0737,$0000,$0FD4,$C014,$0014,$FFE8
	dc.w	$1400,$38CB,$0734,$0003,$0FD4,$C014,$0014,$FFE8
	dc.w	$1081,$14FB,$0B01,$001E,$FF70,$C300,$C300,$3CF8
	dc.w	$0071,$085B,$07B1,$000E,$E190,$9D80,$9D80,$7E70
	dc.w	$00BF,$009D,$075D,$0022,$E1A0,$9D80,$9D80,$7E60
	dc.w	$006A,$0068,$0388,$0017,$5140,$1200,$1200,$EFC0
	dc.w	$0045,$01D0,$0000,$01AF,$FA80,$7880,$7880,$8700
	dc.w	$0053,$0070,$0050,$000F,$E600,$6600,$6600,$9800
	dc.w	$000E,$000E,$000E,$0001,$1000,$1000,$1000,$E000



	BSS
BUFFERSCR	ds.B	64000
masque	ds.b	32*2*2

