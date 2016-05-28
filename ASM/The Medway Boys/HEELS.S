	opt s-
	jmp go
jim	incbin	g:\heels.prg
go	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,$8.w
	clr.w $ffff8240.w
	move.w #$777,$ffff825e
	pea text(pc)
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	move.w #7,-(sp)
	trap #1
	addq.l #2,sp
	lea jim,a0
	move.l a0,a1
	sub.l #$22,a1
cc	move.l (a0)+,(a1)+
	cmp.l #go,a0
	blt.s cc
	move.l $8.w,-(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	jmp jim-$22
text	dc.b 27,'E',27,'f',27,'w'
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ The MEDWAY BOYS bring you:           +",10,13
	dc.b "+                                      +",10,13
	dc.b "+ HEAD OVER HEELS                      +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ Cracked and Packed by ZIPPY          +",10,13
	dc.b "+ Original Supplied by GINO            +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ This will probably be my last ever   +",10,13
	dc.b "+ work on the ST !!!!                  +",10,13
	dc.b "+ First Vapour, now Zippy leave the ST +",10,13
	dc.b "+ scene. I think R.AL is probably the  +",10,13
	dc.b "+ best hacker left out there now.....  +",10,13
	dc.b "+ so look to him for the best work !!  +",10,13
	dc.b "+ Sorry I had to finish on such a crap +",10,13
	dc.b "+ game, but I don't think there will   +",10,13
	dc.b "+ be anything decent out before I have +",10,13
	dc.b "+ to start my new job on Monday !!     +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++"
	even
	dc.w 0
