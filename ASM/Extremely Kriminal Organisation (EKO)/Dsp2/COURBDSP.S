*-------------------------------------------------------------------------*
*   Exemple de programme utilisant le DSP..
*-------------------------------------------------------------------------*
*   Cod‚ par Thorin&Major-X pour How To Code II,le Retour
*-------------------------------------------------------------------------*
*   Debugg‚ par Thorin,c'est … dire moi.
*-------------------------------------------------------------------------*
*  Pour joindre les auteurs:Sur RTEL:
*  Major-X:BAL MAJOR X    (ca parait logique)
*  Thorin:BAL OAKENSHIELD
*-------------------------------------------------------------------------*
* Le programme trace … l'ecran une courbe parametr‚e de la forme:
* X=sina*sinb    Y=sinc*sind      Avec 4096 points,et il reste un temps 
* machine pas negligeable du tout.
* Tous les calculs sont bien sur faits par le DSP,et ce faineant de 68030
* n'a plus qu'a afficher les points ou il faut.
* C'est intolerable,faire bosser ainsi un pauvre petit DSP alors que le 68030
* se tourne les pouces. 	
*--------------------------------------------------------------------------*
*PARAMETRES DE LA COURBE:
ai	equ	0	*Angles d'origine
bi	equ	1024	
ci	equ	512
di	equ 	1024

iva	equ	30	*Increment d'angle d'origine(par courbe/VBL)
ivb	equ	40
ivc	equ	20
ivd	equ	15

ipa	equ	8	*Increment d'angle(par point)
ipb	equ	7
ipc	equ	7
ipd	equ	8
*-------------------------------------------------------------------------*

	pea	00.w
	move.w	#$20,-(sp)		*Hops,on passe en superviseur
	trap	#1
	addq.l	#6,sp
	
	move.w	#-1,-(sp)
	move.w	#$58,-(sp)		*On sauvegarde la rezo
	trap	#14
	addq.l	#4,sp
	move.w	d0,sav_rezo
	
	move.w	#2,-(sp)
	trap	#14			*Et l'adresse ecran
	addq.l	#2,sp
	move.l	d0,sav_pbas

	move.l	#ecran+4,d0		*On calcule une adresse ecran multiple
	andi.b	#$fc,d0			*de 4 (sinon le VIDEL il est pas 
	move.l	d0,scrlog		*content)
	add.l	#320*201*2,d0		*Et on en prend une seconde un ecran
	move.l	d0,scrphy		*plus loin
		* sopv8nnn
	move.w	#%00100100,-(sp)
	move.w	#3,-(sp)
	move.l	scrlog,-(sp)		*Et hop,on change de rezo et on passe
	move.l	scrlog,-(sp)		*en 320*200 TC 
	move.w	#5,-(sp)
	trap	#14
	add.l	#14,sp

	move.l	scrlog,a0
	move.l	a0,d1
	move.w	#320*201-1,d0		*On colorie les ecrans en noir
eff_screen:
	move.l	#0,(a0)+
	dbf	d0,eff_screen

	lea	buf_eff,a0
	move.w	#4096*2-1,d0		*On initialise les buffers 
					*d'effacement pour qu'ils soient
					*sur l'ecran(histoire d'eviter deux
					*petites bombinettes)
init_buf:
	move.l	d1,(a0)+
	dbf	d0,init_buf
	
	lea	buf_eff,a0
	move.l	a0,effphy		*On prepare l'adresse des deux buffers
					*d'effacement
	add.l	#4096*4,a0
	move.l	a0,efflog
	
	
	
	lea	nfdsp,a6
	bsr	dsp_load		*On envoie le .lod dans le DSP
	tst.w	d0
	bpl.s	no_error
	pea	error_txt
	move.w	#9,-(sp)		*ERREUR!!!
	trap	#1
	addq.l	#6,sp
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	bra	fin
no_error:

	btst.b	#1,$ffffa202.w		*On attend que le DSP soit
	beq	no_error		*pret … recevoir
	lea	$ffffa204.w,a1		*a1 pointe sur le port HOST
	lea	sinus,a0
	move.w	#4096-1,d0
trans_sinerien:
	move.l	(a0)+,(a1)		*On envoie la table de sinus par
	dbf	d0,trans_sinerien	*le port HOST(en urgent)
	
	move.l	#ipa,(a1)			*Ici,on envoie les increments de 
	move.l	#ipb,(a1)			*chaque angle a,b,c,d
	move.l	#ipc,(a1)		*(essayez d'autres valeurs,la 
	move.l	#ipd,(a1)		*courbe change enormement..)
	
	
	move.l	#ai,d2			*C'est la valeur de base des angles
	move.l	#bi,d3			*a,b,c,d,qui varie … chaque VBL
	move.l	#ci,d4
	move.l	#di,d5
	
*-------------------------------------------------------------------------*
*  H‚,‡a commence
*-------------------------------------------------------------------------*
vbl:		
	lea	$ffffa204.w,a1
	move.l	scrlog,a6		*Inversion ecrans logique et
	move.l	scrphy,scrlog		*Physique
	move.l	a6,scrphy
	move.l	efflog,a6
	move.l	effphy,efflog
	move.l	a6,effphy
	
	move.b	scrphy+1,$ffff8201.w	*Affichage ecran physique
	move.b	scrphy+2,$ffff8203.w
	move.b	scrphy+3,$ffff820d.w
                                    	
	bsr	effacez_moi_ca
	bsr	affichez

	*move.l	#0,$ffff9800.w		*Vas-y,enleves l'* si tu veux
	move.w	#$25,-(sp)		*voir le temps machine
	trap	#14			*VSYNC
	addq.l	#2,sp	
	*move.l	#-1,$ffff9800.w
	
	cmpi.b	#$39,$fffffc02.w	*Test touche classique
	bne	vbl
*----------------------------------------------------------------
* Oh,c'est fini
*-----------------------------------------------------------------
fin:
	move.w	sav_rezo,-(sp)
	move.w	#3,-(sp)
	move.l	sav_pbas,-(sp)		*On rend l'ecran
	move.l	sav_pbas,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#14,sp
	
	clr.w	-(sp)			*On se barre 
	trap	#1
*-------------------------------------------------------------------------*
*  Routine d'affichage                                                    *
*-------------------------------------------------------------------------*
affichez:
	btst.b	#1,$ffffa202.w		*DSP,pouvez vous emettre?
	beq	affichez
					*Oui oui,5/5
	move.l	scrlog,(a1)		*Je t'envoies l'adresse ecran
	move.l	d2,(a1)			*Et les angles de depart
	move.l	d3,(a1)
	move.l	d4,(a1)
	move.l	d5,(a1)

	add.l	#iva,d2			*Maintenant je modifie les angles
	add.l	#ivb,d3			*en prevision du prochain 
	add.l	#ivc,d4			*passage
	add.l	#ivd,d5			
	andi.l	#4096-1,d2
	andi.l	#4096-1,d3
	andi.l	#4096-1,d4
	andi.l	#4096-1,d5
	
	move.w	#$00ff,d1		*Cette couleur me plait..
	move.l	efflog,a3
handr1:	
	btst.b	#0,$ffffa202.w		*DSP,vous me recevez?
	beq	handr1
					*5/5
	move.w	#4096/16-1,d0		*Tu m'envoies donc 4096 points
la_boucle:			
	rept	16
	move.l	(a1),a2			*Hops,j'ai l'adresse
	move.l	a2,(a3)+		*Ke je stocke pour l'effa‡age
	move.w	d1,(a2)			*Puis j'ecris … ct'adresse
	endr
	dbf	d0,la_boucle
	rts
*-------------------------------------------------------------------------*
*     Routine d'effa‡age des points.Utilise le buffer rempli lors de      *
*                          l'affichage                                    *
*-------------------------------------------------------------------------*
effacez_moi_ca:
	move.l	efflog,a3
	move.w	#0,d6
	move.w	#4096/16-1,d0	
efface:
	rept	16
	move.l	(a3)+,a4		*On procede … un effacage 
	move.w	d6,(a4)			*des points amoureusement
	endr				*affich‚s.C'est un genocide!!!
	dbf	d0,efface
	rts
*-------------------------------------------------------------------------*
* Routine d'execution d'un LOD
*
* Parametre:
*	a6 = pointeur sur le nom du fichier a executer
* Sorti:
*	d0 Si d0 = -1 il y a eu une erreur
*-------------------------------------------------------------------------*
dsp_load:			*Procedure d'envoi du .lod au
				*DSP
	pea	yav		*DSP_available.On aura en yav et xav
	pea	xav		*la memoire libre
	move.w	#106,-(sp)	*Je demande combien ya de libre en X et en Y
	trap	#14	
	add.l	#10,sp
	
	move.l	yav,-(sp)	*Dsp_Reserve.On reserve les memoires xav et
	move.l	xav,-(sp)	*yav
	move.w	#107,-(sp)	*Je reserve tout
	trap	#14
	add.l	#10,sp
	
	pea	buf_dsp		*Et j'envoie mon .lod dont le nom
	move.w	#3,-(sp)	*est en (a6)
	pea	(a6)		*(grace au DSP_LoadProg)
	move.w	#108,-(sp)	*(buf_dsp est un buffer temporaire
	trap	#14		*utilis‚ par le xbios)
	add.l	#12,sp
	rts
*---------------------------*
	section	DATA
*---------------------------*
error_txt:
	dc.b	7,27,"E",27,"pErreur",27,"q lors du chargement du"
	dc.b 	"fichier LOD :",10,13
nfdsp:	dc.b	"a:\CODEDSP.lod",0	* Nom du fichier LOD
sinus:	incbin	sinudsp2.dta		*table de sinus sur 23bits
*---------------------------*
	section	BSS
*---------------------------*
xav	ds.l	1
yav	ds.l	1
buf_dsp	ds.l	2000
sav_stack:
	ds.l	1
sav_rezo:
	ds.w	1
sav_pbas:
	ds.l	1
buf_eff:
	ds.l	4096*2
scrlog:
	ds.l	1
scrphy:	
	ds.l	1
efflog:
	ds.l	1
effphy:
	ds.l	1
ecran:	ds.b	320*201*2*2
