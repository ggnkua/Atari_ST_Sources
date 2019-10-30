;*****************************
;* FORMATTAGE DISQUE SF/DF
;* EN ASSEMBLEUR  68000
;* Specifique ATARI
;* (c)1994 S.ROHAUT/START MICRO 
;*****************************
	move.w	#4,-(sp)		;GETREZ:fournit la r‚solution
	trap	#14		;XBIOS 4
	addq.l	#2,sp		;restaure pile
	cmp.w	#2,d0		;Si c'est 2 c'est la haute
	beq.s	sm124		;donc on passe pas en moyenne
	move.w	d0,oldres		;sauve ancienne resolution
	move.w	#1,-(sp)		;0:basse/1:moyenne/2:haute
	move.l	#-1,-(sp)		;phybase
	move.l	#-1,-(sp)		;logbase
	move.w	#5,-(sp)		;SETSCREEN
	trap	#14		;XBIOS 5
	lea	12(sp),sp		;restaure pile=add.l	#12,sp	
;************************************
;* TOUT CE QU'IL FAUT POUR EFFACER
;* L'ECRAN !!BOUCLE EN DEUX LIGNES
;* S'IL VOUS PLAIT !!!
;************************************
sm124:	move.w	#2,-(sp)		;PHYBASE:adr ecran
	trap	#14		;XIOS 2
	addq.l	#2,sp		;restaure pile
	movea.l	d0,a0		;transfert dans a0
	move.w	#8000,d0		;compteur long word
cls:	clr.l	(a0)+		;j'empile des zeros
	dbf	d0,cls		;donc j'efface
;************************************
;* On se presente
;************************************
	move.l	#text1,-(sp)	;adresse text1
	move.w	#9,-(sp)		;CONWS:affiche chaine ascii
	trap	#1		;GEMDOS
	addq.l	#6,sp		;restaure pile
;************************************
;* GESTION DES TOUCHES
;* PAR FONCTION 1 DU GEMDOS
;* APPUI PUIS AFFICHAGE
;************************************
	move.w	#1,-(sp)		;CONIN:attend touche et affiche
	trap	#1		;GEMDOS
	addq.l	#2,sp		;restaure la pile
	cmp.b	#$73,d0		;si "s" alors
	beq.s	suite1		;dans suite1
	cmp.b	#$53,d0		;si "S" alors
	beq.s	suite1		;dans suite1
	move.w	#1,etatface	;sinon double face
	bra.s 	suite2		;et suite2
suite1:	clr.w	etatface		;simple face		
;************************************
;* IDEM MAIS POUR LES SECTEURS
;* 9 OU 10: GERES PAR LE GEMDOS
;* 0 OU 1 SUR PAVE NUMERIQUE
;************************************
suite2:	move.w	#10,nbsector	;normallement 10 secteurs
	move.l	#text2,-(sp)	;adresse text2
	move.w	#9,-(sp)		;CONWS:affiche chaine ascii
	trap	#1		;GEMDOS 9
	addq.l	#6,sp		;restaure pile
	move.w	#1,-(sp)		;CONIN:attend touche et affiche
	trap	#1		;GEMDOS 1
	addq.l	#2,sp		;restaure pile
	subi.b	#39,d0		;retranche 39
	cmp.b	#9,d0		;et compare
	bne.s	format		;si <>9 alors c'est 10
	move.w	#9,nbsector	;sinon c'est 9 !
; De la maiŠre pr‚c‚dente, quelque soit la touche appuy‚e
; on est sur que ce soit 10 secteurs, sauf pour le 9, bien sur !			
;************************************
;* FONCTION XBIOS 10
;* FORMATTAGE DE PISTES
;************************************
format:	move.w	#0,-(sp)		;motif des secteurs
	move.l	#$87654321,-(sp)	;magic number
	move.w	#1,-(sp)		;ordre des secteur
	move.w	face,-(sp)		;num‚ro de face
	move.w	compteur,-(sp)	;numero de piste
	move.w	nbsector,-(sp)	;secteurs par piste 
	clr.w	-(sp)		;sur le lecteur 0 (A)
	clr.l	-(sp)		;???
	move.l	#memwork,-(sp)	;memoire tampon 8000 bytes
	move.w	#10,-(sp)		;FLOPFMT:formatte des pistes
	trap	#14		;XBIOS
	lea	26(sp),sp		;restaure pile= add.l #26,sp
;************************************
;* REGARDE SI SIMPLE OU DOUBLE
;* SI DOUBLE, ON RECOMMENCE SUR LA 
;* FACE 1
;************************************
	cmpi.w	#1,etatface	;si pas format double
	bne.s	format2		;piste suivante
	addq.w	#1,face		;sinon face+1
	cmpi.w	#1,face		;si face=1
	beq	format		;alors formatte
	clr.w	face		;sinon face 0 et suite
;**************************************
;* debut bouche formattage: on commence
;* par afficher le compteur de piste
;*La routine suivante permet de transformer
;*un nombre de 2 chiffres en une chaine
;*de caracteres...
;**************************************
format2:	clr.l	d0		;nettoie D0
	move.w	compteur,d0	;D0=compteur
	divu	#10,d0		;chiffre/10
	move.b	d0,dizaine		;c'est la dizaine
	add.b	#48,dizaine	;ASCII de la dizaine
	mulu	#10,d0		;dizaine*10
	move.w	compteur,d1	;chiffre dans d1
	sub.b	d0,d1		;chiffre-(dizaine*10)
	move.b	d1,unite		;c'est l'unit‚
	add.b	#48,unite		;ASCII de l'unite
	move.l	#text,a0		;A0=adresse text
	move.b	dizaine,13(a0)	;place l'ascii dizaine
	move.b	unite,14(a0)	;place l'ascii unite
	move.l	#text,-(sp)	;adresse text
	move.w	#9,-(sp)		;CONWS: sort chaine ascii
	trap	#1		;GEMDOS 9
	addq.l	#6,sp		;restore pile
;************************************
;* change de piste et boucle
;************************************	
	addq.w	#1,compteur	;on change de piste
	cmp.w	#80,compteur	;si<>80
	bne	format		;on reboucle
;************************************
;* FORMATTAGE FINI, ON PASSE AU BOOT
;* Thanks to MARC CORDIER
;* Voir TRUCK SYSTEME 2 et 3
;* CONSTRUCTION DU BOOT: ORDRE
;* Branch: 	     1 word
;* Loader: 	     6 Bytes
;* Serial: 	     3 Bytes
;* BPS:Bytes Per Sector:   1 word
;* SPC:Sector Per cluster: 1 Byte
;* RES:Reserved Sector:    1 Word
;* FAT: 		     1 Word
;* DIR: 		     1 Word
;* SEC: 		     1 Word
;* MEDIA: 		     1 Byte
;* SPF:Sector Per FAT:     1 Word
;* SPT:Sector Per Track:   1 Word
;* SIDE: 		     1 Word
;* HID: 		     1 Word
;* + 480 bytes sans signification
;* CHECKSUM: 	     1 Word
;**************************************
	move.l	#text3,-(sp)	;adresse text3
	move.w	#9,-(sp)		;CONWS:sort chaine ascii
	trap	#1		;GEMDOS 9
	addq.l	#6,sp		;restaure pile
	move.l	#boot,a0		;A0=adresse boot
	move.w	#$E900,(a0)+	;branch
	move.l	#$4e4e4e4e,(a0)+	;loader
	move.l	#$4e4e0000,(a0)+	;loader+serial(1,2)
	move.l	#$00000202,(a0)+	;serial(3)+BPS+SPC
	move.l	#$01000270,(a0)+	;RES+FAT+DIR(1)
	clr.l	d0
	move.w	nbsector,d0	;nbsector
	addq.w	#1,etatface	;*(etatface+1)
	mulu.w	etatface,d0
	mulu.w	#80,d0		;*nbpiste
	ror.w	#8,d0		;decale 1 octet -> Word
	rol.l	#8,d0		;decale 1 octet <- Long Word
	move.b	#248,d0		;MEDIA 248
	subq.w	#1,etatface	;+(etatface-1)
	add.w	etatface,d0	;et on place	
	move.l	d0,(a0)+		;DIR(2)+SEC+MEDIA
	move.l	#$03000000,d0	;3 secteurs par FAT
	move.w	nbsector,d0	;nbsector par pistes 
	ror.w	#8,d0 		;petite rotation
	move.l	d0,(a0)+		;SPF+SPT
	clr.l	d0
	addq.w	#1,etatface	;nbre de faces
	move.w	etatface,d0
	ror.w	#8,d0		;une serie de 
	rol.l	#8,d0		;rotations pour placer
	rol.l	#8,d0		;tout au bon endroit
	clr.w	d0		;pas de secteurs caches
	move.l	d0,(a0)+		;SIDE+HID
;****************************************
;* MODELE SUIVANT ISSU DU FORMATTAGE 
;* SYSTEME: 30 'N', 12 octets nuls,
;* 3 octets 245...
;****************************************
	clr.l	d0
	move.b	#15,d0
boucboot1:	move.w	#"NN",(a0)+
	dbra	d0,boucboot1
	move.b	#3,d0
boucboot2: clr.l	(a0)+
	dbra	d0,boucboot2
	move.w	#$F5F5,(a0)+
	move.w	#$F5FE,(a0)+
	move.l	#$4f000102,(a0)+
	move.w	#$F74E,(a0)+
	move.b	#10,d0
boucboot3: move.w	#"NN",(a0)+
	dbra	d0,boucboot3
	move.w	#$4E00,(a0)+
	move.b	#5,d0
boucboot4:	clr.w	(a0)+
	dbra	d0,boucboot4
	move.l	#$00F5F5F5,(a0)+
	move.l	#$FBE5E5E5,(a0)+
	move.b	#97,d0
boucboot5:	move.l	#$E5E5E5E5,(a0)+
	dbra	d0,boucboot5
;**************************************
;* IL FAUT MAINTENANT 'CONFIRMER'
;* LE BOOT PAR UN XBIOS 18
;**************************************
	clr.w	-(sp)		;boot non executable
	move.w	#-1,-(sp)		;ne change pas le media
	move.l	#$1ffffff,-(sp)	;numero de serie au hasard
	move.l	#boot,-(sp)	;adresse du boot
	move.w	#18,-(sp)		;PROTOBT:pr‚pare le checksum
	trap	#14		;XBIOS
	lea	14(sp),sp		;restaure pile=add.l	#18,sp
	clr.w	-(sp)		;sur le lecteur 0 (A)
	move.w	#7,-(sp)		;GETBPB:demande parametres disk
	trap	#13		;BIOS 7
	addq.l	#4,sp		;restaure pile
;***************************************
;* ON INSTALLE LE BOOT PAR UN XBIOS 9
;***************************************
	move.w	#1,-(sp)		;ecrit 1 secteur
	clr.w	-(sp)		;sur la face 0
	clr.w	-(sp)		;sur la piste 0
	move.w	#1,-(sp)		;sur le secteur 1
	clr.w	-(sp)		;sur le lecteur 0 (A)
	clr.l	-(sp)		;???
	move.l	#boot,-(sp)	;adresse du boot
	move.w	#9,-(sp)		;FLOPWRITE:ecrit secteur
	trap	#14		;XBIOS 9
	lea	20(sp),sp		;restaure pile=add.l #20,sp
	clr.w	-(sp)		;sur le lecteur 0 (A)
	move.w	#7,-(sp)		;GETBPB:demande parametres disk
	trap	#13		;BIOS
	addq.l	#4,sp		;restaure pile
;**************************************
;* ON PASSE AUX FATS: STRUCTURE:
;* 2 FATS DE 5 SECTEURS SOIT 10 SECTEURS
;* LES 2 FATS SE SUIVENT.
;* 1 WORD: &HF9FF 
;* 1 BYTE:&HFF
;* 2557 BYTES NULS
;**************************************
	move.l	#text4,-(sp)	;adresse text4
	move.w	#9,-(sp)		;CONWS:sort chaine asci
	trap	#1		;GEMDOS 9
	addq.l	#6,sp		;restaure pile
	move.l	#fat,a0		;A0=adr FAT
	subq.w	#1,etatface	;Calcul du MEDIA
	move.w	etatface,d0	;etatface-1
	add.w	#248,d0		;+248
	rol.l	#8,d0		;au 2nd byte de
	rol.l	#8,d0		;poid fort
	move.w	#$FFFF,d0		;on complete
	rol.l	#8,d0		;pret … placer
	move.l	d0,(a0)		;installe les 
	move.l	d0,1536(a0)	;entetes de FAT
	clr.w	-(sp)		;sur le lecteur 0 (A)
	move.w	#1,-(sp)		;… partir secteur 1
	move.w	#6,-(sp)		;sur 6 secteurs
	move.l	#fat,-(sp)		;adresse FAT
	move.w	#3,-(sp)		;Ecrit secteurs
	move.w	#4,-(sp)		;RWABS:Ecrit secteurs	
	trap	#13		;BIOS 4
	lea	14(sp),sp		;restaure pile
;************************************
;* C'EST FINI. ON ATTEND, ON REMET
;* L'ANCIENNE RESOLUTION, ET ON QUITTE
;************************************
	move.l	#text5,-(sp)	;adresse text
	move.w	#9,-(sp)		;CONWS:affiche chaine ascii
	trap	#1		;GEMDOS 9
	addq.l	#6,sp		;restore pile
	move.w	#7,-(sp)		;RAWCONIN:attend touche sans afficher
	trap	#1		;GEMDOS 1
	addq.l	#2,sp		;restore pile
	clr.l	d0		;vide D0
	move.w	#4,-(sp)		;GETREZ:d‚finition
	trap	#14		;XBIOS 4
	addq.l	#2,sp		;restore pile
	cmp.b	#2,d0		;si haute on quitte directement
	beq.s	the_end		;sinon on restaure l'ex-r‚so
	move.w	oldres,-(sp)	;ancienne resolution
	move.l	#-1,-(sp)		;physique 
	move.l	#-1,-(sp)		;logique
	move.w	#5,-(sp)		;SETSCREEN:change etat ecran
	trap	#14		;XBIOS 5
	lea	12(sp),sp		;restaure pile =add.l #12,sp
the_end:	clr.l	-(sp)		;PTERM:on quitte
	trap	#1		;GEMDOS 0
;***********************************
;* LES DATAS. EVEN ‚vite les adresses
;* impaires dans le cas des bytes
;***********************************
	section data
	
text1:	dc.b	27,"Y",32,53,"FORMATTAGE D'UN DISQUE EN ASSEMBLEUR. "
	dc.b	27,"Y",33,53,"------------------------------------- "
	dc.b	27,"Y",34,53,27,"p","(c)1994 S‚bastien ROHAUT & START MICRO",27,"q"
	dc.b	27,"Y",36,36,"(S)imple ?",0
text2:	dc.b	27,"Y",37,36,"0:9 secteurs. 1:10 secteurs. Votre choix ?",0
text3:	dc.b	27,"Y",39,32,"Pr‚pare et ‚crit le boot...",0
text4:	dc.b	27,"Y",40,32,"Pr‚pare et ‚crit les FATs...",0
text5:	dc.b	27,"Y",45,36,"Formattage termin‚ ! appuyez sur une touche...",0
text:	dc.b	27,"Y",38,32,"Piste nø:   ",0
	
	even
	
unite:	dc.b	0
dizaine:	dc.b	0
etatface:	dc.w 	0
face:	dc.w	0
nbsector:	dc.w	0
compteur:	dc.w	0
oldres:	dc.w	0	
	
	even
	
	section bss
	
memwork:	ds.b	8000		;memwork
boot:	ds.b	512		;le bootsector
fat:	ds.b	3072		;6 secteurs*512