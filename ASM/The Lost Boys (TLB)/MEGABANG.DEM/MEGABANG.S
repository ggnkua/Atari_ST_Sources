* This Piece of Code is BUDGIE UK licenceware (C) LOST BOYS 1989, 1990.

* This is the Megabang Demo Source Code by the Lost Boys, if you are 
* interested in more Source Code or other demos write to:
* 		The Lost Boys Pd library
*		12 Cambridge Rd
*		Teddington
*		Middx
*		TW11 8DR
* If you enclose a blank disk, we will send you our latest Pd list.
* sorry that the code is not documented.


* SEE NOTES on the POWER demo regarding assembly !
* Put MEGABANG on one D/sided disk with at least 300K to spare
* Put GENST2 on SAME disk, same path!
* Assemble to disk, with 300K text buffer preference, and
* symbols this time should be INDEPENDENT.
* Megabang assembles to 53027 bytes.
* All files, PRG, DAT etc.., should be in same folder.
* Sample MAY be corrupted somewhat in some sections.
* This may be an opportunity to slot in your own sample!
* Just make sure you call it 'shootout.spl'
* 
* For source code to DEFINITIVE demo and MINDBOMB demo,
* contact TLB direct at above address.

	move.w	#0,-(sp)	low res
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	
	lea	scrolline,a0
	move.l	a0,store
	pea	text
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	#COLS,-(SP)
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
	CLR.W	-(A7)
	PEA	FILE
	MOVE.W	#$3D,-(SP)
	TRAP	#1
	ADDQ.L	#8,SP
	MOVE.W	D0,HANDLE
	PEA	SHOOT1
	MOVE.L #282281,-(SP)
	MOVE.W HANDLE,-(SP)
	MOVE.W #$3F,-(SP)
	TRAP #1
	ADD.L #12,SP
	MOVE.W HANDLE,-(SP)
	MOVE.W #$3E,-(SP)
	TRAP #1
	ADDQ.L #4,SP

	CLR.W -(A7)
	PEA FILE1
	MOVE.W #$3D,-(SP)
	TRAP #1
	ADDQ.L #8,SP
	MOVE.W D0,HANDLE
	move.l #$6ffde,-(sp)
	MOVE.L #32034,-(SP)
	MOVE.W HANDLE,-(SP)
	MOVE.W #$3F,-(SP)
	TRAP #1
	ADD.L #12,SP
	MOVE.W HANDLE,-(SP)
	MOVE.W #$3E,-(SP)
	TRAP #1
	ADDQ.L #4,SP

	move.l #$70000,a1
	move.l #$78000,a0
	move.w #8000,d0
dloop	move.l (a1)+,(a0)+
	dbf d0,dloop
*	MFP EQUATES
*
MFP	EQU	$FFFA00
IERA	EQU	$07
IERB	EQU	$09
IPRA	EQU	$0B
ISRA	EQU	$0F
IMRA	EQU	$13
IMRB	EQU	$15
VECTOR	EQU	$17
TACR	EQU	$19
TADR	EQU	$1F
ISRVEC	EQU	$134
*
*	THE SOUND CHIP
*
SND_CHP	EQU	$FF8800 CHIP ADDRESS	
SCREG	EQU	0	CHIP REGISTER SELECT
SCDATA	EQU	2	REGISTER DATA
*
*	THE KEYBOARD & MIDI ACIA'S
*
KBDCONT	EQU	$FFFC00
KBDDATA	EQU	KBDCONT+2
MIDCONT	EQU	$FFFC04
MIDDATA	EQU	MIDCONT+2

*	CARTRIDGE PORT ADDRESSES

INPUT	EQU	$FB0001
OUTPUT	EQU	$FA0000

*	BDOS EQUATES (TRAP #1)

P_TERM_OLD EQU	0	
F_SUPER  EQU	$20

*	XBOIS EQUATES (TRAP #14)

IKBDWS	EQU	25

*******************************
*      THE MACHINE CODE.      *
*******************************

	move.l #SAMPLETAB,SAMPLEPOINT
SUPER	MOVEM.L	A0-A6/D0-D7,-(SP) SAVE 'BASIC' SYSTEM

	BSR	KEYSOFF		DISABLE KEYBOARD

	CLR.L	-(SP)		
	MOVE.W	#F_SUPER,-(SP)	GOTO SUPERVISOR
	TRAP	#1
	ADDQ.L	#6,SP

	MOVE.L	D0,oldssp


	BSR	SAVEMFP		SAVE NATURAL MFP CONDITIONS
	MOVE.W	#$2700,SR	INTERRUPTS OFF
	MOVE.L #VBLHAND,$70
	move.l #hblhand,$120
	LEA	INULL(PC),A0
	BSR	SETINT		SET NULL INTERRUPT ADDRESS
	MOVE.L	#1,D0	SET INITIAL FREQUENCY
	BSR	SETFREQ
	BSR	ENABMFP		SET THE MFP RUNNING
	BSR	SETSND		SET UP SOUND REGISTERS
	
	BSR	INTREGS		SET UP INTERNAL REGISTERS
	MOVE.L A1,-(A7)
	move.w #0,sump
	MOVE.L SAMPLEPOINT,A1
	MOVE.L (A1)+,A6
	MOVE.L (A1)+,D6
	MOVE.L A1,SAMPLEPOINT
	MOVE.L (A7)+,A1
	move.w #$2300,sr
	LEA	IREPLAY(PC),A0	SET UP THE OUTPUT CODE ADDRESS
	BSR	SETINT		GO TO IT

go
	bsr	INITIALIZE
	MOVE.L  #BUFFER,SPBACK
	BSR VTSYNC
	JSR LOOPSTART
	bsr scd1
	bsr VTSYNC1
	JSR LOOPSTART
	bsr scd2
LOOP	BSR VTSYNC
	bsr sce1
JUMP1	JSR LOOPSTART
		bsr do_scroll
		addq.b #1,count1
		cmp.b #16,count1
		beq nextlet
pointer
	bsr scd1
	bsr VTSYNC1
	bsr sce2
JUMP2	JSR LOOPSTART
		bsr do_scroll
		addq.b #1,count1
		cmp.b #16,count1
		beq nextlet1
pointer1
	bsr scd2
	BRA LOOP

sce1	
kk	bsr cs1
	MOVE.L #BUFFER4,SPBACK
	bsr CLEARSPRITE
	bsr cs2
	MOVE.L #BUFFER,SPBACK
	bSR	CLEARSPRITE
	bsr cs3
	MOVE.L #BUFFER1,SPBACK
	bSR	CLEARSPRITE
	rts
scd1	bsr ds1
	move.l #BUFFER1,SPBACK
	BSR DRAWSPRITE
	bsr ds2
	MOVE.L #BUFFER,SPBACK
	BSR DRAWSPRITE
	bsr ds3
	move.l #BUFFER4,SPBACK
	BSR DRAWSPRITE
	rts
sce2	
ll	bsr cs1
	MOVE.L #BUFFER5,SPBACK
	bSR	CLEARSPRITE
	bsr cs2
	MOVE.L #BUFFER2,SPBACK
        bSR	CLEARSPRITE
	bsr cs3
	MOVE.L #BUFFER3,SPBACK
	bsR	CLEARSPRITE
	rts
scd2	bsr ds1
	move.l #BUFFER3,SPBACK
	BSR DRAWSPRITE
	bsr ds2
	MOVE.L #BUFFER2,SPBACK
	BSR DRAWSPRITE
	bsr ds3
        move.l #BUFFER5,SPBACK
	BSR DRAWSPRITE
	rts
cs1	move.l erapointx2,a2
	move.w (a2)+,XXX
	MOVE.L A2,erapointx2
	cmp.l #xend,a2
	BEQ	NEWX4
q5	move.l erapointy2,a2
	move.w (a2)+,YYY
	move.l a2,erapointy2
	CMP.L #yend,A2
	BEQ NEWY4
q6      rts
cs2	move.l erapointx1,a2
	move.w (a2)+,XXX
	MOVE.L A2,erapointx1
	cmp.l #xend,a2
	BEQ	NEWX2
t5	move.l erapointy1,a2
	move.w (a2)+,YYY
	move.l a2,erapointy1
	CMP.L #yend,A2
	BEQ NEWY2
t6	rts
cs3	move.l erapointx,a2
	move.w (a2)+,XXX
	MOVE.L A2,erapointx
	cmp.l #xend,a2
	BEQ	NEWX
t1	move.l erapointy,a2
	move.w (a2)+,YYY
	move.l a2,erapointy
	CMP.L #yend,A2
	BEQ NEWY
t2	rts
ds1	MOVE.L 	pointx,a2
	move.w (a2)+,XXX
	move.l a2,pointx
	CMP.L #xend,a2
	beq newx1
t3	move.l pointy,a2
	move.w (a2)+,YYY
	move.l a2,pointy
	cmp.l #yend,a2
	beq newy1
t4      rts
ds2	MOVE.L 	pointx1,a2
	move.w (a2)+,XXX
	move.l a2,pointx1
	CMP.L #xend,a2
	beq newx3
t7	move.l pointy1,a2
	move.w (a2)+,YYY
	move.l a2,pointy1
	cmp.l #yend,a2
	beq newy3
t8	rts
ds3	MOVE.L 	pointx2,a2
	move.w (a2)+,XXX
	move.l a2,pointx2
	CMP.L #xend,a2
	beq newx4t
q3	move.l pointy2,a2
	move.w (a2)+,YYY
	move.l a2,pointy2
	cmp.l #yend,a2
	beq newy4t
q4	rts
NEWX	MOVE.L #xnew,erapointx
	bra t1
NEWY	move.l #ydat,erapointy
	bra t2
NEWX2	MOVE.L #xnew,erapointx1
	bra t5
NEWY2	move.l #ydat,erapointy1
	bra t6
NEWX4	MOVE.L #xnew,erapointx2
	bra q5
NEWY4	move.l #ydat,erapointy2
	bra q6
newx1	move.l #xnew,pointx
	bra t3
newy1	move.l #ydat,pointy
	bra t4
newx4t	move.l #xnew,pointx2
	bra q3
newy4t	move.l #ydat,pointy2
	bra q4
newx3	move.l #xnew,pointx1
	bra t7
newy3	move.l #ydat,pointy1
	bra t8

*    PARAMETER BLOCK    *

LIST:
XXX:	dc.w	0
YYY:	dc.w	0
SPBACK:	dc.l	0
SPDATA:	dc.l	0


*    INSTALLATION ROUTINE   *

INITIALIZE:
	move.l 		#$78000,d0
	lea		scre,a0
	move.l 		d0,(a0)
	move.l d0,phys
	sub.l #$8000,d0
	move.l d0,phys1
	rts



CLEARSPRITE:
	movem.l 	d0-d1/a0-a2,-(sp)
	move.l 		#0,d0
	move.l 		d0,d1
	move.l		d1,d2
	lea 		list,a1
	move.w 		(a1)+,d0   * x
	move.w 		(a1)+,d1   * y
	move.l 		(a1)+,a0   * back
	lea 		scre,a1
	move.l		(a1),a1
	divu   		#16,d0
	muls   		#8,d0
	add.w  		d0,a1
	muls   		#160,d1
	add.l  		d1,a1
	move.w 		#14,d1
sprclea2: 
	move.w 		#7,d0
sprclea1: 
	move.w 		(a0)+,(a1)+
	dbra   		d0,sprclea1
	add.l  		#144,a1
	dbra   		d1,sprclea2
	movem.l 	(sp)+,d0-d1/a0-a2
	rts


*      DRAW SPRITE ROUTINE     *

DRAWSPRITE:
	movem.l 	d0-d7/a0-a2,-(sp)
	lea 		list,a1
	move.w 		(a1)+,d2  * x
	move.w 		(a1)+,d1  * y
	move.l 		(a1)+,a0  * back
	move.l		#sprite2,a4
	lea		scre,a1
	move.l 		(a1),a1
	divs   		#16,d2
	swap   		d2
	move.w 		d2,d0
	move.w 		#0,d2
	swap   		d2
	muls   		#8,d2
	add.l  		d2,a1
	muls   		#160,d1
	add.l  		d1,a1
	move.w 		#16,d1
	sub.w  		d0,d1
	MOVE.L #SPRITES,A2
	MOVE.L D0,D2
	MULU #180,D2
	ADD.L D2,A2
	move.w 		#14,looptest
highs:
	clr.l		d2
lengs:
	move.w  	(a4)+,d2
	not.l  		d2      
	ror.l  		d0,d2
	move.w 		#2,d3
planes:
	move.w 		(a1),d4
	move.w 		d4,(a0)+  * save back
	and.w  		d2,d4     * clear mask size
	move.w 		(a2)+,d5
	or.w   		d5,d4
	move.w 		d4,(a1)+  * poke to screen
	dbra   		d3,planes
	move.w 		(a1),d4
	move.w 		d4,(a0)+
	and.w 		d2,d4
	move.w 		d4,(a1)+
	clr.w 		d2
	ror.l  		d1,d2     next starts here
	ror.l  		d0,d2
	move.w 		#2,d3
planes3:
	move.w 		(a1),d4
	move.w 		d4,(a0)+  * save back
	and.w  		d2,d4     * clear mask size
	move.w 		(a2)+,d5
	or.w   		d5,d4
	move.w 		d4,(a1)+  * poke to screen
	dbra   		d3,planes3
	move.w 		(a1),d4
	move.w 		d4,(a0)+
	and.w 		d2,d4
	move.w 		d4,(a1)+
	add.l  		#144,a1
	sub.w #1,looptest
	cmp.w #-1,looptest
	bne highs
	movem.l 	(sp)+,d0-d7/a0-a2
	rts

looptest	ds.w 1
*   SET PALETTE COLOURS   *

PALETTE:
	movem.l		d0/a0,-(sp)
	move.l		#spr_palette,-(sp)
	move.w		#6,-(sp)
	trap		#14
	addq.l		#6,sp
	movem.l		(sp)+,d0/a0
	rts


*   WAIT FOR SCREEN SYNC - FLICKER FREE   *

VTSYNC:	
	move.l phys,d0
	lsr.w #8,d0
	move.l d0,$ff8200
	move.l phys1,$44e
	move.l phys1,scre
	clr.w sump
k	cmp.w #1,sump
	bne k
	rts
VTSYNC1:
	move.l phys1,d0
	lsr.w #8,d0
	move.l d0,$ff8200
	move.l phys,$44e
	move.l phys,scre
	clr.w sump
j	cmp.w #1,sump
	bne j
	rts


*   WORKSPACE  *

TEMP:   dc.l 0,0,0,0
SCRE:   dc.l 0
phys1	dc.l 0
phys	dc.l 0
; sprite palette data- 16 words

spr_palette   dc.w 0,1792,1824,1840,1858,1874,1892,1911
 dc.w 1616,1889,1906,1908,1910,1911,1910,1092 
SPRITES
; data for sprite 1
 dc.w 2016,0,0,0,0,0
 dc.w 6872,1024,288,0,0,0
 dc.w 13572,2696,112,0,0,0
 dc.w 16386,16348,32,0,0,0
 dc.w 23202,16372,8,0,0,0
 dc.w 61437,28668,4099,0,0,0
 dc.w 54699,21928,10839,0,0,0
 dc.w 33287,16896,48639,0,0,0
 dc.w 57359,4304,61231,0,0,0
 dc.w 61661,3874,61663,0,0,0
 dc.w 12266,20500,32766,0,0,0
 dc.w 5460,27310,32766,0,0,0
 dc.w 2068,16380,16380,0,0,0
 dc.w 2744,8184,8184,0,0,0
 dc.w 2016,2016,2016,0,0,0
; data for sprite 2
 dc.w 1008,0,0,0,0,0
 dc.w 3436,512,144,0,0,0
 dc.w 6786,1348,56,0,0,0
 dc.w 8193,8174,16,0,0,0
 dc.w 11601,8186,4,0,0,0
 dc.w 30718,14334,2049,32768,0,32768
 dc.w 27349,10964,5419,32768,0,32768
 dc.w 16643,8448,24319,32768,0,32768
 dc.w 28679,2152,30615,32768,0,32768
 dc.w 30830,1937,30831,32768,0,32768
 dc.w 6133,10250,16383,0,0,0
 dc.w 2730,13655,16383,0,0,0
 dc.w 1034,8190,8190,0,0,0
 dc.w 1372,4092,4092,0,0,0
 dc.w 1008,1008,1008,0,0,0
; data for sprite 3
 dc.w 504,0,0,0,0,0
 dc.w 1718,256,72,0,0,0
 dc.w 3393,674,28,0,0,0
 dc.w 4096,4087,8,32768,0,0
 dc.w 5800,4093,2,32768,0,0
 dc.w 15359,7167,1024,16384,0,49152
 dc.w 13674,5482,2709,49152,0,49152
 dc.w 8321,4224,12159,49152,0,49152
 dc.w 14339,1076,15307,49152,0,49152
 dc.w 15415,968,15415,16384,32768,49152
 dc.w 3066,5125,8191,32768,0,32768
 dc.w 1365,6827,8191,0,32768,32768
 dc.w 517,4095,4095,0,0,0
 dc.w 686,2046,2046,0,0,0
 dc.w 504,504,504,0,0,0
; data for sprite 4
 dc.w 252,0,0,0,0,0
 dc.w 859,128,36,0,0,0
 dc.w 1696,337,14,32768,0,0
 dc.w 2048,2043,4,16384,32768,0
 dc.w 2900,2046,1,16384,32768,0
 dc.w 7679,3583,512,40960,32768,24576
 dc.w 6837,2741,1354,24576,0,57344
 dc.w 4160,2112,6079,57344,0,57344
 dc.w 7169,538,7653,57344,0,57344
 dc.w 7707,484,7707,40960,16384,57344
 dc.w 1533,2562,4095,16384,32768,49152
 dc.w 682,3413,4095,32768,49152,49152
 dc.w 258,2047,2047,32768,32768,32768
 dc.w 343,1023,1023,0,0,0
 dc.w 252,252,252,0,0,0
; data for sprite 5
 dc.w 126,0,0,0,0,0
 dc.w 429,64,18,32768,0,0
 dc.w 848,168,7,16384,32768,0
 dc.w 1024,1021,2,8192,49152,0
 dc.w 1450,1023,0,8192,16384,32768
 dc.w 3839,1791,256,53248,49152,12288
 dc.w 3418,1370,677,45056,32768,28672
 dc.w 2080,1056,3039,28672,0,61440
 dc.w 3584,269,3826,61440,0,61440
 dc.w 3853,242,3853,53248,8192,61440
 dc.w 766,1281,2047,40960,16384,57344
 dc.w 341,1706,2047,16384,57344,57344
 dc.w 129,1023,1023,16384,49152,49152
 dc.w 171,511,511,32768,32768,32768
 dc.w 126,126,126,0,0,0
; data for sprite 6
 dc.w 63,0,0,0,0,0
 dc.w 214,32,9,49152,0,0
 dc.w 424,84,3,8192,16384,32768
 dc.w 512,510,1,4096,57344,0
 dc.w 725,511,0,4096,40960,16384
 dc.w 1919,895,128,59392,57344,6144
 dc.w 1709,685,338,22528,16384,47104
 dc.w 1040,528,1519,14336,0,63488
 dc.w 1792,134,1913,30720,32768,30720
 dc.w 1926,121,1926,59392,4096,63488
 dc.w 383,640,1023,20480,40960,61440
 dc.w 170,853,1023,40960,28672,61440
 dc.w 64,511,511,40960,57344,57344
 dc.w 85,255,255,49152,49152,49152
 dc.w 63,63,63,0,0,0
; data for sprite 7
 dc.w 31,0,0,32768,0,0
 dc.w 107,16,4,24576,0,32768
 dc.w 212,42,1,4096,8192,49152
 dc.w 256,255,0,2048,28672,32768
 dc.w 362,255,0,34816,53248,8192
 dc.w 959,447,64,62464,61440,3072
 dc.w 854,342,169,44032,40960,23552
 dc.w 520,264,759,7168,0,64512
 dc.w 896,67,956,15360,16384,48128
 dc.w 963,60,963,29696,34816,31744
 dc.w 191,320,511,43008,20480,63488
 dc.w 85,426,511,20480,47104,63488
 dc.w 32,255,255,20480,61440,61440
 dc.w 42,127,127,57344,57344,57344
 dc.w 31,31,31,32768,32768,32768
; data for sprite 8
 dc.w 15,0,0,49152,0,0
 dc.w 53,8,2,45056,0,16384
 dc.w 106,21,0,2048,4096,57344
 dc.w 128,127,0,1024,47104,16384
 dc.w 181,127,0,17408,59392,4096
 dc.w 479,223,32,64000,63488,1536
 dc.w 427,171,84,22016,20480,44544
 dc.w 260,132,379,3584,0,65024
 dc.w 448,33,478,7680,40960,24064
 dc.w 481,30,481,47616,17408,48640
 dc.w 95,160,255,54272,10240,64512
 dc.w 42,213,255,43008,23552,64512
 dc.w 16,127,127,10240,63488,63488
 dc.w 21,63,63,28672,61440,61440
 dc.w 15,15,15,49152,49152,49152
; data for sprite 9
 dc.w 7,0,0,57344,0,0
 dc.w 26,4,1,55296,0,8192
 dc.w 53,10,0,1024,34816,28672
 dc.w 64,63,0,512,56320,8192
 dc.w 90,63,0,41472,62464,2048
 dc.w 239,111,16,64768,64512,768
 dc.w 213,85,42,43776,43008,22272
 dc.w 130,66,189,1792,0,65280
 dc.w 224,16,239,3840,53248,12032
 dc.w 240,15,240,56576,8704,57088
 dc.w 47,80,127,59904,5120,65024
 dc.w 21,106,127,21504,44544,65024
 dc.w 8,63,63,5120,64512,64512
 dc.w 10,31,31,47104,63488,63488
 dc.w 7,7,7,57344,57344,57344
; data for sprite 10
 dc.w 3,0,0,61440,0,0
 dc.w 13,2,0,27648,0,36864
 dc.w 26,5,0,33280,17408,14336
 dc.w 32,31,0,256,60928,4096
 dc.w 45,31,0,20736,64000,1024
 dc.w 119,55,8,65152,65024,384
 dc.w 106,42,21,54656,54272,11136
 dc.w 65,33,94,896,0,65408
 dc.w 112,8,119,1920,26624,38784
 dc.w 120,7,120,28288,37120,28544
 dc.w 23,40,63,62720,2560,65280
 dc.w 10,53,63,43520,22272,65280
 dc.w 4,31,31,2560,65024,65024
 dc.w 5,15,15,23552,64512,64512
 dc.w 3,3,3,61440,61440,61440
; data for sprite 11
 dc.w 1,0,0,63488,0,0
 dc.w 6,1,0,46592,0,18432
 dc.w 13,2,0,16640,41472,7168
 dc.w 16,15,0,128,63232,2048
 dc.w 22,15,0,43136,64768,512
 dc.w 59,27,4,65344,65280,192
 dc.w 53,21,10,27328,27136,38336
 dc.w 32,16,47,33216,32768,32704
 dc.w 56,4,59,960,13312,52160
 dc.w 60,3,60,14144,51328,14272
 dc.w 11,20,31,64128,1280,65408
 dc.w 5,26,31,21760,43904,65408
 dc.w 2,15,15,1280,65280,65280
 dc.w 2,7,7,44544,65024,65024
 dc.w 1,1,1,63488,63488,63488
; data for sprite 12
 dc.w 0,0,0,64512,0,0
 dc.w 3,0,0,23296,32768,9216
 dc.w 6,1,0,41088,20736,3584
 dc.w 8,7,0,64,64384,1024
 dc.w 11,7,0,21568,65152,256
 dc.w 29,13,2,65440,65408,96
 dc.w 26,10,5,46432,46336,19168
 dc.w 16,8,23,16608,16384,49120
 dc.w 28,2,29,480,6656,58848
 dc.w 30,1,30,7072,58432,7136
 dc.w 5,10,15,64832,640,65472
 dc.w 2,13,15,43648,21952,65472
 dc.w 1,7,7,640,65408,65408
 dc.w 1,3,3,22272,65280,65280
 dc.w 0,0,0,64512,64512,64512
; data for sprite 13
 dc.w 0,0,0,32256,0,0
 dc.w 1,0,0,44416,16384,4608
 dc.w 3,0,0,20544,43136,1792
 dc.w 4,3,0,32,64960,512
 dc.w 5,3,0,43552,65344,128
 dc.w 14,6,1,65488,65472,48
 dc.w 13,5,2,23216,23168,42352
 dc.w 8,4,11,8304,8192,57328
 dc.w 14,1,14,240,3328,62192
 dc.w 15,0,15,3536,61984,3568
 dc.w 2,5,7,65184,320,65504
 dc.w 1,6,7,21824,43744,65504
 dc.w 0,3,3,33088,65472,65472
 dc.w 0,1,1,43904,65408,65408
 dc.w 0,0,0,32256,32256,32256
; data for sprite 14
 dc.w 0,0,0,16128,0,0
 dc.w 0,0,0,54976,8192,2304
 dc.w 1,0,0,43040,21568,896
 dc.w 2,1,0,16,65248,256
 dc.w 2,1,0,54544,65440,64
 dc.w 7,3,0,32744,32736,32792
 dc.w 6,2,1,44376,44352,21176
 dc.w 4,2,5,4152,4096,61432
 dc.w 7,0,7,120,34432,31096
 dc.w 7,0,7,34536,30992,34552
 dc.w 1,2,3,32592,32928,65520
 dc.w 0,3,3,43680,21872,65520
 dc.w 0,1,1,16544,65504,65504
 dc.w 0,0,0,21952,65472,65472
 dc.w 0,0,0,16128,16128,16128
; data for sprite 15
 dc.w 0,0,0,8064,0,0
 dc.w 0,0,0,27488,4096,1152
 dc.w 0,0,0,54288,10784,448
 dc.w 1,0,0,8,65392,128
 dc.w 1,0,0,27272,65488,32
 dc.w 3,1,0,49140,49136,16396
 dc.w 3,1,0,22188,22176,43356
 dc.w 2,1,2,2076,2048,63484
 dc.w 3,0,3,32828,17216,48316
 dc.w 3,0,3,50036,15496,50044
 dc.w 0,1,1,49064,16464,65528
 dc.w 0,1,1,21840,43704,65528
 dc.w 0,0,0,8272,65520,65520
 dc.w 0,0,0,10976,32736,32736
 dc.w 0,0,0,8064,8064,8064
; data for sprite 16
 dc.w 0,0,0,4032,0,0
 dc.w 0,0,0,13744,2048,576
 dc.w 0,0,0,27144,5392,224
 dc.w 0,0,0,32772,32696,64
 dc.w 0,0,0,46404,32744,16
 dc.w 1,0,0,57338,57336,8198
 dc.w 1,0,0,43862,43856,21678
 dc.w 1,0,1,1038,33792,31742
 dc.w 1,0,1,49182,8608,56926
 dc.w 1,0,1,57786,7748,57790
 dc.w 0,0,0,24532,41000,65532
 dc.w 0,0,0,10920,54620,65532
 dc.w 0,0,0,4136,32760,32760
 dc.w 0,0,0,5488,16368,16368
 dc.w 0,0,0,4032,4032,4032

; data for sprite 3
sprite2   dc.w 2016
 dc.w 8184
 dc.w 16380
 dc.w 32766
 dc.w 32766
 dc.w 65535
 dc.w 65535
 dc.w 65535
 dc.w 65535
 dc.w 65535
 dc.w 32766
 dc.w 32766
 dc.w 16380
 dc.w 8184
 dc.w 2016
BUFFER	ds.w 250
BUFFER1	DS.W 250
BUFFER2	ds.w 250
BUFFER3	DS.W 250
BUFFER4	DS.W 250
BUFFER5 DS.W 250
pointx dc.l xdat+4
pointy	dc.l ydat+4
pointx1 dc.l xdat+10
pointy1	dc.l ydat+10
pointx2	dc.l xdat+16
pointy2	dc.l ydat+16
erapointx	dc.l xdat+4
erapointy	dc.l ydat+4
erapointx1	dc.l xdat+10
erapointy1	dc.l ydat+10
erapointx2	dc.l xdat+16
erapointy2	dc.l ydat+16
ydat
	dc.w 1,2,3,4,6,8,10,12,15,18,21,24,28,32,36,40,45,50
	dc.w 55,60,64,68,72,76,79,82,85,88,90,92,94,96,97,98,99,100
	dc.w 99,98,97,96,94,92,90,88,85,82,79,76,72,68,64,60,55
	dc.w 50,45,40,36,32,28,24,21,18,15,12,10,8,6,4,3,2
	dc.w 1,2,3,4,6,8,10,12,15,18,21,24,28,32,36,40,45,50
	dc.w 55,60,64,68,72,76,79,82,85,88,90,92,94,96,97,98,99,100
	dc.w 99,98,97,96,94,92,90,88,85,82,79,76,72,68,64,60,55
	dc.w 50,45,40,36,32,28,24,21,18,15,12,10,8,6,4,3,2
	dc.w 1,2,3,4,6,8,10,12,15,18,21,24,28,32,36,40,45,50
	dc.w 55,60,64,68,72,76,79,82,85,88,90,92,94,96,97,98,99,100
	dc.w 99,98,97,96,94,92,90,88,85,82,79,76,72,68,64,60,55
	dc.w 50,45,40,36,32,28,24,21,18,15,12,10,8,6,4,3,2

	dc.w 1,2,3,4,6,8,10,12,15,18,21,24,28,32,36,40,44,48
	dc.w 52,56,60,64,68,72,77,82,87,92,97,102,107,112
	dc.w 117,112,107,102,97,92,87,82,77,72,68,64,60,56,52
	dc.w 48,44,40,36,32,28,24,21,18,15,12,10,8,6,4,3,2

	dc.w 1,2,3,4,6,8,10,12,15,18,21,24,28,32,36,40,44,48
	dc.w 52,56,60,64,68,72,77,82,87,92,97,102,107,112
	dc.w 117,112,107,102,97,92,87,82,77,72,68,64,60,56,52
	dc.w 48,44,40,36,32,28,24,21,18,15,12,10,8,6,4,3,2
	dc.w 1,2,3,4,6,8,10,12,15,18,21,24,28,32,36,40,44,48
	dc.w 52,56,60,64,68,72,77,82,87,92,97,102,107,112
	dc.w 117,112,107,102,97,92,87,82,77,72,68,64,60,56,52
	dc.w 48,44,40,36,32,28,24,21,18,15,12,10,8,6,4,3,2
yend	dc.w 0
xdat
xnew	

	dc.w 1,2,3,5,7,10,13,17,21,26,31,37,43,50,57,64,71,78,85,92,99,106,113,120,127,134,141,148,155,162,169,176,183,190,197,204,211,218,225,232,239,246,253
	dc.w 259,265,271,276,281,285,289,292,295,297,299,300,301,302
	dc.w 302,301,300,299,297,295,292,289,285,281,276,271,265,259,253,246,239,232,225,218,211,204,197,190,183,176,169,162,155,148,141,134,127
	dc.w 120,113,106,99,92,85,78,71,64,57,50,43,37,31,26,21,17,13,10,7,5,3,2,1
xend     dc.w 0

FUCK2	MOVE.L #SAMPLETAB,SAMPLEPOINT
	BRA FUCK
sump	ds.w 0
VBLHAND
		nop
		nop
		nop
		nop
		move.w #1,sump
		move.b #0,$fffa1b
		move.b #18,$fffa21
		move.b #8,$fffa1b
		move.l #$00000444,$ff8240
		move.l #$05550555,$ff8244
		move.l #$07770233,$ff8248
		move.l #$03230425,$ff824c
		move.l #$00700173,$ff8250
		move.l #$03740576,$ff8254
		move.l #$07070737,$ff8258
		move.l #$07570777,$ff825c
		move.l #hblhand,$120
		RTE
hblhand		
		move.l #hblhand2,$120
		move.b #0,$fffa1b
		move.b #42,$fffa21
		move.b #8,$fffa1b
		move.l #$00070127,$ff8250
		move.l #$03470567,$ff8254
		move.l #$07000731,$ff8258
		move.l #$07520774,$ff825c
		bclr #0,$fffa0f
		rte
hblhand2	move.l #hblhand3,$120
		move.b #0,$fffa1b
		move.b #18,$fffa21
		move.b #8,$fffa1b
		move.l #$02440255,$ff8250
		move.l #$02660477,$ff8254
		move.l #$07000722,$ff8258
		move.l #$07440766,$ff825c
		bclr #0,$fffa0f
		rte
hblhand3	move.l #hblhand4,$120
		move.b #0,$fffa1b
		move.b #47,$fffa21
		move.b #8,$fffa1b
		move.l #$00070127,$ff8250
		move.l #$03470567,$ff8254
		move.l #$07000731,$ff8258
		move.l #$07520774,$ff825c
		bclr #0,$fffa0f
		rte
hblhand4
		move.l #hblhand5,$120
		move.b #0,$fffa1b
		move.b #38,$fffa21
		move.b #8,$fffa1b
		cmp.w #1,indic
		bne opp2
		move.l #$06300750,$ff8250
		move.l #$07700773,$ff8254
		bra.s he
opp2		move.l #$03330333,$ff8250
		move.l #$03330333,$ff8254
he		bclr #0,$fffa0f
		rte
hblhand5	move.l #INULL,ISRVEC
		move.l #hblhand6,$120
		move.b #0,$fffa1b
		move.b #1,$fffa21
		move.b #8,$fffa1b
		move.l #$00000500,$ff8240
		move.l #$06000710,$ff8244
		move.l #$07210731,$ff8248
		move.l #$07520765,$ff824c
		bclr #0,$fffa0f
		rte		
hblhand6	
		move.l #$00040005,$ff8250
		move.l #$00060017,$ff8254
		move.l #$01270137,$ff8258
		move.l #$02570367,$ff825c
		move.b #0,$fffa1b
		move.b #1,$fffa21
		move.b #8,$fffa1b
		move.l #hblhand7,$120
		bclr #0,$fffa0f
		rte
hblhand7	move.w #$500,$ff8240
		move.l #ireplay,ISRVEC
		bclr #0,$fffa0f
		rte
*
*  This tidies the system up before leaving back to BASIC.
*
EXIT	MOVE.W	#$2700,SR	DISABLE INTS.
	BSR	OLDMFP		RESTORE ORIGINAL MFP DATA
	BSR	KEYSON		RESTORE KEYBOARD OPERATION
*
*  WE MUST NOW FLUSH ANY CHARACTERS OUT OF THE KEY BUFFER BEFORE
*  RE-ENABLING THE INTERRUPTS SINCE THE FLOOD OF DATA WILL CRASH
*  THE COMPUTER. (USERS WITH A MIDI DEVICE CONNECTED MAY NEED TO 
*  FLUSH THE MIDI ACIA IN A SIMILAR WAY).
*
FLUSH	BTST.B	#0,KBDCONT	IS A CHARACTER WAITING ?
	BEQ.S	INTSON		BR. IF NOT
	MOVE.B	KBDDATA,D0	READ CHARACTER (& IGNORE IT)
	BRA.S	FLUSH		CHECK FOR ANOTHER

INTSON	MOVE.W	#$2000,SR	RESTORE INTS FOR O.S.
	MOVE.L	oldssp,-(SP)
	MOVE.W	#F_SUPER,-(SP)	RETURN TO USER MODE
 	TRAP	#1
	ADDQ.L	#6,SP

	MOVEM.L	(SP)+,A0-A6/D0-D7 RESTORE 'BASIC' DATA
	CLR.W -(A7)
	TRAP #1


****************************************
*   THE INTERRUPT SERVICE ROUTINES     *
****************************************
*
*	A6 = POINTER TO BASE OF REPLAY RAM
*	A5 = UNUSED
*	A4 = INT. SOUND REG / EXT. PORT ADDR
*	A3 = LOOK UP TABLE ADDRESS
*	A2 = UNUSED
*	A1 = UNUSED
*	A0 = UNUSED
*	D7 = BYTE FROM PORT /  OUT TO PORT
*	D6 = POINTER TO END OF REPLAY RAM
*	D5 = UNUSED
*	D4 = UNUSED
*	D3 = UNUSED
*	D2 = UNUSED
*	D1 = UNUSED
*	D0 = UNUSED
*
****************************************
*     THE NULL INTERRUPT ROUTINE       *
****************************************

INULL	RTE

****************************************
*       REPLAY FROM MEMORY             *
****************************************

IREPLAY	MOVE.B	(A6)+,D7	READ FROM RAM
	CMP.L	D6,A6		EXCEDED END STOP
	Bge.S	HALTREP		BRANCH IF SO
INTOUTP	AND.W	#$00FF,D7	MASK OFF RUBBISH
	ADD.B	#$80,D7		SIGN VALUE
	LSL.W	#3,D7		DOUBLE LONG WORD OFFSET
	MOVEM.L D4-D5,-(SP)
 	MOVE.L	0(A3,D7.W),D5	GET DATA #1
	MOVE.W	4(A3,D7.W),D4	GET DATA #2
	MOVEP.L	D5,0(A5)	PLAY #1
	MOVEP.W	D4,0(A5)	PLAY #2
	MOVEM.L (SP)+,D4-D5
	RTE

HALTREP	
	MOVE.L A1,-(A7)
FUCK	MOVE.L SAMPLEPOINT,A1
	MOVE.L (A1)+,A6
	MOVE.L (A1)+,D6
	CMP.L #0,A6
	BEQ FUCK2
	MOVE.L A1,SAMPLEPOINT
	MOVE.L (A7)+,A1
	MOVE.B	(A6)+,D7	READ FROM RAM
	AND.W	#$00FF,D7	MASK OFF RUBBISH
	ADD.B	#$80,D7		SIGN VALUE
	LSL.W	#3,D7		DOUBLE LONG WORD OFFSET
	MOVEM.L D4-D5,-(SP)
 	MOVE.L	0(A3,D7.W),D5	GET DATA #1
	MOVE.W	4(A3,D7.W),D4	GET DATA #2
	MOVEP.L	D5,0(A5)	PLAY #1
	MOVEP.W	D4,0(A5)	PLAY #2
	MOVEM.L (SP)+,D4-D5
	rte

****************************************
*       THE OUTPUT ROUTINES            *
****************************************
*

SAVEMFP	MOVE.L	#MFP,A0
	MOVE.B	IERA(A0),MFPMEM
	MOVE.B	IERB(A0),MFPMEM+1
	MOVE.B	IMRA(A0),MFPMEM+2
	MOVE.B	IMRB(A0),MFPMEM+3
	MOVE.B	TADR(A0),MFPMEM+4
	MOVE.B	TACR(A0),MFPMEM+5
	MOVE.B	VECTOR(A0),MFPMEM+6
	RTS

***********************************
*   RESTORE NATURAL RUNNING MFP   *
***********************************

OLDMFP	MOVE.L	#MFP,A0
	MOVE.B	MFPMEM+6,VECTOR(A0)
	MOVE.B	MFPMEM+5,TACR(A0)
	MOVE.B	MFPMEM+4,TADR(A0)
	MOVE.B	MFPMEM+3,IMRB(A0)
	MOVE.B	MFPMEM+2,IMRA(A0)
	MOVE.B	MFPMEM+1,IERB(A0)
	MOVE.B	MFPMEM,IERA(A0)
	RTS

***********************************
*     CHOOSE INTERRUPT VECTOR     *
***********************************

SETINT 	MOVEM.L A0/D0,-(SP)
	MOVE.W	SR,D0
	MOVE.W	#$2700,SR
	MOVE.L	A0,ISRVEC
	MOVE.W	D0,SR
	MOVEM.L (SP)+,A0/D0
	RTS

******************************
*    IKBD ENABLE/DISABLE     *
******************************

KEYSOFF	PEA	SKBDDIS(PC)
	BRA.S	DO_IKBD
KEYSON	PEA	SKBDEN(PC)
DO_IKBD	MOVE.W	#0,-(SP)	1 PARAMETER
	MOVE.W	#IKBDWS,-(SP)
	TRAP	#14
	ADDQ.L	#8,SP
	RTS

*****************************************
*       SET UP MFP FREQUENCY            *
*****************************************
*
*   SET UP MFP TIMER A TO GENERATE INTERRUPTS
*   ENTER WITH D0.W SET WITH A FREQUENCY NUMBER 0 TO 7
*   E.G. D0.W = $0002 GETS 3RD MFP DATA FROM TABLE
*
SETFREQ	MOVE.L	#MFP,A1
	MOVE.B	#0,TACR(A1)	DISABLE TIMER
	AND.W	#7,D0		ENSURE 0-7
	LEA	FREQTAB(PC),A0	GET THE FREQUENCY XREF ADDR
	LSL.W	#1,D0		CONVERT TO WORD TABLE OFFSET
	MOVE.W	0(A0,D0.W),D0	& GET THE MFP DATA
	MOVE.B	D0,TACR(A1)	LSB = CONTROL REG BYTE
	LSR.W	#8,D0		SHIFT DOWN NEXT BYTE
 	MOVE.B	D0,TADR(A1)	NEXT = DATA REG BYTE
	RTS

***********************************
*       ENABLE THE MFP            *
***********************************

ENABMFP	MOVE.L	#MFP,A0
	MOVE.B	#$21,IMRA(A0)
	MOVE.B #0,IMRB(A0)
	MOVE.B	#$21,IERA(A0)
	MOVE.B #0,IERB(A0)
	BCLR.B	#3,VECTOR(A0)
	RTS

*****************************************
*    SET UP THE SOUND CHIP CHANNELS     *
*****************************************

SETSND	MOVE.L	#SND_CHP,A0
	MOVE.B	#0,SCREG(A0)	CHANNEL A
	MOVE.B	#0,SCDATA(A0)
	MOVE.B	#1,SCREG(A0)
	MOVE.B	#0,SCDATA(A0)

	MOVE.B	#2,SCREG(A0)	CHANNEL B
	MOVE.B	#0,SCDATA(A0)
	MOVE.B	#3,SCREG(A0)
	MOVE.B	#0,SCDATA(A0)

	MOVE.B	#4,SCREG(A0)	CHANNEL C
	MOVE.B	#0,SCDATA(A0)
	MOVE.B	#5,SCREG(A0)
	MOVE.B	#0,SCDATA(A0)

	MOVE.B	#7,SCREG(A0)	SET UP CHANNEL MIXING & PORT 'A' I/O
	MOVE.B	#$FF,SCDATA(A0)

	MOVE.B	#8,SCREG(A0)	SET ALL VOLUMES TO ZERO
	MOVE.B	#0,SCDATA(A0)
	MOVE.B	#9,SCREG(A0)
	MOVE.B	#0,SCDATA(A0)
	MOVE.B	#10,SCREG(A0)
	MOVE.B	#0,SCDATA(A0)
	RTS
	
***************************************
*    SET UP REGS. FOR INTERNAL        *
***************************************

INTREGS	MOVE.W	SR,D0
	MOVE.W	#$2700,SR
	MOVE.L	#SND_CHP,A5	SOUND CHIP CNTRL REG
	LEA.L	SND_OUT(PC),A3	LOOK UP TABLES
	MOVEQ	#0,D7
	MOVE.W	D0,SR
	RTS

***********************************
*	BLOCK STORAGE AREA        *
***************************************
*    Internal sound lookup table.     *
***************************************
	EVEN
SND_OUT	DC.W	$80C,$90B,$A09,0,$80C,$90B,$A09,0
	DC.W	$80D,$908,$A08,0,$80B,$90B,$A0B,0
	DC.W	$80D,$909,$A05,0,$80C,$90B,$A08,0
	DC.W	$80D,$909,$A02,0,$80D,$908,$A06,0
	DC.W	$80C,$90B,$A07,0,$80D,$907,$A07,0
	DC.W	$80C,$90B,$A06,0,$80C,$90A,$A09,0
	DC.W	$80B,$90B,$A0A,0,$80C,$90B,$A02,0
	DC.W	$80C,$90B,$A00,0,$80C,$90A,$A08,0

	DC.W	$80D,$906,$A04,0,$80D,$905,$A05,0
	DC.W	$80D,$905,$A04,0,$80C,$909,$A09,0
	DC.W	$80D,$904,$A03,0,$80B,$90B,$A09,0
	DC.W	$80C,$90A,$A05,0,$80B,$90A,$A0A,0
	DC.W	$80C,$909,$A08,0,$80B,$90B,$A08,0
	DC.W	$80C,$90A,$A00,0,$80C,$90A,$A00,0
	DC.W	$80C,$909,$A07,0,$80B,$90B,$A07,0
	DC.W	$80C,$909,$A06,0,$80B,$90B,$A06,0

	DC.W	$80B,$90A,$A09,0,$80B,$90B,$A05,0
	DC.W	$80A,$90A,$A0A,0,$80B,$90B,$A02,0
	DC.W	$80B,$90A,$A08,0,$80C,$907,$A07,0
	DC.W	$80C,$908,$A04,0,$80C,$907,$A06,0
	DC.W	$80B,$909,$A09,0,$80C,$906,$A06,0
	DC.W	$80A,$90A,$A09,0,$80C,$907,$A03,0
	DC.W	$80B,$90A,$A05,0,$80B,$909,$A08,0
	DC.W	$80B,$90A,$A03,0,$80A,$90A,$A08,0

	DC.W	$80B,$90A,$A00,0,$80B,$909,$A07,0
	DC.W	$80B,$908,$A08,0,$80A,$90A,$A07,0
	DC.W	$80A,$909,$A09,0,$80C,$901,$A01,0
	DC.W	$80A,$90A,$A06,0,$80B,$908,$A07,0
	DC.W	$80A,$90A,$A05,0,$80A,$909,$A08,0
	DC.W	$80A,$90A,$A02,0,$80A,$90A,$A01,0
	DC.W	$80A,$90A,$A00,0,$809,$909,$A09,0
	DC.W	$80A,$908,$A08,0,$80B,$908,$A01,0

	DC.W	$80A,$909,$A06,0,$80B,$907,$A04,0
	DC.W	$80A,$909,$A05,0,$809,$909,$A08,0
	DC.W	$80A,$909,$A03,0,$80A,$908,$A06,0
	DC.W	$80A,$909,$A00,0,$809,$909,$A07,0
	DC.W	$809,$908,$A08,0,$80A,$908,$A04,0
	DC.W	$809,$909,$A06,0,$80A,$908,$A01,0
	DC.W	$809,$909,$A05,0,$809,$908,$A07,0
	DC.W	$808,$908,$A08,0,$809,$909,$A02,0

	DC.W	$809,$908,$A06,0,$809,$909,$A00,0
	DC.W	$809,$907,$A07,0,$808,$908,$A07,0
	DC.W	$809,$907,$A06,0,$809,$908,$A02,0
	DC.W	$808,$908,$A06,0,$809,$906,$A06,0
	DC.W	$808,$907,$A07,0,$808,$908,$A04,0
	DC.W	$808,$907,$A06,0,$808,$908,$A02,0
	DC.W	$807,$907,$A07,0,$808,$906,$A06,0
	DC.W	$808,$907,$A04,0,$807,$907,$A06,0

	DC.W	$808,$906,$A05,0,$808,$906,$A04,0
	DC.W	$807,$906,$A06,0,$807,$907,$A04,0
	DC.W	$808,$905,$A04,0,$806,$906,$A06,0
	DC.W	$807,$906,$A04,0,$807,$905,$A05,0
	DC.W	$806,$906,$A05,0,$806,$906,$A04,0
	DC.W	$806,$905,$A05,0,$806,$906,$A02,0
	DC.W	$806,$905,$A04,0,$805,$905,$A05,0
	DC.W	$806,$905,$A02,0,$805,$905,$A04,0

	DC.W	$805,$904,$A04,0,$805,$905,$A02,0
	DC.W	$804,$904,$A04,0,$804,$904,$A03,0
	DC.W	$804,$904,$A02,0,$804,$903,$A03,0
	DC.W	$803,$903,$A03,0,$803,$903,$A02,0
	DC.W	$803,$902,$A02,0,$802,$902,$A02,0
	DC.W	$802,$902,$A01,0,$801,$901,$A01,0
	DC.W	$802,$901,$A00,0,$801,$901,$A00,0
	DC.W	$801,$900,$A00,0,$800,$900,$A00,0

	DC.W	$80E,$90D,$A0C,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0A,0,$80E,$90D,$A0A,0

	DC.W	$80E,$90D,$A0A,0,$80E,$90D,$A0A,0
	DC.W	$80E,$90C,$A0C,0,$80E,$90D,$A00,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0

	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0A,0,$80E,$90C,$A0A,0
	DC.W	$80E,$90C,$A0A,0,$80E,$90C,$A0A,0
	DC.W	$80D,$90D,$A0C,0,$80D,$90D,$A0C,0
	DC.W	$80E,$90C,$A09,0,$80E,$90C,$A09,0
	DC.W	$80E,$90C,$A05,0,$80E,$90C,$A00,0
	DC.W	$80E,$90C,$A00,0,$80E,$90B,$A0B,0
	DC.W	$80E,$90B,$A0B,0,$80E,$90B,$A0B,0

	DC.W	$80E,$90B,$A0B,0,$80E,$90B,$A0A,0
	DC.W	$80E,$90B,$A0A,0,$80E,$90B,$A0A,0
	DC.W	$80D,$90D,$A0B,0,$80D,$90D,$A0B,0
	DC.W	$80D,$90D,$A0B,0,$80E,$90B,$A09,0
	DC.W	$80E,$90B,$A09,0,$80E,$90B,$A09,0
	DC.W	$80D,$90C,$A0C,0,$80D,$90D,$A0A,0
	DC.W	$80E,$90B,$A07,0,$80E,$90B,$A00,0
	DC.W	$80E,$90B,$A00,0,$80D,$90D,$A09,0

	DC.W	$80D,$90D,$A09,0,$80E,$90A,$A09,0
	DC.W	$80D,$90D,$A08,0,$80D,$90D,$A07,0
	DC.W	$80D,$90D,$A04,0,$80D,$90D,$A00,0
	DC.W	$80E,$90A,$A04,0,$80E,$909,$A09,0
	DC.W	$80E,$909,$A09,0,$80D,$90C,$A0B,0
	DC.W	$80E,$909,$A08,0,$80E,$909,$A08,0
	DC.W	$80E,$909,$A07,0,$80E,$908,$A08,0
	DC.W	$80E,$909,$A01,0,$80C,$90C,$A0C,0

	DC.W	$80D,$90C,$A0A,0,$80E,$908,$A06,0
	DC.W	$80E,$907,$A07,0,$80E,$908,$A00,0
	DC.W	$80E,$907,$A05,0,$80E,$906,$A06,0
	DC.W	$80D,$90C,$A09,0,$80E,$905,$A05,0
	DC.W	$80E,$904,$A04,0,$80D,$90C,$A08,0
	DC.W	$80D,$90B,$A0B,0,$80E,$900,$A00,0
	DC.W	$80D,$90C,$A06,0,$80D,$90C,$A05,0
	DC.W	$80D,$90C,$A02,0,$80C,$90C,$A0B,0

	DC.W	$80C,$90C,$A0B,0,$80D,$90B,$A0A,0
	DC.W	$80D,$90B,$A0A,0,$80D,$90B,$A0A,0
	DC.W	$80D,$90B,$A0A,0,$80C,$90C,$A0A,0
	DC.W	$80C,$90C,$A0A,0,$80C,$90C,$A0A,0
	DC.W	$80D,$90B,$A09,0,$80D,$90B,$A09,0
	DC.W	$80D,$90A,$A0A,0,$80D,$90A,$A0A,0
	DC.W	$80D,$90A,$A0A,0,$80C,$90C,$A09,0
	DC.W	$80C,$90C,$A09,0,$80C,$90C,$A09,0

	DC.W	$80D,$90B,$A06,0,$80C,$90B,$A0B,0
	DC.W	$80C,$90C,$A08,0,$80D,$90B,$A00,0
	DC.W	$80D,$90B,$A00,0,$80C,$90C,$A07,0
	DC.W	$80C,$90C,$A06,0,$80C,$90C,$A05,0
	DC.W	$80C,$90C,$A03,0,$80C,$90C,$A01,0
	DC.W	$80C,$90B,$A0A,0,$80D,$90A,$A05,0
	DC.W	$80D,$90A,$A04,0,$80D,$90A,$A02,0
	DC.W	$80D,$909,$A08,0,$80D,$909,$A08,0

**************************************
*       MFP/FREQUENCY TABLE          *
**************************************
	EVEN
FREQTAB	DC.W	$0506	4.9 KHZ
	DC.W	$0505	7.68 KHZ
	DC.W	$0405	9.6 KHZ
	DC.W	$2901	14.99 KHZ
	DC.W	$1F01	19.8 KHZ
	DC.W	$0802	30.7 KHZ
 	DC.W	$0106	
	DC.W	$0106

************************************
*     KEYBOARD MESSAGE STRINGS     *
************************************
	EVEN
SKBDDIS	DC.B	$13		STOP DATA
	EVEN
SKBDEN	DC.B	$11		RESTART REPORTING
**************************************
*	DEFINE PROGRAM STORAGE       *
**************************************
	EVEN
VARS
XTERNAL	RS.B	1	$FF = EXTERNAL O/P SELECTED
INUSE	RS.B	1	INTERRUPT IN USE FLAG
OPTION	RS.B	1	INT. OPTION  $FF = SAMPLE
	EVEN
FREQNUM	RS.W	1	FREQUENCY SELECTED
STATUS	RS.W	1	STATUS REGISTER
MFPMEM	RS.B	8	SAVED MFP DATA
SAMPLE	RS.L	1
LENGTH	RS.L	1
FREQNCY	RS.L	1
STACK	RS.L	1
	EVEN
	ds.l 100
		
nextlet		clr.b count1
movlet		move.l store,a0
		move.b (a0)+,d0
		cmp.b #$ff,d0
		beq wrap
		subi.b #$20,d0
		move.l a0,store
		move.b d0,b
		move.w a,d0
		mulu #$44,d0
		clr.l a
		move.w d0,c
		add.l #font,a
		sub.l #2,a
		move.l a,a0
		lea letterbuf,a1
		move.w #16,d0
there		move.w 2(a0),6(a1)
		move.w 4(a0),14(a1)

		adda.l #160,a1				
		addq.l #4,a0
		dbf d0,there

		bra pointer
nextlet1		clr.b count1
movlet1		move.l store,a0
		move.b (a0)+,d0
		cmp.b #$ff,d0
		beq wrap1
		subi.b #$20,d0
		move.l a0,store
		move.b d0,b
		move.w a,d0
		mulu #$44,d0
		clr.l a
		move.w d0,c
		add.l #font,a
		sub.l #2,a
		move.l a,a0
		lea letterbuf,a1
		move.w #16,d0
where		move.w 2(a0),6(a1)
		move.w 4(a0),14(a1)

		adda.l #160,a1				
		addq.l #4,a0
		dbf d0,where

		bra pointer1

do_scroll:      move.w  #1,d1  ; the letters are 37 pixels high
dosy		move.w #16,d0
		lea letterbuf,a1
		move.l #scrollbuf,a0
dosy1:           lsl.w   30(a1)  ; scroll 1 pixel to the left
		roxl.w  22(a1)
		roxl.w  14(a1)
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
                adda.l  #160,a1 
                adda.l  #160,a0 ; 160 bytes: one screen line down
                dbra    d0,dosy1 ; do the next screen line
		dbra    d1,dosy

		move.w #16,d0
		move.l $44e,a1
		add.l #$67c0,a1
		move.l #scrollbuf,a0
scrolmov         
                move.w 158(a0),158(a1)
                move.w  150(a0),150(a1)
                move.w 142(a0),142(a1)
                move.w  134(a0),134(a1)
                move.w 126(a0),126(a1)
                move.w  118(a0),118(a1)
                move.w 110(a0),110(a1)
                move.w  102(a0),102(a1)
                move.w  94(a0),94(a1)
                move.w 86(a0),86(a1)
                move.w  78(a0),78(a1)
                move.w  70(a0),70(a1)
                move.w 62(a0),62(a1)
                move.w  54(a0),54(a1)
                move.w 46(a0),46(a1)
                move.w 38(a0),38(a1)
                move.w 30(a0),30(a1)
                move.w  22(a0),22(a1)
                move.w 14(a0),14(a1)
                move.w 6(a0),6(a1)
                adda.l  #160,a1 
                move.w 158(a0),158(a1)
                move.w  150(a0),150(a1)
                move.w 142(a0),142(a1)
                move.w  134(a0),134(a1)
                move.w 126(a0),126(a1)
                move.w  118(a0),118(a1)
                move.w 110(a0),110(a1)
                move.w  102(a0),102(a1)
                move.w  94(a0),94(a1)
                move.w 86(a0),86(a1)
                move.w  78(a0),78(a1)
                move.w  70(a0),70(a1)
                move.w 62(a0),62(a1)
                move.w  54(a0),54(a1)
                move.w 46(a0),46(a1)
                move.w 38(a0),38(a1)
                move.w 30(a0),30(a1)
                move.w  22(a0),22(a1)
                move.w 14(a0),14(a1)
                move.w 6(a0),6(a1)
		adda.l #160,A1
                adda.l  #160,a0 ; 160 bytes: one screen line down
                dbra    d0,scrolmov
                rts             ; end of routine
wrap 		move.b #$20,d0
		lea scrolline,a0
		move.l a0,store
		bra pointer
wrap1 		move.b #$20,d0
		lea scrolline,a0
		move.l a0,store
		bra pointer1

a dc.b 0
b dc.b 0
c dc.b 0
d dc.b 0
indic	ds.w 1
store ds.l 1
count  dc.b 15
count1 dc.b 7
scrolline	dc.b "     WELCOME TO THE MEGA-BANG DEMO PRODUCED BY THE LOST BOYS USING THE BRILLIANT MICRODEAL SAMPLER, ST REPLAY 4, FOR MORE INFORMATION ON REPLAY PHONE 0726 68020.  "
		DC.B " THE SAMPLE COMES FROM A TRACK BY HAROLD FALTERMEYER CALLED 'SHOOTOUT'. IT WAS SAMPLED AT 7.5KHZ BY SPAZ USING ST REPLAY 4. THE PROGRAM AND THE GRAPHIXX WERE DONE BY MANIKIN. "
		DC.B " OTHER MEMBERS OF THE LOST BOYS ARE SAMMY JOE, THE SPROG FROM DEL MONTE AND THE TURTLE. GREETINGS TO MUG, MERLIN, NICO, VOLKMAR, VOLKER,  DAVE WOODHOUSE, AND BARKMANS OF KINGSTON.(NICK AND MIKE) "
		DC.B "ST-REPLAY 4 HAS MANY NEW FEATURES INCLUDING SAMPLE SHIFTING, MIDI TRIGGERING, FILTERING AND MUCH MORE MAKING IT BY FAR THE BEST SAMPLER ON THE ST. "
		DC.B "HOPE YOU ENJOY THIS DEMO. ALSO FROM THE LOST BOYS ARE THE POWER DEMO AND THE BAD MEDECINE DEMO, BOTH ARE FREELY AVAILABLE FROM ALL USUAL SOURCES. "
		DC.B " FINALLY THANKS TO 2 BIT SYSTEMS FOR THERE GREAT ST REPLAY WITHOUT WHICH THIS WOULD NOT HAVE BEEN POSSIBLE. "
		DC.B " GOODBYE, FAREWELL, AU REVOIR, AUF WIEDERSEHEN FROM THE LOST BOYS.......            ",$FF
		even
text	dc.b $1b,$45,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,"            The MEGABANG demo.",13,10,13,10,"             is now loading",0
	even

LOOPSTART
	move.w #1,indic
TH	MOVE.L SPINPOINT,A0
	MOVE.L (A0)+,A1
	MOVE.L A0,SPINPOINT
	CMP.L #0,A1
	BEQ RENEW
	CMP.L #1,A1
	Bne HJK
	MOVE.L #LOOP2START,JUMP1+2
	MOVE.L #LOOP2START,JUMP2+2
	BRA LOOP2START
HJK	MOVE.L $44e,A2
	add.l #$5018,a2
	MOVE.W #34,D1
MN
	MOVE.W #27,D0
KL	MOVE.L (A1)+,(A2)+
	DBF D0,KL
	ADD.L #48,A2
	DBF D1,MN
	rts
LOOP2START
	move.w #0,indic
LOOP2
PH	MOVE.L SPINPOINT,A0
	MOVE.L (A0)+,A1
	MOVE.L A0,SPINPOINT
	CMP.L #0,A1
	BEQ RENEW1
	CMP.L #1,A1
	BNE LKJ
	MOVE.L #LOOPSTART,JUMP1+2
	MOVE.L #LOOPSTART,JUMP2+2
	BRA LOOPSTART
LKJ	MOVE.L $44e,A2
	add.l #$5018,a2
	MOVE.W #34,D1
OP
	MOVE.W #27,D0
HJ	MOVE.L (A1)+,(A2)+
	DBF D0,HJ
	ADD.L #48,A2
	SUB.L #224,A1
	DBF D1,OP
	rts

RENEW1 	MOVE.L #SPINTAB,SPINPOINT
	BRA	PH
RENEW 	MOVE.L #SPINTAB,SPINPOINT
	BRA	TH

SPINPOINT	DC.L SPINTAB
SPINTAB		DC.L SPIN1,SPIN1,SPIN1,SPIN1,SPIN1,SPIN1,SPIN1,SPIN1,SPIN2,SPIN2,SPIN2,SPIN2,SPIN2,SPIN2,SPIN3,SPIN3,SPIN3,SPIN3,SPIN4,SPIN4,SPIN4,SPIN5,SPIN5,SPIN6,SPIN6,SPIN7,SPIN8,1
		DC.L SPIN9,SPIN10,SPIN10,SPIN11,SPIN11,SPIN12,SPIN12,SPIN12,SPIN13,SPIN13,SPIN13,SPIN13,SPIN14,SPIN14,SPIN14,SPIN14,SPIN14
		DC.L SPIN15,SPIN15,SPIN15,SPIN15,SPIN15,SPIN15,SPIN15,SPIN15,SPIN14,SPIN14,SPIN14,SPIN14,SPIN14,SPIN14,SPIN13,SPIN13,SPIN13,SPIN13,SPIN12,SPIN12,SPIN12,SPIN11,SPIN11,SPIN10,SPIN10,SPIN9,SPIN8,1
		DC.L SPIN7,SPIN6,SPIN6,SPIN5,SPIN5,SPIN4,SPIN4,SPIN4,SPIN3,SPIN3,SPIN3,SPIN3,SPIN2,SPIN2,SPIN2,SPIN2,SPIN2

		DC.L SPIN1,SPIN1,SPIN1,SPIN1,SPIN1,SPIN1,SPIN1,SPIN2,SPIN2,SPIN2,SPIN2,SPIN2,SPIN3,SPIN3,SPIN3,SPIN4,SPIN4,SPIN5,SPIN5,SPIN6,SPIN6,SPIN7,SPIN8,1
		DC.L SPIN9,SPIN10,SPIN10,SPIN11,SPIN11,SPIN12,SPIN12,SPIN13,SPIN13,SPIN13,SPIN14,SPIN14,SPIN14,SPIN14
		DC.L SPIN15,SPIN15,SPIN15,SPIN15,SPIN15,SPIN15,SPIN15,SPIN14,SPIN14,SPIN14,SPIN14,SPIN14,SPIN13,SPIN13,SPIN13,SPIN12,SPIN12,SPIN11,SPIN11,SPIN10,SPIN10,SPIN9,SPIN8,1
		DC.L SPIN7,SPIN6,SPIN6,SPIN5,SPIN5,SPIN4,SPIN4,SPIN3,SPIN3,SPIN3,SPIN2,SPIN2,SPIN2,SPIN2
		
		DC.L SPIN1,SPIN1,SPIN1,SPIN1,SPIN1,SPIN1,SPIN2,SPIN2,SPIN2,SPIN3,SPIN3,SPIN4,SPIN4,SPIN5,SPIN5,SPIN6,SPIN7,SPIN8,1
		DC.L SPIN9,SPIN10,SPIN11,SPIN11,SPIN12,SPIN12,SPIN13,SPIN13,SPIN14,SPIN14,SPIN14
		DC.L SPIN15,SPIN15,SPIN15,SPIN15,SPIN15,SPIN15,SPIN14,SPIN14,SPIN14,SPIN14,SPIN13,SPIN13,SPIN12,SPIN12,SPIN11,SPIN11,SPIN10,SPIN9,SPIN8,1
		DC.L SPIN7,SPIN6,SPIN5,SPIN5,SPIN4,SPIN4,SPIN3,SPIN3,SPIN2,SPIN2,SPIN2

		DC.L SPIN1,SPIN1,SPIN1,SPIN1,SPIN2,SPIN2,SPIN2,SPIN3,SPIN3,SPIN4,SPIN4,SPIN5,SPIN6,SPIN7,SPIN8,1
		DC.L SPIN9,SPIN10,SPIN11,SPIN11,SPIN12,SPIN12,SPIN13,SPIN13,SPIN14,SPIN14,SPIN14
		DC.L SPIN15,SPIN15,SPIN15,SPIN15,SPIN14,SPIN14,SPIN14,SPIN13,SPIN13,SPIN12,SPIN12,SPIN11,SPIN10,SPIN9,SPIN8,1
		DC.L SPIN7,SPIN6,SPIN5,SPIN5,SPIN4,SPIN3,SPIN3,SPIN2,SPIN2,SPIN2

		DC.L SPIN1,SPIN1,SPIN1,SPIN2,SPIN2,SPIN3,SPIN3,SPIN4,SPIN5,SPIN6,SPIN7,SPIN8,1
		DC.L SPIN9,SPIN10,SPIN11,SPIN12,SPIN12,SPIN13,SPIN13,SPIN14,SPIN14
		DC.L SPIN15,SPIN15,SPIN15,SPIN14,SPIN14,SPIN13,SPIN13,SPIN12,SPIN11,SPIN10,SPIN9,SPIN8,1
		DC.L SPIN7,SPIN6,SPIN5,SPIN5,SPIN3,SPIN3,SPIN2,SPIN2

		DC.L SPIN1,SPIN1,SPIN1,SPIN2,SPIN2,SPIN3,SPIN3,SPIN4,SPIN5,SPIN6,SPIN7,SPIN8,1
		DC.L SPIN9,SPIN10,SPIN11,SPIN12,SPIN12,SPIN13,SPIN13,SPIN14,SPIN14
		DC.L SPIN15,SPIN15,SPIN15,SPIN14,SPIN14,SPIN13,SPIN13,SPIN12,SPIN11,SPIN10,SPIN9,SPIN8,1
		DC.L SPIN7,SPIN6,SPIN5,SPIN5,SPIN3,SPIN3,SPIN2,SPIN2

		DC.L SPIN1,SPIN1,SPIN1,SPIN1,SPIN1,SPIN1,SPIN2,SPIN2,SPIN2,SPIN3,SPIN3,SPIN4,SPIN4,SPIN5,SPIN5,SPIN6,SPIN7,SPIN8,1
		DC.L SPIN9,SPIN10,SPIN11,SPIN11,SPIN12,SPIN12,SPIN13,SPIN13,SPIN14,SPIN14,SPIN14
		DC.L SPIN15,SPIN15,SPIN15,SPIN15,SPIN15,SPIN15,SPIN14,SPIN14,SPIN14,SPIN14,SPIN13,SPIN13,SPIN12,SPIN12,SPIN11,SPIN11,SPIN10,SPIN9,SPIN8,1
		DC.L SPIN7,SPIN6,SPIN5,SPIN5,SPIN4,SPIN4,SPIN3,SPIN3,SPIN2,SPIN2,SPIN2

		DC.L SPIN1,SPIN1,SPIN1,SPIN1,SPIN1,SPIN1,SPIN1,SPIN2,SPIN2,SPIN2,SPIN2,SPIN2,SPIN3,SPIN3,SPIN3,SPIN4,SPIN4,SPIN5,SPIN5,SPIN6,SPIN6,SPIN7,SPIN8,1
		DC.L SPIN9,SPIN10,SPIN10,SPIN11,SPIN11,SPIN12,SPIN12,SPIN13,SPIN13,SPIN13,SPIN14,SPIN14,SPIN14,SPIN14
		DC.L SPIN15,SPIN15,SPIN15,SPIN15,SPIN15,SPIN15,SPIN15,SPIN14,SPIN14,SPIN14,SPIN14,SPIN14,SPIN13,SPIN13,SPIN13,SPIN12,SPIN12,SPIN11,SPIN11,SPIN10,SPIN10,SPIN9,SPIN8,1
		DC.L SPIN7,SPIN6,SPIN6,SPIN5,SPIN5,SPIN4,SPIN4,SPIN3,SPIN3,SPIN3,SPIN2,SPIN2,SPIN2,SPIN2
		DC.L 0

SPINTABEND
SAMPLEPOINT	DC.L SAMPLETAB
FILE	DC.B "SHOOTOUT.SPL",0
	EVEN
FILE1	DC.B "MEGA.PI1",0
	EVEN
HANDLE	DS.W 1
	EVEN
SAMPLED
SHOOT1 EQU SAMPLED+45000
SHOOT2	EQU SHOOT1+35301
SHOOT3  EQU SHOOT2+35277
SHOOT4	EQU SHOOT3+71619
SHOOT5	EQU SHOOT4+35305
SHOOT6	EQU SHOOT5+35230
SHOOT7	EQU	SHOOT6+34332
SHOOT8  EQU SHOOT7+35217
SHOOTEND EQU	SHOOT8+20956


SAMPLETAB	DC.L SHOOT1,SHOOT2,SHOOT1,SHOOT2,SHOOT1,SHOOT2,SHOOT2,SHOOT3,SHOOT3,SHOOT4,SHOOT4,SHOOT5,SHOOT4,SHOOT5,SHOOT5,SHOOT6,SHOOT4,SHOOT5,SHOOT5,SHOOT6,SHOOT6,SHOOT7,SHOOT7,SHOOT8,SHOOT7,SHOOT8,SHOOT7,SHOOT8,SHOOT3,SHOOT4,SHOOT4,SHOOT5
		DC.L SHOOT5,SHOOT6,SHOOT4,SHOOT5,SHOOT5,SHOOT6,SHOOT6,SHOOT7 
		DC.L 0,0
string dc.b $12,$1a
oldssp ds.l 1
COLS
	dc.w $0,$444,$555,$666,$777,$233,$323,$425,$630,$750,$770,$773,$444,$555,$666,$777

SPINDATA
SPIN1	EQU SPINDATA
SPIN2	EQU SPIN1+3920
SPIN3	EQU SPIN2+3920
SPIN4	EQU SPIN3+3920
SPIN5	EQU SPIN4+3920
SPIN6	EQU SPIN5+3920
SPIN7	EQU SPIN6+3920
SPIN8	EQU SPIN7+3920
SPIN9	EQU SPIN8-112
SPIN10	EQU SPIN7-112
SPIN11 	EQU SPIN6-112
SPIN12	EQU SPIN5-112
SPIN13	EQU SPIN4-112
SPIN14	EQU SPIN3-112
SPIN15 	EQU SPIN2-112
	INCBIN "SPIN.DAT"
	INCBIN "SPIN2.DAT"
font
	incbin "lost.fon"
letterbuf
scrollbuf	equ letterbuf+5000