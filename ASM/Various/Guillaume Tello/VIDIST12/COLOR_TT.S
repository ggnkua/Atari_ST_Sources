; COLOR_TT.PRG
; programme r‚sident (dossier AUTO )
; permet d'obtenir:
; 	- des icones couleurs sur le bureau
;  - des icones color‚es dans les boites d'alerte
; Tourne sur TT (TOS 3.6) uniquement (avec ou sans carte NOVA 32000 couleurs).
; Auteur: Tello Guillaume (Ao–t/Novembre 1995)
;			 240 rue Estienvrin
;			 49260 Montreuil Bellay
;		tel: 41 38 71 48
;		email: gtello@planete.net
; assembl‚ avec ASSEMBLE de Brainstorm.

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

GEM_VDI MACRO
	move.l #\1,d1
	moveq #$73,d0
	trap #2
	ENDM

	OUTPUT "C:\AUTO\COLOR_TT.PRG"		; le programme ex‚cutable

	text
	
debut:
	jmp init									; saute la partie r‚sidente

; cette routine se place en tˆte des instructions AES/VDI
	
inter:
	movem.l d1/a0-a2,-(sp)				; je m'en sers
	cmp #$73,d0								; appel VDI?
	bne .fin									; non, rien … faire

	move.l d1,a0			; vdi_param_blk
	move.l (a0),a0			; control
	cmp #121,(a0)			; vrt_cpyfm?
	bne .fin					; non, rien … faire
	cmp.l #$E5CC,14(a0)	; MFBD source de l'AES?
	bne .fin					; non, pas une icone alors!
	move.l $8E16,a0		; le BITBLK (pointeur donn‚es) des alertes
	cmp.l $E5CC,a0			; meme adresse?
	bne.s .non				; non, pas une icone d'alerte
	exg.l d1,a0				; si oui, on va v‚rifier l'adresse
	sub.l $949a,d1
	sub.l #2156,d1			; offset de l'icone
	bmi .fin					; en dessous!
	cmp.l #384,d1			; 3*128 pour 3 icones
	bpl .fin					; au dessus
	move.l 4(a0),a0		; intin
	move #4,2(a0)			; couleur icone (du bleu au lieu du noir)
	bra .fin
.non:
	move.l $8DF4+4,a0		; ICONBLK des disques (pointeur datas)
	move.l $E5CC,a1		; adresse donn‚es
	cmp.l a1,a0				; meme adresse ?
	bne.s .pas_data		; non, on dessine autre chose
	move.l $9400,a2		; adresse ressource
	add.w 14(a2),a2		; plus offset donn‚es
	add.w #128,a2			; passe le masque
	sub.l a2,a1				; offset de l'icone
	cmp.l #0,a1				; en dessous de la zone?
	bmi .fin					; oui!, pas du bureau!
	add.l a1,a1				; paquets de 256 en 512 (pour 4 plans)
	cmp #4,plans
	beq.s .k0
	add.l a1,a1				; de 512 … 1024 octets (pour 8 plans)
	cmp #8,plans
	beq.s .k0
	add.l a1,a1				; de 1024 … 2048 (pour 16 plans)
.k0:	
	add.l data_ptr,a1		; plus icone de d‚part
	cmp.l data_end,a1		; au dela de la zone?
	bpl .fin					; oui, pas du bureau!
	move.l d1,a0
	move.l 4(a0),a0		; intin
	move #7,(a0)			; mode or
	cmp #16,plans
	bne.s .k1
	addq #2,(a0)			; mode 9 plus joli!
.k1:
	move.l a1,mfdb			; adresse donn‚es
	move.l d1,a0
	move.l (a0),a1			; control
	move #109,(a1)			; vro_cpyfm (au lieu de vrt_cpyfm)
	move #1,6(a1)			; 1 seul intin
	move.l #mfdb,14(a1)	; nouvel mfdb
	bra.s .fin
.pas_data:
	move.l $8DF4,a0		; ICONBLK des disques (masques)
	cmp.l a1,a0				; bonne adresse?
	bne.s .fin				; non, on dessine autre chose
	exg.l d1,a0
	move.l $9400,a2		; adresse ressource
	add.w 14(a2),a2		; plus offset donn‚es
	sub.l a2,d1				; offset de l'icone
	bmi.s .fin				; en dessous de la zone
	asr.l #1,d1				; 256 en paquets de 128
	add.l #zone,d1			; plus masque de d‚part
	cmp.l data_ptr,d1
	bpl.s .fin				; au dela de la zone
	move.l d1,$E5CC		; masque choisi comme donn‚es du MFDB
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
	tst.b mt
	bne quitter				; multitos!, pas de couleur … mettre!
	
	tst.b nova
	bne nova_init			; carte nova, initialisation diff‚rente.
	
	bsr lire_inf			; va voir dans NEWDESK.INF le r‚solution demand‚e
	bra verif_plans
	
nova_init:
	XBIOS 4,2				; getrez
	add d0,ow_int			; 2 + getrez
	GEM_VDI open_work		; station physique, meme r‚solution que celle pour l'AES.
	move ow_cont+12,d7	; handle
	move d7,cw_cont+12
	move d7,qe_cont+12	; pour les autres appels
	GEM_VDI vq_extnd		; remplit work_out, le mot 4 donne le nombre de plans
	move work_out+8,d6
	GEM_VDI close_work	; referme la station, L'AES pourra la rouvrir.
	
	move d6,d0   ; les plans!
	
verif_plans:
	cmp #4,d0
	bmi quitter				; pas assez de couleurs
	
	bne.s .lb0
	lea prendre4,a0		; par d‚faut, 4 plans
	bra.s .lb3
.lb0:
	cmp #8,d0
	bne.s .lb1
	lea prendre8,a0		; rat‚, c'‚tait 8
	bra.s .lb3
.lb1:
	cmp #16,d0
	bne quitter			; plans incorrects
	lea prendre16,a0		; c'‚tait 16...
.lb3:
	move.l a0,prendre
	move d0,plans

	pea titre			; affiche COLOR TT et mon nom
	GEMDOS 9,6
	
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
	move.l prendre,a3		; aiguille vers la routine voulue selon les plans (4, 8 ou 16)
	jsr (a3)					; qu'on aura … l'‚cran
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
	
	; laisser intacts D6,D7,A2
prendre4:
	lea 22(a2),a3			; donn‚es de l'icone
	tst.b nova
	bne.s .nova
	moveq #63,d0			; 64 * 4 mots = 512 octets
.lb1:
	move (a3),(a1)+
	move 128(a3),(a1)+
	move 256(a3),(a1)+
	move 384(a3),(a1)+	; TT sans carte, mˆler les 4 plans!
	addq.l #2,a3
	dbf d0,.lb1
	lea 512+22(a2),a3		; passe au masque
	bra.s masque 
.nova:						; TT avec carte, meme codage!
	moveq #127,d0			; 128 mots longs = 512 octets
.lb0:
	move.l (a3)+,(a1)+	; copie les donn‚es
	dbf d0,.lb0
masque:
	moveq #31,d0
.lb1:
	move.l (a3)+,(a0)+	; copie le masque
	dbf d0,.lb1
	rts
	
	; laisser d6,d7,a2 (avancer a0 et a1)
prendre8:
	lea 22(a2),a3			; donn‚es
	tst.b nova
	bne.s .nova
	moveq #63,d0			; 64 * 4 mots = 512 octets
.lb7:
	move (a3),(a1)+
	move 128(a3),(a1)+
	move 256(a3),(a1)+
	move 384(a3),(a1)+	; TT sans carte, mˆler les 4 plans!
	clr.l (a1)+
	clr.l (a1)+				; plus 4 plans vides! (les plus signifiants)
	addq.l #2,a3
	dbf d0,.lb7
	lea 512+22(a2),a3		; passe au masque
	bra.s masque 
.nova:
	moveq #31,d4			; pour les 32 lignes
.lb0:
	swap d4					; TT avec carte, plus de plans, 1 point=1 octet!
	move.l (a3),d0
	move.l 128(a3),d1
	move.l 256(a3),d2
	move.l 384(a3),d3
	moveq #31,d5			; pour les 32 points par ligne
.lb1:
	clr d4
	btst d5,d0
	beq.s .lb2
	bset #0,d4
.lb2:
	btst d5,d1
	beq.s .lb3
	bset #1,d4
.lb3:
	btst d5,d2
	beq.s .lb4
	bset #2,d4
.lb4:
	btst d5,d3
	beq.s .lb5
	bset #3,d4
.lb5:
	cmp.b #15,d4
	bne.s .lb6
	st d4						; le 1 devient 255
.lb6:
	move.b d4,(a1)+
	dbf d5,.lb1				; autre point sur la mˆme ligne
	swap d4
	addq.l #4,a3			; ligne suivante
	dbf d4,.lb0
	lea 534(a2),a3
	bra masque

	; laisser d6,d7,a2 (avancer a0 et a1)
prendre16:
	lea 22(a2),a3			; donn‚es
	lea .table,a4			; conversions en 16 bits
	moveq #31,d4			; pour les 32 lignes
.lb0:
	swap d4
	move.l (a3),d0
	move.l 128(a3),d1
	move.l 256(a3),d2
	move.l 384(a3),d3
	moveq #31,d5			; pour les 32 points par ligne
.lb1:
	clr d4
	btst d5,d0
	beq.s .lb2
	bset #1,d4
.lb2:
	btst d5,d1
	beq.s .lb3
	bset #2,d4
.lb3:
	btst d5,d2
	beq.s .lb4
	bset #3,d4
.lb4:
	btst d5,d3
	beq.s .lb5
	bset #4,d4
.lb5:
	move 0(a4,d4.w),(a1)+
	dbf d5,.lb1				; autre point sur la mˆme ligne
	swap d4
	addq.l #4,a3			; ligne suivante
	dbf d4,.lb0
	lea 534(a2),a3
	bra masque	
.table: dc.w $ff7f,$007c,$e003,$e07f,$1f00,$1f7c,$ff03,$f75e
		  dc.w $1042,$107e,$f043,$f07f,$1f42,$1f7e,$ff43,$0000
	
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
	cmp.l #'NOVA',(a0)	; cartes NOVA (anciennes IMAGINE)?
	bne.s .lb2
	st nova					; si oui, nova=FF
.lb2:
	addq.l #4,a0			; cookie suivant
	bra.s .lb0
.fin: rts

lire_inf:
	clr -(sp)
	pea desk
	GEMDOS 61,8	; ouvrir NEWDESK.INF
	move d0,d7
	
	pea fichier
	move.l #1024,-(sp)
	move d7,-(sp)
	GEMDOS 63,12	; en lire 1024 octets (suffisant)
	
	move d7,-(sp)
	GEMDOS 62,4		; fermer
	
	lea fichier,a0
	lea 1024(a0),a1
	move.l #'#E 5',(a1)+
	move.l #'8 03',(a1)	; au cas ou on ne trouve pas #E, j'en mets un faux (ST haute)
	
.loop:
	cmp.b #'#',(a0)+		; cherche #
	bne.s .loop
	cmp.b #'E',(a0)+		; suivi de E
	bne.s .loop
	move.b 5(a0),d0		; 6Šme octet aprŠs E
	cmp.b #'1',d0			; ST basse?
	beq.s .ok_16
	cmp.b #'4',d0			; TT Moyenne?
	beq.s .ok_16
	cmp.b #'6',d0			; TT Basse? (cette valeur, je n'en suis pas sur...)
	bpl.s .ok_256
	moveq #2,d0				; par d‚faut deux plans ou moins (4 couleurs ou monochrome)
	rts
.ok_16:
	moveq #4,d0				; 16 couleurs, 4 plans
	rts
.ok_256:
	moveq #8,d0				; 256 couleurs, 8 plans
	rts

	data

open_work: dc.l ow_cont,ow_int,dum,work_out,work_out+90
ow_cont: dc.w 1,0,0,11,0,0,0,0,0,0,0,0
ow_int: dc.w 2,1,1,1,1,1,1,0,1,0,2

vq_extnd: dc.l qe_cont,qe_int,dum,work_out,work_out+90
qe_cont: dc.w 102,0,0,1,0,0,0,0,0,0,0,0
qe_int: dc.w 1

close_work: dc.l cw_cont,dum,dum,dum,dum
cw_cont: dc.w 2,0,0,0,0,0,0,0,0,0,0,0

nom: dc.b "C:\DESKCICN.RSC",0
desk: dc.b "C:\NEWDESK.INF",0
titre: dc.b 13,10,10,27,"c8",27,"b3 COLOR TT (c) 1995 "
			 dc.b 13,10,27,"b2  Tello Guillaume  "
			 dc.b 13,10,27,"c0",27,"b1",0

	even
	bss

ni: ds.w 1					; nombre d'icones
data_ptr: ds.l 1			; adresse pour les donn‚es
data_end: ds.l 1			; fin des donn‚es
zone: ds.b 200*1024		; avec 200k ‡a suffit
prendre: ds.l 1
dum: ds.l 2
fichier: 
work_out: ds.b 200*1024	; l… aussi
ptsout: ds.w 13
pile: ds.w 1
	end

