*	Senast uppdaterad 950430

START_SPRITE		EQU	48
SPRITE_ANIMATIONER	EQU	14
MAX_LJUD_I_SOUND_BOARD	EQU	20
SIKT_STRACKA		EQU	64*6*64*6 ; Den strÑckan som fi kan se.
HAR_STRACKA		EQU	64*4*64*4 ; Den strÑckan som fi kan hîra.
EVENT_STRACKA		EQU	64*4*64*4 ; Den strÑckan som eventet nÜr.
BIT_AVST		EQU	70*70	  ; Den strÑckan som 'bitet' nÜr.
VAKEN_TID		EQU	25*12	  ; Den tid som fi Ñr vaken(larm)
FLY_TID			EQU	25*12	  ; Den tid som fi flyr
FI_MAX_SHOOT_WAIT	EQU	20	  ; Vad skall nedrÑkningen bîrja pÜ
TJOCKLEK		EQU	16*32	  ; Gubbens tjocklek

;--------------------------------------------------------------------------
;			     Tar reda pÜ antalet fi
;--------------------------------------------------------------------------
ant_fiende:
	move.l	fi_data,a0
	move.w	12(a0),d0
	cmp.w	#1,ant_sublev
	blt	.rts
	add.w	(a0),a0
	add.w	8(a0),d0
	cmp.w	#2,ant_sublev
	blt	.rts
	move.l	fi_data,a0
	add.w	2(a0),a0
	add.w	8(a0),d0
.rts	
	move.w	d0,ant_fi
	rts
;--------------------------------------------------------------------------
;				Initiering av Fi
;--------------------------------------------------------------------------
init_av_fi:

*	Fixxa till IX,IY +m.m om det Ñr en vakt och
*	lÑgg in Fi's adress(Adressen till adressmappen) i 56+2(a0) och
*	i adrmap.

	jsr	.init_sublevel

	jsr	.plot_fi

	move.b	$fff820d,slump	; Lite slump in i slump

	rts

*****************************************
*	Initieringen av en sublevel	*
*****************************************
.init_sublevel:
	movem.l	d0-d7/a0-a6,-(sp)

	move.l	fi_data,a0
	tst.w	sublev
	bne	.hîjdhopp
	add.w	#4,a0		; A0 pekar pÜ rÑtt sublevel
	bra	.hîjdhopp2
.hîjdhopp:
	move.w	sublev,d0
	subq.w	#1,d0
	add.w	d0,d0
	add.w	(a0,d0),a0	; A0 pekar pÜ rÑtt sublevel
.hîjdhopp2:
	move.w	8(a0),enemies
	move.l	a0,fi_data_subl
	add.w	2(a0),a0	; A0 pekar mot fi infon

	move.w	enemies,d0
	subq.w	#1,d0		; RÑtta till
	bmi	.end		; Inga fiender, hoppa ur
.loop:

	cmp.w	#3,(a0)
	beq	.next_fi

	move.w	0+2(a0),d6
	asr.w	#4,d6		; X
	asr.w	#6,d6		; /64
	move.w	2+2(a0),d7
	asr.w	#4,d7		; Y
	asr.w	#6,d7		; /64
	asl.w	#5,d7		; *32	; (LO)
	add.w	d6,d7		; X+Y*32
	move.w	d7,d3		; Utan uppgÜngring i d3
	asl.w	#4,d7		; *4*4

	move.l	#adrmap,a1

	move.l	(a1,d7),d4
	beq	.rut_tom	; Lo 1 tom=vi slipper kolla dîrr i rutan
	addq.w	#4,d7
	tst.l	(a1,d7)		; +4
	beq	.tomrum
	addq.w	#4,d7
	tst.l	(a1,d7)		; +8
	beq	.tomrum
	addq.w	#4,d7

.tomrum:

	move.l	d4,a4		; D4 bîr innehÜlla en adress nu.
	cmp.w	#2,(a4)		; Kolla efter dîrr
	bne	.rut_tom	; hoppa îver îppna dîrr rutinen

	lea	akt_d_adr,a5
	move.w	#ANT_DOOR-1-1,d4	; max antal dîrrar samtidigt=ANT_DOOR (-1 fîr att om alla Ñr upptagna sÜ skrivs sista îver)
.chkadr1
	cmp.l	(a5),a4
	beq.s	.open
	cmp.l	#0,(a5)
	beq.s	.put_adr
	addq.l	#4,a5
	dbf	d4,.chkadr1

	move.l	a4,(a5)
	bra.s	.open
	
.put_adr
	move.l	a4,(a5)+
	subq.w	#1,d4
	blt.s	.open

.chkadr2
	cmp.l	(a5),a4
	bne.s	.nollej
	move.l	#0,(a5)
.nollej	addq.l	#4,a5
	dbf	d4,.chkadr2
.open

*	Slut pÜ îppnadîrr rutinen

.rut_tom		; knalla in i rutan

	add.w	d7,a1
	move.l	a1,56+2(a0)	; adressmaps adressen in i PRE_LO
	move.l	a0,(a1)	 	; A(ADDR*4)=adressen till fi (D7 redan adderad)
	move.w	d3,20+2(a0)	; Flytta in ADDR i ADDR_FI

	cmp.w	#1,8+2(a0)
	bne	.hopp
	move.w	14+2(a0),d6	; PP
	move.w	12+2(a0),d7	; NP
	movem.l	d0/a0,-(sp)
	jsr	.init_vakt	; Initiera om det Ñr en vakt. Initierings rutinen Ñr en stor del av NY_SLUTPUNKT rutinen

	movem.l	(sp)+,d0/a0
.hopp:

.next_fi:
	add.w	#82,a0
	dbf.w	d0,.loop

*	Fixxa rÑtt ban adress om det Ñr en fi som fîljer bana.

	move.w	enemies,d0
	subq.w	#1,d0		; RÑtta till
	move.l	fi_data_subl,a0
	add.w	2(a0),a0	; A0 pekar mot fi infon

	move.l	fi_data_subl,a1
	add.w	4(a1),a1	; A1 pekar mot banorna

.ban_fix_loop:
				; Detta kîrs Ñven om fi Ñr dîd. Gîrs inte
	cmp.w	#2,8+2(a0)	; det sÜ hamnar vi nÑmligen snett i ban
	bne	.flopp		; datat.

	move.l	a1,40+2(a0)

.mini_loop:
	tst.w	(a1)+
	bne.s	.mini_loop
.flopp:
	lea	82(a0),a0
	dbf.w	d0,.ban_fix_loop
.end
	movem.l	(sp)+,d0-d7/a0-a6
	rts
*************
* Init vakt *
*************
.init_vakt:
	subq.w	#1,d6		; PP ligger ett steg fîr hîgt
	muls.w	#24,d6		; NÑrmaste 24 steg(12 word)

	move.l	fi_data_subl,a4
	add.w	(a4),a4		; Pekar mot punkt_connection listan
	add.w	d6,a4		; a4 pekar pÜ den punkten som du nu Ñr pÜ

	move.l	fi_data_subl,a6
	add.w	#10,a6

	move.w	#4,w
	tst.w	18(a4)
	bne	.kopp		; 4 punkter runt om
	move.w	#3,w
	tst.w	12(a4)
	bne	.kopp		; 3 punkter runt om
	move.w	#2,w
	tst.w	6(a4)
	bne	.kopp		; 2 punkter runt om
	move.w	#1,w		; 1 punkt runt om
.kopp:

	moveq	#0,d6		; D6=0
	cmp.w	(a4),d7
	beq	.vidare		; Om den nya punkten Ñr samma som fîrsta i OMGIV_PUNKT (E(1)) sÜ Ñr D6=0 och vi hoppar vidare

	moveq	#6,d6		; D6=1
	cmp.w	6(a4),d7
	beq	.vidare		; Om den nya punkten Ñr samma som andra i OMGIV_PUNKT (E(2)) sÜ Ñr D6=6 och vi hoppar vidare

	move.w	#12,d6		; D6=12
	cmp.w	12(a4),d7
	beq	.vidare		; Om den nya punkten Ñr samma som tredje i OMGIV_PUNKT (E(3)) sÜ Ñr D6=12 och vi hoppar vidare

	move.w	#18,d6		; D6=18
	cmp.w	18(a4),d7
	beq	.vidare		; Om den nya punkten Ñr samma som fjÑrde i OMGIV_PUNKT (E(4)) sÜ Ñr D6=18 och vi hoppar vidare

	move.w	#0,d6		; Kommer vi hit har det blivit fel i
				; Mapeditorn och vi lÜter fi titta pÜ
				; punkt nr.1
.vidare:
				; D6 skall vara 0,6,12.....
	move.w	44+2(a0),d2	; Plocka ut farten till D2
	move.w	(a4,d6),12+2(a0)	; LÑgg in den nya punkten i NP
	move.w	2(a4,d6),22+2(a0)	; LÑgg in vinkeln
	move.w	4(a4,d6),d3	; d3 fîrstîrs, blir avstÜnd
	asr.w	d2,d3		; Dra ner pÜ slutsteg (om farten Ñr stor)
	move.w	d3,34+2(a0)	; avstÜndet in i SLUTSTEG
	tst.w	d3

	move.w	12+2(a0),d6	; Nya punkten(NP) i D6
	subq.w	#1,d6
	add.w	d6,d6		; *4 fîr att passa listan
	add.w	d6,d6

	move.w	(a6,d6),d4	; NY_X
	move.w	2(a6,d6),d5	; NY_Y
	move.w	d4,d0		; OBS!Fîrstîr DX!
	move.w	d5,d1		; OBS!Fîrstîr DY!

	move.w	0+2(a0),d6		; X
	lsr.w	#4,d6		; /16
	sub.w	d6,d4		; NY_X-X (DX)
	move.w	2+2(a0),d7	; Y
	lsr.w	#4,d7		; /16
	sub.w	d7,d5		; NY_Y-Y (DY)

	move.w	d4,d6		; DX
	asl.w	#4,d6		; *16
	ext.l	d6
	divs.w	d3,d6		; DX/SLUTSTEG
	move.w	d6,26+2(a0)	; LÑgg in i IX
	
	move.w	d5,d6		DY
	asl.w	#4,d6		; *16
	ext.l	d6
	divs.w	d3,d6		; DY/SLUTSTEG
	move.w	d6,28+2(a0)	; LÑgg in i IY

	move.w	#0,32+2(a0)

	asl.w	#4,d0		; *16
	asl.w	#4,d1		; *16
	move.w	d0,4+2(a0)	; in i SPX
	move.w	d1,6+2(a0)	; in i SPY

	rts
***************************
* Rita fienderna i adrmap *
*************************** 
.plot_fi:

	move.w	enemies,d3
	subq.w	#1,d3
	bmi	.ur			; Inga fi, hoppa ur

	move.l	#adrmap,a3
	move.l	fi_data_subl,a0
	add.w	2(a0),a0		; A0 pekar mot fi infon
.plot_loop:
	cmp.w	#3,(a0)
	bne	.next

	move.w	2(a0),d0
	move.w	4(a0),d1
	lsr.w	#6,d0		; RUTX
	lsr.w	#6,d1		; RUTY
	lsl.w	#5,d1		; D1=RUTY*32
	add.w	d0,d1		; D1=D1+RUTX
	lsl.w	#4,d1		; D1=D1*4*4 (4 long)

	move.l	(a3,d1),d2
	beq	.rita		; Lo 1 tom=vi slipper kolla dîrr i rutan
	bmi	.next
	addq.w	#4,d1
	tst.l	(a3,d1)		; +4
	beq	.kolla_dîrr
	addq.w	#4,d1
	tst.l	(a3,d1)		; +8
	beq	.kolla_dîrr

	bra	.next		; Rita inte ut fi

.kolla_dîrr:
	move.l	d2,a1		; D2 bîr innehÜlla en adress nu.
	cmp.w	#2,(a1)		; Kolla efter dîrr
	ble	.next		; rita inte ut dîd fi om han ligger pÜ dîrr
.rita:
	move.l	a0,(a3,d1)	; SÑtt ut adressen i adrmap
.next:
	add.w	#82,a0
	dbf.w	d3,.plot_loop
.ur
	rts
;--------------------------------------------------------------------------
;   				MOVE FI
;--------------------------------------------------------------------------

move_fi:
	addq.w	#1,move_fi_flag
	cmp.w	#2,move_fi_flag
	bne	.rts			; Move_fi kîrs bara varannan vbl.
	move.w	#0,move_fi_flag

	moveq	#0,d7
	add.b	$ff820d,d7
	add.b	$4bd,d7
	add.b	$ff890c,d7
	add.b	d7,slump		; fixa slumpen

	move.l	fi_data_subl,a0
	move.l	#x_gubbe,a1

	add.w	2(a0),a0		; A0 pekar mot fi infon

	move.w	enemies,counter
	subq.w	#1,counter
	bmi	.rts
.loop:
	tst.w	36+2(a0)		; Om fi Ñr dîd ska han ej rîras.
	ble	.next_fi

	cmp.w	#100,48+2(a0)
	bge	.ingen_upprÑkning 	; Om fi dîr skall han ej rîra sig.

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7

	move.w	#0,skott

	move.w	0+2(a0),d0
	asr.w	#4,d0		; /16
	move.w	d0,slx
	sub.w	(a1),d0		; d0=DX

	move.w	2+2(a0),d1
	asr.w	#4,d1		; /16
	move.w	d1,sly
	sub.w	2(a1),d1	; d0=DY

	move.w	d0,d2
	move.w	d1,d4
	muls	d2,d2
	muls	d4,d4		; d4.l=ATD OBS!! DETTA éR DET VANLIGA ATD UTAN NèGON HôGRE PRECISION!!!
	add.l	d2,d4
	move.l	d4,atd

	tst.w	54+2(a0)
	bne	.larm_pÜ	; Om fi blir trÑffad skall larmet pÜ.

	tst.w	vilket_vapen	; AnvÑnder vi kniven ska fi inte hîra dig.
	beq	.nupp
	tst.w	skjut		; Spelar eld
	beq	.nupp		; om spelar_e=0 sÜ hoppa (fi kan ej dÜ hîra dig)
	cmp.l	#HAR_STRACKA,d4
	bgt	.nupp
.larm_pÜ:

	move.w	#VAKEN_TID,30+2(a0) ; larmet skall fortsÑtta vara pÜ...

	cmp.w	#1,72+2(a0)	; probe skall fly nÑr du skjuter
	blt	.no_probe
	bgt	.no_probe
	move.w	#FLY_TID,68+2(a0)
	tst.w	vilket_vapen
	bgt	.nupp
	move.w	#0,54+2(a0)	; Kniven skall ej skada proben
	bra	.nupp
.no_probe:

	tst.w	10+2(a0)	; ér larmet redan pÜ???
	bne	.nupp

	move.w	#1,10+2(a0)	; larm pÜ

	jsr	vid_larm_pÜ
	
	cmp.w	#1,8+2(a0)	; Om typen Ñr vakt sÜ mÜste lite saker initieras
	bne	.nupp
	movem.l	d0-d7,-(sp)
	jsr	special_ny_slutpunkt	; ny slutpunkt mÜste vÑljas nÑr det Ñr en vakt. SPARA D0-D3!!!!!!!!
	movem.l	(sp)+,d0-d7

	move.w	#3,8+2(a0)		; Fi ska bli en 'slumpare'

.nupp:

*	; HÑr rÑknade vi fîrut ut smf_vin

	move.w	#0,sikt

	tst.w	fi_alarm
	beq	.no_event_koll		; Skall vi kolla event??
	cmp.l	#EVENT_STRACKA,d4
	ble	.event_ger_larm
.no_event_koll:

	cmp.l	#SIKT_STRACKA,d4
	bgt	.fi_ser_dig_ej		; Hoppa om avstÜndet Ñr lÑnge Ñn
					; siktstrÑckan.

*	Nu bîr avstÜndet vara under 4*64*16(man kan max se 4 rutor framÜt)=4096 pix  (4096*sqr(2)) om vi skall vara helt exakta, blir <6000 nÜgonting. OBS 6000 Ñr max i listan!

	move.w	d0,d2
	ext.l	d2
	asl.w	#4,d2
	move.w	d1,d3
	ext.l	d3
	asl.w	#4,d3
	muls	d2,d2
	muls	d3,d3
	add.l	d2,d3
	move.l	d3,d4		; d4.l=ATD OBS!! DETTA ATD éR MED HôGRE PRECISION éN DET VANLIGA!!!

	move.w	d0,d2		; DX i D2
	ext.l	d2
	asl.w	#4,d2		; LÑgga in hîg precision pÜ DX
	add.w	26+2(a0),d2	; LÑgg pÜ IX pÜ DX
	move.w	d1,d3		; DY i D3
	ext.l	d3
	asl.w	#4,d3		; LÑgga in hîg precision pÜ DX
	add.w	28+2(a0),d3	; LÑgg pÜ IY pÜ DY
	muls	d2,d2
	muls	d3,d3
	add.l	d2,d3
	move.l	d3,d5		; d5.l=ATD2 OBS!!! éVEN DETTA MED HôG PRECISION!!!!

	cmp.l	d4,d5
	bge	.fi_ser_dig_ej	; Inget larm slÜs pÜ om fi inte ser dig

* Om fi rîr sig mot dig(tittar mot dig) minskar avstÜndet till dig

.event_ger_larm:

	jsr	check_wall	; Kolla sÜ fi inte ser genom vÑgg

	tst.w	sikt
	beq	.fi_ser_dig_ej	; Inget larm slÜs pÜ om fi inte ser dig

				; Om larmet Ñr pÜ sÜ gÜr datorn hit varje
				; Uppdatering fîr att se till att sikten Ñr
				; fri om han skulle vilja skjuta.

	cmp.w	#1,72+2(a0)
	beq	.hopp		; Probe! Inget larm

	move.w	#VAKEN_TID,30+2(a0) 	; Se till att fi fortsÑtter att vara vaken.

	tst.w	10+2(a0)
	bne	.fi_ser_dig_ej		; Om larmet redan Ñr pÜ behîver vi ej gÜ igenom hela pÜslagnings proceduren.

	move.w	#1,10+2(a0)

	jsr	vid_larm_pÜ

	cmp.w	#1,8+2(a0)		; Typ=1 ?
	bne	.hopp
	move.w	14+2(a0),12+2(a0)	; PP till NP fîr att inget dumt skall ske...
	movem.l	d0-d7,-(sp)
	jsr	special_ny_slutpunkt	; Om fi Ñr en vakt sÜ mÜste en ny slutpunkt vÑljas
	movem.l	(sp)+,d0-d7

	move.w	#3,8+2(a0)		; Fi ska bli en 'slumpare'

.hopp:

.fi_ser_dig_ej

	move.w	34+2(a0),d6		; Slutsteg
	cmp.w	32+2(a0),d6		; Steg=slutsteg?
	bne	.hopp2
	jsr	ny_slutpunkt		; Ny slutpunkt
.hopp2:

	cmp.w	#1,8+2(a0)
	bne	.hopp3			; Om TYP<>1 sÜ skall vi hoppa.
	tst.w	10+2(a0)		; Testa om larmet Ñr pÜ.
	beq	.ingen_upprÑkning 	; StillastÜende vakt skall ej
.hopp3:					; rÑknas upp.

	move.w	60+2(a0),d6		; "VÑnta" flaggan
	subq.w	#1,d6
	blt	.min_tal
	move.w	d6,60+2(a0)
.min_tal:

	tst.w	38+2(a0)
	bne	.ingen_upprÑkning 	; Om fi skall skjuta sÜ skall han
					; ej rîra sig.
	tst.w	60+2(a0)		; "VÑnta" flaggan
	bgt	.ingen_upprÑkning

	move.l	26+2(a0),d6	; XI och YI i D6   OBS! YI direkt efter XI
	add.l	d6,0+2(a0)	; X=X+IX och Y=Y+IY  OBS! Y direkt efter X

	move.w	0+2(a0),d0
	asr.w	#4,d0			; /16
	move.w	d0,slx

	move.w	2+2(a0),d1
	asr.w	#4,d1			; /16
	move.w	d1,sly

	addq.w	#1,32+2(a0)

	jsr	kolla_ruta		; ér rutan ledig???

.ingen_upprÑkning:

	tst.w	10+2(a0)
	beq	.hopp4			; Inte larm pÜ? Hoppa i sÜ fall!
	jsr	larm_gîromÜl
.hopp4:

	jsr	anim_fi

	tst.w	68+2(a0)
	ble	.no_sub
	subq.w	#1,68+2(a0)		; minska 'fly' tiden
.no_sub:

.next_fi:
	lea	82(a0),a0		; Till nÑsta fiendedata

	sub.w	#1,counter
	bge	.loop

	move.w	#0,fi_alarm		; Ska alltid nollas efter loopen.

	move.w	#0,ritat_fÑrdigt	; Nolla 'fÑrdig ritat' flaggan 

.rts

	rts

****************
* Ny slutpunkt *
****************
ny_slutpunkt:
	move.l	4+2(a0),0+2(a0)	; SPX och SPY in i X och Y

	move.w	0+2(a0),d0
	asr.w	#4,d0		; /16
	move.w	d0,slx

	move.w	2+2(a0),d1
	asr.w	#4,d1		; /16
	move.w	d1,sly

	move.w	12+2(a0),14+2(a0) ; NP till PP
special_ny_slutpunkt:
	move.w	14+2(a0),d6	; d6 innehÜller PP

	subq.w	#1,d6		; PP ligger ett steg fîr hîgt
	muls.w	#24,d6		; NÑrmaste 24 steg(12 word)

	move.l	fi_data_subl,a4
	add.w	(a4),a4		; Pekar mot punkt_connection listan
	add.w	d6,a4		; a4 pekar pÜ den punkten som du nu Ñr pÜ

	move.l	fi_data_subl,a6
	add.w	#10,a6

	move.w	#4,w
	tst.w	18(a4)
	bne	.hopp		; 4 punkter runt om
	move.w	#3,w
	tst.w	12(a4)
	bne	.hopp		; 3 punkter runt om
	move.w	#2,w
	tst.w	6(a4)
	bne	.hopp		; 2 punkter runt om
	move.w	#1,w		; 1 punkt runt om
.hopp:
	move.w	66+2(a0),d0
	subq.w	#1,d0		; Olovs bugg
	beq	.no_fly		; Fi Ñr ingen 'flyende' typ.
	tst.w	68+2(a0)
	ble	.no_fly		; tiden har tagit slut.
	move.w	36+2(a0),d6
	move.w	66+2(a0),d0
	cmp.w	d0,d6		; Kolla om kraften Ñr lÜg
	ble	fly
.no_fly:
	tst.w	10+2(a0)	; ér alarm pÜ?
	bne	fîlj_efter_spelare

	cmp.w	#2,8+2(a0)	; Om typ=2(bana) skall fîrutbest. vÑg vÑljas.
	beq	vÑlj_fîrutbestÑmd_vÑg

	cmp.w	#3,8+2(a0)	; Om typ inte Ñr lika med 3 sÜ skall inget slumptal plockas ut.
	bne	lÜs		; Om det Ñr en vakt hÑr hÑr det FEL!
	move.l	#slump_tab,a5
	move.w	w,d6
	subq.w	#1,d6
	lsl.w	#5,d6		; d6 blir nu 0,32,64 eller 96
	add.w	d6,a5		; Nu hamnar vi pÜ rÑtt stÑlle i slumplistan
	moveq	#0,d7
	add.b	slump,d7
	and.w	#%0000000000011110,d7	; Ett slump nummer frÜn 0 till 30 i steg om 2
	move.w	(a5,d7),d6	; d6=ett passande slumptal fîr punkten som fi befinner sig pÜ.
back1:				; D6 skall vara 0,6,12.....
	move.w	44+2(a0),d2	; Plocka ut farten till D2
	move.w	(a4,d6),12+2(a0)	; LÑgg in den nya punkten i NP
	move.w	2(a4,d6),22+2(a0)	; LÑgg in vinkeln
	move.w	4(a4,d6),d3	; d3 fîrstîrs, blir avstÜnd
	asr.w	d2,d3		; Dra ner pÜ slutsteg (om farten Ñr stor)
	move.w	d3,34+2(a0)	; avstÜndet in i SLUTSTEG
	tst.w	d3
	bne	.no_ful		; Om avstÜndet=0 Ñr nÜgot fel
.no_ful:

	move.w	12+2(a0),d6	; Nya punkten(NP) i D6
	subq.w	#1,d6
	add.w	d6,d6		; *4 fîr att passa listan
	add.w	d6,d6

*	move.l	fi_data_subl,a6
*	add.w	#10,a6		; Pekar mot punkt koordinater

	move.w	(a6,d6),d4	; NY_X
	move.w	2(a6,d6),d5	; NY_Y
	move.w	d4,d0		; OBS!Fîrstîr DX!
	move.w	d5,d1		; OBS!Fîrstîr DY!

	move.w	slx,d6		; X
	sub.w	d6,d4		; NY_X-X (DX)
	move.w	sly,d7		; Y
	sub.w	d7,d5		; NY_Y-Y (DY)

	move.w	d4,d6		; DX
	asl.w	#4,d6		; *16
	ext.l	d6
	divs.w	d3,d6		; DX/SLUTSTEG
	move.w	d6,26+2(a0)	; LÑgg in i IX
	
	move.w	d5,d6		DY
	asl.w	#4,d6		; *16
	ext.l	d6
	divs.w	d3,d6		; DY/SLUTSTEG
	move.w	d6,28+2(a0)	; LÑgg in i IY

	move.w	#0,32+2(a0)

	asl.w	#4,d0		; *16
	asl.w	#4,d1		; *16
	move.w	d0,4+2(a0)	; in i SPX
	move.w	d1,6+2(a0)	; in i SPY

	rts

*****************************
* BestÑm vÑg efter spelaren *
*****************************
fîlj_efter_spelare:
*	move.w	#$7,$ff8240
	move.l	#tillf_av,a5

	move.l	#$7fffffff,(a5)+	; Ett tal sÜ stort att det aldrig
	move.l	#$7fffffff,(a5)+	; kan vÑljas, lÑggs in.
	move.l	#$7fffffff,(a5)+
	move.l	#$7fffffff,(a5)+

	move.l	#tillf_av,a5

	move.w	slx,d0			; fi X
	move.w	sly,d1			; fi Y

	move.w	(a1),d2			; D2=Spelar X
	sub.w	d0,d2			; CX
	move.w	2(a1),d3		; D3=Spelar Y
	sub.w	d1,d3			; CY

	moveq	#0,d1
	move.w	w,d0			; Antalet punkter runt om fi.
	subq.w	#1,d0			; loopen rÑtt antal gÜnger!
.loop:
	move.w	(a4,d1),d4		; En av de punkter som ligger runt
	subq.w	#1,d4			; om punkten som fi nu stÜr pÜ.
	add.w	d4,d4
	add.w	d4,d4
	move.w	(a6,d4),d5		; X till den mîjliga punkten
	move.w	2(a6,d4),d6		; Y till den mîjliga punkten

	addq.w	#6,d1			; lÑgg pÜ 6 sÜ kommer vi till nÑsta

	sub.w	(a1),d5			; Delta vÑrdet	(A1)=Spelar X
	sub.w	2(a1),d6		; Delta vÑrdet	2(A1)=Spelar Y
	
	ext.l	d5
	ext.l	d6
	muls	d5,d5
	muls	d6,d6
	add.l	d5,d6
	move.l	d6,d7		; d7.l=avstÜndet till spelaren frÜn den tÑnkta punkten

	move.l	d7,(a5)+

	dbf.w	d0,.loop

	move.l	#tillf_av,a5

	move.l	4(a5),d6
	cmp.l	(a5),d6
	blt	.hopp
	move.l	(a5),d0		; B
	moveq	#0,d2		; R
	bra	.hopp2
.hopp:
	move.l	4(a5),d0	; B
	moveq	#6,d2		; R
.hopp2:
	move.l	12(a5),d6
	cmp.l	8(a5),d6
	blt	.hopp3
	move.l	8(a5),d1	; C
	move.w	#12,d3		; R2
	bra	.hopp4
.hopp3:
	move.l	12(a5),d1	; C
	move.w	#18,d3		; R2
.hopp4:
	cmp.l	d0,d1
	bgt	.hopp5
	move.w	d3,d2
.hopp5:

	move.w	d2,d6

	bra	back1
***************************
* Fly undan frÜn spelaren *
***************************
fly:
	cmp.w	#1,72+2(a0)
	bne	.jmp

	movem.l	a4/d0-d4,-(sp)

	move.l	#fi_scream,a4		; Adr till fi ljud listan
	move.w	slx,d0
	move.w	sly,d1
	move.w	24+2(a0),d2		; plocka ut grund_utseende
	add.w	d2,d2			; *2
	move.w	(a4,d2),d2		; d2=ljud nr
	jsr	sound

	movem.l	(sp)+,a4/d0-d4
.jmp:

	move.l	#tillf_av,a5

	move.l	#0,(a5)+		; Ett tal sÜ litet att det aldrig
	move.l	#0,(a5)+		; kan vÑljas, lÑggs in.
	move.l	#0,(a5)+
	move.l	#0,(a5)+

	move.l	#tillf_av,a5

	move.w	(a1),d2			; D2=Spelar X
	sub.w	slx,d2			; CX
	move.w	2(a1),d3		; D3=Spelar Y
	sub.w	sly,d3			; CY

	moveq	#0,d1
	move.w	w,d0			; Antalet punkter runt om fi.
	subq.w	#1,d0			; loopen rÑtt antal gÜnger!
.loop:
	move.w	(a4,d1),d4		; En av de punkter som ligger runt
	subq.w	#1,d4			; om punkten som fi nu stÜr pÜ.
	add.w	d4,d4
	add.w	d4,d4
	move.w	(a6,d4),d5		; X till den mîjliga punkten
	move.w	2(a6,d4),d6		; Y till den mîjliga punkten

	addq.w	#6,d1			; lÑgg pÜ 6 sÜ kommer vi till nÑsta

	sub.w	(a1),d5			; Delta vÑrdet	(A1)=Spelar X
	sub.w	2(a1),d6		; Delta vÑrdet	2(A1)=Spelar Y
	
	ext.l	d5
	ext.l	d6
	muls	d5,d5
	muls	d6,d6
	add.l	d5,d6
	move.l	d6,d7		; d7.l=avstÜndet till spelaren frÜn den tÑnkta punkten

	move.l	d7,(a5)+

	dbf.w	d0,.loop

	move.l	#tillf_av,a5

	move.l	4(a5),d6
	cmp.l	(a5),d6
	bgt	.hopp
	move.l	(a5),d0		; B
	moveq	#0,d2		; R
	bra	.hopp2
.hopp:
	move.l	4(a5),d0	; B
	moveq	#6,d2		; R
.hopp2:
	move.l	12(a5),d6
	cmp.l	8(a5),d6
	bgt	.hopp3
	move.l	8(a5),d1	; C
	move.w	#12,d3		; R2
	bra	.hopp4
.hopp3:
	move.l	12(a5),d1	; C
	move.w	#18,d3		; R2
.hopp4:
	cmp.l	d0,d1
	blt	.hopp5
	move.w	d3,d2
.hopp5:

	move.w	d2,d6

	bra	back1
**********************************
* GÜ efter fîrutbestÑmd vÑg	 *
**********************************
vÑlj_fîrutbestÑmd_vÑg:

	move.l	40+2(a0),a5		; LÑgg in adressen till vÑg listan.
	add.w	18+2(a0),a5		; LÑgg pÜ NY_VAG sÜ vi kommer till rÑtt stÑlle i listan.
	move.w	(a5),d7		; LÑgg in den nya punkten i d7
	
	move.w	18+2(a0),16+2(a0)		; LAST_VAG=NY_VAG
	add.w	#2,18+2(a0)		; ôka NY_VAG med ett word sÜ vi hittar rÑtt punkt i listan nÑsta gÜng.

	moveq	#0,d6		; D6=0
	cmp.w	(a4),d7
	beq	.vidare		; Om den nya punkten Ñr samma som fîrsta i OMGIV_PUNKT (E(1)) sÜ Ñr D6=0 och vi hoppar vidare

	moveq	#6,d6		; D6=1
	cmp.w	6(a4),d7
	beq	.vidare		; Om den nya punkten Ñr samma som andra i OMGIV_PUNKT (E(2)) sÜ Ñr D6=6 och vi hoppar vidare

	move.w	#12,d6		; D6=12
	cmp.w	12(a4),d7
	beq	.vidare		; Om den nya punkten Ñr samma som tredje i OMGIV_PUNKT (E(3)) sÜ Ñr D6=12 och vi hoppar vidare

	move.w	#18,d6		; D6=18
	cmp.w	18(a4),d7
	beq	.vidare		; Om den nya punkten Ñr samma som fjÑrde i OMGIV_PUNKT (E(4)) sÜ Ñr D6=18 och vi hoppar vidare

.vidare:

	tst	2(a5)		; Testa om listan dÑr den fîrutbestÑmda vÑgen ligger skall bîrja om.
	bne	.inte_slut_pÜ_listan_Ñn
	move.w	#0,18+2(a0)		; NollstÑll NY_VAG

.inte_slut_pÜ_listan_Ñn:

	bra	back1


********************************
* Fi's gîromÜl nÑr alarm Ñr pÜ *
********************************
larm_gîromÜl:

	cmp.w	#100,48+2(a0)		; Fi dîr
	blt	.go_on
	rts
.go_on:
	cmp.w	#1,72+2(a0)
	blt	.go_on2
	bgt	.go_on2
	rts				; Probe
.go_on2:

	subq.w	#1,30+2(a0)		; minska tid med 1

	tst.w	38+2(a0)
	ble	.shoot_maybe
	subq.w	#1,38+2(a0)

	cmp.w	#2,72+2(a0)		; Atat killen vÑntar inte som alla 
	beq	.atat			; andra blîdiga.
	cmp.w	#4,72+2(a0)		; Slutboss2 vÑntar inte som alla 
	beq	.atat			; andra blîdiga.
	cmp.w	#3,72+2(a0)		; Slutboss1 skjuter tvÜ skott 
	beq	.boss1			; i rad.

	move.w	#FI_MAX_SHOOT_WAIT,d0
	asr.w	#1,d0
	cmp.w	38+2(a0),d0
	bne	.ingen_skjutning
	bra	.skutta_îver
.atat:
	
	move.w	38+2(a0),d0
	and.w	#%0000000000000011,d0
	bne	.ingen_skjutning
	bra	.skutta_îver
.boss1:
	
	move.w	38+2(a0),d0
	and.w	#%0000000000000111,d0
	bne	.ingen_skjutning

.skutta_îver:

	tst.w	sikt
	beq	.ingen_skjutning

	move.w	22+2(a0),d0
	add.b	$ff890a,d0
	add.b	slump,d0

	tst.w	50+2(a0)		; attack_typ(bit,skott1,skott2)
	bne	.next_sprite1
					; Hit om spriten skall bita
	cmp.l	#BIT_AVST,atd
	bgt	.ingen_skjutning	; Om avstÜndet till dig Ñr mer Ñn
					; sqr(30) sÜ Ñr monstret fîr lÜngt
					; bort fîr att bita dig.

*	 HÑr ligger rutinen fîr att fi skall bita spelaren.

	move.l	#fi_skjut,a4		; Adr till fi ljud listan
	move.w	slx,d0			; X
	move.w	sly,d1			; Y
	move.w	24+2(a0),d2		; plocka ut grund_utseende
	add.w	d2,d2			; *2
	move.w	(a4,d2),d2		; d2=ljud nr
	jsr	sound

	move.w	#1,skott

	move.w	52+2(a0),d2
	sub.w	d2,health			; han Ñr skadad.

	bra	.ingen_skjutning
.next_sprite1:
	cmp.w	#2,50+2(a0)		; om 2 sÜ Ñr det flygande skott
	beq	.next_sprite2
					; Hit om spriten skall skjuta

*	HÑr ligger rutinen dÑr fi skjuter spelaren.

	move.l	#fi_skjut,a4		; Adr till fi ljud listan
	move.w	slx,d0			; X
	move.w	sly,d1			; Y
	move.w	24+2(a0),d2		; plocka ut grund_utseende
	add.w	d2,d2			; *2
	move.w	(a4,d2),d2		; d2=ljud nr
	jsr	sound

	move.w	#1,skott

	cmp.w	#2,72+2(a0)		; Atat
	beq	.atat_missar_inte
	cmp.w	#4,72+2(a0)		; Slutboss2
	beq	.atat_missar_inte

	and.w	#%0000000000000001,d0	; 0=<d0<3
	tst.w	d0
	bne	.ingen_skjutning	; Om D0<>0 sÜ missar fi

.atat_missar_inte:

	move.w	52+2(a0),d2
	sub.w	d2,health		; han Ñr skadad.

	bra	.ingen_skjutning


;--- hÑr skjuter fi ett flygande skott ---	
.next_sprite2

	movem.l	d0-d7/a3-a6,-(sp)

	lea	flyg_skott_buf,a4
	lea	sin_360,a5
	lea	adrmap,a6
	
	move.l	aktiva_skott,d0
	moveq	#-1,d1
	
	move.w	#32-1-1,d7		; testa vilket skott vi
.tst_vilk	addq.w	#1,d1		; kan anvÑnda
	btst	d1,d0
	beq.s	.hitt_en
	dbf	d7,.tst_vilk		; om alla Ñr upptagna mÜla îver 32:an
	bra	.ingen_skjutning

.hitt_en	bset	d1,d0		; nu Ñr denna upptagen
	move.l	d0,aktiva_skott

	lsl.w	#5,d1			; vilk*32 (16words)
	add.w	d1,a4			; peekar pÜ skottet	

;--- RÑkna relvink ---

	move.w	2(a0),d2		; fi x
	move.w	4(a0),d3		; fi z
	ext.l	d2
	ext.l	d3

	lsr.w	#4,d2
	lsr.w	#4,d3

	sub.w	x_gubbe,d2		; dx
	bge.s	.no_neg1
	neg.w	d2
.no_neg1	sub.w	z_gubbe,d3	; dz
	bge.s	.no_neg2
	neg.w	d3
.no_neg2
	muls	d2,d2
	muls	d3,d3
	add.l	d2,d3
	jsr	roten_ur		; sqr sum

	cmp.w	#512,d3
	blt	.ejo512
	move.w	#512,d3
.ejo512
	move.w	2(a0),d1		; x
	move.w	4(a0),d2		; z
	lsr.w	#4,d1
	lsr.w	#4,d2
	jsr	rÑkna_vinkel		; rÑknar relativ vinkel d3=relvink

	add.w	look_angle,d3
	cmp.w	#360,d3
	blt.s	.nores1
	sub.w	#360,d3
.nores1
	sub.w	#180,d3			; bara fîr vi inte har den relativa
	bge.s	.nores2			; vinkeln mellan fi och gubbe -utan 
	add.w	#360,d3			; tvÑrtom
.nores2
	
;--- sÑtt skottet ---

	move.w	#FISKOTTHAST,hast

	cmp.w	#3,72+2(a0)
	bne	.lille_skutt
	move.w	hast,d6
	asr.w	d6
	add.w	d6,hast			; d7+50% av d7
.lille_skutt
	move.w	2(a0),d0
	move.w	4(a0),d1
	move.w	d3,d7			; spara till save
	
	lsr.w	#4,d0
	lsr.w	#4,d1

	add.w	d3,d3
	add.w	d3,a5
	move.w	(a5),d3			; sin
	move.w	180(a5),d4		; cos
	
	muls	hast,d3			; sin(grad)*snabbhet
	muls	hast,d4			; cos(grad)*snabbhet
	swap	d3
	swap	d4
	rol.l	#6,d3			; x inc*16
	rol.l	#6,d4			; z inc*16
	neg.w	d3
	
	lsr.w	#6,d0
	lsr.w	#6,d1
	lsl.w	#5,d1			; z_gubbe*32
	add.w	d1,d0			; z_gubbe*32+x_gubbe
	lsl.w	#4,d0			; offs i adrmap

	tst.l	(a6,d0.w)
	beq.s	.found_c
	addq.w	#4,d0
	tst.l	(a6,d0.w)
	beq.s	.found_c
	addq.w	#4,d0
	tst.l	(a6,d0.w)
	beq.s	.found_c
	addq.w	#4,d0
.found_c	move.l	a4,(a6,d0.w)	; lÑgg in skottadr pÜ sr

	lea	-90*2(a5),a5		; look_angle-90
	cmp.l	#sin_360,a5
	bge.s	.nojjo
	lea	360*2(a5),a5
.nojjo
*	move.w	(a5),d1
*	move.w	180(a5),d2
	
*	muls	#2,d1			; skott bredd
*	muls	#2,d2			; skott bredd
*	swap	d1
*	swap	d2
*	rol.l	#2,d1
*	rol.l	#2,d2

*	lsl.w	#4,d1
*	lsl.w	#4,d2
*	sub.w	d3,d1
*	add.w	d4,d2
*	lsr.w	#4,d1
*	lsr.w	#4,d2

	move.w	2(a0),d5
	move.w	4(a0),d6
	add.w	d3,d5
	add.w	d4,d6

	move.w	#3,(a4)+		; sÑtt indik
	move.w	#0,(a4)+		;      x_start
	move.w	#0,(a4)+		;      z_start
	move.w	#0,(a4)+
	tst.w	medishoot
	bne	.fusk
	move.w	72(a0),-2(a4)		;      spr nr 1
.fusk:
	move.w	#0,(a4)+		;      explosions rÑknare
	move.w	72(a0),(a4)+		;      spr nr 2 (-1=ej anim)
	move.w	d3,(a4)+		;      x_inc*16
	move.w	d4,(a4)+		;      z_inc*16
	move.w	hast,(a4)+		;      hyp
	move.w	d7,(a4)+		;      skott_vinkel
	move.w	54(a0),(a4)+		;      skada
	move.w	d0,(a4)+		;      adrmap offs (ej +lo:s offs)
	move.w	d5,(a4)+
	move.w	d6,(a4)+

	movem.l	(sp)+,d0-d7/a3-a6

	move.l	#fi_skjut,a4		; Adr till fi ljud listan
	move.w	slx,d0		; X
	move.w	sly,d1		; Y
	move.w	24+2(a0),d2		; plocka ut grund_utseende
	add.w	d2,d2			; *2
	move.w	(a4,d2),d2		; d2=ljud nr
	jsr	sound
	move.w	#1,skott


.ingen_skjutning:
	
	tst.w	30+2(a0)		; Testa TID
	bgt	.no_alarm_av		; hopp om larm ej skall stÑngas av.

	move.w	#0,10+2(a0)		; alarm=0
	move.w	#0,38+2(a0)
	move.w	#3,8+2(a0)		; typ=3

.no_alarm_av:


*	Skall fienden skrika lite kanske???

	tst.w	10+2(a0)
	beq	.no_scream

	move.w	22+2(a0),d0
	and.b	$ff8209,d0
	add.b	slump,d0

	and.w	#%0000000000111111,d0	; 1 pÜ 64
	bne	.no_scream		; Om slump<>0 sÜ skriker fi ej.
	move.l	#fi_scream,a4		; Adr till fi ljud listan
	move.w	slx,d0
	move.w	sly,d1
	move.w	24+2(a0),d2		; plocka ut grund_utseende
	add.w	d2,d2			; *2
	move.w	(a4,d2),d2		; d2=ljud nr
	jsr	sound
.no_scream:
	rts

*	Skall vi skjuta lite kanske??

.shoot_maybe:
	tst.w	sikt			; Om fi inte ser dig skjuter han
	beq	.ingen_skjutning	; inte.

	tst.w	68+2(a0)
	bgt	.ingen_skjutning	; Om fi flyr ska han ej skjuta

	cmp.w	#1,50+2(a0)
	blt	.bitare			; bitare
	bgt	.skott2			; Skott2

	tst.w	54+2(a0)		; Om fi blir trÑffad skall han
	bgt	.skjut			; skjuta!!!

	move.w	22+2(a0),d0
	add.b	$ff890c,d0
	add.b	slump,d0
	and.w	#%0000000000001111,d0	; 1 gÜng av 16 sÜ skjuter fi.
	bne	.ingen_skjutning
.skjut:	move.w	#FI_MAX_SHOOT_WAIT,38+2(a0)
	bra	.ingen_skjutning

.bitare:
	cmp.l	#BIT_AVST,atd		; Om avstÜndet till dig Ñr mer Ñn
	bgt	.ingen_skjutning	; sqr(30) sÜ Ñr monstret fîr lÜngt
					; bort fîr att bita dig.
	tst.w	54+2(a0)		; Om fi blir trÑffad skall han
	bgt	.bit			; bita!!!

	move.w	22+2(a0),d0
	add.b	$ff890c,d0
	add.b	slump,d0
	and.w	#%0000000000100000,d0	; 1 gÜng av 2 sÜ biter fi.
	bne	.ingen_skjutning
.bit:	move.w	#FI_MAX_SHOOT_WAIT,38+2(a0)
	bra	.ingen_skjutning

.skott2:
	move.w	22+2(a0),d0
	add.b	$ff890c,d0
	add.b	slump,d0

	tst.w	54+2(a0)		; Om fi blir trÑffad Ñr det
	bgt	.skjut2			; stîrre chans att han skjuter!!!

	and.w	#%0000000000111100,d0	; 1 gÜng av 16 sÜ skjuter fi.
	bne	.ingen_skjutning
	move.w	#FI_MAX_SHOOT_WAIT,38+2(a0)
	bra	.ingen_skjutning
.skjut2:
	and.w	#%0000000001000010,d0	; 1 gÜng av 4 sÜ skjuter fi.
	bne	.ingen_skjutning
	move.w	#FI_MAX_SHOOT_WAIT,38+2(a0)
	bra	.ingen_skjutning
***********************
*      Ljud rutin     *
* D0=x, D1=Y, D2=ljud *
***********************
sound:
	movem.l	d3,-(sp)

	move.l	#sound_board,a4
	cmp.w	#MAX_LJUD_I_SOUND_BOARD,(a4)
	bge	.no_add
	move.w	(a4),d3		; D3=antal ljud som skall startas
	add.w	#1,(a4)+	; ôka med ett ljud OBS TA BORT "*" NéR EMPAS SOUNDBOARD FUNGERAR.

	add.w	d3,d3
	move.w	d3,d4
	add.w	d3,d3
	add.w	d3,d3
	sub.w	d4,d3		; D3*6 fîr att passa listan

	add.w	d3,a4	
	move.w	d0,(a4)+	; X
	move.w	d1,(a4)+	; Y
	move.w	d2,(a4)		; Ljud nr

.no_add:	
	movem.l	(sp)+,d3

	rts
*******************************************************
* Kolla om det Ñr nÜgon spelare,fi eller dîrr i rutan *
*******************************************************
kolla_ruta:
	move.w	slx,d2
	move.w	sly,d3
	lsr.w	#6,d2		; RUTX
	lsr.w	#6,d3		; RUTY
	
	lsl.w	#5,d3		; D3=RUTY*32
	add.w	d2,d3		; D3=D3+RUTX
	move.w	d3,d7		; D3=ADDR
	lsl.w	#4,d7		; D7=D7*4*4 (4 long)  D7=ADDR*4*4

	move.w	x_gubbe,d4
	lsr.w	#6,d4		; Spelar X SR
	move.w	z_gubbe,d5
	lsr.w	#6,d5		; Spelar Y SR
	lsl.w	#5,d5		; D5=RUTY*32
	add.w	d4,d5		; D5=D5+RUTX

	cmp.w	d3,d5
	beq	.vÑnd		; Spelaren stÜr redan hÑr och fi ska vÑnda.

	cmp.w	20+2(a0),d3
	beq	.tillbaka	; fi har ej gÜtt in i nÜgon ny ruta sedan senaste uppdateringen.

	move.l	#adrmap,a3 	; A() i stos listningen

	tst.l	(a3,d7)
	blt	.vÑnd
	beq	.no_wall
	move.l	(a3,d7),a4
	cmp.w	#1,(a4)
	ble	.vÑnd		; VÑgg i vÑgen
.no_wall:

	tst.l	(a3,d7)		; Kolla om det Ñr en fi i fîrsta rutan
	beq	.no_adr
	move.l	(a3,d7),a4	; A4=SJUK ADRESS IBLAND!!!!(VID 3 BOMBER)
	cmp.w	#4,(a4)
	beq	.vÑnd
.no_adr:
	tst.l	4(a3,d7)	; Kolla om det Ñr en fi i andra rutan
	beq	.no_adr2
	move.l	4(a3,d7),a4
	cmp.w	#4,(a4)
	beq	.vÑnd
.no_adr2:
	tst.l	8(a3,d7)	; Kolla om det Ñr en fi i tredje rutan
	beq	.no_adr3
	move.l	8(a3,d7),a4
	cmp.w	#4,(a4)
	beq	.vÑnd
.no_adr3:
	tst.l	12(a3,d7)	; Kolla om det Ñr en fi i fjÑrde rutan
	beq	.no_adr4
	move.l	12(a3,d7),a4
	cmp.w	#4,(a4)
	beq	.vÑnd
.no_adr4:

*	Ingen fi i nÜgon av rutorna Ñr nu konstaterat

*	Leta tomrum

	move.l	(a3,d7),d4
	beq	.rut_tom	; Lo 1 tom=vi slipper kolla dîrr i rutan
	addq.w	#4,d7
	tst.l	(a3,d7)		; +4
	beq	.tomrum
	addq.w	#4,d7
	tst.l	(a3,d7)		; +8
	beq	.tomrum
	addq.w	#4,d7
	tst.l	(a3,d7)		; +12
	beq	.tomrum

*	Kommer vi hit finns det inget tomrum att lÑgga in fi i. Vi fîrsîker
*	hitta en 3:a att skriva îver.

	sub.w	#12,d7
	move.l	(a3,d7),a4
	cmp.w	#3,(a4)
	beq	.tomrum		; En trea, vi skriver îver denna ruta
	addq.w	#4,d7
	move.l	(a3,d7),a4
	cmp.w	#3,(a4)
	beq	.tomrum		; En trea, vi skriver îver denna ruta
	addq.w	#4,d7
	move.l	(a3,d7),a4
	cmp.w	#3,(a4)
	beq	.tomrum		; En trea, vi skriver îver denna ruta
	addq.w	#4,d7
	move.l	(a3,d7),a4
	cmp.w	#3,(a4)
	beq	.tomrum		; En trea, vi skriver îver denna ruta

*	Allt var fullt av viktiga saker, vÑnd!

	bra	.vÑnd

.tomrum:

	move.l	d4,a4		; D4 bîr innehÜlla en adress nu.
	cmp.w	#2,(a4)		; Kolla efter dîrr
	beq	.door		; hoppa till dîrr rutinen
	blt	.vÑnd		; Fi slog emot en vÑgg, stoppa honom!	

	bra	.rut_tom	; knalla in i rutan

.vÑnd:
	move.w	26+2(a0),d4	; Flytta tillbaka spelaren (skall gîras om det Ñr en fi i rutan)
	sub.w	d4,0+2(a0)	; X=X-IX
	move.w	28+2(a0),d4
	sub.w	d4,2+2(a0)	; Y=Y-IY

	move.w	0+2(a0),d0
	asr.w	#4,d0			; /16
	move.w	d0,slx

	move.w	2+2(a0),d1
	asr.w	#4,d1			; /16
	move.w	d1,sly

	cmp.w	#100,48+2(a0)	; Kolla om fi hÜller pÜ att dî,Flyger bakÜt
	bge	.tillbaka	; I sÜ fall skall han ej vÑnda utan bara
				; Stanna

	neg.w	26+2(a0)		; IX=-IX
	neg.w	28+2(a0)		; IY=-IY
	
	move.w	32+2(a0),34+2(a0)	; SLUTSTEG=STEG
	move.w	#0,32+2(a0)		; STEG=0
	
	add.w	#128,22+2(a0)		; VIN+128
	and.w	#$00ff,22+2(a0)		; if VIN>256 then VIN=VIN-256

	move.w	14+2(a0),12+2(a0)	; NP=PP

	move.l	fi_data_subl,a6
	add.w	#10,a6
	
	move.w	12+2(a0),d4	; D4=NP
	subq.w	#1,d4		; NP Ñr ett steg fîr hîgt.
	add.w	d4,d4		; NP*4 (Fîr att passa listan)(2 word(X och Y))
	add.w	d4,d4

	move.w	(a6,d4),d5	; NY_X
	move.w	2(a6,d4),d6	; NY_Y
	
	lsl.w	#4,d5		; NY_X*16
	lsl.w	#4,d6		; NY_Y*16
	
	move.w	d5,4+2(a0)	; lÑgg in i SPX
	move.w	d6,6+2(a0)	; lÑgg in i SPY

	cmp.w	#2,8+2(a0)
	bne	.no_vÑnd_bana_fi
	move.w	18+2(a0),d5
	move.w	16+2(a0),18+2(a0)	; NY_VAG=LAST_VAG
	move.w	d5,16+2(a0)


.no_vÑnd_bana_fi:
	
	rts

.rut_tom:
	move.l	56+2(a0),a4
	move.l	#0,(a4)		; ( A(ADDR_FI)=0 )
	add.w	d7,a3
	move.l	a3,56+2(a0)	; Spara adr till fi
	move.l	a0,(a3)	 	; A(ADDR*4)=adressen till fi (D7 redan adderad)

	move.w	d3,20+2(a0)	; Flytta in ADDR i ADDR_FI

.tillbaka:

	rts

********************************************
* Hit kommer vi om fi stÜr framfîr en dîrr *
********************************************
.door:

*	Denna rutin îppnar dîrren (om den nu inte redan Ñr îppen)
*	i a4 ligger adr till dîrren

	cmp.w	#100,48+2(a0)
	bge	.vÑnd			; Fi dîdsflyger, fÜr inte Üka in i dîrr.

	move.w	2(a4),d4
	move.w	4(a4),d5
	lsr.w	#6,d4
	lsr.w	#6,d5
	lsl.w	#5,d5
	add.w	d4,d5
	lsl.w	#4,d5

	tst.l	4(a3,d5.w)		; Kolla LO 234
	bne	.rut_tom
	tst.l	8(a3,d5.w)
	bne	.rut_tom
	tst.l	12(a3,d5.w)
	bne	.rut_tom

	cmp.w	#-1,22(a4)
	bgt	.check_open		; Om det Ñr en nyckel-dîrr skall vi
					; kolla om den Ñr îppen.
	blt	.check_open		; Om det Ñr en event-dîrr

	lea	akt_d_adr,a5
	move.w	#ANT_DOOR-1-1,d4	; max antal dîrrar samtidigt=ANT_DOOR (-1 fîr att om alla Ñr upptagna sÜ skrivs sista îver)
.chkadr1
	cmp.l	(a5),a4
	beq.s	.open
	cmp.l	#0,(a5)
	beq.s	.put_adr
	addq.l	#4,a5
	dbf	d4,.chkadr1

	move.l	a4,(a5)
	bra.s	.open
	
.put_adr
	move.l	a4,(a5)+
	subq.w	#1,d4
	blt.s	.open

.chkadr2
	cmp.l	(a5),a4
	bne.s	.nollej
	move.l	#0,(a5)
.nollej	addq.l	#4,a5
	dbf	d4,.chkadr2
.open

*	Slut pÜ îppnadîrr rutinen

	move.w	20(a4),d4	; Dîrr animationen
	cmp.w	#OPEN,d4
	bge	.vÑnd		; VÑnd om dîrren hÜller pÜ att stÑngas

	cmp.w	#15,d4
	bgt.w	.no_wait	; Dîrren Ñr redan îppen sÜ fi vÑntar inte.

*	Nu vet vi att dîrren hÜller pÜ att îppnas.

	move.w	d4,60+2(a0)	; Antal cykler att vÑnta tills dîrren
				; Ñr helt îppen.

	move.w	26+2(a0),d4	; Flytta tillbaka spelaren
	sub.w	d4,0+2(a0)	; X=X-IX
	move.w	28+2(a0),d4
	sub.w	d4,2+2(a0)	; Y=Y-IY

	move.w	0+2(a0),d0
	asr.w	#4,d0		; /16
	move.w	d0,slx
	move.w	2+2(a0),d0
	asr.w	#4,d0		; /16
	move.w	d0,sly

	bra	.tillbaka
	
.no_wait:

*	Dîrren Ñr îppen och det Ñr bara att fortsÑtta knalla...

	bra	.rut_tom	

*	Hit kommer vi om Fi hÜller pÜ att dîdsanimeras eller om han stÜr
*	vid en nyckeldîrr. DÜ fi ej kan îppna dîrren sjÑlv!

.check_open

	move.w	20(a4),d4	; Dîrr animationen
	cmp.w	#OPEN,d4
	bge	.vÑnd		; VÑnd om dîrren hÜller pÜ att stÑngas

	cmp.w	#15,d4
	bgt.w	.no_wait	; Dîrren Ñr redan îppen sÜ fi fortsÑtter gÜ

	bra	.vÑnd		; Dîrren Ñr stÑngd eller hÜller pÜ att
				; îppnas.


*************************************
* Kolla om det Ñr nÜgon vÑgg ivÑgen *
*************************************
check_wall:
	move.l	(a0),d0		; Fi X
	asr.w	#4,d0
	move.w	d0,x1
	move.l	2(a0),d1	; Fi Y
	asr.w	#4,d1
	move.w	d1,y1
	move.w	(a1),x2		; Spelar X
	move.w	2(a1),y2	; Spelar Y

	move.w	x2,d0
	sub.w	x1,d0
	bge	.no_neg
	neg.w	d0
.no_neg:
	move.w	y2,d1
	sub.w	y1,d1
	bge	.no_neg2
	neg.w	d1
.no_neg2:
	cmp.w	d1,d0
	blt	.more_y

.more_x:
	move.w	x2,d0
	cmp.w	x1,d0
	bge	.no_swap
	move.l	x1,d0
	move.l	x2,x1
	move.l	d0,x2	; Swappa
.no_swap:
	moveq.l	#0,d0
	move.w	y2,d0
	sub.w	y1,d0
	swap	d0
	asr.l	#2,d0
	move.w	x2,d1
	sub.w	x1,d1
	divs	d1,d0		; d0=K

	move.w	x1,d1
	muls.w	d0,d1
	swap	d1
	asl.l	#2,d1
	neg.w	d1
	add.w	y1,d1	; d1=m

	move.l	#adrmap,a3 	; A() i stos listningen
	move.w	x1,d2
	asr.w	#6,d2
	asl.w	#4,d2		; tillfixning /16 och sedan 4*4
	add.w	d2,a3		; A3 pekar pÜ rÑtt X linje!
	move.w	x2,d2
	asr.w	#6,d2
	move.w	x1,d3
	asr.w	#6,d3
	sub.w	d3,d2		; d2=antrad
	subq.w	#1,d2		; fix

	move.w	x1,d3
	and.w	#%1111111111000000,d3
	add.w	#64,d3		; d3=xt
.chk_loop_x:
	move.w	d3,d4
	muls.w	d0,d4		; k*xt
	swap	d4
	asl.l	#2,d4
	add.w	d1,d4		; +m ger yt

	and.w	#%1111111111000000,d4
	asl.w	#3,d4		; tillfixning /64 och sedan *32*4*4 ger ya

*	move.l	#fuladr,12(a3,d4)

	tst.l	(a3,d4)
	beq	.tom_ruta
	blt	.stoppa
	move.l	(a3,d4),a6
	cmp.w	#2,(a6)
	blt	.stoppa
	bgt	.tom_ruta
	tst.w	20(a6)
	beq	.stoppa
.tom_ruta:
	add.w	#4*4,a3		; ett steg till hîger

*	move.l	#fuladr,12(a3,d4)

	tst.l	(a3,d4)
	beq	.tom_ruta2
	blt	.stoppa
	move.l	(a3,d4),a6
	cmp.w	#2,(a6)
	blt	.stoppa
	bgt	.tom_ruta2
	tst.w	20(a6)
	beq	.stoppa
.tom_ruta2:
	add.w	#64,d3		; +64 pÜ xt

	dbf.w	d2,.chk_loop_x

	move.w	#1,sikt
	
	rts		

.more_y:

	move.w	y2,d0
	cmp.w	y1,d0
	bge	.no_swap2
	move.l	x1,d0
	move.l	x2,x1
	move.l	d0,x2	; Swappa
.no_swap2:
	moveq.l	#0,d0
	move.w	x2,d0
	sub.w	x1,d0
	swap	d0
	asr.l	#2,d0
	move.w	y2,d1
	sub.w	y1,d1
	divs	d1,d0		; d0=K

	move.w	y1,d1
	muls.w	d0,d1
	swap	d1
	asl.l	#2,d1
	neg.w	d1
	add.w	x1,d1	; d1=m

	move.l	#adrmap,a3 	; A() i stos listningen
	move.w	y1,d2
	and.w	#%1111111111000000,d2
	asl.w	#3,d2		; tillfixning /64 och sedan *32*4*4
	add.w	d2,a3		; A3 pekar pÜ rÑtt Y linje!
	move.w	y2,d2
	asr.w	#6,d2
	move.w	y1,d3
	asr.w	#6,d3
	sub.w	d3,d2		; d2=antrad
	subq.w	#1,d2		; fix

	move.w	y1,d3
	and.w	#%1111111111000000,d3
	add.w	#64,d3		; d3=yt
.chk_loop_y:
	move.w	d3,d4
	muls.w	d0,d4		; k*yt
	swap	d4
	asl.l	#2,d4
	add.w	d1,d4		; +m ger xt

	asr.w	#6,d4
	asl.w	#4,d4		; tillfixning /64 och sedan *4*4 ger xa

*	move.l	#fuladr,12(a3,d4)

	tst.l	(a3,d4)
	beq	.tom_ruta3
	blt	.stoppa
	move.l	(a3,d4),a6
	cmp.w	#2,(a6)
	blt	.stoppa
	bgt	.tom_ruta3
	tst.w	20(a6)
	beq	.stoppa
.tom_ruta3:
	add.w	#4*4*32,a3		; ett steg till ned

*	move.l	#fuladr,12(a3,d4)

	tst.l	(a3,d4)
	beq	.tom_ruta4
	blt	.stoppa
	move.l	(a3,d4),a6
	cmp.w	#2,(a6)
	blt	.stoppa
	bgt	.tom_ruta4
	tst.w	20(a6)
	beq	.stoppa
.tom_ruta4:
	add.w	#64,d3		; +64 pÜ yt

	dbf.w	d2,.chk_loop_y

	move.w	#1,sikt
	
	rts		

.stoppa:
	move.w	#0,sikt

	rts

***********************************************************
* Animera fi och kolla om Empa trÑffar fi nÑr han skjuter *
***********************************************************
anim_fi:
	tst.w	54+2(a0)
	bne	.spelaren_trÑffar	; Om Slempa skjuter och trÑffar
.back:
	cmp.w	#100,48+2(a0)
	bge	.death_anim

	tst.w	skott
	bne	.fi_skjuter		; fi skjuter

	tst.w	62+2(a0)		; Skall vi kontrollera skÑrmuppdatering
	beq	.flyg	; Nej
	tst.w	ritat_fÑrdigt		; ér skÑrmen fÑrdigritad
	bne	.flyg	; japp
	rts
.flyg

	move.w	#0,62+2(a0)

*	Nu vet vi att en vanlig "rîra ben" animation skall visas.

	move.w	24+2(a0),d0		; grund utseende
	muls.w	#SPRITE_ANIMATIONER,d0
	add.w	#START_SPRITE,d0	; START_SPRITE+(g_utseende*SPRITE_ANIMATIONER)

	tst.w	38+2(a0)
	bgt	.gul			; Om fi ska skjuta snart ska ej benen rîra sig

	move.l	#titt_tab,a5

	move.w	22+2(a0),d1		; fi vinkel
	add.w	#32,d1			; +45 grader fîr avrundning
	lsr.w	#6,d1			; /64 (endast 4 hÜll spriten kan titta Üt)
	and.w	#%0000000000000011,d1
	move.w	6(a1),d2		; Spelar vinkel
	add.w	#32,d2			; +45 grader fîr avrundning
	lsr.w	#6,d2			; /64 (endast 4 hÜll spriten kan titta Üt)
	and.w	#%0000000000000011,d2
	lsl.w	#3,d2
	add.w	d1,d1
	add.w	d2,d1
	move.w	(a5,d1),d1

	add.w	d1,d1			; 2 animeringar per hÜll
	add.w	d1,d0			; LÑgg pÜ hÜllet fi tittar Üt.

	cmp.w	#1,8+2(a0)
	beq	.gul			; Om fi Ñr en vakt skall benen ej rîra sig.

	tst.w	60+2(a0)		; "VÑnta" variabeln
	bgt	.hopp4			; Om fi îppnar en dîrr ska benen ej rîra sig.

	add.w	#1,48+2(a0)
	move.w	44+2(a0),d2		; Speed
	move.w	#8,d1			; Anim
	lsr.w	d2,d1
	cmp.w	48+2(a0),d1
	bgt	.hopp4
	move.w	#0,48+2(a0)
.hopp4:
	move.w	48+2(a0),d1
	neg.w	d2
	add.w	#2,d2
	lsr.w	d2,d1			; anim/(3-speed) ger ett vÑrdet 0-1

	add.w	d1,d0			; LÑgg pÜ ben animationen

.gul:
	move.w	d0,46+2(a0)		; LÑgg in i "riktigt utseende"

	rts
**************
* Fi skjuter *
**************
.fi_skjuter:
	move.w	24+2(a0),d0		; grund utseende
	muls.w	#SPRITE_ANIMATIONER,d0
	add.w	#START_SPRITE+8,d0	; START_SPRITE+(g_utseende*SPRITE_ANIMATIONER)+8(skott spriten)

	move.w	d0,46+2(a0)		; LÑgg in i "riktigt utseende"

	move.w	#1,62+2(a0)		; VÑnta pÜ uppdaterning
	
	rts
********************
* Spelaren trÑffar *
********************
.spelaren_trÑffar:
	cmp.w	#100,48+2(a0)
	blt	.hopp6			; Fi hÜller redan pÜ att dîds-
	move.w	#0,54+2(a0)		; animeras sÜ det spelar ingen
	bra	.back			; roll att spelaren Ñr grym
					; och forstÑtter sÑtta kulor i
					; honom.
.hopp6:
	move.w	54+2(a0),d1
	sub.w	d1,36+2(a0)		; vapenskada minus fi kraften
	bgt	.îverlevde		; Fi îverlevde trÑffen och "ouch'ar"

	move.w	#1,36+2(a0)		; Kommer vi hit sÜ dog fi av trÑffen
					; kraften fÜr dock ej bli noll
					; dÜ fi isÜfall inte rÑknas med
					; i MOVE_FI loopen

 *	Fixa lite saker infîr dîdsflygningen.

	move.l	#0,26+2(a0)
	tst.w	vilket_vapen		; AnvÑnder vi kniven ska fi inte
	beq	.nupp			; Flyga bakÜt.
	
	move.w	66(a0),d0		; vinkel(360 gr) pÜ spelaren.(SKALL éNDRAS NéR EMPA HAR GJORT OM TILL TVè BYTE)
	lea	sin_360,a5
	add.w	d0,d0
	add.w	d0,a5
	move.w	(a5),d3			; sin
	neg.w	d3
	move.w	180(a5),d4		; cos
	move.w	54+2(a0),d0
	asl.w	#2,d0
	muls	d0,d3
	muls	d0,d4
	swap	d3
	swap	d4
	rol.l	#2,d3			; /16384
	rol.l	#2,d4			; /16384
	move.w	d3,26+2(a0)		; IX
	move.w	d4,28+2(a0)		; IY
.nupp:
	move.w	#0,54+2(a0)		; Vapen skada skall nollas

	move.w	#100,48+2(a0)		; DÜ vet vi att fi skall dî

	move.w	#0,10+2(a0)		; Alarmet Ñr ej pÜ dÜ fi dîr

					; Jag fîrutsÑtter att spelaren bara
					; har skott som trÑffar omedelbart.

	move.l	#fi_ouch,a4		; Adr till fi ljud listan
	move.w	0+2(a0),d0
	move.w	2+2(a0),d1
	asr.w	#4,d0
	asr.w	#4,d1
	move.w	24+2(a0),d2		; plocka ut grund_utseende
	add.w	d2,d2			; *2
	move.w	(a4,d2),d2		; d2=ljud nr
	jsr	sound

	move.w	#0,62+2(a0)

	bra	.back

.îverlevde:

	move.w	24+2(a0),d0		; grund utseende
	muls.w	#SPRITE_ANIMATIONER,d0
	add.w	#START_SPRITE+9,d0	; START_SPRITE+(g_utseende*SPRITE_ANIMATIONER)+9(fîr "ouchet")

	move.w	d0,46+2(a0)		; LÑgg in i "riktigt utseende"

	move.w	66+2(a0),d0
	subq.w	#1,d0			; Olovs bugg
	beq	.no_fly
	move.w	#FLY_TID,68+2(a0)	; LÑgg in 'fly' tiden
.no_fly:
	move.w	#0,54+2(a0)		; Vapen skada skall nollas
	move.w	#1,62+2(a0)

	move.l	#fi_ouch,a4		; Adr till fi ljud listan
 	move.w	slx,d0
	move.w	sly,d1
	move.w	24+2(a0),d2		; plocka ut grund_utseende
	add.w	d2,d2			; *2
	move.w	(a4,d2),d2		; d2=ljud nr
	jsr	sound

	rts
**************************
* Animationen nÑr fi dîr *
**************************
.death_anim:
	move.w	24+2(a0),d0		; grund utseende
	muls.w	#SPRITE_ANIMATIONER,d0
	add.w	#START_SPRITE+10,d0	; START_SPRITE+(g_utseende*SPRITE_ANIMATIONER)+10(fîr "argh")

	move.w	48+2(a0),d1
	sub.w	#100,d1			; Dra bort indikationen pÜ att
					; fi dîr.
	asr.w	#3,d1			; Anim gÜr pÜ Ütta uppdateringar
	add.w	d1,d0

	move.w	d0,46+2(a0)		; LÑgg in i "riktigt utseende"

	move.w	#1,36+2(a0)		; Kraften fÜr ej bli noll fîrrÑn
					; Fi Ñr helt dîd.

*	Nu skall fi flyga bakÜt

*	Kolla sÜ vi inte flyger in i vÑggen

	move.w	0+2(a0),d0
	move.w	2+2(a0),d1
	move.w	26+2(a0),d2
	bgt	.bgt
	sub.w	#TJOCKLEK,d0
	bra	.blt
.bgt:
	add.w	#TJOCKLEK,d0
.blt:
	move.w	28+2(a0),d2
	bgt	.bgt2
	sub.w	#TJOCKLEK,d1
	bra	.blt2
.bgt2:
	add.w	#TJOCKLEK,d1
.blt2:
	lsr.w	#4,d0	; TX
	lsr.w	#4,d1	; TY
	
	move.w	d0,d2
	move.w	d1,d3
	lsr.w	#6,d2	; RUTX
	lsr.w	#6,d3	; RUTY
	
	lsl.w	#5,d3	; D3=RUTY*32
	add.w	d2,d3	; D3=D3+RUTX
	move.w	d3,d7	; D3=ADDR
	lsl.w	#4,d7	; D7=D7*4*4 (4 long)  D7=ADDR*4*4

	move.l	#adrmap,a3 	; A() i stos listningen

	tst.l	(a3,d7)
	beq	.no_wall
	blt	.wall
	move.l	(a3,d7),a4
	cmp.w	#1,(a4)
	bne	.no_wall
.wall:
	move.l	#0,26+2(a0)
.no_wall:


*	Minska IX och IY med 25%

*	move.l	26+2(a0),d0
*	move.w	d0,d1			; Flytta ut det lÑgre wordet
*	asr.w	#2,d1
*	sub.w	d1,d0			; *(3/4)
*	move.w	d0,28+2(a0)		; lÑgg in i IY
*	swap.w	d0			; Byta till Y
*	move.w	d0,d1			; Flytta ut det lÑgre wordet
*	asr.w	#2,d1
*	sub.w	d1,d0			; *(3/4)
*	move.w	d0,26+2(a0)		; lÑgg in i IX

	move.l	26+2(a0),d0
	add.l	d0,0+2(a0)		; LÑgga pÜ IX och IY pÜ X och Y.

	move.w	0+2(a0),d0
	asr.w	#4,d0		; /16
	move.w	d0,slx
	move.w	2+2(a0),d0
	asr.w	#4,d0		; /16
	move.w	d0,sly

	jsr	kolla_ruta

	add.w	#1,48+2(a0)
	cmp.w	#117,48+2(a0)
	blt	.hopp7
	move.w	#0,36+2(a0)		; NÑr vi kommer hit Ñr fi helt
					; dîd, kraften blir dÜ noll.
					; PÜ Empas begÑran skall nu fi
					; listan fîrÑndra lite...

	add.w	#37,credits
	add.w	#1,ant_killed_fi

	cmp.w	#3,72+2(a0)		; Om det Ñr en slutboss1 ska
	bne	.do_hopp		; eventet lÑggas in

	move.l	bytemap_3,a4
	move.b	#7,17*32+27(a4)

.do_hopp:
	cmp.w	#4,72+2(a0)		; Om det Ñr en slutboss2 ska
	bne	.do_hopp2		; eventet lÑggas in

	move.l	bytemap_3,a4
	move.b	#16,26*32+5(a4)

.do_hopp2:
	cmp.w	#5,72+2(a0)		; Om det Ñr en slutboss3 ska
	bne	.do_hopp3		; eventet lÑggas in

	move.l	bytemap_3,a4
	move.b	#14,5*32+18(a4)
	move.b	#14,5*32+20(a4)

.do_hopp3:
	cmp.w	#6,72+2(a0)		; Om det Ñr en slutboss3 ska
	bne	.do_hopp4		; eventet lÑggas in

	move.l	bytemap_3,a4
	move.b	#15,4*32+24(a4)

.do_hopp4:

	tst.w	detalj
	bgt	.lag_det
	move.w	#3,(a0)			; Ny fi ID
	move.w	2(a0),d0
	asr.w	#4,d0
	move.w	d0,2(a0)		; Fi X utan 16 precision
	move.w	4(a0),d0
	asr.w	#4,d0
	move.w	d0,4(a0)		; Fi Y utan 16 precision
	move.w	46+2(a0),6(a0)		; Riktigt utseende

	move.w	#0,62+2(a0)

.hopp7:
	rts
.lag_det:
	move.l	56+2(a0),a4
	move.l	#0,(a4)
	move.w	#0,62+2(a0)
	rts
***************************************************************************
vid_larm_pÜ:
	
;	Stackars Fi blir sÜ rÑdd nÑr han ser spelaren att han skriker!

	movem.l	a4/d0-d7,-(sp)

	move.l	#fi_scream,a4		; Adr till fi ljud listan
	move.w	slx,d0
	move.w	sly,d1
	move.w	24+2(a0),d2		; plocka ut grund_utseende
	add.w	d2,d2			; *2
	move.w	(a4,d2),d2		; d2=ljud nr
	jsr	sound

	movem.l	(sp)+,a4/d0-d7

	rts
***************************************************************************
lÜs:
	bra	lÜs
***************************************************************************
	section	data

*---------------------  Fi scream
*			scream ljud sprite1,sprite 2 osv.
fi_scream:	dc.w	21,24,27,30
	
*---------------------  Fi skjut
*			skjut ljud sprite1,sprite 2 osv.
fi_skjut:	dc.w	22,25,28,31

*---------------------  Fi ouch
*			ouch ljud sprite1,sprite 2 osv.
fi_ouch:	dc.w	23,26,29,32

*---------------------- Slumptabell
slump_tab:	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		; 0
		dc.w	0,6,0,6,0,6,0,6,0,6,0,6,0,6,0,6		; 0 eller 6
		dc.w	0,6,12,0,6,12,0,6,12,0,6,12,0,6,12,0	; 0,6 eller 12   OBS! Det Ñr lite lite troligare att det blir en 0 Ñn en 6 eller 12!!!!
		dc.w	0,6,12,18,0,6,12,18,0,6,12,18,0,6,12,18	; 0,6,12 eller 18

*---------------------- Tabell îver vilket hÜll fi skall titta Üt.
titt_tab:
		dc.w	1,0,3,2
		dc.w	0,3,2,1
		dc.w	3,2,1,0
		dc.w	2,1,0,3

medishoot:	dc.w	0

	section	bss
tillf_av:	ds.l	4
slump:		ds.b	1
		even
counter:	ds.w	1
enemies:	ds.w	1
k_varde:	ds.w	1
sikt:		ds.w	1
e:		ds.w	1
w:		ds.w	1
atd:		ds.l	1
sublevel:	ds.w	1
fi_data_subl:	ds.l	1
skott:		ds.w	1		; om fi skjuter blir skott=1
move_fi_flag:	ds.w	1
x1:		ds.w	1
y1:		ds.w	1
x2:		ds.w	1
y2:		ds.w	1
slx:		ds.w	1
sly:		ds.w	1
hast:		ds.w	1

		section text
