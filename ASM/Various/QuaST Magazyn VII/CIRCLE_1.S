***************************************************************************
*              Programowanie w Assemblerze ~ Quast Magazyn 8              *
*-------------------------------------------------------------------------*
* nazwa      :  Circle scroll                                             *
* autor      :  STrych / TFTE                                             *
* inne uwagi :  320x200                                                   *
***************************************************************************

*********************************
* Tak wygladal kod do pierwszego*
* Circle Scrolla.				*
* Caly pomysl scroll a kole     *
* wymysil Mr.Byte.				*
*********************************
* Notak do Marchewy				*
*********************************
* Pamietasz Marchew wyscig kto  *
* pierwszy napisze scrolla po   *
* kole.						    *
* Marchew masz moze ten prg. w  *
* GFA do obliczania trajektorii *
* ktory Ci dalem ? 				*
********************************* 

	section TEXT
	
	move.l #text,txt_point
	
	move.w #$20,-(sp)
	trap #1
	addq.l #2,sp
	
	clr.w -(SP)				
	MOVE.L #-1,-(SP)
	MOVE.L #-1,-(SP)
	MOVE.W #5,-(SP)
	TRAP #14
	ADD.L #12,SP
	move.l #fonty+2,-(sp)
	move.w #6,-(sp)
	trap #14
	addq.l #6,sp
	move.l $44e,tutaj
kop
	jsr scroll_1
	jsr test
	move.w #37,-(sp)
	trap #14
	addq.l #2,sp

	move.w #$333,$ff8240
	
	lea circle(pc),a0
	clr.l d1
	clr.l d3	
	move.l #68,d4

loop
	clr.l d0
	move.w 8(a0),d0
	move.w 10(a0),d1
	move.w 8*4+8(a0),d2
	move.w 8*4+10(a0),d3
	
	move.l $44e,a1
	add.l d2,a1                      ; drugi punkt
	btst d3,(a1)
	beq nie_pali2

	move.l $44e,a1
	add.l d0,a1
	bset d1,(a1)
	bra go_go2

nie_pali2
	
	move.l $44e,a1
	add.l d0,a1
	
	bclr d1,(a1)

go_go2
	
******************************************************
	move.w 12(a0),d0
	move.w 14(a0),d1
	move.w 8*4+12(a0),d2
	move.w 8*4+14(a0),d3
	
	move.l $44e,a1
	add.l d2,a1                      ; drugi punkt
	btst d3,(a1)
	beq nie_pali3

	move.l $44e,a1
	add.l d0,a1
	bset d1,(a1)
	bra go_go3

nie_pali3
	
	move.l $44e,a1
	add.l d0,a1
	
	bclr d1,(a1)

go_go3
	
******************************************************
	move.w 16(a0),d0
	move.w 18(a0),d1
	move.w 8*4+16(a0),d2
	move.w 8*4+18(a0),d3
	
	move.l $44e,a1
	add.l d2,a1                      ; drugi punkt
	btst d3,(a1)
	beq nie_pali4

	move.l $44e,a1
	add.l d0,a1
	bset d1,(a1)
	bra go_go4

nie_pali4
	
	move.l $44e,a1
	add.l d0,a1
	
	bclr d1,(a1)

go_go4
	
******************************************************
	move.w 20(a0),d0
	move.w 22(a0),d1
	move.w 8*4+20(a0),d2
	move.w 8*4+22(a0),d3
	
	move.l $44e,a1
	add.l d2,a1                      ; drugi punkt
	btst d3,(a1)
	beq nie_pali5

	move.l $44e,a1
	add.l d0,a1
	bset d1,(a1)
	bra go_go5

nie_pali5
	
	move.l $44e,a1
	add.l d0,a1
	
	bclr d1,(a1)

go_go5
	
******************************************************
	move.w 24(a0),d0
	move.w 26(a0),d1
	move.w 8*4+24(a0),d2
	move.w 8*4+26(a0),d3
	
	move.l $44e,a1
	add.l d2,a1                      ; drugi punkt
	btst d3,(a1)
	beq nie_pali6

	move.l $44e,a1
	add.l d0,a1
	bset d1,(a1)
	bra go_go6

nie_pali6
	
	move.l $44e,a1
	add.l d0,a1
	
	bclr d1,(a1)

go_go6
	
	add.l #4*8,a0
	
	dbf d4,loop
		
	move.w #$222,$ff8240

	
	cmp.b #57,$fffc02
	bne kop


	move.w #1,-(sp)
	trap #1	
	addq.l #2,sp
	move.w #$777,$ff8240

	clr.w (sp)
	trap #1	

******************************************
*      scroll #1 plan                    *
******************************************
scroll_1
	add.l #1,licz
	cmp.l #10,licz
	bne akuku
	jsr czytaj
	clr.l licz
akuku:
	rts

czytaj:
	move.l txt_point,a0
	clr.l d0
	move.b (a0)+,d0 				  ; d0 - odczytany znak(zwracane)
	add.l #1,txt_point
	cmp.b #$ff,d0
	bne finito
	clr.l d0
	move.l #text,txt_point
	rts

finito
	cmp.b #$20,d0
	beq spc
	sub.b #$20,d0
	add.l d0,d0
	move.l #fnt_tabela,a0
	add.l d0,a0
	move.l #fonty+34,a1
	move.w (a0),d0
	add.l a1,d0						; d0 - adres font'u
	move.l d0,a0  
pisz:                                 ; 9 x 8
	lea BUFOR,a1     *buf          ; ZMIEN NA BUFOR
*	move.b (a0),(a1)				  ; a0 - tabela znakow 
*	move.b 160(a0),160(a1)			  ; a1 - ekran
	move.b 2*160(a0),2*160(a1)
	move.b 3*160(a0),3*160(a1)
	move.b 4*160(a0),4*160(a1)
	move.b 5*160(a0),5*160(a1)
	move.b 6*160(a0),6*160(a1)
*	move.b 7*160(a0),7*160(a1)
	rts
spc:
	lea BUFOR,a1     *buf          ; ZMIEN NA BUFOR
	clr.b 2*160(a1)
	clr.b 3*160(a1)
	clr.b 4*160(a1)
	clr.b 5*160(a1)
	clr.b 6*160(a1)
	moveq.l #$20,d0
	rts
check:
	btst #7,(a0)
	beq czysty
	bset d2,(a1)
	bra next
czysty
	bclr d2,(a1)

next
	rts

test:
	clr.l d1

	lea tutaj,a1
	move.w 8(a1),d1
	move.w 10(a1),d2
	move.l $44e,a1
	add.l d1,a1	
	LEA BUFOR,a0		* buf		
	add.l #2*160,a0
	bsr check
	
	lea tutaj,a1
	move.w 12(a1),d1
	move.w 14(a1),d2
	move.l $44e,a1
	add.l d1,a1	
	LEA BUFOR,a0        * buf      
	add.l #3*160,a0
	bsr check

	lea tutaj,a1
	move.w 16(a1),d1
	move.w 18(a1),d2
	move.l $44e,a1
	add.l d1,a1	
	LEA BUFOR,a0	   *buf		
	add.l #4*160,a0
	bsr check
	
	lea tutaj,a1
	move.w 20(a1),d1
	move.w 22(a1),d2
	move.l $44e,a1
	add.l d1,a1	
	LEA BUFOR,a0	 *buf		
	add.l #5*160,a0
	bsr check
	
	lea tutaj,a1
	move.w 24(a1),d1
	move.w 26(a1),d2
	move.l $44e,a1
	add.l d1,a1	
	LEA BUFOR,a0	    * buf	
	add.l #6*160,a0	
	bsr check


	LEA BUFOR,a0			
	clr.l d0


	move.b 2*160(a0),d0
	lsl.b #1,d0
	move.b d0,2*160(a0)

	move.b 3*160(a0),d0
	lsl.b #1,d0
	move.b d0,3*160(a0)	

	move.b 4*160(a0),d0
	lsl.b #1,d0
	move.b d0,4*160(a0)

	move.b 5*160(a0),d0
	lsl.b #1,d0
	move.b d0,5*160(a0)

	move.b 6*160(a0),d0
	lsl.b #1,d0
	move.b d0,6*160(a0)	

	rts

circle:
       dc.w 29680,7
       dc.w 28880,7
       dc.w 28080,7
       dc.w 27280,7
       dc.w 26480,7
       dc.w 25680,7
       dc.w 24880,7
       dc.w 24080,7
       dc.w 29513,5
       dc.w 28713,5
       dc.w 27913,5
       dc.w 27113,4
       dc.w 26313,4
       dc.w 25513,4
       dc.w 24713,3
       dc.w 23913,3
       dc.w 29512,3
       dc.w 28712,3
       dc.w 27912,2
       dc.w 27112,1
       dc.w 26312,1
       dc.w 25512,0
       dc.w 24713,7
       dc.w 23913,6
       dc.w 29345,1
       dc.w 28545,0
       dc.w 27752,7
       dc.w 26952,6
       dc.w 26152,5
       dc.w 25352,4
       dc.w 24552,3
       dc.w 23752,2
       dc.w 29025,7
       dc.w 28225,6
       dc.w 27585,4
       dc.w 26785,3
       dc.w 25985,1
       dc.w 25185,0
       dc.w 24392,7
       dc.w 23752,5
       dc.w 28704,5
       dc.w 28064,3
       dc.w 27264,1
       dc.w 26465,7
       dc.w 25825,6
       dc.w 25025,4
       dc.w 24225,2
       dc.w 23425,1
       dc.w 28377,2
       dc.w 27737,0
       dc.w 26944,6
       dc.w 26144,4
       dc.w 25504,2
       dc.w 24704,0
       dc.w 24065,6
       dc.w 23265,4
       dc.w 28057,7
       dc.w 27257,5
       dc.w 26617,3
       dc.w 25817,0
       dc.w 25184,6
       dc.w 24384,4
       dc.w 23744,1
       dc.w 23105,7
       dc.w 27576,5
       dc.w 26776,2
       dc.w 26137,7
       dc.w 25497,5
       dc.w 24857,2
       dc.w 24064,7
       dc.w 23424,5
       dc.w 22784,2
       dc.w 26929,1
       dc.w 26296,7
       dc.w 25656,4
       dc.w 25016,1
       dc.w 24377,6
       dc.w 23737,3
       dc.w 23097,0
       dc.w 22464,5
       dc.w 26449,6
       dc.w 25809,3
       dc.w 25169,0
       dc.w 24536,4
       dc.w 23896,1
       dc.w 23257,6
       dc.w 22777,3
       dc.w 22137,0
       dc.w 25808,3
       dc.w 25169,7
       dc.w 24529,4
       dc.w 24049,0
       dc.w 23416,5
       dc.w 22936,1
       dc.w 22297,6
       dc.w 21657,2
       dc.w 25008,7
       dc.w 24528,3
       dc.w 24049,7
       dc.w 23409,4
       dc.w 22929,0
       dc.w 22456,4
       dc.w 21816,0
       dc.w 21337,5
       dc.w 24361,2
       dc.w 23888,7
       dc.w 23408,3
       dc.w 22929,7
       dc.w 22449,3
       dc.w 21816,7
       dc.w 21336,3
       dc.w 20857,7
       dc.w 23561,6
       dc.w 23081,2
       dc.w 22608,6
       dc.w 22288,2
       dc.w 21809,5
       dc.w 21329,1
       dc.w 20856,5
       dc.w 20376,1
       dc.w 22760,1
       dc.w 22441,5
       dc.w 21961,0
       dc.w 21648,4
       dc.w 21168,0
       dc.w 20849,3
       dc.w 20376,7
       dc.w 20056,3
       dc.w 21960,4
       dc.w 21641,7
       dc.w 21161,3
       dc.w 20848,6
       dc.w 20528,2
       dc.w 20209,5
       dc.w 19889,1
       dc.w 19416,4
       dc.w 21000,6
       dc.w 20680,2
       dc.w 20521,5
       dc.w 20201,0
       dc.w 19888,4
       dc.w 19569,7
       dc.w 19249,2
       dc.w 18936,6
       dc.w 20193,0
       dc.w 19880,4
       dc.w 19721,7
       dc.w 19401,2
       dc.w 19248,5
       dc.w 18928,1
       dc.w 18609,4
       dc.w 18456,7
       dc.w 19233,2
       dc.w 19080,5
       dc.w 18920,0
       dc.w 18601,3
       dc.w 18448,7
       dc.w 18288,2
       dc.w 18129,5
       dc.w 17969,0
       dc.w 18273,3
       dc.w 18120,6
       dc.w 18120,1
       dc.w 17961,4
       dc.w 17801,0
       dc.w 17648,3
       dc.w 17489,6
       dc.w 17329,1
       dc.w 17313,4
       dc.w 17320,7
       dc.w 17160,2
       dc.w 17161,5
       dc.w 17001,0
       dc.w 17008,3
       dc.w 16849,6
       dc.w 16849,1
       dc.w 16353,4
       dc.w 16360,7
       dc.w 16360,2
       dc.w 16361,5
       dc.w 16361,0
       dc.w 16368,3
       dc.w 16209,6
       dc.w 16209,1
       dc.w 15553,4
       dc.w 15560,7
       dc.w 15560,2
       dc.w 15561,5
       dc.w 15561,0
       dc.w 15568,3
       dc.w 15729,6
       dc.w 15729,1
       dc.w 14593,4
       dc.w 14600,7
       dc.w 14760,2
       dc.w 14761,5
       dc.w 14921,0
       dc.w 14928,3
       dc.w 15089,6
       dc.w 15089,1
       dc.w 13633,3
       dc.w 13800,6
       dc.w 13800,1
       dc.w 13961,4
       dc.w 14121,0
       dc.w 14288,3
       dc.w 14449,6
       dc.w 14609,1
       dc.w 12673,2
       dc.w 12840,5
       dc.w 13000,0
       dc.w 13321,3
       dc.w 13488,7
       dc.w 13648,2
       dc.w 13809,5
       dc.w 13969,0
       dc.w 11713,0
       dc.w 12040,4
       dc.w 12201,7
       dc.w 12521,2
       dc.w 12688,5
       dc.w 13008,1
       dc.w 13329,4
       dc.w 13496,7
       dc.w 10920,6
       dc.w 11240,2
       dc.w 11401,5
       dc.w 11721,0
       dc.w 12048,4
       dc.w 12369,7
       dc.w 12689,2
       dc.w 13016,6
       dc.w 9960,4
       dc.w 10281,7
       dc.w 10761,3
       dc.w 11088,6
       dc.w 11408,2
       dc.w 11729,5
       dc.w 12049,1
       dc.w 12536,4
       dc.w 9160,1
       dc.w 9641,5
       dc.w 9961,0
       dc.w 10448,4
       dc.w 10768,0
       dc.w 11249,3
       dc.w 11576,7
       dc.w 12056,3
       dc.w 8361,6
       dc.w 8841,2
       dc.w 9328,6
       dc.w 9648,2
       dc.w 10129,5
       dc.w 10609,1
       dc.w 11096,5
       dc.w 11576,1
       dc.w 7561,2
       dc.w 8048,7
       dc.w 8528,3
       dc.w 9009,7
       dc.w 9489,3
       dc.w 10136,7
       dc.w 10616,3
       dc.w 11097,7
       dc.w 6928,7
       dc.w 7408,3
       dc.w 7889,7
       dc.w 8529,4
       dc.w 9009,0
       dc.w 9496,4
       dc.w 10136,0
       dc.w 10617,5
       dc.w 6128,3
       dc.w 6769,7
       dc.w 7409,4
       dc.w 7889,0
       dc.w 8536,5
       dc.w 9016,1
       dc.w 9657,6
       dc.w 10297,2
       dc.w 5489,6
       dc.w 6129,3
       dc.w 6769,0
       dc.w 7416,4
       dc.w 8056,1
       dc.w 8697,6
       dc.w 9177,3
       dc.w 9817,0
       dc.w 5009,1
       dc.w 5656,7
       dc.w 6296,4
       dc.w 6936,1
       dc.w 7577,6
       dc.w 8217,3
       dc.w 8857,0
       dc.w 9504,5
       dc.w 4376,5
       dc.w 5176,2
       dc.w 5817,7
       dc.w 6457,5
       dc.w 7097,2
       dc.w 7904,7
       dc.w 8544,5
       dc.w 9184,2
       dc.w 3897,7
       dc.w 4697,5
       dc.w 5337,3
       dc.w 6137,0
       dc.w 6784,6
       dc.w 7584,4
       dc.w 8224,1
       dc.w 8865,7
       dc.w 3577,2
       dc.w 4217,0
       dc.w 5024,6
       dc.w 5824,4
       dc.w 6464,2
       dc.w 7264,0
       dc.w 7905,6
       dc.w 8705,4
       dc.w 3264,5
       dc.w 3904,3
       dc.w 4704,1
       dc.w 5505,7
       dc.w 6145,6
       dc.w 6945,4
       dc.w 7745,2
       dc.w 8545,1
       dc.w 2945,7
       dc.w 3745,6
       dc.w 4385,4
       dc.w 5185,3
       dc.w 5985,1
       dc.w 6785,0
       dc.w 7592,7
       dc.w 8232,5
       dc.w 2625,1
       dc.w 3425,0
       dc.w 4232,7
       dc.w 5032,6
       dc.w 5832,5
       dc.w 6632,4
       dc.w 7432,3
       dc.w 8232,2
       dc.w 2472,3
       dc.w 3272,3
       dc.w 4072,2
       dc.w 4872,1
       dc.w 5672,1
       dc.w 6472,0
       dc.w 7273,7
       dc.w 8073,6
       dc.w 2473,5
       dc.w 3273,5
       dc.w 4073,5
       dc.w 4873,4
       dc.w 5673,4
       dc.w 6473,4
       dc.w 7273,3
       dc.w 8073,3
       dc.w 2480,7
       dc.w 3280,7
       dc.w 4080,7
       dc.w 4880,7
       dc.w 5680,7
       dc.w 6480,7
       dc.w 7280,7
       dc.w 8080,7
       dc.w 2480,2
       dc.w 3280,2
       dc.w 4080,2
       dc.w 4880,3
       dc.w 5680,3
       dc.w 6480,3
       dc.w 7280,4
       dc.w 8080,4
       dc.w 2481,4
       dc.w 3281,4
       dc.w 4081,5
       dc.w 4881,6
       dc.w 5681,6
       dc.w 6481,7
       dc.w 7280,0
       dc.w 8080,1
       dc.w 2648,6
       dc.w 3448,7
       dc.w 4241,0
       dc.w 5041,1
       dc.w 5841,2
       dc.w 6641,3
       dc.w 7441,4
       dc.w 8241,5
       dc.w 2968,0
       dc.w 3768,1
       dc.w 4408,3
       dc.w 5208,4
       dc.w 6008,6
       dc.w 6808,7
       dc.w 7601,0
       dc.w 8241,2
       dc.w 3289,2
       dc.w 3929,4
       dc.w 4729,6
       dc.w 5528,0
       dc.w 6168,1
       dc.w 6968,3
       dc.w 7768,5
       dc.w 8568,6
       dc.w 3616,5
       dc.w 4256,7
       dc.w 5049,1
       dc.w 5849,3
       dc.w 6489,5
       dc.w 7289,7
       dc.w 7928,1
       dc.w 8728,3
       dc.w 3936,0
       dc.w 4736,2
       dc.w 5376,4
       dc.w 6176,7
       dc.w 6809,1
       dc.w 7609,3
       dc.w 8249,6
       dc.w 8888,0
       dc.w 4417,2
       dc.w 5217,5
       dc.w 5856,0
       dc.w 6496,2
       dc.w 7136,5
       dc.w 7929,0
       dc.w 8569,2
       dc.w 9209,5
       dc.w 5064,6
       dc.w 5697,0
       dc.w 6337,3
       dc.w 6977,6
       dc.w 7616,1
       dc.w 8256,4
       dc.w 8896,7
       dc.w 9529,2
       dc.w 5544,1
       dc.w 6184,4
       dc.w 6824,7
       dc.w 7457,3
       dc.w 8097,6
       dc.w 8736,1
       dc.w 9216,4
       dc.w 9856,7
       dc.w 6185,4
       dc.w 6824,0
       dc.w 7464,3
       dc.w 7944,7
       dc.w 8577,2
       dc.w 9057,6
       dc.w 9696,1
       dc.w 10336,5
       dc.w 6985,0
       dc.w 7465,4
       dc.w 7944,0
       dc.w 8584,3
       dc.w 9064,7
       dc.w 9537,3
       dc.w 10177,7
       dc.w 10656,2
       dc.w 7632,5
       dc.w 8105,0
       dc.w 8585,4
       dc.w 9064,0
       dc.w 9544,4
       dc.w 10177,0
       dc.w 10657,4
       dc.w 11136,0
       dc.w 8432,1
       dc.w 8912,5
       dc.w 9385,1
       dc.w 9705,5
       dc.w 10184,2
       dc.w 10664,6
       dc.w 11137,2
       dc.w 11617,6
       dc.w 9233,6
       dc.w 9712,2
       dc.w 10032,7
       dc.w 10505,3
       dc.w 10825,7
       dc.w 11304,4
       dc.w 11617,0
       dc.w 12097,4
       dc.w 10033,3
       dc.w 10352,0
       dc.w 10832,4
       dc.w 11145,1
       dc.w 11465,5
       dc.w 11784,2
       dc.w 12104,6
       dc.w 12577,3
       dc.w 10993,1
       dc.w 11313,5
       dc.w 11472,2
       dc.w 11792,7
       dc.w 12105,3
       dc.w 12424,0
       dc.w 12744,5
       dc.w 13057,1
       dc.w 11800,7
       dc.w 12113,3
       dc.w 12272,0
       dc.w 12592,5
       dc.w 12745,2
       dc.w 13065,6
       dc.w 13384,3
       dc.w 13537,0
       dc.w 12760,5
       dc.w 12913,2
       dc.w 13073,7
       dc.w 13392,4
       dc.w 13545,0
       dc.w 13705,5
       dc.w 13864,2
       dc.w 14024,7
       dc.w 13720,4
       dc.w 13873,1
       dc.w 13873,6
       dc.w 14032,3
       dc.w 14192,7
       dc.w 14345,4
       dc.w 14504,1
       dc.w 14664,6
       dc.w 14680,3
       dc.w 14673,0
       dc.w 14833,5
       dc.w 14832,2
       dc.w 14992,7
       dc.w 14985,4
       dc.w 15144,1
       dc.w 15144,6
       dc.w 15640,3
       dc.w 15633,0
       dc.w 15633,5
       dc.w 15632,2
       dc.w 15632,7
       dc.w 15625,4
       dc.w 15784,1
       dc.w 15784,6
       dc.w 16440,3
       dc.w 16433,0
       dc.w 16433,5
       dc.w 16432,2
       dc.w 16432,7
       dc.w 16425,4
       dc.w 16264,1
       dc.w 16264,6
tutaj:
       dc.w 17400,3
       dc.w 17393,0
       dc.w 17233,5
       dc.w 17232,2
       dc.w 17072,7
       dc.w 17065,4
       dc.w 16904,1
       dc.w 16904,6
       dc.w 18360,4
       dc.w 18193,1
       dc.w 18193,6
       dc.w 18032,3
       dc.w 17872,7
       dc.w 17705,4
       dc.w 17544,1
       dc.w 17384,6
       dc.w 19320,5
       dc.w 19153,2
       dc.w 18993,7
       dc.w 18672,4
       dc.w 18505,0
       dc.w 18345,5
       dc.w 18184,2
       dc.w 18024,7
       dc.w 20280,7
       dc.w 19953,3
       dc.w 19792,0
       dc.w 19472,5
       dc.w 19305,2
       dc.w 18985,6
       dc.w 18664,3
       dc.w 18497,0
       dc.w 21073,1
       dc.w 20753,5
       dc.w 20592,2
       dc.w 20272,7
       dc.w 19945,3
       dc.w 19624,0
       dc.w 19304,5
       dc.w 18977,1
       dc.w 22033,3
       dc.w 21712,0
       dc.w 21232,4
       dc.w 20905,1
       dc.w 20585,5
       dc.w 20264,2
       dc.w 19944,6
       dc.w 19457,3
       dc.w 22833,6
       dc.w 22512,2
       dc.w 22032,7
       dc.w 21705,3
       dc.w 21225,7
       dc.w 20904,4
       dc.w 20417,0
       dc.w 20097,4
       dc.w 23632,1
       dc.w 23152,5
       dc.w 22665,1
       dc.w 22345,5
       dc.w 21864,2
       dc.w 21384,6
       dc.w 20897,2
       dc.w 20417,6
       dc.w 24432,5
       dc.w 23945,0
       dc.w 23465,4
       dc.w 22984,0
       dc.w 22504,4
       dc.w 21857,0
       dc.w 21377,4
       dc.w 20896,0
       dc.w 25065,0
       dc.w 24585,4
       dc.w 24104,0
       dc.w 23464,3
       dc.w 22984,7
       dc.w 22497,3
       dc.w 21857,7
       dc.w 21376,2
       dc.w 25865,4
       dc.w 25224,0
       dc.w 24584,3
       dc.w 24104,7
       dc.w 23457,2
       dc.w 22977,6
       dc.w 22336,1
       dc.w 21696,5
       dc.w 26504,1
       dc.w 25864,4
       dc.w 25224,7
       dc.w 24577,3
       dc.w 23937,6
       dc.w 23296,1
       dc.w 22816,4
       dc.w 22176,7
       dc.w 26984,6
       dc.w 26337,0
       dc.w 25697,3
       dc.w 25057,6
       dc.w 24416,1
       dc.w 23776,4
       dc.w 23136,7
       dc.w 22489,2
       dc.w 27617,2
       dc.w 26817,5
       dc.w 26176,0
       dc.w 25536,2
       dc.w 24896,5
       dc.w 24089,0
       dc.w 23449,2
       dc.w 22809,5
       dc.w 28096,0
       dc.w 27296,2
       dc.w 26656,4
       dc.w 25856,7
       dc.w 25209,1
       dc.w 24409,3
       dc.w 23769,6
       dc.w 23128,0
       dc.w 28416,5
       dc.w 27776,7
       dc.w 26969,1
       dc.w 26169,3
       dc.w 25529,5
       dc.w 24729,7
       dc.w 24088,1
       dc.w 23288,3
       dc.w 28729,2
       dc.w 28089,4
       dc.w 27289,6
       dc.w 26488,0
       dc.w 25848,1
       dc.w 25048,3
       dc.w 24248,5
       dc.w 23448,6
       dc.w 29048,0
       dc.w 28248,1
       dc.w 27608,3
       dc.w 26808,4
       dc.w 26008,6
       dc.w 25208,7
       dc.w 24401,0
       dc.w 23761,2
       dc.w 29368,6
       dc.w 28568,7
       dc.w 27761,0
       dc.w 26961,1
       dc.w 26161,2
       dc.w 25361,3
       dc.w 24561,4
       dc.w 23761,5
       dc.w 29521,4
       dc.w 28721,4
       dc.w 27921,5
       dc.w 27121,6
       dc.w 26321,6
       dc.w 25521,7
       dc.w 24720,0
       dc.w 23920,1
       dc.w 29520,2
       dc.w 28720,2
       dc.w 27920,2
       dc.w 27120,3
       dc.w 26320,3
       dc.w 25520,3
       dc.w 24720,4
       dc.w 23920,4
       dc.w 29680,7
       dc.w 28880,7
       dc.w 28080,7
       dc.w 27280,7
       dc.w 26480,7
       dc.w 25680,7
       dc.w 24880,7
       dc.w 24080,7

kasuj
	dc.b 0
	
	dc.b 0
	dc.b 0
	dc.b 0

fnt_tabela:
	dc.w 0,1,8,9,16,17,24,25,32,33,40,41,48,49,56,57,64,65,72,73
	dc.w 4*160,4*160+1,4*160+8,4*160+9,4*160+16,4*160+17,4*160+24,4*160+25,4*160+32,4*160+33,4*160+40,4*160+41,4*160+48,4*160+49,4*160+56,4*160+57,4*160+64,4*160+65,4*160+72,4*160+73
	dc.w 2*5*160,2*5*160+1,2*5*160+8,2*5*160+9,2*5*160+16,2*5*160+17,2*5*160+24,2*5*160+25,2*5*160+32,2*5*160+33,2*5*160+40,2*5*160+41,2*5*160+48,2*5*160+49,2*5*160+56,2*5*160+57,2*5*160+64,2*5*160+65,2*5*160+72,2*5*160+73
	dc.w 3*5*160,3*5*160+1,6*3*160+8,3*5*160+9,3*5*160+16,3*5*160+17,3*5*160+24,3*5*160+25,3*5*160+32,3*5*160+33,3*5*160+40,3*5*160+41,3*5*160+48,3*5*160+49,3*5*160+56,2*5*160+57,3*5*160+64,3*5*160+65,3*5*160+72,3*5*160+73
	even

zap_kol: 	ds.w 20
scrol_nie	dc.w 0
txt_point:		dc.l 0
txt_point1:		dc.l 0
licz			dc.l 0
BUFOR:
	ds.b 160*10
	EVEN
fonty:
	incbin 'A:ASEMBLER.S\DANE.DAT\fnt8x8.pi1'

text:
	DC.B " TAK WYGLADAL PIERWSZY W POLSCE CIRCLE SCROLL CODED BY STRYCH"
	dc.b "                        ",$FF					
	


