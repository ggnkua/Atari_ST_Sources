;----------------------------------------------------------------------------
;File name:	RA_JAR.I			Revision date:	1998.08.15
;Creator:	Ulf Ronald Andersson		Creation date:	1992.11.15
;(c)1992 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE			(commercial sales forbidden!)
;----------------------------------------------------------------------------
;Purpose:	Macro library for cookie jar operations
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	RA_JAR_defined
RA_JAR_defined	set	1
;----------------------------------------------------------------------------
;	Library macros:
;
;get_jar_size			=> d0  = Total number of entries in jar
;get_jar_used			=> d0  = Number of used entries incl endmark
;seek_cookie	string		=> d0 -> cookie/err_code flagged PL/MI
;eval_cookie	string		=> d0  = cookie_value/err_code flagged PL/MI
;make_cookie	string,value	=> d0 -> new cookie/=err_code flagged PL/MI
;edit_cookie	string,value	=> d0 -> edited cookie/=err flagged PL/MI
;extend_jar	add_entries	=> creates new enlarged cookie jar
;set_new_jar	jar_ptr		=> activates new jar and its reset routine
;
;'make_cookie' trashes d1, all others only affect d0 + flags.
;These macros should only be used in supervisor mode.
;----------------------------------------------------------------------------
;NB: You must include the following line somewhere after the macro calls
;	"make	JAR_links"
;NB: That will cause the needed routines to be included at that point.
;NB: You may do this several times (after further calls), and at each
;NB: point only the 'newly' referenced routines will be added to the code.
;NB: A dummy reference macro exists, so routines can be added to code even
;NB: without calling them.  The macro is '_uniref', used as below:
;	"_uniref reset_old_jar"
;NB: "reset_old_jar" is the only part of a cookie program that _must_ remain
;NB: resident until reset when the jar has been extended.
;NB: To simplify this, its code is location independent.
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
;	Macro definitions:
;----------------------------------------------------------------------------
JAR_links	macro
		_unidef	get_jar_size,get_jar_used,seek_cookie
		_unidef	eval_cookie,edit_cookie,make_cookie
		_unidef	extend_jar,set_new_jar,reset_old_jar
		endm	;JAR_links
;------------------------------------
get_jar_size	macro
	_uniref	get_jar_size
	bsr	get_jar_size_code
	endm	;get_jar_size
;------------------------------------
get_jar_size_code	macro
	move.l	a0,-(sp)
	move.l	(_cookies).w,d0
	beq.s	.done\@
	move.l	d0,a0
.loop\@:
	tst.l	(a0)
	beq.s	.atend\@
	addq.l	#8,a0
	bra.s	.loop\@
.atend\@:
	move.l	4(a0),d0
.done\@:
	move.l	(sp)+,a0
	rts
	endm	;get_jar_size_code
;------------------------------------
get_jar_used	macro
	_uniref	get_jar_used
	bsr	get_jar_used_code
	endm	;get_jar_used
;------------------------------------
get_jar_used_code	macro
	move.l	a0,-(sp)
	move.l	(_cookies).w,d0
	beq.s	.done\@
	move.l	d0,a0
	clr	d0
.loop\@:
	addq	#1,d0
	tst.l	(a0)
	beq.s	.done\@
	addq.l	#8,a0
	bra.s	.loop\@
.done\@:
	move.l	(sp)+,a0
	rts
	endm	;get_jar_used_code
;------------------------------------
seek_cookie	macro	name
	_uniref	seek_cookie
	move.l	\1,d0
	bsr	seek_cookie_code
	endm	;seek_cookie
;------------------------------------
seek_cookie_code	macro
	movem.l	d6-d7/a0,-(sp)
	move.l	d0,d7
	moveq	#-34,d0		;prep 'path not found' error
	move.l	(_cookies).w,d6
	beq.s	.exit\@
	move.l	d6,a0
	moveq	#-33,d0		;prep 'file not found' error
.loop\@:
	tst.l	(a0)
	beq.s	.exit\@
	cmp.l	(a0),d7
	beq.s	.found\@
	addq.l	#8,a0
	bra.s	.loop\@
;
.found\@:
	move.l	a0,d0
.exit\@:
	tst.l	d0
	movem.l	(sp)+,d6-d7/a0
	rts		;return pl,d0->cookie or mi,d0=err_code
	endm	;seek_cookie_code
;------------------------------------
eval_cookie	macro	name
	_uniref	eval_cookie
	move.l	\1,d0
	bsr	eval_cookie_code
	endm	;eval_cookie
;
eval_cookie_code	macro
	move.l	a0,-(sp)
	seek_cookie	d0
	bmi.s	.exit\@
	move.l	d0,a0		;a0 -> cookie   (but still flagging PL)
	movem.l	4(a0),d0	;d0  = cookie value (still flagging PL)
.exit\@:
	move.l	(sp)+,a0
	rts		;return  pl,d0==cookie_value  or  mi,d0==err_code
	endm	;eval_cookie_code
;------------------------------------
edit_cookie	macro	name,value
	_uniref	edit_cookie
	move.l	\1,d0
	move.l	\2,d1
	bsr	edit_cookie_code
	endm	;edit_cookie
;------------------------------------
edit_cookie_code	macro
	move.l	a0,-(sp)
	seek_cookie	d0
	bmi.s	.exit\@
	move.l	d0,a0		;a0 -> cookie   (still flagging PL)
	movem.l	d1,4(a0)	;cookie value = d1 (still flagging PL)
.exit\@:
	move.l	(sp)+,a0
	rts		;return  pl,d0->cookie  or  mi,d0==err_code
	endm	;edit_cookie_code
;------------------------------------
make_cookie	macro	name,value
	_uniref	make_cookie
	move.l	\1,d0
	move.l	\2,d1
	bsr	make_cookie_code
	endm	;make_cookie
;------------------------------------
make_cookie_code	macro
	movem.l	d2-d3/a0,-(sp)
	move.l	d0,d2
	seek_cookie	d0
	bmi.s	.make_cookie_new
	moveq	#E_ACCDN,d0		;old cookie => 'access illegal/denied'
	bra.s	.make_cookie_exit
;
.make_cookie_new:
	get_jar_size
	move	d0,d3
	get_jar_used
	sub	d0,d3
	bgt.s	.have_room
	extend_jar	#32
	bmi.s	.make_cookie_exit
	get_jar_used
.have_room:
	subq	#1,d0
	lsl.w	#3,d0
	move.l	(_cookies).w,a0
	adda	d0,a0
	clr.l	8(a0)
	move.l	4(a0),12(a0)
	move.l	d2,(a0)
	move.l	d1,4(a0)
	move.l	a0,d0
.make_cookie_exit:
	tst.l	d0
	movem.l	(sp)+,d2-d3/a0
	rts	;return  pl,d0->cookie  or  mi,d0==err_code
	endm	;make_cookie_code
;------------------------------------
extend_jar	macro	add_entries
		_uniref	extend_jar
		move.l	\1,d0
		bsr	extend_jar_code
		endm	;extend_jar
;------------------------------------
extend_jar_code	macro
	movem.l	d1-d7/a0-a6,-(sp)
	andi.l	#$FFFF,d0
	move.l	d0,d7			;d7 = size of jar extension
	get_jar_size			;d0 = size of old jar (in entries)
	add.l	d7,d0			;d0 = size of new jar (in entries)
	move.l	d0,d7			;d7 = size of new jar (in entries)
	lsl.w	#3,d0
	gemdos	Malloc,d0
	tst.l	d0
	bmi.s	.extend_cookie_exit
	move.l	d0,a2			;a2 -> new_jar
	move.l	d0,a0			;a0 -> new_jar
	move.l	(_cookies).w,a1		;a1 -> old_jar
	get_jar_used			;d0 = used size of jar
	subq	#1,d0			;prep for dbra
	bmi.s	.set_limit		;skip move if no jar
	bra.s	.move_next		;do move excluding limit_mark
;
.move_loop:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
.move_next:
	dbra	d0,.move_loop
.set_limit:
	clr.l	(a0)+
	move.l	d7,(a0)
	move.l	a2,d0
	set_new_jar	d0
.extend_cookie_exit:
	tst.l	d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts	;return  pl,d0->cookie_jar  or  mi,d0==err_code
	endm	;extend_jar
;----------------------------------------------------------------------------
;	Here is the XBRA_linked reset routine to remove altered cookie jar,
;	with the necessary variables, and the installation routine
;
set_new_jar	macro	jar_ptr
	_uniref	set_new_jar
	move.l	\1,d0
	bsr	set_new_jar_code
	endm	;set_new_jar
;
set_new_jar_code	macro
	_uniref	reset_old_jar
	move.l	(_cookies).w,_cookies_save
	move.l	(resvalid).w,resvalid_save
	move.l	(resvector).w,resvector_save
	move.l	#uncookie_reset,(resvector).w
	move.l	#$31415926,(resvalid).w
	move.l	d0,(_cookies).w		;activate new_jar
	rts
	endm	;set_new_jar_code
;
reset_old_jar_code	macro
_cookies_save:		dc.l	0
resvalid_save:		dc.l	0
			dc.l	'XBRA','UnCk'
resvector_save:		dc.l	0
uncookie_reset:
	move.l	_cookies_save(pc),(_cookies).w
	move.l	resvector_save(pc),(resvector).w
	move.l	resvalid_save(pc),(resvalid).w
	jmp	(a6)	;NB:reset routine can not use standard linking
	endm	;reset_old_jar_code
;
;----------------------------------------------------------------------------
	endc	;RA_JAR_defined
;----------------------------------------------------------------------------
;End of file:	RA_JAR.I
;----------------------------------------------------------------------------
