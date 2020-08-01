; MACMATHS: maths macro words 25/3/90
; Copyright <C> John Redmond, 1989,1990
; Public domain for non-commercial use.
;	
	section	text
	even
;
; _ADD: (n32,n32--n32)
_add:	pop	d0
	pop	d1
	add.l	d1,d0
	push	d0
	rts
;
; _SUB: (32,n32--n32)
_sub:	pop	d0
	pop	d1
	sub.l	d1,d0
	neg.l	d0
	push	d0
	rts
;
_oneadd: pop	d0
	addq.l	#1,d0
	push	d0
	rts
;
_onesub: pop	d0
	subq.l	#1,d0
	push	d0
	rts
;
_twoadd: pop	d0
	addq.l	#2,d0
	push	d0
	rts
;
_twosub: pop	d0
	subq.l	#2,d0
	push	d0
	rts
;
_fouradd: pop	d0
	addq.l	#4,d0
	push	d0
	rts
;
_foursub: pop	d0
	subq.l	#4,d0
	push	d0
	rts
;
_twomul: pop	d0
	add.l	d0,d0
	push	d0
	rts
;
_twodiv: pop	d0
	asr.l	#1,d0
	push	d0
	rts
;
_movrt: pop	d0
	lsr.l	#1,d0
	push	d0
	rts
;
_lsl:	pop	d0
	pop	d1
	lsl.l	d0,d1
	move.l	d1,d0
	push	d0
	rts
;
_lsr:	pop	d0
	pop	d1
	lsr.l	d0,d1
	move.l	d1,d0
	push	d0
	rts
;
_asr:	pop	d0
	pop	d1
	asr.l	d0,d1
	move.l	d1,d0
	push	d0
	rts
;
_roxl:	pop	d0
	roxl.l	#1,d0
	push	d0
	rts
;
_roxr:	pop	d0
	roxr.l	#1,d0
	push	d0
	rts
;
_flip:	pop	d0
	rol.w	#8,d0
	push	d0
	rts
;
_wflip: pop	d0
	swap	d0
	push	d0
	rts
;
_negate: pop	d0
	neg.l	d0
	push	d0
	rts
;
_xnegate:
	neg.l	4(a6)
	negx.l	(a6)
	rts
;
_ore:	pop	d0
	pop	d1
	or.l	d1,d0
	push	d0
	rts
;
_xore:	pop	d0
	pop	d1
	eor.l	d1,d0
	push	d0
	rts
;
_ande:	pop	d0
	pop	d1
	and.l	d1,d0
	push	d0
	rts
;
_note:	pop	d0
	not.l	d0
	push	d0
	rts
;
_equal: pop	d0
	pop	d1
	cmp.l	d1,d0
	seq	d0
	ext.w	d0
	ext.l	d0
	push	d0
	rts
;
_zeroeq: pop	d0
	tst.l	d0
	seq	d0
	ext.w	d0
	ext.l	d0
	push	d0
	rts
;
_zerolt: pop	d0
	tst.l	d0
	smi	d0
	ext.w	d0
	ext.l	d0
	push	d0
	rts
;
_zerogt: pop	d0
	tst.l	d0
	sgt	d0
	ext.w	d0
	ext.l	d0
	push	d0
	rts
;
_ult:	pop	d0
	pop	d1
	cmp.l	d1,d0
	shi	d0
	ext.w	d0
	ext.l	d0
	push	d0
	rts
;
_lt:	pop	d0
	pop	d1
	cmp.l	d1,d0
	sgt	d0
	ext.w	d0
	ext.l	d0
	push	d0
	rts
;
_gt:	pop	d0
	pop	d1
	cmp.l	d1,d0
	slt	d0
	ext.w	d0
	ext.l	d0
	push	d0
	rts
;
; fetch and store group:
;
_at:	pop	a0
	move.l	(a0),d0
	push	d0
	rts
;
_wat:	pop	a0
	moveq.l	#0,d0
	move.w	(a0),d0
	push	d0
	rts
;
_cat:	pop	a0
	moveq.l	#0,d0
	move.b	(a0),d0
	push	d0
	rts
;
_store: pop	a0
	pop	d0
	move.l	d0,(a0)
	rts
;
_wstore: pop	a0
	pop	d0
	move.w	d0,(a0)
	rts
;
_cstore: pop	a0
	pop	d0
	move.b	d0,(a0)
	rts
;
_dup:	pop	d0
	push	d0
	push	d0
	rts
;
_ifdup: move.l	(a6),d0
	beq.s	.ifdx
	push	d0
.ifdx:	rts
;
_drop:	pop	d0
	rts
;
_swap:	pop	d0
	pop	d1
	exg	d0,d1
	push	d1
	push	d0
	rts
;
_over:	move.l	4(a6),d0
	push	d0
	rts
;
_nip:	pop	d0
	move.l	d0,(a6)
	rts
;
_spat:	push	a6
	rts
;
_rpat:	push	a7
	rts
;
_rgt:	bsr	_ifcomp
	push	#$2d1f		;push (a7)+
	bsr	_comma
	bsr	plusedge
	rts
;
_gtr:	bsr	_ifcomp
	push	#$2f1e		;pop -(a7)
	bsr	_comma
	bsr	edgeoff
	rts
;
;
_rat:	bsr	_ifcomp
	push	#$2d17		;push (a7)
	bsr	_comma
	bsr	plusedge
	rts
;
_offsetadd:
	pop	d0
	add.l	a5,d0
	push	d0
	rts
;
_offsetsub:
	pop	d0
	sub.l	a5,d0
	push	d0
	rts
;
_count: pop	a0
	clr.l	d0
	move.b	(a0)+,d0
	push	a0
	push	d0
	rts
;
_dtwomul: pop	d0
	pop	d1
	lsl.l	#1,d1
	roxl.l	#1,d0
	push	d1
	push	d0
	rts
;
_dtwodiv: pop	d0
	pop	d1
	lsr.l	#1,d0
	roxr.l	#1,d1
	push	d1
	push	d0
	rts
;
	section	data
	even
;
; bit manipulation words
;
	dc.b	$83,'LS','L'!$80
	mptrs	_lsl,d0,5,two_one,16
;
	dc.b	$83,'LS','R'!$80
	mptrs	_lsr,d0,5,two_one,16
;
	dc.b	$83,'AS','R'!$80
	mptrs	_asr,d0,5,two_one,16
;
	dc.b	$83,'RO','L'!$80
	mptrs	_roxl,d0,3,one_one,16
;
	dc.b	$83,'RO','R'!$80
	mptrs	_roxr,d0,3,one_one,16
;
	dc.b	$84,'FLIP',$a0
	mptrs	_flip,d0,3,one_one,18
;
	dc.b	$85,'WFLI','P'!$80
	mptrs	_wflip,d0,3,one_one,18
;
	dc.b	$82,'OR',$a0
	mptrs	_ore,d0,4,two_one,16
;
	dc.b	$83,'XO','R'!$80
	mptrs	_xore,d0,4,two_one,16
;
	dc.b	$83,'AN','D'!$80
	mptrs	_ande,d0,4,two_one,16
;
; quick arithmetic words
;
	dc.b	$82,'1+',$a0
	mptrs	_oneadd,d0,3,one_one,16
;
	dc.b	$82,'1-',$a0
	mptrs	_onesub,d0,3,one_one,16
;
	dc.b	$82,'2+',$a0
	mptrs	_twoadd,d0,3,one_one,16
;
	dc.b	$82,'2-',$a0
	mptrs	_twosub,d0,3,one_one,16
;
	dc.b	$82,'4+',$a0
	mptrs	_fouradd,d0,3,one_one,16
;
	dc.b	$82,'4-',$a0
	mptrs	_foursub,d0,3,one_one,16
;
	dc.b	$85,'CELL','+'!$80
	mptrs	_fouradd,d0,3,one_one,18
;
	dc.b	$85,'CELL','-'!$80
	mptrs	_foursub,d0,3,one_one,18
;
	dc.b	$82,'2*',$a0
	mptrs	_twomul,d0,3,one_one,16
;
	dc.b	$82,'2/',$a0
	mptrs	_twodiv,d0,3,one_one,16
;
	dc.b	$83,'U2','/'!$80
	mptrs	_movrt,d0,3,one_one,16
;
	dc.b	$83,'D2','*'!$80
	mptrs	_dtwomul,d0,6,two_two,16
;
	dc.b	$83,'D2','/'!$80
	mptrs	_dtwodiv,d0,6,two_two,16
;
; logic test words
;
	dc.b	$82,'U<',$a0
	mptrs	_ult,d0,7,two_result,16
;
	dc.b	$81,'>'!$80
	mptrs	_gt,d0,7,two_result,14
;
	dc.b	$81,'<'!$80
	mptrs	_lt,d0,7,two_result,14
;
	dc.b	$81,'='!$80
	mptrs	_equal,d0,7,two_result,14
;
;	dc.b	$83,'NO','T'!$80
;	mptrs	_note,d0,3,one_one,16
;
	dc.b	$82,'0=',$a0
	mptrs	_zeroeq,d0,6,one_result,16
;
	dc.b	$82,'0<',$a0
	mptrs	_zerolt,d0,6,one_result,16
;
	dc.b	$82,'0>',$a0
	mptrs	_zerogt,d0,6,one_result,16
;
; integer maths words
;
;	dc.b	$86,'NEGATE',$A0
;	mptrs	_negate,d0,3,one_one,20
;
;	dc.b	$81,'+'!$80
;	mptrs	_add,d0,4,two_one,14
;
	dc.b	$82,'+!',$a0
	mptrs	_laddat,a0,3,two_none,16
;
;	dc.b	$81,'-'!$80
;	mptrs	_sub,d0,5,two_one,14
;
; smart optimising words
;
	dc.b	$c2,'C@',$A0
	fetch	_cat,a0,4,one_one,16
;
	dc.b	$c2,'W@',$a0
	fetch	_wat,a0,4,one_one,16
;
	dc.b	$c1,'@'!$80
	fetch	_at,a0,3,one_one,14
;
	dc.b	$c2,'C!',$A0
	store	_cstore,a0,3,one_none,16
;
	dc.b	$c2,'W!',$a0
	store	_wstore,a0,3,one_none,16
;
	dc.b	$c1,'!'!$80
	store	_store,a0,3,one_none,14
;
	dc.b	$c3,'NO','T'!$80
	invert	_note,d0,3,one_one,16
;
; memory and stack words
;
	dc.b	$82,'ON',$a0
	mptrs	_on,a0,4,one_none,16
;
	dc.b	$83,'OF','F'!$80
	mptrs	_off,a0,2,one_none,16
;
	dc.b	$84,'DROP',$a0
	mptrs	_drop,d0,1,one_one,18
;
	dc.b	$83,'DU','P'!$80
	mptrs	_dup,d0,3,one_two,16
;
	dc.b	$84,'?DUP',$a0
	mptrs	_ifdup,noedge,3,one_one,18
;
	dc.b	$84,'OVER',$a0
	mptrs	_over,noedge,3,none_one,18
;
	dc.b	$84,'SWAP',$A0
	mptrs	_swap,d0,5,two_two,18
;
	dc.b	$83,'NI','P'!$80
	mptrs	_nip,d0,2,one_none,16
;
	dc.b	$85,'2DRO','P'!$80
	mptrs	_twodrop,noedge,1,none_none,18
;
	dc.b	$83,'SP','@'!$80
	mptrs	_spat,a6,1,$24,16
;
	dc.b	$83,'RP','@'!$80
	mptrs	_rpat,noedge,1,$24,16
;
	dc.b	$83,'OS','>'!$80
	mptrs	_offsetadd,d0,3,one_one,16
;
	dc.b	$83,'>O','S'!$80
	mptrs	_offsetsub,d0,3,one_one,16
;
	dc.b	$85,'COUN','T'!$80
	mptrs	_count,a0,5,one_two,18
;
