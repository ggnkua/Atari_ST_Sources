***************************    JDISPA.S    ******************************
*
* $Revision: 2.3 $	$Source: /u2/MRS/osrevisions/aes/jdispa.s,v $
* =======================================================================
* $Author: mui $ 	$Date: 89/04/26 18:28:27 $    $Locker: kbad $
* =======================================================================
*
* $Log:	jdispa.s,v $
* Revision 2.3  89/04/26  18:28:27  mui
* TT - also fixed a typo in comments before _switchto
* 
* Revision 2.2  89/04/19  14:43:14  kbad
* 680x0 support, pseudo-TAS excised, changed interface to _disp, and
* now CPU type is checked before kludgeing up an exception stack frame.
* 
* Revision 2.1  89/02/22  05:30:35  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.3  88/10/12  13:58:24  mui
* added comments
* 
* Revision 1.2  88/09/21  14:29:05  mui
* Add comment
* 
* Revision 1.1  88/06/02  12:35:40  lozben
* Initial revision
* 
*************************************************************************
*	DISPA.S		late 83			Jason Loveman
*	for crystal	9/15/84 - 12/27/84	Lowell Webster
* 	for gemdos	1/31/85 - 05/22/85	
*	Clean up	02/03/88		D.Mui
*	Use MAC to assemble	6/28/90		D.Mui
* assemble with MAS 900801 kbad

	.text

	.globl	_savestate
	.globl	_switchto
	.globl	_indisp
	.globl	_gotopgm
	.globl	_cli
	.globl	_sti
	.globl	_hcli
	.globl	_hsti
	.globl	_dsptch
	.globl	_disp
	.globl	_psetup
	.globl	_rlr
	.globl	_back


longframe	= $59e			; BIOS system variable...


*****************************************************************
* Utility routines						*
*****************************************************************

*
* disable interrupts and save state
*
_cli:
	move	sr,savsr		; save it
	or	#$700,sr
	rts

*
* enable interrupts and restore state
*
_sti:
	move	savsr,sr
	rts

*
* "hard" disable interrupts, no save
*
_hcli:
	or	#$700,sr
	rts

*
* "hard" enable interrupts
*
_hsti:
	and	#$f8ff,sr
	rts

 
*****************************************************************
*								*
* _dsptch, called from lots of places to do context switching.	*
* We want to return to super from switchto (see below) by using	*
* an rte.  Return is already on stack, just push current sr...	*
* OR fix stack frame then push the sr if CPU uses long frames.	*
*								*
*****************************************************************
_dsptch:
	tas	_indisp			; be atomic
	beq.b	dsp1			; if clear, enter with _indisp set
	rts				; else just forget the whole thing
 
dsp1:	tst	longframe		; check what mode what are in
	beq.b	dsp2			; 68000 mode !

	subq	#2,sp			; bump up the stack pointer
	move.l	2(sp),(sp)		; move up the return address
	clr	4(sp)			; fake a stack frame format word

dsp2:	move	sr,-(sp)		; and finish the stack frame with sr
	
*
* Now save the context of the machine
*
_savestate:
	move	sr,srsave		; save interrupts
	or	#$700,sr		; turn them off

	move.l	a0,_savea0

	move.l	_rlr,a0			; Get the current PD
	move.l	8(a0),a0		; Get the UDA from PD

	lea	66(a0),a0		; Save the USP
	movem.l	d0-d7/a0-a7,-(a0)	; save everything

	move.l	usp,a1
	move.l	a1,64(a0)
	move.l	_savea0,32(a0)

	lea	dspstk,sp		; Load a dispatcher stack
	move	srsave,sr		; Restore interrupts
	jsr	_disp			; Go to the Sub dispatcher

* ================================================================
* gemdisp.c:disp() determines who to run next, makes him rlr,
* then comes back to us to do the actual context switch
* ================================================================

*
*	For reference purposes
*	UDA
*	{
*		WORD	u_insuper;		/* in supervisor flag	*/ 
*		ULONG	u_regs[15];		/* d0-d7,a0-a6		*/
*		ULONG	*u_spsuper;		/* supervisor stack	*/
*		ULONG	*u_spuser;		/* user stack		*/
*		ULONG	u_super[STACK_SIZE];
*		ULONG	u_supstk;
*	} ;
*
*
*

_switchto:
	move	sr,srsave
	or	#$700,sr		; no interrupts while on bogus stack!

	move.l	_rlr,sp
	move.l	8(sp),sp		; Get the UDA
	lea	2(sp),sp		; Points the D0 area	
	move.l	64(sp),a0		; Get the USP
	move.l	a0,usp
	movem.l	(sp)+,d0-d7/a0-a6	; Pull regs from uda
	move.l	(sp),sp
	clr.b	_indisp			; Can enter dispatcher now
	rte	

*****************************************************************
* _gotopgm:							*
*	Run an accessory and not giving him the basepage	*
*****************************************************************
_gotopgm:
	move	sr,savsr		; save sr
	or	#$700,SR		; turn interrupts off
	movea.l	_rlr,a0			; get pd
	move.l	$18(a0),a0		; pd->ldaddr is base page of program
	tst	longframe		; if not on longframe CPU
	beq.b	g_1			; don't need a format word
	clr	-(sp)			; otherwise fake a format word

g_1:	move.l	8(a0),-(sp)		; get beg of text on our sp
	move	savsr,-(sp)		; get current irq's.
	eor	#$2000,(sp)		; run him in user mode (SR = 0, IPL0)
	rte

*****************************************************************
*		VOID						*
*	psetup(p, codevalue)					*
*		PD		*p;				*
*		CODE		*codevalue;			*
*								*
*	Set up a process' stack frame in preparation		*
*	for an RTE that will start this process executing.	*
*****************************************************************
_psetup:
	move	sr,psetsr		; save interrupts
	or	#$700,sr		; turn them off
	move.l	4(sp),a0		; *pd
	move.l	8(sp),d0		; val
	move.l	8(a0),a1		; a1 = pd->uda
	move.l	62(a1),a2		; a2 = uda->SUPSTK
	tst	longframe		; if it's not a longframe CPU
	beq.b	p_1			; don't need a format word
	clr	-(a2)			; otherwise, fake a format word

p_1:	move.l	d0,-(a2)		; predecrement and store val on stack
	move.w	#$2000,-(a2)		; predecrement and store status word
	move.l	a2,62(a1)		; restore stack ptr
	move	psetsr,sr		; restore interrupts
	rts

*****************************************************************
* BSS for this module						*
*****************************************************************
	.bss
	.even
_savea0:	.ds.l	1
srsave:		.ds.w	1		; for savestate
savsr:		.ds.w	1		; for _cli and _si
psetsr:		.ds.w	1		; for psetup
*
		.ds.l	160		; 640 bytes ????
dspstk:		.ds.l	1
*
	.end
