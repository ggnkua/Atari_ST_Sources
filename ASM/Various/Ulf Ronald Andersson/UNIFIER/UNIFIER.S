;-----------------------------------------------------------------------------
; File name:	UNIFIER.S			Revised:	1999.12.11
; Revised by:	Ulf Ronald Andersson		Ported:		1999.12.09
;-----------------------------------------------------------------------------
	include	RA_STRUC.I
	include	RA_SYS.I
	include	RA_TOS.I
	include	RA_FCNTL.I
	include	RA_JAR.I
	include	RA_XB.I
	include	RA_RAM.I
;----------------------------------------------------------------------------
	output	.TOS
;----------------------------------------------------------------------------
M_VERSION	MACRO
	dc.b	'1.00'
	ENDM
;----------------------------------------------------------------------------
END_GEMDOS_F	=	340
END_PEXEC_M	=	202
RAM_chunk	=	8192
;----------------------------------------------------------------------------
	section	BSS
init_bss_beg:
	section	DATA
init_data_beg:
	Section	TEXT
init_code_beg:
resident_RAM_beg:	=	init_code_beg-$100
;----------------------------------------------------------------------------
rz:
start:
	bra	init_prog
;----------------------------------------------------------------------------
;		GEMDOS functions with XBRA
;----------------------------------------------------------------------------
user_called_gemdos:
	move.l	USP,a0
	bra.s	have_gemdos_args_a0
;-------
	XB_define	nu_GEMDOS,'Unif'
;-------
	btst	#5,(sp)
	beq.s	user_called_gemdos
	move.l	sp,a0
	adda	stackframe_len(pc),a0
have_gemdos_args_a0:
	move	(a0),d0			;d0 = function opcode
	move.b	gemdos_f_t(pc,d0),d0	;d0 = implementation flag of function
	bne.s	go_nu_gemdos_funcs	;if implemented, go to internal func
	XB_gonext_a0	nu_GEMDOS(pc)	;exit quickly for unimplemented ops
;-------
go_nu_gemdos_funcs:
	bra	nu_gemdos_funcs
;-------
gemdos_f_t:
	ds.b	END_GEMDOS_F
	EVEN
;-------
nu_gemdos_funcs:
	cmp	#END_GEMDOS_F,(a0)	;was the opcode in valid range
	blo.s	nu_gemdos_valid		;if so, go execute new function
	XB_gonext_a0	nu_GEMDOS(pc)	;exit quickly for unimplemented ops
;-------
nu_gemdos_valid:
	ext	d0			;extend byte offset to word
	jmp	front_ref(pc,d0)	;jump to selected frontend handler
;-------------------------------------
norm_oP:
norm_oPw:
norm_oPww:
norm_oPpw:
norm_oPp:
	lea	2(a0),a0		;a0 -> single path arg
	bra.s	fix_single_path
;-------
norm_owPp:
	lea	4(a0),a0		;a0 -> single path arg
	bra.s	fix_single_path
;-------
norm_owpP:
	lea	8(a0),a0		;a0 -> single path arg
	bra.s	fix_single_path
;-------
norm_oPP:
	lea	2(a0),a0		;a0 -> path arg pair
	bra.s	fix_path_pair
;-------
norm_owPP:
	lea	4(a0),a0		;a0 -> path arg pair
	bra.s	fix_path_pair
;-------
Pexec_owPpp:
	bra.s	fix_Pexec_owPpp
;-------
Flock_owwll:
	bra	fix_Flock_owwll
;-------
Fcntl_owlw:
	bra	fix_Fcntl_owlw
;-------
Dcntl_owPl:
	bra	fix_Dcntl_owPl
;-------
front_ref:
;-------------------------------------
fix_single_path:		;a0 -> single path arg
	bsr	try_fix			;fix arg if needed
	XB_gonext_a0	nu_GEMDOS(pc)	;exit quickly after fix
;-------------------------------------
fix_path_pair:			;a0 -> path arg pair to fix
	move.l	a0,-(sp)		;push a0 -> primary arg
	bsr	try_fix			;fix arg if needed
	move.l	(sp)+,a0		;pull a0 -> primary arg
	addq	#4,a0			;a0 -> secondary arg
	bsr	try_fix			;fix arg if needed
	XB_gonext_a0	nu_GEMDOS(pc)	;exit quickly after fix
;-------------------------------------
fix_Pexec_owPpp:
	move	2(a0),d0
	move.b	Pexec_m_t(pc,d0),d0
	bne.s	go_test_Pexec_range
	XB_gonext_a0	nu_GEMDOS(pc)	;exit quickly after fix
;-------
go_test_Pexec_range:
	bra	test_Pexec_range
;-------
Pexec_m_t:
	ds.b	END_PEXEC_M
	EVEN
;-------
test_Pexec_range:
	cmp	#END_PEXEC_M,2(a0)
	blo.s	fix_Pexec_path
	XB_gonext_a0	nu_GEMDOS(pc)	;exit quickly after fix
;-------
fix_Pexec_path:
	addq	#4,a0			;a0 -> primary arg
	bsr	try_fix			;fix arg if needed
	XB_gonext_a0	nu_GEMDOS(pc)	;exit quickly after fix
;-------------------------------------
fix_Flock_owwll:			;Flock(handle,mode,start,length)
	moveq	#14,d0			;d0 = arglist size
	bsr	low_GEMDOS_call
	tst.l	d0
	bpl.s	exit_Flock
	tst.b	silly_Flock_f
	beq.s	.tst_E_INVFN
	cmp.l	#E_LOCK,d0
	bne.s	.tst_E_NSLOCK
.have_E_LOCK:
	bra.s	.try_reverse
;-------
.tst_E_NSLOCK:
	cmp.l	#E_NSLOCK,d0
	bne.s	.tst_E_INVFN
.have_E_NSLOCK:
.try_reverse:
	move	4(a0),d0
	eor	#1,d0
	move	d0,4(a0)
	moveq	#14,d0			;d0 = arglist size
	bsr.s	low_GEMDOS_call
.tst_E_INVFN:
	cmp.l	#E_INVFN,d0
	bne.s	exit_Flock
exit_Flock_ok:
	moveq	#E_OK,d0		;return E_OK, also if unimplemented
exit_Flock:
	rte
;-------------------------------------
fix_Fcntl_owlw:				;Fcntl(handle,arg,cmd)
	move	8(a0),d0		;d0 = cmd
	cmp	#F_SETLK,d0
	beq.s	fix_Fcntl_F_SETLK
	cmp	#F_SETLKW,d0
	beq.s	fix_Fcntl_F_SETLKW
	cmp	#F_GETLK,d0
	beq.s	fix_Fcntl_F_GETLK
	XB_gonext_a0	nu_GEMDOS(pc)	;exit quickly after fix
;-------
fix_Fcntl_F_SETLK:			;Fcntl(hndl,lock_p,F_SETLK)
fix_Fcntl_F_SETLKW:			;Fcntl(hndl,lock_p,F_SETLKW)
	moveq	#10,d0			;d0 = arglist size
	bsr.s	low_GEMDOS_call
	cmp.l	#E_INVFN,d0
	bne.s	exit_F_SETLK
	move.l	4(a0),a0		;a0 -> flock struct
	moveq	#E_OK,d0
exit_F_SETLK:
	rte
;-------
fix_Fcntl_F_GETLK:			;Fcntl(hndl,lock_p,F_GETLK)
	moveq	#10,d0			;d0 = arglist size
	bsr.s	low_GEMDOS_call
	cmp.l	#E_INVFN,d0
	bne.s	exit_F_GETLK
	move.l	4(a0),a0		;a0 -> flock struct
	move	#3,(a0)			;l_type = F_UNLCK
	moveq	#E_OK,d0
exit_F_GETLK:
	rte
;-------------------------------------
fix_Dcntl_owPl:				;Dcntl(cmd,path,arg)
	lea	4(a0),a0		;a0 -> single path arg
	bsr.s	try_fix			;fix arg if needed
	XB_gonext_a0	nu_GEMDOS(pc)	;exit quickly after fix
;-------------------------------------
low_GEMDOS_call:
	move.l	a0,-(sp)		;push -> original arg_list
	move	d0,-(sp)		;\
	swap	d0			; > copy d0 low word to high word
	move	(sp)+,d0		;/
	lea	(a0,d0),a0		;a0 -> end of original arglist
.arg_loop:
	move	-(a0),-(sp)		;repush one arg word
	subq	#2,d0
	bne.s	.arg_loop		;loop until all args repushed
	swap	d0			;d0 = arglist size
	lea	post_call_ref(pc,d0),a0	;a0 -> post_call routine
	push_ex	(a0)			;push an exception frame
	XB_gonext_a0	nu_GEMDOS(pc)	;call lower GEMDOS
;-------
post_call_ref:
	nop
post_fix_ref:
	bsr.s	post_call_fix
	bsr.s	post_call_fix
	bsr.s	post_call_fix
	bsr.s	post_call_fix
	bsr.s	post_call_fix
	bsr.s	post_call_fix
	bsr.s	post_call_fix
	bsr.s	post_call_fix
	bsr.s	post_call_fix
	bsr.s	post_call_fix
	bsr.s	post_call_fix
	bsr.s	post_call_fix
	bsr.s	post_call_fix
	bsr.s	post_call_fix
	bsr.s	post_call_fix
	nop
;-------
post_call_fix:
	move.l	(sp)+,a0		;a0 = post_fix_ref+arg_list_size
	sub.l	#post_fix_ref,a0	;a0 = arg_list_size
	add	a0,sp			;pop auto arg_list off stack
	move.l	(sp)+,a0		;a0 -> original arg_list
	rts				;return to caller
;----------------------------------------------------------------------------
;End of:	GEMDOS functions with XBRA
;----------------------------------------------------------------------------
;Start of:	Resident subroutines
;----------------------------------------------------------------------------
try_fix:
	move.l	a0,-(sp)		;push -> string_ptr argument
	move.l	(a0),d0			;d0 -> string or is NULL
	ble	.exit_direct
	move.l	d0,a0			;a0 -> string needing check
.loop_0:
	move.b	(a0)+,d0
	beq	.exit_direct
	cmp.b	#'/',d0
	bne.s	.loop_0
	move.l	(sp),a0			;revive a0 -> string_ptr argument
	move.l	(a0),a0			;a0 -> string needing fix
	movem.l	d1-d2/a0-a2,-(sp)	;push d1-d2/a0-a2
	move.l	2*4(sp),a0		;a0 -> original string
	move.l	a0,a1			;a1 -> original string
.loop_1:
	tst.b	(a0)+
	bne.s	.loop_1
	sub.l	a1,a0			;a0 = size of string
	addq	#2,a0			;add 2 to size, for drive_spec
	addq	#8,a0			;a0 = padded size of block needed
	move.l	a0,-(sp)		;push a0
.try_allocate:
	move.l	(sp),d0			;d0 = allocation size needed (from stack)
	R_alloc	d0			;allocate padded block
	bgt.s	.have_block
	move	sr,-(sp)		;push interrupt level and flags
	or	#$0700,sr		;disable interrupts
;-------
	move.l	oldroot_p(pc),a0	;  temp_1 = oldroot_p;
	move.l	4(a0),d0		;  if  (temp_1->next > NULL)
	ble.s	.done_next_oldest
	move.l	d0,a1			;  {   temp_2 = temp_1->next;
	clr.l	(a1)			;      temp_2->prev = NULL;
.done_next_oldest:			;  }
	move.l	4(a0),oldroot_p		;  oldroot_p = temp_1->next;
	R_free	(a0)			;  R_free(temp_1);
;-------
	move	(sp)+,sr			;pull interrupt level
	bra.s	.try_allocate
;-------
.have_block:
	addq	#4,sp			;pop allocation size off stack
	move	sr,d2			;d2 = interrupt level and flags
	or	#$0700,sr		;disable interrupts
;-------
	clr.l	(a0)			;  block.prev = NULL
	clr.l	4(a0)			;  block.next = NULL
	move.l	oldroot_p(pc),d0	;\ if  (old_root_p <= NULL)
	bgt.s	.done_oldroot		;/
	move.l	a0,oldroot_p		;      oldroot_p = block
.done_oldroot:
	move.l	newroot_p(pc),(a0)	;  block.prev = newroot_p
	ble.s	.done_oldlink		;  if
	move.l	(a0),a1			;\     block.prev->next = block
	move.l	a0,4(a1)		;/
.done_oldlink:
	move.l	a0,newroot_p		;newroot_p = block
;-------
	move	d2,sr			;restore interrupt level from d2
	addq	#8,a0			;a0 -> block string (after links)
	addq	#2,a0			;a0 -> block string+2
	move.l	a0,a2			;a2 -> block string+2
	move.l	2*4(sp),a1		;a1 -> original string
.loop_2:			;loop start for filtered string copying
	move.b	(a1)+,d0		;d0 = next char from original string
	cmp.b	#'/',d0			;is it a unix path separator ?
	bne.s	.store_char		;else go store it unchanged
	moveq	#'\',d0			;char d0 = TOS path separator
.store_char:
	move.b	d0,(a0)+		;store char in fix string
	bne.s	.loop_2		;loop back until whole string filtered
	cmp.b	#'\',(a2)		;root path without drive_spec ?
	bne.s	.set_arg
	cmp.b	#'\',1(a2)		;dual root spec (u:\) ?
	bne.s	.check_drive
	subq	#1,a2			;a2->room for u: drivespec
	move.l	a2,2*4(sp)		;save a2 overwriting pushed a0
	moveq	#'u',d0			;d0 = u: driveletter
	bra.s	.set_drivespec
;-------
.check_drive:
	subq	#2,a2			;a2 -> string base (room for drivespec)
	move.l	a2,2*4(sp)		;save a2 overwriting pushed a0
	move	#op__Dgetdrv,-(sp)	;push gemdos opcode for Dgetdrv
	push_ex	.post_Dgetdrv		;simulate exception frame
	XB_gonext_a0	nu_GEMDOS(pc)	;use older gemdos Dgetdrv
.post_Dgetdrv:				;here d0 = active drive code
	addq	#2,sp			;clean stack from Dgetdrv operation
	move.l	2*4(sp),a2		;revive a2 -> block string base
;-------
	add.b	#'A',d0			;d0 = drive letter
.set_drivespec:
	move.b	d0,(a2)			;store drive letter in string
	move.b	#':',1(a2)		;complete drive_spec in string
;-------
.set_arg:
	move.l	5*4(sp),a0		;a0 -> string_ptr argument
	move.l	a2,(a0)			;argument -> fixed string
.exit:
	movem.l	(sp)+,d1-d2/a0-a2	;pull d1-d2/a0-a2
.exit_direct:
	addq	#4,sp			;pop -> string_ptr argument
	rts
;----------------------------------------------------------------------------
;End of:	Resident subroutines
;----------------------------------------------------------------------------
;Start of:	Resident lib code
;----------------------------------------------------------------------------
	make	RAM_links
;----------------------------------------------------------------------------
;End of:	Resident lib code
;----------------------------------------------------------------------------
;Start of:	Resident data
;----------------------------------------------------------------------------
stackframe_len:	dc.w	6
oldroot_p:	dc.l	0
newroot_p:	dc.l	0
silly_Flock_f:	dc.w	0
MagX_p:		dc.l	0
;----------------------------------------------------------------------------
;End of:	Resident data
;----------------------------------------------------------------------------
;NB:	All code beyond this point is overwritten after initialization
;----------------------------------------------------------------------------
resident_RAM_end:
resident_RAM_size	=	resident_RAM_end-resident_RAM_beg
;----------------------------------------------------------------------------
init_prog:
	move.l	a0,d0
	beq.s	non_ACC
	gemdos	Cconws,must_be_non_ACC_s
	gemdos	Pterm0
;------------------------------------
non_ACC:
	move.l	4(sp),a5			;a5 -> basepage
	move.l	a5,basepage_p
	lea	init_stack_top(pc),sp		;sp -> local initialization stack
	gemdos	Mshrink,!,(a5),#init_RAM_size
;-------
	gemdos	Super,!
	move.l	d0,-(sp)
;-------
	RAM_own	#1			;setup current bp as owner
	RAM_add	#RAM_chunk		;get more RAM for internal use
	move.l	d0,d3
;-------
	gemdos	Super,()
	move.l	d3,d0
	bhs.s	.have_init_RAM
	gemdos	Cconws,must_have_RAM_s
	gemdos	Pterm0
;------------------------------------
.have_init_RAM:
	lea	patch_t(pc),a0
	lea	gemdos_f_t(pc),a1
	bra.s	.next_patch
;-------
.patch_loop:
	move	(a0)+,d1		;d1 = mixed argument offsets
	move.b	d1,(a1,d0)		;patch table indexed by gemdos opcode
.next_patch:
	move	(a0)+,d0		;d0 = gemdos opcode
	bne.s	.patch_loop		;loop until opcode == zero
;-------
	moveq	#1,d0
	lea	Pexec_m_t(pc),a1
	move.b	d0,0(a1)		;patch Pexec mode 0
	move.b	d0,3(a1)		;patch Pexec mode 3
	move.b	d0,100(a1)		;patch Pexec mode 100
	move.b	d0,200(a1)		;patch Pexec mode 200
;-------
	gemdos	Super,!
	move.l	d0,-(sp)
;-------
	eval_cookie	#'MagX'
	move.l	d0,MagX_p
	spl	silly_Flock_f
;-------
	move	sr,d3			;d3 = interrupt level and flags
	or	#$0700,sr		;disable interrupts
	move.l	(ev_trap5).w,a0
	move.l	#.do_trap,(ev_trap5).w
	move.l	sp,d0
	trap	#5			;process exception at .do_trap
.do_trap:
	sub.l	sp,d0			;d0 = frame size
	add	d0,sp			;sp = pre_exception SSP
	move	d0,stackframe_len	;store stackframe_len
	move.l	a0,(ev_trap5).w		;restore original trap5_handler
	move	d3,sr			;restore interrupt level
	bra.s	next_init
;-------
init_loop:
	addq.l	#1,xb_id+nu_GEMDOS
next_init:
	lea	(ev_gemdos).w,a0
	lea	nu_GEMDOS(pc),a1
	XB_init
	bmi.s	init_loop
;-------
	gemdos	Super,()
	gemdos	Cconws,success_s(pc)
	gemdos	Ptermres,#resident_RAM_size,!
;----------------------------------------------------------------------------
	make	JAR_links
	make	RAM_links
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
patch	MACRO	opcode,fronthandler
	dc.w	op__\1,\2-front_ref
	ENDM	;patch
;----------------------------------------------------------------------------
patch_t:
	patch	Dcreate,norm_oP
	patch	Ddelete,norm_oP
	patch	Dsetpath,norm_oP
	patch	Fcreate,norm_oPw
	patch	Fopen,norm_oPw
	patch	Fdelete,norm_oP
	patch	Fattrib,norm_oPww
	patch	Pexec,Pexec_owPpp
	patch	Fsfirst,norm_oPw
	patch	Frename,norm_owPP
	patch	Flock,Flock_owwll
	patch	Fcntl,Fcntl_owlw
	patch	Dpathconf,norm_oPw
	patch	Dopendir,norm_oPw
	patch	Fxattr,norm_owPp
	patch	Flink,norm_oPP
	patch	Fsymlink,norm_oPP
	patch	Freadlink,norm_owpP
	patch	Dcntl,Dcntl_owPl
	patch	Fchown,norm_oPww
	patch	Fchmod,norm_oPw
	patch	Dreadlabel,norm_oPpw
	patch	Dwritelabel,norm_oPp
	dc.w	NUL
;----------------------------------------------------------------------------
must_be_non_ACC_s:
	dc.b	BEL,CR,LF
	dc.b	' Unifier is a TSR, NOT an ACC !',BEL,CR,LF
	dc.b	'I recommend a RESET now.',BEL,CR,LF
	dc.b	BEL,CR,LF,NUL
	even
;----------------------------------------------------------------------------
must_have_RAM_s:
	dc.b	BEL,CR,LF
	dc.b	' Unifier needs more RAM !',BEL,CR,LF
	dc.b	BEL,CR,LF,NUL
	even
;----------------------------------------------------------------------------
success_s:
	dc.b	ESC,'q',CR,LF
	dc.b	ESC,'p',' '
	dc.b	'Unifier '
	M_VERSION
	dc.b	' ',ESC,'q',CR,LF
	dc.b	'Installed.',CR,LF
	dc.b	CR,LF,NUL
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
basepage_p:	ds.l	1
;----------------------------------------------------------------------------
init_stack_beg:
	ds.b	4*1024
init_stack_top:
;----------------------------------------------------------------------------
	section	DATA
init_data_end:
init_data_size	=	init_data_end-init_data_beg
	section	BSS
init_bss_end:
init_bss_size	=	init_bss_end-init_bss_beg
	SECTION	TEXT
init_code_end:
init_code_size	=	init_code_end-init_code_beg
init_RAM_size	=	init_code_size+init_data_size+init_bss_size+$100
;-----------------------------------------------------------------------------
	end
;-----------------------------------------------------------------------------
;End of file:	UNIFIER.S
;-----------------------------------------------------------------------------
