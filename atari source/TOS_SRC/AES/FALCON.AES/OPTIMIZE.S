*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/optimize.s,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:29:34 $	$Locker: kbad $
* =======================================================================
*  $Log:	optimize.s,v $
* Revision 2.2  89/04/26  18:29:34  mui
* TT
* 
* Revision 2.1  89/02/22  05:31:30  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:36:01  lozben
* Initial revision
* 
*************************************************************************
* --
*
* optimize.s
* 02/02/87	Totally rewritten from optimize.c	Mike Schmal
*
*		Grect - a block of four contiguous words representing a 
*			graphics rectangle x,y,w,h
*
* NOTE	One day we should remove calls to inf_sget and use fs_sget since
*	they are the same function.
*
* UPDATES:
*	02/24/87 Bug in fmt_str now checks for null when skipping extension
*		 '.'.
* Fix bug at unfmt_str	2/23/88		D.Mui
* --
*	Use MAC to assemble		6/28/90		D.Mui
* assemble with MAS 900801 kbad

*
OB_FLAGS	=	$8
OB_STATE	=	$a
OB_SPEC		=	$c
OB_SIZE		=	$18
*
TEDTXTLEN	=	$18
*
PERCENT		=	$25
CAP_L		=	$4c
CAP_W		=	$57
CAP_S		=	$53
DOT		=	$2e
SPACE		=	$20
QUEST		=	$3f
STAR		=	$2a

* --
* external variables
* --
	.globl _gl_wchar
	.globl _gl_hchar
	.globl _r_get

* --
* internal defined routines
* --
	.globl	_r_get
	.globl	_r_set
	.globl _rc_copy
	.globl _rc_equal
	.globl _rc_inter
	.globl _rc_union
	.globl _rc_const
	.globl _movs
	.globl _min
	.globl _max
	.globl _inside
	.globl _strlen
	.globl _strcmp
	.globl _strcpy
	.globl _strscn
	.globl _strchk
	.globl _toupper
	.globl _fmt_str
	.globl _unfmt_st
	.globl _fs_sset
	.globl _inf_sset
	.globl _fs_sget
	.globl _inf_sget
	.globl _inf_fldset
	.globl _inf_gind
	.globl _inf_what
	.globl _merge_st
	.globl _strcat
	.globl _bfill
	.globl _wildcmp
	.globl _scasb
	.globl	_reverse

	.text

_reverse:
 	move.l	d3,-(sp)		; Save d3 since we clobber it
	move.w	8(sp),d3		; d3 = source
	clr.w	d1			; target bit position
	clr.w	d0			; target
	move.w	#15,d2			; source bit position
dobit:
	btst	d2,d3
	beq	nextbit
	bset	d1,d0
nextbit:
	addq	#1,d1			; Update target bit position
	dbra	d2,dobit		; Dbra updates source bit position
	move.l	(sp)+,d3		; Restore d3
	rts

* --
*
* r_get		Routine to set the variables x,y,w,h to the values found
*		in an x,y,w,h block (grect)
*		C binding:	r_get(xywhptr,xptr,yprt,wptr,hptr);
*				int	*xywhptr;
*				int	*xptr,*yptr,*wptr,*hptr;
* --
_r_get:
	movem.l	a3-a4,-(sp)	; save a3,a4
	movem.l	12(sp),a0-a4	; a0 -> grect , a1->x, a2->y, a3->w, a4->h
	move.w	(a0)+,(a1)	; set x from grect
	move.w 	(a0)+,(a2)	; set y
	move.w	(a0)+,(a3)	; set w
	move.w	(a0)+,(a4)	; set h
	movem.l	(sp)+,a3-a4	; restore
	rts

* --
*
* _r_set	Routine to set a x,y,w,h block to the x,y,w,h values passed
*		in.
*		C binding:	r_set(xywhptr,x,y,w,h);
*				int	*xywhptr;
*				int	x,y,w,h;
* --
_r_set:
	movem.l	4(sp),a0-a2	; a0 -> grect, a1 = x and y, a2 = w and h
	movem.l	a1-a2,(a0)	; set x and y and w and h
	rts


* --
*
* rc_copy	Copy src xywh block to dest xywh block.
*		C binding:	r_copy(srcxywh,dstxywh);
*				GRECt	*srcxywh,*dstxywh;
*
* --
_rc_copy:
	movem.l	4(sp),a0-a1	; a0 ->src, a1 ->dest
	move.l	(a0)+,(a1)+	; set x and y
	move.l	(a0)+,(a1)+	; set w and h
	rts


* --
*
* inside	Return true if the x,y position is within the grect
*		C binding:	inside(x,y,ptr1);
*				int	x,y;
*				GRECT	*ptr1;
* --
_inside:
	movem.w	4(sp),d0-d1	; d0 = x, d1 = y
	move.l	8(sp),a0	; a0 -> grect
	cmp.w	(a0),d0		; if (x1 >= x)
	blt	retfalse
	cmp.w	2(a0),d1	; && (y1 >= y)
	blt	retfalse
	move.w	(a0),d2		; d2 = x1
	add.w	4(a0),d2	; d2 = x1 +w1
	cmp.w	d2,d0		; && ( x1+w1 <= x )
	bge	retfalse
	move.w	2(a0),d2	; d2 = y1
	add.w	6(a0),d2	; d2 y2+h2
	cmp.w	d2,d1		; && ( y1+h1 <= y)
	bge	retfalse
	bra	rettrue


* --
*
* rc_equal	Returns true if the two grects are equal.
*		C binding:	rc_equal(ptr1,ptr2);
*				int	*ptr1,ptr2*
* --
_rc_equal:
	movem.l	4(sp),a0-a1	; a0 -> grect 1, a1 -> grect 2
	cmpm.l	(a0)+,(a1)+	; are the x and y equal
	bne	retfalse
	cmpm.l	(a0)+,(a1)+	; are the w and h equal
	bne	retfalse
	bra	rettrue

* --
*
* rc_intersect	Returns the intersection of two rectangles in ptr2.
*		Returns true if there was an intersection where the width
*		is greater than x and the height is greater than y.
*		C binding:	rc_intersect(ptr1,ptr2);
*				GRECT	*ptr1,*ptr2;
*
* --
_rc_inter:
	movem.l	4(sp),a0-a1	; a0 = grect 1, a1 = grect 2
	move.w	(a1),d0		; d0 = x2
	cmp.w	(a0),d0		; If (x1 < x2)
	bge	int1
	move.w	(a0),d0		; d0 = max(x1,x2)
int1:
	move.w	(a0),d1		; d1 = x1
	add.w	4(a0),d1	; d1 = x1 + w1
	move.w	(a1),d2		; d2 = x2
	add.w	4(a1),d2	; d2 = x2 + w2
	cmp.w	d1,d2		; IF (x1+w1 > x2+w2)
	ble	int2
	move.w	d1,d2		; d2 = min(x1+w1,x2+w2)
int2:
	move.w	d0,(a1)		; x2 = max(x1,x2)
	sub.w	d0,d2
	move.w	sr,-(sp)	; save status
	move.w	d2,4(a1)	; w2 = min(x1+w1,x2+w2) - max(x1,x2)
*
	move.w	2(a1),d0	; d0 = y2
	cmp.w	2(a0),d0	; If (y1 < y2)
	bge	int3
	move.w	2(a0),d0	; d0 = max(y1,y2)
int3:
	move.w	2(a0),d1	; d1 = y1
	add.w	6(a0),d1	; d1 = y1 + h1
	move.w	2(a1),d2	; d2 = y2
	add.w	6(a1),d2	; d2 = y2 + h2
	cmp.w	d1,d2		; IF (y1+h1 > y2+h2)
	ble	int4
	move.w	d1,d2		; d2 = min(y1+h1,y2+h2)
int4:
	move.w	d0,2(a1)	; y2 = max(y1,y2)
	sub.w	d0,d2
	move.w	sr,d0		; save status in d0 (ty > th)
	move.w	d2,6(a1)	; h2 = min(y1+h1,y2+h2) - max(y1,y2)
	move.w	(sp)+,ccr	; if (tw > tx)
	ble	retfalse
	move.w	d0,ccr		; && (ty > th)
	ble	retfalse
	bra	rettrue

* --
*
* rc_union	Returns the union of two rectangles in ptr2.
*		C binding:	rc_union(ptr1,ptr2);
*				GRECT	*ptr1,*ptr2;
*
* --
_rc_union:
	movem.l	4(sp),a0-a1	; a0 = ptr block 1, a1 = ptr block 2
	move.w	(a1),d0		; d0 = x2
	cmp.w	(a0),d0		; If (x1 < x2)
	blt	uni1
	move.w	(a0),d0		; d0 = min(x1,x2)
uni1:
	move.w	(a0),d1		; d1 = x1
	add.w	4(a0),d1	; d1 = x1 + w1
	move.w	(a1),d2		; d2 = x2
	add.w	4(a1),d2	; d2 = x2 + w2
	cmp.w	d1,d2		; IF (x1+w1 > x2+w2)
	bgt	uni2
	move.w	d1,d2		; d2 = min(x1+w1,x2+w2)
uni2:
	sub.w	d0,d2
	move.w	d0,(a1)		; x2 = min(x1,x2)
	move.w	d2,4(a1)	; w2 = max(x1+w1,x2+w2) - min(x1,x2)
*
	move.w	2(a1),d0	; d0 = y2
	cmp.w	2(a0),d0	; If (y1 < y2)
	blt	uni3
	move.w	2(a0),d0	; d0 = min(y1,y2)
uni3:
	move.w	2(a0),d1	; d1 = y1
	add.w	6(a0),d1	; d1 = y1 + h1
	move.w	2(a1),d2	; d2 = y2
	add.w	6(a1),d2	; d2 = y2 + h2
	cmp.w	d1,d2		; IF (y1+h1 > y2+h2)
	bgt	uni4
	move.w	d1,d2		; d2 = max(y1+h1,y2+h2)
uni4:
	sub.w	d0,d2
	move.w	d0,2(a1)	; y2 = min(y1,y2)
	move.w	d2,6(a1)	; h2 = max(y1+h1,y2+h2) - min(y1,y2)
	rts


* --
*
* rc_constrain	Routine to constrain a box within another box.  This is done by
*		seting the x,y of the inner box to remain within the
*		constraining box.
*		C binding:	r_constrain(const_ptr,xywhptr);
*				GRECT	*const_ptr,*xywhptr;
* --
_rc_const:
	movem.l	4(sp),a0-a1	; a0 -> x of constrain rect, a1 -> grect
	move.w	(a0),d0		; d0 = const_x
	cmp.w	(a1),d0		; If ( x < const_x )
	blt	clp_right
	move.w	d0,(a1)		; yes set x
clp_right:
	add.w	4(a0),d0	; d0 = const_x+const_w
	move.w	(a1),d1		; d1 = x
	add.w	4(a1),d1	; d1 = x+w
	cmp.w	d1,d0		; If ( x+w < const_x+const_w )
	bge	do_y
	sub.w	4(a1),d0	; d0 = 	const_x+const_w-w
	move.w	d0,(a1)		; set x
do_y:
	move.w	2(a0),d0	; d0 = const_y
	cmp.w	2(a1),d0	; If ( y < const_y )
	blt	clp_bottom
	move.w	d0,2(a1)	; yes set y
clp_bottom:
	add.w	6(a0),d0	; d0 = const_y+const_h
	move.w	2(a1),d1	; d1 = y
	add.w	6(a1),d1	; d1 = y+h
	cmp.w	d1,d0		; If ( y+h < const_y+const_h )
	bge	rc_done
	sub.w	6(a1),d0	; d0 = 	const_y+const_h-h
	move.w	d0,2(a1)	; set y
rc_done:
	rts

* --
*
* movs	move bytes from source to dest for a count of N
*		C binding:	movs(count,src,dst);
*				int	count;
*				byte	*src,*dst;
* --
_movs:
	move.w	4(sp),d0	; count
	movem.l	6(sp),a0-a1	; a0 -> source, a1 -> dest
	bra	stmovs
movnxt:
	move.b (a0)+,(a1)+
stmovs:
	dbra	d0,movnxt
	rts

* --
*
* min	Returns minimum value of two words
*		C binding:	min(a,b);
*				int	a,b;
* --
_min:
	move.w	4(sp),d0	; d0 = a
	cmp.w	6(sp),d0	; if (a < b)
	blt	genret
	bra	minmax

* --
*
* max	Returns maximum value of two words
*		C binding:	max(a,b);
*				int	a,b;
* --
_max:
	move.w	4(sp),d0	; d0 = a
	cmp.w	6(sp),d0	; if (a > b)
	bgt	genret
minmax:
	move.w	6(sp),d0
genret:
	rts			; general rts

* --
*
* bfill		Copy the byte passed in to the dest pointer for a count of N
*		C binding:	bfill(count,byte,dest);
*				int	count;
*				byte	byte;
*				byte	*dest;
* --
_bfill:
	move.w	4(sp),d0	; d0 = count
	move.b	7(sp),d1	; d1 = byte
	move.l	8(sp),a0	; a0 = dest
	bra	bfout
bfnxt:
	move.b	d1,(a0)+
bfout:
	dbra	d0,bfnxt
	rts

* --
*
* toupper	Return upper case value
*		C binding:	toupper(chr);
*				byte	chr;
* --
_toupper:
	move.b	5(sp),d0	; d0 = chr
	ext.w	d0		; extend to word
	cmp.w	#97,d0		; if (chr >= 'a')
	blt	toupout
	cmp.w	#122,d0		; if (chr <= 'z')
	bgt	toupout
	add.w	 #-32,d0	; upper it
toupout:
	rts


* --
*
* strlen	Need I say more
*		C binding:	word	strlen(ptr);
*					byte	*ptr;
* --
_strlen:
	move.l	4(sp),a0	; a0 -> string
	clr.w	d0
strnxt:
	tst.b	(a0)+		; if (end of string)
	beq	genrts
	addq.w	#1,d0		; inc count
	bra	strnxt

* --
*
* strcmp	dito
*		C binding:	word	strcmp(ptr1,ptr2);
*					byte	*ptr1,*ptr2;
* --
_strcmp:
	movem.l 4(sp),a0-a1	; a0 ->string1, a1 ->string2
cmpnxt:
	tst.b	(a0)		; if (we have char)
	beq	cmp1
	cmpm.b (a0)+,(a1)+	; if (they match)
	beq	cmpnxt
	bra	retfalse
cmp1:
	tst.b	(a1)		; if (no char)
	bne	retfalse
	bra	rettrue		; else ret true

* --
*
* strcpy	dito dito
*		C binding:	byte	*strcpy(src,dst);
*					byte	*src,*dst;
* --
_strcpy:
	movem.l	4(sp),a0-a1	; a0 -> src, a1 -> dst
cpynxt:
	move.b	(a0)+,(a1)+	; dst = src
	bne	cpynxt
	bra	catscn

* --
*
* strscn	copy the src to destination untill we are out of characters
*		or we get a char match.
*		C binding:	byte	*strscn(src,dst,stopchar);
*					byte	*src,*dst,stopchar;
*
* --
_strscn:
	movem.l	4(sp),a0-a1	; a0 -> src, a1 -> dst
	move.b	13(sp),d0	; d0 = char
scnxt:
	cmp.b	(a0),d0		; if( (src) != char)
	beq	catscn
	tst.b	(a0)		; && (we have source)
	beq	catscn
	move.b	(a0)+,(a1)+
	bra	scnxt

* --
*
* strcat	dito dito dito
*		C binding:	byte	*strcat(src,dst);
* --
_strcat:
	movem.l	4(sp),a0-a1	; a0 -> src, a1 -> dst
catend:
	tst.b	(a1)+		; if (not at end of dst string)
	bne	catend
	sub.l	#1,a1		; now at end of str
*
catnxt:
	move.b	(a0)+,(a1)+	; dst = scr
	bne	catnxt
catscn:
	move.l	a1,d0		; return dest pointer
	rts

* --
*
* scasb		Returns a byte pointer pointing to the matched byte or
*		the end of the string.
*		C binding:	byte	*scasb(ptr,byte);
*					byte	*ptr,byte;
*
* --
_scasb:
	move.l	4(sp),a1	; a1 -> string
	move.b	9(sp),d0	; d0 = byte
scanxt:
	tst.b	(a1)		; if (end of string)
	beq	catscn
	cmp.b	(a1),d0		; if ((ptr) == byte)
	beq	catscn
	add.l	#1,a1		; next char
	bra	scanxt


* --
*
* strchk	This is the true version of strcmp. Shall we remove the
*		other -we shall see!!!
*		Returns	- <0 if(str1<str2), 0 if(str1=str2), >0 if(str1>str2)
*		C binding:	word	strchk(str1,str2);
*					byte	*str1,*str2;
*
* --
_strchk:
	movem.l	4(sp),a0-a1	; a0 -> string 1, a1 -> string 2
	clr.w	d0		; init to strings equal
chknxt:
	move.b	(a0),d1		; get str1 char
	cmp.b	(a1)+,d1	; if ( strings are not equal )
	bne	chk1
	tst.b	(a0)+		; if ( end of string )
	beq	chkout
	bra	chknxt
chk1:
	move.b	(a0),d0
	ext.w	d0
	move.b	-1(a1),d1	; a1 is ahead by 1 at this point
	ext.w	d1
	sub.w	d1,d0		; return (byte1 - byte2)
chkout:
	rts

* --
*
* fmt_str	Routine to strip out '.' from string and return raw
*		data. Pad with spaces ex. "this.p" to "this    p"
*		C binding:	fmt_str(src,dst);
*					byte	*src,*dst;
* --
_fmt_str:
	movem.l	4(sp),a0-a1	; a0 -> src, a1 -> dst
	move.w	#7,d0		; init for filename
fmtnxt:
	tst.b	(a0)
	beq	padit
	cmp.b	#DOT,(a0)	; char = '.'	
	beq	padit
	move.b (a0)+,(a1)+	; copy char
	dbra	d0,fmtnxt
	bra	extens
padit:
	tst.b	(a0)
	beq	unfout
fmt1:
	move.b #' ',(a1)+	; pad with ' '
	dbra	d0,fmt1
extens:
	tst.b	(a0)+		; inc past '.'
	beq	unfout		; if(null) exit
fmt2:
	tst.b	(a0)
	beq	unfout
	move.b (a0)+,(a1)+	; copy char
	bra	fmt2

* --
*
* unfmt_str	Routine to convert a string of type "mike    xxx" to
*		a dos string of "mike.xxx"
*		C binding:	unfmt_str(src,dst);
*				byte	*src,*dst;
* --
_unfmt_st:
	movem.l	4(sp),a0-a1	; a0 -> src, a1 -> dst
	move.w	#7,d0		; init for filename
unfnxt:
	move.b	(a0)+,d1	; get char
	tst.b	d1	
	beq	unfout		; no more character
	cmp.b	#SPACE,d1	; if (space)
	beq	unfskip
	move.b	d1,(a1)+	; copy char
unfskip:
	dbra	d0,unfnxt
	tst.b	(a0)		; fix the dot
	beq	unfout
	move.b	#DOT,(a1)+	; add '.'
unfext:
	tst.b	(a0)		; If (extension)
	beq	unfout
	move.b	(a0)+,(a1)+
	bra	unfext
unfout:
	clr.b	(a1)		; null terminate dest
	rts


* --
*
* fs_sset	Copy the long in the ob_spec field to the callers variable
*		ptext.  Next copy the string located at the ob_spec long to the
*		callers pstr.  Finally copy the length of the tedinfo string
*		to the callers ptxtlen.
*		C binding:	fs_sset(tree,obj,pstr,ptext,ptxtlen);
*					long	tree,pstr,*ptext;
*					word	obj,*ptxtlen;
* --
_fs_sset:
	move.l	14(sp),a1	; a1 -> ptext
*
	move.l	#OB_SPEC,a0	; a0 = ob_spec offset
	bsr	get_addr
	move.l	(a0),a0		; a0 -> tedinfo block
*
	move.l	(a0),(a1)	; set callers ptext to tedinfo data string
	move.l	a0,-(sp)	; save pointer to tedinfo block
*
	move.l 14(sp),-(sp)	; sp = pstr
	move.l (a0),-(sp)	; sp = tedinfo text data
	jsr _LSTCPY
	addq.l #8,sp
	move.l	(sp)+,a0	; get pointer to tedinfo structure
*
	move.l	18(sp),a1	; ptxtlen
	add.l	#TEDTXTLEN,a0	; now points to tedinfo text length
	move.w	(a0),(a1)	; store it
	rts

* --
*
* inf_sset
*		C binding:	inf_sset(tree,obj,pstr,&text,&txtlen);
*
* --
_inf_sset:
	link	a6,#-8		; room for temp variables
	pea	-6(a6)		; addr of txtlen	(-6)
	pea	-4(a6)		; addr of text		(-4)
	move.l	14(a6),-(sp)	; pstr
	move.w	12(a6),-(sp)	; obj
	move.l	8(a6),-(sp)	; tree
	jsr	_fs_sset
	adda.l	#18,sp
	unlk	a6
	rts

* --
* inf_sget
* fs_sget	This routine copies the tedinfo string to the dst pointer.
*		The function inf_sget was the same as fs_sget.
*		C binding:	inf_sget(tree,obj,dst);
*		C binding:	fs_sget(tree,obj,dst);
*				long	tree,dst;
*				word	obj;
* --
_inf_sget:
_fs_sget:
	move.l	#OB_SPEC,a0	; a0 = offset to ob_spec
	bsr	get_addr
	move.l	(a0),a0		; a0 = ob_spec pointer
*
	move.l	(a0),-(sp)	; sp = addr of tedinfo str
	move.l	14(sp),-(sp)	; sp = destination
	jsr	_LSTCPY
	addq.l	#8,sp
	rts



* --
* f_fldset	This routine is used to set an objects flags based on 
*		the outcome of a 'and' operation.  The word is set to
*		the 'truestate' if the operation is true else set to
*		'falsestate'
*	C binding: inf_fldset(tree,obj,tstfld,tstbit,truestate,falsestate);
*
* --
_inf_fldset:
	move.l	#OB_STATE,a0	; a0 = offset to ob_state
	bsr	get_addr
*
	clr	d0
	move.w	10(sp),d0	; d0 = tstfld
	and.w	12(sp),d0	; d0 = tstfld & tstbit
	beq	false
	move.w	14(sp),(a0)	; set the word to the 'truestate'
	bra	inf1
false:
	move.w	16(sp),(a0)	; set the word to the 'falsestate'
inf1:
	rts


* --
*
* inf_gindex	for each object from baseobj for N objects return the object
*		that is selected or -1 if no objects are selected.
*		C binding:	inf_gindex(tree,baseobj,n);
*					word	baseobj,n;
*					long	tree;
* --
_inf_gind:
	move.l	#OB_STATE+1,a0	; a0 = offset to byte to test
	bsr	get_addr
*
	move.w	10(sp),d0	; d0 = n
	subq.w	#1,d0		; adjust for dbra
	move.w	d0,d1		; d1 = copy of count
nxtstat:
	btst.b	#0,(a0)		; if( OB_STATE & SELECTED)
	beq	gind1
	sub.w	d1,d0		; get object number
	bra	gindout
gind1:
	adda.l	#OB_SIZE,a0	; next object state to test
	dbra	d1,nxtstat
	move.w	d1,d0		; d0 = -1
gindout:
	rts

* --
*
* inf_what	Return	 0 is cancel was selected
*			 1 if ok was selected
*			-1 if nothing is selected
*		If an object was selected then deselect it.
*		C binding:	inf_what(tree,ok,cancel);
*					word	ok,cancel;
*					long	tree;
* --
_inf_what:
	move.w	#2,-(sp)	; sp = 2
	move.w	10(sp),-(sp)	; sp = ok
	move.l	8(sp),-(sp)	; sp = tree
	jsr	_inf_gind	; find selected object
	addq.l	#8,sp
*
	cmp.w	#-1,d0		; if (ret == -1)
	beq	genrts
*
	move.w	d0,d1		; save return value
*
	add.w	d0,8(sp)	; 8(sp) = object# + ret
	move.l	#OB_STATE,a0	; a0 = offset to ob_state
	bsr	get_addr
*
	clr.w	(a0)		; set ob_state to NORMAL
	tst.w	d1
	beq	rettrue
*
* general return true/false exit point
*
retfalse:
	clr.w	d0
	bra	genrts
rettrue:
	move.w	#1,d0		; return 1 if ok is selected
genrts:
	rts



* --
* merge_str
*		C binding:	merge_str(dest,src,parms);
*					byte	*dest,src;
*					uword	parms[];
* --

* PARMS	=	7*4
PARMS	=	28		; fixed 8/1/92

_merge_st:
	movem.l	d3-d6/a3-a5,-(sp)	; save d3,d4,d5,d6,a3,a4,a5
	movem.l	PARMS+4(sp),a3-a5	; a3 -> dest, a4 -> src, a5 -> parms
	clr.w	d3			; d3 = parms[] index
*
mernxt:
	tst.b	(a4)		; if (char = 0) get out
	beq	merout
*
	cmp.b	#'%',(a4)	; if(char == '%')
	beq	do_per
	move.b	(a4)+,(a3)+	; dest = src
	bra	mernxt
*
do_per:
	tst.b	(a4)+		; inc past '%'
	move.b	(a4)+,d0
	cmp.b	#PERCENT,d0	; if (char != '%')
	bne	ltest
	move.b	d0,(a3)+	; dest = '%'
	bra	mernxt
ltest:
	cmp.b	#CAP_L,d0	; if (char != 'L')
	bne	wtest
	move.w	d3,a0		; a0 = num
	add.l	a5,a0		; a0 = &parms[] + num (index)
	move.l	(a0),d4		; d4 = lvalue
	addq.w	#4,d3		; inc num
	bra	dovalue
wtest:
	cmp.b	#CAP_W,d0	; if (char != 'W')
	bne	stest
	clr.l	d4		; d4 = 0
	move.w	d3,a0		; a0 = num
	add.l	a5,a0		; a0 = &parms[] + num (index)
	move.w	(a0),d4		; d4 = lvalue
	addq.w	#4,d3		; inc num
	bra	dovalue
stest:
	cmp.b	#CAP_S,d0	; if (char != 'S')
	bne	mernxt		; else do next character
	move.w	d3,a0		; a0 = num
	add.l	a5,a0		; a0 = &parms[] + num (index)
	move.l	(a0),a0		; a0 = src pointer
	addq.w	#4,d3		; inc num
s1:
	tst.b	(a0)		; If (character)
	beq	mernxt		; do next character
	move.b	(a0)+,(a3)+	; dest = src
	bra	s1
*
dovalue:
	clr.l	d5		; d5 is index
	sub.l	#16,sp		; get room on stack
*
nxtdigit:
	tst.l	d4		; more digits (lvalue)
	beq	nomore
	move.l	#$a,-(sp)
	move.l	d4,-(sp)
	jsr	ldiv
	move.l	d0,d6		; x = d6 = lvalue / 10
	move.l	d0,(sp)
	jsr	lmul
	addq.l #8,sp		; d0 = (x * 10)
	move.l	d4,d2
	sub.l	d0,d2		; d2 = lvalue - (x * 10)
	add	#$30,d2		; d2 = ascii value
	move.b	d2,(sp,d5.w)	; save character
	add.w	#1,d5		; inc index
	move.l	d6,d4		; lvalue = x
	bra	nxtdigit
nomore:
	subq.w	#1,d5		; adjust for dbra
	bge	ascdig
	move.b	#'0',(a3)+	; move digit
	bra	stclean
ascdig:
	move.b	(sp,d5.w),(a3)+	; copy digit
	dbra	d5,ascdig
stclean:
	add.l	#16,sp		; clean up stack
	bra	mernxt
merout:
	clr.b	(a3)		; null terminate string
	movem.l	(sp)+,d3-d6/a3-a5 ; restore d3,d4,d5,d6,a3,a4,a5
	rts

* --
*
* wildcmp
*		C binding:	wildcmp(pwild,ptest);
*					byte	*pwild,*ptest;
* --

_wildcmp:
	movem.l 4(sp),a0-a1	; a0-> pwild, a1 -> ptest
wildnxt:
	tst.b	(a0)		; no pwild source
	beq	wld5
	tst.b	(a1)		; no ptest source
	beq	wld5
	cmp.b	#QUEST,(a0)	; if ( *pwild != '?' )
	bne	wld1
	add.l	#1,a0		; pwild += 1
	cmp.b	#DOT,(a1)	; if ( *ptest != '.')
	beq	wildnxt
inctest:
	add.l	#1,a1		; ptest += 1
	bra	wildnxt
wld1:
	cmp.b	#STAR,(a0)	; if (*pwild != '*')
	bne	wld2
	cmp.b	#DOT,(a1)	; if (*ptest != '.')
	bne	inctest
	add.l	#1,a0		; pwild += 1
	bra	wildnxt
wld2:
	move.b	(a0),d0
	cmp.b	(a1),d0		; if (*pwild == *ptest)
	bne	wldfalse
	add.l	#1,a0		; pwild += 1
	bra	inctest
wld6:
	add.l	#1,a0		; pwild++
wld5:
	cmp.b	#STAR,(a0)	; if (*pwild == '*')
	beq	wld6
	cmp.b	#QUEST,(a0)	; || (*pwild == '?')
	beq	wld6
	cmp.b	#DOT,(a0)	; || (*pwild == '.')
	beq	wld6
*
	tst.b	(a0)		; if (*pwild == char)
	bne	wldfalse
	tst.b	(a1)		; || (*ptest == char)
	bne	wldfalse
	move.w	#1,d0		; return true
	bra	wldout
wldfalse:
	clr.w	d0		; else return false
wldout:
	rts


* --
*
* get_addr	Calculate the objects address given:
*			a0 = object offset
*			12(sp) = object
*			8(sp)  = tree
*--
get_addr:
	move.w	12(sp),d0	; d0 = object
	muls	#OB_SIZE,d0	; d0 = object * ob_size
	add.l	8(sp),a0	; a0 = tree + offset
	add.l	d0,a0		; a0 -> desired word or long
	rts


*	OPTIMIZE.C	1/25/84 - 01/27/85	Lee Jay Lorenzen	*\
*	reg op 68k	2/10/85 - 04/03/85	LKW			*\
*	remove mid,cmps 06/10/85		Mike Schmal		*\
*		bit_num	06/10/85		Mike Schmal		*\
*	Fix the bfill	4/3/86			Derek Mui		*\
*
*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.1
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
**\
*
*#include <portab.h>
*#include <machine.h>
*#include <taddr.h>
*#include <obdefs.h>
*
*
*EXTERN WORD	gl_wchar;
*EXTERN WORD	gl_hchar;
*
*
*r_get(pxywh, px, py, pw, ph)
*	REG WORD	*pxywh;
*	WORD		*px, *py, *pw, *ph;
*{
*	*px = pxywh[0];
*	*py = pxywh[1];
*	*pw = pxywh[2];
*	*ph = pxywh[3];
*}
*
*
*
*r_set(pxywh, x, y, w, h)
*	REG WORD	*pxywh;
*	WORD		x, y, w, h;
*{
*	pxywh[0] = x;
*	pxywh[1] = y;
*	pxywh[2] = w;
*	pxywh[3] = h;
*}
*
*
*rc_constrain(pc, pt)
*	REG GRECT	*pc;
*	REG GRECT	*pt;
*{
*	  if (pt->g_x < pc->g_x)
*	    pt->g_x = pc->g_x;
*	  if (pt->g_y < pc->g_y)
*	    pt->g_y = pc->g_y;
*	  if ((pt->g_x + pt->g_w) > (pc->g_x + pc->g_w))
*	    pt->g_x = (pc->g_x + pc->g_w) - pt->g_w;
*	  if ((pt->g_y + pt->g_h) > (pc->g_y + pc->g_h))
*	    pt->g_y = (pc->g_y + pc->g_h) - pt->g_h;
*}
*
*
*rc_copy(psxywh, pdxywh)
*	REG WORD	*psxywh;
*	REG WORD	*pdxywh;
*{
*	*pdxywh++ = *psxywh++;
*	*pdxywh++ = *psxywh++;
*	*pdxywh++ = *psxywh++;
*	*pdxywh++ = *psxywh++;
*}
*
*
*	VOID
*rc_union(p1, p2)
*	REG GRECT	*p1, *p2;
*{
*	REG WORD	tx, ty, tw, th;
*
*	tw = max(p1->g_x + p1->g_w, p2->g_x + p2->g_w);
*	th = max(p1->g_y + p1->g_h, p2->g_y + p2->g_h);
*	tx = min(p1->g_x, p2->g_x);
*	ty = min(p1->g_y, p2->g_y);
*	p2->g_x = tx;
*	p2->g_y = ty;
*	p2->g_w = tw - tx;
*	p2->g_h = th - ty;
*}
*
*
*	WORD
*rc_intersect(p1, p2)
*	REG GRECT	*p1, *p2;
*{
*	REG WORD	tx, ty, tw, th;
*
*	tw = min(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
*	th = min(p2->g_y + p2->g_h, p1->g_y + p1->g_h);
*	tx = max(p2->g_x, p1->g_x);
*	ty = max(p2->g_y, p1->g_y);
*	p2->g_x = tx;
*	p2->g_y = ty;
*	p2->g_w = tw - tx;
*	p2->g_h = th - ty;
*	return( (tw > tx) && (th > ty) );
*}
*
*
*	UWORD
*inside(x, y, pt)
*	REG WORD	x, y;
*	REG GRECT	*pt;
*{
*	if ( (x >= pt->g_x) && (y >= pt->g_y) &&
*	     (x < pt->g_x + pt->g_w) && (y < pt->g_y + pt->g_h) )
*	  return(TRUE);
*	else
*	  return(FALSE);
*} /* inside *\
*
*
*	WORD
*rc_equal(p1, p2)
*	REG WORD	*p1, *p2;
*{
*	REG WORD	i;
*
*	for(i=0; i<4; i++)
*	{
*	  if (*p1++ != *p2++)
*	    return(FALSE);
*	}
*	return(TRUE);
*}
*
*
*	VOID
*movs(num, ps, pd)
*	REG WORD	num;
*	REG BYTE	*ps, *pd;
*{
*	do
*	  *pd++ = *ps++;
*	while (--num);
*}
*
*
*	WORD
*min(a, b)
*	WORD		a, b;
*{
*	return( (a < b) ? a : b );
*}
*
*
*	WORD
*max(a, b)
*	WORD		a, b;
*{
*	return( (a > b) ? a : b );
*}
*
*
*
*	VOID
*bfill(num, bval, addr)
*	REG WORD	num;
*	REG BYTE	bval;
*	REG BYTE	*addr;
*{
*	while(num)
*	{
*	  *addr++ = bval;
*	  num --;
*	}
*}
*
*
*	BYTE
*toupper(ch)
*	REG BYTE	ch;
*{
*	if ( (ch >= 'a') &&
*	     (ch <= 'z') )
*	  return(ch - 32);
*	else
*	  return(ch);
*}
*
*	BYTE
**scasb(p, b)
*	REG BYTE		*p;
*	REG BYTE		b;
*{
*	for(; *p && *p != b; p++);
*	return (p);
*}
*
*	WORD
*strlen(p1)
*	REG BYTE	*p1;
*{
*	REG WORD	len;
*
*	len = 0;
*	while( *p1++ )
*	  len++;
*
*	return(len);
*}
*
*
*	WORD
*strcmp(p1, p2)
*	REG BYTE	*p1, *p2;
*{
*	while(*p1)
*	{
*	  if (*p1++ != *p2++)
*	    return(FALSE);
*	}
*	if (*p2)
*	  return(FALSE);
*	return(TRUE);
*}
*
*
*\*
**	Return <0 if s<t, 0 if s==t, >0 if s>t
**\
*
*	WORD
*strchk(s, t)
*	REG BYTE	s[], t[];
*{
*	REG WORD	i;
*
*	i = 0;
*	while( s[i] == t[i] )
*	  if (s[i++] == NULL)
*	    return(0);
*	return(s[i] - t[i]);
*}
*
*
*	BYTE
**strcpy(ps, pd)
*	REG BYTE	*ps, *pd;
*{
*	while(*pd++ = *ps++)
*	  ;
*	return(pd);
*}
*
*
*	BYTE
**strscn(ps, pd, stop)
*	REG BYTE	*ps, *pd, stop;
*{
*	while ( (*ps) &&
*		(*ps != stop) )
*	  *pd++ = *ps++;
*	return(pd);
*}
*
*
*	BYTE
**strcat(ps, pd)
*	REG BYTE	*ps, *pd;
*{
*	while(*pd)
*	  pd++;
*	while(*pd++ = *ps++)
*	  ;
*	return(pd);
*}
*
*
*\*
**	Strip out period and turn into raw data.
**\
*	VOID
*fmt_str(instr, outstr)
*	REG BYTE	*instr, *outstr;
*{
*	REG WORD	count;
*	REG BYTE	*pstr;
*
*	pstr = instr;
*	while( (*pstr) && (*pstr != '.') )
*	  *outstr++ = *pstr++;
*	if (*pstr)
*	{
*	  count = 8 - (pstr - instr);
*	  while ( count-- )
*	    *outstr++ = ' ';
*	  pstr++;
*	  while (*pstr)
*	    *outstr++ = *pstr++;
*	}
*	*outstr = NULL;
*}
*
*
*\*
**	Insert in period and make into true data.
**\
*	VOID
*unfmt_str(instr, outstr)
*	REG BYTE	*instr, *outstr;
*{
*	REG BYTE	*pstr, temp;
*
*	pstr = instr;
*	while( (*pstr) && ((pstr - instr) < 8) )
*	{
*	  temp = *pstr++;
*	  if (temp != ' ')
*	    *outstr++ = temp;
*	}
*	if (*pstr)
*	{
*	  *outstr++ = '.';
*	  while (*pstr)
*	    *outstr++ = *pstr++;
*	}
*	*outstr = NULL;
*}
*
*
*	VOID
*fs_sset(tree, obj, pstr, ptext, ptxtlen)
*	LONG		tree;
*	WORD		obj;
*	LONG		pstr;
*	REG LONG	*ptext;
*	WORD		*ptxtlen;
*{
*	REG LONG	spec;
*
*	*ptext = LLGET( spec = LLGET(OB_SPEC(obj)) );
*	LSTCPY(*ptext, pstr);
*	*ptxtlen = LWGET( spec + 24 );
*}
*
*
*	VOID
*inf_sset(tree, obj, pstr)
*	LONG		tree;
*	WORD		obj;
*	BYTE		*pstr;
*{
*	LONG		text;
*	WORD		txtlen;
*
*	fs_sset(tree, obj, ADDR(pstr), &text, &txtlen);
*}
*
*
*	VOID
*fs_sget(tree, obj, pstr)
*	LONG		tree;
*	WORD		obj;
*	LONG		pstr;
*{
*	LONG		ptext;
*
*	ptext = LLGET( LLGET(OB_SPEC(obj)) );
*	LSTCPY(pstr, ptext);
*}
*
*
*	VOID
*inf_sget(tree, obj, pstr)
*	LONG		tree;
*	WORD		obj;
*	BYTE		*pstr;
*{
*	fs_sget(tree, obj, ADDR(pstr));
*}
*
*
*	VOID
*inf_fldset(tree, obj, testfld, testbit, truestate, falsestate)
*	LONG		tree;
*	WORD		obj;
*	UWORD		testfld, testbit;
*	UWORD		truestate, falsestate;
*{
*	LWSET(OB_STATE(obj), (testfld & testbit) ? truestate : falsestate);
*}
*
*
*	WORD
*inf_gindex(tree, baseobj, numobj)
*	LONG		tree;
*	WORD		baseobj;
*	WORD		numobj;
*{
*	WORD		retobj;
*
*	for (retobj=0; retobj < numobj; retobj++)
*	{
*	  if (LWGET(OB_STATE(baseobj+retobj)) & SELECTED)
*	    return(retobj);
*	}
*	return(-1);
*}
*
*
*\*
**	Return 0 if cancel was selected, 1 if okay was selected, -1 if
**	nothing was selected.
**\
*
*	WORD
*inf_what(tree, ok, cncl)
*	REG LONG		tree;
*	REG WORD		ok, cncl;
*{
*	REG WORD		field;
*
*	field = inf_gindex(tree, ok, 2);
*
*	if (field != -1)
*	{
*	  LWSET(OB_STATE(ok + field), NORMAL);
*	  field = (field == 0);
*	}
*	return(field);
*}
*
*
*	WORD
*merge_str(pdst, ptmp, parms)
*	REG BYTE	*pdst;
*	REG BYTE	*ptmp;
*	UWORD		parms[];	
*{
*	REG WORD		num;
*	WORD		do_value;
*	BYTE		lholder[12];
*	REG BYTE		*pnum;
*	BYTE		*psrc;
*	REG LONG		lvalue, divten;
*	WORD		digit;
*
*	num = 0;
*	while(*ptmp)
*	{
*	  if (*ptmp != '%')
*	    *pdst++ = *ptmp++;
*	  else
*	  {
*	    ptmp++;
*	    do_value = FALSE;
*	    switch(*ptmp++)
*	    {
*	      case '%':
*		*pdst++ = '%';
*		break;
*	      case 'L':
*		lvalue = *((LONG *) &parms[num]);
*		num += 2;
*		do_value = TRUE;
*		break;
*	      case 'W':
*		lvalue = parms[num];
*#if MC68K
*		num += 2;
*#endif
*#if I8086
*		num++;
*#endif
*		do_value = TRUE;
*		break;
*	      case 'S':
*		psrc = (BYTE *) parms[num]; 
*#if MC68K
*		num += 2;
*#endif
*#if I8086
*		num++;
*#endif
*		while(*psrc)
*		  *pdst++ = *psrc++;
*		break;
*	    }
*	    if (do_value)
*	    {
*	      pnum = &lholder[0];
*	      while(lvalue)
*	      {
*		divten = lvalue / 10;
*		digit = (WORD) lvalue - (divten * 10);
*		*pnum++ = '0' + digit;
*		lvalue = divten;
*	      }
*	      if (pnum == &lholder[0])
*		*pdst++ = '0';
*	      else
*	      {
*		while(pnum != &lholder[0])
*		  *pdst++ = *--pnum;
*	      }
*	    }
*	  }
*	}
*	*pdst = NULL;
*}
*
*
*	WORD
*wildcmp(pwild, ptest)
*	REG BYTE		*pwild;
*	REG BYTE		*ptest;
*{
*	while( (*ptest) && 
*	       (*pwild) )
*	{
*	  if (*pwild == '?')
*	  {
*	     pwild++;
*	     if (*ptest != '.')
*	       ptest++;
*	  }
*	  else
*	  {
*	    if (*pwild == '*')
*	    {
*	      if (*ptest != '.')
*		ptest++;
*	      else		
*		pwild++;
*	    }
*	    else
*	    {
*	      if (*ptest == *pwild)
*	      {
*	        pwild++;
*	        ptest++;
*	      }
*	      else
*	        return(FALSE);
*	    }
*	  }
*	}
*						/* eat up remaining 	*\
*						/*   wildcard chars	*\
*	while( (*pwild == '*') ||
*	       (*pwild == '?') ||
*	       (*pwild == '.') )
*	  pwild++;
*						/* if any part of wild-	*\
*						/*   card or test is	*\
*						/*   left then no match	*\
*	if ( (*pwild) ||
*	     (*ptest) )
*	  return(FALSE);
*	else
*	  return(TRUE);
*}
