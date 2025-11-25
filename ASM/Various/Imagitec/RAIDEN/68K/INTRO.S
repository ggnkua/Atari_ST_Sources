****************************************************************************
Intro	
	Clr.w	Delay_For_Clear	
	Sf	Entering_Hi_Score+Data
	Sf	Video_Flag
	Clr.b	Atari_Logo_On_Vblank+Data
	Jsr	Setup_Object_Processor_To_Point_to_Stop
	Lea	Data,a4
	Lea	Hardware,a5
	Jsr	RESUMEDSP
	Jsr	Get_Sound_Effect_Music_Vol_From_Eeprom
	Jsr	Set_SFXmusic_Volumes

	Sf	Reflect_Object_Flag(a4)
	Clr.w	Setup_Ints_Flag
	Clr.b	Player1_Start(a4)
	Clr.b	Player2_Start(a4)
	Clr.w	Added_Sprites_To_List(a4)
	Clr.b	Demo_Mode(a4)
	Bsr	Intro_Vbl_Stuff
	Jsr	Stop_Mod
	Lea	Data,a4
	Clr.b	Num_Credits(a4)
	Clr.b	No_More_Scrolling(a4)
	Sf	Flag_To_Stop_Scrolling(a4)
	Move.l	a7,Stack_Save(a4)
	Jsr	Setup_Screens
	Jsr	Copypal			; Initial Pallete is 0s, Clear colour registers
	Jsr	Setup_Screens
	Bsr	Load_In_Intro_Info		
	Jsr	Setup_Object_Processor_To_Point_to_Stop
	Jsr	Setup_Ints
;	Move.l	#$100000,Pl1+Score
	Bsr	Enter_New_Hi_Score

	Move.w	#Panel_Width,Panel_X(a4)
	Move.w	#Panel_Width,Map_Display_Width(a4)
	Lea	Intro_Mod_Name,a0
	Trap	#15
	Move.l	a1,a0
	Move.l	a1,Intro_Mod_Address(a4)
	Jsr	pt_mod_init		
	Jsr	nofade
	Jsr	start_mod		;its this what makes things go
Intro_Loop
	Move.b	#5,Num_Credits(a4)
	St	Exit_On_Vbl(a4)
	Lea	Atari_Pal,a0
	Trap	#15
	Move.l	a1,a0
	Lea	Mypal-2,a1
	Move.w	#257*2,d0
	Jsr	Copy_Bytes
	Move.w	#0,d2
	Bsr	Zoom_A_Logo	
	Lea	IDL_Pal,a0
	Trap	#15
	Move.l	a1,a0
	Lea	Mypal-2,a1
	Move.w	#257*2,d0
	Jsr	Copy_Bytes
	Move.w	#1,d2
	Bsr	Zoom_A_Logo	

	Moveq	#1,d0
	Jsr	Wait_Vbl
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Jsr	Wait_For_Vblank_And_Swapscreens

	Lea	Title_Pal,a0
	Lea	Mypal-2,a1
	Trap	#15
	Lea	Mypal,a0
	Lea	Destpal,a1
	Move.w	#256*2,d0
	jsr	Copy_Bytes
	Bsr	Scroll_Raiden_Screen
	Bsr	Load_Plate_Palette_To_Clut
	Bsr	Reset_Plates
	Bsr	Plates_Up

	Move.b	#1,This_Level(a4)
	Bsr	Scroll_Map_Part
	Bsr	Hi_Score_Part
	Move.b	#3,This_Level(a4)
	Bsr	Scroll_Map_Part
	Bsr	Hi_Score_Part

	Moveq	#1,d0
	Bsr	Demo_Attract_Mode

	Move.b	#6,This_Level(a4)
	Bsr	Scroll_Map_Part
	Bsr	Hi_Score_Part
	Move.b	#7,This_Level(a4)
	Bsr	Scroll_Map_Part
	Bsr	Hi_Score_Part

	Moveq	#4,d0
	Bsr	Demo_Attract_Mode

	Move.b	#5,This_Level(a4)
	Bsr	Scroll_Map_Part
	Bsr	Hi_Score_Part
	Move.b	#8,This_Level(a4)
	Bsr	Scroll_Map_Part
	Bsr	Hi_Score_Part

	Moveq	#6,d0
	Bsr	Demo_Attract_Mode

	Move.b	#4,This_Level(a4)
	Bsr	Scroll_Map_Part
	Bsr	Hi_Score_Part

	Moveq	#7,d0
	Bsr	Demo_Attract_Mode

	Bra	Intro_Loop

****************************************************************************
Set_SFXmusic_Volumes
	Move.w	Music_Vol,d0
	Mulu	#255,d0
	Divu	#15,d0
	EXt.l	d0
	Moveq	#0,d1
	Jsr	Set_Volume
	Move.w	Sfx_Vol,d0
	Mulu	#255,d0
	Divu	#15,d0
	EXt.l	d0
	Moveq	#1,d1
	Jsr	Set_Volume
	Rts


****************************************************************************

Scroll_Raiden_Screen
	Sf	No_Printing_top_Map(a4)
	Move.w	#100-48+14,Rdlogo_coard
;	Move.w	#-Screen_Height+40-32,Rdlogo_coard+2
	Move.w	Height_Of_Screen(a4),d3
	Neg.w	d3
	Add.w	#40,d3
	Sub.w	#32,d3
	Tst.b	Ntsc_Flag(a4)
	Bne.s	.Ntsc_Ok
	Add.w	#24+16,d3
.Ntsc_Ok
	Move.w	d3,Rdlogo_coard+2
	St	Copy_The_Pallete(a4)
;	Move.w	#Screen_Height,-(sp)
	Move.w	Height_Of_Screen(a4),-(sp)
.Back	Moveq	#1,d0
	Jsr	Wait_Vbl
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Move.w	X_Offset_Into_Map(a4),d0
	Add.w	#14,d0
	Move.w	(sp),d1
	Move.w	#91,d2
	Move.l	Intro_Header_Address(a4),a3
	Move.l	Intro_GFX_Address(a4),a5
	Bsr	Blit_A_Sprite
	Movem.w	Rdlogo_coard(pc),d0-d1
	Move.w	#91,d2
	Move.l	Intro_Header_Address(a4),a3
	Move.l	Intro_GFX_Address(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Move.w	#2,d2
	Bsr	Blit_A_Sprite
	Jsr	Swapscreens
	Addq.w	#1,Rdlogo_Coard+2
	Subq.w	#1,(sp)
	Tst.b	Ntsc_Flag(a4)
	Bne.s	.Ok_Ntsc
	Cmp.w	#34,(sp)
	Bne.s	.Back
	Bra.s	.Skipde
.Ok_Ntsc
	Cmp.w	#10,(sp)
	Bne.s	.Back
.Skipde	Move.w	#350,(sp)
.Loop1	Moveq	#1,d0
	Jsr	Wait_Vbl
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Move.w	X_Offset_Into_Map(a4),d0
	Add.w	#14,d0
	Tst.b	Ntsc_Flag(a4)
	Bne.s	.Nok
	Move.w	#34,d1
	Bra.s	.Skip
.NOk
	Move.w	#10,d1
.Skip	Move.w	#91,d2
	Move.l	Intro_Header_Address(a4),a3
	Move.l	Intro_GFX_Address(a4),a5
	Bsr	Blit_A_Sprite
	Movem.w	Rdlogo_coard(pc),d0-d1
	Move.w	#91,d2
	Move.l	Intro_Header_Address(a4),a3
	Move.l	Intro_GFX_Address(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Move.w	#2,d2
	Bsr	Blit_A_Sprite

	Jsr	Swapscreens
	Subq.w	#1,(sp)
	Bne.s	.Loop1
	Addq.l	#2,sp
	Move.w	#256,Master_Intens(a4)
.Loop	
	Moveq	#1,d0
	Jsr	Wait_Vbl
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Move.w	X_Offset_Into_Map(a4),d0
	Add.w	#14,d0
	Tst.b	Ntsc_Flag(a4)
	Bne.s	.Nok1
	Move.w	#34,d1
	Bra.s	.Skipo
.NOk1
	Move.w	#10,d1
.Skipo	Move.w	#91,d2
	Move.l	Intro_Header_Address(a4),a3
	Move.l	Intro_GFX_Address(a4),a5
	Bsr	Blit_A_Sprite
	Movem.w	Rdlogo_coard(pc),d0-d1
	Move.w	#91,d2
	Move.l	Intro_Header_Address(a4),a3
	Move.l	Intro_GFX_Address(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Move.w	#2,d2
	Bsr	Blit_A_Sprite
	Jsr	Swapscreens
	Bsr	Fade_Title_Pal
	Subq.w	#2,Rdlogo_Coard+2
	Subq.w	#8,Master_Intens(a4)
	Bge.s	.Loop
	Moveq	#1,d0
	Jsr	Wait_Vbl
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Jsr	Swapscreens
	Moveq	#1,d0
	Jsr	Wait_Vbl
	Rts

Rdlogo_coard	Ds.w	2

****************************************************************************
Fade_Title_Pal
	Move.w	Master_Intens(a4),d0
	Lea	Mypal,a0
	Lea	Destpal,a1
	Move.w	#256-1,d7
	Moveq	#8,d6
	Move.w	#$ff,d5
.Loop	Move.w	(a0)+,d1
	Move.w	d1,d2
	And.w	d5,d2
	Mulu	d0,d2
	Lsr.w	d6,d2
	Move.b	d2,d1
	Move.w	d1,(a1)+
	Dbra	d7,.Loop
	St	Copy_The_Pallete(a4)
	Rts

****************************************************************************
Check_O_Button
	Move.l	Joycur,d0
	Move.l	Joycur+4,d1
	Tst.b	O_Repeat(a4)
	Bne.s	.Check_O_Repeat	
	St	O_Repeat(a4)
	Btst	#Key_0,d0
	Beq.s	.Check2
	Not.b	Music_On(a4)
	Bne.s	.Turn_It_Off
	Bra.s	.Turn_It_On
.Check2	Btst	#Key_0,d1
	Beq.s	.Check_O_Repeat	
	Not.b	Music_On(a4)
	Bne.s	.Turn_It_Off
	Bra.s	.Turn_It_On
.Check_O_Repeat	
	Btst	#Key_0,d0
	Beq.s	.Not_Repeat
	Rts
.Not_Repeat
	Btst	#Key_0,d1
	Beq.s	.Not_Pressed2
	Rts
.Not_Pressed2
	Clr.b	O_Repeat(a4)
	Rts

.Turn_It_On
	Jsr	start_mod			
	St	Flag_To_Ewrite_Music(a4)
;	Jsr	Write_Music_On_Off_To_Status
	Rts
.Turn_It_Off
;	Jsr	Write_Music_On_Off_To_Status
	St	Flag_To_Ewrite_Music(a4)
	Jsr	Stop_Mod
	Rts	


****************************************************************************
Write_Music_Status_maybe
	Tst.b	Flag_To_Ewrite_Music(a4)
	Beq.s	.No_Music_Write
	Clr.b	Flag_To_Ewrite_Music(a4)
	Jsr	Write_Music_On_Off_To_Status
.No_Music_Write
	Rts

****************************************************************************
Check_For_A_Fire_Button
	jsr	Readpad
	Bsr	Check_O_Button

.Check_For_Fire
	Jsr	Fire_A_Pressed_2		; If ya pressed A
	Sne	Player2_Start
	Bne.s	.Exit_Intro
	Jsr	Fire_B_Pressed_2
	Sne	Player2_Start
	Bne.s	.Exit_Intro
	Jsr	Fire_A_Pressed			; If ya pressed A
	Sne	Player1_Start+Data
	Bne.s	.Exit_Intro
	Jsr	Fire_B_Pressed
	Sne	Player1_Start+Data
.Exit_Intro
	Rts


****************************************************************************
EXit_Intro
	Jsr	Stop_Gpu
	Jsr	Wait_for_Gpu
	Lea	Data,a4
	Sf	Exit_On_Vbl(a4)
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Jsr	Wait_For_Vblank_And_Swapscreens
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Jsr	Wait_For_Vblank_And_Swapscreens

	Clr.b	Fire_Pressed_On_Read+Pl1
	Clr.b	Fire_Pressed_On_Read+Pl2
	Move.b	Player1_Start+Data,Fire_Pressed_On_Read+Pl1
	Move.b	Player2_Start+Data,Fire_Pressed_On_Read+Pl2

	Move.w	#25,-(sp)
	Moveq	#0,d0
.Loop	Tst.b	Fire_Pressed_On_Read+Pl1
	Beq.s	.No_Pressed_Pl1
	Bset	#0,d0
.No_Pressed_Pl1
	Tst.b	Fire_Pressed_On_Read+Pl2
	Beq.s	.No_Pressed_Pl2
	Bset	#1,d0
.No_Pressed_Pl2
	Move.w	d0,-(sp)
	Jsr	Readjoysticks
	Jsr	Wait_Main_Vbl			; Syncronize with a timed source!
	Move.w	(sp)+,d0
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Move.w	d0,(sp)
.Plate_Sequence_Done		
	Move.w	(sp),d0
	Move.l	Stack_Save(a4),a7
	Rts


****************************************************************************
Demo_Attract_Mode
	Clr.b	Times_Through(a4)
	Subq.w	#1,d0
	Move.w	d0,-(sp)
	Moveq	#25-1,d7
.Loop	Jsr	Wait_Main_Vbl
	Dbra	d7,.Loop

	Jsr	Plates_Down

	Jsr	Atari_Logo_On	
	Move.w	(sp),d0
	Lea	.Wep_Tab(pc),a6
	Lsl.w	#3,d0
	Lea	(a6,d0),a6
	Move.b	(a6)+,Weapon_Num(a4)
	Move.b	(a6)+,Weapon_Powersave(a4)
	Move.b	(a6)+,Weapon_Num+1(a4)
	Move.b	(a6)+,Weapon_Powersave+1(a4)
	Move.b	(a6)+,Weapon_Num2(a4)
	Move.b	(a6)+,Weapon_Powersave2(a4)
	Move.b	(a6)+,Weapon_Num2+1(a4)
	Move.b	(a6)+,Weapon_Powersave2+1(a4)


	Move.w	(sp)+,d0
	Add.w	d0,d0
	Add.w	d0,d0
	Lea	.Tab(pc),a6
	Move.w	(a6,d0),Map_Offset_Variable(a4)
	Move.w	2(a6,d0),d1
	Move.b	d1,This_Level(a4)
	Lea	.Fil(pc),a6
	Move.l	(a6,d0),a0
	Trap	#15
	Lea	Player_1_Script,a2
	Bsr	Transfer_Script
	Jsr	Search_Zero
	Trap	#15
	Lea	Player_2_Script,a2
	Bsr	Transfer_Script
	St	Play_Through_Script(a4)
	Moveq	#3,d7
	Move.b	This_Level(a4),-(sp)
	St	Demo_Mode(a4)	
	Jsr	Initial_Vars				; Setup the initial variables for players
	Move.b	(sp)+,This_Level(a4)
	Clr.l	Bomb_Struct(a4)
;	Jsr	Pre_Generate_Some_Player_Objects	; Generate FAST header sprites for player graphics
;	Jsr	Generate_Player_Collision_Boxes		; Make collision boxes based on width and height of sprites
	Move.w	#0,Panel_X(a4)
	Move.w	#0,Map_Display_Width(a4)
	Move.l	Pl1+Score,-(sp)
	Move.l	Pl2+Score,-(sp)
	Move.b	#1,Num_Creds+Pl1
	Move.b	#1,Num_Creds+Pl2
	Bsr	Clear_Out_Weapons
	Jsr	Re_Initialize
	Jsr	Stop_GPU
	Lea	SORTER_S,a0
	Move.l	#$100,d0
	Jsr	Load_Gpu_Prog
	Jsr	Atari_Logo_Off

	Jsr	Pre_Generate_Some_Player_Objects	; Generate FAST header sprites for player graphics
	Jsr	Generate_Player_Collision_Boxes		; Make collision boxes based on width and height of sprites


	Jsr	Main
	Sf	Demo_Mode(a4)	
	Move.w	#Panel_Width,Panel_X(a4)
	Move.w	#Panel_Width,Map_Display_Width(a4)
	Clr.b	Play_Through_Script(a4)
	Move.l	(sp)+,Pl2+Score
	Move.l	(sp)+,Pl1+Score
	Clr.b	Player_Active+Pl1
	Clr.b	Player_Active+Pl2				; Active flags for both players
	Clr.b	Num_Lives+Pl1
	Clr.b	Num_Lives+Pl1
	Bsr	Load_In_Intro_Info		
	Bsr	Load_Plate_Palette_To_Clut
	Jsr	Plates_Up
	Rts

.Fil	
	Dc.l	.Fil1
	Dc.l	.Fil1
	Dc.l	.Fil1
	Dc.l	.Fil4
	Dc.l	.Fil4
	Dc.l	.Fil6
	Dc.l	.Fil7
	Dc.l	.Fil7


.Fil1	Dc.b	"SCR1PL1.SCR",0
	Dc.b	"SCR1PL2.SCR",0
	Even
.Fil4	Dc.b	"SCR4PL1.SCR",0
	Dc.b	"SCR4PL2.SCR",0
	Even
.Fil6	Dc.b	"SCR6PL1.SCR",0
	Dc.b	"SCR6PL2.SCR",0
	Even
.Fil7	Dc.b	"SCR7PL1.SCR",0
	Dc.b	"SCR7PL2.SCR",0
	Even

.Tab	
;	Dc.w	128,1
	Dc.w	128-5,1
	Dc.w	50,1
	Dc.w	50,1
	Dc.w	80,4
	Dc.w	50,1
	Dc.w	20,6
	Dc.w	40,7
	Dc.w	50,1
	
.Wep_Tab
	Dc.b	0,0,-1,0,0,0,-1,0
	Dc.b	0,0,-1,0,0,0,-1,0
	Dc.b	0,0,-1,0,0,0,-1,0

	Dc.b	0,3,1,3,1,4,-1,0
	Dc.b	0,3,1,3,1,4,-1,0

	Dc.b	0,3,1,3,1,4,-1,0
	Dc.b	0,7,1,3,1,4,0,2

	Dc.b	0,3,1,3,1,4,-1,0



****************************************************************************
Clear_Out_Weapons
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Lea	Shots_To_Do(a3),a3
	Move.w	#Max_Weapons,-(sp)
.Loop	Clr.l	(a3)
	Lea	Wep_End(a3),a3
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Rts

****************************************************************************
Transfer_Script
	Move.l	(a1)+,(a2)+
	Bpl.s	Transfer_Script
	Rts

****************************************************************************
Hi_Score_Part
	Clr.b	Reset_Score_Flag
	Lea	Hi_Score_Name_Pal,a0
	Lea	Mypal-2,a1
	Trap	#15
	Tst.l	d0
	Bne.s	.Compressed
	Move.l	a1,a0
	Lea	Mypal-2,a1
	Move.l	#257*2,d0
	Jsr	Copy_Bytes
.Compressed
	Bsr	Load_Plate_Palette
	Move.w	#256,Master_Intens(a4)
	Jsr	Fade_Pallete

	Jsr	Wait_Main_Vbl
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Bsr	Print_Hi_Score_Screen
	Bsr	Print_Hi_Scores
	Bsr	Intro_Vbl_Stuff
	Bsr	Print_Copyright_HI
	Jsr	Check123
	Bsr	Sub_Plates
	Jsr	Wait_For_Vblank_And_Swapscreens
	Tst.b	Plates_Displayed(a4)
	Beq.s	Hi_Score_Part
	
	Move.w	#100,-(sp)
.Loop0	Jsr	Wait_Main_Vbl
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Bsr	Print_Hi_Score_Screen
	Bsr	Print_Hi_Scores
	Bsr	Intro_Vbl_Stuff
	Bsr	Print_Copyright_HI
	Jsr	Check123
	Jsr	Wait_For_Vblank_And_Swapscreens
	Subq.w	#1,(sp)
	Bne.s	.Loop0
	Addq.l	#2,sp
	
.Scroll_Loop2
	Jsr	Wait_Main_Vbl
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Bsr	Print_Hi_Score_Screen
	Bsr	Print_Hi_Scores
	Bsr	Intro_Vbl_Stuff
	Bsr	Print_Copyright_HI
	Bsr	Add_Plates
	Jsr	Wait_For_Vblank_And_Swapscreens
	Tst.b	Plates_Displayed(a4)
	Beq.s	.Scroll_Loop2
	Jsr	Wait_Main_Vbl
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Bsr	Add_Plates
	Jsr	Wait_For_Vblank_And_Swapscreens
	Jsr	Reset_Eeprom
	Clr.w	Delay_For_Clear	
	Rts

****************************************************************************
Reset_Eeprom
	Tst.b	Reset_Score_Flag
	Beq.s	.No
	Jsr	Copy_Hi_Score_To_eprom
	Jsr	Default_Sound
	Jsr	Set_SFXmusic_Volumes
	Jsr	Put_Sound_Effect_Music_Vol_In_Eeprom
	Jsr	Write_Music_On_Off_To_Status
.No	Rts

****************************************************************************
Check123
	Tst.w	Delay_For_Clear	
	Beq.s	.Check
	Subq.w	#1,Delay_For_Clear	
	Moveq	#70,d0
	Moveq	#20,d1
	Moveq	#92,d2
	Add.w	X_Offset_Into_Map(a4),d0
	Move.l	Intro_Header_Address(a4),a3
	Move.l	Intro_GFX_Address(a4),a5
	Bsr	Blit_A_Sprite
	Rts
.Check	MOve.l	Joycur,d0
	Bsr.s	.Do
	MOve.l	Joycur+4,d0

.Do	Btst	#Key_Star,d0
	Sne	d1
	Btst	#Key_Hash,d0
	Sne	d2
	Btst	#Option,d0
	Sne	d3
	And.b	d1,d2
	And.b	d2,d3
	Bne.s	.Pressed
	Sf	Onetwothree
	Rts

.Pressed
	Tst.b	Onetwothree
	Bne.s	.Repeat
	St	Onetwothree
	St	Reset_Score_Flag
	Jsr	Reset_Hi_Score
	Jsr	Default_Sound
	Jsr	Set_SFXmusic_Volumes
	Move.w	#100,Delay_For_Clear
.Repeat	Rts

Reset_Score_Flag	Ds.b	1
Onetwothree		Ds.b	1
Delay_For_Clear		Ds.w	1


****************************************************************************
Print_Copyright_HI
	Rts
	Move.w	#14,d0
;	Move.w	#Screen_Height-27-24+8,d1
	Move.w	Height_Of_Screen(a4),d1
	Sub.w	#27,d1
	Sub.w	#24,d1
	Add.w	#8,d1

	Add.w	#12,d0
	Add.w	#2,d1
	Move.l	Intro_Header_Address(a4),a3
	Move.l	Intro_GfX_Address(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Move.w	#7,d2
	Bsr	Blit_A_Sprite
	Rts

****************************************************************************
Print_Hi_Scores
	Lea	High_Score_Table,a0
	Move.w	#10,-(sp)
	Move.w	#60,d1
	Pal_Add_Center
.Loop0	Move.w	#91+4,d0
	Add.w	X_Offset_Into_Map(a4),d0
	Moveq	#-3,d7				; Letters
	Bsr.s	Print_Chars
	Moveq	#8,d7				; Numbers
	Add.w	#48,d0
	Bsr.s	Print_Chars
	Moveq	#1,d7				; Numbers
	Add.w	#100,d0
	Bsr.s	Print_Chars
	Add.w	#20,d0
	Moveq	#1,d7				; Numbers
	Bsr.s	Print_Chars
	Add.w	#11,d1
	Subq.w	#1,(sp)
	Bne.s	.Loop0
	Addq.l	#2,sp
	Rts

Print_Chars
	Move.w	d0,-(sp)
	Tst.w	d7
	Bmi.s	.Alpha
	Sf	Leading_Zero(a4)
.Loop	Moveq	#0,d2
	Move.b	(a0),d2
	Lsr.w	#4,d2
	And.w	#$f,d2
	Bne.s	.Not_Zero1
	Tst.b	Leading_Zero(a4)
	Beq.s	.Zero1
.Not_Zero1
	St	Leading_zero(a4)
	Add.w	#10,d2
	Move.l	Intro_Header_Address(a4),a3
	Move.l	Intro_GFX_Address(a4),a5
	Bsr	Blit_A_Sprite
.Zero1	Add.w	#10,d0
	Subq.w	#1,d7
	Beq.s	.Done
	Moveq	#0,d2
	Move.b	(a0)+,d2
	And.w	#$f,d2
	Bne.s	.Not_Zero
	Tst.b	Leading_Zero(a4)
	Beq.s	.Zero		
.Not_Zero
	St	Leading_Zero(a4)
	Add.w	#10,d2
	Move.l	Intro_Header_Address(a4),a3
	Move.l	Intro_GFX_Address(a4),a5
	Bsr	Blit_A_Sprite
.Zero	Add.w	#10,d0
	Subq.w	#1,d7
	Bne.s	.Loop
	Move.w	(sp)+,d0
	Rts
.Done	Addq.l	#1,a0
	Move.w	(sp)+,d0
	Rts


.Alpha	Moveq	#0,d2
	Move.b	(a0)+,d2
	Cmp.b	#" ",d2
	Beq.s	.No_Print
	Cmp.b	#"Z",d2
	Ble.s	.Normal
	Sub.b	#"a",d2
	Add.w	#50+10,d2
	Bra.s	.Skipo
.Normal
	Sub.b	#"A",d2
	Add.w	#10+10,d2
.Skipo	
	Move.l	Intro_Header_Address(a4),a3
	Move.l	Intro_GFX_Address(a4),a5
	Bsr	Blit_A_Sprite
.No_Print
	Add.w	#8,d0
	Addq.w	#1,d7
	Bne.s	.Alpha
	Move.w	(sp)+,d0
	Rts

****************************************************************************
Print_Hi_Score_Screen
	Lea	.Hi_Score_Coards_n_Sprites(pc),a1
.Loop	Tst.w	(a1)
	Bmi.s	.Exit
	Move.w	(a1)+,d2
	Move.w	(a1)+,d0
	Move.w	(a1)+,d1
	Add.w	#16,d0
	Add.w	#12-3-2,d1
	Pal_Add_Center
	Move.l	Intro_Header_Address(a4),a3
	Move.l	Intro_GfX_Address(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Bsr	Blit_A_Sprite
	Bra.s	.Loop
.Exit	Rts

.Hi_Score_Coards_n_Sprites
	Dc.w	3,0,0
	Dc.w	4,144,0
	Dc.w	5,0,100
	Dc.w	6,144,100
	Dc.w	-1


****************************************************************************
Enter_New_Hi_Score
	St	Entering_Hi_Score(a4)

	Clr.b	Fire_Pressed_On_Read+Pl1
	Clr.b	Fire_Pressed_On_Read+Pl2
	Clr.b	Fire_Repeat(a4)

	Clr.b	Hi_Score_Set
	Jsr	Enable_Fx
	Lea	Hi_Mod_Name,a0
	Trap	#15
	Move.l	a1,Guardian_Mod_Address(a4)

	Jsr	Load_In_Player_Sprites
	Movem.l	d0-a6,-(sp)
	Jsr	Pre_Generate_Some_Player_Objects
	Movem.l	(sp)+,d0-a6
	Lea	Hi_Score_Name_Pal,a0
	Lea	Mypal-2,a1
	Trap	#15
	Tst.l	d0
	Bne.s	.Compressed
	Move.l	a1,a0
	Lea	Mypal-2,a1
	Move.l	#2+(256*2),d0
	Jsr	Copy_Bytes	
.Compressed
	Bsr	Load_Plate_Palette
	Clr.w	Master_Intens(a4)
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
	Bsr.s	.Do
	Tst.b	Hi_Score_Set
	Beq.s	.No_Hi_Scorey
	Jsr	Fadedown
	Moveq	#50-1,d7
.Wait	Jsr	Wait_Main_Vbl
	Dbra	d7,.Wait
.No_Hi_Scorey
	Jmp	Stop_Mod

.Do	Move.l	a3,Player_Use(a4)
	Bsr	Get_Hi_Score_Number
	Move.w	Hi_Score_Number(a4),d0
	Bmi	.No_Hi_Score
	St	Hi_Score_Set
	Tst.l	Guardian_Mod_Address(a4)
	Beq.s	.Started_Mod
	Move.l	Guardian_Mod_Address(a4),a0
	Jsr	pt_mod_init		
	Jsr	start_mod		;its this what makes things go
	Jsr	Fadeup
	Clr.l	Guardian_Mod_Address(a4)
.Started_Mod
	Move.w	Hi_Score_Number(a4),d0
	Bsr	Shift_Down_Hi_Scores

	Move.w	Hi_Score_Number(a4),d0
	Mulu	#3+4+2,d0			; Base
	Lea	High_Score_Table,a1
	Lea	(a1,d0),a1
	Pea	(a1)
	Move.l	a1,Name_Address(a4)
	Move.b	#" ",(a1)+
	Move.b	#" ",(a1)+
	Move.b	#" ",(a1)+
	Lea	Score(a3),a2
	Move.b	(a2)+,(a1)+
	Move.b	(a2)+,(a1)+
	Move.b	(a2)+,(a1)+
	Move.b	(a2)+,(a1)+
	Move.b	Level_Reached(a3),d1
	Move.b	Stage_Reached(a3),d2
	Cmp.b	#9,d2
	Ble.s	.OOK
	Moveq	#9,d2
.OOk	Lsl.w	#4,d1
	Lsl.w	#4,d2
	Move.b	d2,(a1)+
	Move.b	d1,(a1)+
	Clr.w	Digit_Entry_Number(a4)
	Clr.w	Digit_Number(a4)
	Move.b	#1,Fade_Direction(a4)
	Move.w	#256,Master_Intens(a4)

.Loop0	Jsr	Wait_Main_Vbl
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Jsr	Fade_Up_Or_Down_Palette
	Bsr	Print_Hi_Score_Screen
	Bsr	Print_Hi_Score_Digit_Entry
	Bsr	Print_Hi_Score_Player_Num
	Bsr	Print_Hi_Scores
	Move.l	Player_Use(a4),-(sp)
	Bsr	Intro_Vbl_Stuff
	Bsr	Check_O_Button
	Move.l	(sp)+,Player_Use(a4)
	Bsr	Check_Resete
	Bsr	Print_Copyright_HI
	Jsr	Wait_For_Vblank_And_Swapscreens			; Swap buffers/screens
	Cmp.w	#3,Digit_Entry_Number(a4)
	Bne.s	.Loop0
	Move.l	(sp)+,a1
	Sub.b	#"a"-"A",(a1)+
	Sub.b	#"a"-"A",(a1)+
	Sub.b	#"a"-"A",(a1)+

	Move.w	#25,-(sp)
.Loop1	Jsr	Wait_Main_Vbl
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Bsr	Print_Hi_Score_Screen
	Bsr	Print_Hi_Scores
	Move.l	Player_Use(a4),-(sp)
	Bsr	Intro_Vbl_Stuff
	Bsr	Check_O_Button
	Move.l	(sp)+,Player_Use(a4)
	Bsr	Check_Resete
	Bsr	Print_Hi_Score_Player_Num
	Bsr	Print_Copyright_HI
	Jsr	Wait_For_Vblank_And_Swapscreens			; Swap buffers/screens
	Subq.w	#1,(sp)
	Bne.s	.Loop1
	Addq.l	#2,sp
	Jsr	Copy_Hi_Score_To_eprom
.No_Hi_Score
	Sf	Entering_Hi_Score(a4)
	Rts
	
Check_Resete
	Jsr	Hash_Asterisk_Pressed1
	Bne.s	.Restart
	Jsr	Hash_Asterisk_Pressed2
	Bne.s	.Restart
	Rts
.Restart
	Move.w	#3,Digit_Entry_Number(a4)
	Move.l	Name_Address(a4),a1
	Move.b	#"F",(a1)+
	Move.b	#"R",(a1)+
	Move.b	#"D",(a1)+
	Move.w	#0,Digit_Entry_Number(a4)
	Jmp	Restart_Game

Hi_Score_Set
	Dc.w	0

****************************************************************************
Shift_Down_Hi_Scores
	Cmp.w	#9,d0
	Beq.s	.Last_Entry
	Lea	High_Score_Table,a1			; d0 to insert in table (0-9)
	Lea	(3+4+2)*8(a1),a0
	Lea	(3+4+2)*9(a1),a1
	Sub.w	#9,d0
	Neg.w	d0
	Move.w	d0,d7
.Loop	Moveq	#3+4+2,d0			
	Jsr	Copy_Bytes
	Lea	-(3+4+2)*2(a0),a0
	Lea	-(3+4+2)*2(a1),a1
	Dbra	d7,.Loop
.Last_Entry
	Rts

****************************************************************************
Print_Hi_Score_Digit_Entry
	Move.l	Player_Use(a4),a3
	Tst.w	Xdirection(a3)
	Beq.s	.No_Add
	Tst.b	Repeat_Direction(a4)
	Bne.s	.Repeating_Joy
.Back	Move.b	#4,Delay_Char(a4)
	Tst.w	Xdirection(a3)
	Bpl.s	.Add_Char
	Subq.w	#2,Digit_Number(a4)
.Add_Char
	Addq.w	#1,Digit_Number(a4)
	Bge.s	.OKK
	Move.w	#25,Digit_Number(a4)
.OKK	Cmp.w	#25,Digit_Number(a4)
	Ble.s	.Fuck
	Clr.w	Digit_Number(a4)
.Fuck	St	Repeat_Direction(a4)
	Bra.s	.No_Add2
.No_Add
	Sf	Repeat_Direction(a4)
	Clr.b	Second_Delay(a4)
	Clr.b	Delay_Char(a4)
	Bra.s	.No_Add2
.Repeating_Joy
	Cmp.b	#25,Second_Delay(a4)
	Beq.s	.Delay_For_Chars
	Addq.b	#1,Second_Delay(a4)
	Bra.s	.No_Add2
.Delay_For_Chars
	Tst.b	Delay_Char(a4)
	Beq.s	.Back
	Subq.b	#1,Delay_Char(a4)
.No_Add2
	Lea	High_Score_Table,a1
	Move.w	Hi_Score_Number(a4),d0
	Mulu	#3+4+2,d0			; Base
	Cmp.w	#3,Digit_Entry_Number(a4)
	Beq.s	.No_Fire
	Add.w	Digit_Entry_Number(a4),d0
	Add.l	d0,a1
	Move.w	Digit_Number(a4),d0
	Add.b	#"a",d0
	Move.b	d0,(a1)

	Tst.b	Fire_Pressed_On_Read(a3)
	Beq.s	.No_Fire
	Tst.b	Fire_Repeat(a4)
	Bne.s	.No_Fire2
	Lea	Name_Reg_Samp,a6
	Bsr	Play_This_Sample
	Addq.w	#1,Digit_Entry_Number(a4)
	St	Fire_Repeat(a4)
	Rts
.No_Fire
	Sf	Fire_Repeat(a4)
.No_Fire2
	Rts

****************************************************************************
Print_Hi_Score_Player_Num
	Moveq	#8,d2
	Cmp.l	#Pl1,Player_Use(a4)
	Beq.s	.No_Print
	Moveq	#9,d2
.No_Print
	Move.w	#12,d0
	Move.w	#22,d1
	Pal_Add_Center
	Move.l	Intro_Header_Address(a4),a3
	Move.l	Intro_GfX_Address(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Add.w	#10,d0
	Add.w	#12,d1
	Bsr	Blit_A_Sprite
	Rts

****************************************************************************
Get_Hi_Score_Number
	Lea	High_Score_Table,a1
	Moveq	#9,d7
	Moveq	#0,d6
.Loop	Lea	3(a1),a2
	Subq.l	#4,sp
	Move.l	sp,a6
	Move.b	(a2)+,(a6)+
	Move.b	(a2)+,(a6)+
	Move.b	(a2)+,(a6)+
	Move.b	(a2)+,(a6)+
	Move.l	(sp)+,d0
	Move.l	Score(a3),d1
	Cmp.l	d0,d1
	Bgt.s	.Found_Hi_Score
	Addq.w	#1,d6
	Lea	3+4+2(a1),a1		; Base
	Dbra	d7,.Loop
	Moveq	#-1,d6		
.Found_Hi_Score
	Move.w	d6,Hi_Score_Number(a4)
	Rts	

****************************************************************************
Scroll_Map_Part
	Clr.b	Reset_Score_Flag
	Clr.b	No_Printing_top_Map(a4)
	Move.b	#5,Num_Credits(a4)
	Clr.b	Player_Active+Pl1
	Clr.b	Player_Active+Pl2
	Clr.w	X_Speed+Pl1
	Clr.w	X_Speed+Pl2
	Moveq	#0,d0
	Move.b	This_Level(a4),d0
	Subq.b	#1,d0
	Lsl.w	#2,d0
	Lea	Rom_File_List,a6
	Move.l	(a6,d0),a0
	Lea	MyPal-2,a1
	Trap	#15
	Tst.l	d0
	Bne.s	.Compressed_Pallete
	Push 
	Move.l	a1,a0
	Lea	Mypal-2,a1
	Move.l	#257*2,d0
	Jsr	Copy_Bytes
	Cmp.b	#1,This_Level(a4)
	Bne.s	.Cows_Not_White
	Lea	Mypal+(248*2),a1
	Move.l	#$77ff77ff,(a1)+
	Move.l	#$77ff77ff,(a1)+
	Move.l	#$77ff77ff,(a1)+
	Move.l	#$77ff77ff,(a1)+
.Cows_Not_White
	Pull
.Compressed_Pallete
	Bsr	Load_Plate_Palette
	Lea	Stuff_To_load,a1
	Add.l	File_Len(a4),a1
	Jsr	Search_Zero
	Jsr	Search_Zero
	Trap	#15
	Move.l	a1,Gfxblocks_Base(a4)		; Load in blockset
	Add.l	d0,a1
	Jsr	Search_Zero
	Jsr	Search_Zero
	Jsr	Search_Zero
	Lea	Map_Table(a4),a5
.Map_Load
	Jsr	Search_Zero	
	Tst.b	(a0)
	Bmi.s	.Done
	Trap	#15
	Move.l	a1,(a5)+
	Add.l	d0,a1	
	Bra.s	.Map_Load
.Done	Move.w	#2,Num_Maps_Loaded(a4)
	St	(a5)
	Jsr	Initialize_Maps
	Jsr	Load_In_Player_Sprites
	Movem.l	d0-a6,-(sp)
	Jsr	Pre_Generate_Some_Player_Objects
	Movem.l	(sp)+,d0-a6

	Moveq	#0,d0
	Move.b	This_Level(a4),d0
	Subq.b	#1,d0
	Add.w	d0,d0
	Lea	.Offsets_Into_Map(pc),a5
	Move.w	(a5,d0),d0
	Mulu	#60,d0
	Lea	Map_Info(a4),a5
	Sub.l	d0,Map_Pointer(a5)
	Lea	Map_Structure_End(a5),a5
	Sub.l	d0,Map_Pointer(a5)

	Move.w	#Byteswide/2-(Screen_Width/2),X_Offset_Into_Map(a4)
	Move.w	#0,Map_Offset_Variable(a4)
;	Move.w	#Screen_Height,-(sp)
	Move.w	Height_Of_Screen(a4),-(sp)
.Loop	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Jsr	Scroll_Lr			; Get line offsets, Play/Screen offsets
	Jsr	Build_Map			; Build map if scrolling
	Jsr	Scroll_Down_Maps
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp

	Moveq	#0,d0
	Move.b	This_Level(a4),d0
	Subq.w	#1,d0
	Lea	Rom_File_List,a0
	Lsl.w	#2,d0
	Move.l	(a0,d0),a0
	Lea	MyPal-2,a1	
	Trap	#15
	Bsr	Load_Plate_Palette
	Move.w	#$f0ff,Mypal+(241*2)
	Move.w	#256,Master_Intens(a4)
	Clr.b	Fade_Direction(a4)
	Jsr	Fade_Pallete
.Scroll_Loop0
	Jsr	Wait_Main_Vbl
	Bsr	Level_Pallete_Stuff		; Cycle / pulses etc
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Jsr	Scroll_Lr			; Get line offsets, Play/Screen offsets
	Jsr	Build_Map			; Build map if scrolling
	Bsr	Base_Map_To_Object
	Bsr	Other_Map_To_Object
	Jsr	Scroll_Down_Maps
	Bsr	Intro_Vbl_Stuff
	Bsr	Print_Logo
	Bsr	Print_Copyright
	Jsr	Check123
	Bsr	Sub_Plates
	Jsr	Wait_For_Vblank_And_Swapscreens
	Tst.b	Plates_Displayed(a4)
	Beq.s	.Scroll_Loop0
	Move.w	#300,-(sp)
.Scroll_Loop1
	Jsr	Wait_Main_Vbl
	Bsr	Level_Pallete_Stuff		; Cycle / pulses etc
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Jsr	Scroll_Lr			; Get line offsets, Play/Screen offsets
	Jsr	Build_Map			; Build map if scrolling
	Bsr	Base_Map_To_Object
	Bsr	Other_Map_To_Object
	Jsr	Scroll_Down_Maps
	Bsr	Intro_Vbl_Stuff
	Bsr	Print_Logo
	Bsr	Print_Copyright
	Jsr	Check123
	Jsr	Wait_For_Vblank_And_Swapscreens			; Swap buffers/screens
	Subq.w	#1,(sp)
	Bne.s	.Scroll_Loop1
	Addq.l	#2,sp
.Scroll_Loop2
	Jsr	Wait_Main_Vbl
	Bsr	Level_Pallete_Stuff		; Cycle / pulses etc
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Jsr	Scroll_Lr			; Get line offsets, Play/Screen offsets
	Jsr	Build_Map			; Build map if scrolling
	Bsr	Base_Map_To_Object
	Bsr	Other_Map_To_Object
	Jsr	Scroll_Down_Maps
	Bsr	Intro_Vbl_Stuff
	Bsr	Print_Logo
	Bsr	Print_Copyright
	Jsr	Check123
	Bsr	Add_Plates
	Jsr	Wait_For_Vblank_And_Swapscreens
	Tst.b	Plates_Displayed(a4)
	Beq.s	.Scroll_Loop2
	Jsr	Reset_Eeprom
	Clr.w	Delay_For_Clear	
	Rts
	
.Offsets_Into_Map
	Dc.w	90,30,30,30,50,200,100,200


****************************************************************************
Intro_Vbl_Stuff
	Jsr	Wait_For_100			; Wait until ship has reached line 100 (startup)
	Jsr	Readjoysticks
	Jsr	Adj_Speed			; Adjust Left/Right/Up/Down vectors
	Jsr	Move_Ship			; Get new ship x/y Coardinates
	Jsr	Check_Ship_Bound		; Check screen coardinates of ship
	Jsr	Dead_Count_Dec			; Decrement delay for collision on ship
	Jsr	Draw_Shadow_For_Players
	Jsr	Draw_Ship			; Draw ship to view screen
	Rts

****************************************************************************
Print_Logo
	Move.w	#90,d0
	Move.w	#20-13,d1
	Move.l	Intro_Header_Address(a4),a3
	Move.l	Intro_GfX_Address(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Move.w	#90,d2
	Add.w	#12,d0
	Bsr	Blit_A_Sprite
	Move.l	Current_List_Pointer(a4),a0
	Movem.l	-16(a0),d4-d7
	Bset	#16,d6
	Movem.l	d4-d7,-16(a0)

	Move.w	#58,d0
	Move.w	#70-13,d1
	Move.l	Intro_Header_Address(a4),a3
	Move.l	Intro_GfX_Address(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Move.w	#2,d2
	Add.w	#12,d0
	Bsr	Blit_A_Sprite

	Rts
Print_Copyright
	Move.w	#34,d0
;	Move.w	#Screen_Height-40,d1
	Move.w	Height_Of_Screen(a4),d1
	Sub.w	#40,d1
	Move.l	Intro_Header_Address(a4),a3
	Move.l	Intro_GfX_Address(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Move.w	#7,d2
	Bsr	Blit_A_Sprite
	Rts

****************************************************************************
Plates_Up
	Jsr	Wait_Main_Vbl
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Bsr	Add_Plates
	Jsr	Wait_For_Vblank_And_Swapscreens
	Tst.b	Plates_Displayed(a4)
	Beq.s	Plates_Up
	Rts
Plates_Down
	Jsr	Wait_Main_Vbl
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Bsr	Sub_Plates
	Jsr	Wait_For_Vblank_And_Swapscreens
	Tst.b	Plates_Displayed(a4)
	Beq.s	Plates_Down
	Rts

****************************************************************************
Add_Plates
	St	Plates_Displayed(a4)
	Lea	Plates_Ram,a1
.Loop	Tst.w	(a1)
	Bmi.s	.Done
	Movem.w	(a1)+,d0-d3
	Move.b	Frame_Diff(a4),d4
	Ext.w	d4
	Sub.w	d4,d3
	Subq.w	#1,d3
	Ble.s	.Print_It
	Sf	Plates_Displayed(a4)
	Movem.w	d0-d3,-8(a1)
	Bra.s	.Loop
.Print_It
	Movem.w	d0-d3,-8(a1)
	Move.l	Plate_Header_Address(a4),a3
	Move.l	Plate_Gfx_Address(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Bsr	Add_Plate_If_Ntsc
	Bsr	Blit_A_Sprite
	Bra.s	.Loop
.Done	Rts



****************************************************************************
Sub_Plates
	St	Plates_Displayed(a4)
	Lea	Plates_Ram,a1
.Loop	Tst.w	(a1)
	Bmi.s	.Done
	Movem.w	(a1)+,d0-d3
	Move.b	Frame_Diff(a4),d4
	Ext.w	d4
	Add.w	d4,d3
	Addq.w	#1,d3
	Ble.s	.Print_It
	Movem.w	d0-d3,-8(a1)
	Bra.s	.Loop
.Print_It
	Sf	Plates_Displayed(a4)
	Movem.w	d0-d3,-8(a1)
	Move.l	Plate_Header_Address(a4),a3
	Move.l	Plate_Gfx_Address(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Bsr	Add_Plate_If_Ntsc
	Bsr	Blit_A_Sprite
	Bra.s	.Loop
.Done	Rts


****************************************************************************
Add_Plate_If_Ntsc
	Tst.b	Ntsc_Flag(a4)
	Bne.s	.Ntsc
	Tst.w	d1
	Beq.s	.Ntsc
	Add.w	#24,d1
.Ntsc	Rts


****************************************************************************
Reset_Plates
	Lea	Plates_Rom,a0
	Lea	Plates_Ram,a1
	Move.l	#Plates_Rome-Plates_Rom,d0
	Jmp	Copy_Bytes

Plates_Rom
	Dc.w	000,000,000,02
	Dc.w	078,000,001,04
	Dc.w	140,000,002,15
	Dc.w	181,000,003,04
	Dc.w	213,000,004,02
	
	Dc.w	038,025,005,06
	Dc.w	078,038,006,07
	Dc.w	106,038,007,10
	Dc.w	140,068,008,17
	Dc.w	181,035,009,08
	Dc.w	000,057,010,09

	Dc.w	106,087,011,04
	Dc.w	213,054,012,06
	Dc.w	241,054,013,08
	Dc.w	268,077,014,02
	Dc.w	000,095,015,10

	Dc.w	078,137,016,12
	Dc.w	156,105,017,03
	Dc.w	241,103,018,05
	Dc.w	000,183,019,02
	Dc.w	103,137,020,06

	Dc.w	156,159,021,07
	Dc.w	255,159,022,05

	Dc.w	-1
Plates_Rome

****************************************************************************
Zoom_A_Logo	
Max_Size	Equ	(5<<5)+8
	Move.w	#Max_Size,Atari_Logo_Scale(a4)
	Move.w	d2,-(sp)
.Loop0	
	Moveq	#1,d0
	Jsr	Wait_Vbl
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Move.w	Atari_Logo_Scale(a4),d2
	Sub.w	#$20,d2				; Ranges for 192
	Sub.w	#Max_Size,d2
	Neg.w	d2
	Mulu	#256,d2
	Divu	#Max_Size,d2		
	Move.w	d2,Master_Intens(a4)
	Jsr	Fade_Pallete
	Move.w	(sp),d2
	Bsr	Zoom_Logo
	Jsr	Swapscreens
	Subq.w	#4,Atari_Logo_Scale(a4)
	Cmp.w	#1<<5,Atari_Logo_Scale(a4)
	Bne.s	.Loop0
	Move.w	#150,-(sp)
.Loop1	Moveq	#1,d0
	Jsr	Wait_Vbl
	Subq.w	#1,(sp)
	Bne.s	.Loop1
	Addq.l	#2,sp
.Loop2	Moveq	#1,d0
	Jsr	Wait_Vbl
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Move.w	Atari_Logo_Scale(a4),d2
	Sub.w	#$20,d2				; Ranges for 192
	Sub.w	#Max_Size,d2
	Neg.w	d2
	Mulu	#256,d2
	Divu	#Max_Size,d2		
	Move.w	d2,Master_Intens(a4)
	Jsr	Fade_Pallete
	Move.w	(sp),d2
	Bsr	Zoom_Logo
	Jsr	Swapscreens
	Addq.w	#4,Atari_Logo_Scale(a4)
	Cmp.w	#Max_Size,Atari_Logo_Scale(a4)
	Bne.s	.Loop2
	Addq.l	#2,sp
	Rts

****************************************************************************
Zoom_Logo
	Move.w	d2,-(sp)
	Lsl.w	#4,d2
	Move.l	Intro_Header_Address(a4),a3
	Move.w	Spr_Pixel_Width(a3,d2),d0
	Move.w	Spr_Sheight(a3,d2),d1
	Asr.w	#1,d0
	Asr.w	#1,d1
	Neg.w	d0
	Neg.w	d1
	Move.w	Atari_Logo_Scale(a4),d5
	Muls	d5,d0
	Muls	d5,d1
	Asr.w	#5,d0
	Asr.w	#5,d1
	Add.w	#Screen_Width/2,d0
;	Add.w	#Screen_Height/2,d1
	Move.w	Height_Of_Screen(a4),d2
	Asr.w	#1,d2
	Add.w	d2,d1
	Move.w	(sp)+,d2
	Move.w	Atari_Logo_Scale(a4),d6
	Move.w	Atari_Logo_Scale(a4),d7
	Move.l	Intro_Header_Address(a4),a3
	Move.l	Intro_Gfx_Address(a4),a5
	Bsr	Blit_A_Scaled_Sprite
	Rts
****************************************************************************
Load_In_Intro_Info		
	Clr.l	File_Len(a4)
	Lea	Intro_Header_Name,a0
	Lea	Stuff_To_load,a1
	Move.l	a1,d0
	And.l	#-8,d0
	Move.l	d0,a1
	Move.l	a1,Intro_Header_Address(a4)
	Trap	#15
	Add.l	d0,File_Len(a4)

	Add.l	d0,a1
	Lea	Intro_Sprites_Name,a0
	Move.l	a1,Intro_Gfx_Address(a4)
	Trap	#15
	Add.l	d0,File_Len(a4)
	Add.l	d0,a1
	Tst.b	Ntsc_Flag(a4)
	Bne.s	.Ntsc_Plates
	Lea	Plates_Header_NameUK,a0
	Move.l	a1,Plate_Header_Address(a4)
	Trap	#15
	Move.l	d0,-(sp)
	Add.l	d0,File_Len(a4)
	Add.l	d0,a1
	Lea	Plates_Sprites_NameUK,a0
	Move.l	a1,Plate_Gfx_Address(a4)
	Trap	#15
	Add.l	d0,File_Len(a4)
	Bra.s	.Loaded_Plates
.Ntsc_Plates
	Lea	Plates_Header_Name,a0
	Move.l	a1,Plate_Header_Address(a4)
	Trap	#15
	Move.l	d0,-(sp)
	Add.l	d0,File_Len(a4)
	Add.l	d0,a1
	Lea	Plates_Sprites_Name,a0
	Move.l	a1,Plate_Gfx_Address(a4)
	Trap	#15
	Add.l	d0,File_Len(a4)
.Loaded_Plates
	Move.l	(sp)+,d0
	Move.l	Plate_Header_Address(a4),a1
.Loop	Move.w	#256-32,Spr_PalNum(a1)
	Lea	16(a1),a1
	Sub.w	#16,d0
	Cmp.w	#16,d0
	Bge.s	.Loop
	Rts

****************************************************************************
Load_Plate_Palette
	Push
	Lea	Plate_Palette,a0
	Lea	Mypal+((256-32)*2),a1
	Moveq	#15,d0
.Loop	Move.w	(a0)+,(a1)+
	Dbra	d0,.Loop
	Pull
	Rts

Load_Plate_Palette_To_Clut
	Push
	Lea	Plate_Palette,a0
	Lea	Hardware+Clut+((256-32)*2),a1
	Lea	Destpal+((256-32)*2),a2
	Moveq	#15,d0
.Loop	Move.w	(a0),(a1)+
	Move.w	(a0)+,(a2)+
	Dbra	d0,.Loop
	Pull
	Rts


Plate_Palette
	Incbin	D:\Raiden\Gamedata\Plates.CPL

****************************************************************************

