; COLOR_TT.PRG
; programme r‚sident (dossier AUTO )
; permet d'obtenir:
; 	- des icones couleurs sur le bureau
;  - des icones color‚es dans les boites d'alerte
;  - des boutons 3D dans les fenˆtres (en 256/32768 couleurs NOVA et TOS 3.6)
; Tourne sur TT (TOS 3.6) uniquement (avec ou sans carte NOVA 32000 couleurs).
; Auteur: Tello Guillaume (Ao–t/Novembre 1995)
;			 240 rue Estienvrin
;			 49260 Montreuil Bellay
;		tel: 41 38 71 48
;		email: gtello@planete.net
; assembl‚ avec ASSEMBLE de Brainstorm.

; changements par rapport … la version pr‚c‚dente:
;
; les changements de r‚solution sont support‚s (seule la r‚solution de boot
; du bureau l'‚tait avant), l'adaptation des icones se fait 'en temps r‚el':
; - quelque soit la r‚solution, la place m‚moire est la mˆme
; - si la mˆme icone est redessin‚e deux fois de suite, elle n'est pas
;   recalcul‚e, on dispose d'un buffer d'une icone.

GRIS = $EF3D	; pour l'effet 3D, ombre foncee

	opt w+

TT306 equ 1		; 1 3.06, 0 tos 3.05

	if TT306=1
		output "COLTT306.PRG"
	else
		output "COLTT305.PRG"
	endif


XBIOS MACRO   ; fn,pile
   move #\1,-(sp)
   trap #14
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

GEMDOS MACRO    ; fn,pile
   move #\1,-(sp)
   trap #1
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

	text
	
debut:
	jmp init									; saute la partie r‚sidente

	if TT306=1
	
bouton3d:
	movem.l (sp)+,d1/a0-a2
	btst #5,(sp)
	beq.s .fin			; pas en superviseur!
	move.l a0,-(sp)
	move.l linea,a0
	cmp #16,(a0)
	beq .cool			; True color
	tst.b nova
	beq .rien			; pas sur carte, donc seulement TC accepte
	cmp #8,(a0)
	bne .rien			; pas en 256 couleurs non plus!!!
.cool:
	move.l d1,a0
	move.l (a0),a0
	move (a0),d0		; op code
	cmp #$72,d0			; fill rect?
	bne.s .autre
	bsr sauve_rect
	bra.s .rien	
.autre:
	cmp #$8,d0
	bne.s .rien
	bsr aff_lignes
.rien:
	move.l (sp)+,a0
.fin:
	moveq #$73,d0
	move.l sauve,-(sp)
	rts

sauve_rect:
	sf rect_flag
	cmp.l #$e254cc,16(sp)
	bne .bye
	move $95d6,d0		; fenetre active
	bmi .bye			; aucune!
	beq .bye			; le fond!
	movem.l d1/d2/d3/a1,-(sp)
	move.b d0,rect_flag+1	; garde le handle
	muls #132,d0
	lea $e120,a1		
	add d0,a1			; bloc fenetre active
	move.l a1,active_adr
;	add #16,a1			; taille totale fenetre lors de la creation
;	move.l (a1)+,d0	; x0,y0
;	move.l (a1),d2		; l,h
;	add.l d0,d2			; x1,y1	
	move.l d1,a0
	move.l 8(a0),a0	; ptsin
	move.l (a0)+,d1
	move.l d1,rect_size
	move.l (a0),d3
	move.l d3,rect_size+4
;	cmp d0,d1
;	bmi.s .bof
;	cmp d2,d3
;	bpl.s .bof
;	swap d0
;	swap d1
;	swap d2
;	swap d3
;	cmp d0,d1
;	bmi.s .bof
;	cmp d2,d3
;	bpl.s .bof
;	swap d1
;	swap d3
	st rect_flag
.bof:
	movem.l (sp)+,d1/d2/d3/a1
.bye:
	rts
	
aff_lignes:
	lea rect_flag,a0
	tst.b (a0)
	bne.s .ok
.ciao:
	rts
.ok:
	sf (a0)
	move (a0),d0
	cmp $95d6,d0
	bne.s .ciao				; plus la meme fenetre
	cmp.l #$e24a12,16(sp)
	bne.s .ciao
	movem.l d1/d2/d3/a1,-(sp)
	move.l d1,a0
	move.l 4(a0),a1		; intin
	move.l (a0),a0
	move 6(a0),d0			; taille chaine
	beq .bof					; rien a afficher...
	cmp #1,d0
	bne.s .autres
	move (a1),d1			; seul caractere
	cmp #1,d1
	bmi.s .autres
	cmp #8,d1
	bmi.s .bon				; 1 a 7 c'est bon pour la fenetre
.autres:
	move.l active_adr,a0
	move.l 8(a0),a0		; chaine titre
	bsr compare_chaines
	beq.s .bon
	move.l active_adr,a0
	move.l 12(a0),a0
	bsr compare_chaines
	bne .bof	
.bon:	
	move.l linea,a0
	move -2(a0),d1			; largeur ecran
	lea rect_size,a0
	move 2(a0),d0			; y0
	move 6(a0),d2			; y1
	sub d0,d2				; nbr lignes -1
	bmi .bof
	muls d1,d0
	move.l $44e.w,a1		; ecran
	add.l d0,a1
	move 4(a0),d3			; x1
	move (a0),d0			; x0
	sub d0,d3				; nbr col -1
	bmi .bof
	add d0,a1				; premier pixel!
	cmp #8,([linea])
	bne.s .c32k
	move.l a1,a0			; premiere ligne
	move d3,d0
.bligne0:
	sf (a0)+
	dbf d0,.bligne0
.bbords:
	add d1,a1				; ligne suivante
	subq #1,d2
	cmp #1,d2
	bmi.s .blignefin
	sf (a1)
	move.b #8,0(a1,d3)
	bra.s .bbords
.blignefin:
	sf (a1)+
	move d3,d0
	bra.s .blb0
.blignen:
	move.b #8,(a1)+
.blb0:
	dbf d0,.blignen	
	bra .bof	
.c32k:
	add d0,a1
	move.l a1,a0			; premiere ligne
	move d3,d0
.ligne0:
	move #$ffff,(a0)+
	dbf d0,.ligne0
.bords:
	add d1,a1				; ligne suivante
	subq #1,d2
	cmp #1,d2
	bmi.s .lignefin
	move #$ffff,(a1)
	move #GRIS,0(a1,d3*2)
	bra.s .bords
.lignefin:
	move #$ffff,(a1)+
	move d3,d0
	bra.s .lb0
.lignen:
	move #GRIS,(a1)+
.lb0:
	dbf d0,.lignen
.bof:
	movem.l (sp)+,d1/d2/d3/a1
	rts

; a0: chaine BYTES
; a1: chaine WORDS
; d0: taille

compare_chaines:
	move.l a1,d2	; sauve
	move d0,d3
	subq #1,d3		; pour la boucle
.loop:
	move (a1)+,d1	; caratere
	cmp.b (a0)+,d1
	dbne d3,.loop
	bne.s .diff
	move.l d2,a1
	moveq #0,d1		; EQ
	rts
.diff:
	move.l d2,a1
	moveq #-1,d1	; NE
	rts

	endif
	
; cette routine se place en tˆte des instructions AES/VDI
	
inter:
	movem.l d1/a0-a2,-(sp)				; je m'en sers
	cmp #$73,d0								; appel VDI?
	bne .fin									; non, rien … faire
	cmp #4,([linea])			; nombre de plans
	bmi .fin						; 1 ou 2 plans, pas de couleur … mettre

	move.l d1,a0			; vdi_param_blk
	move.l (a0),a0			; control
	cmp #121,(a0)			; vrt_cpyfm?
	
	if TT306=1
		bne bouton3d
	else
		bne .fin					; non, rien … faire
	endif
	
	if TT306=1
	
	cmp.l #$E5CC,14(a0)	; MFBD source de l'AES?
	bne .fin					; non, pas une icone alors!
	move.l $8E16,a0		; le BITBLK (pointeur donn‚es) des alertes
	cmp.l $E5CC,a0			; meme adresse?
	bne.s .non				; non, pas une icone d'alerte
	exg.l d1,a0				; si oui, on va v‚rifier l'adresse
	sub.l $949a,d1
	
	else
	
	cmp.l #$E132,14(a0)	; MFBD source de l'AES?
	bne .fin					; non, pas une icone alors!
	move.l $8B2A,a0		; le BITBLK (pointeur donn‚es) des alertes
	cmp.l $E132,a0			; meme adresse?
	bne.s .non				; non, pas une icone d'alerte
	exg.l d1,a0				; si oui, on va v‚rifier l'adresse
	sub.l $911C,d1
	
	endif
	
	sub.l #2156,d1			; offset de l'icone
	bmi .fin					; en dessous!
	cmp.l #384,d1			; 3*128 pour 3 icones
	bpl .fin					; au dessus
	move.l 4(a0),a0		; intin
	move #4,2(a0)			; couleur icone (du bleu au lieu du noir)
	bra .fin
.non:

	if TT306=1
	
	move.l $8DF4+4,a0		; ICONBLK des disques (pointeur datas)
	move.l $E5CC,a1		; adresse donn‚es
	cmp.l a1,a0				; meme adresse ?
	bne.s .pas_data		; non, on dessine autre chose
	move.l $9400,a2		; adresse ressource

	else
		
	move.l $8B08+4,a0		; ICONBLK des disques (pointeur datas)
	move.l $E132,a1		; adresse donn‚es
	cmp.l a1,a0				; meme adresse ?
	bne.s .pas_data		; non, on dessine autre chose
	move.l $9082,a2		; adresse ressource
	
	endif
	
	add.w 14(a2),a2		; plus offset donn‚es
	add.w #128,a2			; passe le masque
	sub.l a2,a1				; offset de l'icone
	cmp.l #0,a1				; en dessous de la zone?
	bmi .fin					; oui!, pas du bureau!
	add.l a1,a1				; paquets de 256 en 512 (pour 4 plans)
	add.l data_ptr,a1		; plus icone de d‚part
	cmp.l data_end,a1		; au dela de la zone?
	bpl .fin					; oui, pas du bureau!
	bsr adapt_icone		; selon les plans et NOVA ou ATARI
	move.l d1,a0
	move.l 4(a0),a0		; intin
	move #7,(a0)			; mode or
	cmp #16,plans
	bne.s .k1
	addq #2,(a0)			; mode 9 plus joli!
.k1:
	move.l #une_icone,mfdb			; adresse donn‚es
	move.l d1,a0
	move.l (a0),a1			; control
	move #109,(a1)			; vro_cpyfm (au lieu de vrt_cpyfm)
	move #1,6(a1)			; 1 seul intin
	move.l #mfdb,14(a1)	; nouvel mfdb
	bra.s .fin
.pas_data:

	if TT306=1
	
	move.l $8DF4,a0		; ICONBLK des disques (masques)
	cmp.l a1,a0				; bonne adresse?
	bne.s .fin				; non, on dessine autre chose
	exg.l d1,a0
	move.l $9400,a2		; adresse ressource
	
	else
	
	move.l $8b08,a0		; ICONBLK des disques (masques)
	cmp.l a1,a0				; bonne adresse?
	bne.s .fin				; non, on dessine autre chose
	exg.l d1,a0
	move.l $9082,a2		; adresse ressource
	
	endif
	
	add.w 14(a2),a2		; plus offset donn‚es
	sub.l a2,d1				; offset de l'icone
	bmi.s .fin				; en dessous de la zone
	asr.l #1,d1				; 256 en paquets de 128
	add.l #zone,d1			; plus masque de d‚part
	cmp.l data_ptr,d1
	bpl.s .fin				; au dela de la zone
	
	if TT306=1
	move.l d1,$E5CC		; masque choisi comme donn‚es du MFDB
	else
	move.l d1,$E132
	endif
	
	move.l 4(a0),a0		; intin 
	move.l #1,2(a0)		; toujours mode normal pour ‚viter inversion
.fin:
	movem.l (sp)+,d1/a0-a2	; restaure les registres utilis‚s
	move.l sauve,-(sp)		; ancienne adresse VDI/AES
	rts							; … laquelle on saute
.annul:		
	movem.l (sp)+,d1/a0-a2	; restaure
	rte							; et quitte VDI/AES
	
mfdb: dc.l 0					; mon mfdb couleur
	dc.w 32,32,2,0
plans: dc.w 4,0,0,0	; 32x32 en 4 plans
sauve: dc.l 0					; adresse ancien VDI/AES


adapt_icone:
	move.l d0,-(sp)
	move.l linea,a0
	move (a0),d0			; les plans
	move d0,plans			; pour le mfdb
	cmp p_actu,d0			; mˆme plans
	bne.s .adapt			; non, donn‚es non valides
	cmp.l adr_actu,a1		; mˆme adresse?
	bne.s .adapt			; non, donn‚es non valides
	move.l (sp)+,d0
	rts						; sinon, tout est bon!
.adapt:
	move.l a1,adr_actu
	move d0,p_actu			; la nouvelle icone
	lea une_icone,a0		; l… ou vont les donn‚es
	cmp #4,d0
	beq.s prendre4
	cmp #8,d0
	beq.s prendre8
	cmp #16,d0
	beq prendre16
	
prendre4:
	tst.b nova
	bne.s .nova
	moveq #63,d0			; 64 * 4 mots = 512 octets
.lb1:
	move (a1),(a0)+
	move 128(a1),(a0)+
	move 256(a1),(a0)+
	move 384(a1),(a0)+	; TT sans carte, mˆler les 4 plans!
	addq.l #2,a1
	dbf d0,.lb1
	move.l (sp)+,d0
	rts
.nova:						; TT avec carte, meme codage!
	moveq #127,d0			; 128 mots longs = 512 octets
.lb0:
	move.l (a1)+,(a0)+	; copie les donn‚es
	dbf d0,.lb0
	move.l (sp)+,d0
	rts
	
prendre8:
	tst.b nova
	bne.s .nova
	moveq #63,d0			; 64 * 4 mots = 512 octets
.lb7:
	move (a1),(a0)+
	move 128(a1),(a0)+
	move 256(a1),(a0)+
	move 384(a1),(a0)+	; TT sans carte, mˆler les 4 plans!
	clr.l (a0)+
	clr.l (a0)+				; plus 4 plans vides! (les plus signifiants)
	addq.l #2,a1
	dbf d0,.lb7
	move.l (sp)+,d0
	rts
.nova:
	movem.l d1-d5,-(sp)
	moveq #31,d4			; pour les 32 lignes
.lb0:
	swap d4					; TT avec carte, plus de plans, 1 point=1 octet!
	move.l (a1),d0
	move.l 128(a1),d1
	move.l 256(a1),d2
	move.l 384(a1),d3
	moveq #31,d5			; pour les 32 points par ligne
.lb1:
	clr d4
	roxl.l d3
	roxl.b d4
	roxl.l d2
	roxl.b d4
	roxl.l d1
	roxl.b d4
	roxl.l d0
	roxl.b d4
	cmp.b #15,d4
	bne.s .lb6
	st d4						; le 1 devient 255
.lb6:
	move.b d4,(a0)+
	dbf d5,.lb1				; autre point sur la mˆme ligne
	swap d4
	addq.l #4,a1			; ligne suivante
	dbf d4,.lb0
	movem.l (sp)+,d1-d5
	move.l (sp)+,d0
	rts
	
	
prendre16:
	movem.l d1-d5,-(sp)
	lea .table,a2			; conversions en 16 bits
	moveq #31,d4			; pour les 32 lignes de l'icone
.lb0:
	swap d4					; l'autre mot de d4 est utilis‚ ici
	move.l (a1),d0			; d0-d3 contienent les 4 bits de 32 points
	move.l 128(a1),d1
	move.l 256(a1),d2
	move.l 384(a1),d3
	moveq #31,d5			; pour les 32 points par ligne
.lb1:
	clr d4
	roxl.l d3
	roxl.b d4
	roxl.l d2
	roxl.b d4
	roxl.l d1
	roxl.b d4
	roxl.l d0
	roxl.b d4
	move 0(a2,d4.w*2),(a0)+
	dbf d5,.lb1				; autre point sur la mˆme ligne
	swap d4
	addq.l #4,a1			; ligne suivante
	dbf d4,.lb0
	movem.l (sp)+,d1-d5
	move.l (sp)+,d0
	rts
.table: dc.w $ff7f,$007c,$e003,$e07f,$1f00,$1f7c,$ff03,$f75e
		  dc.w $1042,$107e,$f043,$f07f,$1f42,$1f7e,$ff43,$0000
; L'AES dessine toutes ses icones … travers la fonction VDI vrt_cpyfm(121).
; Pour ˆtre certain que c'est l'AES qui appelle (et non un programme
; utilisateur), il suffit de v‚rifier que le MFDB source se situe en $E5CC.
; maintenant il faut distinguer l'icone alerte, l'icone bureau et le masque
; d'icone bureau.
; icone ALERTE:
; 		l'AES a auparavant pr‚par‚ une structure BITBLK en $8E16 dont l'adresse
;		des donn‚es doit correspondre … celle du mfdb. On v‚rifie en plus que
;     les donn‚es sont bien celles des alertes (en $949A se trouve un pointeur
;     sur une zone contenant les icones d'alertes … l'offset 2156: 3 paquets
;     de 128 octets.) On peut imaginer ajouter des icones alertes car form_alert
;     ne plante pas avec un index sup‚rieur … trois, cette fonction se contente
;     d'afficher ce qui suit en m‚moire, c'est … dire une icone souris!.
;     Si tout concorde, on change alors la couleur (1 NOIR devient 4 BLEU).
; icone BUREAU:
;		l'AES a auparavant pr‚par‚ une structure ICONBLK en $8DF4 dont l'adresse
;		des donn‚es (en $8DF4+4) doit correspondre au mfdb. On v‚rifie en plus
;     que ce sont bien des donn‚es d'icones du bureau (en $9400 se trouve un pointeur sur
;     le DESKICON.RSC en m‚moire. Ceci nous donne ‚galement l'index de l'icone
;     dans ressource pour l'aiguillage correct vers nos donn‚es). Si tout concorde,
;     on change alors vrt_cpyfm en vro_cpyfm (copie couleur), mode NOT (S XOR D).
; masque BUREAU:
;		mˆme systŠme que pour les donn‚es (pour la d‚tection on se sert de
;		l'adresse du masque en $8DF4), pour l'aiguillage c'est la mˆme proc‚dure
;		et on v‚rifie que le masque n'est pas utilis‚ pour l'inversion (lors
;		de la s‚lection). Pour le dessin normal intin vaut 2(mode) 0(coul) 1(fond)
;		et pour l'inversion intin vaut 2 1(coul) 0(fond), dans ce cas on
;		n'ex‚cute pas la copie (c'est moche). Seul le nom sous l'icone devrait
;		ˆtre invers‚.


mt: dc.b 0			; pas de multitos (… priori), FF si pr‚sent
nova: dc.b 0		; ni de carte NOVA, FF si pr‚sente

	even

init:
   move.l  4(a7),a5
   move.l  $18(a5),d0
   add.l $1c(a5),d0
   add.l #$100,d0
   lea pile,sp
   sub.l a5,d0
   move.l  d0,-(sp)
   move.l  a5,-(sp)
   clr -(sp)
   GEMDOS $4a,12			; r‚duit l'espace … strict n‚cessaire

	pea cookie				; cherche MiNT (multitos) et NOVA (carte Nova)
	XBIOS 38,6
	
	pea titre				; affiche COLOR TT et mon nom
	GEMDOS 9,6
	
	tst.b mt
	bne quitter			; multitos!
	
	dc.w $A000				; line-A
	move.l d0,linea		; adresse du nombre de plans
	
	pea installe			; va d‚tourner l'AES/VDI
	XBIOS 38,6
		
	clr -(sp)
	pea nom
	GEMDOS 61,8				; ouvre C:\DESKCICN.RSC
	move d0,d7
	
	pea fichier				; zone m‚moire ou placer le fichier
	move.l #200*1024,-(sp)	; 200 Ko semblent suffisants
	move d7,-(sp)
	GEMDOS 63,12			; lire
	
	move d7,-(sp)			; fermer
	GEMDOS 62,4
	
	lea zone,a0				; les masques
	lea fichier,a2			; le RSC
	move 20(a2),d7			; nombre d'objets
	subq #1,d7				; nombre d'icones (moins le BOX)
	move d7,ni
	move d7,d6
	muls #128,d6			; fois le nombre de masques
	lea 0(a0,d6.l),a1		; pointe sur les donn‚es
	move.l a1,data_ptr
	add.w 34(a2),a2		; vers l'extension
	lea ([4,a2],d7.w*4,fichier+4),a2	; d‚but des structures
	subq #1,d7				; pour la boucle
	
icone:
	lea 306(a2),a2			; saute l'icone monochrome
.lb2:
	move (a2),d6
	cmp #4,d6				; 4 plans pour l'icone?
	bne.s .lb0				; non...
	bsr copie_icone
.lb0:	
	addq #1,d6				; plus le plan masque
	muls #128,d6			; chaque plan fait 128 octets
	cmp.l #1,10(a2)		; flag pour selected?
	bne.s .lb1				; pas 1, une icone
	add.l d6,d6				; double la mise, avec l'icone selected
.lb1:
	move 18(a2),d0			; flag pour autre r‚solution
	lea 22(a2,d6.l),a2	; saute l'icone
	tst d0
	bne.s .lb2				; flag=1 autre r‚solution
	dbf d7,icone			; autre icone!

resident:	
	move.l a1,data_end
	sub.l #debut,a1		; a1 pointait vers la fin des donn‚es
	add.w #$100,a1			; plus basepage
	
	clr -(sp)
	move.l a1,-(sp)		; taille … conserver
	move #49,-(sp)			; PTERMRES (r‚sident!)
	trap #1

quitter:
	clr -(sp)
	trap #1
		
installe:
	move.l $88,sauve		; ancien VDI/AES
	move.l #inter,$88		; le mien … la place
	rts
	
copie_icone:
	lea 22(a2),a3			; donn‚es de l'icone
	moveq #127,d0			; 128 mots longs = 512 octets
.lb0:
	move.l (a3)+,(a1)+	; copie les donn‚es
	dbf d0,.lb0
	moveq #31,d0			; pour le masque
.lb1:
	move.l (a3)+,(a0)+	; copie le masque
	dbf d0,.lb1
	rts	
	
cookie:
	move.l $5A0,a0
	cmp.l #0,a0
	beq.s .fin				; pas de cookie...
.lb0:
	tst.l (a0)
	beq.s .fin
	cmp.l #'MiNT',(a0)	; Multitos?
	bne.s .lb1
	st mt						; si oui, mt=FF
.lb1:
	cmp.l #'MagX',(a0)
	bne.s .lb3
	st mt						; magic = multiTOS
.lb3:
	cmp.l #'NOVA',(a0)	; cartes NOVA (anciennes IMAGINE)?
	bne.s .lb2
	st nova					; si oui, nova=FF
.lb2:
	addq.l #4,a0			; cookie suivant
	bra.s .lb0
.fin: rts

nom: dc.b "C:\DESKCICN.RSC",0
titre: dc.b 13,10,10,27,"c8",27,"b3 COLOR TT (c) 1995 "
			 dc.b 13,10,27,"b2  Tello Guillaume  "
			 dc.b 13,10,27,"c0",27,"b1",0

	even
	bss

rect_flag: ds.w 1
active_adr: ds.l 1
rect_size: ds.w 4
linea: ds.l 1			; adresse des variables linea
adr_actu: ds.w 1			; adresse de l'icone actuelle
p_actu: ds.w 1			; nombre de plans actuels
une_icone: ds.b 32*32*2	; taille en 16 bits
ni: ds.w 1					; nombre d'icones
data_ptr: ds.l 1			; adresse pour les donn‚es
data_end: ds.l 1			; fin des donn‚es
zone: ds.b 200*1024		; avec 200k ‡a suffit
fichier:  ds.b 200*1024	; l… aussi
pile: ds.w 1
	end

