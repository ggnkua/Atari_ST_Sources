*	AESDISPA.S MultiTos Dispatcher Assembly	 Dec 1990	D.Mui 
*	Changed at runpgm	12/14/90			D.Mui
*	Add rundesk to create deskto process	5/1/91		D.Mui
*	Add toaes for switching to AES	10/30/91		D.Mui
*	Toaes will use mode 7 to create basepage  3/3/92	D.Mui	

*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------

		.text	

	.globl	_dispret
	.globl	_releaes
	.globl	_chkmsg
	.globl	_cli
	.globl	_sti
	.globl	_spl7
	.globl	_spl
	.globl	_disp
	.globl	_runaes
	.globl	_runacc
	.globl	_setrunacc
	.globl	_rundisp
	.globl	_switchto
	.globl	_crysbind
	.globl	_toaes
	.globl	_currpd
	.globl	_wake_up
	.globl	_savestate	
	.globl	_systopd
	.globl	_Nostr
	.globl	_waitforaes
	.globl	_gl_multi
	
*****************************************
* disable interrupts and save state	*
* _cli is the old way to do this, using *
*   a global variable			*
* _spl7 is the new way, and returns	*
*   the old status register		*
*****************************************
_cli:
	move	sr,savsr	; save the status word 
	or	#$700,sr	; Interupt level 7 
	rts
_spl7:
	move	sr,d0
	or	#$700,sr
	rts
	
*****************************************
* enable interrupts and restore state	*
* _sti takes the state from a global	*
*    variable				*
* _spl takes it from the stack		*
*****************************************
_sti:
	move	savsr,sr	
	rts
_spl:
	move	4(a7),sr
	rts

*****************************************
*	Run the dispatching process	*
*****************************************

_rundisp:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	_releaes
*	move.l	#_dispret,-(sp)
	move.l	sp,dispstack	; save the stack pointer	
	jmp	_disp		; so can use it later
_dispret:
	move.l	dispstack,sp
	movem.l	(sp)+,d0-d7/a0-a6
	rts

*********************************************************
*	The caller is already put into wait state 	*
*	It can't be activated until the receiver 	*
*	which is the AES receive the request		*
*	toaes ( aes_func, aes_blk, id )			*
*		LONG	d0,d1				*		
*		WORD	id				*
*********************************************************

_toaes:
	jsr	_waitforaes
	move.l	8(sp),-(sp)	; msg.aes_blk
	move.w	16(sp),-(sp)	; msg.aes_id;
	jsr	_chkmsg		
	addq.l	#6,sp

	move.l	d0,a0
	move.l	a0,_currpd	; get current process
	beq	t_1
	
	move.w	6(sp),d0
	cmp.w	#201,d0
	beq	t_1

	move.l	8(sp),d1	
	move.l	8(a0),a0	; get uda 
	move.l	2(a0),sp	; get this process's stack
	move.l	d1,-(sp)	; push the d1
	jsr	_crysbind	; go to aes function
	addq.l	#$4,sp
t_1:
	move.w	#1,-(sp)
	jsr	_wake_up
	addq.l	#2,sp
	bra	t_2

*******************************************************************
*	Save the current process's context into the process stack *
*	because this process is going to sleep			  *
*******************************************************************

_savestate:
	move.l	a0,-(sp)
	move.l	_currpd,a0	; get the current process
	move.l	8(a0),a0	; get the UDA
	lea	66(a0),a0

	movem.l	d0-d7/a1-a7,-(a0)

t_2:
	clr.l	_currpd
	jsr	_releaes
	move.l	dispstack,sp	; get the aestack
	jmp	_disp
	
			
*********************************************************		
* 	Reverse of savestate, restore the whole 	*	
*	context and jmp back to last stage	 	*
*	switchto( p )					*
*********************************************************

_switchto:
;	jsr	_waitforaes
	move.l	4(sp),a0	
	move.l	a0,_currpd
	move.l	8(a0),a0	; get the UDA
	lea.l	6(a0),a0	; get the saved A7
	movem.l	(a0)+,d0-d7/a1-a7

	move.l	(sp)+,a0
	rts

	
*****************************************************************
*								*
*	Exec an AES internal process				*
*								*
*	e.g. CTLMGR and DESKTOP					*
*	After Pexec, the USP will point to TPA			*
*	The super stack comes from the GEMDOS, and will be the 	*
*	same for everyone					*
*	runaes( p, textaddr )					* 	
*****************************************************************

_runaes:
	tst.l	tempstack
	bne	LOK1
	move.l	#topstack,tempstack	; make sure 'tempstack' is initialized
LOK1:
	move.l	#_Nostr,-(sp)		; create an intermediate basepage
	clr.l	-(sp)			; in order to launch the program
	move.l	#7,-(sp)		; Gemdos will allocate a biggest
	move.w	#7,-(sp)		; block of memory, so we need to 
	move.w	#$4b,-(sp)		; do Mshrink afterwards	
	trap	#1
	add.l	#16,sp
	tst.l	d0			; OK ?
	beq	r_exit			; Failed

	move.l	d0,-(sp)		; Push the intermediate basepage

	move.l	#1800,-(sp)		; New size 128 + 1672 ( USP )
	move.l	d0,-(sp)		; block start
	clr.w	-(sp)			; junk word
	move.w	#$4a,-(sp)		; Mshrink
	trap	#1
	add.l	#12,sp

	move.l	(sp)+,a1		; get the basepage again
	move.l	a1,d0
	move.l	8(sp),$8(a1)		; set the text segment of process	
	add.l	#1800,d0
	move.l	d0,$4(a1)		; set the high TPA so that the USP will
					; point to here after executed
	tst.w	_gl_multi
	bne	multitsk

	move.l	4(sp),a0		; get PD
	move.w	34(a0),d1		; get PD->pid
	move.l	tempstack,sp		; set up a temporary stack
	clr.l	-(sp)			; No environment string
	move.l	a1,-(sp)		; Process's basepage
	clr.l	-(sp)			; File Name
	
	move.w	#6,-(sp)		; just go (single tasking)
	move.w	#$4b,-(sp)
	lea	-128(sp),a1		; leave space for gemdos on stack
	move.l	a1, tempstack
	trap	#1
	move.l	tempstack,sp
	add.l	#16+128,sp
	move.l	sp,tempstack
* (undocumented GEMDOS feature; all regs are preserved by Pexec)
	swap	d1			; d1 still has PD->pid
	move.w	d0,d1			; put return code in low word
	move.l	d1,-(sp)		; push Pwait style code
	pea	_pdterm
	jsr	_forkq			; register term event

	clr.l	_currpd
	move.l	dispstack,sp
	jmp	_disp

multitsk:
	clr.l	-(sp)			; No environment string
	move.l	a1,-(sp)		; Process's basepage
	clr.l	-(sp)			; File Name
	
	move.w	#106,-(sp)		; Just go !!!!!!
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp			
r_exit:
	rts


*****************************************************************
*								*
*	Exec an AES external process				*
*								*
*	Called by sh_write to run applications when in single	*
*	tasking mode (in multitasking mode this is handled	*
*	by Pexec 106).
*	After Pexec, the USP will point to TPA			*
*	The super stack comes from the GEMDOS, and will be the 	*
*	same for everyone					*
*	execBP( PD *p, BYTE *basepage )				*
*****************************************************************

	.globl	_execBP
_execBP:
	move.l	8(sp),a1		; get basepage
	move.l	4(sp),a0		; get PD
	move.w	34(a0),d1		; get PD->pid
	move.l	tempstack,sp		; set up a temporary stack

	clr.l	-(sp)			; No environment string
	move.l	a1,-(sp)		; Process's basepage
	clr.l	-(sp)			; File Name
	move.w	#6,-(sp)		; just go (single tasking)
	move.w	#$4b,-(sp)
	lea	-128(sp),a1		; leave space for gemdos on stack
	move.l	a1, tempstack
	trap	#1
	move.l	tempstack,sp
	add.l	#16+128,sp
	move.l	sp,tempstack
* (undocumented GEMDOS feature; all regs are preserved by Pexec)
	swap	d1			; d1 still has PD->pid
	move.w	d0,d1			; put return code in low word
	move.l	d1,-(sp)		; push Pwait style code
	pea	_pdterm
	jsr	_forkq			; register term event
	jsr	_close_accs		; tell ACCs to close themselves
	clr.l	_currpd
	move.l	dispstack,sp
	jmp	_disp


*****************************************************************
* _accexec
*	Run an accessory and not giving him the basepage	*
*								*
* When accessing AES data structures (like the AES PD for the	*
* ACC), we have to run as supervisor because AES memory is	*
* supervisor protected. Not much is promised to acc's, but	*
* one thing is: a0 is nonzero when you start up.  Lots of	*
* programs use this to determine whether or not they were	*
* started as accessories.					*
*								*
* This procedure needs to be copied into unprotected memory.	*
* Otherwise the acc (which starts in user mode) can't even	*
* read the instructions here! To get a block of unprotected	*
* memory, say Mxalloc((long)size,0x13). The '1' in 0x13 means	*
* "unprotected," and the '3' means "TT RAM is OK." The jsr's	*
* here had better really assemble into jsr's, not bsr's, or	*
* the code won't be position-independent.			*
*								*
* The Mxalloc call won't work without MiNT (old TOS bombs when	*
* the 'mode' argument isn't 0-3), so we just go directly;	*
* there's no memory protection if there's no MiNT!		*
*								*
*****************************************************************

_accexec:
	tst.w	_gl_multi	; if no MiNT, just use currpd
	bne	ac_mtsk
	move.w	sr,d1		; save SR
	ori.w	#$700,sr	; turn off interrupts
	move.l	8(sp),a0	; get basepage
	clr.l	$24(a0)		; clear the parent basepage
	move.l	_currpd,a1	; get PD
	move.l	4(a0),a2	; get user stack from basepage
	move.l	a2,usp		; 
	tst.w	longframe
	bne	ac_short
	clr.w	-(sp)		; fake frame format
ac_short:
	move.l	8(a0),-(sp)	; push text address
	move.w	d1,-(sp)	; push status register
	eor	#$2000,(sp)	; put into user mode
	rte			; start it

ac_mtsk:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1		; d7 = Super(0L);
	addq.l	#6,sp
	move.l	d0,d7		; save oldssp in d7
				
	jsr	_waitforaes	; must be in Super mode to get semaphore

	move.w	#$10b,-(sp)	; get the current process id
	trap	#1
	addq.l	#2,sp
	
	move.w	d0,-(sp)	; find the corresponding AES
	jsr	_systopd	; PD address
	addq.l	#2,sp

	move.l	d0,d6		; save AES PD address in d6
	jsr	_releaes	; release the AES semaphore

	move.l	d6,a0		; get the PD
	move.l	$16(a0),a1	; p->p_textaddr, get the text segment of the acc
	move.l	$1A(a0),a0	; get the basepage
	move.l	a1,8(a0)	; set the new text segment
	clr.l	$24(a0)		; clear the parent basepage
	movem.l	a0-a1,-(sp)	; save the a0, a1

	move.l	d7,-(sp)
	move.w	#$20,-(sp)
	trap	#1		; Super(d7) -- back to user mode
	addq.l	#6,sp

	movem.l	(sp)+,a0-a1	; a0 has the basepage address
	jmp	(a1)		; exec the process
endacc:


*************************************************
*	Set up the accessory start up code by	*
*	copying them into unprotected memory	*
*	because all the accessories have to 	*
*	start from here				*
*************************************************

_setrunacc:
	tst.w	_gl_multi
	bne	s_mtsk
	move.l	#_accexec,_runacc
	moveq.l	#1,d0			; everything is OK
	rts
s_mtsk:
	movem.l	d6-d7,-(sp)
	move.l	#endacc,d7
	sub.l	#_accexec,d7		; calculate the size
	move.w	#$23,-(sp)		
	move.l	d7,-(sp)
	move.w	#$44,-(sp)		; call Mxalloc(size,0x23)
	trap	#1
	add.l	#8,sp
	tst.l	d0
	beq	s_out			; no memory
	move.l	d0,_runacc		; save the new address
	move.l	d0,a1			; load in destination address
	lea	_accexec,a0
s_move:
	move.b	(a0)+,(a1)+		; copy the code
	subq.l	#1,d7			; keep doing it
	bne	s_move
	moveq.l	#1,d0			; OK
s_out:
	movem.l	(sp)+,d6-d7
	rts
	
*************************
* BSS for this module	*
*************************

	.bss
	.even
dispstack:	.ds.l	1
savsr:		.ds.l	1		; for _cli and _si
_runacc:	.ds.l	1		; acc exec code address
psetsr:		.ds.w	1		; for psetup and process switching
		.ds.b	2048		; 2K stack
topstack:	.ds.l	1		; top of stack
tempstack:	.ds.l	1		; initialize to topstack
	.end
