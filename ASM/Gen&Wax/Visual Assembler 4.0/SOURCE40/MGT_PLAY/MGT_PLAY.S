	output d:\assemble\sources.v40\mgt_play\mgt_play.acx

;OPT_FULL_PATHNAMES

	lea objet_application,a1

	include mgt_play.def
	include visual40.s
	include mgt_play.hs
	include mgt_play.obj

	comment HEAD=7
	section TEXT

	; ce programme r‚pond aux quatre lois de l'ouverture :
	; 1) ligne de commande
	; 2) si pas de ligne de commande : s‚lecteur de fichiers
	;    et si annule, CTRL+O -> redemande
	; 3) en accessoire : un click appelle le s‚lecteur
	; 4) en accessoire, supporte le VA_START

informations:
	lea fenetre_information,a0
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	rts

my_inits:	clr musique_en_train
	clr.l ad_malloc

	tst GWVA_APP_OBJ_IS_ACC_PRG
	bne.s .prg
	rts

.prg:	tst d0
	bne.s open_object		; cmd line present

	rts

other_message:
	cmp.w #VA_START,d0
	beq.s .vastart
	rts

.vastart:	move.l 6(a0),a0

	save.l a0
	bsr GWVA_APP_OBJ_PRG_ACC_OPEN_VSTATION
	load.l a0
	tst d7
	bge.s open_object

	rts	; pas b infinie si jamais 1 vstation se libŠre ?

acc_open:	move.w #ALERT1,d0
	move #3,d1
	bsr RSC_ALERT_BOX

	cmp #1,d0
	beq load_module

	cmp #2,d0
	beq stop_play

	rts

load_module:lea texte,a0		; 35 chars max.
	lea mask,a1			; 18 caracteres max
	move.l #0,a2
	bsr FILE_SELECTOR

	tst d0
	bgt.s open_object
	rts

open_object:
	save.l a0
	bsr stop_play
	load.l a0

	save.l a0
	bsr GET_FILE_LENGTH
	add.l #5300*4,d0
	save.l d0
	MXALLOC #0,d0
	load.l d6
	load.l a0
	tst.l d0
	ble.s .cancel
	move.l d0,ad_malloc

	move.l d0,a1
	move.l d6,d5
.clr:	clr.b (a1)+
	subq.l #1,d5
	bne.s .clr

	FILE_OPEN read,(a0),d7
	bmi.s .cancel2
	FREAD ad_malloc,d6,d7
	FCLOSE d7

	SUPEXEC init_zik
	move #1,musique_en_train

	rts

.cancel2:	MFREE ad_malloc
.cancel:	rts


routine_menu_quit:
app_term:
	bsr stop_play
	bra VISUAL40_END


acc_close:
stop_play:
	tst musique_en_train
	bne.s .yes
	rts

.yes:	SUPEXEC ZIK+8

	MFREE ad_malloc
	clr.l ad_malloc
	clr musique_en_train

	rts

init_zik:	move.l ad_malloc,a0
	clr.l d0
	JSR	ZIK

	MOVE.L	#ZIK+4,$134.W
	rts

	include routine.s

	section DATA

texte:	dc.b 'Choose module :',0
mask:	dc.b '*.MGT',0

	section BSS
musique_en_train:	ds.w 1
ad_malloc:		ds.l 1
 END
