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

	IFNE	residant
;  #[ Check_for_residant:
coklst:	dc.l	'_MCH',0
	dc.l	'_CPU',0
	dc.l	'_VDO',0
	dc.l	'_SND',0
	dc.l	'_SWI',0
	dc.l	0			;end of cookie jar
coknb:	dc.l	(*-coklst)/8+1+15	;leave 15 blank (should be enough...)
	REPT	15
	dc.l	0,0
	ENDR

check_for_residant:
	movem.l	d3-d4,-(sp)
	move.l	#'RDBG',d4
;	tst.b	crdebug_flag(a6)
;	beq.s	.not_present
	bsr	get_vbr
	move.l	8(a0),a0
	cmp.l	#EXCEPTION_MAGIC,-(a0)
	bne.s	.not_present
	cmp.l	#ADEBUG_MAGIC,-(a0)
	bne.s	.not_present
	cmp.l	#BRAINSTORM_MAGIC,-(a0)
	bne.s	.not_present
.inst:	lea	rdebug_already_installed_text,a0
	jsr	system_print
	jsr	system_getkey
	move.w	#-1,exit_error_number
	jmp	real_exit_in_user
.not_present:
	moveq	#0,d3
	move.l	$5a0.w,d0
	beq.s	.cookset
	move.l	d0,a0
.l1:	move.l	(a0)+,d0
	beq.s	.setcook
	move.l	(a0)+,d1
	cmp.l	d4,d1
	beq	.inst
	bra	.l1
.cookset:	lea	coklst(pc),a0
	move.l	a0,$5a0.w
	lea	coknb(pc),a0
	moveq	#5,d3
.setcook:	cmp.l	(a0),d3
	blt.s	.pokecok
	addq.l	#5,d3			;+5 cookies
	move.l	d3,d0
	add.l	d0,d0
	add.l	d0,d0
	move.l	d0,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.w	#6,sp
	tst.l	d0
	ble.s	.end
	move.l	d0,a0
	move.l	$5a0.w,a1
;	subq.w	#1,d3			;pour copier le nb aussi
.l2:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbf	d3,.l2
	subq.w	#4,a0
.pokecok:	clr.l	4(a0)
	move.l	(a0),8(a0)
	move.l	d4,-4(a0)
	lea	A_Debug(pc),a1
	move.l	a1,(a0)
.end:	movem.l	(sp)+,d3-d4
	rts
;  #] Check_for_residant:
;  #[ Residant_restart:
residant_restart:
	move.l	#$100,d0			;keep bp
	move.l	p0_basepage_addr(a6),a5	;+ TEXT + DATA + BSS
	add.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	clr.w	-(sp)
	move.l	d0,-(sp)
	move.w	#$31,-(sp)
	trap	#1
	move.w	d0,exit_error_number	;si le keep il a pas fonctionne he ben on sort
	jmp	exit_in_super
;  #] Residant_restart:
	ENDC	; de residant
	IFNE	cartouche
;  #[ Cart_restart:
cart_restart: 
	rts
;  #] Cart_restart:
	ENDC	; de cartouche
;  #[ Be_residant:
be_residant:
	pea	waiting(pc)
	IFNE	residant
	lea	residant_restart(pc),a0
	ENDC	; de residant
	IFNE	cartouche
	lea	cart_restart(pc),a0
	move	#$2300,sr_buf(a6)
	ENDC	; de cartouche
	move.l	a0,pc_buf(a6)
	move.l	a6,a6_buf(a6)
	;st	log_screen_ctrlr_flag(a6)
	move.l	kbshift_addr(a6),a0
	move.b	(a0),d0
	cmp.b	#%110,d0
	beq	maybe_resident
	jmp	ctrl_r
;  #] Be_residant:
;  #[ Install_fork:
install_fork:
	tst.b	crdebug_flag(a6)
	beq.s	.end
	; en cas de residant ou cartouche residante
	;installer le detournement de fork
	bsr	get_vbr
	lea	$84(a0),a1
	move.l	(a1),resident_external_trap1(a6)
	lea	resident_trap1(pc),a0
	move.l	a0,(a1)
	clr.w	resident_trap1_level(a6)
	lea	resident_trap1_buffer(a6),a0
	move.l	a0,resident_trap1_buffer_addr(a6)
;	IFNE	residant
;	addq.w	#1,resident_trap1_level(a6)
;	move.l	resident_trap1_buffer_addr(a6),a0
;	jsr	ram_init
;	add.l	#INITIAL_SIZE,resident_trap1_buffer_addr(a6)
;	ENDC	; de residant
.end:
	rts

	SET_ID	RESIDANT_TRAP1_MAGIC
resident_trap1:
	SWITCHA6
	tst.b	p_number(a6)
	beq	.end
	movem.l	d0-a5,d0_buf(a6)
	lea	6(sp),a0
	IFNE	_68030
	tst.b	chip_type(a6)
	beq.s	.68000
	addq.w	#2,a0
.68000:
	ENDC
	btst	#5,(sp)
	bne.s	.super
	move.l	usp,a0
.super:
	move.w	(a0),d0
	beq.s	.pop_params	;pterm0
	cmp.w	#$4b,d0		;pexec
	bne.s	.not_pexec
;	trap	#3
	;sauter 3, 5 et 7
	;detourner 0, 4 et 6
	move.w	2(a0),d0		;mode 0
	beq.s	.push_params
	subq.w	#1,d0		;mode 1 = Adebug calling
	beq.s	.just_push
	subq.w	#3,d0		;mode 4
	beq.s	.push_params
	subq.w	#2,d0		;mode 6
	bne.s	.continue
.push_params:
;	trap	#5
	bsr	.push_them
	bra.s	.continue
.just_push:
	bsr	.push_them
	movem.l	d0_buf(a6),d0-a5
	RESTOREA6
	rte
.not_pexec:
	cmp.w	#$31,d0
	beq.s	.residant
	cmp.w	#$4c,d0
	bne.s	.continue
.pop_params:
	;trap	#5
	tst.w	resident_trap1_level(a6)
	ble.s	.continue
;	beq.s	.stop
	subq.w	#1,resident_trap1_level(a6)
	lea	resident_trap1_buffer_addr(a6),a0
	sub.l	#INITIAL_SIZE,(a0)
	move.l	(a0),a0
	lea	initial_buffer(a6),a1
	bsr	copy_internal
.continue:
	movem.l	d0_buf(a6),d0-a5
.end:	move.l	resident_external_trap1(a6),-(sp)
	RESTOREA6
	rts
;.stop:	movem.l	d0_buf(a6),d0-a5
;	jmp	p1p0
.residant:
	;trap	#5
	tst.w	resident_trap1_level(a6)		;0 empilements
	ble.s	.continue
	lea	resident_trap1_buffer_addr(a6),a3	;au moins un empilement
	move.l	(a3),a0				;reinitialiser le buffer courant
	jsr	ram_init
	move.l	(a3),a0				;le recopier dans le buffer initial courant
	lea	initial_buffer(a6),a5
	move.l	a5,a1
	bsr.s	copy_internal
	move.l	(a3),a4				;sauver le ptr vers le buffer courant
	sub.l	#INITIAL_SIZE,(a3)			;depiler le buffer courant
	subq.w	#1,resident_trap1_level(a6)		;si buffer precedent
	ble.s	.continue
	IFNE	residant_debug
	trap	#5
	ENDC	;de residant_debug
	move.w	resident_trap1_level(a6),d3		;copier dans tous les autres buffers empiles
	subq.w	#1,d3
.l1:	move.l	a5,a0
	lea	-INITIAL_SIZE(a4),a4
	move.l	a4,a1
	bsr.s	copy_internal
	dbf	d3,.l1
	bra.s	.continue

.push_them:
	addq.w	#1,resident_trap1_level(a6)
	move.l	resident_trap1_buffer_addr(a6),a3
	move.l	a3,a0
	jsr	ram_init
	IFNE	cartouche
	move.l	usp,a0
	move.l	a0,internal_usp(a6)
	ENDC	;de cartouche
	lea	initial_buffer(a6),a1
	move.l	a3,a0
	bsr.s	copy_internal
	add.l	#INITIAL_SIZE,resident_trap1_buffer_addr(a6)
	rts

;a0->a1
copy_internal:
	move.w	#INITIAL_SIZE/2-1,d0
.l1:	move.w	(a0)+,(a1)+
	dbf	d0,.l1
	rts
;  #] Install_fork:
