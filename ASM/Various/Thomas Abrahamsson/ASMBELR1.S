*
* HBL Color change...
* A6 reserved as colorpointer.
* Code BY Thomas Abrahamsson 1990
* For *INC* Magazine
* Documented version:
* (C) BlueSTar 1990
* Of course, this routine is not
* optimized at all, that's up to
* you (hehe)!
*


	pea		0  *Let's enter supervisor
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,nd+2 *Save old stack
	bsr	scra  * Build the screen
	bsr	bygg_lista *Prepare A6 color list,
	bsr	init *Init Interrupt routines....
	
lopen: *The main loop
	 .wait_vbl: *Wait for the VBL
	tst.b	vsync * Dito
	beq.s	.wait_vbl *Dito
	sf	vsync * Set false VBL flag
	cmp.b	#$81,$fffffc02.w *Key pressed?
	bne	lopen *Oh, no!
	bsr	bye *Reinstall old interrupts...
	MOVE.W	#$324,$FF8240 *Just for fun!

nd:	move.l	#0,-(sp)	 set user back
	move.w	#$20,-(sp)
	trap		#1
	add.l		#6,sp 
	clr.w	-(sp) *And good bye
	trap	#1 *END
****************************

bye:	move.w	#$2700,sr
shbl	move.l	#0,$120	      restore old interrupts
svbl	move.l	#0,$70
s09	move.b	#0,$fffa09
sxx	MOVE.B	#0,$FFFA07
s1b	move.b	#0,$fffa1b
s21	move.b	#0,$fffa21
	bset		#3,$fffffa17
	move.w	#$2300,sr
	rts
init:	move.w	#$2700,sr
	move.l	$120,shbl+2	*save old interrupts
	move.l	$70,svbl+2
	move.b	$fffa09,s09+3
	MOVE.B	$FFFA07,sxx+3
	move.b	$fffa1b,s1b+3
	move.b	$fffa21,s21+3
	move.l	#hbl,$120
	move.l	#vbl,$70
	MOVE.B	#1,$FFFA07
	MOVE.b	#0,$fffa09
	move.b	#1,$fffa21 *STEP step
	move.b	#8,$fffa1b
	bclr		#3,$fffffa17
	OR.B		#1,$FFFFFA13
	move.w	#$2300,sr
	rts
vbl:	move.w	#$770,$ff8240 *Check time!
	bsr		bygg_lista
	lea		fet_lista,a6
	st		vsync
	move.w	#$000,$ff8240 *Dito
	rte

scra: *Build screen
	*movem.l	pal,d0-d7 *New palette!
	*movem.l	d0-d7,$ff8240 *to $ff8240!
	move.l	$44e.w,a0 *Physbase.
	moveq.l	#39,d1 *40-1 Words in X.
	tjo:
	move.l	a0,a4 *Restore physbase
	add.w		#8,a0 * 8 out
	move.l	#200-1,d2 * 200 lines screen
	tji: *Big loop
	lea		img(pc),a2 * The bitplane data
	tju: *Little loop
	move.w	(a2)+,(a4) * To screen, PL0
	move.w	(a2)+,2(a4) *PL1
	move.w	(a2)+,4(a4) *PL2
	move.w	(a2)+,6(a4) *PL3
	lea		160(a4),a4 *160 bytes/ line
	dbra		d2,tji *Loop it thanx
	dbra		d1,tjo *Dito
	rts

*pal:   dc.w $0000,$0222,$0500,$0700,$0444,$0666,$0500,$0700 
*       dc.w $0620,$0730,$0650,$0770,$0620,$0730,$0650,$0770

img:	dc.w	%1010101010101010 *BITPLANE 0
	dc.w	%0110011001100110 *1
	dc.w	%0001111000011110 *2
	dc.w	%0000000000000000 *3 

 
hbl:  move.l	(a6)+,$ffff8240.w
	move.l	(a6)+,$ffff8244.w *AARRGH...
	move.l	(a6)+,$ffff8248.w
	move.l	(a6)+,$ffff824c.w
	rte

bygg_lista: *BUild colorlist!
	moveq		#0,d0
	moveq		#0,d1
	moveq		#0,d3
	add.w		#1,variabel *Sinus Counter Pointer
	move.w	variabel,d3
	cmp.w		#angel,d3 *loop sinus?
	bne.s		dier *NOO!
 	 clr.w	variabel *Yeah
	 moveq.l	#0,d3 *Funny
	dier:
	* Y in d3
	*lsl		#1,d3 *Mulu 2
	lea		sunis(pc),a4 *Data list
	move.b	(a4,d3.w),d3 *sinusdata to d3
	and.w		#7,d3 *And with 8 lower bits
	lea		fal_pal(pc),a0 *and offset into colorimg
	lsl		#4,d3 *Mulu 16, Eg ( 8 words per line = 16 bytes)
	add.w		d3,a0 *Offset this too
	lea		fet_lista(pc),a1 *Adress to the BIG list
	move.l	#24,d0 *25 * 8 = 200
	move.l	a0,a2 *Save
	so: * BIG loop
	move.l	a2,a0 *Add.er
	rept 	8
	move.l	(a0)+,(a1)+ *From Colorimg to BIG list
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+ *OPtimize with movem here yourself... (Jag orkar inte)
	move.l	(a0)+,(a1)+
	endr	 *8 ggr
	dbra		d0,so *Do loop
	clr.w		-16(A1)
	rts *Return.us

variabel:	dc.w	0 *Cnter
vsync	dc.w	0 *Flag
angel		equ	314 *Numebr siuns numbers
	even
sunis: * Y sinus data... Optimize here to use .b if you want to.
  * 0-155 ,Sektor  1/4 cirkel  0-99/0-99 x,y
   dc.b   127,129,132,134,137,139,142,144,147,149,152,154,157,159,162,164,166,169,171,174,176,178,181,183,185,187,190,192,194,196,198,200,202,204,206,208,210,212,214,216,218
   dc.b   219,221,223,224,226,228,229,231,232,233,235,236,237,239,240,241,242,243,244,245,246,247,247,248,249,250,250,251,251,252,252,252,253,253,253,253,253,253,253,253,253
   dc.b   253,253,253,252,252,252,251,251,250,250,249,248,247,247,246,245,244,243,242,241,240,239,237,236,235,233,232,231,229,228,226,225,223,221,219,218,216,214,212,210,208
   dc.b   207,205,203,200,198,196,194,192,190,188,185,183,181,178,176,174,171,169,167,164,162,159,157,154,152,149,147,144,142,139,137,134,132,129,127,124,122,119,117,114,111
   dc.b   109,106,104,101,99,97,94,92,89,87,84,82,80,77,75,73,70,68,66,64,61,59,57,55,53,51,49,47,45,43,41,39,37,36,34,32,30,29,27,26,24
   dc.b   23,21,20,18,17,16,15,13,12,11,10,9,8,7,6,6,5,4,4,3,2,2,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,2
   dc.b   2,3,3,4,5,5,6,7,8,9,10,11,12,13,14,16,17,18,19,21,22,24,25,27,28,30,32,33,35,37,39,41,42,44,46,48,50,52,54,57,59
   dc.b   61,63,65,67,70,72,74,77,79,81,84,86,89,91,93,96,98,101,103,106,108,111,113,116,118,121,124,126
   even

fal_pal:
	* IMAGE:
	rept	2
	dc.w	$0,$777,$777,$777,$777,$777,$777,$333
	dc.w	$0,$777,$222,$222,$222,$333,$333,$111
	dc.w	$0,$777,$222,$222,$333,$333,$333,$111
	dc.w	$0,$777,$222,$333,$333,$333,$333,$111
	dc.w	$0,$777,$333,$333,$333,$333,$444,$111
	dc.w	$0,$777,$333,$333,$333,$444,$444,$111
	dc.w	$0,$777,$333,$333,$444,$444,$444,$111
	dc.w	$0,$333,$111,$111,$111,$111,$111,$111
	endr

fet_lista:	ds.w	8*200

