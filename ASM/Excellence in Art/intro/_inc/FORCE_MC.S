;/*
;* _mediach(): force the media ‘changed’ state on a removable drive.
;*
;* Usage: errcode = _mediach( devno ) - returns 1 if an error occurs
;*
;* Inputs: devno - (0 = ‘A:’, 1 = ‘B:’, etc...)
;*
;*/

mc_mediach:

	rept 0
	cmp.w #0,mc_installed
	bne .byebye
	bra .goon
.byebye
	rts
.goon
	move.w #1,mc_installed
	endr

;	move.w 4(sp),d0
		move.l #0,d0 ; XiA - force A:
	move.w d0,mc_mydev
	add.b #"A",d0
	move.b d0,mc_fspec ; Set drive spec for search

mc_loop:
	rept 0
	clr.l -(sp) ; Get supervisor mode, leave old SSP
	move.w #$20,-(sp) ; and “Super” function code on stack.
	trap #1
	addq.l #6,sp
	move.l d0,-(sp)
	move.w #$20,-(sp)
	endr

	cmp.l #mc_newgetbpb,$472 ; already installed?
	beq mc_alreadyinstalled

	move.l $472,mc_oldgetbpb
	move.l $47e,mc_oldmediach
	move.l $476,mc_oldrwabs

	move.l #mc_newgetbpb,$472
	move.l #mc_newmediach,$47e
	move.l #mc_newrwabs,$476

mc_alreadyinstalled

	; Fopen a file on that drive
	move.w #0,-(sp)
	move.l #mc_fspec,-(sp)
	move.w #$3d,-(sp)
	trap #1
	addq.l #8,sp

	; Fclose the handle
	tst.l d0
	bmi.s mc_noclose

	move.w d0,-(sp)
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp

mc_noclose:
	moveq #0,d7
	cmp.l #mc_newgetbpb,$472 ; still installed?
	bne.s mc_done

	move.l mc_oldgetbpb,$472 ; Error, restore vectors.
	move.l mc_oldmediach,$47e
	move.l mc_oldrwabs,$476

	rept 0
	trap #1 ; go back to user mode
	addq.l #6,sp ; restore sp
	endr

	moveq.l #1,d0 ; 1 = Error
	rts
mc_done:
	rept 0
	trap #1 ; go back to user mode
	addq.l #6,sp ; from stack left above
	endr

	clr.l d0 ; No Error
	rts

;/*
;* New Getbpb()...if it’s the target device, uninstall vectors.
;* In any case, call normal Getbpb().
;*/

mc_newgetbpb:
	move.w mc_mydev,d0
;	cmp.w 4(sp),d0
		cmp.w #0,d0 ; XiA - force A:
	bne.s mc_dooldg

	move.l mc_oldgetbpb,$472 ; Got target device so uninstall.
	move.l mc_oldmediach,$47e
	move.l mc_oldrwabs,$476
mc_dooldg:
	move.l mc_oldgetbpb,a0 ; Go to real Getbpb()
	jmp (a0)

;/*
;* New Mediach()...if it’s the target device, return 2. Else call old.
;*/

mc_newmediach:
	move.w mc_mydev,d0
;	cmp.w 4(sp),d0
		cmp.w #0,d0 ; XiA - force A:
	bne.s mc_dooldm
	moveq.l #2,d0 ; Target device, return 2

	rts

mc_dooldm:
	move.l mc_oldmediach,a0 ; Call old
	jmp (a0)

;/*
;* New Rwabs()...if it’s the target device, return E_CHG (-14)
;*/

mc_newrwabs:
	move.w mc_mydev,d0
;	cmp.w 4(sp),d0
		cmp.w #0,d0 ; XiA - force A:
	bne.s mc_dooldr
	moveq.l #-14,d0
	rts

mc_dooldr:
	move.l mc_oldrwabs,a0
	jmp (a0)


mc_fspec: dc.b "X:\\X",0
mc_mydev: ds.w 1
mc_oldgetbpb: ds.l 1
mc_oldmediach: ds.l 1
mc_oldrwabs: ds.l 1

	rept 0
mc_installed dc.w 0
	endr