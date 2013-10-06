; COLORSTE.PRG
; programme r‚sident (dossier AUTO ou lanc‚ depuis le bureau)
; permet d'obtenir:
; 	- des icones couleurs sur le bureau
;  - des icones couleurs dans les boites d'alerte
;  - des ‚l‚ments de fenˆtre color‚s
; Tourne sur STE (TOS 1.6) uniquement (si j'avais d'autres machines
;		sous la main, je trouverai facilement les adresses!...)
; Auteur: Tello Guillaume (Ao–t 1995)
;			 240 rue Estienvrin
;			 49260 Montreuil Bellay
; assembl‚ avec ASSEMBLE de Brainstorm (tant pis pour ceux qui
; ont achet‚ DEVPAC)


	OUTPUT "A:\AUTO\COLORSTE.PRG"		; le programme ex‚cutable

	text
	
debut:
	jmp init									; saute la partie r‚sidente
	
inter:
	movem.l d1/a0-a2,-(sp)				; je m'en sers
	cmp #$73,d0								; appel VDI?
	bne fin									; non, rien … faire
	move.l plans,a0
	cmp #4,(a0)								; 4 plans?
	bne fin									; non, alors rien … faire.
relog_0:
	cmp.w #$1074,$6dbe					; COLOR du titre fenˆtre correct?
	beq.s autre							; oui, ne pas s'en occuper
relog_1:
	lea $72b4,a0							; premier COLOR de l'arbre
	lea table,a1							; mes mots COLOR
	moveq #18,d0							; 19 objets
.lb0:
	move (a1)+,d1		; un COLOR
	bne.s .lb1			; si non nul, normal
	move.l (a1)+,a2	; sinon, adresse tedinfo
	move (a1)+,(a2)	; COLOR pour tedinfo
	bra.s .lb2
.lb1:
	move d1,(a0)		; si normal, COLOR dans spec
.lb2:
	lea 24(a0),a0		; objet suivant
	dbf d0,.lb0
	moveq #$73,d0		; remet le code VDI
	bra fin
autre:
	move.l d1,a0			; vdi_param_blk
	move.l (a0),a0			; control
	cmp #121,(a0)			; vrt_cpyfm?
	bne fin					; non, rien … faire
relog_2:
	cmp.l #$a814,14(a0)	; MFBD source de l'AES?
	bne fin					; non, pas une icone alors!
relog_3:
	move.l $6d88,a0		; le BITBLK (pointeur donn‚es) des alertes
relog_4:
	cmp.l $a814,a0			; meme adresse?
	bne.s .non				; non, pas une icone d'alerte
	move.l d1,a0			; si oui, on est en train de dessiner l'icone
	move.l 4(a0),a0		; intin
	move #4,2(a0)			; couleur icone (du bleu au lieu du noir)
	bra fin
.non:
relog_5:
	move.l $6d66+4,a0		; ICONBLK des disques (pointeur datas)
relog_6:
	move.l $a814,a2		; adresse donn‚es
	cmp.l a2,a0				; meme adresse ?
	bne.s .pas_data		; non, on dessine autre chose
	lea 36(a2),a2			; adresse de l'octet discriminant
	lea lecteur-512,a0	; premiŠre icone
	cmp.b #$08,(a2)		; distinction pour lecteur
	beq.s .suite
	add.w #512,a0
	cmp.b #$3f,(a2)		; pour le dossier
	beq.s .suite
	add.w #512,a0
	cmp.b #$01,(a2)		; pour la poubelle
	beq.s .suite
	add.w #512,a0
	cmp.b #$40,(a2)		; programme
	beq.s .suite
	add.w #512,a0			; par d‚faut, fichier
.suite:
	move.l a0,mfdb			; adresse donn‚es
	move.l d1,a0
	move.l (a0),a1			; control
	move #109,(a1)			; vro_cpyfm (au lieu de vrt_cpyfm)
	move #1,6(a1)			; 1 seul intin
	move.l #mfdb,14(a1)	; nouvel mfdb
	move.l 4(a0),a0		; intin
	move #7,(a0)			; mode or
	bra.s fin
.pas_data:
relog_7:
	move.l $6d66,a0		; ICONBLK des disques (masques)
	cmp.l a2,a0				; bonne adresse?
	bne.s fin				; non, on dessine autre chose
relog_8:
	move.l $6d66+4,a2		; les datas
	add.w #36,a2			; l'octet critŠre
	lea m_lecteur,a0		; premier masque
	cmp.b #$08,(a2)		; distinction pour lecteur
	beq.s .suit
	add.w #128,a0
	cmp.b #$3f,(a2)		; pour le dossier
	beq.s .suit
	add.w #128,a0
	cmp.b #$01,(a2)		; pour la poubelle
	beq.s .suit
	add.w #128,a0
	cmp.b #$40,(a2)		; programme
	beq.s .suit
	add.w #128,a0			; par d‚faut, fichier
.suit:
relog_9:
	move.l a0,$a814		; masque choisi comme donn‚es du MFDB
	move.l d1,a0
	move.l 4(a0),a0		; intin 
	tst 2(a0)				; non nul pour l'inversion
	bne.s annul			; inversion, VDI annul‚ (sinon c'est laid)
fin:
	movem.l (sp)+,d1/a0-a2	; restaure les registres utilis‚s
	move.l sauve,-(sp)		; ancienne adresse VDI/AES
	rts							; … laquelle on saute
annul:		
	movem.l (sp)+,d1/a0-a2	; restaure
	rte							; et quitte VDI/AES
	
mfdb: dc.l lecteur-512		; mon mfdb couleur
	dc.w 32,32,2,0,4,0,0,0	; 32x32 en 4 plans
sauve: dc.l 0					; adresse ancien VDI/AES
plans: dc.l 0

; en $72A6 se trouve un arbre de 19 objets repr‚sentant une fenˆtre
; avec tous ses ‚l‚ments. Chaque fois que l'AES veut redessiner une
; fenˆtre il r‚initialise toute cette zone, il faut donc en permanence
; y mettre nos valeurs de couleurs. Comme l'AES appelle proprement le
; VDI pour les dessins des ‚l‚ments, il suffit de v‚rifier qu'… chaque
; appel VDI, nos valeurs y sont install‚es.
; Ci dessous on trouve les 19 mots de couleur (… mettre dans les ob_spec
; des BOX et BOXCHAR ou dans les deux tedinfos des BOXTEXT, en $6DAC on
; trouve la tedinfo du TITRE et en $6DD6 celle de la ligne INFO).

table: dc.w $1100	; BOX parent de la fenˆtre
		dc.w $1178	; BOX ligne du haut
		dc.w $1178	; CLOSER
		dc.w 0		; MOVEBAR et TITRE (indirect, dans tedinfo)
		dc.l $6dbe	; adresse tedinfo
		dc.w $1074	; MOVEBAR et TITRE (les vrais)
		dc.w $1178	; FULLER
		dc.w 0		; INFO (indirect, dans tedinfo)
		dc.l $6de8	; adresse tedinfo
		dc.w $117B	; INFO (le vrai)
		dc.w $1100	; BOX pour le reste de la fenˆtre
		dc.w $1180	; Zone de travail
		dc.w $1178	; SIZER
		dc.w $1178	; BOX pour V_SLIDER
		dc.w $1178	; UP
		dc.w $1178	; DOWN
		dc.w $1178	; V_FOND
		dc.w $1148	; V_SLIDER
		dc.w $1178  ; BOX pour H_SLIDER
		dc.w $1178	; LEFT
		dc.w $1178	; RIGHT
		dc.w $1178	; H_FOND
		dc.w $1148	; H_SLIDER

; L'AES dessine toutes ses icones … travers la fonction VDI vrt_cpyfm(121).
; Pour ˆtre certain que c'est l'AES qui appelle (et non un programme
; utilisateur), il suffit de v‚rifier que le MFDB source se situe en $A814.
; maintenant il faut distinguer l'icone alerte, l'icone bureau et le masque
; d'icone bureau.
; icone ALERTE:
; 		l'AES a auparavant pr‚par‚ une structure BITBLK en $6D88 dont l'adresse
;		des donn‚es doit correspondre … celle du mfdb. On change alors la
;		couleur (1 NOIR devient 4 BLEU). Par contre, le rainbow TOS en prend
;		un coup, l'icone de la boite d'infos du bureau reste bleue...
; icone BUREAU:
;		l'AES a auparavant pr‚par‚ une structure ICONBLK en $6D66 dont l'adresse
;		des donn‚es (en $6D66+4) doit correspondre au mfdb. On change alors
;		vrt_cpyfm en vro_cpyfm (copie couleur), mode OR et pour d‚terminer de
;		quelle icone il s'agit, le 36ø octet des icones monochromes est parti-
;		culier … chacune, on aiguille alors vers son correspondant couleur.
; masque BUREAU:
;		mˆme systŠme que pour les donn‚es (pour la d‚tection on se sert de
;		l'adresse du masque en $6D66), pour l'aiguillage c'est la mˆme proc‚dure
;		et on v‚rifie que le masque n'est pas utilis‚ pour l'inversion (lors
;		de la s‚lection). Pour le dessin normal intin vaut 2(mode) 0(coul) 1(fond)
;		et pour l'inversion intin vaut 2 1(coul) 0(fond), dans ce cas on
;		n'ex‚cute pas la copie (c'est moche). Seul le nom sous l'icone devrait
;		ˆtre invers‚.

; les masques d'icones!

m_lecteur:
 dc.w $0000,$07E0,$003F,$0FF0
 dc.w $007F,$BFFC,$00FF,$FFFC
 dc.w $03FF,$FFFF,$03FF,$FFFF
 dc.w $0FFF,$FFFF,$0FFF,$FFFF
 dc.w $3FFF,$FFFF,$3FFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFE,$FFFF,$FFFC
 dc.w $FFFF,$FFF8,$FFFF,$FFF0
 dc.w $FFFF,$FFE0,$FFFF,$FFC0
 dc.w $FFFF,$FF80,$FFFF,$FF00
 dc.w $FFFF,$FE00,$FFFF,$FE00
m_dossier
 dc.w $0000,$0000,$0000,$0000
 dc.w $0000,$0000,$0000,$0000
 dc.w $0000,$0000,$000F,$C000
 dc.w $001F,$E000,$1FFF,$FFF0
 dc.w $3FFF,$FFF8,$3FFF,$FFF8
 dc.w $7FFF,$FFFC,$7FFF,$FFFC
 dc.w $FFFF,$FFFE,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $7FFF,$FFFF,$3FFF,$FFFE
m_poubelle:
 dc.w $0000,$0000,$0000,$0000
 dc.w $0007,$C000,$0008,$2000
 dc.w $01FF,$FF00,$03FF,$FF80
 dc.w $07FF,$FFC0,$07FF,$FFC0
 dc.w $07FF,$FFC0,$03FF,$FF80
 dc.w $03FF,$FF80,$03FF,$FF80
 dc.w $03FF,$FF80,$03FF,$FF80
 dc.w $03FF,$FF80,$03FF,$FF80
 dc.w $03FF,$FF80,$03FF,$FF80
 dc.w $03FF,$FF80,$03FF,$FF80
 dc.w $03FF,$FF80,$03FF,$FF80
 dc.w $03FF,$FF80,$03FF,$FF80
 dc.w $03FF,$FF80,$03FF,$FF80
 dc.w $03FF,$FF80,$03FF,$FF80
 dc.w $03FF,$FF80,$03FF,$FF80
 dc.w $01FF,$FF00,$00FF,$FE00
m_programm:
 dc.w $FFFF,$FFFE,$FFFF,$FFFE
 dc.w $FFFF,$FFFE,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$3FFF,$FFFF
m_fichier:
 dc.w $FFFF,$FFF0,$FFFF,$FFF0
 dc.w $FFFF,$FFFC,$FFFF,$FFFC
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $FFFF,$FFFF,$FFFF,$FFFF
 dc.w $3FFF,$FFFF,$3FFF,$FFFF
 dc.w $0FFF,$FFFF,$0FFF,$FFFF

; les donn‚es d'icones!
; la zone sert au d‚placement d'une icone vers le bas
; lors du recodage entre le format INDEPENDANT et le SHIFTER

zone: dcb.b 512,0
lecteur:
 dc.w $0000,$07E0,$003F,$0C30
 dc.w $007F,$B81C,$00FF,$C004
 dc.w $03FF,$FFF7,$03FF,$FFF5
 dc.w $0FFF,$FFF3,$0FFF,$FFF7
 dc.w $3FFF,$FFFD,$3FFF,$FFFB
 dc.w $FFFF,$FFF5,$8000,$03EB
 dc.w $BFFF,$FBD7,$BFFF,$FBAF
 dc.w $BFFF,$FB5F,$BFFF,$FAB5
 dc.w $BFFF,$FA7B,$BFFF,$FAD5
 dc.w $BFFF,$FAAB,$BFFF,$FBD5
 dc.w $BFFF,$FB29,$BF01,$FBD3
 dc.w $BF01,$FBA6,$BF01,$FB4C
 dc.w $BFFF,$FA98,$BFFF,$FA30
 dc.w $BF01,$FA60,$BFFF,$FAC0
 dc.w $BFFF,$FB80,$BFFF,$FB00
 dc.w $8000,$0200,$FFFF,$FE00
 dc.w $0000,$07E0,$003F,$0C30
 dc.w $007F,$B81C,$00FF,$C004
 dc.w $03FF,$FFF7,$03FF,$FFF5
 dc.w $0FFF,$FFF3,$0803,$FC77
 dc.w $3FFF,$FF7D,$3FFF,$FF7B
 dc.w $FFFF,$FF37,$8000,$036F
 dc.w $BFFF,$FBDF,$BFFF,$FBBF
 dc.w $BFFF,$FB7F,$BFFF,$FAF5
 dc.w $BFFF,$FAFB,$BFFF,$FAD5
 dc.w $BFFF,$FAAB,$BFFF,$FBD7
 dc.w $BFFF,$FB2D,$BF01,$FBDB
 dc.w $BF01,$FBB6,$BF01,$FB6C
 dc.w $BFFF,$FAD8,$BFFF,$FAB0
 dc.w $BF01,$FA60,$BFFF,$FAC0
 dc.w $BFFF,$FB80,$BFFF,$FB00
 dc.w $8000,$0200,$FFFF,$FE00
 dc.w $0000,$07E0,$003F,$0FF0
 dc.w $0061,$BFFC,$00C0,$FFFC
 dc.w $0380,$7FFF,$0200,$001F
 dc.w $0FFD,$FBDF,$0803,$0C5F
 dc.w $3FFE,$074D,$2000,$015B
 dc.w $FFFF,$FF37,$8000,$036F
 dc.w $BFFF,$FBDF,$BFFF,$FBBF
 dc.w $BFFF,$FB7F,$BFFF,$FAF5
 dc.w $BFFF,$FAFB,$BFFF,$FAD5
 dc.w $BFFF,$FAAB,$BFFF,$FBD7
 dc.w $BFFF,$FB2D,$BF01,$FBDB
 dc.w $BF01,$FBB6,$BF01,$FB6C
 dc.w $BFFF,$FAD8,$BFFF,$FAB0
 dc.w $BF01,$FA60,$BFFF,$FAC0
 dc.w $BFFF,$FB80,$BFFF,$FB00
 dc.w $8000,$0200,$FFFF,$FE00
 dc.w $0000,$07E0,$003F,$0C30
 dc.w $0061,$B81C,$00C0,$C004
 dc.w $0380,$7FF7,$0200,$001F
 dc.w $0FFD,$FBFF,$0803,$0C7F
 dc.w $3FFE,$077F,$2000,$017D
 dc.w $FFFF,$FFF9,$FFFF,$FFF1
 dc.w $C000,$07E3,$C000,$07C5
 dc.w $C000,$078B,$C000,$0717
 dc.w $C000,$072F,$C000,$075F
 dc.w $C000,$07BD,$C000,$0779
 dc.w $C1FF,$07F3,$C183,$0767
 dc.w $C183,$07CE,$C1FF,$079C
 dc.w $C1FF,$0738,$C000,$0770
 dc.w $C7FF,$C7E0,$C3FF,$87C0
 dc.w $C000,$0780,$C000,$0700
 dc.w $FFFF,$FE00,$FFFF,$FE00
dossier:
 dc.w $0000,$0000,$0000,$0000
 dc.w $0000,$0000,$0000,$0000
 dc.w $0000,$0000,$0000,$0000
 dc.w $0000,$0000,$0000,$0000
 dc.w $0000,$1F80,$01F8,$1F80
 dc.w $3DFB,$FFF8,$0000,$0000
 dc.w $00A8,$0000,$1555,$5554
 dc.w $2AAA,$AAA8,$1555,$5554
 dc.w $2AAA,$AAA8,$1555,$5554
 dc.w $2AAA,$AAA8,$1555,$5554
 dc.w $2AAA,$AAA8,$1555,$5554
 dc.w $2AAA,$AAA8,$1555,$5554
 dc.w $2AAA,$AAA8,$1555,$5554
 dc.w $2AAA,$AAA8,$1555,$5554
 dc.w $2AAA,$AAA8,$1555,$5554
 dc.w $0000,$0000,$0000,$0000
 dc.w $0000,$0000,$0000,$0000
 dc.w $0000,$0000,$0000,$0000
 dc.w $0000,$0000,$0000,$0000
 dc.w $000F,$C000,$000F,$C000
 dc.w $0000,$0000,$01F8,$0000
 dc.w $3DFB,$FFF8,$0000,$0000
 dc.w $00A8,$0000,$1555,$5554
 dc.w $2AAA,$AAA8,$1555,$5554
 dc.w $2AAA,$AAA8,$1555,$5554
 dc.w $2AAA,$AAA8,$1555,$5554
 dc.w $2AAA,$AAA8,$1555,$5554
 dc.w $2AAA,$AAA8,$1555,$5554
 dc.w $2AAA,$AAA8,$1555,$5554
 dc.w $2AAA,$AAA8,$1555,$5554
 dc.w $2AAA,$AAA8,$1555,$5554
 dc.w $0000,$0000,$0000,$0000
 dc.w $0000,$0000,$0000,$0000
 dc.w $0000,$0000,$0000,$0000
 dc.w $0000,$0000,$000F,$C000
 dc.w $0010,$2000,$1FF0,$3FF0
 dc.w $21F8,$2048,$3E07,$E078
 dc.w $7E07,$FFFC,$7E07,$FFFC
 dc.w $80A8,$0002,$9555,$5556
 dc.w $AAAA,$AAAA,$9555,$5556
 dc.w $AAAA,$AAAA,$9555,$5556
 dc.w $AAAA,$AAAA,$9555,$5556
 dc.w $AAAA,$AAAA,$9555,$5556
 dc.w $AAAA,$AAAA,$9555,$5556
 dc.w $AAAA,$AAAA,$9555,$5556
 dc.w $AAAA,$AAAA,$9555,$5556
 dc.w $AAAA,$AAAA,$9555,$5556
 dc.w $7FFF,$FFFC,$0000,$0000
 dc.w $0000,$0000,$0000,$0000
 dc.w $0000,$0000,$0000,$0000
 dc.w $0000,$0000,$0000,$0000
 dc.w $000F,$C000,$000F,$C000
 dc.w $1E07,$C030,$0000,$0000
 dc.w $0000,$0000,$0000,$0000
 dc.w $0000,$0000,$0000,$0001
 dc.w $0000,$0001,$0000,$0001
 dc.w $0000,$0001,$0000,$0001
 dc.w $0000,$0001,$0000,$0001
 dc.w $0000,$0001,$0000,$0001
 dc.w $0000,$0001,$0000,$0001
 dc.w $0000,$0001,$0000,$0001
 dc.w $0000,$0001,$0000,$0001
 dc.w $0000,$0001,$0000,$0001
 dc.w $0000,$0003,$3FFF,$FFFE
poubelle: 
 dc.w $0000,$0000,$0000,$0000
 dc.w $0007,$C000,$0008,$2000
 dc.w $01FF,$FF00,$0200,$0080
 dc.w $04C1,$FF40,$0400,$0040
 dc.w $07FF,$FFC0,$0200,$0080
 dc.w $0249,$2480,$0200,$0480
 dc.w $0200,$2480,$0240,$2480
 dc.w $0240,$2480,$0248,$2480
 dc.w $024C,$6480,$0249,$2480
 dc.w $0240,$2480,$0249,$2480
 dc.w $0249,$2480,$0269,$2480
 dc.w $0241,$2480,$0249,$2480
 dc.w $0249,$2480,$0249,$2480
 dc.w $0249,$2480,$0249,$2480
 dc.w $0249,$2480,$0224,$D880
 dc.w $0100,$0100,$00FF,$FE00
 dc.w $0000,$0000,$0000,$0000
 dc.w $0007,$C000,$0008,$2000
 dc.w $01FF,$FF00,$0200,$0080
 dc.w $05EF,$FF40,$0400,$0040
 dc.w $07FF,$FFC0,$0200,$0080
 dc.w $0249,$2480,$0249,$2480
 dc.w $0249,$2480,$0240,$2480
 dc.w $0249,$2480,$0249,$2480
 dc.w $024C,$6480,$0249,$2480
 dc.w $0249,$2480,$0249,$2480
 dc.w $0249,$2480,$0269,$2480
 dc.w $0249,$2480,$0249,$2480
 dc.w $0249,$2480,$0249,$2480
 dc.w $0249,$2480,$0249,$2480
 dc.w $0249,$2480,$0224,$D880
 dc.w $0100,$0100,$00FF,$FE00
 dc.w $0000,$0000,$0000,$0000
 dc.w $0007,$C000,$0008,$2000
 dc.w $01FF,$FF00,$0200,$0080
 dc.w $05EF,$FF40,$0600,$00C0
 dc.w $07FF,$FFC0,$0300,$0180
 dc.w $0249,$2480,$0249,$2480
 dc.w $0249,$2480,$0240,$2480
 dc.w $0249,$2480,$024D,$6480
 dc.w $024F,$E480,$0249,$2480
 dc.w $0249,$2480,$0249,$2480
 dc.w $0249,$2480,$0269,$2480
 dc.w $0249,$2480,$0249,$2480
 dc.w $0249,$2480,$0249,$2480
 dc.w $0249,$2480,$0249,$2480
 dc.w $0249,$2480,$0324,$D980
 dc.w $0180,$0300,$00FF,$FE00
 dc.w $0000,$0000,$0000,$0000
 dc.w $0007,$C000,$0008,$2000
 dc.w $01FF,$FF00,$03FF,$FF80
 dc.w $0600,$00C0,$07FF,$FFC0
 dc.w $07FF,$FFC0,$03FF,$FF80
 dc.w $0324,$9180,$03B6,$DB80
 dc.w $03B6,$DB80,$03B6,$DB80
 dc.w $03B6,$DB80,$03BE,$FB80
 dc.w $03B7,$DB80,$03B6,$DB80
 dc.w $03B6,$DB80,$03B6,$DB80
 dc.w $03B6,$DB80,$0396,$DB80
 dc.w $03B6,$DB80,$03B6,$DB80
 dc.w $03B6,$DB80,$03B6,$DB80
 dc.w $03B6,$DB80,$03B6,$DB80
 dc.w $0324,$8980,$0392,$0380
 dc.w $01FF,$FF00,$00FF,$FE00
programme:
 dc.w $FFFF,$FFFE,$BFFF,$FE3E
 dc.w $FFFF,$FFFE,$BFFF,$FFE3
 dc.w $FFFF,$FFFF,$8000,$07BF
 dc.w $8000,$07FF,$BFDF,$03E3
 dc.w $8000,$01FF,$BBFA,$00E3
 dc.w $8000,$003F,$BFEF,$003F
 dc.w $8000,$003F,$B5FF,$003F
 dc.w $8000,$003F,$BF55,$003F
 dc.w $8000,$003F,$B77F,$003B
 dc.w $8000,$003B,$8000,$0023
 dc.w $8000,$003F,$8000,$003F
 dc.w $8000,$003F,$8000,$0023
 dc.w $8000,$003F,$8000,$003F
 dc.w $FFFF,$FFFF,$8BFF,$FAE7
 dc.w $8BFF,$FAEF,$8BFF,$E2FF
 dc.w $FFFF,$FFFF,$3FFF,$FFFF
 dc.w $FFFF,$FFFE,$B800,$023E
 dc.w $F9FF,$F3FE,$B800,$03E3
 dc.w $FFFF,$FFFF,$8000,$003F
 dc.w $8000,$003F,$BFDF,$0023
 dc.w $8000,$003F,$BBFA,$0023
 dc.w $8000,$003F,$BFEF,$003F
 dc.w $8000,$003F,$B5FF,$003F
 dc.w $8000,$003F,$BF55,$003F
 dc.w $8000,$003F,$B77F,$003B
 dc.w $8000,$003B,$8000,$0023
 dc.w $8000,$003F,$8000,$003F
 dc.w $8000,$003F,$8000,$0023
 dc.w $8000,$003F,$8000,$003F
 dc.w $FFFF,$FFFF,$8BFF,$FAE7
 dc.w $8BFF,$FAEF,$8BFF,$E2FF
 dc.w $FFFF,$FFFF,$3FFF,$FFFF
 dc.w $FFFF,$FFFE,$B800,$023E
 dc.w $F9FF,$F3FE,$B800,$03E3
 dc.w $FFFF,$FFFF,$8000,$3C3F
 dc.w $BFDF,$3C3F,$BFDF,$1E23
 dc.w $BBFA,$1F3F,$BBFA,$0FE3
 dc.w $BFEF,$07FF,$BFEF,$03FF
 dc.w $B5FF,$00FF,$B5FF,$003F
 dc.w $BF55,$003F,$BF55,$003F
 dc.w $B77F,$003F,$B77F,$003B
 dc.w $8000,$003B,$8000,$0023
 dc.w $8000,$003F,$8000,$003F
 dc.w $8000,$003F,$8000,$0023
 dc.w $8000,$003F,$8000,$003F
 dc.w $FFFF,$FFFF,$8BFF,$FAE7
 dc.w $8BFF,$FAEF,$8BFF,$E2FF
 dc.w $FFFF,$FFFF,$3FFF,$FFFF
 dc.w $FFFF,$FFFE,$8800,$022A
 dc.w $F9FF,$F3FE,$8800,$02A2
 dc.w $FFFF,$FFFE,$8000,$1F2A
 dc.w $8000,$1FBE,$8000,$0FE2
 dc.w $8000,$0FFE,$8000,$07FE
 dc.w $8000,$03E2,$8000,$00E2
 dc.w $8000,$0022,$8000,$0022
 dc.w $8000,$0022,$8000,$0022
 dc.w $8000,$003E,$8000,$0026
 dc.w $8000,$0026,$8000,$003E
 dc.w $8000,$003E,$8000,$0022
 dc.w $8000,$003E,$8000,$0022
 dc.w $8000,$003E,$8000,$002A
 dc.w $FFFF,$FFFE,$AC00,$26A2
 dc.w $CC00,$26E2,$AC00,$3EA2
 dc.w $FFFF,$FFFE,$0000,$0000
fichier:
 dc.w $FFFF,$FFF0,$FFFF,$FFF0
 dc.w $C000,$001C,$C000,$0014
 dc.w $DDDF,$CF97,$C000,$0015
 dc.w $C000,$0015,$DF3B,$B795
 dc.w $C000,$0015,$C000,$0015
 dc.w $DBFB,$3F95,$C000,$0015
 dc.w $C000,$0015,$DF7D,$DF95
 dc.w $C000,$0015,$C000,$0015
 dc.w $DBFB,$F395,$C000,$0015
 dc.w $C000,$0015,$DE00,$0015
 dc.w $C000,$0015,$C000,$07F5
 dc.w $C000,$07AD,$C000,$075D
 dc.w $C000,$06B5,$C000,$0565
 dc.w $C000,$0705,$FFFF,$FDE5
 dc.w $2000,$0305,$3FFF,$FFFD
 dc.w $0800,$0001,$0FFF,$FFFF
 dc.w $FFFF,$FFF0,$FFFF,$FFF0
 dc.w $C000,$001C,$C000,$0014
 dc.w $DDDF,$CF97,$C000,$0015
 dc.w $C000,$0015,$DF3B,$B795
 dc.w $C000,$0015,$C000,$0015
 dc.w $DBFB,$3F95,$C000,$0015
 dc.w $C000,$0015,$DF7D,$DF95
 dc.w $C000,$0015,$C000,$0015
 dc.w $DBFB,$F395,$C000,$0015
 dc.w $C000,$0015,$DE00,$0015
 dc.w $C000,$0015,$C000,$07F5
 dc.w $C000,$07AD,$C000,$075D
 dc.w $C000,$06B5,$C000,$0565
 dc.w $C000,$0705,$FFFF,$FDE5
 dc.w $2000,$0305,$3FFF,$FFFD
 dc.w $0800,$0001,$0FFF,$FFFF
 dc.w $FFFF,$FFF0,$FFFF,$FFF0
 dc.w $C000,$001C,$DDDF,$CF94
 dc.w $DDDF,$CF97,$C000,$0017
 dc.w $DF3B,$B797,$DF3B,$B797
 dc.w $C000,$0017,$DBFB,$3F97
 dc.w $DBFB,$3F97,$C000,$0017
 dc.w $DF7D,$DF97,$DF7D,$DF97
 dc.w $C000,$0017,$DBFB,$F397
 dc.w $DBFB,$F397,$C000,$0017
 dc.w $DE00,$0017,$DE00,$0017
 dc.w $C000,$0017,$C000,$07F7
 dc.w $C000,$07AF,$C000,$077F
 dc.w $C000,$06B7,$C000,$0567
 dc.w $C000,$07E7,$FFFF,$FDE7
 dc.w $2000,$0307,$3FFF,$FFFF
 dc.w $0FFF,$FFFF,$0FFF,$FFFF
 dc.w $FFFF,$FFF0,$8000,$0010
 dc.w $8000,$001C,$8000,$001C
 dc.w $8000,$001F,$8000,$001F
 dc.w $8000,$001F,$8000,$001F
 dc.w $8000,$001F,$8000,$001F
 dc.w $8000,$001F,$8000,$001F
 dc.w $8000,$001F,$8000,$001F
 dc.w $8000,$001F,$8000,$001F
 dc.w $8000,$001F,$8000,$001F
 dc.w $8000,$001F,$8000,$001F
 dc.w $8000,$001F,$8000,$07FF
 dc.w $8000,$0477,$8000,$04E7
 dc.w $8000,$05C7,$8000,$0787
 dc.w $8000,$07C7,$FFFF,$FE07
 dc.w $3FFF,$FC07,$3FFF,$FFFF
 dc.w $0FFF,$FFFF,$0FFF,$FFFF 		

init:
	dc.w $a000				; LINE A INIT
	move.l a0,plans		; pour v‚rifier qu'on est en 16 couleurs
	
	pea installe			; v‚rifie le TOS, adpate les pointeurs,
								; d‚tourne l'AES/VDI
	move #38,-(sp)
	trap #14					; SUPEXEC
	addq.l #6,sp
	
	tst.l sauve				; adresse VDI d‚tourn‚e??
	bne.s ok					; oui, TOS reconnu
	
	pea bug					; affiche le message d'erreur
	move #9,-(sp)
	trap #1
	addq.l #6,a7
	
	clr -(sp)				; et quitte
	trap #1
	
ok:
	lea zone,a0				; recode les 4 plans de couleur
.icones:						; des icones
	lea 512(a0),a1
	moveq #63,d0			; 64x4 mots= 512 octets
.lb0:
	move (a1),(a0)+		; m‚lange les 4 plans
	move 128(a1),(a0)+	; qui ‚taient ‚loingn‚s
	move 256(a1),(a0)+
	move 384(a1),(a0)+
	addq.l #2,a1
	dbf d0,.lb0
	cmp.l #init-512,a0	; fin des icones?
	bmi.s .icones			; pas encore

	lea init-512,a0		; fin de la zone … garder (-512 car icones
								; d‚cal‚es)
	sub.l #debut,a0		; debut de la zone … garder
	add.l #$100,a0			; plus la BASEPAGE
	
	clr -(sp)
	move.l a0,-(sp)		; taille … conserver
	move #49,-(sp)			; PTERMRES (r‚sident!)
	trap #1
	
installe:
	move.l $4f2,a0			; d‚but de la rom
	move 2(a0),d0			; version du TOS
	lea tableau,a0			; tableau contenant les diff‚rentes adresses
.lb0:
	move (a0)+,d1			; version connue
	beq.s .fin				; si 0, plus d'autres versions ne conviennent
	cmp.w d1,d0
	beq.s .ok				; version trouv‚e
	lea 20(a0),a0			; avance au prochain bloc
	bra.s .lb0
.ok:
	move.l (a0)+,relog_0+4
	move.l (a0)+,relog_1+2
	move.l (a0)+,d0
	move.l d0,relog_2+2
	move.l d0,relog_4+2
	move.l d0,relog_6+2
	move.l d0,relog_9+2
	move.l (a0)+,relog_3+2
	move.l (a0),d0
	move.l d0,relog_7+2
	addq.l #4,d0
	move.l d0,relog_5+2
	move.l d0,relog_8+2
	move.l $88,sauve		; ancien VDI/AES
	move.l #inter,$88		; le mien … la place
	rts
.fin:
	clr.l sauve
	rts
	
	; version TOS (en .w)
	; adresse MOT COLOR de l'objet titre d'une fenˆtre
	; adresse premier MOT COLOR de l'arbre repr‚sentant une fenˆtre
	; adresse MFDB source de l'AES
	; adresse BITBLK des alertes
	; adresse ICONBLK des disques
	
tableau:
	dc.w $106
	dc.l $6dbe,$72b4,$a814,$6d88,$6d66
	dc.w $162
	dc.l $6dbe,$72b4,$a814,$6d88,$6d66
	dc.w 0
	
bug: dc.b 7,27,"ECette version du TOS",13,10
		dc.b "n'est pas reconnue par ce",13,10
		dc.b "programme!",13,10,10
		dc.b "COLOR STe non install‚...",13,10,0
		
	end