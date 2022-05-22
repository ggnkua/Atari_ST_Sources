*********************************************************************
*							            *
*                 -=+ ProPacker routines V1.0A +=-                  *
*							            *
* Made by: Azatoth/Pha     Created: 91-07-11  Last change: 92-04-16 *
*							            *
*********************************************************************

; Note:
; This is version A with regsets from irqs !!!
; Interrupts must be enabled !!!
; Some commands are not implemented yet !!!
; There is much left to optimize !!!
; This replay can easily be made pc-independent
; For speed reasons vibrato and tremolo must 
; always be set with both parameters !!!
; Assembled with AsmOne1.07b !!!

		RSRESET
pc_Command	rs.l	1			Channel structure
pc_Start	rs.l	1
pc_Length	rs.w	1
pc_LoopStart	rs.l	1
pc_RepLen	rs.w	1
pc_Period	rs.w	1
pc_FineTune	rs.b	1
pc_Volume	rs.b	1
pc_DmaBit	rs.w	1
pc_PortSpeed	rs.w	1
pc_WantedPeriod	rs.w	1
pc_VibratoCmd	rs.b	1
pc_VibratoPos	rs.b	1
pc_TremoloCmd	rs.b	1
pc_TremoloPos	rs.b	1
pc_WaveControl	rs.b	1
pc_GlissFunk	rs.b	1
pc_SamOffset	rs.b	1
pc_PattPos	rs.b	1
pc_LoopCount	rs.b	1
pc_FuncOffset	rs.b	1
pc_WaveStart	rs.l	1
pc_PackCnt	rs.w	1
pc_FnTOffset	rs.w	1
pc_SizeOff	rs.w	0

		RSRESET
ps_Length	rs.w	1			Sample data structure
ps_FineTune	rs.b	1
ps_Volume	rs.b	1
ps_Restart	rs.w	1
ps_RepLen	rs.w	1
ps_SamOffset	rs.l	1
ps_FnTOffset	rs.w	1
ps_SizeOff	rs.b	0

		RSRESET
pm_SamData	rs.b	31*ps_SizeOff		Main structure
pm_SongPos	rs.w	1
pm_SongLength	rs.w	1
pm_PattCnt	rs.w	1
pm_Speed	rs.b	1
pm_Counter	rs.b	1
pm_PlayAdr	rs.l	1
pm_RetrigInd	rs.w	1
pm_PattPoses	rs.l	128
pm_PattData	rs.b	0

********************** ProPacker init routine ***********************
* a0.l <= Module

pp_Init		move	pm_SongLength(a0),pp_SongLength+2
		move	pm_SongPos(a0),d1
		lea	pm_PattPoses(a0),a1
		move.l	(a1,d1.w),d0
		lea	(a0,d0.l),a1
		move.l	a1,pm_PlayAdr(a0)
		clr	pm_RetrigInd(a0)
		move.l	$78.w,pp_OldLev6+2
		move.l	#pp_DmaIrq,$78.w
		move	#$2000,$dff09a
		move.b	#$7f,$bfdd00
		move.b	#$08,$bfde00
		move.b	#$80,$bfd400
		move.b	#$01,$bfd500		
.Respond	btst	#0,$bfdd00
		beq.s	.Respond
		move.b	#$81,$bfdd00
		move	#$a000,$dff09a
		bset	#1,$bfe001
		rts

********************** ProPacker end routine ************************

pp_End		bclr	#1,$bfe001
		move	#$2000,$dff09a
pp_OldLev6	move.l	#$0000,$78.w
		move	#$f,$dff096
		rts

********************* ProPacker replay routine **********************
* a0.l <= Module			       Used regs: d0-d7/a1-a5
* a6.l <= CustomBase

pp_Music	subq.b	#1,pm_Counter(a0)
		bhi	pp_NoNotes

		move.l	pm_PlayAdr(a0),a2
		move	#$8000,pp_DmaconTemp
		lea	pp_Chn1Struct(pc),a1
		lea	$a0(a6),a5
		bsr	pp_PlayVoice
		lea	pp_Chn2Struct(pc),a1
		lea	$b0(a6),a5
		bsr	pp_PlayVoice
		lea	pp_Chn3Struct(pc),a1
		lea	$c0(a6),a5
		bsr	pp_PlayVoice
		lea	pp_Chn4Struct(pc),a1
		lea	$d0(a6),a5
		bsr	pp_PlayVoice
		move.l	a2,pm_PlayAdr(a0)
		
		move.b	#$19,$bfde00

		subq	#1,pm_PattCnt(a0)
		bgt.s	pp_Return
		move	#64,pm_PattCnt(a0)
		clr	pp_Chn1Struct+pc_PackCnt
		clr	pp_Chn2Struct+pc_PackCnt
		clr	pp_Chn3Struct+pc_PackCnt
		clr	pp_Chn4Struct+pc_PackCnt	
		addq	#4,pm_SongPos(a0)
pp_SongLength	cmp	#$0000,pm_SongPos(a0)
		blo.s	pp_NotEOS
		clr	pm_SongPos(a0)
pp_NotEOS	lea	pm_PattPoses(a0),a1
		add	pm_SongPos(a0),a1
		move.l	(a1),d0
		lea	(a0,d0.l),a1
		move.l	a1,pm_PlayAdr(a0)

pp_Return	move.b	pm_Speed(a0),pm_Counter(a0)
		rts

pp_NoNotes	lea	pp_Chn1Struct(pc),a1		Effects
		lea	$a0(a6),a5
		moveq	#4-1,d7
pp_CmdLoop2	move.b	pc_Command+2(a1),d0
		and	#$f,d0
		add	d0,d0
		move	pp_Every(pc,d0.w),d0
		moveq	#0,d1
		move.b	pc_Command+3(a1),d1
		jsr	pp_Every(pc,d0.w)
		add	#pc_SizeOff,a1
		lea	16(a5),a5
		dbf	d7,pp_CmdLoop2

		move.b	pm_RetrigInd(a0),$bfde00
		clr	pm_RetrigInd(a0)
		rts

*********************************************************************

pp_Every	dc.w	pp_Arpeggio-pp_Every
		dc.w	pp_PortUp-pp_Every
		dc.w	pp_PortDown-pp_Every
		dc.w	pp_TonePort-pp_Every
		dc.w	pp_Vibrato-pp_Every
		dc.w	pp_PortSlide-pp_Every
		dc.w	pp_VibSlide-pp_Every
		dc.w	pp_Tremolo-pp_Every
		dc.w	pp_NotImp-pp_Every
		dc.w	pp_NotImp-pp_Every
		dc.w	pp_VolSlide-pp_Every
		dc.w	pp_NotImp-pp_Every
		dc.w	pp_NotImp-pp_Every
		dc.w	pp_NotImp-pp_Every
		dc.w	pp_ECmds1-pp_Every
		dc.w	pp_NotImp-pp_Every

pp_DmaIrq	tst.b	$bfdd00
		move.b	#$19,$bfde00
		add.l	#pp_RegIrq-pp_DmaIrq,$78.w
		move	pp_DmaconTemp(pc),$96(a6)
		move	#$2000,$9c(a6)
		rte

pp_RegIrq	tst.b	$bfdd00
		sub.l	#pp_RegIrq-pp_DmaIrq,$78.w
		move.l	pp_Chn1Struct+pc_LoopStart(pc),$a0(a6)
		move.l	pp_Chn2Struct+pc_LoopStart(pc),$b0(a6)
		move.l	pp_Chn3Struct+pc_LoopStart(pc),$c0(a6)
		move.l	pp_Chn4Struct+pc_LoopStart(pc),$d0(a6)
		move	pp_Chn1Struct+pc_RepLen(pc),$a4(a6)
		move	pp_Chn2Struct+pc_RepLen(pc),$b4(a6)
		move	pp_Chn3Struct+pc_RepLen(pc),$c4(a6)
		move	pp_Chn4Struct+pc_RepLen(pc),$d4(a6)
		move	#$2000,$9c(a6)
		rte

pp_DmaconTemp	dc.w	0
pp_Chn1Struct	dc.l	0,0,0,0,0,$00010000,0,0,0,0,0
pp_Chn2Struct	dc.l	0,0,0,0,0,$00020000,0,0,0,0,0
pp_Chn3Struct	dc.l	0,0,0,0,0,$00040000,0,0,0,0,0
pp_Chn4Struct	dc.l	0,0,0,0,0,$00080000,0,0,0,0,0

**************************** PlayVoice ******************************
* a0.l <= Module			       Used regs: d0-d6/a0-a4
* a1.l <= Channel struct (AutoAdded)
* a2.l <= Play data	 (AutoAdded)
* a5.l <= Sound regs	 (AutoAdded)
* a6.l <= CustomBase

pp_MulList	dc.w	00*ps_SizeOff,01*ps_SizeOff,02*ps_SizeOff,03*ps_SizeOff
		dc.w	04*ps_SizeOff,05*ps_SizeOff,06*ps_SizeOff,07*ps_SizeOff
		dc.w	08*ps_SizeOff,09*ps_SizeOff,10*ps_SizeOff,11*ps_SizeOff
		dc.w	12*ps_SizeOff,13*ps_SizeOff,14*ps_SizeOff,15*ps_SizeOff
		dc.w	16*ps_SizeOff,17*ps_SizeOff,18*ps_SizeOff,19*ps_SizeOff
		dc.w	20*ps_SizeOff,21*ps_SizeOff,22*ps_SizeOff,23*ps_SizeOff
		dc.w	24*ps_SizeOff,25*ps_SizeOff,26*ps_SizeOff,27*ps_SizeOff
		dc.w	28*ps_SizeOff,29*ps_SizeOff,30*ps_SizeOff,31*ps_SizeOff

pp_PlayVoice	addq	#1,pc_PackCnt(a1)
		blt.s	pp_NoNew
		move.l	(a2)+,pc_Command(a1)
		tst	(a2)
		bge.s	pp_NoNew
		move	(a2)+,pc_PackCnt(a1)
pp_NoNew	move.b	pc_Command+0(a1),d0
		beq	pp_NoSample
		ext	d0
		add	d0,d0
		move	pp_MulList(pc,d0.w),d0
		lea	pm_SamData-ps_SizeOff(a0,d0.w),a3
		move.l	ps_SamOffset(a3),d1
		lea	(a0,d1.l),a4
		move.l	a4,pc_Start(a1)
		move	ps_Length(a3),pc_Length(a1)
		move	ps_FnTOffset(a3),pc_FnTOffset(a1)
		move.b	ps_Volume(a3),pc_Volume(a1)
		move	ps_Restart(a3),d0
		beq.s	pp_NoLoop
		add	d0,a4
		add	d0,a4
		add	ps_RepLen(a3),d0
		move	d0,pc_Length(a1)
pp_NoLoop	move.l	a4,pc_LoopStart(a1)
		move	ps_RepLen(a3),pc_RepLen(a1)
		move.b	pc_Volume(a1),9(a5)

pp_NoSample	move.b	pc_Command+1(a1),d2
		beq.s	pp_NoNote

		ext	d2
		add	pc_FnTOffset(a1),d2

		move.b	pc_Command+2(a1),d0
		and.b	#$f,d0
		move	pp_PeriodTable-2(pc,d2.w),d2
		subq.b	#3,d0
		beq	pp_SetPort
		subq.b	#2,d0
		beq	pp_SetPort
		move	d2,pc_Period(a1)
		subq.b	#4,d0
		bne.s	pp_NoSamOffset
		bsr	pp_SamOffset
pp_NoSamOffset	move	pc_Command+2(a1),d0
		and	#$0ff0,d0
		cmp	#$0ed0,d0
		beq.s	pp_GoHome

		move	pc_DmaBit(a1),d0
		or	d0,pp_DmaconTemp
		move	d0,$96(a6)
		
		move.l	pc_Start(a1),(a5)
		move	pc_Length(a1),4(a5)
pp_NoNote	move	pc_Period(a1),6(a5)

		move.b	pc_Command+2(a1),d0
		and	#$f,d0
		add	d0,d0
		move	pp_Note(pc,d0.w),d0
		moveq	#0,d1
		move.b	pc_Command+3(a1),d1
		jmp	pp_Note(pc,d0.w)

pp_Note		dc.w	pp_NotImp-pp_Note
		dc.w	pp_NotImp-pp_Note
		dc.w	pp_NotImp-pp_Note
		dc.w	pp_TonePort-pp_Note
		dc.w	pp_NotImp-pp_Note
		dc.w	pp_TonePort-pp_Note
		dc.w	pp_VibSlide-pp_Note
		dc.w	pp_NotImp-pp_Note
		dc.w	pp_NotImp-pp_Note
		dc.w	pp_NotImp-pp_Note
		dc.w	pp_NotImp-pp_Note
		dc.w	pp_PosJump-pp_Note
		dc.w	pp_SetVolume-pp_Note
		dc.w	pp_PattBrk-pp_Note
		dc.w	pp_ECmds2-pp_Note
		dc.w	pp_SetSpeed-pp_Note

pp_GoHome	rts

		;	C   C#  D   D#  E   F   F#  G   G#  A   A#  H  	Oct FnT
		
pp_PeriodTable	dc.w	856,808,762,720,678,640,604,570,538,508,480,453   1   1
		dc.w	428,404,381,360,339,320,302,285,269,254,240,226   2
		dc.w	214,202,190,180,170,160,151,143,135,127,120,113   3
		dc.w	850,802,757,715,674,637,601,567,535,505,477,450	  1   2
		dc.w	425,401,379,357,337,318,300,284,268,253,239,225   2
		dc.w	213,201,189,179,169,159,150,142,134,126,119,113   3
		dc.w	844,796,752,709,670,632,597,563,532,502,474,447   o   3
		dc.w	422,398,376,355,335,316,298,282,266,251,237,224   s
		dc.w	211,199,188,177,167,158,149,141,133,125,118,112   v
		dc.w	838,791,746,704,665,628,592,559,528,498,470,444       4
		dc.w	419,395,373,352,332,314,296,280,264,249,235,222
		dc.w	209,198,187,176,166,157,148,140,132,125,118,111
		dc.w	832,785,741,699,660,623,588,555,524,495,467,441       5
		dc.w	416,392,370,350,330,312,294,278,262,247,233,220
		dc.w	208,196,185,175,165,156,147,139,131,124,117,110
		dc.w	826,779,736,694,655,619,584,551,520,491,463,437       6
		dc.w	413,390,368,347,328,309,292,276,260,245,232,219
		dc.w	206,195,184,174,164,155,146,138,130,123,116,109
		dc.w	820,774,730,689,651,614,580,547,516,487,460,434       7
		dc.w	410,387,365,345,325,307,290,274,258,244,230,217       
		dc.w	205,193,183,172,163,154,145,137,129,122,115,109
		dc.w	814,768,725,684,646,610,575,543,513,484,457,431      -8
		dc.w	407,384,363,342,323,305,288,272,256,242,228,216
		dc.w	204,192,181,171,161,152,144,136,128,121,114,108
		dc.w	907,856,808,762,720,678,640,604,570,538,508,480      -9
		dc.w	453,428,404,381,360,339,320,302,285,269,254,240
		dc.w	226,214,202,190,180,170,160,151,143,135,127,120
		dc.w	900,850,802,757,715,675,636,601,567,535,505,477     -10
		dc.w	450,425,401,379,357,337,318,300,284,268,253,238
		dc.w	225,212,200,189,179,169,159,150,142,134,126,119
		dc.w	894,844,796,752,709,670,632,597,563,532,502,474     -11
		dc.w	447,422,398,376,355,335,316,298,282,266,251,237
		dc.w	223,211,199,188,177,167,158,149,141,133,125,118
		dc.w	887,838,791,746,704,665,628,592,559,528,498,470     -12
		dc.w	444,419,395,373,352,332,314,296,280,264,249,235
		dc.w	222,209,198,187,176,166,157,148,140,132,125,118
		dc.w	881,832,785,741,699,660,623,588,555,524,494,467     -13
		dc.w	441,416,392,370,350,330,312,294,278,262,247,233
		dc.w	220,208,196,185,175,165,156,147,139,131,123,117
		dc.w	875,826,779,736,694,655,619,584,551,520,491,463     -14
		dc.w	437,413,390,368,347,328,309,292,276,260,245,232
		dc.w	219,206,195,184,174,164,155,146,138,130,123,116
		dc.w	868,820,774,730,689,651,614,580,547,516,487,460     -15
		dc.w	434,410,387,365,345,325,307,290,274,258,244,230
		dc.w	217,205,193,183,172,163,154,145,137,129,122,115
		dc.w	862,814,768,725,684,646,610,575,543,513,484,457     -16
		dc.w	431,407,384,363,342,323,305,288,272,256,242,228
		dc.w	216,203,192,181,171,161,152,144,136,128,121,114

****************************** Commands *****************************
* d1.w <= Command byte
* a0.l <= Module			       Used regs: d0-d6/a3-a4
* a1.l <= Channel struct
* a5.l <= Sound regs
* a6.l <= CustomBase
* sr.? <= tst.b d1

pp_Arpeggio	beq	pp_NoArp
		moveq	#0,d0
		move.b	pm_Speed(a0),d0
		subq.b	#1,d0
		sub.b	pm_Counter(a0),d0
		divs	#3,d0
		swap	d0
		tst	d0
		beq.s	pp_Arpeggio2
		cmp	#2,d0
		beq.s	pp_Arpeggio1
		moveq	#0,d0
		move.b	d1,d0
		lsr.b	#4,d0
		bra.s	pp_Arpeggio3
pp_Arpeggio1	moveq	#0,d0
		move.b	d1,d0
		and.b	#$f,d0
		bra.s	pp_Arpeggio3
pp_Arpeggio2	move	pc_Period(a1),d2
		bra.s	pp_Arpeggio4
pp_Arpeggio3	add	d0,d0
		moveq	#0,d1
		move.b	pc_FineTune(a1),d1
		mulu	#2*36,d1
		lea	pp_PeriodTable(pc),a4
		add.l	d1,a4
		moveq	#0,d1
		move	pc_Period(a1),d1
		moveq	#36-1,d6
pp_arploop	move	(a4,d0.w),d2
		cmp	(a4),d1
		bhs.s	pp_Arpeggio4
		addq	#2,a4
		dbf	d6,pp_arploop
pp_NoArp	rts
pp_Arpeggio4	move	d2,6(a5)
		rts

pp_PortUp	sub	d1,pc_Period(a1)
		cmp	#113,pc_Period(a1)
		bpl.s	.NotMin
		move	#113,pc_Period(a1)
.NotMin		move	pc_Period(a1),6(a5)
		rts

pp_PortDown	add	d1,pc_Period(a1)
		cmp	#856,pc_Period(a1)
		bmi.s	.NotMax
		move	#856,pc_Period(a1)
.NotMax		move	pc_Period(a1),6(a5)
		rts

pp_SetPort	move	d2,pc_WantedPeriod(a1)
		rts

pp_PortSlide	bsr	pp_VolSlide
		tst.b	d1
pp_TonePort	beq.s	.PortNoChange
		move	d1,pc_PortSpeed(a1)
.PortNoChange	move	pc_PortSpeed(a1),d0
		move	pc_WantedPeriod(a1),d2
		sub	pc_Period(a1),d2
		beq.s	.Return
		bgt.s	.Pos		
		neg	d2
		sub	d0,pc_Period(a1)
		bra.s	.Continue
.Pos		add	d0,pc_Period(a1)
.Continue	cmp	d0,d2
		bge.s	.SlideMore
		move	pc_WantedPeriod(a1),pc_Period(a1)
.SlideMore	move	pc_Period(a1),6(a5)
.Return		rts

pp_Vibrato	beq.s	pp_NoParas1
		move.b	d1,pc_VibratoCmd(a1)
pp_NoParas1	move.b	pc_VibratoPos(a1),d0
		lsr	#2,d0
		and	#$1f,d0
		moveq	#0,d2
		move.b	pp_VibratoTable(pc,d0.w),d2
		move.b	pc_VibratoCmd(a1),d3
		move	d3,d4
		and	#$f,d3
		mulu	d3,d2
		lsr	#7,d2
		tst.b	pc_VibratoPos(a1)
		bpl.s	pp_NoNeg
		neg	d2
pp_NoNeg	add	pc_Period(a1),d2
		move	d2,6(a5)
		lsr.b	#2,d4
		and	#$3c,d4
		add.b	d4,pc_VibratoPos(a1)
		rts

pp_Tremolo	beq.s	pp_NoParas2
		move.b	d1,pc_TremoloCmd(a1)
pp_NoParas2	move.b	pc_TremoloPos(a1),d0
		lsr	#2,d0
		and	#$1f,d0
		moveq	#0,d2
		move.b	pp_VibratoTable(pc,d0.w),d2
		move.b	pc_TremoloCmd(a1),d3
		move	d3,d4
		and	#$f,d3
		mulu	d3,d2
		lsr	#7,d2
		tst.b	pc_TremoloPos(a1)
		bmi.s	pp_TreSub
		neg	d2
pp_TreSub	neg	d2
 		add.b	pc_Volume(a1),d2
		bge.s	pp_TreOk1
		clr	d2
pp_TreOk1	cmp.b	#$40,d2
		ble.s	pp_TreOk2
		moveq	#$40,d2
pp_TreOk2	move	d2,8(a5)
		lsr.b	#2,d4
		and	#$3c,d4
		add.b	d4,pc_TremoloPos(a1)
		rts

pp_VibratoTable	dc.b 	0,24,49,74,97,120,141,161,180,197,212,224,235,244,250
		dc.b	253,255,253,250,244,235,224,212,197,180,161,141,120,97
		dc.b	74,49,24

pp_VibSlide	bsr	pp_NoParas1
pp_VolSlide	move.b	d1,d0
		lsr.b	#4,d1
		beq.s	pp_VolSlideDown
pp_VolSlideUp	add.b	d1,pc_Volume(a1)
		cmp.b	#$40,pc_Volume(a1)
		bmi.s	pp_vsdskip
		move.b	#$40,pc_Volume(a1)
		bra.s	pp_vsdskip
pp_VolSlideDown	and.b	#$f,d0
		sub.b	d0,pc_Volume(a1)
		bpl.s	pp_vsdskip
		clr.b	pc_Volume(a1)
pp_vsdskip	move.b	pc_Volume(a1),8(a5)
		rts

pp_SetVolume	move.b	d1,pc_Volume(a1)
		move	d1,8(a5)
		rts

pp_PosJump	add	d1,d1
		add	d1,d1
		move	d1,pm_SongPos(a0)
pp_PattBrk	clr	pm_PattCnt(a0)
		rts

pp_SetSpeed	move.b	d1,pm_Speed(a0)
		rts

pp_SamOffset	move.b	pc_Command+3(a1),d1
		beq	pp_NoNew1
		move.b	d1,pc_SamOffset(a1)
pp_NoNew1	moveq	#0,d1
		move.b	pc_SamOffset(a1),d1
		lsl	#7,d1
		sub	d1,pc_Length(a1)
		add	d1,d1
		add.l	d1,pc_Start(a1)
		rts

pp_ECmds1	move	d1,d0
		lsr	#4,d0
		add	d0,d0
		move	pp_ECmdList1(pc,d0.w),d0
		and	#$f,d1
		jmp	pp_ECmdList1(pc,d0.w)

pp_ECmdList1	dc.w	pp_Filter-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_SetFnTune-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_RetrigNote-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_NoteCut-pp_ECmdList1
		dc.w	pp_NoteDelay-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1

pp_ECmds2	move	d1,d0
		lsr	#4,d0
		add	d0,d0
		move	pp_ECmdList2(pc,d0.w),d0
		and	#$f,d1
		jmp	pp_ECmdList2(pc,d0.w)

pp_ECmdList2	dc.w	pp_Filter-pp_ECmdList2
		dc.w	pp_PortUp-pp_ECmdList2
		dc.w	pp_PortDown-pp_ECmdList2
		dc.w	pp_NotImp-pp_ECmdList2
		dc.w	pp_NotImp-pp_ECmdList2
		dc.w	pp_SetFnTune-pp_ECmdList2
		dc.w	pp_NotImp-pp_ECmdList2
		dc.w	pp_NotImp-pp_ECmdList2
		dc.w	pp_NotImp-pp_ECmdList2
		dc.w	pp_RetrigNote-pp_ECmdList2
		dc.w	pp_VolSlideUp-pp_ECmdList2
		dc.w	pp_VolFineDown-pp_ECmdList2
		dc.w	pp_NoteCut-pp_ECmdList2
		dc.w	pp_NoteDelay-pp_ECmdList2
		dc.w	pp_NotImp-pp_ECmdList2
		dc.w	pp_NotImp-pp_ECmdList2

pp_Filter	add.b	d1,d1
		and.b	#$fd,$bfe001
		or.b	d1,$bfe001
		rts	

pp_SetFnTune	move	d1,d0
		lsl	#6,d0
		lsl	#3,d1
		add	d0,d1
		move	d1,pc_FnTOffset(a1)
		rts

pp_VolFineDown	move	d1,d0
		bra	pp_VolSlideDown

pp_NoteCut	move.b	pm_Speed(a0),d0
		sub.b	pm_Counter(a0),d0
		cmp.b	d0,d1
		bne.s	pp_NoCut
		clr.b	pc_Volume(a1)
		move	#0,8(a5)
pp_NoCut	rts

pp_RetrigNote	beq.s	pp_GetBack
		moveq	#0,d0
		move.b	pm_Speed(a0),d0
		sub.b	pm_Counter(a0),d0
		divu	d1,d0
		swap	d0
		tst	d0
		bne.s	pp_GetBack
		move	pc_DmaBit(a1),d1
		move	d1,$96(a6)
		or	d1,pp_DmaconTemp
		move.l	pc_Start(a1),(a5)
		move	pc_Length(a1),4(a5)
		move	pc_Period(a1),6(a5)
		move.b	#$19,pm_RetrigInd(a0)
pp_GetBack	rts

pp_NoteDelay	move.b	pm_Speed(a0),d0
		sub.b	pm_Counter(a0),d0
		cmp.b	d0,d1
		bne	pp_NoDelay
		move	pc_DmaBit(a1),d1
		move	d1,$96(a6)
		or	d1,pp_DmaconTemp
		move.l	pc_Start(a1),(a5)
		move	pc_Length(a1),4(a5)
		move	pc_Period(a1),6(a5)
		move.b	#$19,pm_RetrigInd(a0)
pp_NoDelay	rts

pp_NotImp	rts

pp_Data		incbin "ram:mod.h.p"

******************* End of ProPacker routines ***********************
*********************************************************************
