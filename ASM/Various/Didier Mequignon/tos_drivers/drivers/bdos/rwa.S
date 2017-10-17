/*
 * rwa.s - GEMDOS assembler interface
 *
 * Copyright (c) 1999 by Caldera Inc.
 * Copyright (c) 1985, 2001 by Authors:
 *
 *  EWF  Eric W. Fleischman
 *  JSL  Jason S. Loveman
 *  SCC  Steven C. Cavender
 *  ACH  Anthony C. Hay
 *  MAD  Martin Doering
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 *
 */

//============================================================================
//
// Originally written by JSL.
//
// MODIFICATION HISTORY
//
//      11 Mar 85       SCC     Added xgetsup() functionality as a hack in
//                              _entry().
//                              Removed get sup functionality from exit().
//      11 Mar 85       JSL     Changed timer vector number.
//      12 Mar 85       SCC     Modified xgetsup() functionality in _entry().
//      13 Mar 85       SCC     Changed 'xgetsup()' type functionality to
//                              'toggle/inquire processor/stack state' type
//                              functionality.
//      25 Mar 85       SCC     Modified 'tikhnd:'.  It didn't need to save
//                              the registers it was saving.
//       1 Apr 85       SCC     Modified 'tikhnd:'.  It needed to get the
//                              number of milliseconds since last tick into
//                              the right place for the stack frame for call
//                              to tikfrk().
//      10 Apr 85       SCC     Modified longjmp() to use long return value
//                              on stack.
//      12 Apr 85       SCC     Modified exit() to check for function -1
//                              (return address of screen driver.
//      14 Apr 85       SCC     Modified osinit() to disable interrupts while
//                              initializing the tick vector.
//      19 Apr 85       SCC     Modified osinit() to preserve the previous
//                              state of the SR.
//      22 Apr 85       SCC     Modified the saving of SR to store it
//                              temporarily in a static.
//
//      31 May 85       EWF     Added in conditional assembly for 68010-based
//                              systems.
//
//      19 Jun 85       EWF     Added additional conditional assemblies for
//                              68010-based systems.
//
//       9 Aug 85       SCC     Modified osinit() to get tick vector from
//                              clock device handle.
//
//                              NOTE:   STACK LOOKS DIFFERENT THAT ATARI'S ON
//                                      INVOCATION OF TICK HANDLER!
//
//                              Modified tikhnd: to work with new clock format
//                              (tick value in long above long flag value on
//                              stack)
//
//      15 Aug 85       SCC     Modified tikhnd:.  It was picking up the
//                              number of milliseconds from the wrong location
//                              on the stack.
//
//      18 Aug 85       SCC     Added copyright message.
//
//       1 Nov 85       SCC     Converted to runtime determination of
//                              processor type (68000 v. 68010)
//
//                              Added 68010 'MOVE SR,...' to 'MOVE CCR,...'
//                              illegal instruction handler
//
//                              Converted all exception vector handling to
//                              use BIOS calls, rather than direct addresses.
//
//       4 Nov 85       SCC     Cleaned up a stack imbalance problem in
//                              'ii_handler'.  It was not POPing D0/A0 off
//                              the stack before going off to the OEM's
//                              Illegal Instruction handler.
//
//      11 Nov 85       KTB     put trap2 handler back in for the nonce
//
//      14 May 86       KTB     removed dojmp
//
//      02 Jul 86       KTB     M01.01a.0702.01 osinit now returns address of 
//                              date/time stamp for bdos
//
//      23 Jul 86       KTB     M01.01.0723.01 osinit needs to save stack ptr
//                              in some other reg besides d1.
//
//      24 Jul 86       KTB     M01.01.0724.01 osinit no longer returns addr
//                              of date/time stamp.  this is all handled in 
//                              startup.a
//
//      04 Aug 86       KTB     M01.01.0804.02 osinit => _osinit
//
//      28 Aug 86       SCC     M01.01.0828.01 changed TRAP #2 handler back
//                              similar to the way it was in the olden days
//                              for Atari's benefit in bringing up a system
//                              where the VDI and AES are already in memory.
//
//      19 May 87       ACH     The 68070 has an exception stack frame similar
//                              to the 68010 but it does not impliment the
//                              "move ccr,d0" instruction. Hence the 68000 vs.
//                              68010 detection would give the oposite result
//                              to the one desired. Force mc68010 flag to true.
//
//      19 Nov 87       ACH     Moved _lbmove, _bfill, _bmove into this module.
//
//============================================================================

#include "config.h"
#include "../../include/ct60.h"
#include "../../include/fire.h"
#include "../../include/vars.h"

//==== Global References =====================================================

        .global _termuser
        .global _gouser
        .global _oscall

        .global _enter
        .global _old_trap2
        .global _bdos_trap2
        
        .xdef   _osif
        .xdef   _xterm
        .xdef   _run
        .xdef   fstrt

        .global _xsuper
        
        .global _swp68w
        .global _swp68l
        
        .global _rwabs

        .global _slb_exec
        
        .global _flush_cache_pexec


#undef DEBUG

#if defined(NETWORK) && defined(LWIP)
        .global _xSemaphoreTakeBDOS,_xSemaphoreGiveBDOS
#endif

#ifdef COLDFIRE
        .globl _M68k_InstrLen,_disassemble_pc,_conout_debug,_conws_debug,_ltoa
#ifdef DEBUG
        .global display_string,display_char,hex_byte

        .data

debug1: .asciz "BDOS #0x
        .align 2
#endif
#endif /* COLDFIRE */

        .data

//==== bdos_trap2 - trap 2 entry point =======================================
//
// This minimal interface connects the entry point for a system where the AES
// and VDI are already in memory.
//

_bdos_trap2:                              
        tst.w   d0
        beq     oterm

        move.l  _old_trap2,-(sp)
        rts

oterm:  move.l  #fstrt,sp
        clr     -(sp)
        jsr     _xterm
        rte

//==== _enter - Front end of TRAP #1 handler =================================

_enter:
        bsr     fix_trap
        btst.b  #5,(sp)         // are we in supervisor mode?
        bne     enter_sup       // yes, go check sup stack
#ifdef COLDFIRE
        .chip 68060
        move.l  usp,a0          // no, check user stack
#if (__GNUC__ <= 3)
        .chip 5200
#else
        .chip 5485
#endif
        moveq   #0,d0
        move.w  (a0),d0
#ifdef DEBUG
        move.l  D0,-(SP)
        move.l  A0,-(SP)
        lea     debug1,A0
        jsr     display_string
        move.l  (SP)+,A0
        jsr     hex_byte
        moveq   #13,D0
        jsr     display_char
        moveq   #10,D0
        jsr     display_char
        move.l  (SP)+,D0
#endif
        cmp.l   #0x20,d0
#else
        move.l  usp,a0          // no, check user stack
        cmp.w   #0x20,(a0)      // toggle/inquire state?
#endif
        beq     x20_usr         // yes, go perform function

        bra     enter_2

enter_sup:
                                // next line is 68000 specific
#ifdef COLDFIRE
        moveq   #0,d0
        move.w  6(sp),d0        // toggle/inquire state?
#ifdef DEBUG
        move.l  D0,-(SP)
        move.l  A0,-(SP)
        lea     debug1,A0
        jsr     display_string
        move.l  (SP)+,A0
        jsr     hex_byte
        moveq   #13,D0
        jsr     display_char
        moveq   #10,D0
        jsr     display_char
        move.l  (SP)+,D0
#endif
        cmp.l   #0x20,d0
#else        
        cmp.w   #0x20,6(sp)     // toggle/inquire state?
#endif
        beq     x20_sup         // yes, go perform function

enter_2:
        move.l  a6,-(sp)
        move.l  _run,a6
        movem.l d0/a3-a5,0x68(a6)
        move.l  (sp)+,0x78(a6)  // olda6
        move.w  (sp)+,d0        // status reg
        move.l  (sp)+,a4        // retadd
        btst    #13,d0          // if he is in system state, use his stack
        bne     systk
#ifdef COLDFIRE
       .chip 68060
        move.l  usp,a5
#if (__GNUC__ <= 3)
       .chip 5200
#else
       .chip 5485
#endif
        lea     -40(a5),a5
        movem.l d1-d7/a0-a2,(a5)
#else /* 68060 */
        move.l  usp,a5
        movem.l d1-d7/a0-a2,-(a5)
#endif /* COLDFIRE */
        move.l  a4,-(a5)        // retadd
        move.w  d0,-(a5)        // sr
        move.l  sp,a0
        move.l  a0,-(a5)
        move.l  a5,0x7c(a6)
// now switch to fs stack
        move.l  #fstrt,sp
        lea     50(a5),a0
        bra     callos
// he was using his own ssp
systk:
#ifdef COLDFIRE
        lea     -40(sp),sp
        movem.l d1-d7/a0-a2,(sp)
        move.l  a4,-(sp)
        move.w  d0,-(sp)
        .chip   68060
        move.l  usp,a0
#if (__GNUC__ <= 3)
        .chip 5200
#else
        .chip 5485
#endif
#else /* 68060 */
        movem.l d1-d7/a0-a2,-(sp)
        move.l  a4,-(sp)
        move.w  d0,-(sp)
        move.l  usp,a0
#endif /* COLDFIRE */
        move.l  a0,-(sp)
        move.l  sp,0x7c(a6)
        lea     50(sp),a0
        move.l  #fstrt,sp
callos: move.l  a0,-(sp)        // push parm pointer

        jsr     _osif
        add.l   #4,sp

//...fall into gouser....



//==== _gouser ===============================================================

_gouser:
        move.l  _run,a5
        move.l  d0,0x68(a5)
ggusr:  move.l  0x7c(a5),a6     // stack pointer (maybe usp, maybe ssp)
        move.l  (a6)+,a4        // other stack pointer
        move.w  (a6)+,d0
        move.l  (a6)+,a3        // retadd
#ifdef COLDFIRE
        movem.l (a6),d1-d7/a0-a2
        lea     40(a6),a6
#else
        movem.l (a6)+,d1-d7/a0-a2
#endif
        btst    #13,d0
        bne     retsys          // a6 is (user-supplied) system stack
        move.l  a4,sp
#ifdef COLDFIRE
        .chip   68060
        move.l  a6,usp
#if (__GNUC__ <= 3)
        .chip 5200
#else
        .chip 5485
#endif
#else /* 68060 */
        move.l  a6,usp
#endif /* COLDFIRE */
gousr:  move.l  a3,-(sp)
        move    d0,-(sp)
        movem.l 0x68(a5),d0/a3-a6

        bra     fix_rte

retsys: move.l  a6,sp
#ifdef COLDFIRE
        .chip   68060
        move.l  a4,usp
#if (__GNUC__ <= 3)
        .chip 5200
#else
        .chip 5485
#endif
#else /* 68060 */
        move.l  a4,usp
#endif /* COLDFIRE */
        bra     gousr
        
        // attempting to fix a problem where return codes provided by
        // xterm [ 0x4C ] aren't correctly passed back to the parent.
        // this is entered from C code as termuser()
        // aug 2005, RCL
_termuser:
        move.l  _run,a5
        bra     ggusr

//==== function 0x20 handler - toggle/inquire processor/stack state ==========

_xsuper:
x20_usr:                        // user mode entry point
        move.l  2(a0),d1        // get parameter
        beq     xu_0            // already have new SSP from
                                // old USP, go handle 0L entry

        subq.l  #1,d1           // check for +1L entry
        beq     x20_inq         // go handle inquiry

        move.l  2(a0),a0        // get new SSP from parameter
xu_0:
        move.w  (sp)+,d0        // pop SR
        move.l  (sp)+,-(a0)     // transport the return address
        ori.l   #0x2000,d0      // set supervisor mode
        move.w  d0,-(a0)        // push SR
        move.l  sp,d0           // set return value (old SSP)
        move.l  a0,sp           // set new SSP

        bra     fix_rte





// supervisor mode gemdos(20) entry point

x20_sup:
        move.l  8(sp),d1        // get parameter
        beq     xs_0            // go handle 0L entry

        subq.l  #1,d1           // check for +1L entry
        beq     x20_inq         // go handle inquiry

        move.l  8(sp),a1        // point to new SSP
        move.w  (sp)+,d0        // pop SR
        move.l  (sp)+,-(a1)     // transport the return address
        move.w  d0,-(a1)        // push SR
#ifdef COLDFIRE
        .chip   68060
        move.l  usp,a0          // get USP
#if (__GNUC__ <= 3)
        .chip 5200
#else
        .chip 5485
#endif
#else /* 68060 */
        move.l  usp,a0          // get USP
#endif /* COLDFIRE */
        cmpa.l  a0,sp           // already at old USP?
        beq     xs_usp          // don't play with stack

        move.l  (sp)+,-(a0)     // transport func # and parm
        move.l  a1,sp           // update SSP
        bra     xs_exit

xs_usp:
        move.l  a1,sp           // update SSP
        bra     xs_scram

xs_0:
        move.l  sp,a0           // create USP
        addq.l  #6,a0           // this is 68000 specific
xs_exit:
#ifdef COLDFIRE
        .chip   68060
        move.l  a0,usp          // update USP
#if (__GNUC__ <= 3)
        .chip 5200
#else
        .chip 5485
#endif
xs_scram:
        move.l  d0,-(sp)
        move.w  4(sp),d0
        andi.l  #0xDFFF,d0      // set user mode
        move.w  d0,4(sp)
        move.l  (sp)+,d0
#else /* 68060 */
        move.l  a0,usp          // update USP
xs_scram:
        andi.w  #0xDFFF,(sp)    // set user mode
#endif /* COLDFIRE */
        bra     fix_rte

// gemdos(20) inquiry mode entry point

x20_inq:
        moveq.l #0,d0           // return 0L for user mode
        btst.b  #5,(sp)         // supervisor mode?
        beq     xi_exit         // no, user mode
        subq.l  #1,d0           // return -1L for sup mode
xi_exit:
        bra     fix_rte

//==== call dosjr from within itself (or from linked-in shell) ===============

_oscall:
        link    a6,#0
        move.l  a0,-(sp)
        lea     8(a6),a0
        move.l  a0,-(sp)
        jsr     _osif
        addq.l  #4,sp
        move.l  (sp)+,a0
        unlk    a6
        rts

//==== fix_trap - make 68010 exception stack frame look like a 68000 frame ===

fix_trap:
#if defined(NETWORK) && defined(LWIP)
        lea     -24(sp),sp
        movem.l d0-d2/a0-a2,(sp)
        jsr     _xSemaphoreTakeBDOS
        movem.l (sp),d0-d2/a0-a2
        lea     24(sp),sp
#endif
        tst.w   proc_type       // check processor type
        beq     ft_exit

        move.w  8(sp),10(sp)    // lsw of return address of TRAP
        move.w  6(sp),8(sp)     // msw of return address of TRAP
        move.w  4(sp),6(sp)     // sr
        move.w  2(sp),4(sp)     // lsw of return address of BSR
        move.w  (sp),2(sp)      // msw of return address of BSR
        addq.l   #2,sp          // discard the missing word
ft_exit:
        rts


//==== fix_rte - restore a 68010 exception stack frame =======================

fix_rte:
        tst.w   proc_type       // check processor type
        beq     fr_exit

        subq.l  #2,sp           // reserve a hole on top of the stack
        move.w  2(sp),(sp)      // move SR
        move.w  4(sp),2(sp)     // msw of return address of TRAP
        move.w  6(sp),4(sp)     // lsw of return address of TRAP
        clr.w   6(sp)           // store a bogus exception frame type
fr_exit:
#if defined(NETWORK) && defined(LWIP)
        lea     -24(sp),sp
        movem.l d0-d2/a0-a2,(sp)
        jsr     _xSemaphoreGiveBDOS
        movem.l (sp),d0-d2/a0-a2
        lea     24(sp),sp
#endif
        rte

//==== miscasm - swap ========================================================

_swp68w:
        move.l  4(sp),a0
        move.w  (a0),d0
#ifdef COLDFIRE
        move.l  d1,-(sp)
        move.w  d0,d1
        asl.l   #8,d0
        lsr.l   #8,d1
        and.l   #0xff00,d0
        and.l   #0x00ff,d1
        or.l    d1,d0
        move.l  (sp)+,d1
#else
        ror.w   #8,d0
#endif
        move.w  d0,(a0)
        rts
        
_swp68l:
        move.l  4(sp),a0
        move.l  (a0),d0
#ifdef COLDFIRE
        move.l  d1,-(sp)
        move.l  d0,d1
        asl.l   #8,d0
        lsr.l   #8,d1
        and.l   #0xff00ff00,d0
        and.l   #0x00ff00ff,d1
        or.l    d1,d0
        swap    d0
        move.l  (sp)+,d1
#else
        ror.w   #8,d0
        swap    d0
        ror.w   #8,d0
#endif
        move.l  d0,(a0)
        rts
        
_rwabs:

        lea -20(sp),sp
        movem.l d1-d5,(sp)
        movem.l 24(sp),d0-d5
        move.l  d5,-(sp) // lrecno
        move.w  d4,-(sp) // dev
        move.w  d3,-(sp) // recno
        move.w  d2,-(sp) // count
        move.l  d1,-(sp) // buf
        move.w  d0,-(sp) // mode
#if defined(NETWORK) && defined(LWIP)
        move.l  _pxCurrentTCB,d0
        cmp.l   _tid_TOS,d0
        beq.s   use_trap
        move.l  hdv_rw,a0
        jsr     (a0)
        lea     16(sp),sp
        movem.l (sp),d1-d5
        lea     20(sp),sp
        rts 
use_trap:
#endif
        move.w  #4,-(sp) // Rwabs
        trap    #13
        lea     18(sp),sp
        movem.l (sp),d1-d5
        lea     20(sp),sp
        rts     
        
#define SL_HEAD 4
#define SH_NO_FUNCS 68
#define SH_FUNCTIONS 72

// slb_exec
//
// Helper function to call an SLB's function from within an application.
//
// Input:
// 4(sp): Pointer to shared library structure
// 8(sp): Function number (long)
// 12(sp): Number of arguments (short)
// 14(sp): arguments (if any)
//
// Returns:
// d0: EINVFN: Function not implemented (or function number out of range)
//     Otherwise: Return code of function
//

_slb_exec:
	move.l	8(sp),d0
	bmi.s	einvfn
	move.l	4(sp),a0
	move.l	SL_HEAD(a0),a0
	cmp.l	SH_NO_FUNCS(a0),d0
	bcc.s	einvfn
	lsl.l	#2,d0
	move.l	SH_FUNCTIONS(a0,d0.l),d0
	beq.s	einvfn
	move.l	_run,a0
	move.l	a0,4(sp)	// replace the SLB handle with basepage pointer
	move.l	d0,a0
	jmp	(a0)

einvfn:	moveq	#-32,d0
	rts


#define DELAY_CACHE 1000   /* 5 Sec */

#define rw_parameter 0xc60b

_flush_cache_pexec:

#ifdef COLDFIRE
	lea -36(SP),SP
	movem.l D0-D4/A0-A2/A5,(SP)
	move.l 40(SP),A5                                    // PD
	move.l 0xC(A5),D1                                   // p_tlen
	lsr.l #1,D1
	lea 256(A5),A0                                      // text
	lea memset_purec,A1
.loop_search_memset:
		move.l (A0),D0
		cmp.l (A1),D0
		bne.s .next_search_memset
		addq.l #4,A1
		lea 4(A0),A2
		moveq #(12*4)-1,D2
.loop_search_memset_2:
			move.l (A2)+,D0
			cmp.l (A1)+,D0
			bne.s .bad_cmp_memset
		subq.l #1,D2
		bgt.s .loop_search_memset_2
		// patch for incompatible instructions
		lea 0x14(A0),A0                        // move.b D0,-(SP) move.w (SP)+,D2
		move.l #0x1400E18A,(A0)                // => move.b D0,D2 lsl.l #8,D2 
		bra.s .fix_code_purec
.bad_cmp_memset:
		lea memset_purec,A1	
.next_search_memset:
		addq.l #2,A0
	subq.l #1,D1
	bgt.s .loop_search_memset
	lea 256(A5),A0                                      // text
	move.l 8(A0),D0
	cmp.l #0x55534844,D0                                // USHD (HDDRIVER)
	beq.s .fix_code_purec
	move.l 20(A0),D0
	cmp.l #0x20505552,D0                                // ' PUR'
	bne.s .test_header_purec
	move.l 24(A0),D0
	cmp.l #0x452D4320,D0                                // 'E-C '
	beq.s .fix_code_purec
.test_header_purec:
	move.l 16(A0),D0
	cmp.l #0x50757265,D0                                // 'Pure'
	bne .test_cacr
	moveq #0,D0
	move.w 20(A0),D0
	cmp.l #0x2043,D0                                    // ' C'
	bne .test_cacr
.fix_code_purec:
#if defined(NETWORK) && defined(LWIP)
	pea purec_found
	jsr _conws_debug
	addq.l #4,SP
	link A6,#-10
	move.l #16,-(SP)
	pea 256(A5)
	pea -10(A6)
	jsr _ltoa
	jsr _conws_debug
	addq.l #8,SP
	pea to_addr
	jsr _conws_debug
	addq.l #4,SP
	lea 256(A5),A0                                      // text
	move.l 0xC(A5),D1                                   // p_tlen
	add.l A0,D1
	move.l D1,-(SP)
	pea -10(A6)
	jsr _ltoa
	jsr _conws_debug
	lea 12(SP),SP
	unlk A6
	move.l #0x20,-(SP)
	jsr _conout_debug
	addq.l #4,SP
	move.l 44(SP),A0                                    // name
	pea (A0)
	jsr _conws_debug
	pea crlf
	jsr _conws_debug
	addq.l #8,SP
#endif /*  defined(NETWORDK) && defined(LWIP) */
	move.l 0xC(A5),D1                                   // p_tlen
	lsr.l #1,D1                                         // 16 bits words
	moveq #0,D2
	moveq #0,D3                                         // flag subroutine
	moveq #0,D4                                         // flag previous instruction is rts
	lea 256(A5),A0                                      // text
	moveq #0,D0
	move.b (A0),D0
	cmp.l #0x60,D0                                      // bra.s
	bne.s .loop_search_byte_on_stack
	move.b 1(A0),D0
	beq.s .loop_search_byte_on_stack                    // bra.w
	add.l D0,A0
	addq.l #2,A0                                        // jump header + size of bra.s
	moveq #-1,D3                                        // flag subroutine (-1 for start program !!!)
.loop_search_byte_on_stack:
		move.l (A0),D0
		cmp.l #0xA00023C8,D0                   // Line A 0xA000 - Pure C - PCLNALIB.LIB
		bne.s .not_linea_pc
		moveq #0,D0
		move.w -2(A0),D0
		cmp.l #0x2F0A,D0                       // move.l A2,-(SP)
		beq .linea_ok
		bra .linea
.not_linea_pc:
		tst.l D3
		beq.s .test_muldiv64                   // not a subroutine or start program
		cmp.l #0xA00048F9,D0                   // Line A 0xA000/movem.l - NVDI.PRG
		beq .linea_ok
		cmp.l #0xA000907C,D0                   // Line A 0xA000/sub.w - NVDI - OFF*.NOD
		beq .linea_ok
		cmp.l #0xA0004CEF,D0                   // Line A 0xA000/movem.l - PAPYRUS
		beq .linea_ok
.test_muldiv64:
		and.l #0xFF8087F8,D0
 		cmp.l #0x4C000400,D0                   // mulu/s.l <ea>,dh:dl or divu/s.l <ea>,Dr:Dq
		bne .not_muldiv64
		tst.l D3
		ble.s .linea                           // not inside a subroutine => just display
		move.l (A0),D0
		and.l #0xFFB887F8,D0
 		cmp.l #0x4C000400,D0                   // mulu/s.l <ea>,dh:dl or divu/s.l <ea>,Dr:Dq with <ea>=Dx
		bne.s .linea
		move.w (A0),D0
		and.l #7,D0
		cmp.l #2,D0
		bhi.s .linea                           // <ea> > D2
		moveq #7,D0
		and.l (A0),D0
		cmp.l #2,D0
		bhi.s .linea                           // Dr > D2
		move.l (A0),D0
		lsr.l #8,D0
		lsr.l #4,D0
		and.l #7,D0
		cmp.l #2,D0
		bhi.s .linea                           // Dq > D2
		moveq #0,D0
		move.w (A0),D0
		btst #6,D0
		bne.s .div64
		and.l #0x003F,D0                       // <ea>
		or.l #0xABC0,D0                        // mulu/s.l <ea>,dh:dl replaced by 0xABC0-0xABFF
		bra.s .muldiv64
.div64:
		and.l #0x003F,D0                       // <ea>
		or.l #0xAFC0,D0                        // divu/s.l <ea>,Dr:Dq replaced by 0xAFC0-0xAFFF
.muldiv64:
		bsr disassemble_byte_on_stack
		move.w D0,(A0)
		bra .next_instruction                  // continue next instruction
.linea:
		moveq #0,D0
		bsr disassemble_byte_on_stack          // just for display
		bra .next_instruction
.linea_ok:
		move.l #0xA920,D0                      // Line A opcode replaced by 0xA920 
		bra .update_byte_on_stack2
.not_muldiv64:		
		move.w (A0),D2
		cmp.l #0xA000,D2
		bcs.s .not_linea
		cmp.l #0xA010,D2
		bcs.s .linea
.not_linea:
		tst.l D4
		beq .not_push_d3                       // previous instruction <> rts
		cmp.l #0x4A79,D2                       // tst.w addr.l (NVDI mulu/s.l <ea>,dh:dl or divu/s.l <ea>,Dr:Dq subroutines)
		beq.s .ok_subroutine
		cmp.l #0x6100,D2                       // bsr
		beq.s .ok_subroutine
		cmp.l #0x4EB9,D2                       // jsr
		beq.s .ok_subroutine
		cmp.l #0x2F03,D2                       // move.l D3,-(SP)
		beq.s .ok_subroutine
		cmp.l #0xB03C,D2                       // cmp.b #xxx,D0 (HDDRIVER)
		beq.s .ok_subroutine
		cmp.l #0x2C48,D2
		beq.s .ok_subroutine                   // move.l A0,A6 (HDDRIVER)
		move.l D2,D0
		and.l #0xFF00,D0
		cmp.l #0x7000,D0                       // moveq #xxx,D0
		beq.s .ok_subroutine
		move.l (A0),D0
		cmp.l #0x50F8043E,D0                   // st.b 0x43E (HDDRIVER)
		beq.s .ok_subroutine
		and.l #0xF100FF00,D0
		cmp.l #0x70006000,D0                   // moveq #xxx,DX bra.s (HDDRIVER)
		beq.s .ok_subroutine
.not_push_d3:
		cmp.l #0x48E7,D2                       // movem.l xxx,-(SP)
		bne.s .not_movem_push
.ok_subroutine:
		moveq #1,D3                            // OK for test if subroutine detected
		bra .next_instruction
.not_movem_push:
		cmp.l #0x4E75,D2                       // rts
		bne.s .not_movem_pop
		moveq #2,D4                            // flag rts
		moveq #0,D3                            // end subroutine
		bra .next_instruction
.not_movem_pop:
		move.l D2,D0
		and.l #0xFFF8,D0
		cmp.l #0x1F00,D0                       // move.b DX,-(SP)
		bne.s .not_moveb_sp
		tst.l D3
		bgt.s .begin_subroutine                // already inside subroutine
		tst.l D4 
		beq.s .begin_subroutine                // previous instruction <> rts  
		moveq #1,D3                            // subroutine without movem and 1st instruction is move.b DX,-(SP) ?!?
.begin_subroutine:
		moveq #7,D0
		and.l D2,D0
		or.l #0xA910,D0                        // replaced by 0xA910-0xA917
		bra .update_byte_on_stack
.not_moveb_sp:
		cmp.l #0x1F10,D0                       // move.l (AX),-(SP)
		bne.s .not_moveb_ax_sp
		moveq #7,D0
		and.l D2,D0
		or.l #0xA930,D0                        // replaced by 0xA930-0xA937
		bra .update_byte_on_stack
.not_moveb_ax_sp:
		cmp.l #0x1F28,D0                       // move.l d(AX),-(SP)
		bne.s .not_moveb_dax_sp
		moveq #7,D0
		and.l D2,D0
		or.l #0xA9B0,D0                        // replaced by 0xA9B0-0xA9B7
		bra .update_byte_on_stack_dax
.not_moveb_dax_sp:
		cmp.l #0x1F39,D2                       // move.b abs.l,-(SP)
		bne.s .not_moveb_absl_sp
		move.l #0xA9F1,D0                      // replaced by 0xA9F1
		bra.s .update_byte_on_stack_dax
.not_moveb_absl_sp:
		cmp.l #0x1F3A,D2                       // move.b d(PC),-(SP)
		bne.s .not_moveb_dpc_sp
		move.l #0xA9F2,D0                      // replaced by 0xA9F2
		bra.s .update_byte_on_stack_dax
.not_moveb_dpc_sp:
		move.l D2,D0
		and.l #0xF1FF,D0
		cmp.l #0x101F,D0                       // move.b (SP)+,DX
		bne.s .not_moveb_spp
		move.l D2,D0
		lsr.l #8,D0
		lsr.l #1,D0
		and.l #0x0007,D0
		or.l #0xA918,D0                        // replaced by 0xA918-0xA91F
		bra.s .update_byte_on_stack
.not_moveb_spp:
		cmp.l #0x109F,D0                       // move.b (SP)+,(AX)
		bne.s .not_moveb_spp_ax
		move.l D2,D0
		lsr.l #8,D0
		lsr.l #1,D0
		and.l #0x0007,D0
		or.l #0xA938,D0	             // replaced by 0xA938-0xA93F
		bra.s .update_byte_on_stack
.not_moveb_spp_ax:
		cmp.l #0x115F,D0                       // move.b (SP)+,d(AX)
		bne.s .not_moveb_spp_dax
		move.l D2,D0
		lsr.l #8,D0
		lsr.l #1,D0
		and.l #0x0007,D0
		or.l #0xA9B8,D0	             // replaced by 0xA9B8-0xA9BF
		bra.s .update_byte_on_stack_dax
.not_moveb_spp_dax:
		cmp.l #0x13DF,D2                       // move.b (SP)+,abs.l
		bne.s .next_instruction
		move.l #0xA9F9,D0                      // replaced by 0xA9F9
.update_byte_on_stack_dax:
		tst.l D3
		bgt.s .update_byte_on_stack2_dax       // inside a subroutine
		moveq #0,D0                            // change code not allowed => just display
.update_byte_on_stack2_dax:
		bsr disassemble_byte_on_stack
		tst.l D0
		beq.s .next_instruction                // no change, continue with next word
		move.w D0,(A0)
		addq.l #4,A0
		subq.l #2,D1
 		bra.s .next_search_byte_on_stack
.update_byte_on_stack:
		tst.l D3
		bgt.s .update_byte_on_stack2           // inside a subroutine
		moveq #0,D0                            // change code not allowed => just display
.update_byte_on_stack2:
		bsr disassemble_byte_on_stack
		tst.l D0
		beq.s .continue_next_word              // no change, continue with next word
		move.w D0,(A0)
.continue_next_word:
		addq.l #2,A0
		subq.l #1,D1
 		bra.s .next_search_byte_on_stack
.next_instruction:
		move.l D1,-(SP)
		move.l A0,-(SP)
		jsr _M68k_InstrLen
		move.l (SP)+,A0
		move.l (SP)+,D1
		add.l D0,A0
		add.l D0,A0                            // next address
		sub.l D0,D1                            // next word counter
.next_search_byte_on_stack:
		lsr.l #1,D4                            // flag rts
	tst.l D1                                            // word counter
	bgt .loop_search_byte_on_stack
.test_cacr:
	.chip 68060
	movec.l CACR,D0
#if (__GNUC__ <= 3)
	.chip 5200
#else
	.chip 5485
#endif
	cmp.l #CACHE_ENABLE_MODE,D0
#else /* 68060 */
	movem.l D0-D2/A0-A2/A5,-(SP)
	move.l _run,A5
	movec.l CACR,D0
	cmp.l #0xA0808000,D0
#endif /* COLDFIRE */
	bne.s .normal
	clr.l -(SP)
	move.l #CT60_CACHE_DELAY,-(SP)
	move.w #CT60_MODE_READ,-(SP)
	move.w #rw_parameter,-(SP)
	trap #14
	lea 12(SP),SP
	cmp.l #-1,D0
	beq.s .normal
	btst #0,D0
	beq.s .normal
	jsr 0xE0085A                                        // caches off
	move.l phystop,A0
	clr.l save_hz_200(A0)
	move.l #0x12345678,D0
	move.l D0,flag_cache(A0)                            // flag delay	
	bra .end_pexec
.normal:
	lea 256(A5),A0                                      // begin of the program
#ifdef COLDFIRE
	moveq #0,D0
	move.w (A0)+,D0
	cmp.l #0x6008,D0                                    // fix problems with Ice Packer
	bne .no_ice
	move.l (A0)+,D0
	cmp.l #0x5061636B,D0                                // Pack
	bne.s .no_ice
	move.l (A0)+,D0
	cmp.l #0x2D496365,D0                                // _Ice
	bne.s .no_ice
	moveq #0,D0
	move.w 0x86(A0),D0
	cmp.l #0x4ED2,D0                                    // jmp (A2)
	bne.s .no_ice
	move.w 0xA4(A0),D0
	cmp.l #0x4ED6,D0                                    // jmp (A6)
	bne.s .no_ice
	move.w #0x4AFC,D0                                   // illegal
	move.w D0,0x86(A0)
	move.w D0,0xA4(A0)                                  // illegal
	lea.l .new_illegal(PC),A0
	move.l 0x10,D0
	move.l D0,0x380                                     // save illegal vector
#else /* 68060 */
	cmp.w #0x6008,(A0)+                                 // fix problems with Ice Packer
	bne.s .no_ice
	cmp.l #0x5061636B,(A0)+                             // Pack
	bne.s .no_ice
	cmp.l #0x2D496365,(A0)+                             // _Ice
	bne.s .no_ice
	cmp.w #0x4ED2,0x86(A0)                              // jmp (A2)
	bne.s .no_ice
	cmp.w #0x4ED6,0xA4(A0)                              // jmp (A6)
	bne.s .no_ice
	move.w #0x4AFC,0x86(A0)                             // illegal
	move.w #0x4AFC,0xA4(A0)                             // illegal
	lea.l .new_illegal(PC),A0
	move.l 0x10,0x380 
#endif /* COLDFIRE */
	clr.l 0x384                                         // illegal counter
	move.l A0,0x10
	bra.s .no_ice
.new_illegal:
#ifdef COLDFIRE
	.chip 68060
	cpusha BC                                           // flush
#if (__GNUC__ <= 3)
	.chip 5200
#else
	.chip 5485
#endif
	addq.l #1,0x384                                     // illegal counter
	move.l 0x384,D0
	cmp.l #2,D0
	bcs.s .jmp_a2
	move.l 0x380,D0
	move.l D0,0x10                                      // restore illegal vector
#else /* 68060 */
	cpusha BC                                           // flush
	addq.l #1,0x384                                     // illegal counter
	cmp.l #2,0x384
	bcs.s .jmp_a2
	move.l 0x380,0x10                                   // restore illegal vector
#endif /* COLDFIRE */
	addq.l #8,SP
	moveq #0,D0
	move D0,SR
	jmp (A6)
.jmp_a2:
	addq.l #8,SP
	moveq #0,D0
	move D0,SR
	jmp (A2)
.no_ice:	
#ifdef COLDFIRE
	.chip 68060
	cpusha BC                                           // flush
#if (__GNUC__ <= 3)
	.chip 5200
#else
	.chip 5485
#endif
.end_pexec:
	movem.l (SP),D0-D4/A0-A2/A5
	lea 36(SP),SP
#else /* 68060 */
	cpusha BC                                           // flush
.end_pexec:
	movem.l (SP)+,D0-D2/A0-A2/A5
#endif /* COLDFIRE */
	rts
	
#ifdef COLDFIRE

disassemble_byte_on_stack: // A0: address, D0: new instruction (0xA9XX - not used by CF: 0xA910-0xA91F 0xA938-0xA93F)

#if defined(NETWORK) && defined(LWIP)
	link A6,#-10
	lea -24(SP),SP
	movem.l D0-D2/A0-A2,(SP)
	move.l D0,-(SP)
	move.l A0,-(SP)
	lea purec_fix,A0
	tst.l D0
	bne.s .fix_ok
	lea purec_found,A0
.fix_ok:
	pea (A0)
	jsr _conws_debug
	addq.l #4,SP
	jsr _disassemble_pc                                 // address on stack
	move.l D0,-(SP)
	jsr _conws_debug
	addq.l #8,SP
	tst.l (SP)                                          // new instruction
	beq.s .crlf
	pea changed
	jsr _conws_debug
	addq.l #4,SP
	move.l (SP),D0                                      // new instruction
	move.l #16,-(SP)
	move.l D0,-(SP)
	pea -10(A6)
	jsr _ltoa
	jsr _conws_debug
	lea 12(SP),SP
.crlf:
	pea crlf
	jsr _conws_debug
	addq.l #8,SP
	movem.l (SP),D0-D2/A0-A2
	lea 24(SP),SP
	unlk A6
#endif /*  defined(NETWORDK) && defined(LWIP) */
	rts

	.data
	.even

memset_purec:
	dc.l 0x2F08D1C1,0x24080802,0x00006708,0x53816500
	dc.l 0x00AC1100,0x1F00341F,0x14003002,0x48423400
	dc.l 0x2001E088,0xE4886778,0x48E75F3E,0x22022602
	dc.l 0x28022A02,0x2C022E02,0x22422442,0x26422842
	dc.l 0x2A422C42,0x48E07F7E,0x48E07F7E,0x48E07F7E
	dc.l 0x48E07F7E,0x48E07F7E,0x48E07F7E,0x48E07F7E
	dc.l 0x48E07F7E,0x48E07F7E,0x48E07F7E,0x48E07F7E
	dc.l 0x48E07F7E,0x48E07F7E,0x48E07F7E,0x48E07F7E
	dc.l 0x48E07F7E,0x48E07F7E,0x48E07F7E,0x48E07F7E
	dc.l 0x48E07F60,0x538066AC,0x4CDF7CFA,0xC27C03FF
	dc.l 0x3001E448,0x67085340,0x210251C8,0xFFFCC27C
	dc.l 0x00036708,0x53411102,0x51C9FFFC,0x205F4E75

crlf:	dc.b 13,10,0,0
purec_fix:	.asciz "Pure C  fix at 0x"
purec_found:	.asciz "Pure C info at 0x"
to_addr:	.asciz " to 0x"
changed:	.asciz " -> 0x"

#endif /* COLDFIRE */

	.bss
	.even

_old_trap2:
	.ds.l   1                       // old TRAP #2 handler

	.ds.w   4096 // was 1000
fstrt:
	.ds.l   1

	.end

