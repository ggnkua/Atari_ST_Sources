 	clr.l -(sp)		;Go into super mode.
 	move.w #$20,-(sp)
 	trap #1
 	add.l #6,sp
 	move.l D0,SAVESSP
	move.l	#raster_y,ystav20
	move.l	#raster_y+6,ystav19
	move.l	#raster_y+12,ystav18
	move.l	#raster_y+18,ystav17
	move.l	#raster_y+24,ystav16
	move.l	#raster_y+30,ystav15
	move.l	#raster_y+36,ystav14
	move.l	#raster_y+42,ystav13
	move.l	#raster_y+48,ystav12
	move.l	#raster_y+54,ystav11
	move.l	#raster_y+60,ystav10
	move.l	#raster_y+66,ystav9
	move.l	#raster_y+72,ystav8
	move.l	#raster_y+78,ystav7
	move.l	#raster_y+84,ystav6
	move.l	#raster_y+90,ystav5
	move.l	#raster_y+96,ystav4
	move.l	#raster_y+102,ystav3
	move.l	#raster_y+108,ystav2
	move.l	#raster_y+114,ystav1
	
	movem.l	$ff8240,d0-d7
	movem.l	d0-d7,colsav
	bsr	rastinit




KEYWAIT	move.b $fffc02,d0		;Wait for somebody to press F1
	cmp.b #$39,d0		;$3b is the code for SPACE
	bne KEYWAIT
	movem.l	colsav,d0-d7
	movem.l	d0-d7,$ff8240
	bsr RESTORE	
	
	clr.w -(sp)		;Quit with the correct GEMDOS call
	move.w #$4c,-(sp)
	trap #1



****************** SUB ROUTINES **************************

rastinit
SAVEMFP 	
	move.w sr,-(sp)		; datorn l†ser sig inte
	move.w #$2700,sr		; med dessa rader!!
	move.b $fffa07,MFPSAVE1		;save the MFP registers we use	
	move.b $fffa09,MFPSAVE2
	move.b $fffa13,MFPSAVE3
	move.b $fffa1b,MFPSAVE4
	move.b $fffa21,MFPSAVE5
	move.l $120,HBLSAVE
	move.l $70,VBLSAVE
	move.w (sp)+,sr

initrast
	move.w sr,-(sp)		; datorn l†ser sig inte
	move.w #$2700,sr		; med dessa rader!!
	
	move.b #1,$fffa07		; only timer B running
	clr.b $fffa09		; turn off anything else
	or.b #1,$fffa13		; turn on timer B
	move.b #8,$fffa1b		; Event count mode
	move.b #1,$fffa21		; HBL ints should occur every raster line
	move.l #HBL,$120		; $120 points to my own HBL routine
	move.l #VBL,$70		; $70 points to the VBL routine
	move.w (sp)+,sr
	
	rts


RESTORE
	
	move.w sr,-(sp)		; datorn l†ser sig inte
	move.w #$2700,sr		; med dessa rader!!
	move.b MFPSAVE1,$fffa07		;Restore MFP registers
	move.b MFPSAVE2,$fffa09
	move.b MFPSAVE3,$fffa13
	move.b MFPSAVE4,$fffa1b
	move.b MFPSAVE5,$fffa21
	move.l HBLSAVE,$120
	move.l VBLSAVE,$70
	move.w (sp)+,sr
  	
  	move.l SAVESSP,-(SP)	;Go back to user mode
 	move.w #$20,-(SP)
 	trap #1
 	addq.l #6,SP
 	rts
 	



********************** HBL interrupt handler... *****************


HBL
	move.w	(a6)+,$ffff8240.w	* ut med en farg
 	bclr.b 	#0,$fffa0f	;Timer B on again
 	rte

 	
********************* .....and the  VBL ********************* 	

VBL
 	move.l	a5,-(sp)
 	move.l	a4,-(sp)
 	move.l	d0,-(sp)
 	move.l	d7,-(sp)
 	lea	rastercol,a6	* restore de 200 fargerna
	lea	rastercol,a5	
	REPT	100
	move.l	#0,(a5)+		* rensa alla 200 rasterraderna
	ENDR

	move.l	#19,d7		* antal stavar-1 
	lea	rastercol,a5
	lea	rasterstav_20,a4
 	move.l	#ystav20,a0
rnewy	moveq.l	#0,d0
	move.l	(a0),a1		* ladda i forst stavyled
 	move.w	(a1),d0		* yled i d0
 	cmp.w	#$ffff,d0
 	bne	go_1
 	move.l	#raster_y,(a0)
 	bra.s	rnewy
go_1 	lsl	#1,d0
 	add.l	d0,a5		* address i a5
 	REPT	11
 	move.w	(a4)+,(a5)+
	ENDR
	add.l	#2,(a0)		* plus ett i yled
	lea	rastercol,a5
	add.l	#4,a0
	dbf	d7,rnewy
	move.l	(sp)+,d7
	move.l	(sp)+,d0
	move.l	(sp)+,a4
	move.l	(sp)+,a5
	rte	
 	
SAVESSP		ds.l 1
MFPSAVE1		ds.w 1
MFPSAVE2		ds.w 1
MFPSAVE3		ds.w 1
MFPSAVE4		ds.w 1
MFPSAVE5		ds.w 1
VBLSAVE		ds.l 1
HBLSAVE		ds.l 1
colsav		ds.b	32
	EVEN
raster_y		include	"a:\yled5.dat"
raster_yend
		dc.w	$ffff

	* The background colors,one for each line.

rasterstav_20
	REPT	2
	dc.w	$211,$400,$500,$600,$721,$714,$721,$600,$500,$400,$211
	dc.w	$315,$305,$405,$505,$605,$705,$605,$505,$405,$305,$315
	dc.w	$225,$335,$445,$555,$665,$775,$665,$555,$445,$335,$225
	dc.w	$114,$224,$334,$444,$554,$664,$554,$444,$334,$224,$114
	dc.w	$304,$307,$417,$527,$637,$747,$637,$527,$417,$307,$304
	dc.w	$213,$313,$413,$513,$613,$713,$613,$513,$413,$313,$213
	dc.w	$002,$013,$123,$233,$343,$453,$343,$233,$123,$013,$002
	dc.w	$202,$312,$422,$532,$642,$752,$642,$532,$422,$312,$202
	dc.w	$211,$321,$431,$541,$651,$761,$651,$541,$413,$321,$211
	dc.w	$011,$121,$231,$341,$451,$561,$451,$341,$231,$121,$011
	ENDR
	
	
rastercol
	ds.w	200
ystav20	ds.l	1
ystav19	ds.l	1
ystav18	ds.l	1
ystav17	ds.l	1
ystav16	ds.l	1
ystav15	ds.l	1
ystav14	ds.l	1
ystav13	ds.l	1
ystav12	ds.l	1
ystav11	ds.l	1
ystav10	ds.l	1
ystav9	ds.l	1
ystav8	ds.l	1
ystav7	ds.l	1
ystav6	ds.l	1
ystav5	ds.l	1
ystav4	ds.l	1
ystav3	ds.l	1
ystav2	ds.l	1
ystav1	ds.l	1

 