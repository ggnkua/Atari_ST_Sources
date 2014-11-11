; Pilote "Mon Encyclop‚die", Micro Applications
;

	opt P=68000,w+

SMA = 14	; offsets de 'petit' et 'grand' par rapport a 'taille'
BIG = 22
STE = 0	; 1 pour test sur STE, 0 pour CD TT
LEO = 0	; 0 indexs normaux, 1 indexs pour Leo et sa matrix etrange.
	
VERSION = '1.02'
VER_STR macro
	dc.b "1.02"
	endm

REG = 1			; 1 for registred versions, 0 for shareware

	if REG=1
		OUTPUT "F:\ENCYCLO\ENCYCLO.PRG"
NIVEAUX = 10
	else
		OUTPUT "F:\ENCYCLO\ENCY_SW.PRG"
NIVEAUX = 6
	endif
	

; some useful Macros

KEY MACRO
	movem.l d0-d2/a0-a2,-(sp)
	move.l #$20002,-(sp)
	trap #13
	addq.l #4,sp
	movem.l (sp)+,d0-d2/a0-a2
	ENDM
	
XBIOS MACRO   ; fn,stack
   move #\1,-(sp)
   trap #14
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

BIOS MACRO    ; fn,stack
   move #\1,-(sp)
   trap #13
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

GEMDOS MACRO    ; fn,stack
   move #\1,-(sp)
   trap #1
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM
   
GEM_AES MACRO
   move.l #\1,d1
   move.l #$c8,d0
   trap #2
   ENDM

GEM_VDI MACRO
   move.l #\1,a0
   move.l a0,d1
   move.l (a0),a0
   move i_handle,12(a0)
   moveq #$73,d0
   trap #2
   ENDM

; seeks into a file
 
SEEK MACRO	; size, mode (0=start, 1=current, 2=end)
	move #\2,-(sp)			; mode
	move mov_h,-(sp)		; handle
	move.l \1,-(sp)		; size (offset)
	move #66,-(sp)			; fseek
	trap #1
	lea 10(sp),sp
	ENDM

; converts an ugly Intel DWORD into a beautiful Motorola Long	
INTEL MACRO ; a data register (long)
	rol #8,\1
	swap \1
	rol #8,\1
	ENDM
	
; READINTEL an,dn	(an va en descendant)
READINTEL MACRO
	move.b -(\1),\2
	lsl #8,\2
	move.b -(\1),\2
	swap \2
	move.b -(\1),\2
	lsl #8,\2
	move.b -(\1),\2
	ENDM	

; READLONG an,dn (an augmente!!)
READLONG MACRO
	move.b (\1)+,\2
	lsl #8,\2
	move.b (\1)+,\2
	swap \2
	move.b (\1)+,\2
	lsl #8,\2
	move.b (\1)+,\2
	ENDM

; converts a beautiful 16bit NOVA pixel into an ugly Falcon one (for cram)
FALC16 MACRO
	ror #5,\1
	lsr.b #1,\1
	roxr #2,\1
	ENDM

; converts an ugly Falcon pixel into a beautiful NOVA one (without byte swap)
NOVA16 MACRO
	ror.l #5,\1
	lsr #1,\1
	rol.l #5,\1
	ENDM			
	
; converts a GGGBBBBB xRRRRRGG into a grey index (0 through 255)
TO_GREY MACRO
	ror #8,\1
	bclr #15,\1
	move.b (a1,\1.w),\1
	ENDM

; for unregistered mode only

TO_GREY_16 MACRO
	ror #8,\1
	bclr #15,\1
	move (a1,\1.w*2),\1
	ENDM
	
splice	MACRO  ; data1,data2,mask,temp,imm
	move.l \2,\4
	lsr.l #\5,\4
	eor.l \1,\4
	and.l \3,\4
	eor.l \4,\1
	lsl.l #\5,\4
	eor.l \4,\2
	ENDM

spl16 MACRO
	move.\0 \2,d7
	lsr.\0 #\3,d7
	eor.\0 \1,d7
	and.\0 d0,d7
	eor.\0 d7,\1
	lsl.\0 #\3,d7
	eor.\0 d7,\2
	ENDM

BUSY macro
	move #2,mf_int
	GEM_AES graf_mouse
	endm

FLECHE macro
	clr mf_int
	GEM_AES graf_mouse
	endm

	text
	
	; **************** Several Initialisations **********************

	jmp skip
debug: dc.l 0	
barre_coul:
	INCBIN "barre16.bmp"
barre_mono:
	INCBIN "barre1.bmp"
	even

skip:
	move.l  4(a7),a5
	move.l a5,basepage
   move.l $18(a5),d0
   add.l $1c(a5),d0
   add.l #$100,d0
   lea _pile,sp
   sub.l a5,d0
   move.l  d0,-(sp)
   move.l  a5,-(sp)
   clr -(sp)
   GEMDOS $4a,12              ; MSHRINK reduces space
   
   GEMDOS 48,2		; sversion
   ror #8,d0		; xx00 en 00xx
   cmp #$0019,d0
   spl mxcall		; si>=0.19, appel mxalloc supporte pour la TT Ram.
   pea special
   XBIOS 38,6

	GEM_AES appl_init
	GEM_AES graf_hand
	XBIOS 2,2
	add d0,ow_int
	GEM_VDI open_work	
	move ow_cont+12,i_handle
	lea intout,a3
	move.l (a3),fd_maxi		; pour form_dial
	lea screenw,a4
	move (a3)+,d0
	addq #1,d0
	move d0,(a4)+
	move (a3)+,d0
	addq #1,d0
	move d0,(a4)+
	GEM_VDI vq_extnd
	move 4(a3),d0
	if REG=1
		cmp #24,d0
		beq.s .areu
		cmp #32,d0
		beq.s .areu
		cmp #16,d0					; 16 plans=connu
		beq.s .areu
		cmp #8,d0					; 256 coul aussi
		beq.s .areu
		cmp #4,d0					; 16 coul idem
		beq.s .areu
		moveq #1,d0					; sinon, faire comme le mnochrome
	.areu:
	else
		moveq #1,d0
	endif
	move d0,(a4)	; plans	
	FLECHE

	GEMDOS 25,2				; dgetdrv
	add #'A',d0	   		; ascii drive (A=0, B=1 ...)
	lea path,a4
	move.b d0,(a4)+
	move.b #':',(a4)+		; paths stats with X:, X being the drive
	sub #'A'-1,d0			; drive number (A=1, B=2,...)
	move d0,-(sp)
	move.l a4,-(sp)
	GEMDOS 71,8				; degetpath, adds path in (A4)
.lb0:
	tst.b (a4)+
	bne.s .lb0				; looks for the 0 (end of the string)
	subq.l #1,a4			; back on the 0
	move.b #"\",(a4)+	
	move.b #"*",(a4)+	
	move.b #".",(a4)+	
	move.b #"T",(a4)+	
	move.b #"X",(a4)+	
	move.b #"T",(a4)+	
	clr.b (a4)


	bsr init_barre
	GEM_VDI vqt_attributes	; remplit 'petit'
	move petit+2,d7			; hauteur
	add d7,d7					; doublee
	move d7,vp_int
	GEM_VDI vst_height			; grande taille
	addq.l #8,vqt_attributes+16	; petit devient grand
	GEM_VDI vqt_attributes	; remplit 'grand'
	asr d7
	move d7,vp_int
	GEM_VDI vst_height

	cmp #640,screenw
	bpl.s .assez_large
	lea etroit,a0
	bsr alert
	bra sortie_2
.assez_large:
	
	lea pal_gem,a3
	moveq #0,d0			; premier index
	moveq #15,d3
	move planes,d1
	cmp #4,d1
	beq.s sauve
	cmp #8,d1
	bne.s saute
	move #255,d3
sauve:
	bsr sauve_palette
saute:
	if REG=1
		cmp #1,planes
		bne.s .areu
		move.l #'_SW.',_name+4
	.areu:
	endif
	GEM_AES shel_find
	GEM_AES rsrc_load
	bsr charge_inf
	GEM_VDI vst_align
	bsr reserve_ecran

.reverifie:
	moveq #1,d0			; le CD numero 1
	bsr verif_cd
	cmp #1,d0			; ok??
	beq.s .c_bon
	
	bsr fenetre			; libere ecran et reserve ecran a la suite
	bra.s .reverifie
	
.c_bon:
	st verif
	bsr init_fenetre
	bsr zone_travail
	bsr intro
	bsr ouvre_fichiers
		
principal:
	GEM_AES evnt_button
	tst eb_out
	beq.s principal
;	bsr aff_eb
	move mx,d0
	move my,d1
	cmp #54,d1
	bpl .autre
	divs #80,d0
	cmp #0,d0
	bne.s .m1
	; ici retour au menu GEM
	bsr fenetre
	bsr affiche_blanc_page
	bra principal
.m1:
	tst.b is_video		; si videotheque, rien d'autre n'est autoris‚!!
	bne.s principal	; donc on quitte...
	cmp #1,d0
	bne.s .m2
	; ici la recherche par themes
	moveq #3,d0
	move.l #$3000A,d7
	bsr manage_tree
	bsr traite_themes
	bra principal
.m2:
	cmp #2,d0
	bne.s .m3
	; ici recherche A-Z
	moveq #2,d0
	move.l #$4001D,d7
	bsr manage_tree
	bsr traite_az
	bra principal
.m3:
	cmp #3,d0
	bne.s .m4
	; ici recherche par critere
	bsr remplit_rech
	moveq #1,d0
	move.l #$1000E,d7
	bsr manage_tree
	bsr traite_recherche
	tst.b err
	bne.s .gloups
	st venant_recherche
	bsr traite_lien	; va vers venant de qix	
	bra principal
.gloups:
	sf err
	bra principal
.m4:
	cmp #4,d0
	bne.s .m5
	; ici galerie multimedia
	moveq #4,d0
	move.l #$2000C,d7
	bsr manage_tree
	bsr traite_galerie
	bra principal
.m5:
	cmp #5,d0
	bne.s .m6
	; ici actualite
	bsr traite_actu
	bra principal
.m6:
	cmp #6,d0
	bne.s .m7
	; ici Quizz
	moveq #8,d0
	move.l #$50010,d7
	bsr manage_tree
	bsr traite_quizz
	bra principal
.m7:
	cmp #7,d0
	bne principal
	; ici aide
	moveq #0,d0			; aide g‚n‚rale
	move.l page_ptr,a1
	tst.b (a1)
	beq.s .joue_aide	; pas d'article, aide generale
	cmp.b #4,1(a1)		; un article?
	bne.s .joue_aide
	moveq #6,d0			; si oui, aide article!!!
.joue_aide:
	bsr aide_video
	bra principal
.autre:
	move.l page_ptr,a1
	tst.b (a1)			; page presente?
	beq principal		; non
	lea taille,a0
	sub (a0),d0			; mx-x fenetre
	bmi principal		; a gauche!
	cmp 4(a0),d0
	bpl principal		; a droite!
	sub 2(a0),d1		; my-y fenetre
	bmi principal		; au dessus
	cmp 6(a0),d1
	bpl principal		; au dessous
	sub 6+SMA(a0),d1	; premiere ligne
	bpl.s .l1
	bsr petit_menu
	bra principal
.l1:
	sub 6+BIG(a0),d1	; ligne de titre
	bpl.s .l4
	; clic sur le titre = Historique.
	bsr remplit_historique
	moveq #7,d0
	move.l #$7000D,d7
	bsr manage_tree
	bsr traite_historique
	bra principal	
.l4:	
	ext.l d1
	divs 6+SMA(a0),d1	; numero de la ligne concernee
	cmp 10(a0),d1
	bpl principal		; trop bas (reste de pixels eventuels)
	add 76(a1),d1		; + premiere ligne de la page = ligne absolue (1 … max)
	lea lignes,a0
	lea pointeurs,a2
	bra.s .l3
.l2:
	tst.b (a0)
	beq principal		; ligne vide!!
	add #256,a0
	add #16,a2
.l3:
	dbf d1,.l2		
	sub #256,a0
	sub #16,a2
	bsr traite_lien
	bra principal

blocs:
	move.l 29646,a0
	move.l basepage,a1
	move #"A"-1,d0
.lb0:
	movem.l (a0),d1-d4
	cmp.l d4,a1
	bne.s .lb1
	addq #1,d0
.lb1:
	move.l (a0),a0
	cmp.l #$800,a0
	bpl.s .lb0
	lea .aff(pc),a0
	move.b d0,2(a0)
	move.l a0,-(sp)
	GEMDOS 9,6
	rts
.aff: dc.b 27,"HA",0

aff_eb:
	move eb_out,d0
	lea .table(pc),a0
	lea .aff+2(pc),a1
	rept 4
	rol #4,d0
	move d0,d1
	and #$000F,d1
	move.b 0(a0,d1.w),(a1)+
	endr
	pea -6(a1)
	GEMDOS 9,6
	rts
.table: dc.b "0123456789ABCDEF"
.aff: dc.b 27,"H1234",0	
	even


; d0=x relatif au debut de la fenetre
; a1=(page_ptr)
; a0=taille

petit_menu:
	move 4+SMA(a0),d1	; largeur un caract
	moveq #6,d2
	muls d1,d2			; largeur 6 caracteres
	sub d2,d0
	bpl.s .lb0
	; ici RETOUR
	tst.b (a1)
	beq.s .rien
	cmp.b #4,1(a1)
	bne.s .rien		; pas d'article
	tst.l 80(a1)
	beq.s .rien
	movem.l d0-d2/a0-a2,-(sp)	; lib‚rer le bloc suppl‚mentaire
	move.l 80(a1),a0
	bsr mfree
	movem.l (sp)+,d0-d2/a0-a2
.rien:
	clr.b (a1)		; page annul‚e
	cmp.l #pages,a1
	beq.s .lb1
	sub #128,a1
.lb1:
	tst.b (a1)		; plus rien a afficher
	bne.s .kekchoz
	sf is_video		; retour au debut, videotheque terminee
	move.b rbcd1,lecteur
	moveq #1,d0
	bsr verif_cd	; la gars il a qu'a etre honnete
.kekchoz:
	move.l a1,page_ptr
	bsr reconstruire_page
.fin:
	rts
.lb0:
	sub d1,d0		; espace
	bmi.s .fin
	sub d2,d0
	bpl.s .lb2
	; ici Pages+
	move 76(a1),d0	; premiere ligne
	add 10(a0),d0	; nouvelle premiere ligne
	cmp 78(a1),d0	; trop bas?
	bgt.s .fin		; oui!
.lb4:
	move d0,76(a1)	; sinon, on change
	bsr affiche_blanc_page
	rts
.lb2:
	sub d1,d0		; espace
	bmi.s .fin
	sub d2,d0
	bpl.s .lb3
	; ici pages-
	move 76(a1),d0
	cmp #1,d0		; deja en premiere ligne?
	beq.s .fin
	sub 10(a0),d0	; nouvelle premiere ligne
	cmp #1,d0		; trop remonte?
	bpl.s .lb4		; non, on garde
	moveq #1,d0		; sinon, c'est 1!
	bra.s .lb4
.lb3:
	cmp.b #4,1(a1)	; un article??
	bne.s .lb5		; ben non...
	sub d1,d0
	bmi.s .fin
	sub d2,d0
	bpl.s .lb5
	; ici COPIER
	bsr copie_article
	bsr affiche_blanc_page
	rts	
.lb5:
	rts	

; a0=la ligne concernee
; a1=(page_ptr)
; a2=pointeurs concernes

traite_lien:
	tst.b venant_recherche
	bne .venant_de_qix
	move.b 1(a1),d0	; type de fichier
	bne .autre
	; ici OUT
	move.l (a2),d0		; index
	move.l d0,d2
	subq.l #1,d0
	muls #75,d0			; offset
	move.l fichier_ptr,a2
	add.l d0,a2			; structure dans le fichier
	lea 128(a1),a3		; structure suivante
	addq.l #2,a0
	moveq #0,d1
	move.b (a0)+,d1	; taille ligne
	lea 12(a3),a4		; titre
	bra.s .lb0
.lb1:
	move.b (a0)+,(a4)+
.lb0:
	dbf d1,.lb1
	clr.b (a4)			; fin de chaine
	lea 75(a2),a4		; structure suivante
	cmp.l fichier_fin,a4
	bpl.s .lien_qix	; fin de fichier, lien vers autre
	move.b $40(a4),d0
	lsl #8,d0
	move.b $3f(a4),d0	; niveau suivant
	cmp 2(a1),d0		; compare avec niveau actuel
	bls.s .lien_qix	; meme niveau ou inferieur, autre fichier
	; ici lien dans le meme OUT
	move.l a3,page_ptr
	move (a1),(a3)+	; recopie nø et type
	move d0,(a3)+		; le niveau
	addq.l #1,d2		; nouvel index
	move.l d2,(a3)+
	move.l #-1,(a3)+	; tout le niveau
	add #64,a3			; saute le titre
	move #1,(a3)+		; premiere ligne
	clr (a3)				; nombre de lignes inconnu
	bsr reconstruire_page
	rts
.lien_qix:
	moveq #0,d1
	move.b (a1),d1			; fichier d'origine
	lea references,a0
	add d1,d1
	move -2(a0,d1),d0	; numero fichier destination
	asr d1
	move.l a3,page_ptr	; nouvelle page
	move.b d0,(a3)+
	cmp.b #18,d1
	bpl.s .qixmedia
	move.b #1,(a3)+		; type 1:QIX si le OUT est avant le fichier 17
	bra.s .commun
.qixmedia:
	move.b #5,(a3)+		; type 5:QIXmedia, si out apres le 18!!
.commun:
	clr (a3)+				; niveau inutile
	move.l a0,-(sp)
	lea $45(a2),a0
	READINTEL a0,d0	
	move.l d0,(a3)+		; premier index dans QIX
	lea $49(a2),a0
	READINTEL a0,d0
	move.l d0,(a3)+		; second index
	move.l (sp)+,a0
	lea 64(a3),a3
	move #1,(a3)+			; premiere ligne
	clr (a3)+				; total lignes inconnu
	bsr reconstruire_page
	rts
.autre:	
	cmp.b #1,d0
	bne .pas_qix
	; ici QIX vers article (passant par LEXART.QIX)
	movem.l a1-a2,-(sp)
	move.l (a2),d0
	INTEL d0					; index dans lexart.qix
	subq.l #1,d0			
	asl.l #2,d0
	move.l d0,d1
	asl.l #2,d1
	add.l d1,d0
	add.l d1,d1
	add.l d1,d0				; offset exact dans larxart.qix
	lea off_size,a0
	move #$7f00,(a0)+		; lire sans fermer
	move index_h,(a0)+
	move.l d0,(a0)+		; offset
	moveq #52,d0
	move.l d0,(a0)			; taille
	bsr charge_fichier
	movem.l (sp)+,a1-a2
	tst.b err
	bne .fin
	move.l a0,(a2)			; remplace index par pointeur RAM
	move.l a0,-(sp)		; sauv‚ pour MFREE
	bra.s .venant_de_qix
.pas_qix:
	cmp.b #2,d0
	bne .pas_azsec
	; ici AZSEC vers LEXART.QIX
	lea 128(a1),a3		; nouvelle page
	move.l a3,page_ptr
	move.b #-1,(a3)+	; LEXART.QIX
	move.b #3,(a3)+
	move #1,(a3)+		; inutile
	move.l (a2)+,d0
	INTEL d0
	move.l d0,(a3)+	; premier index
	move.l (a2)+,d0
	INTEL d0
	move.l d0,(a3)+	; second index
	lea 64(a3),a2
	move #1,(a2)+		; premiere ligne
	clr (a2)+			; nombre de lignes inconnu
	addq.l #2,a0
	moveq #0,d0
	move.b (a0)+,d0	; nombre de caracteres
	bra.s .lb3
.lb2:
	move.b (a0)+,(a3)+
.lb3:
	dbf d0,.lb2
	clr.b (a3)
	bsr reconstruire_page
	rts
.pas_azsec:	
	cmp.b #3,d0
	bne.s .pas_lex
	; ici LEXART.QIX vers article
	; direct ou en venant d'un autre QIX
	; ou alors d'une recherche
.venant_de_qix:
	move.l a1,a3		; niveau actuel
	tst.b (a1)			; quelque chose? (pour une recherche ca peut etre 0.)
	beq.s .pas_monter
	lea 128(a1),a3		; un niveau au dessus
.pas_monter:
	move.l a3,page_ptr
	move.b #-2,(a3)+	; lexart.qdb
	move.b #4,(a3)+	; type 4=article
	move #1,(a3)+		; niveau
	move.l (a2),a2		; pointeur vers la structure
	move.l 30(a2),d0
	INTEL d0
	move.l d0,(a3)+	; offset dans QDB
	move.l 34(a2),D0
	INTEL d0
	move.l d0,(a3)+	; taille dans QDB
	move.l a3,a0		; souvenir
	moveq #29,d0
.lb4:
	move.b (a2)+,(a0)+
	dbf d0,.lb4			; copie le titre 30c
	clr.b (a0)
	add #64,a3
	move #1,(a3)+		; premiere ligne
	clr (a3)+			; total inconnu
	clr.l (a3)+			; pas de liste de blocs a liberer
	tst.b venant_recherche
	bne.s .bon
	cmp.b #-1,(a1)
	beq.s .bon
	; ici, c'est qu'on vient d'un QIX en passant par lexart a liberer
	move.l (sp)+,a0
	bsr mfree
.bon:
	sf venant_recherche
	bsr reconstruire_page
	rts
.pas_lex:
	cmp.b #5,d0
	bne.s .pas_qixmedia
	clr code_cd
	move.l (a2),d0
	INTEL d0
	bsr _bloc_media
	bsr media_nom_type
	bmi .fin
	bsr joue_media
	bra .fin
.pas_qixmedia:
	cmp.b #4,d0
	bne .pas_art
	move.b 1(a0),d0	; type de ligne
	cmp.b #2,d0
	bne.s .pas_image
	; ici, on clique sur l'image d'un article (len avec image agrandie)
	moveq #-16,d0
	add mx,d0
	sub taille,d0
	bmi .fin			; avant l'image
	cmp 10(a0),d0
	bgt .fin			; apres l'image	
	moveq #1,d3			; type IMAGE
	movem.l 14(a0),d4-d5	; nom du fichier
	bsr _media_nom_type
	bsr joue_media
	rts
.pas_image:
	; ici dans un article, cherche un lien sur une ligne de texte
	move mx,d0
	sub taille,d0		; offset par rapport a la bordure
	bmi .fin			; pas sur la ligne!
	lsr #3,d0			; numero du caractŠre (debut a 0)
	addq.l #2,a0
	moveq #0,d1
	move.b (a0)+,d1	; taille de la ligne en caracteres
	cmp d1,d0
	bpl .fin			; trop loin!
	lea 0(a0,d1.w),a3	; pour bloc media
	lea 1(a0,d0.w),a1
.cherche_debut_mot:
	cmp.l a0,a1
	beq .fin			; fini, debut de ligne=pas de lien
	move.b -(a1),d0
	cmp.b #" ",d0
	beq .fin			; un espace donc pas de lien
	cmp.b #">",d0		; magic! caractere de lien!!
	bne.s .cherche_debut_mot
	lea 1(a1),a5
	READLONG a5,d0
	cmp.l #"BMP:",d0
	beq.s .lien_media
	cmp.l #"WAV:",d0
	beq.s .lien_media
	cmp.l #"AVI:",d0
	bne .lien_hypertexte
.lien_media:	
	clr code_cd
	bsr bloc_media		; a5 et a3 corrects
	bsr media_nom_type
	bmi .fin
	bsr joue_media	
	rts	
.lien_hypertexte:
	bsr cherche_mot
	bmi .fin				; pas trouv‚!!!
	move.l a0,-(sp)	; pour liberation
	bra .venant_de_qix
.pas_art
	cmp.b #6,d0
	bne.s .pas_quizz
	cmp.b #1,(a2)		; 1=ligne inactive du quizz
	beq .fin			; donc rien a faire
	tst.b (a2)
	bmi.s .gagne		; FF, donc bonne reponse
	lea quizz_faux,a0
	lea _qfaux,a2
	move.b 10(a1),d0	; bonne reponse
	add.b #'0',d0
	move.b d0,(a2)
	bsr alert
	move.l page_ptr,a1
	bra.s .quizz_suite	
.gagne:
	addq #1,4(a1)		; un point de plus
.quizz_suite:
	subq #1,6(a1)		; une de moins
	beq.s .fin_quizz
	bsr reconstruire_page
	rts
.fin_quizz:
	lea quizz_fin,a0
	lea _qfin,a2
	moveq #0,d0
	move 4(a1),d0		; score
	divs #10,d0
	add.b #'0',d0
	move.b d0,(a2)+
	swap d0
	add.b #'0',d0
	move.b d0,(a2)+
	moveq #0,d0
	move 8(a1),d0
	divs #10,d0
	add.b #'0',d0
	move.b d0,1(a2)
	bsr alert
	bsr vider_pile
	rts
.pas_quizz:
	cmp.b #7,d0
	bne.s .pas_videothek
	; ici le lien menu videotheque vers une sous partie
	lea 128(a1),a3	; niveau au dessus
	move.l a3,page_ptr
	move.b (a2),(a3)+	; numero du fichier
	move.b #8,(a3)+	; type 8: videotheque
	clr (a3)+
	clr.l (a3)+
	clr.l (a3)+
	addq.l #3,a0		; la ligne cliquee devient le titre
	moveq #63,d0
.trik:
	move.b (a0)+,(a3)+
	dbf d0,.trik
	move #1,(a3)+
	clr (a3)+
	clr.l (a3)+
	bsr reconstruire_page
	rts
.pas_videothek:
	cmp.b #8,d0
	bne.s .pas_vid_2
	; ici les liens vers image ou video de la videotheque
	move (a2)+,d0
	beq.s .fin		; pointeur nul, pas de lien sur cette ligne
	lea buffer,a0	; pour y mettre le nom du fichier
	ror #8,d0		; 1 pour image, 2 pour video
	lea .img(pc),a1
	cmp #1,d0
	beq.s .vid_image
	lea .vid(pc),a1
.vid_image:
	move.b (a1)+,(a0)+
	bne.s .vid_image
	moveq #7,d1
	subq.l #1,a0
.le_nom:
	move.b (a2)+,(a0)+
	dbf d1,.le_nom
.recule:
	cmp.b #32,-(a0)
	beq.s .recule
	addq.l #1,a0
.extension:
	move.b (a1)+,(a0)+
	bne.s .extension
	bsr joue_media
	rts
.pas_vid_2:
.fin:	
	sf err
	rts
.img: dc.b "*:\MEDIA\SMALLBMP\",0,".bmp",0
.vid: dc.b "*:\MEDIA\AVI\",0,".avi",0
	even

; renvoit "MI" -> pas de bloc a liberer, pas de lien trouve
; sinon a1 = page_ptr
; a2 pointe sur un pointeur sur la structure de l'article
; a0 bloc lexart.qix a liberer
	
cherche_mot:
	lea iso_vers_majuscules,a6	; conversion en alphabet simple
	BUSY
	lea line_err2,a5		; la ou mettre le mot
	moveq #29,d0
.vide:
	move.b #32,(a5)+
	dbf d0,.vide
	lea -30(a5),a5			; retour au debut
	addq.l #1,a1				; debut du lien
	move.l a5,a0
	moveq #0,d0
.formate:
	move.b (a1)+,d0
	beq.s .fin_mot
	cmp.b #32,d0
	beq.s .fin_mot			; mot se termine sur 0 ou sur un espace
	move.b 0(a6,d0.l),(a0)+	; copie en convertissant
	bra.s .formate
.fin_mot:
	moveq #0,d0
	move.b (a5),d0			; initiale
	cmp #'A',d0
	bmi .zut
	cmp #'Z'+1,d0
	bpl .zut
.ok:
	sub #'A',d0
	lea index_par_lettre,a0
	add d0,d0
	add d0,a0
	moveq #0,d6
	moveq #0,d7
	move (a0)+,d6			; premier index
	move (a0)+,d7			; premier index lettre suivante
	sub d6,d7				; nombre de blocs
	subq.l #1,d6
	mulu #52,d6				; offset
	mulu #52,d7				; taille
	lea off_size,a0
	move #$7f00,(a0)+		; lire sans fermer
	move index_h,(a0)+
	move.l d6,(a0)+		; offset
	move.l d7,(a0)			; taille
	bsr charge_fichier	
	lea 0(a0,d0.l),a3		; fin de fichier
	move.l a0,a1			; les chaines chargees
.chaine:
	cmp.l a3,a1
	bpl.s .libere_zut		; pas trouve!
	move.l a1,a2			; chaine courante
	move.l a5,a4			; celle a chercher
	moveq #0,d0
	moveq #29,d1			; 30 caractŠres
.compare:
	move.b (a2)+,d0
	move.b 0(a6,d0.l),d0	; en alphabet simple
	cmp.b (a4)+,d0
	bne.s .non
	dbf d1,.compare
	bra.s .oui
.non:
	add #52,a1
	bra.s .chaine
.oui:
	move.l a1,(a5)	; conserve l'article trouve (pour "venant de qix")
	move.l a0,4(a5)	; et l'adresse du bloc
	move.l page_ptr,a1
	tst.l 80(a1)	; un bloc?
	beq.s .rien
	move.l 80(a1),a0
	clr.l 80(a1)
	bsr mfree
.rien:
	FLECHE
	bsr nouveau_bloc
	move.l page_ptr,a1
	move.l a5,a2	; line_err2
	move.l 4(a5),a0
	moveq #0,d0		; ne renvoit pas 'MI'
	rts
.libere_zut:
	bsr mfree	
.zut:
	FLECHE
	moveq #-1,d0			; renvoit MI = pas de concordance
	rts

; s'occupe uniquement de page_ptr
; si place suffisante -> rien a faire
; sinon, page_ptr-128 et la table est d‚calee

nouveau_bloc:
	move.l page_ptr,a0
	lea pages,a1
	move.l #NIVEAUX*128,d0
	move.l #128,d1
	lea 0(a1,d0),a2	; fin de table
	add.l d1,a0			; nouvelle place
	cmp.l a2,a0
	bmi.s .ok
	lea 0(a1,d1.l),a2
	move #NIVEAUX*32-33,d0
.lb0:
	move.l (a2)+,(a1)+	; decale la table vers le bas
	dbf d0,.lb0
	sub.l d1,page_ptr
	rts			
.ok:
	rts
	
index_par_lettre:
	; a,b,c,d,e,f,g,h,i,j
	dc.w 1,$b09,$1328,$252f,$2b27,$3117,$3644,$3c9b,$41f6,$456c
	; k,l,m,n,o,p,q,r,s
	dc.w $4706,$4935,$5072,$5b6f,$5f2c,$630c,$7095,$713b,$776f
	; t,u,v,w,x,y,z
	dc.w $81a5,$8897,$898e,$8d08,$8e5a,$8e92,$8efa
	; fin z
	dc.w $8fad

; a0: bloc de 100 octets de LEXMED.QIX
media_nom_type:
	move 38(a0),d3
	ror #8,d3			; type
	move 40(a0),code_cd	; $A920 pour cd1, $5047 pour cd2
	movem.l 30(a0),d4-d5	; nom de 8 lettres du fichier
	bsr mfree			; libere le bloc
_media_nom_type:		; si d3,d4,d5 deja connus!
	lea media,a0
	move d3,d0
	subq #1,d0
	bmi .fin				; pas reconnu!!
	cmp #3,d0
	bpl .fin				; la non plus
	asl #2,d0
	move.l 0(a0,d0.w),a0
	lea buffer,a1
	move.l a2,-(sp)
	lea 100(a1),a2
	movem.l d4-d5,(a2)
.lb0:
	move.b (a0)+,(a1)+	; copie le chemin
	bne.s .lb0
	subq.l #1,a1
	rept 8
	move.b (a2)+,(a1)+	; le nom
	endr
	move.l (sp)+,a2
.lb1:
	cmp.b #32,-(a1)		; revient sur les blancs
	beq.s .lb1
	addq.l #1,a1
.lb2:
	move.b (a0)+,(a1)+	; ajoute l'extension
	bne.s .lb2	
	move d3,d0				; le type!!	
	rts
.fin:
	moveq #-1,d0			; renvoit MINUS si erreur
	rts	
	
media: dc.l .med_images,.med_video,.med_son
.med_images: dc.b "*:\MEDIA\BMP\",0,".BMP",0
.med_video: dc.b "*:\MEDIA\AVI\",0,".AVI",0
.med_son: dc.b "*:\MEDIA\WAVE\",0,".WAV",0

	even	
sortie:
;	move.l #$20002,-(sp)
;	trap #13
;	addq.l #4,sp
	move index_h,-(sp)
	GEMDOS 62,4			; fclose
	move base_h,-(sp)
	GEMDOS 62,4
	move media_h,-(sp)
	GEMDOS 62,4
	GEM_AES rsrc_free
sortie_2:					; si largeur<640
	GEM_VDI close_work
	GEM_AES appl_exit
	clr -(sp)
	trap #1

ouvre_fichiers:
	lea findex,a0
	bsr.s .open
	move d0,index_h
	lea fbase,a0
	bsr.s .open
	move d0,base_h
	lea fmedia,a0
	bsr.s .open
	move d0,media_h
	rts
.open:
	move.b lecteur,(a0)
	clr -(sp)
	move.l a0,-(sp)
	GEMDOS 61,8
	rts
	
reserve_ecran:
	moveq #3,d0
	moveq #0,d1
	bra.s _update
	
libere_ecran:
	moveq #2,d0
	moveq #3,d1
	
_update:
	move d0,wu_int
	move d1,fd_int
	GEM_VDI hide_mouse
	GEM_AES wind_update
	GEM_AES form_dial
	GEM_VDI show_mouse
	rts

fenetre:
	cmp #8,planes
	bne.s .pas_pal
	lea pal_sav,a3
	moveq #16,d0
	move #79,d3		; 16 couleurs + 64 niveaux de gris eventuels
	bsr sauve_palette
	lea pal_gem,a0
	bsr _fixe
.pas_pal:
	bsr libere_ecran
	moveq #0,d0
	move.l d0,rg_int
	GEM_AES rsrc_gaddr
	GEM_AES menu_bar
.lb0:	
	GEM_AES evnt_mesag
	lea message,a0
	cmp #10,(a0)
	bne.s .lb0
	move 8(a0),d0	; objet choisi
	cmp #8,d0
	bne.s .lb1
	; ici infos
	lea alert_info,a0
	bsr alert
	bra .normal
.lb1:
	cmp #17,d0
	bne.s .lb2
	; ici retour
	lea message,a0
	move 6(a0),mt_int
	GEM_AES menu_tnormal
	cmp #8,planes
	bne.s .pas_pal2
	lea pal_sav,a0
	bsr _fixe
.pas_pal2:
	tst.b verif
	beq.s .pas_verif
	bsr reserve_ecran
	bsr zone_travail
.pas_verif:
	rts
.lb2:
	cmp #19,d0
	bne.s .lb3
	; ici quitter
	lea alert_quit,a0
	bsr alert
	cmp #1,d0
	bne .normal
	bra sortie
.lb3:
	cmp #21,d0
	bne.s .lb4
	; ici preferences
	bsr pref_dialogue
	bra.s .normal
.lb4:
	cmp #22,d0
	bne.s .lb5
	; reglage ecran/images
	bsr ima_dialogue
	bra.s .normal
.lb5:
	cmp #24,d0
	bne.s .lb6	
	; ici sauver
	bsr sauve_inf
	bra.s .normal
.lb6:
	nop
.normal:
	moveq #0,d0
	move.l d0,rg_int
	GEM_AES rsrc_gaddr
	lea message,a0
	move 6(a0),mt_int
	GEM_AES menu_tnormal
	bra .lb0

	; upon entry:
	; d7=0 -> draw + form_do + clear
	; d7=1 -> draw
	; d7=-1 -> clear
	; tree=adresse de l'arbre
	
manage_tree2:
	tst d7
	bmi .clear				; if <0, just frees the screen
	GEM_AES form_center	; the coordinates
	clr rect_dial			; reserves screen
	GEM_AES form_dial2
	move.l #7,od_int	; 0.w and 7.w
	GEM_AES objc_draw
	tst d7
	bne .out					; if non zero, just draw
	GEM_AES form_do		; else, dialog
	move intout,d6
	and #$7fff,d6			; the exit object
	move.l tree,a0
	move d6,d0
	muls #24,d0
	bclr #0,11(a0,d0.w)	; resets the 'selected' bit of the exit button
.clear:
	move #3,rect_dial
	GEM_AES form_dial2
.out:
	rts

pref_dialogue:
	moveq #5,d0
	move.l d0,rg_int
	GEM_AES rsrc_gaddr
	bsr remplit_pref
	moveq #0,d7
	bsr manage_tree2
	cmp #22,d6
	beq.s .annule
	bsr recupere_pref
	cmp #24,d6
	bne.s .annule
	bsr sauve_inf
.annule:
	rts	

ima_dialogue:
	moveq #6,d0
	move.l d0,rg_int
	GEM_AES rsrc_gaddr
	bsr remplit_ima
	moveq #0,d7
	bsr manage_tree2
	cmp #31,d6
	beq.s .annule
	bsr recupere_ima
	cmp #33,d6
	bne.s .annule
	bsr sauve_inf
.annule:
	rts	

remplit_rech:
	lea rech_flag,a5
	moveq #1,d0
	move.l d0,rg_int
	GEM_AES rsrc_gaddr
	move.l tree,a0
	lea 12(a5),a1
	move.l 24+12(a0),a2	; ted 1
	move.l (a2),a2			; text 1
.copy1:
	move.b (a1)+,(a2)+
	bne.s .copy1
	lea 46(a5),a1
	move.l 48+12(a0),a2	; ted 2
	move.l (a2),a2			; text 2
.copy2:
	move.b (a1)+,(a2)+
	bne.s .copy2
	moveq #3,d0		; ibox
	move.b 1(a5),d1
	bne.s .ok
	moveq #4,d1		; par defaut, CHAINE 1 seule
.ok:
	bsr fixe_radio
	lea 15*24+11(a0),a0	; octet STATE de "chercher suivant"
	bclr #3,(a0)			; par defaut, il est actif
	tst.b (a5)
	bne.s .fin
	bset #3,(a0)			; pas de recherche entamee, donc inactif
.fin
	rts
	
recupere_rech:
	lea rech_flag,a5
	moveq #3,d0
	bsr lit_radio
	move.b d0,1(a5)		; d0=mode en cours!
	lea atari_vers_majuscules,a6
	move.l tree,a0
	move.l 24+12(a0),a2
	lea 12(a5),a1
	bsr.s .chaine
	move.l a1,d2		; taille chaine 1
	move d2,10(a5)
	move.l 48+12(a0),a2
	lea 46(a5),a1
	bsr.s .chaine
	move.l a1,d3		; taille chaine 2
	move d3,44(a5)
	tst d2
	beq.s .erreur		; si vide pas de recherche
	cmp.b #4,d0			; mode chaine 1 seul??
	beq.s .sortie
	tst d3
	beq.s .erreur		; si modes 1/2/3, chaine 2 vide = erreur
.sortie:
	moveq #0,d0
	rts
.erreur:
	lea rech_bug,a0
	bsr alert
	moveq #-1,d0
	rts
.chaine:
	move.l (a2),a2		; text
	moveq #0,d1
	move.l a1,a3		; garde le debut!
.loop:
	move.b (a2)+,d1
	move.b 0(a6,d1.l),(a1)+
	bne.s .loop
	subq.l #1,a1
.recule:
	cmp.l a3,a1
	beq.s .debut
	cmp.b #32,-(a1)
	beq.s .recule
	addq.l #1,a1
.debut:
	clr.b (a1)			; nouvelle fin
	move.l a3,a1
	move.l a1,d1
.avance:
	tst.b (a3)
	beq.s .gloups
	cmp.b #32,(a3)+
	beq.s .avance
	subq.l #1,a3
.gloups:
	move.b (a3)+,(a1)+
	bne.s .gloups	
	sub.l d1,a1
	subq.l #1,a1		; taille de la chaine
	rts		
	
	
	
remplit_historique:
	moveq #7,d0
	move.l d0,rg_int
	GEM_AES rsrc_gaddr
	move.l tree,a0
	lea 48+12(a0),a0	; ob_spec premiŠre chaine
	move.l a0,a2
	moveq #9,d0
.vide:
	bset #3,-1(a2)		; disabled
	move.l (a2),a1
	move.b #"V",(a1)+
	move.b #"i",(a1)+
	move.b #"d",(a1)+
	move.b #"e",(a1)+
	clr.b (a1)+
	add #24,a2
	dbf d0,.vide
	lea pages,a1
	moveq #NIVEAUX-1,d0	; selon la version!
	moveq #0,d2
	lea iso_atari,a4
.lb0:
	tst.b (a1)
	beq.s .fin				; plus de pages
	bclr #3,-1(a0)			; ligne autorisee
	lea 12(a1),a2			; chaine Titre
	move.l (a0),a3			; chaine objet
	moveq #49,d1			; limite a 50 caracteres
.lb1:
	move.b (a2)+,d2
	move.b 0(a4,d2.w),(a3)+	; copie le titre
	dbf d1,.lb1
	clr.b (a3)				; fin de chaine
	add #24,a0				; objet suivant
	add #128,a1				; page suivante
	dbf d0,.lb0				; limite a NIVEAUX
.fin:
	rts
	
sauve_inf:
	clr -(sp)
	pea _name
	GEMDOS 60,8
	move d0,d3
	bmi.s .bug
	lea le_inf_fin,a1
	lea le_inf,a0
	sub.l a0,a1		; taille fichier
	move.l a0,-(sp)
	move.l a1,-(sp)
	move d3,-(sp)
	GEMDOS 64,12
	move d3,-(sp)
	GEMDOS 62,4
.bug:
	rts
		
remplit_ima:
	moveq #8,d0
	moveq #-48,d1
	add.b rb32,d1
	bsr fixe_radio
	moveq #13,d0
	moveq #-48,d1
	add.b rb24,d1
	bsr fixe_radio
	moveq #16,d0
	moveq #-48,d1
	add.b rb16,d1
	bsr fixe_radio
	moveq #21,d0
	moveq #-48,d1
	add.b rb08,d1
	bsr fixe_radio
	moveq #24,d0
	moveq #-48,d1
	add.b rb04,d1
	bsr fixe_radio
	moveq #28,d0
	moveq #50,d1
	sub.b rbtt,d1
	bsr fixe_radio
	move.l 24+12(a0),a0	; pointeur sur chaine nø1
	lea 15(a0),a0			; bon endroit dela chaine
	move planes,d0
	lea .chaines(pc),a1
.cherche:
	cmp.b (a1)+,d0
	beq.s .trouve
.avance:
	tst.b (a1)+
	bne.s .avance
	bra.s .cherche
.trouve:
	move.b (a1)+,(a0)+
	bne.s .trouve
	rts
.chaines:
	dc.b 32,"32 bits.",0,24,"24 bits.",0,16,"16 bits.",0,8,"256 couleurs.",0
	dc.b 4,"16 culeurs.",0,2,"4 couleurs.",0,1,"monochrome.",0
	even

remplit_pref:
	moveq #26,d0
	moveq #50,d1
	sub.b rbaid,d1
	bsr fixe_radio
	moveq #6,d0
	moveq #89,d1
	sub.b rbavi,d1
	divs #12,d1
	bsr fixe_radio
	moveq #9,d0
	moveq #50,d1
	sub.b rbvid,d1
	bsr fixe_radio
	moveq #19,d0
	moveq #50,d1
	sub.b rbfre,d1
	bsr fixe_radio
	moveq #12,d0
	moveq #0,d1
	lea sons(pc),a0
	move.b rbson,d2
	move.b d2,5(a0)
.lb0:
	addq #1,d1
	cmp.b (a0)+,d2
	bne.s .lb0
	bsr fixe_radio
	move.l 24*3+12(a0),a0	; pointeur sur ted 3
	move.l (a0),a0				; chaine de saisie
	move.b rbcd1,(a0)+
	move.b rbcd2,(a0)+
	clr.b (a0)
	rts
sons: dc.b "DRrPY",0

recupere_ima:
	moveq #48,d7
	moveq #8,d0
	bsr lit_radio
	add d7,d0
	move.b d0,rb32
	moveq #13,d0
	bsr lit_radio
	add d7,d0
	move.b d0,rb24
	moveq #16,d0
	bsr lit_radio
	add d7,d0
	move.b d0,rb16
	moveq #21,d0
	bsr lit_radio
	add d7,d0
	move.b d0,rb08
	moveq #24,d0
	bsr lit_radio
	add d7,d0
	move.b d0,rb04
	moveq #28,d0
	bsr lit_radio
	moveq #50,d7
	sub d0,d7
	move.b d7,rbtt
	rts
	
recupere_pref:
	moveq #6,d0
	bsr lit_radio
	moveq #89,d1
	muls #12,d0
	sub d0,d1
	move.b d1,rbavi
	moveq #26,d0
	bsr lit_radio
	moveq #50,d7
	sub d0,d7
	move.b d7,rbaid
	moveq #9,d0
	bsr lit_radio
	moveq #50,d7
	sub d0,d7
	move.b d7,rbvid
	moveq #19,d0
	bsr lit_radio
	moveq #50,d7
	sub d0,d7
	move.b d7,rbfre
	move.l 24*3+12(a0),a0	; pointeur sur ted 3
	move.l (a0),a0				; chaine de saisie
	move.b (a0)+,d0
	bne.s .lb1
	move.b #'P',d0
	clr.b (a0)	
.lb1:
	move.b d0,rbcd1
	move.b (a0),d1
	bne.s .lb0
	move.b d0,d1
.lb0:
	move.b d1,rbcd2
	moveq #12,d0
	bsr lit_radio
	lea sons(pc),a0
	move.b -1(a0,d0),rbson
	rts
	
; tree=arbre
; d0=i-box
; retour->d0=numero du radio bouton allum‚

lit_radio:
	move.l tree,a0
	move d0,d1
	move d0,d2
	moveq #0,d0
	muls #24,d1
	move 2(a0,d1.l),d1		; premier fils
.boucle:
	addq #1,d0
	muls #24,d1
	lea 0(a0,d1.l),a1
	btst #0,11(a1)				; state?
	bne.s .ok
	move (a1),d1				; suivant
	cmp d2,d1
	bne.s .boucle
.ok:
	rts

; tree=arbre
; d0=ibox
; d1.byte=numero du bouton a allumer	

fixe_radio:
	and #$00FF,d1
	move.l tree,a0
	move d0,d2
	move d0,d3
	moveq #0,d0
	muls #24,d2
	move 2(a0,d2.l),d2		; premier fils
.boucle:
	addq #1,d0
	muls #24,d2
	lea 0(a0,d2.l),a1
	bclr #0,11(a1)
	cmp d0,d1
	bne.s .skip
	bset #0,11(a1)
.skip:
	move (a1),d2				; suivant
	cmp d3,d2
	bne.s .boucle
.ok:
	rts
	
intro:
	cmp.b #'1',rbvid
	bne.s .fin
	lea titre,a0
	bsr joue_video
.fin:
	rts

; a0: chaine complete

joue_video:
	move.l a0,-(sp)
	lea _mp_name,a0
	cmp.b #'M',rbavi
	beq.s .ok
	lea _an_name,a0
.ok:
	move.l a0,af_addr
	GEM_AES appl_find		; cherche le player!!
	move.l (sp)+,a0	
	tst mp_id
	bmi .fin
	tst.b is_video			; videotheque?
	bne.s .pas_swp
	cmp #$5047,code_cd	; cd2??
	bne.s .pas_swp
	move.b rbcd2,(a0)		; modifie le lecteur!!!
	moveq #2,d0
	bsr verif_cd
	cmp #1,d0
	bne .fin					; pas le bon CD!!!
.pas_swp:
	lea mp_chaine,a1
	cmp.b #'*',(a0)
	bne.s .lb0
	move.b lecteur,(a0)
.lb0:
	cmp.b #'M',rbavi
	beq.s .ok2
	move.w #'+d',(a1)+
	bra.s .commun
.ok2:
	move.w #'-d',(a1)+
.commun:
	move.b #' ',(a1)+	; options
.lb1:
	move.b (a0)+,(a1)+
	bne.s .lb1
	move #2,wu_int
	GEM_AES wind_update
	GEM_VDI hide_mouse
	GEM_AES appl_write
.attente:
	GEM_AES evnt_mesag
	move message,d0
	cmp #'EN',d0
	bne.s .attente			; toujours pas fini...
	move #3,wu_int
	GEM_AES wind_update
	bsr zone_travail
	GEM_VDI show_mouse
	tst.b is_video
	bne.s .fin
	cmp #$5047,code_cd
	bne.s .fin
.reverifie:
	moveq #1,d0
	bsr verif_cd
	cmp #1,d0
	beq.s .fin
	sf verif
	bsr fenetre
	bra.s .reverifie	
.fin:
	st verif
	rts

traite_recherche:
	cmp #13,d0		; bouton annule
	beq .fin
	cmp #15,d0		; poursuivre!!
	beq.s .zyva
	bsr recupere_rech
	bmi.s .fin		; erreur, ne pas lancer!
	lea rech_flag,a0
	st (a0)	; debut de recherche accept‚
	clr.l 2(a0)	; offset nul
	move.l a0,a1
	add.l #31954,a1	; fin bloc
	move.l a1,6(a0)	; pointeur forc‚ a la fin
.zyva:
	bsr recherche		; oh! le beau z'algorithme
	tst.b err
	bne.s .gloups
	rts
.gloups:
	lea fin_rech,a0
	bsr alert
.fin:
	st err
	bsr affiche_blanc_page
	rts
	
traite_az:
	cmp #28,d0		; bouton annule
	beq .fin
	move d0,-(sp)
	bsr vider_pile
	lea faz,a0
	bsr charge_fichier
	move (sp)+,d0
	tst.b err
	bne.s .bug
	subq #2,d0
	moveq #"A",d1
	add d0,d1
	move.b d1,_taz	; la lettre dans le titre
	muls #10,d0		; 10 octets par lettre
	movem.l 0(a0,d0.w),d0-d1	; les deux indexs
	movem.l d0-d1,-(sp)
	bsr mfree
	movem.l (sp)+,d0-d1
	INTEL d0
	INTEL d1
	move.l page_ptr,a1
	move.b #17,(a1)+	; numero fichier
	move.b #2,(a1)+	; type 2 (specifique a AZSEC.OUT)
	move #1,(a1)+		; tous au niveau 1!
	move.l d0,(a1)+
	move.l d1,(a1)+	; les deux index!!!
	move #1,64(a1)		; premiere ligne
	clr 66(a1)			; nombre de lignes inconnu
	lea t_az,a0
.lb0:
	move.b (a0)+,(a1)+
	bne.s .lb0
	bsr reconstruire_page
	rts	
.fin:
	bsr affiche_blanc_page
	rts
.bug:
	sf err
	bsr blanc			; plus rien...
	rts
	
traite_actu:
	lea th_actu,a0
	bsr traite_out_qix
	bsr reconstruire_page
	rts
	
traite_historique:
	cmp #12,d0
	beq.s .fin
	subq #2,d0				; niveau (de 0 … 9)
	lea pages,a0
	move #128,d1
	muls d1,d0			; offset
	add.l d0,a0				; niveau voulu
	cmp.l page_ptr,a0
	bpl.s .fin				; rien a faire, deja au niveau voulu
	add d1,a0	
	move.l a0,pile_limite
	bsr vider_pile
	sub.l #128,page_ptr
	bsr reconstruire_page
	rts
.fin:
	bsr affiche_blanc_page
	rts

traite_quizz:
	cmp #15,d0
	beq .fin
	move d0,-(sp)		; bouton de sortie
	bsr vider_pile
	lea f36,a0
	cmp.b #'*',(a0)
	bne.s .ben_non
	move.b lecteur,(a0)
.ben_non:
	clr -(sp)
	move.l a0,-(sp)
	GEMDOS 61,8			; fopen
	tst.l d0
	bpl.s .ok
	addq.l #2,sp		; le D0
	bra.s .fin 			; ouverture impossible
.ok:
	move d0,quizz_h
	lea line_buffer,a0
	move #399,d0
.vide_questions:
	clr (a0)+
	dbf d0,.vide_questions
	moveq #2,d0			; ibox
	bsr lit_radio		; radio bouton allume
	move.l page_ptr,a0
	move.b #-4,(a0)+			; fichier LEXQUIZ.MED
	move.b #6,(a0)+			; type de fichier
	subq #2,d0			; boutons 1/9 -> -1/7
	smi (a0)+			; FF si bouton 'Un peu de tout'
	move.b d0,(a0)+	; sinon, theme fixe
	clr (a0)+			; points=0
	move (sp)+,d0		; recupŠre bouton de sortie
	sub #12,d0
	muls #10,d0			; 10 ou 20 questions
	move d0,(a0)+		; compteur descendant
	move d0,(a0)+		; conserve le total
	clr (a0)+			; ici sera la bonne reponse
	add #64,a0			; pas de titre a priori
	move #1,(a0)+		; afficher premiŠre ligne
	clr (a0)+			; nombre de lignes inconnu
	clr.l (a0)+			; pas de bloc suppl‚mentaire
	bsr reconstruire_page	; ici se fait le choix de la question!
	rts
.fin:
	bsr affiche_blanc_page
	rts
	
	
traite_themes:
	cmp #9,d0
	beq.s .fin
	cmp #11,d0		; articles "multimedia" dans les HPG
	bne.s .them
	bsr traite_hpg
	bsr reconstruire_page
	rts
.them:
	lea themes,a0
	subq #2,d0
	add d0,d0
	add d0,d0
	move.l 0(a0,d0.w),a0
	bsr traite_out_qix	
	bsr reconstruire_page
	rts
.fin:
	bsr affiche_blanc_page
	rts
	
traite_hpg:
	bsr vider_pile
	move.l page_ptr,a1
	move.b #37,(a1)+
	move.b #4,(a1)+
	clr (a1)+
	clr.l (a1)+
	clr.l (a1)+
	lea 64(a1),a0
	move #1,(a0)+	; ligne 1
	clr (a0)+		; nombre de lignes inconnu
	clr.l (a0)+		; pas de bloc en plus
	lea .titre(pc),a0
.lb0:
	move.b (a0)+,(a1)+
	bne.s .lb0
	rts
.titre: dc.b "Le tour du monde en images et sons",0
	even
	
traite_out_qix:
	move.l a0,-(sp)
	bsr vider_pile
	move.l (sp)+,a0
	move.l page_ptr,a1
	moveq #1,d0
	move.b 5(a0),(a1)+	; numero fichier
	clr.b (a1)+				; type OUT
	move d0,(a1)+			; niveau 1
	move.l d0,(a1)+		; LONG premier element
	neg.l d0
	move.l d0,(a1)+		; LONG -1=tous les elements du niveau
	move.l (a0),a0			; chaine titre
	move.l a1,a2			; en souvenir
.lb0:
	move.b (a0)+,(a1)+	; copie le titre
	bne.s .lb0
	add #64,a2				; passe le titre
	move #1,(a2)+			; premiere ligne en haut
	clr (a2)+				; nombre de lignes (rien encore!!)	
	rts

traite_galerie:
	cmp #11,d0		; bouton Annuler
	beq.s .fin
	cmp #13,d0		; bouton Videotheque
	bne.s .pas_video
	lea vidtek_info,a0
	bsr alert
	cmp #2,d0		; annuler!
	beq.s .fin
	moveq #2,d0
	bsr verif_cd
	cmp #1,d0
	bne.s .fin
	st is_video
	move.b rbcd2,lecteur
	bsr traite_videotheque
	bsr reconstruire_page
	rts
.pas_video:
	lea galerie,a0
	subq #2,d0
	add d0,d0
	add d0,d0
	move.l 0(a0,d0.w),a0
	bsr traite_out_qix	
	bsr reconstruire_page
	rts
.fin:
	bsr affiche_blanc_page
	rts

traite_videotheque:
	bsr vider_pile
	move.l page_ptr,a1
	move.b #46,(a1)+	; fichier 46: menu videotheque en RAM deja
	move.b #7,(a1)+	; type 7 menu videotheque
	clr (a1)+
	clr.l (a1)+
	clr.l (a1)+
	lea 64(a1),a0
	move #1,(a0)+		; ligne 1
	clr (a0)+			; nombre de lignes inconnu
	clr.l (a0)+			; pas de bloc en plus
	lea .titre(pc),a0
.lb0:
	move.b (a0)+,(a1)+
	bne.s .lb0
	rts
.titre: dc.b "La vid‚othŠque du CD num‚ro 2",0
	even

; normalement, limite a #pages comme borne inferieure
; mais on peut le limiter a autre chose (en mettant la valeur dans
; pile_limite->pile limit est remis a "pages" a la fin).
pile_limite: dc.l pages
	
vider_pile:
	lea quizz_h,a0
	tst.w (a0)			; fichier QUIZZ ouvert?
	beq.s .suite
	move (a0),-(sp)
	clr (a0)
	GEMDOS 62,4				; ferme le fichier
.suite:
	move.l page_ptr,a0
.lb0:
	tst.b (a0)
	beq.s .deja_vide
	cmp.b #4,1(a0)			; type article??
	bne.s .deja_vide
	tst.l 80(a0)
	beq.s .deja_vide		; pas d'image a liberer
	movem.l d0-d2/a0-a2,-(sp)
	move.l 80(a0),a0
	bsr mfree
	movem.l (sp)+,d0-d2/a0-a2
.deja_vide:
	clr.l 80(a0)
	clr.b (a0)
	cmp.l pile_limite(pc),a0
	beq.s .lb1
	sub #128,a0
	bra.s .lb0
.lb1:
	move.l a0,page_ptr
	move.l #pages,pile_limite
	rts
	
reconstruire_page:
	bsr blanc
	move.l page_ptr,a0
	move.b (a0),d0
	beq .fin			; si 0, pas de page en cours
	bmi.s .deja_ouvert	; si negatif, les deux fichiers de base toujours la
	cmp.b #46,d0			; faux fichier: menu videotheque
	beq.s .en_ram
	move.b fichier_actuel,d1
	cmp.b d1,d0
	beq.s .en_ram		; fichier deja en ram
	move.b d0,fichier_actuel	; nouveau!
	tst.b d1
	beq.s .lb0			; si 0, rien a vider
	move.l fichier_ptr,a0
	bsr mfree
.lb0:
	moveq #0,d0
	move.b fichier_actuel,d0
	subq #1,d0
	lea fichiers,a0
	add d0,d0
	add d0,d0
	move.l 0(a0,d0.w),a0	; adresse fichier
.commun:
	bsr charge_fichier
	tst.b err
	bne .fin
	move.l a0,fichier_ptr
	add.l a0,d0
	move.l d0,fichier_fin
.en_ram:
	bsr remplit_lignes		
	bra .affiche
.deja_ouvert:
	cmp.b #-1,d0
	bne.s .qdb					
	; ici on charge une zone de LEXART.QIX
	lea off_size,a1
	move #$7f00,(a1)+			; charge off size sans fermer!
	move index_h,(a1)+		; f_handle
	move.l 4(a0),d0			; premier index
	move.l d0,d2
	subq.l #1,d0
	asl.l #2,d0
	move.l d0,d1
	asl.l #2,d1
	add.l d1,d0
	add.l d1,d1
	add.l d1,d0
	move.l d0,(a1)+			; (i-1)x52 = offset!
	move.l 8(a0),d0			; second index
	sub.l d2,d0
	addq.l #1,d0
	asl.l #2,d0
	move.l d0,d1
	asl.l #2,d1
	add.l d1,d0
	add.l d1,d1
	add.l d1,d0
	move.l d0,(a1)+			; (j-i+1)x52 = taille!
	tst.b fichier_actuel
	beq.s .lb1			; si 0, rien a vider
	move.l fichier_ptr,a0
	bsr mfree	
.lb1:
	st fichier_actuel		; fichier = -1 !!!
	bra.s .commun	; charge, remplit, affiche
.qdb:
	cmp.b #-2,d0
	bne.s .quizz		; peut etre -4??
	; ici on charge un article de LEXART.QDB (enfin!)
	lea off_size,a1
	move #$7f00,(a1)+			; charge off size sans fermer!
	move base_h,(a1)+		; f_handle
	move.l 4(a0),d0			; offset
	subq.l #1,d0
	move.l d0,(a1)+		; offset corrige
	move.l 8(a0),(a1)+	; taille
	tst.b fichier_actuel
	beq.s .lb2			; si 0, rien a vider
	move.l fichier_ptr,a0
	bsr mfree	
.lb2:
	move.b #-2,fichier_actuel
	bra .commun	; charge, remplit, affiche
.quizz:
	cmp.b #-4,d0
	bne .fin				; inconnu!
	tst.b 2(a0)				; FF si choix du theme
	beq.s .deja_choisi
	bsr random
	and #$7,d0
	move.b d0,3(a0)		; theme actuel
.deja_choisi:
	moveq #0,d0
	move.b 3(a0),d0		; theme
	lea quizz_titre,a1
	move d0,d1
	add d1,d1
	add d1,d1
	move.l 0(a1,d1.w),a1	; chaine de titre
	lea 12(a0),a2
.ajoute_titre:
	move.b (a1)+,(a2)+
	bne.s .ajoute_titre
	muls #50,d0				; offset du theme
	lea line_buffer,a1
	add.l d0,a1				; debut du theme
	lea 50(a1),a2			; fin du theme
	bsr random
	divs #50,d0
	swap d0					; numero de question 0-49
.cherche_question:
	cmp.l a1,a2
	bne.s .good
	lea -50(a2),a1
.good:
	tst.b (a1)+
	bne.s .cherche_question
	dbf d0,.cherche_question
	st -(a1)					; celle la est maintenant utilis‚e
	sub.l #line_buffer,a1	; numero de la question
	move.l a1,d0
	move.l #534,d1
	muls d1,d0				; offset par rapport au debut du fichier
	lea off_size,a1
	move #$7f00,(a1)+			; charge off size sans fermer!
	move quizz_h,(a1)+		; f_handle
	move.l d0,(a1)+		; offset
	move.l d1,(a1)+	; taille
	tst.b fichier_actuel
	beq.s .lb5			; si 0, rien a vider
	move.l fichier_ptr,a0
	bsr mfree	
.lb5:
	move.b #-4,fichier_actuel
	bra .commun	; charge, remplit, affiche	
.affiche;
	bsr affiche_page
.fin:
	sf err
	rts	

random:
	movem.l d1-d2/a0-a2,-(sp)
	XBIOS 17,2
	movem.l (sp)+,d1-d2/a0-a2
	swap d0
	clr d0
	swap d0
	rts

affiche_blanc_page:
	bsr blanc
affiche_page:
	GEM_VDI hide_mouse
	move.l page_ptr,a5
	tst.b (a5)
	beq .fin				; rien a mettre!!!
	lea taille,a3
	lea vt_pts,a4
	move.l (a3),(a4)	; x et y pour premiere ligne
	addq.l #2,a4
	lea menu_page,a0
	moveq #21,d0			; taille maxi
	clr.b 20(a0)
	cmp.b #4,1(a5)			; type article??
	bne.s .pas_art
	move.b #32,20(a0)		; rallonge la chaine
	moveq #28,d0			; la aussi!
.pas_art:	
	bsr _ligne
	move 6+SMA(a3),d0		; hauteur ligne
	add d0,(a4)			; ligne suivante
	move 2+BIG(a3),vp_int		; taille GRANDE
	GEM_VDI vst_height
	move titre_couleur(pc),vp_int
	GEM_VDI vst_color
	move #10,vp_int
	GEM_VDI vst_effects
	lea 12(a5),a0			; titre
	move 12(a3),d0			; largeur en GROS
	bsr _ligne
	move 2+SMA(a3),vp_int
	GEM_VDI vst_height		; taille petite
	move #1,vp_int
	GEM_VDI vst_color
	clr vp_int
	GEM_VDI vst_effects
	move 6+BIG(a3),d0
	sub 6+SMA(a3),d0
	add d0,(a4)
	lea lignes,a6
	moveq #0,d0
	move 76(a5),d0			; premiere ligne a afficher
	subq.l #2,d0
	asl.l #8,d0				; * 256
	add.l d0,a6				; bien place
	move 10(a3),d6			; nombre de lignes en hauteur
	bra.s .fin_boucle
.encore:
	move.l a6,a0
	tst.b (a0)+
	beq.s .fin				; 0=derniere ligne
	move.b (a0)+,d0
	cmp.b #1,d0				; texte?
	bne.s .image
	moveq #0,d0
	move.b (a0)+,d0		; taille
	bsr _ligne
	bra.s .fin_boucle
.image:
	cmp.b #2,d0
	bne.s .fin_boucle
	bsr _ligne_image
.fin_boucle:
	move 6+SMA(a3),d0
	add d0,(a4)			; ligne suivante
	add #256,a6
	dbf d6,.encore
.fin:
	GEM_VDI show_mouse
	rts	
titre_couleur: dc.w 10	; rouge, mais ca peut etre noir!		
	
_ligne:
	movem.l d4/a2-a3,-(sp)
	tst d0
	beq _que_dalle
	moveq #0,d3				; pas d'effet!
	cmp #7,d0
	bmi.s .pas_gras
	cmp.b #"@",(a0)
	bne.s .pas_gras
	cmp.l #"FETT",1(a0)
	bne.s .pas_gras
	cmp.b #"@",5(a0)
	bne.s .pas_gras
	subq #6,d0
	addq.l #6,a0
	movem.l d0-d2/a0-a2,-(sp)
	moveq #9,d3				; un effet
	move d3,vp_int
	GEM_VDI vst_effects	
	movem.l (sp)+,d0-d2/a0-a2
.pas_gras:
	lea vt_int,a1
	addq.l #1,a1			; impair
	moveq #0,d1				; taille
	moveq #0,d2
	moveq #0,d5				; compteur
	moveq #">",d4			; caractŠre a chercher!
	lea buffer,a3			; on va y empiler les soulignements des liens
.lb0:
	move.b (a0)+,d2
	beq _fin_ligne
	cmp.b d4,d2
	bne.s .pas_special
	move d5,(a3)+			; premiere position ou derniŠre
	sub #'>'+' ',d4
	neg d4					; > devient ' ' ou l'inverse
.pas_special:
	addq #1,d1
	move.b iso_atari(pc,d2.w),(a1)
	addq #1,d5
	cmp d5,d0
	beq _fin_ligne
	addq.l #2,a1
	bra.s .lb0
	; codes iso vers codes Atari!
iso_atari:
   dc.b 0,1,2,3,4,5,6,7,8,9
   dc.b 10,11,12,13,14,15,16,17,18,19
   dc.b 20,21,22,23,24,25,26,27,28,29
   dc.b 30,31,32,33,34,35,36,37,38,39
   dc.b 40,41,42,43,44,45,46,47,48,49
   dc.b 50,51,52,53,54,55,56,57,58,59
   dc.b 60,61,3,63,4,65,66,67,68,69
   dc.b 70,71,72,73,74,75,76,77,78,79
   dc.b 80,81,82,83,84,85,86,87,88,89
   dc.b 90,91,92,93,94,32,96,97,98,99
   dc.b 100,101,102,103,104,105,106,107,108,109
   dc.b 110,111,112,113,114,115,116,117,118,119
   dc.b 120,121,122,123,124,125,126,127,128,129
   dc.b 130,131,132,133,134,135,136,137,138,139
   dc.b 140,141,142,143,144,145,39,147,148,149
   dc.b 150,151,152,153,154,155,156,157,158,159
   dc.b 160,161,162,156,164,165,166,167,168,169
   dc.b 170,171,172,173,174,175,248,177,253,254
   dc.b 180,181,182,183,184,185,186,175,188,189
   dc.b 190,191,192,193,194,195,196,143,198,199
   dc.b 200,144,202,203,204,205,206,207,208,209
   dc.b 210,211,212,213,153,215,216,217,218,219
   dc.b 220,221,222,223,133,160,131,227,132,229
   dc.b 230,135,138,130,136,137,236,161,140,139
   dc.b 240,241,242,162,147,245,148,247,248,151
   dc.b 250,150,129,253,254,255
_fin_ligne:
	cmp #'>',d4
	beq.s .pas_lien
	move d5,(a3)+
.pas_lien:
	move d1,vt_cont+6
	GEM_VDI v_gtext
	tst d3
	beq.s .souligne
	clr vp_int
	GEM_VDI vst_effects
.souligne:
	lea vl_pts,a2
	move (a4),d0		; y de la ligne
	move.l a4,-(sp)
	lea taille,a4
	add 6+SMA(a4),d0			; plus hauteur caractere
	subq #1,d0			; moins un point!
	move d0,2(a2)
	move d0,6(a2)		; y=y'
	move (a4),d4		; x fenetre
.lb1:
	cmp.l #buffer,a3
	beq.s .que_dalle_1
	move -(a3),d0
	move -(a3),d1
	muls 4+SMA(a4),d0
	muls 4+SMA(a4),d1			; caracteres en pixels
	add d4,d0
	add d4,d1
	subq #1,d0
	move d1,(a2)
	move d0,4(a2)
	GEM_VDI v_pline
	bra.s .lb1
.que_dalle_1:
	move.l (sp)+,a4
_que_dalle:
	movem.l (sp)+,d4/a2-a3
	rts

_ligne_image:
	move taille,d2			; x fenetre
	add #16,d2				; une bordure les gars!
	swap d2
	move (a4),d2			; y de la ligne: x,y ecran
	move.l 4(a0),d0		; x,y source
	move.l 8(a0),d1		; l,h
	move.l (a0),a0			; mfdb source
	st mouse
	bsr affiche_image
	rts
	
remplit_lignes:
	lea lignes,a2			; les lignes!
	lea pointeurs,a4		; les index ou autres
	move.l fichier_ptr,a0
	move.l page_ptr,a1
	clr 78(a1)				; nombre de lignes remis a zero
	move.b 1(a1),d0		; type
	bne.s .t1
	; ici type 0, les *.OUT
	bsr remplit_out
	bra.s .fin
.t1:
	cmp.b #1,d0
	bne.s .t2
	; ici les type 1, *.QIX
	bsr remplit_qix
	bra.s .fin
.t2:
	cmp.b #2,d0
	bne.s .t3
	; ici le type 2: AZSEC.OUT
	bsr remplit_azsec
	bra.s .fin
.t3:
	cmp.b #-1,(a1)
	bne.s .t4
	; ici LEXART.QIX
	bsr remplit_lexart
	bra.s .fin
.t4:
	cmp.b #-2,(a1)
	bne.s .t5
	bsr remplit_article
	bra.s .fin
.t5:
	cmp.b #5,d0
	bne.s .t6
	bsr remplit_qixmedia
	bra.s .fin
.t6:
	cmp.b #6,d0
	bne.s .t7
	bsr remplit_quizz
	bra.s .fin
.t7:
	cmp.b #4,d0		; un article cree a partir des HPG (fichier=37)
	bne.s .t8
	bsr remplit_hpg
	bra.s .fin
.t8:
	cmp.b #7,d0		; menu videotheque
	bne.s .t9
	bsr remplit_menu_videotheque
	bra.s .fin
.t9:
	cmp.b #8,d0
	bne.s .t10
	bsr remplit_videotheque
	bra.s .fin
.t10:
	nop
.fin:
	rts

remplit_videotheque:
	cmp.l fichier_fin,a0
	bpl .fin
	move.l #$ff010000,(a2)	; une ligne vide
	add #256,a2
	clr (a4)
	add #16,a4
	move.l a2,a3
	st (a3)+
	move.b #1,(a3)+
	move.l a3,a5
	move.b #36,(a3)+	; taille
	move.b #"@",(a3)+
	move.l #"FETT",(a3)+
	move.b #"@",(a3)+
	moveq #29,d0
.titre:
	move.b (a0)+,(a3)+
	dbf d0,.titre
	clr.b (a3)
.recule:
	cmp.b #32,-(a3)
	bne.s .fini
	subq.b #1,(a5)
	bra.s .recule
.fini:
	clr.b 1(a3)
	add #256,a2
	clr (a4)
	add #16,a4
	move.l #$ff010000,(a2)
	add #256,a2	
	clr (a4)
	add #16,a4
	movem.l (a0)+,d2-d3	; nom du fichier
	move #$0100,(a4)+
	movem.l d2-d3,(a4)
	add #14,a4			; ligne image
	move #$0200,(a4)+
	movem.l d2-d3,(a4)
	add #14,a4			; ligne video
	move.l a2,a3
	move.l #$ff010b3e,(a3)+
	move.l #"Voir",(a3)+
	move.l #"_ima",(a3)+
	move #"ge",(a3)+
	clr.b (a3)
	add #256,a2
	move.l a2,a3
	move.l #$ff010b3e,(a3)+
	move.l #"Voir",(a3)+
	move.l #"_vid",(a3)+
	move #"‚o",(a3)+
	clr.b (a3)
	add #256,a2
	move.l #$ff010000,(a2)
	add #256,a2	
	clr (a4)
	add #16,a4		
	addq #6,78(a1)		; six lignes de plus
	lea 50(a0),a3		; debut du texte
	move.l #2048,d0	; taille
	moveq #0,d1			; octet nul a mettre dans les pointeurs
	bsr _formate
	add #2100,a0
	bra remplit_videotheque
.fin:
	clr.b (a2)
	rts
	
remplit_menu_videotheque:
	moveq #38,d0	; numero de fichier
	lea .textes(pc),a0
.lb0:
	tst.b (a0)
	beq.s .fin
	move.l a2,a3
	st (a3)+
	move.b #1,(a3)+
	move.l a3,a5
	clr.b (a3)+
.copie:
	move.b (a0)+,(a3)+
	bne.s .copie
	move.l a3,d1
	sub.l a5,d1
	subq.l #2,d1
	move.b d1,(a5)	; longueur
	add #256,a2
	addq #1,78(a1)
	move.b d0,(a4)	; le pointeur est en fait le numero de fichier
	addq.b #1,d0	; fichier suivant
	addq.l #8,a4
	addq.l #8,a4
	bra.s .lb0	
.fin:
	clr.b (a2)
	rts	
.textes: dc.b "Sport",0,"Politique",0,"Histoire",0,"Espace",0,"Aviation",0
	dc.b "Automobile",0,"Informatique",0,"Curiosit‚s touristiques",0,0
	even

remplit_hpg:
	movem.l a0-a2,-(sp)
	BUSY
	movem.l (sp)+,a0-a2
	move.l fichier_fin,a3
.lb0:
	cmp.l a3,a0
	bpl.s .fin
	cmp.b #'"',(a0)+
	bne.s .lb0			; cherche l'ouverture de guillemets
	READLONG a0,d0
	cmp.l #"HPG:",d0
	beq.s .lb1			; lien HPG
.lb2:
	cmp.b #'"',(a0)+
	bne.s .lb2
	bra.s .lb0			; sinon, va jusqu'a la fermeture des guillements
.lb1:
	lea .fich(pc),a4
.nom:
	move.b (a0)+,d0
	cmp.b #'"',d0
	beq.s .lb3
	move.b d0,(a4)+
	bra.s .nom
.lb3:
	move.b #".",(a4)+
	move.b #"H",(a4)+
	move.b #"P",(a4)+
	move.b #"G",(a4)+
	clr.b (a4)			; le nom est complet!
	movem.l a0/a3,-(sp)	; debut et fin de fichier
	movem.l a1-a2,-(sp)	; qu'on recupere tout de suite
	lea .chem(pc),a0
	bsr charge_fichier
	movem.l (sp)+,a1-a2
	move.l a0,-(sp)		; pour mfree
	bsr.s _remplit_un_hpg	
	move.l (sp)+,a0
	bsr mfree
	movem.l (sp)+,a0/a3
	bra.s .lb0	 
.fin:
	clr.b (a2)
	movem.l a0-a2,-(sp)
	FLECHE
	movem.l (sp)+,a0-a2
	rts
.chem: dc.b "*:\SYSDIR\"
.fich:
	dc.b "12345678.123",0
	even
_remplit_un_hpg:
	lea 0(a0,d0.l),a3	; fin de fichier
.lb0:
	moveq #0,d0
	moveq #3,d1
.lb1:
	lsl.l #8,d0
	cmp.l a3,a0
	bpl .fin
	move.b (a0)+,d0
	dbf d1,.lb1
	cmp.l #"TITE",d0		; le titre???
	bne.s .pas_titre
	move.l #$FF010000,(a2)	; ligne vide
	add #256,a2					; ligne suivante
	move.l a2,a4
	st (a4)+
	move.b #1,(a4)+
	move.l a4,a5
	move.b #6,(a4)+		; deja six caracteres
	move.b #"@",(a4)+
	move.l #"FETT",(a4)+
	move.b #"@",(a4)+		; titre en gras
	addq.l #3,a0			; va sur le titre
.copie_titre:
	move.b (a0)+,d0
	cmp.b #'"',d0
	beq.s .ok
	move.b d0,(a4)+
	addq.b #1,(a5)			; taille a jour
	bra.s .copie_titre
.ok:
	clr.b (a4)
	add #256,a2				; autre ligne
	move.l #$FF010000,(a2)
	add #256,a2				; et une autre!
	addq #3,78(a1)			; nombre de lignes a jour
	bra.s .pas_lien
.pas_titre:
	cmp.l #"SPOT",d0		; lien?
	bne.s .pas_lien
.avance:
	cmp.b #'"',(a0)+
	bne.s .avance
	READLONG a0,d0
	cmp.l #"HELP",d0
	beq.s .pas_lien
	cmp.l #"Info",d0
	bne.s .ok2				; la c'est bon!
	cmp.b #":",(a0)		; Info: c'est pas un lien
	beq.s .pas_lien
.ok2:
	subq.l #4,a0			; revient au debut de la chaine
	move.l a2,a4
	st (a4)+
	move.b #1,(a4)+
	move.l a4,a5
	move.b #4,(a4)+		; deja 4 caracteres
	move.b #" ",(a4)+
	move #"  ",(a4)+
	move.b #">",(a4)+
.copie_lien:
	move.b (a0)+,d0
	cmp.b #'"',d0
	beq.s .ok3
	cmp.b #" ",d0		;un espace?
	bne.s .truc
	move.b #"_",d0
.truc:
	move.b d0,(a4)+
	addq.b #1,(a5)
	bra.s .copie_lien
.ok3:
	clr.b (a4)
	add #256,a2			; ligne suivante
	addq #1,78(a1)		; nombre lignes a jour
.pas_lien:
	cmp.l a3,a0
	bpl.s .fin
	cmp.b #13,(a0)+		; cherche la fin de ligne
	bne.s .pas_lien
	addq.l #1,a0			; saute le LF
	bra .lb0				; retour au debut de ligne
.fin:
	rts


remplit_out:
	move.l 4(a1),d2	; premier index
	move.l d2,d0
	subq #1,d0
	muls #75,d0			; decalage par rapport au debut
	add.l d0,a0			; premier element
	move 2(a1),d0		; niveau de reference
	move.l fichier_fin,a3		
.autre:
	cmp.l a3,a0
	bpl.s .fin			; fin de fichier atteinte
	move.b $40(a0),d1
	lsl #8,d1
	move.b $3f(a0),d1	; niveau actuel
	cmp d1,d0
	bgt.s .fin			; niveau inferieur, fin!
	bmi.s .suivant		; niveau superieur, on le passe
	addq #1,78(a1)		; une ligne de plus!!!
	move.l a2,-(sp)	; souvenir
	st (a2)+				; ligne occupee
	move.b #1,(a2)+	; avec du texte
	moveq #63,d1
	move.b d1,(a2)+	; taille
	subq #1,d1
.lb0:
	move.b (a0)+,(a2)+
	dbf d1,.lb0
	sub #63,a0			; retour
	move.l (sp)+,a2
	add #256,a2
	move.l d2,(a4)		; index dans ce fichier	en cas de clic
	addq.l #8,a4
	addq.l #8,a4		; 16 octets par ligne au cas ou
.suivant:
	addq.l #1,d2		; nouvel index
	add #75,a0
	bra.s .autre
.fin:
	clr.b (a2)			; ligne vide
	rts

remplit_qix:
	move.l 4(a1),d2	; premier index
	move.l d2,d0
	subq #1,d0
	muls #36,d0			; decalage par rapport au debut
	add.l d0,a0			; premier element
	sub.l 8(a1),d2
	neg.l d2				; nombre de lignes-1 a traiter!
	move.l fichier_fin,a3		
.autre:
	cmp.l a3,a0
	bpl.s .fin			; fin de fichier atteinte
	addq #1,78(a1)		; une ligne de plus!!!
	move.l a2,-(sp)	; souvenir
	st (a2)+				; ligne occupee
	move.b #1,(a2)+	; avec du texte
	moveq #30,d1
	move.b d1,(a2)+	; taille
	subq #1,d1
.lb0:
	move.b (a0)+,(a2)+
	dbf d1,.lb0
	sub #30,a0			; retour
	move.l (sp)+,a2
	add #256,a2
	move.l 30(a0),(a4)		; index dans LEXART.QIX en cas de clic (INTEL)
	addq.l #8,a4
	addq.l #8,a4		; 16 octets par ligne au cas ou
	add #36,a0
	dbf d2,.autre
.fin:
	clr.b (a2)			; ligne vide
	rts

remplit_azsec:
	move.l 4(a1),d2	; premier index
	move.l d2,d0
	subq #1,d0
	muls #73,d0			; decalage par rapport au debut
	add.l d0,a0			; premier element
	sub.l 8(a1),d2
	neg.l d2				; nombre de lignes-1 a traiter!
	move.l fichier_fin,a3		
.autre:
	cmp.l a3,a0
	bpl.s .fin			; fin de fichier atteinte
	addq #1,78(a1)		; une ligne de plus!!!
	move.l a2,-(sp)	; souvenir
	st (a2)+				; ligne occupee
	move.b #1,(a2)+	; avec du texte
	moveq #63,d1
	move.b d1,(a2)+	; taille
	subq #1,d1
.lb0:
	move.b (a0)+,(a2)+
	dbf d1,.lb0
	sub #63,a0			; retour
	move.l (sp)+,a2
	add #256,a2
	move.l a1,-(sp)
	lea 63(a0),a1
	READLONG a1,d1
	move.l d1,(a4)+		; index dans LEXART.QIX en cas de clic (INTEL)
	READLONG a1,d1			; a1 au bon endroit 67(a0)
	move.l d1,(a4)+		; index dans LEXART.QIX en cas de clic (INTEL)
	move.l (sp)+,a1
	addq.l #8,a4		; 16 octets par ligne au cas ou
	add #73,a0
	dbf d2,.autre
.fin:
	clr.b (a2)			; ligne vide
	rts

remplit_lexart:
	move.l 4(a1),d2	; premier index
	move.l fichier_fin,a3		
.autre:
	cmp.l a3,a0
	bpl.s .fin			; fin de fichier atteinte
	addq #1,78(a1)		; une ligne de plus!!!
	move.l a0,(a4)+	; pointeur
	move.l d2,(a4)+	; et index au cas ou
	addq.l #8,a4		; 16 octets par ligne au cas ou
	move.l a2,-(sp)	; souvenir
	st (a2)+				; ligne occupee
	move.b #1,(a2)+	; avec du texte
	moveq #30,d1
	move.b d1,(a2)+	; taille
	subq #1,d1
.lb0:
	move.b (a0)+,(a2)+
	dbf d1,.lb0
	sub #30,a0			; retour
	move.l (sp)+,a2
	add #256,a2
	addq.l #1,d2		; nouvel index
	add #52,a0
	bra.s .autre
.fin:
	clr.b (a2)			; ligne vide
	rts

remplit_qixmedia:
	move.l 4(a1),d2	; premier index
	move.l d2,d0
	subq #1,d0
	muls #46,d0			; decalage par rapport au debut
	add.l d0,a0			; premier element
	sub.l 8(a1),d2
	neg.l d2				; nombre de lignes-1 a traiter!
	move.l fichier_fin,a3		
.autre:
	cmp.l a3,a0
	bpl.s .fin			; fin de fichier atteinte
	addq #1,78(a1)		; une ligne de plus!!!
	move.l a2,-(sp)	; souvenir
	st (a2)+				; ligne occupee
	move.b #1,(a2)+	; avec du texte
	moveq #40,d1
	move.b d1,(a2)+	; taille
	subq #1,d1
.lb0:
	move.b (a0)+,(a2)+
	dbf d1,.lb0
	sub #40,a0			; retour
	move.l (sp)+,a2
	add #256,a2
	move.l 40(a0),(a4)		; index dans LEXMED.QIX en cas de clic (INTEL)
	addq.l #8,a4
	addq.l #8,a4		; 16 octets par ligne au cas ou
	add #46,a0
	dbf d2,.autre
.fin:
	clr.b (a2)			; ligne vide
	rts

remplit_quizz:
	move 500(a0),10(a1)	; bonne reponse conservee (INTEL)
	move #200,d0		; nombre de caractŠres
	move.l a0,a3		; demarrage
	moveq #1,d1			; lignes inactives
	bsr _formate
	moveq #1,d1
	bsr .titre
	moveq #100,d0
	lea 200(a0),a3
	cmp.b #1,500(a0)
	seq d1
	bsr _formate
	moveq #2,d1
	bsr .titre
	moveq #100,d0
	lea 300(a0),a3
	cmp.b #2,500(a0)
	seq d1
	bsr _formate
	moveq #3,d1
	bsr .titre
	moveq #100,d0
	lea 400(a0),a3
	cmp.b #3,500(a0)
	seq d1
	bsr _formate
	clr.b (a2)			; derniere ligne!!!
	rts
.titre:
	move.b #1,(a4)		; ligne inactive
	move.l #$FF010000,(a2)	; ligne vide
	add #256,a2
	addq #1,78(a1)			; une de plus
	add #16,a4
	cmp.b 500(a0),d1
	seq (a4)				; bonne r‚ponse!
	add.b #'0',d1
	add #16,a4
	addq #1,78(a1)		; ligne en plus
	move.l a2,a3
	lea .tit(pc),a5
	move.b d1,17(a5)
.ligne:
	move.b (a5)+,(a3)+
	bne.s .ligne
	add #256,a2
	rts
.tit: dc.b $ff,1,15,"@FETT@R‚ponse 1",0	
	even	

; a3:debut de chaine, d0:taille avec les espaces
; d1: byte a mettre dans les pointeurs
; a2: lignes, a4:pointeurs, a1:page_ptr

_formate:
	lea 0(a3,d0.w),a5
.coupe:
	cmp.b #32,-(a5)
	beq.s .coupe
	addq.l #1,a5
	move.l a5,d0
	sub.l a3,d0		; taille reelle de la chaine
	move taille+8,d3	; largeur en carateres d'une ligne
.zyva:
	move d3,d2		; taille a prendre
	cmp d2,d0
	bpl.s .ok
	move d0,d2		; sinon, limiter a ce qu'il y a	
.ok:
	lea 1(a3,d2),a5
.cesure:
	cmp.b #32,-(a5)
	bne.s .cesure
	move.l a5,d2
	sub.l a3,d2		; taille
	sub d2,d0		; taille restante
	move.l a2,a5
	st (a5)+			; ligne occupee
	move.b #1,(a5)+	; avec du texte
	move.b d2,(a5)+	; la taille
	subq #1,d2		; pour la boucle
.copy_ligne:
	move.b (a3)+,(a5)+
	dbf d2,.copy_ligne
	add #256,a2		; nouvelle ligne
	addq #1,78(a1)
	move.b d1,(a4)	; flag 'bon' FF ou 'mauvais' 01
	add #16,a4
	tst d0
	bne.s .zyva
	rts
	
					
remplit_article:
	move.l fichier_fin,a3
	move taille+8,d3	; largeur en caracteres
	bra .lb4			; enleve les blancs au debut de ligne
.autre:	
	move.l a0,a5		; souvenir
	moveq #0,d2			; taille lue actuelle
.ca_va:	
	cmp.l a3,a0
	bpl.s .fin
	move.b (a0)+,d0
	cmp.b #13,d0
	bne.s .lb3
	subq.l #1,a0
	bra.s .fin
.lb3:
	addq #1,d2
	cmp d2,d3
	bpl.s .ca_va
.cherche_vide:
	cmp.b #32,-(a0)
	bne.s .cherche_vide
.fin:
	move.l a0,d0
	sub.l a5,d0
	move.l a2,a4		; sauve
	cmp #7,d0
	bmi.s .trop_petit	; pas assez pour >PIP:x
	cmp.b #">",(a5)
	bne.s .trop_petit
	cmp.b #"P",1(a5)
	bne.s .trop_petit
	cmp.b #"I",2(a5)
	bne.s .trop_petit
	cmp.b #"P",3(a5)
	bne.s .trop_petit	; non!
	addq.l #4,sp		; vire le
	bsr ajoute_image
	tst.b err
	beq.s .fin_ligne	; si erreur, la ligne reste une image
	sf err
.trop_petit:	
	st (a2)+
	move.b #1,(a2)+	; ligne de texte
	move.b d0,(a2)+	; taille
	bra.s .lb0
.lb1:
	move.b (a5)+,(a2)+	; copie ligne
.lb0:
	dbf d0,.lb1
	clr.b (a2)			; termine avec un zero!!!
	addq #1,78(a1)		; une ligne de plus
	move.l a4,a2		; recupere
	add #256,a2			; nouvelle ligne
.fin_ligne:
	cmp.l a3,a0
	bpl.s .exit
	move.b (a0)+,d0
	cmp.b #13,d0
	beq.s .les_vides
	cmp.b #33,d0
	bcs.s .fin_ligne
.commun:
	subq.l #1,a0
	bra .autre
.les_vides:
	addq.l #1,a0		; saute le LF
.lb4:
	cmp.l a3,a0
	bpl.s .exit
	move.b (a0)+,d0
	cmp.b #13,d0
	bne.s .lb2
	move.l #$FF010000,(a2)	; ligne vide
	add #256,a2
	addq #1,78(a1)			; une de plus
	bra.s .les_vides		
.lb2:
	cmp.b #33,d0
	bcs.s .lb4				; encore vide!
	bra.s .commun		
.exit: 
	clr.b (a2)
	rts

ajoute_image:
	movem.l d0/d3/a0-a5,-(sp)
	addq.l #5,a5
	bsr bloc_media
	lea buffer,a1
	lea bmp_path,a2
.lb0:
	move.b (a2)+,(a1)+
	bne.s .lb0
	subq.l #1,a1
	lea .nom(pc),a6
	lea 30(a0),a2
	movem.l (a2),d0-d1
	movem.l d0-d1,(a6)
	rept 8
	move.b (a2)+,(a1)+
	endr		; 8 caractŠres
.lb1:
	cmp.b #32,-(a1)
	beq.s .lb1				; revient sur les espaces
	addq.l #1,a1
	move.b #'.',(a1)+
	move.b #'B',(a1)+
	move.b #'M',(a1)+
	move.b #'P',(a1)+
	clr.b (a1)				; nom complet!
	bsr mfree				; libŠre le bloc maintenant.
	lea buffer,a0			; nom
	bsr charge_fichier
	tst.b err
	bne .err_1	
	move.l a0,a5		; pour lib‚rer
	st is_petit
	bsr bmp_vers_vdi
	sf is_petit
	tst.b err
	bne .err_2
	move.l a0,d5		; mfdb
	move.l d1,d4		; l,h
	move.l a5,a0
	bsr mfree				; libere le BMP
	movem.l (sp)+,d0/d3/a0-a5
	move.l d5,a4			; bidouille
	move.l a4,80(a1)		; bloc supplementaire dans page
	move petit+6,d0		; hauteur caractere
	moveq #0,d1				; x,y d'origine
	tst 78(a1)
	bne.s .ajoute_ligne	; pas au debut
	addq #1,78(a1)
	move.l #$FF010000,(a2)	; sinon, ins‚rer une ligne vide
	add #256,a2
.ajoute_ligne:
	move.l a2,a5
	st (a5)+				; ligne de plus
	addq #1,78(a1)		; la aussi
	move.b #2,(a5)+	; du graphique
	move.l a4,(a5)+	; mfdb de l'image
	move.l d1,(a5)+	; x,y
	cmp d0,d4			; assez de points?
	bpl.s .oui
	move d4,d0			; limite si il n'y a pas assez de hauteur	
.oui:
	sub d0,d4			; hauteur diminuee
	swap d4
	move d4,(a5)+		; l
	swap d4
	move d0,(a5)+		; hauteur pour cette ligne	
	add d0,d1			; y suivant
	move.l (a6),(a5)+
	move.l 4(a6),(a5)+	; nom BMP sur 8 caractŠres
	add #256,a2
	tst d4
	bgt.s .ajoute_ligne
	rts
.err_2:
	move.l a5,a0
	bsr mfree				
.err_1:
	movem.l (sp)+,d0/d3/a0-a5
	rts
.nom: dc.b 0,0,0,0,0,0,0,0

; a5 pointe sur le nombre ASCII decimal
; a3 fin de fichier

bloc_media:
	moveq #0,d0
.lb0:
	cmp.l a3,a5
	bpl.s .fin
	moveq #0,d1
	move.b (a5)+,d1
	sub #"0",d1
	bmi.s .fin		; ce n'est plus un chiffre
	cmp #10,d1
	bpl.s .fin		; la non plus!
	muls #10,d0
	add d1,d0		; reconstruit en base 10
	bra.s .lb0
.fin:
_bloc_media:		; si on connait deja l'index dans D0
	subq #1,d0		; index - 1
	moveq #100,d1
	muls d1,d0	; offset dans LEXMED.QIX
	lea off_size,a0
	move #$7f00,(a0)+	; lire sans fermer
	move media_h,(a0)+
	move.l d0,(a0)+	; offset
	move.l d1,(a0)+	; taille
	bsr charge_fichier
	rts				; a0 pointe sur la structure!!

; d0: numero de l'arbre
; d7=WORD numero video aide/WORD numero bouton aide

manage_tree:
	move.l d0,rg_int
	GEM_AES rsrc_gaddr
	move.l tree,a0
	lea taille,a1
	move 4(a1),d0
	sub 20(a0),d0
	lsr d0
	add (a1),d0			; x du dialogue
	swap d0
	move 6(a1),d0
	sub 22(a0),d0
	lsr d0
	add 2(a1),d0		; x,y du dialogue
	move.l d0,16(a0)
	lea od_int,a1
	move.l #7,(a1)+	; 0.w et 7.w
	move.l d0,(a1)+
	move.l 20(a0),(a1)
.recommence:
	GEM_AES objc_draw
	GEM_AES form_do
	move intout,d1
	move d1,d0
	muls #24,d1
	move.l tree,a0
	bclr #0,11(a0,d1.w)	; objet FIN non selected
	cmp d0,d7			; bouton aide???
	bne.s .fin
	move.l d7,d0
	swap d0				; numero de la vid‚o
	bsr aide_video
	bra.s .recommence	
.fin:
	clr fd_int			; no edit object par defaut
	rts

; d0: numero de l'aide (0 … 7)

aide_video:
	cmp.b #'1',rbaid
	bne.s .fin				; aide d‚sactiv‚e
	lea aides,a0
	add d0,d0
	add d0,d0
	move.l 0(a0,d0.w),a0	; adresse video
	bsr joue_video			; (top d‚lire!!!)
	bsr affiche_blanc_page
.fin:
	rts
		
charge_inf:
	lea _name,a0
	move.l a0,a1
.lb0:
	tst.b (a1)+
	bne.s .lb0
	subq.l #1,a1
	move.b #"F",-(a1)
	move.b #"N",-(a1)
	move.b #"I",-(a1)		; remplace RSC par INF
	bsr charge_fichier		; a0: fichier, d0: taille
	tst.b err
	bne .exit
	move.l a0,-(sp)			; pour liberer
	lea 0(a0,d0.l),a1
.parse:
	READLONG a0,d0
	cmp.l #"VID=",d0
	bne.s .lb1
	move.b (a0)+,rbvid
	bra .autre	
.lb1:
	cmp.l #"CD1=",d0
	bne.s .lb2	
	move.b (a0)+,d0
	move.b d0,lecteur
	move.b d0,rbcd1
	move.b d0,rbcd2
	bra .autre
.lb2:
	cmp.l #"AVI=",d0
	bne.s .lb3
	move.b (a0)+,rbavi
	bra .autre
.lb3:
	cmp.l #"CD2=",d0
	bne.s .lb4
	move.b (a0)+,rbcd2
	bra .autre
.lb4:
	cmp.l #"SON=",d0
	bne.s .lb5
	move.b (a0)+,rbson
	bra.s .autre
.lb5:
	cmp.l #"FRE=",d0
	bne.s .lb6
	move.b (a0)+,rbfre
	bra.s .autre
.lb6:
	cmp.l #"32B=",d0
	bne.s .lb7
	move.b (a0)+,rb32
	bra.s .autre
.lb7:
	cmp.l #"24B=",d0
	bne.s .lb8
	move.b (a0)+,rb24
	bra.s .autre
.lb8:
	cmp.l #"16B=",d0
	bne.s .lb9
	move.b (a0)+,rb16
	bra.s .autre
.lb9:	cmp.l #"08B=",d0
	bne.s .lb10
	move.b (a0)+,rb08
	bra.s .autre
.lb10:	cmp.l #"04B=",d0
	bne.s .lb11
	move.b (a0)+,rb04
	bra.s .autre
.lb11:	cmp.l #"TT8=",d0
	bne.s .lb12
	move.b (a0)+,rbtt
	bra.s .autre
.lb12:
	nop
.autre:
	cmp.l a1,a0
	bpl.s .fin
	cmp.b #' ',(a0)+
	bmi.s .autre
	subq.l #1,a0
	bra .parse
.fin:
	move.l (sp)+,a0
	bsr mfree
.exit:
	sf err
	rts	

; d0=1 image, 2 video, 3 son
; buffer contient le nom complet

joue_media:
	cmp #1,d0		; image
	bne .autre
	BUSY
	lea buffer,a0
	bsr charge_fichier
	tst.b err
	bne .err_fle
	move.l a0,-(sp)
	bsr bmp_vers_vdi
	tst.b err
	bne .err_fle_free
	move.l a0,a4	; mfdb
	move.l d1,d4	; l et h
	move.l (sp)+,a0
	bsr mfree		; libere le BMP devenu inutile
	bsr blanc		; vide l'ecran
	FLECHE
	bsr joue_image
	move.l a4,a0
	bsr mfree
	bsr affiche_blanc_page
	rts
.autre:
	cmp #2,d0
	bne .son
	; ici c'est de la video
	lea buffer,a0
	bsr joue_video
	bsr affiche_blanc_page
	rts
.son:
	cmp #3,d0
	bne .fin	
	BUSY
	bsr joue_son
	FLECHE
	rts
.fin:
	rts
.err_fle_free:
	move.l (sp)+,a0
	bsr mfree
.err_fle:
	FLECHE
	sf err
	rts

; a4: pointeur mfdb
; d4=L et H du dessin

joue_image:
	cmp #8,planes
	bne.s .pas_pal
	lea pal_sav,a3
	moveq #0,d0
	move #255,d3
	bsr sauve_palette
.pas_pal:
	bsr fixe_palette
	lea taille,a5
	lea buffer,a3
	move 6(a5),d0	; H
	move d0,d1
	cmp d4,d1
	bmi.s .lb0
	move d4,d1		; min (h,H)
.lb0:
	move d1,14(a3)	; h' hauteur affichee
	sub d4,d0
	move d0,6(a3)	; H-h
	asr d0
	move 2(a5),d1	; yfen
	move d0,2(a3)	; (H-h)/2 = y de depart
	bmi.s .lb2
	add d0,d1		; yfen+y
.lb2:
	move d1,10(a3)	
	swap d4			; l du dessin
	move 4(a5),d0	; L
	move d0,d1
	cmp d4,d1
	bmi.s .lb1
	move d4,d1		; min (l,L)
.lb1:
	move d1,12(a3)	; l' largeur affich‚e
	sub d4,d0
	move d0,4(a3)	; L-l
	asr d0
	move (a5),d1
	move d0,(a3)	; (L-l)/2 = x de depart
	bmi.s .lb4
	add d0,d1		; xfen+x
.lb4:
	move d1,8(a3)
.zyva:
	move.l a4,a0	; mfdb
	moveq #0,d0
	sub (a3),d0
	bpl.s .lb5
	clr d0			
.lb5:
	swap d0
	sub 2(a3),d0
	bpl.s .lb6
	clr d0
.lb6:
	move.l 12(a3),d1	; l' et h'
	move.l 8(a3),d2	; xd,yd
	bsr affiche_image	; enfin!
.clic:
	GEM_AES evnt_button
	tst eb_out
	beq.s .clic
	move.l mx,d0	; mx et my
	movem.l 4(a3),d1-d3	; zone affichee
	sub d2,d0		; my-yd
	bmi.s .fin		; en dehors!
	cmp d3,d0
	bgt.s .fin		; la aussi
	tst d1
	bpl.s .lb7		; pas de d‚calage vertical
	asr d3			; h/2
	sub d3,d0		; vecteur par rapport au centre
	move 2(a3),d3
	sub d0,d3		; nouvel y
	bmi.s .lb8
	clr 2(a3)		; si >0, revenir a zero
	bra.s .lb7
.lb8:
	cmp d1,d3
	bcc.s .lb9
	move d1,d3		; si < H-h, alors revenir a H-h
.lb9:
	move d3,2(a3)
.lb7:
	swap d0
	swap d1
	swap d2
	swap d3			; passage au x
	sub d2,d0		; mx-xd
	bmi.s .fin		; en dehors!
	cmp d3,d0
	bgt.s .fin		; la aussi
	tst d1
	bpl.s .zyva		; pas de d‚calage horizontal
	asr d3			; l/2
	sub d3,d0		; vecteur par rapport au centre
	move (a3),d3
	sub d0,d3		; nouvel x
	bmi.s .lb18
	clr (a3)		; si >0, revenir a zero
	bra .zyva
.lb18:
	cmp d1,d3
	bcc.s .lb19
	move d1,d3		; si < L-l, alors revenir a L-l
.lb19:
	move d3,(a3)
	bra .zyva
.fin:
	bsr restaure_palette
	rts

; a0: palette (i,n-1,rgb VDI)
	
fixe_palette:
	lea pal_vdi,a0
_fixe:
	move (a0)+,d0		; premier index
	subq #1,d0
	move (a0)+,d1		; nombre-1 de couleurs (15 ou 255)
	beq.s .fin			; si 0, pas de palette a fixer!!!
	lea vsc_int,a1
	move d0,(a1)
.bouc:	
	addq #1,(a1)+
	move.l (a0)+,(a1)+
	move (a0)+,(a1)+
	movem.l d0-d2/a0-a2,-(sp)
	GEM_VDI vs_color
	movem.l (sp)+,d0-d2/a0-a2
	subq.l #8,a1
	dbf d1,.bouc
.fin:
	rts

restaure_palette:
	lea pal_vdi+2,a0
	tst (a0)		; nombre nul??
	beq.s .fin	; oui, rien a faire
	clr (a0)		; virer
	lea pal_sav,a0	; si 256 couleurs, la palette precedente
	cmp #8,planes
	beq.s _fixe
	lea pal_gem,a0	; si 16 couleurs, la palette GEM
	bra.s _fixe
.fin:
	rts
	
	
joue_son:
	lea buffer,a4
	cmp.b #"*",(a4)
	bne.s .lb0
	move.b lecteur,(a4)
.lb0:
	clr -(sp)
	move.l a4,-(sp)
	GEMDOS 61,8		; fopen
	move d0,d7		; handle
	bmi .bug
	moveq #44,d4
	move.l a4,-(sp)
	move.l d4,-(sp)
	move d7,-(sp)
	GEMDOS 63,12	; lire header
	cmp.l d0,d4		; 44 octets lus?
	bne.s .fin
	move 22(a4),d6
	ror #8,d6		; stereo ou non
	clr.l (a4)
	clr.l 8(a4)
	clr.l 16(a4)	; efface les 3 adresses de buffers
	move.b rbson,d0
	cmp.b #'D',d0
	bne.s .pas_dma
	bsr joue_dma
	bra.s .libere
.pas_dma:
	cmp.b #'R',d0
	bne.s .pas_replay16
	bsr joue_replay16
	bra.s .libere
.pas_replay16:
	cmp.b #'r',d0
	bne.s .pas_replay8
	bsr joue_replay8
	bra.s .libere
.pas_replay8:
	cmp.b #'P',d0
	bne.s .pas_psound
	bsr joue_psound
	bra.s .libere
.pas_psound:
	cmp.b #'Y',d0
	bne.s .pas_yamaha
	bsr joue_yamaha
	bra.s .libere
.pas_yamaha:
	nop
.libere:
	move.l (a4),a0
	bsr mfree
	move.l 8(a4),a0
	bsr mfree
	move.l 16(a4),a0
	bsr mfree
.fin:
	move d7,-(sp)
	GEMDOS 62,4		; fclose
.bug:
	rts

joue_dma:
	move.l #22056,d5	; taille bloc intermediaire
	cmp #1,d6			; mono?
	beq.s .mono
	asl.l #3,d5			; d5 multiplie par 8
.mono:
	move.l #24813,d4	; taille buffer
	move.l d4,d0
	clr ram_type
	bsr malloc
	tst.b err
	bne.s .fin
	move.l a0,(a4)		; premier buffer
	move.l d4,d0
	clr ram_type
	bsr malloc
	tst.b err
	bne.s .fin
	move.l a0,8(a4)	; idem second bloc
	move.l d5,d0
	bsr malloc
	tst.b err
	bne.s .fin
	move.l a0,16(a4)
	clr.l -(sp)
	GEMDOS 32,6		; superviseur!
	move.l d0,stack
.boucle:
	move.l a4,a3	; les infos 1er buffer
	bsr.s .charge	; charge 1
	tst.b err
	bne.s .fin_son
	lea 8(a4),a3	; les infos du 2eme buffer
	bsr.s .charge
	tst.b err
	beq.s .boucle
.fin_son:		
	move.l stack,-(sp)
	GEMDOS 32,6		; user
.fin:
	sf err
	rts
.charge:
	move.l 16(a4),-(sp)	; buff interm
	move.l d5,-(sp)
	move d7,-(sp)
	GEMDOS 63,12	; lire une seconde
	cmp.l #64,d0
	bpl.s .ok
.gloups:
	clr.b $ffff8901.w
	st err
	rts
.ok:
	move.l (a3),a0	; dest
	move.l 16(a4),a1	; source
	cmp #2,d6
	beq .16bits
	lsr.l #3,d0		; paquets de 8 octets
	subq #1,d0
	moveq #-128,d1
.ajuste:
	rept 8
		move.b (a1)+,d2
		add.b d1,d2
		move.b d2,(a0)+
	endr
	move.b d2,(a0)+
	dbf d0,.ajuste
.commun:
	move.l a0,4(a3)	; adresse fin
	move.l kbshift,a0
.pas_fini:
	btst #2,(a0)		; control??
	bne.s .gloups
	btst #0,$ffff8901.w
	bne.s .pas_fini	; attend la fin du son precedent
	addq.l #1,a3
	move.b (a3)+,$ffff8903.w
	move.b (a3)+,$ffff8905.w
	move.b (a3),$ffff8907.w	; start address
	addq.l #2,a3
	move.b (a3)+,$ffff890f.w
	move.b (a3)+,$ffff8911.w
	move.b (a3),$ffff8913.w	; end address
	move.b #$82,$ffff8921.w	; mono, 25khz
	move.b #1,$ffff8901
	rts
.16bits:
	asr.l #6,d0		; paquets de 64 octets
	subq #1,d0
.aj16b:
	rept 7
	addq.l #7,a1
	move.b (a1)+,(a0)+
	endr
	addq.l #7,a1
	move.b (a1)+,d2
	move.b d2,(a0)+
	move.b d2,(a0)+
	dbf d0,.aj16b
	bra.s .commun		
	
joue_psound:
	lea .table(pc),a6
	bra.s joue_inter
.table: dc.l psound_8_normal,psound_8_reduit,psound_16_normal,psound_16_reduit

joue_replay16:
	lea .table(pc),a6
	bra.s joue_inter
.table: dc.l replay16_8_normal,replay16_8_reduit,replay16_16_normal,replay16_16_reduit

joue_replay8:
	lea .table(pc),a6
	bra.s joue_inter
.table: dc.l replay8_8_normal,replay8_8_reduit,replay8_16_normal,replay8_16_reduit

joue_yamaha:
	lea .table(pc),a6
	bra.s joue_inter
.table: dc.l yamaha_8_normal,yamaha_8_reduit,yamaha_16_normal,yamaha_16_reduit

; a6=table des 4 routines de son de l'appareil voulu
; en 8 bits a 22050 et a 11025
; en 16 bits a 22050 et a 11025

joue_inter:
	move.l #22056,d5	; taille bloc
	cmp #1,d6			; mono?
	beq.s .mono
	asl.l #3,d5			; d5 multiplie par 8
	addq.l #8,a6		; routines 16 bits
.mono:
	moveq #28,d6		; pour la frequence 22050
	cmp.b #'1',rbfre
	beq.s .fre_normale
	addq.l #4,a6	
	moveq #56,d6		; pour le 11025
.fre_normale:
	move.l (a6),a6		; bonne routine
	move.l d5,d0
	bsr malloc			; malloc en TT Ram
	tst.b err
	bne .fin
	move.l a0,(a4)		; premier buffer
	move.l d5,d0
	bsr malloc			; Malloc en TT Ram
	tst.b err
	bne .fin
	move.l a0,8(a4)	; idem second bloc
	clr.l -(sp)
	GEMDOS 32,6		; superviseur!
	move.l d0,stack
	sf yamaha_flag
	cmp.b #'Y',rbson
	bne.s .boucle
	lea $ffff8800.w,a0	; initialisations pour le YAMAHA
	lea 2(a0),a1
	move.b	#0,(a0)
	move.b	#0,(a1)
	move.b	#1,(a0)
	move.b	#0,(a1)
	move.b	#2,(a0)
	move.b	#0,(a1)
	move.b	#3,(a0)
	move.b	#0,(a1)
	move.b	#4,(a0)
	move.b	#0,(a1)
	move.b	#5,(a0)
	move.b	#0,(a1)
	move.b	#7,(a0)
	move.b	#$FF,(a1)
	move.b	#8,(a0)
	move.b	#0,(a1)
	move.b	#9,(a0)
	move.b	#0,(a1)
	move.b	#10,(a0)
	move.b	#0,(a1)
.boucle:
	move.l a4,a3	; les infos 1er buffer
	bsr.s .charge	; charge 1
	tst.b err
	bne.s .fin_son
	lea 8(a4),a3	; les infos du 2eme buffer
	bsr.s .charge
	tst.b err
	beq.s .boucle
.fin_son:		
	move.l stack,-(sp)
	GEMDOS 32,6		; user
.fin:
	sf err
	rts
.charge:
	move.l (a3),-(sp)	; buffer 1 ou 2
	move.l d5,-(sp)
	move d7,-(sp)
	GEMDOS 63,12	; lire une seconde
	cmp.l #64,d0
	bpl.s .ok
	move.l kbshift,a0
.pas_fini2:
	btst #2,(a0)		; control??
	bne.s .gloups
	tst.b yamaha_flag
	bne.s .pas_fini2	; attend la fin du son precedent
.gloups:
	move sr,d0		; stoppe le timer
	move #$2700,sr
	lea $fffffa00.w,a0
	bclr #5,7(a0)
	bclr #5,$b(a0)
	bclr #5,$f(a0)
	bclr #5,$13(a0)
	sf yamaha_flag
	move d0,sr
	st err
	rts
.ok:
	move.l (a3),a0
	add.l d0,a0
	move.l a0,4(a3)	; adresse fin
	move.l kbshift,a0
.pas_fini:
	btst #2,(a0)		; control??
	bne.s .gloups
	tst.b yamaha_flag
	bne.s .pas_fini	; attend la fin du son precedent
	move sr,d0			; lance le timer
	move.w #$2700,sr
	lea $fffffa00.w,a0
	bclr #5,7(a0)
	bclr #5,$13(a0)
	move.b d6,$1f(a0)
	move.b #1,$19(a0)
	move.l a6,$134.w
	move.l (a3),yamaha_ptr
	move.l 4(a3),yamaha_fin
	st yamaha_flag
	bclr #3,$17(a0)
	bset #5,7(a0)
	bset #5,$13(a0)
	move d0,sr
	rts
	
yamaha_ptr: dc.l 0
yamaha_fin: dc.l 0

replay16_8_normal:	
	move.l a0,-(sp)
	move d0,-(sp)
	move.l yamaha_ptr(pc),a0
	cmp.l yamaha_fin(pc),a0
	bpl.s .fin	
	move.b (a0)+,d0
	add.b #$80,d0
	move.l a0,yamaha_ptr
	lsl #8,d0
	move.l #$fffa8000,a0
	move.w 0(a0,d0.w),d0
.exit_int:
	move (sp)+,d0
	move.l (sp)+,a0
	rte
.fin:
	sf yamaha_flag
	bra.s .exit_int

replay16_8_reduit:
	move.l a0,-(sp)
	move d0,-(sp)
	move.l yamaha_ptr(pc),a0
	cmp.l yamaha_fin(pc),a0
	bpl.s .fin	
	move.b (a0),d0
	add.b #$80,d0
	addq.l #2,yamaha_ptr	; un sur deux seulement!!
	lsl #8,d0
	move.l #$fffa8000,a0
	move.w 0(a0,d0.w),d0
.exit_int:
	move (sp)+,d0
	move.l (sp)+,a0
	rte
.fin:
	sf yamaha_flag
	bra.s .exit_int

replay16_16_normal:
	move.l a0,-(sp)
	move d0,-(sp)
	move.l yamaha_ptr(pc),a0
	addq.l #7,a0
	cmp.l yamaha_fin(pc),a0
	bpl.s .fin	
	move.b (a0)+,d0
	move.l a0,yamaha_ptr
	lsl #8,d0
	move.l #$fffa8000,a0
	move.w 0(a0,d0.w),d0
.exit_int:
	move (sp)+,d0
	move.l (sp)+,a0
	rte
.fin:
	sf yamaha_flag
	bra.s .exit_int

replay16_16_reduit:
	move.l a0,-(sp)
	move d0,-(sp)
	move.l yamaha_ptr(pc),a0
	addq.l #7,a0
	addq.l #8,a0
	cmp.l yamaha_fin(pc),a0
	bpl.s .fin
	move.b (a0)+,d0
	move.l a0,yamaha_ptr
	lsl #8,d0
	move.l #$fffa8000,a0
	move.w 0(a0,d0.w),d0
.exit_int:
	move (sp)+,d0
	move.l (sp)+,a0
	rte
.fin:
	sf yamaha_flag
	bra.s .exit_int
	
replay8_8_normal:	
	move.l a0,-(sp)
	move d0,-(sp)
	move.l yamaha_ptr(pc),a0
	clr d0
	cmp.l yamaha_fin(pc),a0
	bpl.s .fin	
	move.b (a0)+,d0
	move.l a0,yamaha_ptr
	add d0,d0
	move.l #$fffa0100,a0
	move.b 0(a0,d0.w),d0
.exit_int:
	move (sp)+,d0
	move.l (sp)+,a0
	rte
.fin:
	sf yamaha_flag
	bra.s .exit_int

replay8_8_reduit:
	move.l a0,-(sp)
	move d0,-(sp)
	move.l yamaha_ptr(pc),a0
	clr d0
	cmp.l yamaha_fin(pc),a0
	bpl.s .fin	
	move.b (a0),d0
	addq.l #2,yamaha_ptr	; un sur deux seulement!!
	add d0,d0
	move.l #$fffa0100,a0
	move.b 0(a0,d0.w),d0
.exit_int:
	move (sp)+,d0
	move.l (sp)+,a0
	rte
.fin:
	sf yamaha_flag
	bra.s .exit_int

replay8_16_normal:
	move.l a0,-(sp)
	move d0,-(sp)
	move.l yamaha_ptr(pc),a0
	addq.l #7,a0
	clr d0
	cmp.l yamaha_fin(pc),a0
	bpl.s .fin	
	move.b (a0)+,d0
	move.l a0,yamaha_ptr
	add d0,d0
	move.l #$fffa0100,a0
	move.b 0(a0,d0.w),d0
.exit_int:
	move (sp)+,d0
	move.l (sp)+,a0
	rte
.fin:
	sf yamaha_flag
	bra.s .exit_int

replay8_16_reduit:
	move.l a0,-(sp)
	move d0,-(sp)
	move.l yamaha_ptr(pc),a0
	addq.l #7,a0
	clr d0
	addq.l #8,a0
	cmp.l yamaha_fin(pc),a0
	bpl.s .fin
	move.b (a0)+,d0
	move.l a0,yamaha_ptr
	add d0,d0
	move.l #$fffa0100,a0
	move.b 0(a0,d0.w),d0
.exit_int:
	move (sp)+,d0
	move.l (sp)+,a0
	rte
.fin:
	sf yamaha_flag
	bra.s .exit_int
	
psound_8_normal:	
	move.l a0,-(sp)
	move.l d0,-(sp)
	move.l yamaha_ptr(pc),a0
	move.l #$07ff0f00,d0
	cmp.l yamaha_fin(pc),a0
	bpl.s .fin	
	move.b (a0)+,d0
	eor.b #$80,d0
	move.l a0,yamaha_ptr
	lea $FFFF8800.w,a0
	movep.l d0,0(a0)
.exit_int:
	move.l (sp)+,d0
	move.l (sp)+,a0
	rte
.fin:
	sf yamaha_flag
	bra.s .exit_int

psound_8_reduit:
	move.l a0,-(sp)
	move.l d0,-(sp)
	move.l yamaha_ptr(pc),a0
	move.l #$07ff0f00,d0
	cmp.l yamaha_fin(pc),a0
	bpl.s .fin	
	move.b (a0),d0
	eor.b #$80,d0
	addq.l #2,yamaha_ptr	; un sur deux seulement!!
	lea $FFFF8800.w,a0
	movep.l d0,0(a0)
.exit_int:
	move.l (sp)+,d0
	move.l (sp)+,a0
	rte
.fin:
	sf yamaha_flag
	bra.s .exit_int

psound_16_normal:
	move.l a0,-(sp)
	move.l d0,-(sp)
	move.l yamaha_ptr(pc),a0
	addq.l #7,a0
	move.l #$07ff0f00,d0
	cmp.l yamaha_fin(pc),a0
	bpl.s .fin	
	move.b (a0)+,d0
	move.l a0,yamaha_ptr
	eor.b #$80,d0
	lea $FFFF8800.w,a0
	movep.l d0,0(a0)
.exit_int:
	move.l (sp)+,d0
	move.l (sp)+,a0
	rte
.fin:
	sf yamaha_flag
	bra.s .exit_int

psound_16_reduit:
	move.l a0,-(sp)
	move.l d0,-(sp)
	move.l yamaha_ptr(pc),a0
	addq.l #7,a0
	addq.l #8,a0
	move.l #$07ff0f00,d0
	cmp.l yamaha_fin(pc),a0
	bpl.s .fin	
	move.b (a0)+,d0
	move.l a0,yamaha_ptr
	eor.b #$80,d0
	lea $FFFF8800.w,a0
	movep.l d0,0(a0)
.exit_int:
	move.l (sp)+,d0
	move.l (sp)+,a0
	rte
.fin:
	sf yamaha_flag
	bra.s .exit_int

yamaha_16_reduit:
	move.l a0,-(sp)
	move.l d0,-(sp)
	move d1,-(sp)
	move.l yamaha_ptr(pc),a0
	addq.l #7,a0
	moveq #0,d0
	addq.l #8,a0
	cmp.l yamaha_fin(pc),a0
	bpl.s _fin_yamaha
	move.b (a0)+,d0
	move.l a0,yamaha_ptr
	bra.s _yamaha_commun
	
yamaha_8_reduit:
	move.l a0,-(sp)
	move.l d0,-(sp)
	move d1,-(sp)
	move.l yamaha_ptr(pc),a0
	move #$80,d0
	cmp.l yamaha_fin(pc),a0
	bpl.s _fin_yamaha
	add.b (a0),d0
	addq.l #2,yamaha_ptr
	bra.s _yamaha_commun

_fin_yamaha:
	sf yamaha_flag
	move (sp)+,d1
	move.l (sp)+,d0
	move.l (sp)+,a0
	rte

yamaha_16_normal:
	move.l a0,-(sp)
	move.l d0,-(sp)
	move d1,-(sp)
	move.l yamaha_ptr(pc),a0
	moveq #0,d0
	addq.l #7,a0
	cmp.l yamaha_fin(pc),a0
	bpl.s _fin_yamaha
	move.b (a0)+,d0
	move.l a0,yamaha_ptr
	bra.s _yamaha_commun

yamaha_8_normal:
	move.l a0,-(sp)
	move.l d0,-(sp)
	move d1,-(sp)
	move.l yamaha_ptr(pc),a0
	move #$80,d0
	cmp.l yamaha_fin(pc),a0
	bpl.s _fin_yamaha
	add.b (a0)+,d0
	move.l a0,yamaha_ptr
	
_yamaha_commun:
	lsl.w #3,d0
	move.w yamaha_data+4(pc,d0.w),d1
	move.l yamaha_data(pc,d0.w),d0
	lea $ffff8800.w,a0
	movep.l d0,0(a0)
	movep.w d1,0(a0)	
	move (sp)+,d1
	move.l (sp)+,d0
	move.l (sp)+,a0
	rte
	
yamaha_data:
	dc.w	$80C,$90B,$a09,0,$80C,$90B,$a09,0
	dc.w	$80D,$908,$a08,0,$80B,$90B,$a0B,0
	dc.w	$80D,$909,$a05,0,$80C,$90B,$a08,0
	dc.w	$80D,$909,$a02,0,$80D,$908,$a06,0
	dc.w	$80C,$90B,$a07,0,$80D,$907,$a07,0
	dc.w	$80C,$90B,$a06,0,$80C,$90A,$a09,0
	dc.w	$80B,$90B,$a0A,0,$80C,$90B,$a02,0
	dc.w	$80C,$90B,$a00,0,$80C,$90A,$a08,0

	dc.w	$80D,$906,$a04,0,$80D,$905,$a05,0
	dc.w	$80D,$905,$a04,0,$80C,$909,$a09,0
	dc.w	$80D,$904,$a03,0,$80B,$90B,$a09,0
	dc.w	$80C,$90A,$a05,0,$80B,$90A,$a0A,0
	dc.w	$80C,$909,$a08,0,$80B,$90B,$a08,0
	dc.w	$80C,$90A,$a00,0,$80C,$90A,$a00,0
	dc.w	$80C,$909,$a07,0,$80B,$90B,$a07,0
	dc.w	$80C,$909,$a06,0,$80B,$90B,$a06,0

	dc.w	$80B,$90A,$a09,0,$80B,$90B,$a05,0
	dc.w	$80A,$90A,$a0A,0,$80B,$90B,$a02,0
	dc.w	$80B,$90A,$a08,0,$80C,$907,$a07,0
	dc.w	$80C,$908,$a04,0,$80C,$907,$a06,0
	dc.w	$80B,$909,$a09,0,$80C,$906,$a06,0
	dc.w	$80A,$90A,$a09,0,$80C,$907,$a03,0
	dc.w	$80B,$90A,$a05,0,$80B,$909,$a08,0
	dc.w	$80B,$90A,$a03,0,$80A,$90A,$a08,0

	dc.w	$80B,$90A,$a00,0,$80B,$909,$a07,0
	dc.w	$80B,$908,$a08,0,$80A,$90A,$a07,0
	dc.w	$80A,$909,$a09,0,$80C,$901,$a01,0
	dc.w	$80A,$90A,$a06,0,$80B,$908,$a07,0
	dc.w	$80A,$90A,$a05,0,$80A,$909,$a08,0
	dc.w	$80A,$90A,$a02,0,$80A,$90A,$a01,0
	dc.w	$80A,$90A,$a00,0,$809,$909,$a09,0
	dc.w	$80A,$908,$a08,0,$80B,$908,$a01,0

	dc.w	$80A,$909,$a06,0,$80B,$907,$a04,0
	dc.w	$80A,$909,$a05,0,$809,$909,$a08,0
	dc.w	$80A,$909,$a03,0,$80A,$908,$a06,0
	dc.w	$80A,$909,$a00,0,$809,$909,$a07,0
	dc.w	$809,$908,$a08,0,$80A,$908,$a04,0
	dc.w	$809,$909,$a06,0,$80A,$908,$a01,0
	dc.w	$809,$909,$a05,0,$809,$908,$a07,0
	dc.w	$808,$908,$a08,0,$809,$909,$a02,0

	dc.w	$809,$908,$a06,0,$809,$909,$a00,0
	dc.w	$809,$907,$a07,0,$808,$908,$a07,0
	dc.w	$809,$907,$a06,0,$809,$908,$a02,0
	dc.w	$808,$908,$a06,0,$809,$906,$a06,0
	dc.w	$808,$907,$a07,0,$808,$908,$a04,0
	dc.w	$808,$907,$a06,0,$808,$908,$a02,0
	dc.w	$807,$907,$a07,0,$808,$906,$a06,0
	dc.w	$808,$907,$a04,0,$807,$907,$a06,0

	dc.w	$808,$906,$a05,0,$808,$906,$a04,0
	dc.w	$807,$906,$a06,0,$807,$907,$a04,0
	dc.w	$808,$905,$a04,0,$806,$906,$a06,0
	dc.w	$807,$906,$a04,0,$807,$905,$a05,0
	dc.w	$806,$906,$a05,0,$806,$906,$a04,0
	dc.w	$806,$905,$a05,0,$806,$906,$a02,0
	dc.w	$806,$905,$a04,0,$805,$905,$a05,0
	dc.w	$806,$905,$a02,0,$805,$905,$a04,0

	dc.w	$805,$904,$a04,0,$805,$905,$a02,0
	dc.w	$804,$904,$a04,0,$804,$904,$a03,0
	dc.w	$804,$904,$a02,0,$804,$903,$a03,0
	dc.w	$803,$903,$a03,0,$803,$903,$a02,0
	dc.w	$803,$902,$a02,0,$802,$902,$a02,0
	dc.w	$802,$902,$a01,0,$801,$901,$a01,0
	dc.w	$802,$901,$a00,0,$801,$901,$a00,0
	dc.w	$801,$900,$a00,0,$800,$900,$a00,0

	dc.w	$80E,$90D,$a0C,0,$80F,$903,$a00,0
	dc.w	$80F,$903,$a00,0,$80F,$903,$a00,0
	dc.w	$80F,$903,$a00,0,$80F,$903,$a00,0
	dc.w	$80F,$903,$a00,0,$80E,$90D,$a0B,0
	dc.w	$80E,$90D,$a0B,0,$80E,$90D,$a0B,0
	dc.w	$80E,$90D,$a0B,0,$80E,$90D,$a0B,0
	dc.w	$80E,$90D,$a0B,0,$80E,$90D,$a0B,0
	dc.w	$80E,$90D,$a0A,0,$80E,$90D,$a0A,0

	dc.w	$80E,$90D,$a0A,0,$80E,$90D,$a0A,0
	dc.w	$80E,$90C,$a0C,0,$80E,$90D,$a00,0
	dc.w	$80D,$90D,$a0D,0,$80D,$90D,$a0D,0
	dc.w	$80D,$90D,$a0D,0,$80D,$90D,$a0D,0
	dc.w	$80D,$90D,$a0D,0,$80D,$90D,$a0D,0
	dc.w	$80E,$90C,$a0B,0,$80E,$90C,$a0B,0
	dc.w	$80E,$90C,$a0B,0,$80E,$90C,$a0B,0
	dc.w	$80E,$90C,$a0B,0,$80E,$90C,$a0B,0

	dc.w	$80E,$90C,$a0B,0,$80E,$90C,$a0B,0
	dc.w	$80E,$90C,$a0A,0,$80E,$90C,$a0A,0
	dc.w	$80E,$90C,$a0A,0,$80E,$90C,$a0A,0
	dc.w	$80D,$90D,$a0C,0,$80D,$90D,$a0C,0
	dc.w	$80E,$90C,$a09,0,$80E,$90C,$a09,0
	dc.w	$80E,$90C,$a05,0,$80E,$90C,$a00,0
	dc.w	$80E,$90C,$a00,0,$80E,$90B,$a0B,0
	dc.w	$80E,$90B,$a0B,0,$80E,$90B,$a0B,0

	dc.w	$80E,$90B,$a0B,0,$80E,$90B,$a0A,0
	dc.w	$80E,$90B,$a0A,0,$80E,$90B,$a0A,0
	dc.w	$80D,$90D,$a0B,0,$80D,$90D,$a0B,0
	dc.w	$80D,$90D,$a0B,0,$80E,$90B,$a09,0
	dc.w	$80E,$90B,$a09,0,$80E,$90B,$a09,0
	dc.w	$80D,$90C,$a0C,0,$80D,$90D,$a0A,0
	dc.w	$80E,$90B,$a07,0,$80E,$90B,$a00,0
	dc.w	$80E,$90B,$a00,0,$80D,$90D,$a09,0

	dc.w	$80D,$90D,$a09,0,$80E,$90A,$a09,0
	dc.w	$80D,$90D,$a08,0,$80D,$90D,$a07,0
	dc.w	$80D,$90D,$a04,0,$80D,$90D,$a00,0
	dc.w	$80E,$90A,$a04,0,$80E,$909,$a09,0
	dc.w	$80E,$909,$a09,0,$80D,$90C,$a0B,0
	dc.w	$80E,$909,$a08,0,$80E,$909,$a08,0
	dc.w	$80E,$909,$a07,0,$80E,$908,$a08,0
	dc.w	$80E,$909,$a01,0,$80C,$90C,$a0C,0

	dc.w	$80D,$90C,$a0A,0,$80E,$908,$a06,0
	dc.w	$80E,$907,$a07,0,$80E,$908,$a00,0
	dc.w	$80E,$907,$a05,0,$80E,$906,$a06,0
	dc.w	$80D,$90C,$a09,0,$80E,$905,$a05,0
	dc.w	$80E,$904,$a04,0,$80D,$90C,$a08,0
	dc.w	$80D,$90B,$a0B,0,$80E,$900,$a00,0
	dc.w	$80D,$90C,$a06,0,$80D,$90C,$a05,0
	dc.w	$80D,$90C,$a02,0,$80C,$90C,$a0B,0

	dc.w	$80C,$90C,$a0B,0,$80D,$90B,$a0A,0
	dc.w	$80D,$90B,$a0A,0,$80D,$90B,$a0A,0
	dc.w	$80D,$90B,$a0A,0,$80C,$90C,$a0A,0
	dc.w	$80C,$90C,$a0A,0,$80C,$90C,$a0A,0
	dc.w	$80D,$90B,$a09,0,$80D,$90B,$a09,0
	dc.w	$80D,$90A,$a0A,0,$80D,$90A,$a0A,0
	dc.w	$80D,$90A,$a0A,0,$80C,$90C,$a09,0
	dc.w	$80C,$90C,$a09,0,$80C,$90C,$a09,0

	dc.w	$80D,$90B,$a06,0,$80C,$90B,$a0B,0
	dc.w	$80C,$90C,$a08,0,$80D,$90B,$a00,0
	dc.w	$80D,$90B,$a00,0,$80C,$90C,$a07,0
	dc.w	$80C,$90C,$a06,0,$80C,$90C,$a05,0
	dc.w	$80C,$90C,$a03,0,$80C,$90C,$a01,0
	dc.w	$80C,$90B,$a0A,0,$80D,$90A,$a05,0
	dc.w	$80D,$90A,$a04,0,$80D,$90A,$a02,0
	dc.w	$80D,$909,$a08,0,$80D,$909,$a08,0

; si off_size=FF ouvre fichier (a0) et utilise f_offset et f_size et ferme
; si off_size=7F fichier f_handle et f_offset et f_size laisse ouvert
; si off_size=00 ouvre fichier (a0) et charge tout et ferme

charge_fichier:
	move.b off_size,d5
	bgt.s .deja_ouvert
	cmp.b #'*',(a0)
	bne.s .lb0
	move.b lecteur,(a0)
.lb0:
	move.l a0,a3
	clr -(sp)
	move.l a0,-(sp)
	pea dta
	GEMDOS 26,6
	GEMDOS 78,8
	beq .arg
.deja_ouvert:
	move.l dta+26,d4	; taille
	tst.b d5
	beq.s .tout
	move.l f_size,d4
.tout:
	move.l d4,d0
	bsr malloc
	tst.b err
	bne.s .arg2
	exg.l a0,a3
	tst.b d5
	bls.s .ouvre
	move f_handle,d3
	bra.s .ouvert
.ouvre:
	clr -(sp)
	move.l a0,-(sp)
	GEMDOS 61,8
	move d0,d3
	bmi.s .arg
.ouvert:
	tst.b d5
	beq.s .pas_off
	clr -(sp)
	move d3,-(sp)
	move.l f_offset,-(sp)
	GEMDOS 66,10	; fseek	
.pas_off:
	move.l a3,-(sp)
	move.l d4,-(sp)
	move d3,-(sp)
	GEMDOS 63,12
	tst.l d0
	bmi.s .arg
	tst.b d5
	bgt.s .laisse_ouvert	
	move d3,-(sp)
	GEMDOS 62,4
.laisse_ouvert:
	sf off_size
	move.l a3,a0
	move.l d4,d0
	rts
.arg:
	st err
	lea bug_fichier,a0
	bsr alert
.arg2:		; erreur malloc
	sf off_size
	moveq #-1,d0
	rts

init_fenetre:
	move screenw,d0
	sub #32,d0
	and #$FFF0,d0	; largeur fenetre
	move screenh,d1
	sub #54+16,d1
	and #$FFF0,d1	; hauteur fenetre
	lea taille,a0
	move #16,(a0)+
	move #62,(a0)+	; x,y fenetre globale
	move d0,(a0)+
	move d1,(a0)+	; l,h fenetre totale
	ext.l d0
	move.l d0,-(sp)
	lea petit,a1
	divs 4(a1),d0	; largeur en caracteres normaux
	move d0,(a0)+	; largeur en caract
	sub 6(a1),d1	; ligne petit menu
	sub 6+BIG-SMA(a1),d1	; ligne titre
	ext.l d1
	divs 6(a1),d1
	move d1,(a0)+	; hauteur en caract
	move.l (sp)+,d0
	divs 4+BIG-SMA(a1),d0	; largeur en GRAND
	move d0,(a0)+
	rts
	
couleur_cadre: dc.w 15	; normalement, violet, sinon NOIR
zone_travail:
	moveq #0,d0
	move.l screenw,d1
	move couleur_cadre(pc),d2	
	bsr rectangle
	bsr barre
	bsr blanc
	rts

blanc:
	lea taille,a0
	move.l (a0)+,d0
	move.l (a0),d1
	moveq #0,d2
	; a suivre!
rectangle:
	lea vrec_int,a0
	move.l d0,(a0)+
	sub.l #$10001,d1
	add.l d0,d1
	move.l d1,(a0)
	move d2,vc_int
	GEM_VDI vsf_interior
	GEM_VDI vsf_color
	GEM_VDI hide_mouse
	GEM_VDI vr_recfl
	GEM_VDI show_mouse
	rts

init_barre:
	lea barre_mono,a1
	cmp #1,planes
	beq.s .barre_mono
	lea barre_coul+$76,a0
	lea .mini_table(pc),a2
	moveq #0,d0
	moveq #0,d1
.lb0:
	move.b (a0),d0
	move d0,d1
	lsr #4,d0
	and #$F,d1
	move.b 0(a2,d0.w),d2
	move.b 0(a2,d1.w),d0
	lsl #4,d2
	add.b d0,d2
	move.b d2,(a0)+
	cmp.l a0,a1
	bne.s .lb0
	rts
.mini_table:
	dc.b 15,12,4,8,7,0,0,0,0,0,0,0,0,0,0,0
.barre_mono:
	lea 62(a1),a0		; donnees
	move.l a0,(a1)+	; prepare le MFBD
	move #640,(a1)+
	move #55,(a1)+
	move #40,(a1)+
	moveq #1,d0
	move.l d0,(a1)+
	clr (a1)+
	clr.l (a1)+			
	lea 4320(a0),a1	; derniŠre ligne
	moveq #26,d0		; (26+1) * 2= 54 lignes a echanger
.lb2:
	moveq #19,d1		; 640 pixels = 20*32bits
.lb3:
	move.l (a0),d2
	move.l (a1),(a0)+
	move.l d2,(a1)+	; echange deux lignes!
	dbf d1,.lb3
	sub #160,a1			;2 lignes en arriere
	dbf d0,.lb2
	lea vcp_cont,a0
	moveq #1,d0
	move #121,(a0)		; vro_cpyfm en vrt_cpyfm
	move #3,6(a0)		; 3 elements dans intin
	move d0,vcp_int	; mode 1=replace
	move #2,vi_int		; mode 2: fond tram‚ au lieu de fond plein
	move d0,couleur_cadre
	move d0,titre_couleur
	GEM_VDI vsl_color	; ligne noire finalement...
	rts
	
barre:
	cmp #1,planes
	bne.s .couleur
	lea barre_mono,a0
	moveq #0,d0
	move.l #$02800037,d1
	moveq #0,d2
	bsr affiche_image
	bra.s .fin
.couleur:
	lea barre_coul,a0
	st is_bar
	bsr bmp_vers_vdi	; renvoit a0:mfdb, d1=l,h
	sf is_bar
	tst.b err
	bne.s .fin
	move.l a0,-(sp)	; pour liberer le bloc
	moveq.l #0,d0		; x,y=0 source
	moveq.l #0,d2		; x,y=0 dest
	bsr affiche_image
	move.l (sp)+,a0
	bsr mfree
.fin:
	sf err
	rts		

; a0: adresse fichier BMP
; renvoit: a0: adresse MFDB+image
;				d1: l,h image

bmp_vers_vdi:
	move.l 10(a0),d0
	INTEL d0
	lea.l 0(a0,d0.l),a3 ; donnees image
	move.l 14(a0),d0
	INTEL d0
	lea 14(a0,d0.l),a4 ; palette
	move 18(a0),d3
	ror #8,d3			; largeur
	move 22(a0),d4
	ror #8,d4			; hauteur
	move d4,d7
	moveq #15,d5
	add d3,d5
	and #$FFF0,d5		; largeur alignee sur 16 pixels
	move 28(a0),d0		; plans image
	move 30(a0),d1		; compression
	ror #8,d1
	move d1,comp_bmp
	ror #8,d0
	cmp #4,d0
	bne _bvv1
	; ici, image 16 couleurs
	moveq #15,d0		; nombre couleurs
	bsr traite_palette
	move d5,d0
	muls d4,d0			; taille image en pixels
	move planes,d1
	cmp #16,d1
	bne.s .a1
	bsr bmp4_to_16
.terminus:
	move d3,d1
	swap d1
	move d4,d1
	rts
.a1:
	cmp #8,d1
	bne.s .a2
	bsr bmp4_to_8
	cmp.b #'2',rb08
	bne.s .terminus
	bsr vers_8_plans
	bra.s .terminus
.a2:
	cmp #4,d1
	bne.s .a3
	bsr bmp4_to_4
	bra.s .terminus
.a3:
	cmp #1,d1
	bne.s .a4
	bsr bmp4_to_1
	bra.s .terminus
.a4:
	cmp #24,d1
	bne.s .a5
.atc:
	bsr bmp4_to_tc	; 24 ou 32
	bra.s .terminus
.a5:
	cmp #32,d1	
	beq.s .atc
	rts
_bvv1:
	cmp #8,d0
	bne _bvv2
	; ici, image 256 couleurs
	move #255,d0
	bsr traite_palette
	move d5,d0
	muls d4,d0			; taille image en pixels
	move planes,d1
	cmp #16,d1
	bne.s .a1
	bsr bmp8_to_16
.terminus:
	move d3,d1
	swap d1
	move d4,d1
	rts
.a1:
	cmp #8,d1
	bne.s .a2
	bsr bmp8_to_8
	cmp.b #'2',rb08
	bne.s .terminus
	bsr vers_8_plans
	bra.s .terminus
	rts
.a2:
	cmp #4,d1
	bne.s .a3
	cmp.b #'1',rbtt
	bne.s .niveaux_gris
	bsr bmp8_to_4_dith
	bra.s .terminus
.niveaux_gris:
	bsr bmp8_to_4
	bra.s .terminus
.a3:	
	cmp #1,d1
	bne.s .a4
	bsr bmp8_to_1
	bra.s .terminus
.a4:
	cmp #24,d1
	bne.s .a5
.atc:
	bsr bmp8_to_tc		; 24 ou 32 bits
	bra.s .terminus
.a5:
	cmp #32,d1
	beq.s .atc
	rts
	; ici c'est dur...
_bvv2:
	rts
	
; a0:mfdb de l'image

vers_8_plans:
	if REG=1
	movem.l d0-d7/a1,-(sp)
	move.l (a0),a1		; les donnees
	move 8(a0),d6		; paquets de 16 points par ligne
	muls 6(a0),d6		; idem mais pour toute l'image
	bra .loop
.points16:
	movem.l (a1),d1-d4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	splice d2,d4,d0,d7,8
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	swap d2
	swap d4
	eor d1,d2
	eor d3,d4
	eor d2,d1
	eor d4,d3
	eor d1,d2
	eor d3,d4
	swap d2
	swap d4
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move d4,(a1)+
	swap d4
	move d2,(a1)+
	swap d2
	move d3,(a1)+
	swap d3
	move d1,(a1)+
	swap d1
	move d4,(a1)+
	move d2,(a1)+
	move d3,(a1)+
	move d1,(a1)+
.loop:
	dbf d6,.points16
	movem.l (sp)+,d0-d7/a1
	endif
	rts		
	
vers_4_plans:
	movem.l d0-d7/a3-a6,-(sp)
	lea line_buffer,a2
	move 8(a0),d5		; paquets de 16
	cmp #1,planes
	beq floyd_dither	; en fait on est en monochrome!!!
	
	if REG=1	

	cmp.b #'1',rb04
	bne atari_4_plans
	move.l a1,a3
	lea 0(a3,d6.l),a4
	lea 0(a4,d6.l),a5
	lea 0(a5,d6.l),a6
	bra .fin_doug
.doug_16:
	movem.l (a2)+,d1-d4
	move.l #$00ff00ff,d0
	spl16.l d1,d3,8
	spl16.l d2,d4,8
	lsr.l #4,d2
	lsr.l #4,d4
	or.l d2,d1
	or.l d4,d3
	move d1,d2
	move d3,d4
	swap d1
	swap d3
	move #$3333,d0
	spl16.w d1,d2,2
	spl16.w d3,d4,2
	move #$5555,d0
	spl16.w d1,d3,1
	spl16.w d2,d4,1
	move d4,(a6)+
	move d2,(a5)+
	move d3,(a4)+
	move d1,(a3)+
.fin_doug:
	dbf d5,.doug_16
	movem.l (sp)+,d0-d7/a3-a6
	rts		
atari_4_plans:
	move.l a1,a3
	cmp.b #'2',rb04
	bne matrix_packed_bits
	bra .fin_doug
.doug_16:
	movem.l (a2)+,d1-d4
	move.l #$00ff00ff,d0
	spl16.l d1,d3,8
	spl16.l d2,d4,8
	lsr.l #4,d2
	lsr.l #4,d4
	or.l d2,d1
	or.l d4,d3
	move d1,d2
	move d3,d4
	swap d1
	swap d3
	move #$3333,d0
	spl16.w d1,d2,2
	spl16.w d3,d4,2
	move #$5555,d0
	spl16.w d1,d3,1
	spl16.w d2,d4,1
	move d4,(a3)+
	move d2,(a3)+
	move d3,(a3)+
	move d1,(a3)+
.fin_doug:
	dbf d5,.doug_16
	movem.l (sp)+,d0-d7/a3-a6
	rts		
matrix_packed_bits:
	bra.s .fin_matrix
.loop:
	rept 4
	move.l (a2)+,d0
	lsr.l #4,d0
	swap d0
	lsl.b #4,d0
	lsr #4,d0
	move.b d0,(a3)+
	swap d0
	lsl.b #4,d0
	lsr #4,d0
	move.b d0,(a3)+
	endr
.fin_matrix:
	dbf d5,.loop
	
	endif

	movem.l (sp)+,d0-d7/a3-a6
	rts		
floyd_dither:
	lea line_err1+1,a4
	lea line_err2+1,a5
	move.l a1,a3
	btst #0,d7			; selon la parite de la ligne
	beq.s .paire
	exg.l a4,a5
.paire:
	clr.b (a5)
	moveq #0,d7			; erreur courante
	bra.s .fin_boucle
.bloc:
	moveq #15,d6		; 16 pixels
.points16:	
	move d7,d0			; erreur courante
	add.b (a2)+,d0		; le pixel
	add.b (a4)+,d0		; plus l'erreur precedente=luminosite actuelle
	bclr d6,d4			; un bit noir par defaut!
	moveq #15,d7		; pour l'arrondi positif
	cmp.b #32,d0
	bmi.s .noir
	bset d6,d4			; en fait, il est blanc
	sub.b #63,d0		; l'erreur est donc negative
	moveq #-15,d7		; arrondi negatif
.noir:
	ext.w d0
	exg.l d0,d7
	move d7,d1
	asl d1
	move d1,d2
	asl d2
	move d7,d3
	add d0,d3
	asr #4,d3
	move.b d3,1(a5)	; erreur 1/16
	move d7,d3
	add d1,d3
	add d0,d3
	asr #4,d3
	add.b d3,-1(a5)	; erreur 3/16
	move d7,d3
	add d2,d3
	add d0,d3
	asr #4,d3
	add.b d3,(a5)+		; erreur 5/16
	add d1,d7
	add d2,d7
	add d0,d7
	asr #4,d7			; erreur courante 7/16
	dbf d6,.points16
	move d4,(a3)+		; les 16 pixels	
.fin_boucle:
	dbf d5,.bloc
	movem.l (sp)+,d0-d7/a3-a6
	rts

traite_palette:
	lea palette,a0
	move planes,d1
	
	if REG=1

	move.b rb24,d2
	cmp #24,d1
	beq.s .tc24_32
	move.b rb32,d2
	cmp #32,d1
	bne.s .pas_tc
.tc24_32:
	btst #0,d2
	bne.s .rvb_tc		; ordre motorola pour les modes 1-24 ou 1-32 et 3-32
.bvr_tc:
	move.b (a4)+,(a0)+
	move.b (a4)+,(a0)+
	move.b (a4)+,(a0)+
	move.b (a4)+,(a0)+	; copie telle quelle la palette
	dbf d0,.bvr_tc
	lea palette,a4
	rts	
.rvb_tc:
	move.b 2(a4),(a0)+
	move.b 1(a4),(a0)+
	move.b (a4),(a0)+		; copie en inversant
	addq.l #4,a4
	addq.l #1,a0
	dbf d0,.rvb_tc
	lea palette,a4
	rts	
.pas_tc:	
	cmp #16,d1
	bne _palette_8
	move.b rb16,d2
	cmp.b #'3',d2
	bmi.s .lb0			; 15 bits!
.lb2:
	move.b 2(a4),d1
	lsl.w #5,d1
	move.b 1(a4),d1
	lsl.l #6,d1
	move.b (a4),d1
	lsr.l #3,d1
	addq.l #4,a4
	cmp.b #'3',d2	; 3=motorola, pas de swap
	beq.s .lb3
	ror #8,d1
.lb3:
	move d1,(a0)+
	dbf d0,.lb2
	lea palette,a4
	rts	
.lb0:
	move.b 2(a4),d1
	lsl.w #5,d1
	move.b 1(a4),d1
	lsl.l #5,d1
	move.b (a4),d1
	lsr.l #3,d1
	addq.l #4,a4
	cmp.b #'2',d2		; 2=format motorola, pas de swap
	beq.s .lb1
	ror #8,d1
.lb1:
	move d1,(a0)+
	dbf d0,.lb0
	lea palette,a4
	rts
_palette_8:
	cmp #8,d1
	bne _palette_4
	cmp #15,d0		; image 16 couleurs?
	bne.s .pal_256
	tst.b is_bar
	bne.s .sort
	lea vsc_int,a0
	move d0,(a0)	
	if LEO=1
		addq #1,(a0)	; le 17 VDI donne le 16 (au lieu du 16->16)
	endif
.pal16:
	addq #1,(a0)+	; index
	moveq #0,d1
	move.b 2(a4),d1
	lsl #2,d1
	move d1,(a0)+
	moveq #0,d1
	move.b 1(a4),d1
	lsl #2,d1
	move d1,(a0)+
	moveq #0,d1
	move.b (a4),d1
	lsl #2,d1
	move d1,(a0)+
	movem.l d0-d2/a0-a2,-(sp)
	GEM_VDI vs_color
	movem.l (sp)+,d0-d2/a0-a2
	addq.l #4,a4
	subq.l #8,a0
	dbf d0,.pal16
	lea palette,a4
.sort:
	rts		
.pal_256:	
	tst.b is_petit
	beq.s .pal8
.palgris:
	swap d0
	clr d0
	moveq #0,d1
	move.b 1(a4),d1
	add d1,d1
	move.b 2(a4),d0
	add d0,d1
	move d1,d0
	add d1,d1
	add d0,d1
	clr d0
	move.b (a4),d0
	add d0,d1
	divs #40,d1			; 64 niveaux de gris
	swap d0
	add #32,d1			; LEO: changer index depart!! de 32 … 95
	addq.l #4,a4
	move.b d1,(a0)+	; palette contient en fait les indexs de gris
	dbf d0,.palgris
	lea palette,a4
	lea vsc_int,a0
	moveq #63,d0		; niveau de gris
	moveq #0,d1
	moveq #16,d2
	move #31,(a0)
	if LEO=1
		addq #1,(a0)	; le 33 vdi donne le 32 xbios (au lieu de 32->32)
	endif
.pgris:
	addq #1,(a0)+
	move d1,(a0)+
	move d1,(a0)+
	move d1,(a0)+
	add d2,d1
	movem.l d0-d2/a0-a2,-(sp)
	GEM_VDI vs_color
	movem.l (sp)+,d0-d2/a0-a2
	subq.l #8,a0
	dbf d0,.pgris
	lea palette,a4
	rts
.pal8:
	move.l #$00FF0102,(a0)+	; LEO changer indexs!!!!
	move.l #$04060305,(a0)+
	move.l #$0708090a,(a0)+
	move.l #$0c0e0b0d,(a0)+
	if LEO=1
		moveq #15,d1
		move #239,d0
	else
		moveq #16,d1
		move #238,d0
	endif
.index:
	move.b d1,(a0)+
	addq #1,d1
	dbf d0,.index
	if LEO=0
		move.b #15,(a0)+		; contruit la table VDI vers XBIOS
	endif
	lea pal_vdi,a0
	clr (a0)+				; index debut = 0
	move #255,d0
	move d0,(a0)+			; n-1 couleurs
.pcoul:
	moveq #0,d1
	move.b 2(a4),d1
	lsl #2,d1
	cmp #1000,d1
	bmi.s .x1
	move #1000,d1
.x1:
	move d1,(a0)+
	moveq #0,d1
	move.b 1(a4),d1
	lsl #2,d1
	cmp #1000,d1
	bmi.s .x2
	move #1000,d1
.x2:
	move d1,(a0)+
	moveq #0,d1
	move.b (a4),d1
	lsl #2,d1
	cmp #1000,d1
	bmi.s .x3
	move #1000,d1
.x3:
	move d1,(a0)+
	addq.l #4,a4
	dbf d0,.pcoul
	lea palette,a4
	rts
_palette_4:
	cmp #4,d1
	bne _palette_1
	cmp #15,d0		; image 16 couleurs?
	bne.s .pal_256
	tst.b is_bar
	bne.s .ident
	tst.b is_petit
	bne.s .palgris
	move.l a4,-(sp)
	lea .index16(pc),a4
	move.l (a4)+,(a0)+
	move.l (a4)+,(a0)+
	move.l (a4)+,(a0)+
	move.l (a4)+,(a0)+	; conversion standard
	move.l (sp)+,a4
	lea pal_vdi,a0
	clr (a0)+
	move d0,(a0)+			; 16 couleurs!
.pal16c:
	moveq #0,d1
	move.b 2(a4),d1
	lsl #2,d1
	move d1,(a0)+	; r
	moveq #0,d1
	move.b 1(a4),d1
	lsl #2,d1
	move d1,(a0)+	; v
	moveq #0,d1
	move.b (a4),d1
	lsl #2,d1
	move d1,(a0)+	; b
	addq.l #4,a4
	dbf d0,.pal16c
	lea palette,a4
	rts
.ident:
	move.l #$00102030,(a0)+	; pour la barre, palette identique!!!
	move.l #$40506070,(a0)+
	move.l #$8090a0b0,(a0)+
	move.l #$c0d0e0f0,(a0)
	lea palette,a4
	rts		
.pal_256:
	cmp.b #'1',rbtt			; tramage couleur?
	beq .dith8					; ben oui, palette en 0-63
	tst.b is_petit
	beq.s .pal16g
.palgris:
	swap d0
	clr d0
	moveq #0,d1
	move.b 1(a4),d1
	add d1,d1
	move.b 2(a4),d0
	add d0,d1
	move d1,d0
	add d1,d1
	add d0,d1
	clr d0
	move.b (a4),d0
	add d0,d1
	divs #638,d1			; 4 niveaux de gris
	swap d0
	addq.l #4,a4
	move.b .index4(pc,d1),(a0)+
	dbf d0,.palgris
	lea palette,a4
	rts
.index4: dc.b $f0,$80,$70,0
.index16: dc.b $00,$f0,$10,$20,$40,$60,$30,$50,$70,$80,$90,$a0,$c0,$e0,$b0,$d0
.pal16g:
	swap d0
	clr d0
	moveq #0,d1
	move.b 1(a4),d1
	add d1,d1
	move.b 2(a4),d0
	add d0,d1
	move d1,d0
	add d1,d1
	add d0,d1
	clr d0
	move.b (a4),d0
	add d0,d1
	divs #160,d1			; 16 niveaux de gris
	swap d0
	addq.l #4,a4
	move.b .index16(pc,d1),(a0)+
	dbf d0,.pal16g
	lea pal_vdi,a0
	clr (a0)+				; index debut = 0
	moveq #15,d0
	move d0,(a0)+			; n-1 couleurs
	moveq #0,d1
.pcoul:
	move d1,(a0)+
	move d1,(a0)+
	move d1,(a0)+			; gris
	add #67,d1				; gris suivant
	dbf d0,.pcoul
	lea palette,a4
	rts
.dith8:						; pour le dithering 8, niveaux de 0 a 63
	move.l (a4)+,d1
	INTEL d1
	and.l #$FCFCFC,d1		; 6 bits conserves
	lsl.l #6,d1				; rrvvbb00
	move.l d1,(a0)+
	dbf d0,.dith8
	lea palette,a4
	rts
	
	
	endif
	
_palette_1:
;	cmp #1,d1
;	bne.s _palette_24
.palgris:
	swap d0
	clr d0
	moveq #0,d1
	move.b 1(a4),d1
	add d1,d1
	move.b 2(a4),d0
	add d0,d1
	move d1,d0
	add d1,d1
	add d0,d1
	clr d0
	move.b (a4),d0
	add d0,d1
	divs #40,d1			; 64 niveaux de gris
	swap d0
	addq.l #4,a4
	move.b d1,(a0)+	; palette contient la luminosite d'un point (0-63)
	dbf d0,.palgris
	lea palette,a4	
	rts


bmp4_to_16:
	
	if REG=1
	
	add.l d0,d0
	add.l #20,d0		; + MFDB
	move.l d0,d6
	bsr malloc
	tst.b err
	beq.s .ok
	rts
.ok:
	lea 20(a0),a1		; donnees
	move.l a1,(a0)+
	lea -4(a0,d6.l),a1	; fin des donn‚es
	move d5,(a0)+
	move d4,(a0)+
	move d5,d0
	lsr #4,d0
	move d0,(a0)+
	moveq #16,d0
	move.l d0,(a0)+
	clr (a0)+
	clr.l (a0)
	lea -16(a0),a0
	moveq #0,d0
	moveq #0,d1
	neg d5
	add d5,d5
	add d5,a1			; derniere ligne
	move.l a1,a2
	cmp #2,comp_bmp	; compress‚?
	beq.s bmp4_to_16_comp	
	move d3,d0
	swap d3
	addq #7,d0
	and #$fff8,d0
	move d0,d3
	bra.s .fin_ligne
.ligne:
	lea (a1,d5),a2	; debut ligne precedente
	move d3,d2
.points:
	move.b (a3)+,d0
	move.b d0,d1
	lsr #4,d0
	add d0,d0
	move 0(a4,d0.w),(a1)+
	and #$F,d1
	add d1,d1
	move 0(a4,d1.w),(a1)+
	subq #2,d2
	bgt.s .points	
.fin_ligne:
	move.l a2,a1
	dbf d7,.ligne	
	swap d3
	rts	
bmp4_to_16_comp:
	swap d7
	bra.s .fin_ligne
.ligne:
	swap d7
	lea (a1,d5),a2	; debut ligne precedente
	move d3,d7
	addq #1,d7
	bclr #0,d7		; force la parite
.points:
	tst.l d7
	beq.s .fin_ligne
	moveq #0,d2
	move.b (a3)+,d2
	bne.s .lb1	; code <> $00, donc repeter
	move.b (a3)+,d2
	beq.s .fin_ligne	; code 00,00
	; ici, partie non compress‚e
	sub d2,d7
.run:
	move (a3)+,d0		; 4 pixels
	rol #5,d0			; *2 en meme temps
	move.b d0,d1
	and #$1E,d1
	move 0(a4,d1.w),(a1)+
	rol #4,d0
	move.b d0,d1
	and #$1e,d1
	move 0(a4,d1.w),(a1)+
	subq #2,d2
	beq.s .points
	rol #4,d0
	move.b d0,d1
	and #$1E,d1
	move 0(a4,d1.w),(a1)+
	rol #4,d0
	move.b d0,d1
	and #$1e,d1
	move 0(a4,d1.w),(a1)+
	subq #2,d2
	bgt.s .run
	bra.s .points
.lb1:
	sub d2,d7
	moveq #0,d0
	move.b (a3)+,d0
	move.b d0,d1
	lsr #4,d0
	add d0,d0
	and #$F,d1
	move 0(a4,d0),d0
	add d1,d1
	swap d0
	move 0(a4,d1),d0	; d0 contient un long avec deux points
.repeat:
	move.l d0,(a1)+
	subq #2,d2
	bgt.s .repeat
	bra.s .points
.fin_ligne:
	swap d7
	move.l a2,a1
	dbf d7,.ligne	
	endif
	rts			

bmp8_to_16:
	if REG=1
	add.l d0,d0
	add.l #20,d0		; + MFDB
	move.l d0,d6
	bsr malloc
	tst.b err
	beq.s .ok
	rts
.ok:
	lea 20(a0),a1		; donnees
	move.l a1,(a0)+
	lea -4(a0,d6.l),a1	; fin des donn‚es
	move d5,(a0)+
	move d4,(a0)+
	move d5,d0
	lsr #4,d0
	move d0,(a0)+
	moveq #16,d0
	move.l d0,(a0)+
	clr (a0)+
	clr.l (a0)
	lea -16(a0),a0
	moveq #0,d0
	moveq #0,d1
	neg d5
	add d5,d5
	add d5,a1			; derniere ligne
	move.l a1,a2
	cmp #1,comp_bmp
	beq.s bmp8_to_16_comp
	bra.s .fin_ligne
.ligne:
	lea (a1,d5),a2	; debut ligne precedente
	move d3,d2
	add #3,d2
	and #$FFFC,d2
.points:
	moveq #0,d0
	move.b (a3)+,d0
	add d0,d0
	move 0(a4,d0),(a1)+
	subq #1,d2
	bgt.s .points	
.fin_ligne:
	move.l a2,a1
	dbf d7,.ligne	
	rts
bmp8_to_16_comp:	
	swap d7
	bra.s .fin_ligne
.ligne:
	swap d7
	lea (a1,d5),a2	; debut ligne precedente
	move d3,d7
.points:
	tst.l d7
	beq.s .fin_ligne
	moveq #0,d2
	move.b (a3)+,d2
	bne.s .lb1
	move.b (a3)+,d2
	beq.s .fin_ligne
	sub d2,d7
.run:
	move (a3)+,d0
	ror #7,d0
	move d0,d1
	and #$1Fe,d1
	move 0(a4,d1.w),(a1)+
	subq #1,d2
	beq.s .points
	rol #8,d0
	and #$1fe,d0
	move 0(a4,d0.w),(a1)+
	subq #1,d2
	bgt.s .run
	bra.s .points
.lb1
	sub d2,d7
	moveq #0,d0
	move.b (a3)+,d0
	add d0,d0
	move 0(a4,d0.w),d0	; le pixel a repeter
.repeat:	
	move d0,(a1)+
	subq #1,d2
	bgt.s .repeat
	bra.s .points
.fin_ligne:
	swap d7
	move.l a2,a1
	dbf d7,.ligne	
	endif
	rts	


bmp4_to_tc:
	
	if REG=1
	move.l d0,d2
	add.l d0,d0
	add.l d2,d0
	cmp #24,planes
	beq.s .assez
	add.l d2,d0
.assez:
	add.l #20,d0		; + MFDB
	move.l d0,d6
	bsr malloc
	tst.b err
	beq.s .ok
	rts
.ok:
	lea 20(a0),a1		; donnees
	move.l a1,(a0)+
	lea -4(a0,d6.l),a1	; fin des donn‚es
	move d5,(a0)+
	move d4,(a0)+
	move d5,d0
	lsr #4,d0
	move d0,(a0)+
	clr (a0)+
	move planes,d2
	move d2,(a0)+	; 24 ou 32
	swap d4
	clr d4			; 0 pour 24 bits
	cmp #24,d2
	beq.s .bits24
	move #1,d4		; offset pour chaque point
	cmp.b #3,rb32
	bmi.s .bits24
	addq.l #1,a1	; avancer a1 de 1 pour xRVB et xBVR
.bits24:	
	clr (a0)+
	clr.l (a0)
	lea -16(a0),a0
	moveq #0,d0
	moveq #0,d1
	asr #3,d2			; 3 ou 4
	muls d2,d5
	neg d5
	add d5,a1			; derniere ligne
	move.l a1,a2
	cmp #2,comp_bmp	; compress‚?
	beq.s bmp4_to_tc_comp	
	move d3,d0
	swap d3
	addq #7,d0
	and #$fff8,d0
	move d0,d3
	bra.s .fin_ligne
.ligne:
	lea (a1,d5),a2	; debut ligne precedente
	move d3,d2
.points:
	move.b (a3)+,d0
	move.b d0,d1
	lsr #4,d0
	lsl #2,d0
	lea 0(a4,d0.w),a5
	move.b (a5)+,(a1)+
	move.b (a5)+,(a1)+
	move.b (a5)+,(a1)+
	add d4,a1
	and #$F,d1
	lsl #2,d1
	lea 0(a4,d1.w),a5
	move.b (a5)+,(a1)+
	move.b (a5)+,(a1)+
	move.b (a5)+,(a1)+
	add d4,a1
	subq #2,d2
	bgt.s .points	
.fin_ligne:
	move.l a2,a1
	dbf d7,.ligne	
	swap d3
	swap d4
	rts	
bmp4_to_tc_comp:
	swap d7
	bra .fin_ligne
.ligne:
	swap d7
	lea (a1,d5),a2	; debut ligne precedente
	move d3,d7
	addq #1,d7
	bclr #0,d7		; force la parite
.points:
	tst.l d7
	beq .fin_ligne
	moveq #0,d2
	move.b (a3)+,d2
	bne.s .lb1	; code <> $00, donc repeter
	move.b (a3)+,d2
	beq .fin_ligne	; code 00,00
	; ici, partie non compress‚e
	sub d2,d7
.run:
	move (a3)+,d0		; 4 pixels
	rol #6,d0			; *4 en meme temps
	move.b d0,d1
	and #$3c,d1
	lea 0(a4,d1.w),a5
	move.b (a5)+,(a1)+
	move.b (a5)+,(a1)+
	move.b (a5)+,(a1)+
	add d4,a1
	rol #4,d0
	move.b d0,d1
	and #$3c,d1
	lea 0(a4,d1.w),a5
	move.b (a5)+,(a1)+
	move.b (a5)+,(a1)+
	move.b (a5)+,(a1)+
	add d4,a1
	subq #2,d2
	beq.s .points
	rol #4,d0
	move.b d0,d1
	and #$3c,d1
	lea 0(a4,d1.w),a5
	move.b (a5)+,(a1)+
	move.b (a5)+,(a1)+
	move.b (a5)+,(a1)+
	add d4,a1
	rol #4,d0
	move.b d0,d1
	and #$3c,d1
	lea 0(a4,d1.w),a5
	move.b (a5)+,(a1)+
	move.b (a5)+,(a1)+
	move.b (a5)+,(a1)+
	add d4,a1
	subq #2,d2
	bgt.s .run
	bra.s .points
.lb1:
	sub d2,d7
	moveq #0,d0
	move.b (a3)+,d0
	move.b d0,d1
	lsr #4,d0
	lsl #2,d0
	and #$F,d1
	move.l 0(a4,d0),d0
	lsl #2,d1
	move.l 0(a4,d1),d1
.repeat:
	rol.l #8,d0
	move.b d0,(a1)+
	rol.l #8,d0
	move.b d0,(a1)+
	rol.l #8,d0
	move.b d0,(a1)+
	rol.l #8,d1
	add d4,a1
	rol.l #8,d0
	move.b d1,(a1)+
	rol.l #8,d1
	move.b d1,(a1)+
	rol.l #8,d1
	move.b d1,(a1)+
	rol.l #8,d1
	add d4,a1
	subq #2,d2
	bgt.s .repeat
	bra .points
.fin_ligne:
	swap d7
	move.l a2,a1
	dbf d7,.ligne	
	swap d4
	endif
	rts			

bmp8_to_tc:
	if REG=1
	move.l d0,d2
	add.l d0,d0
	add.l d2,d0
	cmp #24,planes
	beq.s .assez
	add.l d2,d0
.assez:	
	add.l #20,d0		; + MFDB
	move.l d0,d6
	bsr malloc
	tst.b err
	beq.s .ok
	rts
.ok:
	lea 20(a0),a1		; donnees
	move.l a1,(a0)+
	lea -4(a0,d6.l),a1	; fin des donn‚es
	move d5,(a0)+
	move d4,(a0)+
	move d5,d0
	lsr #4,d0
	move d0,(a0)+
	clr (a0)+
	move planes,d2
	move d2,(a0)+	; 24 ou 32
	swap d4
	clr d4			; 0 pour 24 bits
	cmp #24,d2
	beq.s .bits24
	move #1,d4		; offset pour chaque point
	cmp.b #3,rb32
	bmi.s .bits24
	addq.l #1,a1	; avancer a1 de 1 pour xRVB et xBVR
.bits24:		
	clr (a0)+
	clr.l (a0)
	lea -16(a0),a0
	moveq #0,d0
	moveq #0,d1
	asr #3,d2			; 3 ou 4
	muls d2,d5
	neg d5
	add d5,a1			; derniere ligne
	move.l a1,a2
	cmp #1,comp_bmp
	beq.s bmp8_to_tc_comp
	bra.s .fin_ligne
.ligne:
	lea (a1,d5),a2	; debut ligne precedente
	move d3,d2
	add #3,d2
	and #$FFFC,d2
.points:
	moveq #0,d0
	move.b (a3)+,d0
	lsl #2,d0
	lea 0(a4,d0.w),a5
	move.b (a5)+,(a1)+
	move.b (a5)+,(a1)+
	move.b (a5)+,(a1)+
	add d4,a1
	subq #1,d2
	bgt.s .points	
.fin_ligne:
	move.l a2,a1
	dbf d7,.ligne	
	swap d4
	rts
bmp8_to_tc_comp:	
	swap d7
	bra.s .fin_ligne
.ligne:
	swap d7
	lea (a1,d5),a2	; debut ligne precedente
	move d3,d7
.points:
	tst.l d7
	beq.s .fin_ligne
	moveq #0,d2
	move.b (a3)+,d2
	bne.s .lb1
	move.b (a3)+,d2
	beq.s .fin_ligne
	sub d2,d7
.run:
	move (a3)+,d0
	ror #6,d0
	move d0,d1
	and #$3FC,d1
	lea 0(a4,d1.w),a5
	move.b (a5)+,(a1)+
	move.b (a5)+,(a1)+
	move.b (a5)+,(a1)+
	add d4,a1
	subq #1,d2
	beq.s .points
	rol #8,d0
	and #$3fc,d0
	lea 0(a4,d0.w),a5
	move.b (a5)+,(a1)+
	move.b (a5)+,(a1)+
	move.b (a5)+,(a1)+
	add d4,a1
	subq #1,d2
	bgt.s .run
	bra.s .points
.lb1
	sub d2,d7
	moveq #0,d0
	move.b (a3)+,d0
	lsl #2,d0
	lea 0(a4,d0.w),a5
	move.b (a5)+,d0
	swap d0
	move.b (a5)+,d1
	move.b (a5)+,d0
	swap d0
.repeat:	
	move.b d0,(a1)+
	swap d0
	move.b d1,(a1)+
	move.b d0,(a1)+
	swap d0
	add d4,a1
	subq #1,d2
	bgt.s .repeat
	bra.s .points
.fin_ligne:
	swap d7
	move.l a2,a1
	dbf d7,.ligne	
	swap d4
	endif
	rts	


bmp4_to_8:
	if REG=1
	add.l #20,d0		; + MFDB
	move.l d0,d6
	bsr malloc
	tst.b err
	beq.s .ok
	rts
.ok:
	lea 20(a0),a1		; donnees
	move.l a1,(a0)+
	lea -4(a0,d6.l),a1	; fin des donn‚es
	move d5,(a0)+
	move d4,(a0)+
	move d5,d0
	lsr #4,d0
	move d0,(a0)+
	moveq #8,d0
	move.l d0,(a0)+
	clr (a0)+
	clr.l (a0)
	lea -16(a0),a0
	moveq #0,d0
	moveq #0,d1
	neg d5
	add d5,a1			; derniere ligne
	move.l a1,a2
	cmp #2,comp_bmp	; compress‚?
	beq.s bmp4_to_8_comp	
	move d3,d0
	swap d3
	addq #7,d0
	and #$fff8,d0
	move d0,d3
	tst.b is_bar
	beq.s .fin_ligne
	bra.s .fin_ligne_bar
.ligne:
	lea (a1,d5),a2	; debut ligne precedente
	move d3,d2
.points:
	move.b (a3)+,d0
	move.b d0,d1
	lsr #4,d0
	and #$F,d1
	add #16,d0
	move.b d0,(a1)+
	add #16,d1
	move.b d1,(a1)+
	subq #2,d2
	bgt.s .points	
.fin_ligne:
	move.l a2,a1
	dbf d7,.ligne	
	swap d3
	rts	
.ligne_bar:
	lea (a1,d5),a2	; debut ligne precedente
	move d3,d2
.points_bar:
	move.b (a3)+,d0
	move.b d0,d1
	lsr #4,d0
	and #$F,d1
	cmp #15,d0
	bne.s .lll1
	st d0
.lll1:
	move.b d0,(a1)+
	cmp #15,d1
	bne.s .lll2
	st d1
.lll2:
	move.b d1,(a1)+
	subq #2,d2
	bgt.s .points_bar
.fin_ligne_bar:
	move.l a2,a1
	dbf d7,.ligne_bar
	swap d3
	rts	
bmp4_to_8_comp:
	swap d7
	bra.s .fin_ligne
.ligne:
	swap d7
	lea (a1,d5),a2	; debut ligne precedente
	move d3,d7
	addq #1,d7
	bclr #0,d7		; force la parite
.points:
	tst.l d7
	beq.s .fin_ligne
	moveq #0,d2
	move.b (a3)+,d2
	bne.s .lb1	; code <> $00, donc repeter
	move.b (a3)+,d2
	beq.s .fin_ligne	; code 00,00
	; ici, partie non compress‚e
	sub d2,d7
.run:
	move (a3)+,d0		; 4 pixels
	rol #4,d0			; *2 en meme temps
	move.b d0,d1
	and #$F,d1
	add #16,d1
	move.b d1,(a1)+
	rol #4,d0
	move.b d0,d1
	and #$F,d1
	add #16,d1
	move.b d1,(a1)+
	subq #2,d2
	beq.s .points
	rol #4,d0
	move.b d0,d1
	and #$F,d1
	add #16,d1
	move.b d1,(a1)+
	rol #4,d0
	and #$f,d0
	add #16,d1
	move.b d0,(a1)+
	subq #2,d2
	bgt.s .run
	bra.s .points
.lb1:
	sub d2,d7
	moveq #0,d0
	move.b (a3)+,d0
	ror #4,d0
	rol.b #4,d0
	rol #4,d0
	add #$1010,d0	; d0 contient un WORD avec deux points
.repeat:
	move d0,(a1)+
	subq #2,d2
	bgt.s .repeat
	bra.s .points
.fin_ligne:
	swap d7
	move.l a2,a1
	dbf d7,.ligne	
	endif
	rts			

bmp8_to_8:
	if REG=1
	add.l #20,d0		; + MFDB
	move.l d0,d6
	bsr malloc
	tst.b err
	beq.s .ok
	rts
.ok:
	lea 20(a0),a1		; donnees
	move.l a1,(a0)+
	lea -4(a0,d6.l),a1	; fin des donn‚es
	move d5,(a0)+
	move d4,(a0)+
	move d5,d0
	lsr #4,d0
	move d0,(a0)+
	moveq #8,d0
	move.l d0,(a0)+
	clr (a0)+
	clr.l (a0)
	lea -16(a0),a0
	moveq #0,d0
	moveq #0,d1
	neg d5
	add d5,a1			; derniere ligne
	move.l a1,a2
	cmp #1,comp_bmp
	beq.s bmp8_to_8_comp
	bra.s .fin_ligne
.ligne:
	lea (a1,d5),a2	; debut ligne precedente
	move d3,d2
	add #3,d2
	and #$FFFC,d2
.points:
	moveq #0,d0
	move.b (a3)+,d0
	move.b 0(a4,d0.w),(a1)+	; convertit les indexs
	subq #1,d2
	bgt.s .points	
.fin_ligne:
	move.l a2,a1
	dbf d7,.ligne	
	rts
bmp8_to_8_comp:	
	swap d7
	bra.s .fin_ligne
.ligne:
	swap d7
	lea (a1,d5),a2	; debut ligne precedente
	move d3,d7
.points:
	tst.l d7
	beq.s .fin_ligne
	moveq #0,d2
	move.b (a3)+,d2
	bne.s .lb1
	move.b (a3)+,d2
	beq.s .fin_ligne
	sub d2,d7
.run:
	move (a3)+,d0
	move d0,d1
	lsr #8,d0
	move.b 0(a4,d0.w),(a1)+
	subq #1,d2
	beq.s .points
	and #$FF,d1
	move.b 0(a4,d1.w),(a1)+
	subq #1,d2
	bgt.s .run
	bra.s .points
.lb1
	sub d2,d7
	moveq #0,d0
	move.b (a3)+,d0
	move.b 0(a4,d0.w),d0	; le pixel a repeter
.repeat:	
	move.b d0,(a1)+
	subq #1,d2
	bgt.s .repeat
	bra.s .points
.fin_ligne:
	swap d7
	move.l a2,a1
	dbf d7,.ligne	
	endif
	rts	
	
bmp4_to_1:
	lea line_err1,a0
	move #1015,d1
.eff:
	clr.l (a0)+
	dbf d1,.eff			; efface les erreurs
	asr.l #2,d0			; 1pixel = 1/8 de byte
	; ne pas separer!
bmp4_to_4:
	asr.l #1,d0			; moitie moins! 1 pixel=1/2 octet
	add.l #20,d0		; + MFDB
	move.l d0,d6
	bsr malloc
	tst.b err
	beq.s .ok
	rts
.ok:
	lea 20(a0),a1		; donnees
	move.l a1,(a0)+
	lea -4(a0,d6.l),a1	; fin des donn‚es
	move d5,(a0)+
	move d4,(a0)+
	move d5,d0
	lsr #4,d0
	move d0,(a0)+
	clr (a0)+
	move planes,d0
	move d0,(a0)+	; 4 ou 1
	clr (a0)+
	clr.l (a0)
	lea -16(a0),a0
	neg d5
	asr d5				; 1pixel = 1/2 octet
	cmp #1,d0			; plans
	bne.s .coul16
	asr #2,d5			; encore limite
	bra.s .nova
.coul16:
	move.b rb04,d1
	cmp.b #'1',d1
	bne.s .nova
	asr #2,d5			; divise en plus par 4 (4 plans separes)
	sub.l #20,d6		; taille donnees
	asr.l #2,d6			; taille d'un plan (pour les 4 autres pointeurs)	
	neg.l d6
.nova:	
	moveq #0,d0
	moveq #0,d1
	add d5,a1			; derniere ligne
	cmp #2,comp_bmp	; compress‚?
	beq.s bmp4_to_4_comp	
	move d3,d0
	swap d3
	addq #7,d0
	and #$fff8,d0
	move d0,d3
	subq #1,d7
.ligne:
	lea line_buffer,a2	; debut ligne packed
	move d3,d2
.points:
	move.b (a3)+,d0
	move.b d0,d1
	lsr #4,d0
	and #$F,d1
	move.b 0(a4,d0),(a2)+
	move.b 0(a4,d1),(a2)+
	subq #2,d2
	bgt.s .points	
.fin_ligne:
	bsr vers_4_plans	; ou en packed bits si mode=3
	add d5,a1
	dbf d7,.ligne	
	swap d3
	rts	
bmp4_to_4_comp:
	subq #1,d7
.ligne:
	swap d7
	lea line_buffer,a2	; debut ligne
	move d3,d7
	addq #1,d7
	bclr #0,d7		; force la parite
.points:
	tst.l d7
	beq.s .fin_ligne
	moveq #0,d2
	move.b (a3)+,d2
	bne.s .lb1	; code <> $00, donc repeter
	move.b (a3)+,d2
	beq.s .fin_ligne	; code 00,00
	; ici, partie non compress‚e
	sub d2,d7
.run:
	move (a3)+,d0		; 4 pixels
	rol #4,d0			; *2 en meme temps
	move.b d0,d1
	and #$F,d1
	move.b 0(a4,d1),(a2)+
	rol #4,d0
	move.b d0,d1
	and #$F,d1
	move.b 0(a4,d1),(a2)+
	subq #2,d2
	beq.s .points
	rol #4,d0
	move.b d0,d1
	and #$F,d1
	move.b 0(a4,d1),(a2)+
	rol #4,d0
	and #$f,d0
	move.b 0(a4,d0),(a2)+
	subq #2,d2
	bgt.s .run
	bra.s .points
.lb1:
	sub d2,d7
	moveq #0,d0
	move.b (a3)+,d0
	move.b d0,d1
	lsr #4,d0
	and #$f,d1
	move.b 0(a4,d0),d0
	ror #8,d0
	move.b 0(a4,d1),d0 ; d0 contient un WORD avec deux points
.repeat:
	move d0,(a2)+
	subq #2,d2
	bgt.s .repeat
	bra.s .points
.fin_ligne:
	swap d7
	bsr vers_4_plans	; ou en packed bits si mode=3
	add d5,a1
	dbf d7,.ligne	
	rts			

bmp8_to_1:
	lea line_err1,a0
	move #1015,d1
.eff:
	clr.l (a0)+
	dbf d1,.eff			; efface les erreurs
	asr.l #2,d0			; 1pixel = 1/8 de byte
	; ne pas separer!
bmp8_to_4:
	asr.l d0
	add.l #20,d0		; + MFDB
	move.l d0,d6
	bsr malloc
	tst.b err
	beq.s .ok
	rts
.ok:
	lea 20(a0),a1		; donnees
	move.l a1,(a0)+
	lea -4(a0,d6.l),a1	; fin des donn‚es
	move d5,(a0)+
	move d4,(a0)+
	move d5,d0
	lsr #4,d0
	move d0,(a0)+
	clr (a0)+
	move planes,d0
	move d0,(a0)+	; 4 ou 1
	clr (a0)+
	clr.l (a0)
	lea -16(a0),a0
	neg d5
	asr d5
	cmp #1,d0			; plans
	bne.s .coul16
	asr #2,d5			; encore limite
	bra.s .nova
.coul16:
	move.b rb04,d1
	cmp.b #'1',d1
	bne.s .nova
	asr #2,d5			; divise en plus par 4 (4 plans separes)
	sub.l #20,d6		; taille donnees
	asr.l #2,d6			; taille d'un plan (pour les 4 autres pointeurs)	
	neg.l d6
.nova:		
	add d5,a1			; derniere ligne
	moveq #0,d1
	moveq #0,d0
	cmp #1,comp_bmp
	beq.s bmp8_to_4_comp
	subq #1,d7
.ligne:
	lea line_buffer,a2	; debut ligne precedente
	move d3,d2
	add #3,d2
	and #$FFFC,d2
.points:
	moveq #0,d0
	move.b (a3)+,d0
	move.b 0(a4,d0.w),(a2)+	; convertit les indexs
	subq #1,d2
	bgt.s .points	
.fin_ligne:
	bsr vers_4_plans
	add d5,a1
	dbf d7,.ligne	
	rts
bmp8_to_4_comp:	
	subq #1,d7
.ligne:
	swap d7
	lea line_buffer,a2	; debut ligne precedente
	move d3,d7
.points:
	tst.l d7
	beq.s .fin_ligne
	moveq #0,d2
	move.b (a3)+,d2
	bne.s .lb1
	move.b (a3)+,d2
	beq.s .fin_ligne
	sub d2,d7
.run:
	move (a3)+,d0
	move d0,d1
	lsr #8,d0
	move.b 0(a4,d0.w),(a2)+
	subq #1,d2
	beq.s .points
	and #$FF,d1
	move.b 0(a4,d1.w),(a2)+
	subq #1,d2
	bgt.s .run
	bra.s .points
.lb1
	sub d2,d7
	moveq #0,d0
	move.b (a3)+,d0
	move.b 0(a4,d0.w),d0	; le pixel a repeter
.repeat:	
	move.b d0,(a2)+
	subq #1,d2
	bgt.s .repeat
	bra.s .points
.fin_ligne:
	swap d7
	bsr vers_4_plans
	add d5,a1
	dbf d7,.ligne	
	rts	
	
bmp8_to_4_dith:
	asr.l d0
	add.l #20,d0		; + MFDB
	move.l d0,d6
	bsr malloc
	tst.b err
	beq.s .ok
	rts
.ok:
	lea 20(a0),a1		; donnees
	move.l a1,(a0)+
	lea -4(a0,d6.l),a1	; fin des donn‚es
	move d5,(a0)+
	move d4,(a0)+
	move d5,d0
	lsr #4,d0
	move d0,(a0)+
	clr (a0)+
	move planes,d0
	move d0,(a0)+	; 4 ou 1
	clr (a0)+
	clr.l (a0)
	lea -16(a0),a0
	neg d5
	asr d5
	cmp #1,d0			; plans
	bne.s .coul16
	asr #2,d5			; encore limite
	bra.s .nova
.coul16:
	move.b rb04,d1
	cmp.b #'1',d1
	bne.s .nova
	asr #2,d5			; divise en plus par 4 (4 plans separes)
	sub.l #20,d6		; taille donnees
	asr.l #2,d6			; taille d'un plan (pour les 4 autres pointeurs)	
	neg.l d6
.nova:		
	add d5,a1			; derniere ligne
	moveq #0,d1
	moveq #0,d0
	cmp #1,comp_bmp
	beq.s bmp8_to_4_dith_comp
	subq #1,d7
.ligne:
	lea line_buffer,a2	; debut ligne precedente
	move d3,d2
	add #3,d2
	and #$FFFC,d2
.points:
	move.b (a3)+,(a2)+
	subq #1,d2
	bgt.s .points	
.fin_ligne:
	bsr dith_ligne
	bsr vers_4_plans
	add d5,a1
	dbf d7,.ligne	
	rts
bmp8_to_4_dith_comp:	
	subq #1,d7
.ligne:
	swap d7
	lea line_buffer,a2	; debut ligne precedente
	move d3,d7
.points:
	tst.l d7
	beq.s .fin_ligne
	moveq #0,d2
	move.b (a3)+,d2
	bne.s .lb1
	move.b (a3)+,d2
	beq.s .fin_ligne
	sub d2,d7
.run:
	move (a3)+,d0
	move d0,d1
	lsr #8,d0
	move.b d0,(a2)+
	subq #1,d2
	beq.s .points
	move.b d1,(a2)+
	subq #1,d2
	bgt.s .run
	bra.s .points
.lb1
	sub d2,d7
	moveq #0,d0
	move.b (a3)+,d0
.repeat:	
	move.b d0,(a2)+
	subq #1,d2
	bgt.s .repeat
	bra.s .points
.fin_ligne:
	swap d7
	bsr dith_ligne
	bsr vers_4_plans
	add d5,a1
	dbf d7,.ligne	
	rts		

	; pour le dithering 8 couleurs
	
matrice: dc.b 0,32,8,40,2,34,10,42
		dc.b 48,16,56,24,50,18,58,26
		dc.b 12,44,4,36,14,46,6,38
		dc.b 60,28,52,20,62,30,54,22
		dc.b 3,35,11,43,1,33,9,41
		dc.b 51,19,59,27,49,17,57,25
		dc.b 15,47,7,39,13,45,5,37
		dc.b 63,31,55,23,61,29,53,21
		dc.b 0,32,8,40,2,34,10,42
		
dith_ligne:
	movem.l d4-d5/a3/a5,-(sp)
	lea line_buffer,a2
	move 8(a0),d5		; paquets de 16
	moveq #7,d0
	and d7,d0			; ligne modulo 8
	lsl #3,d0			; fois 8
	lea matrice(pc,d0),a3	; ligne de la matrice a utiliser
.encore:	
	moveq #15,d4		; 15 index a la fois
.points16:	
	moveq #0,d0
	move.b (a2),d0
	add d0,d0
	add d0,d0
	lea 0(a4,d0),a5	; rvb de l'index
	move.b (a3)+,d1	; niveau de la matrice
	moveq #0,d0			; index couleur
	cmp.b (a5)+,d1
	bmi.s .pas_rouge
	moveq #1,d0
.pas_rouge:
	cmp.b (a5)+,d1
	bmi.s .pas_vert
	addq #2,d0
.pas_vert:
	cmp.b (a5),d1
	bmi.s .pas_bleu
	addq #4,d0
.pas_bleu:
	move.b .index(pc,d0),(a2)+
	dbf d4,.points16
	subq.l #8,a3
	subq.l #8,a3		; retour dans la matrice
	subq #1,d5
	bne.s .encore
	movem.l (sp)+,d4-d5/a3/a5
	rts	
;.index: dc.b $F0,$10,$20,$30,$40,$50,$60,$00	; les 8 couleurs XBIOS
.index: dc.b $00,$60,$50,$40,$30,$20,$10,$F0
	
		
; a0: MFDB source
; d0: x,y source
; d1: l,h source
; d2: x,y ecran

affiche_image:
	lea mfdb_adr,a1
	move.l a0,(a1)		; mfdb source
	clr.l 10(a1)		; source=ecran
	lea vcp_ptsin,a1
	move.l d0,(a1)+	; x,y source
	sub.l #$10001,d1	; l-1,h-1
	add.l d1,d0
	move.l d0,(a1)+	; x',y' source
	move.l d2,(a1)+	; x,y dest
	add.l d1,d2
	move.l d2,(a1)		; x',y' dest
	tst.b mouse
	bne.s .lb0
	GEM_VDI hide_mouse
.lb0:
	GEM_VDI vro_cpyfm		; ou vrt_cpyfm si monochrome
	tst.b mouse
	bne.s .lb1
	GEM_VDI show_mouse
.lb1:
	sf mouse
	rts


malloc:
	tst.l d0
	beq.s .erreur
	tst.b mxcall
	beq.s .vieux
	move ram_type(pc),-(sp)		; tt ram de pr‚f‚rence
	move.l d0,-(sp)
	GEMDOS 68,8
	bra.s .commun
.vieux:
	move.l d0,-(sp)
	GEMDOS 72,6
.commun:
	move.l d0,a0
	tst.l d0
	beq.s .erreur
	move #3,ram_type
	rts
.erreur:
	st err
	lea bug_mem,a0
	bsr alert
	move #3,ram_type
	rts
ram_type: dc.w 3		; tt ram par defaut

mfree:
	moveq #0,d0
	cmp.l a0,d0
	beq.s .fin
	move.l a0,-(sp)
	GEMDOS 73,6
.fin:
	rts
		
alert:
	move.l a0,ab_addrin		; the string adress
	GEM_AES alert_box				; form alert
	move intout,d0
	rts		
	
special:
	move.l $4f2.w,a0			; os header
	lea $E1B.w,a1
	cmp #$0100,2(a0)
	beq.s .vieux
	move.l 36(a0),a1
.vieux:
	move.l a1,kbshift
	rts
	
; a3: adresse palette
; d0: premier index
; d3: nombre d'indexs

sauve_palette:
	move d0,(a3)+
	move d3,(a3)+
	movem.l a4-a5,-(sp)
	lea vq_int,a4
	lea intout+2,a5
	move d0,(a4)	; premier index
.loop:
	GEM_VDI vq_color
	move.l (a5),(a3)+
	move 4(a5),(a3)+
	addq #1,(a4)
	dbf d3,.loop
	movem.l (sp)+,a4-a5	
	rts

; d0: numero du CD (1 ou 2)
; renvoit d0=1 Ok, d0=2 Annuler, d0=3 regler!

verif_cd:
	if STE=1
		moveq #1,d0
		rts
	else
	
	movem.l d1-d3/a0-a4,-(sp)
	moveq #48,d1
	add d0,d1
	move.b d1,_pas_cd1
	moveq #0,d3
	lea .infos_lec1(pc),a4
	move.b rbcd1,d3
	cmp #1,d0
	beq.s .ok
	lea .infos_lec2(pc),a4
	move.b rbcd2,d3
.ok:
	move.b d3,_pas_cd2
	move.b d3,(a4)		; nom du lecteur
	bra.s .detecte
.infos_lec1:
	dc.b "1:\VFW\OLE2.DL_",0
.infos_lec2:
	dc.b "2:\MEDIA\AVI\CLFIN1.AVI",0
	even
.le_cd:
	lea pas_cd,a0
	bsr alert
	cmp #1,d0
	bne.s .sortie
.detecte:
	BUSY
	clr -(sp)
	move.l a4,-(sp)
	GEMDOS 78,8
	move.l d0,-(sp)
	FLECHE
	move.l (sp)+,d0
	bne.s .le_cd
	moveq #1,d0
.sortie:	
	movem.l (sp)+,d1-d3/a0-a4
	rts
	
	endif

copie_article:
	bsr file_select
	tst.b err
	bne .fin
	clr -(sp)
	lea line_err2,a5
	move.l a5,-(sp)
	GEMDOS 60,8		; fcreate
	move d0,d7		; handle
	bmi .fin
	move.l page_ptr,a3
	lea 12(a3),a3	; pointe sur le titre
	move.l a5,a0
	lea iso_atari,a4	; la conversion
	moveq #0,d4
.titre:
	move.b (a3)+,d4
	beq.s .fin_titre
	move.b 0(a4,d4.l),(a0)+
	bra.s .titre
.fin_titre:
	move.l a0,d1
	sub.l a5,d1		; nombre de caracteres (pour souligner ensuite!)
	move.b #13,(a0)+
	move.b #10,(a0)+	; saut de ligne
	subq #1,d1
.souligne:
	move.b #"-",(a0)+
	dbf d1,.souligne
	move.b #13,(a0)+
	move.b #10,(a0)+	; saut
	lea lignes,a3	; premiere ligne a suivre
	bra .fin_ligne
.encore:
	move.l a5,a0	; encore!
	lea 1(a3),a1
	add #256,a3		; prepare
	move.b (a1)+,d0	; type
	cmp.b #2,d0
	beq.s .ligne_image
	cmp.b #1,d0
	bne.s .fin_ligne	; heu... Inconnu!
	moveq #0,d1
	move.b (a1)+,d1	; longueur ligne
	clr.b 0(a1,d1.l)	; termine avec un zero!
.char:
	move.b (a1)+,d4
	beq.s .fin_ligne
	cmp.b #">",d4
	bne.s .pas_lien
	READLONG a1,d0
	cmp.l #'BMP:',d0
	beq.s .lien
	cmp.l #'WAV:',d0
	beq.s .lien
	cmp.l #'AVI:',d0
	beq.s .lien
	subq.l #4,a1	; sinon, retour juste apres le '>'
	bra.s .char
.lien:
	cmp.b #'@',(a1)+
	bne.s .lien
	bra.s .char		; on a ot‚ >BMP:xxxx@	
.pas_lien:
	cmp.b #'@',d4
	bne.s .normal
	READLONG a1,d0
	cmp.l #'FETT',d0
	beq.s .lien		; on va oter @FETT@
	subq.l #4,a1	; sinon, c'est un @ normal
	bra.s .char	
.normal:
	move.b 0(a4,d4.l),(a0)+
	bra.s .char
.ligne_image:
	move.l #"BMP:",(a0)+
	move.l 12(a1),(a0)+
	move.l 16(a1),(a0)+	; copie le nom de l'image		
.fin_ligne:
	move.b #13,(a0)+
	move.b #10,(a0)+
	move.l a5,-(sp)
	sub.l a5,a0		; taille
	move.l a0,-(sp)
	move d7,-(sp)
	GEMDOS 64,12	; ecrit la ligne
	tst.b (a3)		; derniŠre ligne?
	bne .encore
	move d7,-(sp)
	GEMDOS 62,4		; fclose
.fin:
	sf err
	rts

; entree path et file
; sortie: full dans line_err2 ou 'err' si annuler par exemple

file_select:
	GEM_AES fileselect				; to select a MOV or quit (Abort button)
	move.l intout,d0						
	tst d0
	beq .fin				
	swap d0	
	tst d0
	beq .fin				
	lea path,a0
	lea line_err2,a1					; full will contain path+file
	move.l a1,a2						; will keep the last '\' position
.lb1:
	move.b (a0)+,d0					; a byte from path...
	beq.s .copy_name					; it's the end of the path
	move.b d0,(a1)+					; ...to full
	cmp.b #'\',d0
	bne.s .lb1
	move.l a1,a2						; if '\', updates A2
	bra.s .lb1
.copy_name:
	sub.l a2,a1
	lea file,a0							; the file name (or the mask!)
.lb2:
	move.b (a0)+,(a2)+				; copies after the last '\'
	bne.s .lb2							; til the end of the string
	rts	
.fin:
	st err
	rts

recherche:
	BUSY
	lea rech_flag,a5
	lea iso_vers_majuscules(pc),a6
	move.l a5,d5
	add.l #31954,d5					; fin de bloc
	move.l 6(a5),a4					; pointeur de recherche
	clr -(sp)			; le debut
	move index_h(pc),-(sp)
	move.l 2(a5),-(sp)
	GEMDOS 66,10		; fseek
.boucle:
	cmp.l d5,a4
	bmi.s .ok
	move.l #31876,d0	; taille bloc
	sub.l d0,a4			; retour
	add.l d0,2(a5)		; nouvel offset
	move.l a4,-(sp)
	move.l d0,-(sp)
	move index_h(pc),-(sp)
	GEMDOS 63,12		; fread
	cmp.l #31874,d0	; taille-2
	bmi .fin_recherche
.ok:
	moveq #29,d0		; conversion de 30 caracteres
	moveq #0,d1
	lea -32(a5),a0		; chaine 3
.convert:
	move.b (a4)+,d1
	move.b 0(a6,d1.l),(a0)+
	dbf d0,.convert
	clr.b (a0)			; fin de chaine
	lea -30(a4),a4		; retour!
	lea 10(a5),a1		; WORD taille + chaine 1
	bsr .inclus
	beq.s .trouve
	cmp.b #2,1(a5)		; mode 2 =OU, donc chercher 2 maintenant
	bne.s .autre		; sinon, test negatif, autre chaine
	bra.s .second
.trouve:
	cmp.b #2,1(a5)
	beq.s .succes		; l'une trouvee en mode OU, c'est la reussite
	cmp.b #4,1(a5)
	beq.s .succes		; l'une trouve en mode chaine1 seul, reussi aussi
.second:
	lea 44(a5),a1		; WORD taille + chaine 2
	bsr.s .inclus
	beq.s .trouve2
	cmp.b #3,1(a5)
	beq.s .succes		; 1 sans 2, donc gagne!
	bra.s .autre	
.trouve2:
	cmp.b #3,1(a5)		; mode 1 sans 2
	bne.s .succes		; non, c'est donc une reussite (OU ou ET)
.autre:
	add #52,a4			; place suivante
	bra .boucle
.succes:
	FLECHE
	bsr nouveau_bloc
	move.l page_ptr,a1		
	lea -32(a5),a2
	move.l a4,(a2)
	add #52,a4
	move.l a4,6(a5)	; futur pointeur
	rts	
.fin_recherche:
	FLECHE
	sf (a5)				; plus de recherche
	st err				; erreur (enfin, si on veut!)
	rts
.inclus:
	move (a1)+,d1		; taille chaine a chercher
	lea -32(a5),a0		; chaine reference
	moveq #30,d2		; taille chaine reference
	sub d1,d2			; pour la boucle!
	move.b (a1)+,d3	; initiale
.i0:
	cmp.b (a0)+,d3
	beq.s .voir
.i1:
	dbf d2,.i0
	moveq #-1,d0		; MI = erreur
	rts
.voir:
	move.l a1,a2
	move.l a0,a3
.reste:
	move.b (a2)+,d1
	beq.s .i2			; ok, chaine trouvee
	cmp.b (a3)+,d1
	bne.s .i1			; pas trouve, boucle
	bra.s .reste		; regarde encore le reste
.i2:
	moveq #0,d0			; EQ = reussi
	rts
	
atari_vers_majuscules:
	dc.b 0,"         "
   dc.b "          "
   dc.b "          "
   dc.b "          "
   dc.b "        01"
   dc.b "23456789  "
   dc.b "     ABCDE"
   dc.b "FGHIJKLMNO"
   dc.b "PQRSTUVWXY"
   dc.b "Z      ABC"
   dc.b "DEFGHIJKLM"
   dc.b "NOPQRSTUVW"
   dc.b "XYZ     CU"
   dc.b "EAAAACEEEI"
   dc.b "IIAAEOOO"	;  SERT DE ’ ET ‘
   dc.b "UUYOU œ   "
   dc.b "AIOUNNAO  "
   dc.b "      AOOO"
   dc.b "ôôAAO     "	; ô SERT DE µ ET ´
   dc.b "          "
   dc.b "          "
   dc.b "          "
   dc.b "          "
   dc.b "          "
   dc.b "          "
   dc.b "  N23 "

	
iso_vers_majuscules:
	dc.b 0,"         "
   dc.b "          "
   dc.b "          "
   dc.b "          "
   dc.b "        01"
   dc.b "23456789  "
   dc.b "     ABCDE"
   dc.b "FGHIJKLMNO"
   dc.b "PQRSTUVWXY"
   dc.b "Z      ABC"
   dc.b "DEFGHIJKLM"
   dc.b "NOPQRSTUVW"
   dc.b "XYZ       "
   dc.b "          "
   dc.b "          "
   dc.b "          "
   dc.b "   œ      "
   dc.b "A       23"
   dc.b "      O   "
   dc.b "  AAAAAAC"
   dc.b "EEEEIIIIDN"
   dc.b "OOOOOôOUUU"
   dc.b "UY  AAAAAA"
   dc.b "CEEEEIIII"
   dc.b " NOOOOOôOU"
   dc.b "UUUY Y"


	data

page_ptr: dc.l pages

quizz_titre: dc.l t_hist,t_art,t_sci,t_tech,t_pol,t_info,t_geo,t_div
	
themes: dc.l th_hist,th_art,th_sci,th_tech,th_pol,th_info,th_geo
	; *titre, *fichier OUT, *fichier QIX
th_hist: dc.l t_hist
	dc.w 1
th_art: dc.l t_art
	dc.w 3
th_sci: dc.l t_sci
	dc.w 5
th_tech: dc.l t_tech
	dc.w 7
th_pol: dc.l t_pol
	dc.w 9
th_info: dc.l t_info
	dc.w 11
th_geo: dc.l t_geo
	dc.w 13
th_actu: dc.l t_actu
	dc.w 15
	; Pour chaque fichier (a partir du no 1), numero du fichier a suivre
	; -1 = index alphabetique complet
	; -2 = base des articles
	; -3 = index des medias LEXMED.QIX

references:
	dc.w 2,-1,4,-1,6,-1,8,-1,10,-1,12,-1,14,-1,16,-1,-1
	; les MEDBER...
	dc.w 19,-3,21,-3,23,-3,25,-3,27,-3,29,-3,31,-3,33,-3,35,-3
	
galerie: dc.l med_az,med_mon,med_nat,med_art,med_tech,med_pol,med_hist
	dc.l med_cel,med_hom
	
med_az: dc.l tm_az
	dc.w 18
med_mon: dc.l tm_mon
	dc.w 20
med_nat: dc.l tm_nat
	dc.w 22
med_art: dc.l tm_art
	dc.w 24
med_tech: dc.l tm_tech
	dc.w 26
med_pol: dc.l tm_pol
	dc.w 28
med_hist: dc.l tm_hist
	dc.w 30
med_cel: dc.l tm_cel
	dc.w 32
med_hom: dc.l tm_hom
	dc.w 34
			
fichiers:
	dc.l f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,f13,f14,f15,f16,f17
	dc.l f18,f19,f20,f21,f22,f23,f24,f25,f26,f27,f28,f29,f30,f31
	dc.l f32,f33,f34,f35,f36,f37,f38,f39,f40,f41,f42,f43,f44,f45,f46
	
f1: dc.b "*:\DATA\GESCH.OUT",0
f2: dc.b "*:\DATA\GESCH.QIX",0
f3: dc.b "*:\DATA\KULTUR.OUT",0
f4: dc.b "*:\DATA\KULTUR.QIX",0
f5: dc.b "*:\DATA\WISSEN.OUT",0
f6: dc.b "*:\DATA\WISSEN.QIX",0
f7: dc.b "*:\DATA\TECHNIK.OUT",0
f8: dc.b "*:\DATA\TECHNIK.QIX",0
f9: dc.b "*:\DATA\POL.OUT",0
f10: dc.b "*:\DATA\POL.QIX",0
f11: dc.b "*:\DATA\ELEKTRO.OUT",0
f12: dc.b "*:\DATA\ELEKTRO.QIX",0
f13: dc.b "*:\DATA\GEO.OUT",0
f14: dc.b "*:\DATA\GEO.QIX",0
f15: dc.b "*:\DATA\AKTUELL.OUT",0
f16: dc.b "*:\DATA\AKTUELL.QIX",0
f17: dc.b "*:\DATA\AZSEC.OUT",0
f18: dc.b "*:\DATA\MEDBER.OUT",0
f19: dc.b "*:\DATA\MEDBER.QIX",0
f20: dc.b "*:\DATA\MEDBER1.OUT",0
f21: dc.b "*:\DATA\MEDBER1.QIX",0
f22: dc.b "*:\DATA\MEDBER2.OUT",0
f23: dc.b "*:\DATA\MEDBER2.QIX",0
f24: dc.b "*:\DATA\MEDBER3.OUT",0
f25: dc.b "*:\DATA\MEDBER3.QIX",0
f26: dc.b "*:\DATA\MEDBER4.OUT",0
f27: dc.b "*:\DATA\MEDBER4.QIX",0
f28: dc.b "*:\DATA\MEDBER5.OUT",0
f29: dc.b "*:\DATA\MEDBER5.QIX",0
f30: dc.b "*:\DATA\MEDBER6.OUT",0
f31: dc.b "*:\DATA\MEDBER6.QIX",0
f32: dc.b "*:\DATA\MEDBER7.OUT",0
f33: dc.b "*:\DATA\MEDBER7.QIX",0
f34: dc.b "*:\DATA\MEDBER8.OUT",0
f35: dc.b "*:\DATA\MEDBER8.QIX",0
f36: dc.b "*:\DATA\LEXQUIZ.QDB",0
f37: dc.b "*:\SYSDIR\START.HPG",0
f38: dc.b "*:\DATA\MPLUS9.QIX",0
f39: dc.b "*:\DATA\MPLUS10.QIX",0
f40: dc.b "*:\DATA\MPLUS11.QIX",0
f41: dc.b "*:\DATA\MPLUS12.QIX",0
f42: dc.b "*:\DATA\MPLUS13.QIX",0
f43: dc.b "*:\DATA\MPLUS14.QIX",0
f44: dc.b "*:\DATA\MPLUS15.QIX",0
f45: dc.b "*:\DATA\MPLUS16.QIX",0
f46: dc.b 0	; faux fichier, menu videotheque deja en RAM

fbase: dc.b "*:\DATA\LEXART.QDB",0
findex: dc.b "*:\DATA\LEXART.QIX",0
faz: dc.b "*:\DATA\AZPRI.OUT",0
fmedia: dc.b "*:\DATA\LEXMED.QIX",0
bmp_path: dc.b "*:\MEDIA\SMALLBMP\",0

t_hist: dc.b "Histoire",0
t_art: dc.b "Arts et Cultures",0
t_sci: dc.b "Sciences",0
t_tech: dc.b "Technologies",0
t_pol: dc.b "Politique et Social",0
t_info: dc.b "Informatique et Electronique",0
t_geo: dc.b "G‚ographie",0
t_actu: dc.b "Actualit‚s",0
t_az: dc.b "Lettre "
	_taz: dc.b "A",0
t_div: dc.b "Divers",0

tm_az: dc.b "Tout de A … Z!",0
tm_mon: dc.b "Autour du Monde",0
tm_nat: dc.b "Nature",0
tm_art: dc.b "Arts et Cultures",0
tm_tech: dc.b "Technique",0
tm_pol: dc.b "Politique et Soci‚t‚",0
tm_hist: dc.b "Histoire",0
tm_cel: dc.b "Personnalit‚s C‚lŠbres",0
tm_hom: dc.b "Homme et Sant‚",0

menu_page: dc.b "Retour Pages+ Pages-"
			; le '0' en menu_page+20
			dc.b 0,"Copier",0
fin_rech: dc.b "[3][ Recherche termin‚e. ][Confirmer]",0
rech_bug: dc.b "[3][ Recherche impossible sur | une ou plusieurs | chaines vides!][Corriger]",0
bug_mem: dc.b "[1][Pas assez de m‚moire | pour cette op‚ration!][Annuler]",0
bug_fichier: dc.b "[1][Erreur fichier | lors de la lecture! ][Annuler]",0
etroit: dc.b "[3][ Encyclo ne peut pas | fonctionner avec une | largeur "
			dc.b "inf‚rieure … 640!][Quitter]",0
le_inf:
	dc.b "VID="					; 0=pas d'intr, 1 video d'intro
rbvid:	dc.b "0",13,10,"AVI="	; M=m_player, A=aniplay
rbavi:	dc.b "M",13,10,"CD1="	; lecteur pour cd1
rbcd1:	dc.b "P",13,10,"CD2="	; lecteur pour cd2
rbcd2:	dc.b "P",13,10,"32B="	; 1=RVBx, 2=BVRx, 3=xRVB, 4=xBVR
rb32:	dc.b "1",13,10,"24B="	; 1=RVB, 2=BVR
rb24:	dc.b "1",13,10,"16B="	; 1=15nova, 2=15motor, 3=16falcon, 4=16nova
rb16:	dc.b "1",13,10,"08B="	; 1=NOVA, 2=plans
rb08:	dc.b "1",13,10,"04B="	; 1=plans separes, 2=plans entrelaces, 3=packed
rb04:	dc.b "1",13,10,"TT8="	; 1=tramage couleur, 0=16 niveaux de gris
rbtt:	dc.b "1",13,10,"SON="	; D=dma, S=replay16, s=replay8, Y=yamaha, P=psound
rbson:	dc.b "D",13,10,"FRE="	; 1=normale, 0=reduite
rbfre:	dc.b "1",13,10,"AID="	; aide video 0=non, 1=oui
rbaid:	dc.b "0",13,10
le_inf_fin:

	even

aides: dc.l aide0,aide1,aide2,aide3,aide4,aide5,aide6,aide7

aide0: dc.b "*:\MEDIA\AVI\VH_VH.AVI",0
aide1: dc.b "*:\MEDIA\AVI\VH_SS.AVI",0
aide2: dc.b "*:\MEDIA\AVI\VH_GAL.AVI",0
aide3: dc.b "*:\MEDIA\AVI\VH_OUT.AVI",0
aide4: dc.b "*:\MEDIA\AVI\VH_REG.AVI",0
aide5: dc.b "*:\MEDIA\AVI\VH_ANZ.AVI",0
aide6: dc.b "*:\MEDIA\AVI\VH_ART.AVI",0
aide7: dc.b "*:\MEDIA\AVI\VH_BIS.AVI",0

	even


appl_init: dc.l ai_cont,global,dum,appl_id,dum,dum
ai_cont: dc.w 10,0,1,0,0
mp_buffer: dc.w 'MP'
appl_id: dc.w 0,0
	dc.l mp_chaine
	dc.w 'EN',0,0	; j'attends le message 'EN' comme marque de fin.

graf_hand: dc.l gh_cont,global,dum,i_handle,dum,dum
gh_cont: dc.w 77,0,5,0,0		

open_work: dc.l ow_cont,ow_int,dum,intout,ptsout
ow_cont: dc.w 100,0,0,11,0,0,0,0,0,0,0,0
ow_int: dc.w 2,1,4,1,1,1,1,0,1,0,2

vro_cpyfm: dc.l vcp_cont,vcp_int,vcp_ptsin,dum,dum
vcp_cont: dc.w 109,4,0,1,0,0,0
mfdb_adr: dc.l 0,mfdb_dest
			dc.w 0
mfdb_dest dc.w 0,0,0,0,0,0,0,0,0,0
vcp_int: dc.w 3,0,1

hide_mouse: dc.l hm_cont,dum,dum,dum,dum
hm_cont: dc.w 123,0,0,0,0,0,0,0,0,0,0,0

show_mouse: dc.l sm_cont,sm_int,dum,dum,dum
sm_cont: dc.w 122,0,0,1,0,0,0,0,0,0,0,0
sm_int: dc.w 0

appl_exit: dc.l ae_cont,global,dum,intout,dum,dum
ae_cont: dc.w 19,0,1,0,0

close_work: dc.l cw_cont,dum,dum,dum,dum
cw_cont: dc.w 101,0,0,0,0,0,0,0,0,0,0,0

vq_extnd: dc.l ve_cont,ve_int,dum,intout,ptsout
ve_cont: dc.w 102,0,0,1,0,0,0,0,0,0,0,0
ve_int: dc.w 1

vsf_color: dc.l vsf_cont,vc_int,dum,dum,dum
vsf_cont: dc.w 25,0,0,1,0,0,0,0,0,0,0,0
vc_int: dc.w 0

vr_recfl: dc.l vrec_cont,dum,vrec_int,dum,dum
vrec_cont: dc.w 114,2,0,0,0,0,0,0,0,0,0,0

vsf_interior: dc.l vi_cont,vi_int,dum,dum,dum
vi_cont: dc.w 23,0,0,1,0,0,0,0,0,0,0,0
vi_int: dc.w 1

shel_find: dc.l sf_cont,global,dum,dum,rsc_name,dum
sf_cont: dc.w 124,0,1,1,0

rsrc_load: dc.l rl_cont,global,dum,intout,rsc_name,dum
rl_cont: dc.w 110,0,1,1,0
rsc_name: dc.l _name

appl_find: dc.l af_cont,global,dum,mp_id,af_addr,dum
af_cont: dc.w 13,0,1,1,0
af_addr: dc.l _mp_name

appl_write: dc.l aw_cont,global,mp_id,dum,aw_addr,dum
aw_cont: dc.w 12,2,1,1,0
mp_id: dc.w -1,16
aw_addr: dc.l mp_buffer

evnt_timer: dc.l et_cont,global,et_int,dum,dum,dum
et_cont: dc.w 24,2,1,0,0
et_int: dc.w 250,0			; 1/4 sec


evnt_mesag: dc.l em_cont,global,dum,dum,em_add,dum
em_cont: dc.w 23,0,1,1,0
em_add: dc.l message
message: dcb.w 16

evnt_button: dc.l eb_cont,global,eb_int,eb_out,dum,dum
eb_cont: dc.w 21,3,5,0,0
eb_int: dc.w 1,1,1

rsrc_gaddr: dc.l rg_cont,global,rg_int,dum,dum,tree
rg_cont: dc.w 112,2,1,0,1
rg_int: dc.w 0,0

menu_bar: dc.l mb_cont,global,mb_int,dum,tree,dum
mb_cont: dc.w 30,1,1,1,0
mb_int: dc.w 1

menu_tnormal: dc.l mt_cont,global,mt_int,dum,tree,dum
mt_cont: dc.w 33,2,1,1,0
mt_int: dc.w 0,1

alert_box: dc.l ab_cont,global,ab_int,intout,ab_addrin,dum
ab_cont: dc.w 52,1,1,1,0
ab_int: dc.w 1
ab_addrin: dc.l 0

wind_update: dc.l wu_cont,global,wu_int,dum,dum,dum
wu_cont: dc.w 107,1,1,0,0

form_dial: dc.l fd_cont,global,fd_int,dum,dum,dum
fd_cont: dc.w 51,9,0,1,0
fd_int: dc.w 0,0,0,0,0,0,0
fd_maxi: dc.w 640,480

objc_draw: dc.l od_cont,global,od_int,dum,tree,dum
od_cont: dc.w 42,6,1,1,0
rect_dial: dc.w 0,0,0
od_int: dc.w 0
rect: dc.w 7,0,0,0,0

form_center: dc.l fc_cont,global,dum,rect,tree,dum
fc_cont: dc.w 54,0,5,1,0	

form_dial2: dc.l fd_cont,global,rect_dial,dum,dum,dum

form_do: dc.l do_cont,global,do_int,intout,tree,dum
do_cont: dc.w 50,1,1,1,0
do_int: dc.w 0			; no edit object

rsrc_free: dc.l rf_cont,global,dum,dum,dum,dum
rf_cont: dc.w 111,0,1,0,0

v_gtext: dc.l vt_cont,vt_int,vt_pts,dum,dum
vt_cont: dc.w 8,1,0,1000,0,0,0,0,0,0,0,0

vst_align: dc.l va_cont,va_int,dum,dum,dum
va_cont: dc.w 39,0,0,2,0,0,0,0,0,0,0,0
va_int: dc.w 0,5

vst_height: dc.l vp_cont,dum,vp_int-2,dum,dum
vp_cont: dc.w 12,1,0,0,0,0,0,0,0,0,0,0

vst_color: dc.l vc_cont,vp_int,dum,dum,dum
vc_cont: dc.w 22,0,0,1,0,0,0,0,0,0,0,0
	
vst_effects: dc.l vf_cont,vp_int,dum,dum,dum
vf_cont: dc.w 106,0,0,1,0,0,0,0,0,0,0,0

graf_mouse: dc.l mf_cont,global,mf_int,intout,mouse_def,dum
mf_cont: dc.w 78,1,1,1,0
mf_int: dc.w 0
mouse_def: dc.l 0

v_pline: dc.l vl_cont,dum,vl_pts,dum,dum
vl_cont: dc.w 6,2,0,0,0,0,0,0,0,0,0,0

vsl_color: dc.l vsl_cont,vsl_int,dum,dum,dum
vsl_cont: dc.w 17,0,0,1,0,0,0,0,0,0,0,0
vsl_int: dc.w 1

vs_color: dc.l vs_cont,vsc_int,dum,intout,dum
vs_cont: dc.w 14,0,0,4,0,0,0,0,0,0,0,0

vq_color: dc.l vq_cont,vq_int,dum,intout,dum
vq_cont: dc.w 26,0,0,2,0,0,0,0,0,0,0,0
vq_int: dc.w 0,1

vqt_attributes: dc.l vqt_cont,dum,dum,intout,petit
vqt_cont: dc.w 38,0,0,0,0,0,0,0,0,0,0,0

fileselect: dc.l fs_cont,global,dum,intout,fs_addrin,dum
fs_cont: dc.w 91,0,2,3,0
fs_addrin: dc.l path,file,select

	if 0

evnt_keybd: dc.l ek_cont,global,dum,intout,dum,dum
ek_cont: dc.w 21,3,5,0,0
	
form_error: dc.l fe_cont,global,fe_int,dum,dum,dum
fe_cont: dc.w 53,1,1,0,0
fe_int: dc.w 0

wind_update: dc.l wu_cont,global,wu_int,dum,dum,dum
wu_cont: dc.w 107,1,1,0,0

wind_get: dc.l wg_cont,global,wg_int,window0,dum,dum
wg_cont: dc.w 104,2,5,0,0
wg_int: dc.w 0,4

wind_calc: dc.l wc_cont,global,wc_int,wc_int+2,dum,dum
wc_cont: dc.w 108,6,5,0,0

wind_create: dc.l wcr_cont,global,wc_int+2,wc_int+2,dum,dum
wcr_cont: dc.w 100,5,1,0,0

wind_open: dc.l wo_cont,global,wc_int+2,dum,dum,dum
wo_cont: dc.w 101,5,1,0,0

wind_set: dc.l ws_cont,global,ws_int,dum,dum,dum
ws_cont: dc.w 105,6,1,0,0

wind_close: dc.l wcl_cont,global,ws_int,dum,dum,dum
wcl_cont: dc.w 102,1,1,0,0

wind_delete: dc.l wd_cont,global,ws_int,dum,dum,dum
wd_cont: dc.w 103,1,1,0,0

vsf_color: dc.l vc_cont,vi_int,dum,dum,dum
vc_cont: dc.w 25,0,0,1,0,0,0,0,0,0,0,0

	endif

vidtek_info: dc.b "[0][Pendant l'accŠs vid‚othŠque |seule l'icone FENETRES"
			dc.b " et|la fonction RETOUR sont|accessibles.][Continuer|Annuler]",0
select: dc.b "Sauver article dans...",0
alert_info: dc.b "[0][ Encyclo V"
				VER_STR
				dc.b ", pilote de |"
				dc.b "'Mon Encyclop‚die' (c) M.A. |"
				dc.b "     gtello@wanadoo.fr][Suite]",0
quizz_faux: dc.b "[3][ La bonne r‚ponse ‚tait | la r‚ponse "
_qfaux: dc.b "1 ][Dommage!]",0
quizz_fin: dc.b "[3][ Fin du Quizz! | | Votre score est | de "
_qfin: dc.b "09/10.][Merci!]",0
alert_quit: dc.b "[2][ Quitter Encyclo ?][Oui|Non]",0
pas_cd: dc.b "[3][Ins‚rer le CD nø"
_pas_cd1: dc.b "1 | Mon Encyclop‚die | dans le lecteur "
_pas_cd2: dc.b "A: !][Confirmer|Annuler|R‚glage]",0
titre: dc.b "*:\Media\Avi\Titre.avi",0
lecteur: dc.b 'P'
_mp_name: dc.b "M_PLAYER",0
_an_name: dc.b "ANIPLAY ",0

	even
	
	if REG=1
_name: dc.b "ENCYCLO.RSC"
	else
_name: dc.b "ENCY_SW.RSC"
	endif
			 dcb.b 200,0
			 even

	bss
	
dta: ds.b 44
	;----- ne pas separer
i_handle: ds.w 1	; aes handle au depart avec graf_handle
char_size:
	ds.w 4
	; la non plus
screenw: ds.w 1
screenh: ds.w 1
planes: ds.w 1

index_h: ds.w 1	; handle du fichier index
base_h: ds.w 1 	; handle du fichier base			
media_h: ds.w 1	; handle de LEXMED.QIX
quizz_h: ds.w 1	; handle de LEXQUIZ.MED
mov_h: ds.w 1
total: ds.l 1
global: ds.w 16	
intout: ds.w 100

wu_int: ds.w 1
		ds.w 1		; pur Height (dans ptsin)
vp_int: ds.w 1

ptsout: ds.w 100
dum: ds.l 4
tree: ds.l 1
vcp_ptsin: ds.w 8
palette: ds.l 256	; maxi c'est en 32 bits
pal_vdi: ds.w 256*3+2	; index debut + nombre + couleurs,palette IMAGE 256c
pal_sav: ds.w 256*3+2	; idem, palette de travail
pal_gem: ds.w 256*3+2	; idem, palette du bureau
vrec_int: ds.w 4
mp_chaine: ds.b 200
taille: ds.w 7	; x,y,l,h de la fenetre
	; l,h de la fenetre en caracteres
	; l fenetre en gros caracteres
petit: ds.w 4	; taille+14: tailles d'un caractere + cellule en normal
grand: ds.w 4	; taille+22: tailles en grand
eb_out: ds.w 1
mx: ds.w 1
my: ds.w 1
eb_but: ds.w 1
eb_kbd: ds.w 1

pages: ds.b 128*NIVEAUX		; 10 niveaux! 
	; BYTE numero du fichier ou 0 si page vide
	; BYTE type du fichier (0=OUT, 1=QIX, 2=AZSEC,3LEXART.QIX,4article,
	;								(7 videotheque,8 sous videotheque)
	; WORD niveau pour un OUT
	; LONG premier index	; vers quoi ca pointe dans le ficheir a suivre
	; LONG second index
	; CHAR 64 octets de titre
	; WORD numero de la premiere ligne affichee (si sur plusieurs pages)
	; WORD nombre total de lignes dans la page
	; LONG adresse d'un bloc suppementaire eventuel

off_size: ds.w 1		; byte pour charge_fichier
f_handle: ds.w 1
f_offset: ds.l 1
f_size: ds.l 1
	
fichier_actuel: ds.w 1	; BYTE!!! numero du fichier actuellement en RAM
								; 0 si personne
fichier_ptr: ds.l 1		; adresse en RAM du fichier actuel
fichier_fin: ds.l 1		; pointeur vers la fin du fichier charg‚
	; au dela de 10, tout se decale et le premier est perdu!!!
lignes: ds.b 256*512		; chaque ligne:
		; byte ETAT: 0->derniere, FF->ligne occupee
		; byte type: 1 texte
		; si texte-> ubyte longueur 0-254 puis les octets
pointeurs: ds.b 16*512	; chaque ligne, 16 octets
vt_pts: ds.w 2				; x et y pour une ligne de texte
vl_pts: ds.w 4				; x,y x',y' pour une ligne de soulignement
vt_int: ds.w 256			; la chaine de texte		
buffer:	ds.b 1024		; 1 kilo a tout hasard
comp_bmp: ds.w 1			; 0000 si non compress‚, 0002 si compress‚
mouse: ds.w 1
basepage: ds.l 1
err: ds.b 1					; FF si une erreur malloc/lecture fichier.
mxcall: ds.b 1				; FF si appel MXALLOC support‚
stack: ds.l 1				; pile en cas de superviseur
kbshift: ds.l 1
is_bar: ds.b 1				; FF pour bmp_vers_vdi si c'est la barre de menu
is_petit: ds.b 1			; FF si image dans article
verif: ds.b 1				; FF si la premiere verification est passee
yamaha_flag: ds.b 1		; FF si du son, 00 si son termin‚
code_cd: ds.w 1
vsc_int: ds.w 4
	; line_buffer aussi utilise par le QUIZZ comme marque des questions
line_buffer: ds.b 2032	; pour une ligne en mode 16 couleurs (avant les plans)
line_err1:	ds.b 2032
line_err2: ds.b 2032		; pour les erreurs de FLOYD
path: ds.b 200
file: ds.b 16
					; ne pas separer!!!
chaine3: ds.b 32			; -32    celle courante
rech_flag: ds.b 1			; 0      FF si recherche en cours
rech_mode: ds.b 1			; +1     mode de recherche
rech_off: ds.l 1			; +2     offset du prochain bloc a rechercher
rech_ptr: ds.l 1			; +6     pointeur dans le bloc du prochain article
chaine1: ds.b 34			; +10		WORD taille + 30 + zero
chaine2: ds.b 34			; +44    idem
rech_bloc: ds.b 613*52	; +78    613 mots de 52 octets
					; jusqu'ici!!!
venant_recherche: ds.b 1	; byte FF pour detourner traiter lien
is_video: ds.b 1				; FF si dans la videotheque (limite les icones)

	ds.l 1024
_pile:
   
   
   END
   
   end