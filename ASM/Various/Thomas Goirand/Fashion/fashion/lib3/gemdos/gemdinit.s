********************************************************
***** Initialisation des differents element du TOS *****
********************************************************
	text
	XREF	GEMDOSinit_END,stack_start,stack_end
	XREF	base_page_adr,ligne_de_commande_adr

	XDEF	GEMDOSinit_START,dta_buf
	include	gemdos.i
*	include	aes.i
*	include	vdi.i
*****************************
*** Initialisation GEMDOS ***
*****************************
* structure de la page de base *
	rsreset
p_lowtpa	rs.l	1	; pointeur sur le debut de la TPA (Transient Program Area)
p_hitpa		rs.l	1	; pointeur sur la fin de la TPA+1
p_tbase		rs.l	1	; pointeur sur la section text
p_tlen		rs.l	1	; longueur de la  section text
p_dbase		rs.l	1	; pointeur sur la section data
p_dlen		rs.l	1	; longueur de la  section data
p_bbase		rs.l	1	; pointeur sur la section bss
p_blen		rs.l	1	; longueur de la  section bss
p_dta		rs.l	1	; pointeur sur la dta du processe
p_parent	rs.l	1	; pointeur sur la base-page du parent
p_reserved	rs.l	1	; 4 octet inutilise et reserve...
p_env		rs.l	1	; pointeur sur la chaine d'environnement
p_undef		rs.b	80	; 80 octet reserve et inutilise
p_cmdlin	rs.b	128	; 128 octet representant la ligne de commande

GEMDOSinit_START
	movea.l	4(sp),a5		; adresse de la base-page
	move.l	a5,base_page_adr
	move.l	a5,d0
	add.l	#128,d0			; celle de la ligne de commande
	move.l	d0,ligne_de_commande_adr

	move.l	a5,base_page_adr	; calcul la longueur du .PRG
	move.l	p_tlen(a5),d0
	add.l	p_dlen(a5),d0	; la taille de la pile est incluse dans la BSS...
	add.l	p_blen(a5),d0
	add.l	#256,d0

	move.l	#stack_start,sp

	mshrink	d0,a5
	tst.l	d0
	bge.s	suite_GEMDOSstartup

	bsr	tst_gemdos_error

	clr.w	-(sp)
	trap	#1

suite_GEMDOSstartup
	Fsetdta		#dta_buf

	jmp	GEMDOSinit_END		; Fin de m'init GEMDOS
	bss
dta_buf	ds.b	sizeof_dta
	text
************************** Fin de l'initialiation GEMDOS ***********************
