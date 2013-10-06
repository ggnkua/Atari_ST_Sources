*-----------------------------------------------------------------------*
* Falcon Starfield by Graeme Mathieson (dodo)
*-----------------------------------------------------------------------*
* This routine is a realtime calculated starfield for the Falcon030 
* It runs in true colour mode at a resolution of 768x240, as true colour
* Mode is faster than any other mode for plotting coloured pixels. Each
* Star has 32 possible shades but It could be set up to display 64 shades
* of Green with very little effort. At the moment only 500 stars are 
* displayed. This can be changed to about 580 but it tends to flip into
* 25 frames so I settled for 500 stars. The amount of stars could be 
* further increased by getting rid of the system vbi but why bother!
* If anyone can be bothered, this demo could be made interactive by
* changing the values of xmov, ymov and zmov in the main routine. 
* However, Im going to concentrate on getting a DSP version going - this 
* will also perform 3d rotation on the points and I should have enough 
* processor time to do a lot more stars. If your wondering why theres no
* music, its because I dont see the point of putting music in a demo when
* I have a cd player sitting in front of me! If you really want music,
* get a desk accessory like proplay as it runs quite happily in the 
* background. Even if it does take about 30% processor time!
*
* Yours
*
* dodo.
*
*-----------------------------------------------------------------------*
		OPT	P=68030
*-----------------------------------------------------------------------*

stars		equ	500
shades	equ	32
movx		equ	0; movement in x direction
movy		equ	0; movement in y direction
movz		equ	18; movement in z direction
minx		equ 	-384
maxx		equ 	384
miny		equ 	-120
maxy		equ 	120
minz		equ 	-1024
maxz		equ 	900
d		equ	1024

*-----------------------------------------------------------------------*
* Macros
*-----------------------------------------------------------------------*

pushall	MACRO
            movem.l     d0-d7/a0-a6,-(sp)
            endm
popall      MACRO
            movem.l     (sp)+,d0-d7/a0-a6
            endm

*-----------------------------------------------------------------------*
* Hey ho here we go.
*-----------------------------------------------------------------------*

START:	clr.l		-(sp)
		move.w	#$20,-(sp)
		trap		#1
		addq.w	#6,sp
		move.l	d0,-(sp)
		move.b	#$12,$FFFFFC02
		jsr		GET_VIDEO
		jsr		MAIN
		jsr		RESTORE_VIDEO
		move.b	#8,$FFFFFC02
		move.w	#$20,-(sp)
		trap		#1
		addq.w	#6,sp
		move.w	#0,-(sp)
		trap		#1

*-----------------------------------------------------------------------*
* Main routine.
*-----------------------------------------------------------------------*

MAIN:		move.l	#SCR1+256,d0
		clr.b		d0
		move.l	#SCR2+256,d1
		clr.b		d1
		move.l	d0,LOGICAL
		move.l	d1,PHYSICAL
		move.l	#movx,xmov
		move.l	#movy,ymov
		move.l	#movz,zmov

		move.w	#$6c,d3
		moveq		#3,d2
		move.l	PHYSICAL,d1
		move.l	LOGICAL,d0
		jsr		SET_VIDEO
		pea		BLACK
		move.w	#1,-(sp)
		clr.w		-(sp)
		move.w	#93,-(sp)
		trap		#14
		lea		10(sp),sp
		bsr		createstars
		bsr 		CLRSCR
MAIN_LOOP:	bsr		wipestars
		bsr 		movestars
		bsr 		drawstars
		bsr		wait
		cmp.b		#57,$fffffc02.w
		bne.s		MAIN_LOOP
		rts	

*-----------------------------------------------------------------------*
* Wait Vbi
*-----------------------------------------------------------------------*

wait:		move.l	LOGICAL,d0
		move.l	PHYSICAL,LOGICAL
		move.l	d0,PHYSICAL
		move.l	buffer2,d0
		move.l	buffer,buffer2
		move.l	d0,buffer

		move.w	#-1,-(sp)
 		move.l	PHYSICAL,-(sp)
		move.l	LOGICAL,-(sp)
		move.w	#5,-(sp)
		trap		#14
		lea		12(sp),sp
		move.w	#37,-(sp)
		trap		#14	; vsync
		addq.w	#2,sp
		rts

*-----------------------------------------------------------------------*
* Draw starfield..
*-----------------------------------------------------------------------*

drawstars:	move.l	buffer,a0
		move.l	LOGICAL,a1
		lea		starsx,a2
		lea		starsy,a3
		lea		starsz,a4
		lea		ytable,a5
		lea		DepthTable,a6
		move.l	#d,d5
		move.w	#stars-1,d7
.loop:	move.l	(a2)+,d0
		move.l	(a3)+,d1
		move.l	(a4)+,d2		
		move.l	d2,d6	; depth

		neg.l		d2
		add.l		#d,d2
		tst.l		d2
		bne.s		.ok
		moveq		#1,d2
.ok		muls.w	d5,d0
		muls.w	d5,d1
		divs.w	d2,d0
		divs.w	d2,d1
		add.w		#768/2,d0
		add.w		#240/2,d1
		ext.l		d0
		ext.l		d1

		cmp.w		#768,d0
		bge.s		.skip
		cmp.w		#240,d1
		bge.s		.skip

		tst.w		d0
		bmi.s		.skip
		tst.w		d1
		bmi.s		.skip
		sub.l		#minz,d6			; translate z coord to 0
		divu.w	#((maxz-minz)/shades),d6; calc colour region.
		add.l		(a5,d1.l*4),d0
		move.w	(a6,d6.w*2),(a1,d0.l*2) ; plot star
		move.l	d0,(a0)+			; store offset of star
		dbra		d7,.loop
		rts
.skip		clr.l		(a0)+
		dbf 		d7,.loop
		rts

*-----------------------------------------------------------------------*
* Remove the drawn starfield..
*-----------------------------------------------------------------------*

wipestars:	move.l	buffer,a0
		move.l	LOGICAL,a1
		move.w	#stars/10-1,d7
.loop:
		REPT		10
		move.l	(a0)+,d0
		clr.w		(a1,d0.l*2)
		ENDR
		dbf 		d7,.loop
		rts

*-----------------------------------------------------------------------*
* Move the stars.
*-----------------------------------------------------------------------*

movestars:	move.w	#stars-1,d7
		lea		starsx,a0
		lea		starsy,a1
		lea		starsz,a2
		move.l	xmov,d3
		move.l	ymov,d4
		move.l	zmov,d5
.loop:	move.l	(a0),d0
		move.l	(a1),d1
		move.l	(a2),d2		

		add.l 	d3,d0
		cmp.l		#maxx,d0
		blt.s		.skip1
		sub.l		#maxx-minx,d0

.skip1:	add.l 	d4,d1
		cmp.l		#maxy,d1
		blt.s		.skip2
		sub.l		#maxy-miny,d1

.skip2	add.l 	d5,d2
		cmp.l		#maxz,d2
		blt.s		.skip3
		sub.l		#maxz-minz,d2

.skip3	move.l	d0,(a0)+
		move.l	d1,(a1)+
		move.l	d2,(a2)+
		dbf 		d7,.loop
		rts

*-----------------------------------------------------------------------*
* Initialise the star positions.
*-----------------------------------------------------------------------*

createstars:move.w	#stars-1,d7
		lea		starsx,a4
		lea		starsy,a5
		lea		starsz,a6
.loop:	move.w	#17,-(sp)
		trap		#14		;random
		addq.l	#2,sp
		divu.w	#maxx-minx,d0
		clr.w		d0
		swap		d0
		add.l		#minx,d0
		move.l	d0,(a4)+

		move.w	#17,-(sp)
		trap		#14		;random
		addq.l	#2,sp
		divu.w	#maxy-miny,d0
		clr.w		d0
		swap		d0
		add.l		#miny,d0
		move.l	d0,(a5)+

		move.w	#17,-(sp)
		trap		#14		;random
		addq.l	#2,sp
		divu.w	#maxz-minz,d0
		clr.w		d0
		swap		d0
		add.l		#minz,d0
		move.l	d0,(a6)+

		dbf 		d7,.loop
		rts

*--------------------------------------------------------------------------*
* Clear both screens
*--------------------------------------------------------------------------*

CLRSCR:	lea		SCR1,a0
		lea		SCR2+400*1024,a1
.lp		clr.l		(a0)+
		cmp.l		a1,a0
		blt.s		.lp
		rts

*--------------------------------------------------------------------------*
* Store details on current video settings.
*--------------------------------------------------------------------------*

GET_VIDEO:	move.w	#2,-(sp)
		trap		#14
		addq.w	#2,sp
		move.l	d0,OLD_PHYSIC
		move.w	#3,-(sp)
		trap		#14
		addq.w	#2,sp
		move.l	d0,OLD_LOGIC
		move.w	#4,-(sp)
		trap		#14
		addq.w	#2,sp
		move.w	d0,OLD_REZ
		move.w	#-1,-(sp)
		move.w	#88,-(sp)
		trap		#14
		addq.w	#4,sp
		move.w	d0,OLD_MODE
		rts

*--------------------------------------------------------------------------*
* Restore the original details on video settings.
*--------------------------------------------------------------------------*

RESTORE_VIDEO:
		move.w	OLD_MODE,d3
		move.w	OLD_REZ,d2
		move.l	OLD_LOGIC,d1
		move.l	OLD_PHYSIC,d0
		bsr		SET_VIDEO
		rts

*--------------------------------------------------------------------------*
* Change to new resolution.
*--------------------------------------------------------------------------*

SET_VIDEO:	pushall
		move.w	#37,-(sp)
		trap		#14
		addq.w	#2,sp
		popall
		move.w	d3,-(sp)
		move.w	d3,-(sp)
		move.w	d2,-(sp)
		move.l	d1,-(sp)
		move.l	d0,-(sp)
		move.w	#5,-(sp)
		trap		#14
		lea		14(sp),sp
		move.w	#88,-(sp)
		trap		#14
		addq.w	#4,sp
		move.w	#37,-(sp)
		trap		#14
		addq.w	#2,sp
		rts

*--------------------------------------------------------------------------*
* Data segment.
*--------------------------------------------------------------------------*

		DATA

buffer:	dc.l	buffera
buffer2:	dc.l	bufferb
ytable:
.offs 	set 0
		REPT	240
		dc.l	.offs
.offs		set 	.offs+768
		ENDR
		dcb.l	300,.offs
DepthTable:
.colval	set	0
		REPT	shades
		dc.w	(.colval<<11)|(.colval<<6)|.colval
.colval	set	.colval+1
		ENDR

*--------------------------------------------------------------------------*
* Bss segment.
*--------------------------------------------------------------------------*

		BSS

BLACK:	ds.l	2
xmov		ds.l	1
ymov		ds.l	1
zmov		ds.l	1
LOGICAL	ds.l	1
PHYSICAL	ds.l	1
buffera	ds.l	stars
bufferb	ds.l	stars
starsx	ds.l	stars
starsy	ds.l	stars
starsz	ds.l	stars
OLD_PHYSIC:	ds.l	1
OLD_LOGIC:	ds.l	1
OLD_REZ:	ds.w	1
OLD_MODE:	ds.w	1
SCR1:		ds.b	400*1024
SCR2:		ds.b	400*1024
