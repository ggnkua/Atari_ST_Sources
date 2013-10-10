	opt s-
start	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,d7
	moveq #0,d0
	lea text(pc),a0
	lea endt(pc),a1
.0	add.w (a0)+,d0
	rol.l #3,d0
	cmp.l a0,a1
	bne.s .0
	cmp.l #$7de37d06,d0
	beq.s ok
	move.l $4.w,a0
	jmp (a0)
ok	pea text(pc)
	move.w #9,-(sp)
	trap #1
	lea 6(sp),sp
	move.w #7,-(sp)
	trap #1
	lea 2(sp),sp
	lea crack(pc),a0
	lea $140.w,a1
	move.l a1,$bc.w
	lea text(pc),a2
.1	move.w (a0)+,(a1)+
	cmp.l a0,a2
	bne.s .1
	move.l d7,-(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	clr.w -(sp)
	trap #1
crack	addq.l #2,d0
	cmp.b #$1a,-4(a6)
	bne.s end
	cmp.b #$1e,-2(a6)
	bne.s end
	move.b #$1e,-4(a6)
	move.l a0,-(sp)
	move.l 6(sp),a0
	move.w #$5480,-2(a0)
	move.l (sp)+,a0
end	rte
text	dc.b 27,'E',27,'f',27,'w'
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ CYNIX bring you:                     +",10,13
	dc.b "+                                      +",10,13
	dc.b "+ WEEN (English Version)               +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ Cracked by THE MILKY BAR KID         +",10,13
	dc.b "+ Original Supplied by QUASER          +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ This was yet another game written in +",10,13
	dc.b "+ one of those shitty interpreted high +",10,13
	dc.b "+ level languages!!                    +",10,13
	dc.b "+ It's been so long so I've removed    +",10,13
	dc.b "+ a protection of this type that I had +",10,13
	dc.b "+ to develop a few more routines for   +",10,13
	dc.b "+ tracing this little one....          +",10,13
	dc.b "+ Anyway, it's done now so just select +",10,13
	dc.b "+ ANY colour at the passcode screen!!  +",10,13
	dc.b "+ Press any key to load the game.....  +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++"
	even
endt	dc.w 0
