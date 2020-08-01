; MEMORY.S: utility routines.
; <C> John Redmond 1989
;  Public domain for non-commercial use.
;
	section	text
	even
;
_fill:
	movem.l (a6)+,d0/d1/a0		;address,length,char 
	tst.l	d1			;length zero? 
	beq	.cfx 
.cflp:	move.b	d0,(a0)+		;store char 
	subq.l	#1,d1
	bne	.cflp
.cfx:	rts 
; 
_cmove: movem.l (a6)+,d0/a0/a1		;source,dest,length
	tst.l	d0			;zero length? 
	beq	.cmx 
.cmlp:	move.b	(a1)+,(a0)+ 
	subq.l	#1,d0
	bne	.cmlp
.cmx:	rts 
; 
_cmovegt:
	movem.l (a6)+,d0/a0/a1		;source,dest,length 
	tst.l	d0			;zero length? 
	beq	.cmx 
	adda.l	d0,a0
	adda.l	d0,a1
.cmlp:	move.b	-(a1),-(a0)
	subq.l	#1,d0
	bne	.cmlp
.cmx:	rts 
; 
_rot:	move.l	d2,-(a7)
	pop	d0
	pop	d1
	pop	d2
	push	d1
	push	d0
	push	d2
	move.l	(a7)+,d2
	rts
;
_pick:	pop	d0
	bmi	.px
	asl.l	#2,d0
	move.l	0(a6,d0.l),d0
	push	d0
.px:	rts
;
_twodup: move.l (a6),d1
	move.l	4(a6),d0
	push	d0
	push	d1
	rts
;
_twoover: move.l 8(a6),d1
	move.l	12(a6),d0
	push	d0
	push	d1
	rts
;
_twoswap: movem.l d2-d3,-(a7)
	movem.l (a6)+,d0-d3
	movem.l d0-d1,-(a6)
	push	d3
	push	d2
	movem.l (a7)+,d2-d3
	rts
;
_tworot: movem.l d2-d5,-(a7)
	movem.l (a6)+,d0-d5
	movem.l d0-d3,-(a6)
	push	d1
	move.l	d0,d1
	push	d1
	movem.l (a7)+,d2-d5
	rts
;
_twodrop: addq.l #8,a6
	rts
;
_depth: lea	dstack,a0
	move.l	(a0),d0
	sub.l	a6,d0
	asr.l	#2,d0
	push	d0
	rts
;
_minusrot: movem.l d1-d2,-(a7)
	movem.l (a6)+,d0-d2
	push	d0
	push	d2
	push	d1
	movem.l (a7)+,d1-d2
	rts
;
_tuck:	pop	d0
	pop	d1
	push	d0
	push	d1
	push	d0
	rts
;
_spstore: pop	a6
	rts
;
_rpstore: pop	a7
	rts
;
_on:	pop	a0
	move.l	#-1,(a0)
	rts
;
_off:	pop	a0
	clr.l	(a0)
	rts
;
_pad:	bsr	_here
	add.l	#$100,(a6)
	rts
;
_notrailing:
	movem.l (a6)+,d0/a0 
.trlp:	subq.l	#1,d0
	bmi	.empty
	move.b	(a0,d0.l),d1
	cmp.b	#32,d1		;a blank?
	bne	.end
	bra	.trlp
.end:	addq.l	#1,d0		;adjust length
	movem.l d0/a0,-(a6)	;^string & trimmed length
	rts
.empty: clr.l	d0
	movem.l d0/a0,-(a6)
	rts
;
_comp:	pop	d0		;length
	moveq	#0,d1		;result
	pop	a0
	pop	a1
	tst.l	d0
	beq	.cx
	subq.l	#1,d0
.clp:	cmpm.b	(a0)+,(a1)+
	dbne	d0,.clp
	beq	.cx
	bcs	.cw
	moveq	#1,d1
	bra	.cx
.cw	moveq	#-1,d1
.cx	push	d1
	rts
;
	section	data
	even
;
; string and block words
;
	dc.b	$84,'FILL',$a0
	ptrs	_fill,18
;
	dc.b	$84,'TYPE',$a0
	ptrs	_type,18
;
	dc.b	$85,'CMOV','E'!$80
	ptrs	_cmove,18
;
	dc.b	$86,'CMOVE>',$a0
	ptrs	_cmovegt,20
;
	dc.b	$89,'-TRAILIN','G'!$80
	ptrs	_notrailing,22
;
	dc.b	$84,'COMP',$a0
	ptrs	_comp,18
;
	dc.b	$83,'RO','T'!$80
	ptrs	_rot,16
;
	dc.b	$84,'-ROT',$a0
	ptrs	_minusrot,18
;
	dc.b	$84,'PICK',$a0
	ptrs	_pick,18
;
	dc.b	$84,'TUCK',$a0
	ptrs	_tuck,18
;
	dc.b	$84,'2DUP',$a0
	ptrs	_twodup,18
;
	dc.b	$85,'2OVE','R'!$80
	ptrs	_twoover,18
;
	dc.b	$85,'2SWA','P'!80
	ptrs	_twoswap,18
;
	dc.b	$84,'2ROT',$a0
	ptrs	_tworot,18
;
	dc.b	$85,'DEPT','H'!$80
	ptrs	_depth,18
;
	dc.b	$83,'PA','D'!$80
	ptrs	_pad,16
