;
; Copyright 1990-2006 Alexandre Lemaresquier, Raphael Lemoine
;                     Laurent Chemla (Serial support), Daniel Verite (AmigaOS support)
;
; This file is part of Adebug.
;
; Adebug is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; Adebug is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with Adebug; if not, write to the Free Software
; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
;

sprintf2:	bra	sprintf
tri2:	bra	tri
trouve2:	bra	trouve
strclr2:	bra	strclr
strcpy2:	bra	strcpy
strlen2:	bra	strlen
strcat2:	bra	strcat
init_buffer2:	bra	init_buffer
form_do2:	bra	form_do

treat_instruction3:	bra	treat_instruction2
;flash3:	bra	flash2
;print_instruction3:	bra	print_instruction2
;  -------------- LOW LEVEL ROUTINES ----------------
;  #[ lmul:
;d0.l*d1.l
;resultat ds d0.l
lmul:	movem.l d0-d1,-(sp)
	move.w	6(sp),d1
	mulu	2(sp),d1
	move.w	4(sp),d0
	mulu	2(sp),d0
	swap	d0
	clr.w	d0
	add.l	d0,d1
	move.w	(sp),d0
	mulu	4(sp),d0
	swap	d0
	clr.w	d0
	add.l	d0,d1
	move.l	d1,d0
	addq.w	#8,sp
	rts
;  #] lmul:
;  #[ Create_sizes:
create_sizes:
	pea	create_clears_table(pc)
	pea	create_ends_table(a6)
	pea	create_currents_table(a6)
	pea	create_addrs_table(a6)
	pea	create_sizes_table(a6)
	pea	create_routines_table(pc)
.l1:
	;routine de traitement de la taille
	move.l	(sp),a0
	;la taille
	move.l	4(sp),a1

	move.l	(a0),d0
	bmi.s	.fini
	move.l	d0,a0
	move.l	(a1),d0
	beq.s	.more_one
	bmi.s	.more_one
	jsr	(a0)

	;memoriser la taille reservee
	IFEQ	_68000
	move.l	d0,([16.w,sp],4.w)
	ELSEIF
	move.l	16(sp),a0
	move.l	d0,4(a0)
	ENDC
	bmi.s	.l1
	beq.s	.l1

	;reserver la memoire a partir de d0
	sf	d1
	moveq	#3,d2
	_JSR	reserve_memory
	beq.s	.memory_error
	;updater l'@ de debut
	move.l	8(sp),a1
	move.l	d0,(a1)
	move.l	d0,4(a1)

	;updater l'@ courante (initiale)
	IFEQ	_68000
	move.l	d0,([12.w,sp])
	ELSEIF
	move.l	12(sp),a1
	move.l	d0,(a1)
	ENDC	; de _68000

	;updater l'@ de fin en ajoutant la taille reservee
	move.l	16(sp),a1
	add.l	4(a1),d0
	move.l	d0,(a1)

	;clearer tout
	IFEQ	_68000
	move.l	([20.w,sp]),a1
	ELSEIF
	move.l	20(sp),a1
	move.l	(a1),a1
	ENDC	_68000
	jsr	(a1)
.more_one:
	addq.l	#4,(sp)
	addq.l	#4,4(sp)
	addq.l	#8,8(sp)
	addq.l	#4,12(sp)
	addq.l	#8,16(sp)
	addq.l	#4,20(sp)
	bra.s	.l1
.fini:
	moveq	#0,d0
	bra.s	.end
.memory_error:
	lea	memory_error_text,a2
	_JSR	print_press_key
	moveq	#-1,d0
.end:
	movem.l	(sp)+,a0-a5
	rts

create_routines_table:
	dc.l	create_breaks_size
	dc.l	create_blocks_number
	dc.l	create_story
	dc.l	create_var_size
	dc.l	create_la_size
	dc.l	create_lr_size
	dc.l	create_bl_size
	dc.l	create_ex_size
	dc.l	create_mac
	dc.l	create_history
	dc.l	-1

create_clears_table:
	dc.l	clear_breaks
	dc.l	clear_blocks_number
	dc.l	clear_story
	dc.l	clear_var
	dc.l	clear_la
	dc.l	clear_lr
	dc.l	clear_bl
	dc.l	clear_ex
	dc.l	clear_mac
	dc.l	clear_history
	dc.l	-1

	; #[ Create variables:
	;pas de restriction ni de calcul de taille
;nb de vars ds d0
create_var_size:
	;nb de var
	move.l	d0,d1
	and.l	#$ffff,d0
	;taille struct var
	mulu	#VAR_SIZE,d0
	;taille arbre=3 longs=12 bytes
	mulu	#VAR_TREE_SIZE,d1

	add.l	d1,d0
	rts
clear_var:
	clr.l	var_tree_addr(a6)
	;nb de vars
	move.l	table_var_max(a6),d0
	; arbre=3 longs
	mulu	#VAR_TREE_SIZE,d0

	;@ de fin de reservation
	move.l	end_var_addr(a6),d2
	sub.l	d0,d2
	move.l	d2,var_tree_addr(a6)
	rts
create_la_size:
create_lr_size:
create_bl_size:
create_ex_size:
clear_la:
clear_lr:
clear_bl:
clear_ex:
clear_blocks_number:
	rts
	; #] Create variables
	; #[ Create breaks:
create_breaks_size:
	;1 break=16 bytes
	;+ struct virtuelle = 16 bytes
	;+ eval = 32 bytes
;	asl.l	#4,d0	;16
;	add.l	d0,d0	;32
;	add.l	d0,d0	;64
	move.l	d0,d1
	asl.l	#6,d0
	IFNE	sourcedebug
	mulu	#12,d1
	add.l	d1,d0	;+12*nb
	ENDC	;de sourcedebug
	rts
clear_breaks:
	lea	zero_text,a0
	move.l	a0,def_break_eval_addr(a6)
;	clr.l	current_breaks_nb(a6)
	move.l	breaks_max(a6),d0
	beq.s	.end
	move.l	d0,-(sp)
	asl.l	#4,d0
	move.l	d0,d1
	move.l	breaks_addr(a6),a1
	add.l	a1,d0
	move.l	d0,eval_breaks_addr(a6)
	move.l	d0,cur_eval_breaks_addr(a6)
	add.l	d1,d0
	move.l	d0,end_eval_breaks_addr(a6)
;	move.l	a1,current_breaks_addr(a6)
	move.l	d1,d2
	add.l	d1,d2
	add.l	d1,d2
	add.l	a1,d2
	move.l	d2,virt_breaks_addr(a6)
	move.l	(sp)+,d0
	IFNE	sourcedebug
	mulu	#12,d0
	add.l	d2,d0
	move.l	d0,source_breaks_addr(a6)
	ENDC	;de sourcedebug
	;tout clearer:
;	move.l	breaks_max(a6),d0
;	subq.l	#1,d0
;.l1:
;	clr.l	(a1)+
;	clr.l	(a1)+
;	clr.l	(a1)+
;	clr.l	(a1)+
;	clr.l	(a1)+
;	clr.l	(a1)+
;	clr.l	(a1)+
;	clr.l	(a1)+
;	dbf	d0,.l1
.end:
	rts
	; #] Create breaks:
	; #[ Create blocks number:
create_blocks_number:
	;1 bloc=
	;1 long = @ debut
	;1 long = @ fin
	;1 word =
	;	BLWORD -> bl simple
	;	ROWORD -> ro
	;soit 10 octets
	and.l	#$ffff,d0
	mulu	#10,d0
	rts
	; #] Create blocks number:
	; #[ Create mac:
create_mac:
	;+2 pour avoir 2 zeros au debut
	;+2 pour avoir 2 zeros a la fin
	addq.l	#4,d0
	rts
clear_mac:
	move.l	mac_addr(a6),d0
	beq.s	.end
	move.l	d0,a0
	clr.w	(a0)+
	move.l	a0,mac_addr(a6)
	move.l	a0,cur_rec_mac_addr(a6)
	move.l	a0,cur_play_mac_addr(a6)
	move.l	mac_size(a6),d0
.l1:
	clr.b	(a0)+
	subq.l	#1,d0
	bne.s	.l1
	clr.l	cur_rec_mac_size(a6)
	clr.l	cur_play_mac_size(a6)
	sf	trace_mac_flag(a6)
	sf	go_mac_flag(a6)
	sf	rec_mac_flag(a6)
	sf	play_mac_flag(a6)
	clr.w	rec_mac_counter(a6)
.end:
	rts
	; #] Create mac:
	; #[ Create history:
create_history:
	moveq	#0,d1
	move.w	line_buffer_size(a6),d1
	cmp.l	d1,d0
	bgt.s	.good_size
	move.l	d1,d0
	move.l	d1,history_size(a6)
.good_size:
	addq.l	#4,d0
	rts
clear_history:
	;decaler de 2 pour s'arreter en haut
	move.l	history_addr(a6),a0
	clr.w	(a0)+
	move.l	a0,history_addr(a6)
	move.l	a0,cur_history_addr(a6)
	move.l	a0,trans_history_addr(a6)
	rts
	; #] Clear history:
	; #[ Create story:
create_story:
	;5 stories au moins
	and.l	#$ffff,d0
	moveq	#5,d1
	cmp.l	d1,d0
	bge.s	.rien
	move.l	d1,d0
.rien:
	move.l	d0,story_max(a6)
	mulu	#STO_REC_SIZE,d0
	rts
clear_story:
	move.l	story_addr(a6),a0
	move.l	a0,current_sto_addr(a6)
	move.l	a0,cur_h_addr(a6)
	clr.l	cur_sto_nb(a6)
	rts
	; #] Create story:

;  #] Create_sizes:
;  #[ Windows management subroutines:

	; #[ Open big window:

open_big_window:
 cmp.l #SCREEN_OUTPUT,device_number(a6)
 IFNE	ATARIST
 bne.s .rien
 tst.b low_rez(a6)
 beq.s .rien
 _JSR put_640_200
 st med_to_low_flag(a6)
.rien:
 ENDC
 lea windows_to_redraw(a6),a0
 clr.l (a0)
 move.w #$ff,4(a0)
 lea w6_db(a6),a0
 st 8(a0)
 st 9(a0)
 move.b window_magnified(a6),save_window_magnified(a6)
 st window_magnified(a6)
 _JSR little_clear_screen
 bra windows_init

	; #] Open big window:
	; #[ Close big window:

close_big_window:
 cmp.l #SCREEN_OUTPUT,device_number(a6)
 IFNE	ATARIST
 bne.s .rien
 tst.b med_to_low_flag(a6)
 beq.s .rien
 lea w6_db(a6),a0
 sf 8(a0)
 sf 9(a0)
 move.b save_window_magnified(a6),window_magnified(a6)
 _JSR put_320_200
 sf med_to_low_flag(a6)
 bra.s .1
.rien:
 ENDC
 lea w6_db(a6),a0
 sf 8(a0)
 sf 9(a0)
 move.b save_window_magnified(a6),window_magnified(a6)
.1:
 lea windows_to_redraw(a6),a0
 move.l #-1,(a0)
 move.w #$ff00,4(a0)
 bra windows_init

	; #] Close big window:
	; #[ Get current window:
;-- Output --
;d0 l'offset de la fenetre courante (asle)
;d1 le type de la fenetre courante
;a0 l'@ du descripteur de la premiere fenetre
;a1 l'@ courante de la fenetre courante
;ccr:N ou Z
get_curwind:
	move.w	window_selected(a6),d0
	subq.w	#1,d0
	; #] Get current window:
	; #[ Get window:
;-- Output --
;d0=offset ds structure de fenetre (0~5*16)
;d1=type de fenetre
;d2=# de fenetre normal (0~5)
;a0=@ des struct fenetres
;a1=@ binaire dans fenetre
;sr sur d1-1
get_wind:
	andi.l	#$ffff,d0
	move.l	d0,d2
	asl.w	#4,d0
	lea	w1_db(a6),a0
	move.l	$a(a0,d0.w),a1
	moveq	#0,d1
	move.w	$e(a0,d0.w),d1
	IFNE	sourcedebug
	cmp.w	#SRCWIND_TYPE,d1
	beq.s	.src
	ENDC	;de sourcedebug
.end:
	cmp.w	#DISWIND_TYPE,d1
	rts
	IFNE	sourcedebug
.src:
	movem.l	d0-d2/a0/a2,-(sp)
	lea	src_wind_buf(a6),a0
	mulu	#_SRCWIND_SIZEOF,d2
	add.w	d2,a0
	move.l	(a0),a0
	_JSR	get_code_addr
	move.l	d0,a1
	movem.l	(sp)+,d0-d2/a0/a2
	bra.s	.end
	ENDC	;de sourcedebug
	; #] Get window:
	; #[ Get current window without addr:
;-- Output --
;d0 l'offset de la fenetre courante (asle)
;d1 le type de la fenetre courante
;a0 l'@ du descripteur de la premiere fenetre
;a1 l'@ courante de la fenetre courante
;ccr:N ou Z
get_noaddr_curwind:
	move.w	window_selected(a6),d0
	subq.w	#1,d0
	; #] Get current window without addr:
	; #[ Get window without addr:
;-- Output --
;d0=offset ds structure de fenetre (0~5*16)
;d1=type de fenetre
;d2=# de fenetre normal (0~5)
;a0=@ des struct fenetres
;a1=@ binaire dans fenetre
;sr sur d1-1
get_noaddr_wind:
	andi.l	#$ffff,d0
	move.l	d0,d2
	asl.w	#4,d0
	lea	w1_db(a6),a0
	moveq	#0,d1
	move.w	$e(a0,d0.w),d1
.end:	cmp.w	#DISWIND_TYPE,d1
	rts
	; #] Get window without addr:
	; #[ Get current window type:
;-- Output --
;d0 l'offset de la fenetre courante (asle)
;d1 le type de la fenetre courante
;a0 l'@ du descripteur de la premiere fenetre
;a1 l'@ courante de la fenetre courante
;ccr:N ou Z
get_curwind_type:
	move.w	window_selected(a6),d0
	subq.w	#1,d0
	; #] Get current window type:
	; #[ Get window type:
;-- Output --
;d0=offset ds structure de fenetre (0~5*16)
;d1=type de fenetre
;d2=# de fenetre normal (0~5)
;a0=@ des struct fenetres
;a1=@ binaire dans fenetre
;sr sur d1-1
get_wind_type:
	andi.l	#$ffff,d0
	asl.w	#4,d0
	lea	w1_db(a6),a0
	moveq	#0,d1
	move.w	$e(a0,d0.w),d1
.end:
	cmp.w	#DISWIND_TYPE,d1
	rts
	; #] Get window type:
	; #[ Put current window address:
;envoyer ds
;a0 l'@ a mettre en @ courante dans la fenetre
put_curwind_addr:
	move.w	window_selected(a6),d0
	subq.w	#1,d0
;	bra.s	put_wind_addr
	; #] Put current window address:
	; #[ Put window address:
;Input:
;d0 le numero de la fenetre
;a0 l'@ a mettre en @ courante dans la fenetre
put_wind_addr:
	movem.l	d1-d2,-(sp)
	move.w	d0,d2
	asl.w	#4,d0
	lea	w1_db(a6),a1
	add.w	d0,a1
	move.w	$e(a1),d1
	cmp.w	#ASCWIND_TYPE,d1
	ble.s	.general
	IFNE	sourcedebug
	cmp.w	#SRCWIND_TYPE,d1
	beq.s	.src
	ENDC	;de sourcedebug
	bra.s	.end
.good:
	move.l	a1,-(sp)
	;buffer de save pour le zoom de fenetre
	lea	window_buffer(a6),a1
	move.l	a0,$a(a1)
	move.l	(sp)+,a1
.end:
	movem.l	(sp)+,d1-d2
	rts
.general:
	move.l	a0,$a(a1)
	bra.s	.good
	IFNE	sourcedebug
.src:
	;bin addr in d0
	move.l	a0,d0
	bsr	eval_get_source_addr
	;non non ce n'est pas une erreur, le ccr est deja la
	move.l	d0,a0
	beq.s	.end
	move.w	d2,d0
	bsr	put_srcwind_addrnb
	bra.s	.good
	ENDC	;de sourcedebug
	; #] Put window address:
	; #[ Put current window type:
;Input:
;d0=nouveau type
put_curwind_type:
	movem.l	d1/a0,-(sp)
	move.w	d0,d1
	move.w	window_selected(a6),d0
	subq.w	#1,d0
	bsr.s	put_wind_type
	movem.l	(sp)+,d1/a0
	rts
	; #] Put current window type:
	; #[ Put window type:
;Input:
;d0 la fenetre
;d1 le nouveau type
put_wind_type:
	move.w	d0,-(sp)
	asl.w	#4,d0
	lea	w1_db(a6),a0
	move.w	d1,$e(a0,d0.w)
	move.w	(sp)+,d0
	bra	update_title
	; #] Put window type:
	IFNE	sourcedebug
	; #[ Get current src window:
get_cursrcwind:
	move.w	window_selected(a6),d0
	subq.w	#1,d0
;	bra.s	put_srcwind
	; #] Get current src window:
	; #[ Get src window:
get_srcwind:
	lea	src_wind_buf(a6),a0
	mulu	#_SRCWIND_SIZEOF,d0
	add.w	d0,a0
	move.l	(a0),a1
	rts
	; #] Get src window:
	; #[ Put current src window address:
put_cursrcwind_addr:
	move.w	window_selected(a6),d0
	subq.w	#1,d0
;	bra.s	put_srcwind_addr
	; #] Put current src window address:
	; #[ Put src window address:
put_srcwind_addr:
	lea	src_wind_buf(a6),a1
	mulu	#_SRCWIND_SIZEOF,d0
	add.w	d0,a1
	move.l	a0,(a1)
	rts
	; #] Put src window address:
	; #[ Put current src window address and nb:
put_cursrcwind_addrnb:
	move.w	window_selected(a6),d0
	subq.w	#1,d0
;	bra.s	put_srcwind_addr
	; #] Put current src window address and nb:
	; #[ Put src window address and nb:
put_srcwind_addrnb:
	lea	src_wind_buf(a6),a1
	mulu	#_SRCWIND_SIZEOF,d0
	add.w	d0,a1
	move.l	a0,(a1)
	movem.l	a0-a1,-(sp)
	move.l	source_ptr(a6),a1
	exg	a0,a1
	_JSR	count_source_lines
	movem.l	(sp)+,a0-a1
	move.l	d0,_SRCWIND_LINENB(a1)
	rts
	; #] Put src window address and nb:
	; #[ Put var curwind type:
;d0=new type
put_curvarwind_type:
	move.w	d0,d1
	move.w	window_selected(a6),d0
	subq.w	#1,d0
;	bra.s	.put_varwind_type
	; #] Put var curwind type:
	; #[ Put var window type:
;d0=window nb
;d1=new type
put_varwind_type:
	move.w	d0,-(sp)
	lea	var_wind_buf(a6),a0
	mulu	#_VARWIND_SIZEOF,d0
	add.w	d0,a0
	move.w	d1,_VARWIND_TYPE(a0)
	_JSR	update_curwind_tcvars
	move.w	(sp)+,d0
	bra	update_title
	; #] Put var window type:
	; #[ Get current ins window:
get_curinswind:
	move.w	window_selected(a6),d0
	subq.w	#1,d0
;	bra.s	put_inswind
	; #] Get current ins window:
	; #[ Get ins window:
get_inswind:
	lea	ins_wind_buf(a6),a0
	mulu	#_INSWIND_SIZEOF,d0
	add.w	d0,a0
	move.l	(a0),a1
	rts
	; #] Get ins window:
	; #[ Put current ins window address:
put_curinswind_addr:
	move.w	window_selected(a6),d0
	subq.w	#1,d0
;	bra.s	put_inswind_addr
	; #] Put current ins window address:
	; #[ Put ins window address:
put_inswind_addr:
	move.w	d0,-(sp)
	lea	ins_wind_buf(a6),a1
	mulu	#_INSWIND_SIZEOF,d0
	add.w	d0,a1
	move.l	a0,(a1)
	clr.l	_INSWIND_ELNB(a1)
	move.w	(sp)+,d0
	bra	update_curwind_ttl
	; #] Put ins window address:
	ENDC	;de sourcedebug
	; #[ Redraw_relock_curwind:
;redraw_relock_curwind:
;	st	relock_pc_flag(a6)
	; #] Redraw_relock_curwind:
	; #[ Redraw current window & title:
redraw_curwind_ttl:
	move.w	window_selected(a6),d0
	subq.w	#1,d0
	bsr	update_title
	; #] Redraw current window & title:
	; #[ Redraw current window:
redraw_curwind:
	move.w	window_selected(a6),d0
	subq.w	#1,d0
	bra	redraw_inside_window
	; #] Redraw current window:
	; #[ Update current window title:
update_curwind_ttl:
	move.w	window_selected(a6),d0
	subq.w	#1,d0
	bra	update_title
	; #] Update current window title:
	; #[ Redraw_relock_all:
redraw_relock_all:
	st	relock_pc_flag(a6)
	bsr.s	redraw_all_windows
	sf	relock_pc_flag(a6)
	rts
	; #] Redraw_relock_all:
	; #[ Redraw all windows:
redraw_all_windows:
	moveq	#5-1,d0
	move.b	c_line(a6),-(sp)
	move.b	m_line(a6),-(sp)
	sf	c_line(a6)
	sf	m_line(a6)
	move.b	relock_flag(a6),-(sp)
.1:	move.w	d0,-(sp)

	_JSR	get_noaddr_wind
	add.w	d0,a0
	st	relock_flag(a6)
	_JSR	_lock
	move.w	(sp),d0
	bsr	redraw_inside_window
	move.w	(sp)+,d0
	dbf	d0,.1
;.after_loop:
	move.b	(sp)+,relock_flag(a6)
	move.b	(sp)+,m_line(a6)
	move.b	(sp)+,c_line(a6)
	rts

	; #] Redraw all windows:
	; #[ save_registers_for_star:

save_registers_for_star:
 lea d0_buf(a6),a1
 lea save_d0_buf(a6),a0
 moveq #$10,d6
.30:
 move.l (a1)+,(a0)+
 dbf d6,.30
 move.w sr_buf(a6),save_sr_buf(a6)
 move.l pc_buf(a6),save_pc_buf(a6)
 IFNE _68030
 tst.b chip_type(a6)
 beq .end
 move.l isp_buf(a6),save_isp_buf(a6)
 move.l msp_buf(a6),save_msp_buf(a6)
 move.l vbr_buf(a6),save_vbr_buf(a6)
 move.w sfc_buf(a6),save_sfc_buf(a6)
 move.w dfc_buf(a6),save_dfc_buf(a6)
 move.l cacr_buf(a6),save_cacr_buf(a6)
 move.l caar_buf(a6),save_caar_buf(a6)
 move.l crp_buf(a6),save_crp_buf(a6)
 move.l crp_buf+4(a6),save_crp_buf+4(a6)
 move.l srp_buf(a6),save_srp_buf(a6)
 move.l srp_buf+4(a6),save_srp_buf+4(a6)
 move.l tc_buf(a6),save_tc_buf(a6)
 move.l tt0_buf(a6),save_tt0_buf(a6)
; move.l tt0_buf+4(a6),save_tt0_buf+4(a6)
 move.l tt1_buf(a6),save_tt1_buf(a6)
; move.l tt1_buf+4(a6),save_tt1_buf+4(a6)
 move.w mmusr_buf(a6),save_mmusr_buf(a6)
 lea fp0_buf(a6),a0
 lea save_fp0_buf(a6),a1
 moveq #$17,d0
.save_fpx:
 move.l (a0)+,(a1)+
 dbf d0,.save_fpx
 move.l fpcr_buf(a6),save_fpcr_buf(a6)
 move.l fpsr_buf(a6),save_fpsr_buf(a6)
 move.l fpiar_buf(a6),save_fpiar_buf(a6)
 ENDC
.end:
 rts

	; #] save_registers_for_star:
	; #[ Redraw Inside Window:

	include	"redraw.s"

	; #] Redraw Inside Window:
	; #[ Little redraw inside window:

little_redraw_inside_window:
 movem.l d0-d3/d6/a0-a4,-(sp)
 move.w d0,window_redrawed(a6)
 lea w1_db(a6),a0
 lsl.w #4,d0
 add.w d0,a0
 tst.b 8(a0)
 beq .end
 move.w $e(a0),d1
 beq .registers
 cmp.w #HEXWIND_TYPE,d1
 beq.s .hex
.end:
 movem.l (sp)+,d0-d3/d6/a0-a4
 rts

.hex:
 move.l a1,d2
 move.l (a0),x_pos(a6)
 move.w 4(a0),d1
 sub.w (a0),d1
 bsr get_m_l_v
 move.w d6,memory_loop_value(a6)
 lea $a(a0),a1
 move.w 6(a0),d4
 subq.w #2,d4
 move.l $a(a0),a0
.8:
 add.w d3,a0
 cmp.l a0,d2
 ble.s .line_before
 addq.w #1,y_pos(a6)
 dbf d4,.8
.after_line_before:
 addq.w #1,y_pos(a6)
 bra .end
.line_before:
 move.l $18(sp),d0
 move.l a0,$18(sp)
 sub.l a0,d0
 neg.l d0
 add.l d0,$14(sp)
 bsr.s .little_dump
 bra.s .after_line_before
.little_dump:
 sub.w d3,a0
 move.l (a1),-(sp)
 move.l a1,-(sp)
 move.l a0,(a1)
 lea line_buffer(a6),a0
 sf optimise_address(a6)
 sf memory_parity_flag(a6)
.100:
 btst #0,3(a1)
 beq.s .23
 st memory_parity_flag(a6)
.23:
 lea line_buffer(a6),a0
 bsr init_buffer2
 move.l (a1),a4
 _JSR dat_to_asc_l_3
 st allowed_memory_flag(a6)
 move.b #" ",(a0)+
 move.l a4,-(sp)
 move.w memory_loop_value(a6),d6
.1:
 move.l a4,a1
 _JSR dat_to_asc_w_3
 tst.b readable_buffer(a6)
 beq.s .38
 move.b #"*",-4(a0)
 move.b #"*",-3(a0)
.38:
 tst.b readable_buffer+1(a6)
 beq.s .39
 move.b #"*",-2(a0)
 move.b #"*",-1(a0)
.39:
 move.b #" ",(a0)+
 tst.b memory_parity_flag(a6)
 beq.s .55
 move.b -2(a0),-1(a0)
 move.b -3(a0),-2(a0)
 move.b #" ",-3(a0)
.55:
 addq.w #2,a4
 dbf d6,.1
 move.b #" ",(a0)+
 move.l (sp)+,a4
 move.w memory_loop_value(a6),d6
 add.w d6,d6
 addq.w #1,d6
.2:
 _JSR test_if_readable3
 tst.b readable_buffer(a6)
 beq.s .37
 move.b #"*",d0
 bra.s .4
.37:
 move.b (a4),d0
 bne.s .4
 move.b #" ",d0
.4:
 move.b d0,(a0)+
 addq.w #1,a4
 dbf d6,.2
 clr.b (a0)+
 _JSR print_instruction
 move.l (sp)+,a1
 move.l (sp)+,(a1)
 rts
.registers:
;
; redessin en temps reel des registres
;
 bra .end
	; #] Little redraw inside window:
	; #[ Get memory loop value:

get_m_l_v:
 cmp.w #26,d1
 bne.s .1
 moveq #4,d3
 moveq #1,d6
.1:
 cmp.w #50,d1
 bne.s .2
 move.w #10,d3
 moveq #4,d6
.2:
 cmp.w #78,d1
 bne.s .3
 moveq #16,d3
 moveq #7,d6
.3:
 cmp.w #38,d1
 bne.s .4
 moveq #8,d3
 moveq #3,d6
.4:
 cmp.w #158,d1
 bne.s .5
 moveq #32,d3
 moveq #15,d6
.5:
 cmp.w #106,d1
 bne.s .6
 moveq #16,d3
 moveq #7,d6
.6:
 rts

	; #] Get memory loop value:
	; #[ Windows Init:

windows_init:
 movem.l d4/d7/a4-a5,-(sp)
 bsr build_lock
 lea windows_to_redraw(a6),a4
 lea w1_db(a6),a5
 moveq #5,d7
.1:
 tst.b (a4)+
 beq.s .not_this
 tst.b 8(a5)
 beq.s .not_this
 move.b 9(a5),current_window_flag(a6)
 move.w (a5),upper_x(a6)
 move.w 2(a5),upper_y(a6)
 move.w 4(a5),lower_x(a6)
 move.w 6(a5),lower_y(a6)
 _JSR draw_window
 move.w d7,d0
 neg.w d0
 addq.w #5,d0
 movem.l d0/a4,-(sp)
 bsr redraw_inside_window
 movem.l (sp)+,d0/a4
 bsr update_title
.not_this:
 lea $10(a5),a5
 dbf d7,.1
 movem.l (sp)+,d4/d7/a4-a5
 rts

	; #] Windows Init:
	; #[ Even Odd:

even_odd:
 move.l d0,-(sp)
 move.w a1,d0
 btst #0,d0
 beq.s .end
 move.b -2(a0),-1(a0)
 move.b -3(a0),-2(a0)
 move.b #" ",-3(a0)
.end:
 move.l (sp)+,d0
 rts

	; #] Even Odd:
	; #[ Build lock buffer+pointers:

build_lock2:
 movem.l d0-d3/d6-d7/a0-a5,-(sp)
 lea buffer_lock_pointers(a6),a5
 lea w1_db(a6),a0
 lsl.w #2,d7
 add.w d7,a5
 move.l (a5),a2
 lsl.w #2,d7
 add.w d7,a0
 clr.w d7
 bra.s _build

build_lock:
 movem.l d0-d3/d6-d7/a0-a5,-(sp)
 lea buffer_lock_pointers(a6),a5
 lea w1_db(a6),a0
 lea wind_save(a6),a2
 moveq #4,d7
_build:
 move.l a2,(a5)+
 tst.b 8(a0)
 beq.s .3
 move.w $e(a0),d0
 add.w d0,d0
 add.w d0,d0
 lea .table(pc),a4
 jsr 0(a4,d0.w)
.3:
 add.w #$10,a0
 dbf d7,_build
 move.l a2,(a5)+
 movem.l (sp)+,d0-d3/d6-d7/a0-a5
 rts

.table:
 bra .registers
 bra .nothing
 bra .memory_dump
 bra .nothing
 bra .nothing
 bra .nothing
 bra .nothing

.registers:
 lea d0_buf(a6),a1
 moveq #$11,d0
.1:
 move.l (a1)+,(a2)+
 dbf d0,.1
 move.w (a1)+,(a2)+
.nothing:
 rts
.memory_dump:
 move.w 4(a0),d1
 sub.w (a0),d1
 bsr get_m_l_v
 addq.w #1,d6
 add.w d6,d6
 move.w d6,d3
 move.w 6(a0),d2
 subq.w #1,d2
 mulu d2,d3
 subq.w #1,d3
 move.l $a(a0),a1
.4:
 _JSR test_if_readable5
 tst.b readable_buffer(a6)
 bne.s .8
 move.b (a1)+,(a2)+
 dbf d3,.4
 rts
.8:
 addq.w #1,a1
 addq.w #1,a2
 dbf d3,.4
 rts

	; #] Build lock buffer+pointers:
	; #[ Get next instruction:
;--- INPUT ---
;ds a0 l'@ a partir de laquelle scanner
;--- OUTPUT ---
;a0=@ instruction d'apres
;d0=taille instruction

get_next_instruction:
	move.l	a0,a1
	move.l	a1,test_instruction(a6)
	lea	line_buffer(a6),a0
	_JSR	disassemble_line
	tst.w	d0
	bmi.s	.error
	lea	instruction_descriptor(a6),a0
	move.w	_I_size(a0),d0
	add.w	d0,a1
	move.l	a1,a0
.end:
	rts
.error:
	moveq	#-1,d0
	bra.s	.end

;	movem.l	d1-d7/a1-a5,-(sp)
;	move.l	a0,d7
;.0:
;	lea lock_m2_buffer(a6),a3
;	moveq #22,d1
;.1:
;	cmp.l (a3)+,d7
;	beq.s .end
;	dbf d1,.1
;.calculate:
;	st relock_pc_flag(a6)
;	moveq #1,d0
;	move.l device_number(a6),-(sp)
;	clr.l device_number(a6)
;	bsr redraw_inside_window
;	move.l (sp)+,device_number(a6)
;	bra.s .0
;.end:
;	tst.l	(a3)
;	beq.s	.calculate
;	move.l	(a3),a0
;	move.l	a0,d0
;	sub.l	d7,d0
;	movem.l	(sp)+,d1-d7/a1-a5
;	rts

	; #] Get next instruction:
	; #[ clr_c_line:
clr_c_line:
	move.w	y_pos(a6),-(sp)
	move.b	c_line(a6),-(sp)
	st	c_line(a6)
	move.w	column_len(a6),y_pos(a6)
	bsr.s	clr_line
	move.b	(sp)+,c_line(a6)
	move.w	(sp)+,y_pos(a6)
	rts
	; #] clr_c_line:
	; #[ clr_line:
clr_line:
	movem.l	d7/a2,-(sp)
	lea	empty_string(a6),a2
	;choper x_pos courant,enlever 80 et reputer
	move.w	line_len(a6),d7
	sub.w	x_pos(a6),d7
	bmi.s	.no_clear
	tst.b	c_line(a6)
	beq.s	.not_c
	addq.w	#1,d7
.not_c:
	clr.b	(a2,d7.w)
	_JSR	print_instruction
	move.b	#' ',(a2,d7.w)
.no_clear:
	movem.l	(sp)+,d7/a2
	rts
	; #] clr_line:
	; #[ Print_a2:
print_a2:
	move.b	c_line(a6),-(sp)
	move.l	x_pos(a6),-(sp)
	st	c_line(a6)
	move.l	a2,a0
	bsr	strlen2
	move.w	d0,x_pos(a6)
	move.w	column_len(a6),y_pos(a6)
	bsr.s	clr_line
	clr.w	x_pos(a6)
	move.w	line_len(a6),d0
	bsr.s	print_line
	move.l	(sp)+,x_pos(a6)
	move.b	(sp)+,c_line(a6)
	rts
	; #] Print_a2:
	; #[ Print_line:
print_line:
	move.l	a2,-(sp)
	move.w	d0,d1
	move.l	a2,a0
	bsr	strlen2
	lea	printm_buffer(a6),a2
	move.l	a2,a1
.l1:
	move.b	(a0)+,(a1)+
	dbf	d0,.l1
	;mettre un 0
	clr.b	(a1)
	clr.b	0(a2,d1.w)
	_JSR	print_instruction
	move.l	(sp)+,a2
	rts
	; #] Print_line:
	; #[ Print_m_line:
print_m_line:
	move.b	m_line(a6),-(sp)
	move.l	x_pos(a6),-(sp)
	st	m_line(a6)
	move.w	line_len(a6),d0
	bsr.s	print_line
	move.l	(sp)+,x_pos(a6)
	move.b	(sp)+,m_line(a6)
	rts
	; #] Print_m_line:
	; #[ Print_message:
print_message:
	;tester basse
	tst.b	low_rez(a6)
	bne.s	.pas_afficher
	;tester register sleeping
	moveq	#0,d0
	bsr	get_noaddr_wind
	bpl.s	.pas_afficher
	tst.b	8(a0,d0.w)
	beq.s	.pas_afficher
	move.b	c_line(a6),-(sp)
	move.b	m_line(a6),-(sp)
	move.l	x_pos(a6),-(sp)
	move.w	#60,x_pos(a6)
;	move.w	#10,y_pos(a6)
	move.w	big_window_coords+2(a6),y_pos(a6)
	add.w	#9,y_pos(a6)
	st	m_line(a6)
	sf	c_line(a6)
	bsr	clr_line
	move.w	line_len(a6),d0
	sub.w	#60,d0
	bsr	print_line
	move.l	(sp)+,x_pos(a6)
	move.b	(sp)+,m_line(a6)
	move.b	(sp)+,c_line(a6)
.pas_afficher:
	rts
	; #] Print_message:
	; #[ Print ascii:
;prend de a1 tous les caracteres,teste un char C ascii_eol_chars.
;quand rencontre,cherche jusqu'au prochain caractere |C ascii_eol_chars

;--- IN ---
;a0=@ descripteur fenetre
;a1=@ d'ou dumper
;d0=offset x

;--- INTERNAL ----
;d7=lg en x
;d6=lg en y
;d5=sup x
;d4=sup y
;d3=compteur de colonne
;d2=compteur de lignes

;a0=ptr sur fenetre
;a3=ptr sur ascii_eol_chars
;a4=line_buffer
;a5=@ affichage

;--- OUT ---
;a0=@ de fin d'affichage
print_ascii:
	movem.l	d3-d7/a2-a5,-(sp)
	move.w	d0,d5
;	move.w	d0,d4
	lea	line_buffer(a6),a4
	move.l	a1,a5
	;lenx
	move.w	4(a0),d7
	sub.w	(a0),d7
	subq.w	#1,d7
	;leny
	move.w	6(a0),d6
	;pour le dbf
	subq.w	#2,d6
	;supx,y
	move.l	(a0),x_pos(a6)

	;construire chaque ligne de a5->a4 jusqu'a lf et printer
.new_line:
	move.l	line_len_max(a6),d3
	move.l	a4,a0
.l3:
	;tester l'@ de fin si a2!=0
	move.l	a2,d0
	beq.s	.s3
	;si fin ligne vide
	cmp.l	a2,a5
	bge	.print
.s3:
	lea	ascii_eol_chars,a3
	move.l	a5,a1
	_JSR	test_if_readable5
	tst.b	readable_buffer(a6)
	bne.s	.ddbbff2
	move.b	(a5),d0
.scan_if_eol2:
	move.b	(a3)+,d1
	bmi.s	.out
	cmp.b	d1,d0
	bne.s	.scan_if_eol2
.ddbbff2:
	addq.w	#1,a5
	dbf	d3,.l3
.out:
	move.w	d7,d3
	add.w	d5,d3
.l1:
	lea	ascii_eol_chars,a3
	;test if readable
	move.l	a5,a1
	_JSR	test_if_readable5
	tst.b	readable_buffer(a6)
	bne.s	.etoile
	move.b	(a5),d0
.scan_if_eol:
	move.b	(a3)+,d1
	bmi.s	.not_eol
	cmp.b	d0,d1
	beq.s	.print
	bra.s	.scan_if_eol
.not_eol:
	cmpi.b	#9,d0
	beq.s	.tab
.all:
	;tout autre caractere
	move.b	d0,(a0)+
.ddbbff:
	addq.w	#1,a5
	dbf	d3,.l1
	;auto line feed
	tst.b	ascii_line_wrap_flag(a6)
	bne.s	.print
	move.l	a0,-(sp)
	move.l	a5,a1
	moveq	#0,d0
	_JSR	down_line_ascii
	move.l	(sp)+,a0
	move.l	a1,a5
	bra.s	.print
.tab:
	move.w	d7,d0
	add.w	d5,d0
	sub.w	d3,d0
	move.w	d3,d1
	bsr	expand_ascii_tab
	bmi.s	.ddbbff
	sub.w	d0,d3
	addq.w	#1,a5
	bra	.l1
.etoile:
	move.b	#'*',(a0)+
	bra.s	.ddbbff
.print:
	clr.b	(a0)
	move.l	a4,a0
	bsr	strlen2
	cmp.w	d5,d0
	bgt.s	.clipx
	clr.b	(a4)
	bra.s	.realprint	
.clipx:
	lea	0(a4,d5.w),a0
	move.l	a4,a1
	bsr	strcpy2
.realprint:
	_JSR	print_instruction
	addq.w	#1,y_pos(a6)
	dbf	d6,.new_line
	move.l	a5,a0
	movem.l	(sp)+,d3-d7/a2-a5
	rts

;Input:
;a0=@ du buffer ou il faut expander le tab
;d0=colonne
;d1=nb de chars max
;Output:
;d0=nb de chars pokes
expand_ascii_tab:
	move.l	d3,-(sp)
	move.w	d1,d3
	andi.l	#$ffff,d0
	move.w	d0,d1
	;hallucinos
	move.l	tab_value(a6),-(sp)
	ble.s	.no_tab
	divu	2(sp),d0
	andi.l	#$ffff,d0
	addq.w	#1,d0
	mulu	2(sp),d0
;	andi.l	#$ffff,d0
	sub.w	d1,d0
	;suffisamment de chars?
	cmp.w	d0,d3
	bgt.s	.ok
	;non, alors je prends le min
	moveq	#1,d3
	move.w	d3,d0
	bra.s	.ok2
.ok:
	move.w	d0,d3
.ok2:
	subq.w	#1,d0
	moveq	#' ',d1
.l2:
	move.b	d1,(a0)+
	dbf	d0,.l2
.end:
	addq.w	#4,sp
	move.w	d3,d0
	move.l	(sp)+,d3
	tst.w	d0
	rts
.no_tab:
	moveq	#-1,d3
	bra.s	.end
	; #] Print ascii:
	IFNE	sourcedebug
	; #[ Print source ascii:
;--- IN ---
;a0=@ descripteur fenetre
;a1=@ d'ou dumper
;a2=@ de fin
;d0=offset x
;d1=compteur de lignes de depart

;--- INTERNAL ----
;d7=lg en x
;d6=lg en y (compteur de lignes)
;d5=sup x
;d4=max strlen
;d3=compteur de colonne
;d2=

;a2=@ de fin
;a3=compteur de lignes
;a4=line_buffer
;a5=@ affichage

;--- OUT ---
;a0=@ de fin d'affichage
;d=max strlen
print_source_ascii:
	movem.l	d3-d7/a2-a5,-(sp)
	;lenx
	move.w	4(a0),d7
	sub.w	(a0),d7
	subq.w	#1,d7
	;leny
	move.w	6(a0),d6
	;pour le dbf
	subq.w	#2,d6
	;supx,y
	move.l	(a0),x_pos(a6)

	move.w	d0,d5
	move.l	d1,a3
	moveq	#0,d4
	lea	line_buffer(a6),a4
	move.l	a1,a5

	;construire chaque ligne de a5->a4 jusqu'a lf et printer
.new_line:
	move.l	a4,a0
	move.l	a5,a1
	move.l	a3,d0
	move.w	d7,d1
	add.w	d5,d1
	bsr	print_line_source_ascii
	move.l	a1,a5
	bmi.s	.blkline
	beq.s	.print
	;auto line feed
	tst.b	ascii_line_wrap_flag(a6)
	bne.s	.print
	addq.l	#1,a3
	move.l	a4,a0
	bsr	strlen2
	move.w	d0,-(sp)
	move.l	a5,a0
	move.l	a2,a1
	bsr	down_line_source
	move.l	a0,a5
	move.w	d0,d1
	move.w	(sp)+,d0
	add.w	d0,d1
	cmp.w	d1,d4
	bge.s	.not_higher
	move.w	d1,d4
	bra.s	.not_higher
.print:
	addq.l	#1,a3
	move.l	a4,a0
	bsr	strlen2
	cmp.w	d0,d4
	bge.s	.not_higher
	move.w	d0,d4
.not_higher:
	cmp.w	d5,d0
	bgt.s	.clipx
.blkline:	clr.b	(a4)
	bra.s	.realprint	
.clipx:	lea	0(a4,d5.w),a0
	move.l	a4,a1
	bsr	strcpy2
.realprint:
	_JSR	print_instruction
	addq.w	#1,y_pos(a6)
	dbf	d6,.new_line
	move.l	a5,a0
	move.w	d4,d0
	movem.l	(sp)+,d3-d7/a2-a5
	rts

;In:
;a0=ascii buffer
;a1=ascii text
;a2=limit
;d0=line number
;d1=max chars
;Out:
;d0=end of ascii text:
;1:still characters
;0:good
;-1:reached
;a0=end buffer
;a1=end ascii text
;Inside:
;a5=ascii text
;a4=ascii buffer
;a3=break ptr if any
;a2=limit

;d7=max chars
;d4=line count
;d3=cars nb
print_line_source_ascii:
	movem.l	d3-d7/a2-a5,-(sp)
	move.l	a0,a4
	move.l	a1,a5
	move.l	d0,d4
	move.w	d1,d7
	suba.l	a3,a3
	cmp.l	a2,a5			;si fin ligne vide
	bgt	.blkline
	moveq	#0,d3			;0
	tst.b	src_checkcode_flag(a6)
	beq.s	.nocode
	move.l	a5,a0
	move.l	d4,d0
	bsr	check_if_code
	bmi.s	.nocode
	moveq	#$fa,d3			;petit .
.nocode:	move.l	a5,a0			;break or not
	bsr	_get_src_break
	bmi.s	.notbreak
;	moveq	#$2a,d3			;etoile
	moveq	#8,d3			;check
	move.l	a0,a3
.notbreak:
	lsl.w	#8,d3
	move.l	source_pc_ptr(a6),d0	;pc or not
	beq.s	.notpc
	cmp.l	a5,d0
	bne.s	.notpc
	or.b	src_pc_marker(a6),d3	;petite fleche
.notpc:	move.w	d3,-(sp)
	move.l	d4,-(sp)			;numero de ligne
	addq.l	#1,(sp)
	pea	src_line_format_buf(a6)
	move.l	a4,a0
	bsr	sprintf2
	lea	10(sp),sp

	move.l	a4,a0
	bsr	strlen2
	add.w	d0,a0
	move.w	d7,d3
;	moveq	#9,d1
;	moveq	#10,d2
.l1:	cmp.l	a2,a5			;si fin ligne vide
	bgt	.print
	move.b	(a5),d0
	cmp.b	#13,d0
	beq.s	.cr
	cmp.b	#10,d0
	beq.s	.lf
	cmp.b	#' ',d0
	beq.s	.space
	cmpi.b	#9,d0
	beq.s	.tab
.all:	move.b	d0,(a0)+			;tout autre caractere
.ddbbff:	addq.w	#1,a5
	dbf	d3,.l1
	bra.s	.still
.space:	tst.b	ascii_show_inv_flag(a6)
	beq.s	.all
	moveq	#$f8,d0
	bra.s	.all
.cr:	tst.b	ascii_show_inv_flag(a6)
	bne.s	.all
	bra.s	.ddbbff
.tab:	move.w	d7,d0
	sub.w	d3,d0
	move.w	d3,d1
	bsr	expand_ascii_tab
	bmi.s	.ddbbff
	sub.w	d0,d3
	addq.w	#1,a5
	tst.b	ascii_show_inv_flag(a6)
	beq	.l1
	move.b	#$f9,-1(a0)
	bra	.l1
.lf:	addq.w	#1,a5
	tst.b	ascii_show_inv_flag(a6)
	beq.s	.print
	move.b	d0,(a0)+
.print:	moveq	#0,d3
.end:	clr.b	(a0)
	move.l	a3,d1
	beq.s	.nobreak
;	move.b	#' ',(a0)+
;	move.b	#'[',(a0)+
;	move.l	a3,a1
;	exg	a0,a1
;	bsr	strcpy2
;	exg	a0,a1
;	subq.w	#1,d0
;	add.w	d0,a0
;	move.b	#']',(a0)+
;	clr.b	(a0)
	move.l	a3,a1
	_JSR	_display_break
.nobreak:	move.l	a5,a1
	move.l	d3,d0
	movem.l	(sp)+,d3-d7/a2-a5
	rts
.blkline:	moveq	#-1,d3
	bra.s	.end
.still:	moveq	#1,d3
	bra.s	.end

;In:
;a0=@ de debut
;a1=@ de fin
;Out:
;d0=nb de car descendus
;d1=nb de lignes descendues
down_line_source:
	movem.l	d3-d4,-(sp)
	moveq	#13,d1
	moveq	#10,d2
	moveq	#0,d3
	moveq	#0,d4
.l1:
	cmp.l	a1,a0
	bge.s	.failure
	move.b	(a0)+,d0
	cmp.b	d1,d0
	beq.s	.see_if_lf
	cmp.b	d2,d0
	beq.s	.success
	addq.l	#1,d3
	bra.s	.l1
.see_if_lf:
	cmp.b	(a0),d2
	bne.s	.success
	addq.w	#1,a0
.success:
	moveq	#1,d4
.failure:
	move.l	d3,d0
	move.l	d4,d1
	movem.l	(sp)+,d3-d4
	rts

;In:
;a0=@ de debut
;a1=@ de fin
;Out:
;(d0=nb de car descendus)
;d1=nb de lignes descendues
up_line_source:
	move.l	d4,-(sp)
	addq.w	#1,a0
	moveq	#0,d4
.l1:
	cmp.l	a1,a0
	blt.s	.failure
	move.b	-(a0),d0
	cmp.b	#10,d0
	bne.s	.l1
	cmp.b	#13,-1(a0)
	bne.s	.no_cr
	subq.w	#1,a0
.no_cr:
.l2:
	cmp.l	a1,a0
	blt.s	.success
	move.b	-(a0),d0
	cmp.b	#10,d0
	beq.s	.success
	cmp.b	#13,d0
	bne.s	.l2
.success:
	moveq	#1,d4
.failure:
	addq.w	#1,a0
	move.l	d4,d1
	move.l	(sp)+,d4
	rts
	; #] Print source ascii:
	ENDC	;de sourcedebug
	; #[ Switch windows:

switch_windows:
 tst.b meta_rez(a6)
 beq.s .low_high
.high_meta:
 lea w1_db(a6),a0
 lea meta_w1_db(a6),a1
 moveq #5,d0
 bra.s .2
.low_high:
 lea w1_db(a6),a0
 lea low_w1_db(a6),a1
 moveq #5,d0
.2:
 movem.l a0-a1,-(sp)
 moveq #1,d1
.1:
 move.l (a0),d2
 move.l (a1),(a0)+
 move.l d2,(a1)+
 dbf d1,.1
 moveq #1,d1
.3:
 move.w (a0),d2
 move.w (a1),(a0)+
 move.w d2,(a1)+
 addq.w #4,a0
 addq.w #4,a1
 dbf d1,.3
 movem.l (sp)+,a0-a1
 lea $10(a0),a0
 lea $10(a1),a1
 dbf d0,.2
 lea w1_db(a6),a0
 move.w #1,window_selected(a6)
 moveq #5,d0
.5:
 tst.b 9(a0)
 bne.s .4
 add.w #$10,a0
 addq.w #1,window_selected(a6)
 dbf d0,.5
.4:
 move.b low_window_magnified(a6),d0
 move.b window_magnified(a6),low_window_magnified(a6)
 move.b d0,window_magnified(a6)
 lea window_buffer(a6),a0
 lea low_window_buffer(a6),a1
 moveq #3,d1
.6:
 move.l (a0),d0
 move.l (a1),(a0)+
 move.l d0,(a1)+
 dbf d1,.6
 moveq #4,d1
.7:
 move.b (a0),d0
 move.b (a1),(a0)+
 move.b d0,(a1)+
 dbf d1,.7
 bra build_lock

	; #] Switch windows:
	; #[ Evaluate:
		include	"eval_128.s"
	; #] Evaluate:
;  #] Windows management subroutines:
;  #[ Preferences stuff:
;d0=magic tag
;d1=handle
write_magic_header:
	IFEQ	bridos
	move.l	d0,-(sp)
	move.w	v_number(a6),-(sp)
	move.l	#ADEBUG_MAGIC,-(sp)
	move.l	#BRAINSTORM_MAGIC,-(sp)
	lea	(sp),a0
	moveq	#14,d0
	bsr	write_file
	lea	14(sp),sp
	ENDC ; de bridos
	rts

;In:
;d0=requested magic
;d1=handle
;Out:
;d0=error (bad magics, bad version)
read_magic_header:
	movem.l	d7/a2,-(sp)
	move.l	d0,d7
	moveq	#14,d0			;intentionnel
	sub.w	d0,sp
	lea	(sp),a0
	bsr	read_file
	bmi.s	.end
	lea	(sp),a0
	cmp.l	#BRAINSTORM_MAGIC,(a0)+
	bne.s	.not_brst_magic
	cmp.l	#ADEBUG_MAGIC,(a0)+
	bne.s	.not_adbg_magic
	move.w	(a0)+,d0
	cmp.w	v_number(a6),d0
	bne.s	.not_good_version
	cmp.l	(a0),d7
.end:	lea	14(sp),sp
	movem.l	(sp)+,d7/a2
	rts
.not_brst_magic:
.not_adbg_magic:
	lea	bad_magic_file_error_text,a2
	bra.s	.print_error
.not_good_version:
	lea	bad_version_file_error_text,a2
.print_error:
	bsr	print_press_key
	moveq	#-1,d0
	bra.s	.end

	; #[ Load preferences:
load_preferences:
	movem.l	d4/a5,-(sp)
	IFEQ	bridos
	lea	save_var,a0
	bsr	open_file
	bmi	.copy
	move.l	d0,d4
	move.l	#PREF_MAGIC,d0
	move.l	d4,d1
	bsr	read_magic_header
	bne.s	.close_copy

	lea	preferences_table(a6),a0
	moveq	#PREF_FILE_SIZE,d0
	move.l	d4,d1
	bsr	read_file
	bmi.s	.close_copy
	move.l	d4,d0
	bsr	close_file
	bra.s	.end
.close_copy:
	move.l	d4,d0
	bsr	close_file
	ENDC
.copy:
	lea	def_pref_values_table,a0
	tst.b	crdebug_flag(a6)
	beq.s	.ok
	lea	small_pref_values_table,a0
.ok:
	lea	pref_value_buf(a6),a1
.more_value:
	move.l	(a0)+,d0
	bmi.s	.end_of_values
	move.l	d0,(a1)+
	bra.s	.more_value
.end_of_values:
.more_flags:
	move.b	(a0)+,d0
	bgt.s	.end_of_flags
	move.b	d0,(a1)+
	bra.s	.more_flags
.end_of_flags:
.end:
	IFNE	AMIGA
	jsr	update_for_prefs
	ENDC	; de AMIGA
	tst.b	inverse_video_flag(a6)
	bne.s	.real_end
	_JSR	_not_palette
.real_end:
	movem.l	(sp)+,d4/a5
	rts
	; #] Load preferences:
	; #[ Save preferences:
save_preferences:
	movem.l	d4,-(sp)
	IFEQ	bridos
	lea	save_var,a0
	bsr	create_file
	bmi.s	.end
	move.l	d0,d4
	move.l	#PREF_MAGIC,d0
	move.l	d4,d1
	bsr	write_magic_header
	bmi.s	.close

	moveq	#PREF_FILE_SIZE,d0
	lea	preferences_table(a6),a0
	move.l	d4,d1
	bsr	write_file
.close:
	move.l	d4,d0
	bsr	close_file
	ENDC    ; de bridos
.end:
	movem.l	(sp)+,d4
	rts

save_prinfo:
	IFEQ	bridos
	lea	exec_name_buf(a6),a0
	tst.b	(a0)
	beq	.end
	lea	misc_name_buf(a6),a1
	lea	win_ext_text,a2
	bsr	get_new_ext
	move.l	a1,a0
	bsr	create_file
	bmi.s	.end
	move.l	d0,d4
	;entete avec # de version
	move.l	#PRINFO_MAGIC,d0
	move.l	d4,d1
	bsr	write_magic_header
	bmi.s	.close
	;type de debug
	lea	source_type(a6),a0
	moveq	#2,d0
	move.l	d4,d1
	bsr	write_file
	bmi.s	.close
	;reso
	lea	rez_flags(a6),a0
	moveq	#8,d0
	move.l	d4,d1
	bsr	write_file
	bmi.s	.close
	;fenetres
	lea	gen_wind_buf(a6),a0
	move.l	#WINDOWS_PREFS_SIZE,d0
	move.l	d4,d1
	bsr	write_file
	bmi.s	.close
	;history
	move.l	current_his_size(a6),-(sp)
	move.l	history_size(a6),-(sp)
	lea	(sp),a0
	moveq	#8,d0
	move.l	d4,d1
	bsr	write_file
	addq.w	#8,sp
	bmi.s	.close
	move.l	history_size(a6),d0
	move.l	history_addr+4(a6),a0
	move.l	d4,d1
	bsr	write_file
;	bmi.s	.close
;
;
;
.close:
	move.l	d4,d0
	bsr	close_file
.end:
	ENDC ; de bridos
	rts

load_prinfo:
	movem.l	d4-d5,-(sp)

	lea	exec_name_buf(a6),a0
	tst.b	(a0)
	beq	.end
	lea	misc_name_buf(a6),a1
	lea	win_ext_text,a2
	bsr	get_new_ext
	move.l	a1,a0
	bsr	open_file
	bmi	.end
	move.l	d0,d4
	move.l	#PRINFO_MAGIC,d0
	move.l	d4,d1
	bsr	read_magic_header
	bne	.close
	;type de debug+reso
	lea	prinfo_check_buffer(a6),a0
	move.l	a0,-(sp)
	moveq	#10,d0
	move.l	d4,d1
	bsr	read_file
	move.l	(sp)+,a0
	bmi.s	.close
	move.w	(a0)+,d0
	cmp.w	source_type(a6),d0
	bne.s	.close
	lea	rez_flags(a6),a1
	move.l	(a0)+,d0
	cmp.l	(a1)+,d0
	bne.s	.close
	move.l	(a0)+,d0
	cmp.l	(a1)+,d0
	bne.s	.close
	;fenetres
	lea	gen_wind_buf(a6),a0
	move.l	#WINDOWS_PREFS_SIZE,d0
	move.l	d4,d1
	bsr	read_file
	bmi.s	.close
	;retraiter les adresses
	;historique
	subq.w	#8,sp
	lea	(sp),a0
	moveq	#8,d0
	move.l	d4,d1
	bsr	read_file
	move.l	(sp)+,a0
	move.l	(sp)+,a1
	bmi.s	.close
	cmp.l	history_size(a6),a0
	bgt.s	.no_his
	move.l	a0,d0
	move.l	a1,current_his_size(a6)
	move.l	history_addr+4(a6),a0
	move.l	d4,d1
	bsr	read_file
;	bmi.s	.close
	move.l	history_addr(a6),a0
	add.l	current_his_size(a6),a0
	move.l	a0,cur_history_addr(a6)
.no_his:
.close:
	move.l	d4,d0
	bsr	close_file
.end:
	movem.l	(sp)+,d4-d5
	rts

;a0=nom de fichier
;a1=buffer dest
;a2=new ext
get_new_ext:
	move.l	a1,-(sp)
	bsr	strcpy2
	move.l	a1,a0
	add.w	d0,a0
	moveq	#'.',d1
.l1:
	cmp.l	a1,a0
	ble.s	.cat
	move.b	-(a0),d0
	cmp.b	d1,d0
	bne.s	.l1
.copy:
	move.l	a2,a1
	exg	a0,a1
	bsr	strcpy2
.end:
	move.l	(sp)+,a1
	rts
.cat:
	move.l	a1,a0
	bsr	strlen2
	add.w	d0,a0
	bra.s	.copy
	; #] Save preferences:
;  #] Preferences stuff:
;  #[ Variable stuff:
	; #[ Load Variables: charge 'adebug.var'
;internal:
;d7=compteur de macros
;d6=compteur de lignes
;d5=compteur d'erreurs

;a5=@ source (flottante)
;a4=@ source (fixe)
;a3=@ de fin du fichier charge
load_variables:
	suba.l	a1,a1
	moveq	#-1,d0
	moveq	#-1,d1
	moveq	#-1,d2
	bsr	load_file
	move.l	a0,a5
	move.l	a0,a4
	bmi	.end
	move.l	d0,d4
	;@ de fin de fichier
	lea	(a0,d0.l),a3
	clr.b	(a3)
	moveq	#0,d6
	moveq	#0,d7
	moveq	#0,d5
.one_more_var:
	move.b	(a5),d0
	beq	.no_more

	tst.b	debug2_var_flag(a6)
	beq.s	.no_debug2
	move.l	a5,a0
.l0:
	move.b	(a0)+,d0
	beq.s	.out
	IFNE	ATARIST
	cmp.b	#13,d0
	ENDC
	IFNE	AMIGA
	cmp.b	#10,d0
	ENDC
	bne.s	.l0
.out:
	clr.b	-1(a0)
	move.l	a5,-(sp)
	move.l	d5,-(sp)
	move.l	d6,-(sp)
	move.l	d7,-(sp)
	pea	debug2_var_format
	lea	line_buffer(a6),a2
	move.l	a2,a0
	bsr	sprintf2
	lea	5*4(sp),sp
	bsr	print_result
	_JSR	get_char
	cmp.b	#27,d0
	beq	.exit_in_super
.no_debug2:
	move.l	a5,a0
	bsr	create_one_var
	;nb de macros traitees
	add.l	d2,d7
	;nb de lignes traitees
	add.l	d1,d6

	cmp.l	a3,a0
	bge.s	.no_more
	;nouvelle ligne
	move.l	a0,a5
	tst.l	d0
	bge.s	.one_more_var
;.syntax_error:
	addq.l	#1,d5
	;@ de l'erreur
	move.l	a1,-(sp)
	;# de ligne
	move.l	d6,-(sp)
	;# de macro
	move.l	d7,-(sp)
	;# de l'erreur
	not.l	d0
	move.w	d0,-(sp)
	pea	syntax_error_var_text
	lea	line_buffer(a6),a2
	move.l	a2,a0
	bsr	sprintf2
	lea	18(sp),sp
	bsr	print_error
	;-1 macro quand meme
	subq.l	#1,d7
	tst.b	debug1_var_flag(a6)
	beq	.one_more_var
	_JSR	get_char
	cmp.b	#27,d0
	beq.s	.no_more
	bra	.one_more_var
.exit_in_super:
	lea	initial_path(a6),a0
	_JSR	set_drivepath
	_JMP	exit_in_super
.no_more:
	move.l	d5,-(sp)
	move.l	d6,-(sp)
	move.l	d7,-(sp)
	pea	var_loaded_text
	lea	line_buffer(a6),a2
	move.l	a2,a0
	bsr	sprintf2
	lea	16(sp),sp
	bsr	print_result
	;tri des variables
	bsr	create_var_tree
	bsr	redraw_all_windows
.abort:
	move.l	a4,a0
	move.l	d4,d0
	_JSR	free_memory
.end
	rts
	; #] Load Variables:
	; #[ Create one var:
;--- INPUT ---
;a0=ptr (!!!RAM!!!) sur la chaine formatee d'initialisation
;cette chaine peut se terminer par 13,10 ou par 0
;<name[,type]=eval>

;--- IN ---
;reconnaissance du nom,du type,de l'expression a evaluer
;puis put in table du tout
;(d'ou update des vars et autres la)
;d5=type
;d6=nb de lignes traitees (normalement 1)
;d7=reussite
;a2=deuxieme ptr
;a3=premier ptr
;a4=ptr (flou) sur ligne
;a5=ptr sur nom

;--- OUTPUT ---
;d0=succes (pour syntax error,d'ou un tri plus affine)
;-1=fin de ligne prematuree,caractere non ascii
;-2=erreur d'evaluation de la premiere expression
;-3=erreur d'evaluation de la deuxieme expression
;-4=erreur de put_in_table (plus de place ou existe deja sous un autre type)

;a0=@ source
;a1=@ de l'erreur si d0 negatif
create_one_var:
	movem.l	d4-d7/a2-a5,-(sp)
	move.l	a0,a4
	move.l	a0,a5
	;par defaut une ligne
	moveq	#1,d6
	;par defaut type la
	move.w	#LAWORD,d5
	;par defaut une var
	moveq	#1,d4
.one_more_char:
	;je prends un caractere de a4
	move.b	(a4)+,d0
	;fin de ligne prematuree
	beq	.abort_a4
	;remarque ?
	cmpi.b	#';',d0
	bne.s	.no_comment	; skipper la fin de la ligne
	;moins une var
	subq.l	#1,d4
	bra	.good
.no_comment:
	cmpi.b	#'-',d0
	bne.s	.not_opt
	lea	opt_var_table,a0
	lea	opt_var_flags_table(a6),a1
	move.b	(a4),d1
.l40:
	move.b	(a0)+,d2
	beq.s	.not_opt
	cmp.b	d2,d1
	beq.s	.found
	tst.b	(a1)+
	bra.s	.l40
.found:
	;moins une var
	subq.l	#1,d4
	move.b	1(a4),d1
	cmp.b	#'-',d1
	bne.s	.set_flag
	sf	(a1)
	bra	.good
.set_flag:
	cmp.b	#'+',d1
	seq	(a1)
	bra	.good
.not_opt:
	;type
	cmpi.b	#',',d0
	beq.s	.set_type
	;valeur
	cmpi.b	#"=",d0
	beq.s	.set_val
	;espace
	cmpi.b	#' ',d0
	beq.s	.one_more_char
	;tab
	cmpi.b	#9,d0
	beq.s	.one_more_char
	;aut'chose
	cmpi.b	#33,d0
	bpl.s	.one_more_char
	bra	.abort_a4
.set_type:
	;un 0 a la place de la virgule
	clr.b	-1(a4)
	;type
	move.b	(a4)+,d5
	lsl.w	#8,d5
	move.b	(a4)+,d5
	bra.s	.one_more_char
.set_val:
	;premier ptr par defaut sur l'expression ascii
	move.l	a4,a3
	;fin de la ligne:
.l1:
	move.b	(a4)+,d0
	beq.s	.eol
	sub.b	#10,d0
	beq.s	.eol
	subq.b	#13-10,d0
	beq.s	.eol
	cmpi.b	#';'-13,d0
	beq.s	.eol
	;pour les blocks
	cmpi.w	#BLWORD,d5
	bne.s	.l1
	cmpi.b	#','-13,d0
	bne.s	.l1
.eol:
	move.b	-(a4),d7
	clr.b	(a4)
	move.l	a4,a0
	bsr	pskip
	;pour le scd ptr (bloc)
	move.l	a0,a2
	move.b	(a3),d0

	;eval,lr ou nom de fichier/@ ?
	cmp.w	#LAWORD,d5
	beq.s	.eval
	cmp.w	#EQWORD,d5
	beq.s	.eval
	cmp.w	#ROWORD,d5
	beq.s	.file
	cmp.w	#EXWORD,d5
	IFNE	ATARIST
	beq.s	.eval
	ENDC
	IFNE	AMIGA
	bne.s	.no_ex
	jsr	eval_amiga_ex
	bra.s	.eval
.no_ex:
	ENDC
	cmp.w	#LRWORD,d5
	beq.s	.put
	cmp.w	#BLWORD,d5
	beq.s	.file
;	cmp.w	#LMWORD,d5
;	beq.s	.abort_type
	bra.s	.abort_type
.eval:
	move.l	a3,a0
	bsr	evaluate
	move.b	d7,(a4)
	tst.w	d1
	bmi.s	.abort_a3
	;premier ptr = valeur
	move.l	d0,a3
	IFNE	AMIGA
	cmp.w	#EXWORD,d5
	bne.s	.put
	add.l	text_buf(a6),a3
	ENDC
	bra.s	.put
.file:
	cmp.b	#'"',d0
	beq.s	.put
	cmp.b	#"'",d0
	beq.s	.put

	;bloc en memoire
	cmp.w	#BLWORD,d5
	bne.s	.put
	;initialiser le scd ptr
	move.b	(a2),d0
	cmp.b	#'"',d0
	beq.s	.put
	cmp.b	#"'",d0
	beq.s	.put
	move.l	a2,a1
.l2:
	move.b	(a1)+,d0
	beq.s	.eval2
	cmp.b	#13,d0
	beq.s	.clr2
	cmp.b	#10,d0
	bne.s	.l2
.clr2:
	clr.b	-(a1)
.eval2:
	move.l	a2,a0
	bsr	evaluate
	move.b	d7,(a4)
	tst.w	d1
	bmi.s	.abort_a2
;	bra.s	.put
.put:
	;type
	move.w	d5,d0
	;nom
	move.l	a5,a0
	;ptr 1
	move.l	a3,a1
	;ptr 2 deja ds a2

	bsr.s	put_in_table
	move.l	a5,a2
	bmi.s	.abort_a5
.good:
	moveq	#0,d7
	bra.s	.end
.abort_type:
	moveq	#-5,d7
	bra.s	.end
.abort_a5:
	moveq	#-4,d7
	bra.s	.end
.abort_a2:
	moveq	#-3,d7
	bra.s	.end
.abort_a3:
	moveq	#-2,d7
	move.l	a3,a2
	bra.s	.end
.abort_a4:
	moveq	#-1,d7
	move.l	a4,a2
.end:
	;ruse pour down_line_ascii
	subq.w	#1,a4
	move.l	a4,a1
	moveq	#1,d0
	_JSR	down_line_ascii
	move.l	a1,a4
	;nouvelle @
	move.l	a4,a0
	;@ de l'erreur
	move.l	a2,a1
	;nb de lignes traitees
	move.l	d6,d1
	;nb de variables traitees
	move.l	d4,d2
	;resultat
	move.l	d7,d0
	movem.l	(sp)+,d4-d7/a2-a5
	rts
	; #] Create one var:
	; #[ Put in Table: recoit l'@ de la chaine a evaluer ; se demerde ensuite
;---IN---:
;d0=nouveau type
;a0=@ chaine variable a creer
;a1=premier pointeur
;a2=deuxieme pointeur (si besoin)
;---INTERNAL---:
;d4=premier ptr
;d5=deuxieme ptr
;d6=nouveau type
;d7=nb de caracteres
;a2=@ nom a creer
;a3=cur la addr
;a4=cur var addr
;(a5=fin var addr)
;---OUT---:
;d0=nouveau type ou -1 si plus de place (avec affichage de l'erreur)
;a0=premier ptr
;a1=deuxieme ptr
put_in_table:
	movem.l	d4-d7/a2-a5,-(sp)

	;parametres sauves
	moveq	#0,d6
	move.w	d0,d6
	;deuxieme ptr
	move.l	a2,d5
	;nom de variable
	move.l	a0,a2
	;premier ptr
	move.l	a1,d4

	IFNE	sourcedebug
	tst.w	source_type(a6)
	beq.s	.no_source
	bsr	get_curwind_type
	bne	.putinsrc
.no_source:
	ENDC	;de sourcedebug

	;encore de la place ?
	move.l	current_la_addr(a6),a3
	move.l	current_var_addr(a6),a4
	move.l	var_tree_addr(a6),a0
	subq.w	#8,a0
	cmp.l	a0,a4
	bge	.var_full

	;tester var_exist_flag pour verif
	tst.b	overwrite_var_flag(a6)
	bne.s	.not_found
	;il existe deja ?
	moveq	#-1,d0
	moveq	#0,d1
	moveq	#0,d2
	bsr	find_in_table
	bmi.s	.not_found
	;interdire le changement de type
	cmp.w	d0,d6
	bne	.error
;	cmp.w	#BLWORD,d6
;	beq.s	.swapbl
;	cmp.w	#ROWORD,d6
;	beq.s	.swapro
	cmp.w	#BLWORD,d6
	beq	.error
	cmp.w	#ROWORD,d6
	beq	.error
	move.l	d4,(a1)
	bra	.not_a_block
;.swapro:
;.swapbl:
;	move.l	(a1),a0
;	tst.w	BLPTR_TYPE(a0)
;	bpl
;	lea	-VAR_BLPTR(a1),a4
;	bsr	free_bl
;	bra	.bl
.not_found:
	;ptr sur label
	move.l	a3,(a4)
.found:	;type
	move.w	d6,4(a4)

	cmp.w	#LAWORD,d6
	beq.s	.d4_is_ptr
	cmp.w	#EQWORD,d6
	beq.s	.d4_is_ptr
	cmp.w	#ROWORD,d6
	beq.s	.bl
	cmp.w	#LRWORD,d6
	beq.s	.lr
	cmp.w	#EXWORD,d6
	beq.s	.d4_is_ptr
	cmp.w	#LMWORD,d6
	beq.s	.d4_is_ptr
	cmp.w	#BLWORD,d6
	beq.s	.bl
	bra	.error	;pas d'autre type
.bl:	move.l	d4,a0
	move.l	d5,a1
	move.l	d6,d0
	bsr	create_one_bl
	bmi	.rbl
	move.l	a0,d4	;nouveau premier ptr
	move.l	a1,d5	;nouveau deuxieme ptr
	move.l	d1,d6	;nouveau type
	bra.s	.d4_is_ptr
.lr:	move.l	d4,a0
	bsr	create_one_lr
	bmi	.lr_full
	move.l	a0,d4	;nouveau premier ptr
;	bra.s	.d4_is_ptr
.d4_is_ptr:
	;overflow ?
	move.l	end_la_addr(a6),a0
	sub.w	line_buffer_size(a6),a0
	move.l	a0,d0
	sub.l	a3,d0
	bmi	.la_full
	moveq	#0,d7
.l1:
	addq.l	#1,d7
	move.b	(a2)+,(a3)+
	bne.s	.l1

	;nom
	;omettre les symboles interdits
;	move.l	a2,a0
;	move.l	a3,a1
;	move.l	a2,-(sp)

;	moveq	#0,d7
;.l1:
;	addq.l	#1,d7
;	move.b	(a0)+,d0
;	lea	eot_table+1,a2
;.l0:
;	move.b	(a2)+,d1
;	beq.s	.out0
;	cmp.b	d0,d1
;	beq.s	.l1
;	bra.s	.l0
;.out0:
;	move.b	d0,(a1)+
;	bne.s	.l1

;	move.l	(sp)+,a2

	;taille du nom:
	add.l	d7,current_la_addr(a6)
	add.l	d7,current_la_size(a6)

	;premier pointeur
	move.l	d4,6(a4)

	;taille de la struct
	addq.l	#1,current_var_nb(a6)
	add.l	#10,current_var_addr(a6)

	lea	bl_types_table,a0
	move.w	d6,d1
	bclr	#15,d1
.l2:	move.w	(a0)+,d0
	beq.s	.not_a_block
	cmp.w	d1,d0
	bne.s	.l2

	move.l	current_blocks_addr(a6),a0
	;le ptr est maintenant un ptr sur struct
	move.l	a0,6(a4)
	;dont le premier ptr est l'@ de debut
	move.l	d4,(a0)+
	;dont le deuxieme ptr est l'@ de fin
	move.l	d5,(a0)+
	;puis le type
	move.w	d6,(a0)
	;et j'incremente l'@ des blocks
	add.l	#10,current_blocks_addr(a6)
	addq.l	#1,current_blocks_nb(a6)
.not_a_block:
	bclr	#15,d6
.end0:	move.l	d4,a0
	move.l	d5,a1
	move.l	d6,d0
.end:	movem.l	(sp)+,d4-d7/a2-a5
	rts
	;--- ERREURS ---
.rbl:	addq.w	#1,d0
	beq.s	.bl_full
	move.l	a1,-(sp)
	bclr	#15,d6
	bclr	#13,d6
	move.w	d6,-(sp)
	pea	blnf_error_text
	lea	line_buffer(a6),a2
	move.l	a2,a0
	bsr	sprintf2
	lea	10(sp),sp
	bra.s	.print
.la_full:	lea	la_full_text,a2
	bra.s	.print
.lr_full:	lea	lr_full_text,a2
	bra.s	.print
.bl_full:	lea	bl_full_text,a2
	bra.s	.print
;.ex_full:	lea	ex_full_text,a2
;	bra.s	.print
.var_full:
	lea	var_full_text,a2
.print:	bsr	print_press_key
;	cmp.b	#27,d0
;	beq	exit_in_super
.error:	moveq	#-1,d6
	bra.s	.end0
	IFNE	sourcedebug
.putinsrc:
	move.l	a2,a0
	moveq	#0,d0
	bsr	get_var_by_name
	bmi	.no_source
	tst.b	(a0)		;cdef
	beq	.error
	move.l	d4,d0
	bsr	set_var_value
 	bra	.end0
	ENDC	;de sourcedebug
	; #] Put in Table:
	; #[ Create_one_lr:
;-- In --
;a0=l'expression a recopier
;-- Out --
;a0=l'@ de l'expression dans le buffer de lr
create_one_lr:
	;recopier l'expression ds current_lr_addr
	move.l	current_lr_addr(a6),a1
	move.l	a1,d1
	cmp.l	end_lr_addr(a6),a1
	bge.s	.error
.l1:
	move.b	(a0)+,d0
	beq.s	.out1
	cmp.b	#10,d0
	beq.s	.out1
	cmp.b	#13,d0
	beq.s	.l1
	move.b	d0,(a1)+
	bra.s	.l1
.out1:
	clr.b	(a1)+
	move.l	a1,current_lr_addr(a6)
	moveq	#0,d0
	bra.s	.end
.error:
	moveq	#-1,d0
.end:
	move.l	d1,a0
	rts
	; #] Create_one_lr:
	; #[ Create_one_bl:
;--- IN ---
;a0=premier ptr
;ce ptr peut etre un pointeur sur un nom de fichier precede d'un " ou '
;il peut etre aussi une @ memoire
;comment le savoir ? (pour l'instant test du quote)
;a1=deuxieme ptr (s'il y a lieu)
;d0=type (ro ou bl)
;--- OUT ---
;d0=reussite
;d1=nouveau type
;a0=premier ptr
;c'est le ptr qui est dans la struct BL
;a1=deuxieme ptr
;pour etre updates ds la struct VAR
create_one_bl:
	movem.l	d6-d7/a2-a5,-(sp)
	move.l	d0,d6
	move.l	current_blocks_nb(a6),d0
	cmp.l	blocks_max(a6),d0
	bge.s	.rmem
	move.b	(a0),d0
	cmp.b	#'"',d0
	beq.s	.a0_is_filename
	cmp.b	#"'",d0
	beq.s	.a0_is_filename
	bset	#15,d6
	bra.s	.blisptr
.a0_is_filename:
	tst.l	table_bl_size(a6)
	beq.s	.rmem
	move.l	current_bl_addr(a6),a1
	move.l	end_bl_addr(a6),d0
	sub.l	a1,d0
	ble.s	.rmem
	addq.w	#1,a0		;passer le quote
	moveq	#-1,d1
	moveq	#0,d2
	IFNE	AMIGA
	tst.b	internal_ros_flag(a6)
	beq.s	.load_it
	move.l	current_internal_ro_addr(a6),a0
	addq.l	#4,a0
	bra.s	.no_load
.load_it:
	ENDC
	bsr	load_file
	bmi.s	.rfile
.no_load:
	move.l	d0,d7
	move.l	a0,a5
	cmp.w	#ROWORD,d6
	bne.s	.dont_reloc
	;move.l	d7,d0
	moveq	#0,d1
	move.l	a5,a0
	_JSR	update_ro
	move.l	d0,d7
.dont_reloc:
	add.l	d7,current_bl_addr(a6)
	add.l	d7,current_bl_size(a6)
	move.l	a5,a0
	move.l	a5,a1
	add.l	d7,a1
.blisptr:	moveq	#0,d0
.end:	move.l	d6,d1
	tst.l	d0
	movem.l	(sp)+,d6-d7/a2-a5
	rts
.rmem:	moveq	#-1,d0
	bra.s	.end
.rfile:	moveq	#-2,d0
	bra.s	.end

	; #] Create_one_bl:
	; #[ Free_bl:
free_bl:
	subq.l	#1,current_blocks_nb(a6)	;-1 block
	move.l	a0,d0
	beq.s	.end
	move.l	BLPTR_START(a0),d0		;@ debut
	beq.s	.end
	move.l	BLPTR_END(a0),d1		;@ fin
	sub.l	d0,d1				;taille du block
	tst.w	BLPTR_TYPE(a0)			;tester si reserve
	bpl.s	.nofree

	move.l	d0,a0
	move.l	d1,d0
	_JSR	free_memory
	bra.s	.end
.nofree:
	sub.l	d1,current_bl_size(a6)		;en moins de la taille des blocks
	sub.l	d1,current_bl_addr(a6)
.end:	rts
	; #] Free_bl:
	; #[ Rm_in_table:
;a0=@ de la variable a virer
rm_in_table:
	move.l	a5,-(sp)
	move.l	a0,a5

	move.l	VAR_NAME(a5),d0
	beq.s	.clr
	move.l	d0,a0
	bsr	strlen2
	addq.l	#1,d0
	sub.l	d0,current_la_size(a6)
	bsr	strclr2

	move.w	VAR_TYPE(a5),d0
	cmp.w	#LAWORD,d0
	beq.s	.clr
	cmp.w	#EQWORD,d0
	beq.s	.clr
	cmp.w	#ROWORD,d0
	beq.s	.clrbl
	cmp.w	#LRWORD,d0
	beq.s	.clrlr
	cmp.w	#BLWORD,d0
	beq.s	.clrbl
;	cmp.w	#EXWORD,d0
;	beq.s	.clr
;	cmp.w	#LMWORD,d0
;	beq.s	.clr
	bra.s	.clr
.clrlr:	move.l	VAR_VALUE(a5),d0
	beq.s	.clr
	move.l	d0,a0
	bsr	strclr2
	bra.s	.clr
.clrbl:	move.l	VAR_BLPTR(a5),a0
	bsr	free_bl
.clr:	clr.l	(a5)+
	clr.w	(a5)+
	clr.l	(a5)
	subq.l	#1,current_var_nb(a6)
.end:	move.l	(sp)+,a5
	rts
	; #] Rm_in_table:
	; #[ Find in Table: recoit l'@ de la chaine a evaluer;renvoie l'@ du descripteur
;---IN---:
;a2 = @ chaine a trouver
;d0 = -1 ou le  type
;d1 = execution(1) ou non(0)
;d2 = completion(1) ou non(0)
;---INTERNAL---:
;a1 = @ table_var
;a2 = @ chaine a trouver (source)
;a3 = @ table_la
;a4 = @ chaine incrementale
;a5 = @ fin tables (DES tableS)
;d6 = flag d'execution
;d7 = le type demande
;---OUT---:
;d0 = type trouve
;d1 = nombre renvoye:
;	-la:@
;	-lr:@ evaluee
;	-bl:premiere @
;	-ro:RESULTAT de la routine
;	-ex:@+TEXT
;	-lm:@ de l'expression suivant le label
;d2 = deuxieme @ si bl
;a1 = @ du descripteur (pointe APRES le descripteur)

find_in_table:
	movem.l	d5-a0/a2-a5,-(sp)
	move.w	d0,d7
	move.w	d1,d6
	move.w	d2,d5
	IFNE	sourcedebug
	tst.w	source_type(a6)
	beq.s	.not_source_var
	tst.w	d7
	bmi	.source_var
	cmp.w	#LAWORD,d7
	beq	.source_var
.not_source_var:
	ENDC	;de sourcedebug
	move.l	current_var_addr(a6),a5
	move.l	table_var_addr(a6),a1
	tst.l	current_var_nb(a6)
	ble	.end_of_table
	subq.w	#6,a1
.another_label:
	addq.w	#6,a1
	cmp.l	a1,a5
	ble.s	.end_of_table
	move.w	d5,d0
	move.l	(a1)+,a0
	exg	a1,a2
	bsr	var_strcmp
	exg	a1,a2
	bmi.s	.another_label

	moveq	#0,d0
	move.w	(a1)+,d0
	move.l	(a1),d1

	tst.b	d6
	beq.s	.found

	cmp.w	#LAWORD,d0
	beq.s	.end
	cmp.w	#EQWORD,d0
	beq.s	.end
	cmp.w	#ROWORD,d0
	beq.s	.ro
	cmp.w	#LRWORD,d0
	beq.s	.lr
	cmp.w	#EXWORD,d0
	beq.s	.ex
	cmp.w	#BLWORD,d0
	beq.s	.bl
	cmp.w	#LMWORD,d0
	beq.s	.lm
	;not found:
.end_of_table:
	moveq	#-1,d0
	bra.s	.end
.lm:	cmp.w	d0,d7
	bne.s	.end_of_table
.la:	moveq	#0,d0
	move.w	-2(a1),d0
.found:
.end:	tst.l	d0
	movem.l	(sp)+,d5-a0/a2-a5
	rts
.lr:
	move.l	d1,a0
	bsr	_evaluate
	tst.w	d0
	bmi.s	.end_of_table
;	move.l	d0,d1
	bra.s	.la
.ro:
	move.l	d1,a0
	move.l	(a0),a0
	bsr	execute_ro
	move.l	d0,d1
	bra.s	.la
.bl:
	move.l	d1,a0
	move.l	(a0),d1
;	move.l	4(a0),d2
	bra.s	.la
.ex:
	IFEQ	AMIGA
	add.l	text_buf(a6),d1
	ENDC
	bra.s	.la
	IFNE	sourcedebug
.source_var:
	move.l	a2,a0
	move.w	d5,d0
	bsr	get_var_by_name
	bmi	.not_source_var
	move.l	d0,d1
	move.l	#LAWORD,d0
	lea	false_internal_var(a6),a1
	_JSR	get_var_name
	move.l	a0,(a1)
	addq.w	#6,a1
	move.l	d1,(a1)
	bra	.found
	ENDC	;de sourcedebug
;In:
;d0=completion
;a0=string 1
;a1=string 2
;Out:
;d0=success
var_strcmp:
	movem.l	a0/a1,-(sp)
	move.w	d0,d2
	tst.b	case_sensitive_flag(a6)
	beq.s	.next_char_2
.next_char_1:
	cmpm.b	(a1)+,(a0)+
	bne.s	.maybe_not_found
	tst.b	-1(a0)
	bne.s	.next_char_1
	bra.s	.this_label
.maybe_not_found:
	tst.w	d2
	beq.s	.not_found
	tst.b	-1(a1)
	beq.s	.this_label
	bra.s	.not_found
.next_char_2:
	move.b	(a1)+,d0
	beq.s	.may_be_this_label
	bmi.s	.full_test
.reduced_test:
	cmp.b	(a0)+,d0
	beq.s	.next_char_2
	bchg	#5,d0
	cmp.b	-1(a0),d0
	beq.s	.next_char_2
	bra.s	.not_found
.full_test:
	cmp.b	(a0)+,d0
	beq.s	.next_char_2
	bra.s	.not_found
.may_be_this_label:
	tst.w	d2
	bne.s	.this_label
	tst.b	(a0)
	bne.s	.not_found
.this_label:
	moveq	#0,d0
	bra.s	.end
.not_found:
	moveq	#-1,d0
.end:
	movem.l	(sp)+,a0/a1
	rts
	; #] Find in Table:
	; #[ Check_if_ro:
; --- INPUT ---
;a2=chaine a chercher
; --- IN ---
;a5=ptr incremental
; --- OUT ---
;d0 = reussite
check_if_ro:
	movem.l d1/a1-a5,-(sp)
	move.l	table_var_addr(a6),a1
	move.l	current_var_addr(a6),a5
	subq.w	#6,a1
.another_label:
	addq.w	#6,a1
	cmp.l	a1,a5
	ble.s	.not_found

	move.l	(a1)+,a3
	move.l	a2,a4
.2:

	cmpm.b	(a3)+,(a4)+
	bne.s	.another_label
	tst.b	-1(a4)
	bne.s	.2

	cmp.w	#ROWORD,(a1)
	bne.s	.not_found
	move.l	2(a1),a1
	move.l	(a1),eval_ro_address(a6)
	moveq	#0,d0
	bra.s	.end
.not_found:
	st	eval_ro_address(a6)
	moveq	#-1,d0
.end:
	movem.l (sp)+,d1/a1-a5
	rts
	; #] Check_if_ro:
	; #[ call_child:
;-- Input --
;a0=child_struct
;pc (ro @/shell call @)	0
;	ds.l	1
;a0 (ro_struct @/shell cmd_line @)	4
;	ds.l	1
;a1 (parameters @)	8
;	ds.l	1
;d0 (parameters #)	$c
;	ds.l	1
;screen mode (-1=switch to logic/0=no switch)	$10
;	ds.b	1
;user state (0=user/-1=super)	$11
;	ds.b	1
;trap
;free
;-- In --
;a5=child_struct
;a4=ro @

;But:
;switcher de contexte:
;sauver l'ancien contexte

call_child:
	movem.l	d1-a5,-(sp)
	move.l	a0,a5

	;get next pc value
	move.l	(a5),a4
	;a0=child struct already set
	;give return @
	lea	.debug_return(pc),a1
	bsr.s	allocate_routine
	st	run_flag(a6)
	move.b	log_run_flag(a6),d3
	move.b	nowatch_flag(a6),d4
	move.b	$10(a5),d0
	move.b	d0,log_run_flag(a6)
	move.b	d0,nowatch_flag(a6)
	IFNE	AMIGA
	move.b	trace_task_flag(a6),d5
	sf	trace_task_flag(a6)
	ENDC
	bsr	p0p1
	;p1p0 doit me faire revenir ici apres le break
.debug_return:
	move.b	d3,log_run_flag(a6)
	move.b	d4,nowatch_flag(a6)
	IFNE	AMIGA
	move.b	d5,trace_task_flag(a6)
	ENDC
;	tst.b	nowatch_flag(a6)
;	bne.s	.no_relog
	tst.b	v_screen1_flag(a6)
	bne.s	.no_relog
	bsr	sbase1_sbase0
.no_relog:
	move.l	d0_buf(a6),d7
	bsr	disallocate_routine
	move.l	d7,d0
	movem.l	(sp)+,d1-a5
	rts
	; #] call_child:
	; #[ Allocate_routine:
;-- Input --
;a0 child_struct @
;pc (ro @/shell call @)
;	0(a5)
;	ds.l	1
;a0 (ro_struct @/shell cmd_line @)
;	4(a5)
;	ds.l	1
;a1 (parameters @)
;	8(a5)
;	ds.l	1
;d0 (parameters #)
;	12(a5)
;	ds.l	1
;screen mode (0=no logic /-1=logic)
;	16(a5)
;	ds.b	1
;user state (0=user/-1=super)
;	17(a5)
;	ds.b	1
;a1=return @ (piled in corresponding state stack)
;-- In --
;a5 = child struct @
;a4 = return @
allocate_routine:
	movem.l	a4-a5,-(sp)
	move.l	a0,a5
;return @
	move.l	a1,a4
;debug routine flag
	lea	external_context_buffer(a6),a0
	lea	save_external_context_buffer(a6),a1
	moveq	#EXTERNAL_CONTEXT_SIZE/2-1,d0
.l1:
	move.w	(a0)+,(a1)+
	dbf	d0,.l1

	lea	external_context_buffer(a6),a0
;d0 is parameters #
	move.l	12(a5),(a0)
;a0 = ro_struct /shell cmd_line
	move.l	4(a5),8*4(a0)
;a1 = parametres
	move.l	8(a5),9*4(a0)
;usp-ssp:
	lea	ro_usp(a6),a1
	lea	ro_ssp(a6),a2
	tst.b	17(a5)
	bne.s	.super
	;empile ro struct sur pile user
	move.l	4(a5),-(a1)
;	;empile @ de retour sur pile user
;	move.l	a4,-(a1)
	bra.s	.s2
.super:
	;empile ro struct sur pile super
	move.l	4(a5),-(a2)
;	;empile @ de retour sur pile super
;	move.l	a4,-(a2)
.s2:
	move.l	a1,15*4(a0)
	move.l	a2,16*4(a0)
;sr
	;ipl
	IFNE	ATARIST
	move.w	sr,d0
	ENDC
	IFNE	AMIGA
	move.w	current_ipl(a6),d0
	lsl.w	#8,d0
	ENDC
	;super !
	tst.b	17(a5)
	bne.s	.super2
	bclr	#13,d0
.super2:
	move.w	d0,17*4(a0)
;pc
	move.l	(a5),d0
	move.l	d0,18*4-2(a0)

;timers
	tst.b	acia_ikbd(a6)
	beq.s	.no_ipl7
	lea	external_mfp_ctl_struct(a6),a0
	clr.l	(a0)
	lea	external_mfp_speed_struct(a6),a0
	clr.l	(a0)
.no_ipl7:
;breakpoint:
	move.l	d0,a0
	moveq	#2,d0
	move.l	def_break_vec(a6),d1
	move.l	def_break_eval_addr(a6),a1
	move.l	a4,d2
	bsr	set_break

	;trap
	move.b	18(a5),routine_trap_flag(a6)
	movem.l	(sp)+,a4-a5
	rts
	; #] Allocate_routine:
	; #[ Execute ro:
;-- INPUT --
;a0=ro @
;a1=params @
;d0=params #
;--Internal--
;a5=ro @
;a4=params @
;d7=params #
;-- OUTPUT --
;d0 = resultat de la routine
;le flag no_print_eval_ro_flag est mis dans from_rostruct
execute_ro:
	movem.l	d7/a1-a5,-(sp)
	move.l	a1,a4
	move.l	a0,a5
	move.l	d0,d7

	lea	ro_child_struct+16(a6),a2
	lea	$1c+2(a5),a0
.l2:
	move.l	(a0)+,d0
	cmp.l	#'ENDM',d0
	beq.s	.no_magics
	lea	ro_magics_table,a1
.l1:
	move.l	(a1)+,d1
	beq.s	.no_magics
	cmp.l	d1,d0
	beq.s	.found
	move.b	(a1),(a2)+
	tst.w	(a1)+
	bra.s	.l1
.found:
	move.b	1(a1),(a2)+
	bra.s	.l2
	;pas logic par defaut
	;super par defaut
.no_magics:
	bsr.s	to_rostruct
;----------------------------------------
	lea	ro_child_struct(a6),a0
	move.l	a0,a1
	;ro @
	move.l	a5,(a1)+
	;ro struct @
	lea	ro_struct(a6),a2
	move.l	a2,(a1)+
	;parameters @
	move.l	a4,(a1)+
	;parameters #
	move.l	d7,(a1)+
	bsr	call_child
	;ro result
	move.l	d0,d7
;--------------------------------------------
	bsr	from_rostruct
.end:
	move.l	d7,d0
	movem.l	(sp)+,d7/a1-a5
	rts

disallocate_routine:
	lea	save_external_context_buffer(a6),a0
	lea	external_context_buffer(a6),a1
	moveq	#EXTERNAL_CONTEXT_SIZE/2-1,d0
.l1:
	move.w	(a0)+,(a1)+
	dbf	d0,.l1
	sf	routine_trap_flag(a6)
	rts

to_rostruct:
	movem.l	d7/a2-a5,-(sp)
	lea	ro_struct(a6),a5
	move.l	a5,a4
	;remplir la struct
	move.w	v_number(a6),(a4)+	;short	v_number d'Adebug
	IFNE	ATARIST
	move.w	osnumber(a6),(a4)+	;short	os#
	ENDC
	IFNE	AMIGA
	move.l	4.w,a0
	move.l	20(a0),(a4)+	;short	os#
	ENDC
	moveq	#0,d7		;long	windows[5]
.l11:	move.w	d7,d0
	bsr	get_wind
	move.l	a1,(a4)+
	addq.w	#1,d7
	cmp.w	#5,d7
	bne.s	.l11
;	long	TEXT-DATA-BSS-END
	IFNE	ATARIST
	lea	text_buf(a6),a0
	moveq	#4-1,d0
.l12:	move.l	(a0)+,(a4)+
	dbf	d0,.l12
	ENDC
	IFNE	AMIGA
	move.l	amiga_segs(a6),a0
	move.l	(a0),d0
	lsr.l	#2,d0
	move.l	d0,(a4)+
	ENDC
	moveq	#37-1,d0		;long	registers[20]
	lea	d0_buf(a6),a0
.l21:	move.w	(a0)+,(a4)+
	dbf	d0,.l21
	IFNE	ATARIST		;short	reso d'Adebug
	moveq	#0,d0
	lea	$ff8260,a0
	move.w	machine_type(a6),d1
	move.w	.tab(pc,d1.w),d1
	jmp	.tab(pc,d1.w)
.tab:	dc.w	.st-.tab
	dc.w	.ste-.tab
	dc.w	.tt-.tab
	dc.w	.fa-.tab
	dc.w	.nb-.tab
.ste:
.st:	move.b	(a0),d0
	andi.w	#%11,d0
	bra.s	.poke
.tt:	move.b	2(a0),d0
;	andi.w	#%111,d0
	bra.s	.poke
.nb:
.fa:	move.b	(a0),d0
.poke:	move.w	d0,(a4)+
	ENDC	;d'ATARIST
	IFNE	ATARIST	
	move.l	p1_basepage_addr(a6),(a4)+	;char	*basepage_addr
	ENDC
	IFNE	AMIGA
	move.l	Adebug_task(a6),d0
	tst.b	trace_task_flag(a6)
	beq.s	.poke
	move.l	p1_current_task(a6),d0
.poke:	move.l	d0,(a4)+
	ENDC	;d'AMIGA
	move.l	a3,(a4)+		;char	*ro_addr
	IFNE	ATARIST
	move.l	logbase(a6),(a4)+	;char	*logic_screen_addr
	ENDC
	IFNE	AMIGA
	move.l	external_copperlist(a6),(a4)+	;char	*copperlist
	ENDC
	clr.l	(a4)+		;char	*string_addr a afficher
	clr.l	(a4)+		;short	coord[2]
	clr.l	(a4)+		;long	character
	sf	(a4)+		;flag	reput_exc
	move.b	acia_ikbd(a6),(a4)+	;flag	IPL7
	move.l	external_mfp_ctl_struct(a6),(a4)+	;4 flags	timerabcd
	sf	(a4)+		;redraw screen
	cmp.l	#RS232_OUTPUT,device_number(a6)	;rs_232_output
	seq	(a4)+
	sf	(a4)+		;re_exec
	movem.l	(sp)+,d7/a2-a5
	rts

from_rostruct:
	movem.l	d7/a2-a5,-(sp)
	;tenir compte de la struct
	lea	ro_struct(a6),a5
;	int	v_number d'Adebug
	move.w	v_number(a6),d0
	cmp.w	(a5)+,d0
	bne	.end
;	int	tos#
	IFNE	ATARIST
	tst.w	(a5)+
	ENDC
	IFNE	AMIGA
	tst.l	(a5)+
	ENDC
;	long	windows_addr[5]
	moveq	#0,d7
.l12:
	move.w	d7,d0
	move.l	(a5)+,a0
	bsr	put_wind_addr
	addq.w	#1,d7
	cmp.w	#5,d7
	bne.s	.l12
	IFNE	ATARIST
;	long	TEXT-DATA-BSS-END
	lea	text_buf(a6),a0
	moveq	#4-1,d0
.l13:
	move.l	(a5)+,(a0)+
	dbf	d0,.l13
	ENDC
	IFNE	AMIGA
	tst.l	(a5)+
	ENDC
;	long	registres[17]
	moveq	#37-1,d0
	lea	d0_buf(a6),a0
.l22:
	move.w	(a5)+,(a0)+
	dbf	d0,.l22

;	int	reso
	IFNE	ATARIST
	move.w	(a5)+,d0
	jsr	put_internal_rez
	ENDC

;	char	*basepage_addr
	tst.l	(a5)+
;	char	*ro_addr
	tst.l	(a5)+
;	char	*logic_screen_addr
	IFNE	ATARIST
	move.l	(a5)+,logbase(a6)
	ENDC
	IFNE	AMIGA
	move.l	(a5)+,external_copperlist(a6)
	ENDC
;	char	*string_addr a afficher
	move.l	(a5)+,d0
	beq.s	.no_print
;	int	coord[2]
	tst.l	(a5)+
	st	no_print_ro_eval_flag(a6)
	move.l	d0,a2
	st	c_line(a6)
	clr.w	x_pos(a6)
	move.w	column_len(a6),y_pos(a6)
	bsr	clr_line
	move.w	#2,x_pos(a6)
	bsr	print_instruction
;	character
	tst.l	(a5)+
	beq.s	.no_print
	bsr	get_char
	bra.s	.printed
.no_print:
	tst.l	(a5)+
	tst.l	(a5)+
.printed:
;	flag	reput_exc
	tst.b	(a5)+
	beq.s	.dont_reinstall
	bsr	put_exceptions
.dont_reinstall:
;	flag	IPL7
	move.w	initial_ipl(a6),d0
	tst.b	(a5)+
	beq.s	.no_ipl7
	moveq	#7,d0
.no_ipl7:
	bsr	put_internal_sr
;	4 flags	timerabcd
	lea	external_mfp_ctl_struct(a6),a0
	move.l	(a5)+,(a0)
;	redraw screen
	tst.b	(a5)+
	beq.s	.dont_redraw
	bsr	redraw_all_windows
.dont_redraw:
;	rs_232_output
	tst.b	(a5)+
	beq.s	.no_rs232
	moveq	#2,d0
	bsr	_output_to
.no_rs232:
;	re_exec_ro
	tst.b	(a5)+
.end:
	movem.l	(sp)+,d7/a2-a5
	rts

	; #] Execute ro:
	; #[ Find in table 2: recoit une @ et renvoie la variable lui correspondant
;--- IN ---
;d0=@ a rechercher

;--- INTERNAL ---
;d7=@ a chercher
;d6=@ a checker
;d5=type

;a2=@ sur nom a recopier
;a3=@ courant sur table_var_addr
;a4=@ fin var table
;a5=@ buffer ou mettre le nom

;--- OUT ---
;d0:
;<0 if nf
;=0 if found
;>0 if found lower
;a2=@ var
find_in_table2:
	movem.l	d1-a1/a3-a4,-(sp)
	move.l	d0,d7
	IFNE	_68030
	tst.b	chip_type(a6)
	bne.s	.no_and
	ENDC
	andi.l	#$ffffff,d7
.no_and:	tst.l	current_var_nb(a6)
	beq.s	.nf
	tst.b	symbols_flag(a6)
	beq.s	.nf
	tst.l	var_tree_addr(a6)
	bne.s	.find_in_tree

	move.l	current_var_addr(a6),a4
	move.l	table_var_addr(a6),a3
.more_one:
	cmp.l	a4,a3
	bge.s	.nf
	move.l	(a3)+,a2
	move.w	(a3)+,d5
	move.l	(a3)+,d6
	cmp.w	#LAWORD,d5
	beq.s	.see_if_la
	cmp.w	#EQWORD,d5
	beq.s	.more_one
	cmp.w	#ROWORD,d5
	beq.s	.more_one
	cmp.w	#LRWORD,d5
	beq.s	.see_if_lr
	cmp.w	#BLWORD,d5
	beq.s	.see_if_bl
;	cmp.w	#LMWORD,d5
;	beq.s	.more_one
	cmp.w	#EXWORD,d5
	bne.s	.more_one
.see_if_ex:
	IFEQ	AMIGA
	add.l	text_buf(a6),d6
	ENDC
	bra.s	.see_if_la
.see_if_lr:
	;evaluer lr
;	move.l	d6,a0
;	bsr	evaluate
;	move.l	d0,d6
;	bra.s	.see_if_la
	bra.s	.more_one
.see_if_bl:
	move.l	d6,a0
	move.l	(a0),d6
	;bra.s	.see_if_la
.see_if_la:
	cmp.l	d6,d7
	bne.s	.more_one
	lea	-VAR_SIZE(a3),a2
	moveq	#0,d0
.end:	movem.l	(sp)+,d1-a1/a3-a4
	rts
.nf:	moveq	#-1,d0
	bra.s	.end
.find_in_tree:
	move.l	d7,a0
	bsr.s	find_var_in_tree
	bmi.s	.end
	move.l	VAR_TREE_VAR(a0),a2	;ptr sur struct
	bra.s	.end

;In:
;a0=@
;Out:
;d0
find_var_in_tree:
	move.l	a0,a1
	move.l	var_tree_nb(a6),d0
	move.l	var_tree_addr(a6),d1
	lea	comp_var_tree_2(pc),a0
	bsr	trouve2
;	bne.s	.not_found
;	moveq	#0,d0
;	rts
;.not_found:
;	moveq	#-1,d0
	rts

comp_var_tree_2:
	;recherche par ordre d'adresse croissante
	mulu	#VAR_TREE_SIZE,d0
	move.l	VAR_TREE_VALUE(a0,d0.l),d1
	cmp.l	d3,d1
	rts

comp_var_tree:
	;tri par ordre d'adresse croissante
	move.l	d5,d0
	mulu	#VAR_TREE_SIZE,d0

	move.l	d6,d1
	mulu	#VAR_TREE_SIZE,d1

	movea.l	0(a0,d1.l),a3
	cmpa.l	0(a0,d0.l),a3
	rts

inv_var_tree:
	lea	(a0,d0.l),a1
	lea	(a0,d1.l),a2
	;2 longs a switcher
;	movem.l	(a1)+,d0-d1
;	move.l	(a2)+,-8(a1)
;	movem.l	d0-d1,-8(a2)

	;@
	move.l	(a1),d0
	move.l	(a2),(a1)+
	move.l	d0,(a2)+

	;compteur
	move.l	(a1),d0
	move.l	(a2),(a1)+
	move.l	d0,(a2)+

	;ptr vers var
	move.l	(a1),d0
	move.l	(a2),(a1)
	move.l	d0,(a2)
	rts

	; #] Find in table 2:
	; #[ Write line ascii:
;ds a0 le descripteur de fenetre
;ds a1 l'@ de la chaine a imprimer
write_line_ascii:
	;passer a gauche de la fenetre
	move.w	(a0),x_pos(a6)
	move.l	a1,a2
	bra	print_instruction
	; #] Write line ascii:
	; #[ Get next var:
;--- IN ---
;a0=@ d'ou commencer a scanner
;d0=type voulu ?
;--- OUT ---
;a0=nouvelle @
;d0=-1:echec
;=0:reussi
get_next_var:
.again:
	move.l	current_var_addr(a6),a1
	cmp.l	a1,a0
	bge.s	.abort

	addq.w	#4,a0
	move.w	(a0)+,d1
	addq.w	#4,a0

	;cmp.w	d0,d1
	;bne.s	.again

	moveq	#0,d0
	bra.s	.end
.abort:	moveq	#-1,d0
.end:	tst.w	d0
	rts
	; #] Get next var:
	; #[ Get previous var:
;--- IN ---
;a0=@ d'ou commencer a scanner
;d0=type voulu ?
;--- OUT ---
;a0=nouvelle @
;d0=-1:echec
;=0:reussi
get_prev_var:
	move.l	table_var_addr(a6),a1
	cmp.l	a1,a0
	ble.s	.abort

	subq.w	#6,a0
	move.w	(a0),d1
	subq.w	#4,a0

	;cmp.w	d0,d1
	;bne.s	.again

	moveq	#0,d0
	bra.s	.end
.abort:	moveq	#-1,d0
.end:	tst.w	d0
	rts
	; #] Get previous var:
	; #[ clr_table_end:
;efface de <a0> a la fin de la table des variables
;doit marcher meme si c'est la fin de la table ou pas de table
;a0=@ de debut
clr_table_end:
	movem.l	a2-a5,-(sp)
	move.l	a0,d0
	beq.s	.end
	move.l	a0,a5
	move.l	a0,a3
	move.l	(a0),a2
	move.l	current_var_addr(a6),a4
.l1:	cmp.l	a4,a5
	bge.s	.no_more_var
	move.l	a5,a0
	bsr	rm_in_table
	lea	10(a5),a5
	bra.s	.l1
.no_more_var:
	move.l	a3,current_var_addr(a6)
;	move.l	a2,d0
;	beq.s	.no_la
;	move.l	a2,current_la_addr(a6)
;.no_la:
	bsr	create_var_tree
.end:	movem.l	(sp)+,a2-a5
	rts
	; #] clr_table_end:
	; #[ create_var_tree:
;cree le tableau brut
;puis lance le tri
create_var_tree:
	movem.l	d6-d7/a2-a5,-(sp)
	sf	valid_var_tree_flag(a6)
	move.l	current_var_nb(a6),d7
	beq.s	.end
	move.l	table_var_addr(a6),a4
	tst.b	debug_symbols_flag(a6)
	beq.s	.all_vars
	move.l	before_ctrll_addr(a6),a4
	move.l	exec_sym_nb(a6),d7
	beq.s	.end
.all_vars:
	move.l	var_tree_addr(a6),a5
	move.l	d7,var_tree_nb(a6)
	move.l	d7,d0
.next_var:
	;@
	move.l	6(a4),d2
	;type
	move.w	4(a4),d1
	cmp.w	#LAWORD,d1
	beq.s	.put_address
	cmp.w	#EQWORD,d1
	beq.s	.put_address
	cmp.w	#BLWORD,d1
	beq	.put_bl
	cmp.w	#ROWORD,d1
	beq	.put_bl
	; a changer
	cmp.w	#LRWORD,d1
	beq.s	.put_address
	cmp.w	#LMWORD,d1
	beq.s	.put_address
	cmp.w	#EXWORD,d1
	bne.s	.after_var
	IFNE	ATARIST
	add.l	text_buf(a6),d2
	ENDC
.put_address:
	;@
	move.l	d2,(a5)+
	;compteur
	clr.l	(a5)+
	;ptr sur var
	move.l	a4,(a5)+
.after_var:
	lea	10(a4),a4
	subq.l	#1,d0
	bgt.s	.next_var
	IFNE	sourcedebug
	;mettre les vars C
;	move.l	globals_nb(a6),d0
	ENDC	;de sourcedebug
.tri:	lea	comp_var_tree(pc),a0
	lea	inv_var_tree(pc),a1
	move.l	d7,d0
	move.l	var_tree_addr(a6),d1
	bsr	tri2
	st	valid_var_tree_flag(a6)
.end:
	movem.l	(sp)+,d6-d7/a2-a5
	rts
.put_bl:
	move.l	d2,a0
	move.l	(a0),d2
	bra.s	.put_address
	; #] create_var_tree:
	; #[ put_var_and_tree:
;put la var dans la table des vars et dans l'arbre
;pour l'instant recree l'arbre a chaque fois
put_var_and_tree:
	bsr	put_in_table
	bra	create_var_tree
	; #] put_var_and_tree:
;  #] Variable stuff:
;  #[ Breaks stuff:
	; #[ Set break:
;	dc.l	break_addr
;	dc.l	eval_addr
;	dc.w	number
;	dc.w	vec
;	system = bit 13
;	permanent = bit 14
;	rom = bit 15
;	dc.l	old_long
;	=16 bytes
;place un breakpoint.Auparavant,verifie s'il y en a un, si oui ne fait rien.
;si impossible d'ecrire,et si ctrl_a positionne, cree un break rom.
;--- IN:
;a0=@ du break a mettre
;a1=@ de l'expression a evaluer
;d0.l=option:
;0=rien
;1=permanency
;2=rom break
;3=system break
;4=internal break
;d1.w=num de vecteur
;rom break: d2.l=branch @
;system break: d2=
;flags:8
;2nd number:8
;funcno:16

;--- OUT:
;a0=@ 1st break buffer
;a1=@ 2nd break buffer
;d0<0 si echec
;-1=plus de break
;-2=@ non ecrivible
;-3=bad vector number
;-4=bad eval
;-5=plus d'eval
;d1.w=break #

;--- INT ---
;d3=branch @ if rom break
;d4.w=option
;d5=@ a chercher
;d6.w=vector #
;d7.w=break #

;a2=@ table de format des breakpoints
;a3=@ breaks virtuels
;a4=@ expression a evaluer
;a5=@ du buffer de sauvegarde des breakpoints
set_break:
	cmp.w	#3,d0
	beq	.set_system_break

	movem.l	d3-d7/a2-a5,-(sp)
	move.w	d0,d4
	move.w	d1,d6
	move.l	d2,d3
	move.l	a0,d5
	IFNE	_68030
	tst.b	chip_type(a6)
	bne.s	.not_68000
	ENDC
	andi.l	#$ffffff,d5
.not_68000:
	move.l	a1,a4
	;tester si le vecteur de break est valide
	move.w	d6,d0
	andi.w	#$ff,d0
	lsl.w	#2,d0
	lea	exceptions_caught_buffer(a6),a0
	add.w	d0,a0
	;68000 ?
	tst.w	2(a0)
	bmi	.bad_vector

	;detournable?
	tst.w	(a0)
	beq	.bad_vector

	;tester s'il y a deja un breakpoint
	;s'il y en a un,
	;soit ne rien faire et sortir en indiquant le numero-->impossible
	;pb: si break a evaluation,et evaluation!=0,pas d'arret
	;soit utiliser le meme en le mettant en default_break
	move.w	d4,d0
	moveq	#-1,d1
	move.l	d5,a0
	bsr	_check_if_break
	bpl	.end

	;scan de la table pour trouver de la place libre
	bsr	_get_free_break
	bmi	.no_room
	move.l	a0,a5
	move.l	a1,a3
	move.l	d0,d7
	;l'@ ou on veut mettre le break est lisible et paire ?
	move.l	d5,a0
	bsr	write_baderr
	beq.s	.readable

	;emulation break en rom
	;tester runandbreak_flag
	;si oui emuler le break:
	tst.b	runandbreak_flag(a6)
	beq	.bad_address
	;si bsr-jsr-trap-lineaf emuler le break par la pile
	;sinon: emuler en mode trace until pc==%=lx
	move.l	pc_buf(a6),a0
	bsr	get_instr_type
	beq.s	.general_instr
	subq.w	#4,d0
	bmi.s	.trap_lineaf
	subq.w	#2,d0
	bpl.s	.general_instr
;.bsr_jsr:
	;return addr
	move.l	d5,a1
.emulate_bsr:
	;opcode is jsr
	move.w	#$4eb9,d0
	;a0 is branch addr,already set
	bra.s	._indirect
.trap_lineaf:
	;opcode is trap or linea-f
	move.l	pc_buf(a6),a0
	move.w	(a0),d0
	;return addr
	move.l	d5,a1
	;branch addr is noped
	move.l	#$4e714e71,a0
;	bra.s	._indirect
._indirect:
	bsr	_emulate_indirect_break
	bra.s	.poke2
.general_instr:
	bsr	_emulate_dbcc
	bra	.end
.readable:
	cmp.w	#1,d4
	bne.s	.not_permanent
	bset	#BREAK_IS_PERMANENT,d6
.not_permanent:
	cmp.w	#2,d4
	bne.s	.not_indirect
	move.l	a3,d0
	addq.l	#6,d0
	move.l	d0,ro_return_addr(a6)
	move.l	d0,ro_return_break_addr(a6)
	move.l	d5,a0
	move.l	d3,a1
	bra.s	.emulate_bsr
.not_indirect:
	cmp.w	#4,d4
	bne.s	.not_internal
	bset	#BREAK_IS_INTERNAL,d6
	move.l	a3,d0
	move.l	d0,p1_return_addr(a6)
	addq.l	#6,d0
	move.l	d0,p1_return_break_addr(a6)

	move.l	#$4e714e71,d0
	move.l	d0,a0
	move.l	d3,a1
	bsr	_emulate_indirect_break
	bra.s	.poke2
.not_internal:
	;{du break}.l
	move.l	d5,a0
	move.l	(a0),BREAK_OLDINSTR(a5)
.poke2:
	;@ du break
	move.l	d5,(a5)
	IFNE	sourcedebug
	move.l	d5,d0
	bsr	get_source_addr
	beq.s	.not_in_source
	bset	#BREAK_IN_SOURCE,d6
	move.l	d0,(a2)
	move.l	d1,BREAK_SRC_LNB(a2)
	move.l	a0,BREAK_SRC_MDL(a2)
.not_in_source:
	ENDC	;de sourcedebug

	;@ de l'expression a evaluer
	move.l	a5,a0
	move.l	a4,a1
	bsr	_set_break_eval

	;break #
	move.w	d7,BREAK_NUMBER(a5)
	;vecteur #
	move.w	d6,BREAK_VECTOR(a5)
	;plus un break
	addq.l	#1,current_breaks_nb(a6)

	;d6=break vector
	move.w	d6,d1
	andi.w	#$ff,d1
	lsl.w	#2,d1

	;code hexa de l'exception poke dans le code
	move.l	d5,a0
	;(non detournable deja teste)
	lea	exceptions_caught_buffer(a6),a1
	add.w	d1,a1
	move.w	(a1),(a0)
	move.w	2(a1),a1
	;@ etendue
	;il faudrait sauver l'ancienne {vect}
;	move.l	(a1),d0

	move.b	d6,d0
	;@ de la routine de traitement des exceptions
	lea	breakpt(pc),a0
	bsr	_build_breakpt_address
	;pokee dans le vecteur lui correspondant
	move.l	d0,(a1)

	;@ buffer break
	move.l	a5,a0
	;@ virtuelle
	move.l	a3,a1
	;vector
	and.w	#$ff,d6
	move.w	d6,d1
	;break	set:break nb
	move.l	d7,d0
	bra.s	.end
.no_eval_room:
	moveq	#-5,d0
	bra.s	.end
.bad_vector:
	moveq	#-3,d0
	bra.s	.end
.bad_address:
	moveq	#-2,d0
	bra.s	.end
.no_room:
	moveq	#-1,d0
.end:
	movem.l	(sp)+,d3-d7/a2-a5
	rts
.set_system_break:
	_JMP	set_system_break
	; #] Set break:
	; #[ Test_on_break:
;-IN-
;d7=break#
;d6=vector#
;-OUTPUT-
;d0=
;-1=trouve,laisse,stoppe (eval error)
;0=trouve,enleve,stoppe (==-1)
;1=trouve,laisse,passe (!=-1)
test_on_break:
	move.l	pc_buf(a6),d0
	IFNE	_68030
	tst.b	chip_type(a6)
	bne.s	.no_and
	ENDC
	and.l	#$ffffff,d0
.no_and:
	move.l	d0,a0
	bsr	p0p1_rm_break
	;syntax error
	bmi.s	.bad_break_eval
	;continue
	beq.s	.not_on_breakpoint
	;stop
	;in source: traced
	IFNE	sourcedebug
	tst.b	trace_source_flag(a6)
	bne.s	.as_in_trace
	ENDC	;de sourcedebug
	;in run: break
	tst.b	trace_flag(a6)
	beq.s	.run
.as_in_trace:
	tst.l	d1
	beq.s	.trace_done
.run:
	lea	line_buffer(a6),a3
	bsr	treat_breakpt
	move.l	a3,a2
	bsr	print_result
	bsr	redraw_relock_all
	bra.s	.dont_go_on
.trace_done:
	lea	traced2_text,a2
	bsr	print_result
	bsr	redraw_relock_all
	moveq	#0,d0
	bra.s	.end
.not_on_breakpoint:
	moveq	#1,d0
	bra.s	.end
.bad_break_eval:
	moveq	#-4,d0
	bsr	_print_break_error
.dont_go_on:
	moveq	#-1,d0
.end:
	rts
	; #] Test_on_break:
	; #[ Toggle_break:
;--- INPUT ---
;d0=type (permanency,trap catch)
;d1=vector #
;d2=info dependant du type
;a0=@ a checker
;a1=@ expression a evaluer
toggle_break:
	movem.l	d5-d7/a4-a5,-(sp)
	move.l	a0,a5
	move.l	a1,a4
	move.l	d0,d7
	move.l	d1,d6
	move.l	d2,d5
;	move.l	d7,d0
;	move.l	d6,d1
;	move.l	d5,d2
	bsr	_check_if_break
	bmi.s	.set
	move.l	a5,a0
	move.l	a4,a1
	move.l	d7,d0
	move.l	d6,d1
	move.l	d5,d2
	bsr	_just_rm_break
	bmi.s	.error
	lea	killed_text,a1
	moveq	#1,d1
	bra.s	.print
.set:
	move.l	a5,a0
	move.l	a4,a1
	move.l	d7,d0
	move.l	d6,d1
	move.l	d5,d2
	bsr	set_break
	bmi.s	.error
	lea	set_text,a1
	moveq	#0,d1
.print:
	bsr	_print_break_set_unset
	bsr	redraw_all_windows
	moveq	#0,d0
	bra.s	.end
.error:
	bsr	_print_break_error
	moveq	#-1,d0
.end:
	movem.l	(sp)+,d5-d7/a4-a5
	rts
	; #] Toggle_break:
	; #[ Remove break:
		;#[ p1p0_rm_break:
;--- INPUT ---
;a0=@ a checker (ou = d2 si trap catch)
;;d0=type de break
;d1=vecteur du break
;;d2=info dependant du type

;--- IN ---
;d5=break vector
;d6=break #
;d7=valeur evaluee

;a2
;a3=@ a chercher
;a4=@ expr a evaluer
;a5=@ du buffer du breakpoint

;--- OUTPUT ---
;a0=break @
;a1=eval @
;d0=
	;-1=eval syntax error
	;0=break not found
	;>0=break #
;if found:
;d1=
	;0=continue
	;>0=vector #:
	; --> stop
	;normal break: eval==-1
	;perm break: eval==-1

;buts:
;1:
;toujours enlever le break sauf s'il s'agit:
;d'un break permanent
;d'un break normal a eval !=-1
;2:
;s'arreter si eval==-1 meme si permanent
;on se fiche du mode trace

p1p0_rm_break:
	movem.l	d5-d7/a2-a5,-(sp)
	move.l	a0,a3

	move.l	d1,d5
	st	real_break_flag(a6)
	bsr	_get_break
	tst.l	d0
	bmi.s	.notbreak

	move.l	a0,a5
	;# de vecteur
	moveq	#0,d5
	move.w	BREAK_VECTOR(a5),d5
	;# de break
	moveq	#0,d6
	move.w	BREAK_NUMBER(a5),d6
	;@ de l'eval
	move.l	BREAK_EVAL(a5),a4

	;evaluer
	move.l	a4,a0
	bsr	_eval_break
	bmi.s	.syntax_error
	move.l	d0,d7

	;break permanent
	;jamais enlever
	btst	#BREAK_IS_PERMANENT,d5
	bne.s	.permanent

	;break normal
	;si eval==-1 enlever
	cmpi.l	#-1,d7
	bne.s	.continue
	move.l	a5,a0
	st	real_break_flag(a6)
	bsr	_rm_break
	;et s'arreter
	bra.s	.end
.permanent:
	;si eval==-1 s'arreter
	cmpi.l	#-1,d7
	beq.s	.end
.continue:
	moveq	#0,d5
;	bra.s	.end
.notbreak:
	moveq	#0,d6
	bra.s	.end
.syntax_error:
	moveq	#-1,d6
.end:
	;@ du break
	move.l	a3,a0
	;@ de l'eval
	move.l	a4,a1
	andi.w	#$ff,d5
	move.l	d5,d1
	move.l	d6,d0
	movem.l	(sp)+,d5-d7/a2-a5
	rts
		;#] p1p0_rm_break:
		;#[ p0p1_rm_break:
;-- Input --
;a0=break @
;d0=vector #
;-- Output --
;d0=
	;-1:bad break eval
	;0:no break
	;in trace:continue
	;in run:continue
	;>0:break #
	;in trace:
	;	d1==0-->done
	;	d1>0-->stop
	;in run:continue
;d1=
; if trace:
	;0=done (traced)
	;normal break:eval!=-1
	;permanent break:eval!=-1
	;>0=vector # --> stop on it
	;normal break:eval==-1 & remove
	;permanent:eval==-1
; if run
	;0=break emulated and continue
	;never stops
p0p1_rm_break:
	movem.l	d5-d7/a2-a5,-(sp)
	move.l	a0,a3
	move.l	d0,d5
	st	real_break_flag(a6)
	bsr	_get_break
	tst.l	d0
	bmi.s	.notbreak

	move.l	a0,a5
	;# de vecteur
	moveq	#0,d5
	move.w	BREAK_VECTOR(a5),d5
	;# de break
	moveq	#0,d6
	move.w	BREAK_NUMBER(a5),d6
	;@ de l'eval
	move.l	BREAK_EVAL(a5),a4

	moveq	#-1,d7

	;en source?
	IFNE	sourcedebug
	tst.b	trace_source_flag(a6)
	bne.s	.as_in_trace
	ENDC	;de sourcedebug
	;2 etats:
	;en run pas evaluer
	;en trace,evaluer
	tst.b	trace_flag(a6)
	beq.s	.dont_eval
.as_in_trace:
	move.l	a4,a0
	bsr	_eval_break
	bmi.s	.syntax_error
	move.l	d0,d7
.dont_eval:
	;recopier l'eval
	move.l	BREAK_EVAL(a5),a0
	lea	permbreak_buffer(a6),a4
	move.l	a4,a1
	bsr	strcpy2
	;toujours enlever
	move.l	a5,a0
	st	real_break_flag(a6)
	bsr	_rm_break

	;en source?
	IFNE	sourcedebug
	tst.b	trace_source_flag(a6)
	bne.s	.as_in_trace_2
	ENDC	;de sourcedebug
	;en run toujours emuler (pas d'eval)
	tst.b	trace_flag(a6)
	beq.s	.emulate
.as_in_trace_2:
	btst	#BREAK_IS_PERMANENT,d5
	beq.s	.eval
;.permanent:
	IFNE	switching_debug
	pea	trace_on_permanent_text
	bsr	print_debug
	addq.w	#4,sp
	ENDC
	;trace+permanent=emuler
	bra.s	.emulate
	;trace non permanent=test sur true
.eval:
	cmpi.l	#-1,d7
	beq.s	.stop
	;sinon emuler
.emulate:
	bsr.s	_emulate_break
	bmi.s	.syntax_error

	;en source?
	IFNE	sourcedebug
	tst.b	trace_source_flag(a6)
	bne.s	.as_in_trace_3
	ENDC	;de sourcedebug
	;en run,runandbreak: toujours relancer
	tst.b	trace_flag(a6)
	beq.s	.notbreak
.as_in_trace_3:
	;en trace:
	;si -1 stop --> deja fait
	;si !=-1 done
	moveq	#0,d5
	bra.s	.end
.notbreak:
	moveq	#0,d6
	bra.s	.end
.syntax_error:
	moveq	#-1,d6
.stop:
.end:
	;@ du break
	move.l	a3,a0
	;@ de l'eval
	move.l	a4,a1
	andi.w	#$ff,d5
	move.l	d5,d1
	move.l	d6,d0

	movem.l	(sp)+,d5-d7/a2-a5
	rts
		;#] p0p1_rm_break:
		;#[ _emulate_break:
_emulate_break:
	IFNE	switching_debug
	pea	emulating_break_text(pc)
	bsr	print_debug
	addq.w	#4,sp
	ENDC
	;relancer en mode trace le process
	;switcher de contexte de tracing
	bsr	_save_internal_context
	;passer en mode trace justonce
	st	trace_flag(a6)
	st	justonce_flag(a6)
	sf	nostop_flag(a6)
	sf	run_flag(a6)
	sf	runandbreak_flag(a6)
	sf	exc_emulated_flag(a6)
	bsr	p0p1
	IFNE	switching_debug
	pea	break_emulated_text(pc)
	bsr	print_debug
	addq.w	#4,sp
	ENDC
	;restaurer
	bsr	_restore_internal_context
	;remettre le breakpoint
	move.l	a3,a0
	move.l	a4,a1
	move.l	d5,d1
	moveq	#0,d0
	bclr	#BREAK_IS_PERMANENT,d1
	beq.s	.grrr
	moveq	#1,d0
.grrr:
	bsr	set_break
	;continuer
	;ds d6 le # du break
	move.l	d0,d6
	rts
		;#] _emulate_break:
		;#[ _rm_break:
;a0=break struct @
_rm_break:
	movem.l	d5/a3/a5,-(sp)
	tst.l	(a0)
	bne.s	.ok
	tst.l	4(a0)
	beq.s	.end_2
.ok:
	move.l	a0,a5
	move.l	(a5),a3
	move.w	BREAK_VECTOR(a5),d5

	btst	#BREAK_IS_ROM,d5
	bne.s	.in_rom
	;trap catch ?
	btst	#BREAK_IS_SYSTEM,d5
	bne.s	.system_break
	;non en ram alors remettre l'ancien WORD
	move.w	BREAK_OLDINSTR(a5),(a3)
	bra.s	.end
.system_break:
	andi.w	#$ff,d5
	lsl.w	#2,d5
	lea	traps_caught_nb_table(a6),a1
	move.w	d5,d1
	sub.w	#$80,d1
	subq.l	#1,0(a1,d1.w)
	bne.s	.end
	move.l	(a5),d0
	bmi.s	.error
	move.w	d5,a0
	move.l	d0,(a0)
	bra.s	.end
.in_rom:
	tst.b	real_break_flag(a6)
	bne.s	.touch
	;remettre tout comme avant grace au watch
	;{ssp-4} remis:
;	move.l	old_watch_ssp_value(a6),a0
;	move.l	BREAK_OLDPC(a5),-(a0)
	bra.s	.end
.touch:
	;sinon remettre le pc
	move.l	BREAK_OLDPC(a5),pc_buf(a6)
.end:
	move.l	a5,a0
	sf	real_break_flag(a6)
	bsr	__rm_break
.error:
.end_2:
	movem.l	(sp)+,d5/a3/a5
	rts
		;#] _rm_break:
		;#[ _kill_break_nb:
_kill_break_nb:
	movem.l	d7/a5,-(sp)
	move.l	d0,d7

	tst.l	breaks_addr(a6)
	beq.s	.end
	tst.l	current_breaks_nb(a6)
	beq.s	.end
	move.l	breaks_addr(a6),a5
.l1:
	cmp.w	BREAK_NUMBER(a5),d7
	beq.s	.kill_it
	move.l	a5,a0
	bsr	_get_next_break
	bmi.s	.error
	move.l	a0,a5
	bra.s	.l1
.error:
	lea	break_bad_number_error_text,a2
	_JSR	print_error
	bra.s	.end
.kill_it:
	move.l	a5,a0
	move.w	BREAK_NUMBER(a0),d0
	lea	killed_text,a1
	moveq	#1,d1
	bsr	_print_break_set_unset
	move.l	a5,a0
	bsr	_rm_break
.end:
	movem.l	(sp)+,d7/a5
	rts
		;#] _kill_break_nb:
		;#[ _kill_all_breaks:
_kill_all_breaks:
	movem.l	a2/a5,-(sp)
	tst.l	breaks_addr(a6)
	beq.s	.end
	tst.l	current_breaks_nb(a6)
	beq.s	.create
	move.l	breaks_addr(a6),a5
.rm:
;	btst	#BREAK_IS_INTERNAL,BREAK_VECTOR(a5)
;	bne.s	.next
	move.l	a5,a0
	bsr	_rm_break
.next:
	move.l	a5,a0
	bsr	_get_next_break
	move.l	a0,a5
	bpl.s	.rm
.create:
	bsr	clear_breaks
.end:
	lea	breaks_killed_text,a2
	_JSR	print_result
	movem.l	(sp)+,a2/a5
	rts
		;#] _kill_all_breaks:
	; #] Remove break:
	; #[ Internal_breaks_access:
		;#[ _set_break_eval:
;a0=@ buffer break
;a1=@ eval
_set_break_eval:
;	exg	a0,a1
;	bsr	strlen2
;	;pour le zero de fin de chaine
;	addq.l	#1,d0
;	move.l	cur_eval_breaks_addr(a6),d1
;	add.l	d0,cur_eval_breaks_addr(a6)
;	move.l	d1,BREAK_EVAL(a1)
;	;recopier l'eval
;	move.l	d1,a1
;.l3:
;	move.b	(a0)+,(a1)+
;	bne.s	.l3
;	rts
	movem.l	a2-a3,-(sp)
	exg	a0,a1
	bsr	strlen2
	;pour les zeros de fin de chaine
	addq.l	#2,d0

	;trouver autant de 0 consecutifs que d0
	move.l	eval_breaks_addr(a6),a2
	move.l	end_eval_breaks_addr(a6),d2
.l1:
	move.l	a2,a3
	moveq	#0,d1
.l2:
	cmp.l	a2,d2
	ble.s	.full
	tst.b	(a2)+
	bne.s	.l1
	addq.w	#1,d1
	cmp.w	d1,d0
	bne.s	.l2
;.space_found:
	;pour le zero de l'expression precedente
	addq.w	#1,a3
	move.l	a3,BREAK_EVAL(a1)
	;recopier l'eval
.l3:
	move.b	(a0)+,(a3)+
	bne.s	.l3
	moveq	#0,d0
.end:
	movem.l	(sp)+,a2-a3
	rts
.full:
	moveq	#-1,d0
	bra.s	.end
		;#] _set_break_eval:
		;#[ _eval_break:
;a0=@ eval
_eval_break:
	bsr	evaluate
	tst.w	d1
	rts
		;#] _eval_break:
		;#[ _build_breakpt_address:
;Input:
;a0=@ d'ou calculer
;d0.b=exc #
;Output:
;d0=@+d0 (sur 68000)
_build_breakpt_address:
	movem.l	d1,-(sp)
	IFNE	_68030
	tst.b	chip_type(a6)
	beq.s	.68000
	move.l	a0,d0
	bra.s	.end
.68000:
	;@ a poker
	move.l	a0,d1
	andi.l	#$ffffff,d0
	lsl.w	#8,d0
	swap	d0
	or.l	d0,d1
	move.l	d1,d0
	ELSEIF
	;@ a poker
	move.l	a0,d1
	andi.l	#$ffffff,d0
	lsl.w	#8,d0
	swap	d0
	or.l	d0,d1
	move.l	d1,d0
	ENDC
.end:
	movem.l	(sp)+,d1
	rts
		;#] _build_breakpt_address:
		;#[ _emulate_indirect_break:
;d0.w=instr opcode
;a0=@
_emulate_indirect_break:
	move.w	d0,(a3)
	move.l	a0,2(a3)
	IFNE	switching_debug
	pea	rombreak_emulated_text(pc)
	bsr	print_debug
	addq.w	#4,sp
	ENDC
	move.l	a3,d5
	addq.l	#6,d5
	;old long devient l'@ du 'vrai' pc (et du 'faux' break)
	move.l	a1,BREAK_OLDPC(a5)
	move.l	a3,pc_buf(a6)
	;VEC negatif
	bset	#BREAK_IS_ROM,d6
	rts
		;#] _emulate_indirect_break:
		;#[ _emulate_dbcc:
_emulate_dbcc:
	IFNE	switching_debug
	pea	emulating_dbcc_text(pc)
	bsr	print_debug
	addq.w	#4,sp
	ENDC
	;relancer en mode trace le process
	;switcher de contexte de tracing
;	bsr	save_internal_context
	move.l	d5,trace_until_pc_value(a6)
	st	trace_until_pc_flag(a6)
	st	trace_flag(a6)
	st	nowatch_flag(a6)
	st	nostop_flag(a6)
	st	permanent_trace_flag(a6)
	sf	run_flag(a6)
	sf	runandbreak_flag(a6)
	sf	exc_emulated_flag(a6)
;	bsr	p0p1
;	IFNE	switching_debug
;	pea	dbcc_emulated_text(pc)
;	bsr	print_debug
;	addq.w	#4,sp
;	ENDC
	;restaurer
;	bsr	restore_internal_context
	rts
		;#] _emulate_dbcc:
		;#[ _check_if_break:
;-- INPUT --
;a0=@ a checker
;d0.w=-1 si tout type,sinon 0 1 2
;d1.w=-1 si tout vecteur,sinon numero de vecteur
;d2=info dependant du type

;-- In --
;d6=type
;d7=vector #
;a5=break @

;-- OUT --
;a0=@ du break
;d1=
;-1:not found
;=0?
;>0:# de break
;d0=vecteur
;a1=dont_remove_break_long=old_long
_check_if_break:
	;1 long = @ ou se trouve le break
	;1 long = ptr sur l'expression a evaluer
	;1 word pour le numero du breakpoint
	;1 word pour le vecteur
	;1 long = instruction sauvegardee

	movem.l	d5-d7/a5,-(sp)
	move.w	d0,d6
	move.w	d1,d7
	move.l	d2,d5
	bsr	_get_break
	bmi.s	.not_found
	move.l	a0,a5
	moveq	#0,d1
	move.w	BREAK_NUMBER(a5),d1
	move.l	BREAK_OLDINSTR(a5),a1
	move.l	a1,dont_remove_break_long(a6)
	moveq	#0,d0
	move.w	BREAK_VECTOR(a5),d0
	tst.w	d7
	bmi.s	.dont_check
	cmp.b	d7,d0
	bne.s	.not_found
.dont_check:
	bclr	#BREAK_IS_ROM,d0
	beq.s	.end
	;in rom
	move.l	(a1),dont_remove_break_long(a6)
	bra.s	.end
.not_found:
	sf	dont_remove_break_flag(a6)
	moveq	#-1,d0
.end:
	move.l	a5,a0
	andi.w	#$ff,d0
	tst.l	d0
	movem.l	(sp)+,d5-d7/a5
	rts
		;#] _check_if_break:
		;#[ _get_prev_break:
;-- IN --
;a0=@ d'ou scanner
;d0=type ?
;-- OUT --
;a0=new @
;d0=-1 echec,>=0 type
_get_prev_break:
	move.l	breaks_addr(a6),a1
.again:
	cmp.l	a1,a0
	ble.s	.abort

	lea	-BREAK_SIZE(a0),a0

	tst.l	(a0)
	bne.s	.found
	tst.l	4(a0)
	bne.s	.found
	tst.l	8(a0)
	bne.s	.found
	tst.l	12(a0)
	beq.s	.again
.found:
	;tri possible sur d0
	moveq	#0,d0
	bra.s	.end
.abort:
	moveq	#-1,d0
.end:
	rts
		;#] _get_prev_break:
		;#[ _get_next_break:
;-- IN --
;a0=@ d'ou scanner
;a1=2nd @
;d0=type ?
;-- OUT --
;a0=new @ 1st buffer
;a1=new @ 2nd buffer
;d0=-1 echec,>=0 type
_get_next_break:
	movem.l	a2-a3,-(sp)
	move.l	eval_breaks_addr(a6),a2
	tst.b	-(a2)
.again:
	cmp.l	a2,a0
	bgt.s	.abort
	;tri possible sur d0
	lea	BREAK_SIZE(a0),a0
	lea	BREAK_SIZE(a1),a1
	cmp.l	a2,a0
	bgt.s	.abort
	tst.l	(a0)
	bne.s	.found
	tst.l	4(a0)
	bne.s	.found
	tst.l	8(a0)
	bne.s	.found
	tst.l	12(a0)
	beq.s	.again
.found:
	move.l	a3,d1
	moveq	#0,d0
	bra.s	.end
.abort:
	moveq	#-1,d0
.end:
	movem.l	(sp)+,a2-a3
	rts
		;#] _get_next_break:
		;#[ _get_break:
;--- IN ---
;d0=type de break
;d1=vecteur du break
;d2=info dependant du type
;a0=@ de break
;--- OUT ---
;d0=
;-1:echec (not found)
;>0:# de break (sequentiel)
;a0=@ de la struct correspondant a ce break
;a1=@ du deuxieme buffer de breaks
_get_break:
	movem.l	d4-d7/a4-a5,-(sp)
	move.l	a0,d6
	IFNE	_68030
	tst.b	chip_type(a6)
	bne.s	.not_68000
	ENDC
	and.l	#$ffffff,d6
.not_68000:
	move.l	d1,d5
	move.l	d2,d4
	move.l	breaks_addr(a6),a5
	move.l	virt_breaks_addr(a6),a4
	move.l	current_breaks_nb(a6),d7
	beq.s	.not_found
.again:
	move.l	(a5),d0
	beq.s	.next
	move.w	BREAK_VECTOR(a5),d1
	btst	#BREAK_IS_SYSTEM,d1
	bne.s	.system_break
	tst.b	real_break_flag(a6)
	bne.s	.cmp
	btst	#BREAK_IS_ROM,d1
	bne.s	.rom
.cmp:
	cmp.l	d6,d0
	beq.s	.found
.dec_one:
	subq.l	#1,d7
	beq.s	.not_found
.next:
	move.l	a5,a0
	move.l	a4,a1
	bsr	_get_next_break
	bmi.s	.not_found
	move.l	a0,a5
	move.l	a1,a4
	bra.s	.again
.rom:
	move.l	BREAK_OLDPC(a5),d0
	bra.s	.cmp
.system_break:
	cmp.b	d1,d5
	bne.s	.dec_one
	move.l	BREAK_SYSFLAGS(a5),d1
	btst	#BREAK_SYSALLFUNCS,d1
	beq.s	.found
	cmp.w	d2,d1
	bne.s	.dec_one
.found:
	move.l	a5,a0
	move.l	d7,d0
	bra.s	.end
.not_found:
	moveq	#-1,d0
.end:
	sf	real_break_flag(a6)
	movem.l	(sp)+,d4-d7/a4-a5
	tst.l	d0
	rts
		;#] _get_break:
	IFNE	sourcedebug
		;#[ _get_src_break:
;In:
;a0=@ du source
;Out:
;d0=# de break
;a0=@ break struct
;a1=@ source break struct
_get_src_break:
	movem.l	d7/a3-a5,-(sp)
	move.l	a0,a4
	move.l	breaks_addr(a6),a5
	move.l	current_breaks_nb(a6),d7
	beq.s	.not_found
.l1:	tst.l	(a5)
	beq.s	.next
	move.w	BREAK_VECTOR(a5),d1
	btst	#BREAK_IN_SOURCE,d1
	beq.s	.dec_one
	move.l	a5,a1
	sub.l	breaks_addr(a6),a1
	add.l	source_breaks_addr(a6),a1
	cmp.l	(a1),a4
	bne.s	.dec_one
	move.l	BREAK_SRC_MDL(a1),a0
	_JSR	get_mod_name
	cmp.l	source_name_addr(a6),a0
	beq.s	.found
.dec_one:	subq.l	#1,d7
	beq.s	.not_found
.next:	move.l	a5,a0
	bsr	_get_next_break
	bmi.s	.not_found
	move.l	a0,a5
	bra.s	.l1
.found:	move.l	d7,d0
	move.l	a5,a0
	bra.s	.end
.not_found:
	moveq	#-1,d0
.end:	movem.l	(sp)+,a3-a5/d7
	rts
		;#] _get_src_break:
	ENDC	;de sourcedebug
		;#[ _get_free_break:
;--- IN ---
;rien
;--- OUT ---
;d0=
;-1:echec (full)
;>0:break #
;a0=@ de la struct correspondant a ce break
;a1=@ du deuxieme buffer de breaks
;a2=@ du buffer de break source
_get_free_break:
	movem.l	d6-d7/a3-a5,-(sp)
	move.l	a0,d6
	move.l	breaks_addr(a6),a5
	move.l	virt_breaks_addr(a6),a4
	move.l	breaks_max(a6),d7
	cmp.l	current_breaks_nb(a6),d7
	ble.s	.not_found
	IFNE	sourcedebug
	move.l	source_breaks_addr(a6),a3
	ENDC	;de sourcedebug
.l2:
	subq.l	#1,d7
	bmi.s	.not_found
	tst.l	(a5)
	bne.s	.again
	tst.l	4(a5)
	bne.s	.again
	tst.l	8(a5)
	bne.s	.again
	tst.l	12(a5)
	beq.s	.found
.again:
	lea	BREAK_SIZE(a5),a5
	lea	BREAK_SIZE(a4),a4
	IFNE	sourcedebug
	lea	BREAK_SIZE(a3),a3
	ENDC	;de sourcedebug
	bra.s	.l2
.found:
	move.l	a5,a0
	move.l	a4,a1
	move.l	a3,a2
	move.l	breaks_max(a6),d0
	sub.l	d7,d0
	bra.s	.end
.not_found:
	moveq	#-1,d0
.end:
	movem.l	(sp)+,d6-d7/a3-a5
	tst.l	d0
	rts
		;#] _get_free_break:
		;#[ _just_rm_break:
;--- INPUT ---
;a0=@ a checker
;d0=-1 ou type a checker
;--- OUTPUT ---
;d0=
;0=break not found
;>0=break #
;if found:
;d1=vector #
_just_rm_break:
	movem.l	d5-d7/a2-a5,-(sp)
	move.l	d0,d5
	bsr	_get_break
	tst.l	d0
	bmi.s	.notbreak
	;sauver:
	;# de vecteur
	moveq	#0,d6
	move.w	BREAK_NUMBER(a0),d6
	;type
	moveq	#0,d5
	move.w	BREAK_VECTOR(a0),d5

	;remover
	;break deja ds a0
	bsr	_rm_break

	;terminer
	move.l	d6,d0
	move.w	d5,d1
	bra.s	.end
.notbreak:
	moveq	#-1,d0
.end:
	movem.l	(sp)+,d5-d7/a2-a5
	rts
		;#] _just_rm_break:
		;#[ __rm_break:
;a0=@ du buffer de break
__rm_break:
	movem.l	a0-a1,-(sp)
	move.l	a0,a1
	;un break de moins
	subq.l	#1,current_breaks_nb(a6)
	clr.l	(a1)+
	move.l	(a1),a0
	bsr	strclr2
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)
	;tri des breaks
;	lea	comp_breaks(pc),a0
;	lea	inv_breaks(pc),a1
;	move.l	current_breaks_nb(a6),d0
;	addq.l	#1,d0
;	bsr	tri2
	movem.l	(sp)+,a0-a1
	rts
		;#] __rm_break:
		;#[ _print_break_set_unset:
;Input:
;d0=break #
;d1=0->break set/1->break removed
;a0=break struct @
;a1=@ du message a mettre en plus
;IN:
;d5=function # (if trap catch)
;d6=vector #
;d7=break #
;a5=break @
;a4=@ du message a mettre en plus
_print_break_set_unset:
	movem.l	d7/a2-a5,-(sp)
	move.l	d0,d7
	tst.w	d1
	bne.s	.killed 
	move.w	BREAK_VECTOR(a0),d1
	btst	#BREAK_IS_SYSTEM,d1
	bne.s	.system
.killed:
.general:
	move.l	a1,-(sp)
	move.l	d7,-(sp)
	pea	print_break_set_unset_format
	lea	line_buffer(a6),a2
	move.l	a2,a0
	bsr	sprintf2
	lea	12(sp),sp
.print:
	bsr	print_result
	movem.l	(sp)+,d7/a2-a5
	rts
.system:
;	move.l	a0,a0
	lea	tmp_buffer(a6),a1
	move.l	a1,-(sp)
	_JSR	get_system_break_name
	move.l	(sp)+,a1
	bra.s	.general
		;#] _print_break_set_unset:
		;#[ _print_break_error:
;Input:
;d0=type d'erreur
;0=general error
;-1=no more break
;-2=bad address
;-3=bad vector
;-4=bad eval
;-5=no more eval room
_print_break_error:
	move.l	a2,-(sp)
	lea	break_general_error_text,a2
	tst.w	d0
	beq.s	.print
	lea	break_full_error_text,a2
	addq.w	#1,d0
	beq.s	.print
	lea	break_address_error_text,a2
	addq.w	#1,d0
	beq.s	.print
	lea	break_vector_error_text,a2
	addq.w	#1,d0
	beq.s	.print
	lea	break_bad_eval_error_text,a2
	addq.w	#1,d0
	beq.s	.print
	lea	break_eval_full_error_text,a2
.print:
	bsr	print_error
	move.l	(sp)+,a2
	rts
		;#] _print_break_error:
		;#[ _save_internal_context:
_save_internal_context:
	lea	internal_context_buffer(a6),a0
	lea	save_internal_context_buffer(a6),a1
	moveq	#INTERNAL_CONTEXT_SIZE/4-1,d0
.l1:
	move.l	(a0)+,(a1)+
	dbf	d0,.l1
	rts
		;#] _save_internal_context:
		;#[ _restore_internal_context:
_restore_internal_context:
	lea	save_internal_context_buffer(a6),a0
	lea	internal_context_buffer(a6),a1
	moveq	#INTERNAL_CONTEXT_SIZE/4-1,d0
.l1:
	move.l	(a0)+,(a1)+
	dbf	d0,.l1
	rts
		;#] _restore_internal_context:
	; #] Internal_breaks_access:
	; #[ Exceptions stuff:
		;#[ Put exceptions:
put_exceptions:
	IFNE	ATARIST
	moveq	#-1,d0
	tst.b	catch_div0_flag(a6)
	bne.s	.nodiv0
	move.w	d0,exceptions_caught_buffer+5*4+2(a6)
.nodiv0:	tst.b	catch_priv_flag(a6)
	bne.s	.nopriv
	move.w	d0,exceptions_caught_buffer+8*4+2(a6)
.nopriv:	tst.b	catch_linef_flag(a6)
	bne.s	.nolinef
	move.w	d0,exceptions_caught_buffer+11*4+2(a6)
.nolinef:
	IFNE	_68030
	tst.b	chip_type(a6)	;catch linef on 68xxx
	beq.s	.68000
	move.w	#$2c,exceptions_caught_buffer+11*4+2(a6)
.68000:
	ENDC	;_68030
	ENDC	;ATARIST
	IFNE	A3000
	jsr	super_on
	move.l	d0,-(sp)
	ENDC
	moveq	#63,d0
.l1:	move.w	d0,-(sp)
	bsr.s	put_exception
	move.w	(sp)+,d0
	dbf	d0,.l1
	IFNE	A3000
	move.l	(sp)+,d0
	beq.s	.already_super
	move.l	d0,a0
	jsr	super_off
.already_super:
	ENDC	;A3000
	rts
		;#] Put exceptions:
		;#[ Put exception:
;-- In --
;d0=# d'exception
;-- Out --
;d0=reussite
put_exception:
	movem.l	a2-a3,-(sp)
	lea	breakpt(pc),a1	;@ de la routine de traitement des exceptions
	lea	exceptions_caught_buffer(a6),a2
	move.w	d0,d2
	move.w	d0,d1		;taille struct avec ds d1 le vector #
	bmi.s	.end
	andi.w	#$ff,d1
	lsl.w	#2,d1
	moveq	#0,d0		;@ du vecteur en word
	move.w	2(a2,d1.w),d0
	cmp.w	#-1,d0		;si -1, pas detourner
	beq.s	.abort
	andi.w	#$ff,d0
	move.w	d0,a0		;etendue
	move.l	a1,d1		;@ a poker
	IFNE	_68030		;changer ca:
	tst.b	chip_type(a6)
	beq.s	.68000
	_20
	movec	vbr,d0		;dc.l	$4e7a0801
	_00
	add.l	d0,a0
	bra.s	.poke
.68000:
	ENDC
	moveq	#0,d0
	move.b	d2,d0
	swap	d0
	lsl.l	#8,d0
	or.l	d0,d1
.poke:	move.l	d1,(a0)		;pokee dans le vecteur lui correspondant
	moveq	#0,d0
	bra.s	.end
.abort:	moveq	#-1,d0
.end:	movem.l	(sp)+,a2-a3
	rts
		;#] Put exception:
		;#[ Save exceptions:
save_exceptions:
	move.l	d7,-(sp)
	IFNE	A3000
	jsr	super_on
	move.l	d0,-(sp)
	ENDC
	moveq	#2,d7
.l1:	move.w	d7,d0
	bsr.s	save_exception
	addq.w	#1,d7
	cmp.w	#88,d7
	blt.s	.l1
	IFNE	A3000
	move.l	(sp)+,d0
	beq.s	.fin
	move.l	d0,a0
	jsr	super_off
.fin:
	ENDC	; de A3000
	move.l	(sp)+,d7
	rts
		;#] Save exceptions:
		;#[ Save exception:
;d0=# de vecteur
save_exception:
	lea	exceptions_save_buffer(a6),a0
	asl.w	#2,d0
	move.w	d0,a1
	IFNE	_68030
	tst.b	chip_type(a6)
	beq.s	.68000
	dc.l	$4e7a1801		;movec	vbr,d1
	add.l	d1,a1
.68000:
	ENDC
	move.l	(a1),(a0,d0.w)
	rts
		;#] Save exception:
		;#[ Reput exceptions:
reput_exceptions:
	move.l	d7,-(sp)
	moveq	#2,d7
	IFNE	A3000
	jsr	super_on
	move.l	d0,-(sp)
	ENDC
.l1:	move.w	d7,d0
	bsr.s	reput_exception
	addq.w	#1,d7
	cmp.w	#88,d7
	blt.s	.l1
	IFNE	A3000
	move.l	(sp)+,d0
	beq.s	.already_super
	move.l	d0,a0
	jsr	super_off
.already_super:
	ENDC	;de A3000
	move.l	(sp)+,d7
	rts
		;#] Reput exceptions:
		;#[ Reput exception:
;d0=# de vecteur
reput_exception:
	lea	exceptions_save_buffer(a6),a0
	asl.w	#2,d0
	move.w	d0,a1
	IFNE	_68030
	tst.b	chip_type(a6)
	beq.s	.68000
	dc.l	$4e7a1801		;movec	vbr,d1
	add.l	d1,a1
.68000:
	ENDC
	move.l	(a0,d0.w),(a1)
	rts
		;#] Reput exception:
	; #] Exceptions stuff:
;  #] Breaks stuff:
;  #[ Context switching:
	; #[ Put_internal_sr:
;ds d0 le nouveau niveau d'ipl interne
;ne switcher les timers qu'en cas de transition
put_internal_sr:
	IFNE	amiga_avbl
	tst.b	always_vbl_flag(a6)
	beq.s	.avbl_ok
	cmp.w	#3,d0
	blt.s	.avbl_ok
	moveq	#0,d0
	rts
.avbl_ok:
	ENDC	;amig_avbl
	movem.l	d6-d7,-(a7)
	IFNE	AMIGA
	move.w	d0,-(sp)
	_JSR	super_on
	move.l	d0,tmp_a7_buf(a6)
	move.w	(sp)+,d0
	ENDC	;d'AMIGA
	move.w	d0,d7
	bmi	.error
	cmp.w	#7,d7
	bgt	.error
	move.w	d0,d6
	tst.w	d1
	bpl.s	.not_current_sr
	move	sr,d1
.not_current_sr:
	and.w	#%0000011100000000,d1
	lsr.w	#8,d1

;old sr > new sr --> down transition
	cmp.w	d0,d1
	bgt.s	.down_transition

;old sr < new sr --> up transition
	cmp.w	d0,d1
	blt.s	.up_transition
;old sr is new sr --> check ipl 6 and set flag
	cmp.b	#MAX_KBD_IPL,d7
	blt.s	.low_ipl
;.up_ipl:
	;pas switcher clavier
	;pas switcher timers
	st	acia_ikbd(a6)
	bra.s	.set_new_sr
.low_ipl:
	;sauver clavier user et remettre initial
;	bsr	install_kbd
	;on s'en fout des timers
	IFNE	amiga_avbl
	tst.b	always_vbl_flag(a6)
	bne.s	.avf_on
	ENDC
	sf	acia_ikbd(a6)
.avf_on:	bra.s	.set_new_sr
.up_transition:	;0..5->6..7
;up transition is significant only if old ipl is < 6
	cmp.w	#MAX_KBD_IPL,d1
	bge.s	.set_new_sr
;up transition is significant only if new ipl is > 5
	cmp.w	#MAX_KBD_IPL,d0
	blt.s	.set_new_sr
	;reinstaller le clavier user, apres ne plus le switcher
	bsr	kbd1_set
	; voila je suis en ipl > 5
	st	acia_ikbd(a6)
	bra.s	.set_new_sr
.down_transition:	;6..7->0..5
;down transition is significant only if old ipl is > 5
	cmp.w	#MAX_KBD_IPL,d1
	blt.s	.set_new_sr
;down transition is significant only if new ipl is < 6
	IFNE	AMIGA
	move.w	internal_intena(a6),d1
	btst	#14,d1
	beq.s	.set_new_sr
	btst	#3,d1
	beq.s	.set_new_sr
	IFNE	amiga_avbl
	tst.b	always_vbl_flag(a6)
	bne.s	.set_new_sr
	ENDC	;amiga_avbl
	ENDC	;AMIGA
	cmp.w	#MAX_KBD_IPL,d0
	bge.s	.set_new_sr
	; sauver le kbd user et remettre celui du depart
	bsr	kbd1_save
	bsr	kbd0_set
	; sauver les timers users courants et remettre ceux du depart
	IFNE	ATARIST
	cmp.w	#$0300,osnumber(a6)
	bgt.s	.noclr
	move.l	external_repeat_addr(a6),a0
	clr.b	(a0)+
	clr.b	(a0)+
	clr.b	(a0)
.noclr:	bsr	timer0_timer1
	ENDC	;d'ATARIST
	; voila je suis en ipl < 6
	sf	acia_ikbd(a6)
.set_new_sr:
	IFNE	AMIGA
	move.w	d7,current_ipl(a6)
	tst.b	copper_active(a6)
	bne.s	.end_vbl_ctrl
	cmp.w	#3,d7
	blt.s	.end_vbl_ctrl
; repasser en affichage par copper
	movem.l	d0/d1/a0/a2,-(sp)
	st	copper_active(a6)
	bset	#7,internal_dmacon+1(a6)
	lea	custom,a0
	move.l	internal_copperlist(a6),cop1lc(a0)
	clr.w	copjmp1(a0)
	bsr	rethink_display
	lea	warning_vbl_message,a2
	bsr	print_press_key
	movem.l	(sp)+,d0/d1/a0/a2
.end_vbl_ctrl:
	move.w	d7,current_ipl(a6)
	ENDC	;AMIGA
	move	sr,d1
	andi.w	#%1111100011111111,d1
	lsl.w	#8,d7
	or.w	d7,d1
	move	d1,sr
	moveq	#0,d0
	bra.s	.end
.error:	moveq	#-1,d0
.end:
	IFNE	AMIGA
	move.l	d0,d7
	move.l	tmp_a7_buf(a6),d0
	beq.s	.keep_super
	move.l	d0,a0
	_JSR	super_off
.keep_super:
	move.l	d7,d0
	ENDC	;d'AMIGA
	movem.l	(a7)+,d6-d7
	rts
	; #] Put_internal_sr:
	; #[ Get_instr_type:
;-- Input --
;a0=@ de l'instruction a checker
;-- Out --
;d0=type de l'instr:
;0=normal (rien de special)
;1=trap
;2=linea
;3=linef
;4=bsr
;5=jsr
;6=bcc
;7=dbcc
;8=jmp
;9=trapv
;10=chk
;11=rts
;12=rte
;13=rtr
;a0=@ de branchement si bsr,jsr,bcc,dbcc,jmp
;d1= (si bsr jsr bcc dbcc jmp)
 ;-1:branchement pas fait
 ;0:branchement fait
get_instr_type:
	movem.l	a5,-(sp)
	move.l	device_number(a6),-(sp)
	clr.l	device_number(a6)
	move.l	a0,a1
	lea	line_buffer(a6),a0
	move.l	a1,test_instruction(a6)
	_JSR	disassemble_line
	lea	instruction_descriptor(a6),a5
	tst.w	d0
	bmi.s	.default
	move.w	_I_ID_instruction(a5),d0

	cmp.w	#ID_trap,d0
	beq.s	.trap
	cmp.w	#ID_dc_w,d0
	beq.s	.dc_w
	cmp.w	#ID_bsr,d0
	beq.s	.bsr
	cmp.w	#ID_jsr,d0
	beq.s	.jsr
	cmp.w	#ID_bcc,d0
	beq.s	.bcc
	cmp.w	#ID_bra,d0
	beq.s	.bcc
	cmp.w	#ID_dbcc,d0
	beq.s	.dbcc
	cmp.w	#ID_jmp,d0
	beq.s	.jmp
	cmp.w	#ID_trapv,d0
	beq.s	.trapv
	cmp.w	#ID_chk,d0
	beq.s	.chk
	cmp.w	#ID_rts,d0
	beq.s	.rts
	cmp.w	#ID_rte,d0
	beq.s	.rte
	cmp.w	#ID_rtr,d0
	beq.s	.rtr
.default:	moveq	#0,d0
	bra.s	.end
.trap:	moveq	#1,d0
	bra.s	.end
.dc_w:	move.b	(a1),d0
	andi.w	#$f0,d0
	cmp.w	#$f0,d0
	beq.s	.linef
	cmp.w	#$a0,d0
	bne.s	.default
.linea:	moveq	#2,d0
	bra.s	.end
.linef:	moveq	#3,d0
	bra.s	.end
.bsr:	moveq	#4,d0
	bra.s	.get_addr
.jsr:	moveq	#5,d0
	bra.s	.get_addr
.bcc:	moveq	#6,d0
	bra.s	.get_addr
.dbcc:	moveq	#7,d0
	bra.s	.get_addr
.jmp:	moveq	#8,d0
	bra.s	.get_addr
.trapv:	moveq	#9,d0
	bra.s	.end
.chk:	moveq	#10,d0
	bra.s	.end
.rts:	moveq	#11,d0
	bra.s	.end
.rte:	moveq	#12,d0
	bra.s	.end
.rtr:	moveq	#13,d0
;	bra.s	.end
.end:	moveq	#0,d2
	move.w	_I_size(a5),d2
	move.l	(sp)+,device_number(a6)
	movem.l	(sp)+,a5
	tst.l	d0
	rts
.get_addr:
	move.l	_I_branchaddr(a5),a0
	tst.w	_I_branchyn(a5)
	seq	d1
	ext.w	d1
	bra.s	.end

	; #] Get_instr_type:
	; #[ Breakpt:
;internal:
;a6 is fixed
;d7=p1 ssp
;d0/a0-a1=temporary
	SET_ID	EXCEPTION_MAGIC
breakpt:
	IFEQ	switching_debug
;	move	#$2700,sr
	ori	#$700,sr
	ENDC
	SWITCHA6
	movem.l	d0-a5,tmp_context_buffer(a6)
	move.l	sp,d7
	IFNE	_68030
	IFNE	_68000
	tst.b	chip_type(a6)
	beq	.68000
	ENDC	; de _68000
	move.w	6(sp),d0
;	move.w	d0,sf_vector_offset(a6)
	moveq	#0,d1
	move.w	d0,d1
	moveq	#12,d2
	lsr.w	d2,d1
	move.w	d1,sf_type(a6)
	andi.w	#$fff,d0
	asr.w	#2,d0
	move.b	d0,exception(a6)
	lea	stacks_sizes,a0
	add.w	d1,d1
	move.w	0(a0,d1.w),d0
;	move.w	0(a0,d1.w*2),d0
	beq.s	.analyse		;.68000
	subq.w	#1,d0
	move.l	sp,a0
	lea	external_stack_frame(a6),a1
.l0:	move.w	(a0)+,(a1)+
	dbf	d0,.l0
	bra.s	.analyse
	IFEQ	atarifrance
.68000:	lea	.gux(pc),a0
	move.l	a0,d0
	andi.l	#$ffffff,d0
	move.l	d0,a1
	jmp	(a1)
.gux:	move.l	a0,d0
	swap	d0
	lsr.w	#8,d0
;	andi.w	#63,d0
	move.b	d0,exception(a6)
	ENDC	; d'atarifrance
	ELSEIF
	lea	.gux(pc),a0
	move.l	a0,d0
	andi.l	#$ffffff,d0
	move.l	d0,a1
	jmp	(a1)
.gux:	move.l	a0,d0
	swap	d0
	lsr.w	#8,d0
;	andi.w	#63,d0
	move.b	d0,exception(a6)
	ENDC
.analyse:
	moveq	#0,d0
	move.b	exception(a6),d0
	IFNE	AMIGA
;cas special de la violation de privilege
	cmp.b	#8,d0
	bne.s	.catch_it
	move.l	2(sp),a0
	cmp.l	exec_supervisor(a6),a0
	beq.s	.supervisor
	cmp.l	#$f80000,a0
	blt.s	.catch_it
.supervisor:
	move.l	exceptions_save_buffer+8*4(a6),a1
.back:	move.w	(sp),d0
	IFNE	_68020!_68030
	tst.b	chip_type(a6)
	beq.s	._68000
	clr.w	-(sp)
._68000:
	ENDC
	move.l	a1,-(sp)	; @ retour
	move.w	4(sp),d0
	or.w	#$2000,d0
	and.w	#$7fff,d0
	move.w	d0,-(sp)	; SR
	movem.l	tmp_context_buffer(a6),d0-a5
	RESTOREA6
	rte	;retour en ROM
.catch_it:
;test du handler d'exceptions
	tst.b	exceptions_to_handler(a6)
	beq.s	.catch_it_always
	cmp.b	#2,exception(a6)
	blt.s	.catch_it_always
	btst	#5,(sp)		;super ?
	bne.s	.catch_it_always
;saut au trap handler de p1
	move.l	4.w,a0
	move.l	ThisTask(a0),a0
	move.l	tc_TrapCode(a0),a0
	cmp.l	initial_trapcode(a6),a0
	beq.s	.catch_it_always
	add.w	d0,d0
	add.w	d0,d0
	lea	exceptions_save_buffer(a6),a1
	move.l	0(a1,d0.w),a1
	bra.s	.back	; go to trap-handler
.catch_it_always:
	bsr	stop_task
	tst.b	d0
	bne.s	.no_amiga_stop
	tst.b	amiga_stop_flag(a6)
	beq.s	.no_amiga_stop
	sf	amiga_stop_flag(a6)
	clr.b	stat_spec_keys(a6)
	bra	.nothing
.no_amiga_stop:
	ENDC	;d'AMIGA
	cmp.b	#-2,d0	;uninitialized context
	beq	.nothing
	cmp.b	#-1,d0	;reset
	beq	.nothing
	tst.b	d0	;halted
	beq	.nothing
	cmp.w	#2,d0	;berr
	beq	.super
	cmp.w	#3,d0	;aderr
	beq	.super
	cmp.w	#9,d0	;trace
	beq.s	.trace

	cmp.w	#25,d0	;ipl's
	blt	.nothing
	cmp.w	#47,d0	;traps
	bgt	.nothing
	subq.l	#2,2(sp)	;revenir sur l'instruction
	bra	.nothing
.trace:	tst.b	justonce_flag(a6)
	bne	.nothing
	IFNE	sourcedebug
	tst.b	trace_source_flag(a6)
	beq.s	.not_in_source_trace
	tst.b	halted_flag(a6)
	bne	.more_nothing
	move.l	2(sp),a0
	cmp.l	source_block_addr(a6),a0
	blt.s	.not_in_block_trace
	cmp.l	end_source_block_addr(a6),a0
	bge.s	.not_in_block_trace
	move.w	(a0),d0		;verifier trap/bsr/jsr
	andi.w	#$fff0,d0
	cmp.w	#$4e40,d0		;trap
	beq	.more_nothing
	andi.w	#$ffc0,d0
	cmp.w	#$4e80,d0		;jsr
	beq	.more_nothing
	andi.w	#$ff00,d0
	cmp.w	#$6100,d0		;bsr
	beq	.more_nothing
	bra	.return_with_stack
.not_in_block_trace:
	st	not_in_block_flag(a6)
	bra	.more_nothing
.not_in_source_trace:
	ENDC	;de sourcedebug
	tst.b	nowatch_flag(a6)
	beq	.nothing
	move.l	internal_ssp(a6),sp
	IFNE	ATARIST
	_JSR	flashing_cursor
	ENDC
	tst.b	trace_slow_flag(a6)
	beq	.nothing
	IFNE	switching_debug
	pea	fasttrace_text
	bsr	print_debug
	addq.w	#4,sp
	ENDC
	bsr	test_shift_shift
	beq.s	.dont_stop_now
	sf	nostop_flag(a6)
	bra.s	.nothing
.dont_stop_now:
	;slow mode fast!
	;test linea - f trap chk trapv
	move.l	d7,a0
	move.l	2(a0),a0
	bsr	get_instr_type
	beq.s	.return	;normal
	subq.w	#4,d0
	bmi.s	.nothing
	subq.w	#6,d0
	bmi.s	.return
	subq.w	#3,d0
	bmi.s	.nothing
;	subq.w	#3,d0
;	bmi.s	.return
.return:	move.l	d7,sp
.return_with_stack:
	movem.l	tmp_context_buffer(a6),d0-a5
	RESTOREA6
;	ori.w	#$8000,(sp)
	bset	#7,(sp)
	IFNE	_68030
	bclr	#6,(sp)
	ENDC	; de _68030
	rte
.super:
	IFNE	_68030
	tst.b	chip_type(a6)
	bne.s	.nothing
	ENDC	; de _68030
	move.l	d7,a4
	move.w	(a4)+,sf_super_word(a6)
	move.l	(a4)+,sf_cycle_addr(a6)
	move.w	(a4)+,d5
	move.w	d5,sf_ir(a6)
	;rechercher l'instruction (opcode)
	move.l	2(a4),a3
	;8 words max
	moveq	#8-1,d6
.l1:
	move.l	a3,a0
	subq.w	#2,a0
	bsr	read_baderr
	bmi.s	.found
	cmp.w	-(a3),d5
	beq.s	.found
	dbf	d6,.l1
.found:
	move.l	a3,2(a4)
	move.l	a4,d7
;	bra.s	.nothing
.nothing:
	IFNE	sourcedebug
	tst.b	trace_source_flag(a6)
	beq.s	.not_in_source
	move.l	2(sp),a0
	cmp.l	source_block_addr(a6),a0
	blt.s	.not_in_block
	cmp.l	end_source_block_addr(a6),a0
	blt.s	.more_nothing
.not_in_block:
	st	not_in_block_flag(a6)
.not_in_source:
	ENDC	;de sourcedebug
.more_nothing:
	move.l	d7,sp
	movem.l	tmp_context_buffer(a6),d0-a5
	bra	p1p0

	; #] Breakpt:
	; #[ Write_baderr:
;a0=@ a tester
;d0=bne->pas bon
write_baderr:
	IFNE	ATARIST
	move.l	a5,-(sp)
	move	sr,-(sp)
	ori	#$700,sr
	move.l	a0,a5
	_JSR	get_vbr
	move.l	8(a0),tmp_save_8(a6)
	move.l	$c(a0),tmp_save_c(a6)
	lea	_test_baderr(pc),a1
	move.l	a1,8(a0)
	move.l	a1,$c(a0)

	moveq	#0,d0

	;lisible ?
	tst.l	(a5)
	tst.l	d0
	bne.s	.end

	;ecrivible ?
	move.l	(a5),d1
	;tres important (paske ca marche)
	st	(a5)
	tst.l	d0
	bne.s	.end
	move.l	d1,(a5)
.end:
	move.l	tmp_save_8(a6),8(a0)
	move.l	tmp_save_c(a6),$c(a0)
	move	(sp)+,sr
	move.l	(sp)+,a5
	tst.l	d0
	rts
	ENDC
	IFNE	AMIGA
	jmp	amiga_write_baderr
	ENDC
_test_baderr:
	moveq	#-1,d0
	IFNE	_68030
	tst.b	chip_type(a6)
	beq.s	.68000
	bclr	#0,$a(sp)
	rte
.68000:
	ENDC
	addq.w	#8,sp
	rte
;Input:d0=new berr address
;Output:d0=old berr address
set_berr:
	move.l	a0,-(sp)
	_JSR	get_vbr
	move.l	8(a0),d1
	move.l	d0,8(a0)
	move.l	d1,d0
	move.l	(sp)+,a0
	rts
	; #] Write_baderr:
	; #[ Read_baderr:
;a0=@ a tester
;d0=bne->pas bon
read_baderr:
	IFNE	ATARIST
	move.l	a5,-(sp)
	move.l	a0,a5
	_JSR	get_vbr
	move.l	8(a0),tmp_save_8(a6)
	move.l	$c(a0),tmp_save_c(a6)
	lea	_test_baderr(pc),a1
	move.l	a1,8(a0)
	move.l	a1,$c(a0)
	moveq	#0,d0

	;lisible ?
	tst.l	(a5)
	move.l	tmp_save_8(a6),8(a0)
	move.l	tmp_save_c(a6),$c(a0)
	move.l	(sp)+,a5
	tst.l	d0
	rts
	ENDC
	IFNE	AMIGA
	jsr	test_if_readable
	tst.l	readable_buffer(a6)
	rts
	ENDC
	; #] Read_baderr:
	; #[ p0p1_checks:
p0p1_checks:
	;est-ce que la pile est ecrivible et paire ?
	move.l	ssp_buf(a6),d0
	btst	#0,d0
	bne.s	.bad_stack_error
	move.l	d0,a2
	subq.l	#2,a2
	move.l	a2,a0
	bsr	write_baderr
	bne.s	.bad_stack_error
	;chez moi ?
	lea	A_Debug,a1
	cmp.l	a1,a2
	blt.s	.no_bleme
	lea	end_of_data,a1
	cmp.l	a1,a2
	ble.s	.bad_stack_error

	;dans mon bss ?
;	move.l	a6,a1
;	cmp.l	a1,a2
;	blt.s	.no_bleme
;	adda.l	#end_of_offset_base,a1
;	lea	internal_trap2_buffer(a6),a0
;	cmp.l	a0,a2
;	beq.s	.no_bleme
;	cmp.l	a1,a2
;	ble.s	.bad_stack_error
.no_bleme:
	;est-ce que le pc est lisible et paire ?
	move.l	pc_buf(a6),d0
	btst	#0,d0
	bne.s	.bad_pc_error
	move.l	d0,a0
	bsr.s	read_baderr
	bne.s	.bad_pc_error
	moveq	#0,d0
	rts
.bad_stack_error:
	lea	bad_stack_error_text,a2
	bra.s	.print
.bad_pc_error:
	lea	bad_pc_error_text,a2
.print:
	bsr	print_error
	moveq	#-1,d0
	rts
	; #] p0p1_checks:
	; #[ p0p1:
;pas de parametres formels
p0p1:
	IFNE	AMIGA
	bsr	test_task
	bpl.s	.task_ok
	rts
.task_ok:
	ENDC	;d'AMIGA
	movem.l	d3-d7/a2-a5,-(sp)

	;test polled keyboard
	tst.b acia_ikbd(a6)
	beq.s .1
	bsr internal_inkey
.1:
	bsr.s	p0p1_checks
	bmi	.error_found

	;est-ce k'il y a un break devant a emuler ?
	bsr	test_on_break
	bmi	.error_found
	beq	.done
	tst.b	run_flag(a6)
	bne	.no_check
	;dois-je emuler un ctl_a ?
	tst.b	exc_emulated_flag(a6)
	bne	.no_check

	IFNE	sourcedebug
	bsr	p0p1_source_trace
	beq	.no_check
	bmi	.error_found
	ENDC	;de sourcedebug

	tst.b	runandbreak_flag(a6)
	bne	.no_check

	;trace: emuler trap lineaf trapv chk
	move.l	pc_buf(a6),a0
	bsr	get_instr_type
	beq	.no_check
	;trap
	subq.w	#2,d0
	bmi	.emulate_exc
	;linea
	subq.w	#1,d0
	bmi.s	.emulate_linea
	;linef
	subq.w	#1,d0
	bmi.s	.emulate_linef
	;bsr jsr bcc dbcc jmp
	subq.w	#5,d0
	bmi	.no_check
	;chk trapv
	subq.w	#2,d0
	bmi.s	.emulate_exc
	;rts rte rtr
	bra	.no_check
.emulate_linea:
	move.l	$28.w,d0
	IFNE	ATARIST
	bra.s	.emulate_line
	ENDC
.emulate_linef:
	IFNE	ATARIST
	move.l	$2c.w,d0
	tst.b	chip_type(a6)
	bne	.emulate_line
	move.l	pc_buf(a6),a0
	move.w	(a0),d1
	btst	#0,d1
	bne.s	.do_emulate_line
	cmp.w	internal_trap2_return_opcode(a6),d1
	bne.s	.not_trap2_return
	move	sr,d2
	ori	#$700,sr
	move.l	ssp_buf(a6),a0
	move.l	(a0),d1
	lea	internal_trap2_buffer(a6),a1
	move.l	a1,(a0)
	move.l	d1,a0
	moveq	#74/2-1,d1
.l1:
	move.w	(a0)+,(a1)+
	dbf	d1,.l1
	move	d2,sr
	bra.s	.do_emulate_line
.not_trap2_return:
	ENDC	;d'ATARIST
.emulate_line:
	tst.b	follow_traps_flag(a6)
	beq.s	.do_emulate_exc
.do_emulate_line:
	lea	ssp_buf(a6),a1
	move.l	(a1),a0
	IFNE	_68030
	tst.b	chip_type(a6)
	beq.s	.68000_0
	clr.w	-(a0)
.68000_0:
	ENDC	; de _68030
	move.l	pc_buf(a6),-(a0)
	bset	#5,sr_buf(a6)
	move.w	sr_buf(a6),-(a0)
	move.l	a0,(a1)
	move.l	d0,pc_buf(a6)
	bra.s	.no_check
.emulate_exc:
	tst.b	follow_traps_flag(a6)
	bne.s	.no_check
.do_emulate_exc:
	st	exc_emulated_flag(a6)
	_JSR	_ctrl_a
	bmi	.error_found
	IFNE	switching_debug
	pea	emulating_trap_lineaf_text(pc)
	bsr	print_debug
	addq.w	#4,sp
	ENDC
.no_check:
	bsr	save_registers_for_star
	bsr	backup_story
	move.w	sr_buf(a6),d3
	bclr	#15,d3
	bclr	#14,d3

	;ca y en a concerner que le mode trace
	tst.b	trace_flag(a6)
	beq.s	.no_trace

	;mais pas en emul
	tst.b	runandbreak_flag(a6)
	bne.s	.no_trace

	;ni en ctrl_z:
	tst.b	ctlz_flag(a6)
	bne.s	.no_screen

	;si watch_no mettre l'ecran logique
	tst.b	nowatch_flag(a6)
	beq.s	.no_screen
	bsr	sbase0_sbase1
.no_screen:
	tst.b	reinstall_trace_flag(a6)
	beq.s	.dont_reinstall_trace
	_JSR	get_vbr
	move.l	a0,a3
	move.l	$24(a3),save2_exc9(a6)
	lea	breakpt(pc),a0
	moveq	#9,d0
	bsr	_build_breakpt_address
	move.l	d0,$24(a3)
.dont_reinstall_trace:
	IFNE	_68030
	tst.b	chip_type(a6)
	beq.s	.not_t1
	tst.b	trace_t1_flag(a6)
	beq.s	.not_t1
	bset	#14,d3
	bra.s	.restore_all
.not_t1:
	ENDC
	bset	#15,d3
	bra.s	.restore_all
.no_trace:
	;tester log_runandbreak_flag log_trapaf_flag
	tst.b	runandbreak_flag(a6)
	beq.s	.run
	tst.b	exc_emulated_flag(a6)
	bne.s	.emulated
	tst.b	log_runandbreak_flag(a6)
	bne.s	.reput_log
	bra.s	.restore_all
.emulated:
	tst.b	log_trapaf_flag(a6)
	bne.s	.reput_log
	bra.s	.restore_all
.pmmu_error:
	bsr	sbase1_sbase0
	lea	pmmu_config_text,a2
	_JSR	print_error
.error_found:
	bsr	unselect_trace
	IFNE	sourcedebug
	sf	not_in_block_flag(a6)
	sf	step_over_flag(a6)
	ENDC	;de sourcedebug
	movem.l	(sp)+,d3-d7/a2-a5
	rts
.done:
	;pour repartir EN MODE TRACE seulement
	;si pas permanent deja fini
	tst.b	permanent_trace_flag(a6)
	beq.s	.error_found
	IFNE	switching_debug
	pea	return_fromp0p1_top0p1(pc)
	bsr	print_debug
	addq.w	#4,sp
	ENDC
	movem.l	(sp)+,d3-d7/a2-a5
	bra	p0p1
.run:
	tst.b	nowatch_flag(a6)
	beq.s	.restore_all
.no_source_screen:
	tst.b	log_run_flag(a6)
	beq.s	.restore_all
.reput_log:
	bsr	sbase0_sbase1
.restore_all:
	move.l	pc_buf(a6),a0
	bsr	get_instr_type
	subq.w	#4,d0
	blt.s	.no_bsr_jsr
	subq.w	#1,d0
	bgt.s	.no_bsr_jsr
	move.l	pc_buf(a6),a0
	bsr	get_next_instruction
	move.l	a0,old_watch_pc_value(a6)
	move.l	a7_buf(a6),old_watch_a7_value(a6)
	move.l	ssp_buf(a6),old_watch_ssp_value(a6)
	move.w	sr_buf(a6),old_watch_sr_value(a6)
.no_bsr_jsr:
	move.b	#-2,exception(a6)
	bsr	timer0_timer1
	tst.b	acia_ikbd(a6)
	bne.s	.no_kbd
	bsr	kbd1_set
.no_kbd:
	IFNE	AMIGA
	_JSR	super_on
	beq.s	.already
	move.l	d0,internal_am_ssp(a6)
.already:
	ENDC	;d'AMIGA
	move.w	sr,internal_sr(a6)
	IFNE	AMIGA
	move	#$2700,sr
	bsr	reactive_task
	ENDC	;d'AMIGA
	move.l	sp,internal_ssp(a6)
	IFNE	_68030
	tst.b	chip_type(a6)
	beq	.68000
	_30
	move.w	sfc_buf(a6),d0
	dc.l	$4e7b0000		;movec	d0,sfc
	move.w	dfc_buf(a6),d0
	dc.l	$4e7b0001		;movec	d0,dfc
	move.l	cacr_buf(a6),d0
	dc.l	$4e7b0002		;movec	d0,cacr
	move.l	vbr_buf(a6),d0
	dc.l	$4e7b0801		;movec	d0,vbr
	move.l	caar_buf(a6),d0
	dc.l	$4e7b0802		;movec	d0,caar
	move.l	ssp_buf(a6),d4
	btst	#12,d3		;bit M?
	bne.s	.m
	movec	d4,isp
;	dc.l	$4e7b0804		;movec	d0,isp
	move.l	msp_buf(a6),d0
	dc.l	$4e7b0803		;movec	d0,msp
	bra.s	.afterm

.m:	movec	d4,msp
;	dc.l	$4e7b0803		;movec	d0,msp
	move.l	isp_buf(a6),d0
	dc.l	$4e7b0804		;movec	d0,isp
;	ori.w	#$1000,sr		;set M bit

.afterm:	_JSR	get_vbr
	move.l	$e0(a0),d2
	lea	p0_pmmu_routine(pc),a1
	move.l	a1,$e0(a0)
	moveq	#0,d1
	lea	crp_buf(a6),a0
	dc.w	$f010,$4c00	;pmove.q	(a0),crp
	addq.w	#8,a0
	dc.w	$f010,$4800	;pmove.q	(a0),srp
	addq.w	#8,a0
	dc.w	$f010,$4000	;pmove.l	(a0),tc
	addq.w	#4,a0
	dc.w	$f010,$0800	;pmove.l	(a0),tt0
	addq.w	#4,a0
	dc.w	$f010,$0c00	;pmove.l	(a0),tt1
	addq.w	#4,a0
	dc.w	$f010,$6000	;pmove.w	(a0),mmusr
	tst.b	d1
	bne	.pmmu_error
	tst.b	fpu_type(a6)
	beq.s	.no_fpu
	addq.w	#2,a0
;	trap	#0
	dc.w	$f210,$d0ff	;fmovem.x	(a0),fp0-fp7
	lea	8*3*4(a0),a0
;	dc.w	$f210,$dc00	;fmovem.l	(a0),fpcr/fpsr/fpiar
	fmove.l	(a0)+,fpcr
	fmove.l	(a0)+,fpsr
	fmove.l	(a0)+,fpiar
	_00
	;tst frame size ?
;	tst.b	fpu_frame+1(a6)
;	beq.s	.no_fpu
	lea	fpu_frame_end(a6),a0
	tst.l	(a0)
	beq.s	.no_fpu
	move.l	(a0),a1

;	cmp.b	#1,fpu_type(a6)
;	beq.s	.null_fpu_frame

;	move.b	(a1),d0
;	beq.s	.null_fpu_frame
;	moveq	#0,d0
;	move.b	1(a1),d0
;	bset	#3,(a1,d0.w)
.null_fpu_frame:
	dc.w	$f351		;frestore	(a1)
	clr.l	(a0)

.no_fpu:	move.l	d4,sp
	;emulation de sf_vector_offset par une stack frame $0
	clr.w	-(sp)
	clr.w	sf_type(a6)
	bra.s	.do_rte
.68000:
	ENDIF	;68030
	move.l	ssp_buf(a6),sp
.do_rte:	move.l	pc_buf(a6),-(sp)
	move.w	d3,-(sp)
	move.l	a7_buf(a6),a0
	move.l	a0,usp
	move.b	#1,p_number(a6)
	IFEQ	cartouche
	move.l	a6,internal_a6
	ENDC	;de cartouche
	movem.l	d0_buf(a6),d0-a6
	IFNE	stmag!atarifrance
rte_p0p1_addr:
	st	nostop_flag(a6)
	ELSEIF
	rte
	ENDC

p0_pmmu_routine:
	IFEQ	AMIGA	;a voir
	st	d1
	ENDC
	rte

	; #] p0p1:
	; #[ p1p0:
p1p0:
	move.b	p_number(a6),old_p_number(a6)
	sf	p_number(a6)
	sf	halted_flag(a6)
	movem.l	d0-a5,d0_buf(a6)
	IFNE	AMIGA
;du pterm, on rentre en tache p1 et eventuellement en user
	cmp.b	#1,exception(a6)
	bne.s	.in_super
	bsr	super_on_always
	move	sr,-(sp)
	move	#$2700,sr
	bsr	stop_task
	move	(sp)+,sr
	move.l	d0,ssp_buf(a6)
	bne.s	.ssp_ok
.in_super:
	cmp.b	#-3,exception(a6)
	bne.s	.not_guru
	move	sr,-(sp)
	move	#$2700,sr
	bsr	stop_task
	move	(sp)+,sr
.not_guru:
	; on est rentre en super
	move.l	sp,ssp_buf(a6)
	addq.l	#6,ssp_buf(a6)
.ssp_ok:
	ENDC	;d'AMIGA
	IFNE	ATARIST
	move.l	sp,ssp_buf(a6)
	addq.l	#6,ssp_buf(a6)
	ENDC
	move.l	usp,a0
	move.l	a0,a7_buf(a6)
	move.w	(sp),sr_buf(a6)
	move.l	2(sp),d0
	IFNE	_68030
	tst.b	chip_type(a6)
	bne.s	.no_and
	ENDC
	andi.l	#$ffffff,d0
.no_and:	move.l	d0,pc_buf(a6)
	sf	watch_subroutine_flag(a6)
	IFNE	_68030
	tst.b	chip_type(a6)
	beq	.68000
	_30
	dc.l	$4e7a0000		;movec	sfc,d0
	move.w	d0,sfc_buf(a6)
	dc.l	$4e7a0001		;movec	dfc,d0
	move.w	d0,dfc_buf(a6)
	dc.l	$4e7a0002		;movec	cacr,d0
	move.l	d0,cacr_buf(a6)
	move.l	#$819,d0
	movec	d0,cacr		;CD?,IBE,CI,EI
	dc.l	$4e7a0801		;movec	vbr,d0
	move.l	d0,vbr_buf(a6)
	dc.l	$4e7a0802		;movec	caar,d0
	move.l	d0,caar_buf(a6)
	dc.l	$4e7a0803		;movec	msp,d0
	move.l	d0,msp_buf(a6)
	dc.l	$4e7a0804		;movec	isp,d0
	move.l	d0,isp_buf(a6)
	lea	crp_buf(a6),a0
	dc.w	$f010,$4e00	;pmove.q	crp,(a0)
	addq.w	#8,a0
	dc.w	$f010,$4a00	;pmove.q	srp,(a0)
	addq.w	#8,a0
	pmove.l	tc,(a0)		;dc.w	$f010,$4200
	addq.w	#4,a0
	pmove.l	tt0,(a0)		;dc.w	$f010,$0a00
	addq.w	#4,a0
	pmove.l	tt1,(a0)		;dc.w	$f010,$0e00
	addq.w	#4,a0
	dc.w	$f010,$6200	;pmove.w	mmusr,(a0)
	tst.b	fpu_type(a6)
	beq.s	.no_fpu
	; detourner kekchose
.wait_fpu:
	lea	fpu_frame(a6),a1
	dc.w	$f321		;fsave	-(a1)
	tst.b	(a1)
	beq.s	.no_frame
	cmp.b	#1,(a1)		;not ready frame
	beq.s	.wait_fpu
;	cmp.b	#2,(a1)		;illegal frame
;	beq.s	.no_frame
	move.l	a1,fpu_frame_end(a6)
.no_frame:
	addq.w	#2,a0
	dc.w	$f210,$f0ff	;fmovem.x	fp0-fp7,(a0)
	lea	8*3*4(a0),a0
	fmove.l	fpcr,(a0)+
	fmove.l	fpsr,(a0)+
	fmove.l	fpiar,(a0)+
	_00
.no_fpu:	addq.l	#2,ssp_buf(a6)
	move.w	sf_type(a6),d0
	beq.s	.update_stacks
	lea	stacks_sizes,a0
	moveq	#0,d1
	add.w	d0,d0
	move.w	(a0,d0.w),d1
;	move.w	(a0,d0.w*2),d1
	beq.s	.update_stacks
	add.w	d1,d1
	subq.w	#8,d1
	add.l	d1,ssp_buf(a6)
.update_stacks:
	; updater  l'une ou l'autre pile suivant le bit M
	move.w	sr_buf(a6),d1
	btst	#12,d1
	bne.s	.m
	move.l	ssp_buf(a6),isp_buf(a6)
	bra.s	.68000
.m:	move.l	ssp_buf(a6),msp_buf(a6)
.68000:
	ENDC
	IFNE	cartouche
	move.l	(a6),a6_buf(a6)
	ELSEIF
	move.l	external_a6,a6_buf(a6)
	ENDC
	move.l	internal_ssp(a6),sp
	bsr	kbd1_save
	tst.b	acia_ikbd(a6)
	bne.s	.no_kbd
	bsr	kbd0_set
.no_kbd:
	move.w	internal_sr(a6),d0
	lsr.w	#8,d0
	and.w	#$f,d0
	IFNE	AMIGA
	tst.b	force_ipl_flag(a6)
	beq.s	.not_idle
	sf	force_ipl_flag(a6)
	move.w	old_internal_sr(a6),d1
	bra.s	.put_sr
.not_idle:
	ENDC	;d'AMIGA
	moveq	#-1,d1
	tst.b	follow_sr_flag(a6)
	beq.s	.put_sr
	move.w	sr_buf(a6),d1
	lsr.w	#8,d1
	andi.w	#$f,d1
	cmp.w	d0,d1
	blt.s	.ok
	move.w	d1,d0
.ok:
	move.w	internal_sr(a6),d1
.put_sr:
	bsr	put_internal_sr
	;sauver les timers courants, apres switcher
	bsr	timer1_timer0
;	tst.b	acia_ikbd(a6)
;	beq.s	.no_clr
;	;clearer les mask/vitesse pour chez moi
;	bsr	clear_timers
;.no_clr:
	moveq	#0,d1
	move.b	exception(a6),d1
	IFNE	AMIGA
	cmp.b	#-3,d1
	beq	.guru
	cmp.b	#-4,d1
	bne	.no_multi_return
	lea	returned_from_multi_text,a3
	bra	.print_redraw_stop
.no_multi_return:
	ENDC
	
	cmpi.b	#-1,d1
	beq	.reset
	cmpi.b	#-2,d1
	beq	.unknown_tasking

	move.l	pc_buf(a6),a0
;fin de ro?
	cmp.l	ro_return_break_addr(a6),a0
	bne.s	.not_before_ro_break
	clr.l	ro_return_break_addr(a6)
	bra	.before_ro_break
.not_before_ro_break:
;fin de process?
	;devant les nops, enlever le break
	cmp.l	p1_return_addr(a6),a0
	beq	.before_internal_return
	;devant le break, enlever le break
	cmp.l	p1_return_break_addr(a6),a0
	beq	.before_internal_return_break
;trace?
	cmpi.b	#9,d1
	beq	.trace
;	cmp.l	internal_trap_nb(a6),d1
;	beq.s	.internal_trap

	;verifier si c'est un break ki m'a arrete
;	move.l	pc_buf(a6),a0
	moveq	#-1,d0
;	moveq	#0,d1
;	move.b	exception(a6),d1
	st	real_break_flag(a6)
	bsr	_check_if_break
	bmi.s	.exception
;.rm_break:
	;tenter de l'enlever si c'est le cas
	move.l	pc_buf(a6),a0
	moveq	#0,d1
	move.b	exception(a6),d1
	bsr	p1p0_rm_break
	bmi	.bad_break_eval
	;continuer
	tst.l	d1
	beq	.noprint_noredraw_cont

	;s'arreter
	;si ctrl_a aller en ctrl_a
	tst.b	runandbreak_flag(a6)
	bne.s	.ctrl_a
	;si emul source
;	tst.b	src_emulated_flag(a6)
;	bne.s	.ctrl_a
	;sinon break atteint et c'est tout
	bsr	treat_breakpt
	bra	.print_redraw_stop
.unknown_tasking:
	lea	unknown_tasking_text,a3
	bra	.print_redraw_stop
.exception:
	bsr	treat_exception
	IFNE	AMIGA
; rajouter le nom de la tache courante quand ce n'est pas p1
	tst.b	idle_flag(a6)
	bne.s	.message
	tst.b	multitask_access_flag(a6)
	bne.s	.message
	tst.b	trace_task_flag(a6)
	beq.s	.taskname_ok
	move.l	p1_current_task(a6),d0
	cmp.l	p1_task(a6),d0
	beq.s	.taskname_ok
.message:
	move.l	a3,a0
	lea	lower_level_buffer(a6),a1
	move.l	a1,a3
	jsr	strcpy
	lea	-1(a1,d0.w),a1
	move.b	#' ',(a1)+
	move.b	#'(',(a1)+
	tst.b	idle_flag(a6)
	beq.s	.not_idle2
	lea	idle_system_text,a0
	bra.s	.do_strcpy
.not_idle2:
	move.l	p1_current_task(a6),a0
	move.l	10(a0),a0
.do_strcpy:
	jsr	strcpy
	lea	-1(a1,d0.w),a1
	move.b	#')',(a1)+
	clr.b	(a1)
.taskname_ok:
	ENDC	;d'AMIGA
	bra.s	.print_redraw_stop
.internal_trap:
	;
	;
	;
.ctrl_a:
.trace:
	bsr	treat_trace
;print_redraw_stop:-1
	bmi.s	.print_redraw_stop
;print_redraw_cont:0
	beq.s	.print_redraw_cont
;noprint_redraw_cont:1
	subq.w	#1,d0
	beq.s	.noprint_redraw_cont
;noprint_noredraw_cont:2
	subq.w	#1,d0
	beq.s	.noprint_noredraw_cont
;noprint_noredraw_stop:3
	subq.w	#1,d0
	beq.s	.noprint_noredraw_stop
;noprint_redraw_stop:4
	subq.w	#1,d0
	beq.s	.noprint_redraw_stop
	bra.s	.print_redraw_stop
.print_redraw_cont:
	move.l	a3,a2
	bsr	print_result
.noprint_redraw_cont:
	bsr	install_screen
.noprint_noredraw_cont:
	sf	runandbreak_flag(a6)
	sf	exc_emulated_flag(a6)
	IFNE	switching_debug
	pea	continue_from_p1p0_text(pc)
	bsr	print_debug
	addq.w	#4,sp
	ENDC
	movem.l	(sp)+,d3-d7/a2-a5
	bra	p0p1
.print_redraw_stop:
	move.l	a3,a2
	bsr	print_result
.noprint_redraw_stop:
	tst.b	old_p_number(a6)
	beq	.in_me
	bsr	install_screen
;	bra.s	.end
.noprint_noredraw_stop:
.end:
	bsr	unselect_trace
	IFNE	sourcedebug
	sf	not_in_block_flag(a6)
	sf	step_over_flag(a6)
	ENDC	;de sourcedebug
	;routine appelee a chaque exception
;	lea	exception_routine_buffer(a6),a0
;	bsr	evaluate
	movem.l	(sp)+,d3-d7/a2-a5
	IFNE	AMIGA
	cmp.b	#1,exception(a6)
	bne.s	.not_pterm
	tst.l	(sp)+
.not_pterm:
	move.l	internal_am_ssp(a6),a0
	_JSR	super_off
	tst.b	multitask_access_flag(a6)
	beq.s	.p1p0_end
;	move.l	(sp),old_multi_return(a6)
	move.l	#multitask_return,(sp)
.p1p0_end:
	ENDC	;d'AMIGA
	rts
;a0 already set
.before_ro_break:
	bsr	p1p0_rm_break
	bmi.s	.bad_break_eval
	bra.s	.noprint_noredraw_stop
;a0 already set
.before_internal_return:
	;3 nops
	IFNE	ATARIST
	addq.w	#6,a0
	ENDC
	IFNE	AMIGA
	move	sr,sr_buf(a6)
	sf	trace_flag(a6)
	st	run_flag(a6)
	bra.s	.noprint_noredraw_cont
	ENDC
.before_internal_return_break:
	bsr	p1p0_rm_break
	bmi.s	.bad_break_eval
	move.w	sr,sr_buf(a6)
	bra.s	.noprint_noredraw_cont
	IFNE	AMIGA
.guru:
	_JSR	treat_guru
	bsr	sbase0_sbase1
	bsr	install_screen
	bsr.s	unselect_trace
	move.l	top_stack_addr(a6),sp
	subq.w	#4,sp
	_JSR	super_off
	_JMP	waiting
	ENDC ; de AMIGA
.reset:
	lea	reset_exception_text,a3
;	bra.s	.print_in_me
.print_in_me:
	move.l	a3,a2
	bsr	print_result
.in_me:
	moveq	#7,d0
	moveq	#-1,d1
	bsr	put_internal_sr
	;pour recuperer l'ecran logique dans tous les cas
	bsr	sbase0_sbase1
	bsr	install_screen
	bsr.s	unselect_trace
	move.l	top_stack_addr(a6),sp
	subq.w	#4,sp
	IFNE	AMIGA
	_JSR	super_off
	ENDC	;d'AMIGA
	_JMP	waiting
.bad_break_eval:
	moveq	#-4,d0
	bsr	_print_break_error
	bra	.noprint_redraw_stop

unselect_trace:
	lea	internal_context_buffer(a6),a0
	moveq	#INTERNAL_CONTEXT_SIZE/4-1,d0
.l1:
	clr.l	(a0)+
	dbf	d0,.l1
	rts

;print_redraw_stop:-1
;print_redraw_cont:0
;noprint_redraw_cont:1
;noprint_noredraw_cont:2
;noprint_noredraw_stop:3
;noprint_redraw_stop:4
treat_trace:
	IFNE	sourcedebug
	tst.b	trace_source_flag(a6)
	bne	.trace_source
	ENDC	;de sourcedebug
	tst.b	runandbreak_flag(a6)
	beq.s	.trace

	;un bete ctl_a
	lea	ctrla_text,a3
	tst.b	exc_emulated_flag(a6)
	beq	.print_redraw_stop
	;emulation trap
	lea	faux_ctrla_text,a3
	tst.b	permanent_trace_flag(a6)
	bne.s	.in_trace
	bra	.print_redraw_stop
.trace:
	tst.b	reinstall_trace_flag(a6)
	beq.s	.no_reinstall_trace
	_JSR	get_vbr
	move.l	save2_exc9(a6),$24(a0)
.no_reinstall_trace:
	;par defaut: "traced."
	lea	traced2_text,a3
.in_trace:
	;ctrl_z
	tst.b	ctlz_flag(a6)
	bne	.print_redraw_stop
	;emul break
	tst.b	justonce_flag(a6)
	bne	.justonce
	;divers modes trace
	;source echoue dessus
	tst.b	permanent_trace_flag(a6)
	beq	.print_redraw_stop
	;slow
	tst.b	trace_slow_flag(a6)
	bne	.slow
	;until
	tst.b	trace_until_flag(a6)
	bne.s	.until
	;68020
;	IFNE	_68010!_68020!_68030
;	tst.b	chip_type(a6)
;	bne.s	.stop
;	ENDC
	tst.b	trace_t1_flag(a6)
	bne.s	.mode_t1
	;until pc
	tst.b	trace_until_pc_flag(a6)
	bne.s	.trace_until_pc
	;le reste?
	tst.b	trace_instruct_flag(a6)
	beq	.print_redraw_stop
	;instruct
	move.l	pc_buf(a6),a0
	bsr	dis_tmp
	lea	tmp_buffer(a6),a1
	lea	trace_instruc_buffer(a6),a0
	bsr	cmp_instruc
	bmi.s	.slow
.stop:
	sf	nostop_flag(a6)
	bra.s	.slow
	IFNE	sourcedebug
.trace_source:
	lea	traced2_text,a3
	tst.b	not_in_block_flag(a6)
	bne	.print_redraw_stop
	bra	.noprint_noredraw_cont
	ENDC	;de sourcedebug
.mode_t1:
	;chercher les changements de flux
	move.l	pc_buf(a6),a0
	bsr	get_instr_type
	beq.s	.slow
;1=trap
;2=linea
;3=linef
;4=bsr
;5=jsr
;6=bcc
;7=dbcc
;8=jmp
;9=trapv
;10=chk
;11=rts
;12=rte
;13=rtr
	;trap linea-f
	subq.w	#4,d0
	bmi.s	.slow
	;bsr jsr bcc dbcc jmp
	subq.w	#5,d0
	bmi.s	.do
	;trapv chk
	subq.w	#2,d0
	bmi.s	.slow
	;rts-e-r
.do:
	tst.b	d1
	bmi.s	.slow
	sf	nostop_flag(a6)
	bra.s	.slow
.trace_until_pc:
	move.l	trace_until_pc_value(a6),d0
	cmp.l	pc_buf(a6),d0
	bne.s	.slow
	sf	nostop_flag(a6)
	bra.s	.slow
.until:
	lea	trace_until_buffer(a6),a0
	bsr	evaluate
	tst.w	d1
	bmi.s	.run_until_error
	;si d0=-1,s'arreter
	cmpi.l	#-1,d0
	bne.s	.slow
	sf	nostop_flag(a6)
.slow:
	bsr	test_shift_shift
	bne.s	.do_stop

	;if stopped print & redraw
	tst.b	nostop_flag(a6)
	beq.s	.do_stop

	;fout la merde
	;if nowatch,no print & no redraw,but restart
	tst.b	nowatch_flag(a6)
	bne.s	.noprint_noredraw_cont

	;if nostop et watch,no print & redraw windows
	bra.s	.noprint_redraw_cont
.justonce:
	IFNE	switching_debug
	pea	justonce_text(pc)
	bsr	print_debug
	addq.w	#4,sp
	ENDC
	tst.b	permanent_trace_flag(a6)
	beq.s	.noprint_noredraw_stop
	bra.s	.noprint_redraw_stop
.run_until_error:
	lea	bad_run_until_eval_text,a3
	bra.s	.print_redraw_stop
.do_stop:
	lea	traced3_text,a3
.print_redraw_stop:
	moveq	#-1,d0
	bra.s	.end
.print_redraw_cont:
	moveq	#0,d0
	bra.s	.end
.noprint_redraw_cont:
	moveq	#1,d0
	bra.s	.end
.noprint_noredraw_cont:
	moveq	#2,d0
	bra.s	.end
.noprint_noredraw_stop:
	moveq	#3,d0
	bra.s	.end
.noprint_redraw_stop:
	moveq	#4,d0
.end:	rts

install_screen:
	tst.b	v_screen1_flag(a6)
	bne.s	.no_relog
	bsr	sbase1_sbase0
.no_relog:
	bra	redraw_relock_all
	; #] p1p0:
	; #[ Treat_exception:
treat_exception:
	moveq	#0,d0
	move.b	exception(a6),d0
	cmp.w	#$100/4,d0
	bge	.user_vectors
	lea	exception_message_table,a0
	move.w	d0,d1
	asl.w	#2,d0
	move.l	(a0,d0.w),a3
	tst.w	d1
	beq.s	.end
	cmpi.w	#1,d1
	beq.s	.pterm
	cmpi.w	#3,d1
	ble.s	.super
	cmpi.w	#25,d1
	blt.s	.end
	cmpi.w	#32,d1
	blt.s	.ipl

	cmpi.w	#32+16,d1
	bgt.s	.end
;.trap:
	subi.w	#32,d1
	bsr.s	treat_errno
	move.l	a0,a3
	bra.s	.end
.super:
	bsr	treat_baderr
	move.l	a0,a3
	bra.s	.end
.pterm:
	bsr	treat_ptermerr
	move.l	a0,a3
	bra.s	.end
.user_vectors:
	bsr	treat_usererr	
	move.l	a0,a3
	bra.s	.end
.ipl:
	subi.w	#24,d1
	bsr.s	treat_errno
	move.l	a0,a3
.end:
	;chez moi = internal error
	tst.b	old_p_number(a6)
	beq.s	treat_internal_error
	rts
	; #] Treat_exception:
	; #[ Treat_internal_error:
treat_internal_error:
	move.l	pc_buf(a6),d0
	lea	A_Debug,a0
	sub.l	a0,d0
	move.l	d0,-(sp)
	move.b	exception(a6),d0
	move.w	d0,-(sp)
	pea	internal_error_text
	lea	line_buffer(a6),a3
	move.l	a3,a0
	bsr	sprintf2
	lea	10(sp),sp
	move.l	a3,a0
	rts
	; #] Treat_internal_error:
	; #[ Treat_user_error:
treat_usererr:
	subi.w	#$100/4,d0
	move.w	d0,-(sp)
	pea	user_vector_format_text
	lea	line_buffer(a6),a3
	move.l	a3,a0
	bsr	sprintf2
	addq.w	#6,sp
	move.l	a3,a0
	rts
	; #] Treat_user_error:
	; #[ Treat_errno:
treat_errno:
	move.w	d1,-(sp)
	move.l	a3,-(sp)
	lea	line_buffer(a6),a2
	move.l	a2,a0
	bsr	sprintf2
	addq.w	#6,sp
	move.l	a2,a0
	rts
	; #] Treat_errno:
	; #[ Treat baderr:
treat_baderr:
	movem.l	d6-d7/a3-a4,-(sp)

	IFNE	_68030
	tst.b	chip_type(a6)
	beq.s	.68000
	move.l	a3,a4
	bra.s	.end
.68000:
	ENDC
	lea	line_buffer(a6),a4
	move.w	sf_ir(a6),-(sp)
	move.l	sf_cycle_addr(a6),-(sp)

	move.w	sf_super_word(a6),d0
	bsr	build_ssw
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	pea	ssw_text
	move.l	a4,a0
	bsr	sprintf2
	lea	18(sp),sp
.end:
	move.l	a4,a0
	movem.l	(sp)+,d6-d7/a3-a4
	rts

build_ssw:
	;SUPER STATE WORD
	moveq	#'W',d1
	btst	#4,d0
	beq.s	.write
	moveq	#'R',d1
.write:
	lsl.w	#8,d1
	move.b	#'I',d1
	btst	#3,d0
	beq.s	.no_exc
	move.b	#'E',d1
.no_exc:
	swap	d1
	bsr.s	build_fcx
	or.l	d1,d0
	rts

;In:d0=fc0-fc2 (%111)
;Out:d0={'U','S'}+{'D','P','I'}
build_fcx:
	move.l	d1,-(sp)

	;etat de la ligne FC2
	moveq	#'U',d1
	btst	#2,d0
	beq.s	.user
	moveq	#'S',d1
.user:
	lsl.w	#8,d1

	;FC1-FC0
	move.b	#'D',d1
	btst	#1,d0
	beq.s	.data
	btst	#0,d0
	bne.s	.interrupt
	move.b	#'P',d1
	bra.s	.data
.interrupt:
	move.b	#'I',d1
.data:
	move.l	d1,d0
	move.l	(sp)+,d1
	rts
	; #] Treat baderr:
	; #[ Treat ptermerr:
treat_ptermerr:
	_JSR	machine_term
	;effacer les breakpoints
	_JSR	_kill_all_breaks
	;forcer la pile super a zero pour ne plus pouvoir tracer
	IFNE	ATARIST
	clr.l	ssp_buf(a6)
	ENDC
	;effacer les labels
	move.l	before_ctrll_addr(a6),a0
	bsr	clr_table_end

	move.l	d0_buf(a6),-(sp)
	move.l	(sp),-(sp)
	move.l	(sp),-(sp)
	move.l	(sp),-(sp)
	move.l	a3,-(sp)
	lea	line_buffer(a6),a3
	move.l	a3,a0
	bsr	sprintf2
	lea	20(sp),sp
	move.l	a3,a0
	rts
	; #] Treat ptermerr:
	; #[ Treat_breakpt:
;d0 le # de break
treat_breakpt:
	move.l	d0,-(sp)
	pea	break_reach_text
	lea	line_buffer(a6),a3
	move.l	a3,a0
	bsr	sprintf2
	addq.w	#8,sp
	rts
	; #] Treat_breakpt:
	; #[ Dis_tmp:
;Input:
;a0 = @
;a1 = datas @
;Output:in tmp_buffer
dis_tmp:
	movem.l	d0-a5,-(sp)
	move.l	a0,a1
	st	optimise_address(a6)
	move.l	a1,test_instruction(a6)
	lea	instruction_size(a6),a5
	clr.w	(a5)
	lea	tmp_buffer(a6),a0
	move.l	a1,d0
	bclr	#0,d0
;	move.l	d0,a2
	move.l	d0,a1
;	move.l	a0,dc_w_line_buffer(a6)
;	lea	disassemble_datas(a6),a1
;	move.l	(a2),(a1)
;	move.l	4(a2),4(a1)
;	move.w	8(a2),8(a1)
	st	dont_remove_break_flag(a6)
	_JSR	disassemble_line
	_JSR	display_break
	clr.b	(a0)
	movem.l	(sp)+,d0-a5
	rts
	; #] Dis_tmp:
	; #[ Treat_cmd_line:
;implementer:
	;values
;-gp = path general
;-pv = path de ADEBUG.VAR (avec priorite sur le precedent)
;-ps = path de ADEBUG.SAV (id)
;-pm = path de la macro en autoexec
;-v = nom du fichier VAR
;-s = nom du fichier SAV
;-m = nom d'une macro en autoexec
;-o = offset de chargement
;-i# = def IPL level

	;flags
;-r = rs232_output
;-d = debug mode 1 in ADEBUG.VAR
;-D = debug mode 2 in ADEBUG.VAR

treat_cmd_line:
	movem.l	d3-d7/a2-a5,-(sp)
	lea	argv_buffer(a6),a3
.more_cmd:
	move.b	(a3)+,d0
	beq.s	.nothing
	cmp.b	#'-',d0
	bne.s	.no_option
	move.b	(a3)+,d0
	lea	cmdline_letters_table(pc),a0
	moveq	#0,d2
.l2:
	move.b	(a0)+,d1
	beq.s	.not_allowed
	addq.w	#1,d2
	cmp.b	d0,d1
	bne.s	.l2
	subq.w	#1,d2
	move.l	a3,a0
	bsr	pskip
	move.l	a0,a3
	;format
	lea	cmdline_formats_table(pc),a0
	move.b	0(a0,d2.w),d0
	cmp.b	#'s',d0
	beq.s	.dont_eval
	bsr	evaluate
.dont_eval:
	;routine
	lea	cmdline_routines_table(pc),a0
	asl.w	#2,d2
	lea	0(a0,d2.w),a5
	;ds a0 ptr sur string
	;ds d0 la valeur si demandee
	move.l	a3,a0
	move.l	a3,-(sp)
	move.l	(a5),a5
	jsr	(a5)
	move.l	(sp)+,a0
	bsr	pflush
	move.l	a0,a3
	bra.s	.more_cmd
.no_option:
	;option par defaut si '-' non rencontre
	IFEQ	residant!bridos
	lea	-1(a3),a0
	bsr	get_cmd_line
	ENDC
	bra.s	.nothing
.not_allowed:
	lea	line_buffer(a6),a2
	move.w	d0,-(sp)
	pea	option_forbid_textf
	move.l	a2,a0
	bsr	sprintf2
	addq.w	#6,sp
	bsr	print_press_key
.nothing:
	movem.l	(sp)+,d3-d7/a2-a5
	rts

cmdline_letters_table:
	;-b = load binary
	dc.b	'b'
	;-i# = set def ipl
	dc.b	'i'
	dc.b	0
	even
cmdline_formats_table:
	;load binary filename
	dc.b	's'
	;set ipl 3 bits
	dc.b	'3'
	even
cmdline_routines_table:
	IFEQ	residant!bridos
	dc.l	_load_binary
	ENDC
	dc.l	_cmd_ipl
	dc.l	-1

_cmd_ipl:
	andi.w	#%111,d0
	move.w	d0,def_ipl_level(a6)
	rts

	; #] Treat_cmd_line:
;  #] Context switching:
;  #[ Story stuff:
	; #[ Backup story:
backup_story:
	move.l	current_sto_addr(a6),a1
	move.l	cur_sto_nb(a6),d0

	;entrees reservees ?
	move.l	story_max(a6),d1
	beq.s	.end
	;arrive au max ?
	cmp.l	d1,d0
	bne.s	.not_max

	;oui alors debut de buffer
	move.l	story_addr(a6),a1
	move.l	#1,cur_sto_nb(a6)
	bra.s	.copy
.not_max
	;plus un enregistrement dans le story
	addq.l	#1,cur_sto_nb(a6)
.copy:
	;17 registres a copier
	lea	d0_buf(a6),a0
	moveq	#16,d0
.l1:	move.l	(a0)+,(a1)+
	dbf	d0,.l1

	move.w	sr_buf(a6),(a1)+
	move.l	pc_buf(a6),a0
	move.l	a0,(a1)+

	;les 20 (words) octets de l'instruction (68030)
	moveq	#20-1,d0
.l2:	move.w	(a0)+,(a1)+
	dbf	d0,.l2
	;son numero dans le story
	move.l	cur_sto_nb(a6),(a1)+
	move.l	a1,current_sto_addr(a6)
.end:	rts
	; #] Backup story:
;  #] Story stuff:
;  #[ History stuff:
	; #[ Backup history:
;a0=ptr sur chaine a recopier ds l'history
backup_history:
	movem.l	a2-a3,-(sp)
	tst.l	history_size(a6)
	beq.s	.end
.again:	move.l	cur_history_addr(a6),a1
	bsr	strlen2
	addq.l	#1,d0		;pour le zero de fin de chaine
	move.l	d0,d2
	move.l	a1,d1
	add.l	d2,d1
	addq.l	#1,d1		;pour le zero de fin de buffer HIS
	cmp.l	end_history_addr(a6),d1
	ble.s	.backup

	move.l	history_addr(a6),a2	;switcher tout d'un cran vers le haut
	move.l	a0,-(sp)
	move.l	a2,a0
	bsr	strlen2
	move.l	(sp)+,a0
	addq.l	#1,d0		;pour le zero
	move.l	d0,d1
	sub.l	d0,cur_history_addr(a6)
	sub.l	d0,current_his_size(a6)
	move.l	a2,a3
	add.l	d0,a3

	move.l	a1,d0		;switcher vers le haut
	sub.l	a3,d0
	beq.s	.clear
	subq.l	#1,d0
.l1:	move.b	(a3)+,(a2)+
	dbf	d0,.l1
	move.l	a2,a1
.clear:	move.l	cur_history_addr(a6),a2	;clearer
.l3:	clr.b	(a2)+
	dbf	d1,.l3
	bra.s	.again		;retourner pour verifier qu'il reste bien de la place
.backup:
.l2:	move.b	(a0)+,(a1)+
	bne.s	.l2
	add.l	d2,current_his_size(a6)
	move.l	a1,cur_history_addr(a6)
	move.l	a1,trans_history_addr(a6)
	movem.l	(sp)+,a2-a3
.end:	rts
	; #] Backup history:
	; #[ Put last history:
;a0=ptr du buffer dans lequel recopier l'history

;a0=ptr sur la fin de la chaine
;d0=nb de caracteres recopies
put_last_history:
	moveq	#0,d0
	tst.l	current_his_size(a6)
	beq.s	.abort
	move.l	trans_history_addr(a6),a1
	subq.w	#1,a1
	cmp.l	history_addr(a6),a1
	ble.s	.abort
.l1:	tst.b	-(a1)
	bne.s	.l1
	addq.w	#1,a1
	move.l	a1,trans_history_addr(a6)
.l2:	addq.w	#1,d0
	move.b	(a1)+,(a0)+
	bne.s	.l2
	subq.w	#1,a0
	subq.w	#1,d0
.end:	tst.w	d0
	rts
.abort:	moveq	#-1,d0
	bra.s	.end
	; #] Put last history:
	; #[ Put next history:
;a0=ptr du buffer dans lequel recopier l'history

;a0=ptr sur la fin de la chaine
;d0=nb de caracteres recopies
put_next_history:
	tst.l	current_his_size(a6)
	beq.s	.abort
	move.l	trans_history_addr(a6),a1
	cmp.l	cur_history_addr(a6),a1
	bge.s	.abort
	cmp.l	end_history_addr(a6),a1
	bge.s	.abort
.l1:
	tst.b	(a1)+
	bne.s	.l1
	move.l	a1,trans_history_addr(a6)
	moveq	#0,d0
.l2:
	addq.w	#1,d0
	move.b	(a1)+,(a0)+
	bne.s	.l2
	subq.w	#1,a0
	subq.w	#1,d0
.end:
	tst.w	d0
	rts
.abort:
	moveq	#-1,d0
	bra.s	.end
	; #] Put next history:
;  #] History stuff:
;  #[ Block stuff:
	; #[ Block menu:
;block_menu:
;	rts
	; #] Block menu:
;  #] Block stuff:
;  #[ Mac stuff:
	; #[ execute_def_mac:
execute_def_mac:
	lea	def_mac_text,a0
execute_mac:
	bsr	__load_mac
	bmi.s	.abort
	bsr	play_mac
.abort:
	rts
	; #] execute_def_mac:
	; #[ Mac_menu:
mac_menu:
.again1:
	sf	rec_mac_flag(a6)
	sf	rec_flag(a6)
	sf	play_flag(a6)
	;R)ecord P)lay L)oad W)atch
	lea	menu_mac_text,a2
	_JSR	ask_menu
	bmi	.abort

	subq.w	#1,d0
	seq	rec_flag(a6)
	beq.s	.menu2
	subq.w	#1,d0
	seq	play_flag(a6)
	beq.s	.menu2
	subq.w	#1,d0
	beq.s	.load
	subq.w	#1,d0
	bne.s	.flash1
.watch1:
	move.l	mac_addr(a6),a0
	bsr	edit_mac
	bra.s	.again1
.load:
	bsr	load_mac
	bra.s	.again1
.flash1:
	bsr	flash
	bra.s	.again1
.flash2:
	bsr	flash
.menu2:
;R)ecord T)race B)ack S)kip C)lr
;P)lay T)race B)ack S)kip W)atch H)ome E)nd
	lea	menu_rec_mac_text,a2
	tst.b	rec_flag(a6)
	bne.s	.yes_record1
	bsr	print_next_mac
	lea	menu_play_mac_text,a2
.yes_record1:
	_JSR	ask_menu
	bmi.s	.again1

	subq.w	#1,d0
	beq.s	.run
	subq.w	#1,d0
	beq.s	.trace
	subq.w	#1,d0
	beq.s	.back
	subq.w	#1,d0
	beq.s	.skip

	tst.b	play_flag(a6)
	beq.s	.yes_record2

	;play:
	subq.w	#1,d0
	beq.s	.watch2
	subq.w	#1,d0
	bne.s	.flash2
;.home:
	bsr.s	home_mac
	bra.s	.menu2
	;record:
.yes_record2:
	subq.w	#1,d0
	bne.s	.flash2
.clr:
	bsr	clear_mac
	bra.s	.menu2
.watch2:
	bsr	watch_mac
	bra.s	.menu2
.trace:
	bsr.s	once_mac
	bmi.s	.abort
	bra.s	.menu2
.back:
	bsr.s	back_mac
	bra.s	.menu2
.skip:
	bsr	skip_mac
	bra.s	.menu2
.run:
	bsr.s	go_mac
.abort:
	rts
	; #] Mac_menu:
	; #[ Home_mac:
home_mac:
;play:
	move.l	mac_addr(a6),cur_play_mac_addr(a6)
	lea	mac_play_home_text,a2
	bra	print_result
	; #] Home_mac:
	; #[ Go_mac:
go_mac:
	tst.b	rec_flag(a6)
	bne.s	.record
	sf	trace_mac_flag(a6)
	st	go_mac_flag(a6)
	bra	play_mac
.record:
	bra	record_mac
	; #] Go_mac:
	; #[ Once_mac:
once_mac:
	tst.b	rec_flag(a6)
	bne.s	.record
	st	trace_mac_flag(a6)
	sf	go_mac_flag(a6)
	bra	play_mac
.record:
	st	rec_mac_flag(a6)
	lea	mac_rec_text,a2
	bsr	print_result
	bsr	get_char
	bsr	treat_instruction
	bsr	get_char
	sf	rec_mac_flag(a6)
	moveq	#0,d0
	rts
	; #] Once_mac:
	; #[ Back_mac:
back_mac:
	tst.b	rec_flag(a6)
	bne.s	.record
	move.l	cur_play_mac_addr(a6),a0
.re_back:
	bsr	paflush
	bsr	paskip
	bsr	paflush
	move.b	(a0),d0
	beq.s	.no_more_play
	cmp.b	#'`',d0
	beq.s	.no_more_play
	cmp.b	#'ø',d0
	bne.s	.re_back
.no_more_play:
	move.l	a0,cur_play_mac_addr(a6)
	bra.s	.end
.record:
	move.l	cur_rec_mac_addr(a6),a0
	bsr	paflush
	bsr	paskip
	bsr	paflush
	move.b	(a0),d0
	beq.s	.no_more_rec
	cmp.b	#'`',d0
	beq.s	.no_more_rec
	cmp.b	#'ø',d0
	bne.s	.re_back
.no_more_rec:
	move.l	a0,cur_rec_mac_addr(a6)
.end:
	rts
	; #] Back_mac:
	; #[ Skip_mac:
skip_mac:
	tst.b	rec_flag(a6)
	bne.s	.record
	move.l	cur_play_mac_addr(a6),a0
.re_skip
	bsr	pskip
	bsr	pflush
	bsr	pskip
	move.b	(a0),d0
	beq.s	.no_more_play
	cmp.b	#'`',d0
	beq.s	.no_more_play
	cmp.b	#'ø',d0
	bne.s	.re_skip
.no_more_play:
	move.l	a0,cur_play_mac_addr(a6)
;	bra.s	.end
.record:
;	lea	ask_for_function_text(pc),a2
;	bsr	print_result
;	bsr	get_char
;	bsr	_treat_instruction
.end:
	rts
	; #] Skip_mac:
	; #[ Watch_mac:
watch_mac:
	;record ?
	tst.b	rec_mac_flag(a6)
	bne.s	.record
	move.l	cur_play_mac_addr(a6),a0
	bra.s	.edit
.record:
	move.l	cur_rec_mac_addr(a6),a0
.edit:
	bra	edit_mac
	; #] Watch_mac:
	; #[ record_mac:
record_mac:
	st	rec_mac_flag(a6)
	moveq	#0,d0
	bsr	redraw_inside_window
	lea	mac_rec_text,a2
	bra	print_result
	; #] record_mac:
	; #[ Recording mac: recoit une touche et l'expande ds le buf de mac
;d0=code touche complet
;d4=@ de depart du recording
;d5=compteur
;d6=size totale
;d7=d0

;a3=@ expansion
;a4=ptr courant
recording_mac:
	movem.l	d4-d7/a2-a4,-(sp)

	;get the scancode
	swap	d0
	;est-ce interdit d'enregistrement ?
	lea	no_record_table,a0
.l1:
	move.w	(a0)+,d1
	beq.s	.ok
	cmp.w	d0,d1
	beq	.dont_record_this_one
	bra.s	.l1
.ok:
	;faut-il echanger  ?
	lea	swap_record_table,a0
.l2:
	move.w	(a0)+,d1
	beq.s	.ok2
	tst.w	(a0)+
	cmp.w	d0,d1
	bne.s	.l2
	move.w	-2(a0),d0
.ok2:
	;return to normal mode
	swap	d0
	move.l	cur_rec_mac_addr(a6),d1
	beq.s	.memory_error
	bmi.s	.memory_error

	move.l	cur_rec_mac_size(a6),d6
	bmi.s	.memory_error

	move.l	d1,d4
	move.l	d1,a4

	;expander d0
	bsr.s	scan_to_text
	move.l	d0,d5
	move.l	a0,a3

	;longueur correcte?
	move.l	mac_size(a6),d0
	sub.l	cur_rec_mac_size(a6),d0
	cmp.l	d5,d0
	ble.s	.memory_error

	;afficher
	move.l	a0,a2
	bsr	print_message
	;+
	move.b	#'`',(a4)+
	subq.w	#1,d5
	;recopier
.l3:
	move.b	(a3)+,(a4)+
	dbf	d5,.l3

	addq.w	#1,rec_mac_counter(a6)
	;a-t-on atteint 5 macros ?
	;si oui,mettre 13 10 plutot que espace
	cmp.w	#5,rec_mac_counter(a6)
	blt.s	.put_space
	move.b	#13,(a4)+
	move.b	#10,(a4)+
	clr.w	rec_mac_counter(a6)
	bra.s	.record_ended
.put_space:
	move.b	#' ',(a4)+
.record_ended:
	move.l	a4,cur_rec_mac_addr(a6)
	move.l	a4,d0
	sub.l	d4,d0
	add.l	d0,cur_rec_mac_size(a6)
	bra.s	.end
.memory_error:
	lea	mac_memory_error_text,a2
	bsr	print_error
;	bra.s	.abort
.dont_record_this_one:
;	st	again_rec_mac_flag(a6)
.abort:
	sf	rec_mac_flag(a6)
	moveq	#0,d0
	bsr	redraw_inside_window
.end:
	movem.l	(sp)+,d4-d7/a2-a4
	rts
	; #] Recording mac:
	; #[ scan_to_text:
;d5=scan.w
;d6={kbshift}
;d7=scan|asc
;a4=ptr courant sur chaine
;a5=@ line buffer
scan_to_text:
	movem.l	d5-d7/a2-a5,-(sp)
	move.l	d0,d7
	swap	d0
	move.w	d0,d5
	lsr.w	#8,d0
	move.b	d0,d6

	lea	sprintf_line(a6),a5
	move.l	a5,a4

	;shift,alt,ctrl?
;.pass1:
	btst	#0,d6
	beq.s	.not_sft
	move.l	#"sft_",(a4)+
.not_sft:
	btst	#2,d6
	beq.s	.not_ctl
	move.l	#"ctl_",(a4)+
.not_ctl:
	btst	#3,d6
	beq.s	.not_alt
	move.l	#"alt_",(a4)+
.not_alt:
	;textes spe
;.pass2:
	;fleches
	cmp.b	#$4D,d5
	beq	.put_right
	cmp.b	#$4B,d5
	beq	.put_left
	cmp.b	#$48,d5
	beq	.put_up
	cmp.b	#$50,d5
	beq	.put_down

	;help-undo-ins-clr
	cmp.b	#$62,d5
	beq	.put_help
	cmp.b	#$61,d5
	beq	.put_undo
	cmp.b	#$52,d5
	beq	.put_ins
	cmp.b	#$47,d5
	beq	.put_clr

	;tab-esc
	cmp.b	#$0F,d5
	beq	.put_tab
	cmp.b	#$01,d5
	beq	.put_esc

	;back-del
	cmp.b	#$0E,d5
	beq	.put_back
	cmp.b	#$53,d5
	beq	.put_del

	;cr-enter:
	cmp.b	#$1C,d5
	beq	.put_cr
	cmp.b	#$72,d5
	beq	.put_enter

	;touches de fonctions
	cmp.b	#$3B,d5
	blt.s	.no_fnb
	cmp.b	#$44,d5
	bgt.s	.no_fnb
	bra	.put_fnb
.no_fnb:
	;.pass3:

	;cas particuliers:
	cmp.b	#$6C,d5
	bne.s	.not_ctl_6

	move.b	#'6',d7
.not_ctl_6:
	;une lettre normale
.put_letter:
	cmpi.b	#'A',d7
	blt.s	.not_upper
	cmpi.b	#'Z',d7
	bgt.s	.not_upper
	addi.b	#'a'-'A',d7
.not_upper:
	move.b	d7,(a4)+
.ok
	clr.b	(a4)
.end:
	move.l	a4,d0
	sub.l	a5,d0
	move.l	a5,a0
	movem.l	(sp)+,d5-d7/a2-a5
	rts
.put_help:
	move.l	#"help",(a4)+
	bra.s	.ok
.put_undo:
	move.l	#"undo",(a4)+
	bra.s	.ok
.put_ins:
	move.w	#"in",(a4)+
	move.b	#'s',(a4)+
	bra.s	.ok
.put_clr:
	move.w	#"cl",(a4)+
	move.b	#'r',(a4)+
	bra.s	.ok
.put_up:
	move.w	#"up",(a4)+
	bra.s	.ok
.put_down:
	move.l	#"down",(a4)+
	bra.s	.ok
.put_right:
	move.l	#"righ",(a4)+
	move.b	#'t',(a4)+
	bra.s	.ok
.put_left:
	move.l	#"left",(a4)+
	bra.s	.ok
.put_tab:
	move.w	#"ta",(a4)+
	move.b	#'b',(a4)+
	bra.s	.ok
.put_esc:
	move.w	#"es",(a4)+
	move.b	#'c',(a4)+
	bra.s	.ok
.put_fnb:
	move.b	#'F',(a4)+
	cmp.b	#$44,d5
	bne.s	.not_f10
	move.b	#'1',(a4)+
	move.b	#'0',(a4)+
	bra.s	.ok
.not_f10:
	move.w	d5,d0
	sub.b	#$3b,d0
	add.b	#'1',d0
	move.b	d0,(a4)+
	bra	.ok
.put_back:
	move.l	#"back",(a4)+
	bra	.ok
.put_del:
	move.w	#"de",(a4)+
	move.b	#'l',(a4)+
	bra	.ok
.put_cr:
	move.w	#"cr",(a4)+
	bra	.ok
.put_enter:
	move.l	#"ente",(a4)+
	move.b	#'r',(a4)+
	bra	.ok
	; #] scan_to_text:
	; #[ Play mac: joue la macro en memoire
;-- Internal --
;a5=macro @
;d6=current record macro size
;d7=total mac size
play_mac:
	movem.l	d6-d7/a5,-(sp)
	move.l	cur_rec_mac_size(a6),d7
	beq.s	.memory_error
	bmi.s	.memory_error

	st	play_mac_flag(a6)
	; print playing
	lea	mac_play_text,a2
	bsr	print_result
	;redraw window 1 (show play)
	moveq	#0,d0
	bsr	redraw_inside_window
	bsr	print_next_mac
.more_macro:
	;tester shift shift
	bsr	test_shift_shift
	bne.s	.macro_stopped

	;analyser
	move.l	cur_play_mac_addr(a6),d0
	beq.s	.memory_error
	move.l	d0,a5

	;encore ?
	tst.b	(a5)
	beq.s	.end

	move.l	cur_rec_mac_addr(a6),d1
	cmp.l	a5,d1
	ble.s	.end

	;taille
	move.l	a5,a0
	bsr	pskip
	move.l	a0,a5
	move.l	d0,d6

	move.l	a5,a0
	move.b	(a0),d0

	cmp.b	#'ø',d0
	beq.s	.go
	cmp.b	#'`',d0
	beq.s	.go
	cmp.b	#';',d0
	bne.s	.no_comment
	move.l	a0,a1
	moveq	#1,d0
	_JSR	down_line_ascii
	move.l	a1,cur_play_mac_addr(a6)
	bra.s	.more_macro
.no_comment:
.go:
	bsr.s	_play_mac
	bmi.s	.macro_ended
.encore:
	;step by step ?
	tst.b	trace_mac_flag(a6)
	bne.s	.end
	bra.s	.more_macro
.macro_stopped:
	lea	mac_play_stopped_text,a2
	bsr	print_result
	bra.s	.end
.memory_error:
	sf	force_mac_flag(a6)
	lea	mac_memory_error_text,a2
	bsr	print_press_key
.end:
	sf	play_mac_flag(a6)
	moveq	#0,d0
	bsr	redraw_inside_window
	moveq	#0,d0
.phys_end:
	movem.l	(sp)+,d6-d7/a5
	rts
.macro_ended:
	sf	play_mac_flag(a6)
	moveq	#-1,d0
	bra.s	.phys_end
;-- Input --
;a0=@ macro a executer
;-- Output --
;d0:
;-1:stop
;0:cont
_play_mac:
	movem.l	d1-a5,-(sp)
	move.l	a0,a5
	move.l	a0,a4
	bsr	print_next_mac
.examine:
	cmp.l	end_rec_mac_addr(a6),a5
	bge	.macro_ended
	move.b	(a5)+,d0
	beq	.macro_ended
	cmp.b	#';',d0
	beq.s	.skip_till_eol
	cmp.b	#'ø',d0
	beq.s	.preproc
	cmp.b	#13,d0
	beq.s	.macro_ended
	cmp.b	#10,d0
	beq.s	.macro_ended
	cmp.b	#'?',d0
	beq.s	.skip_one_group
	cmp.b	#'`',d0
	bne.s	.missing_back
	move.l	a5,a0
	bsr	text_to_scan
;	tst.l	d1
;	bmi.s	.fnf_error
	addq.l	#1,d1
	add.l	d1,d6
	add.l	d6,cur_play_mac_addr(a6)
	;ds d0 le scan
	bsr	treat_instruction
	bmi.s	.fnf_error
.test_end:
	tst.b	play_mac_flag(a6)
	beq.s	.macro_ended
	bra.s	.good
.skip_till_eol:
	move.l	a5,a0
	moveq	#1,d0
	_JSR	down_line_ascii
	move.l	a0,a5
	bra.s	.examine
.skip_one_group:
	move.l	a5,a0
	bsr	pskip
	move.l	a0,a5
	bra.s	.examine
.preproc:
	bsr	preproc_mac
	move.l	a0,a5
	beq.s	.test_end
	lea	preproc_error_text,a2
	bra.s	.error
.missing_back:
	lea	missing_back_text,a2
	bra.s	.error
.fnf_error:
	lea	fnf_mac_error_text,a2
.error:
	sf	force_mac_flag(a6)
	bsr	print_error
	tst.b	play_mac_flag(a6)
	bne.s	.good
	move.l	a4,a0
	bsr	edit_mac
.macro_ended:
	moveq	#-1,d0
	bra.s	.end
.good:
	moveq	#0,d0
.end:
	movem.l	(sp)+,d1-a5
	rts

;affiche la prochaine mac en print_message (dans w1)
print_next_mac:
	move.l	a2,-(sp)
	move.l	cur_play_mac_addr(a6),a0
	;scanner la prochaine fonction
.l1:
	move.b	(a0)+,d0
	beq.s	.print
	cmp.b	#'`',d0
	beq.s	.print
	cmp.b	#';',d0
	beq.s	.print
	cmp.b	#'ø',d0
	bne.s	.l1
.print:
	tst.b	-(a0)
	lea	my_line(a6),a2
	move.l	a2,a1
	moveq	#19-1,d1
.l2:
	move.b	(a0)+,d0
	beq.s	.no_more
	cmp.b	#10,d0
	beq.s	.no_more
	cmp.b	#13,d0
	beq.s	.no_more
;	cmp.b	#9,d0
;	bne.s	.not_tab
;	moveq	#' ',d0
;.not_tab:
	move.b	d0,(a1)+
	dbf	d1,.l2
.no_more:
	clr.b	(a1)
	bsr	print_message
	move.l	(sp)+,a2
	rts

;-- Output --
;a0=new ptr
preproc_mac:
	movem.l	a1-a2/a5,-(sp)
	move.l	cur_play_mac_addr(a6),a0
	bsr	pskip
	move.l	a0,a5
	cmp.b	#'ø',(a5)+
	bne	.error
.more_opt:
	move.b	(a5)+,d0
	beq	.error
	lea	mac_sep_table(pc),a1
.l0:
	move.b	(a1)+,d1
	bmi.s	.preproc
	cmp.b	d0,d1
	beq.s	.no_more_opt
	bra.s	.l0
.preproc:
	lea	mac_preproc_table(pc),a1
.l1:
	move.b	(a1)+,d1
	beq	.error
	cmp.b	d0,d1
	bne.s	.l1
	;traiter f F t T p s r * c b
	cmp.b	#'t',d0
	beq.s	.trace_on
	cmp.b	#'T',d0
	beq.s	.trace_off
	cmp.b	#'f',d0
	beq.s	.force_on
	cmp.b	#'F',d0
	beq.s	.force_off
	cmp.b	#'s',d0
	beq.s	.mac_stopped
	cmp.b	#'r',d0
	beq.s	.mac_to_record
;	cmp.b	#'*',d0
;	beq.s	.repeat
	cmp.b	#'p',d0
	beq.s	.pause
	cmp.b	#'c',d0
	beq.s	.comment_play
	cmp.b	#'b',d0
	beq.s	.test_if_branch
	cmp.b	#'l',d0
	beq.s	.flush
	bra	.error
.no_more_opt:
	move.l	a5,a0
	bsr	pskip
	move.l	a0,a5
	moveq	#0,d0
	bra	.end
.trace_on:
	st	trace_mac_flag(a6)
	bra.s	.remore_opt
.trace_off:
	sf	trace_mac_flag(a6)
	bra.s	.remore_opt
.force_on:
	st	force_mac_flag(a6)
	bra.s	.remore_opt
.force_off:
	sf	force_mac_flag(a6)
	bra.s	.remore_opt
;.repeat:
;	bra.s	.remore_opt
.mac_to_record:
	st	rec_mac_flag(a6)
.mac_stopped:
	sf	play_mac_flag(a6)
	bra.s	.flush
.remore_opt:
	bra	.more_opt
.comment_play:
	move.l	a5,a0
	lea	line_buffer(a6),a2
	bsr	copy_next_mac_expression
	move.l	a0,a5
	bsr	print_error
.flush:
	move.l	a5,a0
	bsr	pskip
	bsr	pflush
	move.l	a0,a5
	bra.s	.no_more_opt
.pause:
	bsr	get_char
	cmp.b	#$1b,d0
	sne	play_mac_flag(a6)
	beq.s	.flush
	bra.s	.remore_opt
.test_if_branch:
	move.l	a5,a0
	bsr	pskip
	move.l	a0,a5
	lea	line_buffer(a6),a2
	bsr.s	copy_next_mac_expression
	bsr	pflush
	move.l	a0,a5
	move.l	a2,a0
	bsr	evaluate
	tst.l	d1
	bmi.s	.error
	cmp.l	#-1,d0
	bne.s	.skip_label
	move.l	a5,a0
	lea	line_buffer(a6),a2
	bsr.s	copy_next_mac_expression
	bsr	pflush
	move.w	#LMWORD,d0
	moveq	#-1,d1
	moveq	#0,d2
	bsr	find_in_table
	bmi.s	.error
	cmp.w	#LMWORD,d0
	bne.s	.error
	move.l	d1,a5
	bra	.no_more_opt
.skip_label:
	move.l	a5,a0
	bsr.s	lookahead_next_mac_expression
	lea	1(a5,d0.w),a5
	bra	.no_more_opt
.error:
	moveq	#-1,d0
.end:
	move.l	a5,cur_play_mac_addr(a6)
	move.l	a5,a0
	movem.l	(sp)+,a1-a2/a5
	tst.l	d0
	rts

;-- In --
;ds a2 l'@ du buffer
;ds a0 l'@ courante de la macro en play
;-- Out --
;a2 non touche
;ds a0 la nouvelle @ courante de la macro en play (AVANT L'EXPRESSION!!)
copy_next_mac_expression:
	bsr	pskip
	move.l	a0,-(sp)
	bsr.s	lookahead_next_mac_expression
	move.l	a2,a1
	beq.s	.end
	subq.w	#1,d0
.l1:
	move.b	(a0)+,(a1)+
	dbf	d0,.l1
.end:
	clr.b	(a1)
	move.l	(sp)+,a0
	rts

;-- In --
;a0=ptr sur mac courant
;-- Out --
;d0=taille du texte a passer
lookahead_next_mac_expression: ;passe par dessus ' ',9,13,10,;
	move.l	a0,-(sp)
	bsr	pskip
	move.l	a0,d0
.l2:
	move.b	(a0)+,d1
	lea	mac_sep_table(pc),a1
.l1:
	move.b	(a1)+,d2
	bmi.s	.l2
	cmp.b	d1,d2
	bne.s	.l1
.end:
	exg.l	a0,d0
	sub.l	a0,d0
	subq.w	#1,d0
	move.l	(sp)+,a0
	rts
	; #] Play mac:
	; #[ text_to_scan:
;In:a0=@ de la chaine a transformer EN SCAN DE FONCTION! (1 word)
;Out:d0=scan,d1=size
;d4=long a evaluer
;d5=scancode
;d6=shift mode
;a4=ptr sur chaine
;a5=my line
text_to_scan:
	movem.l	d3-d7/a4-a5,-(sp)
	moveq	#0,d6
	moveq	#0,d5
	moveq	#0,d3
	;recopier ds mon buffer
	lea	sprintf_line(a6),a5
	move.l	a5,a4
	move.l	a5,a1
.l1:
	move.b	(a0)+,d0
	beq.s	.pass1
	cmp.b	#' ',d0
	beq.s	.pass1
	cmp.b	#13,d0
	beq.s	.l1
	cmp.b	#10,d0
	beq.s	.pass1
	move.b	d0,(a1)+
	bra.s	.l1
.pass1:
	clr.b	(a1)
	;tester sft ctl alt
	move.l	(a4),d4
	andi.l	#$dfdfdfdf,d4
	cmp.l	#'SFT_',d4
	bne.s	.not_sft
	bset	#0,d6
	addq.w	#4,a4
	move.l	(a4),d4
	andi.l	#$dfdfdfdf,d4
.not_sft:
	cmp.l	#'CTL_',d4
	bne.s	.not_ctl
	bset	#2,d6
	addq.w	#4,a4
	move.l	(a4),d4
	andi.l	#$dfdfdfdf,d4
.not_ctl:
	cmp.l	#'ALT_',d4
	bne.s	.not_alt
	bset	#3,d6
	addq.w	#4,a4
	move.l	(a4),d4
	andi.l	#$dfdfdfdf,d4
.not_alt:
;.pass2:
	;tester touche spe
	;tester 5 lettres:
	cmp.l	#"RIGH",d4
	beq	.put_right
	cmp.l	#"ENTE",d4
	beq	.put_enter

	;tester 4 lettres:
	cmp.l	#"HELP",d4
	beq	.put_help
	cmp.l	#"UNDO",d4
	beq	.put_undo
	cmp.l	#"DOWN",d4
	beq	.put_down
	cmp.l	#"LEFT",d4
	beq	.put_left
	cmp.l	#"BACK",d4
	beq	.put_back

	;tester 3 lettres:
	lsr.l	#8,d4
	cmp.l	#"INS",d4
	beq	.put_ins
	cmp.l	#"CLR",d4
	beq	.put_clr
	cmp.l	#"TAB",d4
	beq	.put_tab
	cmp.l	#"ESC",d4
	beq	.put_esc
	cmp.l	#"DEL",d4
	beq.s	.put_del

	;tester 2 lettres
	lsr.l	#8,d4
	cmp.w	#"UP",d4
	beq.s	.put_up
	cmp.w	#"CR",d4
	beq.s	.put_cr
.pass3:
	;tester si lettre
	move.b	(a4),d4
;	cmp.b	#$20,d4
;	blt.s	.syntax_error
	cmp.b	#'A',d4
	blt.s	.not_upper
	cmp.b	#'Z',d4
	bgt.s	.not_upper
	;repasser en minuscule
	bset	#5,d4
.not_upper:
	move.b	d4,d0
	move.b	d4,d3
	bsr	ascii_to_scan
	move.b	d0,d5
.ok:
	move.l	a5,a0
	bsr	strlen2
	move.l	d0,d1

	;d0=d6|d5||d3
	swap	d5
	move.l	d5,d0
	lsl.w	#8,d6
	swap	d6
	or.l	d6,d0
	move.b	d3,d0
.end:
	movem.l	(sp)+,d3-d7/a4-a5
	rts
;.syntax_error:
;	moveq	#-1,d1
;	bra.s	.end
	;pave intermediaire:
.put_help:
	moveq	#$62,d5
	bra.s	.ok
.put_undo:
	moveq	#$61,d5
	bra.s	.ok
.put_down:
	moveq	#$50,d5
	bra.s	.ok
.put_left:
	moveq	#$4b,d5
	bra.s	.ok
.put_up:
	moveq	#$48,d5
	bra.s	.ok
.put_right:
	moveq	#$4D,d5
	bra.s	.ok
.put_ins:
	moveq	#$52,d5
	bra.s	.ok
.put_clr:
	moveq	#$47,d5
	bra.s	.ok
.put_back:
	moveq	#$E,d5
	moveq	#8,d3
	bra.s	.ok
.put_del:
	moveq	#$53,d5
	moveq	#$7f,d3
	bra.s	.ok
.put_tab:
	moveq	#$F,d5
	moveq	#9,d3
	bra.s	.ok
.put_esc:
	moveq	#1,d5
	moveq	#$1b,d3
	bra.s	.ok
.put_cr:
	moveq	#$1C,d5
	bra.s	.return
.put_enter:
	moveq	#$72,d5
.return:
	moveq	#13,d3
	bra.s	.ok

	; #] text_to_scan:
	; #[ pskip:
;skip ' ',9,13,10
;--- IN ---
;a0=@ texte a skipper
;--- OUT ---
;a0=@ texte skippe
;d0=taille
pskip:
	movem.l	d1-d2/a1,-(sp)
	moveq	#0,d1
.l1:
	addq.l	#1,d1
	move.b	(a0)+,d0
	beq.s	.sub_1
	lea	pproc_term_table(pc),a1
.l2:
	move.b	(a1)+,d2
	bmi.s	.sub_1
	cmp.b	d2,d0
	beq.s	.l1
	bra.s	.l2
.sub_1:
	subq.l	#1,d1
	subq.w	#1,a0
.end:
	move.l	d1,d0
	movem.l	(sp)+,d1-d2/a1
	rts
	; #] pskip:
	; #[ pflush:
;flush tout sauf ' ',9,13,10
;a0
pflush:
	movem.l	d1-d2/a1,-(sp)
	moveq	#0,d1
.l1:
	addq.l	#1,d1
	move.b	(a0)+,d0
	beq.s	.sub_1
	lea	pproc_term_table(pc),a1
.l2:
	move.b	(a1)+,d2
	bmi.s	.l1
	cmp.b	d2,d0
	bne.s	.l2
.sub_1:
	subq.l	#1,d1
	subq.w	#1,a0
.end:
	move.l	d1,d0
	movem.l	(sp)+,d1-d2/a1
	rts
	; #] pflush:
	; #[ paflush:
;flush tout en arriere sauf ' ',9,13,10
paflush:
	movem.l	d1-d2/a1,-(sp)
	moveq	#0,d1
.l1:
	addq.l	#1,d1
	move.b	-(a0),d0
	beq.s	.add_1
	lea	pproc_term_table(pc),a1
.l2:
	move.b	(a1)+,d2
	bmi.s	.l1
	cmp.b	d2,d0
	bne.s	.l2
.add_1:
	subq.l	#1,d1
	addq.w	#1,a0
.end:
	move.l	d1,d0
	movem.l	(sp)+,d1-d2/a1
	rts
	; #] paflush:
	; #[ paskip:
;skip ' ',9,13,10 en arriere
;--- IN ---
;a0=@ texte a skipper
;--- OUT ---
;a0=@ texte skippe
;d0=taille
paskip:
	movem.l	d1-d2/a1,-(sp)
	moveq	#0,d1
.l1:
	addq.l	#1,d1
	move.b	-(a0),d0
	beq.s	.add_1
	lea	pproc_term_table(pc),a1
.l2:
	move.b	(a1)+,d2
	bmi.s	.add_1
	cmp.b	d2,d0
	beq.s	.l1
	bra.s	.l2
.add_1:
	subq.l	#1,d1
	addq.w	#1,a0
.end:
	move.l	d1,d0
	movem.l	(sp)+,d1-d2/a1
	rts
	; #] paskip:
	; #[ Load mac:
load_mac:
	bsr.s	_load_mac
	bra	get_char

_load_mac:
	IFEQ	bridos
.again:
	suba.l	a0,a0
	lea	ask_load_mac_text(pc),a2
	st	no_eval_flag(a6)
	bsr	get_expression
	bmi.s	.abort
	beq.s	.ok
	bsr	flash
	bra.s	.again
.ok:
	bsr.s	__load_mac
	bra.s	.end
.abort:
	moveq	#-1,d0
.end:
	ENDC	;de bridos
	rts

;-- In --
;a0 = nom de la macro
;-- Out --
;d0 = reussite
__load_mac:
	movem.l	a2/a4-a5,-(sp)
	move.l	a0,a5
	moveq	#0,d0
	bsr	find_file
	bne.s	.abort

	move.l	mac_size(a6),d0
	beq.s	.abort
	sub.l	cur_rec_mac_size(a6),d0
	move.l	my_dta+DTA_SIZE(a6),d1
	cmp.l	d0,d1
	bgt.s	.abort

	move.l	a5,a0
	move.l	cur_rec_mac_addr(a6),a4
	move.l	a4,a1
	moveq	#-1,d0
	moveq	#-1,d1
	moveq	#-1,d2
	bsr	load_file
	bmi.s	.abort
	beq.s	.abort
	add.l	d0,cur_rec_mac_size(a6)
	add.l	d0,cur_rec_mac_addr(a6)
	;traitement des labels:
	move.l	d0,a0
	move.l	a4,a1
	add.l	d0,a1
	move.l	a4,a2
	bsr.s	store_mac_labels
	moveq	#0,d0
	bra.s	.end
.abort:
	moveq	#-1,d0
.end:
	movem.l	(sp)+,a2/a4-a5
	rts
	; #] Load mac:
	; #[ Store mac labels:
;ds a0 l'@ d'ou scanner
store_mac_labels:
	;scanner car par car:
	;si ';' skipper jusqu'a fin de ligne
	;si : ranger dans la table des vars
	movem.l	d7/a3-a4,-(sp)
	move.l	a1,a3
	move.l	a2,a4
	move.w	#LMWORD,d7
.more_label:
	cmp.l	a3,a4
	bge.s	.end
	move.b	(a4)+,d0
	beq.s	.end
	cmp.b	#';',d0
	beq.s	.comment
	cmp.b	#'ø',d0
	bne.s	.more_label
	cmp.b	#'l',(a4)+
	bne.s	.more_label
.l1:
	lea	line_buffer(a6),a2
	move.l	a4,a0
	bsr	copy_next_mac_expression
;a0=@ chaine variable a creer
;a1=premier pointeur
	bsr	pflush
	bsr	pskip
	move.l	a0,a1
	move.l	a2,a0
	move.w	d7,d0
	bsr	put_in_table
	move.l	a4,a0
	bsr	pskip
	move.l	a0,a4
	bra.s	.more_label
.more_line:
	move.l	a0,a4
	bra.s	.more_label
.comment:
	move.l	a4,a1
	moveq	#1,d0
	_JSR	down_line_ascii
	move.l	a1,a4
	bra.s	.more_label
.end:
	movem.l	(sp)+,d7/a3-a4
	rts
	; #] Store mac labels:
	; #[ Edit mac:
;a0=@ de debut d'edition
;a5
edit_mac:
	tst.l	cur_rec_mac_size(a6)
	beq.s	.end
	move.l	a0,page_edit_mac_addr(a6)
	lea	edit_mac_form_table(pc),a0
	bra	form_do2
;	clr.w	x_pos(a6)
;	bra	clr_c_line
.end:
	_JMP	flash

edit_mac_form_table:
	dc.l	draw_edit_mac_form-edit_mac_form_table
	dc.l	line_up_edit_mac-edit_mac_form_table
	dc.l	line_down_edit_mac-edit_mac_form_table
	dc.l	page_up_edit_mac-edit_mac_form_table
	dc.l	page_down_edit_mac-edit_mac_form_table
	dc.l	home_edit_mac-edit_mac_form_table
	dc.l	shift_home_edit_mac-edit_mac_form_table
	dc.l	init_edit_mac-edit_mac_form_table
	dc.l	macro_title_text-edit_mac_form_table

draw_edit_mac_form:
;	bsr	test_begin_edit_mac
;	bmi	dont_redraw_edit_mac
;	bsr	test_end_edit_mac
;	bmi	dont_redraw_edit_mac
	moveq	#0,d0
	lea	w6_db(a6),a0
	move.l	page_edit_mac_addr(a6),a1
	move.l	mac_addr(a6),a2
	add.l	cur_rec_mac_size(a6),a2
	move.l	a2,-(sp)
	bsr	print_ascii
	move.l	(sp)+,a1
	cmp.l	a1,a0
	bge	_dont_redraw_edit_mac
	bra.s	_redraw_edit_mac
line_up_edit_mac:
	bsr.s	test_begin_edit_mac
	bmi.s	dont_redraw_edit_mac
	move.l	page_edit_mac_addr(a6),a1
	_JSR	up_line_ascii
	move.l	a1,a0
	bra.s	redraw_edit_mac
line_down_edit_mac:
	bsr.s	test_end_edit_mac
	bmi.s	dont_redraw_edit_mac
	lea	mac_eol_table,a0
	move.l	page_edit_mac_addr(a6),a1
	moveq	#1,d0
	_JSR	_down_line_ascii
	move.l	a1,a0
	bra.s	redraw_edit_mac
test_begin_edit_mac:
	move.l	page_edit_mac_addr(a6),d0
	cmp.l	mac_addr(a6),d0
	ble.s	_dont_redraw_edit_mac
	bra.s	_redraw_edit_mac

test_end_edit_mac:
	move.l	page_edit_mac_addr(a6),d0
	move.l	mac_addr(a6),d1
	add.l	cur_rec_mac_size(a6),d1
	sub.l	line_len_max(a6),d1
	cmp.l	d1,d0
	bge.s	_dont_redraw_edit_mac
	bra.s	_redraw_edit_mac

page_up_edit_mac:
	bsr.s	test_begin_edit_mac
	bmi.s	dont_redraw_edit_mac
	lea	w6_db(a6),a0
	move.l	page_edit_mac_addr(a6),a1
	move.w	6(a0),d3
	;moins les 2 lignes du cadre
	subq.w	#2,d3
.l1:
	move.l	a1,page_edit_mac_addr(a6)
	bsr.s	test_begin_edit_mac
	bmi.s	.end
	_JSR	up_line_ascii
	dbf	d3,.l1
.end:
	move.l	a1,a0
	;bra.s	redraw_edit_mac
redraw_edit_mac:
	move.l	a0,page_edit_mac_addr(a6)
_redraw_edit_mac:
	moveq	#0,d0
	rts
dont_redraw_edit_mac:
	_JSR	flash
_dont_redraw_edit_mac:
	moveq	#-1,d0
	rts

page_down_edit_mac:
	bsr.s	test_end_edit_mac
	;a cause du save sur disk
;	bmi.s	dont_redraw_edit_mac
	bmi.s	_dont_redraw_edit_mac
	lea	w6_db(a6),a0
	move.l	page_edit_mac_addr(a6),a1
	move.w	6(a0),d3
	;moins les 2 lignes du cadre
	subq.w	#2,d3
.l1:
	move.l	a1,page_edit_mac_addr(a6)
	bsr.s	test_end_edit_mac
	bmi.s	.end
	moveq	#1,d0
	lea	mac_eol_table,a0
	_JSR	_down_line_ascii
	dbf	d3,.l1
	bra.s	.not_end
.end:
	_JSR	up_line_ascii
.not_end:
	move.l	a1,a0
	bra.s	redraw_edit_mac

home_edit_mac:
	tst.b	play_flag(a6)
	bne.s	.play
	tst.b	rec_flag(a6)
	beq.s	.not_play_nor_record
	move.l	cur_rec_mac_addr(a6),a0
	bra.s	redraw_edit_mac
.play:
	move.l	cur_play_mac_addr(a6),a0
	bra.s	redraw_edit_mac
.not_play_nor_record:
	move.l	mac_addr(a6),a0
	bra.s	redraw_edit_mac

shift_home_edit_mac:
	tst.b	play_flag(a6)
	bne.s	.play
	move.l	cur_rec_mac_addr(a6),a1
	bra.s	.redraw
.play:
	move.l	cur_play_mac_addr(a6),a1
.redraw:
	lea	w6_db(a6),a0
	_JSR	up_line_ascii
	move.l	a1,a0
	bra	redraw_edit_mac

init_edit_mac:
	rts

	; #] Edit mac:
;  #] Mac stuff:
sprintf3:	bra	sprintf2
strclr3:	bra	strclr2
strcpy3:	bra	strcpy2
strlen3:	bra	strlen2
strcat3:	bra	strcat2
init_buffer3:	bra	init_buffer2

treat_instruction2:	bra	treat_instruction
;  #[ print_question:
;-- Input --
;ds a0 la chaine de format: "%bc%s?"="> Alors?"
;ds a2 la string
;-- Output --
;ds a0 la nouvelle chaine
print_question:
	move.l	a2,-(sp)
	move.l	a2,-(sp)
	move.w	#3,-(sp)
	move.l	a0,-(sp)
	lea	printm_buffer(a6),a2
	move.l	a2,a0
	bsr	sprintf2
	lea	10(sp),sp
	bsr	print_a2
	move.l	a2,a0
	move.l	(sp)+,a2
	rts
;  #] print_question:
;  #[ print_result:" %s."
;-- Input --
;ds a2 la string
;-- Output --
;ds a0 la nouvelle chaine
print_result:
	move.l	a2,-(sp)

	move.l	a2,-(sp)
	pea	print_result_format_text(pc)
	lea	printm_buffer(a6),a2
	move.l	a2,a0
	bsr	sprintf2
	addq.w	#8,sp
	bsr	print_a2
	move.l	a2,a0
	move.l	(sp)+,a2
	rts
;  #] print_result:
;  #[ print_press_key:" %s. Press a key"
;-- Input --
;ds a2 la string
;-- Output --
;ds a0 la nouvelle chaine
print_press_key:
	tst.b	play_mac_flag(a6)	;si macro play y'a deja yes/no
	bne.s	print_error
	bsr	sbase1_sbase0
	move.l	a2,-(sp)
	pea	press_key_text
	move.l	a2,-(sp)
	pea	two_strings_format(pc)
	lea	print_presskey_buffer(a6),a2
	move.l	a2,a0
	bsr	sprintf2
	lea	12(sp),sp
	bsr.s	print_error
	move.l	a0,-(sp)
	bsr	get_char
	move.l	(sp)+,a0
	move.l	(sp)+,a2
	rts
;  #] print_press_key:
;  #[ print_error:" %s ."+flash
;-- Input --
;ds a2 la string
;-- Output --
;ds a0 la nouvelle chaine
;remember to push string
print_error:
	move.l	a2,-(sp)

	move.l	a2,-(sp)
	pea	print_result_format_text(pc)
	lea	printm_buffer(a6),a2
	move.l	a2,a0
	bsr	sprintf2
	addq.w	#8,sp

	tst.b	play_mac_flag(a6)
	bne.s	.play
.print:
	;push new string
	move.l	a2,-(sp)
	bsr	print_a2
	bsr	flash
	bra.s	.no_play
.play:
	tst.b	force_mac_flag(a6)
	bne.s	.print
	pea	continue_text(pc)
	move.l	a2,-(sp)
	pea	two_strings_format(pc)
	lea	printerror_buffer(a6),a2
	move.l	a2,a0
	bsr	sprintf2
	lea	12(sp),sp
	sf	play_mac_flag(a6)
	;push new string
	move.l	a2,-(sp)
.again:
	bsr	flash
	suba.l	a0,a0
	bsr	yesno
	beq.s	.again
	subq.w	#1,d0
	beq.s	.continue
	subq.w	#1,d0
	bne.s	.again
	bra.s	.no_play
.continue:
	st	play_mac_flag(a6)
.no_play:
	;pop new string
	move.l	(sp)+,a0
	move.l	(sp)+,a2
	rts
;  #] print_error:
;  #[ print_center:
;a0=@ du texte a afficher centre
print_center:
	move.l	a2,-(sp)
	move.l	a0,a2
	move.w	x_pos(a6),-(sp)
	bsr	strlen2
	move.w	line_len(a6),d1
	sub.w	d0,d1
	lsr.w	#1,d1
	move.w	d1,x_pos(a6)
;	st	alt_e_flag(a6)
	bsr	print_instruction
;	sf	alt_e_flag(a6)
	addq.w	#1,y_pos(a6)
	move.w	(sp)+,x_pos(a6)
	move.l	(sp)+,a2
	rts
;  #] print_center:
	IFNE	debug
;  #[ print_debug: ne sert que pour afficher en sauvant tous les registres
;dans la pile la chaine a afficher
print_debug:
	link	a2,#0
	movem.l	d0-a5,-(sp)
	bsr	redraw_relock_all
	bsr	sbase1_sbase0
	move.l	8(a2),a2
	bsr	print_press_key
	movem.l	(sp)+,d0-a5
	unlk	a2
	rts
;  #] print_debug:
	ENDC
;  #[ Get expression:
;--- IN ---
;a0 = texte a afficher en second (si besoin,sinon 0)
;a2 = texte a afficher en premier

;d7=x pos de la chaine editee
;d6=lg courante de la chaine editee
;d5=d6+d7
;d4=resultat de l'evaluation

;a4=ptr sur texte au depart
;a3=ptr sur get_expression_buffer
;a2=ptr courant sur ligne

;--- OUT ---
;d0=evaluation(s'il y a lieu)
;d1=
;Esc:-1
;Good eval:0
;Empty line:1
;a0=@ de la chaine chopee
get_expression:
	movem.l	d5-d7/a3-a5,-(sp)
	move.l	a0,a4

	move.l	cur_history_addr(a6),trans_history_addr(a6)

	st	c_line(a6)
	lea	x_pos(a6),a0
	clr.w	(a0)+
	move.w	column_len(a6),(a0)

	lea	get_expression_format_text(pc),a0
	bsr	print_question

	;longueur du texte qui vient d'etre ecrit
	_JSR	strlen2
	move.l	d0,d7

	lea	get_expression_buffer(a6),a3
	move.l	a3,a2
	move.l	a4,d0
	bne.s	.no_clear
	move.l	a3,a0
	_JSR	init_buffer2
.no_clear:
	tst.b	play_mac_flag(a6)		;--- MACRO PLAY ---
	beq.s	.no_play
	bsr	copy_next_mac_eval		;a2=buffer @
	move.l	d1,d6
	tst.l	d0
	bgt.s	.no_play
	;bmi.s	.syntax_error
	move.w	d7,x_pos(a6)
	bsr	print_instruction
	add.l	d6,a2
	bra.s	.eval
.no_play:
	;recopier a4 en a2
	;nb de caracteres deja affiches
	moveq	#0,d6
	move.l	a4,d0
	beq.s	.next_line
	move.l	a4,a1
.l21:
	move.b	(a1)+,(a2)+
	beq.s	.out21
	addq.w	#1,d6
	bra.s	.l21
.out21:
	subq.w	#1,a2
.next_line:
	move.w	d7,d0
	move.w	d6,d1
	move.l	a2,a0
	move.l	a3,a1
	move.l	a4,a2
	move.w	line_len(a6),d1
	subq.w	#1,d1
	bsr	edit_ascii_line
	move.w	d1,d6
	move.l	a2,a4
	move.l	a1,a3
	move.l	a0,a2
	tst.w	d0
	bmi	.esc
	beq.s	.cr
	subq.w	#1,d0
	beq.s	.enter
	subq.w	#1,d0
	beq.s	.fleche_haut
	subq.w	#1,d0
	bne.s	.repeat
;.fleche_bas:
	;descendre ds l'history
	move.l	a3,a0
	bsr	put_next_history
	bmi.s	.repeat
	move.l	a0,a2
	move.w	d0,d6
	bra.s	.next_line
.fleche_haut:
	;remonter ds l'history
	move.l	a3,a0
	bsr	put_last_history
	bmi.s	.repeat
	move.l	a0,a2
	move.w	d0,d6
	bra.s	.next_line
.enter:	clr.b	(a3,d6.w)
	bra.s	.eval
.cr:	clr.b	(a2)
	move.w	linex_cursor(a6),d0		;effacer le reste de la ligne
	move.w	d0,x_pos(a6)
	sub.w	d7,d0
	beq.s	.rien_tape
	move.w	d0,d6
	bsr	clr_c_line
.eval:	moveq	#0,d1			;--- EVALUATE
	tst.b	no_eval_flag(a6)
	bne.s	.no_eval
	move.l	a3,a0
	bsr	evaluate
	move.l	d0,d4
	tst.w	d1
	bge.s	.good_eval
.repeat:	bsr	flash
	bra.s	.next_line
.no_eval:	move.l	a3,d4
.good_eval:
	lea	two_spaces_text(pc),a2
	st	c_line(a6)
	lea	x_pos(a6),a0
	clr.w	(a0)+
	move.w	column_len(a6),(a0)
	bsr	print_instruction
	move.l	a3,a0			;--- RECORD MACRO ----
	bsr	recmacline
	move.l	a3,a0
	bsr	backup_history		;--- RECORD HISTORY ----
	moveq	#0,d1
	bra.s	.end
.rien_tape:
	moveq	#1,d1
	bra.s	.end
.esc:	clr.w	x_pos(a6)
	bsr	clr_c_line	;remettre l'history d'avant ?
	moveq	#-1,d1
.end:	sf	c_line(a6)
	move.l	a3,a0		;ds a0 l'@ de l'evaluation
	move.l	d4,d0		;ds d0 le resultat de l'evaluation
	movem.l	(sp)+,d5-d7/a3-a5
	sf	no_eval_flag(a6)
	tst.l	d1		;ds d1 la reussite de l'evaluation
	rts

recmacline:
	tst.b	rec_mac_flag(a6)
	beq.s	.end
	tst.l	mac_size(a6)
	beq.s	.end
	move.l	cur_rec_mac_addr(a6),d0
	beq.s	.end
	move.l	a1,-(sp)
	move.l	d0,a1
	moveq	#0,d0
.l1:	addq.w	#1,d0
	move.b	(a0)+,(a1)+
	bne.s	.l1
	move.b	#' ',-(a1)
	add.l	d0,cur_rec_mac_size(a6)
	add.l	d0,cur_rec_mac_addr(a6)
	move.l	(sp)+,a1
.end:	rts

;-- Input --
;a2=@ du buffer
;-- Output --
;d0=reussite (-1=syntax error/0=eval/1=question)
;d1=taille
copy_next_mac_eval:
	movem.l	d6/a4-a5,-(sp)
	;recopier jusqu'a un terminal
	;ds le buffer pour le zero au bout
	move.l	cur_play_mac_addr(a6),a4
	move.l	a4,a0
	bsr	pskip
	move.l	a0,a4
	move.l	a2,a5
	moveq	#0,d6
.l0:
	move.b	(a4)+,d0
	cmp.b	#'`',d0
	beq.s	.found
	cmp.b	#'ø',d0
	beq.s	.found
	cmp.b	#'?',d0
	beq.s	.question
	cmp.b	#';',d0
	bne.s	.no_comment
	move.l	a4,a1
	moveq	#1,d0
	_JSR	down_line_ascii
	move.l	a1,a4
	bra.s	.l0
.no_comment:
	move.b	d0,(a5)+
	beq.s	.question
	lea	mac_sep_table(pc),a0
.l1:	move.b	(a0)+,d1
	bmi.s	.not_found
	cmp.b	d0,d1
	beq.s	.found
	bra.s	.l1
.not_found:
	addq.w	#1,d6
	bra.s	.l0
.found:	subq.w	#1,a4
	clr.b	-1(a5)
	bsr.s	.skip
	move.l	a4,cur_play_mac_addr(a6)
	bsr	print_next_mac
	moveq	#0,d0
	bra.s	.end
.question:
	bsr.s	.skip
	move.l	a4,cur_play_mac_addr(a6)
	moveq	#1,d0
	bra.s	.end
.error:	moveq	#-1,d0
.end:	move.l	d6,d1
	movem.l	(sp)+,d6/a4-a5
	tst.l	d0
	rts
.skip:	move.b	(a4)+,d0
	beq.s	.ends
	cmp.b	#' ',d0
	beq.s	.skip
	cmp.b	#9,d0
	beq.s	.skip
	cmp.b	#13,d0
	beq.s	.skip
	cmp.b	#10,d0
	beq.s	.skip
.ends:	subq.w	#1,a4
	rts
;  #] Get expression:
;  #[ Yes/No:(0=[Esc] /1=[Y]es /2=[N]o /3=[Up] /4=[Down] [Ret]=Yes|No)
;-- Input --
;a0=ptr sur flag pour afficher et affecter direct
;a2=chaine a afficher et traiter

;-- Output --
;d0=
;0:esc
;1:yes
;2:no
;3:haut
;4:bas
yesno:
	movem.l	d7/a2-a5,-(sp)
	move.l	a0,d0
	bne.s	.no_default
	;par defaut mis a No
	lea	default_yesno_flag(a6),a5
	sf	(a5)
	bra.s	.sprintf
.no_default:
	move.l	a0,a5
.sprintf:
	lea	yesno_format_text(pc),a0
	bsr	print_question
	move.l	a0,a2
	;il faut que je trouve Y et N et que je mette en minuscule
.l1:
	move.b	(a0)+,d0
	beq.s	.out
	cmp.b	#')',(a0)
	bne.s	.l1
	bclr	#5,d0
	cmp.b	#'Y',d0
	beq.s	.yyes
	cmp.b	#'N',d0
	bne.s	.l1
.nno:
	;-1=Yes
	tst.b	(a5)
	bne.s	.minus
	bra.s	.majus
.yyes:
	;0=No
	tst.b	(a5)
	beq.s	.minus
;	bra.s	.majus
.majus:
	bclr	#5,-1(a0)
	bra.s	.l1
.minus:
	bset	#5,-1(a0)
	bra.s	.l1
.out:
	bsr	print_a2

	tst.b	play_mac_flag(a6)
	beq.s	.get_char
	move.l	cur_play_mac_addr(a6),a0
	bsr	pskip
	moveq	#0,d0
	move.b	(a0)+,d0
	sub.w	#'0',d0
	move.l	a0,cur_play_mac_addr(a6)
	bra.s	.playing
.flash:
	bsr	flash
.get_char
	bsr	get_char
	move.l	a5,a0
	bsr.s	isyesno
	bmi.s	.flash
.playing:
	move.l	d0,d7
	tst.b	rec_mac_flag(a6)
	beq.s	.no_rec
	move.l	cur_rec_mac_addr(a6),a0
	move.l	d7,d0
	add.b	#'0',d0
	move.b	d0,(a0)+
	move.b	#' ',(a0)+
	move.l	a0,cur_rec_mac_addr(a6)
	addq.l	#2,cur_rec_mac_size(a6)
.no_rec:
.end:
	move.w	x_pos(a6),-(sp)
	clr.w	x_pos(a6)
	bsr	clr_c_line
	move.w	(sp)+,x_pos(a6)
	move.l	d7,d0
	movem.l	(sp)+,d7/a2-a5
	rts

;Esc=0
;Yes=1
;No=2
;up=3
;down=4
;autre=-1
;a0=flag addr
isyesno:
	moveq	#0,d1
	cmp.b	#$1b,d0
	beq.s	.end
	cmp.b	#13,d0
	beq.s	.default
	bclr	#5,d0
	addq.w	#1,d1
	cmp.b	#'Y',d0
	beq.s	.end
	addq.w	#1,d1
	cmp.b	#'N',d0
	beq.s	.end
	addq.w	#1,d1
	swap	d0
	cmpi.w	#$0048,d0
	beq.s	.end
	addq.w	#1,d1
	cmpi.w	#$0050,d0
	beq.s	.end
	moveq	#-1,d1
.end:
	move.l	d1,d0
	rts
.default:
	;default is Yes ?
	moveq	#1,d1
	tst.b	(a0)
	bne.s	.end
	;No
	moveq	#2,d1
	bra.s	.end

;  #] Yes/No:
	IFNE	sourcedebug
	include	"srcdebug.s"
	IFNE	turbodebug
	include	"pcdebug.s"
	ENDC	;turbodebug
	ENDC	;sourcedebug
;  #[ Load file:
;--- IN ---
;a0=ptr sur nom de fichier
;a1=ptr sur @ de chargement (nul ou negatif=pas d'@)
;d0=taille a charger
;d1=offset par rapport au debut du fichier a charger
;d2=setpath_flag
;--- INTERNAL ---
;d3=taille
;d4=handle
;d6=@ de chargement
;d7 sert en fin
;a3=new dta
;a4=olddta
;a5=nom de fichier
;--- OUT ---
;a0=@ de chargement
;a1=@ nom de fichier
;d0=taille chargee
load_file:
	movem.l	d3-d7/a2-a5,-(sp)

	move.l	a0,a5
	move.l	a1,d6
	move.l	d0,d3
	move.l	d1,d5
	move.l	d2,d4

	move.l	d2,d0
	lea	my_dta(a6),a3
	lea	file_buffer(a6),a2
	move.l	a5,a0
	bsr	find_file
	bmi	.open_error
	st	ask_disk_vector_flag(a6)
	tst.l	d4				;nom fixe
	bne.s	.name_set
	lea	DTA_NAME(a3),a5
.name_set:
	move.l	DTA_SIZE(a3),d0
	tst.l	d3				;taille fixe pour le fread
	bpl.s	.size_set
	move.l	d0,d3
.size_set:
	cmp.l	d0,d3
	ble.s	.size_ok
	move.l	d0,d3
.size_ok:
	move.l	a5,a0
	bsr	open_file
	bmi.s	.open_error

	;handle	ds d4
	move.l	d0,d4

	move.l	a5,-(sp)
	pea	loading_file_text(pc)
	move.l	a2,a0
	bsr	sprintf3
	addq.w	#8,sp
	bsr	print_result

	move.l	d6,a3
	tst.l	d6
	bgt.s	.no_reserv

	move.l	d3,d0
	sf	d1
	moveq	#3,d2
	_JSR	reserve_memory
	beq.s	.memory_error
	move.l	d0,a3

.no_reserv:
	;seeker au besoin
	move.l	d5,d0
	bmi.s	.no_seek
	;d0 deja charge
	move.l	d4,d1
	moveq	#0,d2
	bsr	seek_file
	tst.l	d0
	bmi.s	.seek_error
.no_seek:
	;lire	le fichier source
	move.l	a3,a0
	move.l	d3,d0
	move.l	d4,d1
	bsr	read_file
	cmp.l	d0,d3
	bne.s	.read_error
	move.l	d0,d7
.end:	move.l	d4,d0
	bsr	close_file			;fermer	le fichier

	move.l	d7,-(sp)
	move.l	a5,-(sp)
	pea	file_loaded_text(pc)
	move.l	a2,a0
	bsr	sprintf3
	lea	12(sp),sp
	bsr	print_result
	bra.s .fin
.memory_error:
	lea	memory_error_text(pc),a2
	bra.s	.print
.open_error:
	move.l	a5,-(sp)
	pea	fnf_error_text(pc)
	move.l	a2,a0
	bsr	sprintf3
	addq.w	#8,sp
	bra.s	.print
.seek_error:
	lea	seek_error_text(pc),a0
	bra.s	.system_error
.read_error:
	lea	read_error_text(pc),a0
.system_error:
	neg.w	d0
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	move.l	a2,a0
	bsr	sprintf3
	lea	10(sp),sp
.print:
	bsr	print_error
.error:
	moveq	#-1,d7
.fin:
	sf	ask_disk_vector_flag(a6)
	move.l	d7,d0
	move.l	a5,a1
	move.l	a3,a0

	movem.l	(sp)+,d3-d7/a2-a5
	rts
;  #] Load file:
	IFEQ	bridos
;  #[ Save file:
;--- IN ---
;a0=nom de fichier
;a1=@ d'ou sauver
;d0=taille
;--- INTERNAL ---
;d3=taille
;d4=handle
;d7=@ sauvegarde
;a5=nom de fichier
save_file:
	movem.l	d3/d7/a3-a5,-(sp)
	lea	file_buffer(a6),a2
	move.l	d0,d3	;taille
	move.l	a1,d7	;@ sauvegarde
	move.l	a0,a5	;@ nom de fichier

	move.l	a5,a0
	bsr	create_file
	bmi.s	.open_error
	move.l	d0,d4	;handle	ds d4

	st	ask_disk_vector_flag(a6)
	move.l	a5,-(sp)
	pea	saving_file_text(pc)
	move.l	a2,a0
	bsr	sprintf3
	addq.w	#8,sp
	bsr	print_result

	move.l	d7,a0	;ecrire le fichier
	move.l	d3,d0
	move.l	d4,d1
	bsr	write_file
	move.l	d0,d7
	bmi.s	.close

	cmp.l	d3,d7
	beq.s	.close
	move.l	a5,-(sp)
	pea	disk_full_text(pc)
	move.l	a2,a0
	bsr	sprintf3
	addq.w	#8,sp
	bsr	print_press_key

.close:	move.l	d4,d0
	bsr	close_file

	tst.l	d7
	bmi.s	.write_error

	move.l	d3,-(sp)
	move.l	d7,-(sp)
	move.l	a5,-(sp)
	pea	file_saved_text(pc)
	move.l	a2,a0
	bsr	sprintf3
	lea	16(sp),sp
	bsr	print_result
	bra.s .fin
.memory_error:
	lea	memory_error_text(pc),a2
	bra.s	.error
.open_error:
	lea	create_error_text(pc),a2
	bra.s	.error
.write_error:
	neg.w	d7
	move.l	a5,-(sp)
	move.w	d7,-(sp)
	pea	write_error_text(pc)
	move.l	a2,a0
	bsr	sprintf3
	lea	10(sp),sp
.error:	moveq	#-1,d7
	bsr	print_error
.fin:	sf	ask_disk_vector_flag(a6)
	move.l	d7,d0
	movem.l	(sp)+,d3/d7/a3-a5
	rts
;  #] Save file:
	ENDC
;  #[ RS232_display:
;	 #[ Terminal_init:
;*******************************************************
;
;	Parametre passe dans vitesse.b :
;	0=19200 1=9600 2=4800 3=3600 4=2400 5=2000 6=1800
;	7=1200 8=600 9=300 10=200 11=150 12=134 13=110 14=75
;	15=50 bauds.
;
;	Parametre passe dans parity.b :
;	bit 0: 1
;	bit 1: 0(parite impaire), 1(parite paire)
;	bit 2: 0(parite ignoree), 1(parite validee)
;	bit 3: 1
;	bit 4: 0(1 bit de stop), 1(2 bits de stop)
;	bit 5: 0(8 bits/caractere), 1(7 bits/caractere)
;	bit 6: 0
;	bit 7: 1
;
;	Parametre passe dans minitel:
;	255: mode minitel (traitement special ligne zero)
;	0: mode vt100 / 25 lignes
;
;***************************************************************
terminal_init:
	lea	rs232_switching_text,a2
	bsr	print_result
	IFNE	AMIGA
	move.w	#25,w3len(a6)
	move.w	#24,column_len(a6)
	bsr	wind_screen_to_term
	ENDC
	move.l	#RS232_OUTPUT,device_number(a6)
	tst.b	minitel_flag(a6)
	bne.s	.lau0
	bsr	rs232_init
	bra	.laun

.lau0:	move.l	#1,rs232_speed(a6)
.lau1:	bsr	rs232_init
	moveq	#27,d0
	bsr	rs_put
	moveq	#'9',d0
	bsr	rs_put
	moveq	#'{',d0		;enquiry ROM
	bsr	rs_put
	bsr	rs_in
	bsr	rs_in
	bsr	rs_in			;ici j'ai dans D0 le type de minitel
	cmpi.w	#-1,d7			;il a repondu ?
	bne.s	.oui
	move.l	rs232_speed(a6),d0
;	cmpi.l	#1,d0
	subq.l	#1,d0
	bne.s	.1
	move.l	#2,rs232_speed(a6)
	bra.s	.lau1
.1:
;	cmpi.l	#2,d0
	subq.l	#1,d0
	bne.s	.2
	move.l	#7,rs232_speed(a6)
	bra.s	.lau1
.2:
;	cmpi.l	#7,d0
	subq.l	#5,d0
	bne.s	.non		;supposons qu'il s'agit d'un minitel a 19600
	move.l	#9,rs232_speed(a6)
	bra.s	.lau1
.non:	clr.l	rs232_speed(a6)
	bsr	rs232_init
	bra	.laun		;dans le futur, sait-on jamais..

.oui:	cmpi.b	#'v',d0		;est-ce un minitel 2 ?
	bne.s	.min1
	moveq	#27,d0
	bsr	rs_put
	bsr	waitlau
	moveq	#':',d0
	bsr	rs_put
	bsr	waitlau
	moveq	#'k',d0
	bsr	rs_put
	bsr	waitlau
	moveq	#$7f,d0		;passe le minitel a 9600 bauds
	bsr	rs_put
	bsr.s	waitlau
	move.l	#1,rs232_speed(a6)
	bsr	rs232_init
	bra.s	.ok

.min1:	moveq	#27,d0
	bsr	rs_put
	bsr.s	waitlau
	moveq	#':',d0
	bsr	rs_put
	bsr.s	waitlau
	moveq	#'k',d0
	bsr	rs_put
	bsr.s	waitlau
	moveq	#'v',d0		;passe le minitel a 4800 bauds
	bsr	rs_put
	bsr.s	waitlau
	move.l	#2,rs232_speed(a6)
	bsr	rs232_init

.ok:	moveq	#27,d0
	bsr	rs_put
	moveq	#$3a,d0
	bsr	rs_put
	moveq	#$32,d0
	bsr	rs_put
	moveq	#$7d,d0		;passe en 80 col mode mixte
	bsr	rs_put
.laun:	_JSR	draw_all_windows
	lea	output_to_rs232_text,a2
	bsr	print_result
	_JMP	sbase0_sbase1

waitlau:
	moveq	#-1,d0
.0:	dbf	d0,.0
	rts

;	 #] Terminal_init:
;	 #[ RS232_display:
terminal_display:
***********************************************************************
* positionner le flag SOULIGN a 1 avant l'appel de PRINT_CHARACTER    *
* si le caractere doit etre affiche en ligne 24.		      *
* Le caractere est passe dans D0.				      *
* Sous-programmes a integrer: clear_screen, draw_window, flash	      *
*			      print_character, poscur		      *
***********************************************************************
* Je ne teste pas alt_e_flag (impossible d'eteindre le curseur)
	movem.l	d0-d7/a0,-(sp)
	move	d0,d7
	tst.b	alt_e_flag(a6)
	beq.s	.0
	bsr	poscur
.0:
	cmp.w	#23,y_pos(a6)
	seq	soulign(a6)
	tst.b	soulign(a6)		;souligner ?
	beq.s	.1		;non
	tst.b	souflg(a6)		;oui. Deja fait ?
	bne.s	.3		;oui
	bsr	soulign_on
	bra.s	.3
.1	tst.b	souflg(a6)
	beq.s	.3
	bsr	soulign_off
.3	move	d7,d0
	*tst.b	d0		;stand-alone
	*bmi	inverted	;>=128 (except accentues) => inverse
	cmp.b	#$7f,d0
	bhi.s	inverted
	bne.s	.2
	moveq	#" ",d0
.2:
	cmpi.b	#$20,d0		;si 31<caractere<128, rs_put directos
	bpl.s	.87
	bra	affiche_controle
.87	tst.b	flginv(a6)
	beq.s	.86
	move	d0,-(sp)
	bsr	inverse_off
	move	(sp)+,d0
.86	bsr	rs_put
	movem.l	(sp)+,d0-d7/a0
	rts

inverted:
	cmpi.b	#$df,d0
	bne.s	.loc0
	moveq	#24,d1
	bra	french
.loc0	cmpi.b	#$9c,d0
	bne.s	.loc1
	moveq	#$23,d1
	bra.s	french
.loc1	cmpi.b	#$85,d0
	bne.s	.loc2
	moveq	#$40,d1
	bra.s	french
.loc2	cmpi.b	#$f8,d0
	bne.s	.loc3
	moveq	#$5b,d1
	bra.s	french
.loc3	cmpi.b	#$87,d0
	bne.s	.loc4
	moveq	#$5c,d1
	bra.s	french
.loc4	cmpi.b	#$82,d0
	bne.s	.loc5
	moveq	#$7b,d1
	bra.s	french
.loc5	cmpi.b	#$97,d0
	bne.s	.loc6
	moveq	#$7c,d1
	bra.s	french
.loc6	cmpi.b	#$8a,d0
	bne.s	invers
	moveq	#$7d,d1
	bra.s	french
invers	bclr	#7,d0
	cmp.b	#$7f,d0
	bne.s	.1
	moveq	#" ",d0
.1:
	tst.b	d0
	bne.s	.raf
	moveq	#20,d0
	bra.s	.raf2
.raf	cmpi.b	#" ",d0
	bpl.s	.95
.raf2	move.b	d0,d6
	bsr	inverse_on
	move.b	d6,d0
	bra.s	term_ctrl
.95:
	tst.b	flginv(a6)
	bne.s	.9
	move.b	d0,d6
	bsr	inverse_on
	move.b	d6,d0
.9	bsr	rs_put
	movem.l	(sp)+,d0-d7/a0
	rts
french	tst.b	flginv(a6)
	beq.s	.89
	move	d1,-(sp)
	bsr	inverse_off
	move	(sp)+,d1
.89	move.b	d1,d6
	moveq	#14,d0
	bsr	rs_put
	move.b	d6,d0
	bsr	rs_put
	moveq	#15,d0
	bsr	rs_put
	movem.l	(sp)+,d0-d7/a0
	rts

affiche_controle:
	tst.b	flginv(a6)
	beq.s	term_ctrl
	move	d0,-(sp)
	bsr	inverse_off
	move	(sp)+,d0
term_ctrl:
	and	#$ff,d0
	lea	controls,a0
	move.b	0(a0,d0.w),d0
	bsr	rs_put
	movem.l	(sp)+,d0-d7/a0
	rts

poscur:
	movem.l	d0-a6,-(sp)
	cmp.l	#RS232_OUTPUT,device_number(a6)
	bne.s	.end
	movem.w x_pos(a6),d2-d3
	addq.w	#1,d2
	addq.w	#1,d3
	tst.b	minitel_flag(a6)
	beq.s	pazero3
	subq	#1,d3
	bne.s	pazero
	moveq	#$1f,d0
	move.b	#1,flag0(a6)
	bsr	rs_put		;si zero: 1f y x
	move.b	#'@',d0		;1f @ X (avec X<64 mais c'est normal)
	bsr	rs_put
	move.b	d2,d0
	bset	#6,d0
	bsr	rs_put
.end:
	movem.l	(sp)+,d0-a6
	rts
pazero	tst.b	flag0(a6)
	beq.s	pazero3
	moveq	#10,d0
	bsr	rs_put
	clr.b	flag0(a6)
pazero3	moveq	#$1b,d0
	bsr	rs_put
	move.b	#'[',d0
	bsr	rs_put
	moveq	#0,d1
	move.b	d3,d0
	move.b	d0,d1
	divu	#10,d1
	move.b	d1,d0
	add.b	#$30,d0
	bsr	rs_put
	swap	d1
	move.b	d1,d0
	add.b	#$30,d0
	bsr	rs_put
	moveq	#';',d0
	bsr	rs_put
	moveq	#0,d1
	move.b	d2,d0
	move.b	d0,d1
	divu	#10,d1
	move.b	d1,d0
	add.b	#$30,d0
	bsr	rs_put
	swap	d1
	move.b	d1,d0
	add.b	#$30,d0
	bsr	rs_put
	moveq	#'H',d0
	bsr	rs_put
	movem.l (sp)+,d0-a6
	rts
;	 #] RS232_display:
;	 #[ Terminal_draw_window:
terminal_draw_window:		*parametres: current_window_flag, upper_x, upper_y
				*lower_x, lower_y.
	movem.l d0/d2-d4/d7,-(sp)
	move.b	flginv(a6),d2
	swap	d2
	move.b	souflg(a6),d2
	moveq	#27,d0
	bsr	rs_put
	moveq	#'7',d0
	bsr	rs_put
	bsr	soulign_off
	bsr	inverse_off
	tst.b	dont_redraw_all(a6)	;CREER UN FLAG POUR CA!
	bne	terminal_change_window	;qui fasse qu'on ne change
	move.l	upper_x(a6),x_pos(a6)	;que les traits verticaux en cas
	subq	#1,x_pos(a6)		;de changement de fenetre.
	subq	#1,y_pos(a6)
	bsr	poscur
	addq	#1,x_pos(a6)
	addq	#1,y_pos(a6)
	moveq	#$5f,d3		;caractere de trait horizontal haut_fenetre
	move	upper_y(a6),d0
	cmpi.b	#1,d0
	beq.s	.3
	moveq	#$7e,d3
	bsr	soulign_on
.3	move	lower_x(a6),d7
	sub	upper_x(a6),d7
	addq	#1,d7	;variable de boucle horizontale
haut_window:
	move.b	d3,d0
	bsr	rs_put
	dbf	d7,haut_window
	move	upper_y(a6),d0
	cmpi.b	#1,d0
	beq.s	.4
	bsr	soulign_off
.4	move	lower_x(a6),d7
	sub	upper_x(a6),d7
	addq	#1,d7
	move	lower_y(a6),y_pos(a6)
	move.w	upper_y(a6),d0
	add	d0,y_pos(a6)	*Ajoute
	subq	#1,y_pos(a6)		*
	moveq	#$7e,d4
	move	lower_y(a6),d0
	add	upper_y(a6),d0		*
	subq	#1,d0			*Ajoute
	cmpi.b	#24,d0
	bne.s	.5
	subi	#1,y_pos(a6)
	moveq	#$5f,d4
	bra.s	.55
.5	bsr	soulign_on
.55	addq	#1,y_pos(a6)
	subq	#1,x_pos(a6)
	subq	#1,y_pos(a6)
	bsr	poscur
	addq	#1,x_pos(a6)
	addq	#1,y_pos(a6)
bas_window:
	move.b	d4,d0
	bsr	rs_put
	dbf	d7,bas_window
	bsr	soulign_off
terminal_change_window:
	move.l	upper_x(a6),x_pos(a6)
	subq	#1,x_pos(a6)
	bsr	poscur
	addq	#1,x_pos(a6)
	addq	#1,y_pos(a6)
	move	lower_y(a6),d7
	add	upper_y(a6),d7
	sub	y_pos(a6),d7
	subq	#1,d7
	moveq	#'!',d3
	tst.b	current_window_flag(a6)
	beq.s	.1
	moveq	#$7c,d3
	bsr	light_on
.1	move	y_pos(a6),d4
gauche_window:
	cmpi	#24,d4
	bne.s	.p1
	bsr	soulign_on
	move.b	d3,d0
	bsr	rs_put
	bsr	soulign_off
	bra.s	.p2
.p1	move.b	d3,d0
	bsr	rs_put
.p2	moveq	#8,d0
	bsr	rs_put
	moveq	#10,d0
	bsr	rs_put
	addq	#1,d4
	dbf	d7,gauche_window
	move	lower_x(a6),x_pos(a6)
	move	upper_y(a6),y_pos(a6)
	bsr	poscur
;	addq	#1,x_pos(a6)
	addq	#1,y_pos(a6)
	move	lower_y(a6),d7
	add	upper_y(a6),d7
	sub	y_pos(a6),d7
	subq	#1,d7
	moveq	#'!',d3
	tst.b	current_window_flag(a6)
	beq.s	.11
	moveq	#$7c,d3
.11	move	y_pos(a6),d4
	move.w	y_pos(a6),-(sp)
droite_window:
	cmpi	#24,d4
	bne.s	.p3
	bsr.s	soulign_on
	move.b	d3,d0
	bsr	rs_put
	bsr.s	soulign_off
	bra.s	.p4
.p3	move.b	d3,d0
	bsr	rs_put
.p4;	addq	#1,d4
;	cmpi	#$50,x_pos(a6)
;	bne.s	.8
	bsr	poscur
	addq.w	#1,d4
	move.w	d4,y_pos(a6)
;	bra.s	.7
;.8	moveq	#8,d0
;	bsr	rs_put
;.7	moveq	#10,d0
;	bsr	rs_put
	dbf	d7,droite_window
	tst.b	current_window_flag(a6)
	beq.s	.2
	bsr.s	light_off
.2	move.b	d2,souflg(a6)
	swap	d2
	move.b	d2,flginv(a6)
	moveq	#27,d0
	bsr	rs_put
	moveq	#'8',d0
	bsr	rs_put
	move.w	(sp)+,y_pos(a6)
	movem.l (sp)+,d0/d2-d4/d7
	rts

light_on:
	moveq	#1,d5
	bra.s	attribute
light_off:
	moveq	#22,d5
	bra.s	attribute
soulign_on:
	tst.b	souflg(a6)
	bne.s	rt2
	st	souflg(a6)
	moveq	#4,d5
	bra.s	attribute
rt2	rts
soulign_off:
	tst.b	souflg(a6)
	beq.s	rt2
	sf	souflg(a6)
	moveq	#24,d5
	bra.s	attribute
inverse_on:
	tst.b	flginv(a6)
	bne.s	rt2
	st	flginv(a6)
	moveq	#7,d5
	bra.s	attribute
inverse_off:
	tst.b	flginv(a6)
	beq.s	rt2
	sf	flginv(a6)
	moveq	#27,d5

attribute:
	tst.w	y_pos(a6)
	bne.s	.1
	moveq	#10,d0
	bsr	rs_put
.1	moveq	#27,d0
	bsr	rs_put
	moveq	#'[',d0
	bsr	rs_put
	moveq	#0,d1
	move.b	d5,d1
	divu	#10,d1
	move.b	d1,d0
	add.b	#$30,d0
	bsr	rs_put
	swap	d1
	move.b	d1,d0
	add.b	#$30,d0
	bsr	rs_put
	moveq	#'m',d0
	bsr	rs_put
	tst.b	flag0(a6)
	beq.s	.2
	bsr	poscur
.2	rts
;	 #] Terminal_draw_window:
;  #] RS232_display:
;  #[ PRT_display:
	IFNE	ATARIST
init_printer_display:
 moveq #$d,d0
 bsr prt_char
 tst.w d0
 bmi.s .error
 moveq #$a,d0
 bsr prt_char
 tst.w d0
 beq.s .end
.error:
 moveq #-1,d0
.end:
 rts
	ENDC	;d'ATARIST

printer_display:
 cmp.b #" ",d0
 bge.s .1
 moveq #".",d0
.1:
 movem.l d1-a6,-(sp)
 bsr prt_char
 movem.l (sp)+,d1-a6
 tst.w d0
 bne.s .3
 rts
.3:
 clr.l device_number(a6)
 addq.w #4,sp
 movem.l (sp)+,d0-d7/a1-a4
 rts
;  #] PRT_display:
;  #[ disk_display:
disk_display:
 IFEQ	bridos
 tst.b c_line(a6)
 bne.s .1
 tst.b m_line(a6)
 bne.s .1
 lea line_buffer(a6),a2
.1:
 move.l a2,a0
 move.l d0,d1
	bsr	strlen3
 tst.w d0
 beq.s .2
 IFNE ATARIST
 move.b #$d,0(a0,d0.w)
 move.b #$a,1(a0,d0.w)
 addq.w #2,d0
 ENDC
 IFNE AMIGA
 move.b #$a,0(a0,d0.w)
 addq.w #1,d0
 ENDC
 ext.l d0
 move.l d0,-(sp)
 bsr write_file
 move.l (sp)+,d1
 cmp.l d0,d1
 beq.s .2
 clr.l device_number(a6)
.2:
 ENDC
 movem.l (sp)+,d0-d7/a1-a4
 rts
;  #] disk_display:
;	 #[ Ascii to scan:
ascii_to_scan:
	move.l	keytbl_addr(a6),a0
	move.l	(a0),a0
	moveq	#0,d1
	moveq	#127,d2
.l1:
	cmp.b	(a0,d1.w),d0
	beq.s	.out
	addq.w	#1,d1
	dbf	d2,.l1
.out:
	move.w	d1,d0
	rts

;	 #] Ascii to scan:
;  -------------- SYSTEM DEPENDENT ROUTINES ---------------
;  #[ Edit ascii line:
;--- INPUT ---
;d0=coordonnee limite a gauche en x
;d1=futur: limite a droite en x

;a0=ptr courant (a1>a0>a1+line_buffer_size)
;a1=@ du buffer de destination
;a2=ptr sur texte a afficher au depart

;--- IN ---
;d7=pos x debut de ligne
;d6=longueur maximum courante
;d5<=d6+d7<d4=pos x maximum courante
;d4=futur: y fin de ligne

;a5=@ debut du buffer destination
;a4=dernier ptr sur texte affiche
;a3=@ debut du texte affiche
;a2=ptr courant (sous le curseur) sur ligne

;--- OUTPUT ---
;d0=
;-1:esc
;0:return
;1:enter
;2:up
;3:down
;d1=nb de caracteres total (pour pouvoir revenir)

;a0=ptr courant
;a1=@ du buffer de destination
;a2=(est devenu le ptr courant) (a1>a2>a1+line_buffer_size)

edit_ascii_line:
	movem.l	d4-d7/a3-a5,-(sp)
	move.w	d1,d4

	;x debut de ligne
	move.w	d0,d7

	;au passage j'ecrase a2 pour pouvoir revenir bien
	move.l	a0,a2

	;a5=debut du buffer de stockage
	move.l	a1,a5

	;longueur totale de la chaine editee
	move.l	a5,a0
	bsr	strlen3
	move.w	d0,d6

	;a3 = ptr sur le debut de la chaine a afficher
	move.l	a2,a3
	move.w	d4,d0
	sub.w	d7,d0
	cmp.w	d6,d0
	ble.s	.lower
	move.w	d6,d0
.lower:
	sub.w	d0,a3

	;coord de fin
	bsr	edit_ascii_get_eol

	;imprimer toute la ligne
	bsr	print_all_getline

	;et clearer jusqu'a la fin de la ligne apres
	move.w	d5,x_pos(a6)
	bsr	edit_ascii_clr_line

	;vider le buffer d'undo
	clr.b	edit_ascii_undo_buffer(a6)
	move.w	d5,linex_cursor(a6)
.new_char:
	move.w	linex_cursor(a6),old_linex_cursor(a6)
	bsr	cursor_on
	bsr	edit_ascii_get_eol
	move.w	linex_cursor(a6),x_pos(a6)
	bsr	get_char
	move.l	d0,d2

	bsr	cursor_off

	move.l	d2,d1
	swap	d1

	lea	edit_ascii_keystable(pc),a0
.l1:
	move.w	(a0)+,d0
	beq.s	.not_func
	cmp.w	d0,d1
	beq.s	.call_func
;	tst.l	(a0)+
	addq.w	#2,a0
	bra.s	.l1
.not_func:
	;tri final:
	tst.b	d2
	beq.s	.flash
.insert:
	cmp.w	line_buffer_size(a6),d6
	bge.s	.flash
	;inserer = decaler la ligne de un car
	moveq	#1,d0
	lea	edit_ascii_poke_one_char,a0
	bsr	edit_ascii_insert
	bpl.s	.new_char
.flash:
	_JSR	flash
	bra.s	.new_char
.call_func:
;	move.l	(a0),a0
;	jsr	(a0)
	move.w	(a0),d0
	jsr	edit_ascii_keystable(pc,d0.w)
	cmp.w	#-2,d0
	beq.s	.new_char
	cmp.w	#-3,d0
	beq.s	.not_func
.end:
	move.w	d6,d1

	move.l	a5,a1
	move.l	a2,a0
	tst.w	d0
	movem.l	(sp)+,d4-d7/a3-a5
	rts

;		#[ Edit_ascii_keystable:
	IFEQ	cartouche
	SET_ID	CMDLINE_MAGIC
	ENDC
edit_ascii_keystable:
	dc.w	$001c	;[Return]
	dc.w	edit_ascii_cr-edit_ascii_keystable
	dc.w	$0072	;[Enter]
	dc.w	edit_ascii_enter-edit_ascii_keystable
	dc.w	$004d	;[Right]
	dc.w	edit_ascii_right-edit_ascii_keystable
	dc.w	$004b	;[Left]
	dc.w	edit_ascii_left-edit_ascii_keystable
	dc.w	$0048	;[Up]
	dc.w	edit_ascii_up-edit_ascii_keystable
	dc.w	$0050	;[Down]
	dc.w	edit_ascii_down-edit_ascii_keystable
	dc.w	$014d	;[Sft_Right]
	dc.w	edit_ascii_sft_right-edit_ascii_keystable
	dc.w	$014b	;[Sft_Left]
	dc.w	edit_ascii_sft_left-edit_ascii_keystable
	dc.w	$0148	;[Sft_Up]
	dc.w	edit_ascii_sft_up-edit_ascii_keystable
	dc.w	$0150	;[Sft_Down]
	dc.w	edit_ascii_sft_down-edit_ascii_keystable

	dc.w	$0474	;[Ctl_Right]
	dc.w	edit_ascii_ctl_right-edit_ascii_keystable
	dc.w	$0473	;[Ctl_Left]
	dc.w	edit_ascii_ctl_left-edit_ascii_keystable

	dc.w	$0053	;[Del]
	dc.w	edit_ascii_del-edit_ascii_keystable
	dc.w	$0414	;[Ctl_T]
	dc.w	edit_ascii_ctl_t-edit_ascii_keystable
	dc.w	$0453	;[Ctl_Del]
	dc.w	edit_ascii_ctl_del-edit_ascii_keystable
	dc.w	$0853	;[Alt_Del]
	dc.w	edit_ascii_alt_del-edit_ascii_keystable
	dc.w	$0001	;[Esc]
	dc.w	edit_ascii_esc-edit_ascii_keystable
	dc.w	$000E	;[Back]
	dc.w	edit_ascii_back-edit_ascii_keystable
	dc.w	$0161	;[Sft_Undo]
	dc.w	edit_ascii_esc-edit_ascii_keystable
	dc.w	$0061	;[Undo]
	dc.w	edit_ascii_undo-edit_ascii_keystable
	dc.w	$0416	;[Ctl_U]
	dc.w	edit_ascii_toupper-edit_ascii_keystable
	dc.w	$0426	;[Ctl_L]
	dc.w	edit_ascii_tolower-edit_ascii_keystable
	dc.w	$0427	;[Ctl_M]
	dc.w	edit_ascii_match-edit_ascii_keystable	
	dc.w	$0413	;[Ctl_R]
	dc.w	edit_ascii_hextoraw-edit_ascii_keystable
	dc.w	$0425	;[Ctl_K]
	dc.w	edit_ascii_rawtohex-edit_ascii_keystable
	dc.w	$042E	;[Ctl_C]
	dc.w	edit_ascii_togupdown-edit_ascii_keystable
	dc.w	$040E	;[Ctl_Back]
	dc.w	edit_ascii_del_sol-edit_ascii_keystable
	;dc.w	$0420	;[Ctl_D]
	;dc.l	edit_ascii_delc-edit_ascii_keystable
	dc.w	$040f	;[Ctl_Tab]
	dc.w	edit_ascii_compvar-edit_ascii_keystable


	;TCSH compatible
	dc.w	$0422	;[Ctl_G]
	dc.w	edit_ascii_esc-edit_ascii_keystable
	dc.w	$0423	;[Ctl_H]
	dc.w	edit_ascii_back-edit_ascii_keystable
	dc.w	$0419	;[Ctl_P]
	dc.w	edit_ascii_up-edit_ascii_keystable
	dc.w	$0431	;[Ctl_N]
	dc.w	edit_ascii_down-edit_ascii_keystable
	dc.w	$0430	;[Ctl_B]
	dc.w	edit_ascii_left-edit_ascii_keystable
	dc.w	$0421	;[Ctl_F]
	dc.w	edit_ascii_right-edit_ascii_keystable
	dc.w	$0410	;[Ctl_A]
	dc.w	edit_ascii_sft_left-edit_ascii_keystable
	dc.w	$0412	;[Ctl_E]
	dc.w	edit_ascii_sft_right-edit_ascii_keystable
	IFNE	debug
	dc.w	$0062
	dc.w	edit_ascii_help-edit_ascii_keystable
	ENDC
	dc.w	0
	EVEN
;		#] Edit_ascii_keystable:

edit_ascii_poke_one_char:
	;poker le car
	move.b	d2,(a2)
	rts

edit_ascii_clr_line:
	movem.l	d6/a2,-(sp)
	lea	empty_string(a6),a2
	move.w	d4,d6
	sub.w	x_pos(a6),d6
	bmi.s	.no_clear
	addq.w	#2,d6
	clr.b	0(a2,d6.w)
	bsr	print_instruction
	move.b	#' ',(a2,d6.w)
.no_clear:
	movem.l	(sp)+,d6/a2
	rts

edit_ascii_compvar:
;	tst.b	(a2)
;	bne.s	.flash
	move.l	a2,a0
.l1:
	;debut physique
	cmp.l	a5,a0
	ble.s	.start_of_label_2
	;alphanumerique ?
	move.b	-(a0),d0
	lea	eot_table,a1
	;nb de tokens
	moveq	#0,d1
	move.b	(a1)+,d1
	subq.w	#1,d1
.l3:
	cmp.b	(a1)+,d0
	beq.s	.start_of_label
	dbf	d1,.l3
	bra.s	.l1
.start_of_label:
	addq.w	#1,a0
.start_of_label_2:
	move.l	a0,edit_ascii_long2(a6)
	_JSR	Extract_number
	movem.l	a0/a2,-(sp)
	lea	evaluator_buffer(a6),a2
	moveq	#-1,d0
	moveq	#0,d1
	moveq	#1,d2
	bsr	find_in_table
	movem.l	(sp)+,a0/a2
	bmi.s	.flash
	;inserer le label trouve dans le buffer
	subq.w	#6,a1
	move.l	(a1),a1
	move.l	a1,edit_ascii_long1(a6)

	exg	a0,a1
	bsr	strlen3
	move.l	a1,d1
	sub.l	edit_ascii_long2(a6),d1
	sub.w	d1,d0
	;pour reafficher du debut de la variable
;	move.l	a1,a2
	lea	edit_ascii_insert_var(pc),a0
	bsr	edit_ascii_insert
.end:
	moveq	#-2,d0
	rts
.flash:
	_JSR	flash
	bra.s	.end

edit_ascii_insert_var:
	move.l	edit_ascii_long1(a6),a0
	move.l	edit_ascii_long2(a6),a1
.l1:
	move.b	(a0)+,d0
	beq.s	.end
	move.b	d0,(a1)+
	bra.s	.l1
.end:
	rts

edit_ascii_hextoraw:
	move.l	a3,-(sp)
	lea	lower_level_buffer(a6),a3
	bsr	get_char
	cmp.b	#'0',d0
	blt.s	.one_char
	cmp.b	#'9',d0
	ble.s	.two_chars
	cmp.b	#'A',d0
	blt.s	.one_char
	cmp.b	#'F',d0
	ble.s	.two_chars
	cmp.b	#'a',d0
	blt.s	.one_char
	cmp.b	#'f',d0
	bgt.s	.one_char
.two_chars:
	move.b	d0,(a3)
	bsr	get_char
	move.b	d0,1(a3)
	clr.b	2(a3)
	move.l	a3,a0
	_JSR	evaluate
	tst.w	d1
	bpl.s	.ok
	_JSR	flash
	bra.s	.abort
.one_char:
.ok:
	move.b	d0,d2
	moveq	#-3,d0
	bra.s	.end
.abort:
	moveq	#-2,d0
.end:
	move.l	(sp)+,a3
	rts

edit_ascii_get_eol:
	move.w	d7,d5
	move.l	a3,a0
	bsr	strlen3
	add.w	d0,d5
	cmp.w	d4,d5
	ble.s	.no
	move.w	d4,d5
.no:
	rts

edit_ascii_rawtohex:
	moveq	#-2,d0
	rts

edit_ascii_togupdown:
	move.b	(a2),d0
	cmp.b	#'a',d0
	blt.s	.test_high
	cmp.b	#'z',d0
	bgt.s	.end
	bclr	#5,d0
	bra.s	.poke
.test_high:
	cmp.b	#'A',d0
	blt.s	.end
	cmp.b	#'Z',d0
	bgt.s	.end
	bset	#5,d0
.poke:
	move.b	d0,(a2)
	bsr	edit_ascii_printclip
.end:
	moveq	#-2,d0
	rts

edit_ascii_del_sol:
	moveq	#-2,d0
	rts

edit_ascii_sft_down:
	moveq	#5,d0
	rts

edit_ascii_sft_up:
	moveq	#4,d0
	rts

edit_ascii_down:
	moveq	#3,d0
	rts

edit_ascii_up:
	moveq	#2,d0
	rts

edit_ascii_enter:
	lea	(a5,d6.w),a2
	moveq	#1,d0
	rts

edit_ascii_cr:
	moveq	#0,d0
	rts

edit_ascii_esc:
	moveq	#-1,d0
	rts

edit_ascii_alt_del:
	moveq	#$bb,d2
	moveq	#-3,d0
	rts

edit_ascii_tolower:
	moveq	#'A'-'a',d1
	moveq	#'A',d2
	moveq	#'Z',d3
	bra.s	edit_ascii_change_case
edit_ascii_toupper:
	moveq	#'a'-'A',d1
	moveq	#'a',d2
	moveq	#'z',d3
edit_ascii_change_case:
	bsr	edit_ascii_save_undo
	move.l	a5,a0
	moveq	#0,d0
.l1:
	move.b	(a0)+,d0
	beq.s	.end
	cmp.b	d2,d0
	blt.s	.l1
	cmp.b	d3,d0
	bgt.s	.l1
	sub.b	d1,-1(a0)
	bra.s	.l1
.end:
	move.l	a2,-(sp)
	move.w	x_pos(a6),-(sp)
	move.w	d7,x_pos(a6)
	move.l	a3,a2
	bsr	edit_ascii_printclip
	move.w	(sp)+,x_pos(a6)
	move.l	(sp)+,a2
	moveq	#-2,d0
	rts

	IFNE	debug
edit_ascii_help:
	bsr	get_char
	bsr	scan_to_text
	;--decaler la ligne de la longueur de la mac
	;ds a0 l'@ de la chaine pokee
	move.l	a0,edit_ascii_long1(a6)
	;ds d0 l'offset de decalage
	;+1 pour le backquote
	addq.w	#1,d0
	lea	edit_ascii_poke_macro(pc),a0
	bsr	edit_ascii_insert
	moveq	#-2,d0
	rts

edit_ascii_poke_macro:
	;--poker la macro
	move.l	edit_ascii_long1(a6),a0
	move.l	a2,a1
	move.b	#'`',(a1)+
.l1:
	move.b	(a0)+,d0
	beq.s	.out
	move.b	d0,(a1)+
	bra.s	.l1
.out:
	rts
	ENDC

edit_ascii_ctl_del:
	bsr	edit_ascii_save_undo
	move.l	a5,a2
	move.l	a5,a3
	moveq	#0,d6
	move.w	d7,linex_cursor(a6)
	move.w	d7,x_pos(a6)
	bsr	edit_ascii_get_eol
	bsr	edit_ascii_clr_line
	move.l	a5,a0
	bsr	init_buffer3
	bsr	edit_ascii_print_left
;	bsr	edit_ascii_print_right
	moveq	#-2,d0
	rts

edit_ascii_ctl_t:
	lea	-2(a2),a0
	cmp.l	a5,a0
	blt.s	.end
	move.b	(a0),d0
	move.b	-1(a2),(a0)
	move.b	d0,-1(a2)
	;afficher deux car seulement
	move.b	(a2),-(sp)
	move.l	a2,-(sp)
	move.w	x_pos(a6),-(sp)
	cmp.w	linex_cursor(a6),d4
	ble.s	.dont_clear
	clr.b	(a2)
.dont_clear:
	subq.w	#2,x_pos(a6)
	subq.w	#2,a2
	bsr	print_instruction
	move.w	(sp)+,x_pos(a6)
	move.l	(sp)+,a2
	move.b	(sp)+,(a2)
.end:
	moveq	#-2,d0
	rts

edit_ascii_del:
	;fin de ligne logique ?
	lea	(a5,d6.w),a0
	move.l	a0,d1
	sub.l	a2,d1
	ble.s	.end

	bsr.s	edit_ascii_save_undo

	move.l	a2,a1
	lea	1(a2),a0
.l12:
	move.b	(a0)+,(a1)+
	dbf	d1,.l12

	subq.w	#1,d6
	bsr	clr_getline
	bsr	edit_ascii_printclip
.end:
	moveq	#-2,d0
	rts

edit_ascii_sft_left:
	move.l	a5,a3
	move.l	a3,a2
	move.w	d7,linex_cursor(a6)
	bsr	edit_ascii_check_print
	moveq	#-2,d0
	rts

edit_ascii_sft_right:
;	lea	-1(a5,d6.w),a2
	lea	0(a5,d6.w),a2
	move.w	d5,linex_cursor(a6)
	cmp.w	d4,d5
	blt.s	.end
	move.w	d4,d0
	move.w	d0,linex_cursor(a6)
	sub.w	d7,d0
	move.l	a2,a3
	sub.w	d0,a3
	bsr	edit_ascii_check_print
.end:
	moveq	#-2,d0
	rts

edit_ascii_save_undo:
	lea	edit_ascii_undo_buffer(a6),a1
	tst.b	(a1)
	bne.s	.no_copy
	move.l	a5,a0
	bsr	strcpy3
	lea	edit_ascii_undo_cursor(a6),a0
	move.l	a3,(a0)+
	move.l	a2,(a0)+
	move.w	linex_cursor(a6),(a0)+
	move.w	d6,(a0)+
.no_copy:
	rts

edit_ascii_undo:
	lea	edit_ascii_undo_buffer(a6),a0
	tst.b	(a0)
	bne.s	.ok
	bsr	flash
	bra.s	.end
.ok:
	;sauver la ligne d'undo dans un troisieme buffer
	lea	edit_ascii_undo2_buffer(a6),a1
	bsr	strcpy3
	lea	edit_ascii_undo_cursor(a6),a0
	lea	edit_ascii_undo2_cursor(a6),a1
	rept	3
	move.l	(a0)+,(a1)+
	endr

	;recopier la ligne courante dans le buffer d'undo
	clr.b	edit_ascii_undo_buffer(a6)
	bsr.s	edit_ascii_save_undo

	;puis le troisieme buffer vers la ligne courante
	move.l	a5,a1
	lea	edit_ascii_undo2_buffer(a6),a0
	bsr	strcpy3
	lea	edit_ascii_undo2_cursor(a6),a0
	move.l	(a0)+,a3
	move.l	(a0)+,a2
	move.w	(a0)+,d3
	move.w	d3,linex_cursor(a6)
	move.w	(a0)+,d6

	move.w	d7,x_pos(a6)
	bsr	print_all_getline
	;et clearer jusqu'a la fin de la ligne apres
	move.l	a3,a0
	bsr	strlen3
	add.w	d7,d0
	move.w	d0,x_pos(a6)
	bsr	edit_ascii_clr_line
;	_JSR	clr_line
	move.w	d3,x_pos(a6)
.end:
	moveq	#-2,d0
	rts

edit_ascii_match:
	;symbole a chercher
	move.b	(a2),d3
	lea	edit_ascii_match_table(pc),a0
.l1:
	move.b	(a0)+,d2
	beq	.end
	cmp.b	d2,d3
	beq.s	.find_closing
	cmp.b	(a0)+,d3
	bne.s	.l1
;.find_opening:
	;ds d2 le symbole ouvrant
	;ds d3 le symbole fermant
	moveq	#0,d1
	;ds d1 le compteur d'ouverture/fermeture
	lea	1(a2),a0
.l3:
	;tester debut de chaine physique
	cmp.l	a5,a0
;	ble.s	.end
	ble	.print
	;tester debut chaine logique
	cmp.l	a3,a0
	ble.s	.print_dec

	move.b	-(a0),d0
	beq.s	.inc
	cmp.b	d3,d0
	beq.s	.add_d12
	cmp.b	d2,d0
	beq.s	.sub_d12
.tst2:
	tst.w	d1
	bne.s	.l3
	bra.s	.print
.print_dec:
;	subq.w	#1,a0
	movem.l	d0-d3/a0-a1,-(sp)
	bsr	edit_ascii_ctl_left
	movem.l	(sp)+,d0-d3/a0-a1
	bra.s	.l3
.inc:
	addq.w	#1,a0
	bra.s	.print
.sub_d12:
	subq.w	#1,d1
	bra.s	.tst2
.add_d12:
	addq.w	#1,d1
	bra.s	.tst2
.sub_d1:
	subq.w	#1,d1
	bra.s	.tst
.add_d1:
	addq.w	#1,d1
	bra.s	.tst
.print_inc:
;	addq.w	#1,a0
	movem.l	d0-d3/a0-a1,-(sp)
	bsr	edit_ascii_ctl_right
	movem.l	(sp)+,d0-d3/a0-a1
	bra.s	.l2
.find_closing:
	move.b	(a0),d2
	;ds d2 le symbole fermant
	;ds d3 le symbole ouvrant
	moveq	#0,d1
	;ds d1 le compteur d'ouverture/fermeture
	move.l	a2,a0
.l2:
	;fin de chaine physique
	lea	(a5,d6.w),a1
	cmp.l	a1,a0
	bgt.s	.dec

	;tester fin de chaine logique
	movem.l	d1-d3/a0,-(sp)
	bsr	edit_ascii_get_eol
	movem.l	(sp)+,d1-d3/a0

	move.w	d5,d0
	sub.w	d7,d0
	lea	(a3,d0.w),a1
	cmp.l	a1,a0
	bgt.s	.print_inc

	move.b	(a0)+,d0
	;tester fin de chaine physique
	beq.s	.dec
	cmp.b	d3,d0
	beq.s	.add_d1
	cmp.b	d2,d0
	beq.s	.sub_d1
.tst:
	tst.w	d1
	bne.s	.l2
.dec:
	subq.w	#1,a0
.print:
	move.l	a0,a2
	move.l	a0,d0
	sub.l	a3,d0
	add.w	d7,d0
	move.w	d0,linex_cursor(a6)
	move.w	d0,x_pos(a6)
;	bsr	edit_ascii_check_print
.end:
	moveq	#-2,d0
	rts
;		#[ Edit_ascii_match_table:
edit_ascii_match_table:
	dc.b	'(',')'
	dc.b	'{','}'
	dc.b	'[',']'
	dc.b	0,0
;	even
;		#] Edit_ascii_match_table:

edit_ascii_back:
	;debut de ligne logique ?
	move.l	a2,d2
	sub.l	a5,d2
	ble.s	.end

	bsr	edit_ascii_save_undo
	;@ dest
	lea	-1(a2),a1
	;@ source
	move.l	a2,a0

	;nb de car a scroller
	move.w	d6,d1
	sub.w	d2,d1
.l10:
	move.b	(a0)+,(a1)+
	dbf	d1,.l10

	subq.w	#1,d6

	;debut de ligne physique ?
	cmp.w	linex_cursor(a6),d7
	blt.s	.ok
	subq.w	#1,a3
	subq.w	#1,a2
	bsr.s	edit_ascii_check_print
	bra.s	.end
.ok:
	subq.w	#1,linex_cursor(a6)
	bsr	clr_getline
	subq.w	#1,x_pos(a6)
	subq.w	#1,a2
	bsr	edit_ascii_printclip
.end:
	moveq	#-2,d0
	rts

edit_ascii_ctl_right:
	bsr	edit_ascii_get_eol
	move.w	d5,d0
	sub.w	d7,d0
	tst.b	(a3,d0.w)
	beq.s	.no

	addq.w	#1,a3
	addq.w	#1,a2
	bsr.s	edit_ascii_check_print
.no:
	moveq	#-2,d0
	rts

edit_ascii_ctl_left:
	cmp.l	a5,a3
	ble.s	.no
	subq.w	#1,a3
	subq.w	#1,a2
	bsr.s	edit_ascii_check_print
.no:
	moveq	#-2,d0
	rts

edit_ascii_right:
	move.w	linex_cursor(a6),d0
	; fin de ligne logique
;	lea	-1(a5,d6.w),a0
	lea	0(a5,d6.w),a0
	cmp.l	a0,a2
	bge.s	.end
	; fin de ligne physique
	cmp.w	d4,d0
	blt.s	.ok
	addq.w	#1,a3
	bsr.s	edit_ascii_check_print
	bra.s	.inc
.ok:
	addq.w	#1,linex_cursor(a6)
.inc:
	addq.w	#1,a2
.end:
	moveq	#-2,d0
	rts

edit_ascii_left:
	;debut de ligne physique
	cmp.w	linex_cursor(a6),d7
	blt.s	.ok
	;debut de ligne logique
	cmp.l	a5,a3
	ble.s	.end
	subq.w	#1,a3
	bsr.s	edit_ascii_check_print
	bra.s	.dec
.ok:
	subq.w	#1,linex_cursor(a6)
.dec:
	subq.w	#1,a2
.end:
	moveq	#-2,d0
	rts

;verifie en comparant
;a4 (valeur du dernier print a3) avec a3 (nouvelle valeur)
;si la chaine doit etre reaffichee.
edit_ascii_check_print:
	move.l	a4,d0
	cmp.l	a3,d0
	beq.s	.end
	bsr.s	print_all_getline
.end:
	rts

;force l'affichage de toute la chaine
print_all_getline:
	move.w	x_pos(a6),-(sp)
	move.l	a2,-(sp)
	move.l	a3,a2
	move.w	d7,x_pos(a6)
	bsr.s	edit_ascii_printclip
	move.l	(sp)+,a2
	move.w	(sp)+,x_pos(a6)
	rts

;affiche la chaine de debut courant en clippant la fin de la chaine
edit_ascii_printclip:
	;sauver a3 pour verif ulterieure
	move.l	a3,a4

	;clipping physique
;	move.w	d4,d0
;	sub.w	d7,d0

	bsr	edit_ascii_get_eol
	move.w	d5,d0
	sub.w	d7,d0
	;pour le clip
	addq.w	#1,d0
	lea	(a3,d0.w),a0
	move.b	(a0),-(sp)
	move.l	a0,-(sp)

	;fleche droite
	subq.w	#1,a0
	bsr.s	edit_ascii_print_right

	;fleche gauche
	bsr.s	edit_ascii_print_left

;	bsr	edit_ascii_get_eol
	;clipper avec effacement
	cmp.w	d4,d5
	bgt.s	.no_clear
	bsr.s	clr_getline
.no_clear:

	;clip
	move.l	(sp),a0
	clr.b	(a0)
	bsr	print_instruction
	move.l	(sp)+,a0
	move.b	(sp)+,(a0)
	rts

edit_ascii_print_right:
	move.w	x_pos(a6),-(sp)
	move.l	a2,-(sp)
	move.w	d4,d0
	addq.w	#1,d0
	move.w	d0,x_pos(a6)
	lea	one_space_text(pc),a2
	tst.b	(a0)
	beq.s	edit_ascii_print_left_right
	lea	right_arrow_text(pc),a2
edit_ascii_print_left_right:
	bsr	print_instruction
	move.l	(sp)+,a2
	move.w	(sp)+,x_pos(a6)
	rts

edit_ascii_print_left:
	move.w	x_pos(a6),-(sp)
	move.l	a2,-(sp)
	move.w	d7,d0
	subq.w	#1,d0
	move.w	d0,x_pos(a6)
	lea	one_space_text(pc),a2
	cmp.l	a5,a3
	ble.s	edit_ascii_print_left_right
	lea	left_arrow_text(pc),a2
	bra.s	edit_ascii_print_left_right

clr_getline:
	move.w	x_pos(a6),-(sp)
	move.w	d5,x_pos(a6)
	lea	empty_string+1(a6),a0
	move.b	(a0),-(sp)
	move.l	a0,-(sp)
	clr.b	(a0)
	_JSR	clr_line
	move.l	(sp)+,a0
	move.b	(sp)+,(a0)
	move.w	(sp)+,x_pos(a6)
	rts

cursor_on:
	move.w	y_pos(a6),d0
	move.w	linex_cursor(a6),d1
	bra	print_cursor

cursor_off:
	move.w	y_pos(a6),d0
	move.w	old_linex_cursor(a6),d1
	bra	print_cursor

edit_ascii_insert:
	movem.l	d3,-(sp)
	move.l	a0,-(sp)
	;nb de lettres a inserer
	move.w	d0,d3

	;decaler vers l'avant de d2 caractere(s)
	;@ source
	lea	0(a5,d6.w),a0
	;@ dest
	lea	0(a0,d3.w),a1

	move.w	d6,d1
	move.l	a2,d0
	sub.l	a5,d0
	sub.w	d0,d1
	beq.s	.no_shift
	;-1 pour le dbf
	subq.w	#1,d1
.l1:
	move.b	-(a0),-(a1)
	dbf	d1,.l1
.no_shift:
	move.l	(sp)+,a0
	jsr	(a0)

	;plus d3 cars
	add.w	d3,d6

	;sur qu'il y a un 0 derriere
	clr.b	(a5,d6.w)

	;vider le buffer d'undo
	clr.b	edit_ascii_undo_buffer(a6)

	;si curseur en fin d'ecran en absolu
	move.w	linex_cursor(a6),d0
	;line_len-1
	cmp.w	d4,d0
	bgt.s	.scroll_left
	;curseur vers droite et afficher le reste de la chaine
;.print_right:
	add.w	d3,linex_cursor(a6)
	bsr	edit_ascii_printclip
	bra.s	.good
	;revenir de d3 car dans la chaine et reafficher tout
.scroll_left:
	add.w	d3,a3
	bsr	edit_ascii_check_print
.good:
	;plus d3 dans le buffer courant
	add.w	d3,a2
	moveq	#0,d0
.end:
	movem.l	(sp)+,d3
	rts

;  #] Edit ascii line:
;  #[ Clear Screen:

little_clear_screen:
 cmp.l #RS232_OUTPUT,device_number(a6)
 beq.s terminal_clear_screen
 tst.l device_number(a6)
 beq.s no_clear_screen
 cmp.l #PRINTER_OUTPUT,device_number(a6)
 beq.s no_clear_screen
 move.l physbase(a6),a0
 move.w screen_size_y(a6),d0
 move.w d0,d1
 ext.l d1
 divu column_len(a6),d1
 sub.w d1,d0
 mulu line_size(a6),d0
 lsr.l #2,d0
 subq.w #1,d0
 moveq #0,d1
 tst.b meta_rez(a6)
 beq.s internal_clear_screen
 tst.b inverse_video_flag(a6)
 beq.s internal_clear_screen
 moveq #-1,d1
 bra.s internal_clear_screen

clear_screen:
 cmp.l #RS232_OUTPUT,device_number(a6)
 beq.s terminal_clear_screen
 tst.l device_number(a6)
 beq.s no_clear_screen
 cmp.l #PRINTER_OUTPUT,device_number(a6)
 beq.s no_clear_screen
 move.l physbase(a6),a0
 move.w screen_size_y(a6),d0
 mulu line_size(a6),d0
 lsr.l #2,d0
 subq.w #1,d0
 moveq #0,d1
 tst.b meta_rez(a6)
 beq.s internal_clear_screen
 tst.b inverse_video_flag(a6)
 beq.s internal_clear_screen
 moveq #-1,d1
internal_clear_screen:
 move.l d1,(a0)+
 dbf d0,internal_clear_screen
no_clear_screen:
 rts
terminal_clear_screen:
 move.l	x_pos(a6),-(sp)
 move.l	#$10001,x_pos(a6)
 bsr soulign_off
 tst.b minitel_flag(a6)
 beq.s .4
 moveq #$a,d0
 bsr rs_put
 moveq #$1b,d0
 bsr rs_put
 moveq #"c",d0
 bsr rs_put
 bra.s	.suite
.4:
 movem.l d0-d2,-(sp)
 moveq #24,d2
.6:
 bsr poscur
 moveq #79,d1
.5:
 moveq #' ',d0
 bsr rs_put
 dbf d1,.5
 addq.w	#1,y_pos(a6)
 dbf d2,.6
 movem.l (sp)+,d0-d2
.suite
 move.l	(sp)+,x_pos(a6)
 rts

;  #] Clear Screen:
;	 #[ Disk operation:
get_drive:
	pea	_get_drive(pc)
	bra.s	disk_operation
get_path:
	pea	_get_path(pc)
	bra.s	disk_operation
get_drivepath:
	pea	_get_drivepath(pc)
	bra.s	disk_operation
;set_drive:
;	pea	_set_drive(pc)
;	bra.s	disk_operation
set_path:
	pea	_set_path(pc)
	bra.s	disk_operation
set_drivepath:
	pea	_set_drivepath(pc)
	bra.s	disk_operation
open_dta:
	pea	_open_dta(pc)
	bra.s	disk_operation
find_first:
	pea	_find_first(pc)
	bra.s	disk_operation
find_next:
	pea	_find_next(pc)
	bra.s	disk_operation
open_file:
	pea	_open_file(pc)
	bra.s	disk_operation
	IFEQ	bridos
create_file:
	pea	_create_file(pc)
	bra.s	disk_operation
write_file:
	pea	_write_file(pc)
	bra.s	disk_operation
	ENDC	;de bridos
read_file:
	pea	_read_file(pc)
	bra.s	disk_operation
seek_file:
	pea	_seek_file(pc)
	bra.s	disk_operation
close_dta:
	pea	_close_dta(pc)
	bra.s	disk_operation
close_file:
	pea	_close_file(pc)
;	bra.s	disk_operation
disk_operation:
	bsr	install_404
	move.l	(sp)+,a1
	bmi.s	.error
	move.l	a2,-(sp)
	jsr	(a1)
	move.l	(sp)+,a2
.error:
	bsr	deinstall_404
	rts
;	 #] Disk operation:
	IFNE	ATARIST
	include	"atari.s"
	ENDC	; d'ATARIST
	IFNE	AMIGA
	include	"amiga.s"
	ENDC	; d'AMIGA
treat_instruction:	bra	_treat_instruction
recording_mac2:	bra	recording_mac
;  #[ Sections data & bss:
	include	"databss.s"
;  #] Sections data & bss:

