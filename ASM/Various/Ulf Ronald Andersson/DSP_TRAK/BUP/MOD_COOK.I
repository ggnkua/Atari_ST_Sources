;----------------------------------------------------------------------------
;File name:	MOD_COOK.I			Revision date:	1998.09.08
;Created by:	Ulf Ronald Andersson		Creation date:	1997.02.13
;----------------------------------------------------------------------------
;
DspT_s_c	=	'DspT'	;This is the XBRA and cookie identifier used
;
;----------------------------------------------------------------------------
;The make_DspT_cookie macro below is only to be invoked by the server source
;in order to create the master copy of the structure. It is useless to clients.
;
make_DspT_cookie	MACRO
DspT_cookie:
	dc.l	DspT_s_c
	dc.l	DspT_cookie_end-DspT_cookie
	dc.w	$0104,$0104	;own_vers,int_vers
	dc.w	0		;Filled in at runtime with DSP ability code
;
	dc.l	_mod_calc	;long	_mod_calc(raw_mod *mod_p)
;
	dc.l	_mod_alloc	;mod	*_mod_alloc(long size)
	dc.l	_mod_free	;long	_mod_free(mod *_mod_p)
;
	dc.l	_mod_copy_start	;mod	*_mod_copy_start(long rawsize, rawmod *mod_p, void (*dump_p)())
;
	dc.l	_mod_load	;mod	*_mod_load(char *filepath_p)
;
	dc.l	_mod_start	;mod	*_mod_start(mod *mod_p, void (*dump_p)())
	dc.l	_mod_restart	;mod	*_mod_restart()
	dc.l	_mod_play	;mod	*_mod_play()
	dc.l	_mod_stop	;void	_mod_stop()
	dc.l	_mod_dump	;void	_mod_dump()
;
	dc.l	_mod_test_end	;long	_mod_test_end()
;
	dc.l	_mod_set_timer	;short	_mod_set_timer(short new_timer_f) 0=off  1=on  -1=ask
	dc.l	_mod_set_boost	;short	_mod_set_boost(short new_boost) 0:/2 1:normal 2:*2 3:*4
	dc.l	_mod_set_stop	;short	_mod_set_stop(short new_stop_f) 0\1 => restart\dump mod at end
	dc.l	_mod_set_order	;short	_mod_set_order(short new_order) 0..3  0=normal Amiga order
;
	dc.l	_mod_s_calc	;long	_mod_s_calc(raw_mod *mod_p)
;
	dc.l	_mod_s_alloc	;mod	*_mod_s_alloc(long size)
	dc.l	_mod_s_free	;long	_mod_s_free(mod *_mod_p)
;
	dc.l	_mod_s_copy_start	;mod	*_mod_s_copy_start(long rawsize, rawmod *mod_p, void (*dump_p)())
;
	dc.l	_mod_s_load	;mod	*_mod_s_load(char *filepath_p)
;
	dc.l	_mod_s_start	;mod	*_mod_s_start(mod *mod_p, void (*dump_p)())
	dc.l	_mod_s_restart	;mod	*_mod_s_restart()
	dc.l	_mod_s_play	;mod	*_mod_s_play()
	dc.l	_mod_s_stop	;void	_mod_s_stop()
	dc.l	_mod_s_dump	;void	_mod_s_dump()
;
	dc.l	_mod_s_test_end	;long	_mod_s_test_end()
;
	dc.l	_mod_s_set_timer	;short	_mod_s_set_timer(short new_timer_f) 0=off  1=on  -1=ask
	dc.l	_mod_s_set_boost	;short	_mod_s_set_boost(short new_boost) 0:/2 1:normal 2:*2 3:*4
	dc.l	_mod_s_set_stop	;short	_mod_s_set_stop(short new_stop_f) 0\1 => restart\dump mod at end
	dc.l	_mod_s_set_order	;short	_mod_s_set_order(short new_order) 0..3  0=normal Amiga order
;
DspT_cookie_end:
	ENDM	;make_DspT_cookie
;
;----------------------------------------------------------------------------
;The copy_DspT_cookie macro below may be used by clients to get a local copy
;of the cookie structure.  This is used by the bsr_mod macro further below.
;
copy_DspT_cookie	MACRO
	bsr	copy_DspT_cookie_code
	IFND	loc_mod_cookie_f
	bra	loc_mod_cookie_end
;
copy_DspT_cookie_code:
	movem.l	d0-d3/a0-a2,-(sp)
	gemdos	Super,1.w		;test Super/User mode
	move.l	d0,-(sp)		;push flag -1/0 for Super/User mode
	bmi.s	.keep_super_1		;skip setting if already in Super
	gemdos	Super,()		;set Super mode using&popping flag
	move.l	d0,-(sp)		;push old SSP
.keep_super_1:
	eval_cookie	#DspT_s_c
	move.l	d0,mod_cookie_p
	ble.s	.done_cookie
	move.l	d0,a0
	lea	loc_mod_cookie(pc),a1
	move.l	#mod_size-1,d0
.loop:
	move.b	(a0)+,(a1)+
	dbra	d0,.loop
.done_cookie:
	move.l	(sp)+,d0		;pop neg_flag/old_SSP of entry Super/User state
	bmi.s	.keep_super_2		;skip setting if entry was in Super mode
	gemdos	Super|_ind,d0		;leave Super mode, restoring old SSP
.keep_super_2:
	movem.l	(sp)+,d0-d3/a0-a2
	rts
;
mod_cookie_p:	dc.l	-1
loc_mod_cookie_f	set	1
loc_mod_cookie:	ds.b	mod_size
loc_mod_cookie_end:
	ENDC
	ENDM	;copy_DspT_cookie
;
;----------------------------------------------------------------------------
;The copy_s_DspT_cookie macro below may be used by clients to get a local copy
;of the cookie structure.  This is used by the bsr_mod macro further below.
;
copy_s_DspT_cookie	MACRO
	bsr	copy_s_DspT_cookie_code
	IFND	loc_mod_cookie_f
	bra	loc_mod_cookie_end
;
copy_s_DspT_cookie_code:
	movem.l	d0-d3/a0-a2,-(sp)
	eval_cookie	#DspT_s_c
	move.l	d0,mod_cookie_p
	ble.s	.done_cookie
	move.l	d0,a0
	lea	loc_mod_cookie(pc),a1
	move.l	#mod_size-1,d0
.loop:
	move.b	(a0)+,(a1)+
	dbra	d0,.loop
.done_cookie:
	movem.l	(sp)+,d0-d3/a0-a2
	rts
;
mod_cookie_p:	dc.l	-1
loc_mod_cookie_f	set	1
loc_mod_cookie:	ds.b	mod_size
loc_mod_cookie_end:
	ENDC
	ENDM	;copy_DspT_cookie
;
;----------------------------------------------------------------------------
;The bsr_mod macro needs a local copy of the cookie structure to make a call
;into the tracker interface.  It will NOT create such a copy if not yet done.
;
;NB:	areg may be one of a0-a6, but not overlapping regs for ptr arguments
;	if it is a0, it may be modified if the function returns a pointer
;
bsr_mod	MACRO	areg,func
	move.l	loc_mod_cookie+mod_\2,\1
	jsr	(\1)
	ENDM	;bsr_mod
;
;----------------------------------------------------------------------------
;The jsr_mod macro makes a call into the tracker interface via the master
;cookie structure.  This will bomb if the areg used does not point to this
;structure, so make sure you get it right.
;
;NB:	a_reg may be one of a2-a6 and will be unchanged at function exit
;
jsr_mod	MACRO	a_reg,func
	IFND	jsr_mod_code_\1_f
jsr_mod_code_\1_f	set	1
	bra.s	jsr_mod_end_\1
;
jsr_mod_code_\1:
	movem.l	a0-a1,-(sp)
	move.l	8(sp),a1	;a1 -> function offset at retad
	move.w	(a1)+,a0	;a0 =  function offset  a1 = stepped retad
	move.l	a1,8(sp)	;store a1 as real retad
	move.l	4(sp),a1	;restore original a1
	move.l	(\1,a0.w),4(sp)	;store function vector in stack
	move.l	(sp)+,a0	;restore original a0
	rts			;jump to mod function
jsr_mod_end_\1:
	ENDC
	bsr	jsr_mod_code_\1
	dc.w	mod_\2
	ENDM	;jsr_mod
;
;----------------------------------------------------------------------------
;Finally, here is the symbolic structure defining the interface offsets
;
	rsreset
;
mod_magic	rs.l	1
mod_cookie_size	rs.l	1
mod_own_version	rs.w	1
mod_int_version	rs.w	1
mod_DSP_ability	rs.w	1
;
mod_calc	rs.l	1
mod_alloc	rs.l	1
mod_free	rs.l	1
;
mod_copy_start	rs.l	1
;
mod_load	rs.l	1
;
mod_start	rs.l	1
mod_restart	rs.l	1
mod_play	rs.l	1
mod_stop	rs.l	1
mod_dump	rs.l	1
;
mod_test_end	rs.l	1
;
mod_set_timer	rs.l	1
mod_set_boost	rs.l	1
mod_set_stop	rs.l	1
mod_set_order	rs.l	1
;
mod_s_calc	rs.l	1
mod_s_alloc	rs.l	1
mod_s_free	rs.l	1
;
mod_s_copy_start	rs.l	1
;
mod_s_load	rs.l	1
;
mod_s_start	rs.l	1
mod_s_restart	rs.l	1
mod_s_play	rs.l	1
mod_s_stop	rs.l	1
mod_s_dump	rs.l	1
;
mod_s_test_end	rs.l	1
;
mod_s_set_timer	rs.l	1
mod_s_set_boost	rs.l	1
mod_s_set_stop	rs.l	1
mod_s_set_order	rs.l	1
;
mod_size	=	__RS
;
;----------------------------------------------------------------------------
;End of file:	MOD_COOK.I
;----------------------------------------------------------------------------
