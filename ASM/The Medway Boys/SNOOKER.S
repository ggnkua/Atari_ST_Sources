	opt s-
	jmp go
jim	incbin	g:\jimmy
go	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	clr.w $ffff8240.w
	move.w #$777,$ffff825e
	pea text(pc)
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	move.w #7,-(sp)
	trap #1
	addq.l #2,sp
	move.l #$80000,d0
cc	subq.l #1,d0
	bne.s cc
	move.w #$2700,sr
	lea jim,a0
	lea $685a,a1
aa	move.l (a0)+,(a1)+
	cmp.l #go,a0
	blt.s aa
	jmp $685a
text	dc.b 27,'E',27,'f',27,'w'
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ The BBC/MEDWAY BOYS bring you:       +",10,13
	dc.b "+                                      +",10,13
	dc.b "+ JIMMY WHITE - WHIRLWIND SNOOKER      +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ Cracked/Packed/Filed by ZIPPY        +",10,13
	dc.b "+ Original Supplied by GINO            +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ This game had a nice little password +",10,13
	dc.b "+ protection that was a bit tricky to  +",10,13
	dc.b "+ remove, but if you want to see a     +",10,13
	dc.b "+ really good protection then check    +",10,13
	dc.b "+ out Maupiti Island....  I've been    +",10,13
	dc.b "+ working on it for 3 days and it's    +",10,13
	dc.b "+ still not finished !!                +",10,13
	dc.b "+                                      +",10,13
	dc.b "+ If you want to use this version on   +",10,13
	dc.b "+ a menu, then feel free to do so....  +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++"
	even
	dc.w 0
