	text
	include	zlib.i
	include	aes.i
	include	structs.s
	include	util.i

	include	..\fashion.s

	XREF	tab_adr
	XREF	FORM_ALERT_adr
	XREF	wd_create_form
	XDEF	form_alert_editor
form_alert_editor
	cmp.w	#FA_OK,d1
	beq	ok_pressed
	cmp.w	#FA_TEST,d1
	beq	ok_pressed
	rts

ok_pressed
	move.w		d1,d7
	move.l		d0,a5
	xobjc_change	d0,d1

	move.l		edited_string,a6
	move.l		a6,a4
* Place le bon icone dans l'alerte
	trouve_bouton_precedent	#FA_IC1,a5
	sub.l		#FA_IC1,d0
	add.b		#"0",d0
	move.b		d0,1(a6)

* Ajoute les lignes de texte
	addq.l		#4,a6
	trouve_objc	a5,#FA_LINE1

	move.l		ob_spec(a0),a1	; ligne1
	move.l		(a1),a1
	tst.b		(a1)
	beq		.next1
.lp_lin1
	move.b		(a1)+,(a6)+
	bne		.lp_lin1
	move.b		#"|",-1(a6)
.next1

	lea		24(a0),a0
	move.l		ob_spec(a0),a1	; ligne2
	move.l		(a1),a1
	tst.b		(a1)
	beq		.next2
.lp_lin2
	move.b		(a1)+,(a6)+
	bne		.lp_lin2
	move.b		#"|",-1(a6)
.next2

	lea		24(a0),a0
	move.l		ob_spec(a0),a1	; ligne3
	move.l		(a1),a1
	tst.b		(a1)
	beq		.next3
.lp_lin3
	move.b		(a1)+,(a6)+
	bne		.lp_lin3
	move.b		#"|",-1(a6)
.next3

	lea		24(a0),a0
	move.l		ob_spec(a0),a1	; ligne4
	move.l		(a1),a1
	tst.b		(a1)
	beq		.next4
.lp_lin4
	move.b		(a1)+,(a6)+
	bne		.lp_lin4
	move.b		#"|",-1(a6)
.next4

	lea		24(a0),a0
	move.l		ob_spec(a0),a1	; ligne5
	move.l		(a1),a1
	tst.b		(a1)
	beq		.next5
.lp_lin5
	move.b		(a1)+,(a6)+
	bne		.lp_lin5
	move.b		#"|",-1(a6)
.next5

	move.b		#"]",-1(a6)
	move.b		#"[",(a6)+

* On ajoute les boutons un par un
	trouve_objc	a5,#FA_BT1
	
	move.l		ob_spec(a0),a1	; ligne1
	move.l		(a1),a1
	tst.b		(a1)
	beq		.nextbt1
.lp_bt1
	move.b		(a1)+,(a6)+
	bne		.lp_bt1
	move.b		#"|",-1(a6)
.nextbt1

	lea		24(a0),a0
	move.l		ob_spec(a0),a1	; ligne2
	move.l		(a1),a1
	tst.b		(a1)
	beq		.nextbt2
.lp_bt2
	move.b		(a1)+,(a6)+
	bne		.lp_bt2
	move.b		#"|",-1(a6)
.nextbt2

	lea		24(a0),a0
	move.l		ob_spec(a0),a1	; ligne5
	move.l		(a1),a1
	tst.b		(a1)
	beq		.nextbt3
.lp_bt3
	move.b		(a1)+,(a6)+
	bne		.lp_bt3
	move.b		"|",-1(a6)
.nextbt3

	move.b		#"]",-1(a6)
	move.b		#0,(a6)
	cmp.w		#FA_OK,d7
	bne		.suitE
	wd_close	a5
	rts
.suitE
	form_alert	#1,a4
	rts
*--------------------------------------------------------------------------------------------------------------------------*
	XDEF	create_alert_edit
create_alert_edit
	movem.l		d0-d2/d7/a0-a2/a5/a6,-(sp)
	move.l		0+40(sp),a6
	move.l		a6,a5
	move.l		a6,edited_string

* Place le radio bouton en bonne position
	move.b		1(a6),d7
	sub.b		#"0",d7
	rsrc_gaddr	#0,#FORM_ALERT
	move.l		addr_out,FORM_ALERT_adr

	trouve_bouton_precedent	#FA_IC1,addr_out
	trouve_objc		addr_out,d0
	bclr			#SELECTED,ob_states+1(a0)
	add.w			#FA_IC1,d7
	trouve_objc		addr_out,d7
	bset			#SELECTED,ob_states+1(a0)

* Place le texte de l'alerte dans le formulaire d'edition
	addq.l		#4,a5
	trouve_objc	addr_out,#FA_LINE5+1
	move.l		a0,a3
	trouve_objc	addr_out,#FA_LINE1
	move.l		a0,a4
.cp_lines
	move.l		ob_spec(a0),a1
	move.l		(a1),a1
.cp_line
	move.b		(a5)+,d0
	cmp.b		#"]",d0
	beq		.end_lin
	cmp.b		#"|",d0
	beq		.next_line
	move.b		d0,(a1)+
	bra		.cp_line
.next_line
	move.b		#0,(a1)

	lea		24(a0),a0
	bra		.cp_lines
* N'a pas toutes les lignes ?
.end_lin
	move.b		#0,(a1)+
	lea		24(a0),a0
	cmp.l		a0,a3
	beq		.end_lines
	move.l		ob_spec(a0),a1
	move.l		(a1),a1
	bra		.end_lin

.end_lines
* Place maintenant les boutons
	cmp.b		#"[",(a5)+
	bne		.end_lines	; trouve le premier bouton

	trouve_objc	addr_out,#FA_BT1

	move.l		ob_spec(a0),a1
	move.l		(a1),a1
.lp_bt1
	move.b		(a5)+,(a1)+
	cmp.b		#"]",(a5)
	beq		.no_bt2n3
	cmp.b		#"|",(a5)
	bne		.lp_bt1
	clr.b		(a1)+

	addq.l		#1,a5

	lea		24(a0),a0
	move.l		ob_spec(a0),a1
	move.l		(a1),a1
.lp_bt2
	move.b		(a5)+,(a1)+
	cmp.b		#"]",(a5)
	beq		.no_bt3
	cmp.b		#"|",(a5)
	bne		.lp_bt2
	clr.b		(a1)+

	addq.l		#1,a5

	lea		24(a0),a0
	move.l		ob_spec(a0),a1
	move.l		(a1),a1
.lp_bt3
	move.b		(a5)+,(a1)+
	cmp.b		#"]",(a5)
	bne		.lp_bt3
	clr.b		(a1)+

	bra		.bts_ok

.no_bt2n3
	clr.b		(a1)+
	lea		24(a0),a0
	move.l		ob_spec(a0),a1
	move.l		(a1),a1
	clr.b		(a1)
	bra		.bt2_ok

.no_bt3
	clr.b		(a1)+
.bt2_ok
	lea		24(a0),a0
	move.l		ob_spec(a0),a1
	move.l		(a1),a1
	clr.b		(a1)

.bts_ok

	wd_create	addr_out,#wd_create_form,#-1,#0,#0,#0
	movem.l		(sp)+,d0-d2/d7/a0-a2/a5/a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
	bss
edited_string	ds.l	1
