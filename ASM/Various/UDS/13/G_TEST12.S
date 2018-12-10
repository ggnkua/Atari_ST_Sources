
SPR		EQU	0	; SPRITE       0=ON 1=OFF 
DD		EQU	0	; DD AUDIO     0=ON 1=OFF

FRAMV		EQU	8	; fram vanligt
FRAMS		EQU	5	; +fram spring
BAKV		EQU	-7	; bak†t vanligt
BAKS		EQU	-4	; +bak†t spring
STRAFV		EQU	5	; +straf vanlig
STRAFS		EQU	5	; +straf spring
ROTSTRAF		EQU	2	; +rotera vid straf
ROTV		EQU	4	; +rotera vanligt v„nster/h”ger
ROTS		EQU	2	; +rotera snabbt v„nster/h”ger
TJOCK		EQU	25	; (hur tjock gubben „r)/2

ANT_SPR		EQU	20	; antal sprites (de bortesta rensas bort)
ANT_DOOR		EQU	10	; antal d”rrar som kan ”ppnas samtidigt
ANT_EXP		EQU	40	; antal explosioner som kan ske samtidigt
ANT_BOMB		EQU	10	; antal bomber som kan vara ig†ng samtidigt
CD_BOMB		EQU	4	; antal sekunder innan bomb spr„ngs
SEK_GOGG		EQU	10	; antal sekunder goggleserna ska vara aktiva

LEFT		EQU	-64*4	; klipp v„nster
RIGHT		EQU	64*4	; klipp h”ger
UP		EQU	-15	; klipp bakom (!)
DOWN		EQU	64*8+32	; klipp en buske...
TRO_GO		EQU	1	; shiftv„rde i tr”ghet fram/bak
TRO_ROT		EQU	1	; shiftv„rde i tr”ghet v„nster/h”ger
OPEN		EQU	70+15	; hur l„nge d”rren ska vara ”ppen+15

UTG_HEALTH	EQU	100	; utg†ngs healthen

MEDIKIT		EQU	25	; +vid medikit upplock
FOOD		EQU	10	; +vid food upplock
SUPERKIT		EQU	150	; +vid superkit upplock
AMMO1		EQU	16	; +vid pistol
AMMO2		EQU	20	; +vid subgun
AMMO3		EQU	16	; +vid gev„r
AMMO4		EQU	20	; +vid minigun
AMMO5		EQU	5	; +vid OMC
MAX_AMMO1		EQU 	100	; max f”r pistol
MAX_AMMO2		EQU 	250	; max f”r subgun
MAX_AMMO3		EQU 	100	; max f”r gev„r
MAX_AMMO4		EQU 	250	; max f”r minigun
MAX_AMMO5		EQU 	75	; max f”r OMC
SKADA0		EQU	5	; skada kniv
SKADA1		EQU	3	; skada pistol
SKADA2		EQU	2	; skada subgun
SKADA3		EQU	12	; skada gev„r
SKADA4		EQU	4	; skada minigun
SKADA5		EQU	15	; skada OMC

SKOTTHAST		EQU	15	; players flygande skott hastighet
FISKOTTHAST	EQU	8	; fi      flygande skott hastighet

REPT0		EQU	4*3	; antal uppd till n„sta stick
ANSP0		EQU	4	; animation speed kniv
REPT1		EQU	3*3	; antal uppd till n„sta skott pistol
ANSP1		EQU	3	; animation speed pistol
REPT2		EQU	1*3	; antal uppd till n„sta skott subgun
ANSP2		EQU	1	; animation speed subgun
REPT3		EQU	4*3	; antal uppd till n„sta skott gev„r
ANSP3		EQU	4	; animation speed gev„r
REPT4		EQU	1*3	; antal uppd till n„sta skott minigun
ANSP4		EQU	1	; animation speed minigun
REPT5		EQU	4*3	; antal uppd till n„sta skott OMC
ANSP5		EQU	4	; animation speed OMC

DISTANSDIFF	EQU	10	; dd. distans avvikelse
VINKELDIFF	EQU	20	; dd. vinkel avvikelse

	section	text

STARTLAB	move.l	#ENDLAB,d0
	sub.l	#STARTLAB,d0	; d0=minne i bytes som progget tar

	move.w	#0,midi_on	; midi on/off (0=off 1=on)
	move.w	#0,detalj		; detalj l†g/h”g (0=h”g 1=l†g)

	jmp	main

* +-*********************************************************************-+
* | Initierings delen i SubStation                                        |
* * Fixar alla listor, fixar v„rlden och en massa andra saker  / /        *
* * Av Mikael Emtinger 1994                                   /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-+
first_init
	move.l	sp,save_sp

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

	move.l	#musoff_ikbd_instr,-(sp)	; mus off
	move.w	#1-1,-(sp)
	move.w	#25,-(sp)
        	trap	#14
	addq.l	#8,sp

	move.b	#0,screen+3
	move.b	#0,screen+7
	move.w	#-1,in_vbl
	
	rts

* +-----------------------------------------------------------------------+	
* | Ladda bana och initiera den
* +-----------------------------------------------------------------------+	
* ui
init_bana	
	move.w	#$555,$ffff8240.w

	move.l	#.len_buf,-(sp)	; set adr to d_buf
	move.w	#26,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	blt	.exit

	move.w	#0,-(sp)		; open file
	move.l	#ladda_namn,-(sp)
	move.w	#61,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	blt	.exit
	move.w	d0,.num

	move.w	#7,-(sp)		; get file atribute (len)
	move.l	#ladda_namn,-(sp)
	move.w	#78,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	blt	.exit

	cmp.l	#180000,.len_buf+26
	bgt	.exit

	move.l	#bana,-(sp)		; read from file
	move.l	.len_buf+26,-(sp)
	move.w	.num,-(sp)
	move.w	#63,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	blt	.exit

	move.w	.num,-(sp)		; close file
	move.w	#62,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	blt	.exit

;-------- Laddat klart banan -------

	move.w	#$333,$ffff8240.w

	lea	bana,a0
	lea	bana,a1
	lea	fi_sprite_config,a2

	move.l	(a0)+,a3
	add.l	a1,a3
	move.l	a3,maps
	
	move.l	(a0)+,a3
	add.l	a1,a3
	move.l	a3,fi_data
	
	move.l	(a0)+,a3
	add.l	a1,a3
	move.l	a3,splbank_adr2

	move.l	(a0)+,a3
	add.l	a1,a3

	move.w	(a3)+,d7			; antal
.sprconf	move.w	(a3)+,(a2)+		; y
	move.l	(a3)+,(a2)		; adr
	add.l	#bana,(a2)+
	move.w	(a3)+,(a2)+		; spegel,g† igenom
	dbf	d7,.sprconf

	addq.l	#4,a0
	move.w	(a0)+,stor_pal		; st”rfade on/off
	move.w	(a0)+,mincnt+2		; s„tt tiden
	movem.l	(a0)+,d0-d7		; banans pal
	movem.l	d0-d7,pal
	movem.l	d0-d7,nuvarande_pal

	rts

.exit	jmp	end2

.num	ds.w	1
.len_buf	ds.w	44

* +-----------------------------------------------------------------------+	
* | Fixa iordning lite variabler                                          |
* +-----------------------------------------------------------------------+	
* ui
init_level
	move.l	maps,a0
	lea	stat_prefs,a1

	move.w	#5,play_indikator		; set 5 som play_indk
	move.w	#0,killed			; d”dad flaggan
	move.w	(a0)+,x_gubbe		; start x
	move.w	(a0)+,z_gubbe		; start z
	move.w	(a0)+,look_angle		; start vinkel
	move.w	(a0)+,ant_sublev		; antal sublevels-1
	move.w	(a0),sublev		; start sublevel
	move.w	(a0)+,oldsublev

	neg.w	look_angle		; fixa lookangle
	add.w	#359,look_angle

	move.w	#UTG_HEALTH,health		; health
	move.w	#SKADA0,vapen_skada		; skada vapen
	move.w	#0,vilket_vapen		; vilket vapen
	move.w	#0,vilken_anim_vapen	; och vilken animation
	move.w	#60*2,bmp_line		; rts line
	move.l	#99*160+56,vap_add		; add onscreen

	move.w	sublev,d0			; till start sublevel
	mulu	#4162,d0
	add.w	d0,a0

	move.w	(a0)+,(a1)+		; antal stat ljud
	move.l	(a0)+,(a1)+		; xz
	move.l	(a0)+,(a1)+		; num,chan
	move.l	(a0)+,(a1)+		; xz
	move.l	(a0)+,(a1)+		; num,chan
	move.l	(a0)+,(a1)+		; xz
	move.l	(a0)+,(a1)+		; num,chan

	move.l	a0,bytemap_0		; walldata
	add.l	#32*32,a0
	move.l	a0,bytemap_1		; connect data
	add.l	#32*32,a0
	move.l	a0,bytemap_2		; location data
	add.l	#32*32,a0
	move.l	a0,bytemap_3		; event data

	rts

* +-----------------------------------------------------------------------+	
* | Denna rutin fixar v„ggarna ENDAST! OBS! Max 60 LongV„ggar!            |
* +-----------------------------------------------------------------------+	
* ui
init_3dworld
	lea	adrmap,a0		; rensa adrmap
	move.w	#32*32*4-1,d7
.loop	move.l	#0,(a0)+
	dbf	d7,.loop

	lea	.longadr,a0
	move.w	#140-1,d7
.rensadr	move.l	#0,(a0)+
	dbf	d7,.rensadr

	move.l	bytemap_0,a0
	lea	adrmap,a1
	lea	datalist,a2
	lea	.fixa_v„gg,a3	; adr till v„ggadder
	move.l	bytemap_1,a4	; v„ggarnas ihopkoppling
	
	move.w	#0,d0		; x
	move.w	#0,d1		; y

	move.w	#32-1,d7
.loop1	move.w	#32-1,d6
.loop2	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0),d2
	beq	.ingenting	; absolut inget p† denna ruta
	blt	.minus_ett

	cmp.w	#15,d2		; „r det n†tt annat s† dra!
	bgt	.inte_v„gg
	tst.b	(a4)		; „r den med i ett v„ggkomplex?
	bge.s	.longwall
.first	add.w	d2,d2
	add.w	d2,d2
	move.l	(a3,d2.w),a6	; addgrejsa!
	move.w	(a6)+,d5		; antal
	bmi.s	.special		; special v„ggarnas 1:a w=-1
	move.l	a2,(a1)		; spara adressen till v„ggen
	move.w	#0,(a2)+		; v„gg indikatorn=0
	move.w	d5,(a2)		; antal koords-1
	addq.w	#1,(a2)+		; antal koords (2-5)
.add_lp	move.l	(a6)+,(a2)	; kordinater xz
	add.w	d0,(a2)+		; adda p† lite
	add.w	d1,(a2)+	
	dbf	d5,.add_lp

	cmp.w	#9*4,d2		; kolla om det kan vara hemlig d”rr
	bne	.ingenting
	move.w	d0,(a2)+		; startx f”r hemlig d”rr
	bra	.ingenting
	
.special	move.l	a2,(a1)		; spara adressen till v„ggen
	move.w	#1,(a2)+		; specialv„ggsindikatorn=
	move.w	#4,(a2)+		; antal koords
	move.w	#4-1,d5		; antal koords-1
.add_lp2	move.l	(a6)+,(a2)	; kordinater xz
	add.w	d0,(a2)+		; adda p† lite
	add.w	d1,(a2)+	
	dbf	d5,.add_lp2
	bra	.ingenting	

;-------- G”r longwall sektionen --------

.longwall	lea	.longadr,a5	; temp adr till longkoordinater
	move.b	(a4),d3		; vilken av longv„ggarna
	add.w	d3,d3		; *4
	add.w	d3,d3
	add.w	d3,a5		; till adressen
	tst.l	(a5)		; kolla om det „r f”rsta g†ngen
	bne.s	.byggp†
	move.l	a2,(a5)		; adr till kordinatblocket
	bra.s	.first		; hoppa till vanliga v„gg-g”randet
.byggp†	move.l	(a5),a5		; adressen till v„ggblocket
	move.l	a5,(a1)		; spara adressen till v„ggen
	subq.w	#1,d2		; 1:an=0
	bne.s	.tva1
	addq.l	#4,a5
	add.w	#64,(a5)		; x1+64	
	bra	.ingenting	
.tva1	subq.w	#1,d2
	bne.s	.tre1
	add.l	#10,a5
	add.w	#64,(a5)		; z2+64
	bra	.ingenting
.tre1	subq.w	#1,d2
	bne.s	.fyr1
	addq.l	#8,a5
	add.w	#64,(a5)		; x2+64
	bra	.ingenting
.fyr1	subq.w	#1,d2
	bne.s	.tio1
	addq.l	#6,a5
	add.w	#64,(a5)
	bra	.ingenting
.tio1	subq.w	#6,d2
	bne.s	.elv1
	addq.l	#8,a5
	add.w	#64,(a5)
	addq.l	#4,a5
	add.w	#64,(a5)
	bra	.ingenting
.elv1	subq.w	#1,d2
	bne	.ingenting
	addq.l	#6,a5
	add.w	#64,(a5)
	add.l	#12,a5
	add.w	#64,(a5)
	bra	.ingenting

;-------- D”rr make sektionen --------

.inte_v„gg
	cmp.w	#27,d2
	bgt.s	.inte_d”rr

	move.l	a2,(a1)
	move.w	#2,(a2)+		; d”rr indikatorn=2
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a3,d2.w),a6	; addgrejsa!
	
	move.w	#4-1,d5
.add_lp3	move.l	(a6)+,(a2)
	add.w	d0,(a2)+
	add.w	d1,(a2)+
	dbf	d5,.add_lp3
	move.w	(a6)+,(a2)+	; typ 0=bas v„nster 1=bas upp
	move.w	#0,(a2)+		; anim=0 (1-7 ”ppnas 8-x ”ppen x-x+7 st„ngs)
	move.w	(a6)+,(a2)+	; nyckel och is†fall vilken

	move.l	(a6)+,(a2)	; xz
	add.w	d0,(a2)+
	add.w	d1,(a2)+
	move.w	(a6)+,(a2)+	; spr nr

	move.l	(a6)+,(a2)	; xz
	add.w	d0,(a2)+
	add.w	d1,(a2)+
	move.w	(a6),(a2)+	; spr nr
	move.w	(a6),(a2)+	; spara sprite nummer

	bra	.ingenting

;-------- Statiska sprite:ar sektionen --------

.inte_d”rr
	sub.w	#30,d2		; 20=f”rsta sprite:n
	blt.s	.ingenting	; om -1 s† „r det fel!

	move.l	a2,-(sp)		; vid l†g detalj s† ska
	tst.w	detalj		; vi kolla om man ska l„gga
	beq.s	.hogdet		; ut den i adrmapen
	lea	.detalj_conf,a2
	tst.b	(a2,d2.w)
	beq.s	.hogdet
	move.l	(sp)+,a2
	bra	.ingenting
.hogdet	move.l	(sp)+,a2

	move.l	a2,(a1)		; spara adressen till sprite:n
	move.w	#3,(a2)+		; sprite:indikator	

	cmp.w	#23,d2
	beq	.exit_kn

	move.w	d0,(a2)		; x
	add.w	#32,(a2)+		; s† att man hamnar mitt i sr:n
	move.w	d1,(a2)		; z
	add.w	#32,(a2)+		; s† att man hamnar mitt i sr:n

	move.w	d2,(a2)+		; typ av sprite
	move.w	#-1,(a2)+		; r„knare eller vad man vill ha den till

	bra	.ingenting

.exit_kn	move.w	d0,(a2)		; x
	add.w	#37,(a2)+		; s† att man hamnar mitt i sr:n
	move.w	d1,(a2)		; z
	add.w	#60,(a2)+		; s† att man hamnar mitt i sr:n

	move.w	d2,(a2)+		; typ av sprite
	move.w	#-1,(a2)+		; r„knare eller vad man vill ha den till

	bra	.ingenting

;-------- N„sta sr-fix sektionen --------

.minus_ett
	move.l	#-1,(a1)
.ingenting
	addq.l	#1,a0		; till n„sta byte!
	addq.l	#1,a4		; till n„sta byte!
	add.l	#4*4,a1		; till n„sta long!
	add.w	#64,d0		; x+64
	dbf	d6,.loop2
	
	moveq	#0,d0		; x tillbax till 0	
	add.w	#64,d1		; y+64
	dbf	d7,.loop1

	jsr	get_hidd

	rts

.fixa_v„gg	dc.l	0,.ett,.tva,.tre,.fyr,.fem,.sex,.sju,.ott,.nio,.tio
		dc.l	.elv,.tolv,.tret,.fjort,.femt,.sext,.sjut,.art,.nitt
		dc.l	.sjug,.sjugett,.sjugtva,.sjugtre,.sjugfyr,.sjugfem,.sjugsex,.sjugsju
.longadr		ds.l	140
.sa5		ds.l	1
.a5		ds.l	1

.ett		dc.w	2-1,64,64,0,64
.tva		dc.w	2-1,64,0,64,64
.tre		dc.w	2-1,0,0,64,0
.fyr		dc.w	2-1,0,64,0,0
.fem		dc.w	3-1,64,0,64,64,0,64
.sex		dc.w	3-1,0,0,64,0,64,64
.sju		dc.w	3-1,0,64,0,0,64,0
.ott		dc.w	3-1,64,64,0,64,0,0
.nio		dc.w	5-1,0,0,64,0,64,64,0,64,0,0
.tio		dc.w	-1,0,0,64,0,64,64,0,64	; special v„gg!
.elv		dc.w	-1,0,64,0,0,64,0,64,64	; special v„gg!
.tolv		dc.w	4-1,0,64,0,0,64,0,64,64
.tret		dc.w	4-1,64,64,0,64,0,0,64,0
.fjort		dc.w	4-1,64,0,64,64,0,64,0,0
.femt		dc.w	4-1,0,0,64,0,64,64,0,64
.sext		dc.w	0,24,64,24,64,40,0,40,0,-1	; d”rr bas v„nster
		dc.w	32,18,32,32,46,32
.sjut		dc.w	40,0,40,64,24,64,24,0,1,-1	; d”rr bas upp†t
		dc.w	18,32,32,46,32,32
.art		dc.w	0,24,64,24,64,40,0,40,0,0	; d”rr bas v„nster
		dc.w	32,18,34,32,46,34
.nitt		dc.w	40,0,40,64,24,64,24,0,1,0	; d”rr bas upp†t
		dc.w	18,32,34,46,32,34
.sjug		dc.w	0,24,64,24,64,40,0,40,0,2	; d”rr bas v„nster
		dc.w	32,18,36,32,46,36
.sjugett		dc.w	40,0,40,64,24,64,24,0,1,2	; d”rr bas upp†t
		dc.w	18,32,36,46,32,36
.sjugtva		dc.w	0,24,64,24,64,40,0,40,0,4	; d”rr bas v„nster
		dc.w	32,18,38,32,46,38
.sjugtre		dc.w	40,0,40,64,24,64,24,0,1,4	; d”rr bas upp†t
		dc.w	18,32,38,46,32,38
.sjugfyr		dc.w	0,24,64,24,64,40,0,40,0,-2	; d”rr bas v„nster
		dc.w	32,18,32,32,46,32
.sjugfem		dc.w	40,0,40,64,24,64,24,0,1,-2	; d”rr bas upp†t
		dc.w	18,32,32,46,32,32
.sjugsex		dc.w	0,24,64,24,64,40,0,40,0,-1	; d”rr bas v„nster
		dc.w	32,18,47,32,46,47
.sjugsju		dc.w	40,0,40,64,24,64,24,0,1,-1	; d”rr bas upp†t
		dc.w	18,32,47,46,32,47

.detalj_conf	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,1,0,1,1,1,1,1,1,1,1,1,1
		even

* +-----------------------------------------------------------------------+	
* | Fixa iordning lite listor och s†n't                                   |
* +-----------------------------------------------------------------------+	
* ui
init_3dlist
	move.w	#0,.look_angle
	move.w	#10,.vilken_linje

	move.w	#360-1,d7
.loop1	lea	sin_360,a1		; sin
	lea	sin_360+90*2,a0		; cos

	move.w	.look_angle,d4
	add.w	d4,d4
	move.w	(a0,d4.w),d0		; sin alpha
	move.w	(a1,d4.w),d1		; cos alpha
	add.w	#1,.look_angle
	
	move.w	#0,d3			; x
	move.w	#-64*50,d2		; z
	move.w	d2,d5
	move.w	d3,d6
	
	muls	d1,d2			; x*cos(alpha)
	swap	d2
	rol.l	#2,d2

	muls	d0,d3
	swap	d3
	rol.l	#2,d3
	add.w	d2,d3
	
	move.w	d3,d4			; new x
	
	move.w	d5,d2			; x
	move.w	d6,d3			; z
	
	muls	d0,d2
	swap	d2
	rol.l	#2,d2
	muls	d1,d3
	swap	d3
	rol.l	#2,d3
	sub.w	d2,d3
	move.w	d4,d2

	asr.w	#6,d2			; x
	asr.w	#6,d3			; y
	
	lea	.step,a4

	move.l	#65537,(a4)		; step1-2 = 1
	move.l	#65537,4(a4)		; step3-4 = 1
	
	move.w	#0,d0			; x1
	move.w	#0,d1			; y1

	move.w	d2,d4			; x2
	move.w	d3,d5			; y2
	sub.w	d0,d2			; dx
	sub.w	d1,d3			; dy


	tst.w	d2
	bge.s	.dx_not_less
	move.w	#-1,(a4)
	move.w	#-1,4(a4)
	neg.w	d2
.dx_not_less

	tst.w	d3
	bge.s	.dy_not_less
	move.w	#-1,2(a4)
	move.w	#-1,6(a4)
	neg.w	d3
.dy_not_less

	cmp.w	d2,d3
	bge.s	.dx_less_dy
	move.w	#0,2(a4)
	bra.s	.dx_more_dy
.dx_less_dy
	move.w	#0,(a4)
	exg.l	d2,d3
.dx_more_dy

	neg.w	d2
	move.w	d2,d6			; error=-dx
	neg.w	d2
	
	add.w	d2,d2			; dx*2
	add.w	d3,d3			; dy*2
	
	move.w	#0,.xgam
	move.w	#0,.ygam
	move.w	#0,.ant
	neg.w	.vilken_linje
	
***** draw loop *****
.dr_lp
	cmp.w	d0,d4
	bne.s	.not_end
	cmp.w	d1,d5
	bne.s	.not_end
	dbf	d7,.loop1
	jmp	.skip

.not_end	add.w	d3,d6		; error+dy	
	bgt.s	.nix_pix
	add.w	(a4),d0
	add.w	2(a4),d1
	jmp	.fixa_lite

.nix_pix	add.w	4(a4),d0
	add.w	6(a4),d1
	sub.w	d2,d6
	jmp	.fixa_lite

****** fixa lite saker

.fixa_lite
	movem.l	d0-d3/a0,-(sp)

	tst.w	.vilken_linje
	ble	.8_linje

	cmp.w	#9,.ant
	beq.s	.samma
	
	moveq	#0,d2

	cmp.w	.xgam,d0
	bne.s	.nox
	add.w	#1,d2
.nox	cmp.w	.ygam,d1
	bne.s	.noy
	add.w	#1,d2
.noy	cmp.w	#2,d2
	beq.s	.samma
	
	lea	look_cord,a0
	add.w	.fram,a0
	add.w	#2,.fram
	add.w	#1,.ant

	move.w	.xgam,d2
	move.w	.ygam,d3

	move.w	d0,.xgam		; nytt stuff i stan
	move.w	d1,.ygam

	sub.w	d2,d0		; realtive
	sub.w	d3,d1

	asl.w	#4,d0		; x*4*4
	asl.w	#8,d1		; y*4*32*4
	add.w	d1,d1
	add.w	d0,d1

	cmp.w	#1,.ant		; spara inte f”rsta
	beq.s	.add_ej
	move.w	d1,(a0)+
	bra.s	.samma
.add_ej	sub.w	#2,.fram		; s† att vi inte f†r f”r m†nga
.samma	movem.l	(sp)+,d0-d3/a0
	jmp	.dr_lp

;--- 8 linjer ---

.8_linje	cmp.w	#8,.ant
	beq.s	.samma2
	
	moveq	#0,d2

	cmp.w	.xgam,d0
	bne.s	.nox2
	add.w	#1,d2
.nox2	cmp.w	.ygam,d1
	bne.s	.noy2
	add.w	#1,d2
.noy2	cmp.w	#2,d2
	beq.s	.samma2
	
	lea	look_cord,a0
	add.w	.fram,a0
	add.w	#2,.fram
	add.w	#1,.ant

	move.w	.xgam,d2
	move.w	.ygam,d3

	move.w	d0,.xgam		; nytt stuff i stan
	move.w	d1,.ygam

	sub.w	d2,d0		; realtive
	sub.w	d3,d1

	asl.w	#4,d0		; x*4*4
	asl.w	#8,d1		; *4*32*4
	add.w	d1,d1
	add.w	d0,d1

	move.w	d1,(a0)+
.samma2	movem.l	(sp)+,d0-d3/a0
	jmp	.dr_lp

;-------- Coppa upp fr†n +180 till -180

.skip	lea	look_cord+2*8*180,a0
	lea	look_cord-2*8*180,a1
	move.w	#180-1,d7
.coppa	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbf	d7,.coppa

;-------- Patcha lite ---------
	
	lea	.var_list,a0

	move.w	#12-1,d7
.ytlp	move.l	(a0)+,a1		; fr†n adr
	move.l	(a0)+,a2		; till adr
	move.w	(a1)+,(a2)
	move.w	(a0)+,d0		; chg first step
	add.w	d0,(a2)+
	move.w	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	dbf	d7,.ytlp

	lea	sqr_list,a0
	moveq	#0,d0		; tal 1
	move.w	#1024-1,d7
.lp_d7a	move.l	d0,d2
	mulu	d2,d2
	move.l	d2,(a0)+
	addq.l	#1,d0
	dbf	d7,.lp_d7a

	lea	list1,a0
	move.w	#-70*4,d1
.make1	move.w	d1,d0
	muls.w	#55*8,d0
	move.l	d0,(a0)+
	addq.w	#1,d1
	cmp.w	#70*4,d1
	ble	.make1

	lea	list2,a0
	move.w	#-50,d1
.make2	move.l	#-26*2*55*8,d0
	tst.w	d1
	bne.s	.ejdivno
	move.w	d0,(a0)+
	bra.s	.divno
.ejdivno	divs	d1,d0
	move.w	d0,(a0)+
.divno	addq.w	#1,d1
	cmp.w	#64*9+32,d1
	ble	.make2
		
	rts
		
.step		ds.w	4
.xgam		ds.w	1
.ygam		ds.w	1
.fram		ds.w	1
.ant		ds.w	1
.look_angle	ds.w	1
.vilken_linje	ds.w	1
.var_list		dc.l	look_cord-179*2*8,look_cord-150*2*8
		dc.w	16
		dc.l	look_cord-90*2*8,look_cord-120*2*8
		dc.w	-512
		dc.l	look_cord-90*2*8,look_cord-60*2*8
		dc.w	512
		dc.l	look_cord+0*2*8,look_cord-30*2*8
		dc.w	16
		dc.l	look_cord+0*2*8,look_cord+30*2*8
		dc.w	-16
		dc.l	look_cord+90*2*8,look_cord+60*2*8
		dc.w	512
		dc.l	look_cord+90*2*8,look_cord+120*2*8
		dc.w	-512
		dc.l	look_cord+180*2*8,look_cord+150*2*8
		dc.w	-16
		dc.l	look_cord+180*2*8,look_cord+210*2*8
		dc.w	16
		dc.l	look_cord+270*2*8,look_cord+240*2*8
		dc.w	-512
		dc.l	look_cord+270*2*8,look_cord+300*2*8
		dc.w	512
		dc.l	look_cord+359*2*8,look_cord+330*2*8
		dc.w	16

* +-----------------------------------------------------------------------+	
* | Init lite sprites
* +-----------------------------------------------------------------------+	
* ui
init_sprite

	IFEQ	SPR
	jsr	change_cliping
	jsr	init_zoom_rout

	lea  	pal,a0			; paletten
	move.l  	a0,a1
	move.l  	#tabs,d0
	add.l   	#256,d0
	clr.b   	d0
	move.l  	d0,a2
	move.l  	d0,pixel_tab
	jsr     	make_tabs
	ENDC

	lea	sprite_config+2,a0		; peekar p† BPP-adr
	lea	statspr_blk,a1
	move.w	(a1)+,d7			; antal
.offslp	move.l	(a1)+,(a0)
	add.l	#statspr_blk,(a0)+
	addq.l	#4,a0
	dbf	d7,.offslp

	rts

* +-----------------------------------------------------------------------+	
* | Init av midi
* +-----------------------------------------------------------------------+	
* ui
init_midi
	tst.w	midi_on
	beq	.ej_init_midi

	move.l	#midisvbi,$70.w
	move.w	#$007,$ffff8240.w
	jsr	midi_init			; init av ring/mfp
.mid_cl	jsr	vsync
	cmp.b	#28,$fffffc02.w
	bne.s	.hp
.hpwrel	cmp.b	#28+128,$fffffc02.w
	bne.s	.hpwrel
	jsr	midi_conn
.hp	cmp.w	#10,charrec
	bne.s	.mid_cl

	cmp.w	#0,com_id
	beq.s	.ej_new
	move.w	x_gubbe,d0
	move.w	z_gubbe,d1
	add.w	#64,d0
	move.w	d0,x_gubbe
	move.w	d1,z_gubbe
.ej_new

	lea	spelar_buffer,a0
	lea	vilk_team,a1
	lea	virt_bmb_adr,a2

	moveq	#0,d0
	move.w	ant_com,d7
	subq.w	#1,d7
.initvar	move.w	#3,(a0)+		; indik
	move.w	#0,(a0)+		; x
	move.w	#0,(a0)+		; z
	move.w	#0,(a0)+		; nuvarande sprite
	move.w	#48,(a0)+		; utg sprite
	move.w	#0,(a0)+		; vinkel
	move.w	#0,(a0)+		; skjut flg
	move.w	#0,(a0)+		; vilket vapen
	move.w	#0,(a0)+		; skadad flg
	move.w	#0,(a0)+		; d”d flg
	move.w	#0,(a0)+		; d”d cnt
	move.w	d0,(a0)+		; vilken gubbe
	move.w	(a1)+,(a0)+	; team
	move.w	#-1,(a0)+		; ant bmb
	move.l	(a2)+,(a0)+	; bmb adr 1
	move.l	(a2)+,(a0)+	;         2
	move.l	(a2)+,(a0)+	;         3

	move.w	x_gubbe,d1
	move.w	z_gubbe,d2
	lsr.w	#6,d1
	lsr.w	#6,d2
	lsl.w	#5,d2
	add.w	d1,d2
	lsl.w	#4,d2
	add.w	#12,d2

	move.w	d2,(a0)+		; rens adr
	move.w	#0,(a0)+		; oldx
	move.w	#0,(a0)+		; oldz
	move.w	#1,(a0)+		; anim flg

	addq.w	#1,d0		; n„sta gubbe
	dbf	d7,.initvar

.ej_init_midi
	rts

* +-*********************************************************************-+
* | Main delen i SubStation                                               |
* * Mainloopen och hoppa till alla initierings grejjor         / /        *
* * Av Mikael Emtinger 1994                                   /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-+
main
	jsr	first_init		; f”rsta init
	jsr	init_bana			; ladda och fixa level
	jsr	init_level		; init level
	jsr	init_3dworld		; fixa v„rlden
	jsr	init_3dlist		; fixa lite listor

	jsr	poly+6			; polygon init

	jsr	init_pnl			; panel init
 	jsr	panel_levinit		; level init f”r panelen
	jsr	prepare_panel		; panel vapen init

	jsr	init_sprite		; init sprite
	jsr	init_av_fi		; init fi

	IFEQ	DD
	jsr	first_init_sound		; init dd-audio
	move.l	splbank_adr2,a0		; peekar p† ljudbuffert tv†
	jsr	init_sound		; init dd-audio
	jsr	init_statsound		; init det statiskaljuet
	ENDC

	move.l	$118.w,s118
	tst.w	midi_on
	bne.s	.no118
	move.l	#my_118,$118.w
.no118
	jsr	init_midi			; init midi

	move.l	$70.w,svbi
	move.l	#vbi,$70.w

	jsr	vsync
	jsr	vsync
	jsr	vsync
	jsr	set_screen2
.main_loop
	jsr	make_3dworld		; g”r v„ggar,sprite:ar och v„nder
	jsr	ud_panel
	jsr	go_elevator
	jsr	escrut
	jsr	you_exit
	jsr	you_are_dead

.ej_hiss	bra.s	.main_loop
 
* +-*********************************************************************-+
* | 3D-motorn i SubStation                                                |
* * ta ut, rotera, sortera, persp. koordinater och rita        / /        *
* * Av Mikael Emtinger 1994                                   /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-+
make_3dworld
	jsr	get_cords
	
	tst.w	num_points
	bge.s	.just_go_on1
	rts
.just_go_on1

	jsr	rotate_cords
	jsr	cut_cords

	tst.w	num_obj2
	bge.s	.just_go_on2
	rts
.just_go_on2

	jsr	sort_cords
	jsr	persp_cords

	jsr	change_screen
.sync	tst.w	gfx_flg
	beq.s	.sync
		
	jsr	put_screen
	jsr	paint_walls
	jsr	turn_screen
	jsr	paint_sprites
	rts

* +-----------------------------------------------------------------------+	
* | Ta ut de r„tta koordinaterna med hj„lp av raytrace:ing                |
* +-----------------------------------------------------------------------+	
* ui
get_cords
	lea	adr_matris,a0
	move.w	#32*32/32-1,d7
.rens	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	dbf	d7,.rens

	lea	adrmap,a0
	lea	look_cord,a1
	lea	xz_points,a2	; h„r kommer x,z ligga
	lea	ant_look,a3	; antalet rutaor de olika ray:sen ska s”ka
	lea	adr_matris,a4	; matrisen till vilka vi plockat
	lea	xz_connect,a5	; beskriver hur koordsen skall anv„ndas

	move.w	x_gubbe,d0	; gubbens x,z koordinat
	move.w	z_gubbe,d1
	move.w	look_angle,d2	; kolla riktning
	add.w	#90,d2
	
	cmp.w	#360,d2
	blt.s	.ej_”verslag
	sub.w	#360,d2
.ej_”verslag

	lsr.w	#6,d0		; x/64
	lsr.w	#6,d1		; z/64
	lsl.w	#5,d1
	add.w	d0,d1
	lsl.w	#4,d1
	add.w	d1,a0		; till r„tt plats p† adrmappen
	lsr.w	#4,d1
	add.w	d1,a4
	move.l	a0,.position	; save
	move.l	a4,.position2	; save

	lsl.w	#4,d2		; look_angle*16
	add.w	d2,a1		; fram till b”rjan av 1:a ray:n
	move.l	a1,.raystart	; spara denna oxo

	move.l	x_gubbe,d4	; x o z gubbe
	moveq	#-1,d0		; num_points
	moveq	#-1,d1		; num_wall

	tst.l	(a0)
	ble.s	.ej_min

	move.w	#90*2-1,d7	; vi s”ker ett omf†ng p† 170 grader
	move.w	(a3)+,d6		; antal rutor denna str†le
	move.l	.position,a0	; din position ruta
	move.l	.raystart,a1	; till b”rjan p† ray:n
	move.l	.position2,a4
	bra.s	.first

.ej_min	move.w	#90*2-1,d7	; vi s”ker ett omf†ng p† 170 grader
.getkord1
	move.w	(a3)+,d6		; antal rutor denna str†le
	move.l	.position,a0	; din position ruta
	move.l	.raystart,a1	; till b”rjan p† ray:n
	move.l	.position2,a4
.getkord2
	move.w	(a1)+,d5		; relativ add f”r n„sta ruta
	add.w	d5,a0		; in till adr sr
	asr.w	#4,d5		; /16 f”r add i matris
	add.w	d5,a4		; adda p† matrisen

	tst.l	(a0)
	blt	.stoppa		; om -1-ruta s† stoppa
	bne.s	.vanlig		; om adr s† hoppa

	tst.b	(a4)		; om 0:ad sr s† kolla vad de
	bne	.inget		; andra inneh†ller
	move.b	#1,(a4)		; s„tt denna sr
	bra	.long2		; g† och kolla 
.vanlig

.first	move.l	(a0),a6		; adressen
	tst.w	(a6)
	bne	.ej_ordv„gg	; inte v„gg (iaf ej ordinarie)

;--- Kolla om vi redan har denna v„gg ---

	tst.b	(a4)
	bne	.stoppa
	move.b	#1,(a4)		; s„tt denna sr
	
	lea	2(a6),a6		; adda och flytta

	move.w	(a6)+,d5
	add.w	d5,d0		; antal kordinater
	move.w	d5,(a5)+		; sammanbindningslistan

	subq.w	#2,d5
	beq	.tva_kords
	subq.w	#1,d5
	beq	.tre_kords
	subq.w	#1,d5
	beq.s	.fyr_kords

* Om det „r fem koordinater (fyrkant)

	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+		
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+		
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+		
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+		
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+		
	sub.l	#2*8,.raystart		
	addq.w	#4,d1		

	dbf	d7,.getkord1
	move.w	d0,num_points
	move.w	d1,num_obj
	rts

* Om det „r fyra koordinater (dubbelh”rn)

.fyr_kords
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+		
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+		
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+		
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+		
	sub.l	#2*8,.raystart		
	addq.w	#3,d1		
	dbf	d7,.getkord1
	move.w	d0,num_points
	move.w	d1,num_obj
	rts
	
* Om det „r tre koordinater (enkelh”rn)

.tre_kords
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+		
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+		
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+		
	addq.w	#2,d1		
	sub.l	#2*8,.raystart
	dbf	d7,.getkord1
	move.w	d0,num_points
	move.w	d1,num_obj
	rts

* Om det „r tv† koordinater (enkelv„gg)

.tva_kords
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+		
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+		
	addq.w	#1,d1		

	sub.l	#2*8,.raystart
	dbf	d7,.getkord1
	move.w	d0,num_points
	move.w	d1,num_obj
	rts

;--------- Kolla om det „r en specialv„gg ------------

.ej_ordv„gg
	cmp.w	#1,(a6)
	bne.s	.ej_v„gg		; inte v„gg

	tst.b	(a4)
	bne	.stoppa
	move.b	#1,(a4)		; s„tt denna sr
	
	lea	4(a6),a6		; adda p† fyra och flytta
	addq.w	#4,d0		; antal koords
	addq.w	#2,d1		; antal objekt
	move.w	#0,(a5)+		; 0 = specialv„gg (1=d”rr osv)

	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+
	sub.l	#2*8,.raystart		
	dbf	d7,.getkord1
	move.w	d0,num_points
	move.w	d1,num_obj
	rts

;--------- Kolla om vi redan s”kt av denna sr ----------

.ej_v„gg	cmp.w	#2,(a6)
	bne.s	.ej_st„ngd_d”rr
	tst.w	20(a6)
	bne.s	.ej_st„ngd_d”rr

	tst.b	(a4)
	bne	.stoppa
	move.b	#1,(a4)		; s„tt denna sr
	bra	.chk_and_stop	; kolla rutan sedan hoppa ur

.ej_st„ngd_d”rr
	tst.b	(a4)
	bne	.inget
	move.b	#1,(a4)		; s„tt denna sr

;--------- Kolla nu vad de olika adresserna inneh†ller -----------------

.now_chk
	cmp.w	#2,(a6)		; f”rsta longet
	bne.s	.ejd1
	bsr	.d”rr
	bra.s	.long2
.ejd1	cmp.w	#3,(a6)
	bne.s	.ejs1
	bsr	.stat_spr
	bra.s	.long2
.ejs1	cmp.w	#4,(a6)
	bne.s	.long2
	bsr	.fi_spr
	
.long2	tst.l	4(a0)		; andra longet
	beq.s	.long3
	move.l	4(a0),a6
		
	cmp.w	#3,(a6)
	bne.s	.ejs2
	bsr	.stat_spr
	bra.s	.long3
.ejs2	cmp.w	#4,(a6)
	bne.s	.long3
	bsr	.fi_spr

.long3	tst.l	8(a0)		; tredje longet
	beq.s	.long4
	move.l	8(a0),a6
		
	cmp.w	#3,(a6)
	bne.s	.ejs3
	bsr	.stat_spr
	bra.s	.long4
.ejs3	cmp.w	#4,(a6)
	bne.s	.long4
	bsr	.fi_spr
	
.long4	tst.l	12(a0)		; tredje longet
	beq.s	.klar
	move.l	12(a0),a6
		
	cmp.w	#3,(a6)
	bne.s	.ejs4
	bsr	.stat_spr
	bra.s	.klar
.ejs4	cmp.w	#4,(a6)
	bne.s	.klar
	bsr	.fi_spr
.klar
	dbf	d6,.getkord2	; next
	sub.l	#2*8,.raystart		
	dbf	d7,.getkord1
	move.w	d0,num_points
	move.w	d1,num_obj
	rts

;--------- Kolla nu vad de olika adresserna inneh†ller sedan stoppa -----

.chk_and_stop
	cmp.w	#2,(a6)		; f”rsta longet
	bne.s	.ejd1b
	bsr	.d”rr
	bra.s	.long2b
.ejd1b	cmp.w	#3,(a6)
	bne.s	.ejs1b
	bsr	.stat_spr
	bra.s	.long2b
.ejs1b	cmp.w	#4,(a6)
	bne.s	.long2b
	bsr	.fi_spr
	
.long2b	tst.l	4(a0)		; andra longet
	beq.s	.long3b
	move.l	4(a0),a6
		
	cmp.w	#3,(a6)
	bne.s	.ejs2b
	bsr	.stat_spr
	bra.s	.long3b
.ejs2b	cmp.w	#4,(a6)
	bne.s	.long3b
	bsr	.fi_spr

.long3b	tst.l	8(a0)		; tredje longet
	beq.s	.long4b
	move.l	8(a0),a6
		
	cmp.w	#3,(a6)
	bne.s	.ejs3b
	bsr	.stat_spr
	bra.s	.long4b
.ejs3b	cmp.w	#4,(a6)
	bne.s	.long4b
	bsr	.fi_spr
	
.long4b	tst.l	12(a0)		; tredje longet
	beq.s	.klarb
	move.l	12(a0),a6
		
	cmp.w	#3,(a6)
	bne.s	.ejs4b
	bsr	.stat_spr
	bra.s	.klarb
.ejs4b	cmp.w	#4,(a6)
	bne.s	.klarb
	bsr	.fi_spr
.klarb
	sub.l	#2*8,.raystart		
	dbf	d7,.getkord1
	move.w	d0,num_points
	move.w	d1,num_obj
	rts

;-------- D”rr sektionen ----------

.d”rr	lea	2(a6),a6		; adda p† tv†
	addq.w	#6,d0		; antal koords
	addq.w	#5,d1		; antal objekt
	move.w	#1,(a5)+		; 1 = d”rr (2=enkelv„gg osv)
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+
	move.l	(a6)+,(a2)
	sub.l	d4,(a2)+

	addq.w	#6,a6

	move.l	(a6)+,(a2)	; xz
	sub.l	d4,(a2)+		; g”r det relativt
	move.w	(a6)+,(a5)+	; ett sprite:nr

	move.l	(a6)+,(a2)	; xz
	sub.l	d4,(a2)+		; g”r det relativt
	move.w	(a6),(a5)+	; ett sprite:nr

	rts

;--------- Kolla om det „r en sprite ------------

.stat_spr	lea	2(a6),a6		; adda p† tv†
	addq.w	#1,d0		; antal koords
	addq.w	#1,d1		; antal objekt

	move.l	(a6)+,(a2)	; xz
	sub.l	d4,(a2)+		; g”r det relativt
	
	move.w	#6,(a5)+		; connectlista + 
	move.l	a6,(a5)+		; spr adr
	move.w	(a6),(a5)+	; ett sprite:nr
	rts

;-------- Kolla om det „r en fiende ------

.fi_spr	addq.w	#1,d0		; antal koords
	addq.w	#1,d1		; antal objekt

	move.w	2(a6),d5		; x
	lsr.w	#4,d5
	move.w	d5,(a2)
	move.w	4(a6),d5		; z
	lsr.w	#4,d5
	move.w	d5,2(a2)
	sub.l	d4,(a2)+		; g”r det relativt

	move.w	#6,(a5)+		; connectlista + 
	move.l	a6,(a5)+		; fi adr
	move.w	48(a6),(a5)+	; ett sprite:nr (20-n)
	rts

;-------- Hoppa ur grejjsa ----------

.inget	dbf	d6,.getkord2	; next
.stoppa	sub.l	#2*8,.raystart		
	dbf	d7,.getkord1
	move.w	d0,num_points
	move.w	d1,num_obj
	rts

.position		dc.l	1
.position2	dc.l	1
.raystart		dc.l	1
.tom		dcb.l	16,0

* +-----------------------------------------------------------------------+	
* | Rotera de utplockade koordinaterna s† mycket som 'look_angle' visar   |
* +-----------------------------------------------------------------------+	
* ui
rotate_cords
	lea	sin_360,a0		; sin
	lea	sin_360+90*2,a1		; cos
	lea	xz_points,a2		; ta ifr†n (x,z)
	move.l	a2,a3			; l„gga i
	
	move.w	look_angle,d2
	add.w	d2,d2
	move.w	(a0,d2.w),d0		; sin alpha
	move.w	(a1,d2.w),d1		; cos alpha

	move.w	num_points,d7
.rotta	move.w	(a2)+,d2		; x
	move.w	(a2)+,d3		; z
	move.w	d2,d5
	move.w	d3,d6
	
	muls	d1,d2		; x*cos(alpha)
	swap	d2
	rol.l	#2,d2
	muls	d0,d3
	swap	d3
	rol.l	#2,d3
	add.w	d2,d3
	
	move.w	d3,(a3)+		; new x
	
	muls	d0,d5
	swap	d5
	rol.l	#2,d5
	muls	d1,d6
	swap	d6
	rol.l	#2,d6
	sub.w	d5,d6
	
	move.w	d6,(a3)+		; new z
	dbf	d7,.rotta
	rts

* +-----------------------------------------------------------------------+	
* | Plocka ”ver koordsen till xyz_x_p, deltaz i dz_p och adr i adr_p      |
* +-----------------------------------------------------------------------+	
* ui
cut_cords
	lea	xz_points,a0
	lea	dz_points,a1
	lea	xz_connect,a2
	lea	adr_points,a3
	lea	xyz_wall_points,a4
	lea	xyz_sprite_points,a5
	lea	.tempo,a6
	
	move.w	#-1,num_obj2
	move.w	num_obj,d7
	
.fix_adr	move.w	(a2)+,d0		; hur m†nga koords i detta omf†ng?
	beq	.spec_adr		; kolla om det „r specialfall
	subq.w	#1,d0
	beq	.door_adr		; plocka d”rr
	subq.w	#1,d0
	beq	.one_adr
	subq.w	#1,d0
	beq	.two_adr
	subq.w	#1,d0
	beq	.thr_adr
	subq.w	#1,d0
	beq	.fou_adr
	
.sprite	move.w	(a0)+,d0		; x
	move.w	(a0)+,d1		; z
	move.l	(a2)+,d3		; adr till spr (ligger efter connectnr)
	move.w	(a2)+,d2		; vilken sprite (ligger efter connectnr)
	blt	.2a

	cmp.w	#LEFT,d0
	blt.s	.2a
	cmp.w	#RIGHT,d0
	bgt.s	.2a
	cmp.w	#UP,d1
	blt.s	.2a
	cmp.w	#DOWN,d1
	bgt.s	.2a

	move.l	a4,usp
	lea	sprite_config,a4	; y,bredd,h”jd,BPP-adr, Mask-adr, dummy

	lsl.w	#3,d2
	add.w	d2,a4		; till r„tt sprite

	add.w	#1,num_obj2	; antal objekt+1

	move.l	a5,(a3)+		; adr to koords
	move.w	d0,(a5)+		; x
	move.w	d1,(a5)+		; z
	move.l	(a4)+,(a5)+	; y + 1/2:a BBP adr
	move.l	(a4)+,(a5)+	; resterande BBP + spegelv„nd?
	move.l	d3,(a5)+		; adr till spr ursprung

	move.w	d1,(a1)+		; dz
	move.l	usp,a4		; tillbax med adressen i USP:en

.2a	dbf	d7,.fix_adr
	rts

.fou_adr	move.l	(a0)+,(a6)
	move.l	(a0),4(a6)

	jsr	.cut_line
	tst.w	d0
	blt.s	.3a

	add.w	#1,num_obj2
	move.l	a4,(a3)+
	move.l	0(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.l	4(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.w	2(a6),d0

	cmp.w	6(a6),d0
	bgt.s	.3adz
	move.w	6(a6),(a1)+	; dz
	bra.s	.3a
.3adz	move.w	d0,(a1)+		; dz

.3a	move.l	(a0)+,(a6)
	move.l	(a0),4(a6)

	jsr	.cut_line
	tst.w	d0
	blt.s	.4a

	add.w	#1,num_obj2
	move.l	a4,(a3)+
	move.l	0(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.l	4(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.w	2(a6),d0
	cmp.w	6(a6),d0
	bgt.s	.4adz
	move.w	6(a6),(a1)+	; dz
	bra.s	.4a
.4adz	move.w	d0,(a1)+		; dz

.4a	move.l	(a0)+,(a6)
	move.l	(a0),4(a6)

	jsr	.cut_line
	tst.w	d0
	blt.s	.5a

	add.w	#1,num_obj2
	move.l	a4,(a3)+
	move.l	0(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.l	4(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.w	2(a6),d0
	cmp.w	6(a6),d0
	bgt.s	.5adz
	move.w	6(a6),(a1)+	; dz
	bra.s	.5a
.5adz	move.w	d0,(a1)+		; dz

.5a	move.l	(a0)+,(a6)
	move.l	(a0)+,4(a6)

	jsr	.cut_line
	tst.w	d0
	blt.s	.6a

	add.w	#1,num_obj2
	move.l	a4,(a3)+
	move.l	0(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.l	4(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.w	2(a6),d0
	cmp.w	6(a6),d0
	bgt.s	.6adz
	move.w	6(a6),(a1)+	; dz
	bra.s	.6a
.6adz	move.w	d0,(a1)+		; dz

.6a	subq.w	#4-1,d7
	dbf	d7,.fix_adr
	rts

.thr_adr	move.l	(a0)+,(a6)
	move.l	(a0),4(a6)

	jsr	.cut_line
	tst.w	d0
	blt.s	.7a

	add.w	#1,num_obj2
	move.l	a4,(a3)+
	move.l	0(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.l	4(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.w	2(a6),d0
	cmp.w	6(a6),d0
	bgt.s	.7adz
	move.w	6(a6),(a1)+	; dz
	bra.s	.7a
.7adz	move.w	d0,(a1)+		; dz

.7a	move.l	(a0)+,(a6)
	move.l	(a0),4(a6)

	jsr	.cut_line
	tst.w	d0
	blt.s	.8a

	add.w	#1,num_obj2
	move.l	a4,(a3)+
	move.l	0(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.l	4(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.w	2(a6),d0
	cmp.w	6(a6),d0
	bgt.s	.8adz
	move.w	6(a6),(a1)+	; dz
	bra.s	.8a
.8adz	move.w	d0,(a1)+		; dz

.8a	move.l	(a0)+,(a6)
	move.l	(a0)+,4(a6)

	jsr	.cut_line
	tst.w	d0
	blt.s	.9a

	add.w	#1,num_obj2
	move.l	a4,(a3)+
	move.l	0(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.l	4(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.w	2(a6),d0
	cmp.w	6(a6),d0
	bgt.s	.9adz
	move.w	6(a6),(a1)+	; dz
	bra.s	.9a
.9adz	move.w	d0,(a1)+		; dz

.9a	subq.w	#3-1,d7
	dbf	d7,.fix_adr
	rts

.two_adr
	move.l	(a0)+,(a6)
	move.l	(a0),4(a6)

	jsr	.cut_line
	tst.w	d0
	blt.s	.10a

	add.w	#1,num_obj2
	move.l	a4,(a3)+
	move.l	0(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.l	4(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.w	2(a6),d0
	cmp.w	6(a6),d0
	bgt.s	.10adz
	move.w	6(a6),(a1)+	; dz
	bra.s	.10a
.10adz	move.w	d0,(a1)+		; dz

.10a	move.l	(a0)+,(a6)
	move.l	(a0)+,4(a6)

	jsr	.cut_line
	tst.w	d0
	blt.s	.11a

	add.w	#1,num_obj2
	move.l	a4,(a3)+
	move.l	0(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.l	4(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.w	2(a6),d0
	cmp.w	6(a6),d0
	bgt.s	.11adz
	move.w	6(a6),(a1)+	; dz
	bra.s	.11a
.11adz	move.w	d0,(a1)+		; dz

.11a	subq.w	#2-1,d7
	dbf	d7,.fix_adr
	rts

.one_adr
	move.l	(a0)+,(a6)
	move.l	(a0)+,4(a6)

	jsr	.cut_line
	tst.w	d0
	blt.s	.12a

	add.w	#1,num_obj2
	move.l	a4,(a3)+
	move.l	0(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.l	4(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.w	2(a6),d0
	cmp.w	6(a6),d0
	bgt.s	.12adz
	move.w	6(a6),(a1)+	; dz
	bra.s	.12a
.12adz	move.w	d0,(a1)+		; dz

.12a	dbf	d7,.fix_adr
	rts

.spec_adr
	move.l	(a0)+,(a6)
	move.l	(a0)+,4(a6)

	jsr	.cut_line
	tst.w	d0
	blt.s	.13a

	add.w	#1,num_obj2
	move.l	a4,(a3)+
	move.l	0(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.l	4(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.w	2(a6),d0
	cmp.w	6(a6),d0
	bgt.s	.13adz
	move.w	6(a6),(a1)+	; dz
	bra.s	.13a
.13adz	move.w	d0,(a1)+		; dz

.13a	move.l	(a0)+,(a6)
	move.l	(a0)+,4(a6)

	jsr	.cut_line
	tst.w	d0
	blt.s	.14a

	add.w	#1,num_obj2
	move.l	a4,(a3)+
	move.l	0(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.l	4(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.w	2(a6),d0
	cmp.w	6(a6),d0
	bgt.s	.14adz
	move.w	6(a6),(a1)+	; dz
	bra.s	.14a
.14adz	move.w	d0,(a1)+		; dz

.14a	subq.w	#2-1,d7
	dbf	d7,.fix_adr
	rts

.door_adr	
	move.l	(a0)+,(a6)
	move.l	(a0),4(a6)

	jsr	.cut_line
	tst.w	d0
	blt.s	.15a

	add.w	#1,num_obj2
	move.l	a4,(a3)+
	move.l	0(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.l	4(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.w	2(a6),d0
	cmp.w	6(a6),d0
	bgt.s	.15adz
	move.w	6(a6),(a1)+	; dz
	bra.s	.15a
.15adz	move.w	d0,(a1)+		; dz

.15a	move.l	(a0)+,(a6)
	move.l	(a0),4(a6)

	jsr	.cut_line
	tst.w	d0
	blt.s	.16a

	add.w	#1,num_obj2
	move.l	a4,(a3)+
	move.l	0(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.l	4(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.w	2(a6),d0
	cmp.w	6(a6),d0
	bgt.s	.16adz
	move.w	6(a6),(a1)+	; dz
	bra.s	.16a
.16adz	move.w	d0,(a1)+		; dz

.16a	move.l	(a0)+,(a6)
	move.l	(a0)+,4(a6)

	jsr	.cut_line
	tst.w	d0
	blt.s	.17a

	add.w	#1,num_obj2
	move.l	a4,(a3)+
	move.l	0(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.l	4(a6),(a4)+	; xz
	move.w	#-26*2,(a4)+	; y
	move.w	2(a6),d0
	cmp.w	6(a6),d0
	bgt.s	.17adz
	move.w	6(a6),(a1)+	; dz
	bra.s	.17a
.17adz	move.w	d0,(a1)+		; dz

.17a	move.w	(a0)+,d0		; x
	move.w	(a0)+,d1		; z
	move.w	(a2)+,d2		; vilken sprite (ligger efter connectnr)
	blt	.18a		; om -1 s† skit it

	cmp.w	#61,d2
	blt.s	.got2
	move.w	#0,d2
*	move.w	#$700,$ffff8240.w
.got2
	cmp.w	2(a0),d1		; jmf z med sprite 2
	bgt.s	.18a		; om st”rre ta andra spriten

	cmp.w	#LEFT,d0
	blt.s	.18a
	cmp.w	#RIGHT,d0
	bgt.s	.18a
	cmp.w	#UP,d1
	blt.s	.18a
	cmp.w	#DOWN,d1
	bgt.s	.18a

	move.l	a4,usp
	lea	sprite_config,a4	; y,bredd,h”jd,BPP-adr, Mask-adr, dummy

	lsl.w	#3,d2
	add.w	d2,a4		; till r„tt sprite

	add.w	#1,num_obj2	; antal objekt+1

	move.l	a5,(a3)+		; adr to koords
	move.w	d0,(a5)+		; x
	move.w	d1,(a5)+		; z
	move.l	(a4)+,(a5)+	; y + 1/2:a BBP adr
	move.l	(a4)+,(a5)+	; resterande BBP + spegelv„nd?

	move.l	usp,a4		; tillbax med adressen i USP:en

	move.w	d1,(a1)+		; dz
	addq.w	#4,a0
	addq.w	#2,a2
	bra	.19a		; vi beh”ver endast en sprite

.18a	move.w	(a0)+,d0		; x
	move.w	(a0)+,d1		; z
	move.w	(a2)+,d2		; vilken sprite (ligger efter connectnr)
	blt	.19a		; om -1 s† skit it

	cmp.w	#61,d2
	blt.s	.got3
	move.w	#0,d2
*	move.w	#$700,$ffff8240.w
.got3

	cmp.w	#LEFT,d0
	blt.s	.19a
	cmp.w	#RIGHT,d0
	bgt.s	.19a
	cmp.w	#UP,d1
	blt.s	.19a
	cmp.w	#DOWN,d1
	bgt.s	.19a

	move.l	a4,usp
	lea	sprite_config,a4	; y,bredd,h”jd,BPP-adr, Mask-adr, dummy

	lsl.w	#3,d2
	add.w	d2,a4		; till r„tt sprite

	add.w	#1,num_obj2	; antal objekt+1

	move.l	a5,(a3)+		; adr to koords
	move.w	d0,(a5)+		; x
	move.w	d1,(a5)+		; z
	move.l	(a4)+,(a5)+	; y + 1/2:a BBP adr
	move.l	(a4)+,(a5)+	; resterande BBP + spegelv„nd?

	move.l	usp,a4		; tillbax med adressen i USP:en

	move.w	d1,(a1)+		; dz
.19a
	subq.w	#5-1,d7
	dbf	d7,.fix_adr
	rts

********************************** Rutinen som klipper koordinater ********

.cut_line	move.w	#10,d6		; shift v„rde (exakthet)
	move.l	a1,usp

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	0(a6),d0
	move.w	2(a6),d1
	move.w	4(a6),d2
	move.w	6(a6),d3
	
	move.w	#0,.exg_flg

	cmp.w	d0,d2		; „r x1 st”rre „n x2
	bgt.s	.no_exg1		; s† byt plats p† kordinaterna
	exg	d0,d2
	exg	d1,d3
	add.w	#1,.exg_flg
.no_exg1	lea	.t_koords,a1
	movem.w	d0-d3,(a1)

**** Nu kollar vi om n†gon „r utanf”r
	
	move.w	#LEFT,d4
	cmp.w	(a1),d4		; v„nster gr„ns
	ble.s	.no_cx1
	jsr	.clipp_x1
.no_cx1	move.w	#RIGHT,d4
	cmp.w	4(a1),d4		; h”ger gr„ns
	bge.s	.no_cx2
	jsr	.clipp_x2
.no_cx2
	movem.w	(a1),d0-d3
	cmp.w	d1,d3		; „r y1 st”rre „n y2
	bgt.s	.no_exg2		; s† byt plats p† kordinaterna
	exg	d0,d2
	exg	d1,d3
	add.w	#1,.exg_flg
.no_exg2	movem.w	d0-d3,(a1)

	move.w	#UP,d4
	cmp.w	2(a1),d4
	ble.s	.no_cy1
	jsr	.clipp_y1
.no_cy1	move.w	#DOWN,d4
	cmp.w	6(a1),d4
	bge.s	.no_cy2
	jsr	.clipp_y2
.no_cy2
	movem.l	(a1),d0-d1
	cmp.w	#1,.exg_flg
	bne.s	.no_exg3
	exg.l	d0,d1
.no_exg3	movem.l	d0-d1,(a6)

	move.l	usp,a1
	moveq	#0,d0		; klippt o klar
	rts

.utanf”r	move.l	usp,a1
	moveq	#-1,d0		; utanf”r
	addq.l	#4,sp
	rts
 
******************* Rutinen som klipper mot v„nsterkanten

.clipp_x1	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	0(a1),d0
	move.w	2(a1),d1
	move.w	4(a1),d2
	move.w	6(a1),d3

	cmp.w	#LEFT,d2		; kolla x2 mot v„nstergr„nsen
	blt	.utanf”r

	move.w	d2,d4		; spara x2
	move.w	d3,d5		; spara y2
	sub.w	d0,d2		; dx1
	sub.w	d1,d3		; dy1
	bgt.s	.no_neg1

	neg.w	d3
	sub.w	#LEFT,d4		; dx2
	asl.l	d6,d3		; *32 (f”rl„ng dy1)
	divs	d2,d3
	muls	d4,d3
	asr.l	d6,d3		; dy2
	add.w	d3,d5		; ny1=y2+dy2
	move.w	#LEFT,(a1)	; nya x1
	move.w	d5,2(a1)		; nya y1
	rts

.no_neg1	sub.w	#LEFT,d4		; dx2
	asl.l	d6,d3		; *32 (f”rl„ng dy1)
	divs	d2,d3
	muls	d4,d3
	asr.l	d6,d3		; dy2
	sub.w	d3,d5		; ny1=y2+dy2
	move.w	#LEFT,(a1)		; nya x1
	move.w	d5,2(a1)		; nya y1
	rts

******************* Rutinen som klipper mot h”gerkanten

.clipp_x2	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	0(a1),d0
	move.w	2(a1),d1
	move.w	4(a1),d2
	move.w	6(a1),d3

	cmp.w	#RIGHT,d0		; kolla x2 mot v„nstergr„nsen
	bgt	.utanf”r

	move.w	d2,d4		; spara x2
	move.w	d3,d5		; spara y2
	sub.w	d0,d2		; dx1
	sub.w	d1,d3		; dy1
	bgt.s	.no_neg2
	
	neg.w	d3
	sub.w	#RIGHT,d4		; dx2
	asl.l	d6,d3
	divs	d2,d3
	muls	d4,d3
	asr.l	d6,d3		; dy2
	add.w	d3,d5		; ny1=y2+dy2
	move.w	#RIGHT,4(a1)	; nya x1
	move.w	d5,6(a1)		; nya y1
	rts

.no_neg2	sub.w	#RIGHT,d4		; dx2
	asl.l	d6,d3		; *32 (f”rl„ng dy1)
	divs	d2,d3
	muls	d4,d3
	asr.l	d6,d3		; dy2
	sub.w	d3,d5		; ny1=y2+dy2
	move.w	#RIGHT,4(a1)	; nya x1
	move.w	d5,6(a1)		; nya y1
	rts

******************* Rutinen som klipper mot ”verkanten

.clipp_y1	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	2(a1),d0
	move.w	0(a1),d1
	move.w	6(a1),d2
	move.w	4(a1),d3

	cmp.w	#UP,d2		; kolla x2 mot v„nstergr„nsen
	blt	.utanf”r

	move.w	d2,d4		; spara x2
	move.w	d3,d5		; spara y2
	sub.w	d0,d2		; dx1
	sub.w	d1,d3		; dy1
	bgt.s	.no_neg3

	neg.w	d3
	sub.w	#UP,d4		; dx2
	asl.l	d6,d3		; *32 (f”rl„ng dy1)
	divs	d2,d3
	muls	d4,d3
	asr.l	d6,d3		; dy2
	add.w	d3,d5		; ny1=y2+dy2
	move.w	d5,(a1)		; nya y1
	move.w	#UP,2(a1)		; nya x1
	rts

.no_neg3	sub.w	#UP,d4		; dx2
	asl.l	d6,d3		; *32 (f”rl„ng dy1)
	divs	d2,d3
	muls	d4,d3
	asr.l	d6,d3		; dy2
	sub.w	d3,d5		; ny1=y2+dy2
	move.w	d5,(a1)		; nya y1
	move.w	#UP,2(a1)		; nya x1
	rts

******************* Rutinen som klipper mot underkanten

.clipp_y2	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	2(a1),d0
	move.w	0(a1),d1
	move.w	6(a1),d2
	move.w	4(a1),d3

	cmp.w	#DOWN,d0		; kolla x2 mot v„nstergr„nsen
	bgt	.utanf”r

	move.w	d2,d4		; spara x2
	move.w	d3,d5		; spara y2
	sub.w	d0,d2		; dx1
	sub.w	d1,d3		; dy1
	bgt.s	.no_neg4

	neg.w	d3
	sub.w	#DOWN,d4		; dx2
	asl.l	d6,d3		; *32 (f”rl„ng dy1)
	divs	d2,d3
	muls	d4,d3
	asr.l	d6,d3		; dy2
	add.w	d3,d5		; ny1=y2+dy2
	move.w	d5,4(a1)		; nya y1
	move.w	#DOWN,6(a1)	; nya x1
	rts

.no_neg4	sub.w	#DOWN,d4		; dx2
	asl.l	d6,d3		; *32 (f”rl„ng dy1)
	divs	d2,d3
	muls	d4,d3
	asr.l	d6,d3		; dy2
	sub.w	d3,d5		; ny1=y2+dy2
	move.w	d5,4(a1)		; nya y1
	move.w	#DOWN,6(a1)	; nya x1
	rts

.tempo		ds.l	4
.t_koords		ds.l	4
.exg_flg		ds.w	1

* +-----------------------------------------------------------------------+	
* | Sortera koordinaterna. Den yta som „r l„ngst fram f”rst               |
* +-----------------------------------------------------------------------+	
* ui
sort_cords
	moveq	#0,d3		; fram i lista_djup r„knare
	moveq	#0,d4		; fram i lista_adr  r„knare
	moveq	#0,d5		; tillbakablick-r„knare

	move.w	num_obj2,d7
	beq	.sort_ej		; om det bara „r en v„gg s† skiti't

	sub.w	#1,d7		; -1
.loop1	lea	dz_points,a0
	lea	dz_points+2,a1
	lea	adr_points,a2
	lea	adr_points+4,a3
	add.l	d3,a0
	add.l	d3,a1
	add.l	d4,a2
	add.l	d4,a3
	addq.l	#2,d3
	addq.l	#4,d4
	
	move.w	d5,d6		; ”ver till loopr„knare
.loop2	move.w	(a0),d0
	move.w	(a1),d1
	
	cmp.w	d0,d1
	bge.s	.sl_lp2
	
	move.w	d1,(a0)		; byt plats
	move.w	d0,(a1)
	move.l	(a2),d0
	move.l	(a3),(a2)
	move.l	d0,(a3)

	subq.l	#2,a0		; ner en pos.
	subq.l	#2,a1
	subq.l	#4,a2
	subq.l	#4,a3
	dbf	d6,.loop2
.sl_lp2	addq.w	#1,d5		; en mer
	dbf	d7,.loop1	

.sort_ej	rts

* +-----------------------------------------------------------------------+	
* | Perspektivera alla koordinater (xz=>xy)                               |
* +-----------------------------------------------------------------------+	
* ui
persp_cords
	lea	adr_points,a0
	lea	list1+70*4*4,a1
	lea	list2+50*2,a4
	
	move.w	#55*8,d0
	move.w	#-UP+7,d4		; y=-52

	move.w	num_obj2,d7
.proj_it	move.l	(a0)+,a2
	cmp.l	#xyz_sprite_points,a2
	bge.s	.sprite

	move.l	a2,a3

	move.w	(a2)+,d1		; x
	move.w	(a2)+,d3		; z
	addq.w	#2,a2		; y

	asl.w	#2,d1
	move.l	(a1,d1),d1	; a1*x
	add.w	d4,d3		; a2+z
	bne.s	.divva
	moveq	#1,d3
.divva	divs	d3,d1
	move.w	d1,(a3)+		; new x
	addq.l	#2,a3
	add.w	d3,d3
	move.w	(a4,d3.w),(a3)+	; new y

*** Punkt tv†

	move.w	(a2)+,d1		; x
	move.w	(a2)+,d3		; z
	add.w	#2,a2		; y

	asl.w	#2,d1
	move.l	(a1,d1),d1	; a1*x
	add.w	d4,d3		; a2+z
	bne.s	.divva2
	moveq	#1,d3
.divva2	divs	d3,d1
	move.w	d1,(a3)+		; new x
	addq.l	#2,a3
	add.w	d3,d3
	move.w	(a4,d3.w),(a3)+	; new y
	dbf	d7,.proj_it
	rts

;-------- Perspektiv om det „r en sprite ------------

.sprite	move.l	a2,a3

	move.w	(a2)+,d1		; x
	move.w	(a2)+,d3		; z
	move.w	(a2)+,d2		; y
	move.w	d2,d5		; Varf”r??

	asl.w	#2,d1
	move.l	(a1,d1),d1	; a1*x
	add.w	d4,d3		; a2+z
	divs	d3,d1
	move.w	d1,(a3)+		; new x
	asl.w	#2,d2
	addq.l	#2,a3
	move.l	(a1,d2),d2	; a*y
	divs	d3,d2
	move.w	d2,(a3)+		; new y

	dbf	d7,.proj_it
	rts

* +-----------------------------------------------------------------------+	
* | Rita upp alla v„ggar och fixa klipp-koordinater                       |
* +-----------------------------------------------------------------------+	
* ui
paint_walls

	lea	.scan+324,a0		; rensa scanen
	movem.l	.tom,d0-d7/a1-a6
	movem.l	d0-d7/a1-a6,-(a0)
	movem.l	d0-d7/a1-a6,-(a0)
	movem.l	d0-d7/a1-a6,-(a0)
	movem.l	d0-d7/a1-a6,-(a0)
	movem.l	d0-d7/a1-a6,-(a0)
	movem.l	d0-d7/a1-a3,-(a0)

	move.b	#%10000000,.scan
	move.b	#%00000001,.scan+319
	move.w	#-1,num_sprites
	move.l	#sprite_adr_buffer,var_spr_adr
	move.l	#sprite_clipp_buffer,var_spr_clipp

	lea	adr_points,a0
	move.w	num_obj2,d7

.big_lp	lea	.koords,a2
	lea	.scan,a3
	lea	.loop1,a4
	lea	.loop2,a5

	move.l	(a0)+,a1
	cmp.l	#xyz_sprite_points,a1
	bge	.sprite
				; d0 d1 d2 d3 d4 d5
	movem.w	(a1),d0-d5	; x1,z1,y1,x2,z2,y2
	
	neg.w	d0
	neg.w	d3

*	move.w	d0,d6
*	asl.w	#2,d0
*	add.w	d6,d0
*	add.w	d6,d0
*	add.w	d6,d0
	asr.w	#2,d2

*	move.w	d3,d6
*	asl.w	#2,d3
*	add.w	d6,d3
*	add.w	d6,d3
*	add.w	d6,d3
	asr.w	#2,d5

	add.w	#160,d0
	add.w	#160,d3
	add.w	#79,d2
	add.w	#79,d5
	
	cmp.w	d0,d3		; kolla om ytan „r
	bgt	.rita_ej		; felv„nd
	tst.w	d0		; till v„nster om bilden
	blt	.rita_ej		; eller till h”ger om
	cmp.w	#319,d3		; bilden
	bgt	.rita_ej

	move.w	d0,(a2)+		; x1
	move.w	d2,(a2)+		; y1
	move.w	#0,(a2)+		; z1 (alltid 0!)
	move.w	d3,(a2)+		; x2
	move.w	d5,(a2)+		; y2
	move.w	#0,(a2)+		; z2 (alltid 0!)
	move.w	#1,(a2)+		; den „r ju iaf alltid 1

	moveq	#0,d1		; pixelcount
	moveq	#0,d2		; antal clipp
	
.loop1	REPT	320
	tst.b	(a3)+
	beq	.f1t0
	addq.w	#1,d1
	ENDR
	bra	.slut_p†_scan

.loop2	REPT	320
	tst.b	(a3)+
	bne	.f0t1
	addq.w	#1,d1
	ENDR
	bra	.slut_p†_scan

.f1t0
	move.w	d1,(a2)+		; s„tt clippet
	addq.w	#1,d1		; ”ka pixelcount
	addq.w	#1,d2		; antal clipp
	move.w	d1,d5		; pixel
	move.l	a5,a6		; loop2 adr
	lsl.w	#3,d5		; pixel*8
	add.w	d5,a6		; adda fram till r„tt tst
	jmp	(a6)		; hoppa dit
	
.f0t1	subq.w	#1,d1
	move.w	d1,(a2)+		; s„tt clippet
	addq.w	#2,d1		; ”ka pixelcount
	move.w	d1,d5		; pixexl
	move.l	a4,a6		; loop1 adr
	lsl.w	#3,d5		; pixel *8
	add.w	d5,a6		; adda fram till r„tt tst
	jmp	(a6)		; hoppa

.slut_p†_scan
	tst.w	d2		; kolla om hela scannen „r fylld
	beq	.ej_mer

	move.w	d2,.koords+12	; s„tt antal clipp

;----- L„gg in denna yta p† scannen

	tst.w	d3
	bge.s	.klarar1
	moveq	#0,d3
.klarar1	cmp.w	#319,d0
	ble.s	.klarar2
	move.w	#319,d0
.klarar2
	
	lea	.scan,a3
	add.w	d3,a3		; till r„tt pixel
	sub.w	d3,d0		; antal pixels
.fyll_lp	move.b	#-1,(a3)+
	dbf	d0,.fyll_lp

	movem.l	d7/a0,-(sp)
	lea	.koords,a0
	move.l	screen,a1
	jsr	poly
	movem.l	(sp)+,d7/a0
	
.rita_ej	dbf	d7,.big_lp
.ej_mer	rts

;------- Sprite rutinen -------

.sprite	cmp.w	#ANT_SPR-1,num_sprites
	beq	.no_more_sprites

	move.l	var_spr_adr,a3
	move.l	var_spr_clipp,a4
	lea	.scan,a5
	
	move.l	a4,(a3)+			; adr till clippet
	move.l	a1,(a3)+			; adr till koordsen

	lea	.loop3,a1			; hopp adresser
	lea	.loop4,a2

	move.w	#1,(a4)+			; antclp „r iaf alltid 1

;--------- R„kna ut clippet ---------

	moveq	#0,d1		; pixelcount
	moveq	#0,d2		; antal clipp
	
.loop3	REPT	320
	tst.b	(a5)+
	beq	.f1t02
	addq.w	#1,d1
	ENDR
	bra	.slut_p†_scan2

.loop4	REPT	320
	tst.b	(a5)+
	bne	.f0t12
	addq.w	#1,d1
	ENDR
	bra	.slut_p†_scan2

.f1t02	move.w	d1,(a4)+		; s„tt clippet
	addq.w	#1,d1		; ”ka pixelcount
	addq.w	#1,d2		; antal clipp
	move.w	d1,d5		; pixel
	move.l	a2,a6		; loop2 adr
	lsl.w	#3,d5		; pixel*8
	add.w	d5,a6		; adda fram till r„tt tst
	jmp	(a6)		; hoppa dit
	
.f0t12	move.w	d1,(a4)+		; s„tt clippet
	addq.w	#1,d1		; ”ka pixelcount
	move.w	d1,d5		; pixexl
	move.l	a1,a6		; loop1 adr
	lsl.w	#3,d5		; pixel *8
	add.w	d5,a6		; adda fram till r„tt tst
	jmp	(a6)		; hoppa

.slut_p†_scan2
	tst.w	d2		; kolla om hela scannen „r fylld
	beq	.ej_mer		; is†fall sluta
	
	addq.w	#1,num_sprites		; en till sprite
	move.l	var_spr_clipp,a1
	move.w	d2,(a1)		; s„tt antal clipp

	move.l	a3,var_spr_adr
	move.l	a4,var_spr_clipp

.no_more_sprites
	dbf	d7,.big_lp
	rts

.koords		ds.w	7		; koordinater+antclipp
		ds.l	14		; cv,ch
.scan		ds.b	320
.tom		ds.l	20

* +-----------------------------------------------------------------------+	
* | Ritar upp en sprite med hj„lp av de undansparade clippsen i paintwalls
* +-----------------------------------------------------------------------+	
* ui
paint_sprites
	tst.w	num_sprites
	blt	.no_sprites

	move.w	#0,right_x	; Nolla rightx leftx
	move.w	#0,left_x
	move.l	#0,skjut_adr	; nolla
	
	move.l	var_spr_adr,a2
	move.w	num_sprites,d7
.spr_lp
	move.l	-(a2),a3		; adr till koords
	move.l	-(a2),a1		; adr till clipp

	move.w	(a3)+,d0		; x
	move.w	(a3)+,d2		; z
	move.w	(a3)+,d1		; y
	move.l	(a3)+,a0		; BBP-adr
	move.w	(a3)+,d3		; l„gre byte=spegelv„nd?
	move.l	(a3)+,a4		; adr till spr ursprung

	tst.w	d2
	blt	.skip_spr

	move.l	d2,-(sp)
	
	neg.w	d0
	asr.w	#2,d1
	add.w	#160,d0
	add.w	#79,d1

	cmp.l	#bana,a0
	bge.s	.fispr
	mulu	#24576,d2
	swap	d2
	rol.l	#2,d2
	moveq	#0,d4
	bra.s	.statspr
.fispr	mulu	#18022,d2
	swap	d2
	rol.l	#2,d2
	moveq	#1,d4

.statspr	tst.b	d3
	bne.s	.spegelv„nd

	IFEQ	SPR
	movem.l	d4/d7/a2/a4,-(sp)
	jsr	draw_sprite
	movem.l	(sp)+,d4/d7/a2/a4
	ENDC

.kolltrf	move.l	(sp)+,d2

	tst.w	d4		; ritades en fi?
	beq.s	.skip_spr

	move.w	#156,d1
	cmp.w	#3,vilket_vapen
	bne.s	.ejrifle
	addq.w	#3,d1
.ejrifle	move.w	d1,d2
	sub.w	#160,d2
	neg.w	d2
	add.w	d2,d2

	move.w	left_x,d0		; kolla om startpunkten
	sub.w	d1,d0		; ligger inom mittdiffen
	blt.s	.chk_r
	sub.w	d2,d0
	bgt.s	.skip_spr
	bra.s	.inom	
.chk_r	move.w	right_x,d0
	sub.w	d1,d0
	blt.s	.skip_spr

.inom	move.l	a4,skjut_adr	; denna adr tr„ffar jag om jag
	move.w	d2,skjut_adr+4	; avst till denne (f”r kniven)

.skip_spr	dbf	d7,.spr_lp
.no_sprites
	rts

.spegelv„nd
	IFEQ	SPR
	movem.l	d4/d7/a2/a4,-(sp)
	jsr	draw_inverse_sprite
	movem.l	(sp)+,d4/d7/a2/a4
	ENDC
	bra	.kolltrf

* +-*********************************************************************-+
* | Sudda sk„rmen och v„nd p† den rutinerna                               |
* * B†da rutinerna „r blitteroberoende                         / /        *
* * Av Mikael Emtinger 1995                                   /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-+
put_screen
	lea	tak_golv,a0
	move.l	screen,a1

	moveq	#70-1,d6
.loop	
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,a2
	move.l	d1,a3
	
	movem.l	d0-d5/a2-a3,(a1)
	movem.l	d0-d5/a2-a3,32(a1)
	movem.l	d0-d5/a2-a3,64(a1)
	movem.l	d0-d5/a2-a3,96(a1)
	movem.l	d0-d5/a2-a3,128(a1)
	lea	160(a1),a1
	dbf	d6,.loop

	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6

	movem.l	d0-d6/a2-a6,(a1)
sunex	set	48
	rept	32
	movem.l	d0-d6/a2-a6,sunex(a1)
sunex	set	sunex+48
	endr
	movem.l	d0-d3,sunex(a1)
	rts

turn_screen
	move.l	screen,a0
	lea	158*160(a0),a1
	
	REPT	87
	movem.l	(a0)+,d0-d7/a2-a6	; 13 longs
	movem.l	d0-d7/a2-a6,(a1)
	movem.l	(a0)+,d0-d7/a2-a6	; 26 longs
	movem.l	d0-d7/a2-a6,13*4(a1)
	movem.l	(a0)+,d0-d7/a2-a6	; 39 longs
	movem.l	d0-d7/a2-a6,26*4(a1)
	move.l	(a0)+,39*4(a1)	; 40 longs
	lea	-160(a1),a1
	ENDR
	
	rts

* +-*********************************************************************-+
* | SFX-rutinen (DD-Audio)                                                |
* * Init statsound och r„knar ut statsound                     / /        *
* * Av Mikael Emtinger 1995                                   /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-
dd_audio
	
	IFEQ	DD
	tst.w	.chkflg
	bne.s	.go
	add.w	#1,.chkflg
	rts
.go	move.w	#0,.chkflg
	jsr	move_statsound
	jsr	add_soundfx

	rts

.chkflg	ds.w	1

* +-----------------------------------------------------------------------+	
* | flytta statsound. Ber„knar de statiska ljudens avst†nd och vinklar    |
* +-----------------------------------------------------------------------+	
* ui
move_statsound
	lea	stat_prefs,a0	; antal,x1z1nr1bs1x2z2... osv
	move.w	(a0)+,d7		; -1 = inga stat_sound
	bmi	.no_stat_sound
.sound_lp
	move.w	(a0)+,d2		; x
	move.w	(a0)+,d3		; z

	cmp.w	#1984,d2
	blt.s	.change_it
	cmp.w	#1984,d3
	bge	.always_same

.change_it
	sub.w	x_gubbe,d2			; x avst
	bge.s	.no_n1
	neg.w	d2
.no_n1	sub.w	z_gubbe,d3			; z avst
	bge.s	.no_n2
	neg.w	d3
.no_n2
	move.w	d2,d4
	lsr.w	#4,d4
	sub.w	d4,d2
	move.w	d3,d4
	lsr.w	#4,d4
	sub.w	d4,d3

	cmp.w	#511,d2		; om n†got av avst†nden
	bgt.s	.no_sound		; „r st”rre „n 511 s† kommer
	cmp.w	#511,d3		; det inte h”ras n†gonting
	bgt.s	.no_sound		; och d„rf”r hoppar till no_sound
	mulu	d2,d2		; dx^2
	mulu	d3,d3		; dz^2
	add.l	d2,d3

	jsr	roten_ur		; tar roten ur d3.l
	cmp.w	#511,d3
	ble.s	.bra
	move.w	#511,ljud_distans
	bra.s	.ej_bra
.bra	move.w	d3,ljud_distans
.ej_bra
	moveq	#0,d2
	move.w	-4(a0),d1		; xljud
	move.w	-2(a0),d2		; zljud
	jsr	r„kna_vinkel
	move.w	d3,ljud_vinkel	; vinkel
	move.w	(a0),ljud_nr	; ljud nummer
	move.w	2(a0),bs_channel	; kanal
	add.w	#18,ljud_nr
	jsr	move_backsound
.no_sound
	lea	4(a0),a0
	dbf	d7,.sound_lp
.no_stat_sound
	rts

.always_same
	move.w	#0,ljud_vinkel
	move.w	stat_vol,ljud_distans
	move.w	(a0),ljud_nr	; ljud nummer
	move.w	2(a0),bs_channel	; kanal
	add.w	#18,ljud_nr
	jsr	move_backsound
	lea	4(a0),a0
	dbf	d7,.sound_lp
	rts

* +-----------------------------------------------------------------------+	
* | addera ljudeffekt. Adderar en ljudeffekt p† komando av AI-rutinen     |
* +-----------------------------------------------------------------------+	
* ui
add_soundfx

	lea	sound_board,a0
	
	move.w	(a0)+,d7			; antal ljud att addera
	subq.w	#1,d7
	bmi	.no_sfx

.lp_d7	move.w	(a0)+,d2
	move.w	(a0)+,d3
	
	sub.w	x_gubbe,d2			; x avst
	bge.s	.no_n1
	neg.w	d2
.no_n1	sub.w	z_gubbe,d3			; z avst
	bge.s	.no_n2
	neg.w	d3
.no_n2
	cmp.w	#4,d2
	bgt	.ej_nara
	cmp.w	#4,d3
	ble	.set_v0
.ej_nara
	cmp.w	#511,d2			; om n†got av avst†nden
	bgt.s	.no_sound		; „r st”rre „n 511 s† kommer
	cmp.w	#511,d3			; det inte h”ras n†gonting
	bgt.s	.no_sound		; och d„rf”r hoppar till no_sound
	mulu	d2,d2			; dx^2
	mulu	d3,d3			; dz^2
	add.l	d2,d3

	jsr	roten_ur		; tar roten ur d3.l
	cmp.w	#511,d3
	ble.s	.bra
	move.w	#511,ljud_distans
	bra.s	.ej_bra
.bra	move.w	d3,ljud_distans
.ej_bra
	moveq	#0,d2
	move.w	-4(a0),d1		; xljud
	move.w	-2(a0),d2		; zljud
	jsr	r„kna_vinkel
	move.w	d3,ljud_vinkel	; vinkel
	move.w	(a0),ljud_nr	; ljud nummer

	jsr	add_sfx

.no_sound	lea	2(a0),a0
	dbf	d7,.lp_d7

	lea	sound_board,a0
	move.w	(a0)+,d7
.cl_sb	move.l	#0,(a0)+
	move.w	#0,(a0)+
	dbf	d7,.cl_sb	

	move.w	#0,sound_board	; antal ljud ska oxo rensas

.no_sfx	rts

.set_v0	move.w	#0,ljud_distans	; avst†nd
	move.w	#0,ljud_vinkel	; vinkel
	move.w	(a0),ljud_nr	; ljud nummer
	jsr	add_sfx
	lea	2(a0),a0
	dbf	d7,.lp_d7

	lea	sound_board,a0
	move.w	(a0)+,d7
.cl_sb2	move.l	#0,(a0)+
	move.w	#0,(a0)+
	dbf	d7,.cl_sb2

	move.w	#0,sound_board	; antal ljud ska oxo rensas

	rts

* +-----------------------------------------------------------------------+	
* | Init statsound, l„gg ut och f”rbered bakgrundsljuden                  |
* +-----------------------------------------------------------------------+	
* ui
init_statsound
	lea	stat_prefs,a0		; antal,x1z1nr1bs1x2z2... osv
	move.w	(a0)+,d7		; -1 = inga stat_sound
	bmi	.no_stat_sound
.sound_lp
	move.w	(a0)+,d2		; x
	move.w	(a0)+,d3		; z
	move.w	#511,ljud_distans
	move.w	#0,ljud_vinkel
	move.w	(a0)+,ljud_nr	; vilket ljud
	move.w	(a0)+,bs_channel	; kanal
	add.w	#18,ljud_nr

	jsr	put_backsound		; starta detta ljud
	dbf	d7,.sound_lp
.no_stat_sound
	rts

	ENDC

;- Lokal rutin som tar roten ur d3.l --------------------------------------
roten_ur
	movem.l	d0-d2/d4-d6/a1,-(sp)
	moveq	#0,d0			; minsta v„rdet
	move.l	#524288,d1		; max v„rdet
	move.w	#256*4,d2			; add ett
	move.w	#512,d4
	move.w	#256,d5
	lea	sqr_list+512*4,a1		; peeka p† mitten av listan
	move.w	#9-1,d6			; det r„cker med 9 itterationer
.lp_d6	cmp.l	(a1),d3
	bgt.s	.st”rre_„n
	move.l	(a1),d1			; l†t maxv„rdet antaga v„rdet a1
	sub.w	d2,a1			; peeka p† mitten av n„sta omr†de
	lsr.w	#1,d2			; n„sta add ska vara h„lften
	dbf	d6,.lp_d6
	bra.s	.go_on
.st”rre_„n
	move.l	(a1),d0			; l†t minv„rdet antaga v„rdet a1
	add.w	d2,a1			; peeka p† mitten av n„sta omr†de
	lsr.w	#1,d2			; n„sta add ska vara h„lften
	dbf	d6,.lp_d6
.go_on	sub.l	#sqr_list,a1
	move.l	a1,d3
	lsr.l	#2,d3
	movem.l	(sp)+,d0-d2/d4-d6/a1	; s† inte utv„rdet pajjas
	rts

;- Lokal rutin som ber„knar den relativa vinkeln till ljudet --------------

r„kna_vinkel
	movem.l	d4/a1,-(sp)

	lea	asin,a1

	sub.w	x_gubbe,d1
	sub.w	z_gubbe,d2

	tst.w	d1
	bgt.s	.kpp
	beq.s	.dx0		; specialrutin om dx=0
	tst.w	d2
	bge.s	.xmzp

.xmzm	move.w	#90,d4		; fix add f”r min-x min-z
	exg.l	d1,d2
	neg.w	d1
	bra.s	.go_on
.xmzp	move.w	#0,d4		; fix add f”r min-x plu-z
	neg.w	d1
	bra.s	.go_on

.dx0	tst.w	d2
	ble.s	.xpzm
	move.w	#0,d4
	bra.s	.go_on

.kpp	tst.w	d2
	bgt.s	.xpzp
.xpzm	move.w	#180,d4		; fix add f”r plu-x min-z
	bra.s	.go_on
.xpzp	move.w	#270,d4		; fix add f”r plu-x plu-z
	exg.l	d1,d2
.go_on

;-------- R„kna ut resten -------

	ext.l	d1
	move.w	#12,d2
	lsl.l	d2,d1

	tst.w	d3
	beq.s	.no_div
	divu	d3,d1
	
	cmp.w	#4096,d1
	ble.s	.ej_over
	move.w	#4097,d1
.ej_over	moveq	#0,d3

	move.b	(a1,d1.w),d3
	add.w	d4,d3		; stor vinkel

	sub.w	look_angle,d3
	bge.s	.ej_res1
	add.w	#360,d3
.ej_res1	movem.l	(sp)+,d4/a1
	rts

.no_div	moveq	#0,d3		; om hyp=0 s† tr„ffar man alltid
	movem.l	(sp)+,d4/a1
	rts


* +-*********************************************************************-+
* | Warning rutinen                                                       |
* * F„jdar paletten och s„tter ljudet                          / /        *
* * Av Mikael Emtinger 1995                                   /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-+
do_warning
	cmp.w	#2,warning
	blt	.warning_on
	bgt	.warning_off

.bomb	add.w	#1,.vblcount
	cmp.w	#2,.vblcount
	bne	back_wa

	move.w	#0,.vblcount

	cmp.w	#22*2,.counter
	bne.s	.ej_nolls
	move.w	#0,.counter
	bra	back_wa
	
.ej_nolls	add.w	#1,.counter
	cmp.w	#22,.counter
	bge.s	.fejd_ner
	
;--- F„jda upp till r”tt ---

.fejd_upp	lea	nuvarande_pal,a0
	lea	warn_pal,a1
	moveq	#16-1,d0
	jsr	paltopal
	bra	back_wa

;--- F„jda ner till svart ---

.fejd_ner	lea	nuvarande_pal,a0
	lea	svart_pal,a1
	moveq	#16-1,d0
	jsr	paltopal
	bra	back_wa

.warning_on
	move.w	#2,warning
	move.w	#22,.counter

	lea	stat_prefs,a0
	lea	.savestat,a1

	move.w	(a0)+,(a1)+	; spara den gamla statprefsen
	move.l	(a0)+,(a1)+	
	move.l	(a0)+,(a1)+	
	move.l	(a0)+,(a1)+	
	move.l	(a0)+,(a1)+	
	move.l	(a0)+,(a1)+	
	move.l	(a0)+,(a1)+	

	lea	stat_prefs,a0
	move.w	#3-1,(a0)+	; antal
	move.w	#2000,(a0)+	; x
	move.w	#2000,(a0)+	; z
	move.w	#15-18,(a0)+	; num
	move.w	#0,(a0)+		; chan
	move.w	#2000,(a0)+	; x
	move.w	#2000,(a0)+	; z
	move.w	#15-18,(a0)+	; num
	move.w	#1,(a0)+		; chan
	move.w	#2000,(a0)+	; x
	move.w	#2000,(a0)+	; z
	move.w	#15-18,(a0)+	; num
	move.w	#2,(a0)+		; chan

	jsr	init_statsound
	bra	.bomb

.warning_off
	lea	nuvarande_pal,a0
	lea	pal,a1
	move.w	#16-1,d0
	jsr	paltopal

	lea	nuvarande_pal,a0
	lea	pal,a1
	move.w	#16-1,d7
.jmf_lp	move.w	(a0)+,d0
	cmp.w	(a1)+,d0
	bne.s	.ej_klar
	dbf	d7,.jmf_lp
	move.w	#0,warning
.ej_klar
	tst.w	warning
	bne	back_wa

	lea	.savestat,a0
	lea	stat_prefs,a1

	move.w	(a0)+,(a1)+	; s„tt tillbax statprefsen
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+	
	move.l	(a0)+,(a1)+	
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+	
	move.l	(a0)+,(a1)+

	jsr	init_statsound
	bra	back_wa

.counter		dc.w	1
.vblcount		dc.w	1
.savestat		dc.w	0
		dc.w	0,0,0,0
		dc.w	0,0,0,0
		dc.w	0,0,0,0

paltopal	lea	.trans_lista,a2	; transfer list
	lea	.col_list,a3
.fade_lp	move.w	(a0),d1		; color from
	move.w	(a1),d2		; color to
	and.w	#$f00,d1		; just r
	and.w	#$f00,d2
	ror.w	#8,d1		; to lower nibble		
	ror.w	#8,d2		
	add.w	d1,d1
	add.w	d2,d2
	move.w	0(a2,d1.w),d3
	move.w	0(a2,d2.w),d4	
	cmp.w	d3,d4		; if eq goto green
	beq.s	.equal1
	cmp.w	d3,d4
	blt.s	.ner†t1
	addq.w	#2,d3
	move.w	0(a3,d3.w),d3	; new color
	rol.w	#8,d3
	move.w	d3,d7		; total color data reg
	bra.s	.green
.ner†t1	subq.w	#2,d3	
	move.w	0(a3,d3.w),d3	
	rol.w	#8,d3
	move.w	d3,d7
	bra.s	.green
.equal1	move.w	0(a3,d3.w),d3	; new color
	rol.w	#8,d3
	move.w	d3,d7		; total color data reg
.green	move.w	(a0),d1		; color from
	move.w	(a1),d2		; color to
	and.w	#$0f0,d1		; just g
	and.w	#$0f0,d2
	ror.w	#4,d1		; to lower nibble		
	ror.w	#4,d2		
	add.w	d1,d1
	add.w	d2,d2
	move.w	0(a2,d1.w),d3
	move.w	0(a2,d2.w),d4	
	cmp.w	d3,d4		; if eq goto green
	beq.s	.equal2
	cmp.w	d3,d4
	blt.s	.ner†t2
	addq.w	#2,d3
	move.w	0(a3,d3.w),d3	; new color
	rol.w	#4,d3
	or.w	d3,d7		; total color data reg
	bra.s	.blue
.ner†t2	subq.w	#2,d3	
	move.w	0(a3,d3.w),d3	
	rol.w	#4,d3
	or.w	d3,d7
	bra.s	.blue
.equal2	move.w	0(a3,d3.w),d3	; new color
	rol.w	#4,d3
	or.w	d3,d7		; total color data reg
.blue	move.w	(a0),d1		; color from
	move.w	(a1)+,d2		; color to
	and.w	#$00f,d1		; just b
	and.w	#$00f,d2
	add.w	d1,d1
	add.w	d2,d2
	move.w	0(a2,d1.w),d3
	move.w	0(a2,d2.w),d4	
	cmp.w	d3,d4		; if eq goto green
	beq.s	.equal3
	cmp.w	d3,d4
	blt.s	.ner†t3
	addq.w	#2,d3
	move.w	0(a3,d3.w),d3	; new color
	or.w	d3,d7		; total color data reg
	bra.s	.save_col
.ner†t3	subq.w	#2,d3	
	move.w	0(a3,d3.w),d3	
	or.w	d3,d7
	bra.s	.save_col
.equal3	move.w	0(a3,d3.w),d3	; new color
	or.w	d3,d7		; total color data reg
.save_col
	move.w	d7,(a0)+		; save color
	dbf	d0,.fade_lp
	rts

.trans_lista	dc.w	1*2,3*2,5*2,7*2,9*2,11*2,13*2,15*2,2*2,4*2,6*2,8*2,10*2,12*2,14*2,16*2
.col_list		dc.w	$0,$0,$8,$1,$9,$2,$a,$3,$b,$4,$c,$5,$d,$6,$e,$7,$f

	rts

* +-*********************************************************************-+
* | St”rfade rutinen                                                      |
* * F„jdar paletten lite fram och tillbaka                     / /        *
* * Av Mikael Emtinger 1995                                   /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-+
do_stor_pal
	tst.w	warning
	bne	back_wa
	tst.w	go_goggles
	bne	back_wa

	add.w	#1,.vbl_cnt
	cmp.w	#15,.vbl_cnt
	bgt.s	.fade_up

	add.w	#1,.fade_flg
	cmp.w	#5,.fade_flg
	bne	back_wa
	move.w	#0,.fade_flg
	lea	nuvarande_pal,a0
	lea	svart_pal,a1
	move.w	#16-1,d0
	jsr	paltopal
	bra	back_wa
	
.fade_up	cmp.w	#30,.vbl_cnt
	bgt.s	.res

	add.w	#1,.fade_flg
	cmp.w	#5,.fade_flg
	bne	back_wa
	move.w	#0,.fade_flg
	lea	nuvarande_pal,a0
	lea	pal,a1
	move.w	#16-1,d0
	jsr	paltopal
	bra	back_wa	

.res	move.w	#0,.vbl_cnt
	move.w	#0,.fade_flg
*	movem.l	pal,d0-d7
*	movem.l	d0-d7,nuvarande_pal
	bra	back_wa

.vbl_cnt		dc.w	0
.fade_flg		dc.w	0

* +-*********************************************************************-+
* | G”r panelen rutinen                                                   |
* * F”rbereder parameterlistan och lite annat till panelen     / /        *
* * Av Mikael Emtinger 1994                                   /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-+
prepare_panel

	cmp.w	#2,vilket_vapen
	beq.s	.oockk
	cmp.w	#4,vilket_vapen
	bne.s	.no_new_anim
.oockk	tst.w	skj_flg
	beq.s	.no_new_anim
	add.w	#1,vilken_anim_vapen
	cmp.w	#3,vilken_anim_vapen
	blt.s	.no_new_anim
	move.w	#0,vilken_anim_vapen
.no_new_anim

	move.w	vilket_vapen,d1
	cmp.w	.gamla_vapen,d1
	beq.s	.inte_nytt_vapen
	move.w	#1,chg_flg
.inte_nytt_vapen

;-------- Kolla om laddning vapen --------

	tst.w	ladda_om_flg
	beq	.chk_change

	cmp.w	#2,ladda_om_flg
	blt	.lad_ner
	bgt	.lad_upp

.lad_ljd	move.w	#2,ladda_om_flg
	add.w	#1,.waitcnt
	cmp.w	#7,.waitcnt
	bne.s	.nosnd
	lea	sound_board,a0	; starta ljud f”r exp
	move.w	(a0),d0
	add.w	#1,(a0)+
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,a0
	move.l	x_gubbe,(a0)+	; xz
	move.w	#13,(a0)+		; ljud nr

.nosnd	cmp.w	#14,.waitcnt
	bne.s	.w8more
	move.w	#0,.waitcnt
	move.w	#3,ladda_om_flg
.w8more
	move.w	#0,bmp_line
	move.l	#159*160+56,vap_add
	move.w	#0,.gupp_vart
	bra	.lad_upp

.lad_ner	add.l	#5*160,vap_add
	move.l	vap_add,d2
	sub.l	#56,d2		; ta bort xadden
	divu	#160,d2		; antal rader
	neg.w	d2
	add.w	#159,d2		; antal rader h”gt nu
	add.w	d2,d2
	move.w	d2,bmp_line

	tst.w	d2
	ble	.lad_ljd

	bra	.chk_change

.lad_upp	sub.l	#5*160,vap_add
	move.l	vap_add,d2
	sub.l	#56,d2		; ta bort xadden
	divu	#160,d2		; antal rader
	neg.w	d2
	add.w	#159,d2		; antal rader h”gt nu
	add.w	d2,d2
	move.w	d2,bmp_line
	
	cmp.w	#118,bmp_line
	bge.s	.lad_ready

	bra.s	.chk_change
	
.lad_ready
	move.w	#0,bmp_line
	move.l	#159*160+56,vap_add
	move.w	#0,ladda_om_flg

;-------- Kolla om byte av vapen --------

.chk_change
	tst.w	chg_flg
	beq	.bump_it

	cmp.w	#2,chg_flg
	blt.s	.dra_ner
	bgt.s	.dra_upp

.chg_vap	move.w	vilket_vapen,.gamla_vapen
	move.w	#0,bmp_line
	move.l	#159*160+56,vap_add
	move.w	#3,chg_flg
	move.w	#0,.gupp_vart
	bra	.dra_upp

.dra_ner	add.l	#3*160,vap_add
	move.l	vap_add,d2
	sub.l	#56,d2		; ta bort xadden
	divu	#160,d2		; antal rader
	neg.w	d2
	add.w	#159,d2		; antal rader h”gt nu
	add.w	d2,d2
	move.w	d2,bmp_line

	tst.w	d2
	ble.s	.chg_vap

	lea	vapen_listor,a0
	lea	ammo_vapen,a1
	move.w	vilken_anim_vapen,d0
	move.w	.gamla_vapen,d1
	bra	.set_it

.dra_upp	sub.l	#3*160,vap_add
	move.l	vap_add,d2
	sub.l	#56,d2		; ta bort xadden
	divu	#160,d2		; antal rader
	neg.w	d2
	add.w	#159,d2		; antal rader h”gt nu
	add.w	d2,d2
	move.w	d2,bmp_line
	
	cmp.w	#118,bmp_line
	bge.s	.chg_ready

	lea	vapen_listor,a0
	lea	ammo_vapen,a1
	move.w	vilken_anim_vapen,d0
	move.w	vilket_vapen,d1
	bra.s	.set_it
	
.chg_ready
	move.w	#0,bmp_line
	move.l	#159*160+56,vap_add
	move.w	#0,chg_flg

;-------- Bumpa vapnet ---------

.bump_it	tst.w	ladda_om_flg
	beq.s	.ejlad

	lea	vapen_listor,a0
	lea	ammo_vapen,a1
	move.w	vilken_anim_vapen,d0
	move.w	vilket_vapen,d1
	bra	.set_it

.ejlad
*	move.w	#5*2,d2		; bump speed
*	tst.w	fram
*	bne.s	.gupp
*	tst.w	bak†t
*	bne.s	.gupp
	move.w	#1*2,d2		; bump speed
	bra.s	.gupp
.gupp_klar
	lea	vapen_listor,a0
	lea	ammo_vapen,a1
	move.w	vilken_anim_vapen,d0
	move.w	vilket_vapen,d1
.set_it
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a0
	move.l	(a0),a0

	add.w	d1,d1
	add.w	d1,a1
	move.w	(a1),ammo
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,a0
	move.l	(a0)+,vilkvap
	move.l	(a0)+,vilkbmp
	rts

.gupp	lea	sin_360,a0
	add.w	d2,.gupp_vart
	move.w	.gupp_vart,d0
	cmp.w	#720,d0
	blt.s	.ej_reset
	sub.w	#720,d0
	sub.w	#720,.gupp_vart
.ej_reset
	add.w	d0,a0
	move.w	(a0),d0		; sinv„rde
	muls	#5,d0
	swap	d0
	rol.l	#2,d0
	move.w	#60*2,d1
	add.w	#5,d0
	add.w	d0,d0
	sub.w	d0,d1
	move.w	d1,bmp_line
	mulu	#80,d0
	add.l	#160*99+56,d0
	move.l	d0,vap_add
	bra	.gupp_klar

.gupp_vart	dc.w	0
.gamla_vapen	dc.w	0
.waitcnt		dc.w	0

* +-*********************************************************************-+
* | ka hiss och byta sublevel rutinen                                    |
* * S„tter statsound ... v„ntar ... initsublev ... go          / /        *
* * Av Mikael Emtinger 1995                                   /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-
new_sublev
	move.w	oldsublev,d0
	cmp.w	sublev,d0
	bne.s	.tst_hiss
	rts
	
.tst_hiss	movem.l	d0-d7/a0-a6,-(sp)
	move.l	bytemap_2,a0

	move.w	x_gubbe,d0
	move.w	z_gubbe,d1
	lsr.w	#6,d0
	lsr.w	#6,d1
	lsl.w	#5,d1
	add.w	d0,d1
	
	cmp.b	#96,(a0,d1.w)
	blt	.skip
	cmp.b	#100,(a0,d1.w)
	bgt	.skip

	move.l	maps,a0
	add.l	#6*2+6*4,a0
	move.w	sublev,d0
	mulu	#4162,d0
	add.w	d0,a0
	add.l	#32*32+32*32,a0
	
	cmp.b	#96,(a0,d1.w)
	blt	.skip
	cmp.b	#100,(a0,d1.w)
	bgt	.skip

	move.l	last_door,a0		; kolla om man st„ngt
	cmp.l	#0,a0
	beq.s	.byt
	tst.w	20(a0)			; d”rren
	bne.s	.skip

.byt	move.w	#1,bytt_sublev
	movem.l	(sp)+,d0-d7/a0-a6
	rts

.skip	move.w	oldsublev,sublev
	movem.l	(sp)+,d0-d7/a0-a6
	rts


* +-----------------------------------------------------------------------+	
* | D† tar vi och †ker lite hiss...                                       |
* +-----------------------------------------------------------------------+	
* ur
go_elevator
	tst.w	bytt_sublev
	bne.s	.yep
	rts
.yep
	move.l	#0,last_door
	move.w	#0,bytt_sublev
	move.l	#.hiss_vbi,$70.w
	move.l	s118,$118.w

	movem.l	pal,d0-d7		; s„tt startpal
	movem.l	d0-d7,nuvarande_pal

	REPT	3
	lea	nuvarande_pal,a0	; pal att f„jda fr†n
	lea	svart_pal,a1	; pal att f„jda till
	moveq	#16-1,d0		; antal f„rger
	jsr	paltopal
	jsr	vsync
	jsr	vsync
	ENDR

	move.w	#15,d0			; s„gg att man †ker hiss
	jsr	do_mess

	lea	stat_prefs,a1
	move.w	#3-1,(a1)+		; antal stat ljud
	move.w	#2016,(a1)+		; x
	move.w	#2016,(a1)+		; z
	move.w	#14-18,(a1)+		; nr-16
	move.w	#0,(a1)+			; chan
	move.w	#2016,(a1)+		; x
	move.w	#2016,(a1)+		; z
	move.w	#14-18,(a1)+		; nr-16
	move.w	#1,(a1)+			; chan
	move.w	#2016,(a1)+		; x
	move.w	#2016,(a1)+		; z
	move.w	#14-18,(a1)+		; nr-16
	move.w	#2,(a1)+			; chan
	jsr	init_statsound		; init sound

	jsr	set_screen
	move.w	#50*5/2,d7
.waitlp	jsr	vsync
	dbf	d7,.waitlp

	lea	hiddbuf,a0
	move.l	bytemap_0,a1
	move.l	bytemap_2,a2
	moveq	#0,d0

	move.w	#32*32-1,d7
.lp	cmp.b	#148,(a2)
	bne	.hp
	cmp.b	#0,(a1)
	beq	.hp
	
	move.l	a0,a3
	move.w	#30-1,d6
.chklp	cmp.w	(a3)+,d0
	bne.s	.again

	move.b	(a3)+,-32(a1)
	move.b	(a3)+,32(a1)
	move.b	#9,(a1)
	bra	.hp

.again	addq.l	#2,a3
	dbf	d6,.chklp

.hp	addq.l	#1,a1
	addq.l	#1,a2
	addq.w	#1,d0
	dbf	d7,.lp

	move.l	maps,a0
	add.l	#5*2,a0
	lea	stat_prefs,a1

	move.w	sublev,d0
	mulu	#4162,d0
	add.w	d0,a0

	move.w	sublev,oldsublev

	move.w	(a0)+,(a1)+		; antal stat ljud
	move.l	(a0)+,(a1)+		; xz
	move.l	(a0)+,(a1)+		; num,chan
	move.l	(a0)+,(a1)+		; xz
	move.l	(a0)+,(a1)+		; num,chan
	move.l	(a0)+,(a1)+		; xz
	move.l	(a0)+,(a1)+		; num,chan

	move.l	a0,bytemap_0		; walldata
	add.l	#32*32,a0
	move.l	a0,bytemap_1		; connect data
	add.l	#32*32,a0
	move.l	a0,bytemap_2		; location data
	add.l	#32*32,a0
	move.l	a0,bytemap_3		; event data

	lea	akt_d_adr,a0		; nolla aktiva d”rrar
	move.w	#ANT_DOOR-1,d7
.aktd	move.l	#0,(a0)+
	dbf	d7,.aktd
	
	lea	bomb_adr,a0		; nolla aktiva bomber
	move.w	#ANT_BOMB-1,d7
.bmb	move.l	#0,(a0)+
	dbf	d7,.bmb
	
	lea	explosion_adr,a0		; nolla aktiva exp
	move.w	#ANT_EXP-1,d7
.exp	move.l	#0,(a0)+
	dbf	d7,.exp
	
	move.l	#0,aktiva_skott		; nolla flygande skott
	move.w	#0,sound_board		; nolla sfx

	jsr	init_3dworld		; init adrmap
	jsr	panel_sublevinit		; init panel
	jsr	init_av_fi		; init fi
	move.l	splbank_adr2,a0
	jsr	init_sound		; stoppa ljudet
	jsr	init_statsound		; init statsound
 
	REPT	3
	lea	nuvarande_pal,a0	; pal att f„jda fr†n
	lea	pal,a1		; pal att f„jda till
	moveq	#16-1,d0		; antal f„rger
	jsr	paltopal
	jsr	vsync
	jsr	vsync
	ENDR

	jsr	vsync

	lea	tecken_area,a0	; rensa acia listan
	move.w	#20-1,d7
.rens1	move.b	#0,(a0)+
	dbf	d7,.rens1

	move.l	#vbi,$70.w
	move.l	#my_118,$118.w
	jsr	vsync
	jsr	set_screen2

	movem.l	pal,d0-d7
	movem.l	d0-d7,nuvarande_pal
	rts

;-------- Hiss Vbi --------

.hiss_vbi	clr.b	$fffffa1b.w
	move.b	#159,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.w	#0,pnlflag
	addq.w	#1,vflag

	movem.l	d0-d7/a0-a6,-(sp)

	movem.l	nuvarande_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	tst.w	midi_on
	beq.s	.no_midi
	jsr	ud_midi
	tst.w	hostconn
	beq.s	.no_midi
	jsr	host_start
.no_midi

	IFEQ	DD
	jsr	dd_audio			; g”r ljudet
	jsr	sound_rout		; play dd-audio
	ENDC

	jsr	time_ud			; uppdatera tiden
	jsr	cd_ud			; uppdatera countdown
	jsr	ud_mess			; uppdatera medelanden
	jsr	ud_lock			; uppdatera location

	movem.l	(sp)+,d0-d7/a0-a6
	rte

* +-*********************************************************************-+
* | Styr rutinen                                                          |
* * $118.w-rutinen => flagg-s„tt => handle-rutinen             / /        *
* * Av Mikael Emtinger 1994                                   /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-+
styr
	tst.w	.flg
	bne.s	.go
	move.w	#1,.flg
	rts
.go	move.w	#0,.flg

	jsr	s„tt_flag
	jsr	handle_styr	; ta hand om styrningen
	jsr	handle_plock	; ta hand om d”rrar och plock
	jsr	handle_event	; ta hand om events
	rts

.flg	ds.w	1

* +-----------------------------------------------------------------------+	
* | Min egna 118-rutin                                                    |
* +-----------------------------------------------------------------------+	
* ur
my_118
	move.l	a0,-(sp)
	move.l	tecken_list(pc),a0
	move.b	$fffffc02.w,(a0)+
	move.l	a0,tecken_list
	move.l	(sp)+,a0

	tst.w	midi_on
	beq.s	.rte

	tst.w	com_id
	bne	slave_acia
	bra	host_acia

.rte	bclr	#6,$fffffa11.w
	rte

* +-----------------------------------------------------------------------+	
* | Rutinen som var VBL s„tter handle-flaggor                             |
* +-----------------------------------------------------------------------+	
* ur
s„tt_flag	move.l	#tecken_area,tecken_list	; resetta peekarn...
	lea	tecken_area,a0
	lea	.tecken_adr,a1
	
	move.w	#20-1,d7
.loop	moveq	#0,d0
	move.b	(a0)+,d0
	bne.s	.list
	dbf	d7,.loop

	lea	tecken_area,a0
	move.w	#20-1,d7
.rens1	move.b	#0,(a0)+
	dbf	d7,.rens1
	rts

.list	add.w	d0,d0			; v„rde*4
	add.w	d0,d0
	move.l	(a1,d0.w),a2		; adr till rutinen
	jmp	(a2)			; hoppa
.no_u	dbf	d7,.loop

	lea	tecken_area,a0
	move.w	#20-1,d7
.rens2	move.b	#0,(a0)+
	dbf	d7,.rens2
	rts

.control1	move.w	#1,skjut
	move.w	#0,richo_flg
	bra	.no_u
.control2	move.w	#0,skjut
	cmp.w	#2,vilket_vapen
	beq.s	.clear_a
	cmp.w	#4,vilket_vapen
	beq.s	.clear_a
	bra	.no_u
.clear_a	move.w	#0,vilken_anim_vapen
	bra	.no_u
.shift1	move.w	#1,spring
	bra	.no_u
.shift2	move.w	#0,spring
	bra	.no_u
.alter1	move.w	#1,straf
	bra	.no_u
.alter2	move.w	#0,straf
	bra	.no_u
.upp1	move.w	#1,fram
	move.w	#0,bak†t
	bra	.no_u
.upp2	move.w	#3,fram
	bra	.no_u
.v„nster1	move.w	#1,h”ger
	move.w	#0,v„nster
	bra	.no_u
.v„nster2	move.w	#3,h”ger
	bra	.no_u
.h”ger1	move.w	#1,v„nster
	move.w	#0,h”ger
	bra	.no_u
.h”ger2	move.w	#3,v„nster
	bra	.no_u
.ned1	move.w	#1,bak†t
	move.w	#0,fram
	bra	.no_u
.ned2	move.w	#3,bak†t
	bra	.no_u
.pilpil1	move.w	#1,straf_right
	move.w	#0,straf_left
	move.w	look_angle,straf_angle
	bra	.no_u
.pilpil2	move.w	#0,straf_right
	move.w	#0,straf_angle
	bra	.no_u
.z_tang1	move.w	#1,straf_left
	move.w	look_angle,straf_angle
	move.w	#0,straf_right
	move.w	#90+1,c_teck
	bra	.no_u
.z_tang2	move.w	#0,straf_left
	move.w	#0,straf_angle
	bra	.no_u
.space1	move.w	#1,space
	bra	.no_u
.space2	move.w	#0,space
	bra	.no_u
.ett	move.w	#0,vilket_vapen
	move.w	#SKADA0,vapen_skada
	move.w	#1,„ndrat_vapen
	bra	.no_u
.tva	move.w	#1,vilket_vapen
	move.w	#SKADA1,vapen_skada
	move.w	#1,„ndrat_vapen
	bra	.no_u
.tre	tst.w	har_vapen+4
	beq	.no_u
	move.w	#1,„ndrat_vapen
	move.w	#2,vilket_vapen
	move.w	#SKADA2,vapen_skada
	bra	.no_u
.fyr	tst.w	har_vapen+6
	beq	.no_u
	move.w	#1,„ndrat_vapen
	move.w	#3,vilket_vapen
	move.w	#SKADA3,vapen_skada
	bra	.no_u
.fem	tst.w	har_vapen+8
	beq	.no_u
	move.w	#1,„ndrat_vapen
	move.w	#4,vilket_vapen
	move.w	#SKADA4,vapen_skada
	bra	.no_u
.sex	tst.w	har_vapen+10
	beq	.no_u
	move.w	#1,„ndrat_vapen
	move.w	#5,vilket_vapen
	move.w	#SKADA5,vapen_skada
	bra	.no_u
.bomb1	move.w	#1,bomb_lagd
	bra	.no_u
.bomb2	move.w	#0,bomb_lagd
	bra	.no_u
.nt_1	move.w	#0,sublev
	jsr	new_sublev
	bra	.no_u
.nt_2	cmp.w	#1,ant_sublev
	blt	.no_u
	move.w	#1,sublev
	jsr	new_sublev
	bra	.no_u
.nt_3	cmp.w	#2,ant_sublev
	blt	.no_u
	move.w	#2,sublev
	jsr	new_sublev
	bra	.no_u
.nt_4a	jsr	map_left
	bra	.no_u
.nt_4b	jsr	rel_left
	bra	.no_u
.nt_5a	jsr	map_down
	bra	.no_u
.nt_5b	jsr	rel_down
	bra	.no_u
.nt_6a	jsr	map_right
	bra	.no_u
.nt_6b	jsr	rel_right
	bra	.no_u
.nt_8a	jsr	map_up
	bra	.no_u
.nt_8b	jsr	rel_up
	bra	.no_u
.nt_7	jsr	tag_sr
	bra	.no_u
.nt_9	jsr	map_norm
	bra	.no_u
.esc	move.w	#1,escflg
	move.w	#2,q_stat
	bra	.no_u
.yes1	move.w	#1,q_stat
	move.w	#89+1,c_teck
	bra	.no_u
.no1	move.w	#2,q_stat
	move.w	#78+1,c_teck
	bra	.no_u
.yes2	move.w	#0,q_stat
	bra	.no_u
.no2	move.w	#0,q_stat
	bra	.no_u
.aa	move.w	#65+1,c_teck
	bra	.no_u
.bb	move.w	#66+1,c_teck
	bra	.no_u
.cc	move.w	#67+1,c_teck
	bra	.no_u
.dd	move.w	#68+1,c_teck
	bra	.no_u
.ee	move.w	#69+1,c_teck
	bra	.no_u
.ff	move.w	#70+1,c_teck
	bra	.no_u
.gg	move.w	#71+1,c_teck
	bra	.no_u
.hh	move.w	#72+1,c_teck
	bra	.no_u
.ii	move.w	#73+1,c_teck
	bra	.no_u
.jj	move.w	#74+1,c_teck
	bra	.no_u
.kk	move.w	#75+1,c_teck
	bra	.no_u
.ll	move.w	#76+1,c_teck
	bra	.no_u
.mm	move.w	#77,c_teck
	bra	.no_u
.oo	move.w	#79+1,c_teck
	bra	.no_u
.pp	move.w	#80+1,c_teck
	bra	.no_u
.qq	move.w	#81+1,c_teck
	bra	.no_u
.rr	move.w	#82+1,c_teck
	bra	.no_u
.ss	move.w	#83+1,c_teck
	bra	.no_u
.tt	move.w	#84+1,c_teck
	bra	.no_u
.uu	move.w	#85+1,c_teck
	bra	.no_u
.vv	move.w	#86+1,c_teck
	bra	.no_u
.ww	move.w	#87+1,c_teck
	bra	.no_u
.xx	move.w	#88+1,c_teck
	bra	.no_u

.slut	jmp	end		; **************************
 
.tecken_adr	dc.l	.no_u
		dc.l	.esc
		dc.l	.ett,.tva,.tre,.fyr,.fem,.sex
		REPT	6
		dc.l	.no_u
		ENDR
		dc.l	.slut,.bomb1
		dc.l	.qq,.ww,.ee,.rr,.tt
		dc.l	.yes1
		dc.l	.uu,.ii,.oo,.pp
		REPT	3
		dc.l	.no_u
		ENDR
		dc.l	.control1
		dc.l	.aa,.ss,.dd,.ff,.gg,.hh,.jj,.kk,.ll
		REPT	3
		dc.l	.no_u
		ENDR
		dc.l	.shift1,.no_u,.z_tang1
		dc.l	.xx,.cc,.vv,.bb,.no1,.mm
		dc.l	.no_u
		dc.l	.pilpil1,.z_tang1,.shift1,.no_u
		dc.l	.alter1,.space1,.control1
		REPT	12
		dc.l	.no_u
		ENDR
		dc.l	.z_tang1
		dc.l	.upp1,.no_u,.no_u
		dc.l	.v„nster1,.no_u
		dc.l	.h”ger1,.no_u,.no_u
		dc.l	.ned1,.no_u,.pilpil1
		REPT	13
		dc.l	.no_u
		ENDR
		dc.l	.pilpil1
		REPT	6
		dc.l	.no_u
		ENDR
		dc.l	.nt_7,.nt_8a,.nt_9
		dc.l	.nt_4a,.nt_5a,.nt_6a
		dc.l	.nt_1,.nt_2,.nt_3
		REPT	16
		dc.l	.no_u
		ENDR
		
		REPT	14
		dc.l	.no_u
		ENDR
		dc.l	.slut,.bomb2
		REPT	5
		dc.l	.no_u
		ENDR
		dc.l	.yes2
		REPT	7
		dc.l	.no_u
		ENDR
		dc.l	.control2
		REPT	12
		dc.l	.no_u
		ENDR
		dc.l	.shift2,.no_u,.z_tang2
		REPT	4
		dc.l	.no_u
		ENDR
		dc.l	.no2,.no_u
		dc.l	.no_u,.pilpil2,.z_tang2
		dc.l	.shift2,.no_u
		dc.l	.alter2,.space2,.control2
		REPT	12
		dc.l	.no_u
		ENDR
		dc.l	.z_tang2
		dc.l	.upp2,.no_u,.no_u
		dc.l	.v„nster2,.no_u
		dc.l	.h”ger2,.no_u,.no_u
		dc.l	.ned2,.no_u,.pilpil2
		REPT	13
		dc.l	.no_u
		ENDR
		dc.l	.pilpil2
		REPT	6
		dc.l	.no_u
		ENDR
		dc.l	.no_u,.nt_8b,.no_u
		dc.l	.nt_4b,.nt_5b,.nt_6b
		REPT	19
		dc.l	.no_u
		ENDR
		
tecken_list	dc.l	tecken_area
tecken_area	ds.b	20

* +-----------------------------------------------------------------------+	
* | Handle styr. Tar hand om de satta styr flaggorna (exk space)          |
* +-----------------------------------------------------------------------+	
* ui
handle_styr

;--------- Kolla om man snurrar eller strafar v„nster ---------

	tst.w	straf_left
	bne.s	.st_left

	tst.w	v„nster		; rotera plus
	beq	.ej_v„nster
	tst.w	straf
	beq	.no_straf_left

	cmp.w	#3,v„nster
	bne	.bonk1
	bra	.ej_v„nster
.bonk1
	move.w	look_angle,d0	; vinkel
	add.w	#90,d0
	cmp.w	#360,d0
	blt.s	.no_wrap1a
	sub.w	#360,d0
.no_wrap1a

	move.w	#STRAFV,d1		; speed
	move.w	#STRAFS,d2		; +runspeed
	jsr	.count_and_chk
	bra	.ej_v„nster

.st_left	move.w	straf_angle,d0	; vinkel
	add.w	#90,d0
	cmp.w	#360,d0
	blt.s	.no_wrap1b
	sub.w	#360,d0
.no_wrap1b
	move.w	#STRAFV,d1		; speed
	move.w	#STRAFS,d2		; +runspeed
	jsr	.count_and_chk
	tst.w	v„nster
	beq	.ej_v„nster
	add.w	#ROTSTRAF,look_angle

.no_straf_left
	cmp.w	#2,v„nster
	blt.s	.acc_v„nst
	bgt.s	.ret_v„nst

.van_v„nst
	move.w	#2,v„nster
	add.w	#ROTV,look_angle
	tst.w	spring
	beq.s	.no_faster_left
	add.w	#ROTS,look_angle
.no_faster_left
	cmp.w	#360,look_angle
	blt	.ej_v„nster
	sub.w	#360,look_angle
	bra	.ej_v„nster

.acc_v„nst
	add.w	#1,.acc_ret_v„nst
	move.w	.acc_ret_v„nst,d0
	asr.w	#TRO_ROT,d0
	cmp.w	#ROTV,d0
	bge.s	.van_v„nst

	add.w	d0,look_angle
	tst.w	spring
	beq.s	.no_f_left1
	move.w	#ROTS,d0
	asr.w	#1,d0
	add.w	d0,look_angle
.no_f_left1
	cmp.w	#360,look_angle
	blt.s	.ej_v„nster
	sub.w	#360,look_angle
	bra.s	.ej_v„nster
	
.ret_v„nst
	sub.w	#1,.acc_ret_v„nst
	move.w	.acc_ret_v„nst,d0
	asr.w	#TRO_ROT,d0
	tst.w	d0
	ble.s	.still_v„nst
	
	add.w	d0,look_angle
	tst.w	spring
	beq.s	.no_f_left2
	move.w	#ROTS,d0
	asr.w	#1,d0
	add.w	d0,look_angle
.no_f_left2
	cmp.w	#360,look_angle
	blt.s	.ej_v„nster
	sub.w	#360,look_angle
	bra.s	.ej_v„nster
	
.still_v„nst
	move.w	#0,v„nster
	move.w	#0,.acc_ret_v„nst

.ej_v„nster

;--------- Kolla om man snurrar eller strafar h”ger ---------

	tst.w	straf_right
	bne.s	.st_righ

	tst.w	h”ger		; rotera plus
	beq	.ej_h”ger
	tst.w	straf
	beq	.no_straf_right

	cmp.w	#3,h”ger
	bne	.bonk2
	bra	.ej_h”ger
.bonk2
	move.w	look_angle,d0	; vinkel
	sub.w	#90,d0
	tst.w	d0
	bge.s	.no_wrap2a
	add.w	#360,d0
.no_wrap2a
	move.w	#STRAFV,d1		; speed
	move.w	#STRAFS,d2		; +runspeed
	jsr	.count_and_chk
	bra	.ej_h”ger

.st_righ	move.w	straf_angle,d0	; vinkel
	sub.w	#90,d0
	tst.w	d0
	bge.s	.no_wrap2b
	add.w	#360,d0
.no_wrap2b
	move.w	#STRAFV,d1		; speed
	move.w	#STRAFS,d2		; +runspeed
	jsr	.count_and_chk

	tst.w	h”ger
	beq	.ej_h”ger
	sub.w	#ROTSTRAF,look_angle

.no_straf_right

	cmp.w	#2,h”ger
	blt.s	.acc_h”ger
	bgt	.ret_h”ger

.van_h”ger
	move.w	#2,h”ger
	sub.w	#ROTV,look_angle
	tst.w	spring
	beq.s	.no_faster_right
	sub.w	#ROTS,look_angle
.no_faster_right
	tst.w	look_angle
	bge	.ej_h”ger
	add.w	#360,look_angle
	bra	.ej_h”ger

.acc_h”ger
	add.w	#1,.acc_ret_h”ger
	move.w	.acc_ret_h”ger,d0
	asr.w	#TRO_ROT,d0
	cmp.w	#ROTV,d0
	bge.s	.van_h”ger

	sub.w	d0,look_angle
	tst.w	spring
	beq.s	.no_f_right1
	move.w	#ROTS,d0
	asr.w	#1,d0
	sub.w	d0,look_angle
.no_f_right1
	tst.w	look_angle
	bge.s	.ej_h”ger
	add.w	#360,look_angle
	bra.s	.ej_h”ger
	
.ret_h”ger
	sub.w	#1,.acc_ret_h”ger
	move.w	.acc_ret_h”ger,d0
	asr.w	#TRO_ROT,d0
	tst.w	d0
	ble.s	.still_h”ger
	
	sub.w	d0,look_angle
	tst.w	spring
	beq.s	.no_f_right2
	asr.w	#1,d0
	sub.w	d0,look_angle
.no_f_right2
	tst.w	look_angle
	bge.s	.ej_h”ger
	add.w	#360,look_angle
	bra.s	.ej_h”ger
	
.still_h”ger
	move.w	#0,h”ger
	move.w	#0,.acc_ret_h”ger
.ej_h”ger

;--------- Kolla om man g†r fram†t ---------

	tst.w	fram
	beq	.ej_fram

	cmp.w	#2,fram
	blt.s	.acc_fram
	bgt.s	.ret_fram

.van_fram	move.w	#2,fram
	move.w	look_angle,d0	; vinkel
	move.w	#FRAMV,d1		; speed
	move.w	#FRAMS,d2		; +runspeed
	jsr	.count_and_chk
	bra.s	.ej_fram
	
.acc_fram	add.w	#1,.acc_ret_framv
	move.w	.acc_ret_framv,d0
	asr.w	#TRO_GO,d0
	cmp.w	#FRAMV,d0
	bge.s	.van_fram
	
	move.w	d0,d1
	move.w	d0,d2
	asr.w	#1,d2
	move.w	look_angle,d0	; vinkel
	jsr	.count_and_chk
	bra.s	.ej_fram

.ret_fram	sub.w	#1,.acc_ret_framv
	move.w	.acc_ret_framv,d0
	asr.w	#TRO_GO,d0
	tst.w	d0
	ble.s	.still_fram
	
	move.w	d0,d1
	move.w	d0,d2
	lsr.w	#1,d2
	move.w	look_angle,d0
	jsr	.count_and_chk
	bra.s	.ej_fram

.still_fram
	move.w	#0,.acc_ret_framv
	move.w	#0,fram	

.ej_fram

;--------- Kolla om man g†r bak†t ---------

	tst.w	bak†t
	beq	.ej_bak

	cmp.w	#2,bak†t
	blt.s	.acc_bak
	bgt.s	.ret_bak

.van_bak	move.w	#2,bak†t
	move.w	look_angle,d0	; vinkel
	move.w	#BAKV,d1		; speed
	move.w	#BAKS,d2		; +runspeed
	jsr	.count_and_chk
	bra.s	.ej_bak

.acc_bak	sub.w	#1,.acc_ret_bakv
	move.w	.acc_ret_bakv,d0
	asr.w	#TRO_GO,d0
	cmp.w	#BAKV,d0
	ble.s	.van_bak
	
	move.w	d0,d1
	move.w	d0,d2
	asr.w	#1,d2
	move.w	look_angle,d0
	jsr	.count_and_chk
	bra.s	.ej_bak
	
.ret_bak	add.w	#1,.acc_ret_bakv
	move.w	.acc_ret_bakv,d0
	asr.w	#TRO_GO,d0
	tst.w	d0
	bge.s	.still_bak

	move.w	d0,d1
	move.w	d0,d2
	asr.w	#1,d2
	move.w	look_angle,d0
	jsr	.count_and_chk
	bra.s	.ej_bak

.still_bak
	move.w	#0,.acc_ret_bakv
	move.w	#0,bak†t
.ej_bak

;---- Kolla om man skjuter och is†fall om man tr„ffar n†gon -------

	tst.w	skjut
	beq	.set_ej_flg
	move.w	#1,skj_flg
.set_ej_flg

	tst.w	skj_flg
	beq	.ej_skjut

	tst.w	ladda_om_flg
	bne	.ej_skjut
	
	tst.w	chg_flg
	bne	.ej_skjut

	tst.w	.ljd_flg
	bne.s	.ej_nytt_ljud
	tst.w	vilket_vapen
	beq.s	.addadd
	tst.w	ammo
	beq	.ej_nytt_ljud
.addadd	lea	sound_board,a0
	lea	ljud_vapen,a1
	move.w	vilket_vapen,d0
	add.w	d0,d0
	add.w	d0,a1
	move.w	(a0),d0
	add.w	#1,(a0)+
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,a0
	move.l	x_gubbe,(a0)+	; xz
	move.w	(a1),(a0)+		; ljud nr
	move.w	#1,.ljd_flg
.ej_nytt_ljud

	lea	ammo_vapen,a0
	lea	ansp_vapen,a1
	lea	rept_vapen,a2
	move.w	vilket_vapen,d0
	add.w	d0,d0
	add.w	d0,a0
	add.w	d0,a1
	add.w	d0,a2

	tst.w	vilket_vapen
	beq	.ammo_ej_slut
	tst.w	(a0)		; kolla ammon
	bgt	.ammo_ej_slut

	move.w	#0,vilken_anim_vapen
	move.w	#0,.anim_flg
	move.w	#0,.anim_flg2
	move.w	#0,skj_flg

	lea	har_vapen+10,a0
	lea	ammo_vapen+10,a1
	move.w	#5,vilket_vapen

	move.w	#5-1,d7		; Kolla vilket vapen han
.chg_vpn	tst.w	(a0)		; ska v„lja om ammon tar slut
	beq.s	.ej_vpn
	tst.w	(a1)
	beq.s	.ej_vpn
	move.w	#1,„ndrat_vapen
	bra	.ej_skjut
.ej_vpn	subq.w	#2,a0
	subq.w	#2,a1
	sub.w	#1,vilket_vapen
	dbf	d7,.chg_vpn
	move.w	#1,„ndrat_vapen
	bra	.ej_skjut

.ammo_ej_slut

	cmp.w	#2,vilket_vapen
	beq	.no_new_anim
	cmp.w	#4,vilket_vapen
	beq	.no_new_anim
	tst.w	.anim_flg2
	bne	.no_new_anim
	add.w	#1,.anim_flg	; kolla om ny animation
	move.w	.anim_flg,d1
	cmp.w	(a1),d1
	blt.s	.no_new_anim
	move.w	#0,.anim_flg
	add.w	#1,vilken_anim_vapen
	cmp.w	#3,vilken_anim_vapen
	blt.s	.no_new_anim
	move.w	#0,vilken_anim_vapen
	move.w	#1,.anim_flg2

	cmp.w	#1,vilket_vapen		; kolla om ladda-om-sekvens 
	bne.s	.ej_koll_ladd1
	move.w	ammo,d0
	and.w	#%0000000000000111,d0
	cmp.w	#7,d0
	bne.s	.ej_koll_ladd1
	move.w	#1,ladda_om_flg
.ej_koll_ladd1
	cmp.w	#3,vilket_vapen
	bne.s	.no_new_anim
	move.w	#1,ladda_om_flg
.no_new_anim

	add.w	#1,.skjut_flg	; kolla om nytt skott
	move.w	.skjut_flg,d1
	cmp.w	(a2),d1
	bne	.ej_new_anim
	move.w	#0,vilken_anim_vapen
	move.w	#0,.skjut_flg
	move.w	#0,.anim_flg
	move.w	#0,.anim_flg2
	move.w	#0,skj_flg
	move.w	#0,.ljd_flg
.ej_new_anim

	cmp.w	#1,.ljd_flg	; kolla om man skjuter
	bne	.ej_skjut
	move.w	#2,.ljd_flg

	move.w	(a0),ammo
	tst.w	vilket_vapen
	beq	.sub_ej_ammo

	cmp.w	#1,vilket_vapen	; kolla ur vilken slot
	bne.s	.ej_vap1		; vi ska minska ammo
	subq.w	#1,ammo_vapen+2
	subq.w	#1,ammo_vapen+6
.ej_vap1	cmp.w	#2,vilket_vapen
	bne.s	.ej_vap2
	subq.w	#1,ammo_vapen+4
	subq.w	#1,ammo_vapen+8
.ej_vap2	cmp.w	#3,vilket_vapen
	bne.s	.ej_vap3
	subq.w	#2,ammo_vapen+2
	subq.w	#2,ammo_vapen+6
.ej_vap3	cmp.w	#4,vilket_vapen
	bne.s	.ej_vap4
	subq.w	#1,ammo_vapen+4
	subq.w	#1,ammo_vapen+8
.ej_vap4	cmp.w	#5,vilket_vapen
	bne.s	.sub_ej_ammo
	subq.w	#1,ammo_vapen+10
.sub_ej_ammo

	cmp.w	#5,vilket_vapen
	bne.s	.not_flyg
	move.w	#1,.flyg_flg
	bra	.ej_skjut
.not_flyg

	tst.w	midi_on
	bne	.midi_skjut

	tst.l	skjut_adr
	beq	.ej_trf
	tst.w	vilket_vapen
	bne.s	.ej_kniv
	cmp.w	#100,skjut_adr+4
	bgt	.ej_skjut

.ej_kniv	move.l	skjut_adr,a3
	move.w	vapen_skada,56(a3)	; skada fi
	move.w	look_angle,66(a3)	; vinkel fi ska flyga i
	bra	.ej_skjut
	
;-------- Om man k”r midi blir det annorlunda skjutrutin --------

.midi_skjut
	tst.l	skjut_adr
	beq	.ej_trb
	tst.w	vilket_vapen
	bne.s	.ej_kniv2
	cmp.w	#100,skjut_adr+4
	bgt	.ej_skjut

.ej_kniv2	move.l	skjut_adr,a3
	move.w	#1,16(a3)		; skada anim
	move.w	22(a3),d1
	lsl.w	#4,d1
	move.w	#1,d0
	or.b	d1,d0
	jsr	midi_send
	bra.s	.ej_skjut

.ej_trb	move.b	#%01010001,d0	; ingen tr„ff
	jsr	midi_send

.ej_trf	cmp.w	#1,vilket_vapen
	ble	.ej_skjut
	cmp.w	#3,vilket_vapen
	beq	.ej_skjut
	cmp.w	#5,vilket_vapen
	beq	.ej_skjut

	move.w	#0,richo_flg+2
	add.w	#1,richo_flg
	and.w	#%0000000000000111,richo_flg
.ej_skjut

	tst.w	richo_flg
	blt	.no_richo
	tst.w	skjut
	bne	.no_richo
	add.w	#1,richo_flg+2		; first delay
	cmp.w	#4,richo_flg+2
	blt	.no_richo
	add.w	#1,richo_flg+4		; mellan delay
	cmp.w	#2,richo_flg+4
	blt	.no_richo
	move.w	#0,richo_flg+4

	sub.w	#1,richo_flg
	
	tst.w	richo_flg
	ble	.no_richo

	moveq	#0,d2
	move.b	slump,d2
	and.b	#%00000011,d2
	cmp.b	#2,d2
	beq	.no_richo
	cmp.b	#3,d2
	beq	.no_richo

	add.w	#16,d2
		
	lea	sound_board,a2	; starta ljud f”r exp 
	move.w	(a2),d0
	add.w	#1,(a2)+
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,a2
	move.l	x_gubbe,(a2)+	; xz
	move.w	d2,(a2)+		; ljud nr
.no_richo

;-------- Nu vet vi att ett nytt flygande skott avlossats -------

	tst.w	.flyg_flg
	beq	.no_flyg_skott
	move.w	#0,.flyg_flg

	lea	flyg_skott_buf,a0
	lea	sin_360,a1
	lea	adrmap,a2
	
	move.l	aktiva_skott,d0
	moveq	#-1,d1
	
	move.w	#32-1-1,d7		; testa vilket skott vi
.tst_vilk	addq.w	#1,d1			; kan anv„nda
	btst	d1,d0
	beq.s	.hitt_en
	dbf	d7,.tst_vilk		; om alla „r upptagna 
	bra	.no_flyg_skott		; s† blire inget skott

.hitt_en	bset	d1,d0			; nu „r denna upptagen
	move.l	d0,aktiva_skott

	lsl.w	#5,d1			; vilk*32 (16words)
	add.w	d1,a0			; peekar p† skottet	

	tst.w	midi_on			; testa om midi
	beq.s	.no_mi4
	move.b	#%01000001,d0
	jsr	midi_send
.no_mi4

	move.w	x_gubbe,d0
	move.w	z_gubbe,d1
	move.w	look_angle,d2
	
	add.w	d2,d2
	add.w	d2,a1
	move.w	(a1),d3			; sin
	move.w	180(a1),d4		; cos
	
	muls	#SKOTTHAST,d3		; sin(grad)*snabbhet
	muls	#SKOTTHAST,d4		; cos(grad)*snabbhet
	lsr.l	#8,d3
	lsr.l	#8,d4
	lsr.l	#2,d3	
	lsr.l	#2,d4	
	neg.w	d3
	
	lsr.w	#6,d0
	lsr.w	#6,d1
	lsl.w	#5,d1			; z_gubbe*32
	add.w	d1,d0			; z_gubbe*32+x_gubbe
	lsl.w	#4,d0			; offs i adrmap

	tst.l	(a2,d0.w)
	beq.s	.found_c
	addq.w	#4,d0
	tst.l	(a2,d0.w)
	beq.s	.found_c
	addq.w	#4,d0
	tst.l	(a2,d0.w)
	beq.s	.found_c
	addq.w	#4,d0
.found_c	move.l	a0,(a2,d0.w)		; l„gg in skottadr p† sr

	lea	-90*2(a1),a1		; look_angle-90
	cmp.l	#sin_360,a1
	bge.s	.nojjo
	lea	360*2(a1),a1
.nojjo
	move.w	(a1),d1
	move.w	180(a1),d2
	
	muls	#2,d1			; skott bredd
	muls	#2,d2			; skott bredd
	swap	d1
	swap	d2
	rol.l	#2,d1
	rol.l	#2,d2

	lsl.w	#4,d1
	lsl.w	#4,d2
	sub.w	d3,d1
	add.w	d4,d2
	lsr.w	#4,d1
	lsr.w	#4,d2

	move.w	#3,(a0)+			; s„tt indik
	move.w	x_gubbe,(a0)		;      x_start
	sub.w	d1,(a0)+			;      korr f”r skottbredd
	move.w	z_gubbe,(a0)		;      z_start
	add.w	d2,(a0)+			;      korr f”r skottbredd
	move.w	#41,(a0)+			;      spr nr 1
	move.w	#0,(a0)+			;      explosions r„knare
	move.w	#42,(a0)+			;      spr nr 2 (-1=ej anim)
	move.w	d3,(a0)+			;      x_inc*16
	move.w	d4,(a0)+			;      z_inc*16
	move.w	#SKOTTHAST,(a0)+		;      hyp
	move.w	look_angle,(a0)+		;      skott_vinkel
	move.w	vapen_skada,(a0)+		;      skada
	move.w	d0,(a0)+			;      adrmap offs

.no_flyg_skott

;---------- Uppdatera flygande skott --------------

	move.l	aktiva_skott,d0
	moveq	#-1,d1
	move.w	#32-1,d7
.ud_skott
	addq.l	#1,d1			; testa om aktivt skott
	movem.l	d0-d1/d7,-(sp)

	btst	d1,d0
	beq	.fixed_skott

	lea	flyg_skott_buf,a0		; buf med skott
	lea	adrmap,a1			; adrmappen

	lsl.w	#5,d1			; g”r s† vi peekar p†
	add.w	d1,a0			; r„tt skott

	tst.w	8(a0)
	bgt	.just_exp

	move.w	2(a0),d0			; x_pos
	move.w	4(a0),d1			; z_pos
	lsl.w	#4,d0			; x_pos*16
	lsl.w	#4,d1			; z_pos*16
	add.w	12(a0),d0			; x_pos+x_inc
	add.w	14(a0),d1			; z_pos+z_inc
	lsr.w	#4,d0			; /16=>absoluta v„rden
	lsr.w	#4,d1
	move.w	d0,2(a0)
	move.w	d1,4(a0)

	move.w	d0,d2
	move.w	d1,d3
	
	lsr.w	#6,d2
	lsr.w	#6,d3
	lsl.w	#5,d3			; kolla vilken sr vi
	add.w	d2,d3			; hamnar p†...
	lsl.w	#4,d3
	move.w	22(a0),d4
	and.w	#%1111111111110000,d4
	cmp.w	d3,d4			; jmf offs med gamla
	beq	.no_new_rut		; om lika hoppa

;--- Ny sr ---

	move.w	22(a0),d4			; rensa gamla sr
	move.l	#0,(a1,d4.w)

	tst.l	(a1,d3.w)			; testa f”rsta longet
	beq	.c_adr			; om=0 s„tt d† denna sr
	blt	.hit_wall
	move.l	(a1,d3.w),a2
	cmp.w	#2,(a2)			; kolla om v„gg
	blt	.hit_wall			; om s† hoppa till stoppa f”r v„gg
	bgt	.tstlo23

;--- d”rr ---

	tst.w	20(a2)			; om st„ngd s† hoppa till stopp f”r v„gg
	beq	.hit_wall
	
	move.w	20(a2),d4
	cmp.w	#14,d4
	ble.s	.chkdhit
	cmp.w	#OPEN,d4
	blt	.tstlo23
	sub.w	#OPEN,d4
	neg.w	d4
	add.w	#14,d4

.chkdhit	tst.w	18(a2)
	beq.s	.dbasv„n
	
	lea	.ca2k,a4
	add.w	d4,d4
	move.w	(a4,d4.w),d4		; vilket zx har denna d”rr
	move.w	4(a0),d5			; skott z
	and.w	#%0000000000111111,d5	; spara sr-koords
	cmp.w	d4,d5			; jmf dz-skottz
	bgt.s	.tstlo23
	bra.s	.hit_wall	

.dbasv„n	lea	.ca2k,a4
	add.w	d4,d4
	move.w	(a4,d4.w),d4		; vilket zx har denna d”rr
	move.w	2(a0),d5			; skott z
	and.w	#%0000000000111111,d5	; spara sr-koords
	cmp.w	d4,d5			; jmf dz-skottz
	bgt.s	.tstlo23
	bra.s	.hit_wall	

;--- testa lo 2,3,4 ---

.tstlo23
	addq.w	#4,d3
	tst.l	(a1,d3.w)
	beq.s	.c_adr
	addq.w	#4,d3
	tst.l	(a1,d3.w)
	beq.s	.c_adr
	addq.w	#4,d3

.c_adr	move.l	a0,(a1,d3.w)
	move.w	d3,22(a0)

	bra	.no_new_rut

;--- Hit wall ---

.hit_wall
	move.w	2(a0),d0
	move.w	4(a0),d1
	lsl.w	#4,d0
	lsl.w	#4,d1
	sub.w	12(a0),d0
	sub.w	14(a0),d1
	lsr.w	#4,d0
	lsr.w	#4,d1
	move.w	d0,2(a0)
	move.w	d1,4(a0)

	lsr.w	#6,d0
	lsr.w	#6,d1
	lsl.w	#5,d1
	add.w	d0,d1
	lsl.w	#4,d1

	lea	adrmap,a4
	tst.l	(a4,d1.w)
	beq.s	.puta
	addq.w	#4,d1
	tst.l	(a4,d1.w)
	beq.s	.puta
	addq.w	#4,d1
	tst.l	(a4,d1.w)
	beq.s	.puta
	addq.w	#4,d1

.puta	move.l	a0,(a4,d1.w)
	move.w	d1,22(a0)

.just_exp	add.w	#1,8(a0)			; s„tt r„knaren f”r exp

	cmp.w	#1,8(a0)
	bne.s	.exp2
	move.w	#43,6(a0)
	bra	.fixed_skott

.exp2	cmp.w	#5,8(a0)
	bne.s	.exp3
	move.w	#44,6(a0)
	bra	.fixed_skott

.exp3	cmp.w	#10,8(a0)
	bne.s	.expc
	move.w	#45,6(a0)
	bra	.fixed_skott
	
.expc	cmp.w	#15,8(a0)
	bne	.fixed_skott
	
	lea	adrmap,a4
	add.w	22(a0),a4
	move.l	#0,(a4)
	movem.l	(sp)+,d0-d1/d7
	bclr	d1,d0
	move.l	d0,aktiva_skott
	movem.l	d0-d1/d7,-(sp)
	bra	.fixed_skott

;--- Kolla om man tr„ffar player ---

.no_new_rut

	move.w	2(a0),d0		; kolla om man tr„ffar
	move.w	4(a0),d1		; gubben...
	sub.w	x_gubbe,d0
	bge.s	.non1
	neg.w	d0
.non1	sub.w	z_gubbe,d1
	bge.s	.non2
	neg.w	d1
.non2		
	cmp.w	16(a0),d0
	bgt.s	.ej_play_hit
	cmp.w	16(a0),d1
	bgt.s	.ej_play_hit	

	mulu	d0,d0
	mulu	d1,d1
	move.l	d0,d3
	add.l	d1,d3
		
	jsr	roten_ur		; sqr(x^2+z^2)
	
	cmp.w	#TJOCK+TJOCK*3/2,d3	; „r skottet inom gubbens tjocklek?
	bgt.s	.ej_play_hit

	move.w	20(a0),d3
	sub.w	d3,health		; skada gubben
	bra	.just_exp		; starta exp och rensa adr

;--- Kolla nu fi ---

.ej_play_hit
	lea	adrmap,a4
	lea	.reladd,a5
	add.w	22(a0),a4		; till r„tt offs

	move.w	(a5)+,d7
.chkrunt	add.w	(a5)+,a4
	
	tst.l	(a4)
	ble.s	.knlo1
	move.l	(a4),a6
	cmp.w	#4,(a6)
	bne.s	.knlo1
	bra.s	.hit_fi
	
.knlo1	tst.l	4(a4)
	ble.s	.knlo2
	move.l	4(a4),a6
	cmp.w	#4,(a6)
	bne.s	.knlo2
	bra.s	.hit_fi

.knlo2	tst.l	8(a4)
	ble.s	.knlo3
	move.l	8(a4),a6
	cmp.w	#4,(a6)
	bne.s	.knlo3
	bra.s	.hit_fi

.knlo3	tst.l	12(a4)
	ble.s	.knlo4
	move.l	12(a4),a6
	cmp.w	#4,(a6)
	bne.s	.knlo4
	bra.s	.hit_fi

.knlo4	bra.s	.didnt_hit_fi

;--- Skada fi kanske ---

.hit_fi	move.w	2(a6),d0
	move.w	4(a6),d1
	lsr.w	#4,d0
	lsr.w	#4,d1
	sub.w	2(a0),d0
	bge.s	.non3
	neg.w	d0
.non3	sub.w	4(a0),d1
	bge.s	.non4
	neg.w	d1
.non4
	cmp.w	16(a0),d0
	bgt.s	.didnt_hit_fi	
	cmp.w	16(a0),d1
	bgt.s	.didnt_hit_fi
	
	mulu	d0,d0
	mulu	d1,d1
	move.l	d0,d3
	add.l	d1,d3
	
	jsr	roten_ur
	
	cmp.w	#TJOCK*2/3,d3
	bgt.s	.didnt_hit_fi

	move.w	20(a0),56(a6)	; skada fi
	move.w	18(a0),66(a6)	; vinkel fi ska flyga i
	bra	.just_exp
.didnt_hit_fi
	dbf	d7,.chkrunt
		
.fixed_skott
	movem.l	(sp)+,d0-d1/d7
	dbf	d7,.ud_skott

;---- Har man „ndrat vapen s† ska lite flaggor rensas ------------

	tst.w	„ndrat_vapen
	beq.s	.ej_„ndrat
	move.w	#0,„ndrat_vapen
	move.w	#0,vilken_anim_vapen	; animerings flagga
	move.w	#0,.skjut_flg		; skjut flaggan
	move.w	#0,.anim_flg		; anim c 1
	move.w	#0,.anim_flg2		; anim c 2
	move.w	#0,skj_flg		; skut flaggan
	move.w	#0,.ljd_flg		; ljud flaggan

	lea	skad_vapen,a0
	move.w	vilket_vapen,d0
	add.w	d0,d0
	move.w	(a0,d0.w),vapen_skada

	tst.w	midi_on
	beq.s	.ej_„ndrat
	moveq	#2,d0
	move.w	vilket_vapen,d1
	lsl.w	#4,d1
	or.b	d1,d0
	jsr	midi_send
.ej_„ndrat

;---- Konvertera look_angle (360deg) till look_angle2 (255deg) ----

	move.w	look_angle,d0
	mulu	#90,d0		; angle*320
	lsr.w	#7,d0		; /128 ger ett fint tal
	move.w	d0,look_angle2	

;---- S„tt gubbens xzv i midi listan ----

	tst.w	midi_on
	beq.s	.no_mi5

	lea	spelar_lista,a0
	move.w	com_id,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a0

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	x_gubbe,d0
	move.w	z_gubbe,d1
	move.w	look_angle,d2

	swap	d0
	lsl.l	#4,d0
	
	lsl.l	#8,d1
	lsl.l	#1,d1
	
	or.l	d1,d0
	or.l	d2,d0
	move.l	d0,(a0)

.no_mi5	rts
	
;---- R„kna ut n„sta koordinat och kolla axlar o dylikt -------

.count_and_chk
	lea	sin_360,a0
	add.w	d0,d0
	add.w	d0,a0
	move.w	(a0),d3			; sin
	move.w	180(a0),d4		; cos

	tst.w	spring
	beq.s	.no_spring
	add.w	d2,d1
.no_spring
	muls	d1,d3
	muls	d1,d4
	swap	d3
	swap	d4
	rol.l	#2,d3			; add
	rol.l	#2,d4			; add

	neg.w	d3
	add.w	x_gubbe,d3		; nya x punkten
	add.w	z_gubbe,d4		; nya z punkten
	move.w	d3,.ny_gx
	move.w	d4,.ny_gz
	
	move.l	#0,.ett			; rensa ett tv† tre fyr
	move.l	#0,.tre

	lea	adrmap,a0			; nuvarande adresser
	move.w	.ny_gx,d3
	move.w	.ny_gz,d4
	add.w	#TJOCK,d3
	add.w	#TJOCK,d4
	lsr.w	#6,d3
	lsr.w	#6,d4
	lsl.w	#5,d4
	add.w	d3,d4
	lsl.w	#4,d4

	tst.l	4(a0,d4.w)
	beq.s	.ntst1
	move.l	4(a0,d4.w),a1
	cmp.w	#4,(a1)
	beq.s	.k1
.ntst1	tst.l	8(a0,d4.w)
	beq.s	.ntst2
	move.l	8(a0,d4.w),a1
	cmp.w	#4,(a1)
	beq.s	.k1
.ntst2	tst.l	12(a0,d4.w)
	beq.s	.ntst3
	move.l	12(a0,d4.w),a1
	cmp.w	#4,(a1)
	beq.s	.k1
.ntst3
	tst.l	(a0,d4.w)
	beq.s	.ej_k1
	move.l	(a0,d4.w),a1
	cmp.l	#-1,a1
	beq.s	.k1
	cmp.w	#1,(a1)			; v„gg+specv„gg
	ble.s	.k1
	cmp.w	#2,(a1)			; d”rr
	beq.s	.d_k1
	cmp.w	#3,(a1)			; stat sprite
	beq.s	.s_k1
	cmp.w	#4,(a1)			; fiende
	beq.s	.k1
	bra.s	.ej_k1
.d_k1	cmp.w	#15,20(a1)		; kolla om d”rren „r
	blt.s	.k1			; ”ppen eller ej...
	cmp.w	#OPEN,20(a1)
	bgt.s	.k1
	bra.s	.ej_k1
.s_k1	lea	sprite_config,a2
	move.w	6(a1),d4			; spr nr
	lsl.w	#3,d4
	tst.b	6(a2,d4.w)
	bne.s	.k1
	bra.s	.ej_k1
.k1	move.w	#1,.ett
.ej_k1

	move.w	.ny_gx,d3
	move.w	.ny_gz,d4
	sub.w	#TJOCK,d3
	add.w	#TJOCK,d4
	lsr.w	#6,d3
	lsr.w	#6,d4
	lsl.w	#5,d4
	add.w	d3,d4
	lsl.w	#4,d4

	tst.l	4(a0,d4.w)
	beq.s	.ntst1b
	move.l	4(a0,d4.w),a1
	cmp.w	#4,(a1)
	beq.s	.k2
.ntst1b	tst.l	8(a0,d4.w)
	beq.s	.ntst2b
	move.l	8(a0,d4.w),a1	
	cmp.w	#4,(a1)
	beq.s	.k2
.ntst2b	tst.l	12(a0,d4.w)	
	beq.s	.ntst3b
	move.l	12(a0,d4.w),a1	
	cmp.w	#4,(a1)
	beq.s	.k2
.ntst3b
	tst.l	(a0,d4.w)
	beq.s	.ej_k2
	move.l	(a0,d4.w),a1		; ID-nr
	cmp.l	#-1,a1
	ble.s	.k2
	cmp.w	#1,(a1)			; v„gg+specv„gg
	ble.s	.k2
	cmp.w	#2,(a1)			; d”rr
	beq.s	.d_k2
	cmp.w	#3,(a1)			; stat sprite
	beq.s	.s_k2
	cmp.w	#4,(a1)			; fiende
	beq.s	.k2
	bra.s	.ej_k2
.d_k2	cmp.w	#15,20(a1)		; kolla om d”rren „r
	blt.s	.k2			; ”ppen eller ej...
	cmp.w	#OPEN,20(a1)
	bgt.s	.k2
	bra.s	.ej_k2
.s_k2	lea	sprite_config,a2
	move.w	6(a1),d4			; spr nr
	lsl.w	#3,d4
	tst.b	6(a2,d4.w)
	bne.s	.k2
	bra.s	.ej_k2
.k2	move.w	#2,.tva
.ej_k2

	move.w	.ny_gx,d3
	move.w	.ny_gz,d4
	sub.w	#TJOCK,d3
	sub.w	#TJOCK,d4
	lsr.w	#6,d3
	lsr.w	#6,d4
	lsl.w	#5,d4
	add.w	d3,d4
	lsl.w	#4,d4

	tst.l	4(a0,d4.w)
	beq.s	.ntst1c
	move.l	4(a0,d4.w),a1
	cmp.w	#4,(a1)
	beq.s	.k3
.ntst1c	tst.l	8(a0,d4.w)
	beq.s	.ntst2c
	move.l	8(a0,d4.w),a1	
	cmp.w	#4,(a1)
	beq.s	.k3
.ntst2c	tst.l	12(a0,d4.w)	
	beq.s	.ntst3c
	move.l	12(a0,d4.w),a1	
	cmp.w	#4,(a1)
	beq.s	.k3
.ntst3c
	tst.l	(a0,d4.w)
	beq.s	.ej_k3
	move.l	(a0,d4.w),a1		; ID-nr
	cmp.l	#-1,a1
	ble.s	.k3
	cmp.w	#1,(a1)			; v„gg+specv„gg
	ble.s	.k3
	cmp.w	#2,(a1)			; d”rr
	beq.s	.d_k3
	cmp.w	#3,(a1)			; stat sprite
	beq.s	.s_k3
	cmp.w	#4,(a1)			; fiende
	beq.s	.k3
	bra.s	.ej_k3
.d_k3	cmp.w	#15,20(a1)		; kolla om d”rren „r
	blt.s	.k3			; ”ppen eller ej...
	cmp.w	#OPEN,20(a1)
	bgt.s	.k3
	bra.s	.ej_k3
.s_k3	lea	sprite_config,a2
	move.w	6(a1),d4			; spr nr
	lsl.w	#3,d4
	tst.b	6(a2,d4.w)
	bne.s	.k3
	bra.s	.ej_k3
.k3	move.w	#4,.tre
.ej_k3

	move.w	.ny_gx,d3
	move.w	.ny_gz,d4
	add.w	#TJOCK,d3
	sub.w	#TJOCK,d4
	lsr.w	#6,d3
	lsr.w	#6,d4
	lsl.w	#5,d4
	add.w	d3,d4
	lsl.w	#4,d4

	tst.l	4(a0,d4.w)
	beq.s	.ntst1d
	move.l	4(a0,d4.w),a1
	cmp.w	#4,(a1)
	beq.s	.k4
.ntst1d	tst.l	8(a0,d4.w)
	beq.s	.ntst2d
	move.l	8(a0,d4.w),a1	
	cmp.w	#4,(a1)
	beq.s	.k4
.ntst2d	tst.l	12(a0,d4.w)	
	beq.s	.ntst3d
	move.l	12(a0,d4.w),a1	
	cmp.w	#4,(a1)
	beq.s	.k4
.ntst3d
	tst.l	(a0,d4.w)
	beq.s	.ej_k4
	move.l	(a0,d4.w),a1		; ID-nr
	cmp.l	#-1,a1
	ble.s	.k4
	cmp.w	#1,(a1)			; v„gg+specv„gg
	ble.s	.k4
	cmp.w	#2,(a1)			; d”rr
	beq.s	.d_k4
	cmp.w	#3,(a1)			; stat sprite
	beq.s	.s_k4
	cmp.w	#4,(a1)			; fiende
	beq.s	.k4
	bra.s	.ej_k4
.d_k4	cmp.w	#15,20(a1)		; kolla om d”rren „r
	blt.s	.k4			; ”ppen eller ej...
	cmp.w	#OPEN,20(a1)
	bgt.s	.k4
	bra.s	.ej_k4
.s_k4	lea	sprite_config,a2
	move.w	6(a1),d4			; spr nr
	lsl.w	#3,d4
	tst.b	6(a2,d4.w)
	bne.s	.k4
	bra.s	.ej_k4
.k4	move.w	#8,.fyr
.ej_k4

	move.w	.ett,d3
	add.w	.tva,d3
	add.w	.tre,d3
	add.w	.fyr,d3
	beq	.no_use

	lea	.adr_list,a0
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a0,d3.w),a0
	jmp	(a0)

.r_a	move.w	.ny_gx,d0
	move.w	.ny_gz,d1
	and.w	#%1111111111000000,d0
	and.w	#%1111111111000000,d1
	add.w	#64-TJOCK,d0
	add.w	#64-TJOCK,d1
	move.w	d0,.ny_gx
	move.w	d1,.ny_gz
	bra	.no_use

.r_b	move.w	.ny_gx,d0
	move.w	.ny_gz,d1
	and.w	#%1111111111000000,d0
	and.w	#%1111111111000000,d1
	add.w	#TJOCK,d0
	add.w	#TJOCK,d1
	move.w	d0,.ny_gx
	move.w	d1,.ny_gz
	bra	.no_use
	
.r_c	move.w	.ny_gx,d0
	move.w	.ny_gz,d1
	and.w	#%1111111111000000,d0
	and.w	#%1111111111000000,d1
	add.w	#TJOCK,d0
	add.w	#64-TJOCK,d1
	move.w	d0,.ny_gx
	move.w	d1,.ny_gz
	bra	.no_use
	
.r_d	move.w	.ny_gx,d0
	move.w	.ny_gz,d1
	and.w	#%1111111111000000,d0
	and.w	#%1111111111000000,d1
	add.w	#64-TJOCK,d0
	add.w	#TJOCK,d1
	move.w	d0,.ny_gx
	move.w	d1,.ny_gz
	bra	.no_use

;------- H”rnrutiner

.r_e	move.w	.ny_gx,d0
	move.w	.ny_gz,d1
	sub.w	#TJOCK,d0
	sub.w	#TJOCK,d1
	and.w	#%0000000000111111,d0
	and.w	#%0000000000111111,d1
	cmp.w	d1,d0
	bge	.r_k
	bra	.r_i

;---
.r_f	move.w	.ny_gx,d0
	move.w	.ny_gz,d1
	add.w	#TJOCK,d0
	add.w	#TJOCK,d1
	and.w	#%0000000000111111,d0
	and.w	#%0000000000111111,d1
	cmp.w	d1,d0
	bge	.r_j
	bra	.r_l

;---
.r_g	move.w	.ny_gx,d0
	move.w	.ny_gz,d1
	add.w	#TJOCK,d0
	sub.w	#TJOCK,d1
	and.w	#%0000000000111111,d0
	and.w	#%0000000000111111,d1
	neg.w	d0
	add.w	#64,d0

	cmp.w	d1,d0
	bge	.r_l
	bra	.r_i

;---
.r_h	move.w	.ny_gx,d0
	move.w	.ny_gz,d1
	sub.w	#TJOCK,d0
	add.w	#TJOCK,d1
	and.w	#%0000000000111111,d0
	and.w	#%0000000000111111,d1
	neg.w	d0
	add.w	#64,d0

	cmp.w	d1,d0
	bge	.r_j
	bra	.r_k

;-------- Rakv„gg-rutiner

.r_i	move.w	.ny_gz,d0
	and.w	#%1111111111000000,d0
	add.w	#TJOCK,d0
	move.w	d0,.ny_gz
	bra	.no_use

.r_j	move.w	.ny_gz,d0
	and.w	#%1111111111000000,d0
	add.w	#64-TJOCK,d0
	move.w	d0,.ny_gz
	bra	.no_use
	
.r_k	move.w	.ny_gx,d0
	and.w	#%1111111111000000,d0
	add.w	#TJOCK,d0
	move.w	d0,.ny_gx
	bra	.no_use

.r_l	move.w	.ny_gx,d0
	and.w	#%1111111111000000,d0
	add.w	#64-TJOCK,d0
	move.w	d0,.ny_gx
	bra	.no_use

.special1	move.w	.ny_gx,d0
	cmp.w	x_gubbe,d0
	bgt	.r_c
	bra	.r_d

.special2	move.w	.ny_gx,d0
	cmp.w	x_gubbe,d0
	bgt	.r_a
	bra	.r_b
	
.no_use	move.w	.ny_gx,x_gubbe
	move.w	.ny_gz,z_gubbe
.shit	rts

.adr_list		dc.l	.no_use,.r_f,.r_h,.r_j,.r_e,.special1,.r_k,.r_c,.r_g,.r_l
		dc.l	.special2,.r_a,.r_i,.r_d,.r_b,.no_use,.no_use,.no_use
.adr_fi		ds.l	20
		dc.w	0,0,0,0,0
.ca2k		dc.w	64,60,56,52,48,44,40,36,32,28,24,20,16,12,8,8,8,8,8,8,8,8
.reladd		dc.w	9-1,-33*16,1*16,1*16,30*16,1*16,1*16,30*16,1*16,1*16,0,0,0
.flyg_flg		ds.w	1
.ny_gx		ds.w	1
.ny_gz		ds.w	1
.ett		ds.w	1
.tva		ds.w	1
.tre		ds.w	1
.fyr		ds.w	1
.acc_ret_framv	ds.w	1
.acc_ret_bakv	ds.w	1
.acc_ret_h”ger	ds.w	1
.acc_ret_v„nst	ds.w	1
.skjut_flg	ds.w	1
.anim_flg		ds.w	1
.anim_flg2	ds.w	1
.ljd_flg		ds.w	1

* +-----------------------------------------------------------------------+	
* | Handle plock. Tar hand om d”rrar och om man plockar upp n†got         |
* +-----------------------------------------------------------------------+	
* ui
handle_plock

; +-------------------------------------+	
; | Kolla om man tryckt space 
; +-------------------------------------+	
; jk
	tst.w	space
	beq	.ej_space

	lea	adrmap,a0
	move.w	x_gubbe,d0
	move.w	z_gubbe,d1
	lsr.w	#6,d0
	lsr.w	#6,d1
	lsl.w	#5,d1
	add.w	d0,d1
	lsl.w	#4,d1
	add.w	d1,a0

	lea	-32*4*4(a0),a0
	move.l	(a0),a1
	cmp.w	#2,(a1)
	beq.s	.door
	lea	31*4*4(a0),a0
	move.l	(a0),a1
	cmp.w	#2,(a1)
	beq.s	.door
	lea	2*4*4(a0),a0
	move.l	(a0),a1
	cmp.w	#2,(a1)
	beq.s	.door
	lea	31*4*4(a0),a0
	move.l	(a0),a1
	cmp.w	#2,(a1)
	bne	.chk_hemlig

.door	tst.l	4(a0)		; ligger det n†tt p† de andra
	bne	.ej_door		; longsen s† l„gg inte in adr
	tst.l	8(a0)		; eftersom den d† redan „r
	bne	.ej_door		; ”ppen...
	tst.l	12(a0)
	bne	.ej_door

	lea	har_nyckel,a0	; kolla nyckel
	move.w	22(a1),d0
	cmp.w	#-1,d0
	blt	.ej_door
	beq	.do_door

	tst.w	(a0,d0.w)
	bne.s	.do_door

	move.w	#13,d0		; skicka meddelande om att man
	jsr	do_mess		; beh”ver nyckel

	lea	sound_board,a2	; starta ljud f”r nyckel beh”vande
	move.w	(a2),d0
	add.w	#1,(a2)+
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,a2
	move.l	x_gubbe,(a2)+	; xz
	move.w	#8,(a2)+		; ljud nr
	bra	.ej_door

.do_door	tst.w	midi_on		; kolla om midi
	beq.s	.no_mi1
	moveq	#4,d0
	jsr	midi_send
.no_mi1
	move.l	a1,last_door
	lea	akt_d_adr,a0
	move.w	#ANT_DOOR-1-1,d7	; max antal d”rrar samtidigt=ANT_DOOR (-1 f”r att om alla „r upptagna s† skrivs sista ”ver)
.chkadr1	cmp.l	(a0),a1
	beq	.ej_door
	cmp.l	#0,(a0)
	beq.s	.put_adr
	addq.l	#4,a0
	dbf	d7,.chkadr1
	
	move.l	a1,(a0)
	bra	.ej_door
	
.put_adr	move.l	a1,(a0)+
	subq.w	#1,d7
	blt.s	.ej_door

.chkadr2	cmp.l	(a0),a1
	bne.s	.nollej
	move.l	#0,(a0)
.nollej	addq.l	#4,a0
	dbf	d7,.chkadr2
	bra.s	.ej_door

;- Kolla om det finns n†gra hemliga d”rrar i n„rheten -

.chk_hemlig
	tst.w	go_hemlig		; om en redan ”ppnas
	bne	.ej_door		; s† skit i det

	move.l	bytemap_3,a0	; event bytemapen
	lsr.w	#4,d1		; gubboffset/16 (f”r bytemap)

	sub.w	#32,d1		; kolla om man st†r vid en 
	cmp.b	#5,(a0,d1.w)	; hemlig d”rr
	beq	.h_door
	add.w	#32-1,d1
	cmp.b	#5,(a0,d1.w)
	beq	.h_door
	add.w	#2,d1
	cmp.b	#5,(a0,d1.w)
	beq	.h_door
	add.w	#32-1,d1
	cmp.b	#5,(a0,d1.w)
	bne	.ej_door

.h_door	lsl.w	#4,d1
	move.w	#1,go_hemlig	; det „r en hemlig d”rr
	move.w	d1,go_hemlig+2	; offset i adrmap till sr
	lsr.w	#4,d1
	jsr	put_hidd

.ej_door	lea	adrmap,a0
	
	move.w	x_gubbe,d0
	move.w	z_gubbe,d1
	lsr.w	#6,d0
	lsr.w	#6,d1
	lsl.w	#5,d1
	add.w	d0,d1
	lsl.w	#4,d1

	move.l	(a0,d1.w),a0
	cmp.l	#0,a0
	beq	.ej_space
	cmp.w	#3,(a0)
	bne	.ej_space
	cmp.w	#23,6(a0)
	bne	.ej_space

	move.w	#30,6(a0)
	move.w	#1,exit_flg
.ej_space

; +-------------------------------------+	
; | Fixa allt med alla d”rrar 
; +-------------------------------------+	
; jk
	lea	akt_d_adr,a0
	move.w	#ANT_DOOR-1,d7
.d_lp	move.l	(a0)+,a1		; d”rrens adr

	cmp.l	#0,a1
	beq	.d_fixed

	move.l	a1,a3
	jsr	buf_door
	add.w	#1,20(a1)		; ”ka animations r„knarn

	cmp.w	#15,20(a1)	; kolla om d”rren ”ppnas
	bgt	.its_open

	cmp.w	#1,20(a1)		; addera en ljudeffekt
	bne.s	.already_added1
	sub.w	#1,28(a1)		; sprite nr
	sub.w	#1,34(a1)		; sprite nr
	sub.w	#1,36(a1)		; sprite nr

	lea	sound_board,a2
	move.w	(a2),d0
	add.w	#1,(a2)+
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,a2
	move.w	2(a1),d0			; nedre w=x1
	move.w	4(a1),d1			;       w=z1
	and.w	#%1111111111000000,d0
	and.w	#%1111111111000000,d1
	add.w	#32,d0
	add.w	#32,d1
	move.w	d0,(a2)+			; x
	move.w	d1,(a2)+			; z
	move.w	#9,(a2)+			; ljud nr
.already_added1

	tst.w	18(a1)		; kolla vilken riktning p† d”rren
	beq.s	.op_v„nst
	sub.w	#4,8(a1)
	sub.w	#4,12(a1)
	sub.w	#4,26(a1)
	sub.w	#4,32(a1)

	move.w	26(a1),d0		; om spriten f”rsvunnit ut
	cmp.w	4(a1),d0		; s† -1:a spriten (ta bort den)
	bgt	.d_fixed
	move.w	#-1,28(a1)
	move.w	#-1,34(a1)
	bra	.d_fixed
.op_v„nst	sub.w	#4,6(a1)
	sub.w	#4,10(a1)
	sub.w	#4,24(a1)
	sub.w	#4,30(a1)
	move.w	24(a1),d0		; om spriten f”rsvunnit ut
	cmp.w	2(a1),d0		; s† -1:a spriten (ta bort den)
	bgt	.d_fixed
	move.w	#-1,28(a1)
	move.w	#-1,34(a1)
	bra	.d_fixed

.its_open	cmp.w	#OPEN,20(a1)
	bgt	.chk_play_fi

;-------- Chk sprite -------

	lea	adrmap,a2		; till d”rrens sr
	move.w	2(a1),d0
	move.w	4(a1),d1
	lsr.w	#6,d0
	lsr.w	#6,d1
	lsl.w	#5,d1
	add.w	d0,d1
	lsl.w	#4,d1
	add.w	d1,a2

	tst.l	4(a2)
	beq.s	.tst1a
	move.l	4(a2),a3
	cmp.l	#flyg_skott_buf,a3
	bge.s	.tst1a
	cmp.w	#3,(a3)
	beq	.alw_op
.tst1a	tst.l	8(a2)
	beq.s	.tst2a
	move.l	8(a2),a3
	cmp.l	#flyg_skott_buf,a3
	bge.s	.tst2a
	cmp.w	#3,(a3)
	beq	.alw_op
.tst2a	tst.l	12(a2)
	beq.s	.tst3a
	move.l	12(a2),a3
	cmp.l	#flyg_skott_buf,a3
	bge.s	.tst3a
	cmp.w	#3,(a3)
	beq	.alw_op
.tst3a	bra	.d_fixed

;-------- Kolla fi och player --------

.chk_play_fi
	cmp.w	#OPEN+15,20(a1)
	bgt	.its_closed

	lea	adrmap,a2		; till d”rrens sr
	move.w	2(a1),d0
	move.w	4(a1),d1
	lsr.w	#6,d0
	lsr.w	#6,d1
	lsl.w	#5,d1
	add.w	d0,d1
	lsl.w	#4,d1
	add.w	d1,a2	

	tst.l	4(a2)
	beq.s	.tst1
	move.l	4(a2),a3
	cmp.w	#4,(a3)
	beq	.rut_fyll
	cmp.l	#spelar_buffer,a3
	bge	.rut_fyll
	cmp.l	#flyg_skott_buf,a3
	bge.s	.tst1
	cmp.w	#3,(a3)
	beq	.alw_op
.tst1	tst.l	8(a2)
	beq.s	.tst2
	move.l	8(a2),a3
	cmp.w	#4,(a3)
	beq	.rut_fyll
	cmp.l	#spelar_buffer,a3
	bge	.rut_fyll
	cmp.l	#flyg_skott_buf,a3
	bge.s	.tst2
	cmp.w	#3,(a3)
	beq	.alw_op	
.tst2	tst.l	12(a2)
	beq.s	.tst3
	move.l	12(a2),a3
	cmp.w	#4,(a3)
	beq	.rut_fyll
	cmp.l	#spelar_buffer,a3
	bge	.rut_fyll
	cmp.l	#flyg_skott_buf,a3
	bge.s	.tst3
	cmp.w	#3,(a3)
	beq	.alw_op	
.tst3
	move.w	x_gubbe,d0
	move.w	z_gubbe,d1
	move.w	2(a1),d2
	move.w	4(a1),d3
	lsr.w	#6,d0
	lsr.w	#6,d1
	lsr.w	#6,d2
	lsr.w	#6,d3
	
	cmp.w	d0,d2
	beq.s	.test_nex
	bra.s	.not_same_sr
.test_nex	cmp.w	d1,d3
	bne.s	.not_same_sr
	
.rut_fyll	move.w	#OPEN,20(a1)
	bra	.d_fixed

.not_same_sr
	cmp.w	#OPEN+1,20(a1)		; addera en ljudeffekt
	bne.s	.already_added2
	lea	sound_board,a2
	move.w	(a2),d0
	add.w	#1,(a2)+
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,a2
	move.w	2(a1),d0			; nedre w=x1
	move.w	4(a1),d1			;       w=z1
	and.w	#%1111111111000000,d0
	and.w	#%1111111111000000,d1
	add.w	#32,d0
	add.w	#32,d1
	move.w	d0,(a2)+			; x
	move.w	d1,(a2)+			; z
	move.w	#9,(a2)+			; ljud nr
.already_added2

	tst.w	18(a1)
	beq.s	.cl_v„nst
	add.w	#4,8(a1)
	add.w	#4,12(a1)
	add.w	#4,26(a1)
	add.w	#4,32(a1)

	move.w	26(a1),d0		; om spriten kommit fram
	cmp.w	4(a1),d0		; s† l„gg tillbaka den
	blt	.d_fixed
	move.w	36(a1),28(a1)
	move.w	36(a1),34(a1)
	bra.s	.d_fixed
.cl_v„nst	add.w	#4,6(a1)
	add.w	#4,10(a1)
	add.w	#4,24(a1)
	add.w	#4,30(a1)

	move.w	24(a1),d0		; om spriten kommit fram
	cmp.w	2(a1),d0		; s† l„gg tillbaka den
	blt	.d_fixed
	move.w	36(a1),28(a1)
	move.w	36(a1),34(a1)
	bra.s	.d_fixed

.its_closed
	add.w	#1,28(a1)		; sprite nr
	add.w	#1,34(a1)		; sprite nr
	add.w	#1,36(a1)
	move.w	#0,20(a1)		; nollst„ll r„knarn
	move.l	#0,-4(a0)
	bra	.d_fixed
.alw_op	move.l	#0,-4(a0)		; rensa i listan
	move.w	#OPEN,20(a1)
.d_fixed	dbf	d7,.d_lp

.no_doors_to_fix

; +-------------------------------------+	
; | fixa allt med hemliga d”rrar 
; +-------------------------------------+	
; jk
	tst.w	go_hemlig
	beq	.no_hemlig_door

	lea	adrmap,a0
	move.l	bytemap_0,a1
	move.l	bytemap_3,a3
	
	move.w	go_hemlig+2,d0		; till r„tt sr
	move.l	(a0,d0.w),a2		; fyrkantens adr
	
	cmp.w	#1,go_hemlig
	bne.s	.not_first
	lsr.w	#4,d0
	move.b	#0,(a1,d0.w)		; rensa i bytemap 0
	move.b	#0,(a3,d0.w)		; rensa i bytemap 3
	move.w	08(a2),go_hemlig+4		; s„tt f”rra x
	move.w	#2,go_hemlig
.not_first
	add.w	#4,04(a2)			; dra bort koords
	add.w	#4,08(a2)
	add.w	#4,12(a2)			
	add.w	#4,16(a2)			
	add.w	#4,20(a2)			

	move.l	a2,a3
	jsr	buf_hdoor			; s„g till att den „ndras

	lea	sound_board,a3		; s„tt lite ljud
	move.w	(a3),d0			; p† tillvaron
	add.w	#1,(a3)+
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,a3
	move.w	04(a2),d0			; x
	move.w	08(a2),d1			; z
	add.w	#32,d0			; till mitten av kuben
	add.w	#32,d1
	move.w	d0,(a3)+			; spara x
	move.w	d1,(a3)+			; spara z
	move.w	#14,(a3)+			; spara ljud nr

	move.w	08(a2),d0			; xz koord 2
	move.w	10(a2),d1
	lsr.w	#6,d0
	lsr.w	#6,d1
	lsl.w	#5,d1
	add.w	d0,d1
	lsl.w	#4,d1
	
	tst.l	(a0,d1.w)
	beq	.chk_if_rens

	move.w	04(a2),d0
	move.w	06(a2),d1
	lsr.w	#6,d0
	lsr.w	#6,d1
	lsl.w	#5,d1
	add.w	d0,d1
	move.b	#9,(a1,d1.w)		; s„tt bytemap=9

	move.w	go_hemlig+2,d0
	move.l	(a0,d0.w),d1		; adr till hemlig d”rr
	move.l	#0,00(a0,d0.w)		; rensa adr i gamla sr
	move.l	d1,16(a0,d0.w)		; s„tt den adr i n„sta sr

	move.l	#0,go_hemlig		; rensa flg+offs
	move.w	#0,go_hemlig+4		; rensa oldx
	bra	.no_hemlig_door
	
.chk_if_rens	
	move.w	08(a2),d0			; v„nster x
	sub.w	go_hemlig+4,d0		; dra bort gamla x
	cmp.w	#64,d0
	bne	.no_hemlig_door	

	move.w	go_hemlig+2,d0
	move.l	(a0,d0.w),d1		; adr till hemlig d”rr
	move.l	#0,00(a0,d0.w)		; rensa adr i gamla sr
	move.l	d1,16(a0,d0.w)		; s„tt den adr i n„sta sr

	add.w	#16,go_hemlig+2		; s„tt offs till r„tt sr
	move.w	08(a2),go_hemlig+4		; s„tt ny startx	

.no_hemlig_door

; +-------------------------------------+	
; | Kolla om man lagt en bomb
; +-------------------------------------+	
; jk
	cmp.w	#1,bomb_lagd
	bne	.no_bomb_lagd

	move.w	#2,bomb_lagd	; rensa h„r s† att han inte l„gger
				; ut en bomb f”r tidigare tryck
	tst.w	bombs
	ble	.no_bomb_lagd

	move.l	bytemap_0,a0
	move.l	bytemap_2,a1
	
	move.w	x_gubbe,d0
	move.w	z_gubbe,d1
	lsr.w	#6,d0
	lsr.w	#6,d1
	lsl.w	#5,d1
	add.w	d0,d1
	
	cmp.b	#26,(a0,d1.w)	; man ska inte kunna l„gga 
	beq	.no_bomb_lagd	; en bomb i en hissd”rr
	cmp.b	#27,(a0,d1.w)
	beq	.no_bomb_lagd
	cmp.b	#96,(a1,d1.w)	; och inte i hissen heller
	blt	.golla
	cmp.b	#100,(a1,d1.w)
	ble	.no_bomb_lagd
.golla
	lea	bombs+2,a0
	lea	adrmap,a1

	move.l	(a0)+,a2
	cmp.w	#-1,8(a2)
	blt.s	.gobaby
	move.l	(a0)+,a2
	cmp.w	#-1,8(a2)
	blt.s	.gobaby
	move.l	(a0)+,a2
	cmp.w	#-1,8(a2)
	bge	.no_bomb_lagd

.gobaby	move.l	a2,a0

	subq.w	#1,bombs

	tst.w	midi_on		; kolla om midi
	beq.s	.no_mi2
	moveq	#3,d0
	move.w	bombs,d1
	lsl.w	#4,d1
	or.b	d1,d0
	jsr	midi_send
.no_mi2

	move.w	x_gubbe,d0
	move.w	z_gubbe,d1
	lsr.w	#6,d0
	lsr.w	#6,d1
	lsl.w	#5,d1
	add.w	d0,d1
	lsl.w	#4,d1
	add.w	d1,a1

	tst.l	(a1)+
	beq.s	.put_bmb
	tst.l	(a1)+
	beq.s	.put_bmb
	tst.l	(a1)+
	beq.s	.put_bmb
	addq.l	#4,a1		; m†la ”ver sista vad det „n „r

.put_bmb	move.l	a0,-4(a1)		; l„gg adr till bomben p† sr:en

	move.l	x_gubbe,2(a0)	; x bmb z bmb
	move.w	#39,6(a0)		; spr start bmb
	move.w	#25*CD_BOMB,8(a0)	; antal sekunder
	move.l	a0,a1

	lea	bomb_adr,a0
	move.w	#ANT_BOMB-1-1,d7	; max antal d”rrar samtidigt=ANT_DOOR (-1 f”r att om alla „r upptagna s† skrivs sista ”ver)
.chkbmb1	cmp.l	(a0),a1
	beq.s	.no_bomb_lagd
	cmp.l	#0,(a0)
	beq.s	.putbmbad
	addq.l	#4,a0
	dbf	d7,.chkbmb1
	
	move.l	a1,(a0)
	bra.s	.no_bomb_lagd
	
.putbmbad	move.l	a1,(a0)+
	subq.w	#1,d7
	blt.s	.no_bomb_lagd

.chkbmb2	cmp.l	(a0),a1
	bne.s	.nollejb
	move.l	#0,(a0)
.nollejb	addq.l	#4,a0
	dbf	d7,.chkbmb2

.no_bomb_lagd

; +-------------------------------------+	
; | Fixa allt med spr„nga bomber 
; +-------------------------------------+	
; jk
	lea	bomb_adr,a0		; adr till eventuella bombs
	move.l	#0,.save_play_adr
	move.w	#ANT_BOMB-1,d7		; antal bomber
.bmb_lp1	move.l	(a0)+,a1

	cmp.l	#0,a1
	beq	.fixed_bm

	tst.w	cdcnt
	bge.s	.ej_ny_cd
	move.w	8(a1),d0
	divu	#25,d0		; shifta ned
	move.w	d0,cdcnt		; och s„tt cdcnt
	mulu	#25,d0		; shifta upp
	move.w	d0,8(a1)		; och s„tt invid-countern
	move.w	#26,.pipcnt
.ej_ny_cd

	tst.w	.pipcnt
	bne.s	.ej_res_pip
	tst.w	cdcnt
	blt.s	.ej_res_pip
	move.w	#26,.pipcnt
.ej_res_pip

	tst.w	.pipcnt
	ble	.ej_nytt_ljud
	sub.w	#1,.pipcnt
	cmp.w	#25,.pipcnt
	bne.s	.ej_nytt_ljud
	lea	sound_board,a2	; starta ljud f”r exp 
	move.w	(a2),d0
	add.w	#1,(a2)+
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,a2
	move.l	2(a1),(a2)+	; xz
	move.w	#8,(a2)+		; ljud nr
.ej_nytt_ljud

	sub.w	#1,8(a1)		; test om det spr„ngs
	tst.w	8(a1)		; tima ur lite s† han inte r„knar ner
	bge	.fixed_bm		; f”r mycket

	move.w	#-1,.pipcnt	; inget mer pip

	lea	adrmap,a6		; l„gg in adr till spelare
	move.w	x_gubbe,d0
	move.w	z_gubbe,d1
	lsr.w	#6,d0
	lsr.w	#6,d1
	lsl.w	#5,d1
	add.w	d0,d1
	lsl.w	#4,d1
	add.w	d1,a6
	tst.l	(a6)+
	beq.s	.putplay
	tst.l	(a6)+
	beq.s	.putplay
	tst.l	(a6)+
	beq.s	.putplay
	addq.l	#4,a6
.putplay	subq.l	#4,a6
	move.l	#x_gubbe-2,(a6)	; adr gubbe
	move.l	a6,.save_play_adr	; spara adr gubbe
	
	lea	.next_beg_bomb,a2
	lea	adrmap,a3

	move.w	2(a1),d0
	move.w	4(a1),d1
	lsr.w	#6,d0
	lsr.w	#6,d1
	lsl.w	#5,d1
	add.w	d0,d1
	lsl.w	#4,d1
	add.w	d1,a3
	
	move.w	#8-1,d6			; antal listor att kolla
.bmb_lp2	move.l	a3,a4
	move.l	(a2)+,a5
	move.w	(a5)+,d5			; antal ruta denna lista
	moveq	#100,d0			; skada p† bomben

;------- Kolla f”rsta rutan -------
	
	tst.l	0(a4)
	beq.s	.long1k
	move.l	0(a4),a6
	cmp.w	#2,(a6)
	blt	.hit
	bgt.s	.ts1a
	tst.w	20(a6)			; om st„ngd d”rr s† sluta
	beq	.hit
	bra.s	.long1k
.ts1a	cmp.w	#4,(a6)
	blt.s	.long1k
	jsr	.hit_fi_with_bomb
.long1k
	tst.l	4(a4)
	beq.s	.long2k
	move.l	4(a4),a6
	cmp.w	#4,(a6)
	blt.s	.long2k
	jsr	.hit_fi_with_bomb
.long2k
	tst.l	8(a4)
	beq.s	.long3k
	move.l	8(a4),a6
	cmp.w	#4,(a6)
	blt.s	.long3k
	jsr	.hit_fi_with_bomb
.long3k
	tst.l	12(a4)
	beq.s	.long4k
	move.l	12(a4),a6
	cmp.w	#4,(a6)
	blt.s	.long4k
	jsr	.hit_fi_with_bomb
.long4k
	add.w	(a5)+,a4			; f”rsta rutan ska alltid

;------- Kolla a-rutorna -------

	moveq	#65,d0			; skada a
	
	tst.l	0(a4)
	beq.s	.long1kb
	blt	.hit
	move.l	0(a4),a6
	cmp.w	#2,(a6)			; tr„ffar den v„gg s† sluta
	blt	.hit
	bgt.s	.ts1
	tst.w	20(a6)			; om st„ngd d”rr s† sluta
	beq	.hit
	bra.s	.long1kb
.ts1	cmp.w	#4,(a6)
	blt.s	.long1kb
	jsr	.hit_fi_with_bomb
.long1kb
	tst.l	4(a4)
	beq.s	.long2kb
	move.l	4(a4),a6
	cmp.w	#4,(a6)
	blt.s	.long2kb
	jsr	.hit_fi_with_bomb
.long2kb
	tst.l	8(a4)
	beq.s	.long3kb
	move.l	8(a4),a6
	cmp.w	#4,(a6)
	blt.s	.long3kb
	jsr	.hit_fi_with_bomb
.long3kb
	tst.l	12(a4)
	beq.s	.long4kb
	move.l	12(a4),a6
	cmp.w	#4,(a6)
	blt.s	.long4kb
	jsr	.hit_fi_with_bomb
.long4kb

;------ Kolla resterande rutor -----

.bmb_lp3	moveq	#30,d0			; skada b c d
	add.w	(a5)+,a4			; till n„sta sr
	
	tst.l	0(a4)
	beq.s	.long1b
	blt	.nextsqr
	move.l	0(a4),a6
	cmp.w	#2,(a6)			; tr„ffar den v„gg s† sluta
	blt	.nextsqr
	bgt.s	.ts1b
	tst.w	20(a6)			; om st„ngd d”rr s† sluta
	beq	.nextsqr	
	bra.s	.long1b
.ts1b	cmp.w	#4,(a6)
	blt.s	.long1b
	jsr	.hit_fi_with_bomb
.long1b
	tst.l	4(a4)
	beq.s	.long2b
	move.l	4(a4),a6
	cmp.w	#4,(a6)
	blt.s	.long2b
	jsr	.hit_fi_with_bomb
.long2b
	tst.l	8(a4)
	beq.s	.long3b
	move.l	8(a4),a6
	cmp.w	#4,(a6)
	blt.s	.long3b
	jsr	.hit_fi_with_bomb
.long3b
	tst.l	12(a4)
	beq.s	.long4b
	move.l	12(a4),a6
	cmp.w	#4,(a6)
	blt.s	.long4b
	jsr	.hit_fi_with_bomb
.long4b
	
.nextsqr	dbf	d5,.bmb_lp3
.hit	dbf	d6,.bmb_lp2
	move.l	#0,-4(a0)		; d† var den bomben klar
	move.w	#0,8(a1)		; resetta r„knaren

	lea	explosion_adr,a6
	move.w	#ANT_EXP-1-1,d6	; max antal explosioner samtidigt=ANT_EXP (-1 f”r att om alla „r upptagna s† skrivs sista ”ver)
.chkexp1	cmp.l	(a6),a1
	beq.s	.fixed_bm
	cmp.l	#0,(a6)
	beq.s	.putexpad
	addq.l	#4,a6
	dbf	d6,.chkexp1
	move.l	a1,(a6)
	bra.s	.fixed_bm
.putexpad	move.l	a1,(a6)+
	subq.w	#1,d6
	blt.s	.fixed_bm
.chkexp2	cmp.l	(a6),a1
	bne.s	.nollejc
	move.l	#0,(a6)
.nollejc	addq.l	#4,a6
	dbf	d6,.chkexp2

.fixed_bm	dbf	d7,.bmb_lp1

	tst.l	.save_play_adr
	beq	.bomb_klar
	move.l	.save_play_adr,a0
	move.l	#0,(a0)
	bra	.bomb_klar
	
;- R„kna ut huruvida fi blir skadad och i vilken vinkel -

.hit_fi_with_bomb
	
	cmp.w	#5,(a6)		; kolla om det „r player
	beq	.skada_player

	move.w	2(a6),d2		; x
	move.w	4(a6),d3		; z
	lsr.w	#4,d2
	lsr.w	#4,d3

	sub.w	2(a1),d2		; dx
	bge.s	.noneg1
	neg.w	d2
.noneg1	sub.w	4(a1),d3		; dz
	bge.s	.noneg2
	neg.w	d3
.noneg2
	mulu	d2,d2
	mulu	d3,d3
	add.l	d2,d3		; x^2+z^2=sum
	jsr	roten_ur		; sqr sum

	move.w	2(a6),d1		; x
	move.w	4(a6),d2		; z
	lsr.w	#4,d1
	lsr.w	#4,d2
	sub.w	2(a1),d1
	sub.w	4(a1),d2
	add.w	x_gubbe,d1	; bara f”r att r„knavinkel rutinen
	add.w	z_gubbe,d2	; drar bort dessa sedan
	
	jsr	r„kna_vinkel	; r„knar relativ vinkel

	add.w	look_angle,d3	; bara f”r att r„knavinkel rutinen
	cmp.w	#360,d3		; drar bort look_angle fr†n svaret
	blt.s	.nores2
	sub.w	#359,d3
.nores2
	move.w	d0,56(a6)		; skada fi
	move.w	d3,66(a6)		; vinkel fi ska flyga i
	rts

.skada_player
	sub.w	d0,health		; skada spelaren
	rts

.bomb_klar

; +-------------------------------------+	
; | Kolla om n†got exploderar 
; +-------------------------------------+	
; jk
	lea	explosion_adr,a0
	move.w	#ANT_EXP-1,d7
.exp_lp	move.l	(a0),a1
	
	cmp.l	#0,a1
	beq	.exp_fixed

	tst.w	8(a1)		; s„tt exp 1
	beq.s	.sta_expl
	cmp.w	#5,8(a1)		; s„tt exp 2
	beq.s	.inc_expl
	cmp.w	#10,8(a1)		; s„tt exp 3
	beq.s	.inc_expl
	cmp.w	#15,8(a1)		; stoppa exp
	beq.s	.sto_expl
	
	add.w	#1,8(a1)
	bra	.exp_fixed

.sta_expl	move.w	#43,6(a1)		; f”rsta exp sprite:n
	add.w	#1,8(a1)
	
	lea	sound_board,a2	; starta ljud f”r exp 
	move.w	(a2),d0
	add.w	#1,(a2)+
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,a2
	move.l	2(a1),(a2)+	; xz
	move.w	#10,(a2)+		; ljud nr
	bra	.exp_fixed	

.inc_expl	add.w	#1,6(a1)		; ”ka nummret
	add.w	#1,8(a1)
	bra	.exp_fixed

.sto_expl	move.w	#-2,8(a1)		; s„tt r„knaren=klar

	lea	adrmap,a2
	move.w	2(a1),d0
	move.w	4(a1),d1
	lsr.w	#6,d0
	lsr.w	#6,d1
	lsl.w	#5,d1
	add.w	d0,d1
	lsl.w	#4,d1
	add.w	d1,a2
	
	cmp.l	(a2)+,a1
	beq.s	.clear
	cmp.l	(a2)+,a1
	beq.s	.clear
	cmp.l	(a2)+,a1
	beq.s	.clear
	cmp.l	(a2)+,a1
	beq.s	.clear
	bra	.exp_fixed
			
.clear	move.l	#0,-4(a2)		; rensa i adrmap
	move.l	#0,(a0)		; rensa i exp_adr

.exp_fixed
	addq.l	#4,a0
	dbf	d7,.exp_lp

; +-------------------------------------+	
; | Kolla om man b„r IR-glas”gonen
; +-------------------------------------+	
; jk
	tst.w	go_goggles
	beq.s	.no_gogg

	add.w	#1,go_goggles

	cmp.w	#18,go_goggles
	bgt.s	.chk_end_gogg

	lea	nuvarande_pal,a0
	lea	gogg_pal,a1
	moveq	#16-1,d0
	jsr	paltopal
	bra.s	.no_gogg

.chk_end_gogg
	cmp.w	#25*SEK_GOGG,go_goggles
	blt.s	.chk_res

	lea	nuvarande_pal,a0
	lea	pal,a1
	moveq	#16-1,d0
	jsr	paltopal
	bra.s	.no_gogg
	
.chk_res	cmp.w	#25*SEK_GOGG+18,go_goggles
	bne.s	.no_gogg
	move.w	#0,go_goggles

.no_gogg

; +-------------------------------------+	
; | Kolla om man plockar upp n†ge 
; +-------------------------------------+	
; jk
	lea	adrmap,a0
	lea	.happen_rut,a1
	move.l	bytemap_0,a3
	move.w	x_gubbe,d0
	move.w	z_gubbe,d1
	lsr.w	#6,d0
	lsr.w	#6,d1
	lsl.w	#5,d1
	add.w	d0,d1
	add.w	d1,a3
	lsl.w	#4,d1
	add.w	d1,a0
	
	tst.l	(a0)
	beq	.inget_att_fixa

	move.l	(a0),a2
	cmp.w	#3,(a2)
	bne	.inget_att_fixa
	
	move.w	6(a2),d0		; typ
	cmp.w	#21,d0
	bgt	.inget_att_fixa

	add.w	d0,d0
	add.w	d0,d0
	move.l	(a1,d0.w),a1
	jmp	(a1)
	
.medikit	cmp.w	#100,health
	bge	.inget_att_fixa
	moveq	#0,d0
	add.w	#MEDIKIT,health
	cmp.w	#100,health 
	ble	.plock_sound1
	move.w	#100,health
	bra	.plock_sound1

.food	cmp.w	#100,health
	bge	.inget_att_fixa
	moveq	#1,d0
	add.w	#FOOD,health
	cmp.w	#100,health
	ble	.plock_sound1
	move.w	#100,health
	bra	.plock_sound1

.superkit	cmp.w	#200,health
	bge	.inget_att_fixa
	moveq	#2,d0
	add.w	#SUPERKIT,health
	cmp.w	#200,health
	ble	.plock_sound1
	move.w	#200,health
	bra	.plock_sound1
	
.subgun	tst.w	har_vapen+4
	bne	.ammo3
	moveq	#3,d0
	move.w	#1,har_vapen+4
	cmp.w	#3,vilket_vapen
	bge	.plock_sound1
	move.w	#SKADA2,vapen_skada
	move.w	#1,„ndrat_vapen
	move.w	#2,vilket_vapen
	bra	.plock_sound1

.booster	tst.w	har_vapen+6
	bne	.ammo1
	moveq	#4,d0
	move.w	#1,har_vapen+6
	cmp.w	#4,vilket_vapen
	bge	.plock_sound1
	move.w	#SKADA3,vapen_skada
	move.w	#1,„ndrat_vapen
	move.w	#3,vilket_vapen
	bra	.plock_sound1

.minigun	tst.w	har_vapen+8
	bne	.ammo3
	move.w	#14,d0
	move.w	#1,har_vapen+8
	cmp.w	#5,vilket_vapen
	bge	.plock_sound1
	move.w	#SKADA4,vapen_skada
	move.w	#1,„ndrat_vapen
	move.w	#4,vilket_vapen
	bra	.plock_sound1

.blaster	tst.w	har_vapen+10
	bne	.ammo4
	moveq	#5,d0
	move.w	#1,har_vapen+10
	move.w	#SKADA5,vapen_skada
	move.w	#1,„ndrat_vapen
	move.w	#5,vilket_vapen
	bra	.plock_sound1

.ammo1	cmp.w	#MAX_AMMO1,ammo_vapen+2
	bge	.inget_att_fixa

	tst.w	ammo_vapen+2
	bne	.ejnoll1
	tst.w	vilket_vapen
	bne	.ejnoll1
	tst.w	har_vapen+6
	bne.s	.ta_hagel
	move.w	#1,vilket_vapen
	move.w	#1,„ndrat_vapen
	bra	.ejnoll1
.ta_hagel	move.w	#3,vilket_vapen
	move.w	#1,„ndrat_vapen
.ejnoll1
	moveq	#6,d0
	add.w	#AMMO1,ammo_vapen+2
	add.w	#AMMO1,ammo_vapen+6
	cmp.w	#MAX_AMMO1,ammo_vapen+2
	ble	.plock_sound2
	move.w	#MAX_AMMO1,ammo_vapen+2
	move.w	#MAX_AMMO1,ammo_vapen+6
	bra	.plock_sound2

.ammo3	cmp.w	#MAX_AMMO2,ammo_vapen+4
	bge	.inget_att_fixa

	tst.w	ammo_vapen+4
	bne	.ejnoll3
	tst.w	vilket_vapen
	bne	.ejnoll3
	tst.w	har_vapen+8
	bne.s	.ta_mini
	move.w	#2,vilket_vapen
	move.w	#1,„ndrat_vapen
	bra	.ejnoll3
.ta_mini	move.w	#4,vilket_vapen
	move.w	#1,„ndrat_vapen
.ejnoll3
	moveq	#7,d0
	add.w	#AMMO2,ammo_vapen+4
	add.w	#AMMO2,ammo_vapen+8
	cmp.w	#MAX_AMMO2,ammo_vapen+4
	ble	.plock_sound2
	move.w	#MAX_AMMO2,ammo_vapen+4
	move.w	#MAX_AMMO2,ammo_vapen+8
	bra	.plock_sound2
	
.ammo4	cmp.w	#MAX_AMMO5,ammo_vapen+10
	bge	.inget_att_fixa
	tst.w	ammo_vapen+10
	bne	.ejnoll4
	tst.w	vilket_vapen
	bne	.ejnoll4
	move.w	#5,vilket_vapen
	move.w	#1,„ndrat_vapen
.ejnoll4
	moveq	#8,d0
	add.w	#AMMO5,ammo_vapen+10
	cmp.w	#MAX_AMMO5,ammo_vapen+10
	ble	.plock_sound2
	move.w	#MAX_AMMO5,ammo_vapen+10
	bra	.plock_sound2

.bomb	cmp.w	#3,bombs
	bge	.inget_att_fixa

	move.l	bombs+2,a4
	cmp.w	#-2,8(a4)
	beq.s	.addbmb
	move.l	bombs+6,a4
	cmp.w	#-2,8(a4)
	beq.s	.addbmb
	move.l	bombs+10,a4
	cmp.w	#-2,8(a4)
	bne	.inget_att_fixa

.addbmb	add.w	#1,bombs		; en bomb mer
	
	moveq	#9,d0
	bra	.plock_sound1
	
.nyckel1	tst.w	har_nyckel
	bne	.inget_att_fixa
	moveq	#10,d0
	move.w	#1,har_nyckel
	bra	.plock_sound3
	
.nyckel2	tst.w	har_nyckel+2
	bne	.inget_att_fixa
	moveq	#11,d0
	move.w	#1,har_nyckel+2
	bra	.plock_sound3

.nyckel3	tst.w	har_nyckel+4
	bne	.inget_att_fixa
	moveq	#12,d0
	move.w	#1,har_nyckel+4
	bra	.plock_sound3

.goggles	tst.w	go_goggles
	bne	.inget_att_fixa
	tst.w	warning
	bne	.inget_att_fixa
	moveq	#16,d0
	move.w	#1,go_goggles
	bra	.plock_sound1
	
.plock_sound1
	move.l	#0,(a0)
	move.b	#0,(a3)
	jsr	do_mess
	moveq	#11,d2		; ljud effekt
	bra	.ladda_dd

.plock_sound2
	move.l	#0,(a0)
	move.b	#0,(a3)
	jsr	do_mess
	moveq	#13,d2		; ljud effekt (ammo)
	bra	.ladda_dd

.plock_sound3
	move.l	#0,(a0)
	move.b	#0,(a3)
	jsr	do_mess
	moveq	#12,d2		; ljud effekt (nyckel)
	
.ladda_dd	lea	sound_board,a0
	move.w	(a0),d0
	add.w	#1,(a0)+
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,a0
	move.l	x_gubbe,(a0)+	; xz
	move.w	d2,(a0)+		; ljud nr
	move.w	#1,.plock_flg	

.inget_att_fixa

;-------- S„tt gr”n f„rg i 4 vbl om man plockat upp n†ge -------

	tst.w	.plock_flg
	beq	.no_greencol
	tst.w	warning
	bne	.no_greencol
	tst.w	go_goggles
	bne	.no_greencol
	tst.w	stor_pal
	bne.s	.no_greencol

	add.w	#1,.plock_flg
	cmp.w	#3,.plock_flg
	ble	.set_gr
	bgt.s	.set_ord1
	bra.s	.no_greencol
	
.set_gr	lea	nuvarande_pal,a0
	lea	plock_pal,a1
	moveq	#16-1,d0
	jsr	paltopal
	bra.s	.no_greencol
	
.set_ord1	lea	nuvarande_pal,a0
	lea	pal,a1
	moveq	#16-1,d0
	jsr	paltopal

	cmp.w	#7,.plock_flg
	bne.s	.no_greencol
	move.w	#0,.plock_flg

.no_greencol

;-------- S„tt r”d f„rg i 4 vbl om man blivit skadad -------

	cmp.w	#0,health		; kolla s† det inte blir
	bge.s	.nomhelth		; minus health
	move.w	#0,health
.nomhelth

	move.w	health,d0
	cmp.w	.old_health,d0
	bge	.set_oldh
	
	tst.w	d0		; d”d
	beq	.killed

	tst.w	.hurt_flg
	bne.s	.ej_ljd
	lea	sound_board,a0
	move.w	(a0),d0
	add.w	#1,(a0)+
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,a0
	move.l	x_gubbe,(a0)+	; xz
	move.w	#6,(a0)+		; ljud nr
.ej_ljd
	tst.w	midi_on		; kolla midi
	beq.s	.no_mi3
	moveq	#6,d0
	jsr	midi_send
.no_mi3
	tst.w	warning
	bne.s	.set_oldh

	tst.w	go_goggles
	bne.s	.set_oldh

	tst.w	stor_pal
	bne.s	.set_oldh

	add.w	#1,.hurt_flg
	cmp.w	#3,.hurt_flg
	ble.s	.set_red
	bgt.s	.set_ord2
	bra.s	.no_redcol

.set_red	lea	nuvarande_pal,a0
	lea	skada_pal,a1
	moveq	#16-1,d0
	jsr	paltopal
	bra.s	.no_redcol
	
.set_ord2	lea	nuvarande_pal,a0
	lea	pal,a1
	moveq	#16-1,d0
	jsr	paltopal

	cmp.w	#7,.hurt_flg
	bne.s	.no_redcol
	bra.s	.set_oldh

.killed	move.w	#0,health
	move.w	#1,killed

.set_oldh	move.w	health,.old_health
	move.w	#0,.hurt_flg
.no_redcol
	rts

;-------- Lite lokala variabler ----------

.plock_flg	dc.w	0
.hurt_flg		dc.w	0
.old_health	dc.w	-10
.pipcnt		dc.w	-1
.save_play_adr	dc.l	0
.happen_rut	dc.l	.medikit,.food,.superkit,.subgun,.booster
		dc.l	.minigun,.blaster,.ammo1,.ammo3,.ammo4,.bomb
		dc.l	.nyckel1,.nyckel2,.nyckel3
		REPT	7
		dc.l	.inget_att_fixa
		ENDR
		dc.l	.goggles
		dc.l	.inget_att_fixa
.rel_add_bomb	dc.w	3-1,(-1-1*32)*16,(-0-1*32)*16,(-1+1*32)*16,(-0-1*32)*16,0,0,0
		dc.w	3-1,(+1-1*32)*16,(-0-1*32)*16,(+1+1*32)*16,(-0-1*32)*16,0,0,0
		dc.w	3-1,(+1+1*32)*16,(-0+1*32)*16,(+1-1*32)*16,(-0+1*32)*16,0,0,0
		dc.w	3-1,(-1+1*32)*16,(-0+1*32)*16,(-1-1*32)*16,(-0+1*32)*16,0,0,0
		dc.w	1-1,(-0-1*32)*16,(-0-1*32)*16,0,0,0,0,0
		dc.w	1-1,(+1-0*32)*16,(+1-0*32)*16,0,0,0,0,0
		dc.w	1-1,(-0+1*32)*16,(-0+1*32)*16,0,0,0,0,0
		dc.w	1-1,(-1-0*32)*16,(-1-0*32)*16,0,0,0,0,0
.next_beg_bomb	dc.l	.rel_add_bomb+16*0
		dc.l	.rel_add_bomb+16*1
		dc.l	.rel_add_bomb+16*2
		dc.l	.rel_add_bomb+16*3
		dc.l	.rel_add_bomb+16*4
		dc.l	.rel_add_bomb+16*5
		dc.l	.rel_add_bomb+16*6
		dc.l	.rel_add_bomb+16*7
		dc.l	.rel_add_bomb+16*7
.savething	dc.w	0
		dcb.w	16,0

* +-----------------------------------------------------------------------+	
* | Handle event. Kollar om n†gon bomb ska sm„lla eller dylikt            |
* +-----------------------------------------------------------------------+	
* ui
handle_event

	move.l	bytemap_3,a0
	lea	.adr_hopp,a1

	move.w	x_gubbe,d0
	move.w	z_gubbe,d1
	lsr.w	#6,d0
	lsr.w	#6,d1
	lsl.w	#5,d1
	add.w	d0,d1
	add.w	d1,a0
	
	move.b	(a0),d0
	ext.w	d0
	tst.w	d0
	beq	.no_event

	move.w	d0,d1
	add.w	d0,d0	
	add.w	d0,d0	
	move.l	(a1,d0.w),a1
	jmp	(a1)

.fi_l	move.w	#1,fi_alarm
	bra	.no_event
	
.warn_on	tst.w	warning
	bne	.no_event
	movem.l	pal,d0-d7
	movem.l	d0-d7,nuvarande_pal
	move.w	#0,go_goggles
	move.w	#1,warning
	bra	.no_event
	
.w_cd_on	tst.w	warning
	bne	.no_event
	move.w	#1,warning
	bra	.no_event
	
.warn_off	tst.w	warning
	beq	.no_event
	cmp.w	#3,warning
	beq	.no_event
	move.w	#3,warning
	bra	.no_event

.total_event
	move.l	bytemap_3,a0
	lea	adrmap,a2
	
	lea	32*32(a0),a0
	subq.w	#6,d1		; d1=eventnummer
	add.w	d1,d1
	move.w	d1,d2		; spara
	move.w	(a0,d1.w),d1	; till r„tt adr
	blt	.no_event		; om offs=-1 s† skit i det

	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,a2
	move.l	(a2),a1

	cmp.l	#0,a1		; om man redan tex plockat upp
	ble	.no_event		; d”rren eller flyttat d”rren
	
	cmp.w	#2,(a1)
	beq.s	.punkt_door
	blt.s	.punkt_hdoor
	bgt	.punkt_bmb
	bra	.no_event

;-------- ™ppna d”rr med punkt -------

.punkt_door
	cmp.w	#-2,22(a1)	; kolla om det „r en punktd”rr
	bne	.no_event

	tst.l	4(a2)		; om det „r n†ge p† de andra
	bne	.no_event		; longsen s† ta inte adr eftersom
	tst.l	8(a2)		; den d† redan „r ”ppen
	bne	.no_event
	tst.l	12(a2)
	bne	.no_event

	lea	akt_d_adr,a0
	move.w	#ANT_DOOR-1-1,d7	; max antal d”rrar samtidigt=ANT_DOOR (-1 f”r att om alla „r upptagna s† skrivs sista ”ver)
.chkadr1	cmp.l	(a0),a1
	beq	.no_event
	cmp.l	#0,(a0)
	beq.s	.put_adr
	addq.l	#4,a0
	dbf	d7,.chkadr1
	
	move.l	a1,(a0)
	bra	.no_event
	
.put_adr	move.l	a1,(a0)+
	subq.w	#1,d7
	blt	.no_event

.chkadr2	cmp.l	(a0),a1
	bne.s	.nollej
	move.l	#0,(a0)
.nollej	addq.l	#4,a0
	dbf	d7,.chkadr2
	bra	.no_event
	
;-------- ™ppna hemlig d”rr med punkt -------

.punkt_hdoor
	tst.w	go_hemlig		; om en h†ller p† att ”ppnas redan
	bne	.no_event		; s† skit i det

	move.w	#0,(a0,d2.w)	; st„ll offsetten=-1
	
	move.w	#1,go_hemlig	; det „r en hemlig d”rr
	move.w	d1,go_hemlig+2	; offset i adrmap till sr
	lsr.w	#4,d1
	jsr	put_hidd
	bra	.no_event

;-------- spr„ng en bomb med punkt -------

.punkt_bmb
	move.w	#-1,(a0,d2.w)	; st„ll offsetten=-1

	move.w	#39,6(a1)		; spr start bmb
	move.w	#25*CD_BOMB,8(a1)	; antal sekunder

	lea	bomb_adr,a0
	move.w	#ANT_BOMB-1-1,d7	; max antal d”rrar samtidigt=ANT_DOOR (-1 f”r att om alla „r upptagna s† skrivs sista ”ver)
.chkbmb1	cmp.l	(a0),a1
	beq.s	.no_event
	cmp.l	#0,(a0)
	beq.s	.putbmbad
	addq.l	#4,a0
	dbf	d7,.chkbmb1
	
	move.l	a1,(a0)
	bra.s	.no_event
	
.putbmbad	move.l	a1,(a0)+
	subq.w	#1,d7
	blt.s	.no_event

.chkbmb2	cmp.l	(a0),a1
	bne.s	.nollejb
	move.l	#0,(a0)
.nollejb	addq.l	#4,a0
	dbf	d7,.chkbmb2

.no_event	rts
	
.adr_hopp		dc.l	.no_event,.fi_l,.warn_on,.w_cd_on,.warn_off
		dc.l	.no_event
		REPT	15
		dc.l	.total_event
		ENDR

* +-*********************************************************************-+
* | Uppdatering av MIDI rutinen                                           |
* * Tar v„rden fr†n templistorna och fixar det som h„nt        / /        *
* * Av Mikael Emtinger 1995                                   /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************
ud_midi
	tst.w	midi_on
	bne.s	.gogo
	rts
.gogo
	tst.w	.flg
	bne.s	.goon
	move.w	#1,.flg
	rts
.goon	move.w	#0,.flg

	jsr	get_values		; fast„ll v„rden
	jsr	chk_evebyte		; kolla eventbytes
	jsr	put_on_adrmap		; l„gg ut i adrmap
*	jsr	chk_event			; trampar n†gon p† event
	rts

.flg	dc.w	0

;--------------------------------------------------------------------------
; Fastst„ll v„rderna fr†n spelarlista
;--------------------------------------------------------------------------
; ui
get_values
	lea	spelar_lista,a0
	lea	spelar_buffer,a1		; indik xz spr spr v osv...

	moveq	#0,d6
	move.w	ant_com,d7		; fastst„ll v„rderna
	subq.w	#1,d7
.fastst„l	cmp.w	com_id,d6
	beq.s	.db

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	
	move.l	(a0),d0			; x
	move.l	d0,d1			; z
	move.l	d0,d2			; vinkel

	and.l	#%01111111111100000000000000000000,d0	; ta fram x
	and.l	#%00000000000011111111111000000000,d1	; ta fram z
	and.l	#%00000000000000000000000111111111,d2	; ta fram vink

	swap	d0			; 16 bittar
	lsr.l	#4,d0			; 4  bittar
	
	lsr.l	#8,d1			; 8  bittar
	lsr.l	#1,d1			; 1  bittar

	move.w	d0,02(a1)		; x
	move.w	d1,04(a1)		; z
	move.w	d2,10(a1)		; v
.db
	lea	4(a0),a0
	lea	48(a1),a1
	addq.w	#1,d6
	
	dbf	d7,.fastst„l
	rts

;--------------------------------------------------------------------------
; Kolla upp eventbytesens status och s„tt lite flaggor
;--------------------------------------------------------------------------
; ui
chk_evebyte

;-------- Kolla ID-0 lista --------

	cmp.w	#0,com_id
	beq.s	.chk_eve2

	lea	event_lista+00,a0	; e*32
	moveq	#32-1,d7
.eve1	tst.b	(a0)
	beq.s	.hp1

	movem.l	d7/a0,-(sp)
	moveq	#0,d0
	move.b	(a0),d0
	move.w	d0,d1
	and.w	#%0000000000001111,d0	; undre nibble
	and.w	#%0000000011110000,d1	; ”vre  nibble
	lsr.w	#4,d1
	lea	spelar_buffer+00,a0		; xz spr spr v osv...
	jsr	.set_flg
	movem.l	(sp)+,d7/a0

.hp1	addq.l	#1,a0
	dbf	d7,.eve1

;-------- Kolla ID-1 lista --------

.chk_eve2	cmp.w	#1,com_id
	beq.s	.chk_eve3

	lea	event_lista+32,a0	; e*32
	moveq	#32-1,d7
.eve2	tst.b	(a0)
	beq.s	.hp2

	movem.l	d7/a0,-(sp)
	moveq	#0,d0
	move.b	(a0),d0
	move.w	d0,d1
	and.w	#%0000000000001111,d0	; undre nibble
	and.w	#%0000000011110000,d1	; ”vre  nibble
	lsr.w	#4,d1
	lea	spelar_buffer+48,a0		; xz spr spr v osv...
	jsr	.set_flg
	movem.l	(sp)+,d7/a0

.hp2	addq.l	#1,a0
	dbf	d7,.eve2

;-------- Kolla ID-2 lista --------

.chk_eve3	cmp.w	#2,com_id
	beq.s	.chk_eve4

	lea	event_lista+64,a0	; e*32
	moveq	#32-1,d7
.eve3	tst.b	(a0)
	beq.s	.hp3

	movem.l	d7/a0,-(sp)
	moveq	#0,d0
	move.b	(a0),d0
	move.w	d0,d1
	and.w	#%0000000000001111,d0	; undre nibble
	and.w	#%0000000011110000,d1	; ”vre  nibble
	lsr.w	#4,d1
	lea	spelar_buffer+96,a0		; xz spr spr v osv...
	jsr	.set_flg
	movem.l	(sp)+,d7/a0

.hp3	addq.l	#1,a0
	dbf	d7,.eve3

;-------- Kolla ID-3 lista --------

.chk_eve4	cmp.w	#3,com_id
	beq.s	.sl_chk

	lea	event_lista+96,a0	; e*32
	moveq	#32-1,d7
.eve4	tst.b	(a0)
	beq.s	.hp4

	movem.l	d7/a0,-(sp)
	moveq	#0,d0
	move.b	(a0),d0
	move.w	d0,d1
	and.w	#%0000000000001111,d0	; undre nibble
	and.w	#%0000000011110000,d1	; ”vre  nibble
	lsr.w	#4,d1
	lea	spelar_buffer+144,a0	; xz spr spr v osv...
	jsr	.set_flg
	movem.l	(sp)+,d7/a0

.hp4	addq.l	#1,a0
	dbf	d7,.eve4

.sl_chk	lea	event_lista,a0		; rensa
	move.w	#128/4-1,d7
.rens	move.l	#0,(a0)+
	dbf	d7,.rens

	rts

;--------------------------------------------------------------------------
; S„tt flag rutinen...
;--------------------------------------------------------------------------
; ui
.set_flg	cmp.w	#1,d0
	bne	.skjut
	
	lea	sound_board,a1
	lea	ljud_vapen,a2
	lea	skad_vapen,a3

	move.w	14(a0),d2
	add.w	d2,d2
	add.w	d2,a2
	add.w	d2,a3
	
	move.w	(a1),d2
	add.w	#1,(a1)+
	add.w	d2,d2
	move.w	d2,d3
	add.w	d2,d2
	add.w	d3,d2
	add.w	d2,a1
	move.l	2(a0),(a1)+	; xz
	move.w	(a2),(a1)+	; ljud nr

	move.w	#1,12(a0)		; s„tt skjut anim

	cmp.w	#5,d1
	bne.s	.trf
	rts
.trf	cmp.w	#4,d1			; flygande skott?
	beq.s	.flysko
	cmp.w	com_id,d1			; blev jag tr„ffad?
	bne	.ejtrf
	move.w	(a3),d0
	sub.w	d0,health
	rts
.ejtrf	lea	spelar_buffer,a1
	mulu	#48,d1
	move.w	#1,16(a1,d1.w)		; skada flaggan
	rts

.flysko	move.l	a0,a3
	lea	flyg_skott_buf,a0
	lea	sin_360,a1
	lea	adrmap,a2

	move.l	aktiva_skott,d0
	moveq	#-1,d1
	
	move.w	#32-1-1,d7		; testa vilket skott vi
.tst_vilk	addq.w	#1,d1			; kan anv„nda
	btst	d1,d0
	beq.s	.hitt_en
	dbf	d7,.tst_vilk		; om alla „r upptagna 
	bra	.no_flyg_skott		; s† blire inget skott

.hitt_en	bset	d1,d0			; nu „r denna upptagen
	move.l	d0,aktiva_skott

	lsl.w	#5,d1			; vilk*32 (16words)
	add.w	d1,a0			; peekar p† skottet	

	move.w	2(a3),d0			; x
	move.w	4(a3),d1			; z
	move.w	10(a3),d2			; v
	
	add.w	d2,d2
	add.w	d2,a1
	move.w	(a1),d3			; sin
	move.w	180(a1),d4		; cos
	
	muls	#SKOTTHAST,d3		; sin(grad)*snabbhet
	muls	#SKOTTHAST,d4		; cos(grad)*snabbhet
	lsr.l	#8,d3
	lsr.l	#8,d4
	lsr.l	#2,d3	
	lsr.l	#2,d4	
	neg.w	d3
	
	lsr.w	#6,d0
	lsr.w	#6,d1
	lsl.w	#5,d1			; z_gubbe*32
	add.w	d1,d0			; z_gubbe*32+x_gubbe
	lsl.w	#4,d0			; offs i adrmap

	tst.l	(a2,d0.w)
	beq.s	.found_c
	addq.w	#4,d0
	tst.l	(a2,d0.w)
	beq.s	.found_c
	addq.w	#4,d0
	tst.l	(a2,d0.w)
	beq.s	.found_c
	addq.w	#4,d0
.found_c	move.l	a0,(a2,d0.w)		; l„gg in skottadr p† sr

	lea	-90*2(a1),a1		; look_angle-90
	cmp.l	#sin_360,a1
	bge.s	.nojjo
	lea	360*2(a1),a1
.nojjo
	move.w	(a1),d1
	move.w	180(a1),d2
	
	muls	#2,d1			; skott bredd
	muls	#2,d2			; skott bredd
	swap	d1
	swap	d2
	rol.l	#2,d1
	rol.l	#2,d2

	lsl.w	#4,d1
	lsl.w	#4,d2
	sub.w	d3,d1
	add.w	d4,d2
	lsr.w	#4,d1
	lsr.w	#4,d2

	move.w	#3,(a0)+			; s„tt indik
	move.w	2(a3),(a0)		;      x_start
	sub.w	d1,(a0)+			;      korr f”r skottbredd
	move.w	4(a3),(a0)		;      z_start
	add.w	d2,(a0)+			;      korr f”r skottbredd
	move.w	#41,(a0)+			;      spr nr 1
	move.w	#0,(a0)+			;      explosions r„knare
	move.w	#41,(a0)+			;      spr nr 2 (-1=ej anim)
	move.w	d3,(a0)+			;      x_inc*16
	move.w	d4,(a0)+			;      z_inc*16
	move.w	#SKOTTHAST,(a0)+		;      hyp
	move.w	10(a3),(a0)+		;      skott_vinkel
	move.w	#SKADA5,(a0)+		;      skada (OMC)
	move.w	d0,(a0)+			;      adrmap offs

.no_flyg_skott
	rts

;-------- Kolla vapen byte ---------
	
.skjut	cmp.w	#2,d0
	bne	.chg_vpn
	move.w	d1,14(a0)			; vilket vapen han bytt till
	rts

;-------- Kolla om man lagt en bomb ---------

.chg_vpn	cmp.w	#3,d0	
	bne	.put_bmb

	lea	adrmap,a1
	lea	bomb_adr,a3
	
	add.w	d1,d1		; *4 f”r listan
	add.w	d1,d1
	move.l	28(a0,d1.w),a2

	move.w	40(a0),d0
	and.w	#%1111111111110000,d0
	add.w	d0,a1

	tst.l	(a1)+
	beq.s	.put_bma
	tst.l	(a1)+
	beq.s	.put_bma
	tst.l	(a1)+
	beq.s	.put_bma
	addq.l	#4,a1		; m†la ”ver sista vad det „n „r

.put_bma	move.l	a2,-4(a1)		; l„gg adr till bomben p† sr:en

	move.l	2(a0),2(a2)	; x bmb z bmb
	move.w	#39,6(a2)		; spr start bmb
	move.w	#25*CD_BOMB,8(a2)	; antal sekunder

	move.w	#ANT_BOMB-1-1,d7	; max antal d”rrar samtidigt=ANT_DOOR (-1 f”r att om alla „r upptagna s† skrivs sista ”ver)
.chkbmb1	cmp.l	(a3),a2
	beq.s	.nopps
	cmp.l	#0,(a3)
	beq.s	.putbmbad
	addq.l	#4,a3
	dbf	d7,.chkbmb1
	
	move.l	a2,(a3)
.nopps	rts
	
.putbmbad	move.l	a2,(a3)+
	subq.w	#1,d7
	blt.s	.nopps

.chkbmb2	cmp.l	(a3),a2
	bne.s	.nollejb
	move.l	#0,(a3)
.nollejb	addq.l	#4,a3
	dbf	d7,.chkbmb2
	rts

;-------- Kolla om man ”ppnar d”rr ---------

.put_bmb	cmp.w	#4,d0
	bne	.space
	lea	adrmap,a1
	move.w	40(a0),d1
	and.w	#%1111111111110000,d1
	add.w	#(-1*32)*16,d1
	add.w	d1,a1
	tst.l	(a1)
	beq.s	.chked_1
	move.l	(a1),a2
	cmp.w	#2,(a2)
	beq.s	.door
.chked_1	add.l	#(-1+1*32)*16,a1
	tst.l	(a1)
	beq.s	.chked_2
	move.l	(a1),a2
	cmp.w	#2,(a2)
	beq.s	.door
.chked_2	add.l	#2*16,a1
	tst.l	(a1)
	beq.s	.chked_3
	move.l	(a1),a2
	cmp.w	#2,(a2)
	beq.s	.door
.chked_3	add.l	#(-1+1*32)*16,a1
	tst.l	(a1)
	beq.s	.chked_4
	move.l	(a1),a2
	cmp.w	#2,(a2)
	beq.s	.door
.chked_4	rts

.door	lea	akt_d_adr,a1
	move.w	#ANT_DOOR-1,d7	; max antal d”rrar samtidigt=ANT_DOOR (-1 f”r att om alla „r upptagna s† skrivs sista ”ver)
.chkadr1	cmp.l	(a1),a2
	beq.s	.rtsa
	cmp.l	#0,(a1)
	beq.s	.put_adr
	addq.l	#4,a1
	dbf	d7,.chkadr1
.rtsa	rts
.put_adr	move.l	a2,(a1)+
	subq.w	#1,d7
	bge.s	.chkadr2
	rts
.chkadr2	cmp.l	(a1),a2
	bne.s	.nollej
	move.l	#0,(a1)
.nollej	addq.l	#4,a1
	dbf	d7,.chkadr2
	rts	

;-------- Kolla om meddelande --------
	
.space	cmp.w	#5,d0
	bne	.msg

*	tst.w	play_mode
*	bne.s	.fritt
*	lea	spelar_buffer,a4
*	move.w	com_id,d0
*	mulu	#42,d0
*	move.w	(a4,d0.w),d0	; jmf team
*	cmp.w	22(a3),d0
*	beq.s	.fritt
*	rts
.fritt	add.w	#13,d1		; f”rbi 'vanliga' msg str„ngar	
	move.w	d1,d0
	jsr	do_mess
	rts

;-------- Kolla om skada --------

.msg	cmp.w	#6,d0
	bne	.skadad

	lea	sound_board,a1	; starta sampling
	move.w	(a1),d0
	add.w	#1,(a1)+
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,a1
	move.l	2(a0),(a1)+	; xz
	move.w	#6,(a1)+		; ljud nr

	move.w	#1,16(a0)		; s„tt skad flag
	rts

;-------- Kolla om d”d ---------

.skadad	cmp.w	#8,d0
	bne	.error
	move.w	#1,18(a0)
.d”d	rts

;-------- Error rutin ---------

.error	move.w	#$700,$ffff8240.w	
	rts

;--------------------------------------------------------------------------
; L„gg ut spelarna p† adrmappen
;--------------------------------------------------------------------------
; ui
put_on_adrmap
	lea	spelar_buffer,a0
	lea	.spr_add,a1
	lea	adrmap,a2
	
	moveq	#0,d6
	move.w	ant_com,d7
	subq.w	#1,d7
.cnt_spr	cmp.w	com_id,d6
	beq	.dbfen
	
	moveq	#0,d1
	move.w	8(a0),d0		; utg spr
	move.w	10(a0),d1		; v

	sub.w	look_angle,d1
	bge.s	.mod_360
	add.w	#360,d1
.mod_360
	tst.w	18(a0)
	beq.s	.ej_dod
	
	add.w	#1,20(a0)

	cmp.w	#10,20(a0)
	bgt.s	.dod1
	add.w	#10,d0
	bra	.put_adrm
.dod1
	cmp.w	#20,20(a0)
	bgt.s	.dod2
	add.w	#11,d0
	bra.s	.put_adrm
.dod2
	move.w	#22,20(a0)
	add.w	#12,d0
	bra.s	.put_adrm

.ej_dod	tst.w	12(a0)
	beq.s	.ej_skjut
	add.w	#1,12(a0)
	cmp.w	#15,12(a0)
	bne.s	.ejnoll1
	move.w	#0,12(a0)
.ejnoll1	add.w	#8,d0
	bra.s	.put_adrm
.ej_skjut
	tst.w	16(a0)
	beq.s	.ej_skad
	add.w	#1,16(a0)
	cmp.w	#15,16(a0)
	bne.s	.ejnoll2
	move.w	#0,16(a0)
.ejnoll2	add.w	#9,d0
	bra.s	.put_adrm
.ej_skad
	divu	#45,d1		; r„kna ut vilken vinkel
	add.w	d1,d1
	add.w	(a1,d1.w),d0

	tst.w	46(a0)		; s† benen sprattlar
	bgt.s	.ej_anim1
	move.w	2(a0),d2
	move.w	4(a0),d3
	cmp.w	42(a0),d2
	bne.s	.anim1
	cmp.w	44(a0),d3
	beq.s	.ej_anim1
.anim1	add.w	#1,d0
.ej_anim1	neg.w	46(a0)

.put_adrm	move.w	d0,06(a0)		; nu spr

	move.w	2(a0),d0
	move.w	4(a0),d1
	move.w	d0,42(a0)
	move.w	d1,44(a0)

	lsr.w	#6,d0
	lsr.w	#6,d1
	lsl.w	#5,d1
	add.w	d0,d1
	lsl.w	#4,d1

	move.w	40(a0),d2
	and.w	#%1111111111110000,d2

	cmp.w	d1,d2
	beq.s	.dbfen

	move.w	40(a0),d2		; rensa gamla adr
	move.l	#0,(a2,d2.w)

	tst.l	(a2,d1.w)
	beq.s	.cleadr
	addq.w	#4,d1
	tst.l	(a2,d1.w)
	beq.s	.cleadr
	addq.w	#4,d1
	tst.l	(a2,d1.w)
	beq.s	.cleadr
	addq.w	#4,d1
.cleadr
	move.l	a0,(a2,d1.w)	; put adr
	move.w	d1,40(a0)		; rens offs

.dbfen	lea	48(a0),a0		; n„sta adr
	addq.w	#1,d6
	dbf	d7,.cnt_spr

	rts

.spr_add		dc.w	4,6,6,0,0,2,2,4,4

;--------------------------------------------------------------------------
; Kolla om n†gon trampar p† ett event
;--------------------------------------------------------------------------
; ui
chk_event	
	lea	spelar_buffer,a0
	move.l	bytemap_3,a1

	moveq	#0,d6
	move.w	ant_com,d7
	subq.w	#1,d7
.chk_eve	cmp.w	com_id,d6
	beq	.dbfas
	addq.w	#1,d6
	
	move.w	40(a0),d1
	and.w	#%1111111111110000,d1
	lsr.w	#4,d1
	
	tst.b	(a1,d1.w)
	beq.s	.dbfas

	nop

.dbfas	add.l	#48,a0
	dbf	d7,.chk_eve

	rts

* +-*********************************************************************-+
* | Fusk hanterare	                                                      |
* * Tar in tecken fr†n 'Tecken' och j„mf”r med egen tabell     / /        *
* * Av Oskar Burman 1995                                      /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-
cheat_hand:
	tst.w	c_teck
	beq	.rts		; Ingen tangent „r tryckt

	move.w	c_teck,d1
	move.w	#0,c_teck

	move.l	#fusk1,a0
	move.w	sbit1,d0
	move.b	(a0,d0),d0
	cmp.b	d1,d0
	bne	.hopp1
	addq.w	#1,sbit1		; Kommer ett steg l„ngre
	cmp.w	#5,sbit1		; fem bokst„ver
	bne	.hopp2
	not.w	medishoot
	move.w	#0,sbit1
.hopp1:
	move.w	#0,sbit1
.hopp2:
	move.l	#fusk2,a0
	move.w	sbit2,d0
	move.b	(a0,d0),d0
	cmp.b	d1,d0
	bne	.hopp3
	addq.w	#1,sbit2		; Kommer ett steg l„ngre
	cmp.w	#7,sbit2		; sju bokst„ver
	bne	.hopp4
	move.w	#100,health
	move.w	#0,sbit2
.hopp3:
	move.w	#0,sbit2
.hopp4:
	move.l	#fusk3,a0
	move.w	sbit3,d0
	move.b	(a0,d0),d0
	cmp.b	d1,d0
	bne	.hopp5
	move.w	#$770,nuvarande_pal
	addq.w	#1,sbit3		; Kommer ett steg l„ngre
	cmp.w	#4,sbit3		; Fyra bokst„ver
	bne	.hopp6
	move.w	#$077,nuvarande_pal
	move.l	#har_vapen,a0
	move.l	#$00010001,(a0)+
	move.l	#$00010001,(a0)+
	move.l	#$00010001,(a0)+
	move.l	#ammo_vapen+2,a0
	move.w	#MAX_AMMO1,(a0)+
	move.w	#MAX_AMMO2,(a0)+
	move.w	#MAX_AMMO3,(a0)+
	move.w	#MAX_AMMO4,(a0)+
	move.w	#MAX_AMMO5,(a0)+
	move.w	#0,sbit3
.hopp5:
	move.w	#0,sbit3
.hopp6:
	move.l	#fusk4,a0
	move.w	sbit4,d0
	move.b	(a0,d0),d0
	cmp.b	d1,d0
	bne	.hopp7
	addq.w	#1,sbit4		; Kommer ett steg l„ngre
	cmp.w	#6,sbit4		; sex bokst„ver
	bne	.hopp8
	move.l	#har_nyckel,a0	; Alla nycklar
	move.l	#$00010001,(a0)+
	move.l	#$00010000,(a0)+
	move.w	#$700,nuvarande_pal
	move.w	#0,sbit4
.hopp7:
	move.w	#0,sbit4
.hopp8:
	move.l	#fusk5,a0
	move.w	sbit5,d0
	move.b	(a0,d0),d0
	cmp.b	d1,d0
	bne	.hopp9
	addq.w	#1,sbit5		; Kommer ett steg l„ngre
	cmp.w	#5,sbit5		; fem bokst„ver
	bne	.hopp10
	not.w	drunkmode		; Drunkmode on/off
	move.w	#0,sbit5
.hopp9:
	move.w	#0,sbit5
.hopp10:
	move.l	#fusk6,a0
	move.w	sbit6,d0
	move.b	(a0,d0),d0
	cmp.b	d1,d0
	bne	.hopp11
	addq.w	#1,sbit6		; Kommer ett steg l„ngre
	cmp.w	#9,sbit6		; nio bokst„ver
	bne	.hopp12
	move.w	#2,bombs		; alla bomber
	move.w	#$7,nuvarande_pal
	move.w	#0,sbit6
.hopp11:
	move.w	#0,sbit6
.hopp12:
	move.l	#fusk7,a0
	move.w	sbit7,d0
	move.b	(a0,d0),d0
	cmp.b	d1,d0
	bne	.hopp13
	addq.w	#1,sbit7		; Kommer ett steg l„ngre
	cmp.w	#6,sbit7		; sex bokst„ver
	bne	.hopp14
	move.w	#1,killed		; d”d
	move.w	#0,sbit7
.hopp13:
	move.w	#0,sbit7
.hopp14:
	move.l	#fusk8,a0
	move.w	sbit8,d0
	move.b	(a0,d0),d0
	cmp.b	d1,d0
	bne	.hopp15
	addq.w	#1,sbit8		; Kommer ett steg l„ngre
	cmp.w	#8,sbit8		; †tta bokst„ver
	bne	.hopp16
	tst.w	times_up
	bne.s	.hopp16
	move.w	#30*56,mincnt+2	; tid
	move.w	#0,sbit8
.hopp15:
	move.w	#0,sbit8
.hopp16:
	move.w	#$0,nuvarande_pal
.rts	rts

* +-*********************************************************************-+
* | Timesup	                                                      |
* * Fixar s† att den lilla SubStationen spr„ngs i luften       / /        *
* * Av Mikael Emtinger 1995                                   /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-
time_slut
	tst.w	times_up
	bgt.s	.go_baby

	cmp.l	#0,mincnt
	bgt.s	.skip
	cmp.l	#30*56,sekcnt
	ble.s	.set
.skip	rts
.set	move.w	#30*50,times_up
	rts

.go_baby	sub.w	#1,times_up

	cmp.w	#30*50-1,times_up
	bne	.ej_start

	lea	stat_prefs,a0
	move.w	#3-1,(a0)+	; antal
	move.w	#2000,(a0)+	; x
	move.w	#2000,(a0)+	; z
	move.w	#15-18,(a0)+	; num
	move.w	#0,(a0)+		; chan
	move.w	#2000,(a0)+	; x
	move.w	#2000,(a0)+	; z
	move.w	#15-18,(a0)+	; num
	move.w	#1,(a0)+		; chan
	move.w	#2000,(a0)+	; x
	move.w	#2000,(a0)+	; z
	move.w	#15-18,(a0)+	; num
	move.w	#2,(a0)+		; chan
	jsr	init_statsound
	move.w	#17,d0
	jsr	do_mess
.ej_start

	cmp.w	#20*50,times_up
	bne.s	.ej_starw
	move.w	#1,warning
	move.w	#17,d0
	jsr	do_mess
.ej_starw
	cmp.w	#1,times_up
	beq.s	.endit
	rts

.endit	move.l	#.exp_vbi,$70.w
	move.l	s118,$118.w
	jsr	vsync

;-------- Ner till svart --------

	move.w	#40-1,d7
.fade_lp1	move.w	d7,-(sp)
	add.w	#15,stat_vol	; minska ljudet
	cmp.w	#511,stat_vol
	blt.s	.nore
	move.w	#511,stat_vol
.nore
	lea	nuvarande_pal,a0	; pal att f„jda fr†n
	lea	svart_pal,a1	; pal att f„jda till
	moveq	#16-1,d0		; antal f„rger
	jsr	paltopal
	lea	panpal,a0		; pal att f„jda fr†n
	lea	svart_pal,a1	; pal att f„jda till
	moveq	#16-1,d0		; antal f„rger
	jsr	paltopal
	jsr	vsync
	jsr	vsync
	move.w	(sp)+,d7
	dbf	d7,.fade_lp1

	jsr	reset_mfp
	
;-------- Upp till vitt --------

	lea	stat_prefs,a0
	move.w	#3-1,(a0)+	; antal
	move.w	#2000,(a0)+	; x
	move.w	#2000,(a0)+	; z
	move.w	#10-18,(a0)+	; num
	move.w	#0,(a0)+		; chan
	move.w	#2000,(a0)+	; x
	move.w	#2000,(a0)+	; z
	move.w	#05-18,(a0)+	; num
	move.w	#1,(a0)+		; chan
	move.w	#2000,(a0)+	; x
	move.w	#2000,(a0)+	; z
	move.w	#10-18,(a0)+	; num
	move.w	#2,(a0)+		; chan
	jsr	init_statsound

	move.w	x_gubbe,d2
	move.w	z_gubbe,d3
	move.w	#0,look_angle
	add.w	#511,d3

	move.w	#50-1,d7
.fade_lp2
	cmp.w	#30,d7
	blt.s	.dra_ner
	sub.w	#30,stat_vol	; minska ljudet
	tst.w	stat_vol
	bgt.s	.dra_upp
	move.w	#0,stat_vol
	bra	.dra_upp

.dra_ner	add.w	#30,stat_vol	; minska ljudet
	cmp.w	#511,stat_vol
	blt	.ljd_ett
	move.w	#512,stat_vol
	bra	.ljd_ett
.dra_upp
	sub.w	#15,d3
	
	tst.w	.exp_flg
	bne.s	.ljd_tva
	move.w	#1,.exp_flg
	lea	sound_board,a0	; starta sampling
	move.w	(a0),d0
	add.w	#1,(a0)+
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,a0
	move.w	d2,(a0)+		; x
	move.w	d3,(a0)+		; z
	move.w	#10,(a0)+		; ljud nr
	bra	.ljd_ett

.ljd_tva	move.w	#0,.exp_flg
	lea	sound_board,a0	; starta sampling
	move.w	(a0),d0
	add.w	#1,(a0)+
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,a0
	move.w	d2,(a0)+		; x
	move.w	d3,(a0)+		; z
	move.w	#5,(a0)+		; ljud nr
.ljd_ett
	movem.w	d2-d3/d7,-(sp)

	moveq	#0,d6
	move.w	d7,d6
	divu	#10,d6
	swap	d6
	tst.w	d6
	bne	.ej_stat

	lea	stat_prefs,a0
	move.w	#3-1,(a0)+	; antal
	move.w	#2000,(a0)+	; x
	move.w	#2000,(a0)+	; z
	move.w	#10-18,(a0)+	; num
	move.w	#0,(a0)+		; chan
	move.w	#2000,(a0)+	; x
	move.w	#2000,(a0)+	; z
	move.w	#05-18,(a0)+	; num
	move.w	#1,(a0)+		; chan
	move.w	#2000,(a0)+	; x
	move.w	#2000,(a0)+	; z
	move.w	#10-18,(a0)+	; num
	move.w	#2,(a0)+		; chan
	jsr	init_statsound
.ej_stat
	lea	nuvarande_pal,a0	; pal att f„jda fr†n
	lea	vit_pal,a1	; pal att f„jda till
	moveq	#16-1,d0		; antal f„rger
	jsr	paltopal
	jsr	vsync
	jsr	vsync
	jsr	vsync
	movem.w	(sp)+,d2-d3/d7
	dbf	d7,.fade_lp2

	jmp	end

.exp_vbi	clr.b	$fffffa1b.w
	move.b	#159,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.w	#0,pnlflag
	addq.w	#1,vflag

	movem.l	d0-d7/a0-a6,-(sp)

	movem.l	nuvarande_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	tst.w	hostconn
	beq.s	.no_midi
	jsr	host_start
.no_midi
	IFEQ	DD
	jsr	dd_audio			; g”r ljudet
	jsr	sound_rout		; play dd-audio
	ENDC

	movem.l	(sp)+,d0-d7/a0-a6
	rte

.exp_flg	dc.w	0

* +-*********************************************************************-+
* | Quit yes/no	                                                      |
* * Fr†gar om man vill avsluta detta fina spel!                / /        *
* * Av Oskar Burman 1995                                      /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-+
escrut
	tst.w	escflg
	beq	.rts

	move.l	$70,-(sp)
	move.l	#.escvbi,$70.w

	move.l	#quit,a0
	move.l	screen+4,a1
	add.w	#160*70+40,a1

	move.w	#17,d3
.drawquit
	move.w	#7,d2
.draw2
	move.w	(a0)+,d1
	move.w	d1,d0
	or.w	(a0),d1
	or.w	d1,(a1)+
	or.w	d1,(a1)+
	or.w	d1,(a1)+
	not.w	d0
	and.w	d0,(a1)
	move.w	(a0)+,d1
	or.w	d1,(a1)+
	dbf.w	d2,.draw2
	lea	160-8*8(a1),a1
	dbf.w	d3,.drawquit

	move.w	#0,q_stat

.wait_key	tst.w	q_stat
	beq	.wait_key

	cmp.w	#1,q_stat
	beq	end

	move.w	#0,q_stat
	move.w	#0,escflg

	move.l	(sp)+,$70.w	
.rts
	rts
.escvbi
	clr.b	$fffffa1b.w
	move.b	#159,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.w	#0,pnlflag
	addq.w	#1,vflag

	movem.l	d0-d7/a0-a6,-(sp)

	movem.l	nuvarande_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	tst.w	midi_on
	beq.s	.no_midi
	jsr	ud_midi
	tst.w	hostconn
	beq.s	.no_midi
	jsr	host_start
.no_midi

	IFEQ	DD
	jsr	dd_audio			; g”r ljudet
	jsr	sound_rout		; play dd-audio
	ENDC

	move.w	#0,q_stat
	jsr	s„tt_flag

	movem.l	(sp)+,d0-d7/a0-a6
	rte

* +-*********************************************************************-+
* | Du „r d”d rutinen                                                     |
* * Kommer hit efter mainloopen och tar ”ver den               / /        *
* * Av Mikael Emtinger 1995                                   /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-
you_are_dead
	tst.w	killed
	bne.s	.yep
	rts
.yep
	tst.w	midi_on		; testa midi
	beq.s	.no_mi6
	moveq	#8,d0
	jsr	midi_send	
.no_mi6
	move.w	#0,health
	move.w	#0,.flg
	
	lea	sound_board,a0	; starta sampling
	move.w	(a0),d0
	add.w	#1,(a0)+
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,a0
	move.l	x_gubbe,(a0)+	; xz
	move.w	#7,(a0)+		; ljud nr

	jsr	ud_panel

	move.l	#.slut_vb1,$70.w
	move.l	s118,$118.w

	move.w	#0,.counter
.minimai1	jsr	set_screen

	add.w	#10,stat_vol
	cmp.w	#512,stat_vol
	blt.s	.noppa1
	move.w	#512,stat_vol
.noppa1

	lea	nuvarande_pal,a0	; pal att f„jda fr†n
	lea	skada_pal,a1	; pal att f„jda till
	moveq	#16-1,d0		; antal f„rger
	jsr	paltopal

	lea	panpal,a0
	lea	skada_pal,a1
	moveq	#16-1,d0
	jsr	paltopal

	move.w	#3,d0		; ant vbl att v„nta
	jsr	vsync2

	add.w	#1,.counter
	cmp.w	#50,.counter
	bne.s	.minimai1

;----- Ner till svart igen -----

	move.w	#1,.flg	
	jsr	reset_mfp
	jsr	change_screen
	jsr	vsync
	move.l	screen,a0
	move.w	#8000-1,d7
.renso	move.l	#0,(a0)+
	dbf	d7,.renso
	jsr	change_screen
	jsr	vsync

	move.w	#0,.counter
.minimai2	jsr	set_screen2

	add.w	#10,stat_vol
	cmp.w	#512,stat_vol
	blt.s	.noppa2
	move.w	#512,stat_vol
.noppa2

	lea	nuvarande_pal,a0	; pal att f„jda fr†n
	lea	svart_pal,a1	; pal att f„jda till
	moveq	#16-1,d0		; antal f„rger
	jsr	paltopal

	lea	panpal,a0
	lea	svart_pal,a1
	moveq	#16-1,d0
	jsr	paltopal

	move.w	#3,d0		; ant vbl att v„nta
	jsr	vsync2

	add.w	#1,.counter
	cmp.w	#50,.counter
	bne.s	.minimai2

	bra	end

.slut_vb1	tst.w	.flg
	bne.s	.ej_timer
	clr.b	$fffffa1b.w
	move.b	#159,$fffffa21.w
	move.b	#8,$fffffa1b.w
.ej_timer
	move.w	#0,pnlflag
	addq.w	#1,vflag

	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	nuvarande_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	IFEQ	DD
	jsr	dd_audio			; g”r ljudet
	jsr	sound_rout		; play dd-audio
	ENDC
	movem.l	(sp)+,d0-d7/a0-a6
	rte

.counter	ds.w	1
.flg	ds.w	1

* +-*********************************************************************-+
* | Klarat av banan sekvensen                                             |
* * G”r s† man hoppar ur spelet                                / /        *
* * Av Mikael Emtinger 1995                                   /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-
you_exit
	tst.w	exit_flg
	bne.s	.yep
	rts
.yep
	move.l	#.exit_vbi,$70.w
	move.l	s118,$118.w

;-------- V„nta ett tag --------

	move.w	#0,.counter
	jsr	make_3dworld		; g”r v„ggar,sprite:ar och v„nder
	jsr	ud_panel
	jsr	change_screen
.wait	jsr	vsync
	jsr	vsync
	jsr	vsync
	add.w	#1,.counter
	cmp.w	#18,.counter
	bne.s	.wait

;-------- Ner till svart --------

	move.w	#0,.counter
.minimai2	jsr	set_screen2

	add.w	#20,stat_vol
	cmp.w	#512,stat_vol
	blt.s	.noppa1
	move.w	#512,stat_vol
.noppa1
	lea	nuvarande_pal,a0	; pal att f„jda fr†n
	lea	svart_pal,a1	; pal att f„jda till
	moveq	#16-1,d0		; antal f„rger
	jsr	paltopal
	lea	panpal,a0
	lea	svart_pal,a1
	moveq	#16-1,d0
	jsr	paltopal

	move.w	#3,d0		; ant vbl att v„nta
	jsr	vsync2

	add.w	#1,.counter
	cmp.w	#50,.counter
	bne.s	.minimai2

	bra	end

.exit_vbi
	clr.b	$fffffa1b.w
	move.b	#159,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.w	#0,pnlflag
	addq.w	#1,vflag

	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	nuvarande_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	IFEQ	DD
	jsr	dd_audio			; g”r ljudet
	jsr	sound_rout		; play dd-audio
	ENDC
	movem.l	(sp)+,d0-d7/a0-a6
	rte

.counter	ds.w	1

* +-*********************************************************************-+
* | Hoppa ur rutinen                                                      |
* * St„ller tillbaka det mesta hoppas jag                      / /        *
* * Av Mikael Emtinger 1995                                   /   /       *
* *                                                          /   /        *
* *                                                          \__/         *
* | ui - MainRutin                                                        |
* +-*********************************************************************-+
end
	move.w	#0,$ffff8900.w		Stoppar ljudchippet
	jsr	reset_mfp
	move.l	s118,$118.w
	move.l	svbi,$70.w

end2	movem.l	savepal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.w	#$777,$ff8240
	move.w	#$000,$ff8242

	move.l	#reset_ikbd_instr,-(sp)	; resetta IKBD:n
	move.w	#2-1,-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	
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

	move.l	save_sp,sp
	
	clr.w	-(sp)
	trap	#1
	
;--------------------------------------------------------------------------
; VBI rutiner och vsync rutiner
;--------------------------------------------------------------------------
; ui
vbi	move.w    #$2700,sr		; patchar f”r dubbelvbl
	tst.w     in_vbl			; p† falken
	beq	exitdd
	clr.w     in_vbl
	move.w    #$2300,sr

	clr.b	$fffffa1b.w
	move.b	#159,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.w	#0,pnlflag
	move.w	#0,gfx_flg
	addq.w	#1,vflag

	movem.l	d0-d7/a0-a6,-(sp)

	tst.w	warning
	bne	do_warning
	tst.w	stor_pal
	bne	do_stor_pal
back_wa
	movem.l	nuvarande_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	tst.w	midi_on
	beq.s	.no_midi
	jsr	ud_midi
	tst.w	hostconn
	beq.s	.no_midi
	jsr	host_start
.no_midi
	jsr	time_slut			; kolla om tiden „r slut
	jsr	styr			; styr
	jsr	cheat_hand		; kolla om man fuskar

	IFEQ	DD
	jsr	dd_audio			; g”r ljudet
	jsr	sound_rout		; play dd-audio
	ENDC

	tst.w	midi_on
	bne.s	.no_movef
	jsr	move_fi			; flytta fiende
.no_movef
	jsr	time_ud			; uppdatera tiden
	jsr	cd_ud			; uppdatera countdown
	jsr	ud_mess			; uppdatera medelanden
	jsr	ud_lock			; uppdatera location

	jsr	prepare_panel		; uppdatera weapons mm
	movem.l	(sp)+,d0-d7/a0-a6

exitdd	move.w    #-1,in_vbl
	rte

midisvbi	add.w	#1,vflag
	rte
	
vsync	tst.w	vflag
	beq.s	vsync
	move.w	#0,vflag
	rts

vsync2	cmp.w	vflag,d0		; d0 = parameter f”r antal vbi
	bgt.s	vsync2
	clr.w	vflag
	rts
	
;--------------------------------------------------------------------------
; Screensetter rutiner och screen swaprutiner
;--------------------------------------------------------------------------
; ui
change_screen
	movem.l	d0-d1,-(sp)
	move.l	screen+0,d0
	move.l	screen+4,d1
	move.l	d1,screen+0
	move.l	d0,screen+4
	movem.l	(sp)+,d0-d1

	move.w	#1,ritat_f„rdigt
	add.b	#137,slump
	
set_screen
	move.b	screen+1+4,$ffff8201.w
	move.b	screen+2+4,$ffff8203.w
	move.b	screen+3+4,$ffff820d.w
	rts

set_screen2
	move.b	screen+4+1,$ffff8201.w
	move.b	screen+4+2,$ffff8203.w
	move.b	screen+4+3,$ffff820d.w
	rts

;--------------------------------------------------------------------------
; Olika include rutiner
;--------------------------------------------------------------------------
; ui
			include	'e:\substatn\ai\ny_ai6.s'
			include	'e:\substatn\panel\panelinc.s'
			include	'e:\substatn\midi\midi_inc.s'
			include	'e:\substatn\gouraud\poly___9.s'
			IFEQ	DD
			include	'e:\substatn\dd_audio\dd_audi6.s'
			ENDC
			IFEQ	SPR
			include	'e:\substatn\sprite\sub_zoom.s'
			ENDC

			section	data
;--------------- Olika incbins och includes -------------------------------

sin_360			include	'e:\substatn\data\sin_360.inc'
asin			include	'e:\substatn\data\asin4096.inc'
splbank			incbin	'e:\substatn\dd_audio\alw_ljud.sbk'
tak_golv			incbin	'e:\substatn\grafik\tak.img'
statspr_blk		incbin	'e:\substatn\grafik\statobj.spr'
quit			incbin	'e:\substatn\grafik\quit.pic'

ladda_namn		dc.b	'e:\bana\wow\testbana.wow',0
			even
bana			dcb.l	180100/4,0

;--------------- Vapen filerna (.dwc och .bmp) ----------------------------

dwc_0_1			incbin	'e:\substatn\panel\bin\dwc_1_1.bin'
dwc_0_2			incbin	'e:\substatn\panel\bin\dwc_1_2.bin'
dwc_0_3			incbin	'e:\substatn\panel\bin\dwc_1_3.bin'
bmp_0_1			incbin	'e:\substatn\panel\bin\bmp_1_1.bin'
bmp_0_2			incbin	'e:\substatn\panel\bin\bmp_1_2.bin'
bmp_0_3			incbin	'e:\substatn\panel\bin\bmp_1_3.bin'

dwc_1_1			incbin	'e:\substatn\panel\bin\dwc_2_1.bin'
dwc_1_2			incbin	'e:\substatn\panel\bin\dwc_2_2.bin'
dwc_1_3			incbin	'e:\substatn\panel\bin\dwc_2_3.bin'
bmp_1_1			incbin	'e:\substatn\panel\bin\bmp_2_1.bin'
bmp_1_2			incbin	'e:\substatn\panel\bin\bmp_2_2.bin'
bmp_1_3			incbin	'e:\substatn\panel\bin\bmp_2_3.bin'

dwc_2_1			incbin	'e:\substatn\panel\bin\dwc_3_1.bin'
dwc_2_2			incbin	'e:\substatn\panel\bin\dwc_3_2.bin'
dwc_2_3			incbin	'e:\substatn\panel\bin\dwc_3_3.bin'
bmp_2_1			incbin	'e:\substatn\panel\bin\bmp_3_1.bin'
bmp_2_2			incbin	'e:\substatn\panel\bin\bmp_3_2.bin'
bmp_2_3			incbin	'e:\substatn\panel\bin\bmp_3_3.bin'

dwc_3_1			incbin	'e:\substatn\panel\bin\dwc_4_1.bin'
dwc_3_2			incbin	'e:\substatn\panel\bin\dwc_4_2.bin'
dwc_3_3			incbin	'e:\substatn\panel\bin\dwc_4_3.bin'
bmp_3_1			incbin	'e:\substatn\panel\bin\bmp_4_1.bin'
bmp_3_2			incbin	'e:\substatn\panel\bin\bmp_4_2.bin'
bmp_3_3			incbin	'e:\substatn\panel\bin\bmp_4_3.bin'

dwc_4_1			incbin	'e:\substatn\panel\bin\dwc_5_1.bin'
dwc_4_2			incbin	'e:\substatn\panel\bin\dwc_5_2.bin'
dwc_4_3			incbin	'e:\substatn\panel\bin\dwc_5_3.bin'
bmp_4_1			incbin	'e:\substatn\panel\bin\bmp_5_1.bin'
bmp_4_2			incbin	'e:\substatn\panel\bin\bmp_5_2.bin'
bmp_4_3			incbin	'e:\substatn\panel\bin\bmp_5_3.bin'

dwc_5_1			incbin	'e:\substatn\panel\bin\dwc_6_1.bin'
dwc_5_2			incbin	'e:\substatn\panel\bin\dwc_6_2.bin'
dwc_5_3			incbin	'e:\substatn\panel\bin\dwc_6_3.bin'
bmp_5_1			incbin	'e:\substatn\panel\bin\bmp_6_1.bin'
bmp_5_2			incbin	'e:\substatn\panel\bin\bmp_6_2.bin'
bmp_5_3			incbin	'e:\substatn\panel\bin\bmp_6_3.bin'

vapen_listor	dc.l	vapen_config1,vapen_config2,vapen_config3

vapen_config1	dc.l	dwc_0_1,bmp_0_1	; vapen 0 anim 1
		dc.l	dwc_1_1,bmp_1_1	; vapen 1 anim 1
		dc.l	dwc_2_1,bmp_2_1	; vapen 2 anim 1
		dc.l	dwc_3_1,bmp_3_1	; vapen 3 anim 1
		dc.l	dwc_4_1,bmp_4_1	; vapen 4 anim 1
		dc.l	dwc_5_1,bmp_5_1	; vapen 5 anim 1

vapen_config2	dc.l	dwc_0_2,bmp_0_2	; vapen 0 anim 2
		dc.l	dwc_1_2,bmp_1_2	; vapen 1 anim 2
		dc.l	dwc_2_2,bmp_2_2	; vapen 2 anim 2
		dc.l	dwc_3_2,bmp_3_2	; vapen 3 anim 2
		dc.l	dwc_4_2,bmp_4_2	; vapen 4 anim 2
		dc.l	dwc_5_2,bmp_5_2	; vapen 5 anim 2

vapen_config3	dc.l	dwc_0_3,bmp_0_3	; vapen 0 anim 3
		dc.l	dwc_1_3,bmp_1_3	; vapen 1 anim 3
		dc.l	dwc_2_3,bmp_2_3	; vapen 2 anim 3
		dc.l	dwc_3_3,bmp_3_3	; vapen 3 anim 3
		dc.l	dwc_4_3,bmp_4_3	; vapen 4 anim 3
		dc.l	dwc_5_3,bmp_5_3	; vapen 5 anim 3

har_vapen		dc.w	1,1,0,0,0,0,0,0,0
skad_vapen	dc.w	SKADA0,SKADA1,SKADA2,SKADA3,SKADA4,SKADA5
ammo_vapen	dc.w	0,48,100,48,100,20
ansp_vapen	dc.w	ANSP0,ANSP1,ANSP2,ANSP3,ANSP4,ANSP5
rept_vapen	dc.w	REPT0,REPT1,REPT2,REPT3,REPT4,REPT5
ljud_vapen	dc.w	0,1,2,4,3,5

har_nyckel	dc.w	0,0,0,0
har_map		dc.w	0
„ndrat_vapen	dc.w	0

;--------------- Ljudrutinens variabler och inst„llningar -----------------

splbank_adr2		dc.l	-1	; adr buffert 2 (buffer1=splbank)
stat_prefs		ds.w	1+4*3	; buf f”r statiska ljud
stat_vol			dc.w	300	; totstatiska ljuds volym

;--------------- Fiende rutinens data -------------------------------------

maps			dc.l	0
fi_data			dc.l	0

;--------------- Sprite data (y,bredd,h”jd,BPPadr) ------------------------

sprite_config		dc.w	52-17		; v„rld-y
			dc.l	0		; medikit
			dc.b	0,0  ;---------	; kan man g† igenom? (0=ja, 1=nej), spegelv„nd? (0=nej 1=ja)
			dc.w	52-13
			dc.l	0		; food
			dc.b	0,0  ;---------
			dc.w	52-17
			dc.l	0		; superkit
			dc.b	0,0  ;---------
			dc.w	52-17
			dc.l	0		; subgun
			dc.b	0,0  ;---------
			dc.w	52-13
			dc.l	0		; booster
			dc.b	0,0  ;---------
			dc.w	52-13
			dc.l	0		; xxxx
			dc.b	0,0  ;---------
			dc.w	52-15
			dc.l	0		; blaster
			dc.b	0,0  ;---------
			dc.w	52-10
			dc.l	0		; ammopistol
			dc.b	0,0  ;---------
			dc.w	52-18
			dc.l	0		; ammo xxxx
			dc.b	0,0  ;---------
			dc.w	52-17
			dc.l	0		; ammoblaster
			dc.b	0,0  ;---------
			dc.w	52-13
			dc.l	0		; bomb1
			dc.b	0,0  ;---------
			dc.w	52-6
			dc.l	0		; redkey
			dc.b	0,0  ;---------
			dc.w	52-6
			dc.l	0		; yellowkey
			dc.b	0,0  ;---------
			dc.w	52-6
			dc.l	0		; greenkey
			dc.b	0,0  ;---------
			dc.w	52-24
			dc.l	0		; hiss1
			dc.b	0,0  ;---------
			dc.w	52-10
			dc.l	0		; blod
			dc.b	0,0  ;---------
			dc.w	52-30
			dc.l	0		; toa
			dc.b	1,0  ;---------
			dc.w	0
			dc.l	0		; borddata
			dc.b	1,0  ;---------
			dc.w	52-28
			dc.l	0		; bordglas
			dc.b	1,0  ;---------
			dc.w	52-17
			dc.l	0		; box
			dc.b	1,0  ;---------
			dc.w	52-29
			dc.l	0		; tuber
			dc.b	0,0  ;---------
			dc.w	52-11
			dc.l	0		; goggles
			dc.b	0,0  ;---------
			dc.w	52-10
			dc.l	0		; vatten
			dc.b	0,0  ;---------
			dc.w	-10
			dc.l	0		; exit1
			dc.b	0,0  ;---------
			dc.w	-52
			dc.l	0		; kroklik
			dc.b	0,0  ;---------
			dc.w	-48
			dc.l	0		; kamera
			dc.b	0,0  ;---------
			dc.w	-10
			dc.l	0		; kruka
			dc.b	0,0  ;---------
			dc.w	-52
			dc.l	0		; lampa
			dc.b	0,0  ;---------
			dc.w	-52
			dc.l	0		; kedja
			dc.b	0,0  ;---------
			dc.w	0
			dc.l	0		; hiss2
			dc.b	1,0  ;---------
			dc.w	-10
			dc.l	0		; exit2
			dc.b	0,0  ;---------
			dc.w	0
			dc.l	0		; door2
			dc.b	0,0  ;---------
			dc.w	0
			dc.l	0		; door1
			dc.b	0,0  ;---------
			dc.w	0
			dc.l	0		; reddoor2
			dc.b	0,0  ;---------
			dc.w	0
			dc.l	0		; reddoor1
			dc.b	0,0  ;---------
			dc.w	0
			dc.l	0		; yeldoor2
			dc.b	0,0  ;---------
			dc.w	0
			dc.l	0		; yeldoor1
			dc.b	0,0  ;---------
			dc.w	0
			dc.l	0		; gredoor2
			dc.b	0,0  ;---------
			dc.w	0
			dc.l	0		; gredoor1
			dc.b	0,0  ;---------
			dc.w	34
			dc.l	0		; bomb2
			dc.b	0,0  ;---------
			dc.w	-84
			dc.l	0		; boost_skott
			dc.b	0,0  ;---------
			dc.w	10
			dc.l	0		; blast_skott1
			dc.b	0,0  ;---------
			dc.w	10
			dc.l	0		; blast_skott2
			dc.b	0,0  ;---------
			dc.w	5
			dc.l	0		; exp1
			dc.b	0,0  ;---------
			dc.w	7
			dc.l	0		; exp2
			dc.b	0,0  ;---------
			dc.w	9
			dc.l	0		; exp3
			dc.b	0,0  ;---------
			dc.w	0
			dc.l	0		; elevator door1
			dc.b	0,0  ;---------
			dc.w	0
			dc.l	0		; elevator door2
			dc.b	0,0  ;---------

fi_sprite_config		dcb.l	14*4*2,0		; max 4 fi och 15 sprites var

;--------------- Paletter och sk„rmadresser -------------------------------

screen			dc.l	scrblk+256,scrblk+32000+256

nuvarande_pal		dc.w	$000,$888,$999,$222,$AAA,$BBB,$444,$CCC
			dc.w	$200,$551,$810,$1B1,$322,$002,$094,$000

pal			dc.w	$000,$888,$999,$222,$AAA,$BBB,$444,$CCC
			dc.w	$200,$551,$810,$1B1,$322,$002,$094,$000
warn_pal			dc.w	$000,$100,$200,$300,$400,$500,$600,$700
			dc.w	$400,$F00,$A00,$E00,$700,$300,$700,$000
plock_pal			dc.w	$0f0,$0f0,$0f0,$0f0,$0f0,$0f0,$0f0,$0f0
			dc.w	$0f0,$0f0,$0f0,$0f0,$0f0,$0f0,$0f0,$0f0
skada_pal			dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00
			dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00
svart_pal			dc.w	$000,$000,$000,$000,$000,$000,$000,$000
			dc.w	$000,$000,$000,$000,$000,$000,$000,$000
vit_pal			dc.w	$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff
			dc.w	$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff
gogg_pal			dc.w	$000,$080,$010,$898,$121,$232,$ABA,$343
			dc.w	$880,$B71,$0A0,$151,$A42,$080,$0B3,$000


;--------------- Ljud Effekts variabler -----------------------------------

sound_board		dc.w	0		; antal ljudeffekter
			REPT	15
			dc.w	0,0,0		; x,z,ljudnr
			ENDR

;--------------- Lite data till 3d-rutinerna ------------------------------

ant_look			dc.w	1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5
			dc.w	6,6,6,6,6,6,6,6
			dcb.w	76,7
			dc.w	6,6,6,6,6,6,6,6
			dc.w	5,5,5,5,5,5,5,5,4,4,4,4,4,4,4,4,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

;--------------- Olika drivers variabler ----------------------------------

go_hemlig			dc.w	0,0,0,0
last_door			dc.l	0
akt_d_adr			dcb.l	ANT_DOOR+1,0
explosion_adr		dcb.l	ANT_EXP+1,0
aktiva_skott		dc.l	0
go_goggles		dc.w	0

bomb_adr			dcb.l	ANT_BOMB+1,0
v_bmb			REPT	3*5
			dc.w	3		; indik
			dc.w	0,0		; xz
			dc.w	0		; sprite nr
			dc.w	-2		; counter
			ENDR
virt_bmb_adr		dc.l	v_bmb+10*0	; midi player 0 bmb
			dc.l	v_bmb+10*1
			dc.l	v_bmb+10*2
	
			dc.l	v_bmb+10*3	; midi player 1 bmb
			dc.l	v_bmb+10*4
			dc.l	v_bmb+10*5
			
			dc.l	v_bmb+10*6	; midi player 2 bmb
			dc.l	v_bmb+10*7
			dc.l	v_bmb+10*8

			dc.l	v_bmb+10*9	; midi player 3 bmb
			dc.l	v_bmb+10*10
			dc.l	v_bmb+10*11

bombs			dc.w	2
			dc.l	v_bmb+10*12	; player bmb
			dc.l	v_bmb+10*13
			dc.l	v_bmb+10*14

fusk1:			dc.b	"KFTVT"		; Skj. Medikit
			even
sbit1			ds.w	1
fusk2:			dc.b	"OJSWBOB"		; Health
			even
sbit2			ds.w	1
fusk3:			dc.b	"QVOL"		; Vapen+ammo
			even
sbit3			ds.w	1
fusk4:			dc.b	"QGMPZE"		; Nycklar
			even
sbit4			ds.w	1
fusk5:			dc.b	"JELGB"		; Drunkmode
			even
sbit5			ds.w	1
fusk6:			dc.b	"PCTFTTJPO"	; 3 bomber
			even
sbit6			ds.w	1
fusk7:			dc.b	"VETLGB"		; d”d
			even
sbit7			ds.w	1
fusk8:			dc.b	"GBMVLPSW"	; tid
			even
sbit8			ds.w	1

;--------------- IKBD instruktions data -----------------------------------

musoff_ikbd_instr		dc.b	$12
reset_ikbd_instr		dc.b	$80,$01

			section	bss

;--------------- Globala variabler ----------------------------------------

scrblk			ds.l	2*8000+256
ustk			ds.l	1
oldphys			ds.l	1
oldlog			ds.l	1
oldrez			ds.l	1
svbi			ds.l	1
s118			ds.l	1
save_sp			ds.l	1
savepal			ds.w	16
vflag			ds.w	1
in_vbl      		ds.w	1
gfx_flg			ds.w	1
midi_on			ds.w	1
detalj			ds.w	1

;--------------- Gubbvariabler --------------------------------------------

play_indikator		ds.w	1	; indk f”r gubben
x_gubbe			ds.w	1
z_gubbe			ds.w	1
look_angle		ds.w	1
look_angle2		ds.w	1
skjut			ds.w	1
fi_alarm			ds.w	1
health			ds.w	1
killed			ds.w	1
ammo			ds.w	1
bytt_sublev		ds.w	1
sublev			ds.w	1
oldsublev			ds.w	1
ant_sublev		ds.w	1
vilket_vapen		ds.w	1
vilken_anim_vapen		ds.w	1
vapen_skada		ds.w	1
ladda_om_flg		ds.w	1
chg_flg			ds.w	1
straf_angle		ds.w	1
spring			ds.w	1
straf			ds.w	1
fram			ds.w	1
v„nster			ds.w	1
h”ger			ds.w	1
bak†t			ds.w	1
straf_left		ds.w	1
straf_right		ds.w	1
space			ds.w	1
skjut_adr			ds.w	3
skj_flg			ds.w	1
warning			ds.w	1
stor_pal			ds.w	1
bomb_lagd			ds.w	1
escflg			ds.w	1
exit_flg			ds.w	1
times_up			ds.w	1
q_stat			ds.w	1
c_teck			ds.w	1
drunkmode			ds.w	1
richo_flg			ds.w	3 

ritat_f„rdigt		ds.w	1
tajma_vapen		ds.w	1

;--------------- 3D-listor och 3D-variabler -------------------------------

num_points		ds.w	1
num_obj			ds.w	1
num_obj2			ds.w	1
num_sprites		ds.w	1
sqr_list			ds.l	1024
datalist			ds.w	4*32*32	; „ndra INTE ordningen p†
flyg_skott_buf		ds.w	32*16	; dessa listor, eftersom
spelar_buffer		ds.w	48*4	; den spelar roll
			ds.w	8*180
look_cord			ds.w	8*360
adr_points		ds.l	101
xz_points			ds.w	101*2
xyz_wall_points		ds.w	101*3
xyz_sprite_points		ds.w	101*3
dz_points			ds.w	101
xz_connect		ds.w	101
adrmap			ds.l	32*32*4	; 4 adr per sr
adr_matris		ds.b	32*32	; en byte per sr
bytemap_0			ds.l	1	; adr=>walldata
bytemap_1			ds.l	1	; adr=>connectdata
bytemap_2			ds.l	1	; adr=>locationdata
bytemap_3			ds.l	1	; adr=>eventdata
sprite_clipp_buffer		ds.w	15*2*ANT_SPR
sprite_adr_buffer		ds.l	ANT_SPR*2+1
var_spr_adr		ds.l	1
var_spr_clipp		ds.l	1
list1			ds.l	560	; persplistor
list2			ds.w	676
credits:			ds.w	0
ENDLAB
		end

