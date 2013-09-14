* FILE: MEDIA.S
* ======================================================================
* Description: cause media-change on a logical device.
*
* USAGE: errcode = mediach( devno );	/* returns 1 for error */
*	 int errcode, devno;
*
* RETURNS: 0 for no error, 1 for error ( GEMDOS never did a getbpb
*	   call; should never happen )
*
* SOURCE: Rainbow TOS 1.4 Release Notes: August 7, 1989
* 
* for Turbo C, this routine must be cdecl since the variable is
* passed on the stack.


	.globl mediach


	.text
	

mediach:
	move.w	4(sp),d0
	move.w	d0, mydev
	add.b	#'A',d0
	move.b	d0,fspec	; set drive spec for search first
	
loop:
	clr.l	-(sp)		; get super mode, leave old ssp
	move.w	#$20,-(sp)	; and "super" function code on stack
	trap	#1
	addq	#6,sp
	move.l	d0,-(sp)
	move.w	#$20,-(sp)
	
	move.l	$472,oldgetbpb
	move.l	$47e,oldmediach
	move.l	$476,oldrwabs
	
	move.l	#newgetbpb,$472
	move.l	#newmediach,$47e
	move.l	#newrwabs,$476
	
	; Fopen a file on that drive
	
	move.w	#0,-(sp)
	move.l	#fspec,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq	#8,sp
	
	; Fclose the handle we just got
	
	tst.l	d0
	bmi	noclose
	
	move.w	d0,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq	#4,sp
	
noclose:
	moveq	#0,d7
	cmp.l	#newgetbpb,$472		; still installed?
	bne	done			; nope
	
	moveq	#1,d7			; yup- remove and return
	move.l	oldgetbpb,$472
	move.l	oldmediach,$47e
	move.l	oldrwabs,$476
	
done:
	trap	#1			; go back to user mode( use stuff
	addq	#6,sp			; left on stack above )
	
	move.l	d7,d0
	rts
	
	
* ===========================================================
* new getbpb: if it's our device, uninstall vectors;
*	      in any case, call the old getbpb vector ( to really
*	      get it.)
*
newgetbpb:
	move.w	mydev,d0
	cmp.w	4(sp),d0
	bne	dooldg
	move.l	oldgetbpb,$472	;it's mine: un-install new vectors
	move.l	oldmediach,$47e 
	move.l	oldrwabs,$476
dooldg:
	move.l	oldgetbpb,a0	; continue here whether mine or not:
				; call old.
	jmp	(a0)
	

* ===========================================================
* new mediach: if it's our device, return 2; else call old
*
newmediach:
	move.w	mydev,d0
	cmp.w	4(sp),d0
	bne	dooldm
	moveq.l	#2,d0		; it's mine: return 2 ( definitely changed )
	rts

dooldm:	move.l	oldmediach,a0	; not mine: call old vector
	jmp	(a0)


* ===========================================================
* new rwabs: return E_CHG ( -14 ) if it's my device
*
newrwabs:
	move.w	mydev,d0
	cmp.w	$e(sp),d0
	bne	dooldr
	moveq.l	#-14,d0
	rts
	
dooldr:
	move.l	oldmediach,a0
	jmp	(a0)
	
	
		.data
	
fspec:		dc.b	"X:\\X",0	; file to look for( doesn't matter)

		.bss

mydev:		ds.w	1
oldgetbpb:	ds.l	1
oldmediach:	ds.l	1
oldrwabs:	ds.l	1

	.end
	
	
			
	
	
	