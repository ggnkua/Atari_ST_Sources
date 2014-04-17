

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

	clr.l	a0
	move.l	$472(a0),oldgetbpb
	move.l	$47e(a0),oldmediach
	move.l	$476(a0),oldrwabs

	move.l	#newgetbpb,$472(a0)
	move.l	#newmediach,$47e(a0)
	move.l	#newrwabs,$476(a0)

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
	clr.l	a0
	cmp.l	#newgetbpb,$472(a0)	; still installed?
	bne.s	done			; nope

	moveq	#1,d0			; yup! remove & return TRUE
	move.l	oldgetbpb,$472(a0)
	move.l	oldmediach,$47e(a0)
	move.l	oldrwabs,$476(a0)

done:
*	trap	#1			; go back to user mode (use stuff
*	addq.w	#$6,sp			; left on stack above)

*	move.l	d7,d0
*	dbeq	d6,loop			; loop until success, or 10 failures.
	rts

*************************************************************************
* new getbpb: if it's our device, uninstall vectors; 			*
*	      in any case, call the old getbpb vector (to really 	*
*	      get it)							*
*************************************************************************

newgetbpb:
	move.w	mydev,d0
	cmp.w	4(sp),d0
	bne.s	dooldg
	clr.l	a0
	move.l	oldgetbpb,$472(a0) 	; it's mine: un-install new vectors
	move.l	oldmediach,$47e(a0)
	move.l	oldrwabs,$476(a0)
dooldg:	move.l	oldgetbpb,a0		; continue here whether mine or not: 
	jmp	(a0)			; call old.


*************************************************************************
* new mediach: if it's our device, return 2; else call old.		*
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
*	newrwabs: return E_CHG (-14) if it's my device			*
*************************************************************************

newrwabs:
	move.w	mydev,d0
	cmp.w	$e(sp),d0
	bne.b	dooldr
	moveq.l	#-14,d0
	rts

dooldr:	move.l	oldrwabs,a0	; changed from oldmediach to oldrwabs
	jmp	(a0)


*********************************
*	end of mediach		*
*********************************

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
retsav:		.ds.l	1

	.end

