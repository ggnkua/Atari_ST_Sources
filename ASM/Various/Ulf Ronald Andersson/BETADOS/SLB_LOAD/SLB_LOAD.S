;----------------------------------------------------------------------------
;File name:	SLB_LOAD.S			Revision date:	1998.10.10
;Revised by:	Ronald Andersson		Revision start:	1998.09.11
;----------------------------------------------------------------------------
;Revision remarks:
;
;This program is based on the original sources for SLBLOAD.OVL by J.Reschke,
;who contributed those on a freeware basis.  I chose to translate them into
;assembly language so as to gain better control of low level efficiency.
;The assembly dialect used is DevPac 3.  (With heavy use of macros.)
;
;The purpose of the overlay remains as before, to allow MagiC-style shared
;libraries to be loaded even without MagiC, by using MetaDOS/BetaDOS with
;enhancement hooks calling this overlay.  Naturally these sources are also
;freeware, and will be offered to J.Reschke for possible bundling with his
;MetaDOS improvements, though it is mainly intended for my own BetaDOS.
;
;A number of farreaching changes have been made as compared to the original
;SLBLOAD code by J.Reschke, in order to make SLB_LOAD.OVL more compatible
;to the SLB implementation of MagiC 6.
;----------------------------------------------------------------------------
	include	RA_SLB.I
;----------------------------------------------------------------------------
	output	.OVL
;----------------------------------------------------------------------------
VERSIONSTRING	MACRO
	dc.b	'0.25'
	ENDM
;-------
DATESTRING	MACRO
	dc.b	'1998 Oct 10'
	ENDM
;----------------------------------------------------------------------------
	struct	SLB_own		;one such structure is allocated for each SLB
	struc_p SLB_own_next	;struct of next lib
	struc_p	SLB_own_pd	;SLB PD of this lib
	long	SLB_own_max	;total array cells
	long	SLB_own_act	;active array cells
	d_alias	SLB_own_arr,32	;array of owner PDs, variable cell count
	d_end	SLB_own
;----------------------------------------------------------------------------
toupper	MACRO	dreg
	cmp.b	#'a',\1
	blo.s	.char_ok_\@
	cmp.b	#'z',\1
	bhi.s	.char_ok_\@
	sub.b	#('a'-'A'),\1
.char_ok_\@:
	ENDM
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
; MetaDOS calls our init function with the following parameter:
;
; long startoftext (BASPAG **act_pd_p);
;
; act_pd_p is the pointer to the GEMDOS internal variable which
; holds the pointer to the currently executing process.
;
; The init function returns a pointer to the SLB function table,
; which contains pointers to the Slbopen() and Slbclose() functions,
; which are GEMDOS 0x16 and 0x17.
;------------------------------------
;Because of the argument usage in this startup sequence, SLB_LOAD can not
;find its own basepage ptr on the stack in the usual manner.  Instead that
;address is defined explicitly in the following code, as 'SLB_LOAD_BP'.
;----------------------------------------------------------------------------
startoftext:
	move.l	4(sp),act_pd_p
	bsr	ShowBanner
	move.l	#function_table,d0
	rts
;------------------------------------
SLB_LOAD_BP	=	startoftext-$100	;basepage of SLB_LOAD.OVL
;----------------------------------------------------------------------------
;Start of:	slbexec, the library function dispatcher
;----------------------------------------------------------------------------
; Shared Lib execution function. A pointer to this function is
; returned upon Slbopen() to the caller. It provides the hook
; to call the functions in the shared library.
;
; long slbexec (BASPAG *shared_lib, long function_number, ...)
;
; shared_lib points to the basepage of the shared library.
;
; function_number is the library function number. If it exceeds
; the maximum value or the function pointer is NULL, slbexec
; returns EINVFN.
;
; Otherwise the function is called and the D0 return value is
; forwarded to the caller.
;----------------------------------------------------------------------------
;long cdecl slbexec(SL *slb, long fn, int params, ...);
;
slbexec:
	lv_init		sp			;init local variable scope
	lv_arg.l	fun_slb_p		;-> SL struct of lib
	lv_arg.l	fun_funcnum		;function number
	lv_arg.w	fun_params		;function argument count (not used here)
	lv_arg.w	fun_arguments		;function arguments (not used here)
;-------
	move.l	fun_slb_p(sp),a0		;a0 -> Basepage == SL struct
	lea	SL_hd_end(a0),a0		;a0 -> end of SL header
	move.l	fun_funcnum(sp),d0		;d0 = function number
	cmp.l	SL_fun_cnt-SL_hd_end(a0),d0	;compare with func count
	bhs.s	.einvfn				;refuse if opcode too high
	asl	#2,d0				;scale word to index longs
	move.l	SL_fun_table-SL_hd_end(a0,d0),d0	;d0 -> function routine
	beq.s	.einvfn				;refuse if ptr is NULL
	move.l	act_pd_p,a0			;a0 -> gemdos variable act_pd
	move.l	(a0),fun_slb_p(sp)		;act_pd onto stack, replacing sl pointer
	move.l	d0,a0				;a0 = d0 -> function routine
	jmp	(a0)				;jump to function routine
;------------------------------------
.einvfn:					;Here we must refuse service
	moveq	#E_INVFN,d0			;d0 = code for INValid FuNction
	lv_exit	sp				;exit local variable scope
	rts					;return with error code
;----------------------------------------------------------------------------
;End of:	slbexec, the library function dispatcher
;----------------------------------------------------------------------------
;static void	Bconws (char *str)	;Write a string to the screen using BIOS
;
Bconws_sub:
	movem.l	a2-a3,-(sp)		;push some registers
	move.l	4(sp),a3		;a3 -> string for display
.loop:
	move.b	(a3)+,d0		;d0 = next char,  terminator ?
	beq.s	.exit			;exit loop on terminator char
	bios	Bconout,#2,d0		;output char using bios
	bra.s	.loop			;loop back for entire string
;
.exit:
	movem.l	(sp)+,a2-a3		;pull some registers
	rts				;return to caller
;------------------------------------
Bconws	MACRO	adress
	pea	\1
	bsr	Bconws_sub
	addq	#4,sp
	ENDM
;----------------------------------------------------------------------------
;Start of:	load_lib_from_mem
;----------------------------------------------------------------------------
;long load_lib_from_mem (const char *name, long minver, SL **slp)
;load a shared library from internal list
;
load_lib_from_mem:
	movem.l	d3-d4/a2-a5,-(sp)		;push some registers
	move.l	a1,a5			;a5 -> external -> SL struct (for result)
	move.l	a0,a4			;a4 -> lib name
	move.l	d0,d3			;d3 =  minimum version code
	move.l	libs(pc),a2		;a2 -> first SLB_own struct in chain
.loop_1:
	move.l	a2,d0			;is pointer valid (non-NULL) ?
	beq	.ret_E_FILNF		;return E_FILNF at end of chain
	move.l	SLB_own_pd(a2),a3	;a3 -> SL struct == SLB pd
	move.l	SL_name(a3),a0		;a0 -> name of current lib in chain
	move.l	a4,a1			;a1 -> name of lib to be loaded
.loop_2:
	move.b	(a0)+,d0		;d0 = next char of chain lib name
	beq.s	.test_str_term		;at string end, go test full equality
	toupper	d0			;force chain name char to uppercase
	move.b	(a1)+,d1		;d1 = next char of load lib name
	beq	.next_loop_1		;at string end names are unequal...
	toupper d1			;force load name char to uppercase
	cmp.b	d1,d0			;similar char ?
	beq.s	.loop_2			;if so, loop back to test whole name
	bra.s	.next_loop_1		;else names are unequal, go try next
;
.test_str_term:				;chain name was terminated, may be correct
	tst.b	(a1)			;is load name unterminated here ?
	bne.s	.next_loop_1		;then names are unequal, go try next
.found_name:				;names match !
	move.l	SL_version(a3),d0	;d0 = lib version code
	cmp.l	d3,d0			;is it sufficiently high ?
	blo.s	.next_loop_1		;else seek on (though doomed to fail !)
.found_ok_version:
	move.l	SLB_own_act(a2),d0	;d0 = active owners in the array
	cmp.l	SLB_own_max(a2),d0	;d0 = max of owners in the array
	blo.s	.have_room
.make_room:
	add.l	#32,d0			;order room for 32 more owners
	move.l	d0,d4			;d4 = array cell count for new struct
	asl.l	#2,d0			;scale this to bytes needed for array
	add.l	#sizeof_SLB_own,d0	;and add size of other SLB_own struct elements
	move.l	a3,a0			;a0 -> SLB, which is to own SLB_own struct
	bsr	own_Malloc		;now try to allocate new struct RAM
	bmi.s	.next_loop_1		;hope for another load instance on failure
	move.l	d0,a1			;a1 -> new SLB_own struct
	move.l	a2,a0			;a0 -> old SLB_own struct
	move.l	SLB_own_max(a2),d1	;d1 = array cell count of old struct
	add.l	#sizeof_SLB_own/4,d1	;d1 += size (in longs) of other struct elements
.copy_SLB_own:			;loop start to copy old struct
	move.l	(a0)+,(a1)+		;copy a longword of SLB_own struct elements
	subq.l	#1,d1			;countdown d1
	bhi.s	.copy_SLB_own		;loop back for entire old struct
	move.l	a1,d2			;d2 -> first free entry in new struct
	moveq	#32-1,d1		;d1 = dbra count for new free entries
.clear_free:			;loop start to clear free entries
	clr.l	(a1)+			;clear a free entry
	dbra	d1,.clear_free		;loop back for all free entries
	exg	d0,a2			;a2 -> new struct,  d0 -> old struct to be released
	move.l	d4,SLB_own_max(a2)	;correct array cell count of new struct
	move.l	a3,a0			;a0 -> SLB, which owns old struct
	bsr	own_Mfree		;now release old struct RAM
.have_room:
	move.l	act_pd_p(pc),a0		;a0 -> p_run
	move.l	(a0),a0			;a0 -> active basepage
	lea	SLB_own_arr(a2),a1	;a1 -> first owner entry
	move.l	SLB_own_max(a2),d2	;d2 = array cell count
.loop_3:
	tst.l	(a1)+			;free entry ?
	bne.s	.next_loop_3		;if not, go try next entry
	move.l	a0,-(a1)		;store -> active basepage in owner entry
	addq.l	#1,SLB_own_act(a2)	;increment active owner count of struct
	bra.s	.exit_loop_3		;exit_loop_3
;
.next_loop_3:
	subq.l	#1,d2			;countdown d2
	bhi.s	.loop_3			;loop back to check all owner entries
.exit_loop_3:
	cmp	#-1,d2			;did we fail to find any free entry ?
	beq.s	.next_loop_1		;then go seek another load instance
.success:
	move.l	a3,(a5)			;store -> SL struct in external ptr
.next_loop_1:
	move.l	SLB_own_next(a2),a2	;a2 -> next SLB_own struct in chain
	bra	.loop_1			;loop back to try next lib in chain
;
.ret_E_FILNF:
	moveq	#E_FILNF,d0		;d0 = E_FILNF
.exit:
	movem.l	(sp)+,d3-d4/a2-a5		;pull some registers
	rts				;return to caller
;----------------------------------------------------------------------------
;End of:	load_lib_from_mem
;----------------------------------------------------------------------------
;Start of:	link_lib_to_mem
;----------------------------------------------------------------------------
;static void link_lib_to_mem (SL *to_add)	;a0 -> new SLB, which is to own SLB_own struct
;put a shared lib onto internal list
;
link_lib_to_mem:
	move.l	#(32*4+sizeof_SLB_own),d0	;d0 = bytes needed for SLB_own struct
	bsr	own_Malloc			;now try to reserve this space
	bmi.s	.exit
	move.l	d0,a1				;a1 -> new SLB_own struct
;-------
;initialize the new SLB_own struct
;-------
	clr.l	SLB_own_next(a1)	;clear chain link of struct
	move.l	a0,SLB_own_pd(a1)	;init SLB pd ptr of struct
	moveq	#32,d1			;d1 = array cell count
	move.l	d1,SLB_own_max(a1)	;init array cell count of struct
	clr.l	SLB_own_act(a1)		;clear active owner count of struct
	lea	SLB_own_arr(a1),a0	;a0 -> first owner entry
	subq	#1,d1			;d1 = dbra count for array cells
.clear_free:
	clr.l	(a0)+			;clear one free owner entry
	dbra	d1,.clear_free		;loop back to clear all entries
;-------
;set first owner
;-------
	move.l	act_pd_p(pc),a0		;a0 -> run_p
	move.l	(a0),SLB_own_arr(a1)	;owner[0] = active basepage
	addq.l	#1,SLB_own_act(a1)	;increment active owner count
;-------
;set parent pointer, not done by Pexec 3
;-------
	move.l	SLB_own_pd(a1),a0				;a0 -> new SLB
	move.l	SLB_LOAD_pd(pc),SL_hd_bp+bp_parent_p(a0)	;parent = SLB_LOAD.OVL
;-------
;link it to the list */
;-------
	move.l	libs(pc),SLB_own_next(a1)	;link old chain into new lib
	move.l	a1,libs				;make the new lib new chain root
	moveq	#E_OK,d0			;flag success
.exit:
	rts			;return to caller
;----------------------------------------------------------------------------
;End of:	link_lib_to_mem
;----------------------------------------------------------------------------
;Start of:	unlink_lib_from_mem
;----------------------------------------------------------------------------
;static void unlink_lib_from_mem (SL *to_remove)
;remove a shared lib from internal list
;
unlink_lib_from_mem:
	move.l	a0,d2				;d2 -> SL struct to be unlinked
	lea	libs-SLB_own_next(pc),a0	;a0 -> simulated SLB_own with 'libs' as SLB_own_next
.loop:
	lea	SLB_own_next(a0),a1	;a1 -> -> current SLB_own in chain
	move.l	(a1),a0			;a0 -> current SLB_own in chain
	move.l	a0,d0			;is a0 valid ptr or end of chain ?
	beq.s	.exit			;exit at end of chain
	cmp.l	SLB_own_pd(a0),d2	;is this the lib to remove ?
	bne.s	.loop			;if not, go try the next one
	move.l	SLB_own_next(a0),(a1)	;unlink current lib
.exit:
	rts
;----------------------------------------------------------------------------
;End of:	unlink_lib_from_mem
;----------------------------------------------------------------------------
;Start of:	get_slb_path
;----------------------------------------------------------------------------
;char *get_slb_path (void); return SLBPATH environment variable string
;
get_slb_path:
	move.l	act_pd_p(pc),a0		;a0 -> run_p
	move.l	(a0),a0			;a0 -> active basepage
	move.l	bp_environ_p(a0),a0	;a0 -> active environment
	beq.s	.exit			;if no evironment, return NULL
.loop_1:
	tst.b	(a0)			;environment terminator ?
	beq.s	.exit_NULL		;at end of env, return NULL
	lea	SLBPATH_s(pc),a1	;a1 -> "SLBPATH="
	moveq	#SLBPATH_len-1,d2	;d2 = strlen -1 for dbra
.loop_2:
	move.b	(a0)+,d0		;get next env char, test if terminator
	beq.s	.loop_1			;try next string if current terminated
	cmp.b	(a1)+,d0		;does it match our string ?
	dbne	d2,.loop_2		;loop until complete or unequal
	beq.s	.exit			;if complete, return current pointer
.loop_3:
	tst.b	(a0)+			;unequal string terminator ?
	bne.s	.loop_3			;loop until unequal string terminated
	bra.s	.loop_1			;loop back to test more env strings
;-------
.exit_NULL:
	suba.l	a0,a0			;a0 = NULL as failure indication
.exit:
	rts				;return to caller with ptr in a0
;----------------------------------------------------------------------------
;End of:	get_slb_path
;----------------------------------------------------------------------------
;Start of:	load_lib_from_file
;----------------------------------------------------------------------------
;try to load shared library from a file
;long cdecl load_lib_from_file (char *name, char *path, size_t path_len, long minver)
;
load_lib_from_file:
	lv_init		a6		;init local variable scope
	lv_arg.l	fun_name
	lv_arg.l	fun_path
	lv_arg.l	fun_path_len
	lv_arg.l	fun_minver
;-------
	lv_var.l	fun_pret	;Pexec return value -> SL or is error code
	lv_var.b	fun_path_1,128
	lv_var.b	fun_path_2,128
;-------
	move.l		a2,-(sp)		;push a2
	lea		fun_path_1(a6),a1	;a1 -> path_1
	clr.b		(a1)			;terminate path_1 at base
	move.l		fun_path(a6),d0		;d0 -> path or is NULL
	beq.s		.at_path_term		;treat NULL as empty string, (CWD)
	move.l		d0,a0			;a0 -> path
	move.l		fun_path_len(a6),d2	;d2 =  path_len
	beq.s		.at_path_term		;use CWD for empty string
	cmp.l		#127,d2			;check length against buffer size
	bhs.s		.at_path_term		;use CWD if length bogus
	subq		#1,d2			;d2 = dbra count for path_len bytes
.copy_path_lp:
	move.b		(a0)+,(a1)+		;copy one byte per loop
	dbeq		d2,.copy_path_lp	;loop until path_len chars or term
	bne.s		.at_path_term		;if path unterminated pos is ok
	subq		#1,a1			;a1 -> copy of path terminator
.at_path_term:
	clr.b		(a1)			;terminate copy at this pos
	lea		fun_path_1(a6),a0	;a0 -> primary path, just copied
	lea		fun_path_2(a6),a1	;a1 -> secondary path, for expansion
	bsr		fix_path		;expand to absolute path
	bmi		.bad_path		;abort process if path bugged !
	exg		a0,a1			;a0 -> secondary,  a1 -> primary
	bsr		fix_path		;re-expand, to resolve all path backing
	bmi		.bad_path		;abort process if path bugged !
;-------
;Here the primary path at (a1) is a fully resolved and absolute path string.
;This also assures ample space for long name appended to this path, since the
;secondary buffer is no longer needed.
;-------
.test_end_lp:
	tst.b		(a1)+			;terminator ?
	bne.s		.test_end_lp		;loop to find end of string
	subq		#1,a1			;back a1 to terminator
	cmp.b		#'\',-1(a1)		;path separator before terminator ?
	beq.s		.done_path		;if so, no need to add one
	move.b		#'\',(a1)+		;else add a backslash
.done_path:					;here a1 -> place for name in pathname
	move.l		fun_name(a6),a0		;a0 -> lib name
.copy_name_lp:
	move.b		(a0)+,(a1)+		;copy one name char per loop
	bne.s		.copy_name_lp		;loop back for entire name
;-------
;try to load SLB
;-------
	lea	fun_path_1(a6),a0		;a0 -> pathname
	bsr	own_Pexec_3			;now load and relocate the SLB
	move.l	d0,fun_pret(a6)			;store -> SL (basepage) or error code
	blt	.exit				;exit on error code
	move.l	d0,a0				;a0 -> SL of new lib
;-------
;check for MagiC 6.x shared lib magic value
;-------
	cmp.l	#SLB_MAGIC,SL_magic(a0)		;correct MagiC 6 SLB magic value ?
	beq.s	.magic_ok			;go to .magic_ok if magic ok... ;-)
	move.l	SLB_LOAD_pd(pc),a0	;a0 -> SLB_LOAD_BP, which owns SLB
	move.l	fun_pret(a6),d0		;d0 -> SLB, to be released
	bsr	own_Mfree		;now release this RAM
	moveq	#E_PLFMT,d0			;d0 = errcode Program Load ForMaT
	bra	.exit				;return to caller
;
.magic_ok:
;-------
;check version number
;-------
	move.l	SL_version(a0),d0		;d0 = lib version code
	cmp.l	fun_minver(a6),d0		;check version against minimum
	bhs.s	.version_ok			;go to .version ok if version ok... ;-)
	move.l	SLB_LOAD_pd(pc),a0	;a0 -> SLB_LOAD_BP, which owns SLB
	move.l	fun_pret(a6),d0		;d0 -> SLB, to be released
	bsr	own_Mfree		;now release this RAM
	moveq	#E_RANGE,d0			;d0 = errcode RANGE
	bra	.exit				;return to caller
;
.version_ok:
;-------
;check lib name, not done by MagiC!
;-------
	move.l	SL_name(a0),a0
	move.l	fun_name(a6),a1
;
.loop_3:
	move.b	(a0)+,d0		;d0 = next char of real lib name
	beq.s	.test_str_term		;at string end, go test full equality
	toupper	d0			;force real name char to uppercase
	move.b	(a1)+,d1		;d1 = next char of sought name
	beq.s	.bad_name		;at string end names are unequal...
	toupper d1			;force sought name char to uppercase
	cmp.b	d1,d0			;similar char ?
	beq.s	.loop_3			;if so, loop back to test whole name
	bra.s	.bad_name		;else names are unequal, go try next
;
.test_str_term:				;real name was terminated, may be correct
	tst.b	(a1)			;is sought name unterminated here ?
	beq.s	.name_is_ok		;go to name_is_ok if name is ok... ;-)
.bad_name:
	move.l	SLB_LOAD_pd(pc),a0	;a0 -> SLB_LOAD_BP, which owns SLB
	move.l	fun_pret(a6),d0		;d0 -> SLB, to be released
	bsr	own_Mfree		;now release this RAM
.bad_path:
	moveq	#E_ERROR,d0		;d0 = errcode general ERROR
	bra.s	.exit			;return to caller
;
.name_is_ok:
;-------
;shrink memory
;-------
	move.l	fun_pret(a6),a0			;a0 -> SL of lib == its basepage
	move.l	#sizeof_BasePage,d0
	add.l	SL_hd_bp+bp_textlen(a0),d0
	add.l	SL_hd_bp+bp_datalen(a0),d0
	add.l	SL_hd_bp+bp_bss_len(a0),d0
	gemdos	Mshrink,!,(a0),d0
;-------
;hook into onto the internal list
;-------
	move.l	fun_pret(a6),a0
	bsr	link_lib_to_mem
	tst.l	d0
	bpl.s	.link_is_ok
.bad_link_memory:
	move.l	SLB_LOAD_pd(pc),a0	;a0 -> SLB_LOAD_BP, which owns SLB
	move.l	fun_pret(a6),d0		;d0 -> SLB, to be released
	bsr	own_Mfree		;now release this RAM
	moveq	#E_NSMEM,d0		;d0 = errcode for 'Not Suffificient MEMory'
	bra.s	.exit			;return to caller
;
.link_is_ok:
;-------
;patch real pathname into command line area of SLB basepage
;-------
	lea	fun_path_1(a6),a0	;a0 -> path string used for Pexec
	move.l	fun_pret(a6),a1		;a1 -> SL
	lea	SL_hd_path(a1),a1	;a1 -> path string in SL
	bsr	fix_path		;expand to full SLB path in SL
	tst.l	d0			;error code ?
	bmi.s	.bad_link_memory	;if so, something crashed the SLB RAM...
;-------
;call the library init function
;-------
	move.l	act_pd_p(pc),a0		;a0 -> p_run
	move.l	(a0),-(sp)		;push -> active basepage onto stack
	move.l	fun_pret(a6),(a0)	;make SLB active basepage
	move.l	(a0),a0			;a0 -> SLB
	move.l	SL_slb_init(a0),a0	;a0 -> slb_init in SLB
	jsr	(a0)			;call slb_init in SLB
	move.l	act_pd_p(pc),a0		;a0 -> p_run
	move.l	(sp)+,(a0)		;pull -> active basepage from stack
;-------
.exit_pret:
	move.l	fun_pret(a6),d0
.exit:
	move.l	(sp)+,a2		;pull a2
	lv_exit	a6			;exit local variable scope
	rts
;----------------------------------------------------------------------------
;End of:	load_lib_from_file
;----------------------------------------------------------------------------
;Start of:	load_lib
;----------------------------------------------------------------------------
;long cdecl load_lib(char *name, char *path, char *alt_path, long minver, SL **slp)
;returns: version number of loaded sl or < 0
;
load_lib:
	lv_init		a6		;init local variable scope
	lv_arg.l	fun_name	;name of library
	lv_arg.l	fun_path	;main path to use or NULL
	lv_arg.l	fun_alt_path	;alternative path or NULL
	lv_arg.l	fun_minver	;minimal version number
	lv_arg.l	fun_slp		;return pointer to shared lib in this **
;-------
	lv_var.l	fun_ret
;-------
;check for SLB in memory
;-------
	move.l	fun_name(a6),a0		;a0 -> lib name
	move.l	fun_minver(a6),d0	;d0 = minimum version code
	move.l	fun_slp(a6),a1		;a1 -> -> SL struct (for result)
	bsr	load_lib_from_mem	;ret = load_lib_from_mem (name, minver, slp);
	move.l	d0,fun_ret(a6)		;store and test result
	bge	.exit			;return this result if positive
;-------
;check for SLB in specified path
;-------
	move.l	fun_path(a6),a1		;a1 -> path, unless NULL
	move.l	a1,d0			;d0 = a0, to test if NULL
	beq.s	.load_in_default_paths	;if NULL, use this as dummy strlen
.loop_1:
	tst.b	(a1)+			;path terminator ?
	bne.s	.loop_1			;loop to find terminator
	subq	#1,a1			;a1 -> path terminator
	move.l	a1,d0			;d0 -> path terminator
	move.l	fun_path(a6),a1		;a1 -> path start
	sub.l	a1,d0			;d0 = strlen of path
.have_strlen:
	move.l	fun_minver(a6),-(sp)	;push minimum version code
	move.l	d0,-(sp)		;push strlen(path)
	move.l	fun_path(a6),-(sp)	;push -> path
	move.l	fun_name(a6),-(sp)	;push -> lib name
	bsr	load_lib_from_file	;ret = load_lib_from_file (name, path, path ? strlen (path) : 0, minver);
	lea	16(sp),sp		;clean stack
	move.l	d0,fun_ret(a6)		;store and test result
	bge.s	.fix_file_return	;return this result if positive
.load_in_default_paths:
;-------
;check for SLB elsewhere
;-------
	movem.l	d3/a3,-(sp)		;push some registers
	move.l	fun_alt_path(a6),a3	;a3 -> alternate path (from env or config)
	move.l	a3,d0			;test for NULL
	beq.s	.exit_loop_2		;skip loop for NULL string
.loop_2:
	tst.b	(a3)			;path string terminator ?
	beq.s	.exit_loop_2		;exit loop at path string end
	clr.l	d3			;clr subpath length
.loop_3:
	move.b	(a3,d3),d0		;d0 = a3[d3], but is that a terminator ?
	beq.s	.exit_loop_3		;exit loop_3 on path string terminator
	cmp.b	#';',d0			;semicolon as subpath separator ?
	beq.s	.exit_loop_3		;exit loop 3 on semicolon
	cmp.b	#',',d0			;comma as subpath separator ?
	beq.s	.exit_loop_3		;exit loop_3 on comma
	addq	#1,d3			;step d3 index to next char
	bra.s	.loop_3			;loop back for next char of subpath
;
.exit_loop_3:
	move.l	fun_minver(a6),-(sp)	;push minimum version code
	move.l	d3,-(sp)		;push subpath length
	move.l	a3,-(sp)		;push -> subpath
	move.l	fun_name(a6),-(sp)	;push -> lib name
	bsr	load_lib_from_file	;ret = load_lib_from_file (name, c, l, minver);
	lea	16(sp),sp		;clean stack
	move.l	d0,fun_ret(a6)		;store and test result
	bge.s	.exit_loop_2		;exit loop_2 if positive
	tst.b	(a3,d3)			;was last char separator or terminator ?
	beq.s	.exit_loop_2		;exit loop_2 on terminator
	add	d3,a3			;a3 -> subpath separator
	addq	#1,a3			;a3 -> next subpath
	bra.s	.loop_2			;loop back to try next subpath
;
.exit_loop_2:
	movem.l	(sp)+,d3/a3		;pull some registers
	move.l	fun_ret(a6),d0		;d0 = last load_lib_... return value
	blt.s	.exit			;return this value if error code
.fix_file_return:
	move.l	fun_slp(a6),a1		;a1 -> external SL pointer
	move.l	d0,(a1)			;store -> new SL struct in external pointer
	move.l	d0,a0			;a0 -> new SL struct
	move.l	SL_version(a0),d0	;d0 = lib version code
.exit:
	lv_exit	a6			;exit local variable scope
	rts
;----------------------------------------------------------------------------
;End of:	load_lib
;----------------------------------------------------------------------------
;Start of:	Slbopen_fun, the MetaDOS entry point for Slbopen()
;----------------------------------------------------------------------------
;long cdecl Slbopen (long rts, int opcode, const char *name, const char *path,
;		     long min_ver, SL **slp, void **fn, long param)
Slbopen_fun:
	lv_init		a6		;init local variable scope
	lv_arg.l	fun_rts		;Return address within MetaDOS
	lv_arg.w	fun_opcode	;GEMDOS opcode
	lv_arg.l	fun_name	;Name of shared library
	lv_arg.l	fun_path	;Path to use or NULL
	lv_arg.l	fun_min_ver	;Minimal version number
	lv_arg.l	fun_slp		;Pointer to pointer to shared library
	lv_arg.l	fun_fn_p_p	;Pointer to library function hook
	lv_arg.l	fun_param	;? (extra parameters ? (legal ?))
;-------
	lv_var.l	fun_ret
	lv_var.l	fun_sl
	lv_var.l	fun_env_path
;-------
	bsr	get_slb_path		;get SLBPATH variable from environment
	move.l	a0,fun_env_path(a6)	;store address locally
;-------
	bne.s	.done_path				;keep path unless invalid
	move.l	alternate_path(pc),fun_env_path(a6)	;use path from config
.done_path:
;-------
	pea	fun_sl(a6)		;push -> local SL struct pointer
	move.l	fun_min_ver(a6),-(sp)	;push long minimum version code
	move.l	fun_env_path(a6),-(sp)	;push -> SLBPATH env value/alternate_path
	move.l	fun_path(a6),-(sp)	;push -> caller specified path
	move.l	fun_name(a6),-(sp)	;push -> lib name
	bsr	load_lib		;load_lib (name, path, env_path, min_ver, &sl);
	lea	(5*4)(sp),sp
;-------
	move.l	d0,fun_ret(a6)		;store return value (for exit)
	blt.s	.exit			;if error code, exit at once
	move.l	act_pd_p(pc),a0		;a0 -> p_run
	move.l	(a0),-(sp)		;push -> active basepage
	move.l	fun_sl(a6),a0
	move.l	SL_slb_open(a0),d0	;d0 -> slb_open routine in lib
	jsr	user_call		;call slb_open routine in CPU user mode
	addq	#4,sp			;clean stack
	move.l	fun_fn_p_p(a6),a1	;a1 -> external function ptr
	lea	slbexec(pc),a0		;a0 -> local slbexec routine
	move.l	a0,(a1)			;store -> slbexec in external ptr
	move.l	fun_slp(a6),a1		;a1 -> external SL struct ptr
	move.l	fun_sl(a6),(a1)		;store -> loaded struct in external ptr
	move.l	fun_ret(a6),d0		;restore correct return value
.exit:
	lv_exit	a6			;exit local variable scope
	rts				;return to caller
;----------------------------------------------------------------------------
;End of:	Slbopen_fun, the MetaDOS entry point for Slbopen()
;----------------------------------------------------------------------------
;Start of:	close_slb, subfunction to close one library for one owner
;----------------------------------------------------------------------------
;long	close_slb (BASPAG *curr_proc, SL *sl)
;
close_slb:
	movem.l	d3/a2-a5,-(sp)		;push some registers
	move.l	a0,a4				;a4 -> basepage of owner
	move.l	a1,a5				;a5 -> SL struct of lib
;
	lea	libs-SLB_own_next(pc),a0	;a0 -> simulated SLB_own with 'libs' as SLB_own_next
.chain_loop:
	lea	SLB_own_next(a0),a1	;a1 -> -> current SLB_own in chain
	move.l	(a1),a0			;a0 -> current SLB_own in chain
	move.l	a0,d0			;is a0 valid ptr or end of chain ?
	beq.s	.exit_E_ACCDN		;exit with error at end of chain, the SLB is not in it
	cmpa.l	SLB_own_pd(a0),a5	;is this the lib to remove ?
	bne.s	.chain_loop		;if not, loop back to try entire chain
	move.l	a0,a2			;a2 -> SLB_own struct of found SLB
;
	lea	SLB_own_arr(a2),a3	;a3 -> first owner entry in array
	move.l	SLB_own_max(a2),d3	;d3 = array cell count
.array_loop:
	cmpa.l	(a3),a4			;is current entry the same owner ?
	beq.s	.found_entry		;if so, break loop to .found_entry
.next_entry:
	addq	#4,a3			;a3 -> next owner entry
	subq.l	#1,d3
	bhi.s	.array_loop		;loop back for all entries in array
.exit_E_ACCDN:
	moveq	#E_ACCDN,d0		;d0 = errorcode for 'ACCess DeNied'
	bra.s	.exit			;the claimed owner is incorrect, so exit with error
;
.found_entry:
	pea	(a4)			;push -> owner basepage
	move.l	SL_slb_close(a5),d0	;d0 -> slb_close routine in lib
	jsr	user_call		;call slb_open routine in CPU user mode
	addq	#4,sp			;clean stack
	clr.l	(a3)			;erase owner entry
	subq.l	#1,SLB_own_act(a2)	;decrement active owner count
	bne.s	.exit_ok		;if non-zero, go keep lib for remaining owners
;-------
;call the library exit function
;-------
	move.l	act_pd_p(pc),a0		;a0 -> p_run
	move.l	(a0),-(sp)		;push -> active basepage onto stack
	move.l	a5,(a0)			;make SLB active basepage
	move.l	SL_slb_exit(a5),a0	;a0 -> slb_exit in SLB
	jsr	(a0)			;call slb_exit in SLB
	move.l	act_pd_p(pc),a0		;a0 -> p_run
	move.l	(sp)+,(a0)		;pull -> active basepage from stack
;-------
	move.l	a5,a0			;a0 -> SL struct of lib
	bsr	unlink_lib_from_mem	;unlink the lib from memory
	move.l	a5,a0			;a0 -> SLB, which owns the SLB_own struct
	move.l	a2,d0			;d0 -> SLB_own struct, to be released
	bsr.s	own_Mfree		;now release SLB_own struct RAM
	move.l	SLB_LOAD_pd(pc),a0	;a0 -> SLB_LOAD_BP, which owns SLB
	move.l	a5,d0			;d0 -> SLB, to be released
	bsr.s	own_Mfree		;now release SLB RAM
.exit_ok:
	moveq	#E_OK,d0		;flag success
.exit:
	movem.l	(sp)+,d3/a2-a5		;pull some registers
	rts				;return to caller
;----------------------------------------------------------------------------
;End of:	close_slb, subfunction to close one library for one owner
;----------------------------------------------------------------------------
;Start of:	Slbclose_fun, the MetaDOS entry point for Slbclose()
;----------------------------------------------------------------------------
;long cdecl Slbclose_fun (long fun_rts, int fun_opcode, SL *fun_SL_p)
;
Slbclose_fun:
	lv_init		a6		;init local variable scope
	lv_arg.l	fun_rts
	lv_arg.w	fun_opcode
	lv_arg.l	fun_SL_p
;-------
	move.l	fun_SL_p(a6),d0		;d0 -> SL struct, or is NULL
	bne.s	.valid_PTR		;skip to .valid_PTR if not NULL
;-------
;Special case:	MetaDOS calls Slbclose with a NULL SL pointer when the current
;		process exits, to remove it as owner of any libs.
;-------
	pea	(a3)			;push a3
	move.l	libs,a3			;a3 -> lib chain
.loop:					;loop start
	move.l	a3,d0			;d0 -> current SLB_own struct, or is NULL
	beq.s	.exit_loop		;exit loop at chain end
	move.l	act_pd_p(pc),a0		;a0 -> p_run
	move.l	(a0),a0			;a0 -> active basepage
	move.l	SLB_own_pd(a3),a1	;a1 -> current SL struct == SLB pd
	bsr	close_slb		;close that lib for active owner
	move.l	SLB_own_next(a3),a3	;a3 -> next SLB_own struct
	bra.s	.loop			;loop back for entire chain
;
.exit_loop:
	move.l	(sp)+,a3		;pull a3
	moveq	#E_OK,d0		;flag success
	bra.s	.exit			;exit without error
;
.valid_PTR:
	move.l	act_pd_p(pc),a0		;a0 -> p_run
	move.l	(a0),a0			;a0 -> active basepage
	move.l	d0,a1			;a1 -> SL struct of lib
	bsr	close_slb		;close that lib for active owner
.exit:
	lv_exit	a6			;exit local variable scope
	rts				;return to caller
;----------------------------------------------------------------------------
;End of:	Slbclose_fun, the MetaDOS entry point for Slbclose()
;----------------------------------------------------------------------------
own_Mfree:
	movem.l	d0-d2/a0-a2,-(sp)	;push some registers
	move.l	act_pd_p(pc),a2		;a2 -> p_run
	move.l	(a2),-(sp)		;push active pd onto stack
	move.l	a0,(a2)			;force active pd = a0
	gemdos	Mfree|_ind,d0		;release RAM block
	move.l	act_pd_p(pc),a2		;a2 -> p_run
	move.l	(sp)+,(a2)		;pull active pd from stack
	movem.l	(sp)+,d0-d2/a0-a2	;pull some registers
	rts				;return to caller
;----------------------------------------------------------------------------
own_Malloc:
	movem.l	d1-d2/a0-a2,-(sp)	;push some registers
	move.l	act_pd_p(pc),a2		;a2 -> p_run
	move.l	(a2),-(sp)		;push active pd onto stack
	move.l	a0,(a2)			;force active pd = a0
	gemdos	Malloc,d0		;allocate RAM block
	move.l	act_pd_p(pc),a2		;a2 -> p_run
	move.l	(sp)+,(a2)		;pull active pd from stack
	movem.l	(sp)+,d1-d2/a0-a2	;pull some registers
	rts				;return to caller
;----------------------------------------------------------------------------
own_Pexec_3:
	movem.l	d1-d2/a0-a2,-(sp)	;push some registers
	gemdos	Pexec,#3,(a0),NULL_s(pc),NULL
	movem.l	(sp)+,d1-d2/a0-a2	;pull some registers
	rts				;return to caller
;----------------------------------------------------------------------------
;Start of:	user_call,	calls routines in user mode from super mode
;----------------------------------------------------------------------------
user_call:
	sub.l	#$200,user_call_sp	;reserve super_stack area
	move.l	user_call_sp(pc),a1	;a1 -> reserved area
	lea	super_stack(pc),a0	;a0 -> super_stack base
	cmpa.l	a0,a1			;is pointer below base
	bhs.s	.user_call_sp_ok	;if not, go call user routine in user mode
	add.l	#$200,user_call_sp	;release (unavailable) super_stack area
	move.l	d0,-(sp)		;push address of user routine
	rts				;goto user routine in super mode
;
;For the case above, all extra stack space is exhausted, and the call has to
;be completed in supervisor mode, in the hope that this will work (often does).
;
;For the case below, the call will be completed in user mode.
;
.user_call_sp_ok:
	lea	$200(a1),a1		;a1 -> top of reserved area
	exg	sp,a1			;SSP -> reserved area, a1 = old_SSP
	move.l	USP,a0			;a0 = old_USP
	move.l	a0,-(sp)		;push old_USP in reserved super_stack area
	move.l	act_pd_p(pc),a0		;a0 -> p_run
	move.l	(a0),-(a1)		;push active PD on future stack
	move.l	#post_uc,-(a1)		;push return address on future stack
	move.l	d0,-(a1)		;push subr address on future stack
	move.l	a1,USP			;USP = old_SSP - 12 -> 3 longs
;-------
	lea	(ev_trap11).w,a0	;a0 -> vector root
	addq	#1,XB_cnt		;increment link level
	move.l	XB_uc+xb_id(pc),d0	;d0 = XBRA id
	bsr	kill_XB			;unlink XB_uc
	lea	XB_uc(pc),a1
	bsr	init_XB			;linkup XB_uc
;-------
	andi	#$DFFF,SR		;force user mode
	rts				;go to user_mode subroutine
;-------
post_uc:
	addq	#4,sp			;pop PD ptr off stack, USP = old_SSP
	trap	#11			;force Super mode at XB_uc+xb_code
user_call_ref:
	illegal
;-------
XB_cnt:	dc.w	0
;-------
XB_uc:	dc.l	'XBRA'
	dc.l	'SLBt'
	dc.l	0
	cmpi.l	#user_call_ref,2(sp)	;is this our own ref ?
	beq.s	.done_user_call
	move.l	XB_uc+xb_next(pc),-(sp)
	rts				;goto original vector code
;-------
.done_user_call:
	addq	#6,sp			;remove small SSP stack frame
	tst	(_longframe).w		;was that enough ?
	beq.s	.cpu_adapted		;if so, then we're adapted
	addq	#2,sp			;else remove remainder of large stack frame
.cpu_adapted:
	move.l	sp,a0			;a0 -> top of reserved super_stack area -4 -> old_USP
	move.l	USP,sp			;SSP = USP = old_SSP
	move.l	(a0)+,a1		;a1 = old_USP,  a0 -> top of reserved super_stack area
	move.l	a0,user_call_sp		;release reserved super_stack area
	move.l	a1,USP			;USP = old_USP
;-------
;Here all three stacks are back in the state of 'user_call' entry
;-------
	move.l	d0,-(sp)		;push return value
	lea	(ev_trap11).w,a0	;a0 -> vector root
	move.l	XB_uc+xb_id(pc),d0	;d0 = XBRA id
	bsr	kill_XB			;unlink XB_uc
	subq	#1,XB_cnt		;countdown link level
	beq.s	.done_XB_fixes		;skip linkup at level zero
	lea	XB_uc(pc),a1
	bsr	init_XB			;linkup XB_uc
.done_XB_fixes:
	move.l	(sp)+,d0		;d0 = return value
	rts
;----------------------------------------------------------------------------
;End of:	user_call,	calls routines in user mode from super mode
;----------------------------------------------------------------------------
;Start of:	fix_path(orig_p, path_p)	=> path_p -> Full pathname
;----------------------------------------------------------------------------
; orig_p	-> user buffer holding pathname (altered)
; path_p	-> buffer for absolute pathname (result)
;----------------------------------------------------------------------------
fix_path:
	movem.l	d1-d3/a0-a4,-(sp)	;protect entry registers
	move.l	a0,a4			;a4 = a0 -> orig path buffer
	move.l	a1,a3			;a3 = a1 -> result path base
;
	move.l	a4,a2			;a2 -> arg path base
	clr	d0			;clear upper byte of d0 word
	move.b	(a4)+,d0		;d0 =  drive letter if included
	beq.s	.fix_default_drive	;get default path if none given
	toupper	d0			;force d0 to uppercase drive letter
	cmp.b	#':',(a4)+		;colon is required after drive letter
	beq.s	.fix_drive_d0		;if colon present, use this drive spec
.fix_default_drive:			;else call gemdos to find default
	move.l	a2,a4			;a4 -> arg path base
	gemdos	Dgetdrv			;d0 =  default drive code of gemdos
	add	#'A',d0			;d0 =  uppercase default drive letter
.fix_drive_d0:
	lea	128(a3),a2		;a2 -> end of area allowed for result
	move.b	d0,(a3)+		;store drive letter in user buffer
	move.b	#':',(a3)+		;append colon to user buffer
	sub	#'A',d0			;d0 = current drive code
;
	cmp.b	#'\',(a4)		;does pure path begin with backslash
	beq.s	.fix_absolute		;then go to fix absolute path
.fix_relative:				;else stay to fix relative path
	addq	#1,d0			;d0 = drive code +1
	gemdos	Dgetpath,(a3),d0	;append default path to result
.find_relation:			;loop start to find terminator of result string
	tst.b	(a3)+			;terminator ?
	bne.s	.find_relation		;loop back until terminator passed
	cmpa.l	a2,a3			;past legal area ?
	bhi.s	.disaster		;Ooops !  Dgetpath just crashed our buffer
	subq	#1,a3			;back pointer to terminator
	cmp.b	#'\',-1(a3)		;final character backslash ?
	beq.s	.append_lp_1		;then append relative path directly
	move.b	#'\',(a3)+		;else append a backslash first
	clr.b	(a3)			;and reterminate
.append_lp_1:				;Here a4 -> 1st char of path or subpath
	cmp.b	#'\',(a4)		;duplicate path separator (ignorable) ?
	beq.s	.ignore_1_char		;if so, go ignore it
	cmp.b	#'.',(a4)		;does a name begin with period ?
	bne.s	.append_lp_2		;if not, go deal with it normally
	tst.b	1(a4)			;is next char terminator ?
	beq.s	.ignore_1_char		;then just ignore the period
	cmp.b	#'\',1(a4)		;is it a harmless case of '.\' (ignorable) ?
	beq.s	.ignore_2_char		;if '.\' go ignore it,  as it should be...
	cmp.b	#'.',1(a4)		;is it '..' (path backing) ?
	bne.s	.bad_path		;else path is unacceptable, but buffer is ok
	tst.b	2(a4)			;final '..' ?
	beq.s	.back_path		;then go do path backing
	cmp.b	#'\',2(a4)		;is it '..\' ?
	bne.s	.bad_path		;else path is unacceptable, but buffer is ok
.back_path:
	move.b	-(a3),d0		;d0 = dest char at backed position
	cmp.b	#'\',d0			;is it a path separator ?
	bne.s	.bad_path		;else path is unacceptable, but SLB still lives...
.back_path_lp:
	move.b	-(a3),d0		;d0 = dest char at backed position
	cmp.b	#':',d0			;is it a drive root separator ?
	beq.s	.bad_path		;then path is unacceptable, but SLB still lives...
	cmp.b	#'\',d0			;is it a path separator ?
	bne.s	.back_path_lp		;else loop back to seek start of subpath
	addq	#1,a3			;step past that separator again
	clr.b	(a3)			;and reterminate
	tst.b	2(a4)			;was this '..\', or final '..' ?
	beq.s	.ignore_2_char		;if final '..', ignore only 2 chars
.ignore_3_char:
	addq	#1,a4			;step past one source char
.ignore_2_char:
	addq	#1,a4			;step past one source char
.ignore_1_char:
	addq	#1,a4			;step past one source char
	bra.s	.append_lp_1		;loop back to try next subpath/name
;
.fix_absolute:
.append_lp_2:				;loop start for most char's of path
	cmpa.l	a2,a3			;past legal area ?
	bhi.s	.disaster		;Ooops !  Somehow we've crashed our SLB...
	beq.s	.bad_path		;The path is too long, but SLB still lives...
;-------
;Here the path is still valid...
;-------
	move.b	(a4)+,d0		;d0 = next byte of the path
	move.b	d0,(a3)+		;append byte to result
	beq.s	.exit_ok		;exit ok on terminator
	cmp.b	#'\',d0			;path separator ?
	bne.s	.append_lp_2		;if not, loop back to copy another char
	bra.s	.append_lp_1		;else, loop back to test subpath/name
;
.disaster:
	moveq	#E_ERROR,d0		;flag error
	bra.s	.exit
;
.bad_path:
	clr.b	-128(a2)		;reterminate bad path at base
.exit_ok:
	moveq	#E_OK,d0		;flag success
.exit:
	movem.l	(sp)+,d1-d3/a0-a4	;restore entry registers
	rts				;return to caller
;----------------------------------------------------------------------------
;End of:	fix_path(path_p)
;----------------------------------------------------------------------------
;char *sccsid (void)
;
sccsid:
	lea	version_info_s(pc),a0	;a0 -> version info string
	move.l	a0,d0			;d0 -> version info string
	rts				;return to caller
;----------------------------------------------------------------------------
;void	ShowBanner (void)
;
ShowBanner:
	Bconws	banner_s(pc)
	lea	(startoftext-$100)+bp_arglen(pc),a0	;a0 -> arg_len byte
	clr	d0			;clear high bits of d0 word
	move.b	(a0)+,d0		;d0 = string length,  a0 -> argument string
	clr.b	(a0,d0)			;terminate string (PEXEC doesn't)
	tst.b	(a0)			;any chars in string ?
	bne.s	.done_path		;if so, then we keep it
	suba.l	a0,a0			;else a0 = NULL
.done_path:
	move.l	a0,alternate_path	;store string ptr for future
	beq.s	.done_banner		;banner is done if ptr is NULL
	Bconws	lib_path_s(pc)		;show text before path string
	move.l	alternate_path(pc),a0	;a0 -> path string
	Bconws	(a0)			;show that string
	Bconws	crlf_s			;terminate display line
.done_banner:
	rts				;return to caller
;----------------------------------------------------------------------------
	include	easy_xb.s
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
version_info_s:	dc.b	'@(#)slb_load.ovl '
		VERSIONSTRING
		dc.b	', Copyright (c) Ronald Andersson, '
		DATESTRING
		dc.b	NUL
banner_s:	dc.b	ESC,'p'
		dc.b	' SLB_LOAD '
		VERSIONSTRING
		dc.b	' ',ESC,'q'
crlf_s:		dc.b	CR,LF,NUL
lib_path_s:	dc.b	' Default library path is: ',NUL
SLBPATH_s:	dc.b	"SLBPATH="
SLBPATH_end:
SLBPATH_len	=	(SLBPATH_end-SLBPATH_s)
;-------
	EVEN	;place strings above, words and longs below...
;-------
NULL_s:		dc.l	0
SLB_LOAD_pd:	dc.l	SLB_LOAD_BP
function_table:	dc.l	Slbopen_fun,Slbclose_fun
user_call_sp:	dc.l	super_stk_top
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
act_pd_p:	ds.l	1	;BASPAG **act_pd_p;
alternate_path:	ds.l	1	;alternate path for SLBs
libs:		ds.l	1	;linked list of SLB_own structs
super_stack:	ds.l	1024	;supervisor stack for 'user_call'
super_stk_top:
;----------------------------------------------------------------------------
;End of file:	SLB_LOAD.S
;----------------------------------------------------------------------------
