	clr.l -(sp)
	move.w #32,-(sp)
	trap #1
start	move.w #0,-(sp)
	move.l #$78000,-(sp)
	move.l #$78000,-(sp)
	move.w #5,-(sp)
	trap #14
	move.w #$777,$ff825e
	move.w #0,$ff8240
	pea text
	move.w #9,-(sp)
	trap #1
	move.w #7,-(sp)
	trap #1
	add.l #$14,sp
	move.w #0,d5
	bsr read
	move.b $20000,d0
	cmp.b #$20,d0
	beq side0
	cmp.b #$40,d0
	ble.s next
	cmp.b #$5a,d0
	ble.s side0
next	move.w #1,d5
	bsr read
	move.b $20000,d0
	cmp.b #$20,d0
	beq side1
	cmp.b #$40,d0
	ble.s nex1
	cmp.b #$5a,d0
	ble.s side1
nex1	pea notdata
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp	
	move.w #7,-(sp)
	trap #1
	addq.l #2,sp
	bra start
side0	bsr mod
	move.w #0,d5
	bsr write
	bra end
side1	bsr mod
	move.w #1,d5
	bsr write
	bra end
read	move.w #1,-(sp)
	move.w d5,-(sp)
	move.w #$45,-(sp)
	move.w #1,-(sp)
	clr.w -(sp)
	clr.l -(sp)
	move.l #$20000,-(sp)
	move.w #8,-(sp)
	trap #14
	add.l #$14,sp
	rts
write	move.w #1,-(sp)
	move.w d5,-(sp)
	move.w #$45,-(sp)
	move.w #1,-(sp)
	clr.w -(sp)
	clr.l -(sp)
	move.l #$20000,-(sp)
	move.w #8,-(sp)
	trap #14
	add.l #$14,sp
	rts
mod	pea yorn
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	move.w #7,-(sp)
	trap #1
	addq.l #2,sp
	cmp.b #$79,d0
	beq ret
end	bra end
ret	move.w #$2020,d0
	lea $2000a,a0
	lea $20032,a1
lp	move.w d0,(a0)+
	cmpa.l a0,a1
	bne.s lp
	lea $20036,a0
	lea $2004a,a2
	lea $2005a,a1
	move.w #0,d0
lp2	move.w d0,(a0)+
	move.w d0,(a2)+
	cmpa.l a1,a2
	bne.s lp2
	rts
yorn	dc.b "Press 'Y' to clear hi-score table!",$d,$a
	dc.b "(Score Number 1 remains!!!)",$d,$a,$0
notdata	dc.b "This is not a GIANA SISTERS data disk!",$d,$a,$0
text	dc.b "Insert your GIANA data disk in drive 1.",$d,$a
	dc.b "NOTE:- This program will clear the",$d,$a
	dc.b "score table on the 1 and 2 disk versions",$d,$a
	dc.b "of GIANA SISTERS.",$d,$a
	dc.b "To continue - remove write-protect,",$d,$a
	dc.b "insert your data disk and press any key.",$d,$a
	dc.b $d,$a,$0
	