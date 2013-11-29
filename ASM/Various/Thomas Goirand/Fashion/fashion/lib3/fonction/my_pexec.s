*---------------------------------------------------------------------
* Pexec sans trap
*---------------------------------------------------------------------
* Realise par Thomas GOIRAND avec l'aide de Xavier Joubert
* et a partir d'un petit relocateur fourni par CENTEK (merci David).
*---------------------------------------------------------------------
* La fonction PEXEC est bugge : impossible de passer une
* ligne de commande vide quand le bureau vous a passe une
* ligne de commande. Resultat : la seul technique c'est de
* se refaire un Pexec soit-meme !!!
*---------------------------------------------------------------------

* structure de la page de base du programme a executer
	rsset	-256

xp_lowtpa	rs.l	1
xp_hightpa	rs.l	1
xp_tbase	rs.l	1
xp_tlen		rs.l	1
xp_dbase	rs.l	1
xp_dlen		rs.l	1
xp_bbase	rs.l	1
xp_blen		rs.l	1
xp_dta		rs.l	1
xp_parent	rs.l	1
xp_reserved	rs.l	1
xp_env		rs.l	1
xp_undef	rs.b	80
xp_cmdlin	rs.b	128


*/------------------------------------/*
		
k_prgload:	* sur la pille :
			* long: pointeur sur chaine "C:\nom_du\fichier\programme",
			* pas de retour : au moment du Pterm, votre application ne reprend
			* pas la main (vous avez envis de detourner le Pterm ??? pas moi...)
		
*/------------/*
		
LOCAL_SPACE	set	7*4+2*2+10*1	; de la place pour la routine sauve sur la pile...

*/------------/*
		
* paramŠtres:
		
		RSSET	8
		
cprg_file		rs.l	1		; adresse du programme en memoire
		
		*/------------/*

* variables locales:
		
		RSSET	-LOCAL_SPACE

cprg_exesize	rs.l	1	; taille du code executable
cprg_flen		rs.l	1	; taille du fichier executable
cprg_dummy		rs.l	1	; ??? c'est quoi M. CENTEK
cprg_handle		rs.w	1	; handle du fichier a executer

cprg_header		rs.w	1	; header 601A (-> c'est un executable
cprg_text		rs.l	1	; taille de la section texte
cprg_data		rs.l	1	; taille de la section data
cprg_bss		rs.l	1	; taille de la section bss
cprg_symbol		rs.l	1	; taille des symbole
cprg_resvd		rs.b	10

*/------------------------------------/*
		
	link	a6,#-LOCAL_SPACE		; reserve de la place sur la pile
	movem.l	d2-a5,-(sp)

	Fopen	#0,cprg_file(a6)
	move.w	d0,cprg_handle(a6)
		
	Fseek	#2,cprg_handle(a6),#0
	move.l	d0,cprg_flen(a6)
		
	cmpi.l	#$20,cprg_flen(a6)		; si fichier < 32 octet : erreur
	blt		.error
		
	Fseek	#0,cprg_handle(a6),#0

	move.l	a6,d0
	add.l	#cprg_header,d0
	Fread	d0,#28,cprg_handle(a6)
		
	cmpi	#$601a,cprg_header(a6)
	bne		.error
		
	move.l	cprg_text(a6),d0		; taille du PRG en ce refferant dans le header
	add.l	cprg_data(a6),d0
	add.l	cprg_bss(a6),d0
	move.l	d0,cprg_exesize(a6)
		
	move.l	cprg_flen(a6),d4		; compare taille fichier/taille prg
	cmp.l	d0,d4
	blt		.ok_size
	exg.l	d0,d4
	
.ok_size							; d0 = taille la plus grande
	add.l	#256,d0
	move.l	d0,d7

	Malloc	#-1
	cmp.l	d0,d7
	bgt		.error					; a-t-on assez de memoire

	Malloc	d0						; on Malloc toute la RAM disponible
	move.l	d0,d1					; on sauve l'adresse de la page de base pour l'empiler plus tard...

	add.l	#256,d0
	move.l	d0,cprg_file(a6)		; cprg_file(a6) = debut du code executable

*~ creation de la base page ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*		
	move.l	d0,a5						; a5 = debut du code executable
	sub.l	#256,d0

	move.l	d0,xp_lowtpa(a5)			; adresse de debut de la base page

	add.l	cprg_exesize(a6),d0
	add.l	#256,d0
	move.l	d0,xp_hightpa(a5)			; adresse de fin du prg

	move.l	a5,xp_tbase(a5)				; debut de la section text

	move.l	cprg_text(a6),xp_tlen(a5)	; longueur de la section text

	move.l	a5,d4
	add.l	cprg_text(a6),d4
	move.l	d4,xp_dbase(a5)				; debut de la section data

	move.l	cprg_data(a6),xp_dlen(a5)	; longueur de la section data

	add.l	cprg_data(a6),d4
	move.l	d4,xp_bbase(a5)				; debut de la section bss

	move.l	cprg_bss(a6),xp_blen(a5)	; longueur de la section bss


	Fsetdta	#pexec_dta

	move.l	#pexec_dta,xp_dta(a5)		; adresse de la dta
	move.l	base_page_adr,xp_parent(a5)	; pointeur sur la base page du parent
	move.l	#0,xp_reserved(a5)			; unsued
	move.l	#pexec_env,xp_env(a5)		; pointeur sur la chaine d'env
	move.l	#0,xp_cmdlin(a5)			; la ligne de commande est VIDE dans notre cas


	Fread	cprg_file(a6),#-1,cprg_handle(a6)
		
	Fclose	cprg_handle(a6)
		
*~ Debut du relocateur ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*/------------/*

	move.l	cprg_file(a6),a0	; a0,a1,d0 debut prg
	move.l	a0,d0
	move.l	a0,a1
	add.l	cprg_text(a6),a1
	add.l	cprg_data(a6),a1	; a1 et a2 adresse symbol
	move.l	a1,a2
	add.l	cprg_symbol(a6),a1	; a1 = adresse fin symbol = fixup offset

	tst.l	(a1)
	beq		.makebss			; si (a1)=0 alors pas de reloc

	add.l	(a1)+,a0			; a0 = premiere instruction a reloger
	add.l	d0,(a0)				; on reloge le premier mot
		
	clr.l	d4
.again
	move.b	(a1)+,d4			; boucle de relocation
	beq		.makebss
	cmpi	#1,d4
	bne		.normal
	lea		254(a0),a0
	bra		.again
		
.normal
	lea		(a0,d4.w),a0
	add.l	d0,(a0)
	bra		.again

*~ Creation de la BSS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

.makebss
	move.l	cprg_bss(a6),d0
	lsr.l	d0
.bssloop
	clr.w	(a2)+
	dbra	d0,.bssloop

;	mshrink	cprg_exesize(a6),cprg_file(a6),#0	; vilain

.end

;	move.l	d1,a0		; on place l'adresse de la page de base dans a0
;	move.l	d1,4(sp)	; puis dans 4(sp)
;	jmp		$100(a0)	; puis on saute dans le code executable du prg reloge : on a fini !!!

	move.l	cprg_file(a6),d0
	movem.l	(sp)+,d2-a5
	unlk	a6
	rts
		
*/------------/*
		
.error	move.l	#-1,cprg_file(a6)	; si il y a retour, c'est qu'il y a erreur !
		bra		.end

	bss
pexec_dta	ds.b	21+1+2+2+4+14	; dta pour le Pexec a la main
	data
	even
pexec_env	dc.b	0,0,0,0
	even
	text

*-------------------------------------------------------------------------*

