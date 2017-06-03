
*   intro thanx to passwods
*   coded by sademan

	section	text 

	move.l	a7,a5
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$200,d0
	move.l	d0,d1
	add.l	a5,d1
	and.l	#-2,d1
	move.l	d1,sp
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp

	move.l	#super,-(sp)
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp

	move.l	#noire,-(sp)
	move.w	#6,-(sp)
	trap	#14
	add.l	#6,sp

	move.l	#super3,-(sp)
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	
	lea	table1,a6
	move.l	#alpha1,(a6)+
	move.l	#txt_p0,(a6)+
	move.l	#txt_p1,(a6)+
	move.l	#txt_p2,(a6)+
	move.l	#suite,(a6)+	
	move.l	#the_scr,(a6)+
		
	pea	env
	pea	com
	pea	lance
	move.w	#3,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp

	move.l	d0,b_page
	
	pea	env
	move.l	b_page,-(sp)
	pea	com
	move.w	#4,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
sorite
	move.l	table1,d0
	cmp.l	#0,d0
	bne.s	second
	move.l	#fil1,a0
	bra	go
second	cmp.l	#1,d0
	bne.s	troisieme
	move.l	#fil2,a0
	bra	go
troisieme
	cmp.l   #2,D0
	move.l	#fil3,a0
        bra   go

go	pea	env
	pea	com
	move.l	a0,-(sp)
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp

	move.l	#palet,-(sp)
	move.w	#6,-(sp)
	trap	#14
	add.l	#6,sp

	clr.w	-(sp)
	trap	#1
super
	move.l	$44e.w,a0
	move.w	#200*40-1,d0
net
	clr.l	(a0)+
	dbf	d0,net
	move.b	#$12,$fffc02
	clr.b	$484.w
	move.l	#table1,$49e.w
	move.l	#$ffff8240,a1
	lea	palet,a0
	movem.l	(a1),d0-D7
	movem.l	d0-D7,(a0)
	rts
super4
	lea	cycle,a5
	lea	16*2*7(a5),a5
	lea	$ffff8240.w,a6
	move.w	#7,cpt
.bcl
	movem.l	(a5),d0-d7
	movem.l	d0-D7,(a6)
	lea	-16*2(a5),a5
	bsr	wait_vbl
	subq.w	#1,cpt
	bpl.s	.bcl
	move.l	#$7770777,d7
	move.l	d7,d6
	move.l	d7,d5
	move.l	d7,d4
	move.l	d7,d3
	move.l	d7,d2
	move.l	d7,d1
	move.l	d7,d0
	move.w	#7,cpt
.bcl2
	movem.l	d0-D7,(a6)
	sub.l	#$1110111,d0
	sub.l	#$1110111,d1
	sub.l	#$1110111,d2
	sub.l	#$1110111,d3
	sub.l	#$1110111,d4
	sub.l	#$1110111,d5
	sub.l	#$1110111,d6
	sub.l	#$1110111,d7
	movem.l	d0-D7,-(sp)
	bsr	wait_vbl
	movem.l	(sp)+,d0-D7
	subq.w	#1,cpt
	bpl.s	.bcl2
	rts
super3
	move.l	$44e.w,a5
	lea	160*70+32(a5),a5
	lea	image1,a6
	
	move.w	#53,d0
.bcl2
	move.w	#22-1,d1
.bcl1
	move.l	(a6)+,(a5)+
	dbf	d1,.bcl1
	lea	72(a5),a5
	dbf	d0,.bcl2
	
	move.l	#$ffff8240,a6
	clr.l	d7
	clr.l	d6
	clr.l	d5
	clr.l	d4
	clr.l	d3
	clr.l	d2
	clr.l	d1
	clr.l	d0
	move.w	#7,cpt
.bcl
	movem.l	d0-D7,(a6)
	bsr	wait_vbl
	add.l	#$1110111,d7
	move.l	d7,d0
	move.l	d7,d1
	move.l	d7,d2
	move.l	d7,d3
	move.l	d7,d4
	move.l	d7,d5
	move.l	d7,d6
	subq.w	#1,cpt
	bpl.s	.bcl
	bsr	wait_vbl
	lea	cycle,a5
	move.w	#7,cpt
.bcl3
	movem.l	(a5)+,d0-D7
	movem.l	d0-D7,(a6)
	bsr	wait_vbl
	subq.w	#1,cpt
	bpl.s	.bcl3
	rts
wait_vbl
	move.w	#$25,-(sp)
	trap	#14
	addq.w	#2,sp
	move.w	#$25,-(sp)
	trap	#14
	addq.w	#2,sp
	move.w	#$25,-(sp)
	trap	#14
	addq.w	#2,sp
	rts	
suite
	move.l	#super4,-(sp)
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	rts
		
	section	data
cpt	dc.w	0
cycle	
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777
	
	dc.w	$666,$666,$677,$666,$666,$666,$666,$666
	dc.w	$666,$666,$666,$666,$777,$666,$666,$666
	
	dc.w	$555,$555,$577,$566,$555,$555,$555,$555
	dc.w	$555,$555,$555,$555,$777,$565,$555,$555
	
	dc.w	$444,$444,$477,$466,$455,$444,$444,$444
	dc.w	$444,$444,$444,$555,$777,$464,$444,$444
	
	dc.w	$333,$333,$377,$366,$355,$344,$333,$333
	dc.w	$333,$333,$444,$555,$777,$364,$343,$333
	
	dc.w	$222,$222,$277,$266,$255,$244,$233,$222
	dc.w	$222,$333,$444,$555,$777,$264,$243,$232
	
	dc.w	$111,$222,$177,$166,$155,$144,$133,$122
	dc.w	$222,$333,$444,$555,$777,$164,$143,$132
	
	dc.w	$000,$222,$077,$066,$055,$044,$033,$022
	dc.w	$222,$333,$444,$555,$777,$064,$043,$032
	
noire	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

lance	dc.b	'sade_sky.int',0
	even
com	dc.b	0,0
env	dc.w	0
image1	incbin	logo.bin

	section	bss
table1	ds.l	10
palet	ds.l	8
b_page	ds.l	1

	
	section	data
		
alpha1	dc.b	'ABCDEFGHIJKLMNOPQRSTUVWXYZ.!?,1234567890 '
	even
*  nom des jeux 
txt_p0	dc.b	'EUROSWAP CD 970',-1	; 20 caracteres maxi	
	even 
txt_p1	dc.b	'TRANSARTICA -B-',-1	; 18 maxi
	even
txt_p2	dc.b    'SNOOFY',-1	; 16 maxi
	even
the_scr	
	DC.B	" PASSWORDS-EUROSWAP PRESENTS YOU HIS CD 970   "
	DC.B	" WITH TRANSARTICA (B) - PACKED BY ORION -REPLICANTS, WARNING : THE EUROSWAP CD 971 REQUISITE !, YOU CAN TYPE ALSO THE THREE NUMERICAL TOUCH FOR SNOOFY... "
	DC.B	" SADEMAN FROM EXO7-EUROSWAP AT KEYBOARD IN THIS MOMENT...I WANT SAY THAT : REAL GREETINGS SO "
	DC.B	" GREETS TO SPEEDLIGHT AND TYPHON FROM THE OVERLANDERS, X-RAY FROM ELECTRA... "
	DC.B	" SNOCKS GREETS TO ALDO & PROSPER...SNOCKS GREETS IS A GREET FOR GREETING AN "
	DC.B	" ALL OLD FRIENDS.....SKYWALKER FROM EXO7 ALSO AT KEYBOARD NOW...MEGA BIG HELLO AND GREETING TO : "
	DC.B	" AXYLAN - SADMAN - R-BOY - DR TRAP - RED BARONS - GUICHE - GOOFY - BVCA - MICHAWK "
	DC.B	" - OXYD - CORPO - DR CLONE - HITCHER - FAST EASY - INFIRMIER - ETERNAL - HYSTERIA "
	DC.B	" - OVERLANDERS - TBO - AND OTHERS CONTACTS ON ATARI...."
	DC.B	" AND NOW I LEAVE THE KEYBOARD AND GIVE IT TO LAURENZO FROM PASSWORDS-EUROSWAP..."
	DC.B    "IT'S LAURENZO AT KEYBOARD NOW...I WANT PRESENT YOU THE ALLIANCE OF EUROSWAP..."
	DC.B    "THIS ALLIANCE IS THE UNION OF THREE CREWS NAMED > PASSWORDS > SELECT > EXO7 "
	DC.B    "THE CURRENT MEMBERS ARE IN THIS MOMENT FOR PASSWORDS - THE WAY TO FUNLAND ! : LAURENZO - DARKO - "
	DC.B    "- TESTAMENT -  PHYMAX -  ARCHON - THE COP - SPA 160 - FRANCOIS - THE BIKER - YNEXYX - "
	DC.B    " WINNER - TEX - BOBO STE - LOLO 77 - ST 123 - LA FLECHE - ZASTAPH - ANTAEUS ..." 
	DC.B    " - ...FOR SELECT : SARK - WARRIOR - KILLER'S -  ....FOR EXO7 : SADEMAN - "
	DC.B    " - SKYWALKER - .......BESTS REGARDS TO : "
	DC.B    "REPLICANTS + FUZION + ICS + VMAX + ULTIMATE + POMPEY PIRATES + RADIATION + THUNDERBIRDS + "
	DC.B    "CYNIX + BAD BOYS BELGIUM + POSITIVITY + APEX DEV. + ANIMAL MINE + ZUUL + ILLUSIONS + "
	DC.B    "EAGLES + SYNDICATE + IMPACT + TSB + EXTRACT + KGB + SECTOR ONE + HMD + PIRACY + JEDI, ATLANTIS, GANDJA KID, COL PEPPERS,-1 "
	
	even

;   nom des fichiers prg
fil1	dc.b	"",0
	even
fil2	dc.b	"",0
	even
fil3	dc.b	"SNOOFY.prg",0
        even

