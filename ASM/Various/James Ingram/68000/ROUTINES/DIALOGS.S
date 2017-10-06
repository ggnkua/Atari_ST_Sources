* Diaolg handlers
*  by James Ingram, July 1993



	IFD	link_library

	MODULE	DIALOGS
	XDEF	get_tree_data,draw_exp_box_tree,draw_con_box_tree
	XDEF	draw_tree,free_tree,hand_dialog,do_dialog
	XDEF	button_off
	XDEF	find_radio_selected,preselect_radio,preselect_radio_no
	XDEF	hide_obj,show_obj,disable_obj,enable_obj
	XDEF	new_default
	XDEF	put_text_dialog,put_text_dialog_end
	XDEF	button_number

	XREF	aes
	XREF	tree_list,tree_coord_list
	ENDC



put_text_dialog:
* d0 = tree no
* d1 = obj no
* a0 = text addr
*
* RETURNS
* a0 = end of text
* d0 & d1 the same


	movem.l	a0/d0-d1,-(a7)
	bsr	get_tree_data
	movem.l	(a7)+,a1/d0-d1

	move.w	d1,d2
	mulu	#24,d2

	move.l	12(a0,d2.w),a0
	move.l	a1,(a0)
	exg.l	a0,a1
	rts

put_text_dialog_end:
* as above, but finds end of string in a0 too!
	bsr	put_text_dialog

_put_text_z:
	tst.b	(a0)+
	bne.s	_put_text_z
	rts



new_default:
* enter with:
*  d0 = tree no
*  d1 = new default button
*  d2 = old default button

	move.w	d2,-(a7)
	move.w	d1,-(a7)
	bsr	get_tree_data
	move.w	(a7)+,d0

	mulu	#24,d0
	bset.b	#1,9(a0,d0.w)	; set default bit on new default obj

	move.w	(a7)+,d0
	mulu	#24,d0
	bclr.b	#1,9(a0,d0.w)	; clear old default bit
	rts



hide_obj:
* tree no in d0
* obj no in d1

	move.w	d1,-(a7)
	bsr	get_tree_data
	move.w	(a7)+,d0

	mulu	#24,d0
	bset.b	#7,9(a0,d0.w)
	rts


show_obj:
* tree no in d0
* obj no in d1

	move.w	d1,-(a7)
	bsr	get_tree_data
	move.w	(a7)+,d0

	mulu	#24,d0
	bclr.b	#7,9(a0,d0.w)
	rts

disable_obj:
* tree no in d0
* obj no in d1

	move.w	d1,-(a7)
	bsr	get_tree_data
	move.w	(a7)+,d0

	mulu	#24,d0
	bset.b	#3,11(a0,d0.w)
	rts

enable_obj:
* tree no in d0
* obj no in d1

	move.w	d1,-(a7)
	bsr	get_tree_data
	move.w	(a7)+,d0

	mulu	#24,d0
	bclr.b	#3,11(a0,d0.w)
	rts






find_radio_selected:
* tree no in d0
* list of buttons in a0 (term -1.W)

* RETURNS
*	button no selected in d0
*	button no in SEQUENCE in d1
*	both = -1 if none are selected

	pea	(a0)
	bsr	get_tree_data

	move.l	(a7)+,a1	; tree addr in a0, list in a1

	moveq	#0,d0
	moveq	#0,d1


get_selled:
	move.w	(a1)+,d0	; get button no to try next
	bmi.s	no_selled

	move.w	d0,d2
	mulu	#24,d2
	btst.b	#0,11(a0,d2.w)	; test the selected bit!
	bne.s	found_selled

	addq.l	#1,d1
	bra.s	get_selled

no_selled:
	moveq	#-1,d0
	moveq	#-1,d1

found_selled:
	rts

preselect_radio_no:
* Preselect a radio button from a list of others!
* d0 = tree no
* d1 = button to turn on (no of button IN LIST)
* a0 = list of button nos
*
* RETURNS: none

	pea	(a0)
	move.w	d1,-(a7)
	bsr	get_tree_data
	move.w	(a7)+,d1
	move.l	(a7)+,a1

	addq.w	#1,d1

.pre_all:
	move.w	(a1)+,d0	; get button no
	bmi.s	.all_preed

	subq.w	#1,d1
	beq.s	.this_butt_on	; branch if this is the one!
	
	mulu	#24,d0
	bclr.b	#0,11(a0,d0.w)	; turn button off
	bra.s	.pre_all


.this_butt_on:
	mulu	#24,d0
	bset.b	#0,11(a0,d0.w)
	bra.s	.pre_all

.all_preed:
	rts



preselect_radio:
* Preselect a radio button from a list of others!
* d0 = tree no
* d1 = button to turn on
* a0 = list of button nos
*
* RETURNS: none

	pea	(a0)
	move.w	d1,-(a7)
	bsr	get_tree_data
	move.w	(a7)+,d1
	move.l	(a7)+,a1

.pre_all:
	move.w	(a1)+,d0	; get button no
	bmi.s	.all_preed

	cmp.w	d0,d1
	beq.s	.this_butt_on	; branch if this is the one!
	
	mulu	#24,d0
	bclr.b	#0,11(a0,d0.w)	; turn button off
	bra.s	.pre_all


.this_butt_on:
	mulu	#24,d0
	bset.b	#0,11(a0,d0.w)
	bra.s	.pre_all

.all_preed:
	rts




draw_exp_box_tree:
* draws expanding box for tree
* tree no passed in d0

	bsr	get_tree_data


	movem.w	d0-d3,-(a7)	; put co-ords on stack
	movem.w	(a7)+,d4-d7	; copy them to d4-d7


* now find average for smaller co-ords

	add.w	d2,d0
	lsr.w	#1,d0

	add.w	d3,d1
	lsr.w	#1,d1

	moveq	#10,d2
	moveq	#10,d3		; width + height 1


	move.w	#draw_an_expanding_box,-(a7)
	bsr	aes

	rts


draw_con_box_tree:
* draws contracting box for tree
* tree no passed in d0

	bsr	get_tree_data

	movem.w	d0-d3,-(a7)	; put co-ords on stack
	movem.w	(a7)+,d4-d7	; copy them to d4-d7


* now find average for smaller co-ords

	add.w	d3,d0
	lsr.w	#1,d0

	add.w	d3,d1
	lsr.w	#1,d1

	moveq	#1,d2
	moveq	#1,d3		; width + height 1

	move.w	#draw_a_contracting_box,-(a7)
	bsr	aes

	rts



draw_tree:
* tree no passed in d0
* first reserve the space!

	bsr	get_tree_data

	pea	(a0)		; keep addr of tree

	movem.w	d0-d3,-(a7)
	movem.w	d0-d3,-(a7)

	movem.w	(a7),d1-d4
	movem.w	(a7)+,d5-d7	; keep last word on stack for call to aes

	moveq	#0,d0		; code for reserve screen

	move.w	#begin_or_end_dialog,-(a7)
	bsr	aes


	movem.w	(a7)+,d2-d5	; get co-ords back in correct regs for call
	move.l	(a7)+,a0	; get tree addr back

	moveq	#0,d0		; from 1st object
	move.w	#200,d1		; depth 200

	move.w	#draw_an_object_tree,-(a7)
	bsr	aes		; tree is now drawn!
	rts


free_tree:
* frees tree number in d0 from screen

	bsr	get_tree_data

	movem.w	d0-d3,-(a7)

	movem.w	(a7),d1-d4
	movem.w	(a7)+,d5-d7	; get correct regs used + one on stack for call to aes

	moveq	#3,d0		; code = free screen

	move.w	#begin_or_end_dialog,-(a7)
	bsr	aes
	rts


hand_dialog:
* handle dialog.
* tree no passed in d0
* editable object no passed in d1

	move.w	d1,-(a7)
	bsr	get_tree_data	; get addr of tree

	move.w	(a7)+,d0	; and obj no

	move.w	#handle_dialog,-(a7)
	bsr	aes
	rts



do_dialog:
* do everything from start to finish to handle a dialog box
* tree no passed in d0
* editable obj passed in d1
* box flag in d2 (0 = no box drawn)

* RETURNS:
*	d0 = exit box no
*	d1 = double click flag

	move.w	d2,-(a7)
	move.w	d1,-(a7)
	move.w	d0,-(a7)

	tst.w	d2
	beq.s	.no_exp_box

	bsr	draw_exp_box_tree

.no_exp_box:
	move.w	(a7),d0
	bsr	draw_tree	; reserve tree area on screen

	move.w	(a7),d0
	move.w	2(a7),d1	; get editable obj no in d1
	bsr	hand_dialog	; do the dialog handling...

* button returned in d0
	move.w	d0,button_number

	bclr.l	#15,d0		; get rid of double click bit

	move.w	(a7),d1
	bsr	button_off


	move.w	(a7),d0
	move.w	4(a7),d2	; get box flag back

	tst.w	d2
	beq.s	.no_con_box

	bsr	draw_con_box_tree

.no_con_box:
	move.w	(a7),d0

	bsr	free_tree

	addq.l	#6,a7

	move.w	button_number,d0	; return the button number dialog exited by
	moveq	#0,d1		; no double click
	btst	#15,d0
	beq.s	.no_d_c

	moveq	#1,d1		; double click!
.no_d_c:
	bclr	#15,d0
	rts



get_tree_data:
* tree number passed in d0

	move.l	tree_list,a0
	moveq	#0,d1
	move.w	d0,d1

	move.l	d1,d0

	lsl.w	#2,d1
	move.l	(a0,d1.w),a0	; get addr of tree

	lsl.w	#3,d0
	move.l	tree_coord_list(pc),a1
	add.l	d0,a1

	movem.w	(a1),d0-d3	; get coords
	rts


button_off:
* turn off button number d0
* in tree number d1

	move.w	d0,-(a7)
	move.w	d1,d0
	bsr	get_tree_data

	move.w	(a7)+,d0
	mulu	#24,d0
	and.w	#$fffe,10(a0,d0.w)
	rts



	ifd	link_library
	section	bss
	endc


button_number:
	ds.w	1


