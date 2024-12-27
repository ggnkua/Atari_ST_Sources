	opt s-
	move.l a7,a6
	move.l 4(a6),a6
	pea $300
	pea (a6)
	pea $4a0000
	trap #1
	lea 12(sp),sp
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
crack	movem.l d0/a0-a1,-(sp)
	move.l a0,a1
	add.w d0,a1
	cmp.b #$1c,-1(a1)
	bne notus
	cmp.b #$1e,(a1)
	bne notus
	cmp.b #$13,1(a1)
	bne notus
	cmp.b #$33,2(a1)
	bne notus
	cmp.b #$4f,$2f(a1)
	bne notus
	cmp.b #$4b,$30(a1)
	bne notus
	lea check(pc),a0
	tst.w (a0)
	bne over
	move.w #$3b,d0
cl1	clr.b (a1)+
	dbf d0,cl1
over	eor.w #1,(a0)
notus	movem.l (sp)+,d0/a0-a1
	move.b 0(a0,d0.w),d0
	rts
check	dc.w 0
env	dc.l 0
com	dc.l 0
name	dc.b 'delphine.clg',0,0
text	dc.b 27,'E',27,'f',27,'w'
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ The MEDWAY BOYS bring you:           +",10,13
	dc.b "+                                      +",10,13
	dc.b "+ OPERATION STEALTH                    +",10,13
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
	dc.b "+ Read the DOC file for more details.  +",10,13
	dc.b "+ You can now select ANY two colours!! +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++ FIXED FOR TOS 1.40 ++++++++++"
	even
	dc.w 0
