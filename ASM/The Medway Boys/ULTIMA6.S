	opt s-
start	move.l 4(sp),a0
	pea $200
	pea (a0)
	move.w #0,-(sp)
	move.w #$4a,-(sp)
	trap #1
	add.l #12,sp
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,d7
.ok	lea crack(pc),a0
	lea end(pc),a1
	moveq #0,d6
.1	add.l (a0)+,d6
	cmp.l a0,a1
	bne.s .1
	pea text(pc)
	move.w #9,-(sp)
	trap #1
	move.w #7,-(sp)
	trap #1
	addq.l #8,sp
	lea crack(pc),a0
	lea $140.w,a1
	lea text(pc),a2
ll	move.w (a0)+,(a1)+
	cmp.l a0,a2
	bne.s ll
	move.w #1,$4a6.w
	move.l d6,$80.w
	move.l d7,-(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	pea env(pc)
	pea com(pc)
	pea file(pc)
	move.l #$4b0000,-(sp)
	trap #1
	add.l #16,sp
	clr.w -(sp)
	trap #1
env	dc.l 0
com	dc.l 0
file	dc.b 'CYNIX',0
crack	cmp.b #'c',(a3)+
	bne.s .1
	cmp.b #'y',(a3)+
	bne.s .1
	cmp.b #'n',(a3)+
	bne.s .1
	cmp.b #'i',(a3)+
	bne.s .1
	cmp.b #'x',(a3)+
	bne.s .1
	moveq #1,d0
.1	rte
text	dc.b 27,'f',27,'E'
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ Cynix are proud to present you:      +",10,13
	dc.b "+                                      +",10,13
	dc.b "+ ULTIMA VI                            +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ Cracked by The Milky Bar Kid         +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ Once again this was a tricky little  +",10,13
	dc.b "+ protection check to remove....       +",10,13
	dc.b "+ In the first room, when you talk to  +",10,13
	dc.b "+ Lord British and he asks you three   +",10,13
	dc.b "+ questions, always reply: 'cynix'     +",10,13
	dc.b "+ To install this version on your hard +",10,13
	dc.b "+ drive just drag all 4 disks down a   +",10,13
	dc.b "+ folder and double click the file     +",10,13
	dc.b "+ 'Ultima6.prg' to start....           +",10,13
	dc.b "+ Message to lamers: Don't try to pack +",10,13
	dc.b "+ this 'cause you will fuck it up!!!   +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++"
	dc.b 0,0
	even
	dc.l $0ebdf3a88
end	dc.w 0
