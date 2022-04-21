; DEMO3.S :  Exemple de r‚cup‚ration de fichiers de d‚finition d'ic“nes
; -------    couleur cr‚‚s avec EIKONA. Ce listing est copiable librement,
;            vous pouvez le modifier et en utiliser les routines dans vos
;            programmes personnels...
;
;            B.MARICHAL  02.93
;

NOBJ		equ 17		; nombre d'objets dans l'arbre de menu
OB_SIZE		equ 24		; taille d'un objet

TRUECOLORS	equ $FFFF9800	; adresse des registres couleur FALCON

__MAXMTFCOUNT	equ 200		; nombre maxi de nouveaux motifs

ob_next		equ 0		; offsets des ‚l‚ments d'une structure OBJECT 
ob_head		equ 2
ob_tail		equ 4
ob_type		equ 6
ob_flags	equ 8
ob_state	equ 10
ob_spec		equ 12
ob_x		equ 16
ob_y		equ 18
ob_w		equ 20
ob_h		equ 22
	
WF_WORKXYWH	equ 4		; divers equates GEM
WF_NEWDESK	equ 14
FMD_START	equ 0
FMD_FINISH	equ 3

G_CICON		equ 33

text:
	movea.l	4(sp),a0	; d‚but de la basepage en a0
	move.l	12(a0),d0	; taille text
	add.l	20(a0),d0	; taille Data
	add.l	28(a0),d0	; taille Bss
	add.l	#$400,d0	; taille d'une petite pile
	
	move.l	d0,d1
	add.l	a0,d1		; longueur plus adresse
	andi.l	#-2,d1		; adresse paire
	movea.l	d1,sp		; installer la pile
	
	move.l	d0,-(sp)	; lib‚rer la m‚moire inoccup‚e
	move.l	a0,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)	; MSHRINK
	trap	#1
	lea.l	12(sp),sp
	
	move.l	#14,d0		; vider les registres (complŠtement inutile)
bcl0:	clr.l	-(sp)
	dbra	d0,bcl0
	movem.l	(sp)+,d0-7/a0-6
	
	bsr	main		; sauter au programme principal
	
	clr.w	-(sp)		; PTERM0
	trap	#1
	
*********************************************************** main

main:

work_in		equ 	0	; offsets des variables dans la pile
work_out	equ	20
mg_buff		equ	134
i		equ	166
wind		equ	168
bid		equ	176
mx		equ	178
my		equ	180
mk		equ	182
nk		equ	184
newx		equ	186
newy		equ	188
event		equ	190
end		equ	192
oldx		equ	194
oldy		equ	196
nbpl		equ	198

	lea.l	-200(sp),sp	; r‚server de la place dans la pile
	move.l	sp,a6		; sauver l'adresse dans A6 qui devient 'base'
	
	move.w	#98,d0		; mettons toutes ces variables … 0
	move.l	a6,a0
main_0	clr.w	(a0)+
	dbra	d0,main_0
	
	bsr	appl_init	; init AES
	move.w	d0,ap_id
	
	lea.l	work_in(a6),a0	; init VDI
	clr.w	d0
main_1	move.w	#1,(a0)+
	addi.w	#1,d0
	cmp.w	#10,d0
	blt	main_1
	move.w	#2,(a0)
	
	lea.l	work_in(a6),a0
	lea.l	vdih,a1
	lea.l	work_out(a6),a2
	bsr	v_opnvwk
	
	lea.l	work_out(a6),a0
	move.w	vdih,d0
	move.w	#1,d1
	bsr	vq_extnd
	move.w	8(a0),nbpl(a6)

	clr.w	d0		; curseur souris = flŠche
	lea.l	0,a0
	bsr	graf_mouse

	clr.w	d7		; convertir les coordonn‚es du menu en points
	lea.l	tr_MENU,a5
main_2	cmp.w	#NOBJ,d7
	bge	main_3
	addi.w	#1,d7
	clr.w	d0
	move.l	a5,a0
	move.w	nbpl(a6),d1
	bsr	rsrcc_obfix
	tst.w	d0
	bne.s	main_16
	st	end(a6)
main_16	adda.l	#OB_SIZE,a5
	bra.s	main_2	

main_3	clr.w	d7		; convertir les coordonn‚es du fond en points
	lea.l	newdesk,a5
main_17	cmp.w	#3,d7
	bge	main_19
	addi.w	#1,d7
	clr.w	d0
	move.l	a5,a0
	move.w	nbpl(a6),d1
	bsr	rsrcc_obfix
	tst.w	d0
	bne	main_18
	st	end(a6)
main_18	adda.l	#OB_SIZE,a5
	bra.s	main_17

main_19	tst.w	end(a6)
	beq	main_20
	lea.l	init_err,a0
	bsr	form_alert
	bsr	rsrcc_free
	
	move.w	vdih,d0
	jsr	v_clsvwk
	jsr	appl_exit
	clr.w	-(sp)
	trap	#1
	
main_20	clr.w	d0		; calculer les dimensions du bureau
	move.w	#WF_WORKXYWH,d1
	move.w	#wind,d2
	lea.l	0(a6,d2),a0
	lea.l	2(a6,d2),a1
	lea.l	4(a6,d2),a2
	lea.l	6(a6,d2),a3
	bsr	wind_get

	subi.w	#1,0(a6,d2)	; agrandir un peu pour ne plus voir la bordure
	subi.w	#1,2(a6,d2)	; (dans le tableau wind)
	addi.w	#2,4(a6,d2)
	addi.w	#2,6(a6,d2)
	
	lea.l	newdesk,a0		; modifier quelque peu le fond
	move.w	0(a6,d2),ob_x(a0)	; ajuster les dimensions du fond
	move.w	2(a6,d2),ob_y(a0)
	move.w	4(a6,d2),ob_w(a0)
	move.w	6(a6,d2),ob_h(a0)
	
	clr.w	d0			; installer ce nouveau bureau
	move.w	#WF_NEWDESK,d1
	move.l	#newdesk,d2
	move.l	d2,d3
	swap	d2
	clr.w	d4
	clr.w	d5
	bsr	wind_set
	
	move.w	#FMD_FINISH,d0		; actualiser l'image
	clr.l	-(sp)
	clr.l	-(sp)
	move.w	#wind,d2
	move.w	0(a6,d2),-(sp)
	move.w	2(a6,d2),-(sp)
	move.w	4(a6,d2),-(sp)
	move.w	6(a6,d2),-(sp)
	bsr	form_dial
	lea.l	16(sp),sp
	

	move.w	#1,d0		; afficher le menu
	lea.l	tr_MENU,a0
	bsr	menu_bar
	
main_4	tst.w	event(a6)	; si aucun ‚vŠnement ne reste … traiter...
	bne	main_5
	
	move.w	#18,d0		; faire un evnt_multi qui d‚tectera clics
	move.w	#2,-(sp)	; souris et messages
	move.w	#1,-(sp)
	move.w	#1,-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	pea	mg_buff(a6)
	clr.w	-(sp)
	clr.w	-(sp)
	pea	mx(a6)
	pea	my(a6)
	pea	mk(a6)
	pea	bid(a6)
	pea	bid(a6)
	pea	nk(a6)
	bsr	evnt_multi
	lea.l	58(sp),sp
	move.w	d0,event(a6)	; stocker l'‚vŠnement dans event

main_5	move.w	d0,d1		; y a-t-il eu un ‚vŠnement 'message' ?
	andi.l	#16,d1
	beq	main_9		; non, sauter plus loin
	
	lea.l	mg_buff(a6),a5	; l'‚vŠnement est-il un clic dans un menu ?
	move.w	(a5),d1
	cmp.w	#10,d1
	bne	main_8		; non, sauter plus loin
	
	move.w	8(a5),d1	; ‚tait-ce l'entr‚e 7 ?
	cmp.w	#7,d1
	bne	main_6		; non, sauter plus loin
	
	move.w	#2,d0		; oui, afficher boŒte d'alerte...
	lea.l	alerte,a0
	bsr	form_alert
	bra.s	main_7		; ...et sauter un peu plus loin
	
main_6	cmp.w	#16,d1		; ‚tait-ce l'entr‚e 16 ?
	bne	main_7		; non, sauter plus loin
	move.w	#1,end(a6)	; oui, positionner flag de fin...

main_7	move.w	6(a5),d0	; remettre le titre de menu en blanc
	move.w	#1,d1
	lea.l	tr_MENU,a0
	bsr	menu_tnormal
		
main_8	andi.w	#$ffef,event(a6)	; annuler le bit 'message' de event
	bra	main_15
	
main_9	move.w	event(a6),d0	; y a-t-il eu un ‚vŠnement 'clic' ?
	andi.l	#2,d0
	beq	main_15		; non, sauter plus loin...
	
	clr.w	d0		; oui, trouver l'objet cliqu‚
	move.w	#1,d1
	move.w	mx(a6),d2
	move.w	my(a6),d3
	lea.l	newdesk,a0
	bsr	objc_find
	move.w	d0,i(a6)	; stocker dans la variable i
	
	cmp.w	#1,d0		; a-t-on cliqu‚ dans le vide ???
	blt	main_13		; il faut croire... sauter...
	
	lea.l	mx(a6),a0	; non, v‚rifier l'‚tat actuel des boutons
	lea.l	my(a6),a1
	lea.l	mk(a6),a2
	lea.l	bid(a6),a3
	bsr	graf_mkstate
	tst.w	mk(a6)		; le bouton a-t-il ‚t‚ relƒch‚ ?
	beq	main_12		; oui, sauter...
	
	lea.l	newdesk,a0	; non, stocker les anciennes coordonn‚es
	move.w	i(a6),d0	; de l'objet dans oldx et oldy
	bsr	getx
	move.w	d0,oldx(a6)
	lea.l	newdesk,a0
	move.w	i(a6),d0
	bsr	gety
	move.w	d0,oldy(a6)
	
	lea.l	newdesk,a0	; d‚placer le 'fant“me' de l'ic“ne
	move.w	i(a6),d0
	mulu	#OB_SIZE,d0
	adda.l	d0,a0
	move.w	ob_w(a0),-(sp)
	move.w	ob_h(a0),-(sp)
	move.w	oldx(a6),-(sp)
	move.w	oldy(a6),-(sp)
	lea.l	wind(a6),a0
	move.w	(a0),-(sp)
	move.w	2(a0),-(sp)
	move.w	4(a0),-(sp)
	move.w	6(a0),-(sp)
	pea	newx(a6)	; newx et newy re‡oivent les nouvelles
	pea	newy(a6)	; coordonn‚es de l'objet
	bsr	graf_dragbox
	lea.l	24(sp),sp
	
	lea.l	newdesk,a0	; fixer ces nouvelles coordonn‚es
	move.w	i(a6),d0
	move.w	newx(a6),d1
	bsr	setx
	lea.l	newdesk,a0
	move.w	i(a6),d0
	move.w	newy(a6),d1
	bsr	sety
	
	lea.l	newdesk,a0	; pr‚parer un pointeur sur l'objet
	move.w	i(a6),d1
	mulu	#OB_SIZE,d1
	adda.l	d1,a0

	move.w	#FMD_FINISH,d0	; redessiner l'endroit o— se trouvait
	clr.w	-(sp)		; l'ic“ne avant d‚placement
	clr.w	-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	move.w	oldx(a6),-(sp)
	move.w	oldy(a6),-(sp)
	move.w	ob_w(a0),-(sp)
	move.w	ob_h(a0),-(sp)
	bsr	form_dial
	lea.l	16(sp),sp
	
	move.w	#FMD_FINISH,d0	; redessiner l'endroit o— se trouve
	clr.w	-(sp)		; l'ic“ne … pr‚sent
	clr.w	-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	move.w	newx(a6),-(sp)
	move.w	newy(a6),-(sp)
	move.w	ob_w(a0),-(sp)
	move.w	ob_h(a0),-(sp)
	bsr	form_dial
	lea.l	16(sp),sp
	bra	main_14		; sauter plus loin...
	
main_12	lea.l	newdesk,a0	; il y a eu simple clic, trouver les
	move.l	a0,a5		; coordonn‚es de l'objet en question
	move.w	i(a6),d0
	bsr	getx
	move.w	d0,d1
	move.w	i(a6),d0
	bsr	gety
	move.w	d0,d2
	
	move.w	i(a6),d3	; pr‚parer un pointeur sur cet objet
	mulu	#OB_SIZE,d3
	adda.l	d3,a5
	
	eori.w	#1,ob_state(a5)	; modifier son ‚tat
	
	move.w	#FMD_FINISH,d0	; redessiner l'objet
	clr.w	-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	move.w	d1,-(sp)
	move.w	d2,-(sp)
	move.w	ob_w(a5),-(sp)
	move.w	ob_h(a5),-(sp)
	bsr	form_dial
	lea.l	16(sp),sp
	bra	main_14		; sauter plus loin...
	
main_13	move.w	#7,d0		; un clic dans le vide --> driIIing..
	bsr	Cconout

main_14	andi.w	#$fffd,event(a6)	; annuler le bit de 'clic' dans event

main_15	tst.w	end(a6)		; le flag de fin est-il positionn‚ ?
	beq	main_4		; non, on boucle...
	
	clr.w	d0		; oui, on remet l'ancien bureau en place
	move.w	#WF_NEWDESK,d1
	move.l	#newdesk,d2
	clr.w	d2
	clr.w	d3
	clr.w	d4
	clr.w	d5
	bsr	wind_set
	
	move.w	#0,d0		; on supprime le menu
	lea.l	tr_MENU,a0
	bsr	menu_bar
	
	bsr	rsrcc_free	; on libŠre la zone m‚moire du ressource
	
	move.w	vdih,d0		; on libŠre la VDI
	bsr	v_clsvwk
	
	bsr	appl_exit	; et pis aussi l'AES
	lea.l	200(sp),sp	; on libŠre les variables locales
	rts			; et retour … la fonction appelante...
	
*********************************************************** Fonctions

************** Fonction personnelles

* d0 = obj.w
* a0 = tree.*
getx:	movem.l	d1-2/a1,-(sp)
	bsr	sgetx
	movem.l	(sp)+,d1-2/a1
	rts
	
* d0 = obj.w
* a0 = tree.*
sgetx:	move.w	d0,-(sp)
	move.w	d0,d1
sgtx_0	move.l	a0,a1
	move.w	d1,d2
	mulu	#OB_SIZE,d2
	adda.l	d2,a1
	move.w	ob_tail(a1),d2
	cmp.w	d2,d0
	bgt	sgtx_1
	move.w	ob_head(a1),d2
	cmp.w	d2,d0
	bge	sgtx_2
sgtx_1	cmp.w	#-1,d1
	beq	sgtx_2
	move.w	ob_next(a1),d1
	bra.s	sgtx_0
sgtx_2	cmp.w	#-1,d1
	beq	sgtx_3
	move.w	d1,d0
	bsr	sgetx	; c'est juste un peu r‚cursif...
	bra.s	sgtx_4	; … partir d'ici D0 contient le r‚sultat partiel
sgtx_3	clr.w	d0
sgtx_4	move.w	(sp)+,d1
	mulu	#OB_SIZE,d1
	move.l	a0,a1
	adda.l	d1,a1
	add.w	ob_x(a1),d0
	rts

	
* d0 = obj.w
* a0 = tree.*
gety:	movem.l	d1-2/a1,-(sp)
	bsr	sgety
	movem.l	(sp)+,d1-2/a1
	rts

* d0 = obj.w
* a0 = tree.*
sgety:	move.w	d0,-(sp)
	move.w	d0,d1
sgty_0	move.l	a0,a1
	move.w	d1,d2
	mulu	#OB_SIZE,d2
	adda.l	d2,a1
	move.w	ob_tail(a1),d2
	cmp.w	d2,d0
	bgt	sgty_1
	move.w	ob_head(a1),d2
	cmp.w	d2,d0
	bge	sgty_2
sgty_1	cmp.w	#-1,d1
	beq	sgty_2
	move.w	ob_next(a1),d1
	bra.s	sgty_0
sgty_2	cmp.w	#-1,d1
	beq	sgty_3
	move.w	d1,d0
	bsr	sgety
	bra.s	sgty_4	;… partir d'ici D0 contient le r‚sultat partiel
sgty_3	clr.w	d0
sgty_4	move.w	(sp)+,d1
	mulu	#OB_SIZE,d1
	move.l	a0,a1
	adda.l	d1,a1
	add.w	ob_y(a1),d0
	rts


* a0 = tree.*
* d0 = obj.w
* d1 = x.w	
setx:	move.l	d2,-(sp)
	move.w	d0,-(sp)
	bsr	getx
	move.w	d0,d2
	move.w	(sp)+,d0
	mulu	#OB_SIZE,d0
	adda.l	d0,a0
	sub.w	d2,d1
	add.w	d1,ob_x(a0)
	move.l	(sp)+,d2
	rts	
	

* a0 = tree.*
* d0 = obj.w
* d1 = y.w	
sety:	move.l	d2,-(sp)
	move.w	d0,-(sp)
	bsr	gety
	move.w	d0,d2
	move.w	(sp)+,d0
	mulu	#OB_SIZE,d0
	adda.l	d0,a0
	sub.w	d2,d1
	add.w	d1,ob_y(a0)
	move.l	(sp)+,d2
	rts	
	

************** Bindings TOS


* d0 = Code ASCII
Cconout:
	movem.l	d0-2/a0-2,-(sp)
	move.w	d0,-(sp)
	move.w	#2,-(sp)
	trap	#1
	lea.l	4(sp),sp
	movem.l	(sp)+,d0-2/a0-2
	rts
	

* d0 = taille.l en entr‚e
* a0 = adresse.l du bloc en sortie ou 0
Malloc:
	movem.l	d0-2/a1-2,-(sp)
	move.l	d0,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	lea.l	6(sp),sp
	move.l	d0,a0
	movem.l	(sp)+,d0-2/a1-2
	rts


* a0 = adresse.l du bloc
Mfree:
	movem.l	d1-2/a0-2,-(sp)
	move.l	a0,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	lea.l	6(sp),sp
	movem.l	(sp)+,d1-2/a0-2
	rts


* a0 = adresse de la pile utilisateur
Super:
	movem.l	d1-2/a0-2,-(sp)
	move.l	a0,-(sp)
	move.w	#$20,-(sp)
	trap	#1		;attention, la pile bouge...
	lea.l	6(sp),sp
	movem.l	(sp)+,d1-2/a0-2
	rts
	
************** Bindings VDI

		
* a0 = work_in.*
* a1 = handle*
* a2 = work_out*
v_opnvwk:
	movem.l	d6/a6,-(sp)
	lea.l	contrl,a6
	move.w	#100,(a6)
	clr.w	2(a6)
	move.w	#11,6(a6)
	lea.l	intin,a6
	move.w	#11,d6
opnv_1	move.w	(a0)+,(a6)+
	dbra	d6,opnv_1
	bsr	vdi
	lea.l	intout,a6
	move.w	#44,d6
opnv_2	move.w	(a6)+,(a2)+
	dbra	d6,opnv_2
	lea.l	ptsout,a6
	move.w	#11,d6
opnv_3	move.w	(a6)+,(a2)+
	dbra	d6,opnv_3
	lea.l	contrl,a6
	move.w	12(a6),(a1)
	movem.l	(sp)+,d6/a6
	rts


* d0 = handle.w
v_clsvwk:
	move.l	a6,-(sp)
	lea.l	contrl,a6
	move.w	#101,(a6)
	clr.w	2(a6)
	clr.w	6(a6)
	move.w	d0,12(a6)
	bsr	vdi
	move.l	(sp)+,a6
	rts

	
* a0 = work_out.*
* d0 = handle.w
* d1 = flag.w
vq_extnd:
	movem.l	d6/a5-a6,-(sp)
	lea.l	contrl,a6
	move.w	#102,(a6)
	clr.w	2(a6)
	move.w	#1,6(a6)
	move.w	d0,12(a6)
	lea.l	intin,a6
	move.w	d1,(a6)
	bsr	vdi
	lea.l	intout,a6
	move.w	#44,d6
	move.l	a0,a5
extd_0	move.w	(a6)+,(a5)+
	dbra	d6,extd_0
	lea.l	ptsout,a6
	move.w	#11,d6
extd_1	move.w	(a6)+,(a5)+
	dbra	d6,extd_1
	lea.l	contrl,a6
	movem.l	(sp)+,d6/a5-6
	rts


************** Bindings AES


aes:	movem.l	d0-3/a0-3,-(sp)
	move.l	#aespb,d1
	move.w	#$c8,d0
	trap	#2
	movem.l	(sp)+,d0-3/a0-3
	rts

vdi:	movem.l	d0-3/a0-3,-(sp)
	move.l	#vdipb,d1
	move.w	#$73,d0
	trap	#2
	movem.l	(sp)+,d0-3/a0-3
	rts

	
appl_init:
	move.l	a6,-(sp)
	lea.l	control,a6
	move.w	#10,(a6)+
	clr.w	(a6)+
	move.w	#1,(a6)+
	clr.w	(a6)
	bsr	aes
	move.l	(sp)+,a6
	move.w	int_out,d0
	rts

			
appl_exit:
	move.l	a6,-(sp)
	lea.l	control,a6
	move.w	#19,(a6)+
	clr.w	(a6)+
	move.w	#1,(a6)+
	clr.w	(a6)
	bsr	aes
	move.l	(sp)+,a6
	move.w	int_out,d0
	rts


* d0 = gr_monumber.w
* a0 = gr_mofaddr.*
graf_mouse:
	move.l	a6,-(sp)
	lea.l	control,a6
	move.w	#78,(a6)+
	move.w	#1,(a6)+
	move.w	#1,(a6)+
	move.w	#1,(a6)+
	clr.w	(a6)
	move.w	d0,int_in
	move.l	a0,addr_in
	bsr	aes
	move.w	int_out,d0
	move.l	(sp)+,a6
	rts

	
rsrcc_free:
	move.w	__NewMtfCount,d1
	beq.s	cfre_1
	ext.l	d1
	lsl.l	#2,d1
	lea.l	__NewMtf,a1
	move.l	a1,a2
	adda.l	d1,a1	; calculer adresse du 1er pointeur + 4 octets

cfre_0	suba.l	#4,a1	; pointeur pr‚c‚dent
	move.l	(a1),a0	
	bsr	Mfree	; lib‚rer
	cmp.l	a2,a1	; c'‚tait le dernier ?
	bne.s	cfre_0	; non, boucler...
cfre_1	rts
	

* a0 = re_otree.*
* d0 = re_object.w
* d1 = re_numplanes.w
rsrcc_obfix:			; routine d'appel … rsrc_obfix et de choix
				; du meilleur motif couleur.

num_planes	equ	0	; nouveaux equates AES : CICON
col_data	equ	2
col_mask	equ	6
sel_data	equ	10
sel_mask	equ	14
next_res	equ	18

monoblk		equ	0	; CICONBLK
mainlist	equ	34

np		equ	0
ii		equ	2
j		equ	4
k		equ	6
l		equ	6
pix		equ	8
wdst		equ	10
wsrc		equ	14
stock1		equ	18
stock2		equ	50
mtf_w		equ	82
mtf_h		equ	84
mtf		equ	86
reg		equ	88
cicnp		equ	90
good_cicnp	equ	94
oldsstack	equ	98
nbpl_		equ	102
re_object	equ	104
re_otree	equ	106

  	movem.l	a1-6/d2-4,-(sp)	; sauvegarde registres
	lea.l	-110(sp),sp
	move.l	sp,a6

	move.w	d1,nbpl_(a6)		; sauver les paramŠtres dans les variables locales	
	move.w	d0,re_object(a6)
	move.l	a0,re_otree(a6)
	
	move.l	a0,a1			; copier adresse de l'arbre
	move.w	d0,d2			; copier num‚ro d'objet
	mulu	#OB_SIZE,d2		; calculer offset /t au d‚but de l'arbre
	adda.l	d2,a1			; calculer l'adresse de l'objet

	cmp.w	#G_CICON,ob_type(a1)	; objet G_CICON ??
	bne	cobf_4			; non, sortir... 

	move.l	ob_spec(a1),a2		; extraire pointeur sur CICONBLK
	move.l	mainlist(a2),a2		; extraire l'adresse du 1er CICON

	move.l	a2,cicnp(a6)
	clr.w	np(a6)			; mettre le nombre de plans id‚al … 0
	
cobf_0	move.l	cicnp(a6),a2		; tant qu'il y a un CICON...
	tst.l	cicnp(a6)
	beq	cobf_2
	
	move.w	num_planes(a2),d2	; extraire nombre de plans du CICON
	cmp.w	np(a6),d2		; nombre de plans <= au np id‚al ?
	bls	cobf_1			; oui, sauter ce vil CICON...
	cmp.w	nbpl_(a6),d2			; nombre de plans > au nombre de plans actuel ?
	bhi	cobf_1			; oui, sauter ce vil CICON...
	move.w	d2,np(a6)		; non, ce CICON est le meilleur jusqu'… pr‚sent, m‚moriser son nombre de plans
	move.l	cicnp(a6),good_cicnp(a6); et son adresse.
cobf_1	move.l	next_res(a2),cicnp(a6)	; avancer d'un CICON
	bra.s	cobf_0			; fin tant que.

cobf_2	move.l	ob_spec(a1),a2		; Actualisation de l'arbre: 
	tst.w	np(a6)			; a-t-on trouv‚ un bon CICON ?
	bne	cobf_3			; oui, aller plus loin...
	clr.l	mainlist(a2)		; non, annuler la liste de CICONs, on utilisera le motif monochrome
	bra	cobf_4			; sortir...
cobf_3	move.l	good_cicnp(a6),a3
	move.l	a3,mainlist(a2)		; oui, remplacer le 1er CICON de la liste par celui qu'on a trouv‚
	clr.l	next_res(a3)		; occulter les suivants

	move.w	nbpl_(a6),d1
	cmp.w	np(a6),d1		; comparer le nombre de plans id‚al au nombre de plans du mode actuel
	beq	cobf_4			; si il y a ‚galit‚, sauter au rsrc_obfix
	
	move.l	ob_spec(a1),a2
	move.w	22(a2),mtf_w(a6)	; r‚cup‚rer la largeur et la hauteur du dessin
	move.w	24(a2),mtf_h(a6)
	
	cmp.w	#16,nbpl_(a6)		; est-on en true color ???
	bne	cobf_16			; non, sauter...
	lea.l	colors,a5		; oui, cr‚er pointeur sur la table

	sub.l	a0,a0			; passer en superviseur
	bsr	Super
	move.l	d0,oldsstack(a6)	; m‚moriser l'ancienne pile superviseur

	move.w	#255,d0			; pr‚parer 256 tours
	lea.l	TRUECOLORS,a0		; adresse des registres
	lea.l	colors,a1		; adresse de la table de stockage
	
cobf_15	move.l	(a0)+,d1		; saisir couleur au format %000rrrrr000vvvvv00000000000bbbbb
	move.l	d1,d2			; copier dans d2
	swap	d2			; permuter
	move.w	d2,d3			; copier en d3
	lsr.l	#3,d2			; amener la composante rouge o— il faut
	and.w	#%0000001111100000,d2	; supprimer les bits du vert qui traŒnent
	and.l	#%0000000000011111,d3	; supprimer de l'autre registre les bits du rouge
	or.w	d3,d2			; superposer
	lsl.l	#6,d2			; d‚caler de 6 bits pour laisser la place au bleu et au bit d'overlay
	and.l	#%0000000000011111,d1	; nettoyer d1 des bits autres que le bleu
	or.w	d2,d1			; superposer pour obtenir %rrrrrvvvvv0bbbbb
	move.w	d1,(a1)+		; inscrire dans  la table
	
	dbra	d0,cobf_15		; boucler...

	move.l	oldsstack(a6),a0	; retour en mode utilisateur
	bsr	Super

cobf_16
	clr.w	mtf(a6)
cobf_for_mtf:
	cmp.w	#2,mtf(a6)		; pour chacun des 2 motifs 'N' et 'S' de l'ic“ne, ...
	bhs	cobf_for_mtf_end

	move.l	good_cicnp(a6),a2
	cmp.w	#0,mtf(a6)
	bne	cobf_5
	move.l	col_data(a2),wsrc(a6)	; motif 'N', initialiser la source
	bra.s	cobf_6
cobf_5	move.l	sel_data(a2),wsrc(a6)	; motif 'S', initialiser la source

cobf_6	tst.w	wsrc(a6)		; le motif existe-t-il ?
	beq	cobf_4			; non, sauter l'adaptation
	
	cmp.w	#__MAXMTFCOUNT,__NewMtfCount	; reste-t-il de la place dans le tableau des pointeurs ?
	bls.s	cobf_8				; non, renvoyer un code d'erreur

	clr.w	d0
	bra	cobf_7
	
cobf_8	movem.l	d0-1/a0-1,-(sp)		; oui, alors on alloue un bloc m‚moire...
	move.w	mtf_w(a6),d0		; calcul du nombre de mots par ligne:
	ext.l	d0
	lsr.l	#4,d0			; on divise la largeur par 16
	lsl.l	#1,d0			; multipli‚ par 2 pour avoir le nombre d'octets par ligne
	mulu	nbpl_(a6),d0			; multipli‚ par le nombre de plans
	move.w	mtf_h(a6),d1		; et par la hauteur
	ext.l	d1
	mulu	d1,d0
	bsr	Malloc			; appel au Gemdos
	move.l	a0,a2			; on sauve le r‚sultat
	movem.l	(sp)+,d0-1/a0-1		; on restaure le contexte
	
	lea.l	__NewMtf,a3		; table des zones allou‚es
	move.w	__NewMtfCount,d2	; former offset avec le nombre de motifs d‚j… allou‚s
	ext.l	d2			; offset long...
	lsl.l	#2,d2			; et en octets
	adda.l	d2,a3		; calcul de l'adresse du nouveau pointeur dans le tableau
	
	move.l	a2,(a3)		; transfert du pointeur dans le tableau
	move.l	a2,wdst(a6)	; m‚morisation de l'adresse de destination
	tst.l	wdst(a6)	; au fait, le pointeur ‚tait-il nul ???
	bne.s	cobf_14		; non, ouf, on peut continuer...
	
	clr.w	d0		; oui, renvoyer un code d'erreur
	bra	cobf_7
	
cobf_14	move.l	good_cicnp(a6),a2	; actualiser les pointeurs du CICON
	cmp.w	#0,mtf(a6)		; traite-t-on le motif 'N' ?
	bne	cobf_9			; non, sauter plus loin...
	move.l	wdst(a6),col_data(a2)	; motif 'N'
	move.w	nbpl_(a6),num_planes(a2)	; actualiser le nombre de plans de bits
	bra.s	cobf_10

cobf_9	move.l	wdst(a6),sel_data(a2)	; motif 'S'

cobf_10	addi.w	#1,__NewMtfCount	; on peut incr‚menter le compteur de pointeurs

	clr.w	j(a6)
cobf_for_j:
	move.w	j(a6),d2		; pour chaque ligne du motif...
	cmp.w	mtf_h(a6),d2
	bhs	cobf_for_j_end

	clr.w	ii(a6)
cobf_for_ii:
	move.w	mtf_w(a6),d2		; pour chaque mot de la ligne...
	addi.w	#15,d2
	lsr.w	#4,d2
	cmp.w	ii(a6),d2
	bls	cobf_for_ii_end
	
	clr.w	d2
	lea.l	stock1(a6),a3
	move.l	wsrc(a6),a2
cobf_for_k_1:
	cmp.w	np(a6),d2		; m‚moriser np plans de la source dans stock1
	bhs.s	cobf_for_k_1_end
	
	move.w	(a2)+,(a3)+

	addi.w	#1,d2
	bra.s	cobf_for_k_1
cobf_for_k_1_end
	move.l	a2,wsrc(a6)		; sauver le nouveau pointeur source pour la prochaine saisie
	
	clr.w	pix(a6)
	lea.l	stock2(a6),a4		; stocker l'adresse du tableau destination en A4...
cobf_for_pix
	cmp.w	#16,pix(a6)		; pour les 16 pixels du mot,
	bhs	cobf_for_pix_end
	
	move.w	np(a6),d2
	subi.w	#1,d2
	move.w	d2,k(a6)
	clr.w	reg(a6)
cobf_for_k_2
	tst.w	k(a6)			; calculer l'index de registre couleur du pixel
	bmi.s	cobf_for_k_2_end
	
	move.w	reg(a6),d4
	lsl.w	#1,d4			; pr‚d‚caler la valeur du registre
	move.w	d4,reg(a6)
	
	lea.l	stock1(a6),a2
	move.w	k(a6),d2
	ext.l	d2
	lsl.l	#1,d2
	adda.l	d2,a2
	move.w	(a2),d2
	move.w	d2,d3
	andi.w	#$8000,d3		; aller chercher le bit 15 de stock1[k]
	beq.s	cobf_11
	ori.w	#1,reg(a6)		; et le copier dans le bit 0 de la valeur du registre

cobf_11	lsl.w	#1,d2			; d‚caler stock1[k] d'un bit … gauche
	move.w	d2,(a2)
	subi.w	#1,k(a6)		; k = k-1
	
	bra.s	cobf_for_k_2
cobf_for_k_2_end
	
	move.w	#$ffff,d2	; si l'index (registre) est l'index maximum pour np plans,
	move.w	np(a6),d3
	lsl.w	d3,d2
	not.w	d2
	cmp.w	reg(a6),d2
	bne	cobf_12
	
	move.w	#$ffff,d2	; convertir en l'index maximum pour nbpl plans, sinon, ne pas modifier
	move.w	nbpl_(a6),d1
	cmp.w	#8,d1		; la conversion doit se faire avec au maximum 8 plans 
	bls.s	cobf_19		; si le nombre de plans est > 8, remplacer par 8
	move.w	#8,d1 
	
cobf_19	lsl.w	d1,d2
	not.w	d2
	move.w	d2,reg(a6)

cobf_12	cmp.w	#16,nbpl_(a6)	; si on est en true color, sauter directement au remplissage
	beq	cobf_17
	
	clr.w	k(a6)
cobf_for_k_3
	cmp.w	k(a6),d1	; construire les nouveaux plans de bits pour la destination
	bls.s	cobf_for_k_3_end
	
	lea.l	stock2(a6),a2	; tableau stock2[]
	move.w	k(a6),d2	; indice k
	ext.l	d2
	lsl.l	#1,d2		; faire des octets... et ajouter
	adda.l	d2,a2
	move.w	(a2),d2		
	lsl.w	#1,d2		; pr‚d‚caler le contenu de stock2[k] d'un bit … gauche
	move.w	reg(a6),d3	; ramener la valeur du registre
	move.w	d3,d4
	andi.w	#1,d3		; exhiber le bit 0
	beq.s	cobf_13
	
	ori.w	#1,d2		; copier dans le bit 0 de stock2[k]
	
cobf_13	move.w	d2,(a2)		; stocker
	lsr.w	#1,d4		; d‚caler la valeur du registre … droite
	move.w	d4,reg(a6)	; stocker
	addi.w	#1,k(a6)	; incr‚menter compteur
	bra.s	cobf_for_k_3
cobf_for_k_3_end
	bra.s	cobf_18		; sauter … l'ordre de bouclage

cobf_17	lea.l	colors,a5		; charger l'adresse de la table des couleurs ( en fait elle y est d‚j…, mais c'est plus clair comme ‡a )
	move.w	reg(a6),d1		; construire un offset pour le tableau stock2...
	lsl.w	#1,d1			; en octets S.V.P.
	ext.l	d1			; convertir en offset long 
	move.w	0(a5,d1),(a4)+		; stocker la couleur dans stock2[]
	
cobf_18	add.w	#1,pix(a6)
	bra	cobf_for_pix
cobf_for_pix_end
	
	clr.w	d2
	lea.l	stock2(a6),a2
	move.l	wdst(a6),a3
cobf_for_l
	move.w	nbpl_(a6),d1
	cmp.w	d2,d1		; sauver les nbpl nouveaux plans de bits
	bls.s	cobf_for_l_end
	
	move.w	(a2)+,(a3)+
	addi.w	#1,d2
	bra.s	cobf_for_l
cobf_for_l_end

	move.l	a3,wdst(a6)	; actualiser le pointeur destination
	add.w	#1,ii(a6)
	bra	cobf_for_ii
cobf_for_ii_end

	add.w	#1,j(a6)
	bra	cobf_for_j
cobf_for_j_end

	add.w	#1,mtf(a6)
	bra	cobf_for_mtf
cobf_for_mtf_end


cobf_4	lea.l	control,a5	; appel de rsrc_obfix
	move.w	#114,(a5)+
	move.w	#1,(a5)+
	move.w	#1,(a5)+
	move.w	#1,(a5)+
	clr.w	(a5)
	move.w	re_object(a6),int_in
	move.l	re_otree(a6),addr_in
	bsr	aes
	move.w	int_out,d0		; variable de retour

cobf_7
	lea.l	110(sp),sp	; supprimer les variables locales
	movem.l	(sp)+,a1-6/d2-4		; restaurer les registres
	rts
	
colors:	ds.w	256			; table des couleurs


* d0 = wi_ghandle.w
* d1 = wi_gfield.w
* a0 = wi_gw1.*
* a1 = wi_gw2.*
* a2 = wi_gw3.*
* a3 = wi_gw4.*
wind_get:
	move.l	a6,-(sp)
	lea.l	control,a6
	move.w	#104,(a6)+
	move.w	#2,(a6)+
	move.w	#5,(a6)+
	clr.w	(a6)+
	clr.w	(a6)
	lea.l	int_in,a6
	move.w	d0,(a6)
	move.w	d1,2(a6)
	bsr	aes
	lea.l	int_out,a6
	move.w	(a6),d0
	move.l	2(a6),(a0)
	move.l	4(a6),(a1)
	move.l	6(a6),(a2)
	move.l	8(a6),(a3)
	move.l	(sp)+,a6
	rts

	
* d0 = wi_ghandle.w
* d1 = wi_gfield.w
* d2 = wi_gw1.w
* d3 = wi_gw2.w
* d4 = wi_gw3.w
* d5 = wi_gw4.w
wind_set:
	move.l	a6,-(sp)
	lea.l	control,a6
	move.w	#105,(a6)+
	move.w	#6,(a6)+
	move.w	#1,(a6)+
	clr.w	(a6)+
	clr.w	(a6)
	lea.l	int_in,a6
	move.w	d0,(a6)
	move.w	d1,2(a6)
	move.w	d2,4(a6)
	move.w	d3,6(a6)
	move.w	d4,8(a6)
	move.w	d5,10(a6)
	bsr	aes
	move.w	int_out,d0
	move.l	(sp)+,a6
	rts

	
* d0 = fo_diflag.w
* 4(sp) = fo_dibigh.w
* 6(sp) = fo_dibigw.w
* 8(sp) = fo_dibigy.w
* 10(sp) = fo_dibigx.w
* 12(sp) = fo_dilittlh.w
* 14(sp) = fo_dilittlw.w
* 16(sp) = fo_dilittly.w
* 18(sp) = fo_dilittlx.w
form_dial:
	move.l	a6,-(sp)
	lea.l	control,a6
	move.w	#51,(a6)+
	move.w	#9,(a6)+
	move.w	#1,(a6)+
	clr.w	(a6)+
	clr.w	(a6)
	lea.l	int_in,a6
	move.w	d0,(a6)
	move.w	22(sp),2(a6)	; 22(sp) car on a empil‚ 1 long (a6)
	move.w	20(sp),4(a6)
	move.w	18(sp),6(a6)
	move.w	16(sp),8(a6)
	move.w	14(sp),10(a6)
	move.w	12(sp),12(a6)
	move.w	10(sp),14(a6)
	move.w	8(sp),16(a6)
	bsr	aes
	move.w	int_out,d0
	move.l	(sp)+,a6
	rts	* au retour, ne pas oublier le 'lea.l  16(sp),sp'

	
* d0 = me_bshow.w
* a0 = me_btree.*
menu_bar:
	move.l	a6,-(sp)
	lea.l	control,a6
	move.w	#30,(a6)+
	move.w	#1,(a6)+
	move.w	#1,(a6)+
	move.w	#1,(a6)+
	clr.w	(a6)
	move.w	d0,int_in
	move.l	a0,addr_in
	bsr	aes
	move.w	int_out,d0
	move.l	(sp)+,a6
	rts
		

* d0 = ev_mflags.w
* 4(sp) = ev_breturn.*
* 8(sp) = ev_kreturn.*
* 12(sp) = ev_mmkstate.*
* 16(sp) = ev_mmbutton.*
* 20(sp) = ev_mmoy.*
* 24(sp) = ev_mmox.*
* 28(sp) = ev_thicount.w
* 30(sp) = ev_tlocount.w
* 32(sp) = ev_mgpbuff.*
* 36(sp) = ev_mo2height.w
* 38(sp) = ev_mo2width.w
* 40(sp) = ev_mo2y.w
* 42(sp) = ev_mo2x.w
* 44(sp) = ev_mo2flags.w
* 46(sp) = ev_mo1height.w
* 48(sp) = ev_mo1width.w
* 50(sp) = ev_mo1y.w
* 52(sp) = ev_mo1x.w
* 54(sp) = ev_mo1flags.w
* 56(sp) = ev_bstate.w
* 58(sp) = ev_evbmask.w
* 60(sp) = ev_bclicks.w		; pfiouuu...
evnt_multi:
	movem.l	d1/a4-6,-(sp)
	lea.l	control,a6
	move.w	#25,(a6)+
	move.w	#16,(a6)+
	move.w	#7,(a6)+
	move.w	#1,(a6)+
	clr.w	(a6)
	lea.l	int_in,a6
	move.w	d0,(a6)+
	move.w	76(sp),(a6)+
	move.w	74(sp),(a6)+
	move.w	72(sp),(a6)+
	move.w	70(sp),(a6)+
	move.w	68(sp),(a6)+
	move.w	66(sp),(a6)+
	move.w	64(sp),(a6)+
	move.w	62(sp),(a6)+
	move.w	60(sp),(a6)+
	move.w	58(sp),(a6)+
	move.w	56(sp),(a6)+
	move.w	54(sp),(a6)+
	move.w	52(sp),(a6)+
	move.w	46(sp),(a6)+
	move.w	44(sp),(a6)
	move.l	48(sp),addr_in
	bsr	aes
	lea.l	int_out,a6
	move.w	(a6)+,d0
	
	lea.l	40(sp),a5
	move.w	#5,d1
evtm_0	move.l	(a5),a4
	move.w	(a6)+,(a4)
	sub.w	#4,a5
	dbra	d1,evtm_0
	
	movem.l	(sp)+,d1/a4-6
	rts	* au retour, ne pas oublier le 'lea.l  58(sp),sp'


* d0 = fo_adefbttn.w
* a0 = fo_astring.*
form_alert:
	move.l	a6,-(sp)
	lea.l	control,a6
	move.w	#52,(a6)+
	move.w	#1,(a6)+
	move.w	#1,(a6)+
	move.w	#1,(a6)+
	clr.w	(a6)
	move.w	d0,int_in
	move.l	a0,addr_in
	bsr	aes
	move.w	int_out,d0
	move.l	(sp)+,a6
	rts

	
* d0 = me_ntitle.w
* d1 = me_nnormal.w
* a0 = me_ntree.*
menu_tnormal:
	move.l	a6,-(sp)
	lea.l	control,a6
	move.w	#33,(a6)+
	move.w	#2,(a6)+
	move.w	#1,(a6)+
	move.w	#1,(a6)+
	clr.w	(a6)
	lea.l	int_in,a6
	move.w	d0,(a6)+
	move.w	d1,(a6)
	move.l	a0,addr_in
	bsr	aes
	move.w	int_out,d0
	move.l	(sp)+,a6
	rts

	
* d0 = ob_fstartob.w
* d1 = ob_fdepth.w
* d2 = ob_fmx.w
* d3 = ob_fmy.w
* a0 = ob_ftree.*
objc_find:
	move.l	a6,-(sp)
	lea.l	control,a6
	move.w	#43,(a6)+
	move.w	#4,(a6)+
	move.w	#1,(a6)+
	move.w	#1,(a6)+
	clr.w	(a6)
	lea.l	int_in,a6
	move.w	d0,(a6)+
	move.w	d1,(a6)+
	move.w	d2,(a6)+
	move.w	d3,(a6)+
	move.l	a0,addr_in
	bsr	aes
	move.w	int_out,d0
	move.l	(sp)+,a6
	rts
	

* a0 = gr_mkmx.*
* a1 = gr_mkmy.*
* a2 = gr_mkmstate.*
* a3 = gr_mkkstate.*
graf_mkstate:
	move.l	a6,-(sp)
	lea.l	control,a6
	move.w	#79,(a6)+
	clr.w	(a6)+
	move.w	#5,(a6)+
	clr.w	(a6)+
	clr.w	(a6)
	bsr	aes
	lea.l	int_out,a6
	move.w	(a6)+,d0
	move.w	(a6)+,(a0)
	move.w	(a6)+,(a1)
	move.w	(a6)+,(a2)
	move.w	(a6),(a3)
	move.l	(sp)+,a6
	rts
	

* 4(sp) = gr_dfinishy.*
* 8(sp) = gr_dfinishx.*
* 12(sp) = gr_dboundh.w
* 14(sp) = gr_dboundw.w
* 16(sp) = gr_dboundy.w
* 18(sp) = gr_dboundx.w
* 20(sp) = gr_dstarty.w
* 22(sp) = gr_dstartx.w
* 24(sp) = gr_dheight.w
* 26(sp) = gr_dwidth.w
graf_dragbox:
	move.l	a0,-(sp)
	move.l	a6,-(sp)
	lea.l	control,a6
	move.w	#71,(a6)+
	move.w	#8,(a6)+
	move.w	#3,(a6)+
	clr.w	(a6)+
	clr.w	(a6)
	lea.l	int_in,a6
	move.w	34(sp),(a6)
	move.w	32(sp),2(a6)
	move.w	30(sp),4(a6)
	move.w	28(sp),6(a6)
	move.w	26(sp),8(a6)
	move.w	24(sp),10(a6)
	move.w	22(sp),12(a6)
	move.w	20(sp),14(a6)
	bsr	aes
	lea.l	int_out,a6
	move.w	(a6)+,d0
	move.l	16(sp),a0
	move.w	(a6)+,(a0)
	move.l	12(sp),a0
	move.w	(a6),(a0)
	move.l	(sp)+,a6
	move.l	(sp)+,a0
	rts	* au retour, ne pas oublier le 'lea.l  24(sp),sp'


*********************************************************** Section DATA	

	data

str_3	dc.b	32,14,15,0		*d‚finition du menu (ressource inclus)
str_4	dc.b	" Fichiers",0
str_7	dc.b	"  A propos de cet exemple...",0
str_8	dc.b	"------------------------------",0
str_9	dc.b	"  Accessoire 1      ",0
str_10	dc.b	"  Accessoire 2      ",0
str_11	dc.b	"  Accessoire 3      ",0
str_12	dc.b	"  Accessoire 4      ",0
str_13	dc.b	"  Accessoire 5      ",0
str_14	dc.b	"  Accessoire 6      ",0
str_16	dc.b	"  Quitter ",0
	
	EVEN	*faisons attention aux adresses impaires
	
tr_MENU
	dc.w	$ffff, $0001, $0005, $0019, $0000, $0000
	dc.l	$00000000
	dc.w	$0000, $0000, $0050, $0019
	
	dc.w	$0005, $0002, $0002, $0014, $0000, $0000
	dc.l	$00001100
	dc.w	$0000, $0000, $0050, $0201
	
	dc.w	$0001, $0003, $0004, $0019, $0000, $0000
	dc.l	$00000000
	dc.w	$0002, $0000, $000e, $0301
	
	dc.w	$0004, $ffff, $ffff, $0020, $0000, $0000
	dc.l	str_3
	dc.w	$0000, $0000, $0004, $0301
	
	dc.w	$0002, $ffff, $ffff, $0020, $0000, $0000
	dc.l	str_4
	dc.w	$0004, $0000, $000a, $0301
	
	dc.w	$0000, $0006, $000f, $0019, $0000, $0000
	dc.l	$00000000
	dc.w	$0000, $0301, $0050, $0013
	
	dc.w	$000f, $0007, $000e, $0014, $0000, $0000
	dc.l	$00ff1100
	dc.w	$0002, $0000, $001e, $0008
	
	dc.w	$0008, $ffff, $ffff, $001c, $0000, $0000
	dc.l	str_7
	dc.w	$0000, $0000, $001e, $0001
	
	dc.w	$0009, $ffff, $ffff, $001c, $0000, $0008
	dc.l	str_8
	dc.w	$0000, $0001, $001e, $0001
	
	dc.w	$000a, $ffff, $ffff, $001c, $0000, $0000
	dc.l	str_9
	dc.w	$0000, $0002, $001e, $0001
	
	dc.w	$000b, $ffff, $ffff, $001c, $0000, $0000
	dc.l	str_10
	dc.w	$0000, $0003, $001e, $0001
	
	dc.w	$000c, $ffff, $ffff, $001c, $0000, $0000
	dc.l	str_11
	dc.w	$0000, $0004, $001e, $0001
	
	dc.w	$000d, $ffff, $ffff, $001c, $0000, $0000
	dc.l	str_12
	dc.w	$0000, $0005, $001e, $0001
	
	dc.w	$000e, $ffff, $ffff, $001c, $0000, $0000
	dc.l	str_13
	dc.w	$0000, $0006, $001e, $0001
	
	dc.w	$0006, $ffff, $ffff, $001c, $0000, $0000
	dc.l	str_14
	dc.w	$0000, $0007, $001e, $0001
	
	dc.w	$0005, $0010, $0010, $0014, $0000, $0000
	dc.l	$00ff1100
	dc.w	$0006, $0000, $000c, $0001
	
	dc.w	$000f, $ffff, $ffff, $001c, $0020, $0000
	dc.l	str_16
	dc.w	$0000, $0000, $000c, $0001

alerte	dc.b	"[0][",8," Programme de d‚monstration  |d'utilisation  des  fichiers|"
	dc.b	"*.ISN cr‚‚s avec EIKONA|",8," Vous  pouvez  d‚placer  et|"
	dc.b	"s‚lectionner les ic“nes...][ DEMO3.S |   O K   ]",0 

init_err
	dc.b	"[1][ |Erreur d'initialisation !  |Retour au bureau...][ Ok ]",0
	
	include "leop.isn"
	include	"leop1pn.isn"
	include	"leop1ps.isn"
	include	"leop2pn.isn"
	include	"leop2ps.isn"
	include	"leop4pn.isn"
	include	"leop4ps.isn"
	
	include "logo.isn"
	include	"logo1pn.isn"
	include	"logo2pn.isn"
	include	"logo4pn.isn"
	
str_leop	dc.b	"L‚opards",0
str_logo	dc.b	"LOGO Eikona",0

leop_cicb	dc.l	leop_m, leop_d, str_leop
		dc.w	$1000, 0, 0, 22, 0, LEOP_W, LEOP_H, 0, 32, 74, 8
		dc.l	cicn_leop_1p
		
logo_cicb	dc.l	logo_m, logo_d, str_logo
		dc.w	$1000, 0, 0, 22, 0, LOGO_W, LOGO_H, 0, 32, 74, 8
		dc.l	cicn_logo_1p
		
cicn_leop_1p	dc.w	LEOP1PN_D_PL
		dc.l	leop1pn_d, leop1pn_m, leop1ps_d, leop1ps_m, cicn_leop_2p
cicn_leop_2p	dc.w	LEOP2PN_D_PL
		dc.l	leop2pn_d, leop2pn_m, leop2ps_d, leop2ps_m, cicn_leop_4p
cicn_leop_4p	dc.w	LEOP4PN_D_PL
		dc.l	leop4pn_d, leop4pn_m, leop4ps_d, leop4ps_m, $00000000

cicn_logo_1p	dc.w	LOGO1PN_D_PL
		dc.l	logo1pn_d, logo1pn_m, $00000000, $00000000, cicn_logo_2p
cicn_logo_2p	dc.w	LOGO2PN_D_PL
		dc.l	logo2pn_d, logo2pn_m, $00000000, $00000000, cicn_logo_4p
cicn_logo_4p	dc.w	LOGO4PN_D_PL
		dc.l	logo4pn_d, logo4pn_m, $00000000, $00000000, $00000000
		
		
newdesk		dc.w	$ffff, $0001, $0002, $0014, $0000, $0000
		dc.l	$00fe11c3
		dc.w	$0000, $0000, $0000, $0000
		
		dc.w	$0002, $ffff, $ffff, G_CICON, $0000, $0000
		dc.l	leop_cicb
		dc.w	$0005, $0002, $4a00, $2800

		dc.w	$0000, $ffff, $ffff, G_CICON, $0000, $0000
		dc.l	logo_cicb
		dc.w	$0010, $0002, $4a00, $2800
		
	EVEN
aespb	dc.l	control		* parameter arrays de l'AES
	dc.l	global
	dc.l	int_in
	dc.l	int_out
	dc.l	addr_in
	dc.l	addr_out
	
vdipb	dc.l	contrl		* parameter arrays de la VDI
	dc.l	intin
	dc.l	ptsin
	dc.l	intout
	dc.l	ptsout
	
__NewMtfCount
	ds.w	1
	
__NewMtf
	ds.l	__MAXMTFCOUNT
	
*********************************************************** Section BSS	

	bss
	
	EVEN	
ap_id		ds.w	1	; les seules variables globales
vdih		ds.w	1

global		ds.w	16
control		ds.w	10
int_in		ds.w	128
int_out		ds.w	128
addr_in		ds.w	128
addr_out	ds.w	128

contrl		ds.w	12
intin		ds.w	128
intout		ds.w	128
ptsin		ds.w	128
ptsout		ds.w	128

	end
	