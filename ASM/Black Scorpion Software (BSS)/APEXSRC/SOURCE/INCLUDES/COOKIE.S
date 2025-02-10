*--------------------------------------------------------------------------*
*	0 all		= ignore value just malloc -1's worth.
*	1 limit	= only malloc "size" worth of memory.
*	2 leave	= leave "size" worth of memory alone..
*--------------------------------------------------------------------------*
* Get CPX memory information..
* 
* Returns correct values even if buffers not found.
*
* Returns..
*	d0.w = ST RAM type.		d1.l = ST RAM size.
*	d2.w = TT RAM type.		d3.l = TT RAM size.
*--------------------------------------------------------------------------*

		rsreset
grab_all	rs.b		1
grab_max	rs.b		1
grab_minus	rs.b		1

ReadCookie:	move.l	#"APEX",d0
		move.l	$5A0.w,a0	; cookie jar pointer.
.findcook:	cmp.l		(a0),d0
		beq.s		.foundcook
		tst.l		(a0)
		beq.s		.fail		; no cookie entry.
		addq.l	#8,a0
		bra.s		.findcook
.foundcook:	move.l	4(a0),a0
		tst.w		(a0)+		; initialized structure with cpx vals.
		beq.s		.fail		; nope so fail.. ( this is a paranoid messure but do leave it in! )
		lea		12(a0),a1	; get to magix to test if corrupt!
		cmp.l		#"Apex",(a1)+
		bne.s		.fail
		cmp.l		#" mem",(a1)+
		bne.s		.fail
		cmp.l		#"ory!",(a1)+
		bne.s		.fail
		moveq		#0,d0
		move.w	(a0)+,d0	; mode of ST ram.
		move.l	(a0)+,d1	; memory value of ST ram.
		moveq		#0,d2
		move.w	(a0)+,d2	; mode of TT ram.
		move.l	(a0)+,d3	; memory value of TT ram.
		bra.s		.end
.fail:	moveq		#0,d0		; malloc all ST ram
		moveq		#0,d1
		moveq		#0,d2		; malloc all TT ram
		moveq		#0,d3
.end:		move.w	d0,d4
		or.w		d2,d4
		bne.s		.ok
		moveq		#grab_minus,d0
		moveq		#16,d1
.ok		move.w	d0,stram_code
		move.w	d2,vram_code
		mulu		#1024,d1
		mulu		#1024,d3
		move.l	d1,stram_value
		move.l	d3,vram_value
		rts
		
stram_code:	ds.w		1
vram_code:	ds.w		1
stram_value:ds.l		1
vram_value:	ds.l		1
stram_free:	ds.l		1
vram_free:	ds.l		1
menuspace:	ds.l		1
