** This is the original source to our first demo (GRIM.PRG)
** I was written by Mr.Ice (TSOF) and Pylon X (SYNC)
** Very dull code and can be optimized ALOT !!!   
** Date for this one is -Sometime in 1990-

 	bsr 	init_all		;initialise stuff
 	bsr 	INTON		;save old inter.values and insert new
 
WAITLOOP 	tst.b 	VSYNC		;test for vbl
 	beq 	WAITLOOP 		 
 	clr.b 	VSYNC
 	MOVE.W 	#$777,$FF8240	
 *	BSR 	SONG+4		;play next note of song
 	BSR 	INIGRAX		;do vumeters	
 	MOVE.W 	#$007,$FF8240	 
 	BSR 	RASTERS		;update rastertabs
 	MOVE.W 	#$0,$FF8240
 	cmp.b 	#185,$fffc02	;check for space on keyboard
 	bne 	WAITLOOP		;finished   wait for next vbl
 	bsr 	INTOFF		;turn off our ints and restore old values
 	bsr 	restore_rest	;restore stuff
  	illegal			;exit to debugger
 	clr.w 	-(sp)
 	trap 	#1

;end of main program
;start of subs

init_all: clr.l -(sp)		;supervisor
 	move.w 	#$20,-(sp)
 	trap 	#1
 	addq.l 	#6,sp
 	move.l 	d0,save_ssp
 
 	movem.l 	$ff8240,d0-d7	;save old palette and insert new
 	movem.l 	d0-d7,savepal
 	movem.l 	newpal,d0-d7
 	movem.l 	d0-d7,$ff8240

 	move.w 	#2,-(sp)		;save old physbase
 	trap 	#14
 	addq.l 	#2,sp
 	move.l 	d0,physbase
		
 	clr.w 	-(sp)		;set lowres and screenadress to $78000
 	move.l 	#$78000,-(sp)
 	move.l 	#$78000,-(sp)
 	move.w 	#5,-(sp)
 	trap 	#14
 	add.l 	#12,sp
	
 	MOVE.L	#$78000,A0	;clear screen
 	MOVE.W 	#$2000,D0
RENS 	CLR.L 	(A0)+
 	DBRA 	D0,RENS

 	MOVEQ.L 	#0,D0		;init musix
* 	BSR 	SONG		;value in d0 = song number
 	rts

restore_rest:
  	movem.l 	savepal,d0-d7	;restore old palette
 	movem.l 	d0-d7,$ff8240

 	move.w 	#1,-(sp)		;set med res and restore old physbase
 	move.l 	physbase,-(sp)
 	move.l 	physbase,-(sp)	
 	move.w 	#5,-(sp)
 	trap 	#14	
 	add.l 	#12,sp

 	move.l 	save_ssp,-(sp)	;set usermode
 	move.w 	#$20,-(sp)	
 	trap 	#1
 	add.l 	#6,sp
 	rts

INTON:	
  	MOVE.L 	#INTSTORE,A0	;save old interuppts
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

INTOFF:
  	MOVE.W 	SR,-(SP)
  	MOVE.W 	#$2700,SR 
  	MOVE.L 	#INTSTORE,A0
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

VBL	MOVE.b 	#1,VSYNC
  	RTE

HBL	MOVE.W (A5)+,$FF8242	;change colour every new screenline
	MOVE.W (A6)+,$FF8240
	BCLR 	#0,$FFFA0F
	RTE

INIGRAX:

;GET VALUES FOR METERS
 	MOVEQ.W #0,D0
 	MOVE.B 	#$8,$FF8800	;read volume voice 1
 	MOVE.B 	$FF8800,D0
 	ADD.W 	D0,D0		;height = volume * 2   
 	MOVE.W 	D0,VU1 

 	MOVEQ.W #0,D0	
 	MOVE.B 	#$9,$FF8800	;read volume voice 2
 	MOVE.B 	$FF8800,D0
 	ADD.W 	D0,D0
 	MOVE.W 	D0,VU2

 	MOVEQ.W #0,D0
 	MOVE.B 	#$A,$FF8800	;read volume voice 3
 	MOVE.B 	$FF8800,D0
 	ADD.W 	D0,D0
 	MOVE.W 	D0,VU3

;CLEARER OF OLD BARS  		;erase old bars
 	MOVEQ 	#0,D0
 	LEA	$7FC90,A0	
 	MOVEQ 	#31,D1
C1 	MOVE.W D0,(A0)
  	MOVE.W D0,8(A0)
  	MOVE.W D0,24(A0)
  	MOVE.W D0,32(A0)
  	MOVE.W D0,48(A0)
  	MOVE.W D0,56(A0)
  	SUB.L 	#320,A0
  	DBRA 	D1,C1
;MAKE BARS
 	MOVE.W 	#$FFFF,D0		;draw new bars
;MAKE BAR #1
 	MOVE.W 	VU1,D1
 	BEQ 	N1
 	LEA 	$7FC90,A0
B1 	MOVE.W 	D0,(A0)
 	MOVE.W 	D0,8(A0)
 	SUB.L 	#320,A0
 	DBRA 	D1,B1
;MAKEBAR #2
N1 	MOVE.W 	VU2,D1
 	BEQ 	N2
 	LEA     $7FCA8,A0
B2 	MOVE.W 	D0,(A0)
 	MOVE.W 	D0,8(A0)
 	SUB.L 	#320,A0
 	DBRA 	D1,B2 
;MAKE BAR #3
N2 	MOVE.W 	VU3,D1
 	BEQ 	N3

 	LEA 	$7FCC0,A0
B3 	MOVE.W 	D0,(A0)
 	MOVE.W 	D0,8(A0)
 	SUB.L 	#320,A0
 	DBRA 	D1,B3
N3 	RTS

;*************************************************
;********* HERE BEGINS BIG RASTER ROUTINE ******** 
;*************************************************

RASTERS:
	SUB.W 	#1,RASTON
 	TST.W 	RASTON
 	BNE 	OUT
 	MOVE.W 	#1,RASTON
 	MOVE.L 	#RASTTAB,A0	;CLEAR RASTERTABLE 
 	MOVEM.L 	ZEROS,D1-D7/A2-A4
 	MOVEM.L 	D1-D7/A2-A4,(A0)
 	MOVEM.L 	D1-D7/A2-A4,40(A0)
 	MOVEM.L 	D1-D7/A2-A4,80(A0)
 	MOVEM.L 	D1-D7/A2-A4,120(A0) 
 	MOVEM.L 	D1-D7/A2-A4,160(A0)
 	MOVEM.L	D1-D7/A2-A4,200(A0)
 	MOVEM.L 	D1-D7/A2-A4,240(A0)
 	MOVEM.L 	D1-D7/A2-A4,280(A0)
 	MOVEM.L 	D1-D7/A2-A4,320(A0)
 	MOVEM.L 	D1-D7/A2-A4,360(A0) 
 	ADDQ.W 	#4,SIN1
 	CMP.W 	#830,SIN1
 	BLT 	LOOP1
 	MOVE.W 	#0,SIN1
LOOP1 	MOVE.L  	#SINDAT,A0
 	ADDA.W 	SIN1,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVE.L 	#SINTUBE,A1
 	MOVEM.L 	(A1),D1-D7/A2-A4
	MOVEM.L 	D1-D7/A2-A4,(A0)
 	MOVEM.L 	40(A1),D1-D7/A2-A4
 	MOVEM.L 	D1-D7/A2-A4,40(A0)
 	ADDQ.W 	#4,SIN2
 	CMP.W 	#830,SIN2
 	BLT 	LOOP2
 	MOVE.W 	#0,SIN2
LOOP2 	MOVE.L 	#SINDAT,A0
 	ADDA.W 	SIN2,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVEM.L 	(A1),D1-D7/A2-A4
 	MOVEM.L 	D1-D7/A2-A4,(A0)
 	MOVEM.L 	40(A1),D1-D7/A2-A4
 	MOVEM.L 	D1-D7/A2-A4,40(A0)
 	ADDQ.W	#4,SIN3
 	CMP.W 	#830,SIN3
 	BLT 	LOOP3
 	MOVE.W 	#0,SIN3
LOOP3 	MOVE.L 	#SINDAT,A0
	ADDA.W 	SIN3,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVEM.L 	(A1),D1-D7/A2-A4
 	MOVEM.L 	D1-D7/A2-A4,(A0)
 	MOVEM.L 	40(A1),D1-D7/A2-A4
 	MOVEM.L 	D1-D7/A2-A4,40(A0)
 	ADDQ.W 	#4,SIN4
 	CMP.W 	#830,SIN4
 	BLT 	LOOP4
 	MOVE.W 	#0,SIN4
LOOP4 	MOVE.L 	#SINDAT,A0
 	ADDA.W 	SIN4,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVEM.L 	(A1),D1-D7/A2-A4
 	MOVEM.L 	D1-D7/A2-A4,(A0)
 	MOVEM.L 	40(A1),D1-D7/A2-A4
 	MOVEM.L 	D1-D7/A2-A4,40(A0)
 	ADDQ.W 	#4,SIN5
 	CMP.W 	#830,SIN5
 	BLT 	LOOP5
 	MOVE.W 	#0,SIN5
 	MOVE.W 	#200,RASTON	;DELAY NOW SET TO 4 SECONDS
LOOP5 	MOVE.L 	#SINDAT,A0
 	ADDA.W 	SIN5,A0
 	MOVE.W 	(A0),D0
 	MOVE.L 	#RASTTAB,A0
 	ADD.W 	D0,A0
 	MOVEM.L 	(A1),D1-D7/A2-A4
 	MOVEM.L 	D1-D7/A2-A4,(A0)
 	MOVEM.L 	40(A1),D1-D7/A2-A4
 	MOVEM.L 	D1-D7/A2-A4,40(A0)
OUT 	MOVE.L 	#RASTTAB,A6
 	CLR.W 	398(A6)		;CLEAR LAST LINE OF RASTTAB
 	MOVE.L 	#VURASTTAB,A5
 	RTS 

SIN1		DC.W 0
SIN2		DC.W 30
SIN3		DC.W 60
SIN4		DC.W 90
SIN5		DC.W 120

RASTON 		DC.W 1

SINTUBE: 				;40 LINES BIG!!!!
 	DC.W $001,$001,$002,$002,$002,$003,$003,$003,$004
 	DC.W $004,$114,$005,$005,$115,$006,$006,$116,$007,$117
 	DC.W $117,$007,$007,$007,$116,$006,$006,$115,$005,$005
 	DC.W $114,$004,$004,$003,$003,$003,$002,$002,$002,$001,$001 

SINDAT 	DC.W 400,398,398,398,398,398,398,398	;kassa rorelsedata
 	DC.W 398,396,396,396,394,394,394,392 	;maste beraknas om
 	DC.W 392,390,390,388,386,386,384,382
 	DC.W 382,380,378,378,376,374,372,368
	DC.W 368,366,364,362,360,358,356,352
	DC.W 352,350,348,346,342,340,338,332
	DC.W 332,330,328,324,322,320,316,310
	DC.W 310,308,304,302,298,296,292,286
	DC.W 286,284,280,278,274,270,268,260
	DC.W 260,258,254,250,248,244,240,234
	DC.W 234,230,226,224,220,216,212,206
	DC.W 206,202,198,196,192,188,186,178
	DC.W 178,174,172,168,164,160,158,150
	DC.W 150,148,144,140,138,134,130,124
	DC.W 124,120,118,114,112,108,106,98
	DC.W 98,96,94,90,88,84,82,76
	DC.W 76,74,70,68,66,62,60,56
	DC.W 56,52,50,48,46,44,42,38
	DC.W 38,36,34,32,30,28,26,22
	DC.W 22,20,20,18,16,14,14,12
	DC.W 12,10,8,8,6,6,4,4
	DC.W 4,2,2,2,0,0,0,0
	DC.W 0,0,0,0,0,0,0,0
	DC.W 0,0,0,0,0,2,2,4
	DC.W 4,4,4,6,6,8,8,12
	DC.W 12,12,14,14,16,18,20,22
	DC.W 22,24,26,28,30,32,34,38
	DC.W 38,40,42,44,46,48,50,56
	DC.W 56,58,60,62,66,68,70,76
	DC.W 76,78,82,84,88,90,94,100
	DC.W 100,102,106,108,112,114,118,124
	DC.W 124,128,130,134,138,140,144,150
	DC.W 150,154,158,160,164,168,172,178
	DC.W 178,182,186,188,192,196,200,206
	DC.W 206,210,212,216,220,224,226,234
	DC.W 234,238,240,244,248,250,254,260
	DC.W 260,264,268,270,274,278,280,286
	DC.W 286,290,292,296,300,302,304,310
	DC.W 310,314,316,320,322,324,328,332
	DC.W 332,336,338,340,342,346,348,352
	DC.W 352,354,356,358,360,362,364,368
	DC.W 368,370,372,374,376,378,378,382
	DC.W 382,384,384,386,386,388,390,392
	DC.W 392,392,394,394,394,396,396,398
	DC.W 398,398,398,398,398,398,398,600
	DC.W 600,600,600,600,600,600,600,600
	DC.W 600,600,600,600,600,600,600,600
	DC.W 600,600,600,600,600,600,600,600
	DC.W 600,600,600,600,600,600,600,600
	DC.W 600,600,600,600,600,600,600,600
	DC.W 600,600,600,600,600,600,600,600
	DC.W 600,600,600,600,600,600,600,600
;**********************************************
;************END OF RASTERTUBEROUT*************
;**********************************************

ZEROS 	DS.L 	16
VU1 	DC.W 	0
VU2 	DC.W 	0
VU3 	DC.W 	0
INTSTORE	DS.L 	20
oldvbl 	ds.l 	1
srtemp	ds.w 	1
physbase	ds.l 	1
save_ssp 	ds.l 	1
savepal  	ds.w 	16
VSYNC	ds.w 	1
VURASTTAB:     
  	DCB.W 	140,0
  	DC.W 	$700,0,$700,0,$600,0,$600,0,$500,0,$500,0,$400,0,$400,0,$400,0
  	DC.W 	$440,0,$440,0,$550,0,$550,0,$660,0,$770,0,$770,0
  	DC.W 	$660,0,$550,0,$550,0,$440,0,$440,0
  	DC.W 	$040,0,$040,0,$040,0,$050,0,$050,0,$050,0,$060,0,$070,0,$070,0
 
newpal 	dc.w 	$0000,$0700,$0070,$0770,$007,$0222,$0333,$0444
 	dc.w 	$0777,$0555,$0027,$0005,$0076,$0055,$0044,$0700

RASTTAB DS.W 400

*SONG INCBIN LIVLETDI.IMG

;To include music, remove the stars ( * ) at the following lines: 11, 56, 371.