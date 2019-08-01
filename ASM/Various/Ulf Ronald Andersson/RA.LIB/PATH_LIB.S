;----------------------------------------------------------------------------
;File name:	PATH_LIB.S			Revision date:	1998.08.14
;Created by:	Ulf Ronald Andersson		Creation date:	1996.02.13
;(c)1996 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE			(commercial sale forbidden)
;----------------------------------------------------------------------------
;Purpose:	Code library for path string operations
;----------------------------------------------------------------------------
;Subroutines:
;
; All use a0,a1 for input pointers with results in those buffers,
; leaving all registers unaltered at return.
;
;fix_path(path)		  => path -> Full pathname
;get_path(path)		  => path -> Full default path
;cut_path_name(path)	  => path -> Full pure path without filename
;cut_path_type(path)	  => path -> Full pathname without type extension
;new_path_name(path,name) => path -> Full pathname with new filename
;new_path_type(path,type) => path -> Full pathname with new type extension
;
;	all above give full absolute path, even if input is relative...
;	those below do not alter path relativity
;
;cut_name(path)		=> path -> pure path without filename
;cut_type(path)		=> path -> pathname without type extension
;new_name(path,name)	=> path -> pathname with new filename
;new_type(path,type)	=> path -> pathname with new type extension
;old_path(path,dest)	=> dest -> pure path part of path
;old_name(path,name)	=> name -> filename part of path
;old_type(path,type)	=> type -> filetype part of path (incl period)
;
;----------------------------------------------------------------------------
;
	include	RA_TOS.I
;
;----------------------------------------------------------------------------
;Start of:	fix_path(path_p)	=> path_p -> Full pathname
;----------------------------------------------------------------------------
; path_p	-> user buffer holding pathname (possibly relative)
;----------------------------------------------------------------------------
;
fix_path:
	movem.l	d0-d2/a0-a4,-(sp)	;protect entry registers
	move.l	a0,a3			;a3 -> path base
;
	move.l	a3,a0			;a0 -> path base
	lea	.path_buff(pc),a1	;a1 -> .path_buff
	moveq	#127-1,d0
.copy_arg:
	move.b	(a0)+,(a1)+		;copy argument to buffer
	dbeq	d0,.copy_arg
;
	lea	.path_buff(pc),a4	;a4 -> arg path base
	move.l	a4,a2			;a2 -> arg path base
	clr	d0
	move.b	(a4)+,d0		;d0 =  drive letter if included
	beq.s	.fix_default_drive	;get default path if none given
	cmp.b	#':',(a4)+		;colon is required after drive letter
	beq.s	.fix_drive_d0
.fix_default_drive:
	move.l	a2,a4			;a4 -> arg path base
	gemdos	Dgetdrv			;d0 =  default drive code
	add	#'A',d0			;d0 =  default drive letter
.fix_drive_d0:
	move.b	d0,(a3)+		;store drive letter in user buffer
	move.b	#':',(a3)+		;append colon to user buffer
	sub	#'A',d0
	move	d0,curr_drive		;remember curr_drive
;
	cmp.b	#'\',(a4)		;does pure path begin with backslash
	beq.s	.fix_absolute
.fix_relative:
	move	curr_drive(pc),d0
	addq	#1,d0
	gemdos	Dgetpath,(a3),d0	;append default path to user buffer
.find_relation:
	tst.b	(a3)+
	bne.s	.find_relation
	subq	#2,a3			;back pointer to final char
	cmp.b	#'\',(a3)+		;final character backslash ?
	beq.s	.append_argument	;then append relative path directly
	move.b	#'\',(a3)+		;else append a backslash first
.fix_absolute:
.append_argument:
	move.b	(a4)+,(a3)+		;append argument to user buffer
	bne.s	.append_argument
;
	movem.l	(sp)+,d0-d2/a0-a4	;restore entry registers
	rts
;
.path_buff:
	ds.b	128
;
;----------------------------------------------------------------------------
;End of:	fix_path(path_p)
;----------------------------------------------------------------------------
;Start of:	get_path(path_p)	=> path_p -> Full default path
;----------------------------------------------------------------------------
; path_p	-> user buffer to which path is to be copied
; curr_drive	=  static variable initially -1 (=> current default drive)
;----------------------------------------------------------------------------
;
get_path:
	movem.l	d0-d2/a0-a3,-(sp)	;protect entry registers
	move.l	a0,a3			;a3 -> string destination
	move	curr_drive,d0
	bmi.s	.get_drive
	bios	Mediach,d0
	tst.l	d0
	bne.s	.get_drive
	move	curr_drive(pc),d0
	bra.s	.put_drive
;
.get_drive:
	gemdos	Dgetdrv
.put_drive:
	move.b	d0,curr_drive
	add	#'A',d0
	move.l	a3,a0			;a0 -> string destination
	move.b	d0,(a0)+
	move.b	#':',(a0)+
	sub	#'A',d0
.get_path:
	addq	#1,d0
	gemdos	Dgetpath,(a0),d0
	move.l	a3,a0			;a0 -> string destination
.test_path:
	tst.b	(a0)+
	bne.s	.test_path
	subq	#2,a0			;back pointer to final char
	cmp.b	#'\',(a0)+		;final character backslash ?
	beq.s	.exit
	move.b	#'\',(a0)+		;else replace terminator with backslash
	clr.b	(a0)+			;and reterminate
.exit:
	movem.l	(sp)+,d0-d2/a0-a3	;restore entry registers
	rts
;
;----------------------------------------------------------------------------
;End of:	get_path(path_p)
;----------------------------------------------------------------------------
;Start of:	cut_path_name(path_p)	=> path_p -> Full pure path
;----------------------------------------------------------------------------
;
cut_path_name:
	bsr	fix_path		;ensure full path
cut_name:
	movem.l	d0-d1/a0-a2,-(sp)	;protect entry registers
	move.l	a0,a2			;a2 -> path base
;
	move.l	a2,a0			;a0 -> path base
	moveq	#127-1,d0
.note_slash:
	move.l	a0,a1			;a1 =  possible name start
.pass_path:
	move.b	(a0)+,d1
	beq.s	.passed
	cmp.b	#'\',d1
	dbeq	d0,.pass_path
	dbra	d0,.note_slash
;
.passed:
	clr.b	(a1)			;reterminate path at name start
;
	movem.l	(sp)+,d0-d1/a0-a2	;restore entry registers
	rts
;
;----------------------------------------------------------------------------
;End of:	cut_path_name(path_p)
;----------------------------------------------------------------------------
;Start of:	cut_path_type(path_p)	=> path_p -> Full path without type
;----------------------------------------------------------------------------
;
cut_path_type:
	bsr	fix_path		;ensure full path
cut_type:
	movem.l	d0-d1/a0-a1,-(sp)	;protect entry registers
	move.l	a0,a1			;a1 -> path base
;
	move.l	a1,a0			;a0 -> path base
	moveq	#127-1,d0
.pass_path:
	tst.b	(a0)+
	dbeq	d0,.pass_path
	subq	#1,a0			;back pointer to terminator
	moveq	#4-1,d1
.pass_type:
	cmpa.l	a1,a0
	ble.s	.exit
	move.b	-(a0),d0
	cmp.b	#'\',d0
	beq.s	.exit
	cmp.b	#'.',d0
	dbeq	d1,.pass_type
	bne.s	.exit
	clr.b	(a0)			;reterminate name at extension
;
.exit
	movem.l	(sp)+,d0-d1/a0-a1	;restore entry registers
	rts
;
;----------------------------------------------------------------------------
;End of:	cut_path_type(path_p)
;----------------------------------------------------------------------------
;Start of:	new_path_name(path_p,name) => path_p -> path with new name
;----------------------------------------------------------------------------
;
new_path_name:
	bsr	fix_path		;ensure full path
new_name:
	bsr	cut_name
	movem.l	d0-d1/a0-a1,-(sp)	;protect entry registers
;
;a0 -> path base
;a1 -> name base
;
	moveq	#127-1,d0
.pass_path:
	tst.b	(a0)+
	dbeq	d0,.pass_path
	subq	#1,a0			;back pointer to terminator
.append_name:
	move.b	(a1)+,(a0)+		;append name to path buffer
	bne.s	.append_name
;
	movem.l	(sp)+,d0-d1/a0-a1	;restore entry registers
	rts
;
;----------------------------------------------------------------------------
;End of:	new_path_name(path_p,name)
;----------------------------------------------------------------------------
;Start of:	new_path_type(path_p,type) => path_p -> path with new type
;----------------------------------------------------------------------------
;
new_path_type:
	bsr	fix_path		;ensure full path
new_type:
	bsr	cut_type
	movem.l	d0-d1/a0-a1,-(sp)	;protect entry registers
;
;a0 -> path base
;a1 -> type base
;
	moveq	#127-1,d0
.pass_path:
	tst.b	(a0)+
	dbeq	d0,.pass_path
	subq	#1,a0			;back pointer to terminator
.append_type:
	move.b	(a1)+,(a0)+		;append type to path buffer
	bne.s	.append_type
;
	movem.l	(sp)+,d0-d1/a0-a1	;restore entry registers
	rts
;
;----------------------------------------------------------------------------
;End of:	new_path_type(path_p,type)
;----------------------------------------------------------------------------
;Start of:	old_path(path_p,dest_p) => dest_p -> old path of pathname
;----------------------------------------------------------------------------
;
old_path:
	movem.l	d0-d1/a0-a3,-(sp)	;protect entry registers
	move.l	a0,a2			;a2 -> path base
	move.l	a1,a3			;a3 -> dest base
;
	move.l	a2,a0			;a0 -> path base
	moveq	#127-1,d0
.note_slash:
	move.l	a3,a1			;a1 =  possible dest name start
.pass_path:
	move.b	(a0)+,d1
	move.b	d1,(a3)+
	beq.s	.passed
	cmp.b	#'\',d1
	dbeq	d0,.pass_path
	dbra	d0,.note_slash
;
.passed:
	clr.b	(a1)+			;reterminate dest path at name
;
	movem.l	(sp)+,d0-d1/a0-a3	;restore entry registers
	rts
;
;----------------------------------------------------------------------------
;End of:	old_path(path_p,dest_p)
;----------------------------------------------------------------------------
;Start of:	old_name(path_p,name_p) => name_p -> old name of pathname
;----------------------------------------------------------------------------
;
old_name:
	movem.l	d0-d1/a0-a3,-(sp)	;protect entry registers
	move.l	a0,a2			;a2 -> path base
	move.l	a1,a3			;a3 -> name base
;
	move.l	a2,a0			;a0 -> path base
	moveq	#127-1,d0
.note_slash:
	move.l	a0,a1			;a1 =  possible name start
.pass_path:
	move.b	(a0)+,d1
	beq.s	.passed
	cmp.b	#'\',d1
	dbeq	d0,.pass_path
	dbra	d0,.note_slash
;
.passed:
.copy_name:
	move.b	(a1)+,(a3)+
	bne.s	.copy_name
;
	movem.l	(sp)+,d0-d1/a0-a3	;restore entry registers
	rts
;
;----------------------------------------------------------------------------
;End of:	old_name(path_p,name)
;----------------------------------------------------------------------------
;Start of:	old_type(path_p,type_p) => type_p -> old type of pathname
;----------------------------------------------------------------------------
;
old_type:
	movem.l	d0-d1/a0-a2,-(sp)	;protect entry registers
	move.l	a1,a2			;a2 -> type base
	move.l	a0,a1			;a1 -> path base
;
	move.l	a1,a0			;a0 -> path base
	moveq	#127-1,d0
.pass_path:
	tst.b	(a0)+
	dbeq	d0,.pass_path
	subq	#1,a0			;back pointer to terminator
	moveq	#4-1,d1
.pass_type:
	cmpa.l	a1,a0
	ble.s	.exit
	move.b	-(a0),d0
	cmp.b	#'\',d0
	beq.s	.exit
	cmp.b	#'.',d0
	dbeq	d1,.pass_type
	bne.s	.exit
.copy_type:
	move.b	(a0)+,(a2)+
	bne.s	.copy_type
;
.exit
	movem.l	(sp)+,d0-d1/a0-a2	;restore entry registers
	rts
;
;----------------------------------------------------------------------------
;End of:	old_type(path_p,type)
;----------------------------------------------------------------------------
;Start of:	static data
;----------------------------------------------------------------------------
;
curr_drive:	dc.w	-1
;
;----------------------------------------------------------------------------
;End of:	static data
;----------------------------------------------------------------------------
;End of file:	PATH_LIB.S
;----------------------------------------------------------------------------
