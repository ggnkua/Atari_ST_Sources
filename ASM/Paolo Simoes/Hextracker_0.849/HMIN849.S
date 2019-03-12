***************************************************************************
*
* PROG: HEXTRACKER MIN		version: 0.849		date:	10/04/2013
*
*==========================================================================
* FUNCTION:
*	Allows to replay a MOD for STF and STE.
*		STF performance:
*			- registers available	d0-d4/a0-a3 up to a5
*			- CPU available (minimum values for 4 voices):
*				-  7.8 KHz	80%
*				- 10.2 KHz	70%
*				- 12.5 KHz	60%
*				- 15.0 KHz	50%
*				- 17.0 KHz	40%
* FILES:
*	- HMIN849.PRG	this program
*	- MSYNT849.EXE	digisynth code part
*	- PSGTABxx.BLK	ST Replay type / Quartet type sound table
*	- xxxxxxxx.MOD	MOD file
*==========================================================================
* HISTORY:
*--------------------------------------------------------------------------
*	DATE		TIME	FORM	PCS	COMMENTS	
*--------------------------------------------------------------------------
*	11/04/2011	14:50	C00??	0.825	First version
*	15/04/2011	14:00	C00??	0.826	msynt826.exe
*	18/04/2011	12:00	C00??	0.830	msynt830.exe
*	20/04/2011	08:30	C00??	0.833	msynt833.exe
*	20/04/2011	22:30	C00??	0.834	msynt834.exe
*	21/04/2011	18:30	C00??	0.835	msynt835.exe
*	27/04/2011	18:30	C00??	0.836	msynt836.exe
*	04/05/2011	13:00	C00??	0.837	msynt837.exe
*	18/06/2011	13:00	C00??	0.840	msynt840.exe
*	22/06/2011	23:00	C00??	0.841	msynt841.exe
*	23/06/2011	23:00	C00??	0.842	msynt842.exe
*	01/07/2011	17:00	C00??	0.843	msynt843.exe
*	15/01/2013	19:30	C00??	0.844	msynt844.exe
*	15/03/2013	19:30	C00??	0.845	msynt845.exe
*	15/03/2013	19:30	C00??	0.846	msynt846.exe
*	20/03/2013	09:00	C00??	0.847	msynt847.exe
*	25/03/2013	09:00	C00??	0.848	msynt848.exe
*	10/04/2013	12:00	C00??	0.849	msynt849.exe
***************************************************************************
***************************************************************************
* PROGRAMSTART
***************************************************************************
programstart:

*////			The same start for all programs

	move.l	4(a7),a0		A0 -> program base page
	move.l	12(a0),d0		D0.l <- code size
	add.l	20(a0),d0		D0.l <- D0.l + data size
	add.l	28(a0),d0		D0.l <- D0.l + BSS size
	add.l	#zsbasepage+zsstacksize,d0	D0.l <- D0.l +extras
	addq.l	#1,d0			D0.l = required memory for program
	bclr	#0,d0			that has to be an EVEN value
	lea	0(a0,d0.l),a7		A7.l <- new value for Stack Pointer

*////			Now reserve this area only and free up the rest

	move.l	d0,-(sp)		memory size to reserve
	move.l	a0,-(sp)		start of the memory area to reserve
	clr	-(sp)
	move	#$4A,-(sp)		TOS Setblock
	trap	#1
	lea	12(sp),sp
	tst.l	d0			error ?
	bne.s	programend		no / yes => it's all over

*////			Go to SUPERVISOR mode now saving the TOS SSP

	clr.l	-(sp)
	move	#$20,-(sp)		TOS SUPERVISOR
	trap	#1
	addq	#6,sp
	lea	zsavedSSP(pc),a0
	move.l	d0,(a0)			save TOS SSP to restore it later

*////			Execute our main program

	bsr.s	mainprog		main program

*////			Go back to USER mode

	move.l	a7,usp			our Stack Pointer is now the USP
	move.l	zsavedSSP(pc),a7	restores the TOS SSP
	and	#$DFFF,sr		clears the SUPERVISOR bit in SR


***************************************************************************
* PROGRAMEND
***************************************************************************
programend:

*////			Go back to TOS

	clr	-(sp)
	move	#$4C,-(sp)		return to TOS desktop
	trap	#1

zsbasepage	equ	256
zsstacksize	equ	4096
zsavedSSP	ds.l	1


***************************************************************************
* MAINPROG
***************************************************************************
mainprog:	

*////			Init the system: memory, files ...
*////			and save context

	bsr	qinitsystem		init the system
	tst.b	d1			problems ?
	bne.s	lmainprog_0		no / yes => it's all over

*////			Load MOD

	bsr	lmod
	tst.b	d1			problems ?
	bne.s	lmainprog_0		no / yes => it's all over
	

*////			Play it

	bsr	play_it

*////			Restore TOS context and return the allocated memory

lmainprog_0
	bsr	qsetTOScontxt
	bsr	qreturnmem
	rts

zTOScontext	ds.w	67					C0002
bcontxtvideo	equ	0					C0002
bcontxtMFP	equ	50					C0002

zpmod		ds.l	1
zmodlength	ds.l	1
zmfptab		ds.b	184

zsSTEmaxfreq	dc.l	50200				0.835
*				Set STF freq to 23.6 KHz
zSTEfreqdiv	dc.b	1
*		1	50xxx
*		2	25xxx
*		3	16xxx
*		4	12xxx
* ...		X	50xxx / X
zoutype_ste_sp	dc.b	-1
*		-1	normal
*		0	25x50 multiplex
*		1	25/50 oversample
*		2	12/50 oversample
*		3	12/25 oversample

outype		ds.b	1
*		0	YM2149 ST REPLAY (needs st replay table file (check inidsk))
*		1	YM2149 QUARTET (needs quartet table file (check inidsk))
*		2	ST(E) MONO
*		3	ST(E) STEREO 

fdiv		dc.b	153

		even

*==========================================================================
*	FDIV main values
*==========================================================================
*	 86	 7492 Hz
*	 87	 7585 Hz
*	 88	 7680 Hz
*	 89	 7777 Hz
*	 90	 7876 Hz
*	 91	 7927 Hz
*	 92	 7979 Hz
*	 93	 8084 Hz
*	 94	 8192 Hz
*	 95	 8302 Hz
*	 96	 8416 Hz
*	 97	 8474 Hz
*	 98	 8533 Hz
*	 99	 8653 Hz
*	100	 8777 Hz
*	101	 8904 Hz
*	102	 9035 Hz
*	103	 9102 Hz
*	104	 9170 Hz
*	105	 9309 Hz
*	106	 9452 Hz
*	107	 9600 Hz
*	108	 9752 Hz
*	109	 9830 Hz
*	110	 9909 Hz
*	111	10072 Hz
*	112	10240 Hz
*	113	10413 Hz
*	114	10593 Hz
*	115	10685 Hz
*	116	10778 Hz
*	117	10971 Hz
*	118	11170 Hz
*	119	11377 Hz
*	120	11592 Hz
*	121	11702 Hz
*	122	11815 Hz
*	123	12047 Hz
*	124	12288 Hz
*	125	12538 Hz
*	126	12800 Hz
*	127	12934 Hz
*	128	13072 Hz
*	129	13356 Hz
*	130	13653 Hz
*	131	13963 Hz
*	132	14288 Hz
*	133	14456 Hz
*	134	14628 Hz
*	135	14985 Hz
*	136	15360 Hz
*	137	15753 Hz
*	138	16168 Hz
*	139	16384 Hz
*	140	16605 Hz
*	141	17066 Hz
*	142	17554 Hz
*	143	18070 Hz
*	144	18618 Hz
*	145	18904 Hz
*	146	19200 Hz
*	147	19819 Hz
*	148	20480 Hz
*	149	21186 Hz
*	150	21942 Hz
*	151	22341 Hz
*	152	22755 Hz
*	153	23630 Hz
*	154	24576 Hz
*	155	25600 Hz
*	156	26713 Hz
*	157	27306 Hz
*	158	27927 Hz
*	159	29257 Hz
*	160	30720 Hz
*	161	32336 Hz
*	162	34133 Hz
*	163	35108 Hz
*	164	36141 Hz
*	165	38400 Hz
*	166	40960 Hz
*	167	43885 Hz
*	168	47261 Hz
*	169	49152 Hz
*	170	51200 Hz
*	171	55854 Hz
*	172	61440 Hz
*==========================================================================
frep		ds.w	1

*==========================================================================
zitfparams	ds.w	17					0.846
*==========================================================================
bpmod		equ	0		MOD pointer
bpfreemem	equ	4		free memory pointer
bfreememsize	equ	8		size of free memory
boutputype	equ	12		Output type
bpymtab		equ	12		PSG lookup table
breplayfreq	equ	16		Replay frequency
b_no_shadow	equ	19		To set no shadow addressing
bvideores	equ	26		Mono / 60 Hz / TT / Falcon / CTxx
*==========================================================================
zpmodplay	ds.l	1
*==========================================================================
bsongidx	equ	$39

***************************************************************************
* PROC: QSAVECONTEXT
***************************************************************************
qsavecontext:
	move.l	a0,-(sp)
	lea	bcontxtvideo(a0),a0
	bsr	qsavidcontxt
	move.l	(sp)+,a0
	lea	bcontxtMFP(a0),a0
	bsr	qsavMFPcontxt
	rts


***************************************************************************
* PROC: INSTALL
***************************************************************************
install:
	bsr	wdrvmot
	move	#$2700,sr
	bsr	instvid
	bsr	psgoff
	bsr	inikey
	bsr	instmfp
	move	#$2300,sr
	rts


***************************************************************************
* PROC: QSETTOSCONTXT
***************************************************************************
qsetTOScontxt:
	move	#$2700,sr
	lea	zTOScontext(pc),a0
	lea	bcontxtvideo(a0),a0
	bsr	qsetvidcontxt
	bsr	psgoff
	bsr	restkey
	lea	zTOScontext(pc),a0
	lea	bcontxtMFP(a0),a0
	bsr	qsetMFPcontxt
	move	#$2300,sr
	rts


***************************************************************************
* PROC: QINITSYSTEM
***************************************************************************
qinitsystem:
	lea	zTOScontext(pc),a0
	bsr	qsavecontext
	bsr	qinitmemory		init memory
	tst.b	d1			problems ?
	bne.s	linitsystem_0		no / yes
	bsr	inidsk			init disk access
	tst.b	d1			problems ?
	bne.s	linitsystem_0		no / yes
	bsr	inivid			init video part
	bsr	qinitmfptab
	bsr	initrk
	moveq	#0,d1			all ok
linitsystem_0
	rts


***************************************************************************
* PROC: INITRK
*	- Inits the interface with the digisynt module
*	    ZPFREEMEM address is the start of the interface area
*	- Sets default output type (0 if STF 3 if STE)
***************************************************************************
initrk:
	move.b	zSTE(pc),d0		default STF output type = 0 = no STE

*	moveq	#0,d0			include to force a STF mode (0 STREP)

	beq.s	initrk0
	moveq	#3,d0			if STE set STE stereo

initrk0
	lea	outype(pc),a0
	move.b	d0,(a0)

	lea	zitfparams(pc),a0
	move.l	zpfreemem(pc),bpfreemem(a0)
	move.l	zfreememsize(pc),bfreememsize(a0)
	move.b	outype(pc),boutputype(a0)				0.835

	move.b	zvideores(pc),d0					0.832
	and.b	#%1111000,d0			space for zaboveSTE	0.837
	or.b	zNTSC(pc),d0						0.832
	move.b	d0,bvideores(a0)			set only once	0.832


*						BVIDEORES
*						76543210
*						R----AAT
*						0    |||	Color
*						1    |||	Mono
*						     00|	ST / STE
*						     10|	TT
*						     11|	Falcon / CTxx
*						       0	Color VBL/HBL Sync
*						       1	Timer Sync

	moveq	#0,d0
	move.l	psynt(pc),a1
	jsr	(a1)				init digisynth
	lea	zpmodplay(pc),a1		stores pointers to ZMODPLAY
	move.l	a0,(a1)

	tst.l	d0					0.835
	beq.s	initrk5					0.835
	lea	zsSTEmaxfreq+2(pc),a0			0.835
	move	d0,(a0)					0.835
initrk5

	lea	zitfparams(pc),a0
	lea	zpfreemem(pc),a1
	move.l	bpfreemem(a0),(a1)
	lea	zfreememsize(pc),a1
	move.l	bfreememsize(a0),(a1)


	move.b	outype(pc),d0
	and.b	#%00011111,d0
	cmp.b	#2,d0
	beq.s	initrk6
	cmp.b	#3,d0
	bne.s	initrk7
initrk6
	move.l	zsSTEmaxfreq(pc),d1				0.835
	moveq	#0,d2
	move.b	zSTEfreqdiv(pc),d2
	divu	d2,d1
	lea	frep(pc),a0
	move	d1,(a0)			Set the STE replay frequency
initrk7

	rts


***************************************************************************
* PROC: LMOD
***************************************************************************
lmod:
	clr	-(sp)
	pea	zfilename(pc)
	bsr	bload			load file
	addq	#6,sp
	tst.b	d1			error ?
	bmi	lmodE			if yes then end of the job

	lea	zfilename(pc),a2	A2.l points to filename
	move.l	d0,d2			D2.l contains the original file size


	lea	zitfparams(pc),a0
	move.l	zpfreemem(pc),bpmod(a0)
	move.l	zpfreemem(pc),bpfreemem(a0)
	move.l	zfreememsize(pc),bfreememsize(a0)

	move.b	outype(pc),d0
	move.b	zoutype_ste_sp(pc),d1		0.845 end
	bmi.s	lmod_2				100xxxxx	Multiplex 25/50
	moveq	#4,d3				01xxxxxx	Oversample 50
	sub.b	d1,d3				001xxxxx	Oversample 25
	lsl	#5,d3				000xxxxx	Normal
	or.b	d3,d0				0.845 end
lmod_2
	move.b	d0,boutputype(a0)

	moveq	#7,d0
	move.l	psynt(pc),a1
	jsr	(a1)			MOD convert
	tst	d1
	bne.s	lmodE

	lea	zpmod(pc),a1		file start
	move.l	a0,(a1)
	lea	zmodlength(pc),a1	file length
	move.l	d0,(a1)

*	move.b	outype(pc),d2
*	and.b	#%00011111,d2
*	cmp.b	#3,d2			STE stereo ?
*	beq.s	lmod_stereo
*	move.b	#$10,29(a0)		You can force a VQ factor here
*					The VQ in stereo is ALWAYS lower
*					than the VQ in mono for the same
*					MOD. Check the tracker !
*					The VQ for multiplex is also
*					lower than for non multiplex.
lmod_stereo

	lea	zitfparams(pc),a0
	lea	zpfreemem(pc),a1
	move.l	bpfreemem(a0),(a1)
	lea	zfreememsize(pc),a1
	move.l	bfreememsize(a0),(a1)

	moveq	#0,d1			no error
	bra.s	lmod4_01
lmodE:
	moveq	#-1,d1			error
lmod4_01:
	rts

***************************************************************************
* PROC: PLAY_IT
***************************************************************************
play_it:

	move.l	zpmodplay(pc),a0
	clr.b	bsongidx(a0)		

	lea	zitfparams(pc),a0
	move.l	zpmod(pc),bpmod(a0)
	move.l	zpfreemem(pc),bpfreemem(a0)
	move.l	zfreememsize(pc),bfreememsize(a0)
	move.b	outype(pc),d0
	bne.s	play_it2
	move.l	preptab(pc),bpymtab(a0)
	bra.s	play_it3
play_it2:
	move.l	pquatab(pc),bpymtab(a0)
play_it3:

	move.b	zoutype_ste_sp(pc),d1		0.845 end
	bmi.s	play_it3z			100xxxxx	Multiplex 25/50
	moveq	#4,d2				01xxxxxx	Oversample 50
	sub.b	d1,d2				001xxxxx	Oversample 25
	lsl	#5,d2				000xxxxx	Normal
	or.b	d2,d0				0.845 end
play_it3z
	move.b	d0,boutputype(a0)
	move	frep(pc),breplayfreq(a0)
	moveq	#1,d0
	move.l	psynt(pc),a1
	jsr	(a1)				init MOD to be played

	tst	d0
	bne	play_ite

	lea	zitfparams(pc),a0
	lea	zpfreemem(pc),a1
	move.l	bpfreemem(a0),(a1)
	lea	zfreememsize(pc),a1
	move.l	bfreememsize(a0),(a1)


	bsr	install				install special context

*****************************************************************************
********
********			BE VERY CAREFULL !!!!
********
********	FROM THE NEXT JSR ON, PART OF THE LOW MEMORY OF THE CPU
********	WILL BE SWITCHED BECAUSE THE REPLAYER NEEDS IT
********	ADDRESSES FROM $140 TO $7FFF ON STF/STE
********	ADDRESSES FROM $900 TO $7FFF ABOVE STF/STE
********	Take care of your vectors !!!
********
********			BE VERY CAREFULL !!!!
********
********	from bsr "mfpset" in case of STF you can only use d0-d4/a0-a3
********	if you also want a4, and don't mind a small slow down
********	then you can add before that bsr:
********
********	lea	qymupdate2(pc),a0
********	move.l	a0,$134.w
********
********	This updates the timer A interrupt handler.
********	If you need even more registers and accept more slow down, then
********	on top of what you did, you can still modify that rout
********	as long as you understood what it does ... :)
********	Ok, then have a look at qymupdate3 you have now a5 too ...
*****************************************************************************

	lea	zitfparams(pc),a0
	moveq	#2,d0
	move.l	psynt(pc),a1
	jsr	(a1)				Low level init

	bsr	mfpset

	lea	old_color(pc),a1
	move	$8240.w,(a1)

	lea	locsync(pc),a0
	move.b	$469.w,d0
	subq.b	#1,d0
	move.b	d0,(a0)

****					START MAIN PLAY LOOP

play_it5:
	bsr	wsync
	bne.s	force_it			Stop if frequency is too high
*	bsr	qwaitVBL			Wait vertical blanking


*				Here you can check how much time is left
	lea	$8240.w,a0
	move	#$700,(a0)
	move	#43,d3		number of scan lines - 1 (example 44 lines)
*				(worst case for 23.6 KHz STF replay 14% CPU free)
*				(worst case for 50 KHz STE is 49 lines 15.5% CPU free)
linelp
	move.l	(a0),(a0)	24 move.l + dbf = 512 cycles = 1 scan line (50 Hz)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	move.l	(a0),(a0)
	dbf	d3,linelp
	move	#$037,(a0)

	lea	zitfparams(pc),a0
	moveq	#3,d0
	move.l	psynt(pc),a1
	jsr	(a1)				PLAY IT !!!

	move	old_color(pc),$8240.w

	tst	d0				Problems ?
	bne.s	force_it			no / yes

	cmp.b	#$B9,$FC02.w			Space pressed ?
	bne.s	play_it5			yes / no

****					END MAIN PLAY LOOP

force_it:
	bsr	mfprest				Stop timers

*****************************************************************************

********			BE VERY CAREFULL !!!!
********
********	FROM THE NEXT JSR ON THE LOW MEMORY NEEDED IS COPIED BACK
********	TO WHERE IT WAS:
********	ADDRESSES FROM $140 TO $7FFF ON STF/STE
********	ADDRESSES FROM $900 TO $7FFF ABOVE STF/STE
********	Take care of your vectors !!!
********	from bsr "mfprest" in case of STF as timer A was stopped
********	you can now use all registers again.
*****************************************************************************

	lea	zitfparams(pc),a0
	moveq	#4,d0
	move.l	psynt(pc),a1
	jsr	(a1)				Stop and restore

	lea	zitfparams(pc),a0
	lea	zpfreemem(pc),a1
	move.l	bpfreemem(a0),(a1)
	lea	zfreememsize(pc),a1
	move.l	bfreememsize(a0),(a1)

play_ite:
	rts

qymupdate2:
	move	(a6)+,a5		08
	move	(a5)+,d5		08
	move	(a5)+,d6		08
	move	(a5),d7			08
	movem.l	d5-d7,$8800.w		44
	rte				76 + rte + interrupt

qymupdate3:
	move	(a6)+,d7		08
	move.l	a6,usp			04
	move	d7,a6			04
	move	(a6)+,d5		08
	move	(a6)+,d6		08
	move	(a6),d7			08
	move	usp,a6			04
	movem.l	d5-d7,$8800.w		44
	rte				88 + rte + interrupt

old_color	ds.w	1

***************************************************************************
* PROC: MFPSET
***************************************************************************
mfpset:
	move	#$2700,sr
	move.b	outype(pc),d0
	and.b	#%00011111,d0
	cmp.b	#2,d0			STE mono ?
	beq.s	mfpste
	cmp.b	#3,d0			STE stereo ?
	beq.s	mfpste
	clr.b	$FA19.w
	moveq	#0,d0
	move.b	fdiv(pc),d0
	lea	zmfptab(pc),a0
	move.b	0(a0,d0),d0
	cmp.b	#175,d0
	scc	d1
	bcs.s	mfpset0
	sub.b	#$FF,d0
	neg.b	d0
mfpset0:
	and.b	#$01,d1
	addq.b	#1,d1
	move.b	d0,$FA1F.w
	move.b	d1,$FA19.w
	bset	#5,$FA07.w
	bset	#5,$FA13.w
mfpste:

	move.b	zvideores(pc),d0	High resolution ?
	bmi.s	mfpset4			no / yes
	move.b	zNTSC(pc),d0		60 Hz ?			0.832
	bne.s	mfpset4			no / yes		0.832
	lea	vblmono(pc),a0		comment these 2 lines and leave the
	move.l	a0,$70.w		next one in to have a VBL sync in colour
	bra.s	mfpset1			Comment to force a timer sync in colour
mfpset4:

	lea	vblmono(pc),a0
	move.l	a0,$70.w
	and.b	#$0F,$FA1D.w
	move.b	#246,$FA23.w
*	or.b	#$70,$FA1D.w		divide by 200	0.848
	or.b	#$60,$FA1D.w		divide by 100	0.848
*	lea	refresh(pc),a0				0.848
	lea	refresh1(pc),a0				0.848
	move.l	a0,$114.w
	lea	refresh2(pc),a1				0.848
	move.l	a1,8(a0)				0.848
	move.l	a0,8(a1)				0.848
	bset	#5,$FA09.w
	bset	#5,$FA15.w
	bra.s	mfpset2
mfpset1:
	clr.b	$FA1B.w
	bset	#0,$FA07.w
	bset	#0,$FA13.w
mfpset2:
	move	#$2300,sr
	rts


***************************************************************************
* PROC: MFPREST
***************************************************************************
mfprest:
	move	#$2700,sr
	lea	vbl(pc),a0
	move.l	a0,$70.w
	clr.b	$FA19.w			STOP TIMER A
	bclr	#5,$FA07.w
	bclr	#5,$FA13.w
	clr.b	$FA1B.w			STOP TIMER B
	bclr	#0,$FA07.w
	bclr	#0,$FA13.w
	and.b	#$0F,$FA1D.w		STOP TIMER C
	bclr	#5,$FA09.w
	bclr	#5,$FA15.w
	move	#$2300,sr
	rts


***************************************************************************
* PROC: QINITMEMORY
*
* CHANGED:	01/03/2005	VERSION:	001
* FUNCTION:
*	Inits the memory allocation system by allocating all the available
*	memory except 4096 bytes that will be reserved for GEM.
* DESCRIPTION:
*	- Determines all available memory
*	- Substracts 4096 bytes
*	- Allocates the remaining amount
* RECEIVES:
*	NONE
* RETURNS:
*	- D1.b		$00 all ok	$FF error
*	- ZPFREEMEM	pointer to the current start of free memory
*	- ZFREEMEMSIZE	current number of available bytes
*	- ZPRETURNMEM	initial value of ZPFREEMEM
* CALLS:
*	TOS
* CHANGES(X)/USES(u):
* 	 D0   D1   D2   D3   D4   D5   D6   D7  A0 A1 A2 A3 A4 A5 A6 A7 US
*	XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XX XX XX XX XX XX XX uu --
***************************************************************************
qinitmemory:
	move.l	#-1,-(sp)		get total amount of free memory
	move	#$48,-(sp)
	trap	#1
	addq	#6,sp
	tst.l	d0			any memory available ?
	smi	d1			set D1.b with $FF if problems
	bmi.s	linitmemory_0
	sub.l	#4096,d0		memory for GEM
	smi	d1			set D1.b with $FF if problems
	bmi.s	linitmemory_0
	lea	zfreememsize(pc),a0
	move.l	d0,(a0)
	move.l	d0,-(sp)		allocate total amount of memory
	move	#$48,-(sp)
	trap	#1
	addq	#6,sp
	tst.l	d0
	smi	d1			set D1.b with $FF if problems
	bmi.s	linitmemory_0
	lea	zpfreemem(pc),a0
	move.l	d0,(a0)
	lea	zpreturnmem(pc),a0
	move.l	d0,(a0)
	moveq	#0,d1
linitmemory_0
	rts


***************************************************************************
* PROC: QMALLOC
*
* CHANGED:	01/03/2005	VERSION:	001
* FUNCTION:
*	Tries to allocate a number of bytes specified in D0.l, returning a
*	pointer in A0.l and the remaining bytes in D0.l
* DESCRIPTION:
*	- turns the requested size an even number
*	- checks if the remaing bytes will be >= 0
*	- calculates the new values for ZFREEMEMSIZE and ZPFREEMEM
*	- returns as pointer the old value of ZPFREEMEM
* RECEIVES:
*	- D0.l		number of bytes of allocate
*	- ZPFREEMEM	pointer to the current start of free memory
*	- ZFREEMEMSIZE	current number of available bytes
* RETURNS:
*	- A0.l		pointer to allocated memory
*	- D0.l		remaining free bytes (must be >= 0)
*	- ZPFREEMEM	pointer to the current start of free memory
*	- ZFREEMEMSIZE	current number of available bytes
* CALLS:
*	NONE
* CHANGES(X)/USES(u):
* 	 D0   D1   D2   D3   D4   D5   D6   D7  A0 A1 A2 A3 A4 A5 A6 A7 US
*	XXXX uuuu ---- ---- ---- ---- ---- ---- XX uu -- -- -- -- -- uu --
***************************************************************************
qmalloc:
	movem.l	d1/a1,-(sp)		saves used registers
	addq.l	#1,d0
	bclr	#0,d0			request even number of bytes C0001
	lea	zfreememsize(pc),a1
	move.l	(a1),d1
	sub.l	d0,d1			remaining free bytes >= 0 ?
	bmi.s	lmalloc_0		yes / no
	move.l	d1,(a1)
	lea	zpfreemem(pc),a1
	move.l	(a1),a0			pointer to allocated area
	add.l	a0,d0
	move.l	d0,(a1)
lmalloc_0
	move.l	d1,d0			copies remaing bytes to D0.l
	movem.l	(sp)+,d1/a1		restores used registers
	rts	


***************************************************************************
* PROC: QMFREE
*
* CHANGED:	01/03/2005	VERSION:	001
* FUNCTION:
*	Sets a new start of free memory with the pointer received in A0.l.
*	Updates ZPFREEMEM with it and calculates ZFREEMEMSIZE using
*	the old value from ZPFREEMEM
* DESCRIPTION:
*	- turns the provided pointer an even number
*	- sets the new value for ZPFREEMEM
*	- calculates the new value for ZFREEMEMSIZE
* RECEIVES:
*	- A0.l		new start for free memory
*	- ZPFREEMEM	pointer to the current start of free memory
*	- ZFREEMEMSIZE	current number of available bytes
* RETURNS:
*	- ZPFREEMEM	pointer to the current start of free memory
*	- ZFREEMEMSIZE	current number of available bytes
* CALLS:
*	NONE
* CHANGES(X)/USES(u):
* 	 D0   D1   D2   D3   D4   D5   D6   D7  A0 A1 A2 A3 A4 A5 A6 A7 US
*	uuuu ---- ---- ---- ---- ---- ---- ---- XX uu -- -- -- -- -- uu --
***************************************************************************
qmfree:
	movem.l	d0/a1,-(sp)		saves used registers
	move.l	a0,d0
	addq.l	#1,d0
	bclr	#0,d0
	move.l	d0,a0			pointer is now an even number
	lea	zpfreemem(pc),a1
	move.l	(a1),d0			old free memory pointer
	sub.l	a0,d0			- new pointer = new free area
	bcs.s	lmfree_0		problems ? yes / no
	move.l	a0,(a1)			set new value for ZPFREEMEM
	lea	zfreememsize(pc),a1
	add.l	d0,(a1)			add it to ZFREEMEMSIZE
lmfree_0
	movem.l	(sp)+,d0/a1		restores used registers
	rts	


***************************************************************************
* PROC: QRETURNMEM
*
* CHANGED:	01/03/2005	VERSION:	001
* FUNCTION:
*	Returns the allocated memory to TOS when quitting the program
* DESCRIPTION:
*	- Returns the allocated memory to TOS using ZPRETURNMEM
* RECEIVES:
*	- ZPRETURNMEM
* RETURNS:
*	NONE
* CALLS:
*	TOS
* CHANGES(X)/USES(u):
* 	 D0   D1   D2   D3   D4   D5   D6   D7  A0 A1 A2 A3 A4 A5 A6 A7 US
*	XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX XX XX XX XX XX XX XX uu --
***************************************************************************
qreturnmem:
	move.l	zpreturnmem(pc),-(sp)
	move	#$49,-(sp)
	trap	#1
	addq	#6,sp
	rts


***************************************************************************
* DATA
*
***************************************************************************

zpfreemem	ds.l	1
zfreememsize	ds.l	1
zpreturnmem	ds.l	1

*****			VIDEO PART			*****

***************************************************************************
* PROC: INIVID
***************************************************************************
inivid:
	move.b	$820A.w,d0					0.832
	not.b	d0						0.832
	and.b	#%00000010,d0					0.832
	lsr.b	#1,d0						0.832
	lea	zNTSC(pc),a0					0.832
	or.b	d0,(a0)						0.832
	move.b	$8260.w,d0		actual resolution
	and.b	#%00000011,d0		keeps only the relevant bits
	cmp.b	#$02,d0			high resolution ?
	seq	d1			yes => D1 <- $FF / no D1 <- $00
	and.b	#%11111100,d1		yes => D1 <- $FC / no D1 <- $00
	or.b	d1,d0			yes => D1 <- $FE / no D1 <- $00/01
	lea	zvideores(pc),a0
	move.b	d0,(a0)			keep this in ZVIDEORES
	rts


***************************************************************************
* PROC: VBL
***************************************************************************
vbl:
	addq.b	#1,$469.w		Increments sync counter
vblmono:
*	rte				set to have VBL sync or timer in colour

	move.l	d0,-(sp)
	move.b	zvideores(pc),d0	High res ?
	bmi.s	vbl0			no / yes
	move.b	zNTSC(pc),d0		60 Hz ?			0.832
	bne.s	vbl0			no / yes		0.832

	clr.b	$FA1B.w			Stop timer B
	move.b	#200,$FA21.w		200 lines
	move.b	#8,$FA1B.w		Timer B event count
	pea	hbl_sync(pc)
	move.l	(sp)+,$120.w
vbl0:
	move.l	(sp)+,d0
	rte

hbl_sync:
	addq.b	#1,$469.w
	clr.b	$FA1B.w
	rte

***************************************************************************
* PROC: QSAVIDCONTXT
***************************************************************************
qsavidcontxt:

	move.l	a0,-(sp)

****				=> First detect if we have STE or above

	bsr	qwaitVBL		Wait vertical blanking
	moveq	#0,d4			default = STF
	lea	$8242.w,a0
	move	(a0),d5			save color
	move	#$0555,d0
	move	#$0AAA,d1
	move	d0,(a0)
	move	(a0),d2
	and	#$0FFF,d2
	move	d1,(a0)
	move	(a0),d3
	and	#$0FFF,d3
	cmp	d0,d2
	bne.s	lsavid0
	cmp	d1,d3
	bne.s	lsavid0
	moveq	#1,d4			STE detected

	move.l	$8.w,d1			old bus error routine pointer	0.846
	lea	lbuserr(pc),a1						0.846
	move.l	a1,$8.w			new bus error handler		0.846

	lea	savebuserr(pc),a1					0.848
	move.l	a7,(a1)+						0.848
	move	sr,(a1)+						0.848

	move.b	$8921.w,d0		cause bus error if no real STE	0.846
lreturnberr
	move.l	d1,$8.w			restore old bus error pointer	0.846

lsavid0
	move	d5,(a0)			restore color
	lea	zSTE(pc),a0
	move.b	d4,(a0)

****				=> Now detect if we have a machine above STE

	moveq	#0,d1			no timer sync forced
	moveq	#0,d2			simple STF or STE
	move.b	zSTE(pc),d0		STE or above ?
	beq.s	lsavid3			yes / no (simple STF)
	move.l	$05A0.w,d0
	beq.s	lsavid3
	move.l	d0,a0
lsavid1
	moveq	#0,d2			simple STF or STE
	move.l	(a0)+,d0		get signature
	beq.s	lsavid3
	moveq	#3,d2			set Falcon
	cmp.l	#'CT60',d0		CT60 ?
	seq	d1
	beq.s	lsavid3
	cmp.l	#'_MCH',d0		STE / TT / Falcon ?
	beq.s	lsavid2
	addq	#4,a0			jump over value
	bra.s	lsavid1			loop to get next one (danger !)
lsavid2
	move	(a0)+,d2		get identifier
	cmp	#1,d2			STE ?
	sne	d1			set D1.b if NOT STE but above !
	and	d1,d2			set to 0 if STE
lsavid3
	and.b	#%00000001,d1		keep only bit 0
	lea	zaboveSTE(pc),a0				0.835
	move.b	d2,(a0)						0.835
	lea	zNTSC(pc),a0					0.832
	move.b	d1,(a0)						0.832
	add.b	d2,d2						0.837
	or.b	d2,(a0)						0.837

****				=> Now use the information to fetch the data

	move.l	(sp)+,a0

	move.b	zaboveSTE(pc),d1
	beq.s	lsavid3a

	lea	zitfparams+b_no_shadow(pc),a1				0.846
	bset	#1,(a1)			set no shadow addressing mode	0.846

lsavid3a
	cmp.b	#3,d1			Falcon or CT60 ?
	bne.s	lsavid4			yes / no

	move.l	a0,-(sp)
	move	#-1,-(sp) 		VM_INQUIRE
	move	#88,-(sp)		VSETMODE (Falcon only)
	trap	#14 			XBIOS
	addq	#4,sp
	move.l	(sp)+,a0
	move	d0,(a0)+
	bra.s	lsavid5
lsavid4
	move.l	a0,-(sp)
	move	#4,-(sp)		Get resolution
	trap	#14			XBIOS
	addq	#2,sp
	move.l	(sp)+,a0
	move	d0,(a0)+
lsavid5
	move.l	a0,-(sp)
	move	#2,-(sp)		Get physbase
	trap	#14			XBIOS
	addq	#2,sp
	move.l	(sp)+,a0
	move.l	d0,(a0)+
	move.l	a0,-(sp)
	move	#3,-(sp)		Get logbase
	trap	#14			XBIOS
	addq	#2,sp
	move.l	(sp)+,a0
	move.l	d0,(a0)+

	lea	$8200.w,a1		video hardware address
	movep	$01(a1),d0
	move	d0,(a0)+
	move.b	$0A(a1),(a0)+		synchro register
	move.b	$60(a1),(a0)+		video resolution
	move.b	zSTE(pc),d0		STE or above ?
	beq.s	lsavid6			yes / no (simple STF)
	move.b	$0D(a1),(a0)+		video address byte low (STE)
	move.b	$65(a1),(a0)+		number of shift bits (STE)
	move	$0E(a1),(a0)+		offset to next line (STE)
	bra.s	lsavid7
lsavid6
	addq	#4,a0
lsavid7
	movem.l	$40(a1),d0-d7
	movem.l	d0-d7,(a0)		16 colours

	rts

lbuserr
	moveq	#0,d4			set STF				0.846
	lea	zitfparams+b_no_shadow(pc),a1				0.846
	bset	#1,(a1)			set no shadow addressing mode	0.846
	lea	savebuserr(pc),a1					0.848
	move.l	(a1)+,a7						0.848
	move	(a1)+,sr						0.848
	lea	lreturnberr(pc),a1					0.848
	jmp	(a1)							0.848

savebuserr	ds.w	3

***************************************************************************
* PROC: INSTVID
***************************************************************************
*					Remove the comments to force 50 Hz PAL !
instvid:
*	move.b	zvideores(pc),d0	High resolution ?
*	bmi.s	instvid1		no / yes
*	bsr	qwaitVBL		Wait vertical blanking
*	bset	#1,$820A.w		Sync mode = 50 Hz PAL
*	lea	zsNTSC(pc),a0
*	sf	(a0)			force 50 Hz behaviour
instvid1
	rts


***************************************************************************
* PROC: QSETVIDCONTXT
***************************************************************************
qsetvidcontxt:
	move.b	zaboveSTE(pc),d1
	beq.s	lsetvidcontxt2
	cmp.b	#3,d1			Falcon or CT60 ?
	bne.s	lsetvidcontxt0		yes / no
	move.l	a0,-(sp)
	move	(a0)+,-(sp) 		Falcon resolution
	move	#3,-(sp)		Use Falcon resolution
	move.l	(a0)+,-(sp) 		physbase
	move.l	(a0)+,-(sp) 		logbase
	move	#5,-(sp) 		Set screen
	trap	#14 			XBIOS
	lea	14(sp),sp
	move.l	(sp)+,a0
	bra.s	lsetvidcontxt1
lsetvidcontxt0
	move.l	a0,-(sp)
	move	(a0)+,-(sp)		TT resolution
	move.l	(a0)+,-(sp)		physbase
	move.l	(a0)+,-(sp)		logbase
	move	#5,-(sp)		Set screen
	trap	#14			XBIOS
	lea	12(sp),sp
	move.l	(sp)+,a0
lsetvidcontxt1
	lea	18(a0),a0
	bra.s	lsetvidcontxt4
lsetvidcontxt2
	lea	10(a0),a0
	move.l	a0,-(sp)
	bsr	qwaitVBL		Wait vertical blanking
	move.l	(sp)+,a0
	lea	$8200.w,a1
	move	(a0)+,d0
	movep	d0,1(a1)		video hardware address
	move.l	a0,-(sp)
	bsr	qwaitVBL		wait vertical blanking
	move.l	(sp)+,a0
	move.b	(a0)+,$0A(a1)		synchro register
	move.b	(a0)+,$60(a1)		video resolution
	move.b	zSTE(pc),d0		STE or above ?
	beq.s	lsetvidcontxt3		yes / no (simple STF)
	move.b	(a0)+,$0D(a1)		video address byte low (STE)
	move.b	(a0)+,$65(a1)		number of shift bits (STE)
	move	(a0)+,$0E(a1)		offset to next line (STE)
	bra.s	lsetvidcontxt4
lsetvidcontxt3
	addq	#4,a0
lsetvidcontxt4
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$40(a1)		16 colours
	dc.w	$A009
	rts


***************************************************************************
* PROC: WSYNC
***************************************************************************
wsync:
	lea	$469.w,a0		Sync counter
	lea	locsync(pc),a1		Variavel to count nsyncs
	moveq	#-1,d2			**** tempo ****
	move.b	(a0),d0
wsync1:
	cmp.b	(a0),d0
	dbne	d2,wsync1		Wait until it chanhes
	cmp	#-1,d2
	bne.s	wsync2
	moveq	#0,d2			maximum ftime value (not 0 = $FFFF)
wsync2:
	cmp.b	(a0),d0
	beq.s	wsync2			wait for the sync ...
	move.b	d0,d1			new locsync
	sub.b	(a1),d0			- old one
	move.b	d1,(a1)			store new
	subq.b	#1,d0			- 1 VBL
	rts

locsync		ds.b	1
	even


***************************************************************************
* PROC: QWAITVBL
***************************************************************************
qwaitVBL:
	lea	$8201.w,a0		current video memory start address
	movep	0(a0),d0
	lea	$8205.w,a0		current video memory address
lwaitVBL_0
	movep	0(a0),d1
	cmp	d0,d1			wait while both are equal
	beq.s	lwaitVBL_0		(top border ? )
lwaitVBL_1
	movep	0(a0),d1
	cmp	d0,d1			wait while they are different
	bne.s	lwaitVBL_1		(screen or lower border ?)
	rts

zpvideomem	ds.l	1
zpTOSvideomem	ds.l	1
zvideores	ds.b	1		$FE 640x400 $01 640x200 $00 320x200
zSTE		ds.b	1		0 STF 1 STE
zaboveSTE	ds.b	1		0 NO  2 TT 3 Falcon/CT60	0.835
zNTSC		ds.b	1						0.832

	even							C0002


*****			DISK ACCESS PART			*****

***************************************************************************
* PROC: INIDSK
***************************************************************************
inidsk:
	bsr	getdrv			Get current drive
	clr	-(sp)
	pea	codfil(pc)
	bsr	load			Load synt file
	addq	#6,sp
	tst.b	d1
	bne.s	inidske
	lea	psynt(pc),a1
	lea	$1C(a0),a0		correct bra.s
	move.l	a0,(a1)
	clr	-(sp)
	pea	psgfil(pc)
	bsr	load			Load PSG table file
	addq	#6,sp
	tst.b	d1
	bne.s	inidske
	lea	preptab(pc),a1
	move.l	a0,(a1)
	and.b	#%00001111,(a0)
	or.b	#%00110000,(a0)		factor is 4 (3 + 1)
	moveq	#0,d1
inidske:
	rts

zfilename	dc.b	'art_hxt.mod',0

codfil		dc.b	'msynt849.exe',0
psgfil		dc.b	'psgtabst.blk',0
psynt		ds.l	1
preptab		ds.l	1		Inside 1st byte is psgfact
pquatab		ds.l	1		Inside 1st byte is psgfact
drive		ds.b	1

	even

***************************************************************************
* PROC: GETDRV
***************************************************************************
getdrv:
	move	#$19,-(sp)		Get current drive
	trap	#1
	addq	#2,sp
	lea	drive(pc),a0
	add.b	#'A',d0
	move.b	d0,(a0)
	rts


***************************************************************************
* PROC: LOAD
***************************************************************************
load:
	link	a6,#0
	movem.l	d5-d7,-(sp)		Save registers D5 -> D7	
	bsr	setdta			Set disk transfer address
	move	12(a6),-(sp)
	move.l	8(a6),-(sp)
	bsr	searchf			Search file
	addq	#6,sp
	tst.b	d1
	bne.s	loadend
	move	12(a6),-(sp)
	move.l	8(a6),-(sp)
	bsr	open			Open file
	addq	#6,sp	
	tst.b	d1
	bne.s	loadend
	move	d0,d7			D7 <- file handle
	move.l	dtabuf+26(pc),d5	D5 <- file length
	move.l	d5,d0			D0 <- D5
	bsr	qmalloc			Get memory for file
	tst.l	d0
	smi	d1
	bmi.s	loadend
	move.l	a0,d6			D6 <- A0 pointer to buffer for file
	move.l	a0,-(sp)
	move.l	d5,-(sp)
	move	d7,-(sp)
	bsr	read			Read data from disk
	lea	10(sp),sp
	tst.b	d1
	bne.s	loadend
	move	d7,-(sp)
	bsr	close			Close file
	addq	#2,sp
	tst.b	d1
	bne.s	loadend
	move.l	d6,a0			A0 <- D6
	move.l	d5,d0			D0 <- D5
loadend:
	movem.l	(sp)+,d5-d7		Restore registers D5 -> D7
	unlk	a6
	rts


***************************************************************************
* PROC: BLOAD
***************************************************************************
bload:
	link	a6,#0
	movem.l	d5-d7,-(sp)		Save registers D5 -> D7	
	bsr	setdta			Set disk transfer address
	move	12(a6),-(sp)
	move.l	8(a6),-(sp)
	bsr	searchf			Search file
	addq	#6,sp
	tst.b	d1
	bne.s	bloadend
	move	12(a6),-(sp)
	move.l	8(a6),-(sp)
	bsr	open			Open file
	addq	#6,sp	
	tst.b	d1
	bne.s	bloadend
	move	d0,d7			D7 <- file handle
	move.l	dtabuf+26(pc),d5	D5 <- file length
	cmp.l	zfreememsize(pc),d5
	sgt	d1
	bgt.s	bloadend
	move.l	zpfreemem(pc),d6	D6 <- pointer to buffer for file
	move.l	d6,-(sp)
	move.l	d5,-(sp)
	move	d7,-(sp)
	bsr	read			Read data from disk
	lea	10(sp),sp
	tst.b	d1
	bne.s	bloadend
	move	d7,-(sp)
	bsr	close			Close file
	addq	#2,sp
	tst.b	d1
	bne.s	bloadend
	move.l	d6,a0			A0 <- D6
	move.l	d5,d0			D0 <- D5
bloadend:
	movem.l	(sp)+,d5-d7		Restore registers D5 -> D7
	unlk	a6
	rts


***************************************************************************
* PROC: SETDTA
***************************************************************************
setdta:
	pea	dtabuf(pc)		Set disk transfer address
	move	#$1A,-(sp)
	trap	#1
	addq	#6,sp
	rts

dtabuf		ds.b	44


***************************************************************************
* PROC: OPEN
***************************************************************************
open:
	link	a6,#0			Open a file
	move	12(a6),-(sp)
	move.l	8(a6),-(sp)
	move	#$3D,-(sp)
	trap	#1
	addq	#8,sp	
	tst	d0
	smi	d1
	unlk	a6
	rts


***************************************************************************
* PROC: CLOSE
***************************************************************************
close:
	link	a6,#0			Close a file
	move	8(a6),-(sp)
	move	#$3E,-(sp)
	trap	#1
	addq	#4,sp	
	tst	d0
	smi	d1
	unlk	a6
	rts


***************************************************************************
* PROC: READ
***************************************************************************
read:
	link	a6,#0			Read data from disk
	move.l	14(a6),-(sp)
	move.l	10(a6),-(sp)
	move	8(a6),-(sp)
	move	#$3F,-(sp)
	trap	#1
	lea	12(sp),sp	
	cmp.l	10(a6),d0
	sne	d1
	unlk	a6
	rts


***************************************************************************
* PROC: SEARCHF
***************************************************************************
searchf:
	link	a6,#0			Search first file
	move	12(a6),-(sp)
	move.l	8(a6),-(sp)
	move	#$4E,-(sp)
	trap	#1
	addq	#8,sp
	tst	d0
	sne	d1
	unlk	a6
	rts


***************************************************************************
* PROC: WDRVMOT
***************************************************************************
wdrvmot:
	move.b	drive(pc),d0
	cmp.b	#'C',d0
	bpl.s	wdrvmot_e
	move	#$80,$8606.w		status register
wdrvmot1:
	moveq	#64,d0
wdrvmot2:
	dbf	d0,wdrvmot2		delay
	move	$8604.w,d0		status
	btst	#7,d0			motor running ?
	bne.s	wdrvmot1		yes
	move	sr,-(sp)
	move	#$2700,sr
	move.b	#14,$8800.w		register 14
	move.b	$8800.w,d0		actual value
	or.b	#%00000111,d0		unselect drives
	move.b	d0,$8802.w
	move	(sp)+,sr
wdrvmot_e:
	rts

	even

*****			SOUND PART			*****

***************************************************************************
* PROC: PSGOFF
***************************************************************************
psgoff:
	move	sr,-(sp)
	move	#$2700,sr
	lea	$8800.w,a0		PSG address
	moveq	#13,d0			14 registers
psgoff1:
	move.b	d0,(a0)
	cmp.b	#7,d0			register 7 ?
	bne.s	psgoff2			no
	move.b	(a0),d1
	or.b	#$3F,d1			only 6 bits are forced to 1
	move.b	d1,2(a0)
	bra.s	psgoff3
psgoff2:
	clr.b	2(a0)			clear it
psgoff3:
	dbf	d0,psgoff1
	move	(sp)+,sr
	rts


*****			MFP/INTERRUPTS PART			*****

***************************************************************************
* PROC: QINITMFPTAB
***************************************************************************
qinitmfptab:
	lea	zmfptab(pc),a0
	move	#612,d1			maximum divider value for 4 KHz
linitmfptab1
	move	d1,d2
	and	#$03,d2
	bne.s	linitmfptab2		multiple of 4 ?
	move	d1,d2			yes then store value divided by 4
	lsr	#2,d2
	move.b	d2,(a0)+
	bra.s	linitmfptab3
linitmfptab2
	moveq	#0,d2
	move	d1,d2
	divu	#10,d2
	swap	d2
	tst	d2
	bne.s	linitmfptab3		multiple of 10 ?
	swap	d2
	sub	#$FF,d2
	neg	d2
	move.b	d2,(a0)+
linitmfptab3
	subq	#1,d1
	bne.s	linitmfptab1
	moveq	#0,d0
	move.b	fdiv(pc),d0
	lea	zmfptab(pc),a2
	move.b	0(a2,d0),d0
	moveq	#0,d1
	move.b	d0,d1
	cmp.b	#175,d0
	bcc.s	linitmfptab4
	add	d1,d1
	add	d1,d1
	bra.s	linitmfptab5
linitmfptab4
	sub	#$FF,d1
	neg	d1
	mulu	#10,d1
linitmfptab5
	move.l	#2457600,d0
	divu	d1,d0
	lea	frep(pc),a1
	move	d0,(a1)
	rts


***************************************************************************
* PROC: REFRESH
***************************************************************************
refresh:
	eor.b	#%00000011,$FA23.w	to allow 245.5 divider
	addq.b	#1,$469.w
	rte

refresh1:
	move.b	#245,$FA23.w
	move.l	#$12345678,$114.w
	addq.b	#1,$469.w
	rte

refresh2:
	move.b	#246,$FA23.w
	move.l	#$12345678,$114.w
	rte


***************************************************************************
* PROC: INSTMFP
***************************************************************************
instmfp:
	clr.b	$FA07.w
	clr.b	$FA09.w
	bclr	#3,$FA17.w
	lea	vbl(pc),a0
	move.l	a0,$70.w
	rts


***************************************************************************
* PROC: QSAVMFPCONTXT
***************************************************************************
qsavMFPcontxt:
	move	sr,-(sp)		save Status Register
	move.l	$68.w,(a0)+		save HBL handler pointer
	move.l	$70.w,(a0)+		save VBL handler pointer
	lea	$100.w,a1		MFP handlers pointers
	moveq	#15,d0			save 16 pointers
lsavMFPcontxt_0
	move.l	(a1)+,(a0)+
	dbf	d0,lsavMFPcontxt_0
	lea	$FA00.w,a1		MFP address
	movep	$07(a1),d0		interrupt enable registers
	move	d0,(a0)+
	movep	$13(a1),d0		interrupt masks registers
	move	d0,(a0)+
	movep.l	$17(a1),d0		vector and timer control registers
	move.l	d0,(a0)+
	move	#$2700,sr		disable interrupts
	lea	lsavMFPtimerA(pc),a2
	move.l	a2,$134.w		set new timer A handler
	lea	lsavMFPtimerB(pc),a2
	move.l	a2,$120.w		set new timer B handler
	lea	lsavMFPtimerC(pc),a2
	move.l	a2,$114.w		set new timer C handler
	lea	lsavMFPtimerD(pc),a2
	move.l	a2,$110.w		set new timer D handler
	move	#%0010000100110000,d0	allow timer interrupts
	move	-8(a0),d1
	or	d0,d1			enable timer interrupts
	movep	d1,$07(a1)
	movep	d0,$13(a1)		masks on only for timer interrupts
	bclr	#3,$17(a1)		no software end of interrupt
	moveq	#4,d1
	clr.b	$19(a1)			stop timer A
	move.b	#$07,$19(a1)		start timer A
	clr.b	$1B(a1)			stop timer B
	move.b	#$07,$1B(a1)		start timer B
	clr.b	$1D(a1)			stop timer C and D
	move.b	#$77,$1D(a1)		start timer C and D
	move	#$2500,sr		allow timer interrupts
lsavMFPcontxt_1
	tst	d1			4 interrupts occured ?
	bne.s	lsavMFPcontxt_1		yes / no
	move	#$2700,sr		disable interrupts
	move.l	-72+$10(a0),$110.w	restore timer handler pointers
	move.l	-72+$14(a0),$114.w
	move.l	-72+$20(a0),$120.w
	move.l	-72+$34(a0),$134.w
	move	-8(a0),d0
	movep	d0,$07(a1)		restore old enables
	move	-6(a0),d0
	movep	d0,$13(a1)		restore old masks
	move.l	-4(a0),d1
	movep.l	d1,$17(a1)		restore vector and timer control
	move	(sp)+,sr		restore Status Register
	rts

lsavMFPtimerA:
	move.b	$1F(a1),(a0)		copy timer A data
	clr.b	$19(a1)			stop timer A
	bra.s	lsavMFPcontxt_2
lsavMFPtimerB:
	move.b	$21(a1),1(a0)		copy timer B data
	clr.b	$1B(a1)			stop timer B
	bra.s	lsavMFPcontxt_2
lsavMFPtimerC:
	move.b	$23(a1),2(a0)		copy timer C data
	and.b	#$0F,$1D(a1)		stop timer C
	bra.s	lsavMFPcontxt_2
lsavMFPtimerD:
	move.b	$25(a1),3(a0)		copy timer D data
	and.b	#$F0,$1D(a1)		stop timer D
lsavMFPcontxt_2
	subq	#1,d1			1 more interrupt occured
	rte


***************************************************************************
* PROC: QSETMFPCONTXT
***************************************************************************
qsetMFPcontxt:
	move	sr,-(sp)		save Status Register
	move	#$2700,sr		disable interrupts
	move.l	(a0)+,$68.w		set HBL handler pointer
	move.l	(a0)+,$70.w		set VBL handler pointer
	lea	$100.w,a1		MFP handlers pointers
	moveq	#15,d0			set 16 pointers
lsetMFPcontxt_0
	move.l	(a0)+,(a1)+
	dbf	d0,lsetMFPcontxt_0
	lea	$FA00.w,a1		MFP address
	move	(a0)+,d0
	movep	d0,$07(a1)		interrupt enable registers
	move	(a0)+,d0
	movep	d0,$13(a1)		interrupt mask registers
	move.l	(a0)+,d0
	clr.b	$19(a1)			stop timers
	clr.b	$1B(a1)
	clr.b	$1D(a1)
	move.l	(a0)+,d1
	movep.l	d1,$1F(a1)		timer data registers
	movep.l	d0,$17(a1)		vector and timer control registers
	move	(sp)+,sr		restores Status Register
	rts


*****			ACIAS PART			*****

***************************************************************************
* PROC: RESETKEY
***************************************************************************
resetkey:
	lea	$FC00.w,a0
	bra.s	resetk2
resetk1:
	btst	#0,(a0)
	bne.s	resetk2
	subq	#1,d0
	beq.s	resetk3
	bra.s	resetk1
resetk2:
	move.b	2(a0),d0
	move	#300,d0
	bra.s	resetk1
resetk3:
	rts


***************************************************************************
* PROC: INIKEY
***************************************************************************
inikey:
	bsr	resetkey
	lea	zskeylist1(pc),a0
inikey2:
	move.b	(a0)+,d0
	bmi.s	inikey1
	bsr	qwrtkeybACIA
	bra.s	inikey2
inikey1:
	bsr	resetkey
	rts


***************************************************************************
* PROC: QWRTKEYBACIA
***************************************************************************
qwrtkeybACIA:
lwrtkeybACIA_0
	btst	#1,$FC00.w
	beq.s	lwrtkeybACIA_0
	move.b	d0,$FC02.w
	rts


***************************************************************************
* PROC: RESTKEY
***************************************************************************
restkey:
	bsr	resetkey
	lea	zskeylist2(pc),a0
restkey2:
	move.b	(a0)+,d0
	bmi.s	restkey1
	bsr	qwrtkeybACIA
	bra.s	restkey2
restkey1:
	bsr	resetkey
	rts

zskeylist1	dc.b	$12,$1A,$FF
zskeylist2	dc.b	$14,$8,$FF

