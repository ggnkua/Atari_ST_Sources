	text
	bra	vive_le_dolmen
* Quelques XREF pour la lib *
	XREF	evnt,hauteur_menu,opt_num,opt_arbre,wd_create_form

	XDEF	options

	include	gemdos.i
	include	vdi.i
	include	aes.i
	include	tosinit.i
	include	zlib.i
	include	structs.s
	include	util.i
	include	d:\code\zvue\rsc.s

	XREF	ligne_de_commande_adr+1


	text
vive_le_dolmen
	TOSinit	30000	; 30k de pile, inits AES + VDI

	ZLIBinit	#rsc_name,#MENU	; chargement ressource, affichage menu

	XREF	nbr_color
	XREF	planes
	move.w	planes,d0
	move.w	#1,d1
	lsl.w	d0,d1
	move.w	d1,nbr_color

	lea		save_color_buff,a6
	subq.w		#1,d1
	move.w		d1,d7
.loop_save_color
	vq_color	d7,#1
	move.w		intout,(a6)+
	move.w		intout+2,(a6)+
	move.w		intout+4,(a6)+
	move.w		intout+6,(a6)+
	dbra		d7,.loop_save_color

	XDEF		exit_prog
	XREF		_INSTALL_LUT
	bsr.l		_INSTALL_LUT

;	move.l		#ldcmd,ligne_de_commande_adr
	move.l		ligne_de_commande_adr,a6
	addq.l		#1,a6
	Fsetdta		#dta
	Fsfirst		#%111,a6
	tst.w		d0
	bmi		exit_prog

	XREF		wd_create_img
	move.l		ligne_de_commande_adr,d0
	addq.l		#1,d0
	wd_create	d0,#wd_create_img,#10,hauteur_menu,#0,#0

* Initialisations de quelques variables du soft *
	graf_mouse	#0
	bra		evnt

options
	move.l		opt_arbre,d0
	move.w		opt_num,d1
	cmp.l		MENU_adr,d0
	beq		menu_selected
	rts

menu_selected
	cmp.w		#M_INFO,d1
	beq		ourvre_info
	cmp.w		#M_QUIT,d1
	beq		exit_prog
	rts
ourvre_info
	rsrc_gaddr	#0,#INFO
	wd_create	addr_out,#wd_create_form,#-1,#0,#0,#0
	rts
exit_prog
	lea		save_color_buff,a6
	move.w		nbr_color,d7
	subq.w		#1,d7
.loop_save_color
	vs_color	(a6)+,(a6)+,(a6)+,(a6)+
	dbra		d7,.loop_save_color

	bsr		gem_exit
	clr.w		-(sp)
	trap		#1


	data
	XDEF	appl_name
appl_name	dc.b	" Zvue v1.0 ",0
	even
rsc_name	dc.b	"ZVUE.RSC",0
		even
;ldcmd		dc.b	20,'d:\code\zvue\yop.gif',0,0,0,0,0
;		even
	bss
save_color_buff	ds.w	256*4
dta	ds.b		44