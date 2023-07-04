	opt	alink,lattice

* super-optimised version of C routine

* in order for case-insensitive mode to work reliably, the binary trees are sorted as if all chars were upper-case.
* The special case of 2 symbols being identical when upper-case but different in true case is handled by 'proper' sub-sorting

	xdef	_find_sym,_init_find_sym,_upper_case_table
	xref	___ctype

	opt	o+,ow-

	IFNE	0
struct s_sym {
	struct sym *left,*right;
	byte type;
	byte size;				/* determines below */
	union {
		long l; word w; byte b; void *ptr; } v;
	word (*func)(void *);	/* ptr to change fn */
	struct sym *next;		/* singly-linked list of all syms */
	ubyte len;				/* of name */
	char name[1];			/* null termed */
	};

struct remstruct {
	sym **toadd;			/* points to left or right */
	sym *last;				/* points to last one added */
	};

/* find a given symbol in a given table */
/* returns pointer to struct, or NULL if not there */
/* remember can be used to add it subsequently, or can be NULL */
sym *find_sym(sym **global,char *symname, ubyte symlen, struct remstruct *remember,bool casesig)

	ENDC

	rsreset
s_left	rs.l	1
s_right	rs.l	1
s_type	rs.b	1
s_size	rs.b	1
s_stuff	rs.l	1
s_fn	rs.l	1
s_next	rs.l	1
s_len	rs.b	1
s_name	rs.b	1


	IFNE	0
	
UCASE	macro	Dn
	cmp.b	#'a',\1
	bcs.s	.\@nouc
	cmp.b	#'z'+1,\1
	bcc.s	.\@nouc
	and.b	#$df,\1
.\@nouc
	endm

	ELSEIF

UCASE	macro	dn
	IFNC	'\1','d1'
	FAIL	UCASE only guaranteed on d1
	ENDC
	move.b	0(a3,d1.w),d1
	endm
	ENDC

_init_find_sym
	lea	_upper_case_table(a4),a0
	lea	___ctype+1(a4),a1
	moveq	#0,d0
	moveq	#1,d1
.build	move.b	d0,d2
	btst	d1,(a1)+
	beq.s	.lower
	sub.b	#$20,d2
.lower	move.b	d2,(a0)+
	addq.b	#1,d0
	bne.s	.build
	rts
	
REGS	reg	d2/a2/d3/a3

_find_sym	link	a6,#0
	movem.l	REGS,-(sp)
	cargs	#8,.global.l,.symname.l,.symlen.l,.remember.l,.case.l

	moveq	#0,d1			LEAVE BITS 8-15 of d1 ALONE!!
	lea	_upper_case_table(a4),a3

	move.l	.global(a6),a0
	move.l	(a0),d0
	bne.s	.notfirst
* very first symbol
	move.l	.remember(a6),d0
	beq.s	.ret
		move.l	d0,a1
		move.l	a0,(a1)+
		clr.l	(a1)
		bra.s	.ret0
.notfirst
	move.l	.symlen(a6),d2		d2=symlen=unsigned byte

* create upper version of input symbol
	lea	sym_in_upper(a4),a1
	move.l	.symname(a6),a2
.cpsym	move.b	(a2)+,d1
	UCASE	d1
	move.b	d1,(a1)+
	subq.b	#1,d2
	bne.s	.cpsym
	
	move.b	.symlen+3(a6),d2	reload it
	
.scan	move.l	d0,a2			's' in the C version
	cmp.b	s_len(a2),d2
	bcs.s	.goleft
	beq.s	.lensame
.goright
	move.l	s_right(a2),d0
	bne.s	.scan
	move.l	.remember(a6),d0
	beq.s	.ret
		lea	s_right(a2),a0
		bra.s	.goboth
.goleft	move.l	s_left(a2),d0
	bne.s	.scan
	move.l	.remember(a6),d0
	beq.s	.ret
		lea	s_left(a2),a0
.goboth		move.l	d0,a2
		move.l	a0,(a2)+
		move.l	.global(a6),a0		replaces get_last_sym
		move.l	(a0),d0
		beq.s	.gotlast
.getlast	move.l	d0,a0
		move.l	s_next(a0),d0
		bne.s	.getlast
.gotlast	move.l	a0,(a2)
.ret0	moveq	#0,d0
.ret	movem.l	(sp)+,REGS
	unlk	a6
	rts

.diff	bcs.s	.goleft
	bra.s	.goright

* lengths are same - are the chars?
.lensame
	tst.l	d1
	bmi.s	.realcmp			if already matched uppered version

	lea	sym_in_upper(a4),a0
	lea	s_name(a2),a1
	move.b	d2,d0
	
.cmp	move.b	(a1)+,d1
	UCASE	d1
	cmp.b	(a0)+,d1			a0 is pre-upper-cased
	bne.s	.diff
	subq.b	#1,d0
	bne.s	.cmp				try each char
* the upper-cased chars all match, further checks if case sensitive, else found
	tst.b	.case+3(a6)
	beq.s	.gotit				found if case insensitive

	bset	#31,d1				mark as 'already'

* now we do the search using true comparisons
.realcmp
	move.l	.symname(a6),a0
	lea	s_name(a2),a1
	move.b	d2,d0
	
.cmp2	cmp.b	(a0)+,(a1)+
	bne.s	.diff
	subq.b	#1,d0
	bne.s	.cmp2
	
* ahah - found it!
.gotit	move.l	a2,d0
	bra.s	.ret

	SECTION	__MERGED,BSS

sym_in_upper		ds.b	256
_upper_case_table	ds.b	256
