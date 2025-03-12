*****************************************
* SOURCE CODE FOR THE DEF DEMO MAIN SCREEN
* BY MANIKIN OF THE LOST BOYS
* DO NOT SPREAD THIS SOURCE, IF WE EVER FIND A 
* SPREAD COPY THEN WE WILL NEVER DO THIS AGAIN
* IF WE FIND WHO SPREAD IT THEY WILL BE BLACKED
******************************************
* THE FILE BALLS.DAT IS AN EXTENDED DEGAS PICTURE
* MADE UP OF 236 LINES AND WITH THE HEADER REMOVED
* IE 236*160BYTES = 37760
*
* LOST. FON IS A CHARACTER SET CONTAINING 60 CHARACTERS
* EACH CHARCTERIS 32 LINES HIGH AND IS ONE PLANE OF A SCREEN
* IT IS 4 BYTES WIDE. IT CAN BE MADE BY TAKEING ONLY EVERY 2 BYTES FROM EVERY8
* IN A SUITABLY DRAWN DEGAS PICTURE
*
* BARREL.PAK	THIS IS A PACKED FILE BUT YOU SHOULD HAVE NO TROUBLE WORKING OUT THE FORMAT OF 
* THE UNPACKED VERSION FROM THE SOURCE CODE.
* EACH LINE OF GRAPHIX IS AGAIN ONE PLAIN AND IS  12 BYTES ACROSS
* 
* IF YOU HAVE ANY PROBLEMS THEN PLEASE CONTACT ME AGAIN
* MANIKIN

iea	equ $fffa07		VARIOUS USEFUL ADDRESSES THAT PROBABLY
ieb	equ $fffa09		ARE NOT USED!!
isra	equ $fffa0f
ima	equ $fffa13

tbcr	equ $fffa1b
tbdr 	equ $fffa21
scrn_ram	equ $ff8201
syspal	 	equ $ff8240
col1	equ $ff8250
shftmod	equ $ff8260
vbl	equ $70
key	equ $118
hbl	equ $120
rawin	equ $7
smode	equ $20

	pea string			turn off mouse
	move.w #$1,-(sp)
	move.w #25,-(sp)
	trap #14
	addq.l #8,sp
	move.l #$7d300,phys1		scroll
	move.l #scrolline,store
	move.l #mystack,-(sp)		supervisor
	move.w #$20,-(sp)
	trap #1
	add.l #6,sp
	move.b #4,$484			TURN OFF KEY REPEAT/KLICK
	MOVE.L #$76000,A0		CLEAR MAIN SCREENS
	MOVE.W #10238,D0
CLMAIN	CLR.L (A0)+
	DBF D0,CLMAIN
	clr.w -(sp)			load main picture
	pea filename1
	move.w #$3d,-(sp)
	trap #1
	addq.l #8,sp
	move.w d0,handle	
	move.l #$76000,-(sp)
	move.l #$ffff,-(sp)
	move.w handle,-(sp)
	move.w #$3f,-(sp)
	trap #1
	add.l #12,sp
	move.w handle,-(sp)
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp
	move.w #$0,$ff8240		LOAD MUSICLOADER GRAPHIX
	pea BAZ				OPEN
	move.w #$3d,-(sp)
	trap #1
	addq.l #8,sp
	move.w d0,handle	
	move.l #$50000-4,-(sp)
	move.l #$ffff,-(sp)
	move.w handle,-(sp)
	move.w #$3f,-(sp)		READ 
	trap #1
	add.l #12,sp
	move.w handle,-(sp)
	move.w #$3e,-(sp)
	trap #1				FILE
	addq.l #4,sp
	move.l $50000-4,d0
	add.l #$50000,d0
	move.l d0,READ1
	MOVEA.L READ1,A0
	MOVE.L #$50000,A1
	BSR DEPACK			DEPACK
	pea terx			clearscreen
	move.w #$9,-(sp)
	trap #1
	addq.l #6,sp
	move.w #-1,-(sp)		set phys/log
	move.l #$76000,-(sp)
	move.l #$76000,-(sp)
	move.w #5,-(sp)
	trap #14
	add.l #12,sp
	move.w #$f,d0
	lea syspal,a1			save palette
	lea oldpal,a0
sp	move.w (a1)+,(a0)+		save various registers
	dbra d0,sp			(NOT REALLY NEEDED AS YOU CAN'T
	lea oldieb,a1			LEAVE OUR DEMO ANYWAY!!)
	move.b ieb,(a1)
	lea oldiea,a1
	move.b iea,(a1)
	lea oldima,a1
	move.b ima,(a1)
	lea oldshftmod,a1
	move.b shftmod,(a1)
	lea oldkey+2,a1
	move.l key,(a1)
	lea keyhand,a0			put in new key handler
	move.l a0,key
	and.b #$df,ieb
	and.b #$fe,iea
	lea oldhbl,a1
	move.l hbl,(a1)
	lea hblhand,a0			put in new timer b
	move.l a0,hbl
	or.b #1,iea
	or.b #1,ima
	move.b #0,shftmod		SET LOW RES
	lea oldvbl+2,a1			SAVE VBL
	move.l vbl,(a1)
	lea vblhand,a0			put in new vbl
	move.l a0,vbl
	move.l #$07370747,$ff825c	SET SOME COLORS
	move.l #$06060717,$ff8258	everything runs from vbl
	move.w #$404,$ff8256		so now its time for
u	bra select			keyboard monitoring!!!

*********************************
* THE DEPACKER BY SPROG 
* I'M AFRAID THAT I CANNOT COMMENT THIS AS IT WAS NICKED STRAIGHT
* FROM THE AMIGA AND I DO NOT HAVE A CLUE AS TO HOW IT WORKS
**********************************
   		
DEPACK			*sprogs depacker
	MOVE.L	-(A0),A2
	ADDA.L	A1,A2
	MOVE.L	-(A0),D5
	MOVE.L	-(A0),D0
	EOR.L	D0,D5
NOTFINISHED
	LSR.L	#1,D0
	BNE.S	NOTEMPTY1
	JSR	GETNEXTLWD
NOTEMPTY1
	BCS.S	BIGONE
	MOVEQ	#8,D1
	MOVEQ	#1,D3
	LSR.L	#1,D0
	BNE.S	NOTEMPTY2
	JSR	GETNEXTLWD
NOTEMPTY2
	BCS.S	DODUPL
	MOVEQ	#3,D1
	CLR.W	D4
DOJMP
	JSR	RDD1BITS
	MOVE.W	D2,D3
	ADD.W	D4,D3
GETD3CHR
	MOVEQ	#7,D1
GET8BITS
	LSR.L	#1,D0
	BNE.S	NOTEMPTY3
	JSR	GETNEXTLWD
NOTEMPTY3
	ROXL.L	#1,D2
	DBF	D1,GET8BITS
	MOVE.B	D2,-(A2)
	DBF	D3,GETD3CHR
	JMP	NEXTCMD
BIGJMP	
	MOVEQ	#8,D1
	MOVEQ	#8,D4
	JMP	DOJMP
BIGONE
	MOVEQ	#2,D1
	JSR	RDD1BITS
	CMP.B	#2,D2
	BLT.S	MIDJMPS
	CMP.B	#3,D2
	BEQ.S	BIGJMP
	MOVEQ	#8,D1
	JSR	RDD1BITS
	MOVE.W	D2,D3
	MOVE.W	#12,D1
	JMP	DODUPL
MIDJMPS
	MOVE.W	#9,D1
	ADD.W	D2,D1
	ADDQ.W	#2,D2
	MOVE.W	D2,D3
DODUPL
	JSR	RDD1BITS
COPY3BYTES
	SUBQ	#1,A2
	MOVE.B	(A2,D2.W),(A2)
	DBF	D3,COPY3BYTES
NEXTCMD
	CMP.L	A2,A1
	BLT.W	NOTFINISHED
	TST.L	D5
	BNE.S	DAMAGE

* FINISHED DEPACKING !

	RTS

DAMAGE
	MOVE.W	#-1,D0
DAMLOOP
	SUBI.L	#1,D0
	BNE.S	DAMLOOP
	
* IT'S SEVERELY FUCKED

	RTS	

GETNEXTLWD

	MOVE.L	-(A0),D0
	EOR.L	D0,D5
	MOVE.W	#$10,CCR
	ROXR.L	#1,D0
	RTS
	
RDD1BITS

	SUBQ.W	#1,D1
	CLR.W	D2
GETBITS
	LSR.L	#1,D0
	BNE.S	NOTEMPTY
	MOVE.L	-(A0),D0
	EOR.L	D0,D5
	MOVE.W	#$10,CCR
	ROXR.L	#1,D0
NOTEMPTY
	ROXL.L	#1,D2
	DBF	D1,GETBITS
	RTS
OLDY	DS.L	1
READ1	DC.L	0

***************
*END OF DEPACKER
***************
**********************************************
* THIS IS THE ROUTINE FOR THE RIPPLING COLORS ON THE MAIN SCREEN 
***********************************************
	
letcount	dc.w 3
paletterpoint	dc.l letterpal
paletterpoint1	dc.l letterpal1
letterpal dc.w $0,$1,$2,$3,$4,$5,$6,$7,$6,$5,$4,$3,$2,$1,$0
	dc.w $111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$0
	dc.w $11,$22,$33,$44,$55,$66,$77,$66,$55,$44,$33,$22,$11
	dc.w $0,0,0,0,0,0,0,0,$10,$20,$30,$40,$50,$60,$70,$60,$50,$40,$30,$20,$10,$0
letterpalend
	 dc.w $0,$1,$2,$3,$4,$5,$6,$7,$6,$5,$4,$3,$2,$1,$0
letterpal1	dc.w $111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$0
		dc.w $101,$202,$303,$404,$505,$606,$707,$606,$505,$404,$303,$201,$101,$0
		dc.w $110,$220,$330,$440,$550,$660,$770,$660,$550,$440,$330,$220,$110,$0
letterpalend1
	dc.w $111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$0
the_cols	sub.w #1,letcount
		bne.s letterend
		move.w #3,letcount
		add.l #2,paletterpoint
		add.l #2,paletterpoint1
		cmp.l #letterpalend,paletterpoint
		bne.s letterend
		move.l #letterpal,paletterpoint
letterend	cmp.l #letterpalend1,paletterpoint1
		bne.s the_letter
		move.l #letterpal1,paletterpoint1
the_letter	rts

******************************
* VARIOUS INTERUPTS USED TO CREATE THE MAIN SCREEN
******************************


keyhand					*the keyboard vector
	move #$2500,sr
oldkey  jmp $0

hblhand	move.w #$2500,sr		the timer b
	move.l a1,-(sp)
	move.l palpoint,a1
	move.l (a1)+,$ff8240		SET COLORS
	move.l (a1)+,$ff8244
	move.l (a1)+,$ff8248
	move.w (a1)+,$ff824c
	move.l a1,palpoint
	move.l (sp)+,a1
	sub.w #1,barcount		1 LESS TO GO!!
	beq hblend2
	bclr #0,isra
	move.b #1,tbdr			1 TO MFP B DATA REG
	rte
hblend2
	move.l #colhbl,$120		the next timer b
	move.b #0,tbcr
	move.b #1,tbdr
	move.b #8,tbcr
	bclr #0,isra
	rte
ball1hbl	movem.l a1-a2,-(sp)	another timer b
	lea $ff8240,a2			this one looks after the
	move.l ball1pal,a1		balls!
	MOVE.L (A1)+,(A2)+
	move.l (a1)+,(a2)+		don't be dirty!!
	move.l (a1)+,(a2)+
	move.l (a1)+,(a2)+		THE ENTIRE PALETTE IS SWAPPED
	move.l (a1)+,(a2)+		TWICE PER LINE TO GET EXTRA COLORS
	move.w (a1)+,(a2)+		THATS WHY THERE ARE TWO SETS
	sub.w #1,ballcount		OF COLOR CHANGES
	beq.s b1end
	move.b #1,tbdr
	lea $ff8244,a2
	move.l (a1)+,(a2)+
	move.l (a1)+,(a2)+
	move.l (a1)+,(a2)+
	move.l (a1)+,(a2)+
	move.w (a1)+,(a2)+
	move.l a1,ball1pal
	movem.l (sp)+,a1-a2
	bclr #0,isra
	rte

b1end	move.b #0,tbcr		an alternative ending
	move.b #1,tbdr
	move.b #8,tbcr
	move.l #hblhand,$120
	movem.l (sp)+,a1-a2
	bclr #0,isra
	rte
colhbl	
	move.l #$00000300,$ff8240	yet another hbl
	move.l #$04000512,$ff8244
	move.l #$06220733,$ff8248
	move.l #$07440766,$ff824c
	move.w #$0000,$ff8250
	move.l a2,-(sp)
	move.l paletterpoint1,a2
	move.w (a2)+,$ff8252		THIS DOES RIPPLING LETTERS ABOVE THE SCROLL
	move.l (a2)+,$ff8254
	move.l (a2)+,$ff8258
	move.l (a2)+,$ff825c
	move.l (sp)+,a2
	move.b #0,tbcr
	move.b #23,tbdr
	move.b #8,tbcr
	move.l #colhbl2,$120
	bclr #0,isra
	rte
colhbl2	move.l #$00000001,$ff8250
	move.l #$00020003,$ff8254
	move.l #$00040005,$ff8258
	move.l #$00060007,$ff825c
	move.b #0,tbcr
	move.b #19,tbdr
	move.b #8,tbcr
	move.l #bborderhbl,$120
	bclr #0,isra
	rte

bborderhbl	clr.b $fffffa1b			timer stop
	movem.l d0-d1/a0-a1,-(sp)		this hbl handles bottom
	move.w #$fa21,a1		border. Precise timing means that
	move.b #17,(a1)		those 16 missing pixels are there
	move.b #8,$fffffa1b		again
	
	move.b (a1),d0
wait	cmp.b (a1),d0			auf ende der letzten zeile warten
	beq wait
*					wir sind rechts im rand
	clr.b $ffff820a			60Hz
	
	moveq #3,d0
nopi2	nop				ein wenig warten
	dbf d0,nopi2		
*					wir sind im linken rand
	move.b #2,$ffff820a		50Hz
	movem.l (sp)+,d0-d1/a0-a1
	move.l #colslethbl,$120
	bclr #0,$fffffa0f		end of interrupt
	rte
					*sorry Sammy Joe (he's German)
					*typed this in!!		
colslethbl				* THIS DOES THE RIPPLING COLORS IN THE LETTERS AT THE BOTTOM
		move.l a2,-(sp)
		move.l paletterpoint,a2
		move.w (a2)+,$ff8252
		move.l (a2)+,$ff8254
		move.l (a2)+,$ff8258
		move.l (a2)+,$ff825c
	move.l (sp)+,a2
	move.b #0,tbcr
	move.b #100,tbdr
	move.b #8,tbcr
	bclr #0,$fffffa0f		end of interrupt
	rte

duffhbl					*save turning it off!!!
	move.b #2,tbdr
	bclr #0,isra
	rte
vblhand					*the very mega vbl for the main screen
	movem.l d0-d7/a0-a6,-(sp)
	move.w #$222,$ff8240
	
	move.l #palettes,palpoint	PUT BARS IN POINTER
	move.w #81,barcount		DO 81 LINES FOR OF BARS
	move.w #75,ballcount		DO 75 LINES OF BALLS
	move.l #ball1,ball1pal		FIRST SET OF BALLS
	move.b #0,tbcr
	move.b #1,tbdr
	move.b #8,tbcr
	move.l #ball1hbl,$120		BALLS IN HBL FIRST
	move.l #$07370747,$ff825c
	move.l #$06060717,$ff8258
	move.w #$404,$ff8256
	bsr do_scroll		this does the scroll
	bsr clrbar		this clears the bars
	bsr drawbars		this redraws them
	bsr the_cols
	sub.w #1,colcount
	beq change		this does the piccy at the top
tret	addq.b #1,count1	this checks for a new letter IN SCROLL
	cmp.b #8,count1
	beq nextlet		this gets it if required!
	movem.l (sp)+,d0-d7/a0-a6
	rte
oldvbl	jmp $0
colcount	dc.w 2
colpos	dc.l colpal
addtab	dc.l 60,48,36,24,24,12,12,12,12,0,12,0,0,12,0,0,0,12,0,0,0,0,12
	dc.l 0,0,0,0,0,0,0
	dc.l 12,0,0,0,0,12,0,0,0,12,0,0,12,0,12,12,12,12,24,24,36,48,60
	dc.l 0,0,0
****************************************
*  THIS IS THE BENDING GRAPHIX AROUND A BAR ROUTINE!!!
*
* THE DATA ABOVEREFERS TO THE AMOUNT THAT MUST BE ADDED TO THE GRAPHIX 
* POINTER BEFORE DRAWING NEXT LINE THUS THE GRAPHIX CAN BE BENT AROUND THE BAR
* USING A SUITABLY CONSTRUCTED TABLE
****************************************
change 	move.w #2,colcount		this routine bends the picture around 
	move.l colpos,a1		the bar. The above table tells
	move.l a1,a4			it how.
back	move.l #$767b8,a2
	move.l #addtab,a3
	move.w #53,d1
lloop	move.w (a1)+,(a2)		MOVE 1 PLANE OF GRAPHIX TO THE SCREEN
	move.w (a1)+,8(a2)
	move.w (a1)+,16(a2)
	move.w (a1)+,24(a2)
	move.w (a1)+,32(a2)
	move.w (a1)+,40(a2)
	add.l (a3)+,a1			ADD TABLE OFFSET
	add.l #160,a2			ADD 1 LINE OF SCREEN
	dbf d1,lloop
	cmp.l #colpalend,a4
	beq.s herego
	add.l #12,a4
	move.l a4,colpos
	bra tret
herego	 move.l #colpal,colpos
	bra tret
paletpoint	dc.l palet
clrbar	move.l #palettes,a1		the bye bye bars routine.
	move.w #100,d0
	move.l paletpoint,a2		this routine does the moving
	add.l #2,a2			palette in side the rotating
	cmp.l #paletend,a2		bars.
	bne.s hear
	move.l #palet,paletpoint
	bra.s clearloop
hear	move.l a2,paletpoint
clearloop	move.l #correct,a0
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.w (a2)+,(a1)+
	dbf d0,clearloop
	rts
swapbar	cmp.w #1,bartype	back bar to front front bar to back
	beq.s swapbar2
	move.w #1,bartype
	move.l #bar1,btype1
	move.l #bar2,btype2
	rts
swapbar2	clr.w bartype
	move.l #bar2,btype1
	move.l #bar1,btype2
	rts	
swapbar3	cmp.w #1,bartype1	as above but for second set OF BARS
	beq.s swapbar4
	move.w #1,bartype1
	move.l #bar3,btype3
	move.l #bar4,btype4
	rts
swapbar4	clr.w bartype1
	move.l #bar4,btype3
	move.l #bar3,btype4
	rts	

*\	the bars are drawn into a large palette.
*\	some are drawn into all colours whilst others are not
*\	this depends on whether they go in front or behind graphix
*\	No movement of graphix and the hbl is quick. Good weeze huh!
*	WHEN A BAR REACHES THE TOP OR BOTTOM OF ITS TRACK IT CHANGES 
*	BECOMING EITHER A BAR IN FRONT OR A BAR BEHIND.
*	THIS IS DONE BY SWITCHING THE POINTERS TO THE PALETTES FOR THE 
*	BAR SO THAT THE NEW PALETTES MAKE THE BAR GO IN FRONT OR BEHIND THE GRAPHIX
*	I.E IF IN FRONT THEN TURN ALL COLORS TO BAR COLOR IF BEHIND THEN ONLY BACKGROUND
*	EACH SINGLE BIT IS TO COMPLICATED TO LABEL BUT YOU SHOULD BE ABLE TO UNDERSTAND 
*	THE BASIC TECHNIQUE FROM THIS EXPLANATION.


drawbars	move.l point1,a0	draw bars time
		move.w (a0)+,pdraw1
		move.l a0,point1
		cmp.l #rotab2,a0
		bne.s drawbars2
		move.l #rottab,point1
		bsr swapbar
		bra.s drawbars
drawbars2	move.l point2,a0
		move.w (a0)+,pdraw2
		move.l a0,point2
		cmp.l #rotabend,a0
		bne.s drawbars3
		move.l #rotab2,point2
		bra.s drawbars2
drawbars3
		move.l point3,a0
		move.w (a0)+,pdraw3
		move.l a0,point3
		cmp.l #rotab2,a0
		bne.s drawbars4
		move.l #rottab,point3
		bsr swapbar3
		bra.s drawbars3
drawbars4
		move.l point4,a0
		move.w (a0)+,pdraw4
		move.l a0,point4
		cmp.l #rotabend,a0
		bne.s drawbars5
		move.l #rotab2,point4
		bra.s drawbars4
drawbars5
		move.w pdraw2,d0
		mulu	#7,d0
		add.l #palettes,d0
		move.l d0,a0
		move.l btype2,a1
		move.w #14,d0
dloop2		move.w (a1)+,(a0)+
		add.l #12,a0
		dbf d0,dloop2

		move.w pdraw4,d0
		mulu	#7,d0
		add.l #palettes,d0
		move.l d0,a0
		move.l btype4,a1
		move.w #14,d0
dloop9		move.w (a1)+,(a0)+
		add.l #12,a0
		dbf d0,dloop9
		move.l #palettes+406,a0
		move.l #mainbar,a1
		move.w #18,d0
mbar		move.w (a1)+,(a0)+
		add.l #12,a0
		dbf d0,mbar
		move.w pdraw1,d0
		mulu	#7,d0
		add.l #palettes,d0
		move.l d0,a0
		move.l btype1,a1
		move.w #14,d0
dloop1		move.w (a1),(a0)+
		move.w (a1),(a0)+
		move.w (a1),(a0)+
		move.w (a1),(a0)+
		move.w (a1),(a0)+
		move.w (a1),(a0)+
		move.w (a1),(a0)+
		add.l #2,a1
		dbf d0,dloop1

		move.w pdraw3,d0
		mulu	#7,d0
		add.l #palettes,d0
		move.l d0,a0
		move.l btype3,a1
		move.w #14,d0
dloop11		move.w (a1),(a0)+
		move.w (a1),(a0)+
		move.w (a1),(a0)+
		move.w (a1),(a0)+
		move.w (a1),(a0)+
		move.w (a1),(a0)+
		move.w (a1),(a0)+
		add.l #2,a1
		dbf d0,dloop11
		rts
******************
*THESE VARIABLES GIVE THE BARS COLORS AND POSITIONS IN THE TABLE
****************

ball1pal	dc.l ball1
bartype		dc.w 1
btype1		dc.l bar1
btype2		dc.l bar2
bartype1	dc.w 1
btype3		dc.l bar3
btype4		dc.l bar4
palpoint	dc.l palettes
terx	dc.b $1b,$45,0,0
point1		dc.l rottab
point2		dc.l rotab2
point3		dc.l rottab+66
point4		dc.l rotab2+66
pdraw1		dc.l 0
pdraw2		dc.l 0
pdraw3		dc.l 0
pdraw4		dc.l 0
barcount	dc.w 0
ballcount	dc.w 0
ballcount1	dc.w 0

********************
*THE TABLES TELLING IT THE OFFSETS INTO THE TABLE FOR THE BARS
*IE THIS MAKES THEM MOVE FASTER OR SLOWER AROUND THE CENTRAL GRAPHIX
****************

rottab		dc.w 0,0,0,0,0,2,2,2,2,2,4,4,4,4,6,6,6,6,8,8,8,10,10
		dc.w 12,12,14,16,18,20,24,28,32,38,44,50,56,64
		dc.w 72,78,84,90,96,100,104,108,110,112,114,116,116
		dc.w 118,118,120,120,120,122,122,122,122,124,124,124,124
		dc.w 126,126,126,126,126

rotab2		dc.w 128,128,128,128,128
		dc.w 126,126,126,126,126,124,124,124,124,122,122,122,122
		dc.w 120,120,120,118,118,116,116,114,112,110,108,104,100
		dc.w 96,90,84,78,72,64,56,50,44,38,32,28,24,20,18,16,14,12,12
		dc.w 10,10,8,8,8,6,6,6,6,4,4,4,4,2,2,2,2,2

rotabend
		
bar1		dc.w $0,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$0

bar2		dc.w $000,$100,$200,$300,$400,$500,$600,$700,$600,$500,$400,$300,$200,$100,$0
bar3		dc.w $0,$1,$2,$3,$4,$5,$6,$7,$6,$5,$4,$3,$2,$1,$0

bar4		dc.w $000,$10,$20,$30,$40,$50,$60,$70,$60,$50,$40,$30,$20,$10,$0
mainbar		dc.w $220,$332,$442,$443,$553,$554,$664,$665,$775,$776
		dc.w $775,$665,$664,$554,$553,$443,$442,$332,$220


*	THE BALLS PALETTE. (THE 4 DIFFERENT COLORED BALLS AT THE TOP OF
*	THE SCREEN ARE OBTAINED BY CHANGING SOME OF THE COLORS IN THE MIDDLE OF
*	THE BALL ON A PRECISELY TIMED HBL (SEE ABOUT 6 PAGES ABOVE)

*\	the palette below is very large. At the time it seemed like 
*\	a good idea. I can now think of better ways, but it works
*\	so why change it!! It is for the balls by the way.

ball1
		dc.w $222,$777
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $222,$777
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $404,$222
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $606,$222
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $717,$222
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $737,$222
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $747,$222
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $737,$222
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $717,$222
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $606,$222
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $404,$222
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
cstart		dc.w $100,$033
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $200,$044
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $300,$055
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $400,$066
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $500,$077
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $500,$077
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $600,$177
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $600,$177
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $700,$277
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $700,$277
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $710,$377
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $710,$377
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $721,$477
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $721,$477
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $721,$477
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $732,$577
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $732,$577
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $732,$577
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $743,$677
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $743,$677
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $743,$677
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $754,$777
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $754,$777
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $754,$777
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $754,$777
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $754,$777
		dc.w $200,$300,$400,$500,$512,$622,$723,$734,$746
		dc.w $20,$30,$40,$50,$251,$262,$272,$373,$474
		dc.w $754,$777
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $754,$777
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $754,$777
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $754,$777
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $754,$777
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $754,$777
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $743,$677
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $743,$677
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $743,$677
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $743,$677
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $732,$577
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $732,$577
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $732,$577
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $721,$477
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $721,$477
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $721,$477
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $710,$377
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $710,$377
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $700,$277
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $700,$277
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $600,$177
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $600,$177
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $500,$077
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $500,$077
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $400,$066
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $300,$055
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $200,$044
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $100,$033
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $404,$222
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $606,$222
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $717,$222
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $737,$222
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $747,$222
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $737,$222
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $717,$222
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $606,$222
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $404,$222
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $222,$222
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $222,$222
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $222,$222
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $222,$777
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $222,$777
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $222,$777
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $222,$777
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447
		dc.w $222,$777
		dc.w $220,$330,$440,$550,$552,$662,$773,$774,$776
		dc.w $2,$3,$4,$5,$215,$226,$327,$337,$447

******************
*THIS PALETTE IS FOR THE NICE COLORS THROUGH THE LETTERS IN THE MIDDLE OF THE SCREEN
***************

palet
	dc.w $37
	dc.w $27,$27,$17,$17,$7,$7,$107,$107,$207,$207,$307,$307,$407
	dc.w $407,$507,$507,$607,$607,$707,$707,$706,$706,$705,$705
	dc.w $710,$710,$720,$720,$730,$730,$740,$740,$750,$750,$760
	dc.w $760,$770,$770,$670,$670,$570,$570,$470,$470,$370,$370
	dc.w $270,$270,$170,$170,$70,$70,$71,$71,$72,$72,$73,$73,$74
	dc.w $74,$75,$75,$76,$76,$77,$77,$67,$67,$57,$57,$47,$47,$37
	dc.w $37
paletend
	dc.w $37
	dc.w $27,$27,$17,$17,$7,$7,$107,$107,$207,$207,$307,$307,$407
	dc.w $407,$507,$507,$607,$607,$707,$707,$706,$706,$705,$705
	dc.w $710,$710,$720,$720,$730,$730,$740,$740,$750,$750,$760
	dc.w $760,$770,$770,$670,$670,$570,$570,$470,$470,$370,$370
	dc.w $270,$270,$170,$170,$70,$70,$71,$71,$72,$72,$73,$73,$74
	dc.w $74,$75,$75,$76,$76,$77,$77,$67,$67,$57,$57,$47,$47,$37
	dc.w $37

*****************
*BLANK PALETTES FOR THE MOVING BARS IN THE MAIN SCREEN
*THE PROGRAM FILLS IN THE DAT AS APPLICABLE (SEE ROUTINES)
****************

palettes	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
correct	dc.w $222,$332,$443,$554,$665,$776,$040

*********************
*THE SCROLL ROUTINE FOR THE 32X32 SCROLL ON THE MAIN SCREEN
*******************

nextlet		clr.b count1		new letter routine for the 
movlet
		MOVEQ #0,D0
		move.l store,a0		crystal scroll
		move.b (a0)+,d0		GET LETTER
		cmp.b #$ff,d0		TEST FOR END
		beq wrap
		subi.b #$20,d0		ADJUST FOR OUR FONT
		move.L a0,store
		mulu #128,d0		
		LEA font,a0		GET FONT POSITION
		add.l d0,a0
		lea data,a1
		move.w #31,d0
there		move.w (a0),6(a1)	MOVE DATA TO LETTER STORE
		move.w 2(a0),14(a1)

		adda.l #16,a1				
		addq.l #4,a0
		dbf d0,there
		movem.l (sp)+,d0-d7/a0-a6

		rte

do_scroll:      move.w  #3,d1  		MOVE AT 4 PIXELS PER FRAME
dosy		move.w #31,d0		32 LINES HIGH
		lea data,a1		GET LETTER STORE
		movea.l phys1,a0	GET SCREEN POS
dosy1:           
		lsl.w  14(a1)
                roxl.w  6(a1)   ; the letters are 32 pixels wide
                roxl.w  158(a0) ; scroll the screen
                roxl.w  150(a0) ; steps of -8, scroll one plane
                roxl.w  142(a0)
                roxl.w  134(a0)
                roxl.w  126(a0)
                roxl.w  118(a0)
                roxl.w  110(a0)
                roxl.w  102(a0)
                roxl.w  94(a0)
                roxl.w  86(a0)
                roxl.w  78(a0)
                roxl.w  70(a0)
                roxl.w  62(a0)
                roxl.w  54(a0)
                roxl.w  46(a0)
                roxl.w  38(a0)
                roxl.w  30(a0)
                roxl.w  22(a0)
                roxl.w  14(a0)
                roxl.w  6(a0)
                adda.l  #16,a1 
		add.l #160,a0		
                dbra    d0,dosy1 ; do the next screen line
		dbra    d1,dosy
                rts             ; end of routine

wrap 		move.b #$20,d0		SCROLL WRAP ROUTINE
		lea scrolline,a0
		move.l a0,store
		movem.l (sp)+,d0-d7/a0-a6
		rte
*************************
*THIS IS THE KEYBOARD MONITOR ROUTINE FROM THE MAIN SCREEN
************************

select			
	bra.s select

BAZ	DC.B "BARREL.pak",0
	EVEN
colpal	EQU $50000
colpalend	equ	colpal+3600	


******************************
* STANDARD FONT
******************************

phys1	dc.l 0
handle	dc.l 0
store	dc.l 0
	ds.l 100
mystack	ds.l 10
font
	incbin "lost.fon"
oldssp	dc.l 0
oldpal	ds.w 16
oldiea	ds.b 0
oldieb	ds.b 0
oldshftmod	ds.b 0
oldima	ds.b 0
oldhbl	ds.l 0
string	dc.b $12,$1a
count1	dc.b 7
	even
scrolline	dc.b "           THE MAIN SCREEN TO THE LOST BOYS DEF DEMO.       "
		DC.B $FF
		EVEN
*********************************
* THIS IS THE GRAPHIX FOR THE MAIN SCREEN
* IT IS A 4 PLANE PIECE OF GRAPHIX OF ORIGINAL LENGTH 37760 BYTES
* THUS THERE ARE ALSO GRAPHIX IN THE BOTTOM BORDER
*********************************

filename1	dc.b "balls.dat",0
	even
data	

