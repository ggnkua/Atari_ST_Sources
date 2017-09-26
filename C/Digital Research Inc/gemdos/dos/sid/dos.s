*****************************************************************
*								*
*  Usual filename:  DOS.S					*
*  Originally Written by W. B. Tyler, 1982.			*
*  Adapted by:  Timothy M. Benson				*
*  Control:  5 May 83  15:25  (TMB)				*
*  Modified 18 March 1984 for extended exception handling WBT.	*
*  This version works with the 68000, not the 68010.		*
*	Revision History:					*
*	85-03-19 RDM - Converted for GEMDOS			*
*                                                               *
*****************************************************************

	.globl	_SIDSTRT
	.globl	_GO
	.globl	_STEP
	.globl	_BDOS		* Supplied only as a dummy for stdio
	.globl	_puthexl
	.globl	_trap
	.globl	_main

        .text
*****************************************************************
*								*
*	SID Startup Code: Initiates program execution		*
*								*
*****************************************************************

_SIDSTRT:				* Provided for display purposes
	move.l	#usrstk,a5		* Set up the USP to our own large area
	move.l	4(SP),-(a5)		* Push the base page address on to stk
	move.l	a5,SP			* Start using our own stack.

*	Exception processing setup:
	Move.W	#$FF,usrcodf		* Signal in SID's own code
	Move.L	#0,-(SP)		* Supervisor trap param = 0
	Move.W	#$20,-(SP)		* Get Supervisor mode function
	Trap	#1
	Addq.L	#6,SP			* Clean up trap parameters.
	Move.L	D0,-(SP)		* Save the original SSP - pass to _main
	Move.W	#2,A0			* First vector
	Move.L	#IBRVEC,A1		* New vector addresses
	Move.L	#OLDVEC,A2		* Storage for old vectors
EXINI1:	Movem.L	A0-A2,-(SP)		* Save the addr registers across traps
	Move.L	A1,-(SP)		* Place to come to on interrupt
	Move.W	A0,-(SP)		* 1st vector is #2, last is 11, $102
	Move.W	#5,-(SP)		* BIOS function
	Trap	#13			* BIOS function 5 to set exc.vec.
	Addq.L	#8,SP			* Discard trap params from the stack
	Movem.L	(SP)+,A0-A2		* Restore the working registers
	Move.L	D0,(A2)+		* Save the Old vector address
	Add.W	#1,A0			* Increase vector num. to change
	Add.L	#6,A1			* And set new exception handler
	Cmp.W	#10,A0			* Have we gotten to line A handler
        Beq	SKIP0			* If so, skip it
        Bra	CONT0			* If not, continue
SKIP0:	Add.W	#1,A0			* Skip change to line A
	Add.L	#6,A1			* And exception handler
CONT0:	Cmp.W	#11,A0			* Done yet?
	Blt	EXINI1			* Nope, do it again
	Bgt	EXFIN			* All finished, even with control-C
	Move.W	#$102,A0		* Set Control-C Handling
	Move.L	#SIDCCEX,A1		* Address of exit routine
	Jmp	EXINI1
EXFIN:	Move.L	#supstk,-(SP)		* Supervisor trap param = new SSP
	Move.W	#$20,-(SP)		* Return to User mode function
	Trap	#1
	Addq.L	#6,SP			* Clean up trap parameters.

*	Now enter the C main routine:
	jsr	_main			* main(OrigSSP, BPPtr)
*					* long OrigSSP;
*					* struct basepage * BPPtr;

*	????? Will we ever return ?????
*	Move.L	(SP)+,D0		* Recover original SSP
*	Addq.L	#4,SP			* discard BPPtr
*	jmp	SIDEXIT
*	When all done, here is how we exit via Control-C:
SIDCCEX:
	Move.W	(SP)+,status
	Move.L	(SP)+,pctr
	AndI	#$5FFF,SR		* return to User mode for SIDEXIT Supv
* SIDEXIT:
	Move.L	#0,-(SP)		* Supervisor trap param = 0
	Move.W	#$20,-(SP)		* Get Supervisor mode function
	Trap	#1
	Addq.L	#6,SP			* Clean up trap parameters.
	Move.W	#2,A0			* First vector
	Move.L	#OLDVEC,A2		* Storage for old vectors
EXEX1:	Move.L	(A2)+,A1		* Pick up next OLDVEC storage
	Movem.L	A0-A2,-(SP)		* Save the addr registers across traps
	Move.L	A1,-(SP)		* Place to come to on interrupt
	Move.W	A0,-(SP)		* 1st vector is #2, last is 11, $102
	Move.W	#5,-(SP)		* BIOS function
	Trap	#13			* BIOS function 5 to set exc.vec.
	Addq.L	#8,SP			* Discard trap params from the stack
	Movem.L	(SP)+,A0-A2		* Restore the working registers
	Add.W	#1,A0			* Increase vector num. to change
	Cmp.W	#10,A0			* Have we gotten to line A handler
        Beq	SKIP1			* If so, skip it
        Bra	CONT1			* If not, continue
SKIP1:	Add.W	#1,A0			* Skip change to line A
CONT1:	Cmp.W	#11,A0			* Done yet?
	Blt	EXEX1			* Nope, more vectors so do it again
	Bgt	EXEXF			* All finished, even with control-C
	Move.W	#$102,A0		* Reset Control-C Handling
	Jmp	EXEX1
EXEXF:
	Move.L	#supstk,-(SP)		* Supervisor trap param = orig. SSP
	Move.W	#$20,-(SP)		* Return to User mode function
	Trap	#1
	Addq.L	#6,SP			* Clean up trap parameters.
	Move.L	#BYEMES,-(SP)		* Say goodbye.
	Move.W	#9,-(SP)
	Trap	#1
	Move.W	#0,-(SP)		* Execute terminate function
	trap	#1
	Jmp	EXEXF			* This should never happen!

*****************************************************************
*
*	Trap function for C programs:
*
*****************************************************************

_trap:	move.l	(SP)+,retsav
	trap	#1
	move.l	retsav,-(SP)
_BDOS:	* Dummy up the stdio reference
	rts

*****************************************************************
*
*	SID GO command (and TRACE) handling:
*
*****************************************************************

_GO:	* Enter with CPUState pointer parameter under return address
	clr.l	errflag
	movem.l	d0-d7/a0-a5,regsave	save register variables
	movem.l a6/a7,asave
	move.l	#0,-(SP)		Supv trap param=0
	move.w	#$20,-(SP)		get supervisor mode
	trap	#1			Params cleaned up by a7 restore.
	move.l	d0,SP			Restore SSP after trap
	move.l	d0,realssp		Save SSP to restore later
	move.l	asave+4,a0		callers stack ptr
	move.l	4(a0), a0		address of cpu state save area
	move.l  (a0),pctr               pc to start at for USER STATE
	move.w  12(a0),status           starting status
	move.l	4(a0),a1		set up stack pointers
	move	a1,USP			user stack pointer
	move.l	8(a0),SP		supervisor stack pointer
        movem.l 14(a0),d0-d7/a0-a6      set up other registers
        move.l  pctr,-(SP)              set up for rte
	and.w	#$7FFF,status		Turn off tracing
        move.w  status,-(SP)		Users stack set as if return fro excep
	clr.w	usrcodf			Signal now in users code for exceptions
        rte                             begin executing by returning into user code

*****************************************************************
*								*
*	execute one user instruction (trace or notrace)		*
*								*
*****************************************************************

_STEP:	clr.l	errflag
	movem.l	d0-d7/a0-a5,regsave	save registers
	movem.l	a6/a7,asave		save registers
	move.l	#0,-(SP)
	move.w	#$20,-(SP)		get supervisor mode
	trap	#1
	move.l	d0,SP
	move.l	SP,realssp
	move.l	asave+4,a0	caller's stack ptr
	move.l	4(a0),a0	address of cpu state save area
	move.l	(a0),pctr	starting pc
	move.w	12(a0),d0	status
	ori.w	#$8000,d0	set trace bit
	move.w	d0,status	starting status
	move.l	4(a0),a1	user stack pointer
	move.l	a1,USP
	move.l	8(a0),SP	system stack pointer
	movem.l	14(a0),d0-d7/a0-a6	registers
	move.l	pctr,-(SP)	set up for rte
	move.w	status,-(SP)	Users stack as if return from exception
	clr.w	usrcodf		Signal now in user's code for exceptions
	rte

***********************************************************************

*	trap handling for _GO and _STEP (and exceptions in user code) *

***********************************************************************

GSRET:	* Here is where the ILLEGAL/TRACE instr vector points to return
	cmp.w	#0,usrcodf		Did we arrive here from users code?
	bne	EXHANDL			No, so lets show it and abort
	move.w	#$FF,usrcodf		Signal back in SID's own code
	move.l	(SP)+,STKVAL		Discard the IBRVEC return address
	move.w  (SP)+,status            grab info from sys stack
        move.l  (SP)+,pctr
	move.l	SP,savessp		Save User State
	move.l	realssp,SP		Restore original SSP
	move.l	a0,savea0
	move.l	USP,a0
	move.l	a0,saveusp
	move.l	savea0,a0
 	andi	$5FFF,SR		Go back to user mode
	movem.l a6/a7,bsave             save regs
        move.l	asave+4,SP              get old regs
        move.l  4(SP),a6		Continue restoring original state
        move.l  pctr,(a6)
	move.l	saveusp,4(a6)
	move.l	savessp,8(a6)
        move.w  status,12(a6)
	and.w	#$7FFF,12(a6)		Insure no trace set
        movem.l d0-d7/a0-a5,14(a6)
        move.l  bsave,70(a6)
        move.l  bsave+4,74(a6)
	btst	#5,status
	beq	wasusr
	move.l	savessp,74(a6)
wasusr: move.l  asave,a6
        movem.l	regsave,d0-d7/a0-a5
	move.l	errflag,d0
	rts                             back to SID proper

*****************************************************************
*								*
*	Exception Vector Handler				*
*								*
*****************************************************************

EXHANDL:
	move.l	#$FF,errflag		* indicate error to caller
	Move.L	(SP),STKVAL		* Get return address to compute Excp.#
	Move.L	SP,ESTKSV		* Save user SSP
	Move.L	#EXCSTK,SP		* And get one of our own
	Movem.L	D0-D7/A0-A6,-(SP)	* Plenty big enough to save regs
	Move.L	STKVAL,D1		* Get the IBRVEC RA again
	Sub.L	#IBRVEC+6,D1		* Make it an offset into IBRVEC
	Divu.W	#3,D1			* Get (EXV-2) * 2
	And.L	#$FFFF,D1		* Clear out the remainder
	Lsl.L	#1,D1			* Make it an offset into messages
	Cmp.W	#8,D1			* If Bus Error or Address Error
	Bge	EXHAN1
	Add.L	#8,ESTKSV		* .. Then get rid of garbage
EXHAN1:	Add.L	#EXMSLT,D1		* Now a pointer to message pointer
	Move.L	D1,A0
	Move.L	(A0),-(SP)		* Now a pointer to the message
	Move.W	#9,-(SP)		* Good enough for printing
	Trap	#1
	Addq.L	#6,SP
	Move.L	#ATMES,-(SP)		* Print " at "
	Move.W	#9,-(SP)		* Good enough for printing
	Trap	#1
	Addq.L	#6,SP
	Move.L	ESTKSV,A0		* Get exception RA
	Move.L	6(A0),-(SP)		* Throw it on the stack
	Jsr	_puthexl		* And print it out
	Addq.L	#4,SP
	Move.L	#ENDMES,-(SP)		* Print out the <CR><LF>
	Move.W	#9,-(SP)		* Good enough for printing
	Trap	#1
	Addq.L	#6,SP
	Movem.L	(SP)+,D0-D7/A0-A6	* Get old register values
	Move.L	ESTKSV,SP		* And the old stack pointer
	cmp.w	#0,usrcodf		Check if exception in SID's code?
	beq	GSRET			User's return thru the GO/STEP handler
	Move.L	(SP)+,STKVAL		* Discard the IBRVEC return address
	jmp	SIDCCEX			SID's, abort SID

*****************************************************************
*****************************************************************

	.data

*
*	Message Table contains all the exception handler messages
*
BUSERR:	Dc.B	"Bus Error",0
ADRERR:	Dc.B	"Address Error",0
ILLINS:	Dc.B	"Illegal Instruction",0
ZERDIV:	Dc.B	"Divide by Zero",0
CHKINS:	Dc.B	"'CHK' Exception",0
TPVINS:	Dc.B	"'TRAPV' Exception",0
PRVERR:	Dc.B	"Privilege Violation",0
XTRACE:	Dc.B	"Trace Exception",0
LN10EM:	Dc.B	"Line 1010 Emulator",0
LN15EM:	Dc.B	"Line 1111 Emulator",0
ATMES:	Dc.B	" at ",0
BYEMES:	Dc.B	"Bye",0
ENDMES:	Dc.B	$0D,$0A,0

	.even

OLDVEC:	.Ds.L	11			* Old vector addresses, incl Control-C
EXMSLT:	.Dc.L	BUSERR,ADRERR,ILLINS	* Message addresses
	.Dc.L	ZERDIV,CHKINS,TPVINS
	.Dc.L	PRVERR,XTRACE,LN10EM
	.Dc.L	LN15EM

	.data
* This is where exceptions point.  Sole purpose is to put their return
* address on the stack so that the exception number can be calculated.
IBRVEC:	Jsr	EXHANDL			* #2 = Bus Error
	Jsr	EXHANDL			* #3 = Address Error
	Jsr	GSRET			* #4 = Illegal Instruction (for GO)
	Jsr	EXHANDL			* #5 = Zero Divide
	Jsr	EXHANDL			* #6 = CHK Instruction
	Jsr	EXHANDL			* #7 = TRAPV Instruction
	Jsr	EXHANDL			* #8 = Privilege Violation
	Jsr	GSRET			* #9 = Trace (for STEP)
	Jsr	EXHANDL			* #10= Line 1010 Emulator
	Jsr	EXHANDL			* #11= Line 1111 Emulator

*****************************************************************

	.bss

	.ds.l	400
usrstk:	
	.ds.l	400
supstk:	
retsav:	.ds.l	1
ESTKSV:	.Ds.L	1			* One LONG for the old user stack
STKVAL:	.Ds.L	1			* Value of pointer from IBRVEC
	.Ds.B	256			* Plenty of room for Exception Stack
EXCSTK:
errflag: .ds.l	1
asave:   .ds.l  2
bsave:   .ds.l  3
regsave: .ds.l	14
realssp: .ds.l	1
savessp: .ds.l	1
saveusp: .ds.l	1
savea0:  .ds.l  1
pctr:    .ds.l  1
status:  .ds.w  1
usrcodf: .ds.w	1

        .end
