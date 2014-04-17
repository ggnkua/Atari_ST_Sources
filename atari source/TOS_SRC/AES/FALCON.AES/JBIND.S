*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/jbind.s,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:28:16 $	$Locker: kbad $
* =======================================================================
*  $Log:	jbind.s,v $
* Revision 2.2  89/04/26  18:28:16  mui
* TT
* 
* Revision 2.1  89/02/22  05:30:27  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.2  88/11/01  11:25:49  mui
* Fix the err_trap to save the PD's stack pointer
* 
* Revision 1.1  88/06/02  12:35:36  lozben
* Initial revision
* 
*************************************************************************

*	JBIND.S		 11/27/84 - 05/03/85  LKW
*			 04/02/85 - 05/23/85  DMM
*	Fix at the dos_exec for dos_ax return code 08/21/85 Derek Mui
*	Clean up 	 02/03/88		D.Mui
*	Change at gosuper, super now inlined	4/11/88
*	Use MAC to assemble	6/28/90		D.Mui
*	Add _crt_error semaphore to dispatcher	900731 D.Mui
* assemble with MAS 900801 kbad (changed 2 clr.w a0 to sub.w a0,a0)
*	Change in critical error to ignore error -15 3/1/91 D.Mui
*	Install a desktop critical error handler	4/22/91	D.Mui

* --Crystal function numbers.
*
CRYSTAL1 =	200			; Call Crystal function.
CRYSTAL2 =	201			; Call dispatch.
TRP2VEC	 =	$88
*
* --DOS.C error flag conventions.
*
ERROR	=	1
NOERR	=	0
*
*
	.text
*
* --Externally defined.
*
*	.globl	_super
	.globl	_sti
	.globl	_cli
	.globl	_rlr
*	.globl	_dr_code	; desktop
	.globl	_DOS_ERR
	.globl	_DOS_AX		; changed
	.globl	_eralert	; fmalt
*
* --Internally defined.
*
*	.globl	_drawaddr
*	.globl	_supret
*	.globl	_far_draw
	.globl	_takecpm
	.globl	_givecpm
	.globl	_retake
	.globl	_back
	.globl	_dos_exec
	.globl	_savsup
	.globl	_takeerr
	.globl	_giveerr
	.globl	_crit_err
	.globl  _err_trap
	.globl	_drawstk	; deskglob
	.globl	errsave
	.globl	_crt_error	; used by gemdisp.c:disp
	.globl	_deskerr
	.globl	_desknoerr
*
*
	.globl	lmul
	.globl	ldiv
	.globl	_ldivr

*
*
_givecpm:
	move.l	_SAV2TRP,TRP2VEC	; Restore Trap 2 vector.
	rts

*
* --Grab trap 2 so we can do our own system reset if the program wants to.
*
_takecpm:
	move.l	TRP2VEC,_SAV2TRP	; Save current Trap 2 vector.
	move.l	#_grptrp,TRP2VEC	; Replace vector with ours.
	rts
*
*	retake gem trap and error trap after execing a program
*
_retake:
	move.l	#_grptrp,TRP2VEC	; Replace vector with ours.
	move.l	#_err_trap,d0		; set ours

*	bra	call_err		; FALL TRHU
*
*
*
call_err:
	move.l	d0,-(a7)
	move.w	#$101,-(a7)
	move.w	#5,-(a7)
	trap	#13
	addq	#8,a7
	rts

_giveerr:
	move.l	_crit_err,d0
	bra	call_err

*
_takeerr:
	move.l	#-1,d0			; get the old one
	bsr	call_err
	move.l	d0, _crit_err
	move.l	#_err_trap,d0		; set ours
	bra	call_err
	
_deskerr:
	move.l	#-1,d0			; get the old one
	bsr	call_err
	move.l	d0, _dk_err
	move.l	#_dk_trap,d0		; set ours
	bra	call_err

_desknoerr:
	move.l	_dk_err,d0
	bra	call_err

_dk_trap:
	cmp.w	#-17,d0			; if swap disk, it's OK
	bne	d_out
	jmp	_err_trap		; don't return to here
d_out:	
	rts
	

*
*
*	ASSUME CALLING PROCESS HAS ENOUGH STACK
*
_err_trap:
	move.w	#1,_crt_error		; set flag for dispatcher
	move.l	_rlr,a0			; get the current rlr
	move.l	8(a0),a0		; get the UDA
	move.l	62(a0),savestk		; save the stack
	
	move.w	4(a7),d0		; error
	cmp.w	#-15,d0
	beq	er_1			; ignore

	move.w	6(a7),d1		; drive
	jsr	_cli
	move.l	a7,errsave		; save stack
	move.l	#errstk,a7		; switch stack
	jsr	_sti
	movem.l	d3-d7/a3-a6,-(a7)
	move.l	#_err_tbl,a1
	move.w	d0,-(a7)		; save error
	bne 	err1			; not 0
	sub.w	a0,a0
	bra 	eok
err1:
	not.w	d0			; one's comp
	move.w	d0,a0
	cmp.w	#17,d0
	ble	eok
	sub.w	a0,a0
eok:
	move.b	0(a0,a1.l),d0
	move.w	d1,-(a7)		; drive,0 rel
	move.w	d0,-(a7)		; alert number
	jsr	_eralert
	addq.l	#4,a7
	move.w	(a7)+,d1		; get back error num
	ext.l	d1
	tst.w	d0
	beq	eabrt			; abort
	move.l	#$10000,d1		; retry
eabrt:
	move.l	d1,d0			; error num or code
	movem.l (a7)+,d3-d7/a3-a6
	move.l	errsave,a7
er_1:
	move.l	_rlr,a0			; get the current rlr
	move.l	8(a0),a0		; get the UDA
	move.l	savestk,62(a0)		; restore the stack
	clr.w	_crt_error		; so dispatcher knows we're done
	rts				; off we go
	

*
*
*	EXEC a program
*	dos_exec(pspec, segenv, pcmdln)
*		LONG	pspec;
*		WORD	segenv;
*		LONG	pcmdln;
*
*	set DOS_ERR 
*
_dos_exec:
	jsr	_cli
	move.l	_rlr,a0
	move.l	8(a0),a0		; get uda (pd->uda)
	move.l	62(a0),_savsup		; save uda->supstk
	move.l	a7,a1			; get current a7
	sub.l	#128,a1			; give up some space
	move.l	a1,62(a0)		; make uda->supstk below GEM's ssp
	jsr	_sti
*
	move.l	a7,a1
	clr.l	-(a7)			;  NULLPTR
	move.l	10(a1),-(a7)		;  pcmdln
	move.l	4(a1),-(a7)		;  pspec
	move.w	8(a1),-(a7)		;  segenv	(3)
	move.w	#$4B,-(a7)		;  command
	trap	#1
	add.l	#16,a7
*
	jsr	_cli
	move.l	_rlr,a0
	move.l	8(a0),a0
	move.l	_savsup,62(a0)		; restore uda->supstk
	jsr	_sti
	clr.w	_DOS_ERR
	tst.w	d0
	beq	exok
	move.w	#1, _DOS_ERR		; set error condition
	move.w	d0, _DOS_AX		; error code changed
exok:
	rts

*
*
* ========================================================
* ==							
* ==    long multiply routine without floating point	==
* ==  call with:					==
* ==		two long values on stack		==
* ==  returns:						==
* ==		long value in d0 			==
* ==							==
* == warning:  no overflow checking or indication!!!!	==
* ==							
* ========================================================
*
*
lmul:
	link	a6,#-4
	clr.w	d2
	tst.l	8(a6)		;is first arg negative?
	bge	L2
	neg.l	8(a6)		;yes, negate it
	addq.w	#1,d2		;increment sign flag
L2:
	tst.l	12(a6)		;is second arg negative?
	bge	L3
	neg.l	12(a6)		;yes, make it positive
	addq.w	#1,d2		;increment sign flag
L3:
	move.w	10(a6),d0	;arg1.loword
	mulu.w	14(a6),d0	;arg2.loword
	move.l	d0,-4(a6)	;save in temp
	move.w	8(a6),d0	;arg1.hiword
	mulu.w	14(a6),d0	;arg2.loword
	move.w	12(a6),d1	;arg2.hiword
	mulu.w	10(a6),d1	;arg1.loword
	add.w	d1,d0		;form the sum of 2 lo-hi products
	add.w	-4(a6),d0	;add to temp hiword
	move.w	d0,-4(a6)	;store back in temp hiword
	move.l	-4(a6),d0	;long results
	btst	#0,d2		;test sign flag
	beq	L4
	neg.l	d0		;complement the results
L4:
	unlk	a6
	rts
*
*
* ========================================================
* ==							==
* ==			Long Divide			==
* ==							==
* ========================================================
*
ldiv:
	link	a6,#-2
	movem.l	d2-d7,-(sp)
	clr.w	d3
	clr.l	d5
	move.l	8(a6),d7
	move.l	12(a6),d6
	bne	La2
	move.l	#$80000000,_ldivr
	move.l	#$80000000,d0
	divs.w	#0,d0			; div by zero trap
	bra	La1
La2:
	bge	La3
	neg.l	d6
	addq.l	#1,d3
La3:
	tst.l	d7
	bge	La4
	neg.l	d7
	addq.l	#1,d3
La4:
	cmp.l	d7,d6
	bgt	La6
	bne	La7
	moveq.l	#1,d5
	clr.l	d7
	bra	La6
La7:
	cmp.l	#$10000,d7
	bge	La9
	divu.w	d6,d7
	move.w	d7,d5
	swap.w	d7
	ext.l	d7
	bra	La6
La9:
	moveq.l	#1,d4
La12:
	cmp.l	d6,d7
	bcs	La11
	asl.l	#1,d6
	asl.l	#1,d4
	bra	La12
La11:
	tst.l	d4
	beq	La6
	cmp.l	d6,d7
	bcs	La15
	or.l	d4,d5
	sub.l	d6,d7
La15:
	lsr.l	#1,d4
	lsr.l	#1,d6
	bra	La11
La6:
	cmp	#1,d3
	bne	La16
	neg.l	d7
	move.l	d7,_ldivr
	move.l	d5,d0
	neg.l	d0
	bra	La1
La16:
	move.l	d7,_ldivr
	move.l	d5,d0
La1:
	tst.l	(sp)+
	movem.l	(sp)+,d3-d7
	unlk	a6
	rts

*
*
*\////////////////////////////////////////
*       Trap 2 interrupt handler
*\////////////////////////////////////////
*
* This handler is looking for the BDOS system reset function
* so that a system reset is not done, rather a return to the 
* calling program can be done.
*
_grptrp:
	tst.w	d0			; Is function number system reset ?
	beq	_back
*
	cmpi.w	#CRYSTAL1,d0		; Trying to get to Crystal?
	beq	_gosuper
	cmpi.w	#CRYSTAL2,d0		; Trying to just do a dispatch?
	beq	_gosuper
*
* Not a system reset or Crystal call, so go to orginal interrupt.
*
	move.l	_SAV2TRP,-(sp)
	rts
*
*
**********************************************
* Return here when loaded program is finished.
**********************************************
*
_back:	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
*
*
*\/////////////////////////////////////////////
*		Call Crystal
*\/////////////////////////////////////////////
*
_gosuper:
*
	jsr	_cli			; interrupts off
*
	move.l	usp,a0
	movem.l	d1-d7/a0-a6,-(a0)	; save regs of caller on users stack
	move.l	a0,usp
	movea.l	_rlr,a6			; rlr is a pointer to pd structure.
	movea.l	8(a6),a6		; get address of uda structure.
*
* 					Set parameters in uda structure
*
	move.w	#1,(a6)			; u_insuper flag.
	move.l	a0,66(a6)		; save current user stack pointer.
	move.l	a7,70(a6)		; save current super stack ptr
	movea.l	62(a6),a7		; get super stack from uda
*
	jsr	_sti			; interrupts on
*
* --Set up to call super() in xif.c
*
*	move.l	d1,-(a7)		; Address of Crystal parameter block.
*	clr.w	-(a7)			; Unused parameter.
*	move.w	d0,-(a7)		; Crystal function number.
*
* --Go to super().
*
*	move.l	#_super,a0
*	jsr	(a0)			; super expects jsr
*
*	Supervisor entry point.  Stack frame must be exactly like
*	this if supret is to work.
*
*	VOID
*      d0,          d1 	
*super(cx, ifunc, pcrys_blk)
*	WORD		cx, ifunc;
*	LONG		pcrys_blk;
*{
*	if( cx == 200 )
*	  xif(pcrys_blk);
*
*	  dsptch();
*
*	supret(0);
*}

	cmp.w	#200,d0
	bne	super1
	move.l	d1,-(sp)
	jsr	_xif
	addq.l	#4,sp
super1:
	jsr	_dsptch
	clr.w	d0	
*
*
*\/////////////////////////////////////////////
*	Return from Crystal call 
*\/////////////////////////////////////////////
*
*_supret:
*	move.w	4(a7),d0		; Get return passed from super().
*
	jsr	_cli
*	add.l	#$18,a7			; restore stack
	movea.l	_rlr,a0
	movea.l	8(a0),a0		; Get address of UDA.
	clr.w	(a0)			; clear u_insuper flag.
	move.l	a7,62(a0)		; reset supers stack
	movea.l	70(a0),a7		; restore caller's super stack.
	move.l	66(a0),a0		; restore caller's user stack.
	movem.l (a0)+,d1-d7/a0-a6	; restore user's regs
	move.l	a0,usp
*
	jsr	_sti
	rte


*
* ==========================================
*
*	Call dr_code with its own stack
*
* ==========================================
*
*_far_draw:
*	move.l	4(a7),d0		; get addr of pb
*	move.l	a7,drawsp
*	movea.l	_drawstk,a7		; allocated by deskglob
*	move.l	d0,-(a7)		; pass addr of pb to dr_code
*	jsr	_dr_code
*	movea.l	drawsp,a7
*	rts

*
*
*
	.data
	.even
_err_tbl:	.dc.b	4,1,1,2,1,1,2,2,4,2,2,2,0,3,4,2,6

	.bss
	.even

_crit_err:	.ds.l	1
_dk_err:	.ds.l	1
savestk:	.ds.l	1

*
* Save current trap 2 vector.
*
_SAV2TRP:	.ds.l	1
*
_savsup:	.ds.l	1
*
*_drawaddr:	.ds.l	1		; initialized to _far_draw
drawsp:		.ds.l	1
*
_ldivr:		.ds.l	1
*
errsave:	.ds.l	1

		.ds.l	400		; lots of space for errors
errstk:		.ds.l	1
	.end
