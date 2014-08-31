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

;vite:
;[Sft_Right] en inspect,src
;modules-> list + load (plutot operateur!)

;ensuite:
;->,.,(int) dans l'evaluateur
;finir visu stack
;speeder la recherche des statics
;p0p1_source_trace->updater le mode trace permanent
;locals:@/registre+verif du type du ptr
;invisibles en ascii
;flag ascii scroll
	IFNE	turbodebug
;;		#[ Pure C:
;	 #[ tcget_sizeof:
;In:a1=struct @
;Out:d0=struct sizeof
tcget_sizeof:
	move.l	6(a1),a1
	add.l	l5_ptr(a6),a1
	move.l	2(a1),d0
	rts
;	 #] tcget_sizeof:
;	 #[ tcget_array_elem_value:
;Input:
;a0=name
;a1=result buffer
;d0=elem nb
;Output:
;d0=-1->not_found
tcget_array_elem_value:
	movem.l	d7/a2-a5,-(sp)
	move.l	a1,a5
	move.w	d0,d7
	moveq	#0,d0
	bsr	tcget_var_by_name
	bmi.s	.error
	tst.b	(a0)
	beq.s	.error
	move.l	a0,a4
	move.l	6(a4),a3
	add.l	l5_ptr(a6),a3
	cmp.b	#12,(a3)
	bne.s	.error
	move.l	10(a3),a2
	add.l	l5_ptr(a6),a2
	move.l	2(a2),d0
	mulu	d0,d7
	add.l	10(a4),d7
	add.l	text_buf(a6),d7
	move.l	d7,a0
	move.l	a2,a1
	bsr	_tcget_var_value
	move.l	d0,$c(a5)
	move.l	d7,d1
	move.w	#$7f00,d0
	or.b	(a2),d0
	lsr.b	#1,d0
.end:
	tst.w	d0
	movem.l	(sp)+,d7/a2-a5
	rts
.error:
	moveq	#-1,d0
	bra.s	.end
;	 #] tcget_array_elem_value:
;	 #[ tcget_amper_value:
;Input:
;a0=name
;Output:
;d0=@
;d1=reussite
tcget_amper_value:
	moveq	#0,d0
	bsr	tcget_var_by_name
	bmi.s	.error
	move.l	a0,a1
	bsr	get_var_addr
	moveq	#0,d1
.end:	rts
.error:	moveq	#-1,d1
	bra.s	.end
;	 #] tcget_amper_value:
;	 #[ tcget_debug_file_info:
;d0=handle
tcget_debug_file_info:
	movem.l	d3-d7/a2-a5,-(sp)
	moveq	#0,d3
	move.l	d0,d4
	move.l	p1_dri_len(a6),d0
	move.l	d4,d1
	moveq	#1,d2
	bsr	seek_file
_tcget_debug_file_info:
	lea	tcdebug_head(a6),a5
	clr.l	(a5)
	move.l	a5,a0
	moveq	#$20,d0
	move.l	d4,d1
	bsr	read_file
	move.l	a5,a0
	cmp.l	#'QDB1',(a0)+
	bne	.format_error
	move.l	a5,tcdebug_ptr(a6)
	move.l	(a0)+,d0		;l1
	add.l	(a0)+,d0		;l2
	add.l	(a0)+,d0		;l3
	add.l	(a0)+,d0		;l4
	add.l	(a0)+,d0		;l5
	add.l	(a0)+,d0		;l6
	add.l	(a0),d0		;names
	move.l	d0,tcdebug_len(a6)
	beq	.no_debug
	st	d1
	moveq	#2,d2
	jsr	reserve_memory
	beq	.memory_error
	move.l	d0,sourcedebug_info_ptr(a6)
	lea	l1_ptr(a6),a0
	lea	l1_len(a6),a1
	move.l	d0,(a0)+		;l1
	add.l	(a1)+,d0
	move.l	d0,(a0)+		;l2
	add.l	(a1)+,d0
	move.l	d0,(a0)+		;l3
	add.l	(a1)+,d0
	move.l	d0,(a0)+		;l4
	add.l	(a1)+,d0
	move.l	d0,(a0)+		;l5
	add.l	(a1)+,d0
	move.l	d0,(a0)+		;l6
	add.l	(a1)+,d0
	move.l	d0,(a0)+		;names
	move.l	tcdebug_len(a6),d0
	move.l	l1_ptr(a6),a0
	move.l	d4,d1
	bsr	read_file
	move.w	#SOURCE_PC,source_type(a6)
	tst.l	l4_len(a6)
	beq.s	.nosym
	st	abssym_flag(a6)	;forcer
.nosym:	bsr	tcget_vars_max	;alloue les tableaux de ptr des blocs courants
	bsr	tcupdate_source	;alloue un buffer pour le plus gros source + verif date
	moveq	#1,d3
	bra.s	.reseek
.format_error:
	bra.s	.reseek
.memory_error:
	lea	memory_error_text,a2
	bsr	print_error
.no_debug:
.reseek:
tcget_nodebug:
	moveq	#$1c,d0
	move.l	d4,d1
	moveq	#0,d2
	bsr	seek_file
	move.l	d3,d0
	movem.l	(sp)+,d3-d7/a2-a5
	rts
;	 #] tcget_debug_file_info:
;	 #[ pcget_debug_file_info:
;d0=handle
pcget_debug_file_info:
	movem.l	d3-d7/a2-a5,-(sp)
	moveq	#0,d3
	move.l	d0,d4
	moveq	#-4,d0
	move.l	d4,d1
	moveq	#2,d2
	bsr	seek_file
	bmi.s	tcget_nodebug
	lea	p1_dri_len(a6),a5
	move.l	a5,a0
	moveq	#4,d0
	move.l	d4,d1
	bsr	read_file
	bmi.s	tcget_nodebug
	move.l	(a5),d0
	addq.l	#4,d0
	cmp.l	p1_disk_len(a6),d0
	bge.s	tcget_nodebug
	neg.l	d0
	move.l	d4,d1
	moveq	#1,d2
	bsr	seek_file
	bmi.s	tcget_nodebug
	bra	_tcget_debug_file_info
;	 #] pcget_debug_file_info:
;	 #[ tcget_vars_max:

;chope les valeurs max des globals/statiques/locals
;reserve les max
tcget_vars_max:
	move.l	l4_len(a6),d0
	beq.s	.no_vars
	move.l	l4_ptr(a6),a0
	lea	0(a0,d0.l),a1
.more_group:
	move.w	(a0),d0
	asl.w	#2,d0
	lea	tcvars_max_table(a6),a2
	add.w	d0,a2
	moveq	#0,d0
	move.w	6(a0),d0
	cmp.l	(a2),d0
	blt.s	.next_group
	move.l	d0,(a2)
.next_group:
	lea	20(a0),a0
	cmp.l	a1,a0
	blt.s	.more_group
.no_vars:
	bsr	tcget_globals_max
	move.l	globals_max(a6),d0
	add.l	statics_max(a6),d0
	add.l	locals_max(a6),d0
	add.l	inners_max(a6),d0
	mulu	#TCVARS_SIZEOF,d0
	move.l	d0,allvars_array_size(a6)
	beq.s	.no_reserve
	st	d1
	moveq	#2,d2
	jsr	reserve_memory
	beq.s	.memory_error
.no_reserve:
	move.l	d0,allvars_array_ptr(a6)

	moveq	#TCVARS_SIZEOF,d2
	move.l	d0,globals_array_ptr(a6)
	move.l	globals_max(a6),d1
	mulu	d2,d1
	add.l	d1,d0
	move.l	d0,statics_array_ptr(a6)

	move.l	statics_max(a6),d1
	mulu	d2,d1
	add.l	d1,d0
	move.l	d0,locals_array_ptr(a6)

	bsr	tcbuild_globals_array
	bsr	tcsort_globals_array
.memory_error:
	rts
;	 #] tcget_vars_max:
;	 #[ tcupdate_globals:
;choper le nb de globals
tcget_globals_max:
	clr.l	globals_max(a6)
	move.l	l4_len(a6),d0
	beq.s	.no_vars
	move.l	l4_ptr(a6),a0
	lea	0(a0,d0.l),a1
.more_global:
	moveq	#0,d0
	move.w	6(a0),d0
	add.l	d0,globals_max(a6)
	move.w	4(a0),d0
	mulu	#20,d0
	add.l	d0,a0
	cmp.l	a1,a0
	blt.s	.more_global
.no_vars:
	rts

tcbuild_globals_array:
	movem.l	d3/a2-a4,-(sp)
	move.l	l4_len(a6),d0
	beq.s	.no_vars
	move.l	l4_ptr(a6),a0
	lea	0(a0,d0.l),a1
	move.l	globals_array_ptr(a6),a4
	moveq	#14,d2
;	move.w	#TCWORD,d3
.more_block:
	move.w	6(a0),d1
	subq.w	#1,d1
	bmi.s	.next_block
	move.l	8(a0),a2
	add.l	l3_ptr(a6),a2

.more_global:
	move.l	a2,(a4)+
;	move.w	d3,(a4)+
	add.w	d2,a2
	dbf	d1,.more_global
.next_block:
	moveq	#0,d0
	move.w	4(a0),d0
	mulu	#20,d0
	add.w	d0,a0
	cmp.l	a0,a1
	bgt.s	.more_block
.no_vars:
	move.l	globals_max(a6),globals_nb(a6)
	movem.l	(sp)+,d3/a2-a4
	rts

tcsort_globals_array:
	clr.l	funcs_nb(a6)
	clr.l	datas_nb(a6)
	clr.l	cdefs_nb(a6)
	;trier les fonctions/globales/static/cdefs
	move.l	globals_nb(a6),d0
	beq	.end
	move.l	globals_array_ptr(a6),d1
	lea	_tccomp_var_type(pc),a0
	lea	_tcinv_var(pc),a1
	jsr	tri

	;pointer les fct/glob/static/cdefs
	move.l	globals_array_ptr(a6),a1
	move.l	globals_nb(a6),d1
	moveq	#TCVARS_SIZEOF,d2
.more_var:
	move.l	(a1),a0
	move.b	(a0),d0
	beq.s	.cdef
	cmp.b	#8,d0
	beq.s	.func
	cmp.b	#7,d0
	beq.s	.func
	cmp.b	#6,d0
	beq.s	.data
;	cmp.b	#5,d0
;	beq.s	.static
	trap	#4
.next_var:
	clr.l	(a2)
.l1:	addq.l	#1,(a2)
	add.w	d2,a1
	subq.l	#1,d1
	ble.s	.alpha
	move.l	(a1),a0
	cmp.b	(a0),d0
	bne.s	.more_var
	bra.s	.l1
.func:	move.l	a1,funcs_array_ptr(a6)
	lea	funcs_nb(a6),a2
	bra.s	.next_var
.data:	move.l	a1,datas_array_ptr(a6)
	lea	datas_nb(a6),a2
	bra.s	.next_var
.cdef:	move.l	a1,cdefs_array_ptr(a6)
	lea	cdefs_nb(a6),a2
	bra.s	.next_var
.alpha:	;trier par ordre alpha
	move.l	funcs_nb(a6),d0		;les funcs
	beq.s	.no_funcs
	move.l	funcs_array_ptr(a6),d1
	lea	_tccomp_var_alpha(pc),a0
	lea	_tcinv_var(pc),a1
	jsr	tri
.no_funcs:
	move.l	datas_nb(a6),d0		;les datas
	beq.s	.no_datas
	move.l	datas_array_ptr(a6),d1
	lea	_tccomp_var_alpha(pc),a0
	lea	_tcinv_var(pc),a1
	jsr	tri
.no_datas:
	move.l	cdefs_nb(a6),d0		;les cdefs
	beq.s	.no_cdefs
	move.l	cdefs_array_ptr(a6),d1
	lea	_tccomp_var_alpha(pc),a0
	lea	_tcinv_var(pc),a1
	jsr	tri
.no_cdefs:
;	move.l	cdefs_nb(a6),d0	;degager les cdefs des globals
;	sub.l	d0,globals_nb(a6)
.end:	rts
;	 #] tcupdate_globals:
;	 #[ tcupdate_source:
;mater tous les sources en verifiant la date et la taille
;gerer le src path
;prendre la plus grande taille et la reserver
tcupdate_source:
	movem.l	d3-d7/a2-a5,-(sp)
	moveq	#0,d7
	lea	my_dta(a6),a5
	move.l	l1_ptr(a6),a3
	move.l	a3,a4
	add.l	l1_len(a6),a4
	move.l	exec_timestamp(a6),d6
	move.l	d6,d5
	swap	d5
.l1:	cmp.l	a4,a3
	bge.s	.done
	move.l	4(a3),a0
	add.l	tcnames_ptr(a6),a0
	moveq	#-1,d0
	bsr	find_file
	bne.s	.not_found
	tst.b	src_checkmodtime_flag(a6)
	beq.s	.check_size
	move.l	DTA_TIME(a5),d0
	cmp.w	d0,d6
	bhi.s	.check_size
	swap	d0
	cmp.w	d0,d5
	bhi.s	.check_size
	move.l	4(a3),a0
	add.l	tcnames_ptr(a6),a0
	move.l	a0,-(sp)
	pea	src_more_recent_format(pc)
	lea	line_buffer(a6),a2
	move.l	a2,a0
	bsr	sprintf3
	addq.w	#8,sp
	bsr	print_press_key
.check_size:
	cmp.l	DTA_SIZE(a5),d7
	bge.s	.not_higher
	move.l	DTA_SIZE(a5),d7
.not_higher:
.not_found:
	addq.w	#8,a3
	bra.s	.l1
.done:	move.l	d7,d0
	jsr	reserve_memory
	bne.s	.ok
	moveq	#0,d0
	moveq	#0,d7
.ok:	move.l	d0,main_source_ptr(a6)
	move.l	d7,main_source_len(a6)
.end:	movem.l	(sp)+,d3-d7/a2-a5
	rts
src_more_recent_format:	dc.b	"Executable older than %s",0
	even
;	 #] tcupdate_source:
;	 #[ tcbegin_source_debug:
tcbegin_source_debug:
	movem.l	d6-d7/a3-a5,-(sp)

	;verifier les noms/valeurs des variables globales/internes
	move.l	globals_nb(a6),d7
	beq.s	.no_vars
	move.l	tcnames_ptr(a6),d6
	move.l	globals_array_ptr(a6),a3
.l1:	move.l	(a3),a4
	move.l	a4,a1
	bsr	tcget_var_addr
	move.l	d0,a0
	bsr	find_var_in_tree
	bne.s	.next_var
	move.l	VAR_TREE_VAR(a0),a5
	move.l	2(a4),a4
	add.l	d6,a4

	move.l	(a5),a0
	move.l	a4,a1
.l2:	cmpm.b	(a0)+,(a1)+
	bne.s	.next_var
	tst.b	(a0)
	bne.s	.l2
.found:	move.l	a4,(a5)
.next_var:
	addq.w	#TCVARS_SIZEOF,a3
	subq.l	#1,d7
	bgt.s	.l1
.no_vars:	clr.l	debug_usp_size(a6)		;pour le stack checking
	lea	tc_stack_size_text,a2
	move.w	#LAWORD,d0
	moveq	#0,d1
	moveq	#0,d2
	bsr	find_in_table
	bmi.s	.no_stack_size
	move.l	d1,debug_usp_size(a6)
.no_stack_size:	
	tst.b	src_untilmain_flag(a6)	;run until main
	beq.s	.end
	lea	tc_main_var_text,a2
	move.w	#LAWORD,d0
	moveq	#0,d1
	moveq	#0,d2
	bsr	find_in_table
	bmi.s	.end
	cmp.l	text_buf(a6),d1
	beq.s	.end
	move.l	d1,a0
	jsr	__ctrl_a
	bmi.s	.end
	jsr	p0p1
.end:	move.l	a7_buf(a6),start_debug_usp(a6)
	move.l	ssp_buf(a6),start_debug_ssp(a6)
	movem.l	(sp)+,d6-d7/a3-a5
	rts
;	 #] tcbegin_source_debug:
;	 #[ tcupdate_vars_array:
;trier les globales/fonctions
;pointer les globales
;pointer les fonctions
;pointer les static
;pointer les locales
tcupdate_vars_array:
	bsr	tcbuild_vars_array
	bmi	.no_action
	;les static
	move.l	statics_nb(a6),d0
	beq.s	.no_statics
	move.l	statics_array_ptr(a6),d1
	lea	_tccomp_var_alpha(pc),a0
	lea	_tcinv_var(pc),a1
	jsr	tri
.no_statics:
	;les locales+inners
	move.l	locals_nb(a6),d0
	beq.s	.no_locals
	move.l	locals_array_ptr(a6),d1
	lea	_tccomp_var_alpha(pc),a0
	lea	_tcinv_var(pc),a1
	jsr	tri
.no_locals:
	moveq	#0,d0
.no_action:
	rts

;compare les fonctions et les globales
_tccomp_var_type:
	move.l	d5,d0
;	mulu	#TCVARS_SIZEOF,d0
	lsl.l	#2,d0
	move.l	d6,d1
;	mulu	#TCVARS_SIZEOF,d1
	lsl.l	#2,d1
	move.l	0(a0,d0.l),a1
	move.l	0(a0,d1.l),a2
	move.b	(a1),d7
	cmp.b	(a2),d7
	rts

;compare le nom
_tccomp_var_alpha:
	move.l	d5,d0
;	mulu	#TCVARS_SIZEOF,d0
	lsl.l	#2,d0
	move.l	d6,d1
;	mulu	#TCVARS_SIZEOF,d1
	lsl.l	#2,d1
	move.l	0(a0,d0.l),a1
	move.l	0(a0,d1.l),a2
	move.l	2(a1),a1
	add.l	tcnames_ptr(a6),a1
	move.l	2(a2),a2
	add.l	tcnames_ptr(a6),a2
.next_alpha:
	move.b	(a2),d7
	cmp.b	(a1),d7
	beq.s	.more_alpha
.alpha_end:
	rts
.more_alpha:
	tst.b	(a1)
	bne.s	.not_alpha_end
	tst.b	(a2)
	beq.s	.alpha_end
.not_alpha_end:
	addq.w	#1,a1
	addq.w	#1,a2
	bra.s	.next_alpha

_tcinv_var:
	lea	(a0,d0.l),a1
	lea	(a0,d1.l),a2
	;2 words a switcher
	move.l	(a1),a3
	move.l	(a2),(a1)+
	move.l	a3,(a2)+

;	move.w	(a1),a3
;	move.w	(a2),(a1)
;	move.w	a3,(a2)
	rts
;	 #] tcupdate_vars_array:
;	 #[ tcbuild_vars_array:
tcbuild_statics_array:
	move.l	statics_nb(a6),d0
	subq.l	#1,d0
	bmi.s	.no_static
	move.l	statics_array_ptr(a6),a1
	move.l	statics_l3_ptr(a6),a0
;	move.w	#TCWORD,d1
	moveq	#14,d2
.more_static:
	move.l	a0,(a1)+
;	move.w	d1,(a1)+
	add.w	d2,a0
	subq.l	#1,d0
	bpl.s	.more_static
.no_static:
	rts

tcbuild_locals_array:
	move.l	locals_nb(a6),d0
	subq.l	#1,d0
	bmi.s	.no_local
	move.l	locals_array_ptr(a6),a1
	move.l	locals_l3_ptr(a6),a0
;	move.w	#TCWORD,d1
	moveq	#14,d2
.more_local:
	move.l	a0,(a1)+
;	move.w	d1,(a1)+
	add.w	d2,a0
	subq.l	#1,d0
	bpl.s	.more_local
.no_local:
	move.l	inners_nb(a6),d0
	subq.l	#1,d0
	bmi.s	.no_inner
	move.l	inners_l3_ptr(a6),a0
.more_inner:
	move.l	a0,(a1)+
;	move.w	d1,(a1)+
	add.w	d2,a0
	subq.l	#1,d0
	bpl.s	.more_inner
	move.l	inners_nb(a6),d0	;patch vite fait
	add.l	d0,locals_nb(a6)
.no_inner:
	rts

tcbuild_vars_array:
	;choper les vars courantes
	bsr	tcget_cur_vars
	bmi.s	.no_action

	;updater l'arbre des vars
	bsr	tcbuild_statics_array
	bsr	tcbuild_locals_array
	moveq	#0,d0
.no_action:
	rts
;	 #] tcbuild_vars_array:
;	 #[ tcget_cur_vars:
;update les ptr sur la struct l3 des statics/locals
tcget_cur_vars:
	move.l	d7,-(sp)
	tst.w	source_type(a6)
	beq.s	.no_action
	move.l	old_pc_vars(a6),d0
	cmp.l	pc_buf(a6),d0
	beq.s	.no_action

	move.l	pc_buf(a6),d7
	move.l	d7,old_pc_vars(a6)
	sub.l	text_buf(a6),d7
	bmi.s	.no_action
	move.l	d7,d0
	bsr	tcget_cur_statics
	move.l	d7,d0
	bsr	tcget_cur_locals
	move.l	d7,d0
	bsr	tcget_cur_inners
	moveq	#0,d0
.end:	movem.l	(sp)+,d7
	rts
.no_action:
	moveq	#-1,d0
	bra.s	.end

;d0=offset to scan for
tcget_cur_inners:
	move.l	d0,d2
	clr.l	inners_nb(a6)
	move.l	l4_ptr(a6),a0
	move.l	a0,a1
	add.l	l4_len(a6),a1
	moveq	#20,d1
.more_group:
	move.l	12(a0),d0
	cmp.l	d0,d2
	blt.s	.next_group
	add.l	16(a0),d0
	cmp.l	d0,d2
	blt.s	.group_found
.next_group:
	add.w	d1,a0
	cmp.l	a1,a0
	blt.s	.more_group
	bra.s	.end
.group_found:
	tst.w	(a0)		;inner
	bne.s	.next_group
	move.l	l3_ptr(a6),d0
	add.l	8(a0),d0
	move.l	d0,inners_l3_ptr(a6)
	move.w	6(a0),inners_nb+2(a6)
	bra.s	.next_group
.end:	rts

;d0=offset to scan for
tcget_cur_locals:
	move.l	d0,d2
	clr.l	locals_nb(a6)
	move.l	l4_ptr(a6),a0
	move.l	a0,a1
	add.l	l4_len(a6),a1
	moveq	#20,d1
.more_group:
	move.l	12(a0),d0
	cmp.l	d0,d2
	blt.s	.next_group
	add.l	16(a0),d0
	cmp.l	d0,d2
	blt.s	.group_found
.next_group:
	add.w	d1,a0
	cmp.l	a1,a0
	blt.s	.more_group
	bra.s	.end
.group_found:
	cmp.w	#1,(a0)		;func
	bne.s	.next_group
	move.l	l3_ptr(a6),d0
	add.l	8(a0),d0
	move.l	d0,locals_l3_ptr(a6)
	move.w	6(a0),locals_nb+2(a6)
	bra.s	.next_group
.end:	rts

;d0=offset to scan for
tcget_cur_statics:
	move.l	d0,d2
	clr.l	statics_nb(a6)
	move.l	l4_ptr(a6),a0
	move.l	a0,a1
	add.l	l4_len(a6),a1
	moveq	#20,d1
.more_group:
	move.l	12(a0),d0
	cmp.l	d0,d2
	blt.s	.next_group
	add.l	16(a0),d0
	addq.l	#1,d0
	cmp.l	d0,d2
	ble.s	.group_found
.next_group:
	add.w	d1,a0
	cmp.l	a1,a0
	blt.s	.more_group
	bra.s	.end
.group_found:
	cmp.w	#2,(a0)		;file
	bne.s	.next_group
	move.l	l3_ptr(a6),d0
	add.l	8(a0),d0
	move.l	d0,statics_l3_ptr(a6)
	move.w	6(a0),statics_nb+2(a6)
	bra.s	.next_group
.end:
	rts
;	 #] tcget_cur_vars:
;	 #[ tcget_source_addr:
;In:
;d0=adresse binaire
;Out:
;d0=@ source
;d1=# de ligne
;d2=longueur du bloc
;a0=@ module
;a1=@ debut du bloc
tcget_source_addr:
	movem.l	d3-d7/a2-a5,-(sp)
	sub.l	text_buf(a6),d0
	bmi	.error_2
	cmp.l	text_size(a6),d0
	bgt	.error_2

	move.l	l2_ptr(a6),a4
	moveq	#0,d6
	move.l	d0,d5
.l1:
	cmp.l	l2_len(a6),d6
;	bgt	.error_2
	bge	.error_2
	move.l	d5,d0
	move.l	4(a4),d1
	sub.l	d1,d0
	cmp.l	8(a4),d0
	bcc	.next
	suba.l	a5,a5		;offset binaire flottant
	move.l	12(a4),a3		;no de ligne flottant=no initial
	lea	20(a4),a0		;debut sous-structure
	move.l	16(a4),d3		;longueur sous-structure
.l2:	move.b	(a0),d2		;offset de source
	ext.w	d2
	add.w	d2,a3

	move.b	1(a0),d5		;offset binaire
	ext.w	d5
	add.w	d5,a5
	cmpa.l	d0,a5
	beq.s	.this_line
	bcc.s	.previous_line
	addq.w	#2,a0
	subq.l	#1,d3
	bgt.s	.l2
.previous_line:
	sub.w	d2,a3
	sub.w	d5,a5
	subq.w	#2,a0
.this_line:
	addq.w	#2,a0		;longueur du bloc concerne
	move.b	1(a0),d5
	ext.w	d5
	ext.l	d5
	add.l	4(a4),a5		;@ de debut de bloc
	add.l	text_buf(a6),a5
	subq.w	#1,a3
	move.l	a4,a0		;tester si le source courant est en memoire
	bsr	tcget_source_name
	cmp.l	source_name_addr(a6),a0
	beq.s	.already_loaded
	move.l	a0,source_name_addr(a6)
	move.l	main_source_ptr(a6),d0
	move.l	d0,source_ptr(a6)
	beq.s	.error
	move.l	d0,a1
	moveq	#-1,d0
	moveq	#-1,d1
	moveq	#-1,d2
	bsr	load_file
	bmi.s	.error
	move.l	d0,source_len(a6)
	move.l	source_ptr(a6),a0
	move.l	a0,a1
	add.l	d0,a1
	bsr	count_source_lines
	move.l	d0,source_lines_nb(a6)

	lea	src_line_format_buf(a6),a0

	move.l	d0,-(sp)
	pea	decimal_format_text
	bsr	sprintf3
	addq.w	#8,sp	

	move.w	d0,-(sp)

	lea	src_line_format_text,a1
	exg	a0,a1
	bsr	strcpy3
	moveq	#'0',d0
	add.w	(sp)+,d0
	move.b	d0,2(a1)
.already_loaded:
	move.l	a3,d0
	move.l	source_ptr(a6),a0
	move.l	source_len(a6),d1
	bsr	get_source_line
	bra.s	.end
.next:
	moveq	#20,d0
	move.l	16(a4),d1
	add.l	d1,d1
	add.l	d0,d1
	add.l	d1,a4
	add.l	d1,d6
	bra	.l1

.error:	clr.l	source_name_addr(a6)
.error_2:	moveq	#0,d0
.end:	move.l	d5,d2
	move.l	a5,a1
	move.l	(a4),a0
	add.l	l1_ptr(a6),a0
	move.l	a3,d1
	tst.l	d0
	movem.l	(sp)+,d3-d7/a2-a5
	rts
;	 #] tcget_source_addr:
;	 #[ tcget_source_name:
;In:
;a0=module structure offset
;Out:
;a0=source name
tcget_source_name:
	move.l	(a0),a0
	add.l	l1_ptr(a6),a0
;In:
;a0=module structure addr
tcget_mod_name:
	move.l	4(a0),a0
	add.l	tcnames_ptr(a6),a0
	rts
;	 #] tcget_source_name:
;	 #[ tcget_var_name:
;In:
;a0=var structure @
;Out:
;a0=source name
tcget_var_name:
	move.l	2(a0),a0
	add.l	tcnames_ptr(a6),a0
	rts
;	 #] tcget_var_name:
;	 #[ tcget_code_addr:
;renvoie l'adresse du binaire correspondant a la ligne de source pointee par a0
;In:
;a0=source addr
;Out:
;d0=code addr
;a0=module ptr
;Internal:
;d0=dummy
;d1=dummy
;d2=dummy
;d3=main source offset
;d4=main bin offset
;d5=last source offset
;d6=last bin offset
;d7=line nb searched
;a1=l2 ptr limit
;a2=current l2 ptr
;a3=2nd struct limit
tcget_code_addr:
	movem.l	d3-d7/a2-a5,-(sp)
	move.l	source_ptr(a6),a1
	move.l	a1,d0
	beq.s	.error
	cmp.l	a1,a0
	blt.s	.error
	exg	a0,a1
	bsr	count_source_lines
	move.l	d0,d7
	move.l	l2_ptr(a6),a2
	move.l	a2,a1
	add.l	l2_len(a6),a1
.l1:	cmp.l	a1,a2
	bge.s	.error

	move.l	16(a2),d0
	add.l	d0,d0
	lea	20(a2,d0.l),a3

	;trouver le module
	move.l	a2,a0
	bsr	tcget_source_name

	cmp.l	source_name_addr(a6),a0
	bne.s	.next

	;trouver la ligne
	move.l	12(a2),a5
	cmp.l	d7,a5
	bgt.s	.next
	move.l	4(a2),a4
	lea	20(a2),a0

.l2:	move.b	(a0),d5
	ext.w	d5
	add.w	d5,a5

	move.b	1(a0),d6
	ext.w	d6
	add.w	d6,a4

	cmp.l	d7,a5
	bgt.s	.this

	addq.w	#2,a0
	cmp.l	a3,a0
	blt.s	.l2

.next:	move.l	a3,a2
	bra.s	.l1
;.previous:
;	sub.l	d6,a4
.this:	move.l	a2,a0
	move.l	a4,d0
	add.l	text_buf(a6),d0
.end:	movem.l	(sp)+,d3-d7/a2-a5
	rts
.error:	moveq	#0,d0
	bra.s	.end
;	 #] tcget_code_addr:
;	 #[ tccheck_if_code:
;Input:
;a0=source_addr
;d0=line nb
;Output:
;d0=-1->not code
;=0->code
tccheck_if_code:
	movem.l	d3-d7/a2-a5,-(sp)
	subq.w	#8,sp			;start block,end block
	pea	-1.w			;offset
	move.l	d0,d7
	move.l	source_ptr(a6),d0
	beq.s	.error
	cmp.l	d0,a0
	blt.s	.error
	move.l	l2_ptr(a6),a2
	move.l	a2,a1
	add.l	l2_len(a6),a1

	move.l	source_name_addr(a6),d6
	move.l	l1_ptr(a6),a4
	move.l	tcnames_ptr(a6),d3

.l1:	cmp.l	a1,a2
	bge.s	.pass2

	move.l	16(a2),d0
	add.l	d0,d0
	lea	20(a2,d0.l),a3

	move.l	a2,a0			;trouver le module
;	bsr	tcget_source_name
	move.l	(a0),a0			;idem ci-dessus
	add.l	a4,a0
	move.l	4(a0),a0
	add.l	d3,a0

	cmp.l	a0,d6			;src @
	bne.s	.next

	move.l	12(a2),a5		;trouver la ligne
	cmp.l	a5,d7
	blt.s	.next

	cmp.l	(sp),a5
	blt.s	.next
	move.l	a5,(sp)
	move.l	a2,4(sp)
	move.l	a3,8(sp)
.next:	move.l	a3,a2
	bra.s	.l1

.pass2:	addq.l	#1,d7
	move.l	(sp),d0
	bmi.s	.error
	move.l	d0,a5
	move.l	4(sp),a2
	move.l	8(sp),a3
	
	lea	20(a2),a0
.l2:	move.b	(a0),d5
	ext.w	d5
	add.w	d5,a5
	cmp.l	a5,d7
	ble.s	.this

	addq.w	#2,a0
	cmp.l	a3,a0
	blt.s	.l2
.error:	moveq	#-1,d0
.end:	lea	$c(sp),sp
	movem.l	(sp)+,d3-d7/a2-a5
	rts
.this:	blt.s	.error
	moveq	#0,d0
	bra.s	.end

;	 #] tccheck_if_code:
;	 #[ tcget_next_code_addr:
;In:
;a0=@ in current block

;Out:
;d0=
;-1:no source, dis window, cant set break
;0:normal block (no jsr)
;1:jsr in block, a1 is branch addr
;d1=jsr addr
;a0=@ next block
;a1=branch addr

;Inside:
;a1=ending highest block addr
;a2=scanning highest block addr
;a3=next highest block addr
;a4=jsr branching addr
;d3=higher block code offset
;d4=next code addr
;d5=retour
;d6=last offset
;d7=cur addr
tcget_next_code_addr:
	movem.l	d3-d7/a2-a4,-(sp)
	move.l	a0,d7
	tst.w	source_type(a6)
	beq	.error
	jsr	get_curwind_type
	beq	.error
	sub.l	text_buf(a6),d7	;in TEXT section ?
	bmi	.error
	cmp.l	text_size(a6),d7
	bgt	.error
	;but: trouver la taille du bloc dans lequel se trouve l'@ consideree
	move.l	l2_ptr(a6),a2
	move.l	a2,a1
	add.l	l2_len(a6),a1
.l1:
	cmp.l	a1,a2
	bge	.error
	move.l	16(a2),d0
	add.l	d0,d0
	lea	20(a2,d0.l),a3

	move.l	d7,d0
	move.l	4(a2),d3
	sub.l	d3,d0
	cmp.l	8(a2),d0
	bcc	.next

	lea	20(a2),a0
.l2:
	move.b	1(a0),d6
	ext.w	d6
	ext.l	d6
	add.l	d6,d3

	cmp.l	d7,d3
	bgt.s	.this

	addq.w	#2,a0
	cmp.l	a3,a0
	blt.s	.l2

.next:	
	move.l	a3,a2
	bra.s	.l1

.this:	moveq	#0,d5		;default
	move.l	d3,d4		;debut bloc suivant
	add.l	text_buf(a6),d4
	move.l	d7,d3		;@ demandee
	add.l	text_buf(a6),d3
	move.l	d4,d6		;longueur restant a scanner
	sub.l	d3,d6
	;y-a-t-il un jsr ds le bloc courant?
	;oui, alors renvoyer l'@ de branchement du jsr et d5 a 1
.same_block:
	move.l	d3,a0
	bsr	get_instr_type
	bne.s	.chck
.again:	add.l	d2,d3
	sub.l	d2,d6
	ble.s	.end
	bra.s	.same_block
.chck:	cmp.w	#4,d0		;trap/linea/linef/
	blt.s	.no_action
	cmp.w	#11,d0
	blt.s	.branch
.rts:	add.l	text_buf(a6),d7	;rts/rte/rtr
	cmp.l	d3,d7
	beq.s	.no_action
.end:	move.l	d3,a0
	move.l	a4,a1
	move.l	d5,d0
	movem.l	(sp)+,d3-d7/a2-a4
	rts
.error:
.no_action:
	moveq	#-1,d5
	bra.s	.end
.branch:	cmp.w	#8,d0		;bsr/jsr/bcc/dbcc/jmp
	bhi.s	.again
	move.l	d3,d1
	move.l	a0,a4
	moveq	#1,d5
	move.l	d4,d3
	bra.s	.end
;	 #] tcget_next_code_addr:
;	 #[ tcprint_source_var:
;d0=buffer len
;d1=shifting_value
;a0=buffer
;a1=window
_tcprint_source_var:
	move.w	_VARWIND_OFFMAX(a1),d2
	cmp.w	d0,d2
	bgt.s	.not_max
	move.w	d0,_VARWIND_OFFMAX(a1)
.not_max:	tst.w	d1
	beq.s	.print

	bsr	strlen3
	cmp.w	d1,d0
	ble.s	.clear

	move.l	a0,a1
	add.w	d1,a0
	bsr	strcpy3
.print:	jsr	print_instruction
.add:	addq.w	#1,y_pos(a6)
	rts
.clear:	clr.b	(a0)
	bra.s	.print

;In:
;a0=var addr (l3)
;a1=buffer
;a2=window struct
;d0=shifting value
;Inside:
;d5:
tcprint_source_var:
	movem.l	d5-d7/a3-a5,-(sp)
	move.l	a0,a4
	move.l	a1,a3
	move.l	a2,a5
	move.w	d0,d7

	lea	lower_level_buffer(a6),a0
	move.l	6(a4),d0
	bsr	tcsprint_var_type

	;cdef
	tst.b	(a4)
	beq.s	.no_info

	;a0 already set is ascii buffer
	;a1 is var start addr
	move.l	a4,a1
	bsr	tcget_var_addr
	move.l	d0,a1
	;nb de car restant ds buffer
	move.l	a0,d1
	lea	lower_level_buffer(a6),a2
	sub.l	a2,d1
	move.l	#190,d0
	sub.l	d1,d0
	move.l	d0,tcvarbuffer_size(a6)
	;a2 is current var l5
	move.l	l5_ptr(a6),a2
	add.l	6(a4),a2
	;first time
	sf	tcfirst_info_flag(a6)
	;line aborted
	sf	tcline_aborted_flag(a6)
	;line ended
	sf	tcline_ended_flag(a6)
	bsr	tcsprint_var_info
.no_info:
	;type numerique (variable)
	pea	lower_level_buffer(a6)
	;nom
	move.l	tcnames_ptr(a6),a0
	add.l	2(a4),a0
	move.l	a0,-(sp)

	pea	source_var_format
	move.l	a3,a0
	bsr	sprintf3
	lea	12(sp),sp

	move.w	d7,d1
	move.l	a5,a1
	bsr	_tcprint_source_var
.end:
	movem.l	(sp)+,d5-d7/a3-a5
	rts
;	 #] tcprint_source_var:
;	 #[ tcinspect_source_var:
;d0=buffer len
;d1=shifting_value
;a0=buffer
;a1=window
_tcprint_inspect_var:
	move.w	_INSWIND_OFFMAX(a1),d2
	cmp.w	d0,d2
	bgt.s	.not_max
	move.w	d0,_INSWIND_OFFMAX(a1)
.not_max:	tst.w	d1
	beq.s	.print

	bsr	strlen3
	cmp.w	d1,d0
	ble.s	.clear

	move.l	a0,a1
	add.w	d1,a0
	bsr	strcpy3
.print:	jsr	print_instruction
.add:	addq.w	#1,y_pos(a6)
	rts
.clear:	clr.b	(a0)
	bra.s	.print


;In:
;a0=var addr (l3)
;a1=buffer
;a2=window struct
;d0=shifting value
;d1=lines nb
;d2=@
;Inside:
;a5=window
;a4=main var (l5/l6)
;a3=child var (l5)
;d7=shifting value
;d6=window lines nb
;d5=@
;d4=growing size
;d3=buffer
tcinspect_source_var:
	movem.l	d3-d7/a3-a5,-(sp)
	move.l	a0,a3
	move.l	a1,d3
	move.l	a2,a5
	move.w	d0,d7

	;cdef
	moveq	#0,d0
	move.b	(a3),d0
	move.w	d0,d6
	swap	d6

	move.w	d1,d6
	move.l	d2,d5
	move.l	_INSWIND_ELNB(a5),d4

	move.l	6(a3),a3
.do_again:
	add.l	l5_ptr(a6),a3
	move.l	10(a3),a4
	moveq	#0,d1
	move.b	(a3),d1
	sub.w	#11,d1
	bmi	.inspect_non_agregate
	bne.s	.as_ptr

	;emule le fait qu'on veut voir *ptr plutot que ptr
	move.l	d5,a0
	bsr	read_baderr
	bmi.s	.as_ptr
	move.l	d5,a0
	;prise du ptr
	move.l	(a0),d0
	sub.l	text_buf(a6),d0
	bmi.s	.as_ptr
	bsr	tcget_var_by_offset
	move.l	a0,d0
	beq.s	.as_ptr
	move.l	6(a0),a3
	move.l	d5,a0
	;reprise du ptr
	move.l	(a0),d5
	bra.s	.do_again
.as_ptr:	add.w	d1,d1
	move.w	.inspect_table(pc,d1.w),d1
	jsr	.inspect_table(pc,d1.w)
.end:	movem.l	(sp)+,d3-d7/a3-a5
	rts

.inspect_table:
	dc.w	_tcinspect_array-.inspect_table
	dc.w	_tcinspect_array-.inspect_table
	dc.w	_tcinspect_struct-.inspect_table
	dc.w	_tcinspect_struct-.inspect_table
	dc.w	_tcinspect_struct-.inspect_table
	dc.w	.end_2-.inspect_table
	dc.w	.end_2-.inspect_table

.inspect_non_agregate:
	add.l	l5_ptr(a6),a4
	moveq	#1,d0
	move.l	d0,_INSWIND_ELMAX(a5)
	lea	lower_level_buffer(a6),a0
	move.l	8(a4),d0
	bsr	tcsprint_var_type

	;a0 already set is ascii buffer
	;a1 is var start addr
	move.l	d5,a1
	;nb de car restant ds buffer
	move.l	#190,d0
	move.l	d0,tcvarbuffer_size(a6)
	;a2 is current var l5
	move.l	a4,a2
	;first time
	sf	tcfirst_info_flag(a6)
	;line aborted
	sf	tcline_aborted_flag(a6)
	;line ended
	sf	tcline_ended_flag(a6)
	bsr	tcsprint_var_info
.no_info:
	;type numerique (variable)
	pea	lower_level_buffer(a6)
	;nom de la variable
	move.l	tcnames_ptr(a6),d0
	add.l	(a4),d0
	move.l	d0,-(sp)
	pea	source_var_format
	move.l	d3,a0
	bsr	sprintf3
	lea	12(sp),sp

	move.w	d7,d1
	move.l	a5,a1
	bsr	_tcprint_inspect_var
	subq.w	#1,d6
	bmi.s	.end_2
.out:	move.l	d3,a0
	clr.b	(a0)
.clear:	jsr	print_instruction
	addq.w	#1,y_pos(a6)
	dbf	d6,.clear
.end_2:	rts

_tcinspect_array:
	swap	d6
	move.w	d4,d6
	swap	d6
	add.l	l5_ptr(a6),a4
	move.l	2(a4),d1
	mulu	d1,d4
	add.l	d4,d5
	move.l	2(a3),d0
	divu	d1,d0
	andi.l	#$ffff,d0
	move.l	d0,_INSWIND_ELMAX(a5)
.l1:	cmp.l	2(a3),d4
	bge	.out
	lea	lower_level_buffer(a6),a0
	;a0 already set is ascii buffer
	;a1 is var start addr
	move.l	d5,a1
	;nb de car restant ds buffer
	move.l	#190,d0
	move.l	d0,tcvarbuffer_size(a6)
	;a2 is current var l5
	move.l	a4,a2
	;first time
	sf	tcfirst_info_flag(a6)
	;line aborted
	sf	tcline_aborted_flag(a6)
	;line ended
	sf	tcline_ended_flag(a6)
	bsr	tcsprint_var_info
.no_info:
	;type numerique (variable)
	pea	lower_level_buffer(a6)
	;[numero]
	swap	d6
	move.w	d6,-(sp)
	swap	d6

	pea	.array_elem_var_format(pc)
	move.l	d3,a0
	bsr	sprintf3
	lea	10(sp),sp

	move.w	d7,d1
	move.l	a5,a1
	bsr	_tcprint_inspect_var

	;arraysize+=elementsize
;	move.l	8(a4),a0
;	add.l	l5_ptr(a6),a0
;	add.l	2(a0),d4
	swap	d6
	addq.w	#1,d6
	swap	d6
	add.l	2(a4),d4
	;arrayptr+=elementsize
	add.l	2(a4),d5
	dbf	d6,.l1
	bra.s	.end
.out:	move.l	d3,a0
	clr.b	(a0)
.clear:	jsr	print_instruction
	addq.w	#1,y_pos(a6)
	dbf	d6,.clear
.end:	rts
.array_elem_var_format:	dc.b	"[%=d] %s",0
	even

_tcinspect_struct:
	add.l	l6_ptr(a6),a4
	move.l	d4,d0
	mulu	#12,d0
	add.l	d0,a4
	moveq	#0,d0
	move.w	14(a3),d0
	move.l	d0,_INSWIND_ELMAX(a5)
.l1:	cmp.w	14(a3),d4
	bge	.out
	lea	lower_level_buffer(a6),a0
	move.l	8(a4),d0
	bsr	tcsprint_var_type

	swap	d6
	move.w	d6,d0
	swap	d6
	tst.w	d0
	beq.s	.no_info

	;a0 already set is ascii buffer
	;a1 is var start addr
	move.l	d5,a1
	add.l	4(a4),a1
	;nb de car restant ds buffer
	move.l	a0,d1
	lea	lower_level_buffer(a6),a2
	sub.l	a2,d1
	move.l	#190,d0
	sub.l	d1,d0
	move.l	d0,tcvarbuffer_size(a6)
	;a2 is current var l5
	move.l	8(a4),a2
	add.l	l5_ptr(a6),a2
	;first time
	sf	tcfirst_info_flag(a6)
	;line aborted
	sf	tcline_aborted_flag(a6)
	;line ended
	sf	tcline_ended_flag(a6)
	bsr	tcsprint_var_info
.no_info:
	;type numerique (variable)
	pea	lower_level_buffer(a6)
	;nom de l'element de la structure
	move.l	tcnames_ptr(a6),d0
	add.l	(a4),d0
	move.l	d0,-(sp)

	pea	source_var_format
	move.l	d3,a0
	bsr	sprintf3
	lea	12(sp),sp

	move.w	d7,d1
	move.l	a5,a1
	bsr	_tcprint_inspect_var
	addq.w	#1,d4
	lea	12(a4),a4
	dbf	d6,.l1
	bra.s	.end
.out:	move.l	d3,a0
	clr.b	(a0)
.clear:	jsr	print_instruction
	addq.w	#1,y_pos(a6)
	dbf	d6,.clear
.end:	rts
;	 #] tcinspect_source_var:
;	 #[ tcsrc_watch_var:
;In: a0=&&struct
tcsrc_watch_var:
	move.l	(a0),a0
	;cdef
;	tst.b	(a0)
;	beq.s	.end
	;verifier qu'il s'agit d'un agregat
	move.l	6(a0),a1
	add.l	l5_ptr(a6),a1
	cmp.b	#$b,(a1)
	blt.s	.end
	;chercher la valeur de la variable
	_JSR	get_var_value
	moveq	#0,d1
	rts
.end:	moveq	#-1,d1
	rts
;	 #] tcsrc_watch_var:
;	 #[ tcsrc_watch_inspect:
;a0=window
;a1=inspect
tcsrc_watch_inspect:
	move.l	a0,a5
	move.l	a1,a2
	move.l	(a2),a0
	_JSR	get_var_by_address
	bmi	.abort
	move.l	6(a0),a3
	add.l	l5_ptr(a6),a3
	move.l	10(a3),a4
	move.l	_INSWIND_ELNB(a2),d4
	moveq	#0,d0
	move.b	(a3),d0
	sub.w	#11,d0
	bmi.s	.abort
	add.w	d0,d0
	move.w	.inspect_table(pc,d0.w),d0
	jsr	.inspect_table(pc,d0.w)
	add.l	(a2),d4
	move.l	d4,a0
	_JSR	read_baderr
	bmi.s	.abort

	move.l	d4,a0
	move.l	(a0),d4

	move.l	d4,a0
	_JSR	get_var_by_address
	bmi.s	.abort

	move.l	6(a0),a0
	add.l	l5_ptr(a6),a0
	cmp.b	#11,(a0)
	blt.s	.abort
	moveq	#0,d0
.end:
	move.l	d4,d1
	rts
.abort:
	moveq	#-1,d0
	bra.s	.end

.inspect_table:
	dc.w	._watch_array-.inspect_table
	dc.w	._watch_array-.inspect_table
	dc.w	._watch_struct-.inspect_table
	dc.w	._watch_struct-.inspect_table
	dc.w	._watch_struct-.inspect_table

._watch_array:
	add.l	l5_ptr(a6),a4
	move.l	2(a4),d1
	mulu	d1,d4
	rts

._watch_struct:
	add.l	l6_ptr(a6),a4
	mulu	#12,d4
	add.l	d4,a4
	move.l	4(a4),d4
	rts
;	 #] tcsrc_watch_inspect:
;	 #[ tcget_var_addr:
;a1=l3_struct
;no_segment
;register
;a7
;a6
;code
;data
;bss
tcget_var_addr:
	move.l	10(a1),d0
	move.b	1(a1),d1
	beq.s	.no_segment
	cmp.b	#4,d1
	blt.s	.local
	add.l	text_buf(a6),d0
.no_segment:
	rts
.local:	subq.b	#1,d1
	beq.s	.register
	subq.b	#1,d1
	beq.s	.stack
;.a6:
	add.l	a6_buf(a6),d0
	rts
.stack:
	move.w	sr_buf(a6),d1
	btst	#13,d1
	bne.s	.super_stack
	add.l	a7_buf(a6),d0
	rts
.super_stack:
	add.l	ssp_buf(a6),d0
	rts
.register:
	move.l	a0,-(sp)
	;# du registre
	asl.w	#2,d0
	lea	d0_buf(a6),a0
	add.w	d0,a0
	move.l	6(a1),a1
	add.l	l5_ptr(a6),a1
	;var size (byte word long)
	move.l	2(a1),d0
	moveq	#4,d1
	sub.l	d0,d1
	add.w	d1,a0
	move.l	a0,d0
	move.l	(sp)+,a0
	rts
;	 #] tcget_var_addr:
;	 #[ tcget_var_by_offset:
;In:
;d0=bin offset
;Out:
;a0=var l3 ptr
tcget_var_by_offset:
	move.l	l3_ptr(a6),a0
	move.l	l3_len(a6),d1
	moveq	#14,d2
.l1:	cmp.l	10(a0),d0
	beq.s	.end
	sub.l	d2,d1
	ble.s	.abort
	add.w	d2,a0
	bra.s	.l1
.abort:	suba.l	a0,a0
.end:	rts
;	 #] tcget_var_by_offset:
;	 #[ tcget_var_by_address:
;In:
;a0=addr
;Out:
;d0=
;-1:not found
;0:found is var itself
;1:found is var element (l5)
;2:found is var element (l6)
;a0=var l3 ptr
;a1=element var l5/l6 ptr
tcget_var_by_address:
	movem.l	d3-d7/a2-a5,-(sp)
	move.l	a0,d0
	sub.l	text_buf(a6),d0
	bmi.s	.abort
	move.l	l3_ptr(a6),a0
	move.l	l3_len(a6),d1
	beq.s	.abort
	moveq	#14,d2
	moveq	#12,d5
.l1:
	cmp.l	10(a0),d0
	beq.s	.found_itself
	bgt.s	.check_element
.next_l3:
	sub.l	d2,d1
	ble.s	.abort
	add.w	d2,a0
	bra.s	.l1
.check_element:
	move.l	6(a0),a2
	add.l	l5_ptr(a6),a2
	move.b	(a2),d3
	cmp.b	#12,d3
	beq.s	.array
	cmp.b	#14,d3
	beq.s	.struct
	bra.s	.next_l3
.array:
	move.l	d0,d4
	sub.l	10(a0),d4
	cmp.l	2(a2),d4
	bgt.s	.next_l3
;.array_found:
	move.l	10(a2),a1
	add.l	l5_ptr(a6),a1
	move.l	2(a1),d1
	exg	d1,d4
	divu	d4,d1
	moveq	#1,d0
	bra.s	.end
.struct:
	move.l	10(a2),a1
	add.l	l6_ptr(a6),a1
	move.w	14(a2),d3
	move.l	d0,d4
	sub.l	10(a0),d4
.next_struct_elem:
	cmp.l	4(a1),d4
	beq.s	.struct_found
	subq.w	#1,d3
	beq.s	.next_l3
	add.w	d5,a1
	bra.s	.next_struct_elem
.struct_found:
	moveq	#2,d0
	bra.s	.end
.abort:
	moveq	#-1,d0
	bra.s	.end
.found_itself:
	moveq	#0,d0
.end:
	tst.l	d0
	movem.l	(sp)+,d3-d7/a2-a5
	rts
;	 #] tcget_var_by_address:
;	 #[ tcget_var_by_name:
;appele par:
;find in table
;put in table
;sizeof
;In:
;a0:points on name string
;d0:is completion flag
;Out:
;a0:points on var struct
;d0:is var value
;d1:is success
tcget_var_by_name:
	movem.l	d5-d7/a2-a4,-(sp)
	move.l	a0,a2
	move.l	d0,d7
	moveq	#TCVARS_SIZEOF,d5
	move.l	tcnames_ptr(a6),a4
	;locals
	move.l	locals_nb(a6),d6
	beq.s	.no_locals
	move.l	locals_array_ptr(a6),a3

.l1:	move.l	(a3),a0
	move.l	2(a0),a0
	add.l	a4,a0
	move.l	a2,a1
	move.l	d7,d0
	bsr	var_strcmp
	beq.s	.found
	add.w	d5,a3
	subq.l	#1,d6
	bgt.s	.l1
.no_locals:
	;statics
	move.l	statics_nb(a6),d6
	beq.s	.no_statics
	move.l	statics_array_ptr(a6),a3
.s1:
	move.l	(a3),a0
	move.l	2(a0),a0
	add.l	a4,a0
	move.l	a2,a1
	move.l	d7,d0
	bsr	var_strcmp
	beq.s	.found
	add.w	d5,a3
	subq.l	#1,d6
	bgt.s	.s1
.no_statics:
	;globals
	move.l	globals_nb(a6),d6
	beq.s	.no_globals
	move.l	globals_array_ptr(a6),a3

.g1:	move.l	(a3),a0
	move.l	2(a0),a0
	add.l	a4,a0
	move.l	a2,a1
	move.l	d7,d0
	bsr	var_strcmp
	beq.s	.found
	add.w	d5,a3
	subq.l	#1,d6
	bgt.s	.g1
.no_globals:
	;cdefs
	move.l	cdefs_nb(a6),d6
	beq.s	.no_cdefs
	move.l	cdefs_array_ptr(a6),a3

.c1:	move.l	(a3),a0
	move.l	2(a0),a0
	add.l	a4,a0
	move.l	a2,a1
	move.l	d7,d0
	bsr	var_strcmp
	beq.s	.found
	add.w	d5,a3
	subq.l	#1,d6
	bgt.s	.c1
.no_cdefs:
	bra.s	.not_found
.found:	move.l	(a3),a0
	bsr	get_var_value
	;var struct
	move.l	(a3),a0
	;d0 is var value
	moveq	#0,d1
.end:	movem.l	(sp)+,d5-d7/a2-a4
	rts
.not_found:
	moveq	#-1,d1
	bra.s	.end
;	 #] tcget_var_by_name:
;	 #[ tcget_var_value:
;renvoie la valeur de la variable suivant son type
;In:
;a0=var l3 ptr
;Out:
;d0=var value
tcget_var_value:
	move.l	a0,-(sp)
	move.l	a0,a1
	bsr	tcget_var_addr
	move.l	d0,a0
	move.l	(sp)+,a1

;renvoie la valeur de la variable suivant son type
;In:
;a0=addr
;a1=var l3 ptr
;Out:
;d0=var value
_tcget_var_value:
	movem.l	a2-a3,-(sp)
	;cdef
	tst.b	(a1)
	beq.s	.end

	move.l	a0,d0
	move.l	a1,a3

	move.l	6(a3),a2
	add.l	l5_ptr(a6),a2
	moveq	#0,d1
	move.b	(a2),d1
	cmp.w	#$11,d1
	bgt.s	.end
	add.w	d1,d1
	move.w	.var_funcs_table(pc,d1.w),d1
	jsr	.var_funcs_table(pc,d1.w)
.end:	movem.l	(sp)+,a2-a3
	rts
.var_funcs_table:
	dc.w	.nothing-.var_funcs_table		;0
	dc.w	.char-.var_funcs_table		;1
	dc.w	.uchar-.var_funcs_table		;2
	dc.w	.int-.var_funcs_table		;3
	dc.w	.uint-.var_funcs_table		;4
	dc.w	.long-.var_funcs_table		;5
	dc.w	.ulong-.var_funcs_table		;6
	dc.w	.float-.var_funcs_table		;7
	dc.w	.double-.var_funcs_table		;8
	dc.w	.ldouble-.var_funcs_table		;9
	dc.w	.void-.var_funcs_table		;A
	dc.w	.pointer-.var_funcs_table		;B
	dc.w	.array-.var_funcs_table		;C
	dc.w	.enum-.var_funcs_table		;D
	dc.w	.struct-.var_funcs_table		;E
	dc.w	.union-.var_funcs_table		;F
	dc.w	.func-.var_funcs_table		;10
	dc.w	.bitfield-.var_funcs_table		;11

.char:	move.b	(a0),d0
	IFEQ	68000
	extb	d0
	ELSEIF
	ext.w	d0
	ext.l	d0
	ENDC	;de 68000
	rts
.uchar:	moveq	#0,d0
	move.b	(a0),d0
	rts
.enum:
.int:	move.w	(a0),d0
	ext.l	d0
	rts
.uint:	moveq	#0,d0
	move.w	(a0),d0
	rts
.long:
.ulong:
.pointer:	move.l	(a0),d0
	rts
.nothing:
.float:
.double:
.ldouble:
.void:
.array:
.struct:
.union:
.func:	;deja ds d0
	rts
.bitfield:
	moveq	#0,d0
	move.w	(a0),d0
	moveq	#0,d1
	move.b	$f(a2),d1
	moveq	#0,d2
	move.b	$e(a2),d2

	move.l	10(a2),a1
	add.l	l5_ptr(a6),a1
	cmp.b	#4,(a1)
	beq	.get_ubf_value
	bsr	tcget_sbf_value
	ext.l	d0
	rts
.get_ubf_value:
	bsr	tcget_ubf_value
	andi.l	#$ffff,d0
	rts	
;	 #] tcget_var_value:
;	 #[ tcset_var_value:
;a0=var struct (l3 ptr)
;d0=new value
tcset_var_value:
	movem.l	d7/a2-a3,-(sp)
	;cdef
	tst.b	(a0)
	beq.s	.end
	move.l	a0,a3
	move.l	d0,d7
	move.l	a3,a1
	bsr	tcget_var_addr
	move.l	d0,a0
	move.l	6(a3),a2
	add.l	l5_ptr(a6),a2
	moveq	#0,d1
	move.b	(a2),d1
	cmp.w	#$11,d1
	bgt.s	.end
	move.l	d7,d0
	add.w	d1,d1
	move.w	.var_funcs_table(pc,d1.w),d1
	jsr	.var_funcs_table(pc,d1.w)
.end:
	movem.l	(sp)+,d7/a2-a3
	rts

.var_funcs_table:
	dc.w	.nothing-.var_funcs_table	;0
	dc.w	.char-.var_funcs_table		;1
	dc.w	.uchar-.var_funcs_table		;2
	dc.w	.int-.var_funcs_table		;3
	dc.w	.uint-.var_funcs_table		;4
	dc.w	.long-.var_funcs_table		;5
	dc.w	.ulong-.var_funcs_table		;6
	dc.w	.float-.var_funcs_table		;7
	dc.w	.double-.var_funcs_table	;8
	dc.w	.ldouble-.var_funcs_table	;9
	dc.w	.void-.var_funcs_table		;A
	dc.w	.pointer-.var_funcs_table	;B
	dc.w	.array-.var_funcs_table		;C
	dc.w	.enum-.var_funcs_table		;D
	dc.w	.struct-.var_funcs_table	;E
	dc.w	.union-.var_funcs_table		;F
	dc.w	.func-.var_funcs_table		;10
	dc.w	.bitfield-.var_funcs_table	;11

.char:
.uchar:	move.b	d0,(a0)
	rts
.enum:
.int:
.uint:	move.w	d0,(a0)
	rts
.long:
.ulong:
.pointer:
.array:
.struct:
.union:
.func:	move.l	d0,(a0)

.float:
.double:
.ldouble:
.void:
.nothing:	rts
.bitfield:
	move.w	(a0),d0
	moveq	#0,d1
	move.b	$f(a2),d1
	moveq	#0,d2
	move.b	$e(a2),d2

	move.l	10(a2),a1
	add.l	l5_ptr(a6),a1
	cmp.b	#4,(a1)
	beq.s	tcset_ubf_value
;	bra.s	tcset_sbf_value

;d0=value
;d1=bf offset
;d2=bf length
tcset_sbf_value:
	lsr.w	d2,d0
	moveq	#16,d2
	sub.b	d1,d2
	asl.w	d2,d0
	move.w	d0,(a0)
	rts

;d0=value
;d1=bf offset
;d2=bf length
tcset_ubf_value:
	move.l	d3,-(sp)
	moveq	#16,d3
	sub.b	d2,d3
	sub.b	d1,d3
	lsr.w	d3,d0

	moveq	#1,d3
	lsl.w	d1,d3
	subq.w	#1,d3
	and.w	d3,d0
	move.w	d0,(a0)
	move.l	(sp)+,d3
	rts

;	 #] tcset_var_value:
;	 #[ tcsprint_var_info:
VAR_STACK_SECURITY	equ	1024

;poke la valeur de la variable en C
;Input:
;a0 is ascii buffer	->a0
;a1 is current var start address	->a3
;a2 is current var l5	->a4
;d0 is buffer max size (0=first,else second)	->d7
;In:
;a0 is ascii buffer
;a1 is dummy ptr
;a2 is dummy ptr

;a3 is current var address
;a4 is current var l5
;a5 is

;d3 is element size
;d4 is elements nb
;d5 is
;d6 is
;d7 is buffer current size
tcsprint_var_info:
	movem.l	d3-d7/a3-a5,-(sp)

	move.l	d0,d7
	move.w	d1,d6
	move.l	a1,a3
	move.l	a2,a4

	;stack checking
	move.l	reserved_stack_addr(a6),d1
	add.l	#VAR_STACK_SECURITY,d1
	cmp.l	d1,sp
	ble.s	.end

	;buffer checkings

	;logical
;	move.l	tcvarbuffer_size(a6),d0
;	sub.l	d7,d0
;	cmp.l	curwind_columns(a6),d0
;	bge.s	.ended

	tst.w	d7	;physical
	ble.s	.abort

	moveq	#0,d0
	move.b	(a4),d0
	cmp.w	#$11,d0
	bgt.s	.end
	add.w	d0,d0
	move.w	.var_funcs_table(pc,d0.w),d0
	jsr	.var_funcs_table(pc,d0.w)
.end:	move.l	d7,d0
	clr.b	(a0)
	movem.l	(sp)+,d3-d7/a3-a5
	rts
.abort:	;neg.w	d7
;	move.l	tcvarbuffer_size(a6),d0
;	lea	lower_level_buffer(a6),a1
	st	tcline_aborted_flag(a6)
	bra.s	.end
.ended:	st	tcline_ended_flag(a6)
	bra.s	.end

.var_funcs_table:
	dc.w	.nothing-.var_funcs_table	;0
	dc.w	.char-.var_funcs_table		;1
	dc.w	.uchar-.var_funcs_table		;2
	dc.w	.int-.var_funcs_table		;3
	dc.w	.uint-.var_funcs_table		;4
	dc.w	.long-.var_funcs_table		;5
	dc.w	.ulong-.var_funcs_table		;6
	dc.w	.float-.var_funcs_table		;7
	dc.w	.double-.var_funcs_table	;8
	dc.w	.ldouble-.var_funcs_table	;9
	dc.w	.void-.var_funcs_table		;A
	dc.w	.pointer-.var_funcs_table	;B
	dc.w	.array-.var_funcs_table		;C
	dc.w	.enum-.var_funcs_table		;D
	dc.w	.struct-.var_funcs_table	;E
	dc.w	.union-.var_funcs_table		;F
	dc.w	.func-.var_funcs_table		;10
	dc.w	.bitfield-.var_funcs_table	;11

.char:
.uchar:	lea	.char_text(pc),a1
	bra.s	.sprint_twice
.char_text:	dc.b	"'%=bC@'=0x%=bx@",0
	even

.int:	lea	.int_text(pc),a1
	bra.s	.sprint_once
.int_text:	dc.b	"%=Sd@",0
	even

.uint:	lea	.uint_text(pc),a1
	bra.s	.sprint_once
.uint_text:	dc.b	"%=d@U",0
	even

.long:	lea	.long_text(pc),a1
	bra.s	.sprint_once
.long_text:	dc.b	"%=lSd@L",0
	even

.ulong:	lea	.ulong_text(pc),a1
	bra.s	.sprint_once
.ulong_text:	dc.b	"%=ld@UL",0
	even

.float:
.double:
.ldouble:	lea	.double_text(pc),a1
	bra.s	.sprint_once
.double_text:	dc.b	"%=D@",0
	even

.sprint_once:
	bsr	.poke_equal
	;@
	move.l	a3,-(sp)
	;format
	move.l	a1,-(sp)
	bsr	sprintf3
	addq.w	#8,sp
	add.w	d0,a0
	sub.w	d0,d7
	rts

.sprint_twice:
	bsr	.poke_equal
	;@
	move.l	a3,-(sp)
	;@
	move.l	a3,-(sp)
	;format
	move.l	a1,-(sp)
	bsr	sprintf3
	lea	12(sp),sp
	add.w	d0,a0
	sub.w	d0,d7
	rts

.poke_equal:
	tst.b	tcfirst_info_flag(a6)
	bne.s	.equal_end
	move.b	#'=',(a0)+
	subq.l	#1,d7
.equal_end:
	rts

.void:	move.b	#'v',(a0)+
	move.b	#'o',(a0)+
	subq.l	#2,d7
	rts

.pointer:	;read_baderr
	move.l	a0,-(sp)
	move.l	a3,a0
	bsr	read_baderr
	move.l	(sp)+,a0
	bne.s	.unknown_pointer
	move.l	(a3),a3
	;emulation de NULL
	move.l	a3,d0
	beq	.func
	move.l	a0,-(sp)
	move.l	a3,a0
	bsr	tcget_var_by_address
	move.l	a0,a1
	move.l	(sp)+,a0
	bne.s	.unknown_pointer
	bsr	.poke_equal
	move.b	#'&',(a0)+
	move.l	2(a1),a1
	add.l	tcnames_ptr(a6),a1
	exg	a0,a1
	bsr	strcpy3
	lea	-1(a1,d0.w),a0
	rts
;	move.l	l5_ptr(a6),a4
;	add.l	6(a1),a4
;	bra.s	.not_string_array
.unknown_pointer:
;	bsr	.get_type
	move.l	l5_ptr(a6),a1
	add.l	10(a4),a1
	cmp.b	#1,(a1)
	beq.s	.string_pointer
	cmp.b	#2,(a1)
;	beq.s	.string_pointer
;	bra	.func
	bne	.func
.string_pointer:
	lea	.string_text(pc),a1
	bra	.sprint_once

.array:	move.l	l5_ptr(a6),a1
	add.l	10(a4),a1
	cmp.b	#1,(a1)
	beq.s	.string_array
	cmp.b	#2,(a1)
	bne.s	.not_string_array

.string_array:
	lea	.string_text(pc),a1
	bsr	.sprint_once
	subq.w	#1,d0
	ext.l	d0

	cmp.l	2(a4),d0
	ble.s	.string_end
	move.b	#'+',(a0)+
	subq.l	#1,d7
.string_end:
	rts
.string_text:
	dc.b	'"%s@"',0
	even

.not_string_array:
	bsr	.poke_equal
;	bsr	.get_type
	;not first time
	st	tcfirst_info_flag(a6)
	move.b	#'{',(a0)+
	subq.l	#1,d7
	;nb d'elements
	moveq	#0,d4
	;taille element courant
	move.l	2(a4),d3
.more_array_element:
	move.l	d4,d0
	bsr	poke_between_brackets
	sub.w	d0,d7

	move.l	l5_ptr(a6),a2
	add.l	10(a4),a2
	move.l	a3,a1
	move.l	d7,d0
	move.l	a2,-(sp)
	bsr	tcsprint_var_info
	move.l	(sp)+,a2
	move.l	d0,d7
	;plus 1 element
	addq.l	#1,d4
	;taille element fils
	add.l	2(a2),a3
	sub.l	2(a2),d3
	ble.s	.end_of_array
;	cmp.w	14(a4),d4
;	bge.s	.end_of_array
	;overflow?
	tst.b	tcline_aborted_flag(a6)
	bne.s	.interrupt_array
	;line ended?
	tst.b	tcline_ended_flag(a6)
	bne.s	.array_ended
	move.b	#',',(a0)+
	subq.l	#1,d7
	bra.s	.more_array_element
.end_of_array:
	move.b	#'}',(a0)+
	subq.l	#1,d7
.array_ended:
	rts
.interrupt_array:
	moveq	#'.',d0
	move.b	d0,(a0)+
	move.b	d0,(a0)+
	move.b	d0,(a0)+
	subq.l	#3,d7
	bra.s	.end_of_array

.struct:
.union:
	bsr	.poke_equal
	bsr	.get_type
	;not first time
	st	tcfirst_info_flag(a6)
	move.b	#'{',(a0)+
	subq.l	#1,d7
	moveq	#0,d4	;nb d'elements
	move.l	2(a4),d3	;taille element courant
.more_struct_element:
	move.l	a4,a1
	move.l	d4,d0
	bsr	get_l6_ptr
	move.l	a1,a2
	;offset element fils
	move.l	a3,a1
	add.l	4(a2),a1

	move.l	8(a2),a2
	add.l	l5_ptr(a6),a2

	move.l	d7,d0
	bsr	tcsprint_var_info
	move.l	d0,d7
	;plus 1 element
	addq.l	#1,d4
	;taille element fils
	sub.l	2(a2),d3
;	ble.s	.end_of_array
	cmp.w	14(a4),d4
	bge.s	.end_of_array

	;overflow?
	tst.b	tcline_aborted_flag(a6)
	bne.s	.interrupt_array
	;line ended?
	tst.b	tcline_ended_flag(a6)
	bne.s	.array_ended
	move.b	#',',(a0)+
	subq.l	#1,d7
	bra.s	.more_struct_element

.enum:
	moveq	#0,d4
	moveq	#0,d2
	move.w	(a3),d2
.enum_l1:
	move.l	a4,a1
	move.l	d4,d0
	bsr	get_l6_ptr
	cmp.l	4(a1),d2
	beq.s	.enum_found
	addq.l	#1,d4
	cmp.w	14(a4),d4
	blt.s	.enum_l1
	;valeur non trouvee
	bra	.int
.enum_found:
	bsr	.poke_equal
	move.l	a0,-(sp)
	move.l	(a1),a1
	add.l	tcnames_ptr(a6),a1
	exg	a0,a1
	bsr	strcpy3
	move.l	(sp)+,a0
	subq.w	#1,d0
	add.w	d0,a0
	sub.w	d0,d7
	rts

.func:
	move.l	a3,d0
	beq.s	.null
	;profiler
	lea	.func_text(pc),a1
	bra	.sprint_once
.func_text:
	dc.b	"0x%=lxL",0
	even
.null:
	move.l	a0,d0
	btst	#0,d0
	beq.s	.poke_null_long
	move.b	#'N',(a0)+
	move.w	#'UL',(a0)+
	move.b	#'L',(a0)+
	subq.l	#4,d7
	rts
.poke_null_long:
	move.l	#'NULL',(a0)+
	subq.l	#4,d7
	rts

.bitfield:
;	moveq	#0,d3
;	move.b	$f(a4),d3
;	moveq	#0,d4
;	move.b	$e(a4),d4
	move.w	(a3),d0
	moveq	#0,d1
	move.b	$f(a4),d1
	move.w	d1,d3
	moveq	#0,d2
	move.b	$e(a4),d2

	move.l	10(a4),a1
	add.l	l5_ptr(a6),a1
	cmp.b	#4,(a1)
	bne.s	.signed_bitfield
	bsr	tcget_ubf_value
	lea	.u_bitfield_text(pc),a1
	bra.s	.sprint_bitfield
.signed_bitfield:
	bsr	tcget_sbf_value
	lea	.bitfield_text(pc),a1
.sprint_bitfield:
	move.w	d3,-(sp)
	move.w	d0,-(sp)
	move.l	a1,-(sp)
	bsr	sprintf3
	addq.w	#8,sp
	add.w	d0,a0
	sub.w	d0,d7
	rts
.bitfield_text:
	dc.b	"%=Sd:%=d",0
.u_bitfield_text:
	dc.b	"%=dU:%=d",0
	even
.nothing:
	rts

;ecrit le type de la variable
.get_type:
	;if not first time
	tst.b	tcfirst_info_flag(a6)
	beq.s	.first_time_so_no_type
	move.l	a0,-(sp)
;	move.b	#'(',(a0)+

	move.l	a4,d0
	sub.l	l5_ptr(a6),d0
	bsr	tcsprint_var_type

	move.b	#')',(a0)+
	clr.b	(a0)
	move.l	(sp)+,a0
	;j'ecrase le premier espace par (
	move.b	#'(',(a0)
	bsr	strlen3
	add.w	d0,a0
	sub.w	d0,d7
.first_time_so_no_type:
	rts

;a1 is l5 ptr
;d0 is element nb
get_l6_ptr:
	move.l	10(a1),a1
	add.l	l6_ptr(a6),a1
	mulu	#12,d0
	add.l	d0,a1
	rts

;d0=value
;d1=bf offset
;d2=bf length
tcget_ubf_value:
	move.l	d3,-(sp)
	moveq	#16,d3
	sub.b	d2,d3
	sub.b	d1,d3
	lsr.w	d3,d0

	moveq	#1,d3
	lsl.w	d1,d3
	subq.w	#1,d3
	and.w	d3,d0
	move.l	(sp)+,d3
	rts
;	moveq	#16,d1
;	sub.b	d4,d1
;	sub.b	d3,d1
;	lsr.w	d1,d0
;	moveq	#1,d2
;	lsl.w	d3,d2
;	subq.w	#1,d2
;	and.w	d2,d0

;d0=value
;d1=bf offset
;d2=bf length
tcget_sbf_value:
	lsl.w	d2,d0
	moveq	#16,d2
	sub.b	d1,d2
	asr.w	d2,d0
	rts
;	moveq	#16,d1
;	lsl.w	d4,d0
;	sub.b	d3,d1
;	asr.w	d1,d0
;	 #] tcsprint_var_info:
;	 #[ tcsprint_var_name_info:
;a0=ASCII buffer
;d0=var addr
tcsprint_var_name_info:
	movem.l	d3/a2-a4,-(sp)
	move.l	a0,a4
	move.l	d0,d3
	bsr	sprint_var_name
	bmi.s	.end
	;a0 already set is ascii buffer
	;a1 is type ptr
	move.l	a1,a2
	;nb de car restant ds buffer
	move.l	a4,a1
	move.l	a0,d1
	sub.l	a1,d1
	move.l	d3,a1
	moveq	#0,d0
	move.w	line_len(a6),d0
	sub.l	d1,d0
	move.l	d0,tcvarbuffer_size(a6)
	;first time
	sf	tcfirst_info_flag(a6)
	;line aborted
	sf	tcline_aborted_flag(a6)
	;line ended
	sf	tcline_ended_flag(a6)
	bsr	tcsprint_var_info
	moveq	#0,d0
.end:
	movem.l	(sp)+,d3/a2-a4
	rts
.no_source:
	moveq	#-1,d0
	bra.s	.end
;	 #] tcsprint_var_name_info:
;	 #[ tcsprint_var_name:
;a0=ASCII buffer
;d0=var addr
tcsprint_var_name:
	movem.l	a2-a4,-(sp)
	move.l	a0,a4

	move.l	d0,a0
	bsr	tcget_var_by_address
	bmi	.no_source
	move.l	a0,a3
	move.l	a1,a5
	move.l	a4,a0
	beq.s	.itself
	subq.w	#1,d0
	beq.s	.array
;.struct:
	move.l	2(a3),a0
	add.l	tcnames_ptr(a6),a0
	move.l	a4,a1
	bsr	strcpy3
	add.w	d0,a1
	move.b	#'.',-1(a1)
	move.l	(a5),a0
	add.l	tcnames_ptr(a6),a0
	bsr	strcpy3
	lea	-1(a1,d0.w),a0
	move.l	8(a5),d0
	bra.s	.as_itself
.array:
	move.l	2(a3),a0
	add.l	tcnames_ptr(a6),a0
	move.l	a4,a1
	bsr	strcpy3
	lea	-1(a1,d0.w),a0
	move.w	d1,d0
	bsr	poke_between_brackets
	move.l	10(a5),d0
	bra.s	.as_itself
.itself:
	move.l	6(a3),d0
.as_itself:
	;a2 is current var l5
	move.l	l5_ptr(a6),a2
	add.l	d0,a2
	bsr	tcsprint_var_type
.end:
	move.l	a2,a1
	movem.l	(sp)+,a2-a4
	rts
.no_source:
	move.l	a4,a0
	moveq	#-1,d0
	bra.s	.end
;	 #] tcsprint_var_name:
;	 #[ tcsprint_var_type:
;a0=buffer
;d0=l5_offset
tcsprint_var_type:
	move.l	reserved_stack_addr(a6),d1	;stack checking
	add.l	#VAR_STACK_SECURITY,d1
	cmp.l	d1,sp
	ble	.end
	move.l	l5_ptr(a6),a1
	add.l	d0,a1
	move.b	(a1),d1		;type
	sub.b	#$b,d1		;simple?
	bmi	.return
	ext.w	d1		;complexe, je renvoie
	cmp.w	#$11-$b,d1
	bgt	.end
	move.w	d1,-(sp)		;je sauve le type complexe
	bsr	.put_struct_name
	cmp.w	#$d-$b,(sp)	;enum
	beq.s	.no_more
	cmp.w	#$e-$b,(sp)	;struct
	beq.s	.no_more
	cmp.w	#$f-$b,(sp)	;union
	beq.s	.no_more
	move.l	10(a1),d0		;ptr,array,func,bit
	move.l	a1,-(sp)
	bsr	tcsprint_var_type
	move.l	(sp)+,a2
.no_more:	move.w	(sp)+,d0
	beq.s	.pointer		;ptr
	cmp.w	#1,d0		;array
	beq.s	.array
;	cmp.w	#2,d0		;enum
;	beq.s	.space
	cmp.w	#5,d0		;func
	beq.s	.func
	bra	.end
;.space:
;	move.b	#' ',(a0)+
;	bra	.end
.pointer:	move.b	#'*',(a0)+
	bra	.end
.array:	move.l	2(a2),d0		;get elements #
	move.l	l5_ptr(a6),a1
	add.l	10(a2),a1

	move.l	2(a1),d1
	divu	d1,d0
	ext.l	d0
;	moveq	#0,d0
;	move.w	14(a2),d0
	bra	poke_between_brackets
.func:	move.b	#'(',(a0)+
	move.b	#')',(a0)+
	bra.s	.end

;type simple
.return:	move.l	a1,-(sp)
	move.b	(a1),d0
	;retrouver une variable en dur correspondant, et lui faire adopter son type
	;apparemment surtout pour les ptrs sur fct
;	beq.s	.recheck_var

	move.l	a0,a1
	ext.w	d0
	add.w	d0,d0
	move.w	.var_types_table(pc,d0.w),d0
	lea	.text_array(pc,d0.w),a0
	bsr	strcpy3
	lea	-1(a1,d0.w),a0
	move.l	(sp)+,a1
.end:	clr.b	(a0)
	rts

.var_types_table:
	dc.w	.unknown_type0_text-.text_array	;0
	dc.w	.char_text-.text_array		;1
	dc.w	.uchar_text-.text_array		;2
	dc.w	.int_text-.text_array		;3
	dc.w	.uint_text-.text_array		;4
	dc.w	.long_text-.text_array		;5
	dc.w	.ulong_text-.text_array		;6
	dc.w	.float_text-.text_array		;7
	dc.w	.double_text-.text_array		;8
	dc.w	.long_double_text-.text_array		;9
	dc.w	.void_text-.text_array		;10
	dc.w	.pointer_text-.text_array		;11
	dc.w	.array_text-.text_array
	dc.w	.enum_text-.text_array
	dc.w	.struct_text-.text_array
	dc.w	.union_text-.text_array
	dc.w	.func_text-.text_array
	dc.w	.bitfield_text-.text_array

.text_array:
.unknown_type0_text:	dc.b	" ???? ",0
.char_text:	dc.b	" char ",0
.uchar_text:	dc.b	" u_char ",0
.int_text:	dc.b	" int ",0
.uint_text:	dc.b	" u_int ",0
.long_text:	dc.b	" long ",0
.ulong_text:	dc.b	" u_long ",0
.float_text:	dc.b	" float ",0
.double_text:	dc.b	" double ",0
.long_double_text:	dc.b	" long double ",0
.void_text:	dc.b	" void ",0
.pointer_text:	dc.b	" pointer ",0
.array_text:	dc.b	" array ",0
.enum_text:	dc.b	" enum ",0
.struct_text:	dc.b	" struct ",0
.union_text:	dc.b	" union ",0
.func_text:	dc.b	" func ",0
.bitfield_text:	dc.b	" bitfield ",0
	even

.put_struct_name:
	move.l	6(a1),d0		;ce type a-t-il un nom?
	beq.s	.end_struct_name
	cmp.l	l3_len(a6),d0	;sanity check
	bge.s	.end_struct_name
	move.l	a1,-(sp)		;le ptr vers la struct sauve
	add.l	l3_ptr(a6),d0
	move.l	d0,a1
	move.l	2(a1),a1
	cmp.l	tcnames_len(a6),a1	;sanity check
	bge.s	.end_struct_movem
	add.l	tcnames_ptr(a6),a1
	move.b	#' ',(a0)+
	exg	a0,a1
	bsr	strcpy3
	lea	-1(a1,d0.w),a0
	move.b	#' ',(a0)+
.end_struct_movem:
	move.l	(sp)+,a1
.end_struct_name:
	rts

;.recheck_var:
;	bsr	tcget_var_by_addr
;	 #] tcsprint_var_type:
;	 #[ tcsprint_stack:
;In:
;d0=value
;a0=buffer
tcsprint_stack:
	movem.l	d5-d6/a2-a3,-(sp)
	move.l	d0,d6
	move.l	a0,a3
	move.l	l2_ptr(a6),a2
	move.l	l2_len(a6),d5
	beq.s	.none

.more_l2:	move.l	d6,d1
	sub.l	4(a2),d1
	cmp.l	8(a2),d1
	bcc.s	.next_l2
	move.l	4(a2),d0

	move.l	funcs_array_ptr(a6),a1
	move.l	funcs_nb(a6),d1
	beq.s	.none
.more_l3:	move.l	(a1)+,a0
	cmp.l	10(a0),d0
;	bne.s	.next_l3
;	cmp.b	#7,(a0)
;	beq.s	.func
;	cmp.b	#8,(a0)
;	beq.s	.func
	beq.s	.found
;.next_l3:
	subq.l	#1,d1
	bgt.s	.more_l3
.next_l2:	moveq	#20,d0
	move.l	16(a2),d1
	add.l	d1,d1
	add.l	d1,d0
	add.l	d0,a2
	sub.l	d0,d5
	beq.s	.none		;.l1
	bra.s	.more_l2
;.func:
.found:	move.l	12(a2),-(sp)
	addq.l	#1,(sp)
	move.l	(a2),a1
	add.l	l1_ptr(a6),a1
	move.l	4(a1),a1
	add.l	tcnames_ptr(a6),a1
	move.l	a1,-(sp)
	move.l	2(a0),a0
	add.l	tcnames_ptr(a6),a0
	move.l	a0,-(sp)
	pea	source_stack_format
	move.l	a3,a0
	jsr	sprintf
	lea	16(sp),sp
	moveq	#0,d0
.end:	movem.l	(sp)+,d5-d6/a2-a3
	rts
.none:	moveq	#-1,d0
	bra.s	.end
;	 #] tcsprint_stack:
;;		#] Pure C:
	ENDC	;de turbodebug
	IFNE	latticedebug
;;		#[ Lattice C:
;	 #[ lcget_array_elem_value:
lcget_array_elem_value:
	rts
;	 #] lcget_array_elem_value:
;	 #[ lcget_amper_value:
lcget_amper_value:
	rts
;	 #] lcget_amper_value:
;	 #[ lcupdate_source:
lcupdate_source:
	rts
;	 #] lcupdate_source:
;	 #[ lcbegin_source_debug:
lcbegin_source_debug:
	rts
;	 #] lcbegin_source_debug:
;	 #[ lcupdate_vars_array:
lcupdate_vars_array:
	rts
;	 #] lcupdate_vars_array:
;	 #[ lcget_source_addr:
lcget_source_addr:
	rts
;	 #] lcget_source_addr:
;	 #[ lcget_source_name:
lcget_source_name:
lcget_mod_name:
	rts
;	 #] lcget_source_name:
;	 #[ lcget_var_name:
;In:
;a0=var structure @
;Out:
;a0=source name
lcget_var_name:
	suba.l	a0,a0
	rts
;	 #] lcget_var_name:
;	 #[ lcget_code_addr:
lcget_code_addr:
	rts
;	 #] lcget_code_addr:
;	 #[ lccheck_if_code:
lccheck_if_code:
	rts
;	 #] lccheck_if_code:
;	 #[ lcget_next_code_addr:
lcget_next_code_addr:
	rts
;	 #] lcget_next_code_addr:
;	 #[ lcprint_source_var:
lcprint_source_var:
	rts
;	 #] lcprint_source_var:
;	 #[ lcinspect_source_var:
lcinspect_source_var:
	rts
;	 #] lcinspect_source_var:
;	 #[ lcsrc_watch_var:
;In: a0=&&struct
lcsrc_watch_var:
	moveq	#-1,d1
	rts
;	 #] lcsrc_watch_var:
;	 #[ lcsrc_watch_inspect:
;a0=window
;a1=inspect
lcsrc_watch_inspect:
	moveq	#-1,d0
	rts
;	 #] lcsrc_watch_inspect:
;	 #[ lcget_var_addr:
lcget_var_addr:
	rts
;	 #] lcget_var_addr:
;	 #[ lcget_var_by_offset:
lcget_var_by_offset:
	rts
;	 #] lcget_var_by_offset:
;	 #[ lcget_var_by_address:
lcget_var_by_address:
	rts
;	 #] lcget_var_by_address:
;	 #[ lcget_var_by_name:
lcget_var_by_name:
	rts
;	 #] lcget_var_by_name:
;	 #[ lcget_var_value:
lcget_var_value:
	rts
;	 #] lcget_var_value:
;	 #[ lcset_var_value:
lcset_var_value:
	rts
;	 #] lcset_var_value:
;	 #[ lcsprint_var_info:
lcsprint_var_info:
	rts
;	 #] lcsprint_var_info:
;	 #[ lcsprint_var_name_info:
lcsprint_var_name_info:
	rts
;	 #] lcsprint_var_name_info:
;	 #[ lcsprint_var_name:
lcsprint_var_name:
	rts
;	 #] lcsprint_var_name:
;	 #[ lcsprint_var_type:
lcsprint_var_type:
	rts
;	 #] lcsprint_var_type:
;	 #[ lcsprint_stack:
lcsprint_stack:
	moveq	#-1,d0
	rts
;	 #] lcsprint_stack:
;;		#] Lattice C:
	ENDC	;de latticedebug

