; Listen here castraneamus McPenus!
; 40 seconds !

Max_Scroll_Speed	Equ	16

**********************************************************
Check_For_Carrier_Sequence
	Lea	Event_Sequences_Initntsc_Pal(pc),a2
.Loopy	Move.l	(a2)+,d1
	Bmi.s	.Done_Video_Setup_Stuff_For_carrier
	Move.l	d1,a1
	Move.w	Height_Of_Screen(a4),d1
	Add.b	#Max_Scroll_Speed-200,d1
	Move.b	d1,2(a1)
	Bra.s	.Loopy
.Done_Video_Setup_Stuff_For_carrier
	Clr.b	Bonus_Score_Init(a4)
	Clr.b	Boost_Type(a4)
	Clr.b	Escape_Val(a4)	
	Clr.b	Drag_Done(a4)
	Clr.b	Carrier_Event_Delay0(a4)
	Clr.b	Carrier_Event_Delay1(a4)
	Move.w	Panel_X(a4),-(sp)
	Move.w	Map_Display_Width(a4),-(sp)
	Tst.b	Demo_Mode(a4)
	Bne	.Demo_Mode_On
	St	Print_Top_Carrier_Map(a4)
	Clr.b	Boosters_On_Aanyway(a4)	
	Clr.b	Done_Carrier(a4)
	Clr.w	Booster_Switch
	Clr.b	Boost_Blocks_Up(a4)
	Clr.b	Boost_Type(a4)
	Clr.b	Atmosphere(a4)
	Sf	Boost_Away(a4)
	Move.w	#-17,Y_Accum(a4)
	Clr.w	Sprite_Boost
	Moveq	#0,d0
	Cmp.b	#1,This_Level(a4)
	Beq.s	.Carrier_Sequence
	Moveq	#1,d0
	Cmp.b	#6,This_Level(a4)
	Beq.s	.Carrier_Sequence
	Bra	.Demo_Mode_On
.Carrier_Sequence
	Cmp.b	#1,This_Level(a4)
	Bne.s	.Not_Level_1
	Tst.b	Completed_Raiden(a4)
	Beq.s	.Not_Level_1
	Moveq	#2,d0	
.Not_Level_1
	Cmp.w	#2,d0
	Bne.s	.Not_End
	Add.w	#1*16,Y_Accum(a4)
.Not_End
	Push
	Lea	Carrier_HEADER_NAME,A0
	Lea	Stuff_To_Load,a1
	Move.l	a1,d0
	Addq.l	#8,d0
	And.l	#-8,d0
	Sub.l	#Stuff_To_Load,d0
	Move.l	d0,File_Len(a4)
	Add.l	d0,a1
	Trap	#15
	Move.l	a1,Carrier_Sprites_Base(A4)
	Add.l	d0,a1
	Add.l	d0,File_Len(a4)
	Move.l	a1,Carrier_GFX_Base(A4)
	Lea	Carrier_SPRITES_NAME,A0
	Trap	#15
	Add.l	d0,File_Len(a4)
	Pull
	Move.w	d0,Carrier_Seq_Number(a4)
	Lsl.w	#2,d0
	Lea	.File_Lists_For_Carrier,a0
	Move.l	(a0,d0),a0
	Lea	Mypal-2,a1
	Trap	#15
	Push
	Cmp.b	#1,This_Level(a4)
	Bne.s	.No_Copy_Bodge
	Move.w	#$4890,Mypal+(198*2)
	Move.w	#$4890,Mypal+(197*2)
.No_Copy_Bodge
	Lea	Mypal+(240*2),a1
	Lea	Damage_Hit_Shadow_Pal,a0
	Moveq	#16*2,d0
	Jsr	Copy_Bytes
	Lea	Panel_Palette,a0
	Lea	Mypal+(224*2),a1
	Moveq	#16*2,d0
	Jsr	Copy_Bytes
	Cmp.b	#1,This_Level(a4)
	Bne.s	.Cows_Not_White
	Lea	Mypal+(248*2),a1
	Move.l	#$77ff77ff,(a1)+
	Move.l	#$77ff77ff,(a1)+
	Move.l	#$77ff77ff,(a1)+
	Move.l	#$77ff77ff,(a1)+
.Cows_Not_White
	Clr.b	Copy_The_Pallete(a4)
	Pull
	Jsr	Search_Zero
	Lea	Stuff_To_Load,a1
	Move.l	File_Len(a4),d5
	Add.l	d5,a1
	Trap	#15
	Move.l	a1,Gfxblocks_Base(a4)		; Load in blockset
	Add.l	d0,a1
	Jsr	Search_Zero
	Trap	#15
	Jsr	Search_Zero
	Move.l	a1,Carrier_Sequence_Base_Map(a4)
	Add.l	d0,a1
	Trap	#15
	Move.l	a1,Launch_Blockset_Base(a4)
	Add.l	d0,a1
	Bsr	Make_Map_Word_Per_Pixel_Due_To_Marvs_Shite_Converter
	Jsr	Search_Zero

	Trap	#15
	Jsr	Search_Zero
	Move.l	a1,Launch_Map_Base(a4)
	Add.l	d0,a1

	Lea	Intro_Mod_Name,a0
	Cmp.w	#2,Carrier_Seq_Number(a4)
	Bne.s	.Normal_Muzak	
;	Cmp.b	#1,Times_Through(a4)
;	Bne.s	.Normal_Muzak	
	Lea	Endgame_Mod_Name,a0
.Normal_Muzak	
	Move.l	a1,-(sp)
	Trap	#15
	Move.l	a1,Base_Mod_Address(a4)
	Move.l	(sp)+,a1
	Move.l	a1,d0
	Addq.l	#8,d0
	And.l	#-8,d0
	Move.l	d0,Cry_Screen_Base(a4)
	Move.w	Carrier_Seq_Number(a4),d0
	Lea	Event_Sequences,a2
	Lsl.w	#3,d0
	Move.l	(a2,d0),Carrier_Event0(a4)
	Move.l	4(a2,d0),Carrier_Event1(a4)
	Move.w	#$f,Block_Line_Offset0(a4)
	Move.w	#$f,Block_Line_Offset1(a4)
	Move.l	Carrier_Sequence_Base_Map(a4),a0
	Bsr	.Init_Map
	Move.w	d0,Map_Len0(a4)
	Move.l	a1,Map_Pointer0(a4)
	Move.l	Launch_Map_Base(a4),a0
	Bsr	.Init_Map
	Move.w	d0,Map_Len1(a4)
	Move.w	#0,Master_Intens(a4)
	Move.w	#-100,Red_Shipxy(a4)	
	Move.w	#180-24,Red_Shipxy+2(a4)
	Move.w	#-100,Blue_Shipxy(a4)	
	Move.w	#180-24,Red_Shipxy+2(a4)
	Tst.b	Pl1+Player_Active
	Beq.s	.Not_Active3
	Move.l	Shipxy+Pl1,Red_Shipxy(a4)	
.Not_Active3
	Tst.b	Pl2+Player_Active
	Beq.s	.Not_Active4
	Move.l	Shipxy+Pl2,Blue_Shipxy(a4)	
.Not_Active4
	Tst.w	Carrier_Seq_Number(a4)
	Bne.s	.No_Modif
	Move.w	#256,Master_Intens(a4)
	Lea	-24*2*50(a1),a1
	Move.w	#50*16,Y_Accum(a4)
	Tst.b	Pl1+Player_Active
	Beq.s	.Not_Active1
	Tst.b	Pl2+Player_Active
	Bne.s	.Both_Active
	Move.w	#136-2+1,Red_Shipxy(a4)
	Move.w	#180-24,Red_Shipxy+2(a4)
	Move.w	#-100,Blue_Shipxy(a4)
	Move.w	#180-24,Blue_Shipxy+2(a4)
	Bra.s	.No_Modif
.Not_Active1
	Move.w	#136-2+1,Blue_Shipxy(a4)
	Move.w	#180-24,Blue_Shipxy+2(a4)
	Move.w	#-100,Red_Shipxy(a4)
	Move.w	#180-24,Red_Shipxy+2(a4)
	Bra.s	.No_Modif
.Both_Active
	Move.w	#136-40-2+1,Red_Shipxy(a4)
	Move.w	#180-24,Red_Shipxy+2(a4)
	Move.w	#136-40+80-2+1,Blue_Shipxy(a4)
	Move.w	#180-24,Blue_Shipxy+2(a4)
.No_Modif
	Move.l	a1,Map_Pointer1(a4)
	Clr.b	Scroll_Rate0(a4)
	Clr.b	Scroll_Rate1(a4)
	Clr.w	Map_Line_Offset0(a4)
	Clr.w	Map_Line_Offset1(a4)
;	Jsr	Pre_Generate_Some_Player_Objects	; Generate FAST header sprites for player graphics

	Tst.b	Ntsc_Flag(a4)
	Bne	.Ntsc
	Cmp.b	#1,This_Level(a4)
	Bne.s	.Not_Level1
	Add.w	#48,Red_Shipxy+2(a4)
	Add.w	#48,Blue_Shipxy+2(a4)
.Not_Level1
.Ntsc
	Bsr	Do_Carrier
.Demo_Mode_On
	Move.w	(sp)+,Map_Display_Width(a4)
	Move.w	(sp)+,Panel_X(a4)
	Clr.b	Doing_Carrier(a4)
	Rts

.Init_Map
	Movem.w	(a0)+,d0-d3
	Move.w	d1,-(sp)
	Mulu	d0,d1
	Subq.w	#1,d1
.Loop	Move.w	(a0),d2
	Ror.w	#8,d2
	Move.w	d2,(a0)+	
	Dbra	d1,.Loop	
	Lea	-24*2(a0),a1
	Move.w	(sp)+,d0
	Rts


.File_Lists_For_Carrier
	Dc.l	.LEVEL_1
	Dc.l	.LEVEL_5
	Dc.l	.LEVEL_8

.Level_1
	Dc.b	"LEV1.CPL",0
	Dc.b	"BEG.BIN",0
	Dc.b	"BEG.MAP",0
	Dc.b	"LAUNCH.BIN",0
	Dc.b	"LAUNCH_1.MAP",0

.Level_8
	Dc.b	"END.CPL",0
	Dc.b	"END.BIN",0
	Dc.b	"END.MAP",0
	Dc.b	"LAUNCH.BIN",0
	Dc.b	"LAUNCH_1.MAP",0

.Level_5
	Dc.b	"MID.CPL",0
	Dc.b	"MID.BIN",0
	Dc.b	"MID.MAP",0
	Dc.b	"LAUNCH.BIN",0
	Dc.b	"LAUNCH_2.MAP",0

	Even

Event_Sequences
	Dc.l	SLEV1B
	Dc.l	SLEV1
	Dc.l	SLEV5B
	Dc.l	SLEV5
	Dc.l	SLEV8B
	Dc.l	SLEV8

Event_Sequences_Initntsc_Pal
	Dc.l	SLEV1
	Dc.l	SLEV5
	Dc.l	SLEV5BA
	Dc.l	SLEV8
	Dc.l	SLEV8BA
	Dc.l	-1




SLEV1B
	Dc.b	250,1
	Dc.b	250,1
	Dc.b	0,-6
	Dc.b	250,1
	Dc.b	250,1

SLEV1
	Dc.b	200,1
;	Dc.b	Screen_Height+Max_Scroll_Speed-200,1
	Dc.b	0,1

	Dc.b	100,0
	Dc.b	100,0
	Dc.b	170,0
	Dc.b	70,1
	Dc.b	60,2
	Dc.b	50,3
	Dc.b	40,4
	Dc.b	30,5
	Dc.b	20,6
	Dc.b	200,0
	Dc.b	200,0
	Dc.b	200,0
	Dc.b	200,0
	Dc.b	200,0


SLEV5B
	Dc.b	0,-9
SLEV5BA
	Dc.b	200,1
;	Dc.b	Screen_Height+Max_Scroll_Speed-200,1
	Dc.b	0,1

	Dc.b	90,1
	Dc.b	90,2
	Dc.b	90,3
	Dc.b	50,4
	Dc.b	20,5
	Dc.b	40,4
	Dc.b	80,3
	Dc.b	80,2
	Dc.b	80,1
	Dc.b	0,-2
	Dc.b	0,-10

	Dc.b	100,0
	Dc.b	100,0
	Dc.b	100,0
	Dc.b	0,-6
	Dc.b	0,-3
	Dc.b	100,1
	Dc.b	100,2
	Dc.b	100,3
	Dc.b	30,4
	Dc.b	0,-7

	Dc.b	0,-11

	Dc.b	80,4
	Dc.b	0,-8
	Dc.b	50,4
	Dc.b	90,3
	Dc.b	200,2
	Dc.b	200,1
	Dc.b	200,0
	Dc.b	200,0
	Dc.b	0,-1	
	Dc.b	200,0
	Dc.b	200,0

SLEV5
	Dc.b	200,1
;	Dc.b	Screen_Height+Max_Scroll_Speed-200,1
	Dc.b	0,1

	Dc.b	200,0
	Dc.b	200,0
	Dc.b	105,4
	Dc.b	78,3
	Dc.b	50,2
	Dc.b	40,1

	Dc.b	100,0
	Dc.b	170,0

	Dc.b	100,1
	Dc.b	130,2
	Dc.b	120,3
	Dc.b	10,4
	Dc.b	250,0
	Dc.b	250,0
	Dc.b	250,0
	Dc.b	250,0
	Dc.b	250,0
	Dc.b	250,0
	Dc.b	250,0
	Dc.b	250,0

SLEV8B
	Dc.b	0,-9
SLEV8BA
	Dc.b	200,1
;	Dc.b	Screen_Height+Max_Scroll_Speed-200,1
	Dc.b	0,1

	Dc.b	90,1
	Dc.b	90,2
	Dc.b	90,3
	Dc.b	0,-7
	Dc.b	50,4
	Dc.b	20,5
	Dc.b	34,4
	Dc.b	0,-8
	Dc.b	80,3
	Dc.b	80,2
	Dc.b	40,1
	Dc.b	0,-2
	Dc.b	0,-4
	Dc.b	0,-10
	Dc.b	250,0
	Dc.b	250,0

	Dc.b	50,0

	Dc.b	240,0

	Dc.b	250,0
	Dc.b	80,0

	Dc.b	0,-5
	Dc.b	130,0
	Dc.b	0,-3
	Dc.b	0,-6
	Dc.b	100,1
	Dc.b	70,2
	Dc.b	50,3
	Dc.b	160,4
	Dc.b	160,4
	Dc.b	160,4
	Dc.b	160,4


SLEV8
	Dc.b	200,1
;	Dc.b	Screen_Height+Max_Scroll_Speed-200,1
	Dc.b	0,1

	Dc.b	200,0
	Dc.b	200,0
	Dc.b	100,4
	Dc.b	78,3
	Dc.b	56-8,2
	Dc.b	46,1

	Dc.b	120,0
	Dc.b	120,0

	Dc.b	250,0
	Dc.b	250,0

	Dc.b	170,0

	Dc.b	250,0
	Dc.b	80,0

	Dc.b	200,1
	Dc.b	100,2
	Dc.b	130,3
	Dc.b	250,0
	Dc.b	250,0
	Dc.b	250,0
	Dc.b	250,0
	Dc.b	250,0
	Dc.b	250,0
	Dc.b	250,0
	Dc.b	250,0
	Dc.b	250,0
	Dc.b	250,0
	Even

**********************************************************
Make_Map_Word_Per_Pixel_Due_To_Marvs_Shite_Converter
	Push
	Lea	Mypal,a0
	Move.l	#512,d0
	Lea	-512(sp),sp
	Move.l	sp,a1
	Jsr	Copy_Bytes
	Lea	.Launch_Palette,a0
	Lea	Mypal-2,a1
	Trap	#15
	Movem.l	512(sp),d0-d7/a0-a6
	Move.l	Launch_Blockset_Base(a4),a0
	Move.l	a1,Launch_Blockset_Base(a4)
	Lea	Mypal,a2
.Loop	Moveq	#0,d3
	Move.b	(a0)+,d3
	Add.w	d3,d3
	Move.w	(a2,d3),(a1)+
	Subq.l	#1,d0
	Bne.s	.Loop
	Lea	Mypal,a1
	Move.l	#512,d0
	Move.l	sp,a0
	Jsr	Copy_Bytes
	Lea	512(sp),sp
	Pull
	Add.l	d0,a1
	Add.l	d0,a1
	Rts

.Launch_Palette
	Dc.b	"LAUNCH.CPL",0
	Even


CarrierMusic_Del
	Dc.w	0
**********************************************************
*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!
Do_Carrier
	Moveq	#41,d3
	Tst.b	Ntsc_Flag(a4)
	Bne.s	.Ntsc
	Mulu	#50,d3
	Bra.s	.Cont
.Ntsc	Mulu	#60,d3
.Cont	Move.w	d3,CarrierMusic_Del
	St	Doing_Carrier(a4)
	Clr.b	No_More_Clouds(a4)
	Clr.b	Kill_Clouds_Active(a4)
	Clr.b	Clouds_Active(a4)
	Clr.b	Up_Complete_Bonus(a4)
	Bsr	Copy_Cloud_Map
	Move.w	#16+(24*16/2)-(Screen_Width/2),X_Offset_Into_Map(a4)
	Move.w	#Panel_Width,Panel_X(a4)
	Move.w	#Panel_Width,Map_Display_Width(a4)
	Tst.b	Old_Vbl_On_Vbl(a4)
	Bne.s	.Skip
	Jsr	Setup_Screens				; Setup initial object lists/pointers
.Skip	Jsr	Generate_Initial_Carrier
	Jsr	Fade_Pallete
	Jsr	Startup_Raiden_Mod
	Move.b	#1,Fade_Direction(a4)
	Clr.b	Old_Vbl_On_Vbl(a4)
	Clr.b	Vbl_Flag(a4)
.Loop	Moveq	#1,d0
	Jsr	Wait_Vbl
	Bsr	Kill_Carrier_Music
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Jsr	Readjoysticks			; You might nothave read them ? cant remember!
	Jsr	Check_O_Button
	Jsr	Fade_Up_Or_Down_Palette		
	Bsr	Draw_Base_Map
	Bsr	Draw_Launch_Map
	Bsr	Carrier_Maps_To_Objects
	Bsr	Drag_Player_Ships
	Bsr	Draw_Boost_Back
	Bsr	Draw_Player_Ships
	Bsr	Draw_Clouds2
	Bsr	Move_Clouds
	Bsr	Draw_Completetion_Text
	Jsr	Swapscreens		; Careful you swap at the write time 
	Tst.b	Done_Carrier(a4)
	Beq.s	.Loop
	Tst.w	Master_Intens(a4)
	Bne.s	.Loop
	Jsr	Setup_Screens				; Setup initial object lists/pointers
	Jsr	Stop_Mod
	Clr.l	Joycur
	Clr.l	Joycur+4
	Rts

**********************************************************
Kill_Carrier_Music
	Cmp.b	#1,This_Level(a4)
	Bne.s	.Not_Level1
	Tst.b	Completed_Raiden(a4)
	Beq.s	.Not_Level1
	Subq.w	#1,CarrierMusic_Del
	Bcc.s	.Not_Level1
	Jsr	Stop_Mod
.Not_Level1
	Rts

**********************************************************
Drag_Player_Ships
	Cmp.w	#1,Carrier_Seq_Number(a4)
	Beq.s	.Drag_Lev56	
	Cmp.w	#2,Carrier_Seq_Number(a4)
	Beq.s	.Drag_Lev8
	Rts
.Drag_Lev8
	Move.w	#136-40-2+1,.Left
	Move.w	#180-36,.Left+2
	Move.w	#136-40+80-2+1,.Right
	Move.w	#180-36,.Right+2
	Move.w	#136-2+1,.Mid
	Move.w	#180-36,.Mid+2
	Bra.s	.Check_Ntsc
.Drag_Lev56	
	Move.w	#136-40-2+1,.Left
	Move.w	#180-36,.Left+2
	Move.w	#136-40+80-2+1,.Right
	Move.w	#180-36,.Right+2
	Move.w	#136-2+1,.Mid
	Move.w	#180-36,.Mid+2

.Check_Ntsc
	Tst.b	Ntsc_Flag(a4)
	Bne.s	.DO
	Add.w	#48,.Left+2
	Add.w	#48,.Right+2
	Add.w	#48,.Mid+2

.DO	Bsr	Check_Both_Players_Active
	Tst.b	Both_Players_Active(a4)
	Bne.s	.Both
	Tst.b	Pl1+Player_Active
	Beq.s	.Blue_Move
	Movem.w	Red_Shipxy(a4),d0-d1
	Movem.w	.Mid(pc),d2-d3
	Bsr.s	.Drag
	Move.b	d7,Drag_Done(a4)
	MOvem.w	d0-d1,Red_Shipxy(a4)
	Rts
.Blue_Move
	Movem.w	Blue_Shipxy(a4),d0-d1
	Movem.w	.Mid(pc),d2-d3
	Bsr.s	.Drag
	Move.b	d7,Drag_Done(a4)
	MOvem.w	d0-d1,Blue_Shipxy(a4)
	Rts

.Both	Movem.w	Red_Shipxy(a4),d0-d1
	Movem.w	.Left(pc),d2-d3
	Bsr.s	.Drag
	Move.b	d7,-(sp)
	MOvem.w	d0-d1,Red_Shipxy(a4)
	Movem.w	Blue_Shipxy(a4),d0-d1
	Movem.w	.Right(pc),d2-d3
	Bsr.s	.Drag
	Move.b	(sp)+,d6
	And.b	d6,d7
	And.b	d7,Drag_Done(a4)
	MOvem.w	d0-d1,Blue_Shipxy(a4)
	Rts

.Drag	St	d7
	Tst.b	Drag_Done(a4)
	Bne.s	.Done_Y
	Cmp.w	d0,d2
	Seq	d6
	Beq.s	.Done_x
	Bgt.s	.Add_x
	Subq.w	#2,d0
.Add_x	Addq.w	#1,d0
.Done_x	Cmp.w	d1,d3
	Seq	d7
	Beq.s	.Done_y
	Bgt.s	.Add_y
	Subq.w	#2,d1
.Add_y	Addq.w	#1,d1
	And.b	d6,d7
.Done_y	Rts

.Left	Ds.w	2
.Mid	Ds.w	2
.Right	Ds.w	2

**********************************************************
Draw_Player_Ships
	Addq.w	#1,.Atmosphere_Tog
	Cmp.w	#3,.Atmosphere_Tog
	Bne.s	.Skip_At
	Clr.w	.Atmosphere_Tog
.Skip_At
	Move.l	Carrier_Sprites_Base(a4),a3
	Move.l	Carrier_GFX_Base(a4),a5
	Tst.b	Atmosphere(a4)
	Beq.s	.No
	Move.w	.Atmosphere_Tog,d2
	Addq.w	#5,d2
	Movem.w	Red_Shipxy(a4),d0-d1
	Sub.w	#17,d0
	Sub.w	#8,d1
	Bsr	.Do2
	Movem.w	Blue_Shipxy(a4),d0-d1
	Sub.w	#17,d0
	Sub.w	#8,d1
	Bsr	.Do2
.No	Bsr.s	.Do_Ship_Stuff
	Rts

.Do_Ship_Stuff
	Addq.w	#1,Booster_Switch
	Tst.b	Boosters_On_Aanyway(a4)	
	Bne.s	.Skip
	Tst.b	Boost_Away(a4)
	Beq	.No_Big_Boost
	Cmp.b	#250,Boost_Type(a4)
	Bne	.No_Big_Boost1
	Cmp.b	#100,Escape_Val(a4)	
	Beq.s	.Start_Escaping
	Addq.b	#1,Escape_Val(a4)
	Bra.s	.Skip
.Start_Escaping

	Subq.w	#2,Red_Shipxy+2(a4)
	Subq.w	#2,Blue_Shipxy+2(a4)
	Cmp.b	#6,This_Level(a4)
	Bne.s	.No_Double
	Subq.w	#1,Red_Shipxy+2(a4)
	Subq.w	#1,Blue_Shipxy+2(a4)
.No_Double
	Move.w	Red_Shipxy+2(a4),d4
	Tst.b	Pl1+Player_Active
	Bne.s	.Active1
	Move.w	Blue_Shipxy+2(a4),d4
.Active1
	Cmp.w	#-50,d4
	Sle	Done_Carrier(a4)
	Sle	Fade_Direction(a4)
	Bgt.s	.Skip
	Jsr	Fadedown

.Skip	Move.w	Booster_Switch,d2
	And.w	#3,d2
	Add.w	#98,d2

	Movem.w	Red_Shipxy(a4),d0-d1
	Add.w	#23,d1
	Addq.w	#8,d0
	Bsr	.Do
	Add.w	#8,d0
	Bsr	.Do
	
	Movem.w	Blue_Shipxy(a4),d0-d1
	Add.w	#23,d1
	Addq.w	#8,d0
	Bsr	.Do
	Add.w	#8,d0
	Bsr.s	.Do
	Bra.s	.No_Big_Boost	
.No_Big_Boost1
	Addq.b	#1,Boost_Type(a4)
	Move.w	Booster_Switch,d2
	And.w	#1,d2
	Add.w	#219,d2
	Movem.w	Red_Shipxy(a4),d0-d1
	Add.w	#22,d1
	Subq.w	#1,d0
	Bsr.s	.Do
	Movem.w	Blue_Shipxy(a4),d0-d1
	Add.w	#22,d1
	Subq.w	#1,d0
	Bsr.s	.Do

.No_Big_Boost
	Movem.w	Red_Shipxy(a4),d0-d1
	Move.w	#2,d2
	Cmp.b	#4,Weapon_Power+Pl1
	Bge.s	.Max_Power1
	Cmp.b	#2,Weapon_Power2+Pl1
	Blt.s	.Skip_Power1
.Max_Power1
	Move.w	#59,d2
.Skip_Power1
	Bsr.s	.Do
	Movem.w	Blue_Shipxy(a4),d0-d1
	Move.w	#126,d2
	Cmp.b	#4,Weapon_Power+Pl2
	Bge.s	.Max_Power2
	Cmp.b	#2,Weapon_Power2+Pl2
	Blt.s	.Skip_Power2
.Max_Power2
	Move.w	#131,d2
.Skip_Power2

.Do	Tst.w	d0
	Ble.s	.No_Sprite
	Push
	Move.l	Current_List_Pointer(a4),a0
	Move.l	Player_Sprite_Base(a4),a3
	Lea	Pre_Generated_Player_Objects,a6
	Jsr	Quick_Player_Blit
	Move.l	a0,Current_List_Pointer(a4)
	Pull
	Rts
.Do2	Add.w	X_Offset_Into_Map(a4),d0
	Jsr	Blit_A_Sprite
.No_Sprite
	Rts

.Atmosphere_Tog
	Ds.w	1
Booster_Switch
	Ds.w	1

**********************************************************
Draw_Boost_Back
	Tst.b	Boost_Blocks_Up(a4)
	Beq.s	.On
	Addq.w	#1,.Delay
	Cmp.w	#4,.Delay
	Bne.s	.On
	Clr.w	.Delay
	Addq.w	#1,Sprite_Boost
	Cmp.w	#4,Sprite_Boost
	Bne.s	.On
	Clr.b	Boost_Blocks_Up(a4)
	St	Boost_Away(a4)
.On	
;	St	Player_Active+Pl1
;	St	Player_Active+Pl2				; Active flags for both players
	Bsr	Check_Both_Players_Active
	Tst.b	Both_Players_Active(a4)
	Bne.s	.Both
	Move.w	#136-2,d0
	Add.w	X_Offset_Into_Map(a4),d0
	Move.w	Y_Accum(a4),d1
	Add.w	#((16*50)-$680)+7,d1
	Move.w	Sprite_Boost,d2
	Move.l	Carrier_Sprites_Base(a4),a3
	Move.l	Carrier_GFX_Base(a4),a5
;	Cmp.w	#Screen_Height,d1
	Cmp.w	Height_Of_Screen(a4),d1
	Bge.s	.Xit
	Bsr	Blit_A_Sprite
.Xit	Rts
.Both	Move.w	#136-40-2,d0
	Add.w	X_Offset_Into_Map(a4),d0
	Move.w	Y_Accum(a4),d1
	Add.w	#((16*50)-$680)+7,d1
	Move.w	Sprite_Boost,d2
	Move.l	Carrier_Sprites_Base(a4),a3
	Move.l	Carrier_GFX_Base(a4),a5
	Cmp.w	Height_Of_Screen(a4),d1
	Bge.s	.Xit
	Bsr	Blit_A_Sprite
	Add.w	#80,d0
	Bsr	Blit_A_Sprite
	Rts

.Delay	Dc.w	0
Sprite_Boost
	Dc.w	0

**********************************************************
Draw_Completetion_Text
;	Cmp.b	#1,Times_Through(a4)
;	Beq.s	.Ok
;	Rts
.Ok	Bsr	Check_For_Bonus_Life
	Tst.b	Up_Complete_Bonus(a4)
	Beq	.No_Bonus
	Tst.b	Bonus_Score_Init(a4)
	Bne.s	.Setup
	St	Bonus_Score_Init(a4)
	Move.l	#$1000000,.One_Million
	Move.w	#100,.Delay
.Setup	Subq.w	#1,.Delay
	Bcc.s	.Print_Bonus
.Keep_Going
	Move.w	#3,.Delay
	Lea	High_Score_Beep_Samp,a6
	Jsr	Play_This_Sample
	Lea	.Ten_Thousand+4(pc),a2
	Lea	.One_Million+4(pc),a3
	Move	#0,ccr
	Sbcd	-(a2),-(a3)
	Sbcd	-(a2),-(a3)
	Sbcd	-(a2),-(a3)
	Sbcd	-(a2),-(a3)
	Pea	(a3)
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
	Bsr.s	.Do
	Move.l	(sp)+,a3
	Tst.l	(a3)
	Bne.s	.Print_Bonus
	Move.w	#$7fff,.Delay
	Move.l	#$00000,.One_Million
.Print_Bonus
	Move.l	Carrier_Sprites_Base(a4),a3
	Move.l	Carrier_GFX_Base(a4),a5
	
	Move.w	#70,d0
	Move.w	#50,d1
	Moveq	#8,d2
	Add.w	X_Offset_Into_Map(a4),d0
	Bsr	Blit_A_Sprite
	Move.l	.One_Million(pc),d0
	Bsr	Print_The_Completion_Score
.No_Bonus
	Rts

.Do	Tst.b	Num_Lives(a3)
	Ble.s	.No_Lives
	Lea	.Ten_Thousand+4(pc),a2
	Lea	Score+4(a3),a3
	Move	#0,ccr
	Abcd	-(a2),-(a3)
	Abcd	-(a2),-(a3)
	Abcd	-(a2),-(a3)
	Abcd	-(a2),-(a3)
.No_Lives
	Rts

.Ten_Thousand
	Dc.l	$10000
.One_Million
	Ds.l	1
.Delay	Ds.w	1

**********************************************************
Print_The_Completion_Score
	Move.l	d0,.Buffer
	Lea	.Buffer(pc),a0
	Subq.l	#8,sp
	Move.l	sp,a1			; Make room on stack. and set a1 as destination for ascii
	Moveq	#4,d7			; 8 characters out please
	Jsr	BCD_Ascii		; Convert BCD to ascii
	Move.l	sp,a2			; Base
	Move.w	#8,-(sp)		; Count of 8 characters
	Sf	Leading_Zero(a4)
	Move.l	Current_List_Pointer(a4),a0
	Lea	Pre_Generated_Player_Objects,a6
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_Gfx_Base(a4),a5
	Move.w	#64,Text_X_Save(a4)
	Move.w	X_Offset_Into_Map(a4),d1
	Add.w	d1,Text_X_Save(a4)
.Loop	Move.w	Text_X_Save(a4),d0	
	Addq.w	#8,Text_X_Save(a4)	; Get x position
	Move.w	#140,d1
	Moveq	#0,d2
	Move.b	(a2)+,d2
	Sub.b	#"0",d2
	Bne.s	.No_Zero	
	Tst.b	Leading_Zero(a4)
	Beq.s	.Dec
.No_Zero	
	St	Leading_Zero(a4)
	Add.w	#112,d2			; Convert the ASCII into sprite number
	Jsr	Quick_Player_Blit
.Dec	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Tst.b	Leading_Zero(a4)
	Bne.s	.Printed_Something
	Move.w	Text_X_Save(a4),d0	
	Subq.w	#8,d0
	Move.w	#140,d1
	Add.w	8(sp),d1
	Move.w	#112,d2			; Convert the ASCII into sprite number
	Jsr	Quick_Player_Blit
.Printed_Something
	Addq.l	#8,sp
	Move.l	a0,Current_List_Pointer(a4)
	Rts

.Buffer	Ds.l	1

**********************************************************
Carrier_Maps_To_Objects
	Move.l	Current_List_Pointer(a4),a0
	Move.w	#(24*16)/8,d4					; Data width
	Move.w	#(Playfield_Width/8)+2,d2			; Image width
	Add.w	Map_Display_Width(a4),d2
	Move.l	Base_Of_Map_Elements(a4),a1
	Move.w	Map_Line_Offset0(a4),d7
	Addq.w	#1,d7
;	Cmp.w	#Screen_Height+Max_Scroll_Speed-1,d7
	Move.l	d0,-(sp)
	Move.w	Height_Of_Screen(a4),d0
	Add.w	#Max_Scroll_Speed-1,d0
	Cmp.w	d0,d7
	Movem.l	(sp)+,d0
	Ble.s	.Ok
	Move.w	#0,d7
.Ok	Move.w	d7,-(sp)
	Mulu	#24*16,d7
	Add.l	d7,a1
	Moveq	#0,d6
	Moveq	#0,d0
	Moveq	#3,d7
	Move.w	X_Offset_Into_Map(a4),d0
	Moveq.l	#-8,d5
	And.l	d0,d5
	Add.l	d5,a1
	Sub.l	d5,d0
	Neg.l	d0
	Moveq	#0,d1
;	Move.w	#Screen_Height+Max_Scroll_Speed,d3
	Move.w	Height_Of_Screen(a4),d3
	Add.w	#Max_Scroll_Speed,d3	

	Sub.w	(sp)+,d3
	Move.w	d3,-(sp)
	Jsr	Make_A_Clipped_Object
	Move.l	a0,Current_List_Pointer(a4)

	Move.w	(sp)+,d1
	Move.l	Current_List_Pointer(a4),a0
	Move.w	#(24*16)/8,d4					; Data width
	Move.w	#(Playfield_Width/8)+2,d2			; Image width
	Add.w	Map_Display_Width(a4),d2
	Move.l	Base_Of_Map_Elements(a4),a1
	Moveq	#0,d6
	Moveq	#0,d0
	Moveq	#3,d7
	Move.w	X_Offset_Into_Map(a4),d0
	Moveq.l	#-8,d5
	And.l	d0,d5
	Add.l	d5,a1
	Sub.l	d5,d0
	Neg.l	d0
;	Move.w	#Screen_Height,d3
	Move.w	Height_Of_Screen(a4),d3
	Jsr	Make_A_Clipped_Object
	Move.l	a0,Current_List_Pointer(a4)

	Tst.b	Print_Top_Carrier_Map(a4)
	Beq	.Xit
	Push
	Bsr	Draw_Clouds1
	Pull
	Move.l	Current_List_Pointer(a4),a0
	Move.w	#(24*16)/4,d4					; Data width
	Move.w	#((Playfield_Width/8)+2)*2,d2			; Image width
	Add.w	Map_Display_Width(a4),d2
	Move.l	Cry_Screen_Base(a4),a1
	Move.w	Map_Line_Offset1(a4),d7
	Addq.w	#1,d7
;	Cmp.w	#Screen_Height+Max_Scroll_Speed-1,d7
	Move.l	d0,-(sp)
	Move.w	Height_Of_Screen(a4),d0
	Add.w	#Max_Scroll_Speed-1,d0
	Cmp.w	d0,d7
	Movem.l	(sp)+,d0

	Ble.s	.Ok2
	Move.w	#0,d7
.Ok2	Move.w	d7,-(sp)
	Mulu	#24*16*2,d7
	Add.l	d7,a1
	Moveq	#0,d6
	Moveq	#0,d0
	Moveq	#4,d7
	Move.w	X_Offset_Into_Map(a4),d0
	Moveq.l	#-8,d5
	And.l	d0,d5
	Add.l	d5,a1
	Sub.l	d5,d0
	Neg.l	d0
	Moveq	#0,d1
;	Move.w	#Screen_Height+Max_Scroll_Speed,d3
	Move.w	Height_Of_Screen(a4),d3
	Add.w	#Max_Scroll_Speed,d3

	Sub.w	(sp)+,d3
	Move.w	d3,-(sp)
	Jsr	Make_A_Clipped_Object
	Move.l	a0,Current_List_Pointer(a4)

	Move.w	(sp)+,d1
	Move.l	Current_List_Pointer(a4),a0
	Move.w	#(24*16)/4,d4					; Data width
	Move.w	#((Playfield_Width/8)+2)*2,d2			; Image width
	Add.w	Map_Display_Width(a4),d2
	Move.l	Cry_Screen_Base(a4),a1
	Moveq	#0,d6
	Moveq	#0,d0
	Moveq	#4,d7
	Move.w	X_Offset_Into_Map(a4),d0
	Moveq.l	#-8,d5
	And.l	d0,d5
	Add.l	d5,a1
	Sub.l	d5,d0
	Neg.l	d0
;	Move.w	#Screen_Height,d3
	Move.w	Height_Of_Screen(a4),d3
	Jsr	Make_A_Clipped_Object
	Move.l	a0,Current_List_Pointer(a4)
.xit
	Rts


**********************************************************
Generate_Initial_Carrier
;	Move.w	#Screen_Height+Max_Scroll_Speed,-(sp)
	Move.w	Height_Of_Screen(a4),d3
	Add.w	#Max_Scroll_Speed,d3
	Move.w	d3,-(sp)
.Loop0	
	Bsr	Draw_Base_Map
	Bsr	Draw_Launch_Map
	Subq.w	#1,(sp)
	Bne.s	.Loop0
	Addq.l	#2,sp
	Rts

**********************************************************
Draw_Base_Map
	Move.b	Scroll_Rate0(a4),d0
	Beq	.No_Scroll
	Ext.w	d0
	Move.w	d0,-(sp)
.Loop0	Move.w	Block_Line_Offset0(a4),d0
	Move.l	GfxBlocks_Base(a4),a0
	Lsl.w	#4,d0
	Lea	(a0,d0),a0
	Move.l	Map_Pointer0(a4),a1
	
	Move.l	Base_Of_Map_Elements(a4),a2	
	Move.w	Map_Line_Offset0(a4),d0
	Mulu	#24*16,d0
	Add.l	d0,a2

	Moveq	#24-1,d0
	Moveq	#8,d3
.Loop1	Moveq	#0,d1
	Move.w	(a1)+,d1
	Lsl.l	d3,d1
	Movem.l	(a0,d1.l),d4-d7
	Movem.l	d4-d7,(a2)
	Lea	16(a2),a2
	Dbra	d0,.Loop1
	Subq.w	#1,Map_Line_Offset0(a4)
	Bcc.s	.No_Carry_Screen
;	Move.w	#Screen_Height+Max_Scroll_Speed-1,Map_Line_Offset0(a4)
	Move.w	Height_Of_Screen(a4),Map_Line_Offset0(a4)
	Add.w	#Max_Scroll_Speed-1,Map_Line_Offset0(a4)

.No_Carry_Screen
	Subq.w	#1,Block_Line_Offset0(a4)
	Bcc.s	.No_New_Line	
	Move.w	#$f,Block_Line_Offset0(a4)
	Sub.l	#24*2,Map_Pointer0(a4)
.No_New_Line	
	Subq.w	#1,(sp)
	Bne.s	.Loop0
	Addq.l	#2,sp
.No_Scroll
	Subq.b	#1,Carrier_Event_Delay0(a4)
	Bcc.s	.No_New_Event	
	Move.l	Carrier_Event0(a4),a1
.Back	Move.b	(a1)+,Carrier_Event_Delay0(a4)
	Move.b	(a1)+,Scroll_Rate0(a4)
	Bmi.s	.Done
	Move.l	a1,Carrier_Event0(a4)
.No_New_Event	
	Rts

.Done	Cmp.b	#-2,Scroll_Rate0(a4)
	Bne.s	.Not_Clouds
	St	Clouds_Active(a4)
	Bra.s	.Back
.Not_Clouds
	Cmp.b	#-3,Scroll_Rate0(a4)
	Bne.s	.Not_Clouds2
	St	Kill_Clouds_Active(a4)
	Bra.s	.Back
.Not_Clouds2
	Cmp.b	#-4,Scroll_Rate0(a4)
	Bne.s	.Not_Game_Bonus
	St	Up_Complete_Bonus(a4)
	Bra.s	.Back
.Not_Game_Bonus
	Cmp.b	#-5,Scroll_Rate0(a4)
	Bne.s	.Not_Game_Bonus2
	Sf	Up_Complete_Bonus(a4)
	Bra.s	.Back
.Not_Game_Bonus2
	Cmp.b	#-6,Scroll_Rate0(a4)
	Bne.s	.Not_Game_Bonus2a
	St	Boost_Blocks_Up(a4)
	Bra.s	.Back
.Not_Game_Bonus2a
	Cmp.b	#-7,Scroll_Rate0(a4)
	Bne.s	.Not_Game_Bonus2b
	St	Atmosphere(a4)
	Bra	.Back
.Not_Game_Bonus2b
	Cmp.b	#-8,Scroll_Rate0(a4)
	Bne.s	.Not_Game_Bonus2c
	Sf	Atmosphere(a4)
	Bra	.Back
.Not_Game_Bonus2c
	Cmp.b	#-9,Scroll_Rate0(a4)
	Bne.s	.Not_Game_Bonus2d
	St	Boosters_On_Aanyway(a4)	
	Bra	.Back
.Not_Game_Bonus2d
	Cmp.b	#-10,Scroll_Rate0(a4)
	Bne.s	.Not_Game_Bonus2e
	Sf	Boosters_On_Aanyway(a4)	
	Bra	.Back
.Not_Game_Bonus2e
	Cmp.b	#-11,Scroll_Rate0(a4)
	Bne.s	.Not_Game_Bonus2f
	Sf	Print_Top_Carrier_Map(a4)
	Bra	.Back
.Not_Game_Bonus2f
	Illegal
	Addq.l	#4,sp
	Rts

**********************************************************
Draw_Launch_Map
	Move.b	Scroll_Rate1(a4),d0
	Beq	.No_Scroll
	Ext.w	d0
	Move.w	d0,-(sp)
.Loop0	Move.w	Block_Line_Offset1(a4),d0
	Move.l	Launch_Blockset_Base(a4),a0
	Lsl.w	#5,d0
	Lea	(a0,d0),a0	
	Move.l	Map_Pointer1(a4),a1
	
	Move.l	Cry_Screen_Base(a4),a2	
	Move.w	Map_Line_Offset1(a4),d0
	Mulu	#24*16*2,d0
	Add.l	d0,a2

	Moveq	#24-1,d0
.Loop1	Moveq	#0,d1
	Move.w	(a1)+,d1
	Add.w	d1,d1
	Lsl.l	#8,d1
	Movem.l	(a0,d1.l),d2-d7/a3/a6
	Movem.l	d2-d7/a3/a6,(a2)
	Lea	4*8(a2),a2
	Dbra	d0,.Loop1
	Subq.w	#1,Map_Line_Offset1(a4)
	Bcc.s	.No_Carry_Screen
;	Move.w	#Screen_Height+Max_Scroll_Speed-1,Map_Line_Offset1(a4)
	Move.w	Height_Of_Screen(a4),Map_Line_Offset1(a4)
	Add.w	#Max_Scroll_Speed-1,Map_Line_Offset1(a4)

.No_Carry_Screen
	Subq.w	#1,Block_Line_Offset1(a4)
	Bcc.s	.No_New_Line	
	Move.w	#$f,Block_Line_Offset1(a4)
	Sub.l	#24*2,Map_Pointer1(a4)
.No_New_Line	
	Addq.w	#1,Y_Accum(a4)
	Subq.w	#1,(sp)
	Bne.s	.Loop0
	Addq.l	#2,sp
.No_Scroll
	Subq.b	#1,Carrier_Event_Delay1(a4)
	Bcc.s	.No_New_Event	
	Move.l	Carrier_Event1(a4),a1
	Move.b	(a1)+,Carrier_Event_Delay1(a4)
	Move.b	(a1)+,Scroll_Rate1(a4)
	Move.l	a1,Carrier_Event1(a4)
.No_New_Event	
	Rts

**********************************************************
Copy_Cloud_Map
	Lea	Cloud_Map_Rom,a0
	Lea	Cloud_Map_Ram,a1
	Move.w	#((Cloud_Map_Ram-Cloud_Map_Rom)/6)-1,d7
.Loop	Movem.w	(a0)+,d0-d2
;	Sub.w	#Screen_Height+100,d2
	Move.w	Height_Of_Screen(a4),d3
	Add.w	#100,d3
	Sub.w	d3,d2
	Move.w	d0,(a1)+
	Move.w	d1,(a1)+
	Move.w	d2,(a1)+
	Dbra	d7,.Loop
	Rts

**********************************************************
Move_Clouds
	Cmp.w	#1,Carrier_Seq_Number(a4)
	Beq.s	.Clouds
	Cmp.w	#2,Carrier_Seq_Number(a4)
	Bne.s	.No_Clouds
.Clouds
	Tst.b	Clouds_Active(a4)
	Beq.s	.No_Clouds
	Tst.b	No_More_Clouds(a4)
	Bne.s	.No_Clouds
	St	No_More_Clouds(a4)
	Lea	Cloud_Map_Ram,a0
	Move.w	#((Cloud_Map_Ram-Cloud_Map_Rom)/6)-1,d7
.Loop	Movem.w	(a0)+,d0-d2
	Addq.w	#2,d2
	Add.w	d0,d2
;	Cmp.w	#Screen_Height,d2
	Cmp.w	Height_Of_Screen(a4),d2
	Blt.s	.Not_At_End_Of_Screen	
	Tst.b	Kill_Clouds_Active(a4)
	Bne.s	.Skip
	Moveq	#-60,d2	
.Not_At_End_Of_Screen	
	Sf	No_More_Clouds(a4)
.Skip	Move.w	d0,-6(a0)
	Move.w	d1,-4(a0)
	Move.w	d2,-2(a0)
	Dbra	d7,.Loop
.No_Clouds
	Rts

**********************************************************
Draw_Clouds1
	Cmp.w	#1,Carrier_Seq_Number(a4)
	Beq.s	.Clouds_Ok
	Cmp.w	#2,Carrier_Seq_Number(a4)
	Beq.s	.Clouds_Ok
	Rts	
.Clouds_Ok
	Lea	Cloud_Lev1,a2
	Move.w	#(Cloud_Lev2-Cloud_Lev1)/6,d0
	Bra.s	Print_Clouds
Draw_Clouds2
	Cmp.w	#1,Carrier_Seq_Number(a4)
	Beq.s	.Clouds_Ok
	Cmp.w	#2,Carrier_Seq_Number(a4)
	Beq.s	.Clouds_Ok
	Rts	
.Clouds_Ok
	Lea	Cloud_Lev2,a2
	Move.w	#(Cloud_Lev3-Cloud_Lev2)/6,d0

Print_Clouds
	Move.w	d0,-(sp)
	Move.l	Carrier_Sprites_Base(a4),a3
	Move.l	Carrier_GFX_Base(a4),a5
.Loop	Move.w	(a2)+,d2
	Add.w	#9,d2
	Move.w	(a2)+,d0
	Move.w	(a2)+,d1
	Add.w	X_Offset_Into_Map(a4),d0
;	Cmp.w	#Screen_Height,d1
	Cmp.w	Height_Of_Screen(a4),d1
	Bge.s	.No_Print
	Bsr	Blit_A_Sprite	
.No_Print
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Rts

**********************************************************
Cloud_Map_Rom
	Dc.w	0,100,0
	Dc.w	1,300,20
	Dc.w	0,200,100
	Dc.w	1,000,40
Cloud_Map_Roma
	Dc.w	0,250,150
	Dc.w	1,160,80
	Dc.w	1,00,140
	Dc.w	0,30,180

Cloud_Map_Ram
Cloud_Lev1
	Ds.b	Cloud_Map_Roma-Cloud_Map_Rom
Cloud_Lev2
	Ds.b	Cloud_Map_Ram-Cloud_Map_Roma
Cloud_Lev3

