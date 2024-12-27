	opt s-
	jmp go
f1	incbin g:\protec.pak
f2	incbin g:\pic.pak
f3	incbin g:\main
go	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	clr.w $ffff8240.w
	move.w #$777,$ffff825e
	pea text
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
	move.l #$4e714e71,(f3+$30)
	move.w #$4e75,(f3+$2a76)
	move.w #$4e75,(f3+$2cf2)
	lea hand,a0
	lea (f3+$2b12),a1
ac	move.w (a0)+,(a1)+
	cmp.l #text,a0
	blt.s ac
	lea f3,a0
	lea $40000,a1
aa	move.l (a0)+,(a1)+
	cmp.l #go,a0
	blt.s aa
	jmp $40004
hand	lea f2,a0
	lea f3,a2
	cmp.l #$70000,a1
	beq.s fok
	lea f1,a0
	lea go,a2
fok	move.w (a0)+,(a1)+
	cmp.l a2,a0
	blt.s fok
	rts
text	dc.b 27,'E',27,'f',27,'w'
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ The MEDWAY BOYS bring you:           +",10,13
	dc.b "+                                      +",10,13
	dc.b "+ MEAN MACHINE                         +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ Cracked/Single Parted by ZIPPY       +",10,13
	dc.b "+ Original Supplied by GINO            +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ Enjoy playing this nice little game  +",10,13
	dc.b "+ and always remember to give your     +",10,13
	dc.b "+ support to Greenpeace and any other  +",10,13
	dc.b "+ pro-environment organisation !!!!    +",10,13
	dc.b "+ (Just think about it !)              +",10,13
	dc.b "+                                      +",10,13
	dc.b "+ Hi to all friends and contacts.....  +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++"
	even
	dc.w 0
