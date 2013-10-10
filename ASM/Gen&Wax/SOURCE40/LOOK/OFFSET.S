go_offset:	save.l a0
	lea fenetre_offset,a0
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	load.l a0
	tst d7
	bmi.s .pas_ouverte

	add.w #1,GWVA_WIND_OBJ_TOPABLE_STATE(a0)
	move.l a0,GWVA_WIND_OBJ_USER_PTR1+fenetre_offset
.pas_ouverte:
	rts	

go_new_offset:
	save.l a0
	lea struct_fao_rbton_base-fenetre_offset(a0),a2
	move.w #FAO_TXT_H,d1
	cmp.w #FAO_RBTON_H,GWVA_FORM_RADIO_OBJ_SELECTION(a2)
	beq.s .valeur_hexa
	move.w #FAO_TXT_D,d1
.valeur_hexa:
	move.w #FORM_ASK_OFFSET,d0
	save.w d1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	load.w d1
	move.l a1,a0
	clr d0
	cmp.w #FAO_TXT_H,d1
	bne.s .pas_valeur_hexa
	bsr HEXA2VALUE
	bra.s .comm
.pas_valeur_hexa:
	bsr DECI2VALUE
.comm:
	load.l a0
	tst.w d7
	bmi cancel_offset

	move.l GWVA_WIND_OBJ_USER_PTR1(a0),a1	; pointeur fenetre qui a fait l'offset
	move.l GWVA_WIND_OBJ_USER_PTR1(a1),a1	; pointeur structure look

	lea struct_fao_rbton_move-fenetre_offset(a0),a2
	cmp.w #FAO_RBTON_ABS,GWVA_FORM_RADIO_OBJ_SELECTION(a2)
	beq.s .deplacement_absolue

	add.l d1,d1
	bra.s .deplacement_relatif

.deplacement_absolue:
	tst.l d1
	bpl.s .positif
	moveq #0,d1
.positif:	cmp.l source_length(a1),d1
	ble.s .inf
	move.l source_length(a1),d1
.inf:
	add.l d1,d1		; en quartet
	sub.l pos_curseur(a1),d1

.deplacement_relatif:
	move.l d1,d0
	move.w #0,d1
	save.l a0
	move.l GWVA_WIND_OBJ_USER_PTR1(a0),a0	; pointeur fenetre qui a fait l'offset
	bsr update_position_curs
	load.l a0

cancel_offset:
	move.l GWVA_WIND_OBJ_USER_PTR1(a0),a2
	sub.w #1,GWVA_WIND_OBJ_TOPABLE_STATE(a2)
	bsr GWVA_WIND_OBJ_PRG_DELETE_ONE_WIND
	rts
