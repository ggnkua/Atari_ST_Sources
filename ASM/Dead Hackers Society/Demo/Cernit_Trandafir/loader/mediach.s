; force media change
; ripped from atari compendium
; must run from supervisor mode

; _mediach(): force the media 'changed' state on a removable drive.
;
; Usage: errcode = _mediach( devno ) - returns 1 if an error occurs
;
; Inputs: d0.w	devno - (0 = 'A:', 1 = 'B:', etc...)


mediach:	moveq.l	#0,d0			; force a:
		move.w	d0,mydev
		add.b	#'A',d0
		move.b	d0,fspec		; Set drive spec for search

loop:		move.l $472,oldgetbpb
		move.l $47e,oldmediach
		move.l $476,oldrwabs

		move.l #newgetbpb,$472
		move.l #newmediach,$47e
		move.l #newrwabs,$476

; Fopen a file on that drive
		move.w	#0,-(sp)
		move.l	#fspec,-(sp)
		move.w	#$3d,-(sp)
		trap	#1
		addq.l	#8,sp

; Fclose the handle
		tst.l	d0
		bmi.s	noclose

		move.w	d0,-(sp)
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp

noclose:	moveq.l	#0,d7
		cmp.l	#newgetbpb,$472			; still installed?
		bne.s	done

		move.l	oldgetbpb,$472			; Error, restore vectors.
		move.l	oldmediach,$47e
		move.l	oldrwabs,$476

		moveq.l	#1,d0				; 1 = Error
		rts

done:		moveq.l #0,d0				; 0 = No Error
		rts


; New Getbpb()...if it's the target device, uninstall vectors.
; In any case, call normal Getbpb().

newgetbpb:	move.w	mydev,d0
		cmp.w	4(sp),d0
		bne.s	dooldg

		move.l	oldgetbpb,$472			; Got target device so uninstall.
		move.l	oldmediach,$47e
		move.l	oldrwabs,$476
dooldg:		move.l	oldgetbpb,a0			; Go to real Getbpb()
		jmp	(a0)


; New Mediach()...if it's the target device, return 2. Else call old.

newmediach:	move.w	mydev,d0
		cmp.w	4(sp),d0
		bne.s	dooldm
		moveq.l	#2,d0				; Target device, return 2
		rts

dooldm:		move.l	oldmediach,a0			; Call old
		jmp	(a0)


; New Rwabs()...if it's the target device, return E_CHG (-14)

newrwabs:	move.w	mydev,d0
		cmp.w	4(sp),d0
		bne.s	dooldr
		moveq.l	#-14,d0
		rts

dooldr:		move.l	oldrwabs,a0
		jmp	(a0)


		section	data

fspec:		dc.b	"X:\\X",0
mydev:		ds.w	1
oldgetbpb:	ds.l	1
oldmediach:	ds.l	1
oldrwabs:	ds.l	1

		section	text
		