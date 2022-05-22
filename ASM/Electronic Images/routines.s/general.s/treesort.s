; The treesort.

; The following structure defines objects to be sorted
;
; 1. do a clr.l root
;
; 2. just repeated call 'insert' with a1 pointing at structure
;    and d0 the value to be sorted
;
; 3. do a jsr treesort with a4 pointing at the routine to call
;    for each object
;
		rsreset

depth		rs.w	1
lptr		rs.l	1
rptr		rs.l	1
obsize		rs.b	1

;
; the following is an example
;

sort		clr.l	root
;
		lea	ob1(pc),a1
		move.w	#100,d0
		bsr	insert
		lea	ob2(pc),a1
		move.w	#200,d0
		bsr	insert
		lea	ob3(pc),a1
		move.w	#300,d0
		bsr	insert
;
		lea	print(pc),a4
		bsr	treesort
;
; exit
		move.w	#7,-(sp)
		trap	#1
		addq.w	#2,sp
		clr.l	-(sp)
		trap	#1
;
; routine called for each object
;
print		move.w depth(a1),d0
		lea	num(pc),a0
		bsr	numout			;convert to ascii
		pea	num(pc)
		move.w #9,-(sp)
		trap	#1			;dos printstring
		addq.w #6,sp
		rts

ob1		ds.b	obsize
ob2		ds.b	obsize
ob3		ds.b	obsize

num		dc.b	"65535",10,13,0
		even

;--------------------------------------------------------------------------
; procedure:		numout
; description:		convert number to ascii digits
;
; entry:
;	d0.w = number
;	a0.l = address to store number
;
; exit:
;	5 ascii decimal equivalent of unsigned 16 bit number held in d0.l
;
;--------------------------------------------------------------------------

numout		moveq	#'0'-1,d1
.1		addq.b	#1,d1			;count up in ascii
		sub.w	#10000,d0
		bcc.s	.1
		move.b	d1,(a0)+
		add.w	#10000,d0		;remainder
		moveq	#'0'-1,d1
.2		addq.b	#1,d1
		sub.w	#01000,d0
		bcc.s	.2
		move.b	d1,(a0)+
		add.w	#01000,d0		;remainder
		moveq	#'0'-1,d1
.3		addq.b	#1,d1
		sub.w	#00100,d0		;do hundreds
		bcc.s	.3
		move.b	d1,(a0)+
		add.w	#00100,d0
		moveq	#'0'-1,d1
.4		addq.b	#1,d1
		sub.w	#00010,d0		;do tens
		bcc.s	.4
		move.b	d1,(a0)+
		add.w	#00010+'0',d0		;remainder
		move.b	d0,(a0)+
		moveq	#5-1,d0
		moveq	#'0',d1
		lea	-5(a0),a0
.zero		cmp.b	(a0),d1
		bne.s	.izero
		move.b	#'_',(a0)+
		dbra	d0,.zero
.izero		rts

;--------------------------------------------------------------------------
;
; file: 	treesort.s
; programmer:	Russell Payne
; date: 	14th September 1989
; version:	1.0
;
;	depth sorting routine used to implement the
;	'painters' algorithm by drawing distant objects
;	before near objects. entries are inserted into
;	a binary tree structure, which is then in-order
;	traversed to sort the entries.
;	for more information see "data structures and
;	program design" by r.kruse, pages 327-332
;
;--------------------------------------------------------------------------

root		dc.l	0

;--------------------------------------------------------------------------
;
; insert node into the binary tree
;
; d0 = distance away for this object
; a1 = pointer to object structure
; root = pointer to the root of the binary tree
;
;--------------------------------------------------------------------------

insert		move.w	d0,depth(a1)		;this objects depth
		moveq	#0,d1
		move.l	d1,lptr(a1)
		move.l	d1,rptr(a1)		;terminal node
		move.l	root(pc),d1
		beq.s	.empty			;test for empty tree
.nextnode	move.l	d1,a2
		cmp.w	depth(a2),d0
		bgt.s	.try_right
		move.l	lptr(a2),d1		;empty left node?
		bne.s	.nextnode
		move.l	a1,lptr(a2)
		rts
.try_right	move.l	rptr(a2),d1		;empty right node?
		bne.s	.nextnode
		move.l	a1,rptr(a2)
		rts
.empty		lea	root(pc),a2
		move.l	a1,(a2) 		;object is first entry
		rts

;--------------------------------------------------------------------------
;
; treesort
;
; perform an inorder traversal on the binary
; tree constructed by the above procedure
;
; root = pointer to the root of the binary tree
;
;--------------------------------------------------------------------------

treesort	move.l	root(pc),d0
		beq.s	.empty			;empty tree
.goright	move.l	d0,a1
		move.l	a1,-(sp)		;save pointer to this node
		move.l	rptr(a1),d0
		beq.s	.noright
		bsr.s	.goright		;recursive descent
		move.l	(sp),a1
.noright	jsr	(a4)
		move.l	(sp)+,a1		;pointer to current
		move.l	lptr(a1),d0		;node
		bne.s	.goright
.empty		rts


