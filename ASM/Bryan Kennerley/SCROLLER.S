** NEW AND IMPROVED SCROLLY INTRO FOR ST USER
** WITH ADDED ZIP, POW AND PEZAZ.
** by Bryan Kennerley.	28/4/90
** Source file for SCROLLER.PRG, a full screen
** multi-colour textscroller, ASTU Nov 1990!!!

	bra progbit

***********************************************
screenbases	dc.l 0,0,0
currlogno	dc.w 0
currphysno	dc.w 0
currlogbase	dc.l 0
currphysbase	dc.l 0

	dc.b "Coded by Bryan Kennerley, 21 Graham Drive, "
	dc.b "Rhyl, Clwyd. LL18 3RS.",0
	even
pathname
	dc.b "A:\AUTO\TITLE.PC1",0
	even

filehandle	dc.w 0
vfine		dc.w 0			curr line no.

drawscrollflag	dc.w 0			1 if redraw needed
screenswitchedflag
		dc.w 0

exitflag	dc.w 0
scrollmode	dc.w 0			0=slow up, 1=stop, 2=fast up

waitcount	dc.w -1			delay counter for middle pause
	even
***********************************************
** PROGRAM INITIALIZATION

progbit	bsr gosuper
	move.b #3,$FFFFFC04.w		disable midi (master reset)
	bsr mouseoff			disable mouse

	bsr savesysscreen		save system display

	bsr gen3screens			get 3 screens & wipe 'em
	move.l screenbases,currphysbase
	move #0,currphysno
	move.l screenbases+4,currlogbase
	move #1,currlogno

	bsr setlowrez			set up low rez display

*******************************************
** THIS LOADS A COMPRESSED DEGAS PICTURE

	move #0,-(sp)			open file
	move.l #pathname,-(sp)
	move #$3D,-(sp)
	trap #1
	add.l #8,sp

	move D0,filehandle
	tst.l D0			exit right now if file not found
	bmi exitprog2

********
	move.l #picbuff,-(sp)		load base
	move.l #32034,-(sp)		length
	move D0,-(sp)			file handle
	move #$3F,-(sp)
	trap #1				load the file
	add.l #12,sp

	tst.l D0			exit if something's dicky
	bmi exitprog2

	move filehandle,-(sp)		close file
	move #$3E,-(sp)
	trap #1
	add.l #4,sp

*******************************************
	movem.l $FFFF8240.w,D0-D7	save system colors
	movem.l D0-D7,syspal
	movem.l picbuff+2,D0-D7		set new palette
	movem.l D0-D7,$FFFF8240.w

	lea picbuff+34,A0		compressed data base
	lea backbuff,A1			temp 32000 byte buffer
	bsr decomppc1			decompress pic

******
	lea backbuff,A0			clear start/end of backdrop
	jsr clearscreen
	lea backbuff+64000,A0
	jsr clearscreen

	lea picbuff+34,A0		draw pic backwards
	lea backbuff+64000,A1		to middle of backdrop
	move #199,D7			200 lines
insl1	movem.l (A0)+,D0-D6/A2-A4
	movem.l D0-D6/A2-A4,-(A1)
	movem.l (A0)+,D0-D6/A2-A4
	movem.l D0-D6/A2-A4,-(A1)
	movem.l (A0)+,D0-D6/A2-A4
	movem.l D0-D6/A2-A4,-(A1)
	movem.l (A0)+,D0-D6/A2-A4
	movem.l D0-D6/A2-A4,-(A1)
	dbra D7,insl1

***********************************************
** START IT RUNNING

	move #0,exitflag
	move #400,vfine			point to last screen
	move #1,drawscrollflag		draw screen
	move #0,screenswitchedflag
	move #0,scrollmode		up slowly first
	move.l #scrollvb,$4EA.w		enable vertical blank routine

	bsr mainloop

	move.l #0,$4EA.w		disable vertical blank routine

***********************************************
exitprog
	movem.l syspal,D0-D7		reset sys palette
	movem.l D0-D7,$FFFF8240.w

exitprog2
	bsr restoresysscreen

	bsr mouseon
	move.b #$95,$FFFFFC04.w		enable midi again
	bsr gouser

	clr -(sp)			exit program
	trap #1

***********************************************
mainloop
	bsr dscreen			draw the screen if necessary
	bsr movescreen			do any screen movement
	bsr testkeys			check for key pressed

	tst exitflag			test for exit
	beq mainloop			and loop if not
	rts

***********************************************
* Remove these 3 semi-colons to see just how much
* processor time is used. The white section of the
* screen shows just how much is left. You may have
* to adjust your screen 'cos there ain't much of it!

dscreen	tst drawscrollflag		no update if no movement
	beq xdds18

	move #0,drawscrollflag
;	move $FFFF8240.w,-(sp)
;	move #$700,$FFFF8240.w
	bsr drawscroll
;	move (sp)+,$FFFF8240.w

wtl1	tst screenswitchedflag		only switch once per frame
	bne wtl1

	move.l currlogbase,D0		switch screenbases
	move.l D0,currphysbase
	lsr #8,D0
	move.b D0,$FFFF8203.w		video base low
	swap D0
	move.b D0,$FFFF8201.w		video base high
	move #1,screenswitchedflag	

	move currlogno,D0		get next logical screen no.
	addq #1,D0
	cmp #3,D0
	bne jki1
	moveq #0,D0
jki1	cmp currphysno,D0		don't overwrite current screen
	beq jki1

	move D0,currlogno		get logical screen pointer
	lsl #2,D0
	lea screenbases,A0
	move.l 0(A0,D0.w),currlogbase
xdds18	rts

***********************************************
movescreen
	cmp #2,scrollmode
	beq moveend
	cmp #1,scrollmode
	beq midpause

****
movestart
	move #1,drawscrollflag		first stage, slowly up
	move vfine,D0
	subq #1,D0
	cmp #200,D0			stop when middle reached
	bne xms1
	move #1,scrollmode		set for middle wait
	move #175,waitcount		of 3.5 secs
xms1	move D0,vfine
	rts

****
midpause
	rts				do nothing

****
moveend	move #1,drawscrollflag		end stage, fast up
	move vfine,D0
	subq #2,D0
	bcs xme1
	move D0,vfine
	rts

xme1	move #1,exitflag		exit when top reached
	rts

***********************************************
testkeys
	bsr testskey			test for key pressed
	tst.l D0			negative if key pressed
	bmi gkey
xtk1	rts

*********
gkey	bsr getskey			get keycode
	bclr #23,D0			ignore if key off bit set
	bne xtk1

	swap D0
	cmp.b #1,D0			ESC exits direct
	beq dexprog

	cmp.b #$39,D0			space exits normally
	bne xtk1
	move #2,scrollmode
	rts

dexprog	move #1,exitflag
	rts

***********************************************
scrollvb
	move currphysno,D0		signal next screen displayed
	addq #1,D0
	cmp #3,D0
	bne jki3
	moveq #0,D0
jki3	move D0,currphysno
	move #0,screenswitchedflag

	cmp #-1,waitcount		no count
	beq xsvb
	subq #1,waitcount		decrease counter
	bcc xsvb
	move #2,scrollmode		exit if timer expired

xsvb	rts

***********************************************
drawscroll
	move.l currlogbase,A1		point to end of logical screen
	add.l #32000,A1
	lea backbuff,A0			point to source data
	move vfine,D0
	mulu #160,D0
	add.l D0,A0

	moveq #24,D7

cl1	movem.l (A0)+,D2-D6/A2-A6	25*8 lines
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)

	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)

	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)

	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)

	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)

	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)

	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)

	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)
	movem.l (A0)+,D2-D6/A2-A6
	movem.l D2-D6/A2-A6,-(A1)

	dbra D7,cl1
	rts

***********************************************
	include STUFF.S

***********************************************
picbuff					;buffer for screen loading
backbuff	=	picbuff+32034	;backdrop definition
thing		=	backbuff+96000	;end of program

