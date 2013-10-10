*** gestion d'erreur ***
	XDEF	tst_gemdos_error
	text
tst_rts		macro
	tst.l	d0
	bge.s	*+4
	rts
	endm
tst_gemdos_error::
	move.l	d0,-(sp)
	move.l	#error_forms,a6
.loop
	cmp.l	#end_error_forms,a6
	beq	no_common_error
	cmp.b	(a6)+,d0
	bne	.loop
affiche_erreur
	move.w		#1,int_in
	move.l		a6,addr_in

	move.l		#aes_params,d1
	move.l		#200,d0
	trap		#2

	move.l		(sp)+,d0
	rts
no_common_error
*	Un petit form_error a la main... ca fait plaisir de temps en temps !
*--------------------------------------------------------------------------------------------------------------------------*
	data
aes_params
	dc.l	control
	dc.l	global,int_in,int_out,addr_in,addr_out
control	dc.w	52,1,1,1,0	; contient les parametres pour form_alert
	bss
global		ds.w	14
int_in		ds.w	16
int_out		ds.w	7
addr_in		ds.l	3
addr_out	ds.l	1
	data
error_forms
	even
	dc.b	-1,"[1][ Erreur Generale ][ Ok ]",0,0
	even
	dc.b	-2,"[1][ Unite de disquette | pas prete ][ Ok ]",0,0
	even
	dc.b	-3,"[1][ Erreur inconue ][ Ok ]",0,0
	even
	dc.b	-4,"[1][ Erreur CRC ][ Ok ]",0,0
	even
	dc.b	-5,"[1][ Bad request, | instruction incorrecte ][ Ok ]",0,0
	even
	dc.b	-6,"[1][ Seek Error, piste non trouv‚e ][ Ok ]",0,0
	even
	dc.b	-7,"[1][ Unknown Media ][ Ok ]",0,0
	even
	dc.b	-8,"[1][ Secteur non trouve ][ Ok ]",0,0
	even
	dc.b	-9,"[1][ Pas de papier ][ Ok ]",0,0
	even
	dc.b	-10,"[1][ Erreur d'ecriture ][ Ok ]",0,0
	even
	dc.b	-11,"[1][ Erreur de lecture ][ Ok ]",0,0
	even
	dc.b	-12,"[1][ Erreur generale ][ Ok ]",0,0
	even
	dc.b	-13,"[1][ Disquette protege en ecriture ][ Ok ]",0,0
	even
	dc.b	-14,"[1][ La disquette a ete change ][ Ok ]",0,0
	even
	dc.b	-15,"[1][ Peripherique inconnu ][ Ok ]",0,0
	even
	dc.b	-16,"[1][ Bad sertors | (lors de la verification) ][ Ok ]",0,0
	even
	dc.b	-17,"[1][ Introduire une disquette | (avec une unite de | disquette connectee) ][ Ok ]",0,0
	even

	dc.b	-32,"[1][ Numero de fonction incorrect ][ Ok ]",0,0
	even
	dc.b	-33,"[1][ Fichier non trouve ][ Ok ]",0,0
	even
	dc.b	-34,"[1][ Nom de chemin non trouve | (path not found) ][ Ok ]",0,0
	even
	dc.b	-35,"[1][ Trop de fichier ouverts | (il ne reste plus de handle) ][ Ok ]",0,0
	even
	dc.b	-36,"[1][ Acces impossible ][ Ok ]",0,0
	even
	dc.b	-37,"[1][ Numero de handle incorrect ][ Ok ]",0,0
	even
	dc.b	-39,"[1][ Memoire insuffisante ][ Ok ]",0,0
	even
	dc.b	-40,"[1][ Adresse de bloc | memoire incorrecte ][ Ok ]",0,0
	even
	dc.b	-46,"[1][ Designation d'unite | de disque incorrecte ][ Ok ]",0,0
	even
	dc.b	-48,"[1][ Rename sur plusieur unite ][ Ok ]",0,0
	even
	dc.b	-49,"[1][ Plus d'autre fichier ][ Ok ]",0,0
	even

	dc.b	-64,"[1][ Range error | (limite depassees) ][ Ok ]",0,0
	even
	dc.b	-65,"[1][ Erreur interne de GEMDOS ][ Ok ]",0,0
	even
	dc.b	-66,"[1][ Le format du ficier de | programme est incorrect | (avec pexec) ][ Ok ]",0,0
	even
	dc.b	-67,"[1][ Erreur de bloc memoire ][ Ok ]",0,0
	even
end_error_forms
	dc.b	0,0
