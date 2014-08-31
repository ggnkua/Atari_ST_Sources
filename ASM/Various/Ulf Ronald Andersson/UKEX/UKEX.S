;-----------------------------------------------------------------------------
; File name:	UKEX.S				Revised:	2000.01.23
; Revised by:	Ulf Ronald Andersson		Ported:		1991.03.22
; Released as:	FREEWARE			Version:	4.8
; File purpose:	Extend ALT-keys and ease user def'd keyboard loading
;-----------------------------------------------------------------------------
;	Revision history:
;
; Revision 4.8: work in progress...
;		Added new cookie command 'I', with argument in A0 being a
;		pointer to a string insertion struct.  This is declared as
;		struct insert_entry
;		{   struct insert_entry *next;
;		    char *string
;		}
;		That struct must remain in safe storage until its string
;		has been fully processed.  It will then be removed from
;		the internal queue of insertion structs.
;
; Revision 4.7:	Equipped with improved keyboard tables for the
; - " -		Swedish keyboards.
;
; Revision 4.6: Keyboard commands replaced by cookie interface
; - " -		The VBI routine is now removed (faster system).
;
; Revision 4.5: Command sequence changed to <ALT><CONTROL><R_SHIFT>.
; - " -		The etv_timer routine is now removed (faster system).
;
; Revision 4.4: Defaults settings & XBRA installation changed.
; - " - 	Defaults are altered to swedish layouts, with active ALT-keys.
; - " -		XBRA installation is altered  for MagiX compatibility.
;
; Revision 4.3: Re-edited for DEVPAC_3 compatibility.
; - " - 	Stack handling improved for compatibility with latest TOS.
; - " -		UKEX now runs error_free under TOS 2.06 and MultiTOS.
; - " -		A new command is added to reload key tables without rebooting.
;
; Revision 4.2:	Improved method of cancelling command characters from buffers
; - " -		New method guarantees compatibility with ALL old TOS (pre 1.4)
; - " -		Tested error free under ST TOS 1.4, TOS 1.7 & KAOS 1.4.2.
; - " -		UKEX uses modern OS standard, should work under any newer TOS,
; - " -		but has problems with commands under TOS 2.06 & MultiTOS.
;
; Revision 4.1:	Deactivated ALT-tables are now default, ALT-CTRL-A activates
;
; Revision 4.0:	Re-edited for DEVPAC_2 compatibility, and to increase
; - " - 	efficiency, both on disk and in runtime RAM.
; - " - 	Extended to allow triple language keyboard swaps.
; - " - 	Enhanced with TOS independent TOS identification.
; - " - 	Enhanced with faster interrupt routines.
; - " - 	Enhanced to release <ALT> <CONTROL> combinations,
; - " - 	except for the 3 special commands shown below:
; - " -		XBRA protocol is now used for all vectors.
;-----------------------------------------------------------------------------
;	Cookie commands:
;
;  <A> Activates UKEX normal keyboard, or toggles ALT-handling.
;  <S> Swaps UKEX normal keyboard with ALT keyboard
;  <Q> Quits UKEX normal keyboard, to use BIOS keys.
;  <L> Load new UKEX keyboard tables from current directory.
;  <I> Add an insertion struct to the internal queue
;-----------------------------------------------------------------------------
	include	RA_SYS.I
	include	RA_TOS.I
	include	RA_XB.I
	include	RA_JAR.I
	include	RA_RAM.I
;-----------------------------------------------------------------------------
RAM_chunk	=	8192
;-----------------------------------------------------------------------------
	struct	INSERT_Q
	struc_p	IQ_next
	char_p	IQ_data
	d_end	INSERT_Q
;-------------------------------------
	struct	MACRO_Q
	struc_p	MQ_next
	long_p	MQ_data
	d_end	MACRO_Q
;-----------------------------------------------------------------------------
	TEXT
;-----------------------------------------------------------------------------
start:
	bra	install
;-----------------------------------------------------------------------------
;Start of:	nu_VBI		XBRA_linked interrupt code for ev_VBI
;-----------------------------------------------------------------------------
	XB_define	nu_VBI,'UKEX'
	push_ex		post_VBI(pc)
	XB_gonext_d	nu_VBI(pc)		;goto older VBI
;-------
post_VBI:	
	move		SR,-(sp)		;push entry SR
	or		#$0700,SR		;disable interrupts
;-------
	tst.b		UKEX_protect_f
	bmi.s		pull_SR_go_old_VBI
	tst.l		macro_ref_q
	bgt.s		ref_macro
	tst.l		insertion_q
	bgt		ref_insert
pull_SR_go_old_VBI:
	move		(sp)+,SR		;pull entry SR
	rte
;-------------------------------------
ref_retry_internal:
	tst.l	macro_ref_q
	bgt.s	ref_macro_internal
	tst.l	insertion_q
	bgt.s	ref_insert_internal
	sf	expanding_f
	move.l	kbshift_p(pc),a1	;a1 -> system kbshift variable
	move.b	physical_kbsh(pc),(a1)
exit_ref_in_VBI_1:
	movem.l		(sp)+,d0-d2/a0-a2	;pull entry registers
	move		(sp)+,SR		;pull entry SR
	rte					;exit
;-------------------------------------
ref_macro:
	movem.l	d0-d2/a0-a2,-(sp)	;push entry registers
ref_macro_internal:
	move.l	kb_iorec_p(pc),a0
	move	io_tail_ix(a0),d1	;d1 = tail index
	cmp	io_head_ix(a0),d1	;buffer empty ?
	bne.s	exit_ref_in_VBI_1	;delay insertion until buffer empty
	addq	#4,d1			;d1 = next position
	cmp	io_size_ix(a0),d1	;size exceeded ?
	blo.s	.wrapping_done
	clr	d1			;wrap to position 0
.wrapping_done:
	move.l	macro_ref_q(pc),a1	;a1 -> current entry in macro ref queue
.try_entry:
	move.l	MQ_data(a1),a2		;a2 -> remaining keys of entry
	move.l	(a2),d0			;d0 = key to insert, unless NULL
	bne.s	.have_some_data
.next_entry:
	move.l	MQ_next(a1),macro_ref_q	;unlink finished macro ref from queue
	R_free	(a1)			;release RAM of finished macro ref
	bra	ref_retry_internal	;loop back to try another macro/insert
;-------------------------------------
.have_some_data:
	bpl.s	.have_key_data
	move.b	delay_count(pc),d2
	bmi.s	.keep_count
	move.b	(a2),d2
.keep_count:
	addq.b	#1,d2
	move.b	d2,delay_count
	bmi.s	exit_ref_in_VBI_1
	addq.l	#4,MQ_data(a1)
	bra.s	.try_entry
;-------
.have_key_data:
	addq.l	#4,MQ_data(a1)
	bra	simulate_key_d0		;go simulate kbsh with key entry
;-------------------------------------
ref_insert:
	movem.l	d0-d2/a0-a2,-(sp)	;push entry registers
ref_insert_internal:
	move.l	kb_iorec_p(pc),a0
	move	io_tail_ix(a0),d1	;d1 = tail index
	cmp	io_head_ix(a0),d1	;buffer empty ?
	bne.s	exit_ref_in_VBI_1	;delay insertion until buffer empty
	addq	#4,d1			;d1 = next position
	cmp	io_size_ix(a0),d1	;size exceeded ?
	blo.s	.wrapping_done
	clr	d1			;wrap to position 0
.wrapping_done:
	move.l	insertion_q(pc),a1	;a1 -> current entry in insertion queue
.try_entry:
	move.l	IQ_data(a1),a2			;a2 -> remaining string of entry
	move.b	(a2),d0			;d0 = byte to insert, unless NUL
	bne.s	.have_insert_byte
.next_entry:
	move.l	IQ_next(a1),insertion_q	;unlink finished insert ref from queue
	R_free	(a1)			;release RAM of finished insert ref
	bra	ref_retry_internal	;loop back to try another macro/insert
;-------
.have_insert_byte:
	addq.l	#1,IQ_data(a1)
	and	#$00FF,d0
	move	d0,d2			;low word of d2 = key ascii code
	swap	d0			;high word of d0 = key ascii code
	move.l	a2,4(a1)		;store updated string ptr of entry
	move.l	DEF_vector(pc),a2	;a2 -> keyboard tables
	move	#3*128-1,d0		;limit search to 3*128 bytes
.search_loop:
	cmp.b	(a2)+,d2		;found correct ascii yet ?
	dbeq	d0,.search_loop		;loop until found or tables end
	bne.s	simulate_weird_key	;if not in table, simulate weirdly
.simulate_found_key:
	subq	#1,a2			;a2 -> found table char
	sub.l	DEF_vector(pc),a2	;a2 =  total offset of found char
	move	a2,d0			;d0 = total offset of found char
	cmp	#128,d0
	blo.s	simulate_key_swap_d0
	cmp	#2*128,d0
	bhs.s	simulate_capslock
.have_shift:
	and	#$007F,d0
	or	#$0100,d0
	bra.s	simulate_key_swap_d0
;-------
simulate_weird_key:
	move	#$0022,d0		;use scan of 'g' for untabled chars
	bra.s	simulate_key_swap_d0
;-------
simulate_capslock:
	and	#$007F,d0
	or	#$1000,d0
simulate_key_swap_d0:
	swap	d0			;d0 = (kbsh<<24)|(scan<<16)|ascii
simulate_key_d0:
	move.l	kbshift_p(pc),a1	;a1 -> system kbshift variable
	st	expanding_f
.done_kbsh_save:
	move.l	d0,d2			;d2 = full key data
	btst	#3,(conterm).w
	beq.s	.done_kbsh_bits
	and.l	#$00FFFFFF,d0		;d0 = key data without kbsh bits
.done_kbsh_bits:
	move.l	io_buffer_p(a0),a2	;get address of io-buffer
	move.l	d0,(a2,d1)		;store key entry in buffer
	move	d1,io_tail_ix(a0)	;store updated tail index
	move	d1,old_tail_ix		;copy new tail index to old_tail_ix
	swap	d2
	lsr	#8,d2			;low byte of d2 = kbsh bits
	and	#$000F,d2		;d2 = relevant kbsh bits
	move.b	(a1),d1			;d1 = active kbsh bits
	and	#$00F0,d1		;d1 = active irrelevant kbsh bits
	or	d1,d2			;d2 = wanted kbsh byte
	move.b	d2,(a1)			;patch system kbshift variable
	move.b	d2,forced_kbsh		;memorize this value for nu_ikbd_vec
exit_ref_in_VBI_2:
	movem.l		(sp)+,d0-d2/a0-a2	;pull entry registers
	move		(sp)+,SR		;pull entry SR
	rte					;exit
;-----------------------------------------------------------------------------
;End of:	nu_VBI		XBRA_linked interrupt code for ev_VBI
;-----------------------------------------------------------------------------
;Start of:	nu_ikbd_vec	XBRA_linked subroutine code for ikbd_vec
;-----------------------------------------------------------------------------
	XB_define	nu_ikbd_vec,'UKEX'
	move.l		kbshift_p(pc),a1
	move.b		physical_kbsh(pc),(a1)
	XB_donext_d	nu_ikbd_vec(pc)
	move.l		kbshift_p(pc),a1
	move.b		(a1),physical_kbsh
	tas		UKEX_protect_f
	bmi		UKEX_return_direct
UKEXcode:
	move	SR,-(sp)
	move.b	UKEX_block_f(pc),d1
	bne	UKEX_return
	move.l	kb_iorec_p(pc),a0
	move	io_tail_ix(a0),d1	;tail index
	cmp	old_tail_ix(pc),d1	;test if changed
	beq	UKEX_return		;just exit if no real key pressed
	or	#$0700,SR
	move	io_tail_ix(a0),d1	;tail index
	move	d1,old_tail_ix		;save tail index at old_tail_ix
	cmp	io_head_ix(a0),d1
	beq	UKEX_return		;if buffer empty, just return
	move.l	kbshift_p(pc),a1
	move.b	(a1),d2			;get kbshifts
	btst	#3,d2			;ALT ?
	beq.s	UKEX_accept_key		;if no ALT, accept key as-is
	move.l	io_buffer_p(a0),a2	;a2 -> keyboard buffer
	move	(a2,d1),d0		;get 1'st word for this key = key code
	and	#$7F,d0			;mask key code
	btst	#2,d2			;CONTROL ?
	bne	try_commands		;If ALT+CONTROL, go try manual commands
	move.l	ALT_vector(pc),a1	;get translation table
	tst.b	ALT_inhibit
	bne.s	UKEX_accept_key
	and.b	#$13,d2			;test SHIFT l/r and CapsL
	beq.s	.goon			;if none go use 1'st ALT-table
	add	#128,a1			;set second table (ALT&SHIFT)
	and.b	#3,d2			;Shift pressed ?
	bne.s	.goon			;If so, go use 2'nd ALT-table
	add	#128,a1			;use third ALT-table (ALT&CAPS)
.goon:
	move.b	(a1,d0),d0		;translate
	beq.s	UKEX_accept_key		;but leave NUL's untranslated
	move	d0,2(a2,d1)		;store char code
UKEX_accept_key:
	move.l	recording_p(pc),d2
	ble.s	.key_accepted
	lea	recording_bf_end(pc),a1	;a1 -> end of recording buffer
	cmp.l	a1,d2			;position at end yet ?
	blo.s	.record_key
	clr.l	recording_p		;break overlong recording
	bra.s	.key_accepted
;-------
.record_key:
	move.l	io_buffer_p(a0),a2	;a2 -> keyboard buffer
	move.l	d2,a1			;a1 -> macro recording position
	move.l	(a2,d1),(a1)		;copy latest key to buffer
	addq.l	#4,recording_p
	cmp.l	#recording_bf,a1	;is this the id key of the macro ?
	beq	remove_key
	move	(a1),d2
	and	#$0F7F,d2
	cmp	#$0C30,d2
	bne.s	.key_accepted
	move.b	#-25,(a1)		;setup 500 ms delay
	bra	remove_key
;-------
.key_accepted:
UKEX_return:
	tst.b	expanding_f
	beq.s	.done_forced_kbsh
	move.l	kbshift_p(pc),a1	;a1 -> system kbshift variable
	move.b	forced_kbsh(pc),d2
	and	#$000F,d2		;d2 = relevant kbsh bits
	move.b	(a1),d1			;d1 = active kbsh bits
	and	#$00F0,d1		;d1 = active irrelevant kbsh bits
	or	d1,d2			;d2 = wanted kbsh byte
	move.b	d2,(a1)			;patch system kbshift variable
.done_forced_kbsh:
	move	(sp)+,SR		;restore entry SR
	sf	UKEX_protect_f
UKEX_return_direct:
	rts				;return to caller
;-------------------------------------
try_commands:
	and	#3,d2			;left and/or right Shift key pressed ?
	bne.s	UKEX_accept_key		;if so, accept key as-is
	cmp	#$32,d0			;Macro start command ?  (Alt+Ctrl+M)
	beq.s	start_macro
	cmp	#$31,d0			;Macro end command ?    (Alt+Ctrl+N)
	beq.s	end_macro
	lea	macro_def_q(pc),a2	;a2 -> root of macro def queue
.loop_1:
	move.l	MQ_next(a2),d2		;d2 -> next macro def
	ble	UKEX_accept_key		;exit at end of macro def queue
	move.l	d2,a2			;a2 -> valid macro def
	move.l	MQ_data(a2),a1		;a1 -> macro data  (first long is id)
	cmp	(a1),d0			;is this the one we want ?
	bne.s	.loop_1			;if not, loop on
	bra	refer_macro
;-----------------------------------------------------------------------------
refer_macro:	;a2 -> macro_def  a0 -> IOREC  d1 = io_tail_ix
	lea	macro_ref_q(pc),a1	;a1 -> root of macro ref queue
.loop_2:
	move.l	MQ_next(a1),d2		;d2 -> next macro ref
	ble.s	.link_new_ref		;go link new ref at end of ref queue
	move.l	d2,a1			;a1 -> valid macro ref
	bra.s	.loop_2
;-------
.link_new_ref:
	movem.l	d1-d2/a0-a1,-(sp)
	R_alloc	#sizeof_MACRO_Q
	movem.l	(sp)+,d1-d2/a0-a1
	tst.l	d0
	ble	remove_key		;exit if no RAM allocated
	move.l	MQ_data(a2),d2		;d2 -> data of macro to expand
	addq.l	#4,d2			;d2 -> data beyond macro id
	move.l	d0,a2			;a2 -> new macro ref struct
	move.l	d2,MQ_data(a2)		;link macro data into new struct
	clr.l	MQ_next(a2)		;clear next-link of new ref struct
	move.l	a2,MQ_next(a1)		;link new struct into ref queue
	bra	remove_key
;-----------------------------------------------------------------------------
start_macro:
	lea	recording_bf(pc),a2
	move.l	a2,recording_p
	bra	remove_key
;-----------------------------------------------------------------------------
end_macro:
	move.l	recording_p(pc),d2	;d2 -> current pos in recording buffer
	ble	remove_key
	clr.l	recording_p		;stop recording
	lea	recording_bf(pc),a2	;a2 -> macro recording buffer base
	sub.l	a2,d2			;d2 = size of recorded macro data
	blo.s	remove_key
	cmp.l	#8,d2
	blo.s	remove_key
	add.l	#4+sizeof_MACRO_Q,d2	;d2 = size needed for macro storage
	movem.l	d1-d2/a0-a1,-(sp)
	R_alloc	d2			;allocate RAM for macro
	movem.l	(sp)+,d1-d2/a0-a1
	tst.l	d0
	ble.s	remove_key
	move.l	d0,-(sp)		;push -> new macro RAM
	move.l	d0,a1			;a1 -> new macro RAM
	lea	sizeof_MACRO_Q(a1),a1	;a1 -> data buffer of new macro
	sub.l	#4+sizeof_MACRO_Q,d2	;d2 = size of data block
	lsr.l	#2,d2			;d2 = count of longs in data
	subq	#1,d2			;d2 = count of longs -1 (for dbra)
.loop_1:
	move.l	(a2)+,(a1)+		;copy macro data
	dbra	d2,.loop_1
	clr.l	(a1)			;add termination mark at macro end
	move.l	(sp)+,a2		;a2 -> new macro struct
	lea	sizeof_MACRO_Q(a2),a1	;a1 -> data of new macro
	and	#$007F,(a1)		;limit macro id to normal form
	move.l	a1,MQ_data(a2)			;link data into new def struct
	move.l	macro_def_q(pc),MQ_next(a2)	;link old queue into new macro
	move.l	a2,macro_def_q			;link new macro as new queue
	move	(a1),d0			;d0 =  macro id
.loop_2:
	move.l	MQ_next(a2),d2		;d2 -> next macro def, unless NULL
	ble.s	.purge_done
	exg	d2,a2			;a2 -> macro def, d2 -> prev macro def
	move.l	MQ_data(a2),a1		;a1 -> id of macro
	cmp	(a1),d0			;same id ?
	bne.s	.loop_2
	move.l	d2,a1			;a1 -> prev macro def
	move.l	MQ_next(a2),MQ_next(a1)	;unlink duplicate macro from queue
	movem.l	d1-d2/a0-a1,-(sp)
	R_free	(a2)			;release RAM of duplicate macro
	movem.l	(sp)+,d1-d2/a0-a1
.purge_done:
remove_key:
	subq	#4,d1			;d1 = pos preceding tail index
	bhs.s	.wrap_done
	move	io_size_ix(a0),d1
	subq	#4,d1
.wrap_done:
	move	d1,io_tail_ix(a0)	;store updated tail index
	move	d1,old_tail_ix		;copy new tail index to old_tail_ix
	move.l	kbshift_p(pc),a1	;a1 -> system kbshift variable
	and.b	#$F0,(a1)		;normalize kbshift status
	bra	UKEX_return
;-----------------------------------------------------------------------------
;End of:	nu_ikbd_vec	XBRA_linked subroutine code for ikbd_vec
;-----------------------------------------------------------------------------
commander:
	move.l	(savptr).w,savptr_save
	move.l	sp,entry_sp_save
	lea	extra_stack_1,sp
	move.l	sp,(savptr).w
	lea	extra_stack_2,sp
	movem.l d0-d2/a0-a2,-(sp)
	move	UKEX_block_f(pc),-(sp)
	st	UKEX_block_f
	bsr.s	commandsub
	move	(sp)+,UKEX_block_f
	movem.l (sp)+,d0-d2/a0-a2
	move.l	savptr_save,(savptr).w
	move.l	entry_sp_save,sp
	rts
;-----------------------------------------------------------------------------
I_command:
	move.l	a0,-(sp)		;push entry a0 -> source string
	move.l	a0,d0
	ble.s	.exit
.loop_1:
	tst.b	(a0)+
	bne.s	.loop_1
	sub.l	(sp),a0			;a0 = string size incl terminator
	addq	#sizeof_INSERT_Q,a0	;a0 = struct size incl data buffer
	R_alloc	a0			;allocate struct RAM
	ble.s	.exit			;exit on allocation failure
	move.l	a0,a2			;a2 = a0 -> insertion struct
	addq	#sizeof_INSERT_Q,a0	;a0 -> data buffer of struct
	clr.l	IQ_next(a2)		;init link of struct
	move.l	a0,IQ_data(a2)		;link data buffer into struct
	move.l	(sp),a1			;a1 -> source string
.loop_2:
	move.b	(a1)+,(a0)+		;copy string into struct data buffer
	bne.s	.loop_2			;loop back until terminator copied
	move	UKEX_protect_f(pc),-(sp)	;push UKEX_protect_f
	st	UKEX_protect_f			;set  UKEX_protect_f
	lea	insertion_q(pc),a1
.loop:
	move.l	(a1),d0
	ble.s	.have_final_link
	move.l	d0,a1
	bra.s	.loop
;-------
.have_final_link:
	move.l	a2,(a1)				;link struct into old queue
	move	(sp)+,UKEX_protect_f		;pull UKEX_protect_f
.exit:
	move.l	(sp)+,a0			;pull entry a0
	rts
;-----------------------------------------------------------------------------
commandsub:
	cmp	#'I',d0
	beq.s	I_command
	cmp	#'Q',d0
	beq.s	Q_command
	cmp	#'A',d0
	beq.s	A_command
	cmp	#'S',d0
	beq.s	S_command
	cmp	#'L',d0
	beq.s	L_command
	bra.s	no_command
;
;'A' reActivates normal tables (after using ROM or externals)
;If already active, toggles ALT handling off/on
A_command:
	lea	ALT_inhibit,a0
	tst.b	DEF_inhibit-ALT_inhibit(a0)
	bne.s	Activate
	tst.b	(a0)
	seq	(a0)
Activate:
	move.l	DEF_vector,a0
	xbios	Keytbl,(a0),128(a0),256(a0)
	sf	DEF_inhibit
	rts
;
;
Q_command: ;ESC Quits normal tables to use ROM (ALT tables remain as before)
	st	DEF_inhibit-kbd_comd(a0)
	xbios	Bioskeys
no_command:
	rts
;
;
L_command:
	move.l	#def_fname_s,def_fpath_p
	bsr	load_def_table
	move.l	#alt_fname_s,alt_fpath_p
	bsr	load_alt_table
	rts

;
;
S_command: ;'S' Swaps normal tables with ALT-tables
	lea	DEF_vector,a0
	lea	ALT_vector,a1
	move.l	(a1),d1
	move.l	(a0),(a1)
	move.l	d1,(a0)
	move.l d1,a0		;a0 -> new normal key table
	move.l	$76(a0),$00(a0)
	CLR	$76(a0)
	CLR.l	$78(a0)
	CLR.l	$7C(a0)
	CLR.b	$00(a0)
	move.l	$0F6(a0),$080(a0)
	CLR	$0F6(a0)
	CLR.l	$0F8(a0)
	CLR.l	$0FC(a0)
	CLR.b	$080(a0)
	move.l	$176(a0),$100(a0)
	CLR	$176(a0)
	CLR.l	$178(a0)
	CLR.l	$17C(a0)
	CLR.b	$100(a0)
;Here both tables have the normalized format, but the newly activated
;normal table may have holes after ALT-usage, so swap those codes
	move.l	DEF_vector,a0
	move.l	ALT_vector,a1
	move	#$180,d2
swapalt_l1:
	move.b	(a0)+,d1
	bne.s	swapalt_l2
	move.b	(a1),-(a0)
	move.b	d1,(a1)
	addq	#1,a0
swapalt_l2:
	addq	#1,a1
	dbra	d2,swapalt_l1
;Here both tables are normalized, with ALT-inhibiting NUL's swapped to ALT-table,
;but TOS won't give normalized key codes for all ALT-keys, so rearrange table
Rearr_ALT:
	move.l ALT_vector,a0		; rearrange ALT-Codes
	move	$00(a0),$76(a0)
	move.l	$02(a0),$78(a0)
	move.l	$06(a0),$7C(a0)
	move.l	$0A(a0),$00(a0)
	move	$080(a0),$0F6(a0)
	move.l	$082(a0),$0F8(a0)	; same for ALT SHIFT
	move.l	$086(a0),$0FC(a0)
	move.l	$08A(a0),$080(a0)
	move	$100(a0),$176(a0)
	move.l	$102(a0),$178(a0)	; same for ALT CAPS
	move.l	$106(a0),$17C(a0)
	move.l	$10A(a0),$100(a0)
	bra	Activate
;
;
load_def_table:
	gemdos	Fopen|_ind,def_fpath_p,!
	move	d0,handle
	bmi.s	.no_file
	gemdos	Fread,handle,#384,DEF_table
	gemdos	Fclose,handle
.no_file:
	tst.l	d0
	rts
;
;
load_alt_table:
	gemdos	Fopen|_ind,alt_fpath_p,!
	move	d0,handle
	bmi.s	.no_file
	gemdos	Fread,handle,#384,ALT_table
	gemdos	Fclose,handle
.no_file:
	rts
;
;
delay_count:	dc.w	0	;used for pauses in macro refs
physical_kbsh:	dc.w	0	;kbsh value for deep TOS code
forced_kbsh:	dc.w	0	;kbsh value for simulated keys
expanding_f:	dc.w	0	;flags expansion in progress
UKEX_protect_f:	dc.w	0	;interrupt protection flag
UKEX_block_f:	dc.w	0	;blocks expansions during commands
insertion_q:	dc.l	0	;-> queue of insertion structs
macro_ref_q:	dc.l	0	;-> queue of macro references
macro_def_q:	dc.l	0	;-> queue of macro definitions
recording_p:	dc.l	0	;-> macro recording position
entry_sp_save:	dc.l	0	;for interrupt command handler
savptr_save:	dc.l	0	;for interrupt calls to XBIOS
keytbl_ptp:	dc.l	0	;-> table of 3 ptrs to keytables
kbshift_p:	dc.l	0	;-> OS variable for kbshift
DEF_vector:	dc.l	0	;-> Default UKEX keytables
ALT_vector:	dc.l	0	;-> Alternate UKEX keytables
kb_iorec_p:	dc.l	0	;-> keyboard iorec structure
old_tail_ix:	dc.w	-1
kbd_comd:	dc.w	0
DEF_inhibit:	dc.b	0	;Default is ON
ALT_inhibit:	dc.b	0	;Default is ON (Rev 4.4)
handle:	dc.w	0
;
def_fpath_p:	dc.l	def_fauto_s
def_fauto_s:
	dc.b	'A:\AUTO\'		;patched to real boot drive
def_fname_s:
	dc.b	'DEF*.KBD',NUL
	even
;
alt_fpath_p:	dc.l	alt_fauto_s
alt_fauto_s:
	dc.b	'A:\AUTO\'		;patched to real boot drive
alt_fname_s:
	dc.b	'ALT*.KBD',NUL
	even
;-----------------------------------------------------------------------------
;	Here lie the built-in keyboard tables of UKEX.
;
DEF_table:
	incbin	KBD_DEF\def_swe.kbd
;
ALT_table:
	incbin	KBD_DEF\alt_swe.kbd
;----------------------------------------------------------------------------
UKEX_cookie;
	dc.l	'UKEX'
	dc.w	0
	dc.w	$0408
	dc.w	$0408
	dc.l	commander
	dc.b	'QASLI'
	dc.b	NUL
	even
;----------------------------------------------------------------------------
;	Resident cookie jar routines & data
;
	_uniref	reset_old_jar
	make	JAR_links
	make	RAM_links
;-----------------------------------------------------------------------------
;	The resident program will end here,
;	but resident stacks and buffers use this area.
;
extra_base		= *
			rsreset
recording_bf		=	(*+__RS)
			rs.b	4096
recording_bf_end	=	(*+__RS)
			rs.b	512
extra_stack_1		=	(*+__RS)
			rs.b	512
extra_stack_2:		=	(*+__RS)
extra_size		= __RS
;
;	The following code only exists during installation,
;	since it is overlaid by the commander stacks.
;
install:
	move.l	4(sp),a5	;a5 -> basepage
	lea	pgm_len,a0
	lea	install,a1
	move.l	a1,d0
	sub.l	a5,d0		;* calculate length
	add.l	#extra_size,d0
	move.l	d0,(a0)
	move.l	(a0),d0
	add.l	#$1000,d0
	lea	(a5,d0.l),sp
	gemdos	Mshrink!_ind,#0,a5,d0
	gemdos	Cconws,initmess_s(pc)
;
	gemdos	Super,!
	move.l	d0,-(sp)
;
	lea	UKEX_cookie(pc),a0
	make_cookie	#'UKEX',a0
	bmi	error_exit
;
	move	(_bootdev).w,d1
	add	#'A',d1
	move.b	d1,def_fauto_s
	move.b	d1,alt_fauto_s
;
	gemdos	Super,()
;
	move.l	#def_fauto_s,def_fpath_p
	bsr	load_def_table
	bpl.s	.got_def_tab
	move.l	#def_fname_s,def_fpath_p
	bsr	load_def_table
.got_def_tab:
	move.l	#alt_fauto_s,alt_fpath_p
	bsr	load_alt_table
	bpl.s	.got_alt_tab
	move.l	#alt_fname_s,alt_fpath_p
	bsr	load_alt_table
.got_alt_tab:
	lea	DEF_vector,a1
	lea	DEF_table,a0
	move.l	a0,(a1)+
	lea	ALT_table,a0
	move.l	a0,(a1)
	bsr	Rearr_ALT
	xbios	Iorec,#1
	move.l	d0,kb_iorec_p
	xbios	Keytbl,?,?,?
	move.l	d0,keytbl_ptp
	bsr	Activate
;
	gemdos	Super,!
	move.l	d0,-(sp)
;
;*********; Here starts TOS identification/adaption
	move.l	(_sysbase).w,a0
	move.l	os_selfbeg_p(a0),a0
	move.l	$24(a0),a1	;->kbshift variable in modern TOS >= 1.2
	cmp	#$0102,2(a0)	;check OS version
	bhs.s	insta_OS
;this is an init of kbshift_p, valid for TOS <= TOS 1.02
	move.l	keytbl_ptp,a1
	subq	#1,a1		;NB: This assumes Kbshift stored at Keytbl-1.
;				;NB: All early TOS have Kbshift data there !!!
insta_OS:
	move.l	a1,kbshift_p
	gemdos	Super,()
;
	RAM_own	#1
	RAM_add	#RAM_chunk
;
	gemdos	Cconws,Activation_s(pc)
	xbios	Kbdvbase
	move.l	d0,a1		;* a1 = addr(kbdvbase)
	XB_install	nu_ikbd_vec(pc),32(a1)
	XB_install	nu_VBI(pc),(ev_VBI).w
	gemdos	Ptermres,pgm_len(pc),#0
;
;
error_exit:
	move.l	d0,d7
	gemdos	Super,()
	lea	Refusal_s(pc),a3
	cmp	#E_ACCDN,d7		;old cookie had same name ?
	beq.s	.disp_error
	lea	ram_failure_s(pc),a3
.disp_error:
	gemdos	Cconws,(a3)
	gemdos	Cconws,prompt_s(pc)
	gemdos	Crawcin
	gemdos	Pterm,d7
;----------------------------------------------------------------------------
;	non-resident cookie jar routines
;
	make	JAR_links
	make	RAM_links
;-----------------------------------------------------------------------------
pgm_len:	dc.l	0
;
;
Activation_s:
	dc.b	"________ UKEX 4.7  activated ! ________",CR,LF
	dc.b	CR,LF
	dc.b	NUL
;
initmess_s:
	dc.b	CR,LF
	dc.b	"---------------- UKEX -----------------",CR,LF
	dc.b	"Version 4.7  developed   Sep 1998 by:  ",CR,LF
	dc.b	"	Ulf Ronald Andersson            ",CR,LF
	dc.b	"	H”ders V„g 7                    ",CR,LF
	dc.b	"	S-145 70  Norsborg              ",CR,LF
	dc.b	"	Sweden                          ",CR,LF
	dc.b	"	                                ",CR,LF
	dc.b	"	mailto:dlanor@oden.se           ",CR,LF
	dc.b	"	http://www.oden.se/~dlanor/     ",CR,LF
	dc.b	CR,LF
	dc.b	NUL
;
Refusal_s:
	dc.b	"________ UKEX already active ! ________",CR,LF
	dc.b	"Sorry, I will not risk installing UKEX,",CR,LF
	dc.b	"when it seems to be installed already. ",CR,LF
	dc.b	"---------------------------------------",CR,LF
	dc.b	NUL
;
ram_failure_s:
	dc.b	"_______ Cookie creation failed ! ______",CR,LF
	dc.b	"Allocation of RAM for new cookie jar",CR,LF
	dc.b	"failed, so installation was aborted.",CR,LF
	dc.b	"---------------------------------------",CR,LF
	dc.b	NUL
;
prompt_s:
	dc.b	CR,LF
	dc.b	"Please press a key to continue...",CR,LF
	dc.b	CR,LF
	dc.b	NUL
	even
;-----------------------------------------------------------------------------
	end
;-----------------------------------------------------------------------------
;End of file:	UKEX.S
;-----------------------------------------------------------------------------
