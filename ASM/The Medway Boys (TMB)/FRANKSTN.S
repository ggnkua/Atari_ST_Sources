	opt s-
	jmp go
main	incbin	l:\main
pic	incbin	l:\pic
pal	incbin	l:\pal
go	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	move.w #0,-(sp)
	pea $78000
	pea $78000
	move.w #5,-(sp)
	trap #14
	add.l #12,sp
	clr.w $ffff8240.w
	move.w #$777,$ffff825e
	pea text(pc)
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	move.w #7,-(sp)
	trap #1
	addq.l #2,sp
	move.w #$2700,sr
	lea $ffff8240.w,a1
	lea pal,a0
	move.w #15,d0
.1	move.w (a0)+,(a1)+
	dbf d0,.1
	lea pic,a0
	lea $78000,a1
	lea pal,a2
.2	move.w (a0)+,(a1)+
	cmp.l a0,a2
	bne.s .2
	lea main,a0
	lea $1000,a1
aa	move.b (a0)+,(a1)+
	cmp.l #go,a0
	blt.s aa
	jmp $1324
text	dc.b 27,'E',27,'f',27,'w'
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ CYNIX bring you:                     +",10,13
	dc.b "+                                      +",10,13
	dc.b "+ FRANKENSTEIN                         +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ Hacked/Packed/Filed by ABSU          +",10,13
	dc.b "+ Original Supplied (BOUGHT!) by ABSU  +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ At last!!! A new title for the ST... +",10,13
	dc.b "+ I was so surprised when I saw this   +",10,13
	dc.b "+ in W.H. Smiths that I immediately    +",10,13
	dc.b "+ had to buy it just to see something  +",10,13
	dc.b "+ new on my ST screen after so long!!  +",10,13
	dc.b "+ Still no sign of Lemmings II, Chaos  +",10,13
	dc.b "+ Engine, Sleepwalker, Civilisation    +",10,13
	dc.b "+ and all those other top titles we've +",10,13
	dc.b "+ been promised for our seemingly      +",10,13
	dc.b "+ obsolete machines.....               +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++"
	even
	dc.w 0
