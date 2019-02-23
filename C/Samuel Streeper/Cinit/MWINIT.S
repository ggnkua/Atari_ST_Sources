/
/ dual purpose startup for accessory/programs under mwc 2.0
/ by Samuel Streeper
/ Copyright 1989 Antic Publishing

	.bssd
	.globl	_stkbot_
_stktop_:	.blkb	2
		.blkb	1024*5
_stkbot_:	.blkb	2

	.shrd
	.globl	_app_
_app_:		.word 0

	.prvd
	.globl	errno_
	.globl	environ_
	.globl	_stksize_
	.globl	_start_

errno_:		.word 0
environ_:	.long 0

/
/	a5 = base page pointer
/	_stksize_ = void
/		overwritten at runtime to make a stack limit
/	_start_ = program text base
/

	.shri
_start_:
	lea		_start_,a5
	suba.l	$256,a5		/ Fetch base page pointer

/ Allocate stack, a1 points beyond vectors
	move.l	$_stktop_, _stksize_	/ Save stack limit
	lea	_stkbot_, a7		/ Set stack

/ Push arguments for main(argc, argv, envp)
	move.l	a5, -(a7)		/ basepage
	clr.l	-(a7)			/ envp[]
	clr.l	-(a7)			/ argv[]
	clr	-(a7)			/ argc

/ Test to see if is accessory
	moveq	$0,d5
	tst.l	36(a5)			/ Parent basepage ptr clear if ACC
	sne	d5			/d5 set if application
	move	d5,_app_
	beq	cont			/is an accessory

/ Release unused memory to the system pool.
	move.l	12(a5),d0
	add.l	20(a5),d0
	add.l	28(a5),d0
	addi.l	$256,d0			/size of basepage

	move.l	d0,-(a7)
	move.l	a5, -(a7)		/ Base of retained memory
	clr	-(a7)			/ Must be zero
	move	$0x4A, -(a7)		/ Mshrink opcode
	trap	$1			/ Gemdos
	adda	$12, a7			/ Pop arguments

cont:
/ Call main(argc, argv, envp)
	suba	a6, a6			/ Zero frame pointer
	jsr	main_			/ Call main line
	adda	$10, a7			/ Pop arguments

/ Terminate
	clr	-(a7)			/ Pterm0
	trap	$1
