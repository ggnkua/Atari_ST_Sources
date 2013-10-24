******************************************************************
*takes a drive\directory(s)\filename and changes it to
*filename only
*pass 	a0 as start of filespec
*	a1 trashed
*return a0 as start of filename only
******************************************************************

preproc		cmp.b	#":",1(a0)
		bne.s	no_drive	;drive in path?
		addq.l	#2,a0
no_drive	move.l	a0,a1
do_parse	cmp.b	#"\",(a1)+
		bne.s	no_slash
		move.l	a1,a0		;save slash start
no_slash	tst.b	(a1)
		bne.s	do_parse	;until zero found
		rts

******************************************************************
*search a block of memory for a filename which may include
*wildcards (*) and any_chars (?). Assumes it is valid and that
*it has been preprocessed by preproc.
* case dependent!
*pass	a0 as start of file to find
*	a1 as start of search area (even boundary)
*	a2 as end of search area   (ditto)
*trash	d0&d1&d2&a0&a1&a2
*return d0 as start position of found name
* 	d0=-1 if error/not found
******************************************************************
do_search	clr.w	d1
		clr.w	d2
main_srch	move.b	(a0,d1.w),d0
		cmp.b	#"a",d0
		blt.s	turkey
		cmp.b	#"z",d0
		bgt.s	turkey
		and.b	#%11011111,d0
turkey		cmp.b	#"?",d0		;is it any char
		bne.s	not_any
		tst.b	(a1,d2.w)
		beq.s	no_match
		cmp.b	#".",(a1,d2.w)
		beq.s	no_match
		bra.s	any_char
not_any		cmp.b	(a1,d2.w),d0	;are they the same
		bne.s	search_next
null_chk	tst.b	d0		;have we finished
		beq.s	all_the_same
any_char	addq.b	#1,d1		;check next char
		addq.b	#1,d2
		bra.s	main_srch
search_next	cmp.b	#"*",d0
		bne.s	no_match	;is it wildcard char
		addq.b	#1,d1
		move.b	(a0,d1.w),d0	;get next char
		cmp.b	#"a",d0
		blt.s	turkey2
		cmp.b	#"z",d0
		bgt.s	turkey2
		and.b	#%11011111,d0
turkey2		tst.b	d0
		beq.s	chk_rest	;end of this name?
chk_next	addq.b	#1,d2
		cmp.b	(a1,d2.w),d0	;found next char yet
		beq.s	null_chk	;yes so end of searching
		cmp.b	#".",(a1,d2.w)	;dot in filename?
		beq.s	null_chk
		tst.b	(a1,d2.w)	;end of check name
		bne.s	chk_next
		bra.s	no_match	;filename not this one
chk_rest	addq.b	#1,d2
		cmp.b	#".",(a1,d2.w)	;found dot?
		beq.s	no_match	;yes then invalid name
		tst.b	(a1,d2.w)
		bne.s	chk_rest	;not eof yet
		bra.s	all_the_same	;match
no_match	lea	22(a1),a1	;next filename to check
		cmp.l	a1,a2		;any more to check
		bgt	do_search	;yes so go again
		move.l	#-1,a1		;no so show error
all_the_same	move.l	a1,d0		;return found or error
		rts
******************************************************************
