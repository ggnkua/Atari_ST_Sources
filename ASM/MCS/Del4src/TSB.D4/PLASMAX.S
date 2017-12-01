; tsb of the european swapping crew present you...
; chromax demo by iki, sponsored by the greenstrife
; for the delirious demo 4

	opt	o+,d+

	section	text
	
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	MOVE.W	#$2700,SR
	
	CLR.B	$FFFF8260.W

	lea	save(pc),a0
	move.l	d0,(a0)+
	move.b	$ffff8260.w,(a0)+
	move.b	$ffff820a.w,(a0)+
	move.l	$fffffa06.w,(a0)+
	move.l	$fffffa12.w,(a0)+
	move.l	$70.w,(a0)+
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)
	move.l	$118.w,key+2
	move.l	#buf+255,d0
	sf	d0
	move.l	d0,sb1
	add.l	#39680,d0
	move.l	d0,sb2
	lea	blast_your_grandmother_by_throwing_it_on_the_keyboard_sorry_for_your_keys_but_this_was_a_good_thing_because_the_grandmothers_and_mothers_in_law_are_always_trying_to_protect_the_ozone_layer_by_buying_ozone_friendly_cfcs_fuck_them+34,a0
	move.l	sb1(pc),a1
	move.l	sb2(pc),a2
	move	#7999,d0
fuck_my_grandmother
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,fuck_my_grandmother
	moveq	#1,d0
	jsr	mus

	bsr	kookoo

	move.l	#end,$8.w
	move.l	#end,$c.w
	move.l	#end,$10.w
	move.l	#vbl,$70.w
	move.l	#kbd,$118.w

	ori.b	#1,$fffffa07.w
	ori.b	#1,$fffffa13.w
	sf	$fffffa09.w
	sf	$fffffa15.w

	MOVE.W	#$2300,SR

	moveq	#-1,d1

wspace	moveq	#0,d0
	move.b	$fffffc02.w,d0
	cmpi	#$48,d0
	bne.s	f1
	tst	inca
	beq.s	f1
	subq	#2,inca
	bsr	vide
f1	cmpi	#$50,d0
	bne.s	f2
	cmpi	#100,inca
	bge.s	f2
	addq	#2,inca
	bsr	vide
f2	cmpi	#$4b,d0
	bne.s	f3
	tst	speeda
	beq.s	f3
	subq	#2,speeda
	bsr.s	vide
f3	cmpi	#$4d,d0
	bne.s	f4
	cmpi	#80,speeda
	bge.s	f4
	addq	#2,speeda
	bsr.s	vide
f4	cmpi	#$39,d0
	bne.s	wspace

end	
	MOVE.W	#$2700,SR
	lea	save+4(pc),a0
	move.b	(a0)+,$ffff8260.w
	move.b	(a0)+,$ffff820a.w
	move.l	(a0)+,$fffffa06.w
	move.l	(a0)+,$fffffa12.w
	move.l	(a0)+,$70.w
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	key+2(pc),$118.w
	move.l	#$8080000,$ffff8800.w
	move.l	#$9090000,$ffff8800.w
	move.l	#$a0a0000,$ffff8800.w

	ILLEGAL

vide	tst	d1
	blt.s	out
	move	#20000,d1
vide2	cmp.b	$fffffc02.w,d0
	dbne	d1,vide2
	rts
out	move	#2000,d1
out2	cmp.b	$fffffc02.w,d0
	dbne	d1,out2
	rts

vbl	sf	$ffff8260.w
	movem.l	d0-a6,-(a7)
	movem.l	blast_your_grandmother_by_throwing_it_on_the_keyboard_sorry_for_your_keys_but_this_was_a_good_thing_because_the_grandmothers_and_mothers_in_law_are_always_trying_to_protect_the_ozone_layer_by_buying_ozone_friendly_cfcs_fuck_them+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	sb1,d0
	move.l	sb2,d1
	move.l	d0,sb2
	move.l	d1,sb1
	move.l	d0,$44e.w
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	move.l	sb2(pc),a6
	lea	32328(a6),a6
	rept	114
	movem.l	(a6)+,d0-d7/a0-a5
	movem.l	d0-d7/a0-a5,-64(a6)
	endr
	move.l	(a6)+,-12(a6)
	move.l	(a6),-8(a6)

	move	offs2(pc),d0
	addq	#1,d0
	btst	#1,d0
	beq.s	noprob
	addq	#6,d0
noprob	move	d0,offs2
	addq	#1,offs
	cmpi	#4,offs
	blt.s	ns5
	cmpi	#5,offs
	bge.s	ns4
	move.l	#j+144,adr
	clr	offs2
	bra.s	ns5
ns4	clr	offs
	move.l	point(pc),d1
	addq.l	#1,d1
	lea	text,a6
	tst.b	(a6,d1.l)
	bne.s	noend
	moveq	#0,d1
noend	move.l	d1,point
	move.b	(a6,d1.l),d1
	subi.b	#32,d1
	andi	#$ff,d1
	lsl	#2,d1
	lea	font,a6
	move.l	(a6,d1.w),d6
	move.l	d6,d5
	bclr	#0,d5
	move.l	d5,adr
	andi	#1,d6
	move	d6,offs2
	tst.l	adr2
	bne.s	ns5
	move.l	d5,adr2
ns5	move.l	adr(pc),a6
	add	offs2(pc),a6
	move.l	adr2(pc),a4
	move.l	a6,adr2
	move.l	sb2(pc),a5
	lea	32152+320(a5),a5
lm	set	0
	rept	27
	movep.l	lm(a4),d0
	movep.l	d0,lm(a5)
	movep.l	lm(a6),d0
	movep.l	d0,lm+1(a5)
lm	set	lm+160
	endr
	move.l	a4,sa4
	bsr	kookoo
	movea.w	#$8209,a0
	moveq	#0,d3
	moveq	#16,d1
sync1	move.b	(a0),d3
	beq.s	sync1
	sub.b	d3,d1
	lsr	d1,d3
	movea.w	#$8240,a1
	dcb.w	94,$4e71
	move	(a4),d1
	move.l	(a2,d1.w),a3
	jmp	(a3)
endplas	clr	(a1)
	move.l	sa4(pc),a4
	rept	2
	movep.l	lm(a4),d0
	movep.l	d0,lm(a5)
	movep.l	lm(a6),d0
	movep.l	d0,lm+1(a5)
lm	set	lm+160
	endr
	movep.l	lm(a4),d0
	movep.l	d0,lm(a5)
	movep.l	lm(a6),d0
	movep.l	d0,lm+1(a5)
lm	set	lm+160
	movep.l	lm(a4),d0
	movep.l	d0,lm(a5)
	movep.l	lm(a6),d0
	movep.l	d0,lm+1(a5)
lm	set	lm+160
	movep.l	lm(a4),d0
	movep.l	d0,lm(a5)
	movep.l	lm(a6),d0
	sf	$ffff820a.w
	movep.l	d0,lm+1(a5)
	dcb.w	6,$4e71
	move.b	#2,$ffff820a.w
	movem.l	fnt+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	jsr	mus+8
	cmpi.b	#$f,$fffffc02.w
	bne.s	ntps
	move	#$27,$ffff8240.w
ntps	movem.l	(a7)+,d0-a6
	rte

kbd	move	#$2500,sr
key	jmp	0.l
sa4	ds.l	1

kookoo	lea	plasmax(pc),a4
	move	offset(pc),d0
	add	speeda(pc),d0
	cmpi	#360,d0
	blt.s	nonono
	subi	#360,d0
nonono	move	d0,offset
	move	width(pc),d0
	add	winc(pc),d0
	cmpi	#offs-plasmax,d0
	blt.s	nogt21
	neg	winc
	add	winc(pc),d0
nogt21	tst	d0
	bge.s	nopl0
	neg	winc
	add	winc(pc),d0
nopl0	move	d0,width
	add	offset(pc),d0
	add	d0,a4
	move	inca(pc),d6
	lea	achtung(pc),a2
	move	#197,d2
	move	#360,d0
	move	d0,d5
	sub	offset(pc),d0
	move	#198,d7
	rts

xx	set	0
daou
	rept	53
	lea	plas+xx(pc),a0
	nop
	nop
	dcb.w	33,$3298
	nop
	subq	#1,d7
	beq	endplas
	sub	d6,d0
	dc.w	$6e08
	lea	-360(a4),a4
	add	d5,d0
	dc.w	$600a
	dcb.w	5,$4e71
	add	d6,a4
	move	(a4),d1
	move.l	(a2,d1.w),a3
	jmp	(a3)

	lea	plas+xx(pc),a0
	nop
	dcb.w	33,$3298
	nop
	nop
	subq	#1,d7
	beq	endplas
	sub	d6,d0
	dc.w	$6e08
	lea	-360(a4),a4
	add	d5,d0
	dc.w	$600a
	dcb.w	5,$4e71
	add	d6,a4
	move	(a4),d1
	move.l	(a2,d1.w),a3
	jmp	(a3)

	lea	plas+xx(pc),a0
	dcb.w	33,$3298
	nop
	nop
	nop
	subq	#1,d7
	beq	endplas
	sub	d6,d0
	dc.w	$6e08
	lea	-360(a4),a4
	add	d5,d0
	dc.w	$600a
	dcb.w	5,$4e71
	add	d6,a4
	move	(a4),d1
	move.l	(a2,d1.w),a3
	jmp	(a3)

xx	set	xx+2
	endr

	section	data
plas	dc.w	1,2,3,4,5,6,7,$17,$27,$37,$47,$57,$67,$77,$176,$275,$374,$473,$572,$671,$770,$761,$752,$743,$734,$725,$716,$707,$606,$505,$404,$303,$202,$101,0
	dc.w	1,2,3,4,5,6,7,$17,$27,$37,$47,$57,$67,$77,$176,$275,$374,$473,$572,$671,$770,$761,$752,$743,$734,$725,$716,$707,$606,$505,$404,$303,$202,$101,0

width	dc.w	0
winc	dc.w	360
speeda	dc.w	2
inca	dc.w	2


off104	set	0
achtung	rept	106
	dc.l	daou+off104
off104	set	off104+114
	endr

sb1	ds.l	1
sb2	ds.l	1
offset	ds.l	1
offs2	ds.w	1
point	ds.l	1
adr	ds.l	1
adr2	ds.l	1
save	ds.l	13

plasmax	incbin	plasma.x
offs	dc.w	4

text	dc.b    "     ALL SYSTEMS ACTIVATED .......      HI CITIZENS !!!   THIS SCREEN IS THE MODEST CONTRIBUTION OF THE STORM BROTHERS TO THE DELIRIOUS DEMO 4 OF MCS........." 
	dc.b	"   THE OZONE-UNFRIENDLY CREW TSB OF THE ESC PRESENTS YOU THE LAST SCREEN CODED BY IKI !!!   I NEEDED ONLY 4 DAYS, BUT I FINALLY GOT BORED AND DIDN'T FILL THE REMAINING TIME -PRESS TAB-   YOU WILL NEVER SEE A SCREEN FROM ME AGAIN... "
	dc.b	" THANKS TO JUDGE DREDD FOR HIS MORAL SUPPORT...  AND NOW TRY THE ARROWS KEYS...... COOL NO ???  "   
	dc.b 	" THE CHROMAX IS SPONSORED BY GREENSTRIFE - ZE NON-CHARITABLE ASSOCIATION DEDICATED TO THE RAPID DESTRUCTION OF OUR PLANET - STUDIO PROTEUS AND CAPSULE CORPORATION.     CREDITS... "
	dc.b	"BRAIN'S DESTRUCTION BY ddIKIdd -NO ?? WAIT FOR THE FABULOUS EXORCIST 3 !, EYES' DESTRUCTION BY THE LAW HIMSELF, dJUDGE DREDDd - AUTHOR OF THE DRAGON - AND THE KANGAROOS -WHO MADE THE UNREADABLE FONT ! "
	dc.b	"   EARS' DESTRUCTION BY MAD MAX, OF COURSE ! -MUSIC ULTIMATE RIPPED BY IKI FROM THE OOH CRIKEY WOT A SCORCHER DEMO-   bbb   SOME GREETINGS, MAYBE ?? YES ?????? OKKKEEYY !"
	dc.b	"     HELLO TO ... ALL AT THE dESCd - ALL OF TSB ESPECIALLY  dZXd THE NEW MEMBER, BILBO AND STICK OF dRIPPED OFFd , AND THE NEW MEMBER   dAWESOMEd    "
        dc.b    " -, dDOCNOd, dMCSd -FOR THEIR GIGADEMO-, dMASTERSd -SKAVEN, ZARATHUSTRA-, AWG -FOR THEIR NICE aCPa, STORMBRINGERS - MY NEW VERY BIG FRIENDS !!!! ESPECIALLY SQUAL AND MORVE - AND ALL"
	dc.b	" OUR OTHER FRIENDS... FRIENDSHIP IS ALL UHUH !! SPECIAL GREETS TO MY PERSONAL MANGA-SWAPPING FRIENDS, ESP. PATRICK, NUMBER6, GUNDAM, M87...   MANGA-GREETINGS TO HAYAO MIYAZAKI -GREAT NAUSICAA-, KATSUHIRO OTOMO -GREAT AKIRA-, TSUKASA"
	dc.b	" HOJO -GREAT CITY HUNTER-, MASAMI KURUMADA -NICE SAINT SEIYA MANGA AND GREAT SERIAL-, AND RUMIKO TAKAHASHI -NICE MAISON IKKOKU AND RANMA NI BUN NO ICHI- .... "
	dc.b	" aaaaaaa..........   a THIS SCREEN DOES dNOTd PRESERVE THE OZONE-LAYER.      BYE BYE,   AND NOW LETS JUDGE ON KEYS !!!   BYE BYE !!!  IKI OF THE STORM BROTHERS -TSB-       DON'T FORGET   cccccccc TO STOP YOUR MUTATION !!!!!!!  "
	dc.b	" DON'T BECOME A NEW TETSUO !  ccdccdcc .....    HI CITIZENS OF THE WORLD !!!  IT'S TIME TO GET UP BECAUSE HERE COMES .......   dJUDGE DREDDd   .......  TODAY I COME TO JUDGE YOU ... EUH NO .... TO POLLUTE YOUR MIND...  SHITTY KEYS "
        dc.b    " I JUST COME FOR SOME GREETS, FUCKS AND INFORMATIONS ABOUT TSB...   bbb GREETINGS SYSTEM ACTIVATED....  I SEND MY BEST REGARDS TO - ESC dRIPPED OFF, AWESOME, TSBd, STALIN FROM FF -ARE YOU ALIVE ???-, STORMBRINGERS ddSQUAL "       
        dc.b    "AND MORVEdd, MCS -JUDGE dDEATHd AND ZORGLUB-, dTHE SERGEANTd -GREAT TRANSBEAUCE II-,"
	dc.b    " DEATH, IMPERATOR, NAPALM SOLDIERS dHAWKd, AND FINALLY... dd MICRO CLUB 66 dd -VIC, VINCENT, DOMINIQUE AND ALL OTHERS MEMBERS- AND THE SHADOW WARRIORS - aa FURAX aa -........."
	dc.b    " NORMAL REGARD TO   dVOYAGERSd, LIGHTNINGS ESP. SLAYER, FUTUR MINDS -BOULDOG-, ARMALYTE, LAZER, ANIMAL MINE, NPG, THE WHITE DWARF, TSK, AWG AND FINALLY DOCNO FROM FUZION......."
	dc.b    "NOW COMES THE MEGA FUCKS, I SEND THEM TO  aaa FIREFOX aaa -MEGALAMER-, a SKYHAWK a, a WARAXE a, a DAVY R...a,  da CHRISTELLE ad,  a PASCAL M......a !!!  " 
	dc.b	"  WELL THATS ALL FOR THIS TIME............ bbb   LET ME TELL YOU SOMETHING VERY IMPORTANT .... "
	dc.b    " IF YOU HAVE RECEIVED AN INVITATION FOR THE MEGAFUN PART II, PLEASE SEND IT US BACK BEFORE THE 28TH OCTOBER 91....... I HOPE YOU WILL BE A LOT TO COME BECAUSE IT WILL BE GREAT.... bbb  IT'S TIME TO PRESENT YOU THE STORM"
	dc.b	" BROTHERS MEMBERS IN NO SPECIAL ORDER          cIKIc         bHECKLEb        cJECKLEc        dREMd        dMAVERICKd        bZXb         cNO NAMEc         a ST MAC GYVER -ANTARES- a        bZINEb          dJUDGE DREDDd          "
	dc.b	" YOU CAN CONTACT ANY MEMBER OF TSB BY WRITING TO        TSB    BP 66   59420 MOUVAUX    FRANCE         TSB  BP 66  59420 MOUVAUX  FRANCE "
        dc.b	" THATS ALL FOLKS !!!        THIS INTRO WAS SPONSORED BY   dcd GREENSTRIFE dcd    A NON CHARITABLE ASSOCIATION DEDICATED TO THE RAPID DESTRUCTION OF OUR PLANET.......  aaa GO WITH THE FLOW aaa .................  BYE BYE ..........."
	dc.b    "........................................ cIKIc   AND   dJUDGE DREDDd  ON AUGUST 1991 ..................................  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .   .   .   .   .   .   .   .   .   .   .   .   .   ."
	dc.b    "   .    .    .    .    .    .    .    .    .    .    .    .     .     .     .     .     .     .     .     .      .      .      .      .      .      .      .      .      .      aaa   THE FUCKING END   aaa                          "
	dc.b	"                                                                                      ",0
fnt	incbin	f_chip1.pi1
mus	incbin	terror.mus
blast_your_grandmother_by_throwing_it_on_the_keyboard_sorry_for_your_keys_but_this_was_a_good_thing_because_the_grandmothers_and_mothers_in_law_are_always_trying_to_protect_the_ozone_layer_by_buying_ozone_friendly_cfcs_fuck_them	incbin	bellmere.pi1
f	equ	fnt+34
g	equ	f+32*160
h	equ	f+64*160
i	equ	f+96*160
j	equ	f+128*160
font	dc.l	j+144,h+128,0,0,0,0,0,h+96,0,0,0,0,h+112,j+16,h+112,0,i,i+16,i+32,i+48,i+64,i+80,i+96,i+112,i+128,i+144,0,0,0,0,0,h+144,0,f,f+16,f+32,f+48,f+64,f+80,f+96,f+112,f+128,f+144,g,g+16,g+32,g+48,g+64,g+80,g+96,g+112,g+128,g+144,h,h+16,h+32,h+48
	dc.l	h+64,h+80,0,0,0,0,0,0,j+32,j+48,j+64,j+96
; a=fuck you
; b=and now ?!?
; c=do use drugs
; d=piracy

	section	bss
buf	ds.l	19904
