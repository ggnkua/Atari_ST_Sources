*************************************************************************
 ********          - DELTA FORCE ICC #2 DEMO SCREEN -           ********
  *******                                                       *******
   ******              (C)1991 BY NUCLEUS OF NAOS               ******
    *****************************************************************

nb_stars	equ	20
speed	equ	8	
iera	equ 	$fffa07
ierb	equ 	$fffa09
imra	equ	$fffa13
isra	equ	$fffa0f
tbcr	equ	$fffa1b
tbdr	equ	$fffa21

	text

************* VERSION DEFINITIVE: COUPER A PARTIR D'ICI... ***************
	
	pea	0
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	move.l	d0,sv_stack
	
	move.l	$466,d0
sync	cmp.l	$466,d0
	beq	sync
	move.b	#0,$ffff8260.w
	move.l	$ffff8200.w,old_scr
			
	move.w	#$2700,sr
	move.b	iera,sv_mfp
	move.b	ierb,sv_mfp+1
	move.l	$120,sv_mfp+2
	
	move.b	#$0,$484

	lea	$ffff8240.w,a0
	lea	sv_pal,a1
	moveq	#7,d0
pal_sv	move.l	(a0),(a1)+
	dbra	d0,pal_sv

	move.l	$70.w,sv_vbl
	
****************************** ...JUSQU'ICI ******************************	

*	clr.b	iera
*	clr.b	ierb
*	move.l	#timer_b,$120.w
*	ori.b	#1,iera
*	ori.b	#1,imra
*	clr.b	tbcr
	
	lea	$ffff8240.w,a1
	lea	img+2,a2
	lea	palette,a3
	moveq	#7,d0
pal_cop	move.l	(a2)+,(a3)+
	clr.l	(a1)+
	dbra	d0,pal_cop
	
	move.w	#$ffff,st_mode	
	clr.w	ox
	clr.w	oy
	clr.w	oz
	move.w	#10,vx
	move.w	#0,vy
	move.w	#20,vz
	
	move.l	#$1,act_dec
	move.w	#8,dec		
	move.w	#128,act_de1
	move.l	#ctxt,act_txt		
	move.l	#sin,act_sin
			
	lea	sin,a0
	lea	14420(a0),a2
	lea	sin_dat,a1
	move.w	#3604,d0
copysin	move.l	(a1),(a0)+
	move.l	(a1)+,(a2)+	
	dbra d0,copysin
	
	move.l	#courbe,act_courbe
	
	clr.b	flag
	
	move.l	#coultab,act_coul
			
	lea	er_buf,a0
	move.w	#49,d0
clbuf	clr.l	(a0)+
	dbra	d0,clbuf

	moveq	#$1,d0
	jsr	zic

	bsr	initspr

	bsr	gen_code
		
	bsr	codetxt
	
	bsr	initflag

	move.l	#fnt_dat,d0
	and.l	#$ffffff00,d0
	add.l	#$100,d0
	move.l	d0,act_sc1
	move.l	d0,ad_ecran
	move.l	#video2,d0
	and.l	#$ffffff00,d0
	add.l	#$100,d0
	move.l	d0,act_sc2
	
	move.l	act_sc1,a0
	move.l	act_sc2,a1
	move.w	#7999,d0
cls	clr.l	(a0)+
	clr.l	(a1)+
	dbra	d0,cls	
	
	move.l	ad_ecran,d0
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.l	#8,d0
	move.b	d0,$ffff8201.w

	clr.w	t_f_out
	move.w	#16,t_fad1		
	move.w	#1,t_fade		

	move.l	#vbl,$70.w
	move.w	#$2300,sr
	
wait	move.w	#1,vsync	
bclvbl	tst.w	vsync
	bne	bclvbl
	move.b	$fffffc02.w,d0
	cmp.b	#$61,d0
	bne	tst0
	move.w	#1,st_mode
tst0	cmp.b	#$62,d0
	bne	tst00
	move.w	#0,st_mode	
tst00	cmp.b	#$0f,d0
	bne	tst1
	move.w	#$007,$ffff8240.w
tst1	tst.w	st_mode
	beq	spc
	cmp.b	#$4b,d0
	bne tst2
	sub.w	#1,vx
tst2	cmp.b	#$4d,d0
	bne	tst3
	add.w	#1,vx
tst3	cmp.b	#$48,d0
	bne	tst4
	add.w	#1,vy
tst4	cmp.b	#$50,d0
	bne	tst5
	sub.w	#1,vy
tst5	cmp.b	#$52,d0
	bne	tst6					
	add.w	#1,vz
tst6	cmp.b	#$47,d0
	bne	spc
	sub.w	#1,vz	
spc	cmp.b	#$39,d0
	bne	wait	

	cmp.w	#16,t_flag
	blo	noflag
	move.w	#16,t_flag
noflag	move.w	#16,t_f_out
	move.w	#15,d0
waiten1	
	move.w	#1,vsync
waitvb1	tst.w	vsync
	bne	waitvb1
	move.b	$fffffc02.w,d1
	dbra	d0,waiten1	

*************************** PUIS COUPER D'ICI... *************************	

	move.l	sv_vbl,$70.w

	move.b	sv_mfp,iera
	move.b	sv_mfp+1,ierb
	move.l	sv_mfp+2,$120
	
	move.l	#$08080000,$ffff8800.w
	move.l	#$09090000,$ffff8800.w
	move.l	#$0a0a0000,$ffff8800.w
	
	move.b	#$ff,$484

	move.l	old_scr,$ffff8200.w
		
	lea	$ffff8240.w,a0
	lea	sv_pal,a1
	moveq	#7,d0
restpal	move.l	(a1)+,(a0)+
	dbra	d0,restpal
	
	move.l	sv_stack,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	
	clr.w	-(sp)
	trap	#1

****************** ...A LA, ET AJOUTER CES TROIS LIGNES: *****************
*	move.l	#rte,$70.w
*	rts
*rte	rte


vbl	movem.l	d0-d7/a0-a6,-(sp)

	clr.b	tbcr
	move.b	#199,tbdr
	move.b	#8,tbcr
		
	clr.w	vsync
	
	clr.w	$ffff8240.w
	
	tst.w	t_fad1
	beq	suitf
	sub.w	#1,t_fad1
	
	tst.w	t_fade
	beq	no_fade
	clr.w	t_fade
	
	lea	palette,a1
	lea	$ffff8240.w,a0
	moveq	#15,d0
colorin	move.w	(a0),d1
	move.w	(a1)+,d4
	move.w	d1,d2
	move.w	d4,d5
	and.w	#$007,d2
	and.w	#$007,d5
	cmp.w	d2,d5
	beq	blue_on
	add.w	#$001,d1
blue_on	move.w	d1,d2
	move.w	d4,d5
	and.w	#$070,d2
	and.w	#$070,d5
	cmp.w	d2,d5
	beq	green_on
	add.w	#$010,d1
green_on	
	move.w	d1,d2
	move.w	d4,d5
	and.w	#$700,d2
	and.w	#$700,d5
	cmp.w	d2,d5
	beq	red_on
	add.w	#$100,d1
red_on	move.w	d1,(a0)+
	dbra	d0,colorin
	bra	suitf				
no_fade	move.w	#1,t_fade

suitf	tst.w	t_f_out
	beq	sui_out
	tst.w	t_fade
	beq	nof_out
	clr.w	t_fade
	moveq	#15,d0
	lea	$ffff8240.w,a0
fad_out	move.w	(a0),d1
	move.w	d1,d2
	and.w	#$700,d2
	tst.w	d2
	beq	r_off
	sub.w	#$100,d1
r_off	move.w	d1,d2
	and.w	#$070,d2
	tst.w	d2
	beq	g_off
	sub.w	#$010,d1
g_off	move.w	d1,d2
	and.w	#$007,d2
	tst.w	d2
	beq	b_off
	sub.w	#$001,d1
b_off	move.w	d1,(a0)+			
	dbra	d0,fad_out	
	bra	sui_out
nof_out	move.w	#1,t_fade
sui_out	jsr	zic+6
	
	move.l	ad_ecran,d0
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.l	#8,d0
	move.b	d0,$ffff8201.w

	tst.b	flag
	bne	other
	bsr	distort
	bra	end
other	cmp.b	#1,flag
	bne	other1
	bsr	logo
	bra	end	
other1	
	bsr	france	
end	bsr	erase
	
	lea	stars,a0
	move.l	ad_ecran,a1
	lea	er_b1,a3
	lea	spr_dat,a4
	tst.w	st_mode
	bne	mode_1
	move.l	act_courbe,a2
	move.w	(a2)+,d3
	move.w	(a2)+,d4
	move.w	(a2)+,d5
	bra	st_move
mode_1	move.w	ox,d3
	move.w	oy,d4
	move.w	oz,d5
	move.w	vx,d0
	move.w	vy,d1
	move.w	vz,d2
	asr.w	#2,d0
	asr.w	#2,d1
	asr.w	#1,d2
	add.w	d0,d3
	add.w	d1,d4
	add.w	d2,d5
	cmp.w	#-160,d3
	bgt	out1
	add.w	#320,d3
out1	cmp.w	#-100,d4
	bgt	out2
	add.w	#200,d4
out2	cmp.w	#-880,d5
	bgt	out3
	add.w	#1280,d5
out3	cmp.w	#160,d3
	bmi	out4
	sub.w	#320,d3
out4	cmp.w	#100,d4
	bmi	out5
	sub.w	#200,d4
out5	cmp.w	#400,d5
	bmi	out6
	sub.w	#1280,d5
out6	move.w	d3,ox
	move.w	d4,oy
	move.w	d5,oz
st_move	move.w	#nb_stars-1,d7
stbcl	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	add.w	d3,d0
	add.w	d4,d1
	add.w	d5,d2
	cmp.w	#-160,d0
	bgt	ou1
	add.w	#320,d0
ou1	cmp.w	#-100,d1
	bgt	ou2
	add.w	#200,d1
ou2	cmp.w	#-880,d2
	bgt	ou3	
	add.w	#1280,d2
ou3	cmp.w	#160,d0
	bmi	ou4
	sub.w	#320,d0
ou4	cmp.w	#100,d1
	bmi	ou5
	sub.w	#200,d1
ou5	cmp.w	#400,d2
	bmi	ou6	
	sub.w	#1280,d2
ou6	move.l	d7,-(sp)

******* PROJECTION ********

	ext.l	d0
	ext.l	d1
	ext.l	d2
	
	*	asr.l	#2,d2	; '*512' '/2048' = '/4'
	* -> par ex: si pt_fuite=256, '*512' '/256' = '*2'
	*			-> asl.l	#1,d2 ;10 cycles 
	*	asr.l	#1,d2

	move.w	#512,d6
	sub.w	d2,d6
	moveq	#9,d7
	asl.l	d7,d0
	asl.l	d7,d1
	
	divs	d6,d0	; xp
	divs	d6,d1	; yp
	add.w	#152,d0
	add.w	#96,d1
*	add.w	#118,d1

******** AFFICHAGE *********
	
	cmp.w	#304,d0
	bgt	nopoint
	tst.w	d0
	bmi	nopoint
	cmp.w	#192,d1
*	cmp.w	#236,d1
	bgt	nopoint
	tst.w	d1
	bmi	nopoint

	move.w	d0,d6

	mulu	#160,d1
	lsr.w	#1,d0
	and.w	#$fff8,d0
	add.w	d0,d1
	
	and.w	#15,d6
	
	add.w	#880,d2
	lsr.w	#4,d2
	and.w	#$fff8,d2
	add.w	(a4,d2.w),d1		*d1=offset ecran
	move.w	2(a4,d2.w),d0		*d0=nb de lignes/sprites
		
	mulu	#1280,d6	
	add.l	4(a4,d2.w),d6
	movea.l	d6,a5			*sprite / source
	
	move.w	d1,(a3)+
	move.w	d0,(a3)+
	
	lea	(a1),a6			*ecran / destination
	add.w	d1,a6
	
affiche	movem.l	(a5)+,d1/d2/d6/d7
	and.l	d6,(a6)
	or.l	d1,(a6)+
	and.l	d6,(a6)+
	and.l	d7,(a6)
	or.l	d2,(a6)+
	and.l	d7,(a6)+
	lea	144(a6),a6
	dbra	d0,affiche
	
nopoint	move.l	(sp)+,d7 

	dbra	d7,stbcl
	tst.w	st_mode
	bne	swap
	lea	courbe+17280,a1
	cmp.l	a2,a1
	bgt	sm_c
	lea	courbe,a2
sm_c	move.l	a2,act_courbe
	
swap	move.l	act_sc1,d0
	move.l	act_sc2,d1
	move.l	d1,act_sc1
	move.l	d0,act_sc2
	move.l	act_sc1,ad_ecran

	movem.l	(sp)+,d0-d7/a0-a6
	rte

*timer_b	clr.b	tbcr
*	move.w	#$700,$ffff8240.w
*	movem.l	d0/a0,-(sp)
*	move.l	#tbdr,a0
*	move.b	#200,(a0)
*	move.b	#8,tbcr
*	move.b	(a0),d0
*wait2	cmp.b	(a0),d0
*	beq	wait2
*	clr.b	$ffff820a.w
*	move.w	#$070,$ffff8240
*	rept	12
*	nop
*	endr
*	move.b	#2,$ffff820a.w
*	clr.w	$ffff8240.w
*	clr.b	tbcr
*	movem.l	(sp)+,d0/a0
*	bclr	#0,isra
*	rte
	
france	
	move.l	ad_ecran,a5
	bsr	er_frce
	sub.w	#1,t_flag
	bhi	putflag
	clr.b	flag
	add.l	#2400,actflag
	move.w	#$000,$ffff8248.w
	move.w	#$000,$ffff8250.w
	move.w	#$000,$ffff8258.w
	move.l	act_sc2,a5
	bsr	er_frce
	move.w	#$557,$ffff8248.w
	move.w	#$337,$ffff8250.w
	bra	lastfl
putflag	cmp.w	#346,t_flag
	blo	f_is_on
	tst.w	t_f_out
	bne 	f_is_on
	move.l	act_fc,a0
	move.w	(a0)+,$ffff8248.w
	move.w	(a0)+,$ffff8250.w
	move.w	(a0)+,$ffff8258.w
	move.l	a0,act_fc
f_is_on	cmp.w	#14,t_flag
	bhi	stay_on
	move.l	act_fc,a0
	move.w	(a0)+,$ffff8248.w
	move.w	(a0)+,$ffff8250.w
	move.w	(a0)+,$ffff8258.w	
	move.l	a0,act_fc
stay_on	move.l	ad_ecran,a0
	lea	32(a0),a0
	move.l	actflag,a1
	rept	200
	move.w	(a1)+,d0
	move.w	(a1)+,d1
	or.w	d1,4(a0,d0.w)
	endr
	rept	200
	move.w	(a1)+,d0
	move.w	(a1)+,d1
	or.w	d1,6(a0,d0.w)
	endr
	rept	200
	move.w	(a1)+,d0
	move.w	(a1)+,d1
	or.w	d1,4(a0,d0.w)
	or.w	d1,6(a0,d0.w)
	endr
	lea	preflag+86400,a0
	cmp.l	a1,a0
	bhi	smflag
	lea	preflag,a1
smflag	move.l	a1,actflag
lastfl	rts

er_frce	
	lea	preflag+4800,a0
	move.l	actflag,a1
	cmp.l	a0,a1
	bhs	subfl
	adda.l	#81600,a1
	bra	doer	
subfl	lea	-4800(a1),a1
doer	
	lea	32(a5),a5
	moveq	#0,d0
	rept	600
	move.w	(a1)+,d1
	lea	2(a1),a1
	move.l	d0,4(a5,d1.w)
	endr	
	rts
	
logo
	move.l	act_coul,a0
	cmp.w	#$888,(a0)
	bne	fade
	move.l	#coultab,act_coul
	clr.b	flag
	move.l	act_sc1,a0
	move.l	act_sc2,a1
	moveq	#0,d1
	moveq	#19,d0
clrp1	
index	set	4
	rept	200
	move.w	d1,index(a0)	
	move.w	d1,index(a1)	
index	set	index+160
	endr
	lea	8(a0),a0
	lea	8(a1),a1
	dbra	d0,clrp1
	move.w	#$557,$ffff8248.w
	bra	logoff
	
fade	tst.w	t_f_out
	bne	offquit
	move.w	(a0)+,$ffff8248.w
offquit	move.l	a0,act_coul
	
	move.l	ad_ecran,a0
	lea	log_dat,a1
	move.w	#199,d0
pym	
index	set	4
	rept	20
	move.w	(a1)+,index(a0)
index	set	index+8
	endr	
	lea	160(a0),a0
	dbra	d0,pym

logoff	rts
	
distort	
	move.l	ad_ecran,a0
	move.l	act_sin,a1
	lea	64(a1),a1
	moveq	#0,d7
	move.w	#19,d6
clr_1p	lea	4(a0),a2
	add.w	(a1),a2
	lea	-160*9(a2),a2
index	set	0	
	rept	50
	move.l	d7,index(a2)
index	set	index+160	
	endr
	lea	8(a0),a0
	lea	32(a1),a1
	dbra	d6,clr_1p	
	
	move.l	act_sin,a1
	move.w	act_de1,d0
	move.w	dec,d1
	move.l	ad_ecran,a6
	lea	4(a6),a6
	lea	-16(a6),a2
	add.l	d0,a1
	add.w	d1,a2
	move.l	act_txt,a3
	move.l	act_dec,d2
	move.l	(a3)+,a4
	jsr	(a4)
	move.l	(a3)+,a4
	jsr	(a4)
	moveq	#0,d7
	lea	clipbuf,a5
index	set	0
	rept	200
	move.l	index(a6),(a5)+
	move.l	index+8(a6),(a5)+
	move.l	d7,index-8(a6)
	move.l	d7,index-16(a6)
index	set	index+160
	endr
	move.w	#8,d1
lin2	
	move.l	(a3)+,a4
	jsr	(a4)
	dbra	d1,lin2
	move.l	ad_ecran,a2
	lea	4(a2),a2
index	set	0
	rept	200
	move.l	d7,index(a2)		
	move.l	d7,index+8(a2)		
index	set	index+160
	endr
	lea	clipbuf,a5
index	set	0	
	rept	200
	move.l	(a5)+,index(a6)
	move.l	(a5)+,index+8(a6)
index	set	index+160
	endr
	sub.w	#4,act_de1
	move.l	act_dec,d0
	lsl.w	#2,d0
	bne	samelet
	moveq	#$1,d0
	sub.w	#8,dec
	beq	samelet
	move.w	#64,act_de1
	move.w	#8,dec
	add.l	#4,act_txt
samelet	move.l	d0,act_dec
	lea	sin+14420,a0
	move.l	act_sin,a1
	lea	speed(a1),a1
	cmp.l	a0,a1
	blo	same_sin
	lea	-14420(a1),a1
same_sin	move.l	a1,act_sin
	rts
		
erase	lea	er_buf,a0
	move.l	ad_ecran,a1
	moveq	#0,d1
	move.w	#nb_stars-1,d0
efface	lea	(a1),a2
	add.w	(a0)+,a2
	move.w	(a0)+,d2
effbcl	move.l	d1,(a2)
	move.l	d1,8(a2)
	lea	160(a2),a2	
	dbra	d2,effbcl
	dbra	d0,efface
	
	lea	er_b1,a1
	lea	er_buf,a0
	rept	nb_stars
	move.l	(a1)+,(a0)+
	endr
	rts
	
initflag	
	lea	flagdat,a0
	lea	preflag,a1
	lea	motif,a2
	move.w	#35,d7
iflag1	move.w	#29,d6
iflag2	moveq	#0,d0
	move.b	(a0)+,d0
	add.b	#22,d0
	mulu	#160,d0
	move.w	#19,d5
iflag3	moveq	#0,d2
	moveq	#0,d3
	move.w	d0,d1
	move.b	(a0)+,d2
	move.b	d2,d3
	lsr.w	#1,d2
	and.b	#$f8,d2
	add.w	d2,d1
	lsl.w	#1,d2
	sub.w	d2,d3
	lsl.w	#1,d3
	move.w	#19,d4
	sub.w	d5,d4
	mulu	#800,d4
	add.w	d4,d1
	move.w	d1,(a1)+
	move.w	0(a2,d3.w),(a1)+
	dbra	d5,iflag3
	dbra	d6,iflag2
	dbra	d7,iflag1	
	rts
	
initspr	lea	pre_spr,a1
	moveq	#15,d0
eachspr	moveq	#9,d1
	lea	img+34,a0
copyspr			
index	set	0
	rept	8
	move.l	index(a0),(a1)+
	move.l	index+8(a0),(a1)+
	move.w	index+4(a0),(a1)+
	move.w	index+4(a0),(a1)+
	move.w	index+12(a0),(a1)+
	move.w	index+12(a0),(a1)+
index	set	index+160
	endr
	lea	16(a0),a0
	dbra	d1,copyspr
	dbra	d0,eachspr
	moveq	#14,d0
dec1	moveq	#15,d1
	lea	pre_spr,a1
	sub.w	d0,d1
	mulu	#1280,d1
	add.l	d1,a1
	move.w	d0,d3
eachde1	moveq	#9,d2
eachdec				
index	set	0
	rept	8
	move	#0,ccr
	roxr.w	index(a1)
	roxr.w	index+4(a1)
	move	#0,ccr
	roxr.w	index+2(a1)
	roxr.w	index+6(a1)
	move	#%00010000,ccr
	roxr.w	index+8(a1)
	roxr.w	index+12(a1)
	move	#%00010000,ccr
	roxr.w	index+10(a1)
	roxr.w	index+14(a1)
index	set	index+16
	endr
	lea	128(a1),a1
	dbra	d2,eachdec
	dbra	d3,eachde1
	dbra	d0,dec1
	rts	

codetxt
	lea	ctxt,a1
	lea	texte,a0
	lea	tab_gen,a2
bclcode	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#255,d0
	beq	endcode
	cmp.b	#32,d0
	bne	sc
	move.l	#space,(a1)+
	bra	bclcode
sc	cmp.b	#100,d0
	bne	sc1
	move.l	#effect1,(a1)+
	bra	bclcode
sc1	cmp.b	#101,d0
	bne	sc2
	move.l	#effect2,(a1)+
	bra	bclcode 
sc2	sub.b	#65,d0
	lsl.w	#2,d0
	move.l	0(a2,d0.w),(a1)+
	bra	bclcode
endcode	move.l	#last,(a1)
	rts		

gen_code	lea	code_buf,a0
	lea	fnt_dat,a1
	lea	tab_gen,a3
	moveq	#0,d7
	move.w	#29,d0
each_let	move.w	#29,d1
	move.l	a0,(a3)+
each_x	lea	header,a2
	move.l	(a2)+,(a0)+
	move.w	(a2)+,(a0)+
	move.w	#7,d2
each_y	move.b	(a1)+,d7
	move.w	#%11000000,d5
	move.w	#3,d3
each_1	move.b	d7,d6
	and.b	d5,d6
	lsr.w	#2,d5
	move.w	d3,d4
	lsl.w	#1,d4
	lsr.w	d4,d6
	tst.b	d6
	beq	nopoin
	cmp.b	#1,d6
	bne	color2
	move.l	(a2),(a0)+
	bra	nopoin
color2	move.l	4(a2),(a0)+
nopoin	lea	8(a2),a2
	dbra	d3,each_1
	dbra	d2,each_y
	move.w	#7,d3
copyend	move.w	(a2)+,(a0)+
	dbra	d3,copyend
	dbra	d1,each_x
	move.w	#18,d3
copyend2	move.w	(a2)+,(a0)+
	dbra	d3,copyend2
	dbra	d0,each_let
	rts
					
header	
	lea	0(a2),a0
	add.w	(a1)+,a0
index	set	0
	rept	32
	or.w	d2,index(a0)
	or.w	d2,index+2(a0)
index	set	index+160
	endr		
	lsr.w	#1,d2
	bne	proto1
	move.l	#$8000,d2
	lea	8(a2),a2
proto1	lea	4(a1),a1
	lsr.w	#1,d2
	bne	proto2
	move.l	#$8000,d2
	lea	8(a2),a2
proto2	lsr.w	#1,d2
	bne	proto3
	move.l	#$8000,d2
	lea	8(a2),a2
proto3	rts

last	move.l	#ctxt,act_txt
	rts
	
effect1	
	move.b	#1,flag
	add.l	#44,act_txt
	rts	

effect2	
	move.l	#flagcol,act_fc
	move.w	#360,t_flag
	move.l	#preflag,actflag
	move.b	#2,flag
	add.l	#44,act_txt
	rts	

space	
	moveq	#31,d0
spbcl	
	lsr.w	#1,d2
	bne	spplan
	move.l	#$8000,d2
	lea	8(a2),a2
spplan	
	dbra	d0,spbcl
	lea	64(a1),a1
	rts

	data
	
motif	dc.w	32768,16384,8192,4096,2048,1024,512,256,128,64,32,16,8,4,2,1		
coultab	dc.w	$000,$000,$111,$111,$222,$222,$333,$333,$444,$444,$555,$555,$666,$666,$777,$777
	rept	50
	dc.w	$777
	endr
	dc.w	$666,$666,$555,$555,$444,$444,$333,$333,$222,$222,$111,$111,$000,$888
flagcol	dc.w	$001,$111,$100,$001,$111,$100,$002,$222,$200,$002,$222,$200,$003,$333,$300,$003,$333,$300
	dc.w	$004,$444,$400,$004,$444,$400,$005,$555,$500,$005,$555,$500,$006,$666,$600,$006,$666,$600
	dc.w	$007,$777,$700,$007,$777,$700
	dc.w	$006,$666,$600,$006,$666,$600,$005,$555,$500,$005,$555,$500,$004,$444,$400,$004,$444,$400
	dc.w	$003,$333,$300,$003,$333,$300,$002,$222,$200,$002,$222,$200,$001,$111,$100,$001,$111,$100
	dc.w	$000,$000,$000,$000,$000,$000
spr_dat	dc.w	480,2
	dc.l	pre_spr+1152
	dc.w	320,3
	dc.l	pre_spr+1024
	dc.w	320,4
	dc.l	pre_spr+896
	dc.w	320,4
	dc.l	pre_spr+768
	dc.w	160,5
	dc.l	pre_spr+640
	dc.w	160,5
	dc.l	pre_spr+512
	dc.w	160,6
	dc.l	pre_spr+384
	dc.w	160,6
	dc.l	pre_spr+256
	dc.w	0,7
	dc.l	pre_spr+128
	dc.w	0,7
	dc.l	pre_spr

texte	dc.b	"           "
	dc.b	"CAPTAIN DANEEL CANUT IS NOW FLYING TO ANOTHER WORLD["
	DC.B	" NO ONE KNOWS IF HE WILL SUCCEED IN HIS MISSION["
	DC.B	" WE CAN JUST SAY THAT IT]S GONNA BE DIFICULT]]] MAY"
	DC.B	" THE FORCE BE WITH YOU]]]"
	dc.b	"           ",100,"           "
	DC.B	"IF YOU DON[T SEE ANY OBJECTION LET US COME BACK ON THE "
	DC.B	"EARTH] OUR TIME CRAFT IS GOING TO LEAD US IN THE CURRENT YEAR]"
	DC.B	" WE ARE NOW IN SUMMER AFTER A FEW HEAVENS WE ARE FLYING OVER"
	DC.B	" THE ATLANTIC OCEAN] WE CAN SEE FRANCE NOW ]]]"
	dc.b	"          ",101,"           "
	DC.B	"]]] HERE COMES GERMANY] LET[S LAND NEAR STUTTGART"
	DC.B	" IN A LITTLE TOWN CALLED LEUTENBACH] THE INTERNATIONAL"
	DC.B	" CODING CONFERENCE ORGANISED BY DELTA FORCE TAKES PLACE THERE]"
	dc.b	"           ",100,"           "
	DC.B	" YOU ARE WATCHING THE CONTRIBUTION OF NAOS TO THE ICC PARTY DEMO["
	DC.B	" SIX PEOPLE BELONG TO NAOS   ARAGORN NUCLEUS AND RIC TRY TO MASTER"
	DC.B	" THE ASSEMBLY LANGAGE[  ATM DOES ALL THE GRAPHICS AND ARTWORK[  "
	DC.B	"FREDDI IS THE LAZIEST CODER IN THE CREW AND KURGAN IS STILL WAITING FOR "
	DC.B	"SOMETHING TO DO["
	dc.b	"           ",101,"           "
	DC.B	" MOST OF THE CODES AND TEXTS FOR THIS SCREEN HAS BEEN MADE BY NUCLEUS AND RIC["
	DC.B	" IT MEANS THAT RIC PROGRAMMED THE INTRODUCTION BASED"
	DC.B	" ON AN OLD SPRITE ROUT BY FREDDI[ HE ALSO MADE THE PRESENTATION "
	DC.B	"AND PUT ALL THE DIFFERENT PART TOGETHER[ NUCLEUS CODED WHAT YOU ARE WATCHING NOW["
	DC.B	"  WE HAD MANY PROBLEMS TO FINISH THIS SCREEN, ESPECIALLY BECAUSE OF THE SCHOOL["
	DC.B	" THAT IS THE REASON WHY THE END OF OUR SCREEN IS SO POOR IN SPECIAL EFFECTS   "
	DC.B	"LET US APOLOGIZE FOR THAT"
	dc.b	"           ",100,"           "
	
	
	
	dc.b	"WE MET A LOT OF COOL GUYS AT THE PARTY[ SO WE SENT A BIG HELLO"
	dc.b	" TO    ALL MEMBERS OF D[ FORCE    TLB [SAMMY JOE[ [MANIKIN[     RIPPED OFF [STICK[    TEX [ES[    TCB [GOGO[    ELECTRA    ULM    "
	DC.B	" TNT CREW [THE DISCO WITH S JOE WAS A BLOODY GOOD FUN^^^ [    GALTAN SIX    AND SOME FRENCH[[[   OVR [ALL MEMBERS[    STCNX    LEGACY [WELL DONE^ ["
	DC.B	"     AND ALL THE PEOPLE WHO WERE THERE[[[   "
	dc.b	" WE WERE ALSO REALLY IMPRESSED BY A REAL TIME TRIDI PROJECTED GRAPHICS BY THALION[[[ WELL I DON]T KNOW HOW TO EXPLAIN IT[[["
	dc.b	" CAN YOU IMAGINE A DUNGEON MASTER GAME WITH PIXEL BY PIXEL MOVEMENTS \\\ ANYWAY LET]S GO ON[[[ "
	dc.b	"          ",100,"           "
	dc.b	"    ANYWAY THIS SCROLL IS TOO FUCKING SLOW TO BE REALLY INTERESTING SO I THINK IT WILL SOON BE OVER[[[" 
	dc.b	" DO YOU WANT TO SEE THE COOL FLAG ONCE AGAIN \\\ WELL[[[     OK^ "
	dc.b	"          ",101,"           "
	dc.b	" HERE COMES THE END[[[   BUT DONT FORGET^"
	dc.b	"          ",100,"           "
	dc.b	"    NUCLEUS IS SIGNING OFF[[[               LETS WRAP^ "
	dc.b	"           "
	dc.b	255
	even
stars	incbin	.\stars1.dat	
	even
courbe	incbin	.\parcours.dat
	even
zic	incbin	.\mainmenu.snd
	even
log_dat	incbin	.\logo.dat
	even
fnt_dat	incbin	.\fnt1.dat
	even	
flagdat	incbin	.\flag1.dat
	even
img	incbin	.\balls.dat
	even
sin_dat	incbin	.\sinus1.dat
	even
	
	bss

sv_mfp	ds.b	6
vs_flag	ds.b	1
key	ds.b	1
flag	ds.b	1
	even
act_sin	ds.l	1
act_c1	ds.l	1
act_pl1	ds.l	1
act_txt	ds.l	1
act_dec	ds.l	1
act_fc	ds.l	1
st_mode	ds.w	1
ox	ds.w	1
oy	ds.w	1
oz	ds.w	1
vx	ds.w	1
vy	ds.w	1
vz	ds.w	1
act_de1	ds.w	1
dec	ds.w	1
t_fade	ds.w	1
t_fad1	ds.w	1
t_f_out	ds.w	1
ad_ecran	ds.l	1	
act_sc1	ds.l	1
act_sc2	ds.l	1
actflag	ds.l	1
act_courbe	ds.l	1
sv_stack	ds.l	1
sv_vbl	ds.l	1
act_coul	ds.l	1	
old_scr	ds.l	1
t_flag	ds.w	1
vsync	ds.w	1
dpa	ds.b	16
sv_pal	ds.w	16
palette	ds.w	16
tab_gen	ds.l	50
clipbuf	ds.l	400
er_buf	ds.l	25
er_b1	ds.l	25
ctxt	ds.w	5000
sin	ds.b	28840	
video2	ds.b	32256
pre_spr	ds.b	20480
preflag	ds.b	86400
code_buf	ds.b	140000

	end
