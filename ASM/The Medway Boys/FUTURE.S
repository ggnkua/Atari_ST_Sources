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
crack	cmp.b #$25,(a0)
	bne notus
	cmp.b #$0a,1(a0)
	bne notus
	cmp.b #$4f,$1c(a0)
	bne notus
	cmp.b #$2e,$1d(a0)
	bne notus
	cmp.b #$50,$1e(a0)
	bne notus
	cmp.b #$52,$1f(a0)
	bne notus
	cmp.b #$22,$14(a0)
	bne notus
	cmp.b #$0a,$15(a0)
	bne notus
	clr.b (a0)
	clr.b 1(a0)
	clr.b $14(a0)
	clr.b $15(a0)
notus	move.b (a0),d0
	and.w #$ff,d0
	rts
env	dc.l 0
com	dc.l 0
name	dc.b 'delphine.clg',0,0
text	dc.b 27,'E',27,'f',27,'w'
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ The MEDWAY BOYS bring you:           +",10,13
	dc.b "+                                      +",10,13
	dc.b "+ FUTURE WARS - TIME TRAVELLERS        +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ Cracked by THE MIGHTY CLOG           +",10,13
	dc.b "+ Original Supplied by EGB             +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ This was another game written in one +",10,13
	dc.b "+ of those shit adventure languages !! +",10,13
	dc.b "+ When this game was first released, I +",10,13
	dc.b "+ spent about a week trying to crack   +",10,13
	dc.b "+ it, but now that I've worked out a   +",10,13
	dc.b "+ method to crack this stuff, it took  +",10,13
	dc.b "+ me only about 4 hours to finish it ! +",10,13
	dc.b "+ Thanks to EGB for TOS 1.40 testing.  +",10,13
	dc.b "+                                      +",10,13
	dc.b "+ You can now select ANY two boxes !!  +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++ FIXED FOR TOS 1.40 ++++++++++"
	even
	dc.w 0
