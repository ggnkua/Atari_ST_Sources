MAXVISSPRITES	=	64	; Max number of sprites to display
MAXACTORS	=	128	; max number of nazis etc.
MAXSTATICS	=	200	; max number of lamps, bonus etc.
MAXMISSILES	=	32	; max missiles, flames, smoke etc.
MINACTORDIST	=	128	; min distance from player center
				; to any actor

TI_ACTOR	=	7	; Actor here

		**** temporary ****
		**include	'temp\statics.s'

***********************************
*	
*  void RenderSprite(a0.l *thing)
*
* Draw a single scaled sprite
*
***********************************
		section	text
RenderSprite	move.w	SprTz(a0),d6
		cmpi.w	#MINZ,d6	; Too near?
		ble.w	.break
		
		lea.l	scaleatzptr,a1
		add.w	d6,d6
		move.w	(a1,d6.w),d2	; Scale at z
		beq.w	.break		; Too far?

		tst.b	detail		; Check level of detail
		beq.s	.lo

		lsr.w	d2		; Fix up scale in high detail mode

.lo		move.w	SprTx(a0),d0
		muls.w	d2,d0		; Left x
		asr.l	#6,d0
		move.w	xsize(pc),d3
		sub.w	d2,d3
		asr.w	d3
		add.w	d3,d0
		
		move.l	#64<<8,d3	; Stepsize
		divu.w	d2,d3
		
; Clip horizontally

		move.w	d0,d1		; x1
		add.w	d2,d1		; x2

		moveq.l	#0,d4		; column (8.8)

		tst.w	d0		; x1 out of left border?
		bpl.s	.x1_in
		
		muls.w	d3,d0		; Column = -x1*stepsize
		sub.l	d0,d4
		moveq.l	#0,d0		; x1 = 0
		
.x1_in		move.w	xsize(pc),d5
		cmp.w	d5,d1		; x2 out of right border?
		blt.s	.x2_in

		move.w	d5,d1
				
.x2_in		sub.w	d0,d1		; Width
		subq.w	#1,d1
		bmi.s	.break

		movem.l	d0-d4,-(sp)	; Compile scaler
		bsr.s	ScaleShape
		movem.l	(sp)+,d0-d4

		lea.l	ViewBuffer,a2	; Destination[x1]
		adda.w	d0,a2

		lea.l	ZBuffer,a4	; ZBuffer[x1]
		add.w	d0,d0
		adda.w	d0,a4

		movea.l	SprShape(a0),a0
		jmp	SprScaler
		
.break		rts		



*********************************
*
*  void ScaleShape(d2.w Scale,d3.w Stepsize)
*
* Compile a scaler for rendering a sprite
*
*********************************

ScaleShape	lea.l	.sliceloop(pc),a6
		lea.l	SprScaler,a4

	rept	3
		move.l	(a6)+,(a4)+
	endr
		move.w	(a6)+,(a4)+

		move.l	a4,-(sp)
		addq.l	#2,a4


		moveq.l	#0,d1		; Row

		tst.b	detail		; high detail?
		beq.s	.lo

		add.w	d2,d2		; scale *=2
		lsr.w	d3		; step /= 2

.lo		move.w	d2,d5
		movem.w	xsize(pc),d4/d7	; xsize, ysize
		

; Clip vertically

		sub.w	d2,d7		; Needs y clipping?
		bpl.s	.y_in

		add.w	d7,d5		; Clip scale
		asr.w	d7
		muls.w	d3,d7		; Clip Row
		sub.w	d7,d1
		moveq.l	#0,d7		; Clip Dest
		
.y_in		lsr.w	d7
		mulu.w	d4,d7		; Dest = xsize*(ysize-scale)/2

		movea.l	d4,a5
		
		lea.l	.scaletpl(pc),a2
		
		ext.l	d3		; Prepare variables for
		ror.l	#8,d3		; fast addx scaling
		adda.l	d3,a5
		suba.w	d3,a5
		
		ror.l	#8,d1
		add.l	d1,d7
		sub.w	d1,d7

		subq.w	#1,d5

		lea.l	-1.w,a1
		
.prescale	cmp.w	a1,d1		; Same as previous pixel?
		beq.s	.multi		; Yes, then optimize scaler

		move.w	(a2),(a4)+	; "move.b ..(a1),d0"
		move.w	d1,(a4)+	; "..source"
		movea.l	d1,a1		; Save source offset
		
		movea.l	a4,a3
		move.w	4(a2),(a4)+	; "bmi.s  *+x"

.multi		move.w	6(a2),(a4)+	; "move.b d0,..(a2)"
		move.w	d7,(a4)+
		addq.w	#4,(a3)		; Patch branch offset

		add.l	a5,d7		; (frac)Row|Dest += (frac)Step|DestYSkip
		addx.w	d3,d1		; (int)Row += (int)Step
		dbra	d5,.prescale


		movea.l	(sp)+,a3
		movea.l	a4,a2
		suba.l	a3,a2
		move.w	a2,(a3)
		
		move.l	(a6)+,(a4)+
		move.w	(a6)+,(a4)+
		lea.l	SprScaler,a2
		suba.l	a4,a2
		move.w	a2,(a4)+
		move.w	(a6)+,(a4)	; "rts"
		rts

.sliceloop	move.l	d4,d5
		clr.b	d5
		lsr.w	#2,d5		; (int)Column*64
		
		movea.l	a0,a1		; Source[Column]
		adda.l	d5,a1

		cmp.w	(a4)+,d6	; Behind a wall slice?
		dc.w	$6e00		; "bgt.w .skip"
	
		addq.w	#1,a2		; Destination++
		add.w	d3,d4		; Column += Stepsize
		dc.w	$51c9		; "dbra d1,.sliceloop"

		rts

	
.scaletpl	move.b 1(a1),d0
		dc.w	$6b00 		; "bmi.s *+x", for colorkeyed pixels
		move.b d0,1(a2)		; to be skipped
	

		section	bss
SprScaler	ds.w	2*6*MAXY+22	; Space for scaler




***********************************
*
*  void AddSprite(d7.w tileoffset)
*	
* Add a sprite entry to the render list
*
***********************************
		section	text
SprEventPtr	dc.l	SprEvents
numvisspr	dc.w	-1		; Visible sprites

AddSprite	cmpi.w	#MAXVISSPRITES-1,numvisspr
		bge.s	.break

		movem.l	d0-d3/a2,-(sp) ***

		lea.l	Actors,a1	; VisSpr = Actors[tileoffset]
		add.w	d7,d7
		add.w	d7,d7
		move.l	(a1,d7.w),d7	; blank entry?
		beq.s	.break		; so do not process it
		movea.l	d7,a1

		tas.b	(a1)		; Has sprite been seen yet?
		bne.s	.break		; Yes, then skip it

		movea.l	SprEventPtr(pc),a2; Current event pointer
		move.l	a1,(a2)+	; Save record
		move.l	a2,SprEventPtr

		btst.b	#TI_ACTOR,actornum(a1)	; Is this an actor?
		beq.s	.noactor		; Yes, so it has seen us

		; Mark as active & visible
		ori.b	#(1<<FL_ACTIVE)|(1<<FL_SEEPLAYER),flags(a1)

		
; transform the origin point

.noactor	addq.l	#SprX,a1
		move.l	(a1)+,d1	; trx, try
		sub.l	player.x(pc),d1
		move.l	d1,d0
		swap.w	d0
		move.w	d0,d2
		move.w	d1,d3
		
		movem.w	viewsin(pc),d6/d7
		muls.w	d7,d0		; tz
		muls.w	d6,d1
		add.l	d1,d0
		
		moveq.l	#10,d1
		asr.l	d1,d0
			
		muls.w	d6,d2		; tx
		muls.w	d7,d3
		sub.l	d2,d3
		asr.l	d1,d3
		
		move.w	d0,(a1)+	; Save coordinates
		move.w	d3,(a1)

		addq.w	#1,numvisspr	; 1 more valid record
		
.break		movem.l	(sp)+,d0-d3/a2 ****
		rts

	ifeq	1
/**********************************
	
	Draw a scaling game over sprite on top of everything
	
**********************************/

void DrawTopSprite(void)
{
	unsigned short *patch;
	int x1, x2;
	Word width;
	vissprite_t VisRecord;

	if (topspritescale) {		/* Is there a top sprite? */

/* calculate edges of the shape */

		patch = SpriteArray[topspritenum];		/* Get the info on the shape */
		
		width = (patch[0]*topspritescale)>>7;		/* Adjust the width */
		if (!width) {	
			return;		/* Too far away */
		}
		x1 = CENTERX - (width>>1);		/* Use the center to get the left edge */
		if (x1 >= SCREENWIDTH) {		
			return;		/* off the right side*/
		}
		x2 = x1 + width - 1;		/* Get the right edge */
		if (x2 < 0) {
			return;		/* off the left side*/
		}
		VisRecord.pos = patch;	/* Index to the shape record */
		VisRecord.x1 = x1;			/* Left edge */
		VisRecord.x2 = x2;			/* Right edge */
		VisRecord.clipscale = topspritescale;	/* Size */
		VisRecord.columnstep = (patch[0]<<8)/(x2-x1+1);	/* Width step */

/* Make sure it is sorted to be drawn last */

		memset(xscale,0,sizeof(xscale));		/* don't clip behind anything */
		if (x1<0) {
			x1 = 0;		/* Clip the left */
		}
		if (x2>=SCREENWIDTH) {
			x2 = SCREENWIDTH-1;	/* Clip the right */
		}
		RenderSprite(x1,x2,&VisRecord);		/* Draw the sprite */
	}
}
	endc

	
***********************************
*	
*  void DrawSprites()
*
* Draw all the character sprites
*	
**********************************

DrawSprites	move.w	numvisspr(pc),d0; Any sprites to draw?
		bmi.s	.break
		
; Sort sprites from back to front (Selection sort)

		lea.l	SprEvents,a1
		move.l	a1,SprEventPtr	; Reset event pointer

		move.w	d0,d1
		beq.s	.skipsort	; Only one sprite visable
		subq.w	#1,d1
		
.sort		movea.l	(a1),a2
		move.w	SprTz(a2),d4	; Assume farthest
		lea.l	4(a1),a3
		movea.l	a3,a5

		move.w	d1,d2
.farthest	movea.l	(a3)+,a4

		move.w	SprTz(a4),d5
		cmp.w	d4,d5
		bgt.s	.keep		; Farther away?

		move.w	d5,d4
		movea.l	a3,a5
.keep		dbra	d2,.farthest

		move.l	-(a5),(a1)+	; Exchange records
		move.l	a2,(a5)
		dbra	d1,.sort
		
.skipsort	addq.l	#4,a1


; Draw from the smallest scale to the largest

.sprloop	movea.l	-(a1),a0	; Which one?
		clr.b	(a0)		; Mark as invisible

		movem.l	d0/a1,-(sp)
		bsr.w	RenderSprite	; Draw the sprite
		movem.l	(sp)+,d0/a1

		dbra	d0,.sprloop
		
		move.w	d0,numvisspr
.break		rts


		section	bss
SprEvents	ds.l	MAXVISSPRITES	; List of *VisSprite