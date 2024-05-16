unpackxp4:
; In: a0 - address to xp1 data
;     a1 - address to unpack to
	movem.l d0-d2,-(sp)
	move.l (a0)+,d0
	cmp.l #"xp4!",d0
	bne .exitungracefully
.handleonepacket:
	move.l (a0)+,d0
	cmp.l #"end!",d0
	beq .exit
	sub.l #4,a0
	move.w (a0)+,d0
	cmp.w #$fffe,d0
	beq .datablock
	cmp.w #$fffd,d0
	beq .repeatblock
.emptyblock:
	move.l #0,d0
	move.w (a0)+,d0
	add.l d0,a1
	bra .nextpacket
.repeatblock:
	move.l #0,d0
	move.w (a0)+,d0
	move.l (a0)+,d1
	move.l (a0)+,d2
.repeatloop:
	move.l d1,(a1)+
	move.l d2,(a1)+
	dbra d0,.repeatloop
	bra .nextpacket
.datablock:
	move.l #0,d0
	move.w (a0)+,d0
.iterate:
	cmp.l #80,d0
	blt .dataloop
	rept 80
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	endr
	sub.l #80,d0
	bra .iterate
.dataloop:
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	dbra d0,.dataloop
.nextpacket:
	bra .handleonepacket
.exit:
	movem.l (sp)+,d0-d2
	rts
.exitungracefully:
	move.w #$0f00,currentpalette
	move.w #$0f00,$ffff8240
	bra .exit

	rept 0
unpackxp4:
; In: a0 - address to xp1 data
;     a1 - address to unpack to
	movem.l d0-d2,-(sp)
	move.l (a0)+,d0
	cmp.l #"xp4!",d0
	bne .exitungracefully
.handleonepacket:
	move.l (a0)+,d0
	cmp.l #"end!",d0
	beq .exit
	sub.l #4,a0
	move.w (a0)+,d0
	cmp.w #$fffe,d0
	beq .datablock
	cmp.w #$fffd,d0
	beq .repeatblock
.emptyblock:
	move.l #0,d0
	move.w (a0)+,d0
	add.l d0,a1
	bra .nextpacket
.repeatblock:
	move.l #0,d0
	move.w (a0)+,d0
	move.l (a0)+,d1
	move.l (a0)+,d2
.repeatloop:
	move.l d1,(a1)+
	move.l d2,(a1)+
	dbra d0,.repeatloop
	bra .nextpacket
.datablock:
	move.l #0,d0
	move.w (a0)+,d0
.dataloop:
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	dbra d0,.dataloop
.nextpacket:
	bra .handleonepacket
.exit:
	movem.l (sp)+,d0-d2
	rts
.exitungracefully:
	move.w #$0f00,currentpalette
	move.w #$0f00,$ffff8240
	bra .exit
	endr
