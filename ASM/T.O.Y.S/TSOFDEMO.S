  *************************************************************
  *                                                           *
  *  This is the source to T.S.O.F's first demo.              *
  *  Files included in this package:                          *
  *                                                           *
  *          TSOFDEMO.S     -  This source                    *
  *          THE_FONT.FON   -  The font used in this demo     *
  *          THEMUSIC.MUZ   -  The music used in the demo     *
  *                                                           *
  * + + + + + + + + + + + + + + + + + + + + + + + + + + + + + *
  *                                                           *  
  *  This is a very (VERY!!) simple scroller containing some  *
  *   music and some rasterbaras that is waving in a sinus    *
  *   wave. Remember that this demo was written in late 89.   *
  *  The demos of today is bigger,better and sometimes even   *
  *   really stunning !!                                      *
  *  This short demo/intro can be altered in many ways...     *
  *  For instance you can change the waves,change the colors  *
  *   and put some rasters in the scroller just to mention    *
  *   some things.                 Enjoy it anyway !!         *
  *                                                           *
  *                           Mr. Ice of T.S.O.F. // G.R.C.   *
  *                                                           *
  *************************************************************

	bsr 	init_all
 	bsr 	int_on
 
wait_l	tst.b 	VSYNC
 	beq 	wait_l
 	clr.b 	VSYNC
 	JSR 	music+2652
 	BSR 	ini_gfx
 	BSR 	raster
	bsr	scroll
 	cmp.b 	#185,$fffc02
 	bne 	wait_l
  	bsr 	int_off
 	bsr 	restore_rest
 	illegal
 	clr.w 	-(sp)
 	trap 	#1

;************  END OF MAIN PROGRAM  ************
;************     START OF SUBS     ************  

init_all: clr.l 	-(sp)
 	move.w 	#$20,-(sp)
 	trap 	#1
 	addq.l 	#6,sp
 	move.l 	d0,save_ssp
  	movem.l 	$ff8240,d0-d7
 	movem.l 	d0-d7,savepal
 	movem.l 	newpal,d0-d7
 	movem.l 	d0-d7,$ff8240
 	move.w 	#2,-(sp)
 	trap 	#14
 	addq.l 	#2,sp
 	move.l 	d0,physbase
 	clr.w 	-(sp)
 	move.l 	#$78000,-(sp)
 	move.l 	#$78000,-(sp)
 	move.w 	#5,-(sp)
	trap 	#14
 	add.l 	#12,sp

 	MOVE.L 	#$78000,A0
 	MOVE.W 	#$2000,D0
RENS 	CLR.L 	(A0)+
 	DBRA 	D0,RENS		;relocate madmax music
	move.l 	#$72000,d1	;lowest adress to relocate
	move.l 	#$73B9A,d2	;higest adress to relocate
	move.l 	#music,d3		;relocation base
	lea 	music,a0		;area to scan
	lea 	music_end,a1	;end of scan area

relocate  cmp.l 	(a0),d1		;relocate!
	bhs 	notthis
	cmp.l 	(a0),d2
	bls 	notthis
	sub.l 	d1,(a0)
	add.l 	d3,(a0)
	addq.l 	#2,a0
notthis	addq.l 	#2,a0
	cmp.l 	a1,a0
	blt 	relocate

 	MOVEQ.L 	#0,D0
	jsr 	music+5140	;init music

	lea 	$78000,a0
	add.l 	#29440,a0		;position on screen
	move.l 	a0,phys_1
	lea 	scrolline,a0
	move.b 	(a0)+,d0
	move.l 	a0,store

	lea	tab68,a0
	moveq	#0,d0
	move.w	#99,d1
lp68	move.w	d0,(a0)+
	add.w	#68,d0
	dbra	d1,lp68
	
	rts

restore_rest:
	move.l	#$8080000,$ff8800	;silence soundchip
	move.l	#$9090000,$ff8800
	move.l	#$a0a0000,$ff8800	

  	movem.l 	savepal,d0-d7
 	movem.l 	d0-d7,$ff8240

 	move.w 	#1,-(sp)
 	move.l 	physbase,-(sp)
 	move.l 	physbase,-(sp)
 	move.w 	#5,-(sp)
 	trap 	#14
 	add.l 	#12,sp

 	move.l 	save_ssp,-(sp)
 	move.w 	#$20,-(sp)
 	trap 	#1
 	add.l 	#6,sp
 	rts

int_on:
  	MOVE.L 	#int_store,A0
  	MOVE.B 	$FFFA07,(A0)+
  	MOVE.B 	$FFFA09,(A0)+
  	MOVE.B 	$FFFA0F,(A0)+
  	MOVE.B 	$FFFA11,(A0)+
  	MOVE.B 	$FFFA13,(A0)+
  	MOVE.B 	$FFFA15,(A0)+
  	MOVE.B 	$FFFA1B,(A0)+
  	MOVE.B 	$FFFA21,(A0)+
  	MOVE.L 	$120,(A0)+
  	MOVE.L 	$70,(A0)+
  	MOVE.B 	#1,$FFFA07
  	CLR.B 	$FFFA09
  	OR.B 	#1,$FFFA13
  	MOVE.B 	#1,$FFFA21
  	MOVE.B 	#8,$FFFA1B
  	MOVE.L 	#HBL,$120
  	MOVE.L 	#VBL,$70
  	MOVE.W 	#$2300,SR
  	RTS

int_off:
  	MOVE.W 	SR,-(SP)
  	MOVE.W 	#$2700,SR 
  	MOVE.L 	#int_store,A0
  	MOVE.B 	(A0)+,$FFFA07
  	MOVE.B 	(A0)+,$FFFA09
  	MOVE.B 	(A0)+,$FFFA0F
  	MOVE.B 	(A0)+,$FFFA11
  	MOVE.B 	(A0)+,$FFFA13
  	MOVE.B 	(A0)+,$FFFA15
  	MOVE.B 	(A0)+,$FFFA1B
  	MOVE.B 	(A0)+,$FFFA21
  	MOVE.L 	(A0)+,$120
  	MOVE.L 	(A0)+,$70
  	MOVE.W 	(SP)+,SR
 	RTS

VBL:
  	MOVE.b 	#1,VSYNC
  	RTE

HBL:
 	MOVE.W 	(A5)+,$FFFF8242.W
 	MOVE.W 	(A6)+,$FFFF8240.W
 	BCLR 	#0,$FFFFFA0F.W
 	RTE

;**************  VU METER ROUTINE  *************

ini_gfx:				;GET VALUES FOR METERS
 	moveq	#0,d0
 	MOVE.B 	#$8,$FFFF8800.W
 	MOVE.B 	$FFFF8800.W,D0
 	lsl.W 	#1,D0
 	MOVE.W 	D0,VU_Meter_1 

 	moveq.w	#0,d0
 	MOVE.B 	#$9,$FFFF8800.W
 	MOVE.B 	$FFFF8800.W,D0
 	lsl.w	#1,d0
 	MOVE.W 	D0,VU_Meter_2

 	moveq.w	#0,d0
 	MOVE.B 	#$A,$FFFF8800.W
 	MOVE.B 	$FFFF8800.W,D0
 	lsl.w	#1,d0
 	MOVE.W 	D0,VU_Meter_3
				;Clear the old meters
 	MOVEQ 	#0,D0
 	lea 	$7fc90,A0
 	MOVEQ 	#31,D1
C1	MOVE.W 	D0,(A0)
  	MOVE.W 	D0,8(A0)
  	MOVE.W 	D0,24(A0)
  	MOVE.W 	D0,32(A0)
  	MOVE.W 	D0,48(A0)
  	MOVE.W 	D0,56(A0)
  	SUB.L 	#320,A0
  	DBRA 	D1,C1
				;Make VU-Meters
 	MOVE.W 	#$FFFF,D0
				;Make VU-Meter #1
 	MOVE.W 	VU_Meter_1,D1
 	BEQ 	N1
 	lea 	$7fc90,A0
B1 	MOVE.W 	D0,(A0)
 	MOVE.W 	D0,8(A0)
 	SUB.L 	#320,A0
 	DBRA 	D1,B1
				;Make VU-Meter #2
N1 	MOVE.W 	VU_Meter_2,D1
 	BEQ 	N2
 	lea	$7fca8,A0
B2 	MOVE.W 	D0,(A0)
 	MOVE.W 	D0,8(A0)
 	SUB.L 	#320,A0
 	DBRA 	D1,B2 
				;Make VU-Meter #3
N2 	MOVE.W 	VU_Meter_3,D1
 	BEQ 	N3

 	lea 	$7fcc0,A0
B3 	MOVE.W 	D0,(A0)
 	MOVE.W 	D0,8(A0)
 	SUB.L 	#320,A0
 	DBRA 	D1,B3
N3 	RTS

VU_Meter_1 	DC.W 	0
VU_Meter_2 	DC.W 	0
VU_Meter_3 	DC.W 	0

;************** BIG RASTER ROUTINE *************

raster:
	SUB.W 	#1,RASTON
 	TST.W 	RASTON
 	BNE 	OUT
 	MOVE.W 	#1,RASTON
 	MOVE.L 	#RASTTAB,A0	;CLEAR RASTERTABLE 
 	MOVEM.L 	ZEROS,D1-D7/A2-A4
 	MOVEM.L	D1-D7/A2-A4,(A0)
 	MOVEM.L 	D1-D7/A2-A4,40(A0)
 	MOVEM.L 	D1-D7/A2-A4,80(A0)
 	MOVEM.L 	D1-D7/A2-A4,120(A0) 
 	MOVEM.L 	D1-D7/A2-A4,160(A0)
 	MOVEM.L 	D1-D7/A2-A4,200(A0)
 	MOVEM.L 	D1-D7/A2-A4,240(A0)
 	MOVEM.L 	D1-D7/A2-A4,280(A0)
 	MOVEM.L 	D1-D7/A2-A4,320(A0)
 	MOVEM.L 	D1-D7/A2-A4,360(A0) 
 	ADD.W 	#14,SIN1
 	CMP.W 	#1820,SIN1
 	BLT 	LOOP1
 	MOVE.W 	#0,SIN1
LOOP1 	MOVE.L  	#SINDAT,A0
 	ADDA.W 	SIN1,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVE.L 	#SINTUBE1,A1
 	MOVEM.L 	(A1),D1-D7/A2
 	MOVEM.L 	D1-D7/A2,(A0)
 	MOVEM.L 	32(A1),D1-D3
	MOVEM.L 	D1-D3,32(A0)
 	ADD.W 	#14,SIN2
 	CMP.W 	#1820,SIN2
 	BLT 	LOOP2
 	MOVE.W 	#0,SIN2
LOOP2 	MOVE.L  	#SINDAT,A0
 	ADDA.W 	SIN2,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVE.L 	#SINTUBE2,A1
 	MOVEM.L 	(A1),D1-D7/A2
 	MOVEM.L 	D1-D7/A2,(A0)
 	MOVEM.L 	32(A1),D1-D3
	MOVEM.L 	D1-D3,32(A0)
 	ADD.W 	#14,SIN3
 	CMP.W 	#1820,SIN3
 	BLT 	LOOP3
 	MOVE.W 	#0,SIN3
LOOP3 	MOVE.L  	#SINDAT,A0
 	ADDA.W 	SIN3,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVE.L 	#SINTUBE3,A1
 	MOVEM.L 	(A1),D1-D7/A2
 	MOVEM.L 	D1-D7/A2,(A0)
 	MOVEM.L 	32(A1),D1-D3
	MOVEM.L 	D1-D3,32(A0)
 	ADD.W 	#14,SIN4
 	CMP.W 	#1820,SIN4
 	BLT 	LOOP4
 	MOVE.W 	#0,SIN4
LOOP4 	MOVE.L  	#SINDAT,A0
 	ADDA.W 	SIN4,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVE.L 	#SINTUBE4,A1
 	MOVEM.L 	(A1),D1-D7/A2
 	MOVEM.L 	D1-D7/A2,(A0)
 	MOVEM.L 	32(A1),D1-D3
	MOVEM.L 	D1-D3,32(A0)
 	ADD.W 	#14,SIN5
 	CMP.W 	#1820,SIN5
 	BLT 	LOOP5
 	MOVE.W 	#0,SIN5

LOOP5 	MOVE.L  	#SINDAT,A0
 	ADDA.W 	SIN5,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVE.L 	#SINTUBE5,A1
 	MOVEM.L 	(A1),D1-D7/A2
 	MOVEM.L 	D1-D7/A2,(A0)
 	MOVEM.L 	32(A1),D1-D3
	MOVEM.L 	D1-D3,32(A0)
 	ADD.W 	#14,SIN6
 	CMP.W 	#1820,SIN6
 	BLT 	LOOP6
 	MOVE.W 	#0,SIN6

LOOP6 	MOVE.L  	#SINDAT,A0
 	ADDA.W 	SIN6,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVE.L 	#SINTUBE6,A1
 	MOVEM.L 	(A1),D1-D7/A2
 	MOVEM.L 	D1-D7/A2,(A0)
 	MOVEM.L 	32(A1),D1-D3
	MOVEM.L 	D1-D3,32(A0)
 	ADD.W 	#14,SIN7
 	CMP.W 	#1820,SIN7
 	BLT 	LOOP7
 	MOVE.W 	#0,SIN7
LOOP7 	MOVE.L  	#SINDAT,A0
 	ADDA.W 	SIN7,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVE.L 	#SINTUBE7,A1
 	MOVEM.L 	(A1),D1-D7/A2
 	MOVEM.L 	D1-D7/A2,(A0)
 	MOVEM.L 	32(A1),D1-D3
	MOVEM.L 	D1-D3,32(A0)
 	ADD.W 	#14,SIN8
 	CMP.W 	#1820,SIN8
 	BLT 	LOOP8
 	MOVE.W 	#0,SIN8
LOOP8 	MOVE.L  	#SINDAT,A0
 	ADDA.W 	SIN8,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVE.L 	#SINTUBE8,A1
 	MOVEM.L 	(A1),D1-D7/A2
 	MOVEM.L 	D1-D7/A2,(A0)
 	MOVEM.L 	32(A1),D1-D3
	MOVEM.L 	D1-D3,32(A0)
 	ADD.W 	#14,SIN9
 	CMP.W 	#1820,SIN9
 	BLT 	LOOP9
 	MOVE.W 	#0,SIN9
LOOP9 	MOVE.L 	#SINDAT,A0
 	ADDA.W 	SIN9,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVE.L 	#SINTUBE9,A1
 	MOVEM.L 	(A1),D1-D7/A2
 	MOVEM.L 	D1-D7/A2,(A0)
 	MOVEM.L 	32(A1),D1-D3
	MOVEM.L 	D1-D3,32(A0)
 	ADD.W	#14,SIN10
 	CMP.W 	#1820,SIN10
 	BLT 	LOOP10
 	MOVE.W 	#0,SIN10
LOOP10 	MOVE.L 	#SINDAT,A0
	ADDA.W 	SIN10,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVE.L 	#SINTUBE10,A1
 	MOVEM.L 	(A1),D1-D7/A2
 	MOVEM.L 	D1-D7/A2,(A0)
 	MOVEM.L 	32(A1),D1-D3
	MOVEM.L 	D1-D3,32(A0)
 	ADD.W 	#14,SIN11
 	CMP.W 	#1820,SIN11
 	BLT 	LOOP11
 	MOVE.W 	#0,SIN11
LOOP11 	MOVE.L 	#SINDAT,A0
 	ADDA.W 	SIN11,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVE.L 	#SINTUBE11,A1
 	MOVEM.L 	(A1),D1-D7/A2
 	MOVEM.L 	D1-D7/A2,(A0)
 	MOVEM.L 	32(A1),D1-D3
	MOVEM.L 	D1-D3,32(A0)
 	ADD.W 	#14,SIN12
 	CMP.W 	#1820,SIN12
 	BLT 	LOOP12
 	MOVE.W 	#0,SIN12
 	MOVE.W 	#1,RASTON
LOOP12 	MOVE.L 	#SINDAT,A0
 	ADDA.W 	SIN12,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVE.L 	#SINTUBE12,A1
 	MOVEM.L 	(A1),D1-D7/A2
 	MOVEM.L 	D1-D7/A2,(A0)
 	MOVEM.L 	32(A1),D1-D3
	MOVEM.L 	D1-D3,32(A0)
 	ADD.W 	#14,SIN13
 	CMP.W 	#1820,SIN13
 	BLT 	LOOP13
 	MOVE.W 	#0,SIN13
 	MOVE.W 	#1,RASTON
LOOP13 	MOVE.L 	#SINDAT,A0
 	ADDA.W 	SIN13,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVE.L 	#SINTUBE13,A1
 	MOVEM.L 	(A1),D1-D7/A2
 	MOVEM.L 	D1-D7/A2,(A0)
 	MOVEM.L 	32(A1),D1-D3
	MOVEM.L 	D1-D3,32(A0)
 	ADD.W 	#14,SIN14
 	CMP.W 	#1820,SIN14
 	BLT 	LOOP14
 	MOVE.W 	#0,SIN14
 	MOVE.W 	#1,RASTON
LOOP14 	MOVE.L 	#SINDAT,A0
 	ADDA.W 	SIN14,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVE.L 	#SINTUBE14,A1
 	MOVEM.L 	(A1),D1-D7/A2
 	MOVEM.L 	D1-D7/A2,(A0)
 	MOVEM.L 	32(A1),D1-D3
	MOVEM.L 	D1-D3,32(A0)
 	ADD.W 	#14,SIN15
 	CMP.W 	#1820,SIN15
 	BLT 	LOOP15
 	MOVE.W 	#0,SIN15
 	MOVE.W 	#1,RASTON
LOOP15 	MOVE.L 	#SINDAT,A0
 	ADDA.W 	SIN15,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVE.L 	#SINTUBE15,A1
 	MOVEM.L 	(A1),D1-D7/A2-a5
 	MOVEM.L 	D1-D7/A2-a5,(A0)
OUT 	MOVE.L 	#RASTTAB,A6
 	CLR.W 	398(A6)		;CLEAR LAST LINE OF RASTTAB
 	MOVE.L 	#VURASTTAB,A5
 	RTS 

SIN1	DC.W 0
SIN2	DC.W 70
SIN3	DC.W 140
SIN4	DC.W 210
SIN5	DC.W 280
SIN6	DC.W 350
SIN7	DC.W 420
SIN8	DC.W 490
SIN9	DC.W 560
SIN10	DC.W 630
SIN11	DC.W 700
SIN12	DC.W 770
SIN13	DC.W 840
SIN14	DC.W 910
SIN15	DC.W 980
RASTON	DC.W 1

	
SINTUBE1:					; YELLOW
	DC.W $000,$110,$110,$220,$220,$330,$440,$550,$660,$770,$770,$770,$770,$660
	DC.W $550,$440,$330,$220,$220,$110,$110,$000
SINTUBE2:					; CYAN
	DC.W $000,$011,$011,$022,$022,$033,$044,$055,$066,$077,$077,$077,$077,$066
	DC.W $055,$044,$033,$022,$011,$022,$011,$000
SINTUBE3:					; WHITE
	DC.W $000,$111,$111,$222,$222,$333,$444,$555,$666,$777,$777,$777,$777,$666
	DC.W $555,$444,$333,$222,$222,$111,$111,$000
SINTUBE4:					; RED
	DC.W $000,$100,$100,$200,$200,$300,$400,$500,$600,$700,$700,$700,$700,$600
	DC.W $500,$400,$300,$200,$200,$100,$100,$000
SINTUBE5:					; GREEN
	DC.W $000,$010,$010,$020,$020,$030,$040,$050,$060,$070,$070,$070,$070,$060
	DC.W $050,$040,$030,$020,$020,$010,$010,$000
SINTUBE6:					; BLUE
	DC.W $000,$001,$001,$002,$002,$003,$004,$005,$006,$007,$007,$007,$007,$006
	DC.W $005,$004,$003,$002,$002,$001,$001,$000
SINTUBE7:					; MAGENTA
	DC.W $000,$101,$101,$102,$102,$203,$304,$405,$506,$607,$607
	DC.W $607,$607,$506,$405,$304,$203,$102,$102,$101,$101,$000
SINTUBE8:					; YELLOW
	DC.W $000,$110,$110,$220,$220,$330,$440,$550,$660,$770,$770,$770,$770,$660
	DC.W $550,$440,$330,$220,$220,$110,$110,$000
SINTUBE9:					; MAGENTA
	DC.W $000,$101,$101,$102,$102,$203,$304,$405,$506,$607,$607
	DC.W $607,$607,$506,$405,$304,$203,$102,$102,$101,$101,$000
SINTUBE10:					; BLUE
	DC.W $000,$001,$001,$002,$002,$003,$004,$005,$006,$007,$007,$007,$007,$006
	DC.W $005,$004,$003,$002,$002,$001,$001,$000
SINTUBE11:				; GREEN
	DC.W $000,$010,$010,$020,$020,$030,$040,$050,$060,$070,$070,$070,$070,$060
	DC.W $050,$040,$030,$020,$020,$010,$010,$000
SINTUBE12:				; RED
	DC.W $000,$100,$100,$200,$200,$300,$400,$500,$600,$700,$700,$700,$700,$600
	DC.W $500,$400,$300,$200,$200,$100,$100,$000
SINTUBE13:				; WHITE
	DC.W $000,$111,$111,$222,$222,$333,$444,$555,$666,$777,$777,$777,$777,$666
	DC.W $555,$444,$333,$222,$222,$111,$111,$000
SINTUBE14:				; CYAN
	DC.W $000,$011,$011,$022,$022,$033,$044,$055,$066,$077,$077,$077,$077,$066
	DC.W $055,$044,$033,$022,$011,$022,$011,$000
SINTUBE15:				; YELLOW
	DC.W $000,$110,$110,$220,$220,$330,$440,$550,$660,$770,$770,$770,$770,$660
	DC.W $550,$440,$330,$220,$220,$110,$110,$000

SINDAT 
    	DC.W 160,160,162,162,164,164,166,166,168,168,170,170
	DC.W 172,172,174,174,176,176,178,178,180
	DC.W 180,182,182,184,186,186,188,188
	DC.W 190,192,192,194,194,196,198,198
	DC.W 200,200,202,204,204,206,206,208
	DC.W 208,210,212,212,214,214,216,216
	DC.W 218,218,220,220,222,222,224,224
	DC.W 226,226,228,228,230,230,232,232
	DC.W 234,234,236,236,238,238,240,240
	DC.W 240,242,242,244,244,246,246,248
	DC.W 248,250,250,252,252,254,254,254
	DC.W 256,256,258,258,258,260,260,262
	DC.W 262,264,264,264,266,266,268,268
	DC.W 270,270,272,272,274,274,276,276
	DC.W 278,278,278,280,280,280,282,282
	DC.W 282,284,284,286,286,286,288,288
	DC.W 288,290,290,290,292,292,292,292
	DC.W 294,294,294,296,296,296,298,298
	DC.W 298,298,300,300,300,302,302,302
	DC.W 302,304,304,304,304,306,306,306
	DC.W 306,308,308,308,308,308,310,310
	DC.W 310,310,310,312,312,312,312,312
	DC.W 314,314,314,314,314,314,314,316
	DC.W 316,316,316,316,316,316,316,316
	DC.W 318,318,318,318,318,318,318,318
	DC.W 318,318,318,318,318,320,318,318
	DC.W 318,318,318,318,318,318,318,318
	DC.W 318,318,318,316,316,316,316,316
	DC.W 316,316,316,316,314,314,314,314
	DC.W 314,314,314,312,312,312,312,312
	DC.W 310,310,310,310,310,308,308,308
	DC.W 308,308,306,306,306,306,304,304
	DC.W 304,304,302,302,302,302,300,300
	DC.W 300,298,298,298,298,296,296,296
	DC.W 294,294,294,292,292,292,292,290
	DC.W 290,290,288,288,288,286,286,286
	DC.W 284,284,282,282,282,280,280,280
	DC.W 278,278,278,276,276,274,274,272
	DC.W 272,270,270,268,268,266,266,264
	DC.W 264,264,262,262,260,260,258,258
	DC.W 258,256,256,254,254,254,252,252
	DC.W 250,250,248,248,246,246,244,244
	DC.W 242,242,240,240,240,238,238,236
	DC.W 236,234,234,232,232,230,230,228
	DC.W 228,226,226,224,224,222,222,220
	DC.W 220,218,218,216,216,214,214,212
	DC.W 212,210,208,208,206,206,204,204
	DC.W 202,200,200,198,198,196,194,194
	DC.W 192,192,190,188,188,186,186,184
	DC.W 182,182,180,180,178,178,176,176
	DC.W 174,172,172,170,170,168,168,166
	DC.W 166,164,162,162,160,160,158,158
	DC.W 156,156,154,154,152,152,150,148
	DC.W 148,146,146,144,144,142,142,140
	DC.W 138,138,136,136,134,134,132,132
	DC.W 130,130,128,128,126,126,124,124
	DC.W 122,122,120,120,118,118,116,116
	DC.W 114,114,112,112,110,110,108,108
	DC.W 106,106,104,104,102,102,100,100
	DC.W 98,98,96,96,94,94,92,92
	DC.W 90,90,88,88,86,86,84,84
	DC.W 82,82,80,80,80,78,78,76
	DC.W 76,74,74,72,72,70,70,70
	DC.W 68,68,66,66,64,64,62,62
	DC.W 60,60,58,58,58,56,56,54
	DC.W 54,52,52,52,50,50,50,48
	DC.W 48,48,46,46,46,44,44,44
	DC.W 42,42,42,40,40,38,38,38
	DC.W 36,36,36,34,34,34,32,32
	DC.W 32,30,30,30,28,28,28,26
	DC.W 26,26,24,24,24,24,22,22
	DC.W 22,22,20,20,20,20,18,18
	DC.W 18,18,16,16,16,16,14,14
	DC.W 14,14,14,12,12,12,12,12
	DC.W 10,10,10,10,10,8,8,8
	DC.W 8,8,8,6,6,6,6,6
	DC.W 6,6,4,4,4,4,4,4
	DC.W 4,2,2,2,2,2,2,2
	DC.W 2,2,2,0,0,0,0,0
	DC.W 0,0,0,0,0,0,0,0
	DC.W 0,0,0,0,0,0,0,0
	DC.W 0,0,0,0,0,0,0,0
	DC.W 0,0,0,0,0,0,0,0
	DC.W 0,0,0,0,0,0,0,0
	DC.W 0,0,0,0,0,0,0,0
	DC.W 0,0,0,0,0,0,0,0
	DC.W 0,0,0,0,2,2,2,2
	DC.W 2,2,2,2,2,2,4,4
	DC.W 4,4,4,4,4,6,6,6
	DC.W 6,6,6,6,8,8,8,8
	DC.W 8,8,10,10,10,10,10,12
	DC.W 12,12,12,12,14,14,14,14
	DC.W 14,16,16,16,16,18,18,18
	DC.W 18,20,20,20,20,22,22,22
	DC.W 24,24,24,24,26,26,26,28
	DC.W 28,28,30,30,30,32,32,32
	DC.W 34,34,34,36,36,36,38,38
	DC.W 38,40,40,42,42,42,44,44
	DC.W 44,46,46,46,48,48,48,50
	DC.W 50,50,52,52,52,54,54,56
	DC.W 56,58,58,58,60,60,62,62
	DC.W 64,64,66,66,68,68,70,70
	DC.W 70,72,72,74,74,76,76,78
	DC.W 78,80,80,80,82,82,84,84
	DC.W 86,86,88,88,90,90,92,92
	DC.W 94,94,96,96,98,98,100,100
	DC.W 102,102,104,104,106,106,108,108
	DC.W 110,110,112,112,114,114,116,116
	DC.W 118,118,120,120,122,122,124,124
	DC.W 126,126,128,128,130,130,132,132
	DC.W 134,134,136,136,138,138,140,142
	DC.W 142,144,144,146,146,148,148,150
	DC.W 150,152,152,154,154,156,156,158,158
	
;***********  END OF RASTERTUBEROUT  ***********

ZEROS 	DS.L 	16
int_store	DS.L 	20
oldvbl 	ds.l 	1
srtemp	ds.w 	1
physbase	ds.l 	1
save_ssp 	ds.l 	1
savepal  	ds.w 	16
VSYNC	ds.w 	1
page1	ds.l 	1
page2	ds.l 	1
VURASTTAB:     
  	DCB.W 138,0 
  	DC.W $700,0,$700,0,$600,0,$600,0,$500,0,$500,0,$400,0,$400,0,$400,0
  	DC.W $440,0,$440,0,$550,0,$550,0,$660,0,$770,0,$770,0
  	DC.W $660,0,$550,0,$550,0,$440,0,$440,0
  	DC.W $040,0,$040,0,$040,0,$050,0,$050,0,$050,0,$060,0,$070,0,$070,0,$070,0
 
newpal 	dc.w $0000,$0700,$0070,$0770,$007,$0777,$0777,$0777
 	dc.w $0777,$0777,$0027,$0005,$0076,$0055,$0044,$0700

RASTTAB   DS.W 	400

music 	INCBIN 	"themusic.muz"
music_end

;***************  SCROLLER PART  ***************

scroll	bsr 	do_scroll		
	addq.b 	#1,count_1
	cmp.b 	#8,count_1
	beq 	nextlet
	rts

nextlet	clr.b 	count_1
movlet	MOVE.L	store,a0
	move.b 	(a0)+,d0
	cmp.b 	#$ff,d0
	beq 	wrap
	subi.b 	#$20,d0
	move.l 	a0,store
 	move.b 	d0,b
	move.w 	a,d0
	lsl.w	#1,d0
	lea	tab68,a1
	move.w	0(a1,d0.w),d0
	clr.l 	a
	move.w 	d0,c
	add.l 	#font,a
	sub.l 	#2,a
	move.l 	a,a0
	lea 	frame,a1
	move.w 	#16,d0
there	move.w 	2(a0),6(a1)
	move.w 	4(a0),14(a1)

	adda.l 	#160,a1				
	addq.l 	#4,a0
	dbf 	d0,there
	rts


do_scroll:
	move.w  	#3,d1  ; scroll 4 pixels per vbl
dosy	lea 	frame,a1
	move.l 	phys_1,a0
	
	rept 	17
	lsl.w   	30(a1)  ; scroll 1 pixel to the left
	roxl.w  	22(a1)
	roxl.w  	14(a1)
          roxl.w  	6(a1)   ; the letters are 32 pixels wide
          roxl.w  	158(a0) ; scroll the screen
          roxl.w  	150(a0) ; steps of -8, scroll one plane
          roxl.w  	142(a0)
          roxl.w  	134(a0)
          roxl.w  	126(a0)
          roxl.w  	118(a0)
          roxl.w  	110(a0)
          roxl.w  	102(a0)
          roxl.w  	94(a0)
          roxl.w  	86(a0)
          roxl.w  	78(a0)
          roxl.w  	70(a0)
          roxl.w  	62(a0)
          roxl.w  	54(a0)
          roxl.w  	46(a0)
          roxl.w  	38(a0)
          roxl.w  	30(a0)
          roxl.w  	22(a0)
          roxl.w  	14(a0)
          roxl.w  	6(a0)
          adda.l  	#160,a1 
          adda.l  	#160,a0	; 160 bytes: one screen line down
	endr	        

	dbra    	d1,dosy
          rts		; end of routine

wrap 	move.b 	#$20,d0
	lea 	scrolline,a0
	move.l 	a0,store
	rts

scrolline	
	dc.b "        HELLO!          THIS IS T.S.O.F'S FIRST DEMO."
	dc.b "          CREDITS FOR THIS:          PAIN (CODE)       "
	DC.B "   MR.ICE (REWRITING AND ALTERING)          DO WHAT YOU"
	DC.B " WANT WITH THIS PIECE OF CODE. WE DON'T LIKE IT !!"
	DC.B "          GREETZ TO ALL WE KNOW !!          DON'T WORRY..."
	DC.B "          BE HAPPY !!         */ */ */    "
	DC.B "               ",$FF
	even

a 	dc.b 	0
b 	dc.b 	0
c 	dc.b 	0
d 	dc.b 	0
phys_1 	ds.l 	1
store 	ds.l 	1
count_1 	dc.b 	7
tab68	ds.w 	100
font	incbin 	"the_font.fon"
frame 	DS.B 	3000
