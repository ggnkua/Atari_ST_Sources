*################################################
*SCROLLER
*################################################
*INIT

             move.w #0,-(sp)
             move.l #$f8000,-(sp)
             move.l #$f8000,-(sp)
             move.w #5,-(sp)
             trap #14
             add.l #12,sp

                 
             MOVE.L #0,-(SP)
             MOVE.W #$20,-(SP)
             TRAP #1
             ADD.L #6,SP
             MOVE.L D0,SPSAVE

	jsr inladd
                 
	move.l #0,antsteg
	move.l #grafbuff,buffer
	add.l #168,buffer
	move.l #grafbuff,copybuff
	move.l #grafbuff,buffpos
	add.l #16,buffpos
	move.l #20,antword
	move.l #1,vbokword
	move.l #$F8000,screen      
	move.l #3,pixplan	;antal pixelplan
	move.l #0,vword
	move.l #data,datapos
	move.l #text,textpos
	move.w #1,colour
	move.l #raster,a6
	move.l #0,raknare
	
	move.l $70,vsave
	move.b $fffa07,intmsk1
	move.b $fffa09,intmsk2
	move.l #vsync,$70
	move.b #0,$fffa07
	move.b #0,$fffa09

timing:	cmpi.l #1,vtrue
	bne timing
	move.l #0,vtrue

             MOVE.L #PALSHIFT,-(SP)      ;STARTA TIMER B
             MOVE.W #1,-(SP)             ;INT. GENERERAS VARJE HSYNC
             MOVE.W #8,-(SP)             ;EVENT COUNT MODE
             MOVE.W #1,-(SP)
             MOVE.W #31,-(SP)
             TRAP #14
             ADD.L #12,SP


	move.w $ff8240,palsave
	move.w #0,$ff8240
	
	jsr getbok

*################################################
*Start
*################################################
main:	;move.w #$0,$ff8240
             jsr scrollit
	jsr putit	
	jsr fixbufferts
	;move.w #$777,$ff8240
	jsr wait
	
	cmpi.b #185,$fffc02
	bne main

	;move.w #1,-(sp)
	;trap #1
	;add.l #2,-(sp)

	;cmpi.l #1,raknare
	;bne main
	bra slut
	

*################################################
*Hamta bokstav
*################################################
getbok:	move.l textpos,a0
	add.l #1,textpos
	clr.l d0
	move.b (a0),d0

	cmpi.b #0,d0
	bne forbi2
	move.l #text,textpos
	bra getbok

forbi2:	cmpi.b #32,d0
	bne forbi3
	move.l #fontbuff,d1
	add.l #20608,d1
	move.l d1,bokaddr
	rts

forbi3:      cmpi.b #46,d0
	bne forbi4
	move.b #94,d0

forbi4:      cmpi.b #44,d0
	bne forbi5
	move.b #95,d0

forbi5:      sub.l #65,d0

	mulu #4,d0
	move.l #tabaddr,a0
	add.l d0,a0

	move.l (a0),a0
	move.l #fontbuff,d0
	add.l #128,d0	
	add.l a0,d0
	move.l d0,bokaddr
	rts
	
*################################################
*scrolla bokst.
*################################################
scrollit:	move.l bokaddr,a0
	move.l buffer,a1
	move.l copybuff,a2
	move.l antsteg,d5
	move.l pixplan,d6
	move.l #31,d7
	

rollit:	clr.l d0
             move.w (a0)+,d0	
	lsl.l d5,d0
	
	swap d0
	or.w d0,(a1)
	or.w d0,(a2)
	swap d0
	move.w d0,8(a1)
	addq #2,a1
 	move.w d0,8(a2)
	addq #2,a2
   
	add.l #158,a0		;andra vid skarmlas
	add.l #326,a1
	add.l #326,a2
	clr.l d0

	dbra d7,rollit

	add.l #8,antsteg
	add.l #20992,buffer
	add.l #20992,copybuff

	rts




*################################################
*Put grafik
*################################################
putit:	
	move.l buffpos,a0
	add.l #20992,buffpos
	move.l screen,a1
	add.l #16000,a1
	move.l datapos,a2
	move.l #31,d6
	move.l #19,d7

	move.l (a2)+,d1
	sub.l d1,a1
	add.l #12,a2



putout:	move.b (a0),d0
	move.b d0,(a1)
	move.b 328(a0),d0
	move.b d0,160(a1)
	move.b 656(a0),d0
	move.b d0,320(a1)
	move.b 984(a0),d0
	move.b d0,480(a1)
	move.b 1312(a0),d0
	move.b d0,640(a1)
	move.b 1640(a0),d0
	move.b d0,800(a1)
	move.b 1968(a0),d0
	move.b d0,960(a1)
	move.b 2296(a0),d0
	move.b d0,1120(a1)
	move.b 2624(a0),d0
	move.b d0,1280(a1)
	move.b 2952(a0),d0
	move.b d0,1440(a1)
	move.b 3280(a0),d0
	move.b d0,1600(a1)
	move.b 3608(a0),d0
	move.b d0,1760(a1)
	move.b 3936(a0),d0
	move.b d0,1920(a1)
	move.b 4264(a0),d0
	move.b d0,2080(a1)
	move.b 4592(a0),d0
	move.b d0,2240(a1)
	move.b 4920(a0),d0
	move.b d0,2400(a1)
	move.b 5248(a0),d0
	move.b d0,2560(a1)
	move.b 5576(a0),d0
	move.b d0,2720(a1)
	move.b 5904(a0),d0
	move.b d0,2880(a1)
	move.b 6232(a0),d0
	move.b d0,3040(a1)
	move.b 6560(a0),d0
	move.b d0,3200(a1)
	move.b 6888(a0),d0
	move.b d0,3360(a1)
	move.b 7216(a0),d0
	move.b d0,3520(a1)
	move.b 7544(a0),d0
	move.b d0,3680(a1)
	move.b 7872(a0),d0
	move.b d0,3840(a1)
	move.b 8200(a0),d0
	move.b d0,4000(a1)
	move.b 8528(a0),d0
	move.b d0,4160(a1)
	move.b 8856(a0),d0
	move.b d0,4320(a1)
	move.b 9184(a0),d0
	move.b d0,4480(a1)
	move.b 9516(a0),d0
	move.b d0,4640(a1)
	move.b 9840(a0),d0
	move.b d0,4800(a1)
	move.b 10168(a0),d0
	move.b d0,4960(a1)
	add.l #1,a0
	add.l #1,a1

	add.l d1,a1
	move.l (a2)+,d1
	sub.l d1,a1
	add.l #12,a2
	
	move.b (a0),d0
	move.b d0,(a1)
	move.b 328(a0),d0
	move.b d0,160(a1)
	move.b 656(a0),d0
	move.b d0,320(a1)
	move.b 984(a0),d0
	move.b d0,480(a1)
	move.b 1312(a0),d0
	move.b d0,640(a1)
	move.b 1640(a0),d0
	move.b d0,800(a1)
	move.b 1968(a0),d0
	move.b d0,960(a1)
	move.b 2296(a0),d0
	move.b d0,1120(a1)
	move.b 2624(a0),d0
	move.b d0,1280(a1)
	move.b 2952(a0),d0
	move.b d0,1440(a1)
	move.b 3280(a0),d0
	move.b d0,1600(a1)
	move.b 3608(a0),d0
	move.b d0,1760(a1)
	move.b 3936(a0),d0
	move.b d0,1920(a1)
	move.b 4264(a0),d0
	move.b d0,2080(a1)
	move.b 4592(a0),d0
	move.b d0,2240(a1)
	move.b 4920(a0),d0
	move.b d0,2400(a1)
	move.b 5248(a0),d0
	move.b d0,2560(a1)
	move.b 5576(a0),d0
	move.b d0,2720(a1)
	move.b 5904(a0),d0
	move.b d0,2880(a1)
	move.b 6232(a0),d0
	move.b d0,3040(a1)
	move.b 6560(a0),d0
	move.b d0,3200(a1)
	move.b 6888(a0),d0
	move.b d0,3360(a1)
	move.b 7216(a0),d0
	move.b d0,3520(a1)
	move.b 7544(a0),d0
	move.b d0,3680(a1)
	move.b 7872(a0),d0
	move.b d0,3840(a1)
	move.b 8200(a0),d0
	move.b d0,4000(a1)
	move.b 8528(a0),d0
	move.b d0,4160(a1)
	move.b 8856(a0),d0
	move.b d0,4320(a1)
	move.b 9184(a0),d0
	move.b d0,4480(a1)
	move.b 9516(a0),d0
	move.b d0,4640(a1)
	move.b 9840(a0),d0
	move.b d0,4800(a1)
	move.b 10168(a0),d0
	move.b d0,4960(a1)

	add.l #7,a0
	add.l #7,a1

	add.l d1,a1
	move.l (a2)+,d1
	sub.l d1,a1
	add.l #12,a2


	dbra d7,putout

	rts


*################################################
*kollar och fixar buffertar
*################################################
fixbufferts: cmpi.l #16,antsteg
	bne chnybok
	add.l #8,buffer
	add.l #8,copybuff
	sub.l #41984,buffer
	sub.l #41984,copybuff
	add.l #8,bokaddr
	add.l #1,vword
	add.l #1,antword
	move.l #0,antsteg
	add.l #8,buffpos
	sub.l #41984,buffpos


chnybok:    	cmpi.l #2,vword
	bne omigbuff
	move.l #0,vword
	jsr getbok

omigbuff:	cmpi.l #41,antword
	bne startfrborj
	move.l #grafbuff,buffer
	move.l #grafbuff,copybuff
	add.l #168,buffer
	move.l #0,antword
	move.l #grafbuff,buffpos
	add.l #16,buffpos
	add.l #20,antword

	add.l #1,raknare


startfrborj:	rts

*################################################
*Vanta pa vsync
*################################################

wait:	cmpi.l #1,vtrue
	bne wait
	move.l #0,vtrue
	rts



*################################################
*Inladdning
*################################################
inladd:      MOVE.L #FILNAME,D5
             MOVE.L #fontbuff,D6
             MOVE.L #32128,D4
             JSR LADD

             RTS


LADD:        CLR.W -(SP)
             MOVE.L D5,-(SP)
             MOVE.W #$3D,-(SP)
             TRAP #1
             ADDQ.L #8,SP
             MOVE.W D0,HANDLE
                
                
             MOVE.L D6,-(SP)
             MOVE.L D4,-(SP)
             MOVE.W HANDLE,-(SP)
             MOVE.W #$3F,-(SP)
             TRAP #1
             ADD.L #12,SP
                
                
             MOVE.W HANDLE,-(SP)
             MOVE.W #$3E,-(SP)
             TRAP #1
             ADDQ.L #4,SP

	rts

*################################################
*Slutrut
*################################################

slut:        move.w palsave,$ff8240

	MOVE.W #8,-(SP)
             MOVE.W #26,-(SP)
             TRAP #14
             ADD.L #4,SP

	move.l vsave,$70
	move.b intmsk1,$fffa07
	move.b intmsk2,$fffa09

             move.w #1,-(sp)
             move.l #$f8000,-(sp)
             move.l #$f8000,-(sp)
             move.w #5,-(sp)
             trap #14
             add.l #12,sp


             MOVE.L SPSAVE,-(SP)
             MOVE.W #$20,-(SP)
             TRAP #1
             ADD.L #6,SP
             
	clr.w -(sp)
	trap #1


*################################################
*VBL interupt
*################################################
vsync:	move.l #1,vtrue
	rte

*################################################
*HBL interupt
*################################################
palshift:    move.w colour,$ff8242
	move.w #0,colour
             add.l #1,radrakn
	cmpi.l #73,radrakn
	ble ejnycol

	cmpi.l #127,radrakn
	bge ejnycol

             move.w (a6)+,colour

ejnycol:	cmpi.l #200,radrakn
	bne return
	move.l #0,radrakn
	move.l #raster,a6

return:      BCLR #0,$FFFA0F
             RTE

*vars
grafbuff	ds.b 45000
fontbuff	ds.b 33000

vtrue	ds.l 1
vsave	ds.l 1
antsteg	ds.l 1
screen	ds.l 1
buffer	ds.l 1
spsave	ds.l 1
vword	ds.l 1
antword	ds.l 1
copybuff	ds.l 1
pixplan	ds.l 1
bokaddr	ds.l 1
vbokword	ds.l 1
buffpos	ds.l 1
raknare	ds.l 1
palsave	ds.w 1
intmsk1	ds.w 1
intmsk2	ds.w 1
datapos	ds.l 1
datarakn	ds.l 1
textpos	ds.l 1
handle	ds.l 1
colour	ds.w 1
radrakn	ds.l 1

filname	dc.b 'slimeft.neo',0

raster	dc.w $100,$200,$300,$400,$500,$600,$700,$600,$500,$400,$300,$200,$100
	dc.w $011,$022,$033,$044,$055,$066,$077,$066,$055,$044,$033,$022,$011
	dc.w $771,$772,$773,$774,$775,$776,$777,$776,$775,$774,$773,$772,$771
	dc.w $010,$020,$030,$040,$050,$060,$070,$060,$050,$040,$030,$020,$010

tabaddr	dc.l 0,16,32,48,64,80,96,112,128,144
	dc.l 5120,5136,5152,5168,5184,5200,5216,5232,5248,5264
	dc.l 10240,10256,10272,10288,10304,10320,10336,10352,10368,10384
	dc.l 15360,15376,15392,15408,15424,15440

text	dc.b 'THIS IS THE NEW SUPER SCROLLER FROM GROWTWIG, AS USUAL WITH FONT DESIGN BY CEXOR'
	DC.B '. THIS TIME GROWTWIG HITS THE ROADS WITH A SINUS SCROLLER, COMPLETE WITH RASTER '
	DC.B '. THIS SCROLLER IS QUIT SIMPLE TO USE. ALL YOU NEED TO DO IS TO DESIGN A NICE FONT'
 	DC.B ', PUT IT ON A NEOCHROME PICTURE IN THE SAME WAY THAT THIS ONE IS, AND WRITE A TEXT'
	DC.B ' UNDER THE LABEL TEXT. THAT IS ALL. BYE, BYE                                ',0


DATA:        DC.L 2400,2400,2400,2560,2560,2560,2720,2720,2880,2880
             DC.L 2880,3040,3040,3040,3200,3200,3200,3360,3360,3360
             DC.L 3520,3520,3520,3520,3680,3680,3680,3680,3840,3840
             DC.L 3840,3840,3840,3840,3840,3840,3840,3840,3840,3840
             DC.L 3840,3840,3840,3840,3840,3840,3840,3840,3840,3840
             DC.L 3840,3680,3680,3680,3680,3680,3520,3520,3520,3520
             DC.L 3360,3360,3360,3200,3200,3200,3040,3040,3040,2880
             DC.L 2880,2720,2720,2720,2560,2560,2560,2400,2400,2240
             DC.L 2240,2240,2080,2080,1920,1920,1920,1760,1760,1600
             DC.L 1600,1600,1440,1440,1440,1280,1280,1280,1120,1120
             DC.L 1120,1120,960,960,960,960,960,800,800,800
             DC.L 800,800,800,800,800,800,800,800,800,800
             DC.L 800,800,800,800,800,800,800,800,800,800
             DC.L 960,960,960,960,1120,1120,1120,1120,1280,1280
             DC.L 1280,1440,1440,1440,1600,1600,1600,1760,1760,1760
             DC.L 1920,1920,1920,2080,2080,2240,2240,2240,2400,2400
             DC.L 2560,2560,2560,2720,2720,2880,2880,2880,3040,3040
             DC.L 3040,3200,3200,3200,3360,3360,3360,3520,3520,3520
             DC.L 3520,3680,3680,3680,3680,3680,3840,3840,3840,3840
             DC.L 3840,3840,3840,3840,3840,3840,3840,3840,3840,3840
             DC.L 3840,3840,3840,3840,3840,3840,3840,3840,3680,3680
             DC.L 3680,3680,3680,3520,3520,3520,3520,3360,3360,3360
             DC.L 3200,3200,3200,3040,3040,3040,2880,2880,2880,2720
             DC.L 2720,2560,2560,2560,2400,2400,2240,2240,2240,2080
             DC.L 2080,1920,1920,1920,1760,1760,1600,1600,1600,1440
             DC.L 1440,1440,1280,1280,1280,1280,1120,1120,1120,960
             DC.L 960,960,960,960,800,800,800,800,800,800
             DC.L 800,800,800,800,800,800,800,800,800,800
             DC.L 800,800,800,800,800,800,800,960,960,960
             DC.L 960,1120,1120,1120,1120,1280,1280,1280,1280,1440
             DC.L 1440,1440,1600,1600,1760,1760,1760,1920,1920,1920
             DC.L 2080,2080,2240,2240,2240



	  end