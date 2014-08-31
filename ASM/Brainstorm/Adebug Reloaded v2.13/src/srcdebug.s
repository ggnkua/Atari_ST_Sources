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

;Accesseurs
;	 #[ get_sizeof:
;In:a1=struct @
;Out:d0=struct sizeof
get_sizeof:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcget_sizeof
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcget_sizeof
	ENDC	;de turbodebug
	moveq	#-1,d0
	rts
;	 #] get_sizeof: 
;	 #[ get_array_elem_value:
;Input:
;a0=name
;a1=result buffer
;d0=elem nb
;Output:
;d0=-1->not_found
get_array_elem_value:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcget_array_elem_value
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcget_array_elem_value
	ENDC	;de turbodebug
	moveq	#-1,d0
	rts
;	 #] get_array_elem_value: 
;	 #[ get_amper_value:
;Input:
;a0=name
;Output:
;d0=@
;d1=reussite
get_amper_value:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcget_amper_value
	ENDC	;de turbodebug
	moveq	#-1,d1
	rts
;	 #] get_amper_value: 
;	 #[ update_source:
update_source:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcupdate_source
	ENDC	;de turbodebug
	rts
;	 #] update_source: 
;	 #[ begin_source_debug:
begin_source_debug:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcbegin_source_debug
	ENDC
	rts
;	 #] begin_source_debug: 
;	 #[ update_vars_array:
update_vars_array:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcupdate_vars_array
	ENDC
	rts
;	 #] update_vars_array: 
;	 #[ get_source_addr:
;d0=addr bin
get_source_addr:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcget_source_addr
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcget_source_addr
	ENDC	;de latticedebug
	moveq	#0,d0
	rts
;	 #] get_source_addr: 
;	 #[ get_source_name:
;a0=struct
get_source_name:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcget_source_name
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcget_source_name
	ENDC	;de latticedebug
	moveq	#0,d0
	rts
;	 #] get_source_name: 
;	 #[ get_mod_name:
;a0=struct
get_mod_name:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcget_mod_name
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcget_mod_name
	ENDC	;de latticedebug
	moveq	#0,d0
	rts
;	 #] get_mod_name: 
;	 #[ get_var_name:
;a0=struct
get_var_name:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcget_var_name
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcget_var_name
	ENDC	;de latticedebug
	moveq	#0,d0
	rts
;	 #] get_var_name: 
;	 #[ get_code_addr:
get_code_addr:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcget_code_addr
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcget_code_addr
	ENDC	;de latticedebug
	moveq	#0,d0
	rts
;	 #] get_code_addr: 
;	 #[ check_if_code:
check_if_code:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tccheck_if_code
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lccheck_if_code
	ENDC	;de latticedebug
	moveq	#0,d0
	rts
;	 #] check_if_code: 
;	 #[ get_next_code_addr:
get_next_code_addr:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcget_next_code_addr
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcget_next_code_addr
	ENDC	;de latticedebug
	moveq	#0,d0
	rts
;	 #] get_next_code_addr: 
;	 #[ print_source_var:
print_source_var:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcprint_source_var
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcprint_source_var
	ENDC	;de latticedebug
	moveq	#0,d0
	rts
;	 #] print_source_var: 
;	 #[ inspect_source_var:
inspect_source_var:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcinspect_source_var
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcinspect_source_var
	ENDC	;de latticedebug
	moveq	#0,d0
	rts
;	 #] inspect_source_var: 
;	 #[ src_watch_var:
src_watch_var:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcsrc_watch_var
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcsrc_watch_var
	ENDC	;de latticedebug
	moveq	#0,d0
	rts
;	 #] src_watch_var: 
;	 #[ src_watch_inspect:
src_watch_inspect:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcsrc_watch_inspect
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcsrc_watch_inspect
	ENDC	;de latticedebug
	moveq	#0,d0
	rts
;	 #] src_watch_inspect: 
;	 #[ get_var_addr:
get_var_addr:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcget_var_addr
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcget_var_addr
	ENDC	;de latticedebug
	moveq	#0,d0
	rts
;	 #] get_var_addr: 
;	 #[ get_var_by_offset:
get_var_by_offset:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcget_var_by_offset
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcget_var_by_offset
	ENDC	;de latticedebug
	moveq	#0,d0
	rts
;	 #] get_var_by_offset: 
;	 #[ get_var_by_address:
get_var_by_address:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcget_var_by_address
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcget_var_by_address
	ENDC	;de latticedebug
	moveq	#0,d0
	rts
;	 #] get_var_by_address: 
;	 #[ get_var_by_name:
get_var_by_name:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcget_var_by_name
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcget_var_by_name
	ENDC	;de latticedebug
	moveq	#0,d0
	rts
;	 #] get_var_by_name: 
;	 #[ get_var_value:
get_var_value:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcget_var_value
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcget_var_value
	ENDC	;de latticedebug
	moveq	#0,d0
	rts
;	 #] get_var_value: 
;	 #[ set_var_value:
set_var_value:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcset_var_value
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcset_var_value
	ENDC	;de latticedebug
	moveq	#0,d0
	rts
;	 #] set_var_value: 
;	 #[ sprint_var_info:
sprint_var_info:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcsprint_var_info
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcsprint_var_info
	ENDC	;de latticedebug
	rts
;	 #] sprint_var_info: 
;	 #[ sprint_var_name_info:
sprint_var_name_info:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcsprint_var_name_info
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcsprint_var_name_info
	ENDC	;de latticedebug
	rts
;	 #] sprint_var_name_info: 
;	 #[ sprint_var_name:
sprint_var_name:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcsprint_var_name
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcsprint_var_name
	ENDC	;de latticedebug
	rts
;	 #] sprint_var_name: 
;	 #[ sprint_var_type:
sprint_var_type:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcsprint_var_type
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcsprint_var_type
	ENDC	;de latticedebug
	rts
;	 #] sprint_var_type: 
;	 #[ sprint_stack:
sprint_stack:
	IFNE	turbodebug
	cmp.w	#SOURCE_PC,source_type(a6)
	beq	tcsprint_stack
	ENDC	;de turbodebug
	IFNE	latticedebug
	cmp.w	#SOURCE_LC,source_type(a6)
	beq	lcsprint_stack
	ENDC	;de latticedebug
	rts
;	 #] sprint_stack: 

;Routines communes
;	 #[ count_source_lines:
;Input:
;a0=start ptr
;a1=end ptr
;Output:
;d0.l=lines nb
count_source_lines:
 movem.l d1-d3/a0-a1,-(sp)
 moveq #0,d0
 moveq #$a,d3
 move.l a1,d1
 sub.l a0,d1
 subq.l #1,d1
 bmi.s .end
 move.w d1,d2
 swap d1
.word_loop:
 cmp.b (a0)+,d3
 dbeq d2,.word_loop
 bne.s .word_end
 addq.l #1,d0
 dbf d2,.word_loop
.word_end:
 moveq #-1,d2
 dbf d1,.word_loop
.end:
 movem.l (sp)+,d1-d3/a0-a1
	rts
;	 #] count_source_lines: 
;	 #[ get_source_line:
;renvoie le ptr(ds d0) sur le texte situe d0 lignes plus bas
;Input:
;a0=start ptr
;d0=line nb
;d1=max length
get_source_line:
 movem.l d1-d3/a0,-(sp)
 subq.l #1,d0
 bmi.s .first_line
 subq.l #1,d1
 bmi.s .error
 move.w d1,d2
 swap d1
 moveq #$a,d3
.word_loop:
 cmp.b (a0)+,d3
 dbeq d2,.word_loop
 bne.s .word_end
 subq.l #1,d0
 bpl.s .word_line
.first_line:
 move.l a0,d0
 movem.l (sp)+,d1-d3/a0
 rts
.word_line:
 dbf d2,.word_loop
.word_end:
 moveq #-1,d2
 dbf d1,.word_loop
.error:
 moveq #0,d0
 movem.l (sp)+,d1-d3/a0
 rts
 
;	move.l	d0,d2
;	moveq	#10,d0
;	lea	0(a0,d1.l),a1
;	moveq	#0,d1
;	cmp.l	d1,d2
;	beq.s	.end
;	blt.s	.abort
;.l1:
;	REPT	13
;	cmp.l	a1,a0
;	bge.s	.abort
;	cmp.b	(a0)+,d0
;	beq.s	.found
;	ENDR
;
;	cmp.l	a1,a0
;	bge.s	.abort
;	cmp.b	(a0)+,d0
;	bne.s	.l1
;.found:
;	addq.l	#1,d1
;	cmp.l	d1,d2
;	bgt.s	.l1
;
;	cmp.l	a1,a0
;	bge.s	.abort
;;	moveq	#10,d2
;;.l2:
;;	move.b	(a0)+,d1
;;	cmp.b	d0,d1
;;	beq.s	.l2
;;	cmp.b	d2,d1
;;	beq.s	.l2
;.end:
;	move.l	a0,d0
;;	subq.l	#1,d0
;	rts
;.abort:
;	moveq	#0,d0
;	rts

;	 #] get_source_line: 
;	 #[ update_source_pc_ptr:
;update le pc source
update_source_pc_ptr:
	move.l	source_pc_ptr(a6),old_source_pc_ptr(a6)
	move.l	pc_buf(a6),d0
	bsr	get_source_addr
	move.l	d0,source_pc_ptr(a6)
	;->
	move.b	#3,src_pc_marker(a6)
	cmp.l	pc_buf(a6),a1
	beq.s	.in_front_of
	;>>
	move.b	#$af,src_pc_marker(a6)
.in_front_of:
	rts
;	 #] update_source_pc_ptr: 
;	 #[ update_curwind_vars:
;appelle par le changement de type de var
update_curwind_tcvars:
	jsr	get_noaddr_curwind
	move.w	d2,d0
;appelle par redraw_window
update_wind_tcvars:
	mulu	#_VARWIND_SIZEOF,d0
	lea	var_wind_buf(a6),a0
	add.w	d0,a0

	move.l	a0,-(sp)
	bsr	update_vars_array
	move.l	(sp)+,a0
	move.w	_VARWIND_TYPE(a0),d0
	beq.s	.set_global
	subq.w	#1,d0
	beq.s	.global
	subq.w	#1,d0
	beq.s	.static
	subq.w	#1,d0
	beq.s	.local
	rts
.local:	move.l	locals_array_ptr(a6),d0
	move.l	locals_nb(a6),d1
	bra.s	.update
.static:	move.l	statics_array_ptr(a6),d0
	move.l	statics_nb(a6),d1
	bra.s	.update
.set_global:
	move.w	#_VARWIND_GLOBAL_TYPE,_VARWIND_TYPE(a0)
.global:	move.l	globals_array_ptr(a6),d0
	move.l	globals_nb(a6),d1
.update:	move.l	_VARWIND_STARTVAR(a0),d2	;meme premiere variable ?
	beq.s	.do_update

	move.l	d0,a1
	move.l	(a1),a1

	cmp.l	a1,d2
	beq.s	.no_need_to_update
.do_update:
	move.l	d0,_VARWIND_PTR(a0)
	move.l	d0,a1
	move.l	(a1),_VARWIND_STARTVAR(a0)
	;revenir au debut
	clr.l	_VARWIND_NB(a0)
.no_need_to_update:
	move.l	d0,_VARWIND_STARTPTR(a0)
	move.l	d1,_VARWIND_NBMAX(a0)
	rts
;	 #] update_curwind_vars: 
;	 #[ set_trace_source:
;while (in_block(pc) && *(int *)pc!=JSR && *(int *)pc!=BSR && *(int *)pc!=TRAP) {
;	stacked_sr|=0x8000;
;	run();->trace
;}

;if (*(int *)pc==JSR || *(int *)pc==BSR || *(int *)pc==TRAP) {
;	run(pc);->trace
;	if (step_over || !in_source(pc)) {
;		set_break(return_addr);
;		stacked_sr&=0x7fff;
;		run();
;		stacked_sr!=0x8000;
;		goto while;
;	}
;}


;3 states:
;trace
;runandbreak
;before bsr|jsr|trap

;in ctrl_z, if source and in_source_window, set_trace_source -> p0p1
;in ctrl_a, if source and in_source_window,
;set_trace_source and step_over_flag on -> p0p1
;(remove runandbreak_flag)
;in permanent_trace, if source and in_source_window, set_trace_source -> p0p1

;set_trace_source:
;set trace_source_flag on
;record blockstart_addr, record blockend_addr

;p0p1:
;if (trace_source_flag) {
;	soit step_over, soit pas
;	transforme trace_source_flag en trace_flag ou runandbreak_flag
;	if (jsr(pc) || bsr(pc) || trap(pc)) {
;		if (step_over || !in_source(watch(pc))) {
;			_ctrl_a();
;			(trace_flag off)
;			(runandbreak_flag on)
;		}
;	}
;	else {
;		trace_flag on;
;		(runandbreak_flag off)
;	}
;	run accordingly to trace_flag or runandbreak flag;
;	->breakpt;
;}

;breakpt:
;if (trace_source_flag) {
;	if (!in_block(pc)) {
;		not_in_block_flag set;
;		->p1p0();
;	}
;	if (!trace_flag) (donc runandbreak on)
;		->p1p0();
;	if (*(int *)pc==jsr || *(int *)pc==bsr || *(int *)pc==trap)
;		->p1p0();
;	rte();
;}

;p1p0:
;if (trace_source_flag) {
;	if (not_in_block_flag) {
;		(tenir compte du trace permanent)
;		not_in_block_flag off;
;		remove_break();
;		unselect_trace();
;		return;
;	}
;	p0p1();	(runandbreak on || bsr|jsr|trap)
;}

set_trace_source:
	st	trace_source_flag(a6)
	;record block
	move.l	pc_buf(a6),d0
	bsr	get_source_addr
	move.l	a1,source_block_addr(a6)
	add.l	d2,a1
	move.l	a1,end_source_block_addr(a6)
	rts

;Out:
;d0=1, no action
;d0=0, no check
;d0=-1, error_found
p0p1_source_trace:
	moveq	#1,d0
	tst.b	trace_source_flag(a6)
	beq.s	.end
	move.l	pc_buf(a6),a0
	jsr	get_instr_type
	subq.w	#1,d0
	beq.s	.trap
	subq.w	#4-1,d0
	beq.s	.bsr
	subq.w	#5-4,d0
	beq.s	.jsr
.trace:
;	bsr	unselect_trace
	sf	runandbreak_flag(a6)
	st	trace_flag(a6)
	st	nostop_flag(a6)
	st	permanent_trace_flag(a6)
;	st	trace_source_flag(a6)
	moveq	#0,d0
.end:
	tst.l	d0
	rts
.trap:
.bsr:
.jsr:	tst.b	step_over_flag(a6)
	bne.s	.do_break
	move.l	a0,d0
	bsr	get_source_addr
	bne.s	.trace
.do_break:
;	bsr	unselect_trace
	sf	trace_flag(a6)
	sf	nostop_flag(a6)
	sf	permanent_trace_flag(a6)
;	st	trace_source_flag(a6)
	jsr	_ctrl_a
;	bmi.s	.end
	bra.s	.end
;	 #] set_trace_source: 
;	 #[ poke_between_brackets:
;a0=buffer
;d0=value
poke_between_brackets:
	move.l	d0,-(sp)
	pea	.text(pc)
	bsr	sprintf3
	addq.w	#8,sp
	add.w	d0,a0
	rts
.text:	dc.b	"[%=ld]",0
	even
;	 #] poke_between_brackets: 

