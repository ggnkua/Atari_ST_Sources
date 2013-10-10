	opt s-
	bra start
trap0	move.l a0,save
	cmp.b #$88,$00(a0)
	bne notus
	cmp.b #$0a,$01(a0)
	bne notus
	cmp.b #$01,$02(a0)
	bne notus
	cmp.b #$b3,$03(a0)
	bne notus
	cmp.b #$14,$28(a0)
	bne notus
	cmp.b #$0f,$2a(a0)
	bne notus
	add.l #$28,save
	move.l 2(sp),a0
	move.l -6(a0),a0
	add.l #$28,(a0)
notus	move.l save,a0
	move.b (a0),d0
	rte
save	dc.l 0
start	move.l a7,a6
	move.l 4(a6),a6
	pea $300
	pea (a6)
	pea $4a0000
	trap #1
	lea 12(sp),sp
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,oldsp
	lea $ffff8240,a0
	move.l #$07770777,(a0)+
	move.l #$07770777,(a0)+
	move.l #$07770777,(a0)+
	move.l #$07770777,(a0)+
	move.l #$07770777,(a0)+
	move.l #$07770777,(a0)+
	move.l #$07770777,(a0)+
	move.l #$07770777,(a0)+
	lea music,a0
	lea $49be8,a1
ml1	move.l (a0)+,(a1)+
	cmp.l #end,a0
	ble ml1
	move.l $70.w,old70
	moveq #1,d0
	jsr $49bea
	move.l #int,$70.w

	pea text
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	move.w #6,d0
f0	bsr wait
	sub.w #$111,$ffff8240.w
	sub.w #$111,$ffff825e.w
	dbf d0,f0

	move.w #6,d0
f1	bsr wait
	add.w #$111,$ffff825e.w
	dbf d0,f1



	move.w #7,-(sp)
	trap #1
	lea 2(sp),sp
	move.l old70,$70.w
	move.l #$08080000,$ffff8800.w
	move.l #$09090000,$ffff8800.w
	move.l #$0a0a0000,$ffff8800.w
	move.l oldsp,-(sp)
	move.w #$20,-(sp)
	move.l #trap0,$80.w
	trap #1
	addq.l #6,sp
	pea env
	pea com
	pea name
	pea $4b0000
	trap #1
	lea 16(sp),sp
	clr.w -(sp)
	trap #1
env	dc.l 0
com	dc.l 0
name	dc.b 'monkey.zip',0,0
oldsp	dc.l 0
old70	dc.l 0
wait	move.w #2,d7
v0	clr.w $24.w
v1	tst.w $24.w
	beq v1
	dbf d7,v0
	rts
int	move.w #1,$24.w
	movem.l d0-a6,-(sp)
	jsr $49bee
	movem.l (sp)+,d0-a6
	move.l old70,-(sp)
	rts
text	dc.b 27,'E',27,'f',27,'w'
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ The MEDWAY BOYS bring you:           +",10,13
	dc.b "+                                      +",10,13
	dc.b "+ THE SECRET OF MONKEY ISLAND          +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ Cracked by ZIPPY                     +",10,13
	dc.b "+ Original by Gino and Mike of Trend   +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ Once you work out how to trace these +",10,13
	dc.b "+ interpreted languages they're quite  +",10,13
	dc.b "+ easy.... This took under 2 hours !!  +",10,13
	dc.b "+                                      +",10,13
	dc.b "+ Hey EGB, what's so funny about me    +",10,13
	dc.b "+ listening to Dead Kennedys, Cancer,  +",10,13
	dc.b "+ NWA and the Bangles ????             +",10,13
	dc.b "+                                      +",10,13
	dc.b "+ Greetings go to all crews who didn't +",10,13
	dc.b "+ manage to break this protection....  +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++"
	even
	dc.w 0
music	incbin 'c:\music\texcopy.mus'
end	dc.w 0

