	opt s-
start	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	lea $80000,sp
	lea $ffff8240.w,a0
	moveq #7,d0
clla	clr.l (a0)+
	dbf d0,clla
	eor.b #3,$484.w
	moveq #1,d0
	bsr music
	move.l #int,$70.w
	lea text(pc),a0
	bsr print
	bsr fadeup
	bsr getkey
	bsr fadedn
	bsr checkbot
	bsr checkmeg
	lea text5(pc),a0
	bsr print
	lea lev1(pc),a0
	bsr print
	bsr fadeup
gk	bsr getkey
	cmp.b #' ',d0
	beq goo
	cmp.b #'+',d0
	bne notpl
	cmp.w #16,levnum
	bge gk
	addq.w #1,levnum
	bra dislev
notpl	cmp.b #'-',d0
	bne gk
	cmp.w #0,levnum
	ble gk
	subq.w #1,levnum
dislev	lea lev0(pc),a0
	bsr print
	moveq #0,d0
	move.w levnum,d0
	lea lev1(pc),a0
	mulu #28,d0
	lea $0(a0,d0.l),a0
	bsr print
	bra gk
goo	bsr fadedn
	moveq #0,d0
	move.w levnum,d0
	mulu #28,d0
	add.l #(lev1+24),d0
	move.l d0,a0
	move.l (a0),d0
	tst.l d0
	beq notr
	move.w #$4ef9,(main+$3d6)
	move.l d0,(main+$3d8)
notr	lea main(pc),a0
	lea $7d0a8,a1
ab	move.l (a0)+,(a1)+
	cmp.l #music,a0
	blt ab
	move.l #ex,$70.w
	move.l #$08080000,$ffff8800.w
	move.l #$09090000,$ffff8800.w
	move.l #$0a0a0000,$ffff8800.w
	jmp $7d0a8

fadeup	move.w #6,d0
ful	move.w #$1234,d2
	move.w #$2000,d1
paa	mulu d1,d2
	dbf d1,paa
	add.w #$111,$ffff825e.w
	dbf d0,ful
	rts

fadedn	move.w #6,d0
ful1	move.w #$1234,d2
	move.w #$2000,d1
paa1	mulu d1,d2
	dbf d1,paa1
	sub.w #$111,$ffff825e.w
	dbf d0,ful1
	rts

getkey	move.w #7,-(sp)
	trap #1
	addq.l #2,sp
	rts

print	pea (a0)
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	rts

checkbot	lea text3(pc),a0
		bsr print
		cmp.w #2,$4a6.w
		blt nodr
		move.w #10,-(sp)
		move.w #1,-(sp)
		move.w #0,-(sp)
 		move.w #1,-(sp)
		move.w #1,-(sp)
		clr.l -(sp)
		pea $60000
		move.w #8,-(sp)
		trap #14
		add.l #20,sp
		tst.l d0
		bmi nodr
		move.w #$606,(main+$16)
		lea text2(pc),a0
		bra print
nodr		lea text1(pc),a0
		bra print

checkmeg	lea text4(pc),a0
		bsr print
		bsr get79
		cmp.l #$80000,$42e.w
		ble half
		lea $60000,a0
		lea $f0000,a1
lk		move.l (a0)+,(a1)+
		move.l (a0)+,(a1)+
		lea 4(a1),a1
		cmp.l #$61400,a0
		ble lk
		lea raml(pc),a0
		lea (main+$da8)(pc),a1
nn		move.l (a0)+,(a1)+
		cmp.l #get79,a0
		ble nn
		lea text2(pc),a0
		bra print
half		lea text1(pc),a0
		bra print

raml		bra ovv
		nop
		nop
		nop
		nop
ovv		movem.l d0/a0/a6,-(sp)
		lea $f0000,a0
		move.w #$13f,d0
cc		move.l (a0)+,(a6)+
		move.l (a0)+,(a6)+
		lea 4(a0),a0
		move.l (a0)+,(a6)+
		move.l (a0)+,(a6)+
		lea 4(a0),a0
		dbf d0,cc
		movem.l (sp)+,d0/a0/a6
		rts

get79		move.w #10,-(sp)
		move.w #0,-(sp)
		move.w #79,-(sp)
 		move.w #1,-(sp)
		move.w #0,-(sp)
		clr.l -(sp)
		pea $60000
		move.w #8,-(sp)
		trap #14
		add.l #20,sp
		cmp.l #'ZIPY',$60000
		bne notok
		rts
notok		lea fuck(pc),a0
		bsr print
		bsr fadeup
fucked		bra fucked
levnum		dc.w 0
int		movem.l d0-a6,-(sp)
		bsr (music+8)
		movem.l (sp)+,d0-a6
ex		rte

main		incbin 'b:\7d0a8'
music		incbin 'c:\music\tale6.mus'
fuck		dc.b 27,'f',27,'E'
		dc.b "This disk has not been copied properly!",10,10,13
		dc.b "Are you sure you copied ALL sectors ????",0
text		dc.b 27,'f',27,'E'
		dc.b "The Medway Boys Present",10,13
		DC.B "~~~~~~~~~~~~~~~~~~~~~~~",10,10,13
		DC.B "WRATH OF THE DEMON+",10,10,13
		dc.b "Cracked & Filed by Illegal",10,13
		dc.b "Trainer & Enhanced loader by Zippy",10,10,10,13
		dc.b "If the screen flashes blue, then insert",10,13
		dc.b "another disk in either drive.",10,10,13
		dc.b "If you already have the Replicants",10,13
		dc.b "version and you don't want to re-copy",10,13
		dc.b "all 5 disks, then just copy track 79 of",10,13
		dc.b "this disk onto track 79 of disks 2-5.",10,13
		dc.b "If you don't fix (or copy) these disks",10,13
		dc.b "the two drive option will not work !!",10,10,13
		dc.b "Always copy ALL sectors, not just USED!",10,10,10,13
		dc.b "If you have an External Drive then you",10,13
		dc.b "must insert disk 2 in Drive B NOW !!!",0
text1		dc.b "NO",10,13,0
text2		dc.b "YES",10,13,0
text3		dc.b 27,'f',27,'E'
		dc.b "This version will still work OK with",10,13
		dc.b "Half meg, single drive systems but if",10,13
		dc.b "you have an extra drive or expansion ram",10,13
		dc.b "the game will load faster and/or have",10,13
		dc.b "less disk swapping !!",10,10,13
		dc.b "DS external drive found - ",0
text4		dc.b "Expansion Ram found - ",0
text5		dc.b 10,10,13
		dc.b "Select start level with +/- or press",10,13
		dc.b "SPACE to start....",10,10,13
lev0		dc.b 13,"Level: ",0
	even
		dc.w 0
lev1		dc.b "01  Horse              ",0
		dc.l 0
		dc.b "02  Goblins            ",0
		dc.l $7d4f6
		dc.b "03  Dragon             ",0
		dc.l $7d562
		dc.b "04  Cave               ",0
		dc.l $7d5d6
		dc.b "05  Cave guardian      ",0
		dc.l $7d630
		dc.b "06  Swamp creature     ",0
		dc.l $7d6a4
		dc.b "07  Clearing           ",0
		dc.l $7d712
		dc.b "08  Dark tower         ",0
		dc.l $7d7b6
		dc.b "09  After Dark tower   ",0
		dc.l $7d84a
		dc.b "10  Temple             ",0
		dc.l $7d87a
		dc.b "11  Castle             ",0
		dc.l $7d8f4
		dc.b "12  Castle goblin      ",0
		dc.l $7d988
		dc.b "13  Castle after goblin",0
		dc.l $7d9e2
		dc.b "14  Castle dragon      ",0
		dc.l $7da08
		dc.b "15  Castle after dragon",0
		dc.l $7da62
		dc.b "16  Demon              ",0
		dc.l $7da96
		dc.b "17  End sequence       ",0
		dc.l $7daf8

