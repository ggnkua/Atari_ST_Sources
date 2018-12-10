section	text

	jmp	main
	
****************
* First init   *
****************
first_init
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,ustk

	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldphys
	
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldlog
	
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,oldrez
	
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savepal
	
	move.w	#0,-(sp)
	pea	-1
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	rts

*********************
* Initiering av Fi  *
*********************
init_av_fi

	move.l	#80*80,sikt_stracka	;Den str„ckan som fi kan se.
	move.l	#80*80,har_stracka	;Den str„ckan som fi kan hora.
	move.w	#200,vaken_tid		;Den tid som fi „r vaken efter larmet g†tt.

	move.w	#1,enemies

	rts

*********************
* Main och mainloop *
*********************
main
	jsr	first_init
	jsr	init_av_fi

	move.w	#$700,$ff8242
	move.w	#$500,$ff8244
	move.w	#$300,$ff8246
	move.w	#$7,$ff8248
	move.w	#$5,$ff824a
	move.w	#$3,$ff824c
	move.w	#$70,$ff824e
	move.w	#$30,$ff8250
	move.w	#$770,$ff8252
	move.w	#$570,$ff8254
	move.w	#$370,$ff8256
	move.w	#$707,$ff8258
	move.w	#$507,$ff825a
	move.w	#$307,$ff825c
	move.w	#$777,$ff825e
	
	move.l	$70.w,svbi
	move.l	#vbi,$70.w
	
main_loop
	jsr	change_screen

	move.l	#spelar_data,a0
	move.w	#100*64,(a0)+	; X
	move.w	#100*64,(a0)+	; Y
	move.w	#0,(a0)+	; Vinkel
	move.w	#0,(a0)+	; Skott

	move.w	#$353,$ffff8240.w
	jsr	move_fi
	move.w	#$0,$ffff8240.w

	jsr	vsync

	move.b	$fffffc02.w,d0
	cmp.b	#75,d0
	bne	.no1
.no1:
	cmp.b	#77,d0
	bne	.no2
.no2:
	cmp.b	#72,d0
	bne	.no3
.no3:
	cmp.b	#80,d0
	bne	.no4
.no4:
	cmp.b	#106,d0
	bne	.no5
.no5:
	cmp.b	#108,d0
	bne	.no6
.no6:
	cmp.b	#104,d0
	bne	.no7
.no7:
	cmp.b	#110,d0
	bne	.no8
.no8:
	cmp.b	#57,d0
	bne	main_loop
	bra	end
*****************
*    Move fi	*
*****************
move_fi:

	move.l	#fi_data,a0
	move.l	#spelar_data,a1
	move.l	#exp_tab,a2

	move.w	enemies,counter
loop:

	move.w	(a0),d0
	lsr.w	#6,d0		; /64
	sub.w	(a1),d0		; d0=DX

	move.w	2(a0),d1
	lsr.w	#6,d1		; /64
	sub.w	2(a1),d1	; d0=DY

	move.w	d0,d2
	move.w	d1,d3
	lsl.w	#1,d2
	lsl.w	#1,d3
	and.w	#%0111111111111111,d2	; absolutv„rde
	and.w	#%0111111111111111,d3	; absolutv„rde
	move.l	(a2,d2),d4
	add.l	(a2,d3),d4	; d4.l=ATD

	cmp.w	#1,6(a1)	; Spelar_E
	bne	.nupp
	cmp.l	har_stracka,d4
	bgt	.nupp
	cmp.w	#1,10(a0)	; Alarm
	bne	.nupp

	move.w	#1,10(a0)	; Alarm p†
	move.w	vaken_tid,28(a0)
	cmp.w	#1,8(a0)	; Om typen „r vakt s† m†ste lite saker initieras
.nupp

	move.w	22(a0),d2	; fiende vinkeln till d2
	sub.w	4(a1),d2	; dra ifr†n spelar vinkeln
	and.w	#%11111111,d2	; Inom 256 (ett varv=256 grader)
	move.w	d2,24(a0)	; In med skiten i smf_vin

	move.w	#0,sikt
	cmp.w	sikt_stracka,d4
	blt	fi_ser_dig_ej	; Hoppa om avst†ndet „r l„nge „n siktstr„ckan.

*	Nu b”r avst†ndet vara under 64*7(man kan max se 7 rutor fram†t)=448 pix

	move.w	d0,d2		; DX i d2
	add.w	26(a0),d2	; l„gg p† IX
	move.w	d1,d3		; DY i d3
	add.w	28(a0),d3	; L„gg p† IY
	lsl.w	#1,d2		; F”r att passa listan
	lsl.w	#1,d3		; F”r att passa listan
	move.l	(a2,d2),d5
	add.l	(a2,d3),d5	; d5.l=ATD2

	cmp.w	d4,d5
	bgt	fi_ser_dig_ej	; Inget larm sl†s p† om fi inte ser dig

* Om fi r”r sig mot dig(tittar mot dig) minskar avst†ndet till dig

	jsr	check_wall	; Kolla s† fi inte ser genom v„gg

	tst.w	sikt
	beq	fi_ser_dig_ej	; Inget larm sl†s p† om fi inte ser dig

	cmp.w	#1,10(a0)
	beq	fi_ser_dig_ej	; Om larmet redan „r p† beh”ver vi ej g† igenom hela p†slagnings proceduren.

	move.w	#1,10(a0)
	move.w	vaken_tid,30(a0)

	cmp.w	#1,8(a0)
	bne	.hopp
	jsr	ny_slutpunkt	; Om fi „r en vakt s† m†ste en ny slutpunkt v„ljas
.hopp

fi_ser_dig_ej

	move.w	34(a0),d6	; Slutsteg
	cmp.w	32(a0),d6	; Steg=slutsteg?
	bne	.hopp2
	jsr	ny_slutpunkt	; Ny slutpunkt
.hopp2

	cmp.w	#1,8(a0)	; Tid
	bne	.hopp3
	tst.w	10(a0)
	beq	.ingen_uppr„kning ; Stillast†ende vakt skall ej r„knas upp.
.hopp3

	move.w	26(a0),d6
	add.w	d6,(a0)		; X=X+IX
	move.w	28(a0),d6
	add.w	d6,2(a0)	; Y=Y+IY

	addq.w	#1,32(a0)
.ingen_uppr„kning
	jsr	kolla_ruta	; Žr rutan ledig???

	cmp.w	#1,10(a0)
	bne	.hopp4
	jsr	larm_g”rom†l
.hopp4

	sub.w	#1,counter
	bne	loop

	rts

****************
* Ny slutpunkt *
****************
ny_slutpunkt
	move.w	4(a0),(a0)
	move.w	6(a0),2(a0)

	move.w	14(a0),d6	; d6 inneh†ller PP
	move.w	d6,36(a0)
	move.w	12(a0),14(a0)

	lsl.w	#4,d6	; N„rmaste 16 steg(8 word)

	move.l	#omgiv_punkt,a4
	add.w	d6,a4	; a4 pekar p† den punkten som du nu „r p†


	move.l	#fi_punkter,a6	; D6 pekar p† punkt koordinater

	move.w	#4,w
	tst.w	12(a4)
	bne	.hopp	; 4 punkter runt om
	move.w	#3,w
	tst.w	8(a4)
	beq	.hopp	; 3 punkter runt om
	move.w	#2,w
	tst.w	4(a4)
	beq	.hopp	; 2 punkter runt om
	move.w	#1,w	; 1 punkt runt om
.hopp

	cmp.w	#1,10(a0)
	beq	f”lj_efter_spelare

	cmp.w	#2,8(a0)
	beq	v„lj_f”rutbest„md_v„g

	cmp.w	#3,8(a0)
	bne	back1
	move.l	#slumptal,a5
	move.w	w,d6
	subq.w	#1,d6
	lsl.w	#2,d6	; d6 blir nu 0,4,8 eller 12
	add.w	d6,a5
	move.w	e_str†le,d7
	and.w	#%0111100000000000,d7	; Ett slump nummer fr†n 0 till 22 i steg om 2
	move.w	(a5,d7),d6	; d6=ett passande slumptal f”r punkten som fi befinner sig p†.
back1
				; D6 skall vara 0,6,12.....
	move.w	(a4,d6),12(a0)	; L„gg in den nya punkten i NP
	move.w	2(a4,d6),22(a0)	; L„gg in vinkeln
	move.w	4(a4,d6),d3	; d3 f”rst”rs
	move.w	d3,34(a0)	; avst†ndet in i SLUTSTEG

	move.w	(a6,d6),d4	; NY_X
	move.w	2(a6,d6),d5	; NY_Y
	move.w	d4,d0		; OBS!F”rst”r DX!
	move.w	d5,d1		; OBS!F”rst”r DY!

	move.w	(a0),d6		; X
	lsr.w	#6,d6		; /64
	sub.w	d6,d4		; NY_X-X (DX)
	move.w	2(a0),d7	; Y
	lsr.w	#6,d7		; /64
	sub.w	d7,d5		; NY_Y-Y (DY)

	move.w	d4,d6
	lsl.w	#6,d6		; *64
	divs.w	d3,d6		; DX/SLUTSTEG
	move.w	d6,26(a0)	; L„gg in i IX
	
	move.w	d5,d6
	lsl.w	#6,d6		; *64
	divs.w	d3,d6		; DY/SLUTSTEG
	move.w	d6,28(a0)	; L„gg in i IY

	move.w	#0,32(a0)

	lsl.w	#6,d0		; *64
	lsl.w	#6,d1		; *64
	move.w	d0,4(a0)	; in i SPX
	move.w	d1,6(a0)	; in i SPY

	rts

*****************************
* Best„m v„g efter spelaren *
*****************************
f”lj_efter_spelare

	move.l	#tillf_av,a5

	move.w	(a0),d0		; fi X
	lsl.w	#6,d0
	move.w	2(a0),d1	; fi Y
	lsl.w	#6,d1

	move.w	spelar_x,d2
	sub.w	d0,d2		; CX
	move.w	spelar_y,d3
	sub.w	d1,d3		; CY

	move.w	#0,d1
	move.w	w,d0	; Antalet punkter runt om fi
	subq.w	#1,d0	; R„tta till lite s† att den k”r lopen r„tt antal g†nger
.loop
	move.w	(a4,d1),d4	; En av de punkter som ligger runt om punkten som fi nu st†r p†.
	addq.w	#6,d4		; l„gg p† 6 s† kommer vi till n„sta punkt i listan.
	lsl.w	#2,d4
	move.w	(a6,d4),d5	; X till den m”jliga punkten
	move.w	2(a6,d4),d6	; Y till den m”jliga punkten

	sub.w	spelar_x,d5	; Delta v„rdet
	sub.w	spelar_y,d6	; Delta v„rdet
	
	lsl.w	#1,d5
	lsl.w	#1,d6
	and.w	#%0111111111111111,d5	; absolutv„rde
	and.w	#%0111111111111111,d6	; absolutv„rde
	move.l	(a2,d5),d7
	add.l	(a2,d6),d7	; d7.l=avst†ndet till spelaren fr†n den t„nkta punkten

	move.w	d7,(a5)
	addq.w	#4,a5

	dbf.w	d0,.loop

	move.l	#tillf_av,a5

	cmp.w	(a5),2(a5)
	blt	.hopp
	move.w	(a5),d0		; B
	move.w	#0,d2		; R
	bra	.hopp2
.hopp
	move.w	2(a5),d0	; B
	move.w	#6,d2		; R
.hopp2
	cmp.w	4(a5),6(a5)
	blt	.hopp3
	move.w	4(a5),d1	; C
	move.w	#12,d3		; R2
	bra	.hopp4
.hopp3
	move.w	6(a5),d1	; C
	move.w	#18,d3		; R2
.hopp4
	cmp.w	d0,d1
	bgt	.hopp5
	move.w	d3,d2
.hopp5

	move.w	d2,d6

	bra	back1

*************************************
* Kolla om det „r n†gon v„gg iv„gen *
*************************************
check_wall
	move.w	#1,sikt
	move.w	(a1),d2		; Spelar X (X1)
	move.w	2(a1),d3	; Spelar Y (Y1)
	move.w	(a0),d4		; Fi X (X2)
	lsr.w	#6,d4		; /64
	move.w	(a0),d5		; Fi Y (Y2)
	lsr.w	#6,d5		; /64

	move.w	d4,d6
	sub.w	d2,d6
	and.w	#%0111111111111111,d6	; Absolutv„rde
	move.w	d5,d7
	sub.w	d3,d7	; X2-X1
	and.w	#%0111111111111111,d7	; Absolutv„rde
	cmp.w	d6,d7
	blt	more_x
more_y
	cmp.w	d5,d3
	blt	.hopp
	exg.l	d2,d4	; Swap X1,X2
	exg.l	d3,d5	; Swap Y1,Y2
.hopp
	move.w	d5,d6
	sub.w	d3,d6	; Y2-Y1
	lsl.w	#6,d6	; d6=T1

	move.w	d4,d7
	sub.w	d2,d7	; X2-X1   d7=T2

	beq	.hopp2	; T2(d7) f†r ej vara noll
	divs.w	d7,d6
	move.w	d6,k_varde	; K_varde=T1/T2
.hopp2
	tst.w	d7	; /2(d7) f†r ej vara noll
	beq	.hopp3
	muls.w	d2,d6
	lsr.w	#6,d6
	move.w	d3,d7
	neg.w	d7
	add.w	d7,d6	; d6(T1) och d7(T2) f”rst”rd
	lsr.w	#6,d6	; d6 = M
	bra	.hopp4
.hopp3
	move	#0,d6	; d6 = M
	move.w	#64,k_varde
.hopp4
	move.w	d3,d7
	and.w	#%1111111111000000,d7	; (y1/64)*64
	move.w	d7,d2	; X1 f”rst”rs
	add.w	#64,d7
	move.w	d7,d4	; Starten ligger i d4 (X2 f”rst”rd)

	move.w	d5,d7
	and.w	#%1111111111000000,d7	; (y1/64)*64
	move.w	d7,e	; Slutet

	move.l	#block_status,a3
	lsr.w	#1,d2
	add.w	d2,a3		; adressen till start rutan

.koll_loop

	move.w	d4,d2
	sub.w	d6,d2
	lsl.w	#6,d2
	divs.w	k_varde,d2
	lsr.w	#6,d2

	move.w	(a3,d2),d7
	tst.w	d7
	beq	.no_tr„ff_v„gg
	cmp.w	#4,d7
	beq	.no_tr„ff_v„gg
	move.w	#0,sikt
.no_tr„ff_v„gg
	add.w	#64,a3	; ™ka addr med 64(32 word)

	move.w	(a3,d2),d7
	tst.w	d7
	beq	.no_tr„ff_v„gg2
	cmp.w	#4,d7
	beq	.no_tr„ff_v„gg2
	move.w	#0,sikt
.no_tr„ff_v„gg2

	add.w	#64,d4
	cmp.w	e,d4
	blt	.koll_loop

	rts

more_x

	cmp.w	d4,d2
	blt	.hopp
	exg.l	d2,d4	; Swap X1,X2
	exg.l	d3,d5	; Swap Y1,Y2
.hopp
	move.w	d4,d6
	sub.w	d2,d6	; X2-X1
	lsl.w	#6,d6	; d6=T1

	move.w	d5,d7
	sub.w	d3,d7	; Y2-Y1   d7=T2

	beq	.hopp2	; T2(d7) f†r ej vara noll
	divs.w	d7,d6
	move.w	d6,k_varde	; K_varde=T1/T2
.hopp2
	tst.w	d7	; /2(d7) f†r ej vara noll
	beq	.hopp3
	muls.w	d3,d6
	lsr.w	#6,d6
	move.w	d2,d7
	neg.w	d7
	add.w	d7,d6	; d6(T1) och d7(T2) f”rst”rd
	lsr.w	#6,d6	; d6 = M
	bra	.hopp4
.hopp3
	move	#0,d6	; d6 = M
	move.w	#64,k_varde
.hopp4
	move.w	d2,d7
	and.w	#%1111111111000000,d7	; (y1/64)*64
	add.w	#64,d7
	move.w	d7,d4	; Starten ligger i d4 (X2 f”rst”rd)

	move.w	d4,d7
	and.w	#%1111111111000000,d7	; (y1/64)*64
	move.w	d7,e	; Slutet

	move.l	#block_status,a3
	lsr.w	#6,d2
	add.w	d2,a3		; adressen till start rutan

.koll_loop

	move.w	d4,d2
	sub.w	d6,d2
	lsl.w	#6,d2
	divs.w	k_varde,d2
	lsr.w	#6,d2
	lsl.w	#5,d2

	move.w	(a3,d2),d7
	tst.w	d7
	beq	.no_tr„ff_v„gg
	cmp.w	#4,d7
	beq	.no_tr„ff_v„gg
	move.w	#0,sikt
.no_tr„ff_v„gg
	add.w	#2,a3	; ™ka addr med 2(1 word)

	move.w	(a3,d2),d7
	tst.w	d7
	beq	.no_tr„ff_v„gg2
	cmp.w	#4,d7
	beq	.no_tr„ff_v„gg2
	move.w	#0,sikt
.no_tr„ff_v„gg2

	add.w	#64,d4
	cmp.w	e,d4
	blt	.koll_loop

	rts	

****************
* Endif        *
****************
end
	movem.l	savepal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	move.l	svbi,$70.w
	
	move.w	oldrez,-(sp)
	move.l	oldphys,-(sp)
	move.l	oldlog,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	move.l	ustk,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr.w	-(sp)
	trap	#1
	
*****************
* VBI och VSYNC *
*****************
vbi	add.w	#1,vflag
	rte
	
vsync	tst.w	vflag
	beq.s	vsync
	clr.w	vflag
	rts

vsync2	cmp.w	vflag,d0		; d0 = parameter f”r antal vbi
	bgt.s	vsync2
	clr.w	vflag
	rts
	
**********************
* olika screenseters * 
**********************
change_screen
	move.l	a0,-(sp)
	move.l	screen,a0
	move.l	screen,screen+4
	move.l	a0,screen
	move.l	(sp)+,a0
	
set_screen
	move.b	screen+1,$ffff8201.w
	move.b	screen+2,$ffff8203.w
	move.b	screen+3,$ffff820d.w
	rts

set_screen2
	move.b	screen+4+1,$ffff8201.w
	move.b	screen+4+2,$ffff8203.w
	move.b	screen+4+3,$ffff820d.w
	rts
	
***************************************************************************
	section	data
	
screen		dc.l	scrblk,scrblk+32000

*				 Fi data
*		x,y,spx,spy,typ,alarm,np,pp,strt_vag,ny_vag,addr_fi,vin,smf_vin,ix,iy,tid,steg,slutsteg,lp
fi_data
		dc.w	200*64,10*64,200*64,10*64,3,0,1,1,0,0,3,0,0,0,0,0,0,0,0


* 				Niv† data
block_status
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

* 				Punkternas angr„nsande punkter
*			punkt1,vin1,punkt2,vin2,punkt3,vin3,punkt4,vin4
omgiv_punkt
		dc.w	2,150,81,4,196,50,0,0,0,0,0,0
		dc.w	1,21,81,3,133,100,4,238,76,5,189,80
		dc.w	2,7,100,6,182,80,0,0,0,0,0,0
		dc.w	2,112,76,1,70,50,8,63,72,0,0,0
		dc.w	2,63,80,6,133,107,7,231,30,8,0,71
		dc.w	5,7,107,3,56,80,0,0,0,0,0,0
		dc.w	5,105,30,8,21,37,0,0,0,0,0,0
		dc.w	5,126,71,4,63,72,7,182,37,0,0,0

fi_punkter
		dc.w	200,10
		dc.w	130,50
		dc.w	30,60
		dc.w	205,60
		dc.w	132,130
		dc.w	25,140
		dc.w	170,150
		dc.w	203,132

exp_tab:	incbin	"exp.dat"

slump_tab:	dc.w	0,0,0,0,0,0,0,0,0,0,0,0		; 0
		dc.w	0,6,0,6,0,6,0,6,0,6,0,6		; 0 eller 6
		dc.w	0,6,12,0,6,12,0,6,12,0,6,12	; 0,6 eller 12
		dc.w	0,6,12,18,0,6,12,18,0,2,12,18	; 0,6,12 eller 18


	section	bss
scrblk		ds.l	2*8000
ustk		ds.l	1
oldphys		ds.l	1
oldlog		ds.l	1
oldrez		ds.l	1
svbi		ds.l	1
savepal		ds.l	8
vflag		ds.w	1

spelar_data	ds.w	4

tillf_av	ds.l	4

counter		ds.w	1
sikt_stracka	ds.w	1
har_stracka	ds.w	1
vaken_tid	ds.w	1
enemies		ds.w	1
k_varde		ds.w	1
sikt		ds.w	1
e		ds.w	1


	end
