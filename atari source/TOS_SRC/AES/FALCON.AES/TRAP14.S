*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/trap14.s,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:31:22 $	$Locker: kbad $
* =======================================================================
*  $Log:	trap14.s,v $
* Revision 2.2  89/04/26  18:31:22  mui
* TT
* 
* Revision 2.1  89/02/22  05:32:36  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.6  89/02/12  01:05:14  kbad
* Added zeropage references in _mediach, to save a few bytes from as68 idiocy
* 
* Revision 1.5  89/01/24  07:21:02  kbad
* Optimize get/putmouse, and make maddr available as a flag. (clear on exit
* from _putmouse
* 
* Revision 1.4  88/07/27  10:32:47  mui
* fix mediach
* 
* Revision 1.3  88/07/01  16:25:55  mui
* Nothing
* 
* Revision 1.2  88/07/01  16:22:56  mui
* add mediach code
* 
* Revision 1.1  88/06/02  12:36:33  lozben
* Initial revision
* 
*************************************************************************
*	trap14.s	02/28/85 - 05/21/85		Derek Mui	
*	combine trap14 trap13 with trp14 and trp13	3/4/86	D.Mui
*	Added save mouse form function	1/6/87	- 1/7/87Derek Mui
*	Take out s68	2/9/88				D.Mui
*	Rename maddr to _maddr		6/25/90		D.Mui
*	Use MAC to assemble		6/28/90		D.Mui
* assemble with MAS 900801 kbad (removed zeropage a0 from mediach)
*	Fix mediach at dooldr 		12/11/90	D.Mui
*	Fix at mediach at remove extra slash at the beginning 4/5/91 D.Mui


	.globl _trap14
	.globl _trap13
	.globl _gr_mouse
	.globl _trp13
	.globl _trp14
	.globl _getmouse
	.globl _putmouse
	.globl _LBCOPY
	.globl _mediach
	.globl _maddr		; used by gembind:graf_mouse as a flag

	.text

_trap13:
_trp13:
	move.l	(sp)+, trp13ret
	trap	#13
	move.l	trp13ret, -(sp)
	rts


_trap14:
_trp14:
	move.l	(sp)+, trp14ret
	trap	#14
	move.l	trp14ret, -(sp)
	rts


_getmouse:
	.dc.w	$A000
	suba.l	#$358,a0
	move.l	a0,_maddr		; save the mouse block address
	lea	mform,a1		; destination
	move.w	#36,d0			; size ( - 1 for dbra )
getmcp:
	move.w	(a0)+,(a1)+
	dbra	d0,getmcp
	rts

_putmouse:
	lea	mform,a0		; from our form
	move.l	_maddr,a1		; back to the line-a
	move.w	#36,d0			; size ( - 1 for dbra )
putmcp:
	move.w	(a0)+,(a1)+
	dbra	d0,putmcp
	clr.l	_maddr			; no longer in use...
	rts


*************************************************************************
*									*
*	mediach: cause media-change on a logical device.		*
*									*
*	USAGE:								*
*		errcode = mediach(devno);    /* returns 1 for error */	*
*		int errcode, devno;					*
*									*
*									*
*	This procedure causes a media change by installing a new	*
*	handler for the mediach, rwabs, and getbpb vectors; for device	*
*	devno, the mediach handler returns "definitely changed," and	*
*	the rwabs handler returns E_CHNG, until the new getbpb handler	*
*	is called.  The new getbpb handler un-installs the new 		*
*	handlers.							*
*									*
*	After installing the new handlers, this procedure performs a	*
*	disk operation (e.g. search first) which makes GEMDOS check	*
*	the media-change status of the drive: this will trigger the	*
*	new rwabs, mediach and getbpb handlers to do their things.	*
*									*
*	RETURNS: 0 for no error, 1 for error (GEMDOS didn't ever do a	*
*		getbpb call).						*
*									*
*************************************************************************



_mediach:
	move.w	4(sp),d0
	move.w	d0,mydev
	add.b	#'A',d0
	move.b	d0,fspec		; set drive spec for search first
	move.b	#$3a,fspec+1
	move.l	#$5c580000,fspec+2	; make sure it is on word boundary


*	move.w	#9,d6			; loop 10 times!

loop:
*	clr.l	-(sp)			; get super mode, leave old ssp
*	move.w	#$20,-(sp)		; and "super" function code on stack
*	trap	#1
*	addq	#6,sp
*	move.l	d0,-(sp)
*	move.w	#$20,-(sp)

	move.l	$472.w,oldgetbpb
	move.l	$47e.w,oldmediach
	move.l	$476.w,oldrwabs

	move.l	#newgetbpb,$472.w
	move.l	#newmediach,$47e.w
	move.l	#newrwabs,$476.w

*	; Fopen a file on that drive

	move.w	#0,-(sp)
	move.l	#fspec,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq	#8,sp

*	; Fclose the handle we just got

	tst.l	d0
	bmi.b	noclose

	move.w	d0,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq	#4,sp

noclose:
	moveq	#0,d0
	cmp.l	#newgetbpb,$472.w	; still installed?
	bne.b	done			; nope

	moveq	#1,d0			; yup! remove & return TRUE
	move.l	oldgetbpb,$472.w
	move.l	oldmediach,$47e.w
	move.l	oldrwabs,$476.w

done:
*	trap	#1			; go back to user mode (use stuff
*	addq.w	#$6,sp			; left on stack above)

*	move.l	d7,d0
*	dbeq	d6,loop			; loop until success, or 10 failures.
	rts

*************************************************************************
*									*
* new getbpb: if it's our device, uninstall vectors; 			*
*	      in any case, call the old getbpb vector (to really 	*
*	      get it)							*
*									*
*************************************************************************

newgetbpb:
	move.w	mydev,d0
	cmp.w	4(sp),d0
	bne.b	dooldg
	move.l	oldgetbpb,$472.w ; it's mine: un-install new vectors
	move.l	oldmediach,$47e.w
	move.l	oldrwabs,$476.w
dooldg:	move.l	oldgetbpb,a0	; continue here whether mine or not: call old.
	jmp	(a0)

*************************************************************************
*									*
* new mediach: if it's our device, return 2; else call old.		*
*									*
*************************************************************************

newmediach:
	move.w	mydev,d0
	cmp.w	4(sp),d0
	bne.b	dooldm
	moveq.l	#2,d0		; it's mine: return 2 (definitely changed)
	rts

dooldm:	move.l	oldmediach,a0	; not mine: call old vector.
	jmp	(a0)


*************************************************************************
*									*
*	newrwabs: return E_CHG (-14) if it's my device			*
*									*
*************************************************************************

newrwabs:
	move.w	mydev,d0
	cmp.w	$e(sp),d0
	bne.b	dooldr
	moveq.l	#-14,d0
	rts

dooldr:	move.l	oldrwabs,a0	; changed from oldmediach to oldrwabs
	jmp	(a0)


*************************************************************************
*									*
*	end of mediach							*
*									*
*************************************************************************

	.bss
	.even

fspec:		.ds.b	8		; file to look for (doesn't matter)
mydev:		.ds.w	1
oldgetbpb:	.ds.l	1
oldmediach:	.ds.l	1
oldrwabs:	.ds.l	1
		.ds.l	1
_maddr:		.ds.l	1
mform:		.ds.w	37
trp13ret:	.ds.l	1
trp14ret:	.ds.l	1

	.end
