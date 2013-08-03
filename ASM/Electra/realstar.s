;*******************************************
;*  Realtime stars with perspective table  *
;*  By Jesper Rudberg                      *
;*  (Kasper of Electra)		       *
;*  This is one of my first versons but it *
;*  shows the tech you use.                *
;*  Hope you learn something new anyway    *
;*  The code is very bad comented and you  *
;*  have to fix the screen address if you  *
;*  have a 520.                            *
;*  Should be assembled from Devpac 2.23   *
;*  el dyl.                                *
;*******************************************
nr_pnts	equ	330	antal punkter
helan	equ	256
halvan	equ	helan/2
y_scr	equ	40*200
x_scr	equ	40*320
	move.w	#0,-(sp)
	move.l	#$f8000,-(sp)
	move.l	#$f0000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#$111,$ff8242
	move.w	#$222,$ff8244
	move.w	#$333,$ff8246
	move.w	#$444,$ff8248
	move.w	#$555,$ff824a
	move.w	#$666,$ff824c
	move.w	#$777,$ff824e
	move.w	#$0,$ff8250

	jsr	studs
	jsr	drw_clc
	jsr 	random
	jsr	screenchg
	
vbl	move.w	#37,-(sp)		wait for vbl
	trap	#14
	addq.l	#2,sp
	move.w	#$000,$ff8240
	jsr	screenchg		byt screen mm
	
;**********************************************
	move.w	#0,d0		clear points
	move.w	#0,d1
	move.w	#0,d2
	move.l	screen,a0
	move.l	nowthis,a1
	jsr	(a1)
;***********************************************
	jsr	hot_stf		rita ut
	rept	25
	move.w	#$111,$ff8240
	endr
	move.w	#$000,$ff8240
	

	cmp.b	#185,$fffc02
	bne	vbl
	move.w	#$777,$ff8240
	move.w	#$000,$ff8246

	clr.w	-(sp) 
	trap	#1
;***************************************************************
hot_stf	
;*************************
;*  Check my var         *
;*************************
nono	lea	runt_kurv,a6
	add.w	add3,a6	
	add.w	#6,add3
	cmp.w	#-10000,(a6)
	bne	dont_care
	move.w	#0,add3
	bra	nono
dont_care	move.w	(a6),my_x
	move.w	2(a6),my_y
	move.w	4(a6),my_z

	cmp.w	#-halvan,my_x
	bge	got1
	add.w	#helan,my_x
got1	cmp.w	#halvan,my_x
	ble	got2
	sub.w	#helan,my_x

got2	cmp.w	#-halvan,my_y
	bge	got3
	add.w	#helan,my_y
got3	cmp.w	#halvan,my_y
	ble	got4
	sub.w	#helan,my_y
got4	
	cmp.w	#0,my_z
	bge	got5
	add.w	#helan,my_z
got5	cmp.w	#helan,my_z
	ble	got6
	sub.w	#helan,my_z
got6	
	move.w	my_x,d1
	move.w	my_y,d2
	move.w	my_z,d3
;*************************************************************************
;* Valj ut lampliga stjarnor  *
;* fixa cords 	      *
;******************************
	lea	ur_cords,a0		pekar pa massa cords
	lea	sorted,a2
	move.l	#nr_pnts-1,d0
lappa	move.w	(a0)+,d4		x
	add.b	d1,d4
	move.w	(a0)+,d5		y
	add.b	d2,d5
	move.w	(a0)+,d6		z
	add.b	d3,d6
;**********************************************************************
;**  Hamta perspectiv  **
;************************
	lsl.w	#1,d4
	lsl.w	#1,d5
	move.w	d6,(a2)+
	move.l	#9,d7
	lsl.l	d7,d6
	
	lea	pre_z,a3		hamta tabell
	add.l	d6,a3
	lea	(a3),a4
	add.w	d5,a3		y
	move.w	(a3),(a2)+
	
	add.w	d4,a4		x	
	move.w	(a4),(a2)+
	dbf	d0,lappa
;**************************************************
;*         draw point			  *
;************************************************************************
draw_pnts	move.l	screen,a6		
	move.l	#$48a80007,d3	=(movem.w d0-2,xx(a0))
	move.l	#$31400000,d0	=(move.w d0,xx(a0))

	move.w	#y_scr/2+100,d6	y_varde
	move.w	#x_scr/2+160,d4        	x_varde
	
	move.l	#nr_pnts-1,d2
	lea	sorted,a4		pekar pa x,y varden
	move.l	nowthis,a5		pekar pa savs tabell
rita	move.w	(a4)+,d7		get z

	lea	y_preps,a1	
	move.w	(a4)+,d0		get y varde to d0
	add.w	d6,d0		mitt
	lsl.w	#1,d0
	add.w	d0,a1		y till y
	move.w	(a1)+,d0
	
	lea 	x_preps,a2
	move.w	(a4)+,d1		get x varde to d1	
	add.w	d4,d1
	lsl.w	#2,d1
	add.w	d1,a2		x till x
	move.l	(a2)+,d1
	
	add.w	d1,d0		d0=adress offset
	swap	d1		d1.w=ratt bit
 
	lsr.w	#3,d7
	and.w	#$fc,d7
	lea	jumps(pc),a0
	add.w	d7,a0
	move.l	(a0),a0
jm	jmp	(a0)
		
farg7	move.l	d3,(a5)+
	move.w	d0,(a5)+
	or.w	d1,(a6,d0.w)
	or.w	d1,2(a6,d0.w)
	or.w	d1,4(a6,d0.w)
	dbf	d2,rita
	move.w	#$4e75,(a5)
	rts	  
farg1	move.l	d0,(a5)+
	or.w	d1,(a6,d0.w)
	dbf	d2,rita
	move.w	#$4e75,(a5)
	rts	
farg2	move.l	d3,(a5)+
	move.w	d0,(a5)+
	or.w	d1,2(a6,d0.w)
	dbf	d2,rita
	move.w	#$4e75,(a5)
	rts	
farg3	move.l	d3,(a5)+
	move.w	d0,(a5)+
	or.w	d1,(a6,d0.w)
	or.w	d1,2(a6,d0.w)
	dbf	d2,rita
	move.w	#$4e75,(a5)
	rts	
farg4	move.l	d3,(a5)+
	move.w	d0,(a5)+
	or.w	d1,4(a6,d0.w)
	dbf	d2,rita
	move.w	#$4e75,(a5)
	rts	
farg5	move.l	d3,(a5)+
	move.w	d0,(a5)+
	or.w	d1,(a6,d0.w)
	or.w	d1,4(a6,d0.w)
	dbf	d2,rita
	move.w	#$4e75,(a5)
	rts	
farg6	move.l	d3,(a5)+
	move.w	d0,(a5)+
	or.w	d1,2(a6,d0.w)
	or.w	d1,4(a6,d0.w)
	dbf	d2,rita
	move.w	#$4e75,(a5)
	rts	

jumps	dc.l	farg7,farg7,farg6,farg5,farg4,farg3,farg2,farg1,jm+2
;*****************************************************************
;**  Draw point: calc routs  **
;******************************
drw_clc	lea	y_preps(pc),a0
	add.l	#y_scr,a0
	move.l	#0,d1
	move.l	#200-1,d0		200 rader
dr_clc_lpy	move.l	d1,d2		spara d1
	mulu	#160,d2		160 bytes per rad
	move.w	d2,(a0)+		spara till y_preprtabellen
	addq.l	#1,d1		nasta rad
	dbf	d0,dr_clc_lpy
;********************************************************************************
	lea	x_preps,a0
	add.l	#x_scr*2,a0
	move.l	#0,d1
	move.l	#320-1,d0		320 pixels per rad
dr_clc_lpx	move.l	d1,d2		spara d1
	divu	#16,d2		
	move.l	d2,d3		spara d2
	lsl.w	#3,d3		*8(ratt byte/word)	
		
	swap	d2
	move.w	#15,d4		
	sub.w	d2,d4		15-d2(ratt bit (omvant))
	move.w	#1,d2		
	lsl.w	d4,d2		ratt or varde
	swap	d2		or vardet overst
	move.w	d3,d2		byte vardet underst
	move.l	d2,(a0)+		spara i x_prepstabellen
	addq.l	#1,d1
	dbf	d0,dr_clc_lpx
	rts
;*********************************************
screenchg	cmp.l	#$f8000,screen
	beq	chg_it
	move.l	#savs,nowthis
	move.l	#$f8000,screen
	move.b	#$0f,$ffff8201
	move.b	#$80,$ffff8203
	rts
chg_it	move.l	#savs2,nowthis
	move.l	#$f0000,screen
	move.b	#$0f,$ff8201
	move.b	#$00,$ff8203
            rts          
;*****************************************************
;* Slump kordinater *
;********************
random	lea	ur_cords,a6
	move.l	#nr_pnts*3,d6
looopy	move.w	#$11,-(sp)
	trap	#14
	addq.l	#2,sp
	and.w	#helan-1,d0
	move.w	d0,(a6)+
	dbf	d6,looopy
	
;************************************************
;* Fixa perspectiv preps *
;*************************
	lea	pre_z,a0
	move.l	#helan-1,d1
z_1_lp	move.l	#helan-1,d0
	move.l	#0,d2

x_1_lp	move.l	d1,d6		get z-varde
	move.l	d2,d4		get x,y varde
	sub.w	#halvan,d4		
	lsl.w	#2,d4		lagom factor(storlek)
	move.w	d4,d7		spara for add
	
	neg.w	d6		omvand for ratt bitpl
	add.w	#helan,d6		
	
	muls	d6,d4			
	add.w	#34,d6		avstand fran screen
	neg	d6
	divs.w	d6,d4
	add.w	d7,d4

	move.w	d4,(a0)+		spara
	addq.l	#1,d2		oka x,y varde
	dbf	d0,x_1_lp
	dbf	d1,z_1_lp
	rts
;**************************************************************************
;*** Fixar dvs kurvor,z_adder,mm   			     	***
;**************************************************************************
studs	lea	runt_kurv,a1	kurvor mm i a1
	lea	varden,a4
	move.l	#2-1,d7

lopy	lea	sin_tab,a0		sin kurva i a0
	move.l	#0,d3		noll fran borjan	
	move.l	#360-1,d0		360 grader=1 varv
	moveq.l	#14,d2		lsr data (=divu 2^14)
;*************************************************************************
;* X varden *
;************
kurv_lp	move.w	(a0)+,d1		hamta sin varde
	muls	(a4),d1		(* 100)
	lsr.l	d2,d1		(/16384)
mer_test3	cmp.w	#helan,d1
	ble	klar4
	sub.w	#helan,d1	
	bra	mer_test3
klar4	cmp.w	#-helan,d1
	bge	klar5
	add.l	#helan,d1
	bra	klar4
klar5	
	move.w	d1,(a1)+		spara undan X-varde
	
;*************************************************************************
;* Y-varden *
;************
	move.w	178(a0),d4		hamta cos (sin+2+88) 
	muls	2(a4),d4		(* 300)
	lsr.l	d2,d4		dela lite

mer_test2	cmp.w	#helan,d4
	ble	klar2
	sub.w	#helan,d4	
	bra	mer_test2
klar2	cmp.w	#-helan,d4
	bge	klar3
	add.l	#helan,d4
	bra	klar2
klar3	
	move.w	d4,(a1)+		spara undan z_adder

;*************************************************************************
;* Z-varden *
;************
	lea	sin_tab,a2		sin kurva i a2
	add.w	4(a4),d3		oka adder
	add.l	d3,a2		fram i kurvan
	cmp.w	#360*2,d3		testa slut
	blt	so_what		 inte so what
	move.l	#0,d3		 annars nolla adder
	
so_what	move.w	(a2),d1		hamta studs-sin varde
	
	muls	6(a4),d1			
	lsr.l	d2,d1
	add.w	6(a4),d1
mer_test	cmp.w	#helan,d1
	ble	klar
	sub.w	#helan,d1	
	bra	mer_test
klar	move.w	d1,(a1)+		spara undan y-varde
	dbf	d0,kurv_lp		igen?
	add.w	#8,a4	
	dbf	d7,lopy

	move.w	#-10000,(a1)
	move.w	#-10000,(a1)
	move.w	#-10000,(a1)	
	rts

varden	dc.w	helan,helan,4,helan
	dc.w	helan,helan,4,helan
;***********************************************
screen	dc.l	$f8000
nowthis	ds.l	1
add3	dc.l	0
my_x	dc.w	0
my_y	dc.w	0
my_z	dc.w	0

sin_tab	dc.w	0,286,572,857,1143,1428,1713,1997,2280
	dc.w	2563,2845,3126,3406,3686,3964,4240,4516
	dc.w	4790,5063,5334,5604,5872,6138,6402,6664
	dc.w	6924,7182,7438,7692,7943,8192,8438,8682
	dc.w	8923,9162,9397,9630,9860,10087,10311,10531
	dc.w	10749,10963,11174,11381,11585,11786,11982,12176
	dc.w	12365,12551,12733,12911,13085,13255,13421,13583
	dc.w	13741,13894,14044,14189,14330,14466,14598,14726
	dc.w	14849,14962,15082,15191,15296,15396,15491,15582
	dc.w	15668,15749,15826,15897,15964,16026,16083,16135
	dc.w	16182,16225,16262,16294,16322,16344,16362,16374
	dc.w	16382

costab	dc.w	16384
	dc.w	16382,16374,16362,16344,16322,16294,16262,16225
	dc.w	16182
	dc.w	16135,16083,16026,15964,15897,15826,15749,15668
	dc.w	15582,15449,15396,15296,15191,15082,14962,14849
	dc.w	14726,14598,14466,14330,14189,14044,13894,13741
	dc.w	13583,13421,13255,13085,12911,12733,12551,12365
	dc.w	12176,11982,11786,11585,11381,11174,10963,10749
	dc.w	10531,10311,10087,9860,9630,9397,9162,8923
	dc.w	8682,8438,8192,7943,7692,7438,7182,6924
	dc.w	6664,6402,6138,5872,5604,5334,5063,4790
	dc.w	4516,4240,3964,3686,3406,3126,2845,2563
	dc.w	2280,1997,1713,1428,1143,857,572,286,0
	
	dc.w	-286,-572,-857,-1143,-1428,-1713,-1997,-2280
	dc.w	-2563,-2845,-3126,-3406,-3686,-3964,-4240,-4516
	dc.w	-4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
	dc.w	-6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682
	dc.w	-8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
	dc.w	-10749,-10963,-11174,-11381,-11585,-11786,-11982,-12176
	dc.w	-12365,-12551,-12733,-12911,-13085,-13255,-13421,-13583
	dc.w	-13741,-13894,-14044,-14189,-14330,-14466,-14598,-14726
	dc.w	-14849,-14962,-15082,-15191,-15296,-15396,-15491,-15582
	dc.w	-15668,-15749,-15826,-15897,-15964,-16026,-16083,-16135
	dc.w	-16182,-16225,-16262,-16294,-16322,-16344,-16362,-16374
	dc.w	-16382,-16384

	dc.w	-16382,-16374,-16362,-16344,-16322,-16294,-16262,-16225
	dc.w	-16182
	dc.w	-16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668
	dc.w	-15582,-15449,-15396,-15296,-15191,-15082,-14962,-14849
	dc.w	-14726,-14598,-14466,-14330,-14189,-14044,-13894,-13741
	dc.w	-13583,-13421,-13255,-13085,-12911,-12733,-12551,-12365
	dc.w	-12176,-11982,-11786,-11585,-11381,-11174,-10963,-10749
	dc.w	-10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
	dc.w	-8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
	dc.w	-6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
	dc.w	-4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
	dc.w	-2280,-1997,-1713,-1428,-1143,-857,-572,-286,0
	
	dc.w	286,572,857,1143,1428,1713,1997,2280
	dc.w	2563,2845,3126,3406,3686,3964,4240,4516
	dc.w	4790,5063,5334,5604,5872,6138,6402,6664
	dc.w	6924,7182,7438,7692,7943,8192,8438,8682
	dc.w	8923,9162,9397,9630,9860,10087,10311,10531
	dc.w	10749,10963,11174,11381,11585,11786,11982,12176
	dc.w	12365,12551,12733,12911,13085,13255,13421,13583
	dc.w	13741,13894,14044,14189,14330,14466,14598,14726
	dc.w	14849,14962,15082,15191,15296,15396,15491,15582
	dc.w	15668,15749,15826,15897,15964,16026,16083,16135
	dc.w	16182,16225,16262,16294,16322,16344,16362,16374
	dc.w	16382,16384,16382

y_preps	dcb.w	y_scr,200*160
savs	dcb.w	nr_pnts*4,$4e75
savs2	dcb.w	nr_pnts*4,$4e75

	section	bss
x_preps	ds.l	x_scr
sorted	ds.w	nr_pnts*3
ur_cords	ds.l	3*nr_pnts
runt_kurv	ds.l	600*10
pre_z	ds.w	helan*helan