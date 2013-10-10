	opt s-
	move.l a7,a6
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
	move.l #trap15,$bc.w
	move.l d0,-(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	pea text
	move.w #9,-(sp)
	trap #1
	lea 6(sp),sp
	move.w #7,-(sp)
	trap #1
	lea 2(sp),sp
	lea crack,a0
	lea $1000,a1
cop1	move.w (a0)+,(a1)+
	cmp.l #env,a0
	ble cop1
	pea env
	pea com
	pea name
	pea $4b0000
	trap #1
	lea 16(sp),sp
	clr.w -(sp)
	trap #1
trap15	clr.w (a0)+
	dbf d0,trap15
	sub.l #2,2(sp)
	move.l 2(sp),a0
	move.w #$4ef9,(a0)
	add.l #$11d9c,a0
	move.l #$4eb81000,(a0)
	rte
crack	movem.l d0/a0-a1,-(sp)
	cmp.b #$a0,-1(a0)
	bne notus
	cmp.b #$14,(a0)
	bne notus
	cmp.b #$73,$1a(a0)
	bne notus
	cmp.b #$65,$1b(a0)
	bne notus
	cmp.b #$63,$1c(a0)
	bne notus
	cmp.b #$72,$1d(a0)
	bne notus
	cmp.b #$65,$1e(a0)
	bne notus
	cmp.b #$74,$1f(a0)
	bne notus
	move.l a0,a1
	sub.l #$41,a0
	move.w #$40,d0
cp1	move.b (a0)+,(a1)+
	dbf d0,cp1
notus	movem.l (sp)+,d0/a0-a1
	moveq #0,d0
	move.b (a0),d0
	rts
env	dc.l 0
com	dc.l 0
name	dc.b 'loom.clg',0,0
text	dc.b 27,'E',27,'f',27,'w'
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ The MEDWAY BOYS bring you:           +",10,13
	dc.b "+                                      +",10,13
	dc.b "+ LOOM                                 +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ Cracked by THE MIGHTY CLOG           +",10,13
	dc.b "+ Original Supplied by Mike of Trend   +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ This was another game written in one +",10,13
	dc.b "+ of those shit adventure languages !! +",10,13
	dc.b "+ I spent 2 days developing a routine  +",10,13
	dc.b "+ that allows me to trace through the  +",10,13
	dc.b "+ program and stop it before entering  +",10,13
	dc.b "+ a new procedure, and using this code +",10,13
	dc.b "+ I cracked Stealth and Loom in 1 day! +",10,13
	dc.b "+                                      +",10,13
	dc.b "+ When the Protection screen appears,  +",10,13
	dc.b "+ just wait, and don't click anything! +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++ FIXED FOR TOS 1.40 ++++++++++"
	even
	dc.w 0
