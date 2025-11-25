                                                                                  ; /**************************************/
; /*          Frednous Gave ya          */
; /*                                    */
; /*              RAIDEN!               */
; /*                                    */
; /**************************************/

;ROB68K
;**********************************************************
; GREEN / RED / BYTE / BLUE			- Format for JAGS border/paper colours
; Top byte colour / Bottom byte intensity	- A standard CRY 16 bit value

; Some stuff used all the time for test purposes, not worthy to be in EQUATES.S
Ntsc_Height	Equ	226
Pal_Height	Equ	226+48
Pal_Center	Equ	(Pal_Height-Ntsc_Height)/2

Map_offset		Equ	0 240 260 300 160 220 330 83 100 150		50!
Load_Event		Equ	1				; Load Binary event
Level			Equ	1				; Initial level number
Max_Level		Equ	8				; STOP!STOP!STOP!
Atari_Wants		Equ	1
Record			Equ	0				; Record player movements from start !
Feedevents

	Ifne	Load_Event
On	Equ	1
Off	Equ	0
	Endc




	xref GPUPP_S
	xref GPUPP_E
	xref SETUPGPU
	xref DECOMPRESSGPUPP1
	xref WAITFORGPU
	xref init_sound
	xref pt_mod_init
	xref fadeup
	xref fadedown
	xref nofade
	xref set_volume
;	xref set_master_volume
	xref start_mod
	xref stop_mod
	xref nt_vbl
	xdef ENABLETIMER
	xdef DISABLETIMER	
	xref playfx
	xref	stop_mod
	xref	disable_fx
	xref	enable_fx
	xref	HALTDSP
	Xref	RESUMEDSP

	Xref	SORTER_E
	Xref	SORTER_S
	Xref	GPU_SORT
	Xref	SORT_PARAMS
	Xref	GPU_DRAW_ALIENS
	Xref	Draw_Aliens_Params
	Xref	Olist_Return
	Xref	Num_Objects_Added

	Xref	XGpu_Draw_Aliens_Shadow
	Xref	XDraw_Aliens_Shadow_Params
	Xref	GET_ATTRIB_RISC
	Xref	Attrib_Params
	Xref	Num_Objects_In_List

	Xref	Draw_Weapons_GPU
	Xref	Weapon_Params
	Xref	Link_Params
	Xref	Build_Link_GPU

	Xref	Gpu_Quick_Ref
	Xref	Move_Aliens_GPU
	Xref	Move_Params
	Xref	GpuX_Move_Pointer
	Xref	Weapon_Params
	Xref	Gpu_Weapon_Collision
	Xref	WEPCOL_POINTER
	Xref	Move_Weapon_Params
	Xref	Gpu_Move_Weapons




;**********************************************************
	Opt	w-				; Turn off all assembly warnings
GO	Include	Spool.s				; SYSTEM BOOTER! -CODE HERE!-
	Include	AlnPrev.s
	Include	Linfo.s
	Include	Equates.s			; Game Equates
	Include	Globvars.s			; Variables from 16bit displacements
	Include	ObjSetup.s
	Include	SFX.S
	Include	Macros.s			; Some Code&Data macros
	Include	Options.s
	Include	EromInt.s
	Include	Carrier.s
	Include	Intro.s				; Intro code can go in JAG too!
	Include	Rommer.s			; ROM file loader
	Include	"D:\jaguar\include\jaguar.inc'	; Jaguar HARDWARE includes
	Include	"D:\jaguar\include\Joypad.Inc"	; Jaguar JOYPAD includes
	Include	"D:\jaguar\include\Blit.inc"	; Jaguar BLITTER includes
	Include	Video.s				; Video setup
	Include	"OBJECT.S"			; Object processor stuff
	Include	"BLITTER.S"			; Blitter routines
	Include	"JOYPAD.S"			; Joypad routines
	Include	"GPU.S"				; GPU interface routines
	Include	"CYCLE.S"			; Color cycling tables
	Include	"ATARILO.S"			; Atari logo for dreaded "BLACK SCREENS!"
Video_Flag	Dc.w	0
Cheat_Mode_Active	Dc.w	0


;**********************************************************
	OPT	D+

; Parameters passed
; d0 - Bit 0 - Player 1 Active 
; d0 - Bit 1 - Player 2 Active 

Start	Sf	Video_Flag
	Jsr	Setup_Object_Processor_To_Point_to_Stop
	Clr.l	Num_Objects_To_Display+Data
	Jsr	Setup_Initial_Branch
	Clr.w	Setup_Ints_Flag
	Lea	Data,a4					; Pointer to game variables
	Jsr	init_sound		
	Clr.b	Music_On(a4)
	Clr.b	O_Repeat(a4)
	Clr.w	Added_Sprites_To_List(a4)
	Jsr	Clear_Out_Data_Variables		; Clear em all !
	Jsr	Clear_Out_Player_Variables		; Clear all player variables
	Jsr	Generate_Pre_Sines		; Wont have to do these all of the time
Re_Start
	Clr.b	Atari_Logo_On_Vblank(a4)
	Sf	Reflect_Object_Flag(a4)
	Lea	Stack_Area,a7
	Ifeq	Record
	Jsr	Intro(pc)			; Boot into luvly intro yup!
	Else
	Move.w	#3,d0				; Players 1 & 2
	Endc
;	Move.w	#1,d0
	Jsr	Init				; Setup game


**********************************************************
** MAIN GAME LOOP
Main	Jsr	Wait_Main_Vbl
;	Move.l	Joycur,d0
;	Btst	#OPTION,d0
;	Bne	Freeze

	Bsr	Level_Skip
	Bsr	Check_Guardian_Mod
	Bsr	Move_Back_Panel
	Jsr	Fade_Up_Or_Down_Palette		; Palette fades for level start/exit
	Jsr	Check_O_Button
	Bsr	Check_For_Pause			; Check if pause button pressed
	Bsr	Level_Pallete_Stuff		; Cycle / pulses etc
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Jsr	Check_Bomb_Button		; Check if bomb button pressed
	Jsr	Check_Fire_Button		; Check if fire button pressed
	Jsr	Can_I_Let_It_Loose		; Let a weapon go if ya pressed fire
	Bsr	Move_Weapons			; Move weapons around the play-area
	Jsr	Move_Bomb			; Move bomb if dropping
	Bsr	Move_Aliens			; Move aliens around the play-area
	Bsr	Build_Linked_Alien_Lists	; Linked sprites < Base sprites
	Bsr	Track_Sprites_To_Player		; Track sprites that auto track ya
	Bsr	Sort_Out_Alien_Attributes	; Get various info about sprites & tablize!
	Bsr	Scroll_Lr			; Get line offsets, Play/Screen offsets
	Bsr	Base_Map_To_Object		; Display the base map
	Bsr	Sort_Aliens			; Draw aliens priority 0 first > priority 15 last
	Bsr	Draw_Aliens			; Draw alien sprites
	Bsr	Build_Map			; ODD PLACE BUT PARALLEL with G-P-U!
	Jsr	Finish_Drawing
	Jsr	Draw_Bomb			; Draw "ACTUAL" bomb sprite dropping from the skies
	Jsr	Draw_Bomb_Explosion		; Uno mega expplosion !
	Bsr	Draw_weapons			; Draw Weapons
	Bsr	Home_Into_Bastards		; Direct homing missiles
	Jsr	Finish_Drawing
	Bsr	Alien_To_Ship			; Check if anything has hit the player ship
	Bsr	Weapons_To_Aliens		; Check if any weapons have hit the aliens
	Bsr	Weapons_To_Players		; Player weapon<>player ship collision (sends sparks!)
	Bsr	Kill_Aliens_If_Bomb		; Knack off aliens if they are getting toasted
	Bsr	Scroll_Down_Maps		; Scroll down base map and maybe a mask map
	Bsr	Check_Event			; Check along event table
	Bsr	Check_Paralax_Event		; Check along Paralax (if available)
	Bsr	Insert_Stuff			; Various insertions into the active sprite list
	Bsr	Old_VBL_STUFF			; OLD VBL ? / lets call it PLAYER STUFF!
	Bsr	Check_Continue			; Continue logic
	Bsr	Seed_Rand			; Continually Generate a random number
	Bsr	Check_Can_Continue
	Jsr	Wait_For_Vblank_And_Swapscreens	; Careful you swap at the write time 
	Bsr	Check_End_Level			; Cehck if ya reached end of level
	Bsr	Check_Options_Pressed
	Jsr	Write_Music_Status_maybe
	Bra	Main				; lots and lots of subroutines=Easily managiable code!
Skip_Pause
	Bsr	Display_Pause			; Pause logic
	Jsr	Readjoysticks			; You might nothave read them ? cant remember!
	Bsr	Check_1_3_To_Get_Rid_Of_Pause
	Bsr	Check_Volume_Change
	Bsr	Display_Muzak_SFX_Volume
	Tst.b	Pause_Flag(a4)
	Bne	Main
	Jsr	Put_Sound_Effect_Music_Vol_In_Eeprom
	Bra	Main

**********************************************************
Check_Can_Continue
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Tst.w	Continue_Delay(a4)
	Bne.s	.No
	Tst.b	Num_Lives(a3)
	Bne.s	.No
	Cmp.w	#30*60,Can_Continue(a3)
	Beq.s	.No
	Addq.w	#1,Can_Continue(a3)
	Cmp.w	#30*60,Can_Continue(a3)
	Bne.s	.No
	Move.b	Num_Creds(a3),d0
	Sub.b	d0,Num_Credits(a4)
	Clr.b	Num_Creds(a3)
.No	Rts	

**********************************************************
Check_1_3_To_Get_Rid_Of_Pause
	Lea	Pl1,a3
	Move.l	Joycur,d0
	Bsr.s	.Do
	Lea	Pl2,a3
	Move.l	Joycur+4,d0

.Do	Btst	#Key_1,d0
	Beq.s	.No_Key1
	Btst	#Key_3,d0
	Beq.s	.No_Key1
	Tst.b	One_Three_Repeat(a3)
	Bne.s	.Exit
	St	One_Three_Repeat(a3)
	Not.b	Pause_Display_Flip(a4)
	Rts
.No_Key1
	Clr.b	One_Three_Repeat(a3)
.Exit	rts

**********************************************************
Finish_Drawing
	Jsr	Wait_for_Gpu
	Move.l	Olist_Return,Current_List_Pointer(a4)
	Move.l	Num_Objects_Added,d7
	Add.w	d7,Num_Objects_To_Display(a4)
	Rts

**********************************************************
Display_Muzak_SFX_Volume
	Tst.b	Music_On_Off
	Bne.s	.Display_Music
	Tst.b	SFX_On_Off
	Bne.s	.SFX
	St	Dsp_Halted(a4)
	Move.w	#$3f,d0
	Jsr	HALTDSP
	Clr.b	.Sfx_Halted
	Rts

.SFX	Tst.b	.Sfx_Halted
	Bne.s	.Changed
	St	.Sfx_Halted
	St	Dsp_Halted(a4)
	Jsr	RESUMEDSP
	Move.w	#$f,d0
	Jsr	HALTDSP
.Changed
	Moveq	#110,d2
	Move.w	SFX_Vol,d7
	Subq.w	#1,.SFX_TOGGLE
	Bpl.s	.Display_Level
	Move.w	#20,.SFX_TOGGLE
	Lea	BigExplosion_Sfx,a6
	Jsr	Play_This_Sample
	Bra.s	.Display_Level
.Display_Music
	Clr.b	.Sfx_Halted
	Tst.b	Dsp_Halted(a4)
	Beq.s	.Changed2
	Clr.b	Dsp_Halted(a4)
	Jsr	RESUMEDSP
	Move.w	#$30,d0
	Jsr	HALTDSP
.Changed2
	Moveq	#111,d2
	Move.w	Music_Vol,d7
.Display_Level
	Move.w	#06,d0
	Move.w	#170,d1
	Add.w	X_Offset_Into_Map(a4),d0
	Move.l	Player_Sprite_Base(a4),a3	
	Move.l	Player_GFX_Base(a4),a5
	Move.w	d7,-(sp)
	Move.w	d2,-(sp)
	Bsr	Add_A_Sprite
	Subq.w	#1,d1

	Add.w	#18,d0
	Move.w	#147,d2
	Bsr	Add_A_Sprite
	Sub.w	X_Offset_Into_Map(a4),d0
	Move.w	(sp)+,d2
	Move.w	(sp)+,d7

	Cmp.w	#111,d2
	Bne.s	.Not_Music
	Tst.b	Music_On(a4)
	Beq.s	.Not_Music
	Moveq	#0,d7	

;	Move.w	#56,d2
;	Addq.w	#3,d1
;	Add.w	#90,d0
;	Bsr	Add_A_Sprite
;	Rts

.Not_Music
	Move.w	#196,d6			; Normal length of bar / d7 0-15 (15-max)
	Mulu	d7,d6			; Multiply by normal width !
	Beq.s	.No_Volume
	Divu	#15,d6			; Number of pixels to print !
	Lsr.w	#2,d6			; /4 for number of phrases
	And.w	#$fffc,d6
	Ext.l	d6
	Addq.w	#4,d0			; A Bit in
	
	Move.l	d6,d2			; Width to print in d2
	Move.l	#196/4,d4		; Width of normal graphic in phrases
	Moveq	#4,d7			; Bits per pixel code (16!)
	Move.w	d2,-(sp)
	Move.w	#123,d2			; Sprite to print
	Lsl.w	#4,d2
	Move.l	Spr_Data(a3,d2),a1
	Add.l	a5,a1
	Move.w	Spr_Sheight(a3,d2),d3
		
	Move.w	(sp)+,d2
	Move.l	Current_List_Pointer(a4),a0
	Addq.w	#1,d0
	Addq.w	#3,d1
	Bsr	Add_A_Clipped_Sprite
.No_Volume
	Rts

.SFX_TOGGLE
	Ds.w	1
.Sfx_Halted
	Ds.w	1
**********************************************************
Add_A_Sprite
	Push
	Bsr	Disable_Ints
	Addq.w	#1,Num_Objects_To_Display+2(a4)
	Addq.w	#1,Added_Sprites_To_List(a4)
	Bsr	Blit_A_Sprite
	Bsr	Fix_Added_Sprite
	Bsr	Enable_Ints
	Pull
	Rts

Add_A_Clipped_Sprite
	Push
	Bsr	Disable_Ints
	Addq.w	#1,Num_Objects_To_Display+2(a4)
	Addq.w	#1,Added_Sprites_To_List(a4)
	Bsr	Make_A_Clipped_Object
	Move.l	a0,Current_List_Pointer(a4)
	Bsr	Fix_Added_Sprite
	Bsr	Enable_Ints
	Pull
	Rts

**********************************************************
Fix_Added_Sprite
	Move.l	Current_List_Pointer(a4),a0
	Movem.l	-16(a0),d0-d3
	Add.l	#16,Object_To_Link_To(a4)
	Move.l	Object_To_Link_To(a4),d4
	Lsr.l	#3,d4
	Move.l	d4,d5
	And.l	#%11111111,d5
	Ror.l	#8,d5
	And.l	#$fffff800,d0
	And.l	#$ffffff,d1	
	Lsr.l	#8,d4
	Or.l	d5,d1
	Or.l	d4,d0
	Movem.l	d0-d3,-16(a0)
	Move.l	Current_List_Pointer(a4),a0
	Bsr	Insert_Stop_Object
	Rts


**********************************************************
Get_Object_To_Link_To
	Move.w	Num_Objects_To_Display+2(a4),d0
	Lsl.w	#4,d0
	Move.l	Object_List_Pointer+4(a4),a0
	Lea	(a0,d0),a6
	Move.l	a6,Object_To_Link_TO(a4)
	Move.l	Object_List_Pointer+8(a4),a0
	Lea	(a0,d0),a0
	Move.l	a0,Current_List_Pointer(a4)
	Rts

**********************************************************
Check_Volume_Change
	Subq.w	#1,Joy_Check_Delay_Count
	Bpl.s	.Posytron
	Move.w	#2,Joy_Check_Delay_Count
.Posytron
	Tst.w	Joy_Check_Delay_Count
	Bne.s	.No_Check
	Bsr	Readjoy1MSFX
	Bsr	Readjoy2MSFX
.No_Check
	Rts

Readjoy2MSFX
	Tst.b	Pl2+Num_Lives
	Beq	.No_Readjoy1
	Tst.w	Joy_Check_Delay_Count
	Bne.s	.Not_Pressed_Right
	Jsr	Direction_Pressed_2
	Btst	#2,d0
	Beq.s	.Not_Pressed_Left
	Bsr	Sub_Music_SFX		
.Not_Pressed_Left
	Btst	#3,d0
	Beq.s	.Not_Pressed_Right
	Bsr	Add_Music_SFX		
.Not_Pressed_Right
	Jsr	Fire_A_Pressed_2			; If ya pressed A
	Beq.s	.Not_Presseda
	Tst.b	Joy_2_Repeat
	Bne.s	.No_Joystick_Pressed
	St	Joy_2_Repeat
	Tst.b	SFX_On_Off
	Beq.s	.Ok_To_Put_Up_Music
	Clr.b	SFX_On_Off
	Clr.b	Music_On_Off
.Ok_To_Put_Up_Music
	Not.b	Music_On_Off
	Rts
.Not_Presseda
	Jsr	Fire_B_Pressed_2			; If ya pressed A
	Beq.s	.Not_Pressedb
	Tst.b	Joy_2_Repeat
	Bne.s	.No_Joystick_Pressed
	St	Joy_2_Repeat
	Tst.b	Music_On_Off
	Beq.s	.Ok_To_Put_Up_SFX
	Clr.b	Music_On_Off
	Clr.b	Sfx_On_Off
.Ok_To_Put_Up_SFX
	Not.b	Sfx_On_Off
	Rts
.Not_Pressedb
.No_Readjoy1
	Clr.b	Joy_2_Repeat
.No_Joystick_Pressed
	Rts





Readjoy1MSFX
	Tst.b	Pl1+Num_Lives
	Beq	.No_Readjoy1
	Tst.w	Joy_Check_Delay_Count
	Bne.s	.Not_Pressed_Right
	Jsr	Direction_Pressed
	Btst	#2,d0
	Beq.s	.Not_Pressed_Left
	Bsr	Sub_Music_SFX		
.Not_Pressed_Left
	Btst	#3,d0
	Beq.s	.Not_Pressed_Right
	Bsr	Add_Music_SFX		
.Not_Pressed_Right
	Jsr	Fire_A_Pressed			; If ya pressed A
	Beq.s	.Not_Presseda
	Tst.b	Joy_1_Repeat
	Bne.s	.No_Joystick_Pressed
	St	Joy_1_Repeat
	Tst.b	SFX_On_Off
	Beq.s	.Ok_To_Put_Up_Music
	Clr.b	SFX_On_Off
	Clr.b	Music_On_Off
.Ok_To_Put_Up_Music
	Not.b	Music_On_Off
	Rts
.Not_Presseda
	Jsr	Fire_B_Pressed			; If ya pressed A
	Beq.s	.Not_Pressedb
	Tst.b	Joy_1_Repeat
	Bne.s	.No_Joystick_Pressed
	St	Joy_1_Repeat
	Tst.b	Music_On_Off
	Beq.s	.Ok_To_Put_Up_SFX
	Clr.b	Music_On_Off
	Clr.b	Sfx_On_Off
.Ok_To_Put_Up_SFX
	Not.b	Sfx_On_Off
	Rts
.Not_Pressedb
.No_Readjoy1
	Clr.b	Joy_1_Repeat
.No_Joystick_Pressed
	Rts


Music_On_Off
	Ds.b	1
SFX_On_Off
	Ds.b	1
Joy_1_Repeat
	Ds.b	1
Joy_2_Repeat
	Ds.b	1
Joy_Check_Delay_Count
	Ds.w	1

Music_Vol
	Dc.w	10
SFX_Vol
	Dc.w	15

**********************************************************
Add_Music_SFX		
	Bsr	Check_If_Music_On
	Moveq	#1,d4
	Bra.s	Upper_Lower_MSFX
Sub_Music_SFX		
	Bsr	Check_If_Music_On
	Moveq	#-1,d4
Upper_Lower_MSFX
	Tst.b	Music_On_Off
	Bne.s	.Adj_Music
	Tst.b	SFX_On_Off
	Bne.s	.Adj_Sfx
	Rts

.Adj_Music
	Push
	Add.w	d4,Music_Vol
	Bpl.s	.Pos		; Bastard comment here !!!!
	Clr.w	Music_Vol
.Pos	Cmp.w	#$f,Music_Vol
	Ble.s	.No_Music
	Move.w	#$f,Music_Vol
.No_Music
	Jsr	Set_SFXmusic_Volumes
	Pull
	Rts


.Adj_Sfx
	Push
	Add.w	d4,SFX_Vol
	Bpl.s	.Pos2
	Clr.w	SFX_Vol
.Pos2	Cmp.w	#$f,SFX_Vol
	Ble.s	.No_Sfx
	Move.w	#$f,SFX_Vol
.No_Sfx
	Jsr	Set_SFXmusic_Volumes
	Pull
	Rts

**********************************************************
Check_If_Music_On
	Tst.b	Music_On_Off
	Beq.s	.No_check_Music
	Tst.b	Music_On(a4)
	Beq.s	.No_check_Music
	Addq.l	#4,sp
.No_check_Music
	Rts

**********************************************************

Check_Guardian_Mod
	Tst.b	Guardian_Music_On(a4)
	Beq.s	.No_Mod
	Bpl.s	.Guardian_Mod_Coming_Up
	Addq.b	#1,Guardian_Music_On(a4)
	Bne.s	.No_Mod
	Move.l	Base_Mod_Address(a4),a0
.Back	Jsr	Stop_Mod
	Jsr	pt_mod_init
	Jsr	Fadeup
	Jsr	Start_Mod
	Rts
.Guardian_Mod_Coming_Up
	Subq.b	#1,Guardian_Music_On(a4)
	Bne.s	.No_Mod
	Move.l	Guardian_Mod_Address(a4),a0
	Bra.s	.Back
.No_Mod	Rts


**********************************************************
Freeze
	Move.w	#0,Vmode+Hardware
	Move.l	Object_List_Pointer+4(a4),a0
	Move.l	Gfxblocks_Base(a4),a1
	Move.w	#Screen_Width,d0
;	Move.w	#Screen_Height,d1
	Move.w	Height_Of_Screen(a4),d1
	Bra	Construct_Cry_Screen

**********************************************************
; Parameters
; A0 - Object list to build to screen
; A1 - Area of memory to construct to (Must be phrased!)
; D0 - X Dimension of screen area
; D1 - Y Dimension of screen area

Get_Obj	Macro	
	Movem.l	Object_Data_Read,d0-d3
	Endm

Construct_Cry_Screen
	Movem.l	a0-a1,Objlist_To_Build_From		; Save parameters
	Movem.w	d0-d1,Width_Of_Screen			; Save width/ height
	Move.l	#Backup_Freeze_Objectlist,d0
	And.l	#-16,d0
	Move.l	d0,Backup_Freeze_Objectlistp			; Phrase align pointer to vbl buffer
	Move.l	d0,a0
	Move.w	#0,d0
	Moveq	#4,d7					; Number of bits per pixel encoded
	Move.w	Width_Of_Screen,d2
	Lsr.w	#2,d2					; Get number of phrases !
	Move.w	Height_Of_Screen_Dump,d3
	Move.w	#0,d1					; Get height and y position 0
	Moveq	#0,d6
	Bsr	Make_An_Object				; Make it
	Clr.l	(a0)+
	Move.l	#4,(a0)+				; Stop object

	Lea	Freeze_Objectlist,A0
	Move.l	Backup_Freeze_Objectlistp,a1
	Exg	a0,a1
	Rept	8
	Move.l	(a0)+,(a1)+
	Endr




	Move.l	Base_Screen_Buffer,a0
	Movem.w	Width_Of_Screen,d0-d1			; Base pointer to screen
	Mulu	d1,d0					; Size of screen in words
.Clear	Clr.w	(a0)+
	Subq.l	#1,d0
	Bne.s	.Clear					; Clear out screen
	Pea	Construct_Vbl
	MOve.l	(sp)+,Level2
	Move.l	Backup_Freeze_Objectlistp,d0
	swap	d0
	move.l	d0,OLP+Hardware			; and other bits of the OL address
	move.w	#$6C1,VMODE+Hardware

Object_Type_Loop
	Move.l	Objlist_To_Build_From,a0
	Movem.l	(a0)+,d0-d3
	Movem.l	d0-d3,Object_Data_Read
	Move.l	a0,Objlist_To_Build_From
	Bsr	Get_Object_Attributes		

	Cmp.w	#0,Object_Type
	Bne	Not_A_Bitmap_Object
	Clr.w	Source_Gfx_Y
.Loop0	Clr.w	-(sp)
.Loop1	Clr.w	-(sp)
	Clr.w	Source_Gfx_X
	Tst.b	Object_Reflect
	Beq.s	.Loop2
	Move.w	Object_Dwidth,d2
	Lsl.w	#5,d2
	Subq.w	#1,d2
	Asr.w	#1,d2
	Move.w	d2,Source_Gfx_X
	Neg.w	d2
	Move.w	d2,(sp)
.Loop2	Movem.w	(sp),d0-d1
	Add.w	Object_Xpos,d0
	Add.w	Object_Ypos,d1
	Tst.w	d0
	Bmi	.Incx
	Tst.w	d1
	Bmi	.Incx
	Move.w	Width_Of_Screen,d4
	Cmp.w	d4,d0
	Bge	.Incx
	Cmp.w	Height_Of_Screen_Dump,d1
	Bge	.Incx
	Mulu	Width_Of_Screen,d1
	Add.l	d1,d1
	Ext.l	d0
	Add.l	d0,d1
	Add.l	d0,d1
	Add.l	Base_Screen_Buffer,d1
	Move.l	d1,Address_Of_CRYPixel
	Movem.w	Source_Gfx_X,d0-d1
	Bsr	Get_A_Pixel
	Tst.w	d7
	Bne.s	.Not_Trans
	Tst.b	Object_Trans
	Bne.s	.Incx
.Not_Trans
	Move.l	Address_Of_CRYPixel,a3
	Tst.b	Object_RMW
	Beq.s	.Not_Rmw_Object
	Tst.w	d7
	Beq.s	.Ploted_Pixel
	Addq.l	#1,a3
.Back1	Tst.w	d7
	Beq.s	.Ploted_Pixel
	Tst.b	d7
	Bpl.s	.Pos1
	Neg.b	d7
	Sub.b	d7,(a3)
	Bcc.s	.No_Carry1
	Clr.b	(a3)
.No_Carry1
	Lsr.w	#8,d7
	Subq.l	#1,a3
	Bra.s	.Back1
.Pos1	Add.b	d7,(a3)
	Bcc.s	.No_Carry2
	Move.b	#$ff,(a3)	
.No_Carry2
	Lsr.w	#8,d7
	Subq.l	#1,a3
	Bra.s	.Back1
.Not_Rmw_Object
	Move.w	d7,(a3)
.Ploted_Pixel
.Incx	Addq.w	#1,(sp)
	Tst.b	Object_Reflect
	Beq.s	.Normal_Dec
	Subq.w	#1,Source_Gfx_x
	Bpl	.Loop2
	Bra.s	.Skip
.Normal_Dec
	Addq.w	#1,Source_Gfx_x
	Move.w	Source_Gfx_X,d2
	
	Move.w	Object_Dwidth,d3
	Lsl.w	#3,d3
	Lsl.w	#3,d3
	Move.w	Object_Depth,d4
	Lsr.w	d4,d3	
	Cmp.w	d3,d2
	Bne	.Loop2
.Skip	Addq.l	#2,sp
	Addq.w	#1,(sp)
	Addq.w	#1,Source_Gfx_Y
	Move.w	(sp),d2
	Cmp.w	Object_Height,d2
	Bne	.Loop1
	Addq.l	#2,sp
	MOve.l	Object_Link,Objlist_To_Build_From
	Bra	Object_Type_Loop


; d0-x
; d1-y
; Returns CRY in d7

Get_A_Pixel
	Mulu	Object_Dwidth,d1
	Lsl.l	#3,d1
	Add.l	Object_Data,d1
	Move.l	d1,a3
	Move.w	Object_Depth,d2
	Add.w	d2,d2
	Add.w	d2,d2
	Lea	Dest_Bits,a6
	Clr.l	(a6)
	Jmp	.Jt(pc,d2)
.Jt	
	Bra	.Pixel1
	Bra	.Pixel2
	Bra	.Pixel4
	Bra	.Pixel8
	Bra	.Pixel16
	Bra	.Pixel32


.Pixel1
.Pixel2
.Pixel4
	Move.w	Object_Depth,d2
	Lsl.w	d2,d0				; Which bit field to check
	Moveq	#$7,d1
	And.w	d0,d1
	Eor.w	#$7,d1				; First bit to check
	Lsr.w	#3,d0				; Divide by bytes !
	
	Moveq	#1,d3
	Lsl.w	d2,d3
	Subq.w	#1,d3
.Check_Loop
	btst	d1,(a3,d0)
	Sne	(a6)+
	Subq.b	#1,d1
	Bcc.s	.No_Carry
	Moveq	#$7,d1
	Addq.w	#1,d0
.No_Carry
	Dbra	d3,.Check_Loop

	Moveq	#1,d3
	Lsl.w	d2,d3
	Subq.w	#1,d3
	Moveq	#0,d4
	Lea	Dest_Bits,a6
.Bit_Loop
	Tst.b	(a6)+
	Sne	d5
	And.b	#1,d5
	Lsl.w	#1,d4
	Or.b	d5,d4
	Dbra	d3,.Bit_Loop
	Tst.b	d4
	Bne.s	.Not_Trans	
	Tst.b	Object_Trans
	Beq.s	.Not_Trans
	Moveq	#0,d7
	Rts
.Not_Trans
	Move.w	Object_Index,d7
	Lsl.w	#1,d7
	Add.w	d4,d7
	Bra	.Pixel_There
.Pixel8
	Moveq	#0,d7
	Move.b	(a3,d0),d7
	Bne.s	.Pixel_There
	Tst.b	Object_Trans
	Beq.s	.Pixel_There
	Moveq	#0,d7
	Rts
.Pixel_There
	Add.w	d7,d7
	Lea	Clut+Hardware,a2
	Move.w	(a2,d7),d7
	Rts
.Pixel16
	Add.w	d0,d0
	Move.w	(a3,d0),d7
	Rts

.Pixel32
	Illegal

Not_A_Bitmap_Object
	Cmp.w	#4,Object_Type
	Beq	Its_A_Stop_Object
	Cmp.w	#3,Object_Type
	Bne.s	.Not_Branch
	Get_Obj
	MOveq	#14,d7
	Lsr.w	d7,d1
	And.b	#%11,d1
	Bne.s	.Conditional
	MOve.l	Object_Link,Objlist_To_Build_From
	Bra	Object_Type_Loop
.Conditional
	Addq.l	#8,Objlist_To_Build_From
	Bra	Object_Type_Loop



.Not_Branch
	Illegal
	Nop

Its_A_Stop_Object
	Move.l	Base_Screen_Buffer,a0
	Subq.l	#4,a0
	Movem.w	Width_Of_Screen,d0-d1
	Movem.w	d0-d1,(a0)
	Mulu	d1,d0
	Add.l	d0,d0
	Addq.l	#4,d0
	Illegal


Get_Object_Attributes
	Get_Obj
	And.l	#%111,d1
	Move.w	d1,Object_Type
	Get_Obj
	And.l	#%11111111111000,d1
	Lsr.l	#4,d1
	Sub.w	#(N_Vdb)/2,d1
	Asl.w	#6,d1
	Asr.w	#6,d1
	Move.w	d1,Object_Ypos
	Get_Obj
	And.l	#%1111111111100000000000000,d1
	Moveq	#14,d7
	Lsr.l	d7,d1
	Move.w	d1,Object_Height
	Get_Obj
	And.l	#%11111111<<24,d1
	Moveq	#24,d7
	Lsr.l	d7,d1
	And.l	#%11111111111,d0
	Lsl.l	#8,d0
	Add.l	d0,d1
	Lsl.l	#3,d1
	Move.l	d1,Object_Link
	Get_Obj
	And.l	#%11111111111111111111100000000000,d0
	Moveq	#11,d7
	Lsr.l	d7,d0
	Lsl.l	#3,d0
	Move.l	d0,Object_Data
	
	Get_Obj
	And.l	#%111111111111,d3
	Asl.w	#4,d3
	Asr.w	#4,d3
	Move.w	d3,Object_Xpos
	Get_Obj
	Moveq	#12,d7
	Lsr.l	d7,d3
	And.w	#%111,d3
	Move.w	d3,Object_Depth
	Get_Obj
	And.l	#%1111111111000000000000000000,d3
	Moveq	#18,d7
	Lsr.l	d7,d3
	Move.w	d3,Object_Dwidth
	Get_Obj
	And.l	#%1111111000000,d2
	Lsr.l	#38-32,d2
	Move.w	d2,Object_Index
	Get_Obj
	Btst	#45-32,d2
	Sne	Object_Reflect
	Btst	#46-32,d2
	Sne	Object_RMW
	Btst	#47-32,d2
	Sne	Object_Trans
	Rts

Construct_Vbl
	Push
	Move.w	Int1+Hardware,d0
	btst	#3,d0
	beq.s	.no_sound
	Move.w	#$809,Int1+Hardware
	Pull
	Move.w	#0,Int2+Hardware	
	Rte
.No_Sound
	Lea	Freeze_Objectlist,A0
	Move.l	Backup_Freeze_Objectlistp,a1
	Rept	8
	Move.l	(a0)+,(a1)+
	Endr
	Move.l	Backup_Freeze_Objectlistp,d0
	swap	d0
	move.l	d0,OLP+Hardware			; and other bits of the OL address
	Move.w	Int1+Hardware,d0
	lsl.w	#8,d0
	move.b	intmask,d0
	move.w	d0,INT1+Hardware
	move.w	d0,INT2+Hardware
	Pull
	Rte


Dest_Bits	Ds.b	4

Object_Type	Ds.w	1
Object_Ypos	Ds.w	1
Object_Height	Ds.w	1
Object_Link	Ds.l	1
Object_Data	Ds.l	1
	
Object_Xpos	Ds.w	1
Object_Depth	Ds.w	1
Object_Dwidth	Ds.w	1
Object_Index	Ds.w	1
Object_Reflect	Ds.b	1
Object_RMW	Ds.b	1
Object_Trans	Ds.b	1
		Even
Address_Of_CRYPixel		Ds.l	1
Object_Data_Read		Ds.l	4
Source_Gfx_X			Ds.w	1
Source_Gfx_Y			Ds.w	1

Objlist_To_Build_From		Ds.l	1
Base_Screen_Buffer		Ds.l	1
Width_Of_Screen			Ds.w	1
Height_Of_Screen_Dump		Ds.w	1
				Ds.b	16
Backup_Freeze_Objectlist	Ds.b	32
Backup_Freeze_Objectlistp	Ds.l	1
Freeze_Objectlist		Ds.b	32




**********************************************************
Move_Back_Panel
	Tst.b	End_Level(a4)
	Bne.s	.Checking
	Tst.w	Panel_X(a4)
	Beq.s	.Checking
	Subq.w	#2,Panel_X(a4)
	Subq.w	#2,Map_Display_Width(a4)
.Checking
	Rts

**********************************************************
Display_Sprites_In_Active_List
	Moveq	#0,d0
	Move.w	Number_Of_Sprites_In_Activelist(a4),d0
	Divu	#10,d0
	Move.w	d0,d2
	Swap	d0
	Move.w	d0,-(sp)
	Move.w	#0,d0
	Move.w	#170,d1	
	Add.w	X_Offset_Into_Map(a4),d0
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_Gfx_Base(a4),a5
	Add.w	#112,d2			; Convert the ASCII into sprite number
	Bsr	Blit_A_Sprite
	Move.w	(sp)+,d2
	Move.w	#14,d0
	Move.w	#170,d1	
	Add.w	X_Offset_Into_Map(a4),d0
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_Gfx_Base(a4),a5
	Add.w	#112,d2			; Convert the ASCII into sprite number
	Bsr	Blit_A_Sprite
.Noon	Rts
	
**********************************************************
Cheat_Mode
	Tst.b	Cheat_Mode_Active
	Bne.s	.Not_Cheat
	Cmp.b	#1,This_Level(a4)
	Bne.s	.Not_Cheat
	Tst.w	Num_Guardians_Active(a4)
	Beq.s	.Not_Cheat	
	Move.l	Joycur,d0
	Bsr.s	.Check_Cheat
	Move.l	Joycur+4,d0
.Check_Cheat
	Btst	#Key_1,d0
	Beq.s	.Not_Cheat
	Btst	#Key_4,d0
	Beq.s	.Not_Cheat
	Btst	#Key_7,d0
	Beq.s	.Not_Cheat

	Btst	#Key_3,d0
	Beq.s	.Not_Cheat
	Btst	#Key_6,d0
	Beq.s	.Not_Cheat
	Btst	#Key_9,d0
	Beq.s	.Not_Cheat
	Btst	#Option,d0
	Beq.s	.Not_Cheat
	St	Cheat_Mode_Active
	Lea	Powerup_SFX,a6
	Jsr	Play_This_Sample
.Not_Cheat
	Rts

**********************************************************
Level_Skip
	Rts
	Move.l	JoyCur,d0
	Lea	.Tab(pc),a6
	Moveq	#0,d1
	Moveq	#1,d2
.Loop	Move.b	(a6)+,d1
	Bmi.s	.Exit
	Btst	d1,d0
	Bne.s	.Hit
	Addq.b	#1,d2
	Bra.s	.Loop
.Exit	Rts
.Hit	Cmp.b	#9,d2
	Beq	Save_Scripts
	Move.b	d2,This_Level(a4)
	Move.l	#Main,(sp)
	Clr.l	Joycur
	Clr.l	Joycur+4
	Bra	Re_Initialize

.Tab	Dc.b	Key_1
	Dc.b	Key_2
	Dc.b	Key_3
	Dc.b	Key_4
	Dc.b	Key_5
	Dc.b	Key_6
	Dc.b	Key_7
	Dc.b	Key_8
	Dc.b	Key_9
	Dc.b	-1
	Even

Save_Scripts
	Not.b	Panel_Offon(a4)
	Rts



	Lea	Player_1_Script,a0
	Lea	Player_2_Script,a1
	Movem.l	Player_Script_Pointer(a4),a2-a3
	Addq.l	#4,a2
	Addq.l	#4,a3
	Move.l	#-1,(a2)
	Move.l	#-1,(a3)
	Addq.l	#4,a2
	Addq.l	#4,a3
	Sub.l	a0,a2
	Sub.l	a1,a3
	MOve.l	a2,d0
	MOve.l	a3,d1
	Illegal

**********************************************************
Check_Options_Pressed
	Bra	Cheat_Mode
	Tst.b	Options_Repeat(a4)
	Bne.s	.Options_Repeat
	Bsr	Options_Pressed
	Beq.s	.No_Pressed	
	St	Options_Repeat(a4)
	Not.b	No_Player_Collisions(a4)
.No_Pressed	
	Rts
.Options_Repeat
	Bsr	Options_Pressed
	Sne	Options_Repeat(a4)
	Rts

**********************************************************
Check_Both_Players_Active
	Move.b	Player_Active+Pl1,d0
	Move.b	Player_Active+Pl2,d1				; Active flags for both players
	And.b	d0,d1						; True if both set
	Move.b	d1,Both_Players_Active(a4)			; Store flag
	Rts

**********************************************************
Check_End_Level
	Tst.b	End_Level(a4)					; Check end level flag
	Beq.s	.Sprites_Still_Active				; Start processing end of level stuff
	Tst.w	Number_Of_Sprites_On_Screen(a4)		 	; Test number of sprites on screen, stuff on screen still ?
	Bgt.s	.Sprites_Still_Active				; Yes, dont do any end level stuff
	Tst.w	Continue_Delay(a4)				; Set it up
	Bne.s	.Sprites_Still_Active
	Tst.b	Game_Over_Delay(a4)
	Bgt.s	.Sprites_Still_Active
	Tst.b	Pl1+Num_Lives
	Beq.s	.One_Not_Active	
	Tst.b	Pl1+Dead_Count
	Bne.s	.Sprites_Still_Active
.One_Not_Active	
	Tst.b	Pl2+Num_Lives
	Beq.s	.Two_Not_Active	
	Tst.b	Pl2+Dead_Count
	Bne.s	.Sprites_Still_Active
.Two_Not_Active	
	Bra.s	.Check_Fits
.Sprites_Still_Active
	Rts
.Check_Fits
	Bsr	Check_Both_Players_Active			; Set flag if both active
	Tst.b	Both_Players_In_Place(a4)			; Test flag
	Beq.s	.No_Players_In_Place				; FALSE, 1 player active
	Jsr	Fadedown

	Tst.b	Fade_Direction(a4)
	Beq	Display_End_Of_Level_Screen
	Rts
.No_Players_In_Place	
	St	Fade_Direction(a4)				;
	St	Both_Players_In_Place(a4)			; TRUE, both in place

	Lea	Pl1,a3
	Bsr.s	.Do						; Check if player in place
	Move.w	d5,-(sp)					; Save flag that player 1 reached center
	Lea	Pl2,a3
	Bsr.s	.Do
	Move.w	(sp)+,d6					; Restore player 1 flag
	And.b	d5,d6						; Both together
	Bsr	.Down_Maps
	And.b	d6,Fade_Direction(a4)				;
	And.b	d6,Both_Players_In_Place(a4)			; TRUE, both in place
	Cmp.w	#Panel_Width,Panel_X(a4)
	Bne.s	.No_Set_Panel
	Rts
.No_Set_Panel
	Tst.b	Fade_Direction(a4)
	Beq.s	.No_Place
	Sf	Fade_Direction(a4)				;
	Sf	Both_Players_In_Place(a4)			; TRUE, both in place
	Addq.w	#2,Panel_X(a4)
	Addq.w	#2,Map_Display_Width(a4)
.No_Place
	Rts
.Down_Maps
	Cmp.w	#(Byteswide/2)-(Playfield_Width/2),X_Offset_Into_Map(a4)
	Beq.s	.Okk
	Bgt.s	.Add
	Addq.w	#2,X_Offset_Into_Map(a4)
.Add	Subq.w	#1,X_Offset_Into_Map(a4)
	Sf	Both_Players_In_Place(a4)
	Sf	Fade_Direction(a4)
.Okk	Rts

.Do	Moveq	#-1,d5
	Tst_Act
	Tst_Startup
	St	No_Bombing(a4)
	St	No_Firing(a4)			
	St	No_Move(a3)
	And.l	#$fffefffe,Shipxy(a3)	
	Movem.w	Shipxy(a3),d0-d1
	Move.w	#((Playfield_Width/2)&$fffffe)+30,d6			; Middle !
	Tst.b	Both_Players_Active(a4)
	Beq.s	.Player1
	Move.w	#((Playfield_Width/2)&$fffffe)+10,d6			; Left !
	Cmp.l	#Pl1,a3
	Beq.s	.Player1	
	Move.w	#((Playfield_Width/2)&$fffffe)+60,d6			; Right !
.Player1
;-----
;	Move.w	#(Screen_Height-40)&$fffe,d7
	Move.w	Height_Of_Screen(a4),d7
	Sub.w	#40,d7
	And.w	#$fffe,d7
;-----
	Cmp.w	d6,d0
	Beq.s	.X_Ok
	Bge.s	.Subx
	Addq.w	#4,d0
.Subx	Subq.w	#2,d0
	Sf	d5
.X_Ok	Cmp.w	d7,d1
	Beq.s	.Y_Ok
	Bge.s	.Suby
	Addq.w	#4,d1
.Suby	Subq.w	#2,d1
	Sf	d5
.Y_Ok	Movem.w	d0-d1,Shipxy(a3)
	Rts

**********************************************************
Display_End_Of_Level_Screen
	Jsr	Wait_Main_Vbl			; Syncronize with a timed source!
	Bsr	Setup_Mainloop_Vars		
	Bsr	Old_VBL_STUFF
	Jsr	Wait_For_Vblank_And_Swapscreens	; Careful you swap at the write time 

	Lea	Interm_Mod_Name,a0
	Trap	#15
	Move.l	a1,Base_Mod_Address(a4)
	Move.b	This_Level(a4),This_Level_Bonus(a4)
	Lea	End_Screen_Pal,a0
	Lea	Mypal-2,a1
	Sf	Copy_The_Pallete(a4)
	Trap	#15
	Lea	Mypal,a0
	Lea	Destpal,a1
	Move.l	#(256-32)*2,d0
	Jsr	Copy_Bytes
	Bsr	Get_Bonus_Scores
	Sf	Bonus_Sequence_Done(a4)
	Clr.b	Bonus_Sequence_Out_Delay(a4)
	Move.b	#100,Bonus_Sequence_Dec(a4)
	Sf	Bonus_Score_Dec(a4)
	Clr.w	-(sp)

	Jsr	Stop_Mod
	Move.l	Base_Mod_Address(a4),a0
	Jsr	Pt_Mod_Init
	Jsr	NoFade
	Jsr	Start_Mod
	Clr.w	Interm_Mod_Delay(a4)
	St	Flag_To_Kill_Interm_Mod(a4)	

.Main	
	Jsr	Wait_Main_Vbl			; Syncronize with a timed source!
	Tst.w	(sp)
	Beq.s	.No_Cycle
	Move.b	This_Level(a4),-(sp)
	Clr.b	This_Level(a4)
	Bsr	Level_Pallete_Stuff		; Cycle / pulses etc
	Move.b	(sp)+,This_Level(a4)
.No_Cycle
	Bsr	Setup_Mainloop_Vars		
	Bsr	Old_VBL_STUFF
	Bsr	Display_Bonus_Panel
	Bsr	Add_Bonus
	Jsr	Check_For_Bonus_Life
	Bsr	Swapscreens			
	Tst.w	(sp)
	Bne.s	.Set
	St	(sp)
	St	Copy_The_Pallete(a4)
.Set	Tst.b	Bonus_Sequence_Done(a4)
	Beq.s	.Main
	Tst.b	Flag_To_Kill_Interm_Mod(a4)	
	Bne.s	.Main

	Addq.l	#2,sp
	St	Old_Vbl_On_Vbl(a4)
	Cmp.b	#Max_Level,This_Level(a4)
	Beq.s	.Done_Game	
	Addq.b	#1,This_Level(a4)
	Move.l	#Main,(sp)
	Bra	Re_Initialize				
.Done_Game	
	Addq.b	#1,Times_Through(a4)
	Addq.w	#2,Difficuly(a4)
	Cmp.w	#4,Difficuly(a4)
	Ble.s	.Skip
	Move.w	#4,Difficuly(a4)
.Skip	St	Completed_Raiden(a4)
	Move.b	#1,This_Level(a4)
	Move.l	#Main,(sp)
	Bra	Re_Initialize				

**********************************************************
Add_Bonus
	Tst.b	Bonus_Sequence_Out_Delay(a4)
	Beq.s	.Notdo
	Subq.b	#1,Bonus_Sequence_Out_Delay(a4)
	Sle	Bonus_Sequence_Done(a4)
	Rts

.Notdo	Tst.b	Bonus_Sequence_Dec(a4)
	Beq.s	.Subtract_Scores
	Subq.b	#1,Bonus_Sequence_Dec(a4)
	Rts

.Subtract_Scores
	Subq.b	#1,Bonus_Score_Dec(a4)
	Bcc.s	.No_Reset	
	Move.b	#01,Bonus_Score_Dec(a4)
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
	Bsr.s	.Do
	Tst.l	Bonus_Score+Pl1
	Bne.s	.No_Reset
	Tst.l	Bonus_Score+Pl2
	Bne.s	.No_Reset
	Bra.s	.Done_Scoreing


.Do	Tst.b	Num_Lives(a3)
	Bne.s	.Ok_Alive
	Clr.l	Bonus_Score(a3)
	Rts
.Ok_Alive
	Tst.l	Bonus_Score(a3)
	Beq.s	.No_Reset
	Lea	.One_Thousand_Score+4(pc),a0
	Lea	Score+4(a3),a1
	Move	#0,CCR
	Abcd	-(a0),-(a1)
	Abcd	-(a0),-(a1)
	Abcd	-(a0),-(a1)
	Abcd	-(a0),-(a1)
	Lea	.One_Thousand_Score+4(pc),a0
	Lea	Bonus_Score+4(a3),a1
	Move	#0,CCR
	Sbcd	-(a0),-(a1)
	Sbcd	-(a0),-(a1)
	Sbcd	-(a0),-(a1)
	Sbcd	-(a0),-(a1)
	Lea	High_Score_Beep_Samp,a6
	Bsr	Play_This_Sample
.No_Reset	
	Rts

.Done_Scoreing
	Move.b	#100,Bonus_Sequence_Out_Delay(a4)
	Rts

.One_Thousand_Score
	Dc.l	$00001000


**********************************************************
;#########
Display_Bonus_Panel

	Move.w	#75,d0
	Move.w	#End_Level_GFX_Y-22,d1
	Move.w	#173,d2
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Pal_add_Center
	Bsr	Blit_A_Sprite

	Move.w	#75,d0
	Move.w	#End_Level_GFX_Y-22,d1
	Move.w	#173,d2
	Move.l	Player_Sprite_Base(a4),a3
	Lsl.w	#4,d2
	Add.w	Spr_Pixel_Width(a3,d2),d0
	Move.w	d0,-(sp)
	Add.w	#20,d0
	Move.w	#174,d2
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Pal_add_Center
	Bsr	Blit_A_Sprite
	
	Move.w	(sp)+,d0
	Move.w	#End_Level_GFX_Y-22,d1
	Moveq	#0,d2
	Move.b	This_Level_Bonus(a4),d2
	Subq.w	#1,d2
	Add.w	#89,d2
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Pal_add_Center
	Bsr	Blit_A_Sprite

	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Tst_Act
	Move.l	a3,Player_Use(a4)
	Bsr	Bonus_To_Ascii
	Tst.b	Both_Players_Active(a4)
	Bne.s	.Both_Players
	Move.w	#End_Level_GFX_Mid,d0
	Bra.s	.Not_Left
.Both_Players
	Move.w	#End_Level_GFX_Left,d0
	Cmp.l	#Pl1,a3
	Beq.s	.Not_Left
	Move.w	#End_Level_GFX_Right,d0
.Not_Left
	Move.w	#End_Level_GFX_Y,d1
	Move.w	#175,d2
	Movem.w	d0-d1,-(sp)
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Pal_add_Center
	Bsr	Blit_A_Sprite

	Movem.w	(sp),d0-d1
	Add.w	#End_Level_Bomb_X,d0
	Add.w	#End_Level_Bomb_Y,d1
	Move.l	Player_Use(a4),a3
	Moveq	#0,d2
	Move.b	Num_Bombs(a3),d2
	Add.w	#112,d2
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Pal_add_Center
	Bsr	Blit_A_Sprite

	Movem.w	(sp),d0-d1
	Add.w	#End_Level_Medal_X,d0
	Add.w	#End_Level_Medal_Y,d1
	Move.l	Player_Use(a4),a3
	Moveq	#0,d2
	Move.b	Medals_Got(a3),d2
	Cmp.b	#10,d2
	Blt.s	.No_Ten_Medals
	Sub.w	#12,d0
	Divu	#10,d2
	Add.w	#112,d2
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Move.w	d1,-(sp)
	Pal_add_Center
	Bsr	Blit_A_Sprite
	Move.w	(sp)+,d1
	Sub.w	X_Offset_Into_Map(a4),d0
	Swap	d2
	Add.w	#12,d0	
.No_Ten_Medals
	Add.w	#112,d2
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Pal_add_Center
	Bsr	Blit_A_Sprite

	Movem.w	(sp),d0-d1	
	Add.w	#End_Level_Score_X,d0
	Add.w	#End_Level_Score_y,d1
	Pal_add_Center

	Move.l	Player_Use(a4),a3
	Move.w	#8,-(sp)
	Lea	Bonus_Score_Ascii(a3),a0
	Sf	Leading_Zero(a4)
.Loop	Moveq	#0,d2
	Move.b	(a0)+,d2
	Sub.b	#"0",d2
	Bne.s	.Normal_Char
	Tst.b	Leading_Zero(a4)
	Beq.s	.Addx	
.Normal_Char
	St	Leading_Zero(a4)
	Add.w	#112,d2
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Bsr	Blit_A_Sprite
	Sub.w	X_Offset_Into_Map(a4),d0
.Addx	Add.w	#12,d0
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Tst.b	Leading_Zero(a4)
	Bne.s	.Ok
	Sub.w	#16,d0
	Move.w	#112,d2
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Bsr	Blit_A_Sprite
.Ok	Addq.l	#2,sp

	
	Move.l	Player_Use(a4),a3
	Moveq	#0,d2
	Move.b	Medals_Got(a3),d2
	Movem.w	(sp),d0-d1
	Add.w	#End_Level_Medal_X,d0
	Add.w	#End_Level_Medal_Y,d1
	Pal_add_Center
	Bsr.s	Quick_Point_Display
	Move.l	Player_Use(a4),a3
	Moveq	#0,d2
	Move.b	Num_Bombs(a3),d2
	Movem.w	(sp)+,d0-d1
	Add.w	#End_Level_Bomb_X,d0
	Add.w	#End_Level_Bomb_Y,d1
	Pal_add_Center
	Bsr.s	Quick_Point_Display
	Rts

Quick_Point_Display
	Ext.w	d2
	Subq.l	#8,sp
	Move.l	sp,a1
	Move.w	#"00",(a1)+
	Move.b	#"0",(a1)+
	Divu	#10,d2
	Add.b	#"0",d2
	Move.b	d2,(a1)+
	Swap	d2
	Add.b	#"0",d2
	Move.b	d2,(a1)+
	Move.b	#"0",(a1)+
	Move.w	#"00",(a1)+
	Move.l	sp,a0

	Move.w	#8,-(sp)
	Sf	Leading_Zero(a4)
.Loop	Moveq	#0,d2
	Move.b	(a0)+,d2
	Sub.b	#"0",d2
	Bne.s	.Normal_Char
	Tst.b	Leading_Zero(a4)
	Beq.s	.Addx	
.Normal_Char
	St	Leading_Zero(a4)
	Add.w	#112,d2
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Bsr	Blit_A_Sprite
	Sub.w	X_Offset_Into_Map(a4),d0
.Addx	Add.w	#12,d0
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Tst.b	Leading_Zero(a4)
	Bne.s	.Ok
	Sub.w	#16,d0
	Move.w	#112,d2
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Bsr	Blit_A_Sprite
.Ok	Addq.l	#2,sp
	Addq.l	#8,sp
	Rts

	
**********************************************************
Bonus_To_Ascii
	Lea	Bonus_Score(a3),a0
	Lea	Bonus_Score_Ascii(a3),a1
	Moveq	#4,d7
	Bra	Bcd_Ascii

**********************************************************
Get_Bonus_Scores
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Clr.l	Bonus_Score(a3)
	Tst_Act	
	Moveq	#0,d0
	Moveq	#0,d1
	Moveq	#0,d2
	Move.b	Num_Bombs(a3),d0
	Bne.s	.No_Mul1
	Moveq	#1,d0
.No_Mul1
	Move.b	Medals_Got(a3),d1
	Bne.s	.No_Mul2
	Moveq	#1,d1
.No_Mul2
	Mulu	d0,d1
	Subq.w	#1,d1
	Move.l	sp,a1
	Clr.l	-(sp)
.Loop	Lea	.Bonus1000+4(pc),a0
	Move.l	a1,a2
	Move	#0,CCR
	Abcd	-(a0),-(a2)
	Abcd	-(a0),-(a2)
	Abcd	-(a0),-(a2)
	Abcd	-(a0),-(a2)
	Dbra	d1,.Loop
	Move.l	(sp)+,Bonus_Score(a3)
	Rts

.Bonus1000
	Dc.l	$1000

**********************************************************
Weapons_To_Players
	Lea	Pl1,a3
	Lea	Pl2,a2
	Bsr.s	.Do
	Lea	Pl2,a3
	Lea	Pl1,a2

.Do	Tst_Act
	Tst.b	Player_Active(a2)
	Beq.s	.Not_Active
	Tst.b	Dead_Count(a2)
	Beq.s	.Continue_With_Checks
.Not_Active
	Rts
.Continue_With_Checks
	Movem.w	Shipxy(a2),d0-d1	
	Add.w	X_Offset_Into_Map(a4),d0	
	Move.w	d0,d2
	Move.w	d1,d3
	Addq.w	#8,d1
	Add.w	#24,d2
	Add.w	#24,d3

	Lea	Weapon_Active_List(a3),a1
.Weapon_Loop	
	Move.l	(a1)+,d4
	Bmi	.Exit
	Move.l	d4,a0
	Tst.b	(a0)
	Ble.s	.Weapon_Loop	
	Tst.b	Is_Weapon_A_Homing_Missle(a0)
	Bne.s	.Weapon_Loop	
	Tst.b	Is_Weapon_A_Rocket(a0)
	Bne.s	.Weapon_Loop	
	Movem.w	Wep_Box(a0),d4-d7
	Cmp.w	d2,d4
	Bgt.s	.Weapon_Loop
	Cmp.w	d0,d6
	Blt.s	.Weapon_Loop
	Cmp.w	d3,d5
  	Bgt.s	.Weapon_Loop
	Cmp.w	d1,d7
	Blt.s	.Weapon_Loop
	St	Is_Weapon_A_Homing_Missle(a0)
	St	Is_Weapon_A_Rocket(a0)
	Move.b	#6,(A0)				; Damage for bolt
	Clr.b	Wep_Sprite_Num(a0)
	Clr.b	Wep_Delay(a0)
	Move.b	#0,Wep_Anim(a0)
	Move.b	#24,Wep_Sprite(a0)
	Cmp.l	#Pl2,a2
	Beq.s	.Green
	Move.b	#35,Wep_Sprite(a0)
.Green
	Move.w	Seed(a4),d4
	Ror.w	#3,d4
	Eor.w	d4,Seed(a4)
	Mulu	#.Special_Shot_Direction_List_End-.Special_Shot_Direction_List,d4
	Swap	d4
	Moveq	#0,d5
	Cmp.l	#Pl1,a2
	Beq.s	.Ok_Its_Red
	Move.b	.Special_Shot_Direction_List1(pc,d4),d5
	Bra.s	.Skipo
.Ok_Its_Red
	Move.b	.Special_Shot_Direction_List(pc,d4),d5
.Skipo	Move.w	d5,Wep_Xv(a0)
	Move.w	#20,Wep_Yv(a0)
	Bra	.Weapon_Loop
.Exit	Rts


.Special_Shot_Direction_List
	Dc.b	$a0,$b0,$c0,$d0,$e0,$f0,$00,$10,$20,$30,$40,$50,$60
.Special_Shot_Direction_List_End


.Special_Shot_Direction_List1
	Dc.b	$d0,$00,$c0,$d0,$e0,$f0,$00,$10,$20,$30,$38,$20,$10
.Special_Shot_Direction_List_End1

	Even

**********************************************************
Sort_Out_Alien_Attributes
	Jsr	Wait_For_Gpu
	Lea	Attrib_Params,a0
	Move.l	#Aln_Activelist+Data,(a0)+
	Move.l	#Weapon_Check_Table+Data,(a0)+
	Move.l	#Player_Check_Table+Data,(a0)+
	Move.l	#Draw_Check_Table+Data,(a0)+
	Clr.w	(a0)+
	Move.w	Number_Of_Sprites_In_Activelist(a4),(a0)+
	Move.l	Enemy_Sprites_Base(a4),(a0)+
	Clr.w	(a0)+
	Move.w	X_Offset_Into_Map(a4),(a0)+
	Move.l	#Playfield_Width,(a0)+
	Move.l	#Alien_Offset_Check_Table,(a0)+
	Move.l	#Aln_Itsonscreen,(a0)+
	Move.l	#Aln_Sprite,(a0)+
	Move.l	#Enemy_Sprite_Offsets,(a0)+
	Move.l	#Aln_Weaponeffect,(a0)+
	Move.l	#Aln_KillPlayer,(a0)+
	MOve.l	#Aln_Hitoveride,(a0)+
	Move.l	#Aln_X_Offseted,(a0)+
	Move.l	#Alien_Boxes,(a0)+
	Clr.w	(a0)+
	Move.w	Height_Of_Screen(a4),(a0)+
	Lea	GET_ATTRIB_RISC,a0
	Jsr	Start_GPU
;	Jsr	Wait_For_Gpu
;	Move.l	Num_Objects_In_List,d7
;	Move.w	d7,Number_Of_Sprites_On_Screen(a4)
	Rts





Sort_Out_Alien_Attributes68k
	Clr.w	d6
	Lea	ALN_Activelist(a4),a6
	Lea	Weapon_Check_Table(a4),a1
	Lea	Player_Check_Table(a4),a2
	Lea	Draw_Check_Table(a4),a3	
	Move.w	Number_Of_Sprites_In_Activelist(a4),-(sp)
	Ble	.Last_In_List

	Move.l	Enemy_Sprites_Base(a4),a5
	Move.w	X_Offset_Into_Map(a4),d4
	Move.w	d4,d5
	Add.w	#Playfield_Width,d5
	Lea	Alien_Offset_Check_Table(pc),a4

.Loop	Move.l	(a6)+,a0				; Sprite address in a0
	Clr.b	Aln_Itsonscreen(a0)
	Move.w	Aln_X(a0),d0
	Move.w	Aln_Y(a0),d1
	Move.w	Aln_Sprite(a0),d7			; Get x/y and sprite
	Bmi	.Dec
	Tst.b	(a4,d7)
	Bne.s	.Offseted
	Lsl.w	#4,d7
	Bra.s	.Skip_Offset_Add
.Offseted
	Add.w	d7,d7
	Add.w	d7,d7
	Lea	Enemy_Sprite_Offsets,a4
	Add.w	(a4,d7),d0
	Add.w	2(a4,d7),d1
	Lea	Alien_Offset_Check_Table(pc),a4
	Add.w	d7,d7
	Add.w	d7,d7
.Skip_Offset_Add
	Add.w	SPR_YOffset(a5,d7),d1			; Add to base of y coardinate
	Move.w	d0,d2
	Move.w	d1,d3					; Save x and adjusrted y
	Add.w	SPR_Sheight(a5,d7),d3
	Blt.s	.Alien_Off_Screen
	Add.w	SPR_Pixel_Width(a5,d7),d2
	Cmp.w	d4,d2
	Blt.s	.Alien_Off_Screen			; Same for left hand screen bound
	Cmp.w	d5,d0
	Bge.s	.Alien_Off_Screen			; Right hand screen bound
;	Cmp.w	#Screen_Height,d1
	Cmp.w	Height_Of_Screen(a4),d1
	Bge.s	.Alien_Off_Screen			; and bottom of screen

.Coardkill_Active
	Tst.b	Aln_Weaponeffect(a0)
	Beq.s	.No_Weaponeffect
	Tst.b	Aln_Hitoveride(a0)
	Bne.s	.No_Weaponeffect
	Cmp.w	#10,d1
	Ble.s	.No_Weaponeffect
	Move.l	a0,(a1)+
.No_Weaponeffect
	Tst.b	Aln_Killplayer(a0)
	Beq.s	.No_Playereffect
	Move.l	a0,(a2)+
.No_Playereffect
	Tst.b	Aln_Weaponeffect(a0)
	Bne.s	.Make_Collision_Box
	Tst.b	Aln_Killplayer(a0)
	Beq.s	.No_Collision_Box
.Make_Collision_Box
	Lea	Alien_Boxes,a4
	Lsr.w	#1,d7
	Lea	(a4,d7),a4
	Move.w	d0,d2
	Move.w	d1,d3
	Move.w	d0,Aln_X_Offseted(a0)
	Move.w	d1,Aln_X_Offseted+2(a0)
	Add.w	(a4)+,d0
	Add.w	(a4)+,d1
	Add.w	(a4)+,d2
	Add.w	(a4)+,d3
	Lea	Alien_Offset_Check_Table(pc),a4
	Movem.w	d0-d3,Aln_Collision_Box(a0)
	Bra.s	.Add_Sprite_To_List
.No_Collision_Box
	Move.w	d0,Aln_X_Offseted(a0)
	Move.w	d1,Aln_X_Offseted+2(a0)
.Add_Sprite_To_List
	Move.l	a0,(a3)+	
	Addq.w	#1,d6
	Subq.w	#1,(sp)
	Bne	.Loop
	Bra.s	.Last_In_List
.Alien_Off_Screen
	St	Aln_Itsonscreen(a0)
.Dec	Subq.w	#1,(sp)
	Bne	.Loop

.Last_In_List
	St	(a1)
	St	(a2)
	St	4(a2)
	St	(a3)
	Lea	Data,a4
	Addq.l	#2,sp
	Move.w	d6,Number_Of_Sprites_On_Screen(a4)
	Rts

	Ds.w	1
Alien_Offset_Check_Table
	Ds.b	1520

**********************************************************
Level_Pallete_Stuff
	Tst.b	Direction_Of_Intens(a4)
	Beq.s	.Forward
	Subq.w	#4,Intens(a4)
	Cmp.w	#128,Intens(a4)
	Sne	Direction_Of_Intens(a4)
	Bra.s	.Skip_AddIntens
.Forward
	Cmp.w	#256,Intens(a4)
	Seq	Direction_Of_Intens(a4)
	Beq.s	.Skip_AddIntens
	Addq.w	#4,Intens(a4)
	Cmp.w	#256,Intens(a4)
	Seq	Direction_Of_Intens(a4)
.Skip_AddIntens
	Lea	Level_Color_Tables(pc),a6
	Moveq	#0,d0
	Move.b	This_Level(a4),d0
	Asl.w	#2,d0
	Move.l	-4(a6,d0),a6
	Not.b	Flash_Pal(a4)
	Lea	Mypal,a0
	Lea	CLUT+Hardware,a1
	Move.w	Intens(a4),d0
.Loop	Move.w	(a6)+,d1
	Bmi.s	.Done_Intensity			; Last colour, fuck off !
	Add.w	d1,d1				; Index *2
	Move.w	(a0,d1),d2			; Get original colour / Intensity
	Move.w	d2,d3				; Save it
	And.w	#$ff,d3				; Mask intensity
	Mulu	d0,d3
	Lsr.w	#8,d3				; Scale intensity
	Move.b	d3,d2				; Save intensity with HUE
	Move.w	d2,(a1,d1)			; Into clut table
	Bra.s	.Loop
.Done_Intensity
	Lea	Destpal,a1
.Loop1	Move.w	(A6)+,d0			; Colour number
	Bmi.s	.Done
	Move.w	d0,Cycle_Colour
	Add.w	d0,d0
	Lea	(a1,d0),a2
	Move.w	(a6)+,d1			; Number of colours
	Move.w	d1,Cycle_Number
	Bpl.s	.Forward_Cycle
.Backward_Cycle
	Neg.w	d1
	Move.w	d1,Cycle_Number
	Move.w	d1,d2
	Add.w	d2,d2
	Lea	(a2,d2),a2
	Move.l	a2,a3
	Move.w	-(a2),-(sp)
	Subq.w	#1,d1
.Bloop	MOve.w	-(a2),-(a3)
	Dbra	d1,.Bloop
	MOve.w	(sp)+,-(a3)
	Bsr	Copy_Colours_To_Clut
	Bra.s	.Loop1
.Forward_Cycle
	Subq.w	#2,d1
	Move.l	a2,a3
	Move.l	a4,a5
	Move.w	(a2)+,-(sp)
.Floop	
	Move.w	(a2)+,(a3)+
	Dbra	d1,.Floop
	Move.w	(sp)+,(a3)+
	Bsr	Copy_Colours_To_Clut
	Bra.s	.Loop1
.Done	
Flashing_Pal
	Lea	Destpal,a0
	Lea	Clut+Hardware,a1
	Tst.b	Flash_Pal(a4)
	Bne.s	.Low
	Move.w	#256,d0
	Bra.s	.Loop
.Low	Move.w	#240,d0

.Loop	Move.w	(a6)+,d1
	Bmi.s	.Done_Intensity			; Last colour, fuck off !
	Add.w	d1,d1				; Index *2
	Move.w	(a0,d1),d2			; Get original colour / Intensity
	Move.w	d2,d3				; Save it
	And.w	#$ff,d3				; Mask intensity
	Mulu	d0,d3
	Lsr.w	#8,d3				; Scale intensity
	Move.b	d3,d2				; Save intensity with HUE
	Move.w	d2,(a1,d1)			; Into clut table
	Bra.s	.Loop
.Done_Intensity
	Cmp.b	#8,This_Level(a4)
	Beq.s	.Wash_Level_8
	Cmp.b	#4,This_Level(a4)
	Beq.s	.Cehck_Lev4_Cycle_Stop
	Rts		

.Wash_Level_8
	Tst.b	Wash_Add(a4)
	Beq.s	.Add
	Subq.w	#1,Wash_Intensity(a4)
	Sne	Wash_Add(a4)
	Bra.s	.Washer
.Add	Addq.w	#1,Wash_Intensity(a4)
	Cmp.w	#63,Wash_Intensity(a4)
	Seq	Wash_Add(a4)
.Washer	Move.w	Wash_Intensity(a4),d0
	Move.l	Wash_Mem_Pointer(a4),a0
	Add.w	d0,d0
	lea	(a0,d0),a0
	Lea	Clut+Hardware+(208*2),a1
	Moveq	#15,d6
.Loopt	Move.w	(a0),(a1)+
	Lea	64*2(a0),a0
	Dbra	d6,.Loopt
	Rts

.Cehck_Lev4_Cycle_Stop
	Tst.b	Stop_Cycle4(a4)
	Beq.s	.No_Stop
	Lea	Mypal+200*2,a0
	Lea	Clut+Hardware+200*2,a1
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
.No_Stop
	Rts

Copy_Colours_To_Clut
	Lea	Destpal,a2
	Lea	Clut+Hardware,a3
	Move.w	Cycle_Colour,d6
	Move.w	Cycle_Number,d7
	Bpl.s	.Pos
	Neg.w	d7
.Pos	Add.w	d6,d6
	Lea	(a2,d6),a2
	Lea	(a3,d6),a3
.Loop	Move.w	(a2)+,(a3)+
	Subq.w	#1,d7
	Bne.s	.Loop
	Rts

Cycle_Colour	Dc.w	0
Cycle_Number	Dc.w	0

**********************************************************
Display_Pause
	Move.w	Added_Sprites_To_List(a4),d7
	Sub.w	d7,Num_Objects_To_Display+2(a4)
	Clr.w	Added_Sprites_To_List(a4)
	Bsr	Get_Object_To_Link_To

	Subq.b	#1,Pause_Display_Del(a4)
	Bpl.s	.No_Flip
	Move.b	#8,Pause_Display_Del(a4)
;	Not.b	Pause_Display_Flip(a4)
.No_Flip
	Tst.b	Pause_Display_Flip(a4)
	Bne.s	.No_Display_Pause
	Move.w	#Playfield_Width/2,d0
;---
;	Move.w	#Screen_Height/2,d1
	Move.w	Height_Of_Screen(a4),d1
	Lsr.w	#1,d1
;---

	Move.w	#280,d2				; 173 before !
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_Gfx_Base(a4),a5
	Move.w	d2,d4
	Lsl.w	#4,d4
	Move.w	Spr_Pixel_Width(a3,d4),d5
	Move.w	Spr_SHeight(a3,d4),d6
	Asr.w	#1,d5
	Asr.w	#1,d6
	Sub.w	d5,d0
	Sub.w	d6,d1
	Add.w	X_Offset_Into_Map(a4),d0
	Bsr	Add_A_Sprite
;	Move.w	#278,d2
;	Bsr	Add_A_Sprite				; VERSION!
.No_Display_Pause
	Move.l	Current_List_Pointer(a4),a0
	Bsr	Insert_Stop_Object
	Rts

**********************************************************
Old_VBL_STUFF
	Jsr	Wait_For_100			; Wait until ship has reached line 100 (startup)
	Jsr	Readjoysticks
	Bsr	Adj_Speed			; Adjust Left/Right/Up/Down vectors
	Jsr	Move_Ship			; Get new ship x/y Coardinates
	Jsr	Check_Ship_Bound		; Check screen coardinates of ship
	Bsr	Dead_Count_Dec			; Decrement delay for Pcollision on ship
	Jsr	Draw_Shadow_For_Players
	Jsr	Draw_Ship			; Draw ship to view screen
	Bsr	Score_Stuff			; Do some score stuff
	Rts

**********************************************************
Check_Coninue_Button
;	Tst.b	End_Level(a4)
;	Bne	.No_Fire_Player
	Cmp.w	#450,Continue_Delay(a4)
	Bge	.No_Fire_Player
;	Tst.b	No_Firing_Bombing_Or_Pausing(a4)
;	Bne	.No_Fire_Player
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
.Do	Tst.b	Num_Lives(a3)
	Bgt	.No_Fire_Player
	Move.l	Joycur,d0
	Cmp.l	#Pl1,a3
	Beq.s	.Pl1_Check
	Move.l	Joycur+4,d0
.Pl1_Check
	Btst	#Fire_A,d0
	Sne	d5
	Btst	#Fire_B,d0
	Sne	d6
	Btst	#Fire_C,d0
	Sne	d7
	Or.b	d5,d6
	Or.b	d6,d7
	Beq.s	.No_Fire_Player
	Tst.b	Num_Credits(a4)
	Beq.s	.No_Fire_Player
	Tst.b	Num_Creds(a3)
	Beq.s	.No_Fire_Player
	Subq.b	#1,Num_Creds(a3)
	Move.l	Score(a3),-(sp)
	Bsr	Setup_Player
	Move.l	(sp)+,Score(a3)
	Move.b	#5,Num_Lives(a3)
	St	Player_Active(a3)
	Subq.b	#1,Num_Credits(a4)
	Tst.w	Continue_Delay(a4)
	Beq.s	.No_Fire_Player
	Move.w	#0,Continue_Delay(a4)		; Set it up
	Tst.w	Guardian_Delay(a4)
	Ble.s	.Play_Normal_Mod
	Move.l	Base_Mod_Address(a4),-(sp)
	Move.l	Guardian_Mod_Address(a4),Base_Mod_Address(a4)
	Jsr	Startup_Raiden_Mod
	Move.l	(sp)+,Base_Mod_Address(a4)
	Rts
.Play_Normal_Mod
	Jsr	Startup_Raiden_Mod
.No_Fire_Player
	Rts

**********************************************************
Check_Continue
	Tst.b	Game_Over_Delay(a4)
	Bgt	.Game_Over
	Bsr	Check_Coninue_Button
	Lea	Pl1,a0
	Lea	Pl2,a1				; Pointers to bothj player structures
	Tst.b	Num_Lives(a0)
	Bne	.Not_Dead
	Tst.b	Num_Lives(a1)
	Bne	.Not_Dead			; If both lives are not zero, continue flag not up
;	Seq	No_Firing_Bombing_Or_Pausing(a4)
	Tst.b	Demo_Mode(a4)
	Beq.s	.Demo_Mode_Not_On
	Rts
.Demo_Mode_Not_On
	Tst.b	One_Player_Game(a4)
	Beq.s	.Two_Player_Game
	Tst.b	Red_player_Start(a4)
	Beq.s	.Blue_Player
	Tst.b	Num_Creds+Pl1
	Bne.s	.Two_Player_Game
	Move.b	Num_Creds+Pl2,d0
	Move.b	#0,Num_Creds+Pl2
	Sub.b	d0,Num_Credits(a4)
	Bra.s	.Two_Player_Game
.Blue_Player
	Tst.b	Num_Creds+Pl2
	Bne.s	.Two_Player_Game
	Move.b	Num_Creds+Pl1,d0
	Move.b	#0,Num_Creds+Pl1
	Sub.b	d0,Num_Credits(a4)
.Two_Player_Game
	Cmp.w	#(Byteswide/2)-(Playfield_Width/2),X_Offset_Into_Map(a4)
	Beq.s	.Okk
	Bgt.s	.Add
	Addq.w	#2,X_Offset_Into_Map(a4)
.Add	Subq.w	#1,X_Offset_Into_Map(a4)
.Okk	Tst.w	Continue_Delay(a4)
	Bne	.Countdown			; If countdown not set
	Move.w	#600,Continue_Delay(a4)		; Set it up
	Tst.b	Num_Credits(a4)
	Beq.s	.Countdown
	Move.l	Continue_Mod_Address(a4),a0
	Jsr	Stop_Mod
	Jsr	pt_mod_init		;setup song and player
	Jsr	nofade
	Jsr	start_mod		;its this what makes things go
.Countdown
	Subq.w	#2,Continue_Delay(a4)
	Beq	.Reached_Zero			; Game over if zero reached
	Cmp.w	#500,Continue_Delay(a4)
	Bge	.Not_Dead			; Do not display things for an initial 2 seconds
	Tst.b	Num_Credits(a4)
	Ble	.Game_Over			; Number of credits 0, quit anyway !
	Move.w	#Playfield_Width/2,d0		; Half the screen
	Move.w	#167,d2				; Sprite number for "CONINUE?"
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5
	Move.w	d2,d3
	Lsl.w	#4,d3
	Move.w	Spr_Pixel_Width(a3,d3),d4	; Get width of "continue"
	Move.w	Spr_Sheight(a3,d3),d5		; and height

;	Move.w	#Screen_Height/2,d1		; Middle of screen
	Move.w	Height_Of_Screen(a4),d1
	Lsr.w	#1,d1

	Asr.w	#1,d5
	Sub.w	d5,d1				; Subtract half of height from middle of screen
	Move.w	d4,d5				; Save width of continue
	Asr.w	#1,d5
	Sub.w	d5,d0
	Add.w	X_Offset_Into_Map(a4),d0	; Setup X coardinate of "continue"
	Bsr	Blit_A_Sprite
	Add.w	d4,d0				; Add width to X
	Moveq	#0,d5
	Move.w	Continue_Delay(a4),d5
	Divu	#50,d5
	Addq.w	#1,d5				; Continue delay / Number of frames
	Clr.w	-(sp)
	Move.l	sp,a6				; Setup pointer to 2 bytes on stack
	Cmp.b	#10,d5
	Beq.s	.Count_Of_Ten			; If ten, then move vale "10" in !
	Move.b	#"0",(a6)+
	Add.b	#"0",d5
	Move.b	d5,(a6)+
	Bra.s	.Dispaly_Count			; Else lead with a zero
.Count_Of_Ten
	Move.b	#"1",(a6)+	
	Move.b	#"0",(a6)+	
.Dispaly_Count
	Move.l	sp,a6				; Setup pointer to 2 bytes on stack
	Move.w	#(Playfield_Width/2)-16,d0
	Add.w	X_Offset_Into_Map(a4),d0
	Rept	2
	Moveq	#0,d2
	Move.b	(a6)+,d2
	Sub.b	#"0",d2
	Add.w	#88,d2
;---
;	Move.w	#(Screen_Height/2)+30,d1		; Middle of screen
	Move.w	Height_Of_Screen(a4),d1
	Lsr.w	#1,d1
	Add.w	#30,d1
;---

	Bsr	Blit_A_Sprite
	Add.w	#16,d0
	Endr
	Addq.l	#2,sp
	Rts
.Not_Dead
	Rts



.Game_Over
.Reached_Zero
	Tst.b	Game_Over_Delay(a4)
	Bgt.s	.Already_Set
	Move.b	#120,Game_Over_Delay(a4)
	Push
	Jsr	Stop_Mod
	Move.l	Gameover_Modaddress(a4),a0
	Jsr	Stop_Mod
	Jsr	pt_mod_init		;setup song and player
	Jsr	nofade
	Jsr	start_mod		;its this what makes things go
	Pull
.Already_Set
	Move.w	#Playfield_Width/2,d0		; Half the screen
	Move.w	#172,d2				; Sprite number for "GAME OVER"
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5
	Move.w	d2,d3
	Lsl.w	#4,d3
	Move.w	Spr_Pixel_Width(a3,d3),d4	; Get width of "continue"
	Move.w	Spr_Sheight(a3,d3),d5		; and height
;-----
;	Move.w	#Screen_Height/2,d1		; Middle of screen
	Move.w	Height_Of_Screen(a4),d1
	Lsr.w	#1,d1
;-----

	Asr.w	#1,d5
	Sub.w	d5,d1				; Subtract half of height from middle of screen
	Move.w	d4,d5				; Save width of continue
	Asr.w	#1,d5
	Sub.w	d5,d0
	Add.w	X_Offset_Into_Map(a4),d0	; Setup X coardinate of "continue"
	Bsr	Blit_A_Sprite
	Subq.b	#1,Game_Over_Delay(a4)
	Beq.s	.Game_Over_Done
	Rts
.Game_Over_Done
	Move.l	#Re_Start,(sp)
	Rts

**********************************************************
Other_Map_To_Object
	Lea	Map_Info(a4),a5
	Cmp.w	#2,Num_Maps_Loaded(a4)
	Ble.s	.Normal	
	Tst.b	Paralax_Active(a4)
	Bne.s	.Ok_Display
	Rts
.Ok_Display
	Move.w	Paralax_Map_Number(a4),d0
	Mulu	#Map_Structure_End,d0
	Add.l	d0,a5
.Normal	Lea	Map_Structure_End(a5),a5
	Tst.b	No_Printing_top_Map(a4)
	Beq.s	Map_To_Object
	Rts
Base_Map_To_Object
	Lea	Map_Info(a4),a5
	Move.l	Current_List_Pointer(a4),a0
	Bsr	Map_To_Object
	Rts
Map_To_Object
	Move.l	Map_Line_Stack_Pointer(a5),a6
	Move.w	Map_Y_Offset(a5),-(sp)
	Eor.w	#$f,(sp)
	Neg.w	(sp)
	Tst.w	(a6)
	Beq.s	.One_Object
	Move.w	#0,d3
	Move.w	(a6)+,d6
.Loop1	Add.w	#16,d3
	Cmp.w	(a6)+,d6
	Blt.s	.Loop1
	Move.w	(sp),d1
	Move.w	#Byteswide/8,d4				; Data width
	Move.w	#(Playfield_Width/8)+2,d2			; Image width
	Add.w	Map_Display_Width(a4),d2

	Moveq	#3,d7
	Add.w	d3,(sp)
	Mulu	#Byteswide*16,d6
	Move.l	Base_Map_Element(a5),a1
	Add.l	d6,a1
	Moveq	#0,d6

	Moveq	#0,d0
	Move.w	X_Offset_Into_Map(a4),d0
	Moveq.l	#-8,d5
	And.l	d0,d5
	Add.l	d5,a1
	Sub.l	d5,d0
	Neg.l	d0
	Bsr	Make_A_Clipped_Object

	Subq.l	#2,a6
.One_Object
	Move.w	(sp),d1

	Move.w	#Byteswide/8,d4			; Data width
	Move.w	#(Playfield_Width/8)+2,d2	; Image width ??????? (dont know why i should add 2, but its early in the morning!)
	Add.w	Map_Display_Width(a4),d2

	Move.w	(sp),d3
	Neg.w	d3
;----
;	Add.w	#Screen_Height,d3
	Add.w	Height_Of_Screen(a4),d3
;----

	Ble.s	.Exit_Loop
	Moveq	#3,d7
	Move.w	(a6),d6
	Mulu	#Byteswide*16,d6
	Move.l	Base_Map_Element(a5),a1
	Add.l	d6,a1
	Moveq	#0,d6
	Moveq	#0,d0
	Move.w	X_Offset_Into_Map(a4),d0
	Moveq.l	#-8,d5
	And.l	d0,d5
	Add.l	d5,a1
	Sub.l	d5,d0
	Neg.l	d0
	Bsr	Make_A_Clipped_Object
.Exit_Loop
	Addq.l	#2,sp
	Move.l	a0,Current_List_Pointer(a4)
	Lea	Data,a4
	Rts

**********************************************************
Blit_A_Scaled_Sprite
; d0 - x
; d1 - y
; d2 - Sprite number

; a3 - Sprite table
; a5 - GFX data

; Registers corrupted
	Push
	Movem.w	d6-d7,-(sp)					hscale, vscale !
	Lsl.w	#4,d2
	Lea	(a3,d2),a3
	Move.l	Spr_Data(a3),a1
	Add.l	a5,a1
	Moveq	#0,d7
	Move.b	Spr_BitsPerPixel(a3),d7
	Move.w	Spr_Pixel_Width(a3),d2
	Moveq	#0,d6
	Move.b	.Pixel_Shift(pc,d7),d6
	Lsr.w	d6,d2
	Move.w	Spr_SHeight(a3),d3
	Subq.w	#1,d3
	Ble.s	.No_Spr
	Add.w	Spr_Yoffset(a3),d1
	Move.l	Current_List_Pointer(a4),a0
	Movem.w	(sp),d4-d5
	Bsr	Make_A_Scaled_Object
	Move.l	a0,Current_List_Pointer(a4)
.No_Spr	Movem.w	(sp)+,d4-d5
	Pull
	Rts

.Pixel_Shift
	Dc.b	6,5,4,3,2,1


**********************************************************
; d0 - x
; d1 - y
; d2 - Sprite number

; a3 - Sprite table
; a5 - GFX data

; Registers corrupted
Blit_A_Sprite
	Push
	Sub.w	X_Offset_Into_Map(a4),d0
	Lsl.w	#4,d2
	Lea	(a3,d2),a3
	Move.l	Spr_Data(a3),a1
	Add.l	a5,a1
	Moveq	#0,d7
	Move.b	Spr_BitsPerPixel(a3),d7
	Move.w	Spr_Pixel_Width(a3),d2
	Moveq	#0,d6
	Move.b	.Pixel_Shift(pc,d7),d6
	Lsr.w	d6,d2
	Move.w	Spr_SHeight(a3),d3
	Ble.s	.No_Spr
	Add.w	Spr_Yoffset(a3),d1
	Move.l	Current_List_Pointer(a4),a0
	Move.w	Spr_Palnum(a3),d6
	Bsr	Make_An_Object
	Move.l	a0,Current_List_Pointer(a4)
.No_Spr	Pull
	Rts

.Pixel_Shift
	Dc.b	6,5,4,3,2,1


**********************************************************
Blit_A_Non_Transparent_Sprite
	Push
	Sub.w	X_Offset_Into_Map(a4),d0
	Lsl.w	#4,d2
	Lea	(a3,d2),a3
	Move.l	Spr_Data(a3),a1
	Add.l	a5,a1
	Moveq	#0,d7
	Move.b	Spr_BitsPerPixel(a3),d7
	Move.w	Spr_Pixel_Width(a3),d2
	Lsr.w	#2,d2
	Move.w	Spr_SHeight(a3),d3
	Ble.s	.No_Spr
	Add.w	Spr_Yoffset(a3),d1
	Move.l	Current_List_Pointer(a4),a0
	Bsr	Make_A_NON_Trasnparent_Object
	Move.l	a0,Current_List_Pointer(a4)
.No_Spr	Pull
	Rts

**********************************************************
Insert_Stuff
	Bsr	Insert_Alien		
	Bsr	Insert_Crators
	Bsr	Insert_Explosion	
	Bsr	Insert_Power		
	Bsr	Insert_Bonus_Sprites
	Rts

**********************************************************
;Turrets left =20
;Turrets or cannons =21

Check_Lev3cannon
	Tst.l	Aln_Prevlink(a1)
	Ble.s	.Found
	Move.l	Aln_Prevlink(a1),a1
	Bra.s	Check_Lev3cannon
.Found	Move.l	a1,a5
	Addq.b	#1,Aln_Shite+20(a5)
	Tst.b	Aln_Shite+21(a5)
	Beq.s	.Turret
	Cmp.b	#5,Aln_Shite+20(a5)
	Bne	.Not_there
	Not.b	Aln_Shite+21(a5)
	Clr.b	Aln_Shite+20(a5)
	Move.l	a5,a0
	Move.w	#320,Aln_Dmg(a0)
	Move.w	#320/2,Aln_Half_Damage(a0)
	Moveq	#17,d0
.Loopy	Move.l	Aln_Link(a0),a0
	Dbra	d0,.Loopy
	Clr.w	Aln_Seqdec(a0)
	Move.l	#MadLev3_Seq,Aln_Seqp(a0)
	Rts

.Turret	Cmp.b	#8,Aln_Shite+20(a5)
	Bne	.Not_There
	Clr.b	Aln_Shite+20(a5)
	Not.b	Aln_Shite+21(a5)
	Move.l	a5,a0
	Move.l	a0,a1
	Move.l	Aln_X(a0),-(sp)
	Pea	(a1)
	Move.l	a5,a1
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Move.w	#113,Aln_Anmset(a1)
	Clr.w	Aln_Anim(a1)
	Move.l	Aln_Link(a1),a1
	Move.w	#114,Aln_Anmset(a1)
	Clr.w	Aln_Anim(a1)
	Move.l	(sp)+,a1
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Bsr	Void_It
	Move.l	Aln_Link(a1),a1
	Bsr	Void_It
	Move.l	Aln_Link(a1),a1
	Bsr	Void_It
	Move.l	Aln_Link(a1),a1
	Bsr	Void_It
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Moveq	#4,d0
	Moveq	#124,d1
	Lea	.Cannon_Fire_Table(pc),a2
	Pea	(a5)
.Loopx	
	Move.w	d1,d3
	Lsl.w	#2,d3
	Lea	Alien_Anim_Table,a5
	Move.l	(a5,d3),a5
	Move.w	2(a5),Aln_Sprite(a1)
	Move.w	d1,Aln_Anmset(a1)
	Addq.l	#1,d1
	Move.w	#36,Aln_Dmg(a1)
	Clr.w	Aln_Anim(a1)
	Move.w	(a2)+,Aln_Seqdec(a1)
	Move.w	#-1,Aln_Wave(a1)
	Move.l	#Cannon_Fodder_Fireseq,Aln_Seqp(a1)
	St	Aln_Pauseflag(a1)
	Move.l	Aln_Link(a1),a1
	Dbra	d0,.Loopx
	Move.l	(sp)+,a5
	Move.l	a5,a0
	Moveq	#10-1,d3
.Loopz	Move.l	Aln_Link(a0),a0
	Dbra	d3,.Loopz
	Lea	.Five_New_Cannons(pc),a5
	Moveq	#5-1,d3
.Loopa	Move.l	(a5)+,Aln_Childx(a0)
	Move.l	Aln_Link(a0),a0
	Dbra	d3,.Loopa
	Move.w	#405,Aln_Sprite_Save(a4)
	Lea	.Quadexplosion(pc),a2
	Moveq	#3,d7
.Xploop	Movem.w	(sp),d0-d1
	Add.w	(a2)+,d0
	Add.w	(a2)+,d1
	Add.w	#32,d0
	Add.w	#56,d1
	Movem.w	d0-d1,Aln_X_Save(a4)
	Bsr	Explosion64
	Dbra	d7,.Xploop
	Addq.l	#4,sp
.Not_There
	Rts	

.Cannon_Fire_Table
	Dc.w	0,30,60,30,0
.Quadexplosion
	Dc.w	0,-32,32,0,0,32,-32,0
.Five_New_Cannons
	Dc.w	12,60,26,64,44,64,62,64,76,60

**********************************************************
Score_Stuff
	Bsr	Add_Ten_Point_Accumalate
	Bsr	Check_For_Bonus_Life

	Ifeq	Atari_Wants
	Bsr	Append_Branch_Object
	Bsr	Display_Score_Headers
	Bsr	Display_Scores
	Bsr	Display_Bombs_And_Lives	
	Else
	Bsr	Display_Atari_Score_Panel
	Bsr	Panel_Anim_Script_Routine
	Endc
	Rts

**********************************************************
Check_For_Bonus_Life
	Lea	Pl1,a3
	Bsr.s	.DO
	Lea	Pl2,a3

.Do	Tst.b	Num_Lives(a3)
	Beq.s	.No_Lives	
	Move.l	Live_Add(a3),d0
	Move.l	Score(a3),d1
	Cmp.l	d0,d1
	Blt.s	.No_Lives
	Cmp.l	#$150000,d0
	Beq.s	.Four_Thousand	
	Lea	.Five_K+4(pc),a1
	Lea	Live_Add+4(a3),a2
	Move	#0,CCR
	Abcd	-(a1),-(a2)
	Abcd	-(a1),-(a2)
	Abcd	-(a1),-(a2)
	Abcd	-(a1),-(a2)
	Bra.s	.Up_Life
.Four_Thousand	
	Move.l	#$400000,Live_Add(a3)
.Up_Life
	Lea	Powerup_SFX,a6
	Jsr	Play_This_Sample
	Addq.b	#1,Num_Lives(a3)
	Cmp.b	#9,Num_Lives(a3)
	Ble.s	.No_Lives
	Move.b	#9,Num_Lives(a3)
.No_Lives	
	Rts

.Five_K
	Dc.l	$500000

**********************************************************
Panel_X_Modif	Equ	2

Panel_Anim_Script_Routine
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_Gfx_Base(a4),a5
	Lea	Pre_Generated_Player_Objects,a6
	Move.l	Current_List_Pointer(a4),a0
	Ifd	Lenny	
	Move.b	Panel_Light_Frame_Number(a4),d2
	Addq.b	#1,d2
	And.w	#$3,d2
	Move.b	d2,Panel_Light_Frame_Number(a4)
	Add.w	#179,d2
	Move.w	#41,d0
	Move.w	#35-3,d1
	Add.w	Panel_X(a4),d0
	Add.w	#Screen_Width-Panel_Width+Panel_X_Modif,d0
;	Bsr	Quick_Player_Blit
	Moveq	#0,d2
	Move.b	Panel_Light_Frame_Number(a4),d2
	Addq.b	#2,d2
	And.w	#$3,d2
	Add.w	#179,d2
	Move.w	#41,d0
	Move.w	#132-3,d1
	Add.w	Panel_X(a4),d0
	Add.w	#Screen_Width-Panel_Width+Panel_X_Modif,d0
;	Bsr	Quick_Player_Blit
	Move.l	a0,Current_List_Pointer(a4)
	Endc

.Repeat_Sequence
	Tst.b	Screen_Script_Repeat(a4)
	Beq.s	.No_Repeat
	Move.l	Screen_Location(a4),a0
	Cmp.b	#-1,(a0)
	Bne.s	.Valid
	Subq.b	#1,Screen_Script_Repeat(a4)
	Bne.s	.Keep_Repeating
	Addq.l	#1,a0
	Move.l	a0,Screen_Script_Pointer(a4)
	Bra.s	.No_Repeat
.Keep_Repeating
	Move.l	Repeat_Screen_Location(a4),a0	
.Valid	Moveq	#0,d2
	Move.b	(a0)+,d2
	Move.l	a0,Screen_Location(a4)
	Move.w	#32,d0
	Move.w	#113,d1
	Add.w	Panel_X(a4),d0
	Add.w	#Screen_Width-Panel_Width+Panel_X_Modif,d0
	Move.l	Current_List_Pointer(a4),a0
	Bsr	Quick_Player_Blit
	Move.l	a0,Current_List_Pointer(a4)
	Rts
.No_Repeat
	Move.l	Screen_Script_Pointer(a4),a0
	Move.b	(a0)+,d0
	Cmp.b	#-1,d0
	Bne.s	.Continue
	Move.l	#Screen_Script,Screen_Script_Pointer(a4)
	Bra.s	.No_Repeat
.Continue
	Move.b	d0,Screen_Script_Repeat(a4)
	Move.l	a0,Repeat_Screen_Location(a4)
	Move.l	a0,Screen_Location(a4)
	Bra.s	.Repeat_Sequence

Screen_Script
	Dc.b	120,192,-1
	Dc.b	6,183,184,185,186,-1
	Dc.b	2,187,188,189,190,-1
	Dc.b	30,191,-1
	Dc.b	2,183,184,185,186,-1
	Dc.b	-1
	Even

**********************************************************

Panelfuck	Equ	0

Pl1_Atari_Scorepanel_Y		Equ	40
Pl2_Atari_Scorepanel_Y		Equ	126
Atari_Bombicon_X		Equ	06-Panelfuck
Atari_Bombicon_Y		Equ	10
Atari_Shipicon_X		Equ	38-Panelfuck
Atari_Shipicon_Y		Equ	12
Atari_Score_X			Equ	04-Panelfuck
Atari_Score_Y			Equ	58

Display_Atari_Score_Panel
	Lea	Pre_Generated_Player_Objects,a6
	Move.l	Current_List_Pointer(a4),a0
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_Gfx_Base(a4),a5
	Move.w	Panel_X(a4),d0
	Add.w	#Screen_Width-Panel_Width,d0
	Move.w	#0,d1
	Move.w	#281,d2
	Movem.l	d0-d1,-(sp)
	Bsr	Quick_Player_Blit
	Movem.l	(sp),d0-d1
	Addq.w	#6,d0
	Add.w	#199,d1
	Move.w	#282,d2
	Bsr	Quick_Player_Blit
	Movem.l	(sp)+,d0-d1
	Tst.b	Ntsc_Flag(a4)
	Bne.s	.Ntsc_System
	Addq.w	#6,d0
	Add.w	#199+28,d1
	Move.w	#294,d2
	Bsr	Quick_Player_Blit
.Ntsc_System
	Lea	Pl1,a3
	Move.w	#Pl1_Atari_Scorepanel_Y,d1
	Bsr.s	.Do
	Lea	Pl2,a3	
	Move.w	#Pl2_Atari_Scorepanel_Y,d1
	Bsr.s	.Do
	Move.l	a0,Current_List_Pointer(a4)
	Rts

.Do	Move.l	a3,a2
	Move.w	d1,-(sp)
	Move.w	#Atari_Bombicon_X+Screen_Width-72-(Panel_Width-84)+Panel_X_Modif-4+26,d0
	Add.w	Panel_X(a4),d0
	Move.w	#Atari_Bombicon_Y+6,d1
	Add.w	(sp),d1
	Moveq	#0,d2
	Move.b	Num_Creds(a2),d2
	Add.w	#283,d2
	Bsr	Quick_Player_Blit
	
	Move.w	#Atari_Bombicon_X+Screen_Width-72-(Panel_Width-84)+Panel_X_Modif-4,d0
	Add.w	Panel_X(a4),d0
	Move.w	#Atari_Bombicon_Y,d1
	Add.w	(sp),d1
	Moveq	#55,d2
	Bsr	Quick_Player_Blit

	Move.w	#Atari_Bombicon_X+Screen_Width-72+6-(Panel_Width-84)+Panel_X_Modif-8,d0
	Add.w	Panel_X(a4),d0
	Move.w	#Atari_Bombicon_Y+24,d1
	Add.w	(sp),d1
	Moveq	#0,d2
	Move.b	Num_Bombs(a2),d2
	Add.w	#283,d2
	Subq.w	#2,d1
	Bsr	Quick_Player_Blit

	Move.w	#Atari_Shipicon_X+Screen_Width-72-07-(Panel_Width-84)+Panel_X_Modif+18,d0
	Add.w	Panel_X(a4),d0
	Move.w	#Atari_Shipicon_Y-2,d1
	Add.w	(sp),d1

	Move.w	Player_Sprite_To_Draw(a2),d2
	Tst.b	Num_Lives(a2)
	Bne.s	.Lives_Ok
	Moveq	#2,d2
	Cmp.l	#Pl1,a2
	Beq.s	.Lives_Ok
	Moveq	#126,d2
.Lives_Ok
	Bsr	Quick_Player_Blit

	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_Gfx_Base(a4),a5
	Move.w	#Atari_Shipicon_X+Screen_Width-72+7-(Panel_Width-84)+Panel_X_Modif+16-2,d0
	Add.w	Panel_X(a4),d0
	Move.w	#Atari_Shipicon_Y+30-4,d1
	Add.w	(sp),d1
	Moveq	#0,d2
	Move.b	Num_Lives(a2),d2
	Add.w	#283,d2
	Bsr	Quick_Player_Blit
	Move.l	a0,Current_List_Pointer(a4)

	Move.w	#Atari_Score_X+Screen_Width-72-(Panel_Width-84)+Panel_X_Modif-2,Text_X_Save(a4)
	MOve.w	Panel_X(a4),d0
	Add.w	d0,Text_X_Save(a4)
	Lea	Score(a2),a0
	Subq.l	#8,sp
	Move.l	sp,a1			; Make room on stack. and set a1 as destination for ascii
	Moveq	#4,d7			; 8 characters out please
	Bsr	BCD_Ascii		; Convert BCD to ascii
	Move.l	sp,a2			; Base
	Move.w	#8,-(sp)		; Count of 8 characters
	Sf	Leading_Zero(a4)
	Move.l	Current_List_Pointer(a4),a0
	Lea	Pre_Generated_Player_Objects,a6
.Loop	Move.w	Text_X_Save(a4),d0	
	Add.w	#10,Text_X_Save(a4)	; Get x position
	Move.w	#Atari_Score_Y,d1
	Add.w	10(sp),d1
	Moveq	#0,d2
	Move.b	(a2)+,d2
	Sub.b	#"0",d2
	Bne.s	.No_Zero	
	Tst.b	Leading_Zero(a4)
	Beq.s	.Dec
.No_Zero	
	St	Leading_Zero(a4)
	Add.w	#283,d2			; Convert the ASCII into sprite number
	Bsr	Quick_Player_Blit
.Dec	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Tst.b	Leading_Zero(a4)
	Bne.s	.Printed_Something
	Move.w	Text_X_Save(a4),d0	
	Subq.w	#8,d0
	Move.w	#Atari_Score_Y,d1
	Add.w	8(sp),d1
	Move.w	#283,d2			; Convert the ASCII into sprite number
	Bsr	Quick_Player_Blit
.Printed_Something
	Lea	10(sp),sp
	Rts


**********************************************************
Append_Branch_Object
	Move.l	Current_List_Pointer(a4),a0
	Movem.l	-16(a0),d0-d1	
	And.l	#%11111111111111111111100000000000,d0
	And.l	#%00000000111111111111111111111111,d1
	Move.l	a0,d7
	Addq.l	#8,d7
	Move.l	d7,Address_For_Branch(a4)
	Move.l	d7,d6
	Moveq	#11,d5
	Lsr.l	d5,d7
	Or.l	d7,d0
	Ror.l	d5,d6
	And.l	#$ff000000,d6
	Or.l	d6,d1
	Add.l	#16,Current_List_Pointer(a4)
	Addq.w	#1,Num_Objects_To_Display(a4)
	Movem.l	d0-d1,-16(a0)
	Rts

**********************************************************
End_Branch_Object
	Move.l	Address_For_Branch(a4),a0
	MOve.l	Current_List_Pointer(a4),a1	; Address for link
	Bsr	Insert_Branch_Object
	Rts
**********************************************************
Insert_Branch_Object
	Add.w	#(N_Vdb)/2,d0
	Add.w	d0,d0				; Ypos doubled
	Move.l	a1,d7				; Link address in a workable register
	Move.l	d7,d6
	Moveq	#11,d3
	Lsr.l	d3,d6				; Chop of 8 lower bits
	Move.l	d6,(a0)+			; Top long in
	Lsl.w	#3,d0				; Align ypos
	Or.b	#3,d0				; Branch object type 3
	Ror.w	#2,d1				; Condition code in bits 14-15
	Or.w	d1,d0				; Or together
	Moveq	#21,d3
	Lsl.l	d3,d7
	And.l	#$ff000000,d7
	Or.l	d7,d0				; Rest of link address
	Move.l	d0,(a0)+
	Rts

**********************************************************
Display_Score_Headers
	Move.l	Current_List_Pointer(a4),a0
	Move.l	Player_Sprite_Base(a4),a3
	Lea	Pre_Generated_Player_Objects,a6
	Move.w	#Scoreboard_Left,d0
	Move.w	#162,d2
	Move.w	#Score_BoardY,d1
	Add.w	#28,d0
	Bsr	Quick_Player_Blit
	Move.w	#Scoreboard_Mid+10,d0
	Move.w	#Score_BoardY,d1
	Move.w	#164,d2
	Bsr	Quick_Player_Blit
	Move.w	#Scoreboard_Right+28,d0
	Move.w	#Score_BoardY,d1
	Move.w	#161,d2			; Player 2 text
	Bsr	Quick_Player_Blit
	Move.l	a0,Current_List_Pointer(a4)
	Rts


**********************************************************
Check_For_Pause
	Tst.b	No_Firing_Bombing_Or_Pausing(a4)
	Beq.s	.Ok_I_Do
	Clr.b	Pause_Flag(a4)
	Clr.b	DSP_Halted(a4)
	Rts
.Ok_I_Do
	Tst.b	Pause_Flag(a4)
	Beq.s	.Skip_Pause
	Move.l	#Skip_Pause,(sp)
	Rts
.Skip_Pause
	Clr.b	One_Three_Repeat+Pl1
	Clr.b	One_Three_Repeat+Pl2
	Clr.b	Pause_Display_Flip(a4)
	Tst.b	DSP_HALTED(a4)
	beq.s	.Halt
	Clr.b	DSP_HALTED(a4)
	Jsr	RESUMEDSP
.Halt	Rts

**********************************************************
Build_Linked_Alien_Lists
	Jsr	Wait_For_Gpu
	Lea	Link_Params,a0
	Clr.w	(a0)+
	Move.w	Number_Of_Sprites_In_Activelist(a4),(a0)+
	Move.l	#Aln_Activelist+Data,(a0)+
	Move.l	#Aln_Its_A_Child,(a0)+
	MOve.l	#Aln_Childx,(a0)+
	Move.l	#Aln_Link,(a0)+
	Move.l	#Aln_PrevLink,(a0)+
	Move.l	#Aln_Anmset,(a0)+
	Move.l	#Aln_Rotnumber,(a0)+
	Lea	Build_Link_GPU,a0
	Jsr	Start_Gpu
;	Jsr	Wait_For_Gpu
	Rts

Build_Linked_Alien_Lists68k
	Move.w	Number_Of_Sprites_In_Activelist(a4),d7
	Subq.w	#1,d7
	Blt	.Exit
	Lea	Aln_Activelist(a4),a5
.Loop	Move.l	(a5)+,a0			; Get pointer to sprite
	Tst.b	Aln_Its_A_Child(a0)
	Bne.s	.Dec
	Tst.l	Aln_Link(a0)
	Ble.s	.Dec				; If no link, dont bother checking
	Tst.l	Aln_Prevlink(a0)
	Bgt.s	.Dec				; If no parent sprite, dont bother
	Movem.w	Aln_X(a0),d0-d1			; Base coardinates of parent sprite

.Link_Loop	
	Move.l	Aln_Link(a0),d2			; Link address in data register to flag CC
	Ble.s	.Dec				; No link, last sprite in list
	Move.l	d2,a0				; Link address in a useful register
	St	Aln_Its_A_Child(a0)
	Move.w	Aln_ChildX+2(a0),d3		; Get child x offsets
	Move.w	Aln_ChildX(a0),d2		; Get child x offsets
	Bpl.s	.Pos_Number
	Cmp.w	#$8000,d2
	Beq.s	.Special_Case			; If child x is $8000, then its something special !
.Pos_Number
	Add.w	d0,d2				
	Add.w	d1,d3				; Else add parents x/y to each sprite
.Back	Move.w	d2,Aln_X(a0)
	Move.w	d3,Aln_Y(a0)
	Bra.s	.Link_Loop
.Dec	Dbra	d7,.LOOP
.Exit	Rts

.Special_Case
	Cmp.w	#$8001,d3
	Bne.s	.Tank

.Boat	Move.l	Aln_Prevlink(a0),a3
	Move.w	Aln_Anmset(a3),d4
	Sub.w	#71,d4
	Add.w	d4,d4	
	Add.w	d4,d4	
	Move.w	d0,d2
	Move.w	d1,d3
	Add.w	.Boat_Offsets(pc,d4),d2
	Add.w	.Boat_Offsets+2(pc,d4),d3
	Bra.s	.Back


.Tank	Moveq	#0,d6
	Move.l	Aln_Prevlink(a0),a3
	Move.b	Aln_Rotnumber(a3),d6
	Add.w	d6,d6	
	Add.w	d6,d6	
	Move.w	d0,d2
	Move.w	d1,d3
	Add.w	Tank_Adj+$0(pc,d6),d2
	Add.w	Tank_Adj+$2(pc,d6),d3
	Bra.s	.Back

.Boat_Offsets
	Dc.w	-4,2
	Dc.w	1,-3
	Dc.w	-4,2
	Dc.w	2,-3

Tank_Adj
	Dc.w	+0,+0
	Dc.w	+1,+0
	Dc.w	+1,+1
	Dc.w	+1,+1
	Dc.w	+1,+2		;90
	Dc.w	+1,+2
	Dc.w	+1,+2
	Dc.w	+1,+2
	Dc.w	+0,+2		;180
	Dc.w	+0,+2
	Dc.w	+1,+2
	Dc.w	+1,+1
	Dc.w	+2,+1		;270
	Dc.w	+2,+1
	Dc.w	+1,+1
	Dc.w	0,0

**********************************************************
Disable_Ints
	Rts
;	Move.w	sr,Sr_Save(a4)
;	Move.w	#$2600,sr
;	Move.w	#$0,Int1+Hardware	
;	Rts

**********************************************************
Enable_Ints	
	Rts
	Move.w	Sr_Save(a4),sr
;	Moveq	#0,d0
;	Move.w	Int1+Hardware,d0
;	Lsl.w	#8,d0
;	Or.w	#1,d0
;	Move.w	#$909,Int1+Hardware
;	Rts

**********************************************************
Track_Sprites_To_Player
	Move.w	Number_Of_Sprites_In_Activelist(a4),-(sp) ; Number of sprites on stack
	Ble.s	Quit_Track
	Lea	Alien_Anim_Table,a3
	Lea	Aln_Activelist(a4),a5
Loop_Track
	Move.l	(a5)+,a0				; Pull in a sprite
	Move.b	Aln_Track_val(a0),d3			; Change graphic on track ?
	Beq.s	No_Track_Coards				; 0, no rotation method
	Subq.b	#1,d3
	Beq.s	Track_Coards
	Subq.b	#1,d3
	Beq.s	Angle_Track
	Subq.b	#1,d3
	Beq.s	Head_Track

No_Track_Coards
	Subq.w	#1,(sp)
	Bne.s	Loop_Track				; All sprites
Quit_Track
	Addq.l	#2,sp
	Rts

Head_Track
	Tst.w	(a0)
	Bgt.s	.Ok
	Rts
.Ok	Moveq	#0,d2
	Move.w	Aln_Shite(a0),d2			; Get angle of sprite
	Cmp.b	#$40,d2
	Bcc.s	.Not_Less40
	Moveq	#$40,d2
.Not_Less40
	Cmp.b	#$c0,d2
	Bcs.s	.Not_Lessc0
	Move.w	#$c0,d2
.Not_Lessc0
	Move.w	d2,Aln_Shite(a0)
	Move.w	Aln_Base_Sprite(a0),d3
	Sub.b	#$40,d2
	Addq.b	#8,d2					
	Divu	#16,d2
	Subq.w	#8,d2
	Neg.w	d2
	Move.w	d2,Aln_Shite+14(a0)
	Add.w	d3,d2
	Move.w	d2,Aln_Sprite(a0)
	Bra.s	No_Track_Coards

Angle_Track
	Move.w	Aln_Shite(a0),d2			; Get angle of sprite
	Addq.b	#8,d2					; Normalize a bit for a divide by 16
	Lsr.w	#4,d2					; Get value from 0-15 from 0-255
	Move.b	d2,Aln_Rotnumber(a0)			; Store this graphic adjustment
	Add.w	Aln_Base_Sprite(a0),d2			; Add base sprite to graphic number
	Move.w	d2,Aln_Sprite(a0)			; Finally store as the sprite number
	Bra.s	No_Track_Coards

Track_Coards
	Tst.b	Aln_Itsonscreen(a0)
	Bne.s	No_Track_Coards
.On_Screen
	Tst.b	Track_Del(a4)
	Bne.s	.Exit					; Global flag for track delay
	Move.w	Aln_X(a0),d0
	Move.w	Aln_Y(a0),d1
	Bsr	Get_Closest_Ship
	Bsr	Track_Routine
	And.w	#$f0,d7					; Angle only goes up/down in 16's
	Move.w	Aln_Shite+22(a0),d2			; Get current angle
	Cmp.w	d2,d7
	Beq.s	.Set_Sprite	
	Move.w	d7,d6					; Copy destination angle
	Add.b	#$80,d6					; Add half a circle
	Sub.b	d2,d6
	Sub.b	d2,d7
	Cmp.b	d6,d7
	Bcc.s	.Clockwise_Is_Greater	;		 If clockwise is greater=
	Add.b	#32,d2
.Clockwise_Is_Greater
	Sub.b	#16,d2
.Set_Sprite
	Move.w	d2,Aln_Shite+22(a0)			; Save calculated angle
	Addq.b	#8,d2
	Lsr.w	#4,d2
	Move.b	d2,Aln_Rotnumber(a0)
	Add.w	Aln_Base_Sprite(a0),d2
	Move.w	d2,Aln_Sprite(a0)
	Bra	No_Track_Coards
.Exit	Moveq	#0,d2
	Move.b	Aln_Rotnumber(a0),d2
	Add.w	Aln_Base_Sprite(a0),d2
	Move.w	d2,Aln_Sprite(a0)
	Bra	No_Track_Coards

**********************************************************
Home_Into_Bastards
	Lea	Home_Dir(a4),a6
	Lea	Wep_Anims,a5
	Move.l	Enemy_Sprites_Base(a4),a1
	Not.b	Even_Odd_Missles(a4)
	Beq.s	.Loop
	Addq.l	#4,a6
.Loop	Tst.b	(a6)
	Bmi	.End_Loop
	Move.l	(a6),a0		
	Addq.l	#8,a6
	Movem.w	Wep_X(a0),d0-d1
	Lea	Weapon_Check_Table(a4),a2
	Clr.l	-(sp)					; Address of sprite storage
	Move.w	#$7fff,d6				; Maximum distance
	
.Loopx	Tst.b	(a2)
	Bmi.s	.Done			
	Move.l	(a2)+,a3				; Pull in a sprite
	Movem.w	Aln_Collision_Box(a3),d2-d5		; Box collision
	Add.w	d4,d2
	Add.w	d5,d3
	Asr.w	#1,d2
	Asr.w	#1,d3					; Mean average of box (center of box)
	Add.w	d7,d3
	Sub.w	d0,d2
	Bpl.s	.Pos1					; Absolute difference in x
	Neg.w	d2			
.Pos1	Sub.w	d1,d3			
	Bpl.s	.Pos2
	Neg.w	d3					; Absolute difference in y
.Pos2	Add.w	d2,d3			
	Cmp.w	d6,d3			
	Bge.s	.Loopx			
	Move.w	d3,d6					; If distance of sprite is less than current distance
	Move.l	a3,(sp)					; save parameters
	Bra.s	.Loopx			

.Done	Cmp.w	#$7fff,d6				; Any sprites to home into ?
	Move.l	(sp)+,a3				; Note, this pull from stack dont affect 68K flags
	Beq	.Loop			
	Movem.w	Aln_X(a3),d2-d3				; Get coardinates of alien
	Pea	(a6)					; Need to save this register (gets corrupted!)
	Bsr	Track_Routine				; Angle returned in d7
	Move.l	(sp)+,a6
	Moveq	#0,d6
	Move.b	Wep_Sprite(a0),d6
	Sub.w	#17,d6					; Get home anim, for home-missle manauverability
	Move.b	.Manauv(pc,d6),d6			; Get maximum value you can step through the sine table
	Sub.b	9(a0),d7				; Current angle from destination angle
	Bpl.s	.Clock					; Clockwise rotation if >=
	Sub.b	d6,9(a0)			
	Bra	.Loop
.Clock	Add.b	d6,9(a0)			
	Bra	.Loop
.End_Loop
	Rts

.Manauv	Dc.b	3,5,6,8,9
	Even
***********************************************************
Seed_Rand
	Move.l	Object_list_Pointer(a4),a1		; This could be anything at this stage !
	Move.l	(10*32)+8(a1),d0				; Guarenteed JUNK!
	Swap	d0		
	Ror.w	#3,d0
	Add.w	d0,Seed(a4)				; Current random seed changed !
	Move.w	Seed(a4),d0
	Ror.w	#5,d0
	Move.w	d0,Seed(a4)
	Move.w	VC+Hardware,d0
	Ror.w	#3,d0
	Add.w	d0,Seed(a4)
	Rts
	
**********************************************************
;Type byte
;Pad byte
; X
; Y

;0-Shot
;1-Laser
;2-Rockets
;3-Homing missle
;4-Big Powerup
;5-Pig
;6-Medal
;7-Tree Fairy
;8-Bomb

Insert_Power
	Move.l	Power_Up_Posp(a4),a0
	St	(a0)
	Lea	Power_Up_Pos(a4),a0				; Kill last entry in list and setup pointer to table
.Loop	Tst.b	(a0)
	Bmi.s	.Quit						; Last powerup if -ve
	Bsr	Search_Free_Alien_Slot				; Find a space in the list
	Move.w	#$7fff,Aln_Dmg(a6)				; Maybe i dont haveto do this ? It works so fuck it
	Moveq	#0,d6
	Move.b	(a0),d6						; Get powerup numer
	Pea	.Loop(pc)					; Set return address ( for RTS!)
	Asl.w	#2,d6
	Jmp	.Tab(pc,d6)					; Jump to appropriate routine
.Tab	Jmp	POWERSHOT(PC)
	Jmp	POWERLAZR(PC)
	Jmp	POWERROCK(PC)					; JMP xxxxx(pc) is 4 bytes instruction
	Jmp	POWERHOME(PC)
	Jmp	POWERBIGY(PC)
	Jmp	POWERPIGY(PC)
	Jmp	POWERMEDL(PC)
	Jmp	POWERTREE(PC)
	Jmp	POWERBOMB(PC)
.Quit	Rts

POWERSHOT
	Addq.b	#1,Number_Of_Powerups_On_Screen(a4)
	Moveq	#3,d0
	Bra	Sine_In
POWERLAZR
	Addq.b	#1,Number_Of_Powerups_On_Screen(a4)
	Moveq	#4,d0
	Bra	Sine_In
POWERROCK
	Addq.b	#1,Number_Of_Powerups_On_Screen(a4)
	Moveq	#5,d0
	Bra	Sine_In
POWERHOME
	Addq.b	#1,Number_Of_Powerups_On_Screen(a4)
	Moveq	#6,d0
	Bra	Sine_In
POWERBIGY
	Addq.b	#1,Number_Of_Powerups_On_Screen(a4)
	Moveq	#38,d0
	Bra	Sine_In
	Nop

Sine_In	Move.w	d0,Aln_Anmset(a6)
	Movem.w	2(a0),d0-d1
	Sub.w	X_Offset_Into_Map(a4),d0
	Sub.w	#Playfield_Width/2,d0

;---
;	Sub.w	#(Screen_Height-20)/2,d1
	Move.l	d0,-(sp)
	Move.w	Height_Of_Screen(a4),d0
	Sub.w	#20,d0
	Asr.w	#1,d0
	Sub.w	d0,d1
	Movem.l	(sp)+,d0
;---

	Ext.l	d0
	Ext.l	d1
	Tst.l	d0
	Slt	d6			
	Bge.s	.Ok1
	Neg.l	d0	
.Ok1	Tst.l	d1
	Slt	d7			
	Bge.s	.Ok2
	Neg.l	d1
.Ok2	Cmp.w	d0,d1
	Sgt	d5
	Ble.s	.Ok3			
	Exg	d0,d1
.Ok3	Movem.w	d0-d1,-(sp)		
	Swap	d1
	Tst.w	d0			
	Bne.s	.OkDIV
	Moveq	#1,d0
.OkDIV	Divu	d0,d1			
	Moveq	#-1,d3
	Moveq	#1,d0	
	Moveq	#1,d2
	Tst.b	d5
	Bne.s	.NxB
	Exg	d0,d2
	Exg	d1,d3	
.NxB	Tst.b	d6
	Bne.s	.NxA
	Neg.w	d0			
.NxA	Tst.b	d7
	Bne.s	.Nxc
	Neg.w	d2			
.NxC	
	St	Aln_AnimFlipFlg(a6)
	Move.b	#Pow_Del,Aln_AnimFlipdel(a6)
	Move.w	#9,Aln_Wave(a6)	
	Move.l	2(a0),Aln_X(a6)
	Sub.w	#22,Aln_X(a6)
	Add.w	#6,Aln_Y(a6)

	Lea	Aln_Shite(a6),a5
	Clr.l	(a5)+			
	Move.w	d1,(a5)+
	Move.w	d3,(a5)+		
	Move.w	d0,(a5)+
	Move.w	d2,(a5)+		
	Movem.w	(sp)+,d0-d1
	Movem.w	2(a0),d2-d3
	Cmp.w	d0,d1
	Bge.s	.OkX
	Exg	d0,d1
.OkX	Move.w	d1,(a5)+		
	Clr.b	(a5)+
	Move.b	#2,(a5)+		
	Btst	#0,Number_Of_Powerups_On_Screen(a4)
	Beq.s	.Clockwise
	Neg.w	-2(a5)
.Clockwise
	Move.w	#40,(a5)+		!!!!-SCALE!
	Move.w	#500,Aln_Seqdec(a6)
	Move.l	#Powerup_Down_Seq,Aln_Seqp(a6)
.Dec	Addq.l	#6,a0
	Rts

POWERBOMB
	Move.w	#$7fff,Aln_Seqdec(a6)
	Move.w	#36,Aln_Anmset(a6)
	Move.w	#8,Aln_Wave(a6)
	Or.l	#$00010001,2(a0)
	Movem.w	2(a0),d0-d1
	Cmp.w	#-16,d1
	Bge.s	.Xrt
	Moveq	#-16,d1
.Xrt	
;	Cmp.w	#Screen_Height,d1
	Cmp.w	Height_Of_Screen(a4),d1
	Blt.s	.XLt
;	Move.w	#Screen_Height,d1
	Move.w	Height_Of_Screen(a4),d1
.Xlt	Moveq	#-3,d2
	Moveq	#-3,d3			
	Sub.w	X_Offset_Into_Map(a4),d0
	Cmp.w	#Playfield_Width/2,d0
	Bgt.s	.Okm
	Moveq	#3,d2
.Okm	
;	Cmp.w	#Screen_Height/2,d1
	Move.w	Height_Of_Screen(a4),d4
	Lsr.w	#1,d4
	Cmp.w	d4,d1
	Bgt.s	.Okm2
	Moveq	#3,d3
.Okm2	
	Movem.w	d0-d1,Aln_X(a6)
	Moveq	#0,d4
	Moveq	#0,d5
	Moveq	#8,d6
	Movem.w	d2-d6,Aln_Shite(a6)
	Addq.l	#6,a0
	Rts

POWERPIGY
	Moveq	#50,d0
	Bra.s	Powerup_Straight_Dopwn
POWERMEDL
	Moveq	#37,d0

Powerup_Straight_Dopwn
	Move.w	d0,Aln_Anmset(a6)
	Move.l	#1,Aln_Shite(a6)
	Move.l	2(a0),Aln_X(a6)
	Addq.w	#6,Aln_X(a6)
	Addq.w	#6,Aln_Y(a6)
	Move.l	#Branch_Seq_Power,Aln_Seqp(a6)
	Addq.l	#6,a0
	Rts	

POWERTREE
	Move.w	#43,Aln_Anmset(a6)
	Move.l	2(a0),Aln_X(a6)
	Move.l	#Angel_Seq,Aln_Seqp(a6)
	Addq.l	#6,a0
	Rts

**********************************************************

Kill_Aliens_If_Bomb
	Tst.b	Bomb_Active(a4)
	Beq	.Exit
	Move.w	Bomb_Explosion_Sprite_Num(a4),d2
	Cmp.w	#247,d2
	Beq.s	.Ok_To_Try_And_Kill
	Cmp.w	#248,d2
	Beq.s	.Ok_To_Try_And_Kill
	Cmp.w	#249,d2
	Beq.s	.Ok_To_Try_And_Kill
	Rts
.Ok_To_Try_And_Kill
	Tst.b	Bomb_Kill_Count(a4)
	Ble.s	.Kill_Em
	Subq.b	#1,Bomb_Kill_Count(a4)
	Rts
.Kill_Em
	Move.b	#Bomb_Kill_Delay,Bomb_Kill_Count(a4)
	Move.l	#Pl1,Player_Use(a4)
	Cmp.b	#1,Player_That_Bombed(a4)
	Bne.s	.No_Player1
	Move.l	#Pl2,Player_Use(a4)
.No_Player1
	Moveq	#55,d4
	Movem.w	Bomb_Struct(a4),d0-d1
	Movem.w	Bomb_Struct(a4),d2-d3

	Sub.w	d4,d0
	Sub.w	d4,d1
	Add.w	d4,d2
	Add.w	d4,d3
	Movem.w	d0-d3,Bomb_Box(a4)
	Lea	Aln_Activelist(a4),a5
.Back	Lea	Bomb_Kill_Table,a3
.Loop	Tst.b	(a5)
	Bmi	.Exit
	Move.l	(a5)+,a0
	Tst.w	Aln_Dmg(a0)		; Test hit points, dec !
	Ble.s	.Loop
	Move.w	Aln_Sprite(a0),d0
	Lea	Bomb_Kill_Table,a3
	Tst.b	(a3,d0)
	Beq.s	.Loop
	Tst.b	Aln_Hitoveride(a0)
	Bne.s	.Loop
	Movem.w	Aln_Collision_Box(a0),d4-d7
	Movem.w	Bomb_Box(a4),d0-d3
	Cmp.w	d2,d4
	Bge.s	.Loop
	Cmp.w	d3,d5
	Bge.s	.Loop
	Cmp.w	d6,d0
	Bge.s	.Loop
	Cmp.w	d7,d1
	Bge.s	.Loop
	Pea	(a5)
	Move.l	Aln_X(a0),Aln_X_Save(a4)
	Move.w	#-1,Aln_Sprite_Save(a4)
	Move.l	a0,a1
	Tst.b	Aln_Hit(a1)
	Bne.s	.Hit_Already
	St	Aln_Hit(a1)
	Pea	(a5)
	Pea	(a1)
	Lea	Sprite_Child_Parent_HitDMG_Table,a5
	Move.w	Aln_Sprite(a1),d1
	Add.w	d1,d1
	Move.b	(a5,d1),d0				; Previous count in d0
	Beq.s	.No_Previous2
.Prev_Loop2
	Move.l	Aln_Prevlink(a1),a1
	St	Aln_Hit(a1)
	Subq.b	#1,d0
	Bne.s	.Prev_Loop2
.No_Previous2
	Move.b	1(a5,d1),d0				; After count in d0
	Beq.s	.No_Next2
	Move.l	(sp),a1
.Next_Loop2
	Move.l	Aln_Link(a1),a1
	St	Aln_Hit(a1)
	Subq.b	#1,d0
	Bne.s	.Next_Loop2
.No_Next2
	Move.l	(sp)+,a1
	Move.l	(sp)+,a5

.Hit_Already
	Bsr	Search_Prev_Link
	Subq.w	#5,Aln_Half_Damage(a1)
	Bcc.s	.No_DMG
	Movem.l	d0/d5/a1/a5,-(sp)
.Link_Loop
	Lea	Sprite_Child_Parent_HitDMG_Table,a5
	Move.w	Aln_Sprite(a1),d5
	Add.w	d5,d5
	Move.b	(a5,d5),d0				; Previous count in d0
	Beq.s	.No_Previous
.Prev_Loop
	Move.l	Aln_Prevlink(a1),a1
	St	Aln_Half_Damage(a1)
	Subq.b	#1,d0
	Bne.s	.Prev_Loop
.No_Previous
	Move.b	1(a5,d5),d0				; After count in d0
	Beq.s	.No_Next
	Move.l	8(sp),a1
.Next_Loop
	Move.l	Aln_Link(a1),a1
	St	Aln_Half_Damage(a1)
	Subq.b	#1,d0
	Bne.s	.Next_Loop
.No_Next
	Movem.l	(sp)+,d0/d5/a1/a5
.No_DMG
	Subq.w	#5,Aln_Dmg(a1)
	Bgt.s	.Dec
	Bsr	Add_Score_For_Alien
	Bsr	Process_Dead_Alien
	Move.l	(sp)+,a5
	Bra	.Back
.Dec	Move.l	Player_Use(a4),a3
	Addq.w	#1,Ten_Point_Accumolate(a3)
	Move.l	(sp)+,a5
	Bra	.Back
.Exit	Move.l	Explosion_Tabp(a4),a0
	St	(a0)
	Move.l	Crator_Tabp(a4),a0
	St	(a0)
	Rts
 
**********************************************************
Check_Paralax_Event			
	Tst.b	Paralax_Event_Flag(a4)
	Bne.s	.Ok
	Rts
.Ok	St	Checking_A_Paralax_Event(a4)
	Clr.b	Paralax_Event_Flag(a4)
	Move.l	Event_Tablep(a4),-(sp)
	Move.l	Paralax_Data_Pointer(a4),-(sp)
	Addq.l	#4,Paralax_Event_Pointer(a4)
	Move.l	Paralax_Event_Pointer(a4),Event_Tablep(a4)
	Bsr.s	Skip_Event_Checkup
	Move.l	(sp)+,Paralax_Data_Pointer(a4)
	Move.l	(sp)+,Event_Tablep(a4)
	Rts
Check_Event
	Sf	Checking_A_Paralax_Event(a4)
	Tst.b	Make_Event(a4)		
	Beq.s	.No_Event
	Tst.b	End_Level(a4)
	Bne.s	.No_Event
	Sf	Make_Event(a4)		
	Bra.s	Skip_Event_Checkup
.No_Event
	Rts

Skip_Event_Checkup
	Cmp.w	#2,Num_Maps_Loaded(a4)
	Ble.s	.No_Paralax	
	Move.l	Paralax_Data_Pointer(a4),a0
	Addq.l	#1,Paralax_Data_Pointer(a4)
	Tst.b	(a0)+
	Beq.s	.No_Paralax
	St	Paralax_Active(a4)
.No_Paralax
	Move.l	Event_Tablep(a4),a0				; Pointer into current event table offset
	Tst.l	(a0)
	Beq	.No_Event					; line 0, then no sprites
	Move.l	(a0),d0
	Bpl.s	.Pos
	Tst.b	Checking_A_Paralax_Event(a4)
	Beq.s	.Normal_Check					; If ya checking a paralax event and code was -ive, next paralax map
	Move.l	#Paralax_Event_Table2,Paralax_Event_Pointer(a4) ; Pointer !
	Bra	.No_Event
.Normal_Check
	Cmp.l	#-1,d0		
	Seq	End_Level(a4)
	Seq	Flag_To_Stop_Scrolling(a4)
	Beq	.No_Event					; If -1, flag end_level, no more checking
	Cmp.l	#-2,d0
	Bne.s	.No_No
	Move.l	#$ff,Bord1+Hardware
	Rts
.No_No
	Cmp.l	#-3,d0
	Seq	No_Firing_Bombing_Or_Pausing(a4)
	Beq	.No_Event					; If -3, Turn of fire button,pause and bomb checks
	Cmp.l	#-4,d0
	Seq	No_Printing_top_Map(a4)
	Beq	.No_Event					; If -4, Turn of printing of mask map
	Cmp.l	#-5,d0
	Sne	No_Printing_top_Map(a4)
	Beq	.No_Event					; If -4, Turn of printing of mask map
	Illegal
.Pos	
	Ifnd	Feedevents
	Rts
	Endc
	Move.l	d0,a0						; Move Data into address for stuff
.Loop	Tst.w	(a0)			
	Bmi.s	.No_Event					; Last sprite in list, no more checking
	Bsr	Fill_Entry					; Allocate the sprite into active list
	Pea	(a0)						; Save pointer into sprite list to insert
	Bsr	Get_Sprite_Track_Power
	Bsr	Check_For_A_Link
	Move.l	(sp)+,a0
	Bra.s	.Loop
.No_Event
	Rts

Get_Sprite_Track_Power
	Move.w	Aln_Anmset(a6),d0				; Get anim table number
	Lea	Alien_Track_Numbers,a2
	Move.b	(a2,d0),Aln_Track_Val(a6)
	Lea	Alien_Power_Numbers,a2
	Tst.b	(a2,d0)
	Beq.s	.Exit
	Move.l	Power_Up_Event_Table_Pointer(a4),a3
	Move.b	(a3)+,Aln_POWNUM(a6)
	Cmp.b	#9,Aln_POWNUM(a6)
	Bne.s	.Not_Random_Medal_Or_Pig	
	Move.w	Seed(a4),d6
	Mulu	#10,d6
	Swap	d6
	Move.b	#6,Aln_POWNUM(a6)
	Tst.w	d6
	Bne.s	.Not_Random_Medal_Or_Pig	
	Move.b	#5,Aln_POWNUM(a6)
.Not_Random_Medal_Or_Pig	
	Move.l	a3,Power_Up_Event_Table_Pointer(a4)
.Exit	Rts

Check_For_A_Link
	Move.w	Aln_Anmset(a6),d0				; Get anim table number
	Lea	Link_Offsets,a1				; Table of base offsets for base sprites
	Add.w	d0,d0
	Add.w	d0,d0
	Move.l	(a1,d0),d0
	Beq.s	.No_Linking					; 0, no child sprites !
	Move.l	d0,a0						; a0 points to list of sprites to insert (act as childs)
	Move.l	(a0)+,a3					; Base offsets for child x/y modifiers !
.Loop	Move.l	a6,a1						; Save pointer to previous sprite
	Bsr	Fill_Entry					; Allocate sprite
	Move.l	(a3)+,Aln_ChildX(a6)				; Save offsets from parent sprite
	Bsr	Get_Sprite_Track_Power
	Move.l	a6,Aln_Link(a1)					; save pointer to this sprite (from previous sprite)
	Move.l	a1,Aln_Prevlink(a6)				; Save pointer to previous sprite
	Tst.w	(a0)						; Pointer to hp, test, if >0, another sprite !
	Bgt.s	.Loop
.No_Linking
	St	Aln_Link(a6)
	Rts

**********************************************************
Fill_Entry
	Bsr	Search_Free_Alien_Slot  		; Find a free slot in the list
	Move.w	(a0)+,d3				; Get number of hit points
	Move.w	d3,Aln_Dmg(a6)				; Save into damage
	Asr.w	#1,d3
	Move.w	d3,Aln_Half_Damage(a6)			; /2 for half damage
	Move.w	(a0)+,Aln_Anmset(a6)			; Animation table
	Move.l	(a0)+,Aln_X(a6)				; Coardinates
	Move.l	(a0)+,Aln_Seqp(a6)			; Sequnce pointer
	Rts

**********************************************************
; Returns angle in d2!

Get_Angle_From_Alien_To_Ship
	Bsr	Get_Closest_Ship
	Bsr	Track_Routine
	Move.w	d7,d2
	Rts

**********************************************************
Check_Weapon_Is_On_Screen
	Cmp.w	#-16,d1
	Blt.s	.Exit_Weapon
;	Cmp.w	#Screen_Height,d1
	Cmp.w	Height_Of_Screen(a4),d1
	Bge.s	.Exit_Weapon
	Cmp.w	Right_Hand_Screenxbound(a4),d0
	Bge.s	.Exit_Weapon
	Move.w	X_Offset_Into_Map(a4),d6
	Sub.w	#16,d6
	Cmp.w	d6,d0
	Ble.s	.Exit_Weapon
	Rts
.Exit_Weapon
	Lea	Dummy_Sprite,a6
	Addq.l	#4,sp
	Rts

**********************************************************
; X/Y in d0/d1
; Angle in d2
; Scale in d3
; Initial Scale in d4
; Weapon animset in d5

Insert_Weapon_If_Above_Screen
;	Cmp.w	#Screen_Height,d1
	Cmp.w	Height_Of_Screen(a4),d1
	Blt.s	Insert_Weapon_No_Screen_Check
	Rts
Insert_Weapon
	Bsr.s	Check_Weapon_Is_On_Screen
Insert_Weapon_No_Screen_Check
	Bsr	Search_Free_Alien_Slot	
	Move.w	#$1,Aln_Dmg(a6)
	Move.w	#2,Aln_Seqdec(a6)
	Move.l	#Fuck_Seq,Aln_Seqp(a6)		; After done, quit !
	Movem.w	d0-d1,Aln_X(a6)
	Move.w	#211,Aln_Anmset(a6)
	Bra.s	Insert_Weapon_Without_Flash_Skip_Screen_Check

Insert_Weapon_If_Above_Screen_Without_Flash
;	Cmp.w	#Screen_Height,d1
	Cmp.w	Height_Of_Screen(a4),d1
	Blt.s	Insert_Weapon_Without_Flash_Skip_Screen_Check
	Rts
Insert_Weapon_Without_Flash
	Bsr.s	Check_Weapon_Is_On_Screen
Insert_Weapon_Without_Flash_Skip_Screen_Check
	Bsr	Search_Free_Alien_Slot	
	Move.w	#$1,Aln_Dmg(a6)
	Move.l	#.Wait,Aln_Seqp(a6)		; After done, quit !
	Move.w	#6,Aln_Wave(a6)			; Vector move
	And.w	#$ff,d2
	Move.w	d2,Aln_Shite(a6)		; Angle
	Tst.w	d3
	Bpl.s	.Pos_Scale
	Addq.w	#2,d3
	Sub.w	Difficuly(a4),d3
	Bra.s	.Ins_Speed
.Pos_Scale
	Subq.w	#2,d3
	Add.w	Difficuly(a4),d3
.Ins_Speed
	Move.w	d3,Aln_Shite+4(a6)		; Scale
	Move.w	d5,Aln_Anmset(a6)		; Animset to use
	Lea	Quick_1024,a3
	Add.w	d4,d4
	Add.w	d4,d4
	Move.l	(a3,d4),a3
	Add.w	d2,d2
	Add.w	d2,d2
	Add.w	(a3,d2),d0
	Add.w	#$100,d2
	And.w	#$3fc,d2
	Add.w	(a3,d2),d1
	Movem.w	d0-d1,Aln_X(a6)
	Rts

.Wait	Check_Screen_Bound	


**********************************************************
; Lots of little subroutines for maximum versatility!!!!
; Sorry PC people!

Insert_Alien
	Tst.b	Num_Lives+Pl1
	Bne.s	.Ok
	Tst.b	Num_Lives+Pl2
	Bne.s	.Ok
	Tst.b	Delay_Set_For_Player_fire(a4)
	Beq.s	.Set
	Move.b	#50,Delay_For_Player_fire(a4)
	St	Delay_Set_For_Player_fire(a4)
.Set	Tst.b	Delay_For_Player_fire(a4)
	Beq.s	.Ok
	Subq.b	#1,Delay_For_Player_fire(a4)
	Rts
.Ok	Move.l	Aliens_Insert_P(a4),a0
	St	(a0)
	Lea	Aliens_Insert_T(a4),a0  Pointer to insert structure!
.Loop	Move.w	(a0)+,d0		Insert number !
	Bmi.s	.Exit			-ive then end !
	Move.l	(a0)+,a2
	Lsl.w	#2,d0
	Move.w	(a0)+,d3
	Tst.w	(a2)
	Ble.s	.Loop
	Cmp.w	Aln_Unique_fire(a2),d3
	Bne.s	.Loop
	Jsr	.Jt(pc,d0)		Go to it !
	Bra.s	.Loop			Next !
.Exit	Rts

.Jt	Bra	Ins0			Normal energy bolt
	Bra	Ins1			?????
	Bra	Ins2			Power up bolts
	Bra	Ins3			Track fire
	Bra	Ins4			Enlarged Alien
	
	Bra	Ins6
	Bra	Ins5
	Bra	Ins8			Cannons for end level !
	Bra	Ins7
	Bra	Ins9
	Bra	Ins10
	Bra	Ins11
	Bra	Ins12
	Bra	Ins13
	Bra	Ins14

	Bra	Ins15
	Bra	Ins16
	Bra	Ins17
	Bra	Ins18
	Bra	Ins19			; Tank fires
	Bra	Ins20
	Bra	Ins21
	Bra	Ins22

	Bra	Ins23			; Plane down fire !
	
	Bra	Ins24
	Bra	Ins25
	Bra	Ins26
	Bra	Ins27
	
	Bra	Ins28			; Bomb stuff !
	
	Bra	Ins29
	Bra	Ins30
	Bra	Ins31			; Plane up fire !
	Bra	Ins32
	
	Bra	Ins33
	Bra	Ins34
	Bra	Ins35
	Bra	Ins36
	Bra	Ins37			; Mid2Tank fires
	Bra	Ins38
	Bra	Ins39
	Bra	Ins40

	Bra	Ins41
	Bra	Ins42			;Plane fires
	
	Bra	Ins43			; Hovercraft fires
	
	Bra	Ins44			; Straight down fires
	
	Bra	Ins45			; Left wing fire
	Bra	Ins46			; Right wing fire
	
	BRA	Ins47
	BRA	Ins48
	BRA	Ins49			; Mid guardian fire
	
	Bra	Ins50
	Bra	Ins51			; Center bolts for mid2
	Bra	Ins52			; Center bolts for mid2
	Bra	Ins53
	
	Bra	Ins54			; 
	Bra	Ins55			; 
	Bra	Ins56			; Second level Mad! Bolts!
	Bra	Ins57			; 
	Bra	Ins58			; 
	Bra	Ins59			; 
	
	Bra	Ins60
	Bra	Ins61			; Shots for Backturretslev3
	Bra	Ins62

	Bra	Ins63
	Bra	Ins64
	Bra	Ins65
	Bra	Ins66
	
	Bra	Ins67			; Shots for Backturretslev3
	Bra	Ins68			; Shots for Backturretslev3
	Bra	Ins69			; Shots for Backturretslev3
	Bra	Ins70			; Shots for Backturretslev3

	Bra	Ins71			; Bolts for end lev baddy4
	Bra	Ins72			; Bolts for end lev baddy4
	Bra	Ins73			; Bolts for end lev baddy4
	
	Bra	Ins74			; Spinny bits 5
	Bra	Ins75			; Big gun 5
	Bra	Ins76			; Wing guns 
	Bra	Ins77			; Wing guns 
	Bra	Ins78			; Tree fairy explosion !

	Bra	Ins79			; Boat left shot
	Bra	Ins80			; Boat right shot

	Bra	Ins81
	Bra	Ins82
	Bra	Ins83
	Bra	Ins84
	Bra	Ins85
	Bra	Ins86

	Bra	Ins87
	Bra	Ins88

	Bra	Ins89			; twin Boats up !
	Bra	Ins90			; twin Boats down

	Bra	Ins91			; Level 2 Spit out arrowy thangys

	Bra	Ins92
	Bra	Ins93			; 4 bolts!

	Bra	Ins94
	Bra	Ins95
	Bra	Ins96
	Bra	Ins97
	Bra	Ins98
	Bra	Ins99

	Bra	Ins100
	Bra	Ins101
	Bra	Ins102			; Scafolding right sequence explosions
	Bra	Ins103
	Bra	Ins104
	Bra	Ins105

	Bra	Ins106
	Bra	Ins107
	Bra	Ins108			; Scafolding left sequence explosions
	Bra	Ins109
	Bra	Ins110

	Bra	Ins111			; Spider fire !
	Bra	Ins112			; Grey wide ship

	Bra	Ins113			; Track thingy fire
	Bra	Ins114			; Track thingy fire

	Bra	Ins115			
	Bra	Ins116			
	Bra	Ins117
	Bra	Ins118			

	Bra	Ins119			
	Bra	Ins120			
	Bra	Ins121
	Bra	Ins122

	Bra	Ins123			; Big cannon fire
	Bra	Ins124			; Insert hi-pri massive crator

	Bra	Ins125			; Random asteroid

	Bra	Ins126			; Baddy 6 shot
	Bra	Ins127			; Baddy 6 shot (double)

	Bra	Ins128			; level 4 baddy mad
	Bra	Ins129			; level 4 baddy mad
	Bra	Ins130			; level 4 baddy mad
	Bra	Ins131			; level 4 baddy mad

	Bra	Ins132			; level 4 baddy mid

	Bra	Ins133			; Blowup mid 4 powerup
	Bra	Ins134			; Blowup mid 4 powerup
	Bra	Ins135			; Blowup mid 4 powerup
	Bra	Ins136			; Blowup mid 4 powerup
	Bra	Ins137			; Blowup mid 4 powerup

	Bra	Ins138			; Blowup 4 guardian
	Bra	Ins139			
	Bra	Ins140			
	Bra	Ins141			
	Bra	Ins142			
	Bra	Ins143			

	Bra	Ins144			; Spinny 1
	Bra	Ins145			; Spinny 2
	Bra	Ins146			; Lev5 fire bit
	Bra	Ins147			; 8-Way, fire

	Bra	Ins148
	Bra	Ins149
	Bra	Ins150
	Bra	Ins151
	Bra	Ins152
	Bra	Ins153
	Bra	Ins154

	Bra	Ins155

	Bra	Ins156			; Wing fire

	Bra	Ins157			; Row fire

	Bra	Ins158			; Wrap round 7 fire
	Bra	Ins159			; Wrap round 7 fire
	Bra	Ins160			; Wrap round 7 fire
	Bra	Ins161			; Wrap round 7 fire
	Bra	Ins162			; Wrap round 7 fire
	Bra	Ins163			; Wrap round 7 fire
	Bra	Ins164			; Wrap round 7 fire
	Bra	Ins165			; Wrap round 7 fire

	Bra	Ins166			; Wrap round 7 fire
	Bra	Ins167			; Wrap round 7 fire

	Bra	Ins168			; Level 7 dead
	Bra	Ins169			; Level 8 cannon fire
	Bra	Ins170			; Level 8 up fire
	Bra	Ins171			; Bit of fire

	Bra	Ins172			; Mad1 level8 
	
	Bra	Ins173
	Bra	Ins174
	Bra	Ins175			; Double bolts
	Bra	Ins176

	Bra	Ins177			; MAD!!!!! - This is it!

	Bra	Ins178
	Bra	Ins179
	Bra	Ins180
	Bra	Ins181
	Bra	Ins182
	Bra	Ins183
	Bra	Ins184

	Bra	Ins185
	Bra	Ins186
	Bra	Ins187

	Bra	Ins188			; TANK TURRET FIRE!!!
	Bra	Ins189			; Cannon type fire


	Bra	Ins190
	Bra	Ins191
	Bra	Ins192
	Bra	Ins193
	Bra	Ins194
	Bra	Ins195
	Bra	Ins196
	Bra	Ins197
	Bra	Ins198
	Bra	Ins199

	Bra	Ins200
	Bra	Ins201

	Bra	Ins202
	Bra	Ins203

	Nop	
Ins201	Movem.w	Aln_X(a2),d0-d1
	Addq.w	#2,d0
	Addq.w	#2,d1
	Move.b	Aln_Rotnumber(a2),d2
	Lsl.w	#4,d2
	Moveq	#6,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bra	Insert_Weapon



Ins200
	Pea	(a1)
	Move.l	Pow_Ins0(a4),a1
	Move.l	Power_Up_Posp(a4),a2
	Move.w	#0,(a2)+
	Move.l	Aln_X(a1),(a2)
	Sub.w	#40,(a2)+	
	Add.w	#10,(a2)+	
	Jsr	Void_It
	Move.l	Pow_Ins1(a4),a1
	Move.w	#$0200,(a2)+
	Move.l	Aln_X(a1),(a2)
	Add.w	#20,(a2)+	
	Add.w	#10,(a2)+	
	Move.l	a2,Power_Up_Posp(a4)
	Jsr	Void_It
	Move.l	(sp)+,a1
	Rts


Ins190	Moveq	#10,d0
	Moveq	#10,d1
	Bra.s	Small_Explosion_Fired
Ins191	Moveq	#20,d0
	Moveq	#20,d1
	Bra.s	Small_Explosion_Fired
Ins192	Moveq	#40,d0
	Moveq	#30,d1
	Bra.s	Small_Explosion_Fired
Ins193	Moveq	#30,d0
	Moveq	#30,d1
	Bra.s	Small_Explosion_Fired
Ins194	Moveq	#8,d0
	Moveq	#40,d1
	Bra.s	Small_Explosion_Fired
Ins195	Moveq	#50,d0
	Moveq	#16,d1
	Bra.s	Small_Explosion_Fired
Ins196	Moveq	#60,d0
	Moveq	#30,d1
	Bra.s	Small_Explosion_Fired
Ins197	Moveq	#20,d0
	Moveq	#30,d1
	Bra.s	Small_Explosion_Fired
Ins198	Moveq	#50,d0
	Moveq	#30,d1
	Bra.s	Small_Explosion_Fired
Ins199	Moveq	#60,d0
	Moveq	#32,d1
	Bra.s	Small_Explosion_Fired
	Nop



Small_Explosion_Fired
	Movem.w	Aln_X_Offseted(a2),d2-d3
	Add.w	d2,d0
	Add.w	d3,d1
	Sub.w	#14,d1
	Move.w	Seed(a4),d4
	Add.w	#$6213,Seed(a4)
	Muls	#20,d4
	Swap	d4
	Add.w	d4,d0
	Add.w	d4,d1
	Move.l	Explosion_Tabp(a4),a2
	Move.w	#0,(a2)+
	Move.w	#1,(a2)+
	Move.w	d0,(a2)+
	Move.w	d1,(a2)+
	Move.l	a2,Explosion_Tabp(a4)
	Subq.w	#1,.Samp_Do
	Bpl.s	.Skip
	Move.w	#6,.Samp_Do
	Pea	(a6)
	Lea	BigExplosion_Sfx,a6
	Jsr	Play_This_Sample
	Move.l	(sp)+,a6
.Skip	Rts

.Samp_Do	Ds.w	1


Ins189	Movem.w	Aln_X(a2),d0-d1
;----
;	Cmp.w	#Screen_Height-120,d1
	Move.w	Height_Of_Screen(a4),d2
	Sub.w	#120,d2
	Cmp.w	d2,d1
;----
	Bge.s	.Xit
	Move.b	Aln_Rotnumber(a2),d2
	And.w	#$f,d2
	Add.w	d2,d2
	Add.w	d2,d2
	Add.w	Cannon_Fire_Offsets(pc,d2),d0	
	Add.w	2+Cannon_Fire_Offsets(pc,d2),d1	
	Move.b	Aln_Rotnumber(a2),d2
	And.w	#$f,d2
	Lsl.w	#4,d2
	Moveq	#5,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bra	Insert_Weapon
.Xit	Rts

Cannon_Fire_Offsets
	Dc.w	12,1,17,2,21,4,24,8,25,12,21,17,21,19,16,22,12,23,8,22,4,19,4,17,2,9,3,8,4,4,6,2

Ins188	Movem.w	Aln_X_Offseted(a2),d0-d1
;	Cmp.w	#Screen_Height-120,d1
	Move.w	Height_Of_Screen(a4),d2
	Sub.w	#120,d2
	Cmp.w	d2,d1

	Bge.s	.Xit
	Move.b	Aln_Rotnumber(a2),d2
	And.w	#$f,d2
	Add.w	d2,d2
	Add.w	d2,d2
	Add.w	Tank_Turret_Fire_Offsets(pc,d2),d0	
	Add.w	2+Tank_Turret_Fire_Offsets(pc,d2),d1	
	Move.w	Aln_Sprite(a2),d6
	Lsl.w	#4,d6
	Move.l	Enemy_Sprites_Base(a4),a6
	Sub.w	Spr_Yoffset(a6,d6),d1
	Move.b	Aln_Rotnumber(a2),d2
	Lsl.w	#4,d2
	Moveq	#5,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bra	Insert_Weapon
.Xit	Rts

Tank_Turret_Fire_Offsets
	Radix	16
	Dc.w	0c,2,12,1,16,4,19,8,1b,0c,19,11,18,18,14,18,0f,1a,0a,19,5,16,4,14,-2,0e,0,9,2,5,4,2
	Radix	10


Ins185	Moveq	#$8,d7
	Bra.s	Ins_Plane_Fire

Ins186	Moveq	#$10,d7
	Bra.s	Ins_Plane_Fire

Ins187	Moveq	#$18,d7
;	Bra.s	Ins_Plane_Fire

Ins_Plane_Fire
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#22,d1
	Add.w	#10,d0
	Move.w	#$80,d2
	Moveq	#6,d3		
	Moveq	#0,d4
	Moveq	#44,d5
	Movem.w	d0-d7,-(sp)
	Add.b	d7,d2
	Bsr	Insert_Weapon	
	Movem.w	(sp)+,d0-d7
	Add.w	#30,d0
	Move.w	#$80,d2
	Sub.b	d7,d2
	Bra	Insert_Weapon	

Ins184	
	Add.w	#09,Aln_X(a2)
	Add.w	#-14,Aln_Y(a2)
	Bsr	Ins124
	Add.w	#-9,Aln_X(a2)
	Add.w	#14,Aln_Y(a2)
	Rts

Ins178	
	Add.w	#09,Aln_X(a2)
	Add.w	#-14,Aln_Y(a2)
	Bsr	Ins81
	Add.w	#-9,Aln_X(a2)
	Add.w	#14,Aln_Y(a2)
	Rts
Ins179	Add.w	#9,Aln_X(a2)
	Add.w	#-14,Aln_Y(a2)
	Bsr	Ins82
	Add.w	#-9,Aln_X(a2)
	Add.w	#14,Aln_Y(a2)
	Rts
Ins180	Add.w	#9,Aln_X(a2)
	Add.w	#-14,Aln_Y(a2)
	Bsr	Ins83
	Add.w	#-9,Aln_X(a2)
	Add.w	#14,Aln_Y(a2)
	Rts
Ins181	
	Add.w	#9,Aln_X(a2)
	Add.w	#-14,Aln_Y(a2)
	Bsr	Ins84
	Add.w	#-9,Aln_X(a2)
	Add.w	#14,Aln_Y(a2)
	Rts
Ins182	
	Add.w	#9,Aln_X(a2)
	Add.w	#-14,Aln_Y(a2)
	Pea	(a2)
	Bsr	Ins85
	Move.l	(sp)+,a2
	Add.w	#14,Aln_Y(a2)
	Add.w	#-9,Aln_X(a2)
	Rts
Ins183	
	Add.w	#9,Aln_X(a2)
	Add.w	#-14,Aln_Y(a2)
	Bsr	Ins86
	Add.w	#-9,Aln_X(a2)
	Add.w	#14,Aln_Y(a2)
	Rts

Ins177	Movem.w	Aln_X(a2),d0-d1
	Add.w	#13,d0
	Add.w	#13,d1
	Moveq	#8,d3		
	Moveq	#0,d4
	Moveq	#44,d5
	MOve.w	Aln_Shite(a2),d2
	Bra	Insert_Weapon	
Ins173	
	Moveq	#6,d0
	Moveq	#0,d1
	Moveq	#0,d2
	Bsr	Insert_Double_Fuck
	Moveq	#$80,d2
	Bra	Insert_Double_Fuck
Ins174	
	Moveq	#0,d0
	Moveq	#6,d1
	Moveq	#$40,d2
	Bsr	Insert_Double_Fuck
	Moveq	#$c0,d2
	Bra	Insert_Double_Fuck
Ins175	
	Moveq	#-3,d0
	Moveq	#-3,d1
	Moveq	#$20,d2
	Bsr	Insert_Double_Fuck
	Moveq	#$a0,d2
	Bra	Insert_Double_Fuck
Ins176	Moveq	#3,d0
	Moveq	#-3,d1
	Moveq	#$60,d2
	Bsr	Insert_Double_Fuck
	Moveq	#$e0,d2
	Bra	Insert_Double_Fuck
	Nop

Insert_Double_Fuck
	Movem.w	d0-d1,-(sp)
	Move.w	d2,-(sp)
	Add.w	Aln_X(a2),d0
	Add.w	Aln_Y(a2),d1
	Add.w	#13,d0
	Add.w	#13,d1
	Moveq	#8,d3		
	Moveq	#0,d4
	Moveq	#44,d5
	Bsr	Insert_Weapon	
	Movem.w	2(sp),d0-d1
	Neg.w	d0
	Neg.w	d1
	Add.w	Aln_X(a2),d0
	Add.w	Aln_Y(a2),d1
	Add.w	#13,d0
	Add.w	#13,d1
	Moveq	#8,d3		
	Moveq	#0,d4
	Moveq	#44,d5
	Move.w	(sp)+,d2
	Bsr	Insert_Weapon
	Movem.w	(sp)+,d0-d1
	Rts

Ins172	Movem.w	Aln_X(a2),d0-d1
	Add.w	#13,d0
	Add.w	#21,d1
	Bsr	Get_Closest_Ship
	Bsr	Track_Routine
	Move.w	d7,d2
	Moveq	#9,d3
	Moveq	#0,d4
	Moveq	#96,d5
	Movem.w	d0-d5,-(sp)
	Subq.w	#4,d2
	Bsr	Insert_Weapon
	Movem.w	(sp)+,d0-d5
	Addq.w	#4,d2
	Bra	Insert_Weapon

Ins171	
	Tst.w	Aln_Anmset(a2)
	Bmi.s	.Dont_Do
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#11,d0
	Add.w	#11,d1
	Bsr	Get_Closest_Ship
	Bsr	Track_Routine
	Move.w	d7,d2
	Moveq	#7,d3	
	Moveq	#0,d4
	Moveq	#44,d5
	Bra	Insert_Weapon
.Dont_Do
	Rts

Ins170	
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#13,d0
	Add.w	#13,d1
	Moveq	#0,d2
	Moveq	#8,d3
	Moveq	#0,d4
	Moveq	#44,d5
	Movem.w	d0-d5,-(sp)
	Move.w	#8,-(sp)
.Loop	Movem.w	2(sp),d0-d5
	Bsr	Insert_Weapon
	Add.w	#$20,6(sp)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Movem.w	(sp)+,d0-d6
	Rts

Ins169	
	Movem.w	Aln_X(a2),d0-d1
	Addq.w	#4,d1
	Add.w	#16,d0
	Bsr	Get_Closest_Ship
	Bsr	Track_Routine
	Move.w	d7,d2
	Moveq	#7,d3	
	Moveq	#0,d4
	Moveq	#44,d5
	Movem.w	d0-d5,-(sp)
	Bsr	Insert_Weapon
	Movem.w	(sp),d0-d5
	Addq.w	#6,d2
	Bsr	Insert_Weapon
	Movem.w	(sp)+,d0-d5
	Subq.w	#6,d2
	Bra	Insert_Weapon

Ins168	
	Add.w	#40,Aln_X(a2)
	Add.w	#10,Aln_Y(a2)
	Bsr	Ins86
	Add.w	#-40,Aln_X(a2)
	Add.w	#-10,Aln_Y(a2)

	Add.w	#70,Aln_X(a2)
	Add.w	#70,Aln_Y(a2)
	Pea	(a2)
	Bsr	Ins85	
	Move.l	(sp)+,a2
	Add.w	#-70,Aln_X(a2)
	Add.w	#-70,Aln_Y(a2)

	Add.w	#20,Aln_X(a2)
	Add.w	#70,Aln_Y(a2)
	Pea	(a2)
	Bsr	Ins85	
	Move.l	(sp)+,a2
	Add.w	#-20,Aln_X(a2)
	Add.w	#-70,Aln_Y(a2)

	Add.w	#50,Aln_X(a2)
	Add.w	#100,Aln_Y(a2)
	Pea	(a2)
	Bsr	Ins85
	Move.l	(sp)+,a2
	Add.w	#-50,Aln_X(a2)
	Add.w	#-100,Aln_Y(a2)

	Rts


Ins166	
	MOve.w	Num_Spiders(a4),d3
	Btst	#0,d3
	Bne.s	.No_More_Spider
	Or.w	#1,d3
	Move.w	d3,Num_Spiders(a4)
	Bsr	Search_Free_Alien_Slot
	Move.l	Aln_X(a2),Aln_X(a6)
	Add.w	#-16,Aln_X(a6)
	Add.w	#156,Aln_Y(a6)
	Move.w	#5,Aln_Dmg(a6)
	Clr.w	Aln_Seqdec(a6)
	Move.l	#Left_spider,Aln_Seqp(a6)
	Move.w	#243,Aln_Anmset(a6)
	Move.w	#1,Aln_Shite+20(a6)
	Bsr	Make_Spider_Link
.No_More_Spider
	Rts

Ins167	MOve.w	Num_Spiders(a4),d3
	Btst	#1,d3
	Bne.s	.No_More_Spider
	Or.w	#2,d3
	Move.w	d3,Num_Spiders(a4)
	Bsr	Search_Free_Alien_Slot
	Move.l	Aln_X(a2),Aln_X(a6)
	Add.w	#145,Aln_X(a6)
	Add.w	#156,Aln_Y(a6)
	Move.w	#5,Aln_Dmg(a6)
	Clr.w	Aln_Seqdec(a6)
	Move.l	#Right_spider,Aln_Seqp(a6)
	Move.w	#243,Aln_Anmset(a6)
	Move.w	#2,Aln_Shite+20(a6)
	Bsr	Make_Spider_Link
.No_More_Spider
	Rts

Make_Spider_Link
	Pea	(a6)
	Bsr	Search_Free_Alien_Slot
	Move.l	(sp)+,a3
	Move.l	a3,Aln_Prevlink(a6)
	Move.l	a6,Aln_Link(a3)
	Move.w	#$7fff,(a6)
	MOve.w	#12,Aln_Childx(a6)
	MOve.w	#10,Aln_ChildY(a6)
	Clr.w	Aln_Seqdec(a6)		
	Move.w	#251,Aln_Anmset(a6)
	Move.l	#Ud_Spider_Seq,Aln_Seqp(a6)
	Rts

Left_Spider
	Move_Relative	0,1,43
	Gosub		Tween_Spider
	Move_Relative	1,0,78
	Move_Relative	0,0,1
	Stop_Anim
.Hold	Branch		.Hold

Right_Spider
	Move_Relative	0,1,44+32
	Gosub		Tween_Spider2
	Move_Relative	-1,0,78
	Move_Relative	0,0,1
	Stop_Anim
.Hold	Branch		.Hold

Tween_Spider
	Move_Relative	0,0,1	
;	Abs_Move	0,1,1
	Change_Link_Anim	1,-1
	Check_An_Anim_And_Branch_IfNE		244,.Vertical			; Vertical spider
	Change_Anim	267
	Wait_Anim	2
	Change_Anim	243
	Change_Child_Offset	1,12,10
	Change_Link_Anim	1,251
	Return

.Vertical
	Change_Anim	266
	Wait_Anim	2
	Change_Anim	244
	Change_Child_Offset	1,10,12
	Change_Link_Anim	1,252
	Return

Tween_Spider2
	Move_Relative	0,0,1	
	Change_Link_Anim	1,-1
	Check_An_Anim_And_Branch_IfNE		244,.Vertical			; Vertical spider
	Change_Anim	263
	Wait_Anim	2
	Change_Anim	243
	Change_Child_Offset	1,12,10
	Change_Link_Anim	1,251
	Return

.Vertical
	Change_Anim	262
	Wait_Anim	2
	Change_Anim	244
	Change_Child_Offset	1,10,12
	Change_Link_Anim	1,252
	Return






Ins158	Moveq	#$b0,d2
	Bra.s	Insert_Wrap7

Ins159	Moveq	#$a0,d2
	Bra.s	Insert_Wrap7

Ins160	Moveq	#$90,d2
	Bra.s	Insert_Wrap7

Ins161	Moveq	#$88,d2
	Bra.s	Insert_Wrap7

Ins162	Moveq	#$80,d2
	Bra.s	Insert_Wrap7

Ins163	Moveq	#$78,d2
	Bra.s	Insert_Wrap7

Ins164	Moveq	#$70,d2
	Bra.s	Insert_Wrap7

Ins165	Moveq	#$66,d2
;	Bra.s	Insert_Wrap7


Insert_Wrap7
	MOveq	#6,d0
	Moveq	#4,d1
	Add.w	Aln_X(a2),d0
	Add.w	Aln_Y(a2),d1
	Moveq	#8,d3
	Moveq	#0,d4
	Moveq	#44,d5
	Movem.w	d0-d5,-(sp)
	Bsr	Insert_Weapon
	Movem.w	(sp)+,d0-d5
	Add.w	#30,d0
	Sub.b	#$80,d2
	Move.w	#$80,d7
	Sub.w	d2,d7
	Move.w	d7,d2
	Bra	Insert_Weapon
	

Ins157	Movem.w	Aln_X(a2),d0-d1
	Bsr	Get_Closest_Ship
	Bsr	Track_Routine
	Movem.w	Aln_X(a2),d0-d1
	Move.w	d7,d2
	Addq.w	#3,d0
	Addq.w	#3,d1
	Moveq	#8,d3
	Moveq	#0,d4
	Moveq	#44,d5
	Bra	Insert_Weapon


Ins156	Movem.w	Aln_X(a2),d0-d1
	Bsr	Get_Closest_Ship
	Bsr	Track_Routine
	Movem.w	Aln_X(a2),d0-d1
	Move.w	d7,d2
	Addq.w	#2,d0
	Addq.w	#6,d1
	Moveq	#6,d3
	Moveq	#0,d4
	Moveq	#44,d5
	Bra	Insert_Weapon

Ins155
	Add.w	#17,Aln_X(a2)
	Add.w	#-14,Aln_Y(a2)
	Bsr	Ins86
	Add.w	#-17,Aln_X(a2)
	Add.w	#+14,Aln_Y(a2)
	Rts



Ins154	Movem.w	Aln_X(a2),d0-d1
	Add.w	#10,d0
	Add.w	#-10,d1
	Movem.w	d0-d1,Aln_X_Save(a4)
	Move.w	#-1,Aln_Sprite_Save(a4)
	Bsr	Crator64
	Rts

Ins148	Add.w	#-20,Aln_Y(a2)
	Bsr	Ins81
	Add.w	#20,Aln_Y(a2)
	Rts
Ins149	Add.w	#-20,Aln_Y(a2)
	Bsr	Ins82
	Add.w	#20,Aln_Y(a2)
	Rts
Ins150	Add.w	#-20,Aln_Y(a2)
	Bsr	Ins83
	Add.w	#20,Aln_Y(a2)
	Rts
Ins151	Add.w	#-20,Aln_Y(a2)
	Bsr	Ins84
	Add.w	#20,Aln_Y(a2)
	Rts
Ins152	Add.w	#-20,Aln_Y(a2)
	Pea	(a2)
	Bsr	Ins85
	Move.l	(sp)+,a2
	Add.w	#20,Aln_Y(a2)
	Rts
Ins153	Add.w	#-20,Aln_Y(a2)
	Bsr	Ins86
	Add.w	#20,Aln_Y(a2)
	Rts



Ins147	Movem.w	Aln_X(a2),d0-d1
	Add.w	#26,d0
	Add.w	#17,d1
	Moveq	#7,d3
	Moveq	#0,d4
	Moveq	#44,d5
	Movem.w	d0-d1/d3-d5,-(sp)
	Move.w	#8,-(sp)
	Lea	.Quick_Tab_Adder(pc),a5
.Loop0	Movem.w	2(sp),d0-d1/d3-d5
	Move.w	(a5)+,d2
	Add.w	(a5)+,d0
	Add.w	(a5)+,d1
	Bsr	Insert_Weapon
	Subq.w	#1,(sp)
	Bne.s	.Loop0
	Addq.l	#2,sp
	Movem.w	(sp)+,d0-d1/d3-d5
	Rts

.Quick_Tab_Adder
	Dc.w	$f0,-8,-8	
	Dc.w	$10,+2,-8	
	Dc.w	$30,+8,-2
	Dc.w	$50,+8,+2	
	Dc.w	$70,+2,+6
	Dc.w	$90,-8,+6	
	Dc.w	$b0,-12,+2	
	Dc.w	$d0,-12,-2	

Ins146
	Movem.w	Aln_X(a2),d0-d1
	Addq.w	#4,d1
	Move.w	Aln_Shite(a2),d2
	Moveq	#6,d3
	Moveq	#0,d4
	Moveq	#44,d5
	Bra	Insert_Weapon

Ins144	Bsr	Insert_Spinny
	Move.l	#Spinny_Seq1,Aln_Seqp(a6)
	Rts

Ins145	Bsr	Insert_Spinny
	Move.l	#Spinny_Seq2,Aln_Seqp(a6)
	Rts

Insert_Spinny
	Bsr	Search_Free_Alien_Slot
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#18,d0
	Add.w	#30,d1
	Movem.w	d0-d1,Aln_X(a6)
	Move.w	#195,Aln_Anmset(a6)
	Move.w	#100,Aln_Dmg(a6)
	Move.w	#50,Aln_Half_Damage(a6)
	Rts

Ins143	Add.w	#16,Aln_X(a2)
	Add.w	#2,Aln_Y(a2)
	Bsr	Ins86
	Sub.w	#16,Aln_X(a2)
	Sub.w	#2,Aln_Y(a2)
	Rts

Ins133	
	Moveq	#-10,d0
	Moveq	#-2,d2
	Bsr	Scaf_Explosion
	Moveq	#+10,d0
	Moveq	#-2,d2
	Bra	Scaf_Explosion
Ins134			
	Moveq	#-25,d0
	Moveq	#-2,d2
	Bsr	Scaf_Explosion
	Moveq	#+25,d0
	Moveq	#-2,d2
	Bra	Scaf_Explosion

Ins135			
	Moveq	#-40,d0
	Moveq	#-2,d2
	Bsr	Scaf_Explosion
	Moveq	#+40,d0
	Moveq	#-2,d2
	Bra	Scaf_Explosion
Ins136			
	Moveq	#-55,d0
	Moveq	#-2,d2
	Bsr	Scaf_Explosion
	Moveq	#+55,d0
	Moveq	#-2,d2
	Bra	Scaf_Explosion
Ins137			
	Moveq	#-70,d0
	Moveq	#-2,d2
	Bsr	Scaf_Explosion
	Moveq	#+70,d0
	Moveq	#-2,d2
	Bra	Scaf_Explosion



Ins128	Moveq	#$40,d2
	Bsr.s	Lev4_Mad_Fire
	Moveq	#$c0,d2
	Bra.s	Lev4_Mad_Fire
Ins129	Moveq	#$00,d2
	Bsr.s	Lev4_Mad_Fire
	Moveq	#$80,d2
	Bra.s	Lev4_Mad_Fire
Ins130	Moveq	#$20,d2
	Bsr.s	Lev4_Mad_Fire
	Moveq	#$a0,d2
	Bra.s	Lev4_Mad_Fire
Ins131	Moveq	#$60,d2
	Bsr.s	Lev4_Mad_Fire
	Moveq	#$e0,d2
	Bra.s	Lev4_Mad_Fire
	Nop

Lev4_Mad_Fire
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#12,d0
	Add.w	#12,d1
	Moveq	#8,d3
	Moveq	#0,d4
	Moveq	#44,d5
	Sub.w	#6*2,d2
	Movem.w	d0-d5,-(sp)
	Move.w	#5,-(sp)
.Loop	Movem.w	2(sp),d0-d5
	Bsr	Insert_Weapon_If_Above_Screen_Without_Flash
	Move.l	#Fuck_Seq,Aln_Seqp(a6)
	Move.w	#55,Aln_Seqdec(a6)
	Addq.w	#6,6(sp)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Movem.w	(sp)+,d0-d5
	Rts

Ins126
	Movem.w	Aln_X(a2),d0-d1
	Move.w	Aln_Shite(a2),d2
	Moveq	#7,d3
	Moveq	#0,d4
	Moveq	#44,d5
	Move.w	Aln_Shite+14(a2),d6
	Lsl.w	#2,d6
	Add.w	Head_Offset_Shots(pc,d6),d0
	Add.w	Head_Offset_Shots+2(pc,d6),d1
	Bra	Insert_Weapon

Ins127	Movem.w	Aln_X(a2),d0-d1
	Move.w	Aln_Shite(a2),d2
	Moveq	#7,d3
	Moveq	#0,d4
	Moveq	#44,d5
	Move.w	Aln_Shite+14(a2),d6
	Lsl.w	#2,d6
	Add.w	Head_Offset_Shots(pc,d6),d0
	Add.w	Head_Offset_Shots+2(pc,d6),d1
	Movem.w	d0-d5,-(sp)
	Addq.b	#8,d2
	Bsr	Insert_Weapon
	Movem.w	(sp)+,d0-d5
	Subq.b	#8,d2
	Bra	Insert_Weapon

Head_Offset_Shots
	Dc.w	0,12
	Dc.w	4,14
	Dc.w	5,22
	Dc.w	8,23
	Dc.w	10,24
	Dc.w	12,23
	Dc.w	14,20
	Dc.w	18,17
	Dc.w	22,12

Ins125
;	Cmp.w	#Playfield_Height,Aln_Y(a2)
	Move.w	Aln_Y(a2),d3
	Cmp.w	Height_Of_Screen(a4),d3
	Bge.s	.Not_On_Screen
	Move.w	Seed(a4),d2
	And.w	#$ff,d2
	Lsr.w	#2,d2
	Sub.b	#$20,d2
	Bsr	Search_Free_Alien_Slot	
	Move.w	d2,Aln_Shite(a6)
	Move.w	#5,Aln_Shite+4(a6)	
	MOve.w	#$3,Aln_Dmg(a6)
	Moveq	#0,d0
	Move.w	Seed(a4),d0
	Divu	#300,d0
	Swap	d0
	Add.w	#(480-300)/2,d0
;	Move.w	#Playfield_Height,d1	
	Move.w	Height_Of_Screen(a4),d1
	Movem.w	d0-d1,Aln_X(a6)
	Move.w	#6,Aln_Wave(a6)	
	Move.w	#80,Aln_Seqdec(a6)
	Move.w	#307,Aln_Anmset(a6)
	Move.l	#Fuck_Seq,Aln_Seqp(a6)
.Not_On_Screen
	Rts

Ins124	
	Movem.w	Aln_X(a2),d0-d1
	Sub.w	#8,d0
	Sub.w	#8,d1
	Bsr	Search_Free_Alien_Slot	
	MOve.w	#$7fff,Aln_Dmg(a6)
	Movem.w	d0-d1,Aln_X(a6)
	Move.w	#6,Aln_Wave(a6)	
	Move.w	#$7fff,Aln_Seqdec(a6)
	Move.w	#310,Aln_Anmset(a6)
	Rts

Ins123
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#20,d0
	Add.w	#65,d1
	MOveq	#6,d3
	Moveq	#0,d4
	Moveq	#44,d5
	Movem.w	d0-d1/d3-d5,-(sp)
	Move.w	#$80,d2
	Bsr	Insert_Weapon
	Movem.w	(sp),d0-d1/d3-d5
	Move.w	#$90,d2
	MOveq	#5,d3
	Bsr	Insert_Weapon
	Movem.w	(sp)+,d0-d1/d3-d5
	Move.w	#$70,d2
	MOveq	#5,d3
	Bra	Insert_Weapon

Ins122	Move.l	a2,a5
.Loop	Move.l	Aln_Prevlink(a5),a5
	Cmp.w	#136,Aln_Anmset(a5)
	Bne.s	.Loop
	Cmp.b	#4,Aln_Anim(a5)
	Bne.s	.Exit
	Movem.w	Aln_X(a2),d0-d1
	Addq.w	#8,d0
	Addq.w	#8,d1
	Move.b	Aln_Rotnumber(a2),d2
	Lsl.w	#4,d2
	Moveq	#6,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bra	Insert_Weapon
.Exit	Rts

Ins121	Movem.w	Aln_X(a2),d0-d1
	Add.w	#16,d1
	Sub.w	#30,d0
	Movem.w	d0-d1,-(sp)
	Bsr	Search_Free_Alien_Slot
	Move.l	(sp),Aln_X(a6)
	Move.w	#5,(a6)
	Move.w	#2,Aln_Half_damage(a6)
	Move.l	#.Bomb_Down_Seq1,Aln_Seqp(a6)
	Move.w	#54,Aln_Anmset(a6)
	Bsr	.Child_Sprite
	Bsr	Search_Free_Alien_Slot
	Move.l	(sp)+,Aln_X(a6)
	Add.w	#40,Aln_X(a6)
	Move.w	#5,(a6)
	Move.w	#2,Aln_Half_damage(a6)
	Move.l	#.Bomb_Down_Seq2,Aln_Seqp(a6)
	Move.w	#54,Aln_Anmset(a6)
	Bsr	.Child_Sprite
	Rts	

.Child_Sprite
	Move.l	a6,a5
	Bsr	Search_free_Alien_Slot
	Move.l	a6,Aln_Link(a5)
	Move.l	a5,Aln_Prevlink(a6)
	Move.w	#$7fff,(a6)
	Move.w	#55,Aln_Anmset(a6)
	Move.w	#1000,Aln_Seqdec(a6)
	Move.w	#-8,Aln_Childx(a6)
	Move.w	#-30,Aln_Childy(a6)
	Rts

.Bomb_Down_Seq1
	Vector_Move	$80,0,2,08
	Vector_Move	$88,0,1,200
	End_Seq

.Bomb_Down_Seq2
	Vector_Move	$80,0,2,08
	Vector_Move	$78,0,1,200
	End_Seq

Ins119	Add.w	Aln_X(a2),d0
	Add.w	Aln_Y(a2),d1
	Bsr	Get_Angle_From_alien_To_Ship
	Move.w	d7,d2
	MOveq	#6,d3
	Moveq	#0,d4
	Moveq	#44,d5
	Movem.w	d0-d5,-(sp)
	Subq.b	#4,d2
	Bsr	Insert_Weapon
	Movem.w	(sp)+,d0-d5
	Addq.b	#4,d2
	Bra	Insert_Weapon

Ins120	Add.w	Aln_X(a2),d0
	Add.w	Aln_Y(a2),d1
	Bsr	Get_Angle_From_alien_To_Ship
	Move.w	d7,d2
	MOveq	#6,d3
	Moveq	#0,d4
	Moveq	#44,d5
	Bsr	Insert_Weapon

Ins115	Moveq	#1,d0
	Moveq	#1,d1
	Bsr	Fire_Terrain
	Moveq	#1,d0
	Moveq	#20,d1
	Bra	Fire_Terrain

Ins116	Moveq	#1,d0
	Moveq	#10,d1
	Bsr	Fire_Terrain
	Moveq	#1,d0
	Moveq	#30,d1
	Bra	Fire_Terrain

Ins117	Moveq	#1,d0
	Moveq	#1,d1
	Bsr	Fire_Terrain
	Moveq	#20,d0
	Moveq	#1,d1
	Bra	Fire_Terrain

Ins118	Moveq	#10,d0
	Moveq	#1,d1
	Bsr	Fire_Terrain
	Moveq	#30,d0
	Moveq	#1,d1
	Bra	Fire_Terrain
	Nop

Fire_Terrain
	Add.w	Aln_X(a2),d0
	Add.w	Aln_Y(a2),d1
	Bsr	Get_Angle_From_alien_To_Ship
	Move.w	d7,d2
	MOveq	#6,d3
	Moveq	#0,d4
	Moveq	#44,d5
	Bra	Insert_Weapon

Ins114	Movem.w	Aln_X(a2),d0-d1

;	Cmp.w	#Screen_Height-120,d1
	Move.w	Height_Of_Screen(a4),d2
	Sub.w	#120,d2
	Cmp.w	d2,d1

	Bge.s	.Xit
	Addq.w	#2,d0
	Addq.w	#2,d1
	Bsr	Get_Angle_From_alien_To_Ship
	Move.w	d7,d2
	MOveq	#6,d3
	Moveq	#0,d4
	Moveq	#44,d5
	Bra	Insert_Weapon
.Xit	Rts

Ins113	Move.l	Aln_PRevlink(a2),a3
	Tst.b	Aln_Hitoveride(a3)
	Beq.s	.Continue	
	Rts
.Continue	
	Movem.w	Aln_X(a2),d0-d1
	Bsr	Get_Angle_From_alien_To_Ship
	Move.w	d7,d2
	Addq.w	#3,d0
	Addq.w	#3,d1
	MOveq	#6,d3
	Moveq	#0,d4
	Moveq	#44,d5
	Bra	Insert_Weapon


Ins111	MOve.l	Aln_Prevlink(a2),a3
	Tst.b	Aln_HitOveride(a3)
	Bne.s	.No_Hit
	Cmp.w	#243,Aln_anmset(a3)
	Beq.s	.Continue
	Cmp.w	#244,Aln_anmset(a3)
	Beq.s	.Continue
.No_Hit
	Rts
.Continue
	Movem.w	Aln_X(a2),d0-d1
	Bsr	Get_Angle_From_Alien_To_Ship
	Move.w	d7,d2
	Moveq	#6,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bra	Insert_Weapon

Ins100	Moveq	#40,d0
	Moveq	#-4,d2
	Bra	Scaf_Explosion
Ins101	Moveq	#30,d0
	Moveq	#-4,d2
	Bra	Scaf_Explosion
Ins102	Moveq	#20,d0
	Moveq	#-4,d2
	Bra	Scaf_Explosion
Ins103	Moveq	#10,d0
	Moveq	#-4,d2
	Bra	Scaf_Explosion
Ins104	Moveq	#04,d0
	Moveq	#-4,d2
	Bra.s	Scaf_Explosion

Ins106	Moveq	#-50,d0
	Moveq	#-4,d2
	Bra.s	Scaf_Explosion
Ins107	Moveq	#-40,d0
	Moveq	#-4,d2
	Bra.s	Scaf_Explosion
Ins108	Moveq	#-30,d0
	Moveq	#-4,d2
	Bra.s	Scaf_Explosion
Ins109	Moveq	#-20,d0
	Moveq	#-4,d2
	Bra.s	Scaf_Explosion
Ins110	Moveq	#-10,d0
	Moveq	#-4,d2
	Bra.s	Scaf_Explosion

Ins105
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#-11,d0
	Add.w	#-8,d1
	Moveq	#0,d2
	Moveq	#0,d3
	Moveq	#0,d4
	MOveq	#52,d5
	Bsr	Insert_Weapon_Without_Flash_Skip_Screen_Check
	Clr.l	Aln_Shite(a6)
	Clr.l	Aln_Shite+4(a6)
	Clr.l	Aln_Shite+8(a6)
	Clr.l	Aln_Shite+12(a6)
	Move.w	#$7fff,Aln_Dmg(a6)
	Move.w	#16,Aln_Seqdec(a6)
	Move.l	#Fuck_Seq,Aln_Seqp(a6)
	Move.l	Power_Up_Posp(a4),a3
	Move.b	ALN_POWNUM(a2),(a3)+
 	Addq.l	#1,a3
	Movem.w	Aln_X(a2),d3-d4
	Add.w	#11,d3
	Add.w	#11,d4
	Move.w	d3,(a3)+
	Move.w	d4,(a3)+
 	Move.l	a3,Power_Up_PosP(a4)
	Rts

Scaf_Explosion
	Add.w	Aln_X(a2),d0
	Move.w	Aln_Y(a2),d1
	Moveq	#$c0,d2
	Moveq	#0,d3
	Moveq	#0,d4
	MOveq	#53,d5
	Bsr	Insert_Weapon_Without_Flash_Skip_Screen_Check
	Move.w	#$7fff,Aln_Dmg(a6)
	Move.w	#10,Aln_Seqdec(a6)
	Move.l	#Fuck_Seq,Aln_Seqp(a6)
	Pea	(a6)
	Lea	Bigexplosion_Sfx,a6
	Jsr	Play_This_Sample
	Move.l	(sp)+,a6
	Rts

Ins93	Bsr	Get_Angle_From_Alien_To_Ship
	Movem.w	Aln_X(a2),d0-d1
	Move.w	#6,d3
	Move.w	#0,d4
	Move.w	#2,d5
	Bra	Insert_Weapon

Ins92	
	Movem.w	Aln_X(a2),d0-d1
	Bsr	Get_Angle_From_Alien_To_Ship
	Move.w	#2,-(sp)
	MOve.w	#0,-(sp)
	Move.w	#6,-(sp)
	Move.w	d2,-(sp)
	Move.l	Aln_X(a2),-(sp)
	
	Movem.w	(sp),d0-d5
	Bsr	Insert_Weapon
	Movem.w	(sp),d0-d5
	Add.w	#27,d0
	Bsr	Insert_Weapon
	Movem.w	(sp),d0-d5
	Add.w	#27,d1
	Bsr	Insert_Weapon
	Movem.w	(sp)+,d0-d5
	Add.w	#27,d0
	Add.w	#27,d1
	Bra	Insert_Weapon


Ins91	Movem.w	Aln_X(a2),d0-d1
	Add.w	#42,d0
	Add.w	#20,d1
	Movem.w	d0-d1,-(sp)
	Lea	.Offsets(pc),a5
	Move.w	#6,-(sp)
.Loop	Bsr	Search_Free_Alien_Slot	
	Move.w	#1,(a6)
	Movem.w	2(sp),d0-d1
	Add.w	(a5)+,d0
	Add.w	(a5)+,d1
	Movem.w	d0-d1,Aln_X(a6)
	St	Aln_Pauseflag(a6)
	Move.l	#.Spit_Out_Seq,Aln_Seqp(a6)
	Move.w	#8,Aln_Seqdec(a6)
	Move.w	#6,Aln_Wave(a6)		; Vector move
	Move.w	(a5)+,Aln_Shite(a6)	
	Move.w	#6,Aln_Shite+4(a6)	
	Moveq	#94,d5
	Tst.b	-1(a5)
	Bmi.s	.Left_Spit
	Moveq	#95,d5
.Left_Spit
	Move.w	d5,Aln_Anmset(a6)	; Animset to use
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#6,sp
	Rts

.Offsets
	Dc.w	-28-10,-8,$e8
	Dc.w	-24-10,-12,$f0
	Dc.w	-18-10,-20,$f8

	Dc.w	+20,-8,$18
	Dc.w	+16,-12,$10
	Dc.w	+10,-20,$08


.Spit_Out_Seq
	Unpause_Anim
	Wait_Anim	2
	Change_Anim	68
	Arrow_Home	$80,90
	End_Seq

Ins89	Movem.w	Aln_X(a2),d0-d1
	Add.w	#30-12,d0
	Add.w	#30-12,d1
	Moveq	#-2,d2
	Bsr.s	Ins_Twin_Boat
	Add.w	#40+12,d0
	Moveq	#-2,d2
	Bra.s	Ins_Twin_Boat

Ins90	Movem.w	Aln_X(a2),d0-d1
	Add.w	#30-12,d0
	Add.w	#30-12,d1
	Moveq	#2,d2
	Bsr.s	Ins_Twin_Boat
	Add.w	#40+12,d0
	Moveq	#2,d2

Ins_Twin_Boat
	Move.w	d2,-(sp)
	Movem.w	d0-d1,-(sp)
	Bsr	Search_Free_Alien_Slot	
	Move.l	(sp),Aln_X(a6)
	Move.w	#$1,Aln_Dmg(a6)
	Move.l	#.Boat_Seq1,Aln_Seqp(a6)	; After done, quit !
	Move.w	#30,Aln_Seqdec(a6)	
	Move.w	#71,Aln_Anmset(a6)	; Animset to use
	Move.w	4(sp),Aln_Shite+2(a6)
	Bpl.s	.Boat_down
	Move.w	#73,Aln_Anmset(a6)	; Animset to use
	Move.l	#.Boat_Seq2,Aln_Seqp(a6)
.Boat_down
	Pea	(a6)
	Move.l	#$80008000,Aln_Childx(a6)
	Bsr	Search_Free_Alien_Slot	
	Move.w	#$1,Aln_Dmg(a6)
	Move.l	#Track_Seq1,Aln_Seqp(a6)
	Move.w	#8,Aln_Anmset(a6)	; Animset to use
	Move.b	#2,Aln_Track_Val(a6)
	MOve.l	(sp)+,a5
	Move.l	a5,Aln_prevLink(a6)
	Move.l	a6,Aln_Link(a5)
	Movem.w	(sp)+,d0-d1
	Move.w	(sp)+,d2
	Rts

.Boat_Seq1
	Abs_Move	0,2,100
	End_Seq	

.Boat_Seq2
	Abs_Move	0,-1,100
	End_Seq	



Ins88	Moveq	#-6,d6
	Bsr.s	.Fire
	Moveq	#6,d6
.Fire	Movem.w	Aln_X(a2),d0-d1
	Move.b	Aln_Rotnumber(a2),d2
	Lsl.w	#4,d2
	Add.w	d6,d2
	Moveq	#5,d3
	Moveq	#0,d4
	Move.w	#2,d5
	Bra	Insert_Weapon


Ins87	Movem.w	Aln_X(a2),d0-d1
	Bsr	Get_Angle_From_Alien_To_Ship
	Moveq	#4,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Add.w	#16,d0
	Add.w	#16,d1
	Bra	Insert_Weapon

Ins98	Add.w	#10,Aln_X(a2)
	Add.w	#4,Aln_Y(a2)
	Pea	(a2)
	Bsr	Ins85
	Move.l	(sp)+,a2
	Sub.w	#10,Aln_X(a2)
	Sub.w	#4,Aln_Y(a2)
	Rts

Ins99	Add.w	#10,Aln_X(a2)
	Add.w	#-2,Aln_Y(a2)
	Bsr	Ins86
	Sub.w	#10,Aln_X(a2)
	Sub.w	#-2,Aln_Y(a2)
	Rts


Ins85	Movem.w	Aln_X(a2),d0-d1
	Add.w	#10,d0
	Add.w	#10,d1
	Move.l	Explosion_Tabp(a4),a2
	Pea	(a6)
	Lea	BigExplosion_Sfx,a6
	Jsr	Play_This_Sample
	Move.l	(sp)+,a6
	Move.w	#3,(a2)+
	Move.w	#1,(a2)+
	Move.w	d0,(a2)+
	Move.w	d1,(a2)+
	Move.l	a2,Explosion_Tabp(a4)
	Rts
Ins86	Movem.w	Aln_X(a2),d0-d1
	Add.w	#40,d0
	Add.w	#40,d1
	Pea	(a6)
	Lea	Massive_Explosion_Sfx,a6
	Jsr	Play_This_Sample
	Move.l	(sp)+,a6
	Pea	(a2)
	Move.l	Explosion_Tabp(a4),a2
	Move.w	#9,(a2)+
	Move.w	#1,(a2)+	
	Move.w	d0,(a2)+
	Move.w	d1,(a2)+
	Move.l	a2,Explosion_Tabp(a4)
	Move.l	(sp)+,a2
	Rts
Ins142	Movem.w	Aln_X(a2),d0-d1
	Add.w	#30,d0
	Add.w	#14,d1
	Move.l	Explosion_Tabp(a4),a2
	Move.w	#3,(a2)+
	Move.w	#1,(a2)+
	Move.w	d0,(a2)+
	Move.w	d1,(a2)+
	Move.l	a2,Explosion_Tabp(a4)
	Pea	(a6)
	Lea	BigExplosion_Sfx,a6
	Jsr	Play_This_Sample
	Move.l	(sp)+,a6

	Rts
	





Ins94	Add.w	#10,Aln_X(a2)
	Add.w	#-2,Aln_Y(a2)
	Bsr	Ins81
	Sub.w	#10,Aln_X(a2)
	Sub.w	#-2,Aln_Y(a2)
	Rts
Ins95	Add.w	#10,Aln_X(a2)
	Add.w	#-2,Aln_Y(a2)
	Bsr	Ins82
	Sub.w	#10,Aln_X(a2)
	Sub.w	#-2,Aln_Y(a2)
	Rts
Ins96	Add.w	#10,Aln_X(a2)
	Add.w	#-2,Aln_Y(a2)
	Bsr	Ins83
	Sub.w	#10,Aln_X(a2)
	Sub.w	#-2,Aln_Y(a2)
	Rts
Ins97	Add.w	#10,Aln_X(a2)
	Add.w	#-2,Aln_Y(a2)
	Bsr	Ins84
	Sub.w	#10,Aln_X(a2)
	Sub.w	#-2,Aln_Y(a2)
	Rts

Ins138	Add.w	#16-8,Aln_X(a2)
	Add.w	#0,Aln_Y(a2)
	Bsr	Ins81
	Sub.w	#16-8,Aln_X(a2)
	Sub.w	#0,Aln_Y(a2)
	Rts
Ins139	Add.w	#16-8,Aln_X(a2)
	Add.w	#0,Aln_Y(a2)
	Bsr	Ins82
	Sub.w	#16-8,Aln_X(a2)
	Sub.w	#0,Aln_Y(a2)
	Rts
Ins140	Add.w	#16-8,Aln_X(a2)
	Add.w	#0,Aln_Y(a2)
	Bsr	Ins83
	Sub.w	#16-8,Aln_X(a2)
	Sub.w	#0,Aln_Y(a2)
	Rts
Ins141	Add.w	#16-8,Aln_X(a2)
	Add.w	#0,Aln_Y(a2)
	Bsr	Ins84
	Sub.w	#16-8,Aln_X(a2)
	Sub.w	#0,Aln_Y(a2)
	Rts



Ins81	Moveq	#0,d2
	Bra.s	Spit_Out_Dead_Guardian
Ins82	Moveq	#$10,d2
	Bra.s	Spit_Out_Dead_Guardian
Ins83	Moveq	#$20,d2
	Bra.s	Spit_Out_Dead_Guardian
Ins84	Moveq	#$30,d2

Spit_Out_Dead_Guardian
	Move.w	d2,-(sp)
	Move.w	#12,-(sp)
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#35,d0
	Add.w	#35,d1
	Moveq	#7,d3
	Move.w	#198,d5
.Loop	Bsr	Search_Free_Alien_Slot	
	Move.w	#$1,Aln_Dmg(a6)
	Movem.w	d0-d1,Aln_X(a6)
	Move.w	2(sp),Aln_Shite(a6)
	Move.w	d3,Aln_Shite+4(a6)
	Move.w	d5,Aln_Anmset(a6)
	Move.w	#6,Aln_Wave(a6)		; Vector move
	Move.w	#15,Aln_Seqdec(a6)
	Move.l	#Fuck_Seq,Aln_Seqp(a6)	; After done, quit !
	Add.w	#$18,2(sp)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#4,sp
	Rts

Ins79	Movem.w	Aln_X(a2),d0-d1
	Move.w	Aln_Shite(a2),d2
	Moveq	#6,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Add.w	#16,d0
	Add.w	#16,d1
	Movem.w	d0-d5,-(sp)
	Subq.w	#8,d2
	Bsr	Insert_Weapon
	Movem.w	(sp)+,d0-d5
	Addq.w	#8,d2
	Bra	Insert_Weapon

Ins80	Movem.w	Aln_X(a2),d0-d1
	Move.w	Aln_Shite(a2),d2
	Moveq	#6,d3
	Moveq	#0,d4
	Moveq	#96,d5
	Add.w	#16,d0
	Add.w	#16,d1
	Bra	Insert_Weapon

Ins77	Movem.w	Aln_X(a2),d0-d1
	Move.w	Aln_Shite(a2),d2
	Moveq	#8,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Addq.w	#4,d0
	Addq.w	#8,d1
	Bra	Insert_Weapon

Ins78	Movem.w	Aln_X(a2),d0-d1
	Clr.w	d2
	Move.w	#8,d3
	Move.w	#0,d4
	Move.w	#219,d5
	Move.w	#8,-(sp)
.Loop	Movem.w	d0-d5,-(sp)

	Bsr	Search_Free_Alien_Slot	
	Move.w	#$1,Aln_Dmg(a6)
	And.w	#$ff,d2
	Move.w	#5,Aln_Seqdec(a6)
	Move.l	#Fuck_Seq,Aln_Seqp(a6)	; After done, quit !
	Move.w	#6,Aln_Wave(a6)		; Vector move
	Move.w	d2,Aln_Shite(a6)	; Angle
	Move.w	d3,Aln_Shite+4(a6)	; Scale
	Move.w	d5,Aln_Anmset(a6)	; Animset to use
	Lea	Alien_Sine(pc),a3
	Add.w	d2,d2
	Move.w	(a3,d2),d6
	Add.w	#$40,d2
	And.w	#$ff,d2
	Move.w	(a3,d2),d7
	Add.w	d4,d4
	Muls	d4,d6			; X offset
	Muls	d4,d7			; y Offset
	Swap	d6
	Swap	d7
	Add.w	d6,d0
	Add.w	d7,d1
	Movem.w	d0-d1,Aln_X(a6)
	Movem.w	(sp)+,d0-d5
	Add.w	#$20,d2
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	St	(a2)
	Rts

Ins76	Movem.w	Aln_X(a2),d0-d1
	Move.w	Aln_Shite(a2),d2
	Moveq	#8,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Movem.w	(sp),d0-d5
	Addq.w	#4,d0
	Addq.w	#4,d1
	Bsr	Insert_Weapon
	Movem.w	(sp)+,d0-d5
	Add.w	#20,d0
	Addq.w	#4,d1
	Bra	Insert_Weapon
	
	

Ins75	Movem.w	Aln_X(a2),d0-d1
	Add.w	#13,d0
	Add.w	#36,d1
	Moveq	#$80,d2
	Moveq	#8,d3
	Moveq	#0,d4
	Moveq	#96,d5
	Bra	Insert_Weapon

Ins74	Movem.w	Aln_X(a2),d0-d1
	Add.w	#13,d0
	Add.w	#13,d1
	Moveq	#0,d2
	Moveq	#7,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Move.w	#12,-(sp)
.Loop	MOvem.w	2(sp),d0-d5
	Add.w	#21,6(sp)
	Bsr	Insert_Weapon
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Movem.w	(sp)+,d0-d5
	Rts

Ins71	Movem.w	Aln_X(a2),d0-d1
	Subq.w	#2,d0
	Moveq	#$80,d2
	Moveq	#$6,d3
	Moveq	#2,d4
	Move.w	#49,d5
	Bsr	Insert_Weapon
	Movem.w	Aln_X(a2),d0-d1
	Addq.w	#06,d0
	Moveq	#$80,d2
	Moveq	#$6,d3
	Moveq	#2,d4
	Move.w	#49,d5
	Bra	Insert_Weapon

Ins132	Moveq	#$00,d2
	Bra.s	Fire_4_Seq_Mid
Ins72	Moveq	#$20,d2

Fire_4_Seq_Mid
	Movem.w	Aln_X(a2),d0-d1
	Addq.w	#4,d0
	Addq.w	#4,d1
	Moveq	#6,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Move.w	d2,-(sp)
	Move.w	#4,-(sp)
.Loop	Movem.w	4(sp),d0-d5
	Move.w	2(sp),d2
	Bsr	Insert_Weapon
	Add.w	#$40,2(SP)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Lea	16(sp),sp
	Rts	

Ins73	Movem.w	Aln_X(a2),d0-d1
	Moveq	#0,d2
	Moveq	#6,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Move.w	#$60,-(sp)
	Move.w	#3,-(sp)
.Loop	Movem.w	4(sp),d0-d5
	Move.w	2(sp),d2
	Bsr	Insert_Weapon
	Add.w	#$20,2(SP)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Lea	16(sp),sp
	Rts	

Ins67	Movem.w	Aln_X(a2),d0-d1
	Moveq	#0,d2
	Moveq	#8,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Move.w	#8,-(sp)
.Loop	Movem.w	2(sp),d0-d5
	Bsr	Insert_Weapon
	Add.w	#$20,6(sp)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Lea	14(sp),sp
	Rts

Ins68	Movem.w	Aln_X(a2),d0-d1
	Moveq	#$20,d2
	Moveq	#8,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Move.w	#4,-(sp)
.Loop	Movem.w	2(sp),d0-d5
	Bsr	Insert_Weapon
	Add.w	#$40,6(sp)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Lea	14(sp),sp
	Rts

Ins69	Movem.w	Aln_X(a2),d0-d1
	Moveq	#$20,d2
	Moveq	#8,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Move.w	#2,-(sp)
.Loop	Movem.w	2(sp),d0-d5
	Bsr	Insert_Weapon
	Add.w	#$80,6(sp)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Lea	14(sp),sp
	Rts


Ins70	Movem.w	Aln_X(a2),d0-d1
	Moveq	#$60,d2
	Moveq	#8,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Move.w	#2,-(sp)
.Loop	Movem.w	2(sp),d0-d5
	Bsr	Insert_Weapon
	Add.w	#$80,6(sp)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Lea	14(sp),sp
	Rts


Ins63	Moveq	#0,d6
	Bra.s	Shoot_End3

Ins64	Moveq	#+$08,d6
	Bsr.s	Shoot_End3
	Moveq	#-$08,d6
	Bra.s	Shoot_End3

Ins65	Moveq	#$10,d6
	Bsr.s	Shoot_End3
	Moveq	#-$10,d6
	Bra.s	Shoot_End3

Ins66	Moveq	#$18,d6
	Bsr.s	Shoot_End3
	Moveq	#-$18,d6
;	Bra.s	Shoot_End3

Shoot_End3
	Movem.w	Aln_X(a2),d0-d1
	Addq.w	#6,d0
	Addq.w	#6,d1
	Moveq	#7,d3
	Moveq	#0,d4
	Move.w	#Trendy_Bolts_Anm_Set,d5
	Move.w	Aln_Shite(a2),d2
	Add.w	d6,d2
	Bsr	Insert_Weapon_If_Above_Screen
	Move.w	#70,Aln_Seqdec(a6)
	Move.l	#Fuck_Seq,Aln_Seqp(a6)
	Rts

Ins62	Movem.w	Aln_X(a2),d0-d1
	Move.w	Aln_Anmset(a2),d2
	Sub.w	#124,d2
	Asl.w	#2,d2
	Movem.w	.Offset(pc,d2),d3-d4
	Asr.w	#2,d2
	Add.w	d3,d0
	Add.w	d4,d1
	Add.w	d2,d2
	Move.w	.Angle_Tab(pc,d2),d2
	Moveq	#9,d3
	Moveq	#0,d4
	Moveq	#Trendy_Bolts_Anm_Set,d5
	Movem.w	d0-d5,-(sp)
	Bsr	Insert_Weapon
	Move.w	#8,6(sp)
	Movem.w	(sp),d0-d5
	Addq.b	#8,d2
	Bsr	Insert_Weapon
	Movem.w	(sp)+,d0-d5
	Subq.b	#8,d2
	Bsr	Insert_Weapon
	Rts

.Angle_Tab	Dc.w	$a0,$90,$80,$70,$60
.Offset	Dc.w	$0,$0
	Dc.w	$0,$0
	Dc.w	$3,$3
	Dc.w	$0,$0
	Dc.w	$0,$0

Ins60	Movem.w	Aln_X(a2),d0-d1
	Move.w	Aln_Shite(a2),d2
	Moveq	#8,d3
	Moveq	#2,d4
	Moveq	#44,d5
	Movem.w	d0-d5,-(sp)
	Movem.w	(sp),d0-d5
	Addq.w	#4,d0
	Bsr	Insert_Weapon_Without_Flash
	Movem.w	(sp),d0-d5
	Add.w	#24,d0
	Bsr	Insert_Weapon_Without_Flash
	Lea	12(sp),sp	
	Rts

Ins61	Movem.w	Aln_X(a2),d0-d1
	Moveq	#0,d2
	Moveq	#8,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Move.w	#4,-(sp)
.Loop	Movem.w	2(sp),d0-d5
	Bsr	Insert_Weapon
	Add.w	#$40,6(sp)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Lea	14(sp),sp
	Rts
	
Ins54	Moveq	#$38,d0
	Bra.s	SecondLev_Doubleshot
Ins55	Moveq	#$30,d0
	Bra.s	SecondLev_Doubleshot
Ins56	Moveq	#$28,d0
	Bra.s	SecondLev_Doubleshot
Ins57	Moveq	#$18,d0
	Bra.s	SecondLev_Doubleshot
Ins58	Moveq	#$10,d0
	Bra.s	SecondLev_Doubleshot
Ins59	Moveq	#$0,d0
;	Bra.s	SecondLev_Doubleshot

SecondLev_Doubleshot
	Move.w	d0,-(sp)
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#-16,d0
	Add.w	#16,d1
	Moveq	#$80,d2
	Sub.w	(sp),d2
	Moveq	#5,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bsr	Insert_Weapon
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#32,d0
	Add.w	#16,d1
	Moveq	#$80,d2
	Sub.w	(sp),d2
	Moveq	#5,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bsr	Insert_Weapon
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#-16,d0
	Add.w	#16,d1
	Moveq	#$80,d2
	Add.w	(sp),d2
	Moveq	#5,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bsr	Insert_Weapon
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#32,d0
	Add.w	#16,d1
	Moveq	#$80,d2
	Add.w	(sp),d2
	Moveq	#5,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bsr	Insert_Weapon
	Addq.l	#2,sp
	Rts
	
Ins50	Moveq	#$80,d0
	Moveq	#$c0,d1
	Moveq	#$00,d2
	Moveq	#$40,d3
	Moveq	#4,d4
	Bra.s	Do_Center_Mid2
Ins51	Moveq	#$a0,d0
	Moveq	#$e0,d1
	Moveq	#$20,d2
	Moveq	#$60,d3
	Moveq	#4,d4
	Bra.s	Do_Center_Mid2
Ins52	Moveq	#$10,d0
	Moveq	#$50,d1
	Moveq	#$90,d2
	Moveq	#$d0,d3
	Moveq	#4,d4
	Bra.s	Do_Center_Mid2
Ins53	Moveq	#$30,d0
	Moveq	#$70,d1
	Moveq	#$b0,d2
	Moveq	#$f0,d3
	Moveq	#4,d4
	Bra.s	Do_Center_Mid2
Ins202	Moveq	#$10,d0
	Moveq	#$20,d1
	Moveq	#$c0,d2
	Moveq	#$80,d3
	Moveq	#4,d4
	Bra.s	Do_Center_Mid2
Ins203	Moveq	#$40,d0
	Moveq	#$90,d1
	Moveq	#$60,d2
	Moveq	#$a0,d3
	Moveq	#4,d4
	Bra.s	Do_Center_Mid2
Ins204	Move.w	Seed(a4),d0
	Ror.w	#3,d0
	Move.w	d0,Seed(a4)
	Move.w	Seed(a4),d1
	Ror.w	#3,d1
	Move.w	d1,Seed(a4)
	Move.w	Seed(a4),d2
	Ror.w	#3,d2
	Move.w	d2,Seed(a4)
	Move.w	Seed(a4),d3
	Ror.w	#3,d3
	And.w	#$ff,d0
	And.w	#$ff,d1
	And.w	#$ff,d2
	And.w	#$ff,d3
	Moveq	#4,d4
Do_Center_Mid2
	Move.w	d4,d7
	Movem.w	d0-d3,-(sp)
.Loop	Move.w	(sp)+,d2
	Movem.w	Aln_X(a2),d0-d1
	Moveq	#8,d3
	Move.w	#0,d4
	Move.w	#96,d5
	MOve.w	d7,-(sp)
	Bsr	Insert_Weapon_If_Above_Screen
	MOve.w	(sp)+,d7
	Subq.w	#1,d7
	Bne.s	.Loop
	Rts
	
Ins47	Moveq	#-20,d0
	Moveq	#40,d1
	Bra.s	Ins44
Ins48	Moveq	#-10,d0
	Moveq	#40,d1
	Bra.s	Ins44
Ins49	Moveq	#0,d0
	Moveq	#40,d1
	Bra.s	Ins44
	
	
Ins45	Moveq	#13,d0
	Moveq	#8,d1
	Bra.s	Ins44
Ins46	Moveq	#17,d0
	Moveq	#8,d1
;	Bra.s	Ins44
	
; Offsets for x/y in d0/d1 - Fire straight down
Ins44	Add.w	Aln_X(a2),d0
	Add.w	Aln_Y(a2),d1
	Moveq	#$80,d2
	Moveq	#8,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bra	Insert_Weapon
	
Ins41	Moveq	#0,d0
	Bra	Planeup_Shots
Ins42	Moveq	#$10,d0
	Bsr	Planeup_Shots
	Moveq	#$20,d0
	Bra	Planeup_Shots
	
Ins43	Movem.w	Aln_X(a2),d0-d1
	Add.w	#16,d0
	Add.w	#14,d1
	Move.l	Aln_Link(a2),a2
	Move.b	Aln_Rotnumber(a2),d2			; Hovercraft fires
	Lsl.w	#4,d2
	Moveq	#10,d3
	Moveq	#4,d4
	Moveq	#2,d5
	Bra	Insert_Weapon
	
Ins23	
	Movem.w	Aln_X(a2),d0-d1
	Bsr	Get_Angle_From_Alien_To_Ship
	Add.w	#3,d0
	Moveq	#4,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Add.w	#32,d1
	Bsr	Insert_Weapon
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#47,d0
	Bsr	Get_Angle_From_Alien_To_Ship
	Moveq	#4,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Add.w	#32,d1
	Bra	Insert_Weapon

Ins15	Moveq	#0,d3
	Bra.s	Big_Tank_Fired
Ins16	Moveq	#$20,d3
	Bra.s	Big_Tank_Fired
Ins17	Moveq	#$40,d3
	Bra.s	Big_Tank_Fired
Ins18	Moveq	#$60,d3
	Bra.s	Big_Tank_Fired
Ins19	Moveq	#$80,d3
	Bra.s	Big_Tank_Fired
Ins20	Moveq	#$a0,d3
	Bra.s	Big_Tank_Fired
Ins21	Moveq	#$c0,d3
	Bra.s	Big_Tank_Fired
Ins22	Moveq	#$e0,d3

Big_Tank_Fired
	Move.w	d3,d2
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#16,d0
	Add.w	#16,d1
	Moveq	#6,d3
	Moveq	#4,d4
	Moveq	#2,d5
	Bra	Insert_Weapon

Ins9	Moveq	#10,d0
	Moveq	#10,d1
	Bra.s	Ins_Second
Ins10	Moveq	#14,d0
	Moveq	#10,d1
	Bra.s	Ins_Second
Ins11	Moveq	#-14,d0
	Moveq	#20,d1
	Bra.s	Ins_Second
Ins12	Moveq	#2,d0
	Moveq	#20,d1
	Bra.s	Ins_Second
Ins13	Moveq	#-30,d0
	Moveq	#20,d1

;Straight down
Ins_Second
	Movem.w	Aln_X(a2),d2-d3
	Add.w	d0,d2
	Add.w	d1,d3
	Move.w	d2,d0
	Move.w	d3,d1
	Moveq	#$80,d2
	Moveq	#7,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bra	Insert_Weapon

Ins14	Movem.w	Aln_X(a2),d0-d1
	Moveq	#0,d2
	Move.b	Aln_Rotnumber(a2),d2
	Lsl.w	#2,d2
	Lea	Cannon_Fire_Offsets(pc),a3
	Add.w	(a3,d2),d0	
	Add.w	2(a3,d2),d1	
	Lsl.w	#2,d2
	Moveq	#5,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bsr	Insert_Weapon
	Move.w	#Trendy_Bolts_Anm_Set,Aln_Anmset(a6)
	Move.w	#5,Aln_Shite+4(a6)
	Rts
	
Ins5	Moveq	#$c0,d2
	Bra.s	Do_Cannon_End_Level_Shot
Ins6	Moveq	#$a0,d2
	Bra.s	Do_Cannon_End_Level_Shot
Ins7	Moveq	#$60,d2
	Bra.s	Do_Cannon_End_Level_Shot
Ins8	Moveq	#$40,d2

Do_Cannon_End_Level_Shot
	Movem.w	Aln_X(a2),d0-d1
	Moveq	#6,d3
	Moveq	#4,d4
	Moveq	#44,d5
	Bra	Insert_Weapon


Ins28	Movem.w	Aln_X(a2),d0-d1
	Moveq	#10,d2
	Moveq	#6,d3
	Moveq	#4,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Move.w	#8,-(sp)
.Loop	Movem.w	2(sp),d0-d5
	Bsr	Insert_Weapon
	Add.w	#$20,6(sp)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	St	(a2)
	Lea	14(sp),sp
	Rts

Ins1	Movem.w	Aln_X(a2),d0-d1
	Add.w	#8,d0
	Add.w	#8,d1
	Move.b	Aln_Rotnumber(a2),d2
	Lsl.w	#4,d2
	Moveq	#7,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bra	Insert_Weapon

Ins0	Movem.w	Aln_X(a2),d0-d1
	Cmp.w	#0,Aln_Anmset(a2)
	Bne.s	.Not_Helichopper
	Add.w	#16,d0
	Add.w	#16,d1
.Not_Helichopper
	Move.b	Aln_Rotnumber(a2),d2
	Lsl.w	#4,d2
	Moveq	#5,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bra	Insert_Weapon

Ins2	Movem.w	Aln_X(a2),d0-d1
	Bsr	Get_Angle_From_Alien_To_Ship
	Move.w	d2,-(sp)
	Moveq	#5,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Bsr	Insert_Weapon
	Move.w	(sp),d2
	Sub.w	#$10,d2
	Moveq	#5,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Movem.w	Aln_X(a2),d0-d1
	Bsr	Insert_Weapon
	Move.w	(sp)+,d2
	Add.w	#$10,d2
	Moveq	#5,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Movem.w	Aln_X(a2),d0-d1
	Bra	Insert_Weapon

Ins33	Moveq	#0,d6
	Bra.s	Ins3a
Ins34	Moveq	#1,d6
	Bra.s	Ins3a
Ins35	Moveq	#2,d6
	Bra.s	Ins3a
Ins36	Moveq	#3,d6
	Bra.s	Ins3a
Ins37	Moveq	#4,d6
	Bra.s	Ins3a
Ins38	Moveq	#5,d6
	Bra.s	Ins3a
Ins39	Moveq	#6,d6
	Bra.s	Ins3a
Ins40	Moveq	#7,d6
;	Bra.s	Ins3

INS3a	
	Move.b	Aln_Rotnumber(a2),d2
	Lsl.w	#4,d2
.Find	Tst.l	Aln_Prevlink(a2)
	Bmi.s	.Found
	Move.l	Aln_Prevlink(a2),a2
	Bra.s	.Find
.Found	Movem.w	Aln_X(a2),d0-d1
	Add.w	#12,d0
	Add.w	#12,d1
	Lsl.w	#2,d6
	Add.w	.T(pc,d6),d0
	Add.w	.T+2(pc,d6),d1
	Moveq	#7,d3
	Moveq	#0,d4
	Move.w	#Trendy_Bolts_Anm_Set,d5
	Bra	Insert_Weapon

.T	
	Dc.w	-8,-6
	Dc.w	+3,-6
	Dc.w	+6,-3
	Dc.w	+6,+3

	Dc.w	+4,+8
	Dc.w	-8,+8
	Dc.w	-12,+3
	Dc.w	-12,-3




; Angle offset in d6
Ins3	Move.b	Aln_Rotnumber(a2),d2
	Lsl.w	#4,d2
	Add.w	d6,d2
.Find	Tst.l	Aln_Prevlink(a2)
	Bmi.s	.Found
	Move.l	Aln_Prevlink(a2),a2
	Bra.s	.Find
.Found	Movem.w	Aln_X(a2),d0-d1
	Add.w	#14,d0
	Add.w	#14,d1
	Moveq	#7,d3
	Moveq	#0,d4
	Move.w	#Trendy_Bolts_Anm_Set,d5
	Bra	Insert_Weapon


Ins112	Movem.w	Aln_X(a2),d0-d1
	Add.w	#10,d0
	Add.w	#28,d1
	Movem.w	d0-d1,-(sp)
	Move.w	#$80,d2
	Moveq	#6,d3
	Moveq	#0,d4
	Move.w	#2,d5
	Bsr	Insert_Weapon
	Move.w	#1,Aln_Dmg(a6)
	Movem.w	(sp)+,d0-d1
	Add.w	#20,d0
	Move.w	#$80,d2
	Moveq	#6,d3
	Moveq	#0,d4
	Move.w	#2,d5
	Bsr	Insert_Weapon
	Move.w	#1,Aln_Dmg(a6)
	Rts


Ins4	Movem.w	Aln_X(a2),d0-d1
	Add.w	#10,d0
	Add.w	#32,d1
	Movem.w	d0-d1,-(sp)
	Move.w	#$80,d2
	Moveq	#6,d3
	Moveq	#0,d4
	Move.w	#Bolt_Anm_Set,d5
	Bsr	Insert_Weapon
	Move.w	#1,Aln_Dmg(a6)
	Movem.w	(sp)+,d0-d1
	Add.w	#20,d0
	Move.w	#$80,d2
	Moveq	#6,d3
	Moveq	#0,d4
	Move.w	#Bolt_Anm_Set,d5
	Bsr	Insert_Weapon
	Move.w	#1,Aln_Dmg(a6)
	Rts

Search_Free_Alien_Slot
	Move.l	Alien_List_Search_Pointer+Data,a6
	Tst.w	Alien_search_Count+Data
	Beq.s	.Dummy
.Find	Tst.w	(a6)			
	Ble.s	.Found			
	Lea	Aln_End(a6),a6		
	Subq.w	#1,Alien_search_Count+Data
	Bne.s	.Find
.Dummy	Lea	Dummy_Sprite,a6	
.Found	Move.l	a6,Alien_List_Search_Pointer+Data
	Movem.l	d0-d7,-(sp)
	Movem.w	Clearr+Data,d0-d7
	Movem.l	d0-d7,(a6)
	Movem.l	d0-d7,32(a6)
	Movem.l	d0-d7,64(a6)
	Movem.l	d0-d1,96(a6)
	Movem.l	(sp)+,d0-d7
	Move.w	#$7fff,(a6)		
	St	Aln_Link(a6)		
	St	Aln_PrevLink(a6)	
	Rts

Ins24	Moveq	#$20,d0
	Bra.s	Two_Vector_Shots
Ins25	Moveq	#$18,d0
	Bra.s	Two_Vector_Shots
Ins26	Moveq	#$10,d0
	Bra.s	Two_Vector_Shots
Ins27	Moveq	#$08,d0
;	Bra.s	Two_Vector_Shots

Two_Vector_Shots
	Move.w	d0,d6
	Move.b	Aln_Rotnumber(a2),d2
	And.w	#$f,d2
	Lsl.w	#3,d2
	Lea	.Tab(pc,d2),a3
	Moveq	#0,d2
	Move.b	Aln_Rotnumber(a2),d2
	And.w	#$f,d2
	Lsl.w	#4,d2
	Movem.w	Aln_X(a2),d0-d1
	Moveq	#6,d3
	Moveq	#4,d4
	Moveq	#2,d5
	Movem.w	d0-d6,-(sp)
	Add.w	(a3)+,d0
	Add.w	(a3)+,d1
	Pea	(a3)
	Sub.w	d6,d2
	Bsr	Insert_Weapon
	Move.l	(sp)+,a3
	Movem.w	(sp)+,d0-d6
	Add.w	(a3)+,d0
	Add.w	(a3)+,d1
	Add.w	d6,d2
	Bra	Insert_Weapon

.Tab	
	Dc.w	5,12,20,12
	Dc.w	9,09,18,14
	Dc.w	9,06,14,15
	Dc.w	6,04,14,15
	Dc.w	11,01,11,17
	Dc.w	13,4,09,15
	Dc.w	15,6,07,13
	Dc.w	17,9,04,10
	Dc.w	20,12,03,12
	Dc.w	17,14,04,10
	Dc.w	15,16,06,7
	Dc.w	12,18,08,5
	Dc.w	11,19,11,4
	Dc.w	08,17,13,6
	Dc.w	06,15,16,8
	Dc.w	05,13,19,9


Ins29	Moveq	#$08,d0
	Bra.s	Planeup_Shots
Ins30	Moveq	#$18,d0
	Bra.s	Planeup_Shots
Ins31	Moveq	#$28,d0
	Bra.s	Planeup_Shots
Ins32	Moveq	#$30,d0
;	Bra.s	Planeup_Shots

Planeup_Shots
	Move.w	d0,d6
	Move.w	#$80,d2
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#30,d1
	Moveq	#6,d3
	Moveq	#4,d4
	Moveq	#2,d5
	Movem.w	d0-d6,-(sp)
	Add.w	d6,d2
	Add.w	#10,d0
	Bsr	Insert_Weapon
	Movem.w	(sp)+,d0-d6
	Add.w	#50,d0
	Sub.w	d6,d2
	Bra	Insert_Weapon

**********************************************************
Add_Ten_Point_Accumalate
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Move.w	Ten_Point_Accumolate(a3),d0	; Get number of times ya hit summat
	Beq.s	.Exit				; No need to do anything if ya hit nothing
	Move.l	sp,a2				; Pointer to BCD i'm gonna create
	Clr.l	-(sp)
	Mulu	#10,d0				; Accumalator multiplied by 10
	Divu	#100,d0				; I dont reckon on ya hitting stuff 100 times in a game loop!
	Move.b	d0,d1
	Clr.w	d0
	Swap	d0
	Divu	#10,d0
	Lsl.b	#4,d0
	Move.b	d0,-1(a2)
	Move.b	d1,-2(a2)			; Make the BCD number and store !
	Lea	Score+4(a3),a1
	Abcd	-(a2),-(a1)
	Abcd	-(a2),-(a1)			; Add up to score!
	Abcd	-(a2),-(a1)
	Abcd	-(a2),-(a1)
	Addq.l	#4,sp
.Exit	Rts

**********************************************************
Weapons_To_Aliens
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
	Bsr.s	.Do
	Rts

.Do	Jsr	Wait_For_Gpu
	Lea	Weapon_Params,a0
	Lea	Weapon_Active_List(a3),a1
	Not.b	Even_Odd_Weapon_Check(a3)
	Beq.s	.Even
	Addq.l	#4,a1
.Even	Move.l	a1,(a0)+
	Lea	Weapon_Check_Table(a4),a1
	Move.l	a1,(a0)+
	Move.l	#Aln_Collision_Box,(a0)+
	Move.l	#Wep_Box,(a0)+
	Lea	Wep_Hit_List(a4),a1
	Move.l	a1,(a0)+
	Move.l	a1,Wep_Hit_Listp(a4)
	Clr.l	WEPCOL_POINTER
	Lea	Gpu_Weapon_Collision,a0
	Jsr	Start_Gpu
	Move.l	a3,Player_Use(a4)
	Clr.w	Ten_Point_Accumolate(a3)

.Another_Alien
	Move.l	Wep_Hit_Listp(a4),a0
.Wait_For_Pointer
	Move.l	WEPCOL_POINTER,d0
	Cmp.l	a0,d0
	Ble.s	.Wait_For_Pointer
	Move.l	(a0)+,d0
	Bmi.s	.Done_Collision_Stuff
	Move.l	(a0)+,d1
	Bmi.s	.Done_Collision_Stuff
	Move.l	a0,Wep_Hit_Listp(a4)
	Move.l	d0,a0
	Move.l	d1,a1
	Movem.w	Wep_X(a0),d0-d1
	Bsr.s	This_Weapon_Hit
	Bra.s	.Another_Alien
.Done_Collision_Stuff
	Move.l	Crator_Tabp(a4),a0
	St	(a0)
	Move.l	Explosion_Tabp(a4),a0
	St	(a0)
	Rts

;-------------------------
	Ifd	Not_Jaguar
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
.Do	Move.l	a3,Player_Use(a4)
	Clr.w	Ten_Point_Accumolate(a3)
	Lea	Weapon_Active_List(a3),a0
	Not.b	Even_Odd_Weapon_Check(a3)
	Beq.s	.Even
	Addq.l	#4,a0
.Even
Weapon_Loop	
	Tst.b	(a0)
	Bmi.s	.No_More_Weapons
	Pea	8(a0)
	Move.l	(a0),a0
	Movem.w	Wep_Box(a0),d0-d3
	Bsr.s	Compare_This_Weapon
	Move.l	(sp)+,a0
	Bra.s	Weapon_loop
.No_More_Weapons
	Move.l	Crator_Tabp(a4),a0
	St	(a0)
	Move.l	Explosion_Tabp(a4),a0
	St	(a0)
	Rts

Compare_This_Weapon
	Lea	Weapon_Check_Table(a4),a5
Alien_Loop	
	Tst.b	(a5)
	Bmi	.No_More_Aliens
	Move.l	(a5)+,a1
	Tst.w	(a1)
	Ble.s	Alien_Loop
	Pea	(a5)
	Movem.w	Aln_Collision_Box(a1),d4-d7
	Cmp.w	d2,d4
	Bgt	.Missed
	Cmp.w	d0,d6
	Blt	.Missed
	Cmp.w	d3,d5		
  	Bgt	.Missed
	Cmp.w	d1,d7
	Blt	.Missed
	Endc
;-------------------------

This_Weapon_Hit
;-----------------
; Jaguar bit only!
	Tst.w	(a1)
	Bgt.s	.Not_Dead
	Rts
.Not_Dead
;-----------------
	Tst.b	Aln_Hit(a1)
	Bne.s	.Hit_Already
	Move.l	a1,a6
	St	Aln_Hit(a6)
	Lea	Sprite_Child_Parent_HitDMG_Table,a2
	Move.w	Aln_Sprite(a1),d3
	Add.w	d3,d3
	Move.b	(a2,d3),d4				; Previous count in d0
	Beq.s	.No_Previous
.Prev_Loop
	Move.l	Aln_Prevlink(a6),a6
	St	Aln_Hit(a6)
	Subq.b	#1,d4
	Bne.s	.Prev_Loop
.No_Previous
	Move.b	1(a2,d3),d4				; After count in d0
	Beq.s	.Hit_Already
	Move.l	a1,a6
.Next_Loop
	Move.l	Aln_Link(a6),a6
	St	Aln_Hit(a6)
	Subq.b	#1,d4
	Bne.s	.Next_Loop
.Hit_Already
	Move.l	Player_Use(a4),a3
	Move.l	Explosion_Tabp(a4),a2
	Move.w	Wep_Explosion_Num(a0),(a2)+
	Clr.w	(a2)+
	Cmp.w	#6,Wep_Explosion_Num(a0)
	Bne.s	.Nx
	Sub.w	#16,d0
	Sub.w	#16,d1
	Bra.s	.Nx2	
.Nx	Cmp.w	#5,Wep_Explosion_Num(a0)
	Bne.s	.Nx2
	Lea	Lazer_Hit_Sfx,a6
	Jsr	Play_This_Sample
	Bra.s	.Nx3
.Nx2	Tst.b	Is_Weapon_A_Homing_Missle(a0)
	Bne.s	.Special_Sfx
	Tst.b	Is_Weapon_A_Rocket(a0)
	Bne.s	.Special_Sfx
	Lea	Shot_Hit_Sfx,a6
	Jsr	Play_This_Sample
	Bra.s	.Nx3
.Special_Sfx
	Lea	Misc_Weapon_Hit_SFX,a6
	Jsr	Play_This_Sample
.Nx3	Move.w	d0,(a2)+
	Move.w	d1,(a2)+
	Move.l	a2,Explosion_Tabp(a4)
	Bsr	Process_Hit
	Bgt.s	.Did_Not_Die
	Bsr	Add_Score_For_alien	
	Bsr	Process_Dead_Alien
	Bra.s	.No_More_Checking_For_A_Hit_Weapon
.Missed	Move.l	(sp)+,a5
;----------
; Uncomment if not jaguar !

;	Bra	Alien_Loop
;----------
.Did_Not_Die
	Addq.w	#1,Ten_Point_Accumolate(a3)
.No_More_Checking_For_A_Hit_Weapon
;----------
; Uncomment if not jaguar !
;	Addq.l	#4,sp
;----------
.No_More_Aliens
	Rts

Process_Hit
	Tst.b	Is_Weapon_A_Homing_Missle(a0)
	Beq.s	.Not_A_Homing
	Tst.b	Is_Weapon_A_Rocket(a0)
	Bne.s	.Not_A_Homing
	MOve.l	Player_Use(a4),a3
	Subq.b	#1,Num_Homes(a3)
.Not_A_Homing
	Moveq	#0,d5
 	Move.b	(a0),d5			
	Clr.b	(a0)			
 	Bsr.s	Search_Prev_Link
	Sub.w	d5,Aln_Half_Damage(a1)
	Bcc.s	.No_Next
	Move.l	a1,a6
.Link_Loop
	Lea	Sprite_Child_Parent_HitDMG_Table,a2
	Move.w	Aln_Sprite(a1),d4
	Add.w	d4,d4
	Move.b	(a2,d4),d0				; Previous count in d0
	Beq.s	.No_Previous
.Prev_Loop
	Move.l	Aln_Prevlink(a6),a6
	St	Aln_Half_Damage(a6)
	Subq.b	#1,d0
	Bne.s	.Prev_Loop
.No_Previous
	Move.b	1(a2,d4),d0				; After count in d0
	Beq.s	.No_Next
	Move.l	a1,a6
.Next_Loop
	Move.l	Aln_Link(a6),a6
	St	Aln_Half_Damage(a6)
	Subq.b	#1,d0
	Bne.s	.Next_Loop
.No_Next
	Sub.w	d5,(a1)			
	Rts

Search_Prev_Link
	Lea	Search_Prev_Alien_Table,a6
	Move.w	Aln_Anmset(a1),d6
	Tst.b	(a6,d6)
	Bne.s	.No_More
.Search_First
	Move.l	Aln_Prevlink(a1),d6
	Ble.s	.No_More
	Move.l	d6,a1
	Bra.s	.Search_First
.No_More
	Rts

Add_Score_For_Alien
	Move.w	Aln_Sprite(a1),d0
	Lea	Scoretable,a6	
	Add.w	d0,d0
	Add.w	d0,d0
	Lea	$4(a6,d0),a6		
	Move.l	Player_Use(a4),a3
	Lea	Score+4(a3),a3
	Move.b	#0,Ccr
	Abcd	-(a6),-(a3)	
	Abcd	-(a6),-(a3)	
	Abcd	-(a6),-(a3)	
	Abcd	-(a6),-(a3)	
	Rts

Process_Dead_Alien
	Move.l	Aln_X(a1),Aln_X_Save(a4)
	Move.w	Aln_Sprite(a1),d1
	Move.w	d1,Aln_Sprite_Save(a4)
	Lea	Explosion_And_Crator_Offset_Table,a6
	Add.w	d1,d1
	Move.b	(a6,d1),d2
	Move.b	$1(a6,d1),d3
	Ext.w	d2
	Ext.w	d3
	Add.w	d2,Aln_X_Save(a4)
	Add.w	d3,Aln_X_Save+2(a4)
	Lea	Dead_Alien_Jump_Table,a6
	Moveq	#0,d0
	Asr.w	#1,d1
	Move.b	(a6,d1),d0
	Add.w	d0,d0
	Add.w	d0,d0
	Jmp	.Jt(pc,d0)

.Jt	Bra	DoExplosion32
	Bra	Explosion32_Crator32
	Bra	DoExplosion64
	Bra	Explosion64_Crator64
	Bra	Bolt
	Bra	Cannon
	Bra	Turret
	Bra	Do_Car
	Bra	Train_Carraige
	Bra	Second_Guardian
	Bra	Bomb8way
	Bra	Casket
	Bra	Bigpowup
	Bra	James_Brown_Is_Dead
	Bra	Tree_Is_Dead
	Bra	No_Effect
	Bra	Void_Sprite32
	Bra	Void_Sprite64
	Bra	Third_Guardian
	Bra	Scafhit
	Bra	Powmid4_Killed
	Bra	Tank_Base_Killed
	Bra	Spinny_Stuff_Dead
	Bra	Grey_Tank
	Bra	Massive_boat_fucked
	Bra	Upper_Tank_Killed
	Bra	Lev4_Child
	Bra	End_Baddy_Child
	Bra	Endbaddy4
	Bra	Wing5
	Bra	End_Baddy_Child5
	Bra	End_Baddy_5_Dead
	Bra	Head_Hit
	Bra	Big_Plane_Destroyed
	Bra	Lev7_Baddy_dead
	Bra	Spider_Dead

	Bra	Wing8_Dead
	Bra	Wing8_Dead_Slide
	Bra	Lev8_Guard_Dead
	Bra	Lev8_Fuxed

	Bra	Floaty_Eye

;0-32*32 Explosion
;1-32*32 Explosion with 32*32 crator
;2-64*64 Explosion 
;3-64*64 Explosion with 64*64 Crator
;4- Bolt
;5- Cannon
;6- Turret
;7- CAR!
;8- Back train/Carraige
;9- Bits for second level guardian
;10-Bomb 8way
;11-Casket
;12-Big-power-up
;13-End Level 1 !
;14-Tree
;15-No effect
;16-Void it (32)!
;17-Void it (64)!
;18-Third Guardian
;19-SCAFOLDING LEFT/RIGHT!
;20-Pow_Mid4 killed
;21-Base tanke
;22-Spinny_Stuff_Dead
;23-Grey tank dead !
;24-Massive boat fucked
;25-Upper tank
;26-Level 4 child sprites
;27- End baddy child
;28- Endbaddy4
;29- Wing baddy 5
;30 -End_Baddy_Child5
;31  End baddy 5 dead
;32- Head hit level 6
;33- Big_Plane_Destroyed
;34- Level 7 baddy
;35- Spider dead
;36-Wing8_Dead
;37-Wing8_Dead_Slide
;38-Lev8_Guard_Dead
;39-Lev8 fucked-complete game
;40-Floaty_Eye

	Nop

Floaty_Eye
	Tst.l	Aln_Prevlink(a1)
	Ble.s	.Normal_Eye
	Move.l	Aln_Prevlink(a1),a6
	St	Aln_Link(a6)
	Move.l	#.Wait,Aln_Seqp(a6)
	Clr.w	Aln_Seqdec(a6)	
.Normal_Eye
	Bra	DoExplosion32	

.Wait	Abs_Move	0,1,260
	End_Seq

Lev8_Fuxed
	Subq.w	#1,Num_Guardians_Active(a4)
	Bne.s	.Skip_Scroll	
	Bsr	Boss_Dead
.Skip_Scroll	
	Bsr	Render_Sprites_Inactive
	Move.w	#$7fff,Aln_Dmg(a1)
	Move.w	#$7fff,Aln_Half_Damage(a1)
	Move.l	#Dead_8,Aln_Seqp(a1)
	Clr.w	Aln_Seqdec(a1)
	Move.l	Aln_Link(a1),a3
	Move.w	#$7fff,Aln_Dmg(a3)
	Move.w	#$7fff,Aln_Half_Damage(a3)
	Rts

Lev8_Guard_Dead
	Pea	(a1)
	Bsr	Void_Sprite64
	Move.l	(sp)+,a1
	Move.l	a1,a3
.Loop0	Tst.l	Aln_Prevlink(a3)
	Ble.s	.Found_Last
	Move.l	Aln_Prevlink(a3),a3
	Bra.s	.Loop0
.Found_Last
	Addq.b	#1,Aln_Shite+20(a3)
	Cmp.b	#2,Aln_Shite+20(a3)
	Bne.s	.Not_Done	
	Sf	Aln_Hitoveride(a3)
	Move.l	Aln_Link(a3),a3	
	Sf	Aln_Hitoveride(a3)
	Move.l	Aln_Link(a3),a3	
	Move.l	Aln_Link(a3),a3	
	Move.l	#Raidens_Last_Fuckoff_Mental,Aln_Seqp(a3)
	Clr.w	Aln_Seqdec(a3)
.Not_Done	
	Rts


Wing8_Dead
	Bra	Void_Wing

Wing8_Dead_Slide
	Bsr	Void_Wing
	Move.l	Aln_Link(a1),a3
	Move.l	Aln_Link(a3),a3
	Move.l	Aln_Link(a3),a3
	Move.l	Aln_Link(a3),a3
	Movem.w	Aln_X(a1),d4-d5
	Movem.w	Aln_X(a3),d2-d3
	Sub.w	d2,d4
	Spl	d6
	Bpl.s	.Abs_DX
	Neg.w	d4
.Abs_DX	Sub.w	d3,d5
	Spl	d7
	Bpl.s	.Abs_DY
	Neg.w	d5
.Abs_DY	Cmp.w	d4,d5
	Sle	d3
	Ble.s	.DeltaY_Ok
	Exg	d4,d5
.Deltay_Ok
	Move.w	d4,-(sp)
	Swap	d5
	Clr.w	d5
	Divu	d4,d5
	And.l	#$ffff,d5	
	Moveq	#1,d4
	Swap	d4
	Tst.b	d3
	Bne.s	.No_Swap	
	Exg	d4,d5
.No_Swap
	Tst.b	d6
	Bne.s	.No_Neg0
	Neg.l	d4
.No_Neg0
	Tst.b	d7
	Bne.s	.No_Neg1
	Neg.l	d5
.No_Neg1
	Moveq	#0,d6
	Movem.l	d4-d6,Aln_Shite(a3)	
	Move.w	(sp)+,Aln_Seqdec(a3)
	Move.l	#Fire_And_Forget,Aln_Seqp(a3)
	Move.w	#18,Aln_Wave(a3)
	Rts			

Fire_And_Forget
	Wait		50
.Hold	Start_Link_Anim	1
	Fire_Ship	171
	Stop_Link_Anim	1
	Wait		40
	Branch		.Hold



Void_Wing
	Pea	(a1)
	Bsr	Void_Sprite64
	MOve.l	(sp),a1
	Move.l	Aln_Link(a1),a1
	Bsr	Void_Sprite64
	Move.l	(sp)+,a1
	Move.l	a1,a3
.Loop0	Tst.l	Aln_Prevlink(a3)
	Ble.s	.Found_Last
	Move.l	Aln_Prevlink(a3),a3
	Bra.s	.Loop0
.Found_Last
	Addq.b	#1,Aln_Shite+20(a3)
	Cmp.b	#4,Aln_Shite+20(a3)
	Bne.s	.Not_All_Dead	
	Move.l	#Madder_Than_Mad_Seq8,Aln_Seqp(a3)
	Clr.w	Aln_Seqdec(a3)	
	Clr.b	Aln_Shite+20(a3)
	
	Rept	4
	Move.l	Aln_Link(a3),a3	
	Endr
	Sf	Aln_HitOveride(a3)
	Move.l	Aln_Link(a3),a3	
	Sf	Aln_HitOveride(a3)
.Not_All_Dead	
	Rts

Madder_Than_Mad_Seq8
	Start_Link_Anim	2
	Abs_Move	0,2,60
	Stop_Link_Anim	2
	Abs_Move	0,1,60
	Start_Link_Anim	2
	Abs_Move	0,0,60
	Stop_Link_Anim	2
	Abs_Move	0,1,60
	Branch		Madder_Than_Mad_Seq8



Spider_Dead
	Tst.l	Rel_Base(a4)
	Beq.s	.No_Spider
	Move.w	Num_Spiders(a4),d3
	Move.l	a1,a3
	Tst.l	Aln_Prevlink(a3)
	Ble.s	.Found
	MOve.l	Aln_Prevlink(a3),a3
.Found	Move.w	Aln_Shite+20(a3),d4
	Eor.w	d4,d3
	Move.w	d3,Num_Spiders(a4)
.No_Spider
	Bra	DoExplosion32	


Lev7_Baddy_dead
	Subq.w	#1,Num_Guardians_Active(a4)
	Bne.s	.Skip_Scroll	
	Bsr	Boss_Dead
.Skip_Scroll	
	Bsr	Render_Sprites_Inactive
	Move.w	#$7fff,Aln_Dmg(a1)
	Move.w	#$7fff,Aln_Half_Damage(a1)
	Move.l	#Dead_7,Aln_Seqp(a1)
	Clr.w	Aln_Seqdec(a1)
	Pea	(a1)
.Skip	Tst.l	Aln_Link(a1)
	Ble.s	.Done
	Move.l	Aln_Link(a1),a1
	Bra.s	.Skip
.Done	Bsr	Void_It
	Move.l	(sp)+,a1
	Rts

Big_Plane_Destroyed
	Bsr	Render_Sprites_Inactive
	Move.w	#$7fff,Aln_Dmg(a1)
	Move.w	#$7fff,Aln_Half_Damage(a1)
	Move.l	#Dead_Plane_Fuxter_Knuckles,Aln_Seqp(a1)
	Clr.w	Aln_Seqdec(a1)
	Rts

Head_Hit
	Clr.b	Aln_Track_Val(a1)
	Move.l	a1,a3
.Search_Prev_Link
	Tst.l	Aln_Prevlink(a3)
	Ble.s	.Found_Prevlink
	Move.l	Aln_Prevlink(a3),a3
	Bra.s	.Search_Prev_Link
.Found_Prevlink
	Bsr	Void_It
	Bsr	Explosion64
	Addq.b	#1,Aln_Shite+20(a3)
	Cmp.b	#2,Aln_Shite+20(a3)
	Bne.s	.Not_Dead
	Subq.w	#1,Num_Guardians_Active(a4)
	Bne.s	.Skip_Scroll	
	Bsr	Boss_Dead
.Skip_Scroll	
	Bsr	Render_Sprites_Inactive
	Move.l	#Dead_End_Level6_Seq,Aln_Seqp(a3)
	Clr.w	Aln_Seqdec(a3)
.Not_Dead
	Rts

End_Baddy_5_Dead
	Bsr	Kill_2_Childs_For_Baddys
	Subq.w	#1,Num_Guardians_Active(a4)
	Bne.s	.Skip_Scroll	
	Bsr	Boss_Dead
.Skip_Scroll	
	Bsr	Render_Sprites_Inactive
	Move.w	#$7fff,(a1)
	Move.w	#$7fff,Aln_Half_Damage(a1)
	Clr.w	Aln_Seqdec(a1)
	Move.l	#Dead_End_Level5_Seq,Aln_Seqp(a1)
.Loop2	Tst.l	Aln_Link(a1)
	Bmi.s	.Done
	Move.l	Aln_Link(a1),a1
	Bra.s	.Loop2
.Done	Bsr	Void_It
	Rts


Kill_2_Childs_For_Baddys
	Push
	Move.l	Destruct_Table(a4),a1
	Tst.b	Aln_Shite+18(a1)
	Beq.s	.No_Sprite1
	Tst.w	(a1)
	Ble.s	.No_Sprite1
	Clr.w	(a1)
	Bsr	Add_Score_For_Alien
	Bsr	Process_Dead_Alien
.No_Sprite1
	Move.l	Destruct_Table+4(a4),a1
	Tst.b	Aln_Shite+18(a1)
	Beq.s	.No_Sprite2
	Tst.w	(a1)
	Ble.s	.No_Sprite2
	Clr.w	(a1)
	Bsr	Add_Score_For_Alien
	Bsr	Process_Dead_Alien
.No_Sprite2
	Pull
	Rts

End_Baddy_Child5
	Subq.w	#1,Num_Guardians_Active(a4)
	Bne.s	.Skip_Scroll	
	Bsr	Boss_Dead
.Skip_Scroll	
	Bra	Explosion64_Crator64




Wing5	Pea	(a1)
.Loop	Tst.l	Aln_Prevlink(a1)
	Ble.s	.Done
	Move.l	Aln_Prevlink(a1),a1
	Bra.s	.Loop
	
.Done	Addq.b	#1,Aln_Shite+20(a1)
	Cmp.b	#2,Aln_Shite+20(a1)
	Bne.s	.Not_done
	MOve.w	#500,Aln_Dmg(a1)
	MOve.w	#250,Aln_Half_Damage(a1)
.Not_done
	Move.l	(sp),a1
	Cmp.w	#188,Aln_Anmset(a1)
	Beq.s	.Left_Wing
.Right_Wing
	Bsr	Void_It
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Bsr	Void_It
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Bsr	Void_It
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Bsr	Void_It
	Move.l	Aln_Link(a1),a1
	Bsr	Void_It
	Move.l	(sp)+,a1
	Bra	Explosion64
.Left_Wing	
	Bsr	Void_It
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Bsr	Void_It
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Bsr	Void_It
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Bsr	Void_It
	Move.l	Aln_Link(a1),a1
	Bsr	Void_It
	Move.l	(sp)+,a1
	Bra	Explosion64


Endbaddy4
	Pea	(a1)
	Bsr	Kill_2_Childs_For_Baddys
	Subq.w	#1,Num_Guardians_Active(a4)
	Bne.s	.Skip_Scroll	
	Bsr	Boss_Dead
.Skip_Scroll	
	Bsr	Render_Sprites_Inactive
	Move.w	#$7fff,(a1)
	Move.w	#$7fff,Aln_Half_Damage(a1)
	Clr.w	Aln_Seqdec(a1)
	Move.l	#Dead_End_Level4_Seq,Aln_Seqp(a1)
.Loop2	Tst.l	Aln_Link(a1)
	Ble.s	.Done
	Move.w	#$7fff,(a1)
	Move.w	#$7fff,Aln_Half_Damage(a1)
	Move.l	Aln_Link(a1),a1
	Bra.s	.Loop2
.Done	Bsr	Void_It
	Move.l	(sp)+,a1
	Rts

End_Baddy_Child
	Subq.w	#1,Num_Guardians_Active(a4)
	Bne.s	.Skip_Scroll	
	Bsr	Boss_Dead
.Skip_Scroll	
	Bra	DoExplosion64


Lev4_Child
	Move.l	a1,a6
	Move.l	Aln_Prevlink(a6),a6
	Tst.l	Aln_Prevlink(a6)
	Ble.s	End_Baddy_Child
.Srch	Tst.l	Aln_Prevlink(a6)
	Ble.s	.No_Prevlink
	Move.l	Aln_Prevlink(a6),a6
	Bra.s	.Srch	
.No_Prevlink
	Addq.b	#1,Aln_Shite+21(a6)
	Cmp.b	#6,Aln_Shite+21(a6)
	Bne.s	.No_Mad_baddy
;	Move.w	#400,Aln_Dmg(a6)
;	Move.w	#200,Aln_Half_Damage(a6)
	Moveq	#10-1,d6
.Loop	Move.l	Aln_Link(a6),a6
	Dbra	d6,.Loop
	Clr.w	Aln_Seqdec(a6)
	Move.l	#Mad_4_Seq,Aln_Seqp(a6)
.No_Mad_baddy
	Bra	Void_Sprite32



Upper_Tank_Killed
	Tst.l	Aln_Link(a1)
	Bpl.s	.No_Kill
	Move.l	Crator_Tabp(a4),a6
	Move.w	#5,(a6)+
	Move.w	Aln_Sprite_Save(a4),(a6)+
	Move.l	Aln_X_Save(a4),(a6)+
	Move.l	a6,Crator_Tabp(a4)
	Bsr	Explosion32
	Rts
.No_Kill
	MOve.w	#1,(a1)
	Pea	(a1)
	Move.l	Aln_Link(a1),a1
	St	(a1)
	St	Aln_Prevlink(a1)
	Bsr	Explosion32
	Move.l	(sp)+,a1
	St	Aln_Link(a1)
	Rts



Massive_boat_fucked
	Pea	(a1)
	Move.l	Aln_LInk(a1),a1
	Move.l	Aln_LInk(a1),a1
	Move.l	Aln_LInk(a1),a1
	Move.w	#-1,Aln_Anmset(a1)
	MOve.w	#-1,Aln_Sprite(a1)
	Move.l	Aln_LInk(a1),a1
	Move.w	#-1,Aln_Anmset(a1)
	MOve.w	#-1,Aln_Sprite(a1)
	Move.l	Aln_LInk(a1),a1
	Move.w	#-1,Aln_Anmset(a1)
	MOve.w	#-1,Aln_Sprite(a1)
	Move.l	(sp)+,a1
	Bsr	Render_Sprites_Inactive
	Move.w	#$7fff,(a1)
	Move.w	#798,Aln_Sprite(a1)
	Move.w	#235,Aln_Anmset(a1)
	Move.w	#300,Aln_Seqdec(a1)
	Move.l	#Fuck_Seq,Aln_Seqp(a1)
	Move.l	Explosion_Tabp(a4),a3
	Pea	(a6)
	Lea	Massive_Explosion_Sfx,a6
	Jsr	Play_This_Sample
	Move.l	(sp)+,a6
	Move.w	#9,(a3)+
	Move.w	#-1,(a3)+
	MOve.l	Aln_X(a1),(a3)+
	Add.w	#56,-4(a3)	
	Add.w	#30,-2(a3)	
	Move.l	a3,Explosion_Tabp(a4)
	Move.l	Power_Up_Posp(a4),a3
	Move.b	#6,(a3)+
	Move.b	#0,(a3)+
	MOve.l	Aln_X(a1),(a3)+
	Add.w	#46,-4(a3)	
	Add.w	#16,-2(a3)	
	Move.l	a3,Power_Up_Posp(a4)
	Rts

Grey_Tank
	Tst.l	Aln_Link(a1)
	Bpl.s	.No_Kill
	Move.l	Crator_Tabp(a4),a6
	Move.w	#4,(a6)+
	Move.w	Aln_Sprite_Save(a4),(a6)+
	Move.l	Aln_X_Save(a4),(a6)+
	Move.l	a6,Crator_Tabp(a4)
	Bsr	Explosion32
	Rts
.No_Kill
	MOve.w	#1,(a1)
	Pea	(a1)
	Move.l	Aln_Link(a1),a1
	St	(a1)
	Bsr	Explosion32
	Move.l	(sp)+,a1
	St	Aln_Link(a1)
	Rts


Spinny_Stuff_Dead
	Tst.l	Aln_Prevlink(a1)
	Ble	DoExplosion32
	Bsr	Void_It	
	Bra	Explosion32

Powmid4_Killed
	St	Stop_Cycle4(a4)
	Move.w	#$7fff,(a1)
	Clr.w	Aln_Seqdec(a1)
	Move.l	#Power4_Blowup_Seq,Aln_Seqp(a1)	

;	Move.l	Power_Up_Posp(a4),a2
	Move.l	Aln_Link(a1),a3

	Move.l	a3,Pow_Ins0(a4)
	
;	Move.w	#0,(a2)+
;	Move.l	Aln_X(a3),(a2)
;	Sub.w	#40,(a2)+	
;	Add.w	#10,(a2)+	

	Move.l	Aln_Link(a3),a3
	Move.l	a3,Pow_Ins1(a4)

;	Move.w	#$0200,(a2)+
;	Move.l	Aln_X(a3),(a2)
;	Add.w	#20,(a2)+	
;	Add.w	#10,(a2)+	
; 	Move.l	a2,Power_Up_PosP(a4)
;	Pea	(a1)
;	Move.l	Aln_Link(a1),a1
;	Bsr	Void_It
;	Move.l	Aln_Link(a1),a1
;	Bsr	Void_It
;	Move.l	(sp)+,a1
	Bra	Explosion64

Tank_Base_Killed
	Tst.l	Aln_Link(a1)
	Bpl.s	.No_Kill
	Bra	Explosion32_Crator32
.No_Kill
	MOve.w	#1,(a1)
	Pea	(a1)
	Move.l	Aln_Link(a1),a1
	St	(a1)
	Bsr	Explosion32
	Move.l	(sp)+,a1
	St	Aln_Link(a1)
	Rts


Tree_Is_Dead
	Move.l	Power_Up_Posp(a4),a2
	Move.b	ALN_POWNUM(a1),(a2)+
 	Addq.l	#1,a2
	Move.l	Aln_X(a1),(a2)+	
 	Move.l	a2,Power_Up_PosP(a4)
	Cmp.b	#1,This_Level(a4)
	Beq.s	.Angel
	Cmp.b	#4,This_Level(a4)
	Beq.s	.Angel
	Cmp.b	#6,This_Level(a4)
	Beq.s	.Angel
	Bra	DoExplosion32
.Angel	Push
	Move.l	Aliens_Insert_P(a4),a3	; Restore pointer !
	Move.w	#78,(a3)+		; Weapon number !
	Move.l	a1,(a3)+ 		; Start of this X/Y and shit !
	Move.w	Unique_Fire(a4),Aln_Unique_fire(a1)
	Move.w	Unique_Fire(a4),(a3)+
	Addq.w	#1,Unique_Fire(a4)
	Move.l	a3,Aliens_Insert_P(a4)	; Restore pointer !
	St	Aln_Hitoveride(a1)
	Bsr	DoExplosion32
	Move.w	#$7fff,(a1)
	Pull
	Rts

Void_Sprite32
	Bsr	Void_It	
	Bra	Explosion32
	
Void_Sprite64
	Cmp.w	#89,Aln_Anmset(a1)
	Bne.s	.Check_If_Anm90
	Move.l	Aln_Link(a1),a2
	Tst.w	Aln_Anmset(a2)
	Bmi.s	.Double_Killed
	Bra.s	.Not_Anm90
.Check_If_Anm90
	Cmp.w	#90,Aln_Anmset(a1)
	Bne.s	.Not_Anm90
	Move.l	Aln_Prevlink(a1),a2
	Tst.w	Aln_Anmset(a2)
	Bmi.s	.Double_Killed
.Not_Anm90
	Cmp.w	#120,Aln_Anmset(a1)
	Beq.s	.Turret_Cannon_Add
	Cmp.w	#124,Aln_Anmset(a1)
	Blt.s	.Not_Anm120
	Cmp.w	#128,Aln_Anmset(a1)
	Bgt.s	.Not_Anm120
.Turret_Cannon_Add
	Push
	Bsr	Explosion64
	Bsr	Void_It	
	Bsr	Check_Lev3cannon
	Pull
	Rts
.Not_Anm120
	Bsr	Void_It	
	Bra	Explosion64
.Double_Killed
	Bsr	Void_It	
	Move.l	a1,a2
.Search	Tst.l	Aln_Prevlink(a2)
	Bmi.s	.There
	Move.l	Aln_Prevlink(a2),a2
	Bra.s	.Search	
.There	
	Tst.w	Aln_Half_Damage(a2)
	Blt.s	.Damaged_2
	Move.w	#800,Aln_Dmg(a2)
	Move.w	#400,Aln_Half_Damage(a2)
	Move.l	Aln_Link(a2),a2
	Move.w	#400,Aln_Half_Damage(a2)
	Bra	Explosion64
	
.Damaged_2
	Move.w	#400,Aln_Dmg(a2)	
	Bra	Explosion64

Void_It	
	Clr.b	Aln_Weaponeffect(a1)
	Clr.b	Aln_Anim(a1)
	Clr.b	Aln_Delay(a1)
	Move.w	#-1,Aln_Anmset(a1)
	Move.w	#-1,Aln_Sprite(a1)
	Move.w	#$7fff,Aln_Dmg(a1)
	Move.w	#$7fff,Aln_Half_Damage(a1)
	Clr.w	Aln_Seqdec(a1)
	Move.l	#Do_Nothing_Seq,Aln_Seqp(a1)
	Rts


Train_Carraige
	Lea	Train_Links(a4),a2			; Pointer to addresses of trains
	Moveq	#0,d6					; Clear work register
	Move.w	Aln_Shite+22(a1),d6			; Train number
	Divu	#3,d6					; Get partition
	Mulu	#12,d6					; 12 = 3 longs (carraiges)
	Lea	(a2,d6),a2				; Pointer to base of table
	Moveq	#2,d6					; Clear count
.Loop	Cmp.l	(a2)+,a1
	Beq.s	.Found_The_Link
	Sub.w	#1,d6
	Bra.s	.Loop
.Found_The_Link
	Clr.l	-4(a2)					; Clear pointer to train
.LoopKIll
	Tst.w	d6					; Test if last train in list
	Beq.s	.No_Link
	Tst.l	(a2)+
	Beq.s	.Dec
	Move.l	-4(a2),a5				; Get pointer for next train
	Move.w	#16,Aln_Wave(a5)
.Dec	Sub.w	#1,d6
	Bra.s	.LoopKILL
.No_Link
	Bsr	Kill_Link
	Bra	Explosion64

Third_Guardian
	Subq.w	#1,Num_Guardians_Active(a4)
	Bne.s	.Skip_Scroll	
	Bsr	Boss_Dead
.Skip_Scroll	
	Pea	(a1)
	Bsr	Render_Sprites_Inactive
	St	Aln_Hitoveride(a1)
	St	Aln_Pauseflag(a1)
	Move.w	#$7fff,Aln_Dmg(a1)
	Move.w	#$7fff,Aln_Half_Damage(a1)
	Clr.w	Aln_Seqdec(a1)
	Move.l	#Dead_End_Level3_Seq,Aln_Seqp(a1)
.Loop0	Tst.l	Aln_Link(a1)
	Ble.s	.No_Link
	Move.l	Aln_Link(a1),a1
	Bra.s	.Loop0
.No_Link
	St	Aln_Hitoveride(a1)
	St	Aln_Pauseflag(a1)
	Move.w	#$7fff,Aln_Dmg(a1)
	Move.w	#$7fff,Aln_Half_Damage(a1)
	Move.l	(sp)+,a1
	Rts

Second_Guardian
	Subq.w	#1,Num_Guardians_Active(a4)
	Bne.s	.Skip_Scroll	
	Bsr	Boss_Dead
.Skip_Scroll	
	Bsr	Render_Sprites_Inactive
	Pea	(a1)
.Loop0	Tst.l	Aln_Prevlink(a1)
	Ble.s	.Loop
	Move.l	Aln_Prevlink(a1),a1
	Bra.s	.Loop0
.Loop	Move.w	#$7fff,Aln_Dmg(a1)
	Clr.w	Aln_Seqdec(a1)
	Move.l	#Dead_End_Level2_Seq,Aln_Seqp(a1)
.Back	Tst.l	Aln_Link(a1)
	Ble.s	.No_Link
	St	Aln_Pauseflag(a1)
	Sf	Aln_Killplayer(a1)
	St	Aln_HitOveride(a1)
	Move.l	Aln_Link(a1),a1
	Bra.s	.Back
.No_Link
	St	Aln_Pauseflag(a1)
	Sf	Aln_Killplayer(a1)
	St	Aln_HitOveride(a1)
	Move.l	(sp)+,a1
	Rts

Turret	Tst.l	Aln_Prevlink(a1)
	Ble.s	.Kill	
	Move.l	Aln_Prevlink(a1),a3
	St	Aln_Link(a3)
.Kill	Bra	Explosion32

Cannon	
	Move.l	Aln_Prevlink(a1),a2
	St	Aln_Link(a2)
	Tst.b	Aln_Pownum(a2)
	Beq.s	.No_Power
	Move.b	Aln_Pownum(a2),d3
	Move.l	Aln_X(a2),d4
	Move.l	Power_up_Posp(a4),a2
	Move.b	d3,(a2)
	Swap	d4
	Addq.w	#4,d4
	Swap	d4
	Move.l	d4,2(a2)
	Addq.l	#6,Power_up_Posp(a4)
.No_Power
	Bsr	Kill_Link
 	Bra	Explosion32

James_Brown_Is_Dead
	Subq.w	#1,Num_Guardians_Active(a4)
	Bne.s	.Skip_Scroll	
	Bsr	Boss_Dead
.Skip_Scroll	
	Bsr	Render_Sprites_Inactive
	Pea	(a1)
.Loop0	Tst.l	Aln_Prevlink(a1)
	Ble.s	.Loop
	Move.l	Aln_Prevlink(a1),a1
	Bra.s	.Loop0
.Loop	St	Aln_Pauseflag(a1)
	Move.w	#$7fff,Aln_Dmg(a1)
	Clr.w	Aln_Seqdec(a1)
	Move.l	#Dead_End_Level1_Seq,Aln_Seqp(a1)
	Move.l	(sp)+,a1
	Rts

Render_Sprites_Inactive
	MOve.l	a1,-(sp)
.Loop0	Tst.l	Aln_Prevlink(a1)
	Ble.s	.Loop
	Move.l	Aln_Prevlink(a1),a1
	Bra.s	.Loop0
.Loop	St	Aln_Pauseflag(a1)
	St	Aln_HitOveride(a1)
	Move.w	#$7fff,Aln_Seqdec(a1)
	Move.w	#0,Aln_Wave(a1)
	Move.l	#1,Aln_Shite(a1)
	Tst.l	Aln_Link(a1)
	Ble.s	.No_Link
	Move.l	Aln_Link(a1),a1
	Bra.s	.Loop
.No_Link
	MOve.l	(sp)+,a1
	Rts


Bolt	Bra	DoExplosion16

Bomb8way
	Tst.b	Bomb_Explosion_Off(a4)
	Beq.s	.Ok
	Bsr	Kill_Link
	Bra	Explosion64
	Rts
.Ok	Move.l	Aliens_Insert_P(a4),a3
	Move.w	#28,(a3)+		; Weapon number !
	Move.l	a1,(a3)+ 		; Start of this X/Y and shit !
	Move.w	Unique_Fire(a4),Aln_Unique_fire(a1)
	Move.w	Unique_Fire(a4),(a3)+
	Addq.w	#1,Unique_Fire(a4)
	Move.l	a3,Aliens_Insert_P(a4)	; Restore pointer !
	Bsr	Kill_Link
	Move.w	#$7fff,(a1)
	St	Aln_Hitoveride(a1)
	Bra	Explosion64

Scafhit	
	Pea	(a1)
	Bsr	Render_Sprites_Inactive
	St	Aln_Hitoveride(a1)
	Move.l	Aln_Link(a1),a1
	St	Aln_Hitoveride(a1)
	Move.l	(sp),a1
	Move.w	#$7fff,(a1)
	Clr.w	Aln_Seqdec(a1)
	Move.l	#.Death_Of_Scafolding_Pointsright,Aln_Seqp(a1)
	Cmp.w	#99,Aln_Anmset(a1)
	Beq.s	.Right
	Move.l	#.Death_Of_Scafolding_Pointsleft,Aln_Seqp(a1)
.Right	Move.l	(sp)+,a1
	Rts

.Death_Of_Scafolding_Pointsright
	Fire_Ship	100
	Abs_Move	0,1,2
	Fire_Ship	101
	Abs_Move	0,1,2
	Fire_Ship	102
	Abs_Move	0,1,2
	Fire_Ship	103
	Abs_Move	0,1,2
	Fire_Ship	104
	Abs_Move	0,1,2
	Fire_Ship	105
	End_Seq

.Death_Of_Scafolding_Pointsleft
	Fire_Ship	106
	Abs_Move	0,1,2
	Fire_Ship	107
	Abs_Move	0,1,2
	Fire_Ship	108
	Abs_Move	0,1,2
	Fire_Ship	109
	Abs_Move	0,1,2
	Fire_Ship	110
	Abs_Move	0,1,2
	Fire_Ship	105
	End_Seq



Casket	Move.l	Power_Up_Posp(a4),a2
	Move.b	ALN_POWNUM(a1),d3
	Bsr	Check_Random_Bomb
	Move.b	d3,(a2)+
 	Addq.l	#1,a2
	Move.l	Aln_X(a1),(a2)+	
 	Move.l	a2,Power_Up_PosP(a4)
	Bra	Explosion32

Bigpowup
 	Move.l	Aln_X(a1),d4
	Add.w	#16,d4
	Swap	d4
	Add.w	#$0e,d4
	Swap	d4
 	Move.l	Power_Up_PosP(a4),a2
 	Move.b	ALN_POWNUM(a1),d3
	Move.l	d4,-(sp)
	Bsr	Check_Random_Bomb
	Move.b	d3,(a2)+
 	Addq.l	#1,a2
 	Move.l	(sp)+,(a2)+
 	Move.l	a2,Power_Up_PosP(a4)
	Bsr	Kill_Link
	Bra	Explosion64

No_Effect
	Rts

Check_Random_Bomb
	Cmp.b	#1,d3
	Bgt.s	.No_Rand_Check
	Move.l	Player_Use(a4),a3
	Addq.b	#1,Pups_Got(a3)
	Cmp.b	#3,Pups_Got(a3)
	Blt.s	.No_Rand_Check
	Moveq	#0,d4
	Moveq	#0,d5
	Move.b	Num_Bombs(a3),d4
	Move.w	d4,d5
	Add.w	d5,d4
	Add.w	d5,d4
	Move.b	Weapon_Power(a3),d5
	Tst.b	Secondry_Weapon(a3)
	Bmi.s	.No_Addition_For_Second
	Moveq	#0,d6
	Move.b	Weapon_Power2(a3),d6
	Add.w	d6,d5
.No_Addition_For_Second
	Add.w	d5,d5
	Sub.w	d4,d5
	Bmi.s	.No_Rand_Check
	Cmp.w	#10,d5
	Bge.s	.Always_Bomb	
	Moveq	#0,d4
	Move.w	Seed(a4),d4
	Divu	#65536/10,d4
	Cmp.w	d4,d5
	Blt.s	.No_Rand_Check
.Always_Bomb	
	Clr.b	Pups_Got(a3)
	Moveq	#8,d3
.No_Rand_Check

	Rts

Kill_Link
	Move.l	a1,a6
.Kill_Link
	Tst.l	Aln_Link(a6)
	Ble.s	.Skip_Link
	Move.l	Aln_Link(a6),-(sp)
	St	(a6)
	Move.l	(sp)+,a6
 	Subq.w	#1,Number_Of_Sprites_In_Activelist(a4)	
	Bra.s	.Kill_Link
.Skip_Link
	Subq.w	#1,Number_Of_Sprites_In_Activelist(a4)
	St	(a6)
;	Clr.l	Aln_Link(a6)
	Rts

Do_Car	Move.l	Score_Bonus_Tablep(a4),a2
	Move.w	#1,(a2)+
	Move.l	Aln_X_Save(a4),(a2)+
	Move.l	a2,Score_Bonus_Tablep(a4)
	Bsr	Kill_Link
	Bra	DoExplosion16
	Nop

DoExplosion16
	Bsr	Kill_Link	
Explosion16
	Move.l	Explosion_Tabp(a4),a6
	Move.w	#0,(a6)+
	Move.w	Aln_Sprite_Save(a4),(a6)+
	Move.l	Aln_X_Save(a4),(a6)+
	Move.l	a6,Explosion_Tabp(a4)
	Rts
DoExplosion32
	Bsr	Kill_Link	
Explosion32
	Lea	BabyExplosion_Sfx,a6
	Bsr	Play_This_Sample
	
	Move.l	Explosion_Tabp(a4),a6
	Move.w	#1,(a6)+
	Move.w	Aln_Sprite_Save(a4),(a6)+
	Move.l	Aln_X_Save(a4),(a6)+
	Move.l	a6,Explosion_Tabp(a4)
	Rts
Crator32
	Move.l	Crator_Tabp(a4),a6
	Move.w	#1,(a6)+
	Move.w	Aln_Sprite_Save(a4),(a6)+
	Move.l	Aln_X_Save(a4),(a6)+
	Move.l	a6,Crator_Tabp(a4)
	Rts
Explosion32_Crator32
	Bsr	Kill_Link
	Bsr	Explosion32
	Bra	Crator32
DoExplosion64
	Bsr	Kill_Link
Explosion64
	Lea	BigExplosion_Sfx,a6
	Bsr	Play_This_Sample
	Move.l	Explosion_Tabp(a4),a6
	Move.w	#3,(a6)+
	Move.w	Aln_Sprite_Save(a4),(a6)+
	Move.l	Aln_X_Save(a4),(a6)+
	Move.l	a6,Explosion_Tabp(a4)
	Rts
Crator64
	Move.l	Crator_Tabp(a4),a6
	Move.w	#3,(a6)+
	Move.w	Aln_Sprite_Save(a4),(a6)+
	Move.l	Aln_X_Save(a4),(a6)+
	Move.l	a6,Crator_Tabp(a4)
	Rts
Explosion64_Crator64
	Bsr	Kill_Link
	Bsr	Explosion64
	Bra	Crator64
		
**********************************************************
Insert_Crators
	Move.l	Crator_Tabp(a4),a0
	St	(a0)
	Lea	Crator_Tab(a4),a0
.Loop	Tst.b	(a0)	
	Bmi.s	.Exit
	Movem.w	(a0)+,d0-d3		
	Bsr	Search_Free_Alien_Slot		
	Cmp.w	#4,d0
	Bne.s	.Normal_branch
	Add.w	d0,d0
	Move.w	.Size(pc,d0),Aln_Anmset(a6)
	Movem.w	d2-d3,Aln_X(a6)
	Move.w	#15,Aln_Wave(a6)

;	Move.w	#Screen_Height,Aln_Seqdec(a6)
	Move.w	Height_Of_Screen(a4),Aln_Seqdec(a6)

	Move.l	#.Fuck,Aln_Seqp(a6)
	Move.w	#$80,Aln_Shite+0(a6)
	Move.w	#$00,Aln_Shite+2(a6)
	Move.w	#$1,Aln_Shite+6(a6)
	Bra.s	.Loop
.Normal_branch
	Movem.w	d2-d3,Aln_X(a6)
	Clr.w	Aln_Wave(a6)
	Move.l	#1,Aln_Shite(a6)
	Move.l	#.Wait,Aln_Seqp(a6)
	Add.w	d0,d0
	Move.w	.Size(pc,d0),Aln_Anmset(a6)
	Bra.s	.Loop
.Exit	Rts

.Size	Dc.w	47,46,00,48
	Dc.w	326
	Dc.w	326
	
.Wait	Check_Y_Bound
.Fuck	End_Seq



**********************************************************
Insert_Explosion
	Move.l	Explosion_Tabp(a4),a0
	St	(a0)
	Lea	Explosion_Tab(a4),a0
	Lea	Alien_Anim_Table,a3
.Loop	Tst.b	(a0)	
	Bmi.s	.Exit
	Movem.w	(a0)+,d0-d3		Size/Sprite/X/Y
	Bsr	Search_Free_Alien_Slot		
	Clr.w	Aln_Wave(a6)
	Movem.w	d2-d3,Aln_X(a6)
	Moveq	#1,d6
	And.b	d1,d6
	Move.l	d6,Aln_Shite(a6)
	Move.l	#Fuck_Seq,Aln_Seqp(a6)
	Add.w	d0,d0
	Move.w	.Size(pc,d0),d2
	Move.w	d2,Aln_Anmset(a6)
	Asl.w	#2,d2
	Move.l	(a3,d2),a2
	Move.w	(a2)+,d2
	Addq.w	#1,d2
	Moveq	#0,d3
.Muloop	Add.w	d2,d3
	Tst.w	(a2)+
	Bpl.s	.Muloop
	Sub.w	d2,d3
	Move.w	d3,Aln_Seqdec(a6)
	Bra.s	.Loop
.Exit	Rts
.Size	Dc.w	30,31,53,52
; Add4!
	Dc.w	220,202,53,30,30			; Red,Blue,Sidewinder,Home,Splatter

	Dc.w	210					; Massive muther explosion

**********************************************************
Boss_Dead
	Clr.w	Guardian_Delay(a4)	; Set guardian delay
	Push
	Jsr	Fadedown
	Move.b	#-30,Guardian_Music_On(a4)
	Pull
	Bsr	Kill_Hover
	Rts

**********************************************************
Kill_Hover
	Sf	No_More_Scrolling(a4)		
	Sf	Flag_To_Stop_Scrolling(a4)
	St	Hover_Direction+Pl1
	St	Hover_Direction+Pl2

	Move.b	#2,Transforming_Ship+Pl1
	Move.b	#2,Transforming_Ship+Pl2
	Rts
**********************************************************
;1240-1241	- fucked level2
;570-car
;571-car

Insert_Bonus_Sprites
	Move.l	Score_Bonus_Tablep(a4),a0
	St	(a0)
	Lea	Score_Bonus_Table(a4),a0
.Loop	Tst.b	(a0)
	Bmi.s	.Exit
	Movem.w	(a0)+,d0-d2			Type/X/Y
	Bsr	Search_Free_Alien_Slot		
	Movem.w	d1-d2,Aln_X(a6)
	Move.l	#Bonus_Sprite_Sequence,Aln_Seqp(a6)
	Add.w	d0,d0
	Move.w	.Tab(pc,d0),Aln_Anmset(a6)	; 5000,1000,3000
	Bra.s	.Loop
.Exit	Rts

.Tab	Dc.w	21,22,376

**********************************************************
Alien_To_Ship
	Not.b	Player_Check_Even_odd(a4)
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Clr.l	Alien_Hit_With(a4)
	Tst_Act
	Tst.b	Death_Sequence(a3)
	Bne	.Exit
	Move.l	a3,Player_Use(a4)
	Movem.w	Shipxy(a3),d0-d1	
	Add.w	X_Offset_Into_Map(a4),d0	
	Move.w	d0,d2
	Move.w	d1,d3
	Add.w	#12,d0
	Add.w	#14,d1
	Add.w	#20,d2
	Add.w	#23,d3
	Lea	Player_Check_Table(a4),a6
	Tst.b	Player_Check_Even_odd(a4)
	Beq.s	.Loop
	Addq.l	#4,a6

.Loop	Tst.l	(a6)
	Bmi	.Exit
	Move.l	(a6)+,a1
	Addq.l	#4,a6
	Tst.w	(a1)
	Ble.s	.Loop
	Movem.w	Aln_Collision_Box(a1),d4-d7
	Cmp.w	d0,d6			
	Blt.s	.Loop
	Cmp.w	d2,d4			
	Bgt.s	.Loop
	Cmp.w	d1,d7			
	Blt.s	.Loop
	Cmp.w	d3,d5			
	Bgt.s	.Loop
	Pea	(a6)
	Move.w	Aln_Anmset(a1),d4
	Cmp.w	#Power_Up_Routine_Table_End-Power_Up_Routine_Table,d4
	Bge.s	.Not_A_Powerup
	Lea	Power_Up_Routine_Table(pc),a6
	Move.b	(a6,d4),d4
	Bmi.s	.Not_A_Powerup
	Ext.w	d4
	Lsl.w	#2,d4
	Lea	Power_Up_Jump_Table(pc),a6
	Movem.l	d5/a3/a6,-(sp)
	Jsr	(a6,d4)
	Bsr	Play_Collect_SFX
	Movem.l	(sp)+,d5/a3/a6
	Move.l	(sp)+,a6
	Bra.s	.Loop
.Not_A_Powerup
	Tst.b	Dead_Count(a3)
	Beq.s	.Can_Hit
	Move.l	(sp)+,a6
	Bra.s	.Loop
.Can_Hit
;----
;	Move.l	(sp)+,a6
;	Bra.s	.Loop
;----
	Move.l	a1,Alien_Hit_With(a4)
	Clr.b	Stage_Reached(a3)
	Move.b	Number_Of_Powerups_On_Screen(a4),d6
	Cmp.b	#4,d6
	Bge.s	.Exit2
	Move.l	Power_Up_Posp(a4),a2
	Move.w	Seed(a4),d5
	Move.w	d5,d4						; Random 16-bit in d4
	And.w	#$0100,d5
	Cmp.w	#(65536/20)*2,d4				; 1 in 10 of being a super-power up
	Bcc.s	.NO_Special_Weapon
	Move.w	#$0400,d5
	Cmp.w	#(65536/20)*1,d4				; 1 in 10 of being a bomb
	Bcc.s	.NO_Special_Weapon
	Move.w	#$0800,d5
.NO_Special_Weapon
.Special_Weapon
	Move.w	d5,(a2)+
	Move.l	Shipxy(a3),d4
	Swap	d4
	Add.w	X_Offset_Into_Map(a4),d4
	Swap	d4
	Move.l	d4,(a2)+
	Addq.b	#1,d6
	Tst.b	Weapon_Power(a3)
	Bgt.s	.Primary_Weapon_Ok
	Subq.l	#6,a2
.Primary_Weapon_Ok
	Tst.b	Secondry_Weapon(a3)
	Bmi.s	.No_Second
	Cmp.b	#2,Weapon_Power2(a3)
	Blt.s	.No_Second
	Move.w	Seed(a4),d5
	Moveq	#2,d2
	Lsr.w	#4,d5
	And.w	#1,d5
	Add.b	d5,d2
	Move.b	d2,(a2)+
	Clr.b	(a2)+
	Move.l	d4,(a2)+
.No_Second
	Move.l	a2,Power_Up_Posp(a4)
	St	Just_Dead(a3)
	Move.b	Times_Through(a4),Stage_Reached(a3)
	Addq.b	#1,Stage_Reached(a3)
	Move.b	This_Level(a4),Level_Reached(a3)
.Exit2	Addq.l	#4,sp

.Exit	Tst.l	Alien_Hit_With(a4)
	Beq.s	.No_Kill_Alien_Shot
	Move.l	Alien_Hit_With(a4),a1
	Cmp.w	#2,Aln_Anmset(a1)
	Beq.s	.Kill_Shot
	Cmp.w	#44,Aln_Anmset(a1)
	Beq.s	.Kill_Shot
	Cmp.w	#49,Aln_Anmset(a1)
	Beq.s	.Kill_Shot
	Cmp.w	#96,Aln_Anmset(a1)
	Beq.s	.Kill_Shot
.No_Kill_Alien_Shot
	Rts		
.Kill_Shot
	Clr.w	(a1)
	Rts

Play_Collect_Sfx
	Push
	Lea	Collect_Sfx,a6
	Bsr	Play_This_Sample
	Pull
	Rts

	Dc.b	-1
Power_Up_Routine_Table
	Dcb.b	3,-1
	Dc.b	0				; 3 		- power up shot
	Dc.b	1				; 4 		- power up laser
	Dc.b	2				; 5		- Rockets
	Dc.b	3				; 6		- Homing missle
	Dcb.b	36-7,-1				; 7
	Dc.b	4,5,6				; 36 37 38	- BOMB / MEDAL / FULL POWER
	Dcb.b	43-39,-1			; 39
	Dc.b	7				; 43		- Tree fairy
	Dcb.b	50-44,-1			; 44
	Dc.b	8				; 50		- PIG
Power_Up_Routine_Table_End
	Dc.b	-1
	Even
	
Power_Up_Jump_Table
	Jmp	Shot_Powerup_Routine(pc)
	Jmp	Laser_Powerup_Routine(pc)
	Jmp	Rocket_Powerup_Routine(pc)
	Jmp	Homing_Powerup_Routine(pc)
	Jmp	Bomb_Powerup_Routine(pc)
	Jmp	Medal_Powerup_Routine(pc)
	Jmp	Full_Powerup_Routine(pc)
	Jmp	Angel_Powerup_Routine(pc)
	Jmp	Pig_Powerup_Routine(pc)

Pig_Powerup_Routine
	Move.l	Player_Use(a4),a3	
	Addq.b	#1,Medals_Got(a3)	
	Move.l	Score_Bonus_Tablep(a4),a2
	Move.w	#2,(a2)+
	Move.l	Aln_X(a1),(a2)+
	Move.l	a2,Score_Bonus_Tablep(a4)
	Bsr	Kill_Link
	Bsr	Add_Score_For_Alien
	Rts
Angel_Powerup_Routine
	Bsr.s	Medal_Powerup_Routine
	Move.l	Score_Bonus_Tablep(a4),a2
	Move.w	#1,(a2)+
	Move.l	Aln_X(a1),(a2)+
	Move.l	a2,Score_Bonus_Tablep(a4)
	Subq.b	#1,Medals_Got+Pl1	
	Rts
Medal_Powerup_Routine
	Move.l	Player_Use(a4),a3	
	Addq.b	#1,Medals_Got(a3)	
	Bsr	Add_Score_For_Alien
	Bsr	Kill_Link
	Rts

Bomb_Powerup_Routine
	Bsr	Kill_Link
	Bsr	Add_Score_For_Alien
	Move.l	Player_Use(a4),a3
	Addq.b	#1,Num_Bombs(a3)
	Cmp.b	#9,Num_Bombs(a3)
	Ble.s	.No_Power		
	Move.b	#9,Num_Bombs(a3)
.No_Power		
	Rts

Full_Powerup_Routine
	Subq.b	#1,Number_Of_Powerups_On_Screen(a4)
	Bsr	Kill_Link
	Cmp.b	#4,Weapon_Power(a3)
	Sge	d6
	Cmp.b	#2,Weapon_Power2(a3)
	Sge	d7
	Or.b	d6,d7
	Bne.s	.No_Transform
	Lea	Powerup_SFX,a6
	Bsr	Play_This_Sample
	Move.b	#1,Transforming_Ship(a3)
.No_Transform
	Cmp.b	#7,Weapon_Power(a3)
	Bne.s	.No_Max_Weapon
	Cmp.b	#4,Weapon_Power2(a3)
	Beq	Score_Add_For_Weapon
.No_Max_Weapon
	Move.b	#7,Weapon_Power(a3)	
	Tst.b	Secondry_Weapon(a3)
	Bmi.s	.No_Power
	Move.b	#4,Weapon_Power2(a3)
.No_Power
	Rts


Shot_Powerup_Routine
	Subq.b	#1,Number_Of_Powerups_On_Screen(a4)
	Moveq	#0,d4		
	Bra.s	Power_Up_A_Weapon_Rputine
Laser_Powerup_Routine
	Subq.b	#1,Number_Of_Powerups_On_Screen(a4)
	Moveq	#1,d4		
	Bra.s	Power_Up_A_Weapon_Rputine
Rocket_Powerup_Routine
	Subq.b	#1,Number_Of_Powerups_On_Screen(a4)
	Moveq	#0,d4		
	Bra.s	Powerup_Secondry_Routine
Homing_Powerup_Routine
	Subq.b	#1,Number_Of_Powerups_On_Screen(a4)
	Moveq	#1,d4		
	Bra.s	Powerup_Secondry_Routine

Power_Up_A_Weapon_Rputine
	Bsr	Kill_Link
	Move.l	Player_Use(a4),a3
	Cmp.b	Weapon_In_Use(a3),d4
	Beq.s	.PUP
	Move.b	d4,Weapon_In_Use(a3)
	Rts
.PUP	Cmp.b	#4,Weapon_Power(a3)
	Bge.s	.No_Transform
	Cmp.b	#2,Weapon_Power2(a3)
	Bge.s	.No_Transform
	Cmp.b	#3,Weapon_Power(a3)
	Bne.s	.No_Transform
	Move.b	#1,Transforming_Ship(a3)
	Lea	Powerup_SFX,a6
	Bsr	Play_This_Sample
.No_Transform
	Addq.b	#1,Weapon_Power(a3)
	Cmp.b	#7,Weapon_Power(a3)
	Ble.s	.Exit
	Move.b	#7,Weapon_Power(a3)
	Bra.s	Score_Add_For_Weapon
.Exit	Rts

Powerup_Secondry_Routine
	Bsr	Kill_Link
	Move.l	Player_Use(a4),a3
	Cmp.b	Secondry_Weapon(a3),d4
	Beq.s	.PUP
	Move.b	d4,Secondry_Weapon(a3)
	Rts
.PUP	Cmp.b	#2,Weapon_Power2(a3)
	Bge.s	.No_Transform
	Cmp.b	#4,Weapon_Power(a3)
	Bge.s	.No_Transform
	Cmp.b	#1,Weapon_Power2(a3)
	Bne.s	.No_Transform
	Move.b	#1,Transforming_Ship(a3)
	Lea	Powerup_SFX,a6
	Bsr	Play_This_Sample
.No_Transform
	Addq.b	#1,Weapon_Power2(a3)
	Cmp.b	#4,Weapon_Power2(a3)
	Ble.s	.Exit
	Move.b	#4,Weapon_Power2(a3)
	Bra.s	Score_Add_For_Weapon
.Exit	Rts

Score_Add_For_Weapon
	Lea	.Bonus5000+4(pc),a6
	Move.l	Player_Use(a4),a3
	Lea	Score+4(a3),a3
	Move.b	#0,Ccr
	Abcd	-(a6),-(a3)	
	Abcd	-(a6),-(a3)	
	Abcd	-(a6),-(a3)	
	Abcd	-(a6),-(a3)	
	Move.l	Score_Bonus_Tablep(a4),a2
	Move.w	#0,(a2)+
	Move.l	Aln_X(a1),(a2)+
	Move.l	a2,Score_Bonus_Tablep(a4)
	Rts
	
.Bonus5000
	Dc.l	$05000

**********************************************************
Play_This_Sample
; a0-Address
; d0-Length
; d1-Priority 1->n (1 lowest!)
; d2-Stereo  ($3fff-Middle 0-Left $7fff-Right)
	Tst.b	Demo_Mode(a4)
	Bne.s	.Demo_mode_On
	Movem.l	d0-d3/a0,-(sp)
	Move.l	a6,a0
	Movem.w	(a0)+,d0-d3
	Jsr	playfx
	Movem.l	(sp)+,d0-d3/a0
.Demo_mode_On
	Rts

**********************************************************
Moving_Power_Up				
	Subq.b	#1,Aln_AnimFlipdel(a0)
	Bcc.s	.No_Animflip		; 1 from flip-del, <0 indicates anim flip
	Move.b	#Pow_Del,Aln_Animflipdel(a0)	; Set delay
	Move.w	Aln_Anmset(a0),d0	; Get alien anim
	Cmp.w	#38,d0
	Beq.s	.No_Animflip
	Cmp.w	#5,d0
	Bge.s	.FivSix			; If true flip between anims 5/6
	Eor.w	#%100,Aln_Anmset(a0)	; Swith between 3/4
.FivSix	Eor.w	#%011,Aln_Anmset(a0)	; Else between 5/6
.No_Animflip
	Rts

**********************************************************
;d0-d1 = Source coardinates
;d2-d3 = Dest coardinates
; returns d7 = Angle!

Track_Routine
	Moveq	#0,d7
 	Lea	Arc_Tan,a6			; Pointer to pre-calced arc-tans
	Sub.w	d0,d2			; Get difference in x
	Asr.w	#2,d2
;	Bmi.s	.Quadrent_34
	Ble.s	.Quadrent_34
.Quadrent_12
	Sub.w	d1,d3
	Asr.w	#2,d3
;	Ble.s	.Quadrent_1
	Blt.s	.Quadrent_1
.Quadrent_2
	Moveq	#64,d4
	Sub.w	d4,d3
	Neg.w	d3
	Sub.w	d4,d2
	Neg.w	d2
	Lsl.w	#6,d3
	Add.w	d2,d3
	Move.b	(a6,d3),d7
	Add.b	d4,d7
	Rts
.Quadrent_1
	Neg.w	d3
	Lsl.w	#6,d3
	Add.w	d2,d3
	Move.b	(a6,d3),d7
	Rts

.Quadrent_34
	Sub.w	d1,d3
	Asr.w	#2,d3
	Bgt.s	.Quadrent_3
.Quadrent_4
	Moveq	#64,d4
	Neg.w	d2
	Sub.w	d4,d2
	Neg.w	d2
	Neg.w	d3
	Sub.w	d4,d3
	Neg.w	d3
	Lsl.w	#6,d3
	Add.w	d2,d3
	Move.b	(a6,d3),d7
	Add.b	#$c0,d7
	Rts
.Quadrent_3
	Neg.w	d2	
	Lsl.w	#6,d3
	Add.w	d2,d3
	Move.b	(a6,d3),d7
	Add.b	#$80,d7
	Rts	

;x/y in d0/d1

Get_Closest_Ship
	Movem.w	Track_Shipxy(a4),d2-d5
	Sub.w	d0,d2
	Bpl.s	.Ok1
	Neg.w	d2
.Ok1	Sub.w	d0,d4
	Bpl.s	.Ok2
	Neg.w	d4
.Ok2	Sub.w	d1,d3
	Bpl.s	.Ok3
	Neg.w	d3
.Ok3	Sub.w	d1,d5
	Bpl.s	.Ok4
	Neg.w	d5
.Ok4	Add.w	d2,d3
	Add.w	d4,d5
	Cmp.w	d3,d5
	Ble.s	.Track_2
	Movem.w	Track_Shipxy(a4),d2-d3
	Rts
.Track_2
	Movem.w	Track_Shipxy+4(a4),d2-d3
	Rts	



**********************************************************
Move_Aliens
	Jsr	Wait_For_GPU
	Lea	Gpu_Quick_Ref,a0
	Move.l	#Enemy_Prioritys,(a0)+
	Move.l	#Alien_Killya_Table,(a0)+
	Move.l	#Wdo_Or_Die,(a0)+
	Move.l	#Shadow_Tab,(a0)+

	Lea	Move_Params,a0
	Move.l	#Alien_Table+Data,(a0)+
	Move.l	#Aln_End,(a0)+
	Move.l	#Max_Aliens,(a0)+
	Move.l	#GPU_Checked_Aliens+Data,(a0)+
	Move.l	#Aln_Half_Damage,(a0)+
	Move.l	#Aln_Dmg_Dec,(a0)+
	Move.l	#Aln_Its_A_Child,(a0)+
	Move.l	#Aln_Animflipflg,(a0)+
	Move.l	#Aln_Pauseflag,(a0)+
	Move.l	#Aln_Delay,(a0)+
	Move.l	#Aln_Anmset,(a0)+
	Move.l	#Alien_Anim_Table,(a0)+
	Move.l	#Aln_Init,(a0)+
	Move.l	#Aln_Anim,(a0)+
	Move.l	#Aln_Animcont,(a0)+
	Move.l	#Aln_Animflag,(a0)+
	Move.l	#Aln_Sprite,(a0)+
	Move.l	#Aln_Base_Sprite,(a0)+
	Move.l	#Aln_Rotnumber,(a0)+
	Move.l	#Aln_Spr_Priority,(a0)+
	Move.l	#ALN_Killplayer,(a0)+
	Move.l	#Aln_Weaponeffect,(a0)+
	Move.l	#Aln_Shadsprite,(a0)+
	Move.l	#Aln_Track_Val,(a0)+
	
	Clr.l	GpuX_Move_Pointer
	Lea	Move_Aliens_GPU,a0
	Jsr	Start_GPU
;	Jsr	Wait_For_GPU

;	Lea	Alien_Table(a4),a0		; Base pointer to alien list
;	Move.l	Aln_Activelist_Pointer(a4),-(sp)
;	Move.w	#Max_Aliens,-(sp)	; Counter on stack
;.Loop	Moveq	#Aln_End,d1
;.Loop1	Tst.w	(a0)			; Valid sprite if DMG>0
;	Bgt.s	.Sprite_Active
;	Add.l	d1,a0
;.Exit_Alien_Move
;	Subq.w	#1,(sp)
;	Bne.s	.Loop1
;	Addq.l	#2,sp
;	Move.l	(sp)+,a3
;	St	(a3)			
;	Rts

	Move.l	Aln_Activelist_Pointer(a4),-(sp)
	Move.w	#Max_Aliens,-(sp)	; Counter on stack
	Pea	GPU_Checked_Aliens(a4)
	Move.l	(sp)+,GPU_Checked_Aliensp(a4)
.Exit_Alien_Move
.Loop1
.Loop	Move.l	GPU_Checked_Aliensp(a4),a0
.Wait_For_Gpu_to_Do
	Move.l	GpuX_Move_Pointer,d0
	Cmp.l	a0,d0
	Ble.s	.Wait_For_Gpu_to_Do	
	Move.l	(a0),d1
	Bmi.s	.Unactive
	Addq.l	#4,GPU_Checked_Aliensp(a4)
	Move.l	d1,a0
	Tst.w	(a0)
	Ble.s	.Loop
	Bra	.No_New_Sprite
.Unactive
	Addq.l	#2,sp
	Move.l	(sp)+,a3
	St	(a3)			
	Rts

.Sprite_Active
	Tst.w	Aln_Half_Damage(a0)
	Bge.s	.No_Sprite_DMG
	Subq.b	#1,Aln_DMG_Dec(a0)
.No_Sprite_DMG
	Clr.b	Aln_Its_A_Child(a0)
	Tst.b	Aln_AnimFlipFlg(a0)	; Does this anim flip at a given interval
	Beq.s	.No_Animflip		; NO!
	Bsr	Moving_Power_Up		; Moving powerup 
.No_Animflip			
	Tst.b	Aln_Init(a0)
	Beq.s	.Skip_Pauser
	Tst.w	Aln_Pauseflag(a0)
	Bne	.No_New_Sprite		; Flag to restart anim,!= Skip
.Skip_Pauser
	Subq.b	#1,Aln_Delay(a0)
	Bcc.s	.No_New_Sprite
	Move.w	Aln_Anmset(a0),d2	; Anim set number
	Lea	Alien_Anim_Table,a2	; Pointer to base of anim table
	Add.w	d2,d2
	Add.w	d2,d2
	Move.l	(a2,d2),a2		; Anim sequence base
	Move.w	(a2)+,d3		; Get delay for next frame
	Move.b	d3,Aln_Delay(a0)	; Save it
	Tst.b	Aln_Init(a0)
	Bne.s	.Initialized
	St	Aln_Init(a0)
	Subq.b	#1,Aln_Anim(a0)			; Add 1 to number 
.Initialized
	Addq.b	#1,Aln_Anim(a0)			; Add 1 to number 
	Moveq	#0,d2
	Move.b	Aln_Anim(a0),d2			; Get current anim number
	Add.w	d2,d2
	Move.w	(a2,d2),d2			; Get sprite number
	Bpl.s	.Valid_Sprite			; Positive, not end of list
	Move.w	(a2),d2				; Get first sprite in list
	Clr.b	Aln_Anim(a0)			; Next sprite in sprite 1
	Move.b	Aln_AnimCont(a0),Aln_Animflag(a0) ; Continue anim, or pause at frame 0
.Valid_Sprite
	Move.w	d2,Aln_Sprite(a0)		; Save sprite number
	Move.w	d2,Aln_Base_Sprite(a0)
	Movem.l	Quick_Ref_Pointers(pc),a2-a3/a5-a6
	Move.b	(a2,d2),ALN_SPR_Priority(a0)	; Sprite priority
	Move.b	(a3,d2),ALN_Killplayer(a0)	; Can it hit the player
	Move.b	(a5,d2),Aln_Weaponeffect(a0)	; Can you hit it with a weapon
	Add.w	d2,d2
	Move.w	(a6,d2),Aln_Shadsprite(a0)	
	Bmi.s	.No_New_Sprite
	Tst.b	Aln_Track_Val(a0)
	Beq.s	.No_New_Sprite
	Moveq	#0,d2
	Move.b	Aln_Rotnumber(a0),d2
	Add.w	d2,Aln_Shadsprite(a0)
.No_New_Sprite
	Move.w	Aln_X(a0),d0
	Move.w	Aln_Y(a0),d1
	Move.w	Aln_Wave(a0),d2		; Attack wave number
	Lea	Aln_Shite(a0),a5	; Pointer to variables pertaining to the way we move
	Add.w	d2,d2
	Add.w	d2,d2
	Jsr	Path_Jt(pc,d2)		; Get ready for return
	Swap	d0
	Move.w	d1,d0
	Move.l	d0,Aln_X(a0)
	Move.l	d0,Aln_X_Offseted(a0)
	Subq.w	#1,Aln_Seqdec(a0)	; Sequence decrement
	Bgt.s	.No_New_Command		; No new sequence, BRANCH
	Move.l	Aln_Seqp(a0),a2		; Sequence in order
	Lea	Aln_Wave(a0),a1		; Pointer to sprite wave number
	Lea	Aln_Shite(a0),a5	; Wave variable space
	Lea	Comm_Table(pc),a3	; Pointer to Jump table of new sequences
	Move.w	(a2)+,d2		; Command number
	Add.w	d2,d2
	Add.w	d2,d2
	Jsr	(a3,d2)			; Call appropriate routine
	Tst.w	(a0)
	Ble.s	.No_Sprite
	Move.l	a2,Aln_Seqp(a0)		; Save pointer
.No_New_Command				
	Move.l	2(sp),a3
	Move.l	a0,(a3)
	Addq.l	#4,2(sp)
	Addq.w	#1,Number_Of_Sprites_In_Activelist(a4)
.No_Sprite
;	Lea	Aln_End(a0),a0
;	Moveq	#Aln_End,d1
	Bra	.Exit_Alien_Move

Quick_Ref_Pointers
	Dc.l	Enemy_Prioritys
	Dc.l	Alien_Killya_Table
	Dc.l	Wdo_Or_Die
	Dc.l	Shadow_Tab

	Rts
	Rts
Path_Jt	Jmp	Attack_Wave0(pc)	; X/Y ADD	
	Jmp	Attack_Wave1(pc)	; Left/right Sine
	Jmp	Attack_Wave2(pc)	; Up/Down Sine
	Jmp	Attack_Wave3(pc)	; X Swoop
	Jmp	Attack_Wave4(pc)	; Y Swoop
	Jmp	Attack_Wave5(pc)	; Some sort of sine
	Jmp	Attack_Wave6(pc)	; Vector Move
	Jmp	Attack_Wave7(pc)	; Track !
	Jmp	Attack_Wave8(pc)	; Bomb movements
	Jmp	Attack_Wave9(pc)	; Sine for power ups
	Jmp	Attack_Wave0(pc)	
	Jmp	Attack_Wave11(pc)	; Spit-Out-home
	Jmp	Attack_Wave12(pc)	; Noop !
	Jmp	Attack_Wave13(pc)	; Accelerate towards
	Jmp	Attack_Wave14(pc)	; Arrow thang!
	Jmp	Attack_Wave15(pc)	; Paralax vector move
	Jmp	Attack_Wave16(pc)	; Paralax vector move with slow down
	Jmp	Attack_Wave17(pc)	; Move relative
	Jmp	Attack_Wave18(pc)	; Nove on a graidient (child)
	Nop


Attack_Wave18
	Movem.l	Aln_Shite(a0),d2-d3
	Movem.w	Aln_Shite+8(a0),d4-d5
	Movem.w	Aln_Childx(a0),d0-d1
	Swap	d0
	Swap	d1
	Move.w	d4,d0
	Move.w	d5,d1
	Add.l	d2,d0
	Add.l	d3,d1
	Movem.w	d0-d1,Aln_Shite+8(a0)
	Swap	d0
	Swap	d1
	Movem.w	d0-d1,Aln_Childx(a0)
	Add.w	#11,d0
	Add.w	#11,d1
	Move.l	Aln_Link(a0),a3
	Movem.w	d0-d1,Aln_Childx(a3)
	Rts

Attack_Wave17
	Movem.w	Aln_Shite(a0),d2-d3
	Add.w	d2,Aln_Shite+4(a0)
	Add.w	d3,Aln_Shite+6(a0)
	Movem.w	Aln_Shite+4(a0),d0-d1
	Move.l	Rel_Base(a4),a3
	Add.w	Aln_X(a3),d0
	Add.w	Aln_Y(a3),d1
	Rts

Attack_Wave16
	Bsr	Attack_Wave15
	Tst.w	Aln_Shite+4(a0)
	Beq.s	.No_Sub
	Tst.b	Flip_Flag(a4)
	Beq.s	.No_sub
	Subq.w	#1,Aln_Shite+4(a0)
.No_sub
	Rts
	

Attack_Wave14
	Movem.w	Aln_X(a0),d0-d1
	Bsr	Get_Closest_Ship
	Move.w	#4,2(a5)
	Sub.w	d0,d2
	Bpl.s	.Pos_Ship
	Move.w	#-4,2(a5)
.Pos_Ship
	Move.w	d1,-(sp)
	Bsr	Attack_Wave6
	Move.w	(sp)+,d1
	Addq.w	#5,d1
	Rts

Attack_Wave0
	Add.w	(a5)+,d0		; Relative offset to X coardinate
	Add.w	(a5)+,d1		; Relative offset to Y coardinate
	Tst.b	No_More_Scrolling(a4)
	Beq.s	.No_Sub
	Subq.w	#1,d1
.No_Sub	Rts

Attack_Wave1
	Bsr	Sprite_Sine_Routine
 	Sub.w	(a5),d0			; Subtract this val from X
	Move.w	d2,(a5)+		; Save Word wot we got !
	Add.w	d2,d0			; Add to X
	Bra.s	Attack_Wave0		; Add next 2 to X/Y

Attack_Wave2
	Bsr	Sprite_Sine_Routine
	Sub.w	(a5),d1			; Subtract this val from X
	Move.w	d2,(a5)+		; Save Word wot we got !
	Add.w	d2,d1			; Add to X
	Bra.s	Attack_Wave0		; Add next 2 to X/Y

Sprite_Sine_Routine
	Lea	Alien_Sine(pc),a2
	Movem.w	(a5)+,d2-d3		; Current sine / Speed in d2-d3
	Add.b	d3,d2			; Sine table is just 256 Words	
	Move.w	d2,-4(a5)		; Resave !
	Add.w	d2,d2
	Move.w	(a2,d2),d2		; Sine value in d2
	Muls	(a5)+,d2		; Scale it!
	Add.l	d2,d2
	Swap	d2
	Rts

Sprite_Half_Sine_Routine
	Lea	Alien_Sine(pc),a2
	Movem.w	(a5)+,d2-d3
	Add.b	d3,d2
	Move.w	d2,-4(a5)		; Same as sine calculation
	Lsr.w	#1,d2
	Add.w	d2,d2
	Move.w	(a2,d2),d2		; Only for a half-circle
	Muls	(a5)+,d2		; Scale it
	Add.l	d2,d2
	Swap	d2
	Rts


Attack_Wave3
	Bsr	Sprite_Half_Sine_Routine
	Sub.w	(a5),d0			; Previous value from x
	Move.w	d2,(a5)+		; O.k In !
	Add.w	d2,d0			; Add sine value to X
	Bra	Attack_Wave0		; Add next 2 words !

Attack_Wave4
	Sub.w	(a5),d1			; Previous value from Y
	Move.w	d2,(a5)+		; O.k In !
	Add.w	d2,d1			; Add sine value to Y
	Bra	Attack_Wave0		; Add next 2 words !

Attack_Wave5
	Lea	Alien_Sine(pc),a2
	Movem.w	(a5)+,d2-d5
	Add.b	d4,d2
	Add.b	d5,d3
	Movem.w	d2-d3,-8(a5)		; Save em !
	Add.w	d2,d2
	Add.w	d3,d3
	Move.w	(a2,d2),d2
	Move.w	(a2,d3),d3		Sine values !
	Muls	(a5)+,d2
	Muls	(a5)+,d3		Scale values 
	Add.l	d2,d2
	Add.l	d3,d3
	Swap	d2
	Swap	d3
	Sub.w	(a5),d0
	Move.w	d2,(a5)+
	Sub.w	(a5),d1			Subtract previous values !
	Move.w	d3,(a5)+
	Bsr	Attack_Wave0		Add x/y scale !
	Add.w	d2,d0
	Add.w	d3,d1			Get new x/y
	Rts

Attack_Wave6
	Movem.w	(a5)+,d2-d6
	Add.b	d3,d2
	Move.w	d2,-10(a5)
	Lea	Pre_Sines,a2		; Pointer to pre-calced sines
	And.w	#$ff,d2
	Add.w	d4,d4
	Add.w	d4,d4
	Bpl.s	.Positive
	Add.b	#$80,d2
	Neg.w	d4
.Positive
	And.w	#$f<<2,d4
	Move.l	Quick_1024(pc,d4),a2
	Add.w	d2,d2
	Add.w	d2,d2			; Andle *4
	Move.l	(a2,d2),d3		; Sine in d3
	Add.w	#$100,d2
	And.w	#$3fc,d2
	Move.l	(a2,d2),d4		; Cosine in d4
	Add.w	d3,d5
	Swap	d3
	Addx.w	d3,d0
	Sub.w	d4,d6
	Swap	d4
	Subx.w	d4,d1
	Move.w	d6,-(a5)
	Move.w	d5,-(a5)
	Tst.b	No_More_Scrolling(a4)
	Bne.s	.Scroll_Stoped
	Addq.w	#1,d1
.Scroll_Stoped
	Rts	

Quick_1024
	Dc.l	Pre_Sines+(0*1024)
	Dc.l	Pre_Sines+(1*1024)
	Dc.l	Pre_Sines+(2*1024)
	Dc.l	Pre_Sines+(3*1024)
	Dc.l	Pre_Sines+(4*1024)
	Dc.l	Pre_Sines+(5*1024)
	Dc.l	Pre_Sines+(6*1024)
	Dc.l	Pre_Sines+(7*1024)
	Dc.l	Pre_Sines+(8*1024)
	Dc.l	Pre_Sines+(9*1024)
	Dc.l	Pre_Sines+(10*1024)
	Dc.l	Pre_Sines+(11*1024)
	Dc.l	Pre_Sines+(12*1024)
	Dc.l	Pre_Sines+(13*1024)
	Dc.l	Pre_Sines+(14*1024)
	Dc.l	Pre_Sines+(15*1024)

Attack_Wave15
	Bsr	Attack_Wave6
	Tst.b	Paralax_Scroll_PXL(a4)
	Beq.s	.One_Pixel
	Addq.w	#1,d1
.One_Pixel
	Rts

Attack_Wave7
	Move.w	Seed(a4),d6
	Asr.w	#3,d6
	Move.w	d6,Seed(a4)
	Moveq	#1,d7
	And.w	d6,d7
	Addq.b	#1,d7
	Add.b	d7,Aln_Trackdec(a0)
	Btst	#2,Aln_Trackdec(a0)
	Bne.s	.Exit
	Movem.w	d0-d1,-(sp)
	Move.w	Aln_Sprite(a0),d4
	Lsl.w	#4,d4
	Move.l	Enemy_Sprites_Base(a4),a6
	Move.w	Spr_Pixel_Width(a6,d4),d2
	Asr.w	#1,d2
	Add.w	d2,d0
	Move.w	Spr_Sheight(a6,d4),d2
	Add.w	Spr_YOffset(a6,d4),d2
	Asr.w	#1,d2
	Add.w	d2,d1
	Bsr	Get_Closest_Ship
	Bsr	Track_Routine
	And.w	#$f8,d7			; Angle only goes up/down in 4's
	Move.w	(a5),d2			; Get current angle
	Cmp.b	d2,d7
	Beq.s	.Angles_Same
	Move.w	d7,d6			; Copy destination angle
	Add.b	#$80,d6			; Add half a circle
	Sub.b	d2,d6
	Sub.b	d2,d7
	Cmp.b	d6,d7
	Bcc.s	.Clockwise_Is_Greater	; If clockwise is greater=
	Add.b	#16,d2
.Clockwise_Is_Greater
	Subq.b	#8,d2
.Angles_Same
	Move.w	d2,(a5)			; Save calculated angle
	Addq.b	#8,d2
	Lsr.b	#4,d2
	Move.b	d2,Aln_Rotnumber(a0)
	Movem.w	(sp)+,d0-d1
.Exit	Rts

Attack_Wave8
	Sf	6(a5)
	Sf	d5			; Flag to dec number of times ya bounced
	Sub.w	4(a5),d0
	Tst.w	8(a5)
	Ble.s	.Set
	Tst.w	d0
	Blt.s	.Set
	Tst.w	d1
	Blt.s	.Set

;	Cmp.w	#Screen_Height-16,d1
	Move.w	Height_Of_Screen(a4),d3
	Sub.w	#16,d3
	Cmp.w	d3,d1

	Bge.s	.Set
	Cmp.w	#Playfield_Width-16,d0
	Blt.s	.Noset
.Set	St	6(a5)
.Noset	Add.w	(a5)+,d0
	Add.w	(a5)+,d1			; x/y modifier
	Move.w	X_Offset_Into_Map(a4),(a5)	; Save it!
;???
	Move.w	Prev_X_Offset_Into_Map(a4),d3
	Sub.w	d3,(a5)
;???
	Tst.b	2(a5)
	Bne.s	.Nsy
	Cmp.w	#0,d0
	Bge.s	.Psx
	St	d5			; Flag bounced
	Neg.w	-4(a5)
	Add.w	-4(a5),d0
.Psx	
;	Cmp.w	#Screen_Width-16,d0
	Cmp.w	#Playfield_Width-16,d0
	Blt.s	.Nsx
	St	d5			; Flag bounced
	Neg.w	-4(a5)
	Add.w	-4(a5),d0
.Nsx	Cmp.w	#0,d1
	Bge.s	.Psy
	St	d5			; Flag bounced
	Neg.w	-2(a5)
	Add.w	-2(a5),d1
.Psy	
;	Cmp.w	#Screen_Height-16,d1
	Move.w	Height_Of_Screen(a4),d3
	Sub.w	#16,d3
	Cmp.w	d3,d1

	Blt.s	.Nsy
	St	d5			; Flag bounced
	Neg.w	-2(a5)
	Add.w	-2(a5),d1
.Nsy	Add.w	(a5),d0
	Tst.b	d5
	Beq.s	.No_Set_Bounce_Flag
	Subq.w	#1,4(a5)
	Bne.s	.No_Set_Bounce_Flag
	Move.l	-4(a5),Aln_Shite(a0)
	Move.w	#0,Aln_Wave(a0)
;	MOve.w	#Screen_Width,Aln_Seqdec(a0)
	MOve.w	#Playfield_Width,Aln_Seqdec(a0)
	Move.l	#Fuck_Seq,Aln_Seqp(a0)
.No_Set_Bounce_Flag
	Rts	

Attack_Wave9
;	Sub.w	Prev_X_Offset_Into_Map(a4),d0
	Movem.w	(a5)+,d2-d5
	Add.w	d4,d2
	Bcc.s	.AAA
	Add.w	(a5),d0
.AAA	Add.w	d5,d3
	Bcc.s	.BBB
	Add.w	2(a5),d1
.BBB	Movem.w	d2-d3,-8(a5)
	Addq.l	#4,a5
	Subq.w	#1,(a5)+
	Bgt.s	.KKK
	Clr.l	-6(a5)
.KKK	Moveq	#0,d3
	Move.b	(a5)+,d3
	Add.b	(a5)+,d3
	Move.w	d3,-(sp)		; Save sine value on stack
	Move.b	d3,-2(a5)
	Lea	Alien_Sine(pc),a3
	Add.w	d3,d3
	Move.w	(a3,d3),d4
	Add.w	#$80,d3
	Move.w	(a3,d3),d3
	Muls	(a5),d3		
	Muls	(a5)+,d4		
	Add.l	d3,d3
	Add.l	d4,d4
	Swap	d3
	Swap	d4
	Sub.w	(a5),d0
	Sub.w	2(a5),d1
	Movem.w	d3-d4,(a5)
	Move.w	(sp)+,d5		; Retrieve Sine value
	Cmp.w	#1,Aln_Seqdec(a0)
	Bne.s	.No_Sine_Drop
	Move.w	#2,Aln_Seqdec(a0)
	And.w	#$ff,d5
	Cmp.w	#$3c,d5
	Blt.s	.No_Sine_Drop
	Cmp.w	#$42,d5
	Bgt.s	.No_Sine_Drop
	Clr.w	Aln_Seqdec(a0)
	Subq.b	#1,Number_Of_Powerups_On_Screen(a4)
.No_Sine_Drop
	Add.w	d3,d0
	Add.w	d4,d1
	Rts

Attack_Wave11
	Move.l	Player_Use(a4),a5
	Move.w	Shipxy(a5),d2
	Btst	#0,d2
	Beq.s	.Ship_Even
	Or.w	#1,d0
	Bra.s	.Skip_Even_Odd_Text	
.Ship_Even
	And.w	#$fffe,d0
.Skip_Even_Odd_Text	
	Add.w	X_Offset_Into_Map(a4),d2
	Add.w	#16,d2
	Cmp.w	d0,d2
	Beq.s	.No_Add
	Bge.s	.Add
	Subq.w	#4,d0
.Add	Addq.w	#2,d0
.No_Add	Addq.w	#5,d1
	Rts

Attack_Wave12	
	Rts

Attack_Wave13
	Move.w	#$7fff,Aln_Seqdec(a0)	; Dont get out of this wave pattern
	Move.w	X_Offset_Into_Map(a4),d6
	Sub.w	#80,d6
	Cmp.w	d6,d0
	Ble.s	.Alien_Off_Screen	; Make sure the sprite is still on the playfield
	Cmp.w	#-80,d1
	Ble.s	.Alien_Off_Screen
	Cmp.w	Right_Hand_Screenxbound(a4),d0
	Bge.s	.Alien_Off_Screen

;	Cmp.w	#Screen_Height,d1
	Cmp.w	Height_Of_Screen(a4),d1

	Bge.s	.Alien_Off_Screen
	Movem.w	Aln_X(a0),d0-d1
	Pea	(a5)
	Bsr	Get_Closest_Ship
	Bsr	Track_Routine
	Move.l	(sp)+,a5
	Move.w	(a5),d2			; Get current angle
	Move.w	d7,d6			; Copy destination angle
	Add.b	#$80,d6			; Add half a circle
	Sub.b	d2,d6
	Sub.b	d2,d7
	Cmp.b	d6,d7
	Bcc.s	.Clockwise_Is_Greater	; If clockwise is greater=
	Addq.b	#4,d2
.Clockwise_Is_Greater
	Subq.b	#2,d2
	Move.w	d2,(a5)
	Cmp.w	#6,4(a5)
	Beq	Attack_Wave6		; Do a standard vector move
	Addq.w	#1,4(a5)		; 1 to scale along angle
	Bra	Attack_Wave6		; Do a standard vector move
.Alien_Off_Screen
	Clr.w	Aln_Seqdec(a0)		; Else Execute the next command
	Rts

	Illegal
	Illegal
Comm_Table
	Bra	.Comm0			; Abs Move
	Bra	.Comm1			; Sine Lr
	Bra	.Comm2			; Sine Ud
	Bra	.Comm3			; X Swoop
	Bra	.Comm4			; Y Swoop
	Bra	.Comm5			; Repeat
	Bra	.Comm6			; Repend
	Bra	.Comm7			; Gosub
	Bra	.Comm8			; Return
	Bra	.Comm9			; Branch
	Bra	.Comm10			; Fireship
	Bra	.Comm11			; End Sequence
	Bra	.Comm12			; Multi-Sine
	Bra	.Comm13			; Vector move
	Bra	.Comm14			; Track To player Ship
	Bra	.Comm15			; Bounce move!
	Bra	.Comm16			; Center move
	Bra	.Comm17			; No-operaration
	Bra	.Comm18			; Release power-ups
	Bra	.Comm19			; Zoom intto!
	Bra	.Comm20			; Start scrolling
	Bra	.Comm21			; Stop scrolling
	Bra	.Comm22			; Spit Out
	Bra	.Comm23			; Spit-out-Home
	Bra	.Comm24			; START mid2 split
	Bra	.Comm25			; Change power up ship anim
	Bra	.Comm26			; Tween between 2 vector moves
	Bra	.Comm27			; Plane home into !
	Bra	.Comm28			; Accelerate towards ship
	Bra	.Comm29			; Stop anim
	Bra	.Comm30			; One shot anim
	Bra	.Comm31			; Start anim
	Bra	.Comm32			; Only if moving !
	Bra	.Comm33			; hovercraft add up
	Bra	.Comm34			; hovercraft add down
	Bra	.Comm35			; Guardian2 reached center
	Bra	.Comm36			; Pause
	Bra	.Comm37			; Unpause
	Bra	.Comm38			; Do nothing !
	Bra	.Comm39			; Change anim
	Bra	.Comm40			; Wait until coard is out of screen boundrys
	Bra	.Comm41			; Hit, on or off
	Bra	.Comm42			; Set guardian delay
	Bra	.Comm43			; Set guardian delay
	Bra	.Comm44			; Cannons_Hi_Priority		
	Bra	.Comm45			; Cannons_Lo_Priority		
	Bra	.Comm46			; Wait anim fram
	Bra	.Comm47			; Y bound
	Bra	.Comm48			; Pause a Link Anim	
	Bra	.Comm49			; UnPause a Link Anim	
	Bra	.Comm50			; Change a Link Anim	
	Bra	.Comm51			; Setup arrow home
	Bra	.Comm52			; vector move with paralax
	Bra	.Comm53			; Set angle !
	Bra	.Comm54			; Wait link anim
	Bra	.Comm55			; Check anim and branch
	Bra	.Comm56			; Add a train to list
	Bra	.Comm57			; Change a child sprite x/y offset
	Bra	.Comm58			; Stop link anim
	Bra	.Comm59			; Move child x y
	Bra	.Comm60			; Start link anim
	Bra	.Comm61			; Add power up
	Bra	.Comm62			; Wings out level 5 bodge getting late fuck off!
	Bra	.Comm63			; Change sequence/linksequence
	Bra	.Comm64			; Change sequence/linksequence
	Bra	.Comm65			; Legs up shadow out
	Bra	.Comm66			; Pause multiple link
	Bra	.Comm67			; Unpause_Multiple link
	Bra	.Comm68			; Set relative base address (bodge)
	Bra	.Comm69			; Add spiders (bodge, gotta be done for today!)
	Bra	.Comm70			; Abs Move relative (bodge for spiders)
	Bra	.Comm71			; Child attached
	Bra	.Comm72			; Set hit points
	Bra	.Comm73			; Set hit points
	Bra	.Comm74			; Set destruct address
	Bra	.Comm75			; 2 Player event !
	Bra	.Comm76			; Turn of bomb explosions
	Bra	.Comm77			; Mad sequence level 4
	Bra	.Comm78			; Pal test
	Bra	.Comm79			; Ntsc test
	
	Nop
.Comm78	Tst.b	Ntsc_Flag(a4)
	Beq	.Comm11
	Rts	

.Comm79	Tst.b	Ntsc_Flag(a4)
	Bne	.Comm11
	Rts	

.Comm77	
	Cmp.b	#3,Aln_Shite+21(a0)
	Beq.s	.No_ChecK4
	Addq.b	#1,Aln_Shite+21(a0)
	Cmp.b	#3,Aln_Shite+21(a0)
	Bne.s	.Check_Hit_Points
	Cmp.w	#250,Aln_Dmg(a0)
	Blt.s	.No_Check4
	Bra.s	.Make_Mad4
.Check_Hit_Points
	Cmp.w	#250,Aln_Dmg(a0)
	Bge.s	.No_ChecK4
.Make_Mad4
	Tst.b	Aln_Shite+23(a0)
	Bne.s	.No_Check4
	St	Aln_Shite+23(a0)
	Move.l	a0,a6
	Moveq	#10-1,d6
.Loop	Move.l	Aln_Link(a6),a6
	Dbra	d6,.Loop
	Clr.w	Aln_Seqdec(a6)
	Move.l	#Mad_4_Seq,Aln_Seqp(a6)
.No_ChecK4
	Rts

.Comm76	St	Bomb_Explosion_Off(a4)
	Rts

.Comm75	Tst.b	Player_Active+Pl1
	Beq.s	.Not_Active
	Tst.b	Player_Active+Pl2
	Beq.s	.Not_Active
	Rts	
.Not_Active
	Bra	.Comm11

.Comm74	Move.w	(a2)+,d3
	Lea	Destruct_Table(a4),a3
	St	Aln_Shite+18(a0)	; Flag for destruct (quick bodge coz its a last bug, use 18 coz it dont get used on level 4/5)
	Lsl.w	#2,d3
	Move.l	a0,(a3,d3)
	Rts

.Comm73	
	Move.w	(a2)+,d3
	Move.w	Aln_Shite(a0),d4
	Add.b	d3,d4
	Move.w	d4,Aln_Shite(a0)
	Rts

.Comm72	Move.w	(a2)+,d3
	Move.w	d3,Aln_Dmg(a0)
	Asr.w	#1,d3
	Move.w	d3,Aln_Half_Damage(a0)
	Rts

.Comm71	Move.l	Rel_Base(a4),a3
.Search_End_Link
	Tst.l	Aln_Link(a3)
	Ble.s	.Found_Last_Link
	Move.l	Aln_Link(a3),a3
	Bra.s	.Search_End_Link
.Found_Last_Link
	Pea	(a6)
	Move.l	a0,a6
	Move.l	a6,Aln_Link(a3)
	Move.l	a3,Aln_Prevlink(a6)
.Loop_Linker
	Movem.w	Aln_Childx(a6),d2-d3
	Add.w	0(a2),d2	
	Add.w	2(a2),d3	
	Movem.w	d2-d3,Aln_Childx(a6)
	Tst.l	Aln_Link(a6)
	Ble.s	.Done_looper_Link
	Move.l	Aln_Link(a6),a6
	Bra.s	.Loop_Linker
.Done_looper_Link
	Addq.l	#4,a2
	Move.l	(sp)+,a6
	Rts

.Comm68	Move.l	a0,Rel_Base(a4)
	Rts

.Comm69	Addq.w	#1,Num_Spiders(a4)
	Rts

.Comm70	Movem.w	(a2)+,d2-d4
	Move.w	d4,Aln_Seqdec(a0)
	Movem.w	d2-d3,Aln_Shite(a0)
	Move.l	Rel_Base(a4),a3
	Movem.w	Aln_X(a0),d3-d4
	Sub.w	Aln_X(a3),d3
	Sub.w	Aln_Y(a3),d4
	Movem.w	d3-d4,Aln_Shite+4(a0)
	Move.w	#17,Aln_Wave(a0)
	Rts

.Comm66			
	Move.w	(a2)+,d3		; Get link number
	Bmi.s	.Done_Pause_Link
	Subq.w	#1,d3
	Move.l	a0,a3
.Pause_Link_Loop
	MOve.l	Aln_Link(a3),a3
	Dbra	d3,.Pause_Link_Loop
	St	Aln_Pauseflag(a3)
	Bra.s	.Comm66			
.Done_Pause_Link
	Rts
.Comm67	
	Move.w	(a2)+,d3		; Get link number
	Bmi.s	.Done_Pause_Link2
	Subq.w	#1,d3
	Move.l	a0,a3
.Pause_Link_Loop2
	MOve.l	Aln_Link(a3),a3
	Dbra	d3,.Pause_Link_Loop2
	Sf	Aln_Pauseflag(a3)
	Bra.s	.Comm67
.Done_Pause_Link2
	Rts


.Comm65	Cmp.w	#311,Aln_Anmset(a0)
	Bne.s	.No_Slide_Up
	Move.l	Aln_Link(a0),a3
	Move.w	#312,Aln_Anmset(a3)
	Subq.w	#1,Aln_X(a0)
	Move.l	a0,a3
	Moveq	#8-1,d7
.Shadow_Loop
	Move.l	Aln_Link(a3),a3
	Dbra	d7,.Shadow_Loop
	Addq.w	#1,Aln_ChildX(a3)
	Addq.w	#1,Aln_ChildY(a3)
	Move.l	Aln_Link(a0),a3
	Move.l	Aln_Link(a3),a3
	Cmp.b	#2,Aln_Anim(a3)
	Beq.s	.Done_Sliding
	Bsr	.Make_Leg_Go
	Bsr	.Make_Leg_Go
	Bsr	.Make_Leg_Go
	Bsr	.Make_Leg_Go
.No_Slide_Up
	Subq.l	#2,a2
	Rts
.Done_Sliding
	Bsr.s	.Make_Leg_Stop
	Bsr.s	.Make_Leg_Stop
	Bsr.s	.Make_Leg_Stop
	Bsr.s	.Make_Leg_Stop
	Move.l	Aln_Link(a0),a3
	Move.l	#Asteroid_Seq,Aln_Seqp(a3)
	Clr.w	Aln_Seqdec(a3)
	Move.l	Aln_Link(a3),a3
	Move.l	Aln_Link(a3),a3
	Move.l	Aln_Link(a3),a3
	Move.l	Aln_Link(a3),a3
	Move.l	Aln_Link(a3),a3
;	Move.l	Aln_Link(a3),a3
	Move.l	#Head_Track1,Aln_Seqp(a3)
	Clr.w	Aln_Seqdec(a3)
	Move.b	#3,Aln_Track_Val(a3)
	Move.w	#317,Aln_Anmset(a3)
	Clr.b	Aln_Anim(a3)
	Clr.b	Aln_Delay(a3)
	Move.l	Aln_Link(a3),a3
	Move.l	#Head_Track2,Aln_Seqp(a3)
	Clr.w	Aln_Seqdec(a3)
	Move.b	#3,Aln_Track_Val(a3)
	Move.w	#317,Aln_Anmset(a3)
	Clr.b	Aln_Anim(a3)
	Clr.b	Aln_Delay(a3)
	Rts

.Make_Leg_Stop
	St	Aln_Animcont(a3)
	St	Aln_Animflag(a3)
	Move.l	Aln_Link(a3),a3
	Rts

.Make_Leg_Go
	Sf	Aln_Animcont(a3)
	Sf	Aln_Animflag(a3)
	Move.l	Aln_Link(a3),a3
	Rts

.Comm64	Move.w	(a2)+,d3
	Move.l	a0,a3
.Loopyloop
	Move.l	Aln_Prevlink(a3),a3
	Subq.w	#1,d3
	Bne.s	.Loopyloop
	Move.w	(a2)+,Aln_Anmset(a3)
	Clr.b	Aln_Delay(a3)
	Clr.b	Aln_Anim(a3)
	Rts

.Comm63	Move.w	(a2)+,d2
	Move.l	a0,a3
	Tst.w	d2
	Beq.s	.Change_Sequence_Zero
.Loop_Link_Search
	Move.l	Aln_Link(a3),a3
	Subq.w	#1,d2
	Bne.s	.Loop_Link_Search
.Change_Sequence_Zero
	Clr.w	Aln_Seqdec(a3)	
	Move.l	(a2)+,Aln_Seqp(a3)
	Rts


.Comm62	
	Cmp.b	#48,Aln_Shite+21(a0)
	Beq.s	.Wings_Out
	Addq.b	#1,Aln_Shite+21(a0)
	Pea	(a0)
	Move.l	Aln_Link(a0),a0
	Move.l	Aln_Link(a0),a0
	Bsr.s	.Sub_Child
	Bsr.s	.Add_Child
	Move.l	Aln_Link(a0),a0
	Bsr.s	.Sub_Child
	Bsr.s	.Add_Child
	Bsr.s	.Sub_Child
	Bsr.s	.Add_Child
	Bsr.s	.Sub_Child
	Bsr.s	.Sub_Child
	Bsr.s	.Add_Child
	Bsr.s	.Add_Child
	Move.l	(sp)+,a0
	Subq.l	#2,a2
.Wings_Out
	Rts

.Add_Child
	Addq.w	#2,Aln_Childx(a0)
.Sub_Child
	Subq.w	#1,Aln_Childx(a0)
	Move.l	Aln_Link(a0),a0
	Rts

.Comm61	Move.w	(a2)+,d3
	Move.b	d3,Aln_Pownum(a0)
	Rts

.Comm59	Movem.w	(a2)+,d2-d4
	Move.l	a0,a1
	Tst.w	d2
	Beq.s	.Skip_Child2
.Loop2	Move.l	Aln_Link(a1),a1
	Subq.w	#1,d2
	Bne.s	.Loop2
.Skip_Child2
	Add.w	d3,Aln_Childx(a1)
	Add.w	d4,Aln_Childy(a1)
	Rts


.Comm49	Pea	(a0)
	Move.w	(a2)+,d2
.Comm49_Loop
	Move.l	Aln_Link(a0),a0
	Subq.w	#1,d2
	Bne.s	.Comm49_Loop
	Sf	Aln_Pauseflag(a0)
	Move.l	(sp)+,a0
	Rts

.Comm57	Move.w	(a2)+,d0
	Move.l	a0,a1
	Beq.s	.Skip_Child
.Loop4	Move.l	Aln_Link(a1),a1
	Subq.w	#1,d0
	Bne.s	.Loop4
.Skip_Child
	Move.l	(a2)+,Aln_Childx(a1)
	Rts

.Comm56	Move.w	Train_Links_Number(a4),d5
	Move.w	d5,Aln_Shite+22(a0)
	Lea	Train_Links(a4),a1
	Lsl.w	#2,d5
	Move.l	a0,(a1,d5)
	Addq.w	#1,Train_Links_Number(a4)
	Rts

.Comm55	Move.w	(a2)+,d0
	Move.l	(a2)+,a3
	Cmp.w	Aln_Anmset(a0),d0
	Beq.s	.No_Jump
	Move.l	a3,a2
.No_Jump
	Rts

.Comm53	Move.w	(a2)+,Aln_Shite(a0)
	Rts

.Comm51	Move.w	#14,Aln_Wave(a0)
	MOve.w	(a2)+,Aln_Shite(a0)
	MOve.w	(a2)+,Aln_Seqdec(a0)
	Clr.w	Aln_Shite(a0)
	Rts

.Comm48	Pea	(a0)
	Move.w	(a2)+,d2
.Comm48_Loop
	Move.l	Aln_Link(a0),a0
	Subq.w	#1,d2
	Bne.s	.Comm48_Loop
	St	Aln_Pauseflag(a0)
	Move.l	(sp)+,a0
	Rts

.Comm50	Pea	(a0)
	Move.w	(a2)+,d2
.Comm50_Loop
	Move.l	Aln_Link(a0),a0
	Subq.w	#1,d2
	Bne.s	.Comm50_Loop
	Clr.w	Aln_Anim(a0)
	Move.w	(a2)+,Aln_Anmset(a0)
	Move.l	(sp)+,a0
	Rts


.Comm42	Move.w	(a2)+,Guardian_Delay(a4)	; Set guardian delay
	Move.b	#30,Guardian_Music_On(a4)
	Push
	Jsr	Fadedown
	Pull
	Rts
.Comm43
	Addq.w	#1,Num_Guardians_Active(a4)
	Rts	
.Comm46	Move.w	(a2)+,d0
	Cmp.b	Aln_Anim(a0),d0
	Beq.s	.Anim_Reached
	Subq.l	#4,a2
.Anim_Reached
	Rts

.Comm54
	Move.w	(a2)+,d0
	Move.w	(a2)+,d1
	Move.l	a0,a1
.Slink_Loop
	Move.l	Aln_Link(a1),a1
	Subq.w	#1,d1
	Bne.s	.Slink_loop
	Cmp.b	Aln_Anim(a1),d0
	Beq.s	.Anim_Reached
	Subq.l	#6,a2
	Rts


.Comm47	Movem.w	Aln_X(a0),d0-d1
	Cmp.w	#-90,d1
	Ble	.Comm11
;	Cmp.w	#Screen_Height,d1
	Cmp.w	Height_Of_Screen(a4),d1
	Bge	.Comm11		
	Subq.l	#2,a2
	Rts

.Comm44	
;*!*!	
	Tst.b	Track_Del(a4)
	Bne.s	.No_Tween
	Move.l	Aln_Link(a0),a3
	Cmp.w	#42,Aln_Anmset(a3)
	Beq.s	.Tween_Up_Wheels
	Moveq	#4-1,d7
	Lea	.T_Link_Tween(pc),a1
.Tween_Loop1
	Move.w	#42,Aln_Anmset(a3)
	Clr.w	Aln_Anim(a3)
	Move.l	(a1)+,Aln_Childx(a3)
	Move.w	#104,Aln_sprite(a3)
	Move.l	Aln_Link(a3),a3
	Dbra	d7,.Tween_Loop1
.No_Tween
	Subq.l	#2,a2
	Rts
.Tween_Up_Wheels
	Moveq	#4-1,d7
	Lea	.Tlink_1(pc),a1
.Tween_Loop2
	Move.w	#40,Aln_Anmset(a3)
	Clr.w	Aln_Anim(a3)
	Move.l	(a1)+,Aln_Childx(a3)
	Move.w	#95,Aln_sprite(a3)
	Move.l	Aln_Link(a3),a3
	Dbra	d7,.Tween_Loop2
	Rts
		
.Tlink_1
	Dc.w	-4,+2,+25,+2,-4,+23,+23,+23

.Comm45	
	Tst.b	Track_Del(a4)
	Bne.s	.No_Tween
	Move.l	Aln_Link(a0),a3
	Cmp.w	#42,Aln_Anmset(a3)
	Beq.s	.Tween_RT_Wheels
	Moveq	#4-1,d7
	Lea	.T_Link_Tween(pc),a1
	Bra	.Tween_Loop1
.Tween_RT_Wheels
	Moveq	#4-1,d7
	Lea	.Tlink_2(pc),a1
.Tween_Loop4
	Move.w	#41,Aln_Anmset(a3)
	Clr.w	Aln_Anim(a3)
	Move.l	(a1)+,Aln_Childx(a3)
	Move.w	#99,Aln_sprite(a3)
	Move.l	Aln_Link(a3),a3
	Dbra	d7,.Tween_Loop4
	Rts

.Tlink_2
	Dc.w	-4,-2,+25,-2,-4,+27,+23,+27

.T_Link_Tween
	Dc.w	-4,+2,+25,+2,-4,+23,+23,+23

		
.Comm36	St	Aln_Pauseflag(a0)
	Rts
.Comm37	Sf	Aln_Pauseflag(a0)
	Rts

.Comm41	Cmp.w	#OFF,(a2)+
	Seq	Aln_Hitoveride(a0)
	Move.l	Aln_Link(a0),a3
;	Cmp.w	#8,Aln_Anmset(a3)
;	Bne.s	.No_Turret
	Move.b	Aln_Hitoveride(a0),Aln_Hitoveride(a3)
.No_Turret
	Rts	


.Comm40	
	Movem.w	Aln_X(a0),d0-d1
	Cmp.w	#-16,d1
	Ble.s	.Xity
;	Cmp.w	#Screen_Height,d1
	Cmp.w	Height_Of_Screen(a4),d1
	Bge.s	.Xity
	Cmp.w	Right_Hand_Screenxbound(a4),d0
	Bge.s	.Xity
	Move.w	X_Offset_Into_Map(a4),d3
	Sub.w	#16,d3
	Cmp.w	d3,d0
	Ble.s	.Xity
	Subq.l	#2,a2
	Rts	
.Xity	Bra	.Comm11
	
.Comm38	Move.w	#12,(a1)
	Move.w	(a2)+,Aln_Seqdec(a0)
	Rts			

.Comm35	
	Cmp.w	#400,Aln_Dmg(a0)
	Bgt.s	.Nothp100
	Move.l	Aln_Link(a0),a1
	Move.l	#Do_Nothing_Seq,Aln_Seqp(a1)
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Move.l	#Center_Lev2seq,Aln_Seqp(a1)
	Lea	Mad_Guardian2Seq,a2
.Nothp100
	Rts

.Comm33	
	Move.l	Aln_Link(a0),a1
	Subq.w	#1,Aln_ChildY(a1)
	Cmp.w	#2,Aln_Childy(a1)
	Bne.s	.Not_Top
	Addq.l	#2,a2
.Not_Top
	Subq.l	#2,a2
	Rts	

.Comm34	Move.l	Aln_Link(a0),a1
	Addq.w	#1,Aln_ChildY(a1)
	Cmp.w	#14,Aln_Childy(a1)
	Bne.s	.Not_Bot
	Addq.l	#2,a2
.Not_Bot
	Subq.l	#2,a2
	Rts	

.Comm58	Move.w	(a2)+,d3
	Move.l	a0,a1
.Loop_Linko
	Move.l	Aln_Link(a1),a1
	Subq.w	#1,d3			
	Bne.s	.Loop_Linko
	St	Aln_Animcont(a1)
	Rts

.Comm60	Move.w	(a2)+,d3
	Move.l	a0,a1
.Loop_Linkz
	Move.l	Aln_Link(a1),a1
	Subq.w	#1,d3			
	Bne.s	.Loop_Linkz
	Sf	Aln_Animcont(a1)
	Sf	Aln_Animflag(a1)
	Rts

.Comm29	St	Aln_Animcont(a0)
	Rts
.Comm30	St	Aln_Animcont(a0)
	Sf	Aln_Animflag(a0)
	Rts
.Comm31	Sf	Aln_Animcont(a0)
	Sf	Aln_Animflag(a0)
	Rts

.Comm32	Move.l	a0,a3
.Search_Prev_Link
	Tst.l	Aln_Prevlink(a3)
	Bmi.s	.Found_Prevlink
	Move.l	Aln_Prevlink(a3),a3
	Bra.s	.Search_Prev_Link
.Found_Prevlink
	Cmp.l	#1,Aln_Shite(a3)
	Bne.s	.comm31
	Bra.s	.Comm29
			
.Comm0	Move.w	#0,(a1)+		; Abs Move
	Addq.l	#4,a1			; Get into alien shite
	Move.w	(a2)+,(a1)+		; X vector
	Move.w	(a2)+,(a1)+		; Y vector
	Move.w	(a2)+,Aln_Seqdec(a0)	; Decrement time
	Rts

.Comm1	Move.w	#1,(a1)+		; Left right sine
	Sf	d5			; Clear flag for half-circle
.Comm1b	Addq.l	#4,a1			; Skip x/y Coardinates
	Lea	Alien_Sine(pc),a3	; Sine table pointer
	Move.w	(a2)+,d4		; Get Sine value
	Move.w	d4,(a1)+		; Sine val -Saved
	Move.w	(a2)+,(a1)+		; Sine speed
	Move.w	(a2)+,(a1)+		; Scale factor
	Tst.b	d5			; Half A flag ?
	Beq.s	.No_Shift
	Lsr.w	#1,d4			; /2 the angle (uses only half a sine table)
.No_Shift
	Add.w	d4,d4
	Move.w	(a3,d4),d4		; Previous sine value !
	Muls	-2(a1),d4		; Multilplied by scale
	Add.l	d4,d4
	Swap	d4
	Move.w	d4,(a1)+		; Divide by 32768, and save previous sine value
	Move.l	(a2)+,(a1)+		; x/y Add
	Move.w	(a2)+,Aln_Seqdec(a0)	; Decrement time
	Rts
	
.Comm2	Move.w	#2,(a1)+		; Up down sine
	Sf	d5			; Flag for full sine
	Bra.s	.Comm1b			; Same process for LR sine

.Comm3	Move.w	#3,(a1)+		; XSWOOP
	St	d5			; Half circle
	Bra.s	.Comm1b

.Comm4	Move.w	#4,(a1)+		; YSWOOP
	St	d5			; Half circle
	Bra.s	.Comm1b

.Comm5	Move.w	(a2)+,Aln_Repeat(a0)
	Move.l	a2,Aln_Replocate(a0)	; Repeat location starts at next macro
	Rts

.Comm6	Subq.w	#1,Aln_Repeat(a0)	; 1 from repeat !
	Beq.s	.Comm6E
	Move.l	Aln_Replocate(a0),a2	; Set repeat location
.Comm6E	Rts

.Comm7	Move.l	(a2)+,d0		; Goto !
	Move.l	a2,Aln_Stack(a0)	; Save return address
	Move.l	d0,a2			; Set new program counter
	Rts

.Comm8	Move.l	Aln_Stack(a0),a2	; Get return address off "STACK"!
	Rts

.Comm9 	Move.l	(a2),a2			; Set branch pointer
	Rts

.Comm10 Move.l	Aliens_Insert_P(a4),a3
	Move.w	(a2)+,(a3)+		; Weapon number !
	Move.l	a0,(a3)+ 		; Start of this X/Y and shit !
	Move.w	Unique_Fire(a4),Aln_Unique_fire(a0)
	Move.w	Unique_Fire(a4),(a3)+
	Addq.w	#1,Unique_Fire(a4)
	Move.l	a3,Aliens_Insert_P(a4)	; Restore pointer !
.Off_Screen
	Rts

.Comm11	
	Cmp.w	#Planedn_Anm_Set,Aln_Anmset(a0)
	Beq.s	.Plane_Up
	Move.l	a0,a1
	Move.w	Number_Of_Sprites_In_Activelist(a4),-(sp)
	Bsr	Kill_Link
	Move.w	(sp)+,Number_Of_Sprites_In_Activelist(a4)
	Clr.w	(a0)
	Rts

.Plane_Up
	Move.w	#Planeup_Anm_set,Aln_Anmset(a0)
	Lea	Up_Plane_Seq(pc),A2
	Lea	Planeup_Link(pc),a1
	Move.l	(a1),a1
	Move.l	Aln_Link(a0),a3
	Move.l	(a1)+,Aln_Childx(a3)
	Move.w	#12,Aln_Anmset(a3)
	Move.l	Aln_Link(a3),a3
	Move.l	(a1)+,Aln_Childx(a3)
	Move.w	#12,Aln_Anmset(a3)
	Rts

.Comm12	Move.w	#5,(a1)+
	Addq.l	#4,a1			Skip x/y
	Move.l	(a2)+,(a1)+
	Move.l	(a2)+,(a1)+
	Move.l	(a2)+,(a1)+
	Clr.l	(a1)+
	Move.l	(a2)+,(a1)+
	Move.w	(a2)+,Aln_Seqdec(a0)
	Rts

.Comm13	
	Move.w	#6,(a1)+		Attack Wave 7
	Addq.l	#4,a1
	Pea	(a1)
	Cmp.w	#$7fff,(a2)
	Bne.s	.Skip_Ang
	Cmp.w	(a2)+,(a1)+
	Move.w	(a2)+,(a1)+
	Bra.s	.Skip_Ang2
.Skip_Ang
	Move.l	(a2)+,(a1)+
.Skip_Ang2
	Move.w	(a2)+,(a1)+
	Move.w	#$8000,(a1)+
	Move.w	#$8000,(a1)+
	Move.w	(a2)+,Aln_Seqdec(a0)
	Move.l	(sp)+,a1
	Rts

.Comm52	Move.w	#15,(a1)+		Attack Wave 15
	Addq.l	#4,a1
	Cmp.w	#$7fff,(a2)
	Bne.s	.Skip_Ang1
	Cmp.w	(a2)+,(a1)+
	Move.w	(a2)+,(a1)+
	Bra.s	.Skip_Ang3
.Skip_Ang1
	Move.l	(a2)+,(a1)+
.Skip_Ang3
	Move.w	(a2)+,(a1)+
	Clr.w	(a1)+
	Clr.w	(a1)+
	Move.w	(a2)+,Aln_Seqdec(a0)
	Rts

.Comm14	Move.w	#7,(a1)+		Attack wave 8 
	Move.w	(a2)+,Aln_Seqdec(a0)	Set delay for track !
	Rts

.Comm15	Move.w	#8,(a1)+		Attack wave 9
	Addq.l	#4,a1
	Move.l	(a2)+,(a1)+		Set vectors !
	Clr.w	(a1)+			Clear X offset !
	Move.w	#$6fff,Aln_Seqdec(a0)	Abs. Delay
	Rts

.Comm16	Move.w	#9,(a1)+		Attack wave 10
	Moveq	#0,d0
	Moveq	#0,d1
	Move.w	(a1)+,d0
	Move.w	(a1)+,d1		Get X/Y
	Clr.l	(a1)+			Fractions for X/Y!
	Sub.w	#Byteswide/2,d0
	Smi	d6			Set if negative
	Bpl.s	.Uk0
	Neg.w	d0
.Uk0	Sub.w	#120,d1			Get x/y vectors
	Smi	d7
	Bpl.s	.Uk2
	Neg.w	d1
.Uk2	Cmp.w	d0,d1
	Slt	d2			Set if d1 is Less than!
	Bge.s	.UK1
	Exg	d0,d1
.Uk1	Movem.w	(a0)+,d0-d3		x/y/xv/yv Fractions
	Add.w	d2,d0
	Add.w	d3,d1
.Comm17	Rts

.Comm18	Bra.s	.Comm18

.Comm19	Move.w	#10,(a1)+			Attack wave 11
	Addq.l	#4,a1
	Move.w	(a2)+,d5			Vector scale!
	Move.w	(a2)+,Aln_Seqdec(a0)		Delay !
	Move.w	14+28(a0),d3			Angle in
	Pea	(a0)
;	Lea	VectorTab(pc),a0
	Asl.w	#2,d3
	Movem.w	(a0,d3),d3-d4
	Move.l	(sp)+,a0
	Asr.w	#1,d3
	Asr.w	#1,d4
	Muls	d5,d3
	Muls	d5,d4
	Movem.w	d3-d4,(a1)
	Rts
 
.Comm20	Sf	Flag_To_Stop_Scrolling(a4)
	Rts
 
.Comm21	St	Flag_To_Stop_Scrolling(a4)
	Rts

.Comm22	
;	Move.l	Aln_X(a0),Flag_To_Spit_Out(a4)
	Rts

.Comm23	Move.w	#100,Aln_Seqdec(a0)
	Move.w	#Zoomer_Anm_Set,Aln_Anmset(a0)
	Clr.w	Aln_Anim(a0)
	Move.w	#11,(a1)+
	Rts

.Comm24	Tst.w	Aln_Shite+22(a0)
	Bne.s	.No_Init
	Move.w	#10,Aln_Shite+22(a0)
.No_Init
	Subq.l	#2,a2
	Move.w	#1,Aln_Seqdec(a0)	

	Move.l	Aln_Link(a0),a1
	Subq.w	#1,Aln_Childx(a1)
	Move.l	Aln_Link(a1),a1
	Addq.w	#1,Aln_Childx(a1)
	Move.l	Aln_Link(a1),a1
	Subq.w	#1,Aln_Childx(a1)
	Move.l	Aln_Link(a1),a1
	Addq.w	#1,Aln_Childx(a1)
	Not.b	Aln_Shite+21(a0)
	Beq.s	.Noy_Modis
	Move.l	Aln_Link(a1),a1
	Addq.w	#1,Aln_Childy(a1)
	Move.l	Aln_Link(a1),a1
	Addq.w	#1,Aln_Childy(a1)
	Move.l	Aln_Link(a1),a1
	Subq.w	#1,Aln_Childy(a1)
	Move.l	Aln_Link(a1),a1
	Subq.w	#1,Aln_Childy(a1)
.Noy_Modis
	Subq.w	#1,Aln_Shite+22(a0)
	Bne.s	.No_Exit_Mid2
	Addq.l	#2,a2
.No_Exit_Mid2
	Rts

.Comm25	Subq.l	#2,a2
	Tst.b	Flip_Flag(a4)
	Beq	.No_Flip_PUP_Ship
	Movem.l	a0,-(sp)
	Move.l	Aln_Link(a0),a0
	Move.l	Aln_Link(a0),a0
	Move.l	Aln_Link(a0),a0
	Move.l	Aln_Link(a0),a0
	Moveq	#3+2,d7
.Loop_Do_Anim
	Subq.w	#1,d7
	Beq.s	.Restore_Regs
	Cmp.w	#23,Aln_Anmset(a0)
	Beq.s	.Tween
	Move.w	#13,Aln_Anmset(a0)
	Clr.b	Aln_Delay(a0)
	Clr.b	Aln_Anim(a0)
	Move.l	Aln_Link(a0),a0
	Bra.s	.Loop_Do_Anim
.Tween	Move.w	#24,Aln_Anmset(a0)
	Clr.b	Aln_Delay(a0)
	Clr.b	Aln_Anim(a0)
	Move.l	Aln_Link(a0),a0
	Bra.s	.Loop_Do_Anim
.Restore_Regs
	Move.l	Aln_Prevlink(a0),a0
	Move.l	Aln_Prevlink(a0),a0
	Move.l	Aln_Prevlink(a0),a0
	Cmp.w	#13,Aln_Anmset(a0)
	Bne.s	.No_Next_Command
	Move.l	Aln_Link(a0),a0
	Move.l	Aln_Link(a0),a0
	Move.l	Aln_Link(a0),a3
	St	Aln_Link(a0)
	Move.l	Aln_Link(a3),a0
	Clr.w	Aln_Dmg(a3)
	Clr.l	Aln_Link(a3)
	Clr.w	Aln_Dmg(a0)
	Clr.l	Aln_Link(a0)
	Addq.l	#2,a2
.No_Next_Command
	Move.l	(sp)+,a0
.No_Flip_PUP_Ship
	Rts	

.Comm26	
	Move.w	(a2)+,-(sp)		; Number of frames to tween on stack
	Move.w	6(a1),d3		; Current Angle
	And.w	#$ff,d3			; Mask
	Move.w	d3,d4			; Save current angle
	Add.b	#$80,d4			; Half a circle
	Sub.w	2(a2),d3		; Get anticlockwise difference
	Bpl.s	.Posok1
	Neg.w	d3
.PosOk1	Sub.w	2(a2),d4		; Get clockwise difference
	Bpl.s	.Posok2
	Neg.w	d4
.Posok2
	Moveq	#-1,d2			; Set to anti clockwise
	Sub.w	d3,d4
	Bge.s	.AntiClock		; Its anticlockwise anyway!
	Neg.w	d4
	Moveq	#1,d2			
.AntiClock
	Move.w	#6,(a1)+		; Attack Wave 7	(Move along a vector)
	Addq.l	#4,a1			; Points to sprite data move area
	Addq.l	#2,a1			; Skip current sine value !
	Move.w	(sp)+,d5
	Ext.l	d4
	Tst.w	d5
	Bne.s	.Okdiv
	Moveq	#0,d4
	Bra.s	.Skipdiv
.Okdiv
	Divu	d5,d4
.Skipdiv
	Muls	d2,d4
	Move.w	d4,(a1)+		; Set direction !
	Clr.w	(a1)+			; Sine Scale
	Clr.w	(a1)+			; Clear out remainder
	Clr.w	(a1)+
	Move.w	d5,Aln_Seqdec(a0)	; Set decrement for sine
	Rts

.Comm27	
	Move.l	Player_Use(a4),a3
	Lea	Pl1,a3
	Move.w	Aln_X(a0),d0		; Get aliens X coardinate
	Move.w	Shipxy(a3),d1		; Get Players X coardinate
	Add.w	X_Offset_Into_Map(a4),d1	; Add Base of playfield
	Add.w	#16,d0
	Move.w	d0,d2			; Save playerrs X coardinate
	Add.w	#32,d2
	Add.w	#16,d1
	Move.w	#0,(a1)+		; Abs move
	Addq.l	#4,a1			; Skip x/y
	Moveq	#0,d4			; Set X vector to 0
	Moveq	#3,d5
	Cmp.w	d0,d1
	Blt.s	.Ship_Is_To_The_Left	; If ships X is less than plane X
	Cmp.w	d2,d1
	Ble.s	.Straight_Down
.Ship_Is_To_The_Right
	Addq.w	#4,d4			; Add 4 (Not subtracting 2, therefore move x +2)		
.Ship_Is_To_The_Left
	Subq.w	#2,d4			; Move x -2
.Straight_Down
	Movem.w	d4-d5,(a1)		; Set x/y Interger adds
	Move.w	#70,Aln_Seqdec(a0)	; Set decrement to fixed value (should go off screen)
	Rts
	
.Comm28
	Move.w	#13,(a1)+
	Addq.l	#4,a1
	Clr.w	12(a1)
	Clr.w	Aln_Shite+2(a0)
	Move.w	#$7fff,Aln_Seqdec(a0)
	Rts

.Comm39	Clr.w	Aln_Anim(a0)
	Move.w	(a2)+,Aln_Anmset(a0)
	Rts

**********************************************************
Sort_Aliens
	Jsr	Wait_For_Gpu
	Move.l	Num_Objects_In_List,d7
	Move.w	d7,Number_Of_Sprites_On_Screen(a4)
	Lea	Sort_Params,a0
	Move.l	#Quick_Mul+Data,(a0)+
	Move.l	#Sort_Counts+Data,(a0)+
	Move.l	Alien_Sort_Pointer(a4),(a0)+
	Clr.w	(a0)+
	Move.w	Number_Of_Sprites_On_Screen(a4),(a0)+		; Number to draw in register
	Move.l	#Draw_Check_Table+Data,(a0)+
	Move.l	#Aln_spr_Priority,(a0)+
	Lea	Gpu_Sort,a0
	Jsr	Start_GPU
	Jsr	Wait_For_Gpu
	Rts	

Sort_Aliens68k
	Lea	Quick_Mul(a4),a6
	Lea	Sort_Counts(a4),a5
	Move.l	Alien_Sort_Pointer(a4),a0
	Moveq	#15,d0
	Move.l	#(Max_Aliens/2)*4,d1
	Moveq	#-1,d6
.Mloop	Move.l	a0,(a6)+
	Move.w	d6,(a5)+
	Add.l	d1,a0
	Dbra	d0,.Mloop
	Move.l	Quick_Mul+8*4(a4),a3
	St	(a3)
	Addq.w	#1,Sort_Counts+8*2(a4)
	Addq.l	#4,Quick_Mul+8*4(a4)
	Move.w	Number_Of_Sprites_On_Screen(a4),d7		; Number to draw in register
	Subq.w	#1,d7
	Blt.s	.Exit				; None to draw, exit !
	Moveq	#0,d2				; Clear reg for index
	Lea	Sort_Counts(a4),a2
	Lea	Quick_Mul(a4),a5
	Lea	Draw_Check_Table(a4),a1
	Moveq	#0,d2
.Loop	Move.l	(a1)+,a0
	Move.b	ALN_SPR_Priority(a0),d2
	Addq.w	#1,(a2,d2)
	Add.w	d2,d2
	Move.l	(a5,d2),a3
	Move.l	a0,(a3)+
	Move.l	a3,(a5,d2)
	Dbra	d7,.Loop
.Exit	Lea	Quick_Mul(a4),a6
	Move.l	Alien_Sort_Pointer(a4),a0
	Moveq	#15,d0
	Move.l	#(Max_Aliens/2)*4,d1
.Mloop2	Move.l	a0,(a6)+
	Add.l	d1,a0
	Dbra	d0,.Mloop2
	Lea	Data,a4
	Move.l	Alien_Sort_Pointer(a4),a1
	Lea	Quick_Mul(a4),a2
	Lea	Sort_Counts(a4),a3
	Moveq	#16-1,d3
.Loop0	Move.l	(a2)+,a0
	Move.w	(a3)+,d0
	Bmi.s	.No_Loop0
.Loop3	Move.l	(a0)+,(a1)+
	Dbra	d0,.Loop3
.No_Loop0
	Dbra	d3,.Loop0
	St	(a1)
	Rts
	
**********************************************************
Draw_Alien_Shadows
	Movem.l	d0-d7/a1-a6,-(sp)
	Move.w	Number_Of_Sprites_In_Activelist(a4),d0
	Ble.s	.Done
	Lea	ALN_Activelist(a4),a2
	Subq.w	#1,d0
.Loop	Move.l	(a2)+,a1
	Move.w	Aln_Shadsprite(a1),d2
	Bgt.s	.Draw_Shadow
	Dbra	d0,.Loop
.Done	Movem.l	(sp)+,d0-d7/a1-a6
	Rts	
.Draw_Shadow
	Move.w	d0,-(sp)
	Moveq	#30,d0
	Moveq	#30,d1
	Add.w	Aln_X(a1),d0
	Add.w	Aln_Y(a1),d1
	Bsr	Quick_Enemy_Blit_Shadow
	Move.w	(sp)+,d0
	Dbra	d0,.Loop
	Bra.s	.Done

**********************************************************
Quick_Enemy_Blit_Shadow
	Lsl.w	#4,d2
	Sub.w	X_Offset_Into_Map(a4),d0
	And.w	#%111111111111,d0
	Tst.w	d1
	Bmi.s	.Clip_Y
;	Cmp.w	#Playfield_Height,d1
	Move.w	Height_Of_Screen(a4),d4
	Cmp.w	d4,d1
	Bge.s	.No_Display
	Add.w	d1,d1
	Movem.l	(a6,d2),d4-d7
	Move.l	a0,d3
	Addq.l	#8,d3
	Addq.l	#8,d3
	Moveq	#11,d2
	Ror.l	d2,d3
	Or.w	d3,d4
	Clr.w	d3
	Or.l	d3,d5
	Lsl.w	#3,d1
	Add.w	d1,d5
	Or.w	d0,d7
	Or.l	#%10100000000000000,d6
	Movem.l	d4-d7,(a0)
	Lea	16(a0),a0
	Addq.w	#1,Num_Objects_To_Display(a4)
.No_Display
	Rts

.Clip_Y	Move.w	d1,d3
	Add.w	Spr_Sheight(a3,d2),d3
	Ble.s	.No_Display
	Movem.l	(a6,d2),d4-d7	
	Moveq	#0,d3
	Neg.w	d1
	Move.w	d1,d3
	Lsl.l	#8,d3
	Lsl.l	#6,d3
	Sub.l	d3,d5

	Move.w	Spr_Pixel_Width(a3,d2),d3
	Subq.w	#1,d3
	Lsr.w	#6,d3
	Addq.w	#1,d3
	Lsl.w	#3,d3
	Mulu	d3,d1
	

	Moveq	#43-32-3,d3
	Lsl.l	d3,d1
	Add.l	d1,d4
	Move.l	a0,d3
	Addq.l	#8,d3
	Addq.l	#8,d3
	Moveq	#11,d2
	Ror.l	d2,d3	
	Or.w	d3,d4
	Clr.w	d3
	Or.l	d3,d5
	Or.w	d0,d7
	Or.l	#%10100000000000000,d6		; Bits 16 & 14
	Movem.l	d4-d7,(a0)
	Lea	16(a0),a0
	Addq.w	#1,Num_Objects_To_Display(a4)
	Rts

**********************************************************
Draw_Aliens
;	Bra	Draw_Aliens68k
	Jsr	Wait_For_GPU
	Lea	Draw_Aliens_Params,a0
	Move.w	#0,(a0)+
	Move.w	Number_Of_Sprites_On_Screen(a4),(a0)+
	Move.l	Alien_Sort_Pointer(a4),(a0)+
	Move.l	Enemy_Sprites_Base(a4),(a0)+
	Move.l	#Pre_Generated_Objects,(a0)+
	Move.l	Current_List_Pointer(a4),(a0)+
	Move.l	#Aln_Sprite,(a0)+
	Move.l	#Aln_Hit,(a0)+
	Move.l	#Sprite_Display_Hit_Table,(a0)+
	Move.l	#Aln_Half_DaMaGe,(a0)+
	Move.l	#Sprite_Display_DMG_Table,(a0)+
	Move.l	#Aln_DMG_DEC,(a0)+
	Move.l	#Aln_X_Offseted,(a0)+
	Move.w	#0,(a0)+
	Move.w	X_Offset_Into_Map(a4),(a0)+
	MOVE.L	#Flame_Offset_Table,(A0)+

	Lea	GPU_DRAW_ALIENS,a0
	Jsr	Start_GPU
	Jsr	Finish_Drawing
	Move.l	Current_List_Pointer(a4),a0
	Movem.l	d0-d7/a1-a6,-(sp)
	Bsr	Other_Map_To_Object
	Movem.l	(sp)+,d0-d7/a1-a6
	Lea	XDraw_Aliens_Shadow_Params,a0

	Clr.w	(a0)+
	Move.w	Number_Of_Sprites_In_Activelist(a4),(a0)+
	Move.l	#ALN_Activelist+Data,(a0)+
	Move.l	#Aln_Shadsprite,(a0)+
	Move.l	Current_List_Pointer(a4),(a0)+
	MOve.l	#Aln_X,(a0)+
	Clr.w	(a0)+
	Move.w	X_Offset_Into_Map(a4),(a0)+
	Clr.w	(a0)+
	Move.w	Right_Hand_Screenxbound(a4),(a0)+
	Move.l	Enemy_Sprites_Base(a4),(a0)+
	Move.l	#Pre_Generated_Objects,(a0)+
	Clr.w	(a0)+
	Move.w	Height_Of_Screen(a4),(a0)+

	Lea	XGpu_Draw_Aliens_Shadow,a0
	Jsr	Start_GPU
	Jsr	Finish_Drawing

	Move.l	Alien_Sort_Pointer(a4),a3
.Loopy	Tst.l	(a3)+
	Bpl.s	.Loopy
	Lea	Draw_Aliens_Params,a0
	Move.l	#$7fff,(a0)+
	Move.l	a3,(a0)+
	Move.l	Enemy_Sprites_Base(a4),(a0)+
	Move.l	#Pre_Generated_Objects,(a0)+
	Move.l	Current_List_Pointer(a4),(a0)+
	Move.l	#Aln_Sprite,(a0)+
	Move.l	#Aln_Hit,(a0)+
	Move.l	#Sprite_Display_Hit_Table,(a0)+
	Move.l	#Aln_Half_DaMaGe,(a0)+
	Move.l	#Sprite_Display_DMG_Table,(a0)+
	Move.l	#Aln_DMG_DEC,(a0)+
	Move.l	#Aln_X_Offseted,(a0)+
	Clr.w	(a0)+
	Move.w	X_Offset_Into_Map(a4),(a0)+
	MOVE.L	#Flame_Offset_Table,(A0)+
	Lea	GPU_DRAW_ALIENS,a0
	Jsr	Start_GPU
	Rts

Draw_Aliens68k
	Move.w	Number_Of_Sprites_On_Screen(a4),-(sp)
	Move.w	(sp),d7	
;	Add.w	d7,Num_Objects_To_Display(a4)
	Addq.w	#1,(sp)
	Move.l	Alien_Sort_Pointer(a4),a2
	Move.l	Enemy_Sprites_Base(a4),a3
	Lea	Pre_Generated_Objects,a6
	Move.l	Current_List_Pointer(a4),a0
.Loop	Move.l	(a2)+,d0
	Bpl.s	.Positive_Address
	Movem.l	d0-d7/a1-a6,-(sp)
	Bsr	Other_Map_To_Object
	Movem.l	(sp)+,d0-d7/a1-a6
	Bsr	Draw_Alien_Shadows
	Bra	.Dec
.Positive_Address
	Move.l	d0,a1
	Move.w	Aln_Sprite(a1),d2
	Bmi	.Dec
	Tst.b	Aln_Hit(a1)
	Beq.s	.No_Sprite_Hit
	Clr.b	Aln_Hit(a1)
	Lea	Sprite_Display_Hit_Table,a5
	Move.w	d2,d3
	Add.w	d3,d3
	Move.w	(a5,d3),d3
	Bmi.s	.No_Sprite_DMG
	Move.w	d3,d2
	Bra.s	.No_Sprite_DMG
.No_Sprite_Hit
	Tst.w	Aln_Half_Damage(a1)
	Bge.s	.No_Sprite_DMG
	Btst	#2,Aln_DMG_Dec(a1)
	Beq.s	.No_Sprite_DMG
	Lea	Sprite_Display_DMG_Table,a5
	Move.w	d2,d3
	Add.w	d3,d3
	Move.w	(a5,d3),d3
	Bmi.s	.No_Sprite_DMG
	Move.w	d3,d2
.No_Sprite_DMG
	Move.w	Aln_X_Offseted(a1),d0
	Move.w	Aln_X_Offseted+2(a1),d1
	Bsr	Quick_Enemy_Blit
	Tst.w	Aln_Half_Damage(a1)
	Bge.s	.Dec
	Move.w	Aln_Sprite(a1),d2
	Lea	Flame_Offset_Table,a5
	Add.w	d2,d2
	Add.w	d2,d2
	Move.l	(a5,d2),d4
	Beq.s	.Dec
	Moveq	#1,d3
	And.b	Aln_DMG_Dec(a1),d3
	Add.w	#912,d3
	Move.l	d4,a5
	Move.w	d3,-(sp)
	Move.w	(a5)+,-(sp)
.Flame_Loop
	Movem.w	Aln_X(a1),d0-d1
	Add.w	(a5)+,d0
	Add.w	(a5)+,d1
	Move.w	2(sp),d2
	Bsr	Quick_Enemy_Blit
	Subq.w	#4,(sp)
	Bne.s	.Flame_Loop
	Addq.l	#4,sp
.Dec	Subq.w	#1,(sp)
	Bne	.Loop
	Addq.l	#2,sp
	Lea	Data,a4
	Move.l	a0,Current_List_Pointer(a4)
	Rts		

**********************************************************
Draw_Weapons
;	Bra	Draw_Weapons68k
	Lea	Pl1,a3
	Bsr.s	.Do
	Jsr	Finish_Drawing
	Lea	Pl2,a3

.Do	Lea	Weapon_Params,a0
	Lea	Shots_To_Do(a3),a1
	Move.l	a1,(a0)+
	Move.l	#Max_Weapons,(a0)+
	Move.l	Player_Sprite_Base(a4),(a0)+
	Move.l	#Pre_Generated_Player_Objects,(a0)+
	Move.l	Current_List_Pointer(a4),(a0)+
	Move.l	#Wep_X,(a0)+
	Move.l	#Wep_Sprite_Num,(a0)+
	Clr.w	(a0)+
	Move.w	X_Offset_Into_Map(a4),(a0)+
	Move.l	#Wep_End,(a0)+	
	Lea	Draw_Weapons_GPU,a0
	Jsr	Start_Gpu
	Rts


Draw_Weapons68k
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
.Do	Lea	Shots_To_Do(a3),a1
	Move.l	Player_Sprite_Base(a4),a3
	Lea	Pre_Generated_Player_Objects,a6
	Move.l	Current_List_Pointer(a4),a0
	Move.w	#Max_Weapons,-(sp)
.Loop	Tst.b	(a1)
	Ble.s	.Dec
	Movem.w	Wep_X(a1),d0-d1
	Moveq	#0,d2
	Move.b	Wep_Sprite_Num(a1),d2
	Sub.w	X_Offset_Into_Map(a4),d0
	Bsr	Quick_Player_Blit
.Dec	Lea	Wep_End(a1),a1
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Move.l	a0,Current_List_Pointer(a4)
	Rts
	
**********************************************************
Move_Weapons
	Jsr	Wait_For_Gpu
	St	Home_Dir(a4)
	Lea	Pl1,a3
	Bsr.s	.Do_Move
	Jsr	Wait_For_Gpu
	Lea	Pl2,a3

.Do_Move
	Lea	Home_Dir(a4),a6
.Find	Tst.l	(a6)+
	Bpl.s	.Find
.Done	Subq.l	#4,a6
	Lea	Move_Weapon_Params,a0
	Move.l	a6,(a0)+
	Lea	Shots_To_Do(a3),a1
	Move.l	a1,(a0)+
	Move.l	#Wep_Anims,(a0)+
	Move.l	#Alien_Sine,(a0)+
	Lea	Weapon_Active_List(a3),a1
	Move.l	a1,(a0)+
	Move.l	#Max_Weapons,(a0)+
	Lea	Num_Homes(a3),a1
	Move.l	a1,(a0)+
	Move.l	#Player_Boxes,(a0)+	
	Clr.w	(a0)+
	Move.w	X_Offset_Into_Map(a4),(a0)+
	Clr.w	(a0)+
	MOve.w	Height_Of_Screen(a4),(a0)+
	Lea	Gpu_Move_Weapons,a0
	Jsr	Start_Gpu
	Rts
	


.GOO	Lea	Home_Dir(a4),a6
	Move.l	a6,Home_Dirp(a4)
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
	
.Do	Lea	Shots_To_Do(a3),a0
	Lea	Wep_Anims,a2
	Lea	Alien_Sine(pc),a5
	Lea	Weapon_Active_List(a3),a1

	Moveq	#Max_Weapons-1,d7
.Back	Moveq	#Wep_End,d6
.Loop	Tst.b	Wep_Dmg(a0)		; Test damage
	Bgt.s	.Weapon_Active
	Add.l	d6,a0
	Dbra	d7,.Loop
	Bra	.Exit	

.Weapon_Active
	Moveq	#0,d0
	Moveq	#0,d1
	Moveq	#0,d6
	Tst.b	Is_Weapon_A_Homing_Missle(a0)
	Beq.s	.Not_Homing
	Tst.b	Is_Weapon_A_Rocket(a0)
	Bne.s	.Death_Bolt_MOve
	Bsr	.Move_At_An_Angle
	Beq.s	.Homing_Still_On_Screen
	Subq.b	#1,Num_Homes(a3)
	Bra	.Remove_Weapon_From_List
.Death_Bolt_MOve
	Bsr	.Animate_Weapon
	Bsr	.Move_At_An_Angle
	Bne	.Remove_Weapon_From_List
	Bra	.Not_A_Rocket

.Homing_Still_On_Screen
	Move.b	Wep_Sprite(a0),d6		; Sprite number
	Asl.w	#2,d6
	Move.l	(a2,d6),a6			; Pointer to sprite anims !
	Move.w	Wep_Xv(a0),d6
	Lsr.b	#4,d6				; 0-15!
	Add.b	1(a6),d6			; Add to Base anim!
	MOve.b	d6,Wep_Sprite_Num(a0)
	Move.l	Home_Dirp(a4),a6
	Move.l	a0,(a6)+	
	Move.l	a6,Home_Dirp(a4)
	Bra	.Not_A_Rocket
.Remove_Weapon_From_List
	Clr.b	(a0)
	Bra	.Dec

.Not_Homing	
	Bsr	.Animate_Weapon
	Movem.w	Wep_X(a0),d0/d2-d4	; Collect x/y/xv/yv
	Add.w	d3,d0
	Add.w	d4,d2			; Add em up
	Bsr	.Check_Weapon_Bound
	Bne.s	.Remove_Weapon_From_List
	Tst.b	Is_Weapon_A_Rocket(a0)
	Beq.s	.Not_A_Rocket
	Moveq	#0,d3
	Moveq	#0,d5
	Move.b	Wep_Sine_Val(a0),d3
	Move.b	Wep_Sine_Scale(a0),d5
	Add.b	Wep_Sine_Speed(a0),d3
	Scs	d4
	Or.b	d4,d3
	Move.b	d3,Wep_Sine_Val(a0)
	Lsr.w	#2,d3
	Add.w	d3,d3
	Addq.w	#1,d5
	Mulu	-30(a5,d3),d5
	Add.l	d5,d5
	Swap	d5
	Sub.w	d5,d2
.Not_A_Rocket
	Movem.w	d0/d2,Wep_X(a0)		; Save X/Y!
	Moveq	#0,d3
	Move.b	Wep_Sprite_Num(a0),d3
	Lsl.w	#3,d3
	Lea	Player_Boxes,a6
	Movem.w	(a6,d3),d3-d6
	Add.w	d0,d3	
	Add.w	d2,d4	
	Add.w	d0,d5	
	Add.w	d2,d6
	Movem.w	d3-d6,Wep_Box(a0)
	Move.l	a0,(a1)+
.Dec	Lea	Wep_End(a0),a0
	Dbra	d7,.Back
.Exit	Move.l	Home_Dirp(a4),a6
	St	(a6)
	St	4(a6)
	St	(a1)
	St	4(a1)
	Rts

.Animate_Weapon
	Move.b	Wep_sprite(a0),d0	; Weapon number.
	Asl.w	#2,d0
	Move.l	(a2,d0),a6		; Pointer into table
	Move.b	Wep_Anim(a0),d1		; Current anim
	Move.b	Wep_Delay(a0),d2	; Anim delay!
	Addq.l	#1,a6
	Subq.b	#1,d2			; 1 to anim delay
	Bcc.s	.No_Anim_Add
	Move.b	-1(a6),d2
	Addq.b	#1,d1			; Add 1 to current anim
	Cmp.b	#-1,(a6,d1)	
	Bne.s	.No_Anim_Add
	Moveq	#0,d1			; If sprite -ive, Clear anim number
.No_Anim_Add
	Move.b	d2,Wep_Delay(a0)	; Save delay
	Move.b	d1,Wep_Anim(a0)		; Save frame number
	Move.b	(a6,d1),Wep_Sprite_Num(a0)
	Rts


.Move_At_An_Angle
	Movem.w	Wep_X(a0),d0/d2-d3/d5	; Collect x/y Sine val/Scale!
	And.w	#$ff,d3
	Add.w	d3,d3
	Move.w	(a5,d3),d4		; X vector
	Add.w	#$80,d3
	Move.w	(a5,d3),d3		; y Vector
	Muls	d5,d4
	Neg.w	d5
	Muls	d5,d3
	Swap	d0
	Swap	d2
	Move.w	Wep_FractionX(a0),d0
	Move.w	Wep_FractionY(a0),d2
	Add.l	d4,d0
	Add.l	d3,d2
	Move.w	d0,Wep_FractionX(a0)
	Move.w	d2,Wep_FractionY(a0)
	Swap	d0
	Swap	d2
	Bsr.s	.Check_Weapon_Bound
	Rts

.Check_Weapon_Bound
	Sub.w	X_Offset_Into_Map(a4),d0
	Cmp.w	#-16,d0
	Blt.s	.Out_Of_Bounds
	Cmp.w	#Playfield_Width,d0
	Bge.s	.Out_Of_Bounds
	Cmp.w	#-16,d2
	Blt.s	.Out_Of_Bounds
;	Cmp.w	#Screen_Height,d2
	Cmp.w	Height_Of_Screen(a4),d2
	Bge.s	.Out_Of_Bounds
	Add.w	X_Offset_Into_Map(a4),d0
	Moveq	#0,d6
	Rts
.Out_Of_Bounds
	Moveq	#-1,d6
	Rts

**********************************************************

Vbl_Copypal
	Tst.b	Copy_The_Pallete(a4)
	Bne.s	Copypal
	Rts
Copypal	Clr.b	Copy_The_Pallete(a4)
	Lea	Destpal,a0
	Lea	Clut+Hardware,a1
	Moveq	#(256/2)-1,d0
.Loop	Move.l	(a0)+,(a1)+
	Dbra	d0,.Loop
	Rts
	
**********************************************************
;a0 Source numbers
;a1 Dest numbers
;d7 Number of numbers to convert

BCD_Ascii
	Subq.w	#1,d7
	Move.b	#"0",d4			
	Moveq	#4,d6
.Loop	Move.b	(a0)+,d0		
	Moveq	#$f,d1
	And.w	d0,d1			
	Lsr.b	d6,d0
	Add.b	d4,d0
	Add.b	d4,d1			
	Move.b	d0,(a1)+
	Move.b	d1,(a1)+
	Dbra	d7,.Loop		; Store & Loop
	Rts
	
**********************************************************
Display_Scores
	Move.l	Player_Sprite_Base(a4),a3
	Lea	Pre_Generated_Player_Objects,a6

	Lea	Pl1+Score,a0
	Move.w	#Scoreboard_Left,d0	; Player 1 BCD score pointer and X position
	Bsr.s	.Print
	Lea	High_Score_Table+3,a0
	Move.w	#Scoreboard_Mid,d0	; Hi-Score BCD score pointer and X position
	Bsr.s	.Print
	Lea	Pl2+Score,a0		; Player 1 BCD score pointer and X position
	Move.w	#Scoreboard_Right,d0

.Print	Move.w	d0,Text_X_Save(a4)	; Save x position
	Subq.l	#8,sp
	Move.l	sp,a1			; Make room on stack. and set a1 as destination for ascii
	Moveq	#4,d7			; 8 characters out please
	Bsr	BCD_Ascii		; Convert BCD to ascii
	Move.l	sp,a2			; Base
	Move.w	#8,-(sp)		; Count of 8 characters
	Sf	Leading_Zero(a4)
	Move.l	Current_List_Pointer(a4),a0
.Loop	
	Move.w	Text_X_Save(a4),d0	
	Add.w	#10,Text_X_Save(a4)	; Get x position
	Move.w	#Score_BoardY+13,d1
	Moveq	#0,d2
	Move.b	(a2)+,d2
	Sub.b	#"0",d2
	Bne.s	.No_Zero	
	Tst.b	Leading_Zero(a4)
	Beq.s	.Dec
.No_Zero	
	St	Leading_Zero(a4)
	Add.w	#112,d2			; Convert the ASCII into sprite number
	Bsr	Quick_Player_Blit
.Dec	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Tst.b	Leading_Zero(a4)
	Bne.s	.Printed_Something
	Move.w	Text_X_Save(a4),d0	
	Sub.w	#12,d0
	Move.w	#Score_BoardY+12,d1
	Move.w	#112,d2			; Convert the ASCII into sprite number
	Move.l	Player_Sprite_Base(a4),a3
	Bsr	Quick_Player_Blit
.Printed_Something
	Addq.l	#8,sp
	Move.l	a0,Current_List_Pointer(a4)
	Rts

**********************************************************
Display_Bombs_And_Lives
	Sf	Killed_Branch(a4)
	Lea	Pre_Generated_Player_Objects,a6
	Subq.b	#1,Display_Game_Over_Or_Start_Delay(a4)
	Bgt.s	.Switched
	Move.b	#50,Display_Game_Over_Or_Start_Delay(a4)
	Tst.b	Num_Credits(a4)
	Beq.s	.No_Switch
	Eor.b	#1,Display_Game_Over_Or_Start(a4)
	Bra.s	.Switched
.No_Switch
	Move.b	#1,Display_Game_Over_Or_Start(a4)
.Switched
	Lea	Pl1,a3
	Move.w	#Scoreboard_Left,d0
	Moveq	#0,d1			; Use type 1 player icons (red)
	Bsr.s	.Do
	Move.w	#Scoreboard_Right,d0
	Lea	Pl2,a3
	Moveq	#1,d1			; Use type 2 player icons (Blue)
	Bsr.s	.Do
	Rts
.Do	
; First display lives
	Move.l	Current_List_Pointer(a4),a0
	Move.l	a3,Player_Use(a4)		; Save player base pointer
	Move.b	d1,Player_Icon_Print(a4)	; 0=Player 1 1=Player 1
	Move.w	d0,-(sp)			; Save initial X position
	Move.w	d0,Base_Icon_X(a4)		; Save x position for loop
	Moveq	#0,d0
	Move.b	Num_Lives(a3),d0
	Bne.s	.Continue_Printing_Lives
	Tst.b	Game_Over_Delay(a4)
	Bne.s	.Display_Start
	Tst.b	Display_Game_Over_Or_Start(a4)
	Bne.s	.Display_Start
	Move.w	Base_Icon_X(a4),d0
	Move.w	#Score_BoardY+22,d1		; Y positiion
	Move.w	#122,d2				; PUSH 1-UP TO START!
	Cmp.l	#Pl1,Player_Use(a4)
	Beq.s	.Display_1up
	Move.w	#166,d2
.Display_1up
	Move.l	Player_Sprite_Base(a4),a3
	Bsr	Quick_Player_Blit
	Addq.l	#2,sp
	Move.l	a0,Current_List_Pointer(a4)
	Bra	.No_Bombs
.Display_Start
	Move.w	Base_Icon_X(a4),d0
	Addq.w	#2,d0
	Move.w	#Score_BoardY+22,d1		; Y positiion
	Move.w	#123,d2				; GAMEOVER!
	Move.l	Player_Sprite_Base(a4),a3
	Bsr	Quick_Player_Blit
	Addq.l	#2,sp
	Bra	.No_Bombs
.Continue_Printing_Lives
	Move.w	d0,-(sp)			; Number of lives for count
	Move.l	Player_Sprite_Base(a4),a3
.Lives_Loop
	Move.w	Base_Icon_X(a4),d0
	Add.w	#12,Base_Icon_X(a4)		; Base x and add 
	Move.w	#Score_BoardY+22,d1		; Y positiion
	Move.w	#56,d2				; This sprite num for player1
	Tst.b	Player_Icon_Print(a4)
	Beq.s	.Print_player1_Icons
	Move.w	#147,d2				; If flag set for player2 , change sprite num
.Print_player1_Icons
	Bsr	Quick_Player_Blit
	Subq.w	#1,(sp)
	Bne.s	.Lives_Loop			; Until all lives ave been printed
	Addq.l	#2,sp
; Now display bombs
.Display_Bombs
;	Move.w	#Screen_Height-4,d1
	Move.l	Player_Sprite_Base(a4),a1
	Lea	55*16(a1),a1			; Bomb sprite nunmber
	Sub.w	Spr_Sheight(a1),d1		; From bottom of screen (-4 pixels
	Move.w	d1,Bomb_Y_Position(a4)		; Y position for bomb icons
	Move.w	(sp)+,Base_Icon_x(a4)		; Set sprite x
	Move.l	Player_Use(a4),a3
	Moveq	#0,d0
	Move.l	a0,Current_List_Pointer(a4)
	Move.b	Num_Bombs(a3),d0
	Beq.s	.No_Bombs
	Tst.b	Killed_Branch(a4)
	Bne.s	.Killed_It
	Push
	St	Killed_Branch(a4)
	Move.w	#36,d0				; Ypos 50 (end of score board)
	Move.w	#%10,d1				; Branch if YPOS(50) > Vertical counter
	Bsr	End_Branch_Object
	Pull

.Killed_It
	Move.l	Current_List_Pointer(a4),a0
	Move.w	d0,-(sp)			; Number of bombs on stack
	Move.l	Player_Sprite_Base(a4),a3
.Bomb_Loop
	Move.w	Base_Icon_x(a4),d0
	Add.w	#16,Base_Icon_x(a4)
	Move.w	Bomb_Y_Position(a4),d1
	Moveq	#55,d2				; Get position on screen+Bomb sprite number
	Move.l	Player_Sprite_Base(a4),a3
	Bsr	Quick_Player_Blit
	Subq.w	#1,(sp)
	Bne.s	.Bomb_Loop
	Addq.l	#2,sp
.No_Bombs
	Move.l	a0,Current_List_Pointer(a4)
	Tst.b	Killed_branch(a4)
	Bne.s	.Skip_Kill	
	St	Killed_Branch(a4)
	Move.w	#36,d0				; Ypos 50 (end of score board)
	Move.w	#%10,d1				; Branch if YPOS(50) > Vertical counter
	Bsr	End_Branch_Object
.Skip_Kill	
	Rts

**********************************************************
Scroll_Lr
	Move.w	X_Offset_Into_Map(a4),d7
	Move.w	d7,Prev_X_Offset_Into_Map(a4)
;	Tst.w	Bomb_Wobble(a4)
;	Beq.s	.No_Wobble
; 	Add.w	Bomb_Wobble(a4),d7
;	Move.w	d7,X_Offset_Into_Map(a4)
;	Bsr	.Scroll_Bound
.No_Wobble
	Lea	Pl1,a0
	Lea	Pl2,a1
	Tst.b	Num_Lives(a0)
	Bne.s	.RedShip_Active
	Move.l	Shipxy(a1),Shipxy(a0)
.RedShip_Active
	Tst.b	Num_Lives(a1)
	Bne.s	.Both_Ships_Active
	Move.l	Shipxy(a0),Shipxy(a1)
.Both_Ships_Active
	Tst.b	Num_Lives(a0)
	Beq.s	.No_2_Player
	Tst.b	Num_Lives(a1)
	Beq.s	.No_2_Player
	Tst.w	X_Speed(a0)
	Beq.s	.No_2_Player
	Smi	d0
	Tst.w	X_Speed(a1)
	Beq.s	.No_2_Player
	Smi	d1
	Cmp.b	d0,d1
	Bne	.Opposite_Directions	
.No_2_Player
	Tst.w	X_Speed(a0)
	Beq.s	.Check_Blue_Player_Move				; Red player not moving, check the blue player
	Bpl.s	.Red_Moved_Right
	Bsr	.Add_Scroll
	Bne	.Dont_Move_Blue
	Tst.w	X_Speed(a1)
	Bne.s	.Dont_Addx
	Addq.w	#2,ShipXY(a1)
.Dont_Addx
	Cmp.w	#Playfield_Width-44,ShipXY(a1)
	Blt.s	.Dont_Move_Blue
	Move.w	#Playfield_Width-44,ShipXY(a1)
	Bsr	.Sub_Scroll
	Bra.s	.Dont_Move_Blue
.Red_Moved_Right
	Bsr	.Sub_Scroll
	Bne.s	.Dont_Move_Blue
	Tst.w	X_Speed(a1)
	Bne.s	.Dont_Addx2
	Subq.w	#2,ShipXY(a1)
.Dont_Addx2
	Cmp.w	#12,ShipXY(a1)
	Bgt.s	.Dont_Move_Blue
	Move.w	#12,ShipXY(a1)
	Bsr	.Add_Scroll
	Bra.s	.Dont_Move_Blue

.Check_Blue_Player_Move
	Move.w	X_Speed(a1),d5
	Tst.w	X_Speed(a1)
	Beq.s	.Move_Done				; Red player not moving, check the blue player
	Bpl.s	.Blue_Moved_Right
	Bsr.s	.Add_Scroll
	Bne.s	.Dont_Move_Blue
	Tst.w	X_Speed(a0)
	Bne.s	.Dont_Addx3
	Addq.w	#2,ShipXY(a0)
.Dont_Addx3
	Cmp.w	#Playfield_Width-44,ShipXY(a0)
	Blt.s	.Dont_Move_Blue
	Move.w	#Playfield_Width-44,ShipXY(a0)
	Bsr	.Sub_Scroll
	Bra.s	.Dont_Move_Blue
.Blue_Moved_Right
	Bsr.s	.Sub_Scroll
	Bne.s	.Dont_Move_Blue
	Tst.w	X_Speed(a0)
	Bne.s	.Dont_Addx4
	Subq.w	#2,ShipXY(a0)
.Dont_Addx4
	Cmp.w	#12,ShipXY(a0)
	Bgt.s	.Dont_Move_Blue
	Move.w	#12,ShipXY(a0)
	Bsr	.Add_Scroll

.Move_Done
.Dont_Move_Blue
.Opposite_Directions	
	Move.w	X_Offset_Into_Map(a4),d1
	Sub.w	d1,Prev_X_Offset_Into_Map(a4)
	Add.w	#Playfield_Width,d1
	Move.w	d1,Right_Hand_Screenxbound(a4)
	Rts	

.Add_Scroll
	Subq.w	#4,X_Offset_Into_Map(a4)		
.Sub_Scroll
	Addq.w	#2,X_Offset_Into_Map(a4)		
.Scroll_Bound
	Moveq	#0,d6
	Move.w	X_Offset_Into_Map(a4),d7
	Cmp.w	Map_X_Left_Bound(a4),d7	
	Bge.s	.Map_Not_Left
	St	d6
	Move.w	Map_X_Left_Bound(a4),d7	
.Map_Not_Left
	Cmp.w	Map_X_Right_Bound(a4),d7	
	Ble.s	.Map_Not_Right
	St	d6
	Move.w	Map_X_Right_Bound(a4),d7	
.Map_Not_Right
	Move.w	d7,X_Offset_Into_Map(a4)
	Tst.b	d6
	Rts

**********************************************************
Scroll_Down_Maps
	Tst.w	Num_Guardians_Active(a4)
	Beq.s	.No_Set
	Tst.w	Guardian_Delay(a4)
	Beq.s	.No_Set
	Subq.w	#1,Guardian_Delay(a4)
	Bne.s	.No_Set
	Tst.w	Continue_Delay(a4)
	Bne.s	.No_Set
	Tst.b	Game_Over_Delay(a4)
	Bne.s	.No_Set
	Push
	Jsr	Fadedown
	Move.b	#-30,Guardian_Music_On(a4)
	Pull
	Bsr	Kill_Hover
.No_Set	Tst.b	Flag_To_Stop_Scrolling(a4)
	Sne	No_More_Scrolling(a4)		
	Tst.b	No_More_Scrolling(a4)		
	Bne.s	.Exit3
	Addq.b	#1,Make_Event_Delay(a4)
	And.b	#$f,Make_Event_Delay(a4)
	Bne.s	.No_Ev
	St	Make_Event(a4)
	Addq.l	#4,Event_Tablep(a4)		
.No_EV	Clr.b	Base_Map_Add_Flag(a4)
	Lea	Map_Info(a4),a0
	Move.w	#2,-(sp)
	Cmp.w	#2,Num_Maps_Loaded(a4)
	Ble.s	.Loop
	Subq.w	#1,(sp)
.Loop	Subq.w	#1,(sp)
	Bmi.s	.Exit
	Addq.w	#1,Map_Y_Offset(a0)
	And.w	#$f,Map_Y_Offset(a0)
	Bne.s	.No_Up
	Tst.b	Base_Map_Add_Flag(a4)
	Bne.s	.No_Base_Add
	St	Base_Map_Add_Flag(a4)
	Addq.w	#1,Level_Map_Height(a4)
.No_Base_Add
	Sub.l	#60,Map_Pointer(a0)
	Move.l	a0,-(sp)
	Bsr	Re_Stack_Maplines
	Move.l	(sp)+,a0
.No_Up	Lea	Map_Structure_End(a0),a0
	Bra.s	.Loop
.Exit	Addq.l	#2,sp
	Rts

.Exit3	Tst.b	End_Level(a4)
	Bne.s	.Transforming
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
.Do	Cmp.b	#2,Transforming_Ship(a3)
	Beq.s	.Transforming
	Tst.b	Hover_Mode(a3)
	Bne.s	.Transforming
	Tst.b	Dead_Count(a3)
	Bne.s	.Transforming
	Move.b	#2,Transforming_Ship(a3)
	Clr.b	Hover_Direction(a3)
.Transforming
	Rts

Re_Stack_Maplines
	Move.l	Map_Line_Stack_Pointer(a0),a0
	Lea	19*2(a0),a0
	Move.l	a0,a1
	Move.w	-(a0),-(sp)
	Moveq	#19-2,d0
.Loop	Move.w	-(a0),-(a1)
	Dbra	d0,.Loop
	Move.w	(sp)+,-(a1)
	Rts

**********************************************************
Build_Map
	Lea	Map_Info(a4),a5
	Move.w	#2,-(sp)
.Loop0	Subq.w	#1,(sp)
	Bmi	.Exit	
	Cmp.w	#1,(sp)
	Beq.s	.Build_Base_Map
	Cmp.w	#2,Num_Maps_Loaded(a4)
	Bgt	.Exit
.Build_Base_Map
	Pea	Map_Structure_End(a5)
	Move.w	Map_Y_Offset(a5),d4
	Eor.w	#$f,d4
	Lsl.w	#4,d4
	Move.l	GfxBlocks_Base(a4),a1
	Lea	(a1,d4),a1
	Move.l	Map_Line_Stack_Pointer(a5),a2
	Move.w	(a2),d0
	Mulu	#Byteswide*16,d0
	Move.l	Map_Pointer(a5),a0
	Move.l	Base_Map_Element(a5),a5
	Add.l	d0,a5	
	Lsr.w	#4,d4
	Mulu	#Byteswide,d4
	Lea	(a5,d4),a5
	Move.w	#(Byteswide/16)-1,d7
	Moveq	#8,d5
	Moveq	#16,d4
.Loop	Moveq	#0,d6
	Move.w	(a0)+,d6
	Ror.w	d5,d6
	Lsl.l	d5,d6
	Lea	(a1,d6.l),a2
	Move.l	(a2)+,(a5)+
	Move.l	(a2)+,(a5)+
	Move.l	(a2)+,(a5)+
	Move.l	(a2)+,(a5)+
	Dbra	d7,.Loop
	Move.l	(sp)+,a5
	Bra	.Loop0
.Exit	Addq.l	#2,sp
Build_PLX
	Lea	Data,a4
	Lea	Hardware,a5
	Cmp.w	#2,Num_Maps_Loaded(a4)
	Ble	.No_Paralax	
	MOveq	#0,d2
	Move.b	Paralax_Scroll_PXL(a4),d2
	Eor.w	#1,d2
	Addq.w	#1,d2
	Move.w	d2,-(sp)
.Plx_Loop
	Tst.b	Paralax_Active(a4)
	Beq	.Skipo
	Move.w	Paralax_Map_Number(a4),d0
	Addq.w	#1,d0
	Mulu	#Map_Structure_End,d0
	Lea	Map_Info(a4),a5
	Add.l	d0,a5
	Pea	(a5)
	Move.w	Map_Y_Offset(a5),d4
	Addq.w	#1,d4
	Btst	#4,d4
	Sne	d7
	Beq.s	.No_Six
	And.w	#$f,d4
	Eor.w	#$f,d4
.No_Six	Eor.w	#$f,d4
	Lsl.w	#4,d4
	Move.l	GfxBlocks_Base(a4),a1
	Lea	(a1,d4),a1
	Move.l	Map_Line_Stack_Pointer(a5),a2
	Move.w	(a2),d0
	Tst.b	d7
	Beq.s	.Skip1
;	Move.w	14*2(a2),d0
;	Tst.b	Ntsc_Flag(a4)
;	Bne.s	.Skip1
	Move.w	17*2(a2),d0
.Skip1
	Mulu	#Byteswide*16,d0
	Move.l	Map_Pointer(a5),a0
	Tst.b	d7
	Beq.s	.Skip2
	Cmp.w	#1,Map_Height(a5)
	Beq.s	.Fuck_Off
	Lea	-60(a0),a0
.Skip2	Move.l	Base_Map_Element(a5),a5
	Add.l	d0,a5	
	Lsr.w	#4,d4
	Tst.b	d7
	Beq.s	.Norm
	Eor.w	#$f,d4
.Norm	Mulu	#Byteswide,d4
	Lea	(a5,d4),a5
	Move.w	#(Byteswide/16)-1,d7
	Moveq	#8,d5
	Moveq	#16,d4
.Loop	Moveq	#0,d6
	Move.w	(a0)+,d6
	Ror.w	d5,d6
	Lsl.l	d5,d6
	Lea	(a1,d6.l),a2
	Move.l	(a2)+,(a5)+
	Move.l	(a2)+,(a5)+
	Move.l	(a2)+,(a5)+
	Move.l	(a2)+,(a5)+
	Dbra	d7,.Loop
.Fuck_Off
	Move.l	(sp)+,a0
	Addq.w	#1,Map_Y_Offset(a0)
	And.w	#$f,Map_Y_Offset(a0)
	Bne.s	.Skipo
	St	Paralax_Event_Flag(a4)
	Sub.l	#60,Map_Pointer(a0)
	Move.l	a0,-(sp)
	Bsr	Re_Stack_Maplines
	Move.l	(sp)+,a0
	Subq.w	#1,Map_Height(a0)
	Bne.s	.Skipo
	Sf	Paralax_Active(a4)
	Move.w	Paralax_Map_Number(a4),d0
	Cmp.w	#1,d0
	Beq.s	.Skipo
	Addq.w	#1,d0
	Mulu	#Map_Structure_End,d0
	Lea	Map_Info(a4),a5
	Add.l	d0,a5
	Lea	Map_Structure_End(a5),a6
	Move.l	Base_Map_Element(a5),Base_Map_Element(a6)
	Move.l	Map_Line_Stack_Pointer(a5),Map_Line_Stack_Pointer(a6)
	Addq.w	#1,Paralax_Map_Number(a4)	
	Bra.s	.NoPXSc
.Skipo	Subq.w	#1,(sp)
	Bne	.PLX_Loop
.NoPXSc	Addq.l	#2,sp
.No_Paralax	
	Rts

**********************************************************
Setup_Mainloop_Vars
	Pea	Alien_Table(a4)
	Move.l	(sp)+,Alien_List_Search_Pointer(a4)
	Move.w	#Max_Aliens,Alien_search_Count(a4)
	Lea	Track_Shipxy(a4),a2
	Lea	Pl1,a0	
	Lea	Pl2,a1
	Tst.b	Player_Active(a0)
	Beq.s	.Player_1_Not_Active
	Tst.b	Player_Active(a1)
	Bne.s	.Player_1n2_Active
	Move.l	Shipxy(a0),(a2)+
	Move.l	Shipxy(a0),(a2)+
	Bra.s	.Do_Tracking
.Player_1n2_Active
	Move.l	Shipxy(a0),(a2)+
	Move.l	Shipxy(a1),(a2)+
	Bra.s	.Do_Tracking
.Player_1_Not_Active
	Tst.b	Player_Active(a1)
	Beq.s	.Do_Tracking
	Move.l	Shipxy(a1),(a2)+
	Move.l	Shipxy(a1),(a2)+
.Do_Tracking
	Lea	Track_Shipxy(a4),a1
	Move.w	X_Offset_Into_Map(a4),d0	; Add base of screeb x
	Add.w	#16,d0
	Add.w	d0,(a1)+
	Addq.l	#2,a1
	Add.w	d0,(a1)+
	Addq.l	#2,a1


	Addq.b	#1,Paralax_Scroll_PXL(a4)
	And.b	#1,Paralax_Scroll_PXL(a4)
	Pea	Score_Bonus_Table(a4)
	Move.l	(sp)+,Score_Bonus_Tablep(a4)
	Pea	Aln_ActiveList(a4)
	Move.l	(sp)+,Aln_ActiveList_Pointer(a4)
	Clr.w	Number_Of_Sprites_In_Activelist(a4)		; No sprites to draw
	Pea	Power_Up_Pos(a4)
	Move.l	(sp)+,Power_Up_Posp(a4)	; Setup pointer to power up table
	Pea	Aliens_Insert_T(a4)
	Move.l	(sp)+,Aliens_Insert_P(a4)	; Setup pointer for alien insert
	Clr.b	Pause_Display_Flip(a4)
	Not.b	Bomb_Flip(a4)
	Not.b	Flip_Flag(a4)
	Subq.b	#1,Track_Del(a4)
	Bpl.s	.Pos_Track_Del1
	Move.b	#Track_Amount,Track_Del(a4)
.Pos_Track_Del1
	Move.l	Object_List_Pointer(a4),Current_List_Pointer(a4)
	Clr.w	Num_Objects_To_Display(a4)
	Move.l	Special_Object_Bufferp(a4),Special_Object_Pointer(a4)
.Dont_Modify
	Pea	Explosion_Tab(a4)
	Move.l	(sp)+,Explosion_Tabp(a4)
	Pea	Crator_Tab(a4)
	Move.l	(sp)+,Crator_Tabp(a4)
	Rts

**********************************************************
Wait_For_Vblank_And_Swapscreens
	Lea	Data,a4
	Cmp.b	#Frame_Rate-1,Vbl_Flag(a4)
	Blt.s	Wait_For_Vblank_And_Swapscreens

Swapscreens
	Lea	Data,a4
	Move.b	Frame_Rate_To_Wait(a4),d0
	Sub.b	Vbl_Flag(a4),d0
	Bpl.s	.Pos
	Neg.b	d0
	Bra.s	.SKip
.Pos	Clr.b	d0
.Skip	Move.b	d0,Frame_Diff(a4)
	St	List_Made(a4)
	Rts
	

***********************************************************
Vbl_Swap	
	Move.l	Current_List_Pointer(a4),a0
	Jsr	Insert_Stop_Object
	Movem.l	Object_List_Pointer(a4),d0-d1
	Exg	d0,d1
	Movem.l	d0-d1,Object_List_Pointer(a4)
	Move.l	Num_Objects_To_Display(a4),d3
	Swap	d3
	Move.l	d3,Num_Objects_To_Display(a4)
	Rts

***********************************************************
Search_Zero
	Tst.b	(a0)+
	Bne.s	Search_Zero
	Rts

***********************************************************
Load_In_Player_Sprites
	Move.l	#Player_Sprites,d0
	And.l	#-8,d0
	Move.l	d0,Player_Sprite_Base(a4)
	Move.l	d0,-(sp)
	Lea	Player_Header_NAME,a0
	Move.l	Player_Sprite_Base(a4),a1
	Trap	#15
	Move.l	a1,Player_Sprite_Base(a4)
	Move.l	(sp)+,a1
	Add.l	d0,a1
	Lea	Player_SPRITES_Name,a0
	Move.l	a1,Player_Gfx_Base(a4)
	Trap	#15
	Add.l	d0,a1
	Lea	BULLETS_HEADER,a0
	Move.l	a1,Bullets_Header_Base(a4)
	Trap	#15
	Add.l	d0,a1
	Move.l	a1,Bullets_GFX_Base(a4)
	Lea	BULLETS_GFX,a0
	Trap	#15
	Jsr	Darken_Player_Fire_Sprites

	Move.w	#123<<4,d0
	Move.l	Player_Sprite_Base(a4),a0
	Lea	(a0,d0),a0
	Move.l	(a0),a0
	Add.l	Player_Gfx_Base(a4),a0

	MOve.w	#16,-(sp)
.Loop0	Moveq	#1,d0
.Loop1	Move.w	d0,d1
	Mulu	#255,d1
	Divu	#196,d1
	Move.b	#$66,(a0)+
	Move.b	d1,(a0)+
	Addq.w	#1,d0
	Cmp.w	#197,d0
	Bne.s	.Loop1
	Subq.w	#1,(sp)
	Bne.s	.Loop0
	Addq.l	#2,sp
	Rts

***********************************************************
Sixteen_Bit_Sprites_To_Four_Bit
	Tst.w	(a0)
	Bmi	.Done_List
	Moveq	#0,d0
	Moveq	#0,d1
	Move.w	(a0)+,d0		; Source sprite
	Move.w	(a0)+,d1		; Destination sprite
	Pea	(a0)			; Save address of pointer
	Lsl.w	#4,d0
	Lsl.w	#4,d1			; Source *16, Dest * 16
	Lea	(a1,d1),a0		; Get address of sprite header
	Move.l	(a0),a6			; Get sprite graphic data offset
	Add.l	a2,a6			; This added to the gfx base gives us were we want to write out
	Move.l	Bullets_Header_Base(a4),a5 ; Source header
	Add.l	d0,a5			; Get address of sprite header
	Move.l	Bullets_GFX_Base(a4),a3 ; Base address of graphic data
	Move.l	(a5),d1			; Offset into graphic data
	Add.l	d1,a3			; Base graphic data added
	Move.w	Spr_Pixel_Width(a5),d0	; Get pixel width ( of source)
	Move.w	Spr_Sheight(a5),d1	; Get height
	Mulu	d0,d1			; Get total size ( in bytes)
	Lsr.w	#1,d1			; /2 since 4 bits per pixel
	Subq.w	#1,d1			; For dbra
.Loop	Move.b	(a3)+,(a6)+		; Copy the source graphic to destination
	Dbra	d1,.Loop
	Cmp.l	(a5)+,(a0)+		; Neat way of adding 4 to 2 address registers
	Move.l	(a5)+,(a0)+	
	Move.l	(a5)+,(a0)+		; Move in 12 bytes of header info !
	Move.l	(a5)+,(a0)+
	Move.l	(sp)+,a0
	Bra	Sixteen_Bit_Sprites_To_Four_Bit
.Done_List
	Rts

***********************************************************
Load_In_Level_Info
	Clr.l	File_Len(a4)
	Lea	Continue_Mod_Name,a0
	Trap	#15
	Move.l	a1,Continue_Mod_Address(a4)
	Lea	Guardian_Mod_Name,a0
	Trap	#15
	Move.l	a1,Guardian_Mod_Address(a4)
	Lea	Rom_File_list,a0
	Moveq	#0,d0
	Move.b	This_Level(a4),d0
	Subq.b	#1,d0
	Lsl.w	#2,d0
	Lea	Map_Bound_List(pc),a6
	Move.l	(a6,d0),Map_X_Left_Bound(a4)
	Sub.w	#Playfield_Width,Map_X_Right_Bound(a4)
	Move.l	(a0,d0),a0
	Lea	Mypal-2,a1
	Trap	#15
	Tst.l	d0
	Bne.s	.Compressed_Palette
	Push
	Move.l	a1,a0
	Lea	Mypal-2,a1
	Move.l	#257*2,d0
	Bsr	Copy_Bytes
	Pull
.Compressed_Palette
	Clr.w	Mypal
	Push
	Cmp.b	#1,This_Level(a4)
	Bne.s	.No_Copy_Bodge
	Move.w	#$487c,Mypal+(198*2)
	Move.w	#$487c,Mypal+(197*2)
.No_Copy_Bodge
	Lea	Mypal+(240*2),a1
	Lea	Damage_Hit_Shadow_Pal,a0
	Moveq	#16*2,d0
	Bsr	Copy_Bytes
	Lea	Panel_Palette,a0
	Lea	Mypal+(224*2),a1
	Moveq	#16*2,d0
	Bsr	Copy_Bytes
	Cmp.b	#1,This_Level(a4)
	Bne.s	.Cows_Not_White
	Lea	Mypal+(248*2),a1
	Move.l	#$77ff77ff,(a1)+
	Move.l	#$77ff77ff,(a1)+
	Move.l	#$77ff77ff,(a1)+
	Move.l	#$77ff77ff,(a1)+
.Cows_Not_White
	Pull
	Bsr	Search_Zero	
	Ifne	Load_Event			; Assemble if your not sourcing your events
	Lea	Stuff_To_Load,a1
	Trap	#15
	Move.l	d0,File_Len(a4)			; Save length of file
	Move.w	(a1),d0				; Get relative branch offset
	And.w	#$ff,d0				; Mask (get offset)
	Lea	6(a1,d0),a2			; Branch instruction+Offset
	Subq.l	#4,a2
	Move.l	a2,Event_Base(a4)
	Move.l	a2,Event_Tablep(a4)		; Setup base event and pointer
	Trap	#12				; Relocate file
	Else
	Clr.l	File_Len(a4)			; No file loaded into area
	Move.l	#Event_Table,Event_Base(a4)
	Move.l	#Event_Table,Event_Tablep(a4)
	Endc

	Bsr	Search_Zero	
	Lea	Stuff_To_Load,a1		; Base pointer to load area
	Addq.l	#8,File_Len(a4)
	Add.l	File_Len(a4),a1			; Next bit of load data
	Move.l	a1,d0
	And.l	#-8,d0
	Move.l	d0,a1
	Trap	#15
	Move.l	a1,Gfxblocks_Base(a4)		; Load in blockset
	Add.l	d0,File_Len(a4)

	Bsr	Search_Zero	
	Lea	Stuff_To_Load,a1		; Base pointer to load area
	Move.l	File_Len(a4),d0
	Add.l	a1,d0
	And.l	#-8,d0
	Move.l	d0,a1
	Trap	#15
	Move.l	a1,Enemy_Sprites_Base(a4)	; Base pointer for sprites
	Add.l	d0,File_Len(a4)

	Bsr	Search_Zero	
	Lea	Stuff_To_Load,a1		; Base pointer to load area
	Move.l	File_Len(a4),d0
	Add.l	a1,d0
	And.l	#-8,d0
	Move.l	d0,a1
	Trap	#15
	Move.l	a1,Enemy_GFX_Base(a4)	; Base pointer for sprites
	Add.l	d0,File_Len(a4)
	Bsr	Darken_enemy_Fire_Sprites
	Bsr	Patch_Fixed_Explosion_Sprites

	Lea	Stuff_To_Load,a1
	Add.l	File_Len(a4),a1
	Move.l	a1,Base_Mod_Address(a4)
	Bsr	Search_Zero
	Trap	#15
	Add.l	#16,d0	
	Add.l	d0,File_Len(a4)
	Lea	Stuff_To_Load,a1
	Add.l	File_Len(a4),a1

	Lea	Map_Table(a4),a5
	Clr.w	-(sp)
.Map_Load
	Bsr	Search_Zero	
	Tst.b	(a0)
	Bmi.s	.Done
	Addq.w	#1,(sp)
	Trap	#15
	Move.l	a1,(a5)+
	Add.l	d0,a1	
	Add.l	d0,File_Len(a4)
	Bra.s	.Map_Load
.Done	Lea	Stuff_To_Load,a1
	Add.l	File_Len(a4),a1
	Cmp.b	#8,This_Level(a4)
	Bne.s	.Not_Level_8
	Move.l	a1,Wash_Mem_Pointer(a4)
	Bsr	Search_Zero
	Trap	#15
.Not_Level_8
	Move.w	(sp)+,Num_Maps_Loaded(a4)
	Move.l	#Paralax_Event,Paralax_Data_Pointer(a4)
	Clr.w	Paralax_Map_Number(a4)
	St	(a5)
	Ifeq	Load_Event
	Tst.b	.Bill
	Bne.s	.Fuck_Off
	St	.Bill
	Endc
	Bsr	Build_Sprites_To_Anims
	Move.l	#Paralax_Event_Table,Paralax_Event_Pointer(a4)
.Fuck_Off
	Bsr	Initialize_Maps
	Rts

.Bill	Ds.w	1

Map_Bound_List
	Dc.w	48,Byteswide-48
	Dc.w	16,Byteswide-32
	Dc.w	0,Byteswide
	Dc.w	8,Byteswide-8
	Dc.w	0,Byteswide
	Dc.w	0,Byteswide
	Dc.w	48,Byteswide-48
	Dc.w	0,Byteswide

Damage_Hit_Shadow_Pal
	Dc.w	$f0be
	Dc.w	$00a0
	Dc.w	$f0be
	Dc.w	$77ff
	Dc.w	$f0be
	Dc.w	$f7f7,$f3a7,$f05b

	Dc.w	$00ff
	Dc.w	$ffff
	Dc.w	$77ff
	Dc.w	$f0ff
	Dc.w	$0fff
	Dc.w	$80ff
	Dc.w	$40ff
	Dc.w	$3fff

Darken_enemy_Fire_Sprites
	Push
	Move.l	Enemy_Sprites_Base(a4),a0
	Move.l	Enemy_GFX_Base(a4),a1
	Lea	Enemy_Sprites_To_Darken(pc),a2
	Bsr	Darken_List
	Pull
	Rts

Darken_Player_Fire_Sprites
	Push
	Move.l	Player_Sprite_Base(a4),a0
	Move.l	Player_GFX_Base(a4),a1
	Lea	Player_Sprites_To_Darken(pc),a2
	Bsr	Darken_List
	Pull
	Rts

Darken_List
	Move.w	(a2)+,d1
	Bmi.s	.Done
	Lsl.w	#4,d1
	Move.l	Spr_data(a0,d1),a3
	Add.l	a1,a3
	Move.w	Spr_Pixel_Width(a0,d1),d2
	Move.w	Spr_SHeight(a0,d1),d3
	Mulu	d3,d2
	Subq.w	#1,d2
.Loop	Move.w	(a3)+,d3
	Beq.s	.Blank	
	Sub.b	#$30,d3
	Scc	d4
	And.b	d4,d3
	Move.w	d3,-2(a3)
.Blank	Dbra	d2,.Loop
	Bra.s	Darken_List
.Done	Rts

Enemy_Sprites_To_Darken
	Dc.w	64,65,168,169,226,227,228,229,-1
Player_Sprites_To_Darken
	Dc.w	5,6,7,8,9,10,11,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50
	Dc.w	62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,176,177,178,193,194,195,223,224,225,226,227,228,229,230
	Dc.w	231,232,233,234,-1


***********************************************************
Patch_Fixed_Explosion_Sprites
	Push
	Moveq	#0,d0
	Move.w	#119,d1
	Bsr.s	.Patch
	Moveq	#1,d0
	Move.w	#120,d1
	Bsr.s	.Patch
	Pull
	Rts
.Patch	
	Movem.w	d0-d1,-(sp)
	Lea	Explosion_Patch_Header_Name,a0
	Trap	#15
	Move.l	a1,a2
	Lea	Explosion_Patch_Gfx_Name,a0
	Trap	#15
	Move.l	a1,a3
	Movem.w	(sp)+,d0-d1
	Lsl.w	#4,d0
	Lsl.w	#4,d1
	Move.l	(a2,d0),a6
	Add.l	a3,a6
	Move.w	Spr_Pixel_Width(a2,d0),d4
	Move.w	d4,-(sp)
	Move.w	Spr_Sheight(a2,d0),d3
	Move.w	d3,-(sp)
	Add.w	d4,d4
	Mulu	d4,d3
	Subq.w	#1,d3
	Move.l	Enemy_Sprites_Base(a4),a0
	Move.l	Enemy_GFX_Base(a4),a1
	Move.w	Spr_Sheight(a0,d0),-(sp)
	Move.l	(a0,d1),a0
	Add.l	a1,a0
.Loop	Move.b	(a6)+,(a0)+
	Dbra	d3,.Loop
	Movem.w	(sp)+,d0-d2
	Cmp.w	d0,d1
	Beq.s	.Same
	Add.w	d2,d2
	Subq.w	#1,d2
.Loop1	Clr.b	(a0)+
	Dbra	d2,.Loop1
.Same	Rts	

***********************************************************
Initialize_Maps
	Lea	Element_Table,a0
	Bsr	Setup_Elements
	Bsr	Setup_Elements
	Lea	Map_Table(a4),a6
	Lea	Map_Info(a4),a5
	Pea	Element_Table
	Move.l	Base_Of_Map_Elements(a4),-(sp)
	Move.w	#1,d7
	Move.l	(a6),a0
	Move.w	2(a0),Base_Map_Height(a4)			; Base map height
	Clr.w	Level_Map_Height(a4)					; Base map height

.Loop	Tst.l	(a6)
	Bmi.s	.Done
	Move.l	(a6)+,a0
	Movem.w	(a0)+,d0-d3
	Push
	Mulu	d0,d1
	Subq.w	#1,d1
.Ror_Loop
;	Move.w	(a0),d0
;	Ror.w	#8,d0
;	Move.w	d0,(a0)+
	Dbra	d1,.Ror_Loop
	Pull
	Move.w	d1,Map_Height(a5)
	Move.w	d1,Map_Start_Height(a5)
	Move.w	d0,Map_Width(a5)
	Mulu	d0,d1
	Add.l	d1,d1
	Add.l	d1,a0
	Lea	-60(a0),a0
	Move.l	a0,Map_Start_Address(a5)
	Move.l	a0,Map_Pointer(a5)
	Clr.w	Map_Y_Offset(a5)
	Move.l	(sp),Base_Map_Element(a5)
	Move.l	4(sp),Map_Line_Stack_Pointer(a5)
	Tst.w	d7
	Beq.s	.No_Add
	Subq.w	#1,d7
	Add.l	#Byteswide*19*16,(sp)
	Add.l	#19*2,4(sp)
.No_Add
	Lea	Map_Structure_End(a5),a5
	Bra.s	.Loop
.Done	St	(a5)
	Addq.l	#8,sp
	Lea	Data,a4
	Lea	Hardware,a5
	Rts

Setup_Elements
	Moveq	#0,d0
.Loop	Move.w	d0,(a0)+
	Addq.w	#1,d0
	Cmp.w	#19,d0
	Bne.s	.Loop
	Rts


***********************************************************
Build_Sprites_To_Anims
	Lea	Anim_Convert_Table,a5	; Table for Sprites>Anims
	Move.l	Event_Base(a4),a0	; Base pointer for events
.Loop	Tst.l	(a0)			; Test event offset
	Beq.s	.Next			; Zero, no event
	Bgt.s	.Event			; >, Event happens !
	Cmp.l	#-1,(a0)		
	Beq.s	.Done			; If -1, end of event list
	Bra.s	.Next			; Else skip event
.Event	Move.l	(a0),a1			; Get address of sprites
.Make_Loop
	Tst.w	(a1)
	Bmi.s	.Next			; Check for end of sprite block
	Move.w	2(a1),d0		; Get sprite number
	Add.w	d0,d0
	Move.w	(a5,d0),2(a1)		; Anim offset back in
	Lea	12(a1),a1		; Advance to next sprite
	Bra.s	.Make_Loop	
.Next	Addq.l	#4,a0			; Next event
	Bra.s	.Loop
.done	Rts

***********************************************************
Init	Move.w	d0,-(sp)				; Save parameters for number of players
	Lea	Data,a4					; Pointer to game variables
	Bsr	Clear_Out_Data_Variables		; Clear em all !
	Bsr	Clear_Out_Player_Variables		; Clear all player variables
	Clr.b	Play_Through_Script(a4)
	Move.w	#0,Panel_X(a4)
	Move.w	#0,Map_Display_Width(a4)
	Bsr	Setup_Screens				; Setup initial object lists/pointers
	Bsr	Copypal					; Initial Pallete is 0s, Clear colour registers
	Jsr	Options_Menu
	Move.w	(sp)+,d7				; Restore player bits
	Move.w	d0,d7
	Bsr	Initial_Vars				; Setup the initial variables for players
	Bsr	Load_In_Player_Sprites			; Download sprite headers/graphics for all player related stuff
	Bsr	Pre_Generate_Some_Player_Objects	; Generate FAST header sprites for player graphics
	Bsr	Generate_Player_Collision_Boxes		; Make collision boxes based on width and height of sprites
	Clr.b	Demo_Mode(a4)
	Clr.b	Times_Through(a4)
Re_Initialize						; Come back here when new level is to be loaded
	Lea	Gameover_Mod_Name,a0
	Trap	#15
	Move.l	a1,Gameover_Modaddress(a4)
	Sf	End_Level(a4)
	Clr.l	Rel_Base(a4)
	Ifne	Record
	Lea	Player_1_Script,a0
	Lea	Player_2_Script,a1
	Movem.l	a0-a1,Player_Script_Pointer(a4)
	Move.l	#$00010000,(a0)
	Move.l	#$00010000,(a1)
	Else
	Lea	Player_1_Script,a0
	Lea	Player_2_Script,a1
	Movem.l	a0-a1,Player_Script_Pointer(a4)
	Endc
	Tst.b	Demo_Mode(a4)
	Bne.s	.Demo_Mode
	Jsr	Stop_Mod
	
.Demo_Mode
	Jsr	Check_For_Carrier_Sequence
	Cmp.b	#1,This_Level(a4)
	Beq.s	.On
	Cmp.b	#6,This_Level(a4)
	Beq.s	.On
	Bra.s	.Off
.On	Jsr	Atari_Logo_On	
.Off	Bsr	Load_In_Level_Info			; Load in the current level data
	Jsr	Stop_Gpu
	Lea	SORTER_S,a0
	Move.l	#$100,d0
	Jsr	Load_Gpu_Prog
	Bsr	Setup_Color_Stuff			; No fade, set flash to intesity 128
	Bsr	Make_Alien_Boxes			; Make colision boxes for alien data
	Bsr	Pre_Generate_Some_Objects		; Generate FAST headers for alien sprites
	Bsr	Generate_Level				; Blast a full screen of level graphic data before ya fade up
	Bsr	Setup_Game_Loop_Vars			; Need to setup stuff for main loop
	Jsr	Atari_Logo_Off	
	Bsr	Initialize_Palette			; Intensity=256 if started on level 1/5 (carrier!)
	Bsr	Setup_INTS				; Setup JAG interupts (VBL, etc!)
	Bsr	Startup_Raiden_Mod
	Rts


**********************************************************
Startup_Raiden_Mod
	Tst.b	Play_Through_Script(a4)
	Bne.s	.No_Game
	Move.l	Base_Mod_Address(a4),a0
	Push
	Jsr	Stop_Mod
	Jsr	pt_mod_init		;setup song and player
	Jsr	nofade
	Jsr	start_mod		;its this what makes things go
	Jsr	enable_fx
	Pull
.No_Game
	rts

**********************************************************
Generate_Pre_Sines
	Lea	Pre_Sines,a1
	Moveq	#0,d7
.Loop	Lea	Alien_Sine,a0
	Move.w	#256-1,d6
.Loop1	MOve.w	(a0)+,d5
	Muls	d7,d5
	Add.l	d5,d5
	Move.l	d5,(a1)+
	Dbra	d6,.Loop1
	Addq.w	#1,d7
	Cmp.w	#16,d7
	Bne.s	.Loop
	Rts

**********************************************************
Clear_Out_Data_Variables
	Lea	Var_Clear_Start(a4),a0
	Move.l	#Varend-Var_Clear_Start,d0
	Bra	Clear_Bytes

**********************************************************
Clear_Out_Player_Variables
	Lea	Pl1,a0
	Move.l	#PVarend,d0
	Bsr	Clear_Bytes
	Lea	Pl2,a0
	Move.l	#PVarend,d0
	Bra	Clear_Bytes

**********************************************************
Initialize_Palette
	Tst.b	Play_Through_Script(a4)
	Bne.s	.Initial_Pal
	Cmp.b	#Level,This_Level(a4)
	Bne.s	.No_Init_Pallete
.Initial_Pal
	Move.w	#256,Master_Intens(a4)
	Bsr	Fade_Pallete
.No_Init_Pallete
	Rts

**********************************************************
Fade_Up_Or_Down_Palette
	Tst.b	Fade_Direction(a4)
	Beq.s	.Done
	Bmi.s	.Fade_Down
.Fade_Up
	Addq.w	#8,Master_Intens(a4)
	Cmp.w	#256,Master_Intens(a4)
	Blt.s	.Not_Done_Fading
	Move.w	#256,Master_Intens(a4)
	Clr.b	Fade_Direction(a4)
	Bra.s	.Not_Done_Fading
.Fade_Down
	Subq.w	#8,Master_Intens(a4)
	Bgt.s	.Not_Done_Fading
	Move.w	#0,Master_Intens(a4)
	Clr.b	Fade_Direction(a4)
.Not_Done_Fading
	St	Copy_The_Pallete(a4)
	Bsr	Fade_Pallete
.Done	Rts

**********************************************************
Fade_Pallete
	Move.w	Master_Intens(a4),d0
	Cmp.w	#0,d0
	Bge.s	.Ok1
	Moveq	#0,d0
.Ok1	Cmp.w	#256,d0
	Ble.s	.Ok2
	Move.w	#256,d0
.Ok2	Lea	Mypal,a0
	Lea	Destpal,a1
	Move.w	#256-1-32,d7
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
	Moveq	#32/2-1,d0
.Mloop	Move.l	(a0)+,(a1)+
	Dbra	d0,.Mloop
	St	Copy_The_Pallete(a4)
	Rts

**********************************************************
Generate_Player_Collision_Boxes
	Lea	Player_Boxes,a1
	Move.l	Player_Sprite_Base(a4),a0
	MOve.w	#Maximum_Amount_Of_Player_Sprites,-(sp)
.Loop	Move.l	Spr_Data(a0),a6
	Add.l	Player_Gfx_Base(a4),a6
	Bsr	Search_For_A_Byte
	Move.w	d7,(a1)+
	Move.w	d7,d5
	MOve.w	Spr_Yoffset(a0),d6
	MOve.w	d6,(a1)+
	Bsr	Search_For_A_Zero_Byte
	Add.w	d7,d5
	Move.w	d5,(a1)+
	Add.w	Spr_Sheight(a0),d6
	Move.w	d6,(a1)+
	Lea	16(a0),a0
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Rts



**********************************************************
Search_For_A_Zero_Byte
	Moveq	#0,d7
.Loop	Tst.w	(a6)+
	Beq.s	.Found
	Addq.w	#1,d7
	Bra.s	.Loop
.Found	Rts

**********************************************************
; Address in a6
; d7 returns count

Search_For_A_Byte
	Moveq	#0,d7
.Loop	Tst.w	(a6)+
	Bne.s	.Found
	Addq.w	#1,d7
	Bra.s	.Loop
.Found	Rts
	

**********************************************************
Setup_Color_Stuff
	Clr.b	Direction_Of_Intens(a4)
	Move.w	#128,Intens(a4)
	Rts

**********************************************************
Generate_Level	
	Clr.b	End_Level(a4)
	Clr.b	No_More_Scrolling(a4)
	Clr.b	Flag_To_Stop_Scrolling(a4)
	Tst.b	Demo_Mode(a4)	
	Bne.s	.Demo_Mode_On
	Move.w	#Map_Offset,Map_Offset_Variable(a4)
.Demo_Mode_On
	Cmp.b	#1,This_Level(a4)
	Bne.s	.Skip
	Add.w	#40,Map_Offset_Variable(a4)
.Skip	Cmp.b	#3,This_Level(a4)
	Bne.s	.Skip2
	Add.w	#20,Map_Offset_Variable(a4)
.Skip2	
	Lea	Map_Info(a4),a5
	Move.w	Map_Offset_Variable(a4),d6

	Mulu	#60,d6
	Sub.l	d6,Map_Pointer(a5)
	Lea	Map_Structure_End(a5),a5
	Sub.l	d6,Map_Pointer(a5)
	Move.w	Map_Offset_Variable(a4),d6

	Mulu	#4,d6
	Add.l	d6,Event_Tablep(a4)		; Offset into maps and event table (TEST PURPOSES!- (beware this dont work with paralax!) )
	Clr.b	Make_Event_Delay(a4)
	Sf	Make_Event(a4)		
	Move.l	#BACKDROP_MEM*2,d0
	Lea	Screen1,a0
	Bsr	Clear_Bytes
;	Move.w	#Screen_Height,-(sp)
	Move.w	Height_Of_Screen(a4),-(sp)
.Loop	
;	Bsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Clr.l	X_Speed+Pl1
	Clr.l	Draw_X_Speed+Pl1
	Clr.l	X_Speed+Pl2
	Clr.l	Draw_X_Speed+Pl2
;	Bsr	Scroll_Lr			; Get line offsets, Play/Screen offsets
	Bsr	Build_Map			; Build map if scrolling
	Bsr	Scroll_Down_Maps
	Bsr	Check_Event
	Bsr	Check_Paralax_Event			
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Rts

**********************************************************
; Parameters
; d0=x
; d1=y
; d2=Sprite

; a0=List pointer
; a3=Enemy sprite base
; a6=Pre generated objects

Quick_Enemy_Blit
	Lsl.w	#4,d2
	Tst.w	Spr_Sheight(a3,d2)
	Ble.s	.No_Display
	Sub.w	X_Offset_Into_Map(a4),d0
	And.w	#%111111111111,d0
	Add.w	d1,d1
	Bmi.s	.Clip_Y
	Movem.l	(a6,d2),d4-d7
	Move.l	a0,d3
	Addq.l	#8,d3
	Addq.l	#8,d3
	Moveq	#11,d2
	Ror.l	d2,d3
	Or.w	d3,d4
	Clr.w	d3
	Or.l	d3,d5
	Lsl.w	#3,d1
	Add.w	d1,d5
	Or.w	d0,d7
	Movem.l	d4-d7,(a0)
	Lea	16(a0),a0
	Addq.w	#1,Num_Objects_To_Display(a4)
.No_Display
	Rts

.Clip_Y	Asr.w	#1,d1
	Move.w	d1,d3
	Add.w	Spr_Sheight(a3,d2),d3
	Ble.s	.No_Display
	Movem.l	(a6,d2),d4-d7	
	Moveq	#0,d3
	Neg.w	d1
	Move.w	d1,d3
	Lsl.l	#8,d3
	Lsl.l	#6,d3
	Sub.l	d3,d5
	Move.w	Spr_Pixel_Width(a3,d2),d3			; Width of the graphic in pixels
	Subq.w	#1,d3
	Move.b	Spr_Bitsperpixel(a3,d2),d2			; Number of bits per pixel
	Lsl.w	d2,d3						; Total number of bits on a line
	And.w	#-64,d3
	Add.w	#64,d3						; Fix to phrase boundry (pixels!)
	Lsr.w	#3,d3						; /8 Number of bytes !
	Mulu	d3,d1						; Difference in y
	Moveq	#43-32-3,d3
	Lsl.l	d3,d1
	Add.l	d1,d4
	Move.l	a0,d3
	Addq.l	#8,d3
	Addq.l	#8,d3
	Moveq	#11,d2
	Ror.l	d2,d3	
	Or.w	d3,d4
	Clr.w	d3
	Or.l	d3,d5
	Or.w	d0,d7
	Movem.l	d4-d7,(a0)
	Lea	16(a0),a0
	Addq.w	#1,Num_Objects_To_Display(a4)
	Rts

**********************************************************
; Parameters
; d0=x
; d1=y
; d2=Sprite

; a0=List pointer
; a3=Player sprite base
; a6=Pre generated objects

Quick_Player_Blit
	Lsl.w	#4,d2
;	Add.w	Spr_Yoffset(a3,d2),d1
	And.w	#%111111111111,d0
	Tst.w	d1
	Bmi.s	.Clip_Y
	Add.w	d1,d1
	Movem.l	(a6,d2),d4-d7
	Move.l	a0,d3
	Addq.l	#8,d3
	Addq.l	#8,d3
	Moveq	#11,d2
	Ror.l	d2,d3
	Or.w	d3,d4
	Clr.w	d3
	Or.l	d3,d5
	Lsl.w	#3,d1
	Add.w	d1,d5
	Or.w	d0,d7
	Move.l	d4,(a0)+
	Move.l	d5,(a0)+
	Move.l	d6,(a0)+
	Move.l	d7,(a0)+
	Addq.w	#1,Num_Objects_To_Display(a4)
.No_Display
	Rts

.Clip_Y	Move.w	d1,d3
	Add.w	Spr_Sheight(a3,d2),d3
	Ble.s	.No_Display
	Movem.l	(a6,d2),d4-d7	
	Moveq	#0,d3
	Neg.w	d1
	Move.w	d1,d3
	Lsl.l	#8,d3
	Lsl.l	#6,d3
	Sub.l	d3,d5
	Add.w	d1,d1
	Mulu	Spr_Pixel_Width(a3,d2),d1
	Moveq	#43-32-3,d3
	Lsl.l	d3,d1
	Add.l	d1,d4
	Move.l	a0,d3
	Addq.l	#8,d3
	Addq.l	#8,d3
	Moveq	#11,d2
	Ror.l	d2,d3	
	Or.w	d3,d4
	Clr.w	d3
	Or.l	d3,d5
	Or.w	d0,d7
	Move.l	d4,(a0)+
	Move.l	d5,(a0)+
	Move.l	d6,(a0)+
	Move.l	d7,(a0)+
	Addq.w	#1,Num_Objects_To_Display(a4)
	Rts

**********************************************************
Pre_Generate_Some_Player_Objects
	Lea	.Player_List(pc),a0
	Move.l	Player_Sprite_Base(a4),a1
	Move.l	Player_GFX_Base(a4),a2
	Jsr	Sixteen_Bit_Sprites_To_Four_Bit
	Lea	Pre_Generated_Player_Objects,a6
	Clr.w	-(sp)	
.Loop	Moveq	#0,d0
	Moveq	#0,d1
	Move.w	(sp),d2
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_Gfx_Base(a4),a5
	Movem.w	Clearr(a4),d4-d7
	Movem.l	d4-d7,-(sp)
	Move.l	sp,a0
	Add.w	X_Offset_Into_Map(a4),d0
	Pea	(a6)
	Move.w	d2,d3
	Lsl.w	#4,d3
	Sub.w	Spr_Yoffset(a3,d3),d1
	Bsr	Qblit_Bodge
	Move.l	(sp)+,a6
	Movem.l	(sp)+,d0-d3
	And.l	#%11111111111111111111100000000000,d0
	And.l	#%00000000111111111111111111111111,d1	; Link is not valid !
	Movem.l	d0-d3,(a6)
       	Lea	16(a6),a6
	Addq.w	#1,(sp)
	Cmp.w	#Maximum_Amount_Of_Player_Sprites,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Rts

.Player_List
	Dc.w	18,5,12,6,5,7,7,8,9,9
	Dc.w	16,10,24,11,14,223,21,224
	Dc.w	20,225,13,226,6,227,8,228
	Dc.w	15,229,22,230,4,231,10,232
	Dc.w	19,233,23,234
	Dc.w	-1

**********************************************************
Pre_Generate_Some_Objects
	Lea	.Enemy_Sprites_to_Convert(pc),a0
	Move.l	Enemy_Sprites_Base(a4),a1
	Move.l	Enemy_Gfx_Base(a4),a2
	Jsr	Sixteen_Bit_Sprites_To_Four_Bit
	Lea	Data,a4
	Clr.b	Reflect_Object_Flag(a4)
	Lea	Pre_Generated_Objects,a6
	Clr.w	-(sp)	
.Loop	Moveq	#0,d0
	Moveq	#0,d1
	Move.w	(sp),d2
	Move.l	Enemy_Sprites_Base(a4),a3
	Move.l	Enemy_Gfx_Base(a4),a5
	Clr.l	-(sp)
	Clr.l	-(sp)
	Clr.l	-(sp)
	Clr.l	-(sp)
	Move.l	sp,a0
	Add.w	X_Offset_Into_Map(a4),d0
	Pea	(a6)
	Move.w	d2,d3
	Lsl.w	#4,d3
	Sub.w	Spr_Yoffset(a3,d3),d1
	Bsr.s	Qblit_Bodge
	Move.l	(sp)+,a6
	Movem.l	(sp)+,d0-d3
	And.l	#%11111111111111111111100000000000,d0
	And.l	#%00000000111111111111111111111111,d1	; Link is not valid !
	Movem.l	d0-d3,(a6)
       	Lea	16(a6),a6
	Addq.w	#1,(sp)
	Cmp.w	#Maximum_Amount_Of_Sprites,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Rts

.Enemy_Sprites_to_Convert
	Dc.w	2,64
	Dc.w	3,65
	Dc.w	0,168
	Dc.w	1,169
	Dc.w	25,322
	Dc.w	26,323
	Dc.w	27,324
	Dc.w	-1


Qblit_Bodge
	Push
	Sub.w	X_Offset_Into_Map(a4),d0
	Lsl.w	#4,d2
	Lea	(a3,d2),a3
	Move.l	Spr_Data(a3),a1
	Add.l	a5,a1
	Moveq	#0,d7
	Move.b	Spr_BitsPerPixel(a3),d7
	Move.w	Spr_Pixel_Width(a3),d2
	Moveq	#0,d6
	Move.b	.Pixel_Shift(pc,d7),d6
	Moveq	#0,d5
	Cmp.b	#2,d7
	Bgt.s	.Nx
	Bset	#16,d5
.Nx	Movem.l	d5/a0,-(sp)
	Moveq	#0,d5
	Lsr.w	d6,d2
	Move.w	Spr_SHeight(a3),d3
	Ble.s	.No_Spr
	Add.w	Spr_Yoffset(a3),d1
	Move.w	Spr_Palnum(a3),d6
	Jsr	Make_An_Object2
	Movem.l	(sp)+,d5/a0
	Or.l	d5,8(a0)
	Pull
	Rts
.No_Spr	Movem.l	(sp)+,d5/a0
	Clr.l	0(a0)
	Clr.l	4(a0)
	Clr.l	8(a0)
	Clr.l	12(a0)
	Pull
	Rts

.Pixel_Shift
	Dc.b	6,5,4,3,2,1

**********************************************************
Make_Alien_Boxes
	Move.l	Enemy_Sprites_Base(a4),a0
	Lea	Alien_Boxes,a1
	Move.w	#Maximum_Amount_Of_Sprites-1,d7
	Lea	Enemy_Sprite_Offsets,a6
.Loop	Move.w	Spr_Pixel_Width(a0),d0
	Move.w	Spr_SHeight(a0),d2
	Movem.w	(a6)+,d5-d6
	Move.w	#0,(a1)+
	Add.w	d5,-2(a1)
	Move.w	#0,(a1)+
	Add.w	d6,-2(a1)
	Move.w	d0,(a1)+
	Add.w	d5,-2(a1)
	Move.w	d2,(a1)+
	Add.w	d6,-2(a1)
	Lea	16(a0),a0
	Dbra	d7,.Loop
	Move.w	#0,d0
	Move.w	#0,d1
	Move.w	#24,d2
	Move.w	#24,d3
	Lea	Alien_Boxes,a1
	Movem.w	d0-d3,91*16(a1)			; This is an invisible sprite
	Lea	.Bodge_Sprites1(pc),a0
	Moveq	#-8,d4
	Moveq	#-8,d5
	Moveq	#24,d6
	Moveq	#24,d7
	Bsr.s	.Bodge_Collision
	Lea	.Bodge_Sprites2(pc),a0
	Moveq	#-2,d4
	Moveq	#-2,d5
	Moveq	#32,d6
	Moveq	#32,d7
	Bsr.s	.Bodge_Collision
	Rts

.Bodge_Collision
	Lea	Alien_Boxes,a1
.Loopy	Move.w	(a0)+,d0
	Bmi.s	.Out
	Lsl.w	#3,d0
	Movem.w	d4-d7,(a1,d0)
	Bra.s	.Loopy
.Out	Rts

.Bodge_Sprites1
	Dc.w	66,67,68,69,70,71,72,73,74,75,76,77,78,79
	Dc.w	100,108,109,110,111,112,113,86,87,224,225,617,618
	Dc.w	267,269,818,820,-1
.Bodge_Sprites2
Temper	Set	1271
	Rept	16
	Dc.w	Temper
Temper	Set	Temper+1
	Endr
Temper	Set	801
	Rept	16
	Dc.w	Temper
Temper	Set	Temper+1
	Endr
	Dc.w	-1

**********************************************************
Setup_Game_Loop_Vars
	Clr.b	Old_Vbl_On_Vbl(a4)
	Move.w	#0,Unique_Fire(a4)
	Clr.b	Bomb_Explosion_Off(a4)
	Sf	Stop_Cycle4(a4)
	Clr.l	Joycur
	Clr.l	Joycur+4
	Clr.b	Completed_Raiden(a4)
	Clr.w	Seed(a4)
	Move.w	#00,Continue_Delay(a4)		; Set it up
	Clr.b	Number_Of_Powerups_On_Screen(a4)
	Clr.w	Wash_Intensity(a4)
	Clr.b	Wash_Add(a4)
	Sf	No_Printing_top_Map(a4)
	Clr.b	Paralax_Event_Flag(a4)
	Clr.w	Train_Links_Number(a4)
	Move.w	#Max_Aliens-1,d7
	LEa	Alien_Table(a4),a1
.Loop	Clr.w	(a1)
	Lea	Aln_End(a1),a1
	Dbra	d7,.Loop
	Clr.w	Guardian_Delay(a4)	
	Clr.b	Guardian_Music_On(a4)
	Clr.w	Num_Guardians_Active(a4)
	Sf	Both_Players_In_Place(a4)
	Sf	End_Level(a4)
	Sf	No_Bombing(a4)
	Sf	No_Firing(a4)			
	Sf	No_More_Scrolling(a4)		
	Clr.b	Flag_To_Stop_Scrolling(a4)
	Sf	Vbl_Flag(a4)			
	Move.b	#1,Fade_Direction(a4)		; Fading positive (up!)
	Clr.b	No_Firing_Bombing_Or_Pausing(a4)
	Moveq	#0,d0
	Move.b	This_Level(a4),d0
	Lea	Powerup_Event_Pointers,a1
	Lsl.w	#2,d0
	Move.l	-4(a1,d0),Power_Up_Event_Table_Pointer(a4)
	Lea	Pl1,a3
	Bsr	.Setup_Player
	Lea	Pl2,a3
	Bsr	.Setup_Player
	Rts

.Setup_Player
	Sf	No_Move(a3)
	Clr.b	Medals_Got(a3)
	Clr.l	X_Speed(a3)
	Clr.b	Button_Repeat(a3)
	Clr.b	We_Have_Fired(a3)		
	Clr.b	Stream_Done(a3)
	Clr.b	Button_Repeat(a3)
	Clr.b	Fire_Pressed_On_read(a3)
	Rts

**********************************************************
Initial_Vars
	Movem.w	Clearr(a4),d0-d4	; Clear top values
	Movem.w	d0-d4,Bomb_Struct(a4)	; X/Y of bomb into structure
	Clr.b	Bomb_Active(a4)
	Clr.w	Difficuly(a4)
	Tst.b	Ntsc_Flag(a4)
	Bne.s	.Running_On_Ntsc
	Addq.w	#2,Difficuly(a4)
.Running_On_Ntsc
	Clr.b	Num_Creds+Pl1
	Clr.b	Num_Creds+Pl2
	Clr.l	JoyCur
	Clr.l	JoyCur+4
	Move.l	#Screen_Script,Screen_Script_Pointer(a4)
	Pea	Alien_Sort_Table(a4)
	And.l	#-8,(sp)
	Move.l	(sp)+,Alien_Sort_Pointer(a4)
;---	
;	Move.b	#10,Num_Credits(a4)
;---	
		
	Move.b	Num_Credits(a4),d0
	Lsr.b	#1,d0
	Move.b	d0,Num_Creds+Pl1
	Move.b	d0,Num_Creds+Pl2

	Move.w	#(Byteswide/2)-(Playfield_Width/2),X_Offset_Into_Map(a4)
	Move.b	#Level,This_Level(a4)		; Setup current level

	Btst	#0,d7
	Sne	Num_Lives+Pl1		; Set number of lives
	Ifeq	Record
	And.b	#5,Num_Lives+Pl1	; Set number of lives
	Else
	And.b	#1,Num_Lives+Pl1	; Set number of lives
	Endc
	Tst.b	Play_Through_The_Script(a4)
	Beq.s	.No_Play1
	Move.b	#1,Num_Lives+Pl1
.No_Play1
	Btst	#1,d7
	Sne	Num_Lives+Pl2		; Set number of lives
	Ifeq	Record
	And.b	#5,Num_Lives+Pl2	; Set number of lives
	Else
	And.b	#1,Num_Lives+Pl2	; Set number of lives
	Endc
	Tst.b	Play_Through_The_Script(a4)
	Beq.s	.No_Play2
	Move.b	#1,Num_Lives+Pl2
.No_Play2
	Lea	Pl1,a3		
	Tst.b	Num_Lives(a3)
	Beq.s	.No_Pl1
	Bsr	Setup_Player
	Subq.b	#1,Num_Credits(a4)
	Subq.b	#1,Num_Creds+Pl1
.No_Pl1			
	Lea	Pl2,a3
	Tst.b	Num_Lives(a3)
	Beq.s	.No_Pl2
	Bsr	Setup_Player
	Subq.b	#1,Num_Credits(a4)
	Subq.b	#1,Num_Creds+Pl2
	Rts

.No_Pl2	
;	Clr.b	Num_Creds+Pl2
;	Move.b	Num_Credits(a4),d2
;	Lsr.w	#1,d2
;	Bcc.s	.No_Carry
;	Addq.b	#1,d2
;.No_Carry
;	Sub.b	d2,Num_Credits(a4)
	Rts



**********************************************************
Setup_Player
	Clr.w	Can_Continue(a3)
	Sf	Delay_Set_For_Player_fire(a4)
	Clr.b	Stream_Done(a3)
	Clr.b	Hover_Direction(a3)
	Clr.b	Hover_Mode(a3)
	Clr.b	Transforming_Ship(a3)
	Clr.w	Transform_Frame(a3)
	Move.b	#3,Num_Bombs(a3)
	St	Player_Active(a3)		
	St	Startup(a3)			; No restore/Active/Startup routine
	Sf	Death_sequence(a3)
	Sf	No_Move(a3)
	Clr.b	Pups_Got(a3)
	Clr.b	Medals_Got(a3)
	Move.b	#0,Weapon_In_Use(a3)		; Using normal shot
	Move.b	#0,Weapon_Power(a3)		; At power-up level 0
	Tst.b	Demo_Mode(a4)
	Beq.s	.No_Demo1	
	Cmp.l	#Pl1,a3
	Beq.s	.Set_Player1_Primary
	Move.b	Weapon_Num2(a4),Weapon_In_Use(a3)
	Move.b	Weapon_Powersave2(a4),Weapon_Power(a3)
	Bra.s	.No_Demo1	
.Set_Player1_Primary
	Move.b	Weapon_Num(a4),Weapon_In_Use(a3)
	Move.b	Weapon_Powersave(a4),Weapon_Power(a3)
.No_Demo1	
	Tst.l	Score(a3)
	Bne.s	.Scored
	Move.l	#$150000,Live_Add(a3)
.Scored
	Clr.l	Score(a3)
	Move.b	#-1,Secondry_Weapon(a3)		; No secondry weapon
	Tst.b	Demo_Mode(a4)
	Beq.s	.No_Demo2
	Cmp.l	#Pl1,a3
	Beq.s	.Set_Player1_Primaryb
	Move.b	Weapon_Num2+1(a4),Secondry_Weapon(a3)
	Move.b	Weapon_Powersave2+1(a4),Weapon_Power2(a3)
	Bra.s	.No_Demo2
.Set_Player1_Primaryb
	Move.b	Weapon_Num+1(a4),Secondry_Weapon(a3)
	Move.b	Weapon_Powersave+1(a4),Weapon_Power2(a3)
.No_Demo2
	Move.b	#0,Weapon_Power2(a3)		; Clear powerup for level

	Move.b	#Ded_Delay,Dead_Count(a3)	; Startup-delay
	Cmp.l	#Pl1,a3
	Beq.s	.Check_Player1_To_Player2
.Check_Player2_To_Player1
	Lea	Pl1,a2
	Moveq	#2,d4
	Bra.s	.Startup_Ship
.Check_Player1_To_Player2
	Lea	Pl2,a2
	Moveq	#0,d4
.Startup_Ship
	Tst.b	Num_Lives(a2)
	Bne.s	.Normal_Start
	Moveq	#1,d4
.Normal_Start
	Add.w	d4,d4
	Move.w	.Player_Start_Coards(pc,d4),Shipxy(a3)
;	Move.w	#Screen_Height+100,Shipxy+2(a3)
	Move.w	Height_Of_SCREEN(a4),Shipxy+2(a3)
	Add.w	#100,Shipxy+2(a3)

;	Move.b	#1,Secondry_Weapon(a3)		; No secondry weapon
;	Move.b	#4,Weapon_Power2(a3)
;	Move.b	#1,Weapon_In_Use(a3)
;	Move.b	#7,Weapon_Power(a3)

	Rts

.Player_Start_Coards
	Dc.w	32
	Dc.w	(Playfield_Width/2)-16+8
	Dc.w	Playfield_Width-32-32

**********************************************************
Clear_Player_data			; Save certain player variables and then clear all player data
	Move.l	#Pvarend,d0
	Bra	Clear_Bytes	

**********************************************************
; Clear an array of bytes
; a0-Start address
; d0.l-Number of bytes to clear

Clear_Bytes
	Clr.b	(a0)+
	Subq.l	#1,d0
	Bne.s	Clear_Bytes
	Rts

**********************************************************
; Copy an array of bytes
; a0-Start address
; a1-Dest address
; d0.l-Number of bytes to clear

Copy_Bytes
	Move.b	(a0)+,(a1)+
	Subq.l	#1,d0
	Bne.s	Copy_Bytes
	Rts

**********************************************************
Setup_Screens
	Move.l	#Object_List1+DATa,d0
	Move.l	#Object_List2+DATA,d1			; Double buffered lists
	Move.l	#Object_List_VBL_Buffer+DATA,d2		; VBL buffer list
	And.l	#-32,d0
	And.l	#-32,d1
	And.l	#-32,d2					; Reserve for ALL object types
	Movem.l	d0-d2,Object_List_Pointer(a4)		; Save 32 byte aligned pointers
	Clr.l	Num_Objects_To_Display(a4)		; No objects to display
	Bsr	Setup_Mainloop_Vars			; Pointers required for swap routines
	Bsr	Swapscreens				; Swap lists
	Bsr	Setup_Mainloop_Vars
	Bsr	Swapscreens				; Do twice to initialize both lists with stop objects
	PHRASE_IT	#Screen1,Base_Of_Map_Elements(a4)	; Screen base
	Rts

**********************************************************
Wait_Main_Vbl
;	Moveq	#2,d0
	Move.w	#1,d0
Wait_Vbl
	Move.b	d0,Frame_Rate_To_Wait(a4)
	Move.b	Vbl_Flag(a4),d1			; Current frame count in d1
.Wait1	Cmp.b	Vbl_Flag(a4),d1
	Beq.s	.Wait1				; Wait for tick over
.Wait	Cmp.b	Vbl_Flag(a4),d0			; Wait for Vblflag>=
	Bgt.s	.Wait
	Clr.b	Vbl_Flag(a4)			; Clear vbl_Flag
	Rts

**********************************************************
** NEW VERTICAL BLANK !

TIMERINTBIT	equ	3

DisableTimer
	bclr	#TIMERINTBIT,intmask
	rts

ENABLETIMER
	bset	#TIMERINTBIT,intmask
	rts

**********************************************************


Setup_Ints
	Tst.b	Setup_Ints_Flag
	Bne.s	.Already_Setup
	St	Setup_Ints_Flag
	Pea	NEW_Vbl(pc)
	Move.l	(sp)+,LEVEL2
	moveq	#0,d1
	Bset	#0,Intmask
	move.b	intmask,d1
	move.w	d1,INT1+Hardware
	move.w	#999,PIT0+Hardware		;set timer for mod player
	move.w	#531,PIT1+Hardware
	Lea	Hardware,a5
	Move.w	Height_Of_Screen(a4),d1
	Add.w	d1,d1
	Add.w	#N_Vdb+5,d1
;	move.w	#N_Vde+5,VI(a5)
	move.w	d1,VI(a5)
	move.w	sr,d0
	and.w	#$f8ff,d0
	move.w	d0,sr
	Jsr	VideoInit
.Already_Setup
	rts

Setup_Ints_Flag
	Ds.w	1

New_Vbl Move.w	d0,-(sp)
	Move.w	Int1+Hardware,d0
	Tst.b	Video_Flag
	Bne.s	.Video_Enabled
	Move.w	#$909,Int1+Hardware
	Move.w	(sp)+,d0
	Move.w	#0,Int2+Hardware
	Rte

.Video_Enabled
	btst	#3,d0
	beq.s	.no_sound
	Move.w	#$809,Int1+Hardware
	Move.w	#$2100,sr
	Bsr	Check_Intermision
	Btst	#Timerintbit,Intmask
	Beq.s	.no_sound
	Tst.b	Music_On+Data
	Bne.s	.No_Sound
	Tst.b	DSP_Halted+Data
	Bne.s	.No_sound
	jsr	nt_vbl
.No_sound
	Move.w	Int1+Hardware,d0
	btst	#0,d0
	Bne.s	Vbl_Int
	move.w	(sp)+,d0
	Move.w	#$0,Int2+Hardware
	Rte

Vbl_Int	Move.w	(sp)+,d0
	Push
	Lea	Data,a4
	Lea	Hardware,a5
	Jsr	Vblank_Atari_Logo
.Video	Tst.b	List_Made(a4)
	Beq.s	.No_List_Made
	Bsr	Vbl_Swap	
.No_List_Made
	Bsr	Copy_List_To_Vbl_Buffer
	Bsr	Copy_Vbl_Buffer_To_List
	Sf	List_Made(a4)
	Bsr	Setup_Object_Processor
	Bsr	Vbl_Copypal	
	Tst.b	Old_Vbl_On_Vbl(a4)
	Beq.s	.No_Do_Oldvbl
	Cmp.b	#Frame_Rate,Vbl_Flag(a4)
	Bne.s	.No_Do_Oldvbl
	Bsr	End_Lev_Vbl
.No_Do_Oldvbl
	Tst.b	Exit_On_Vbl(a4)
	Beq.s	.No_Check
	Tst.b	Loading_Stuff(a4)
	Bne.s	.No_Check
	Jsr	Check_For_A_Fire_Button
	Bne.s	.Vbl_Exit
.No_Check
	Addq.b	#1,Vbl_Flag(a4)
	move.w	#$109,INT1+Hardware
	Move.w	Int1+Hardware,d0
	btst	#3,d0
	beq.s	.no_sound
	Move.w	#$809,Int1+Hardware
	Bsr	Check_Intermision
	Btst	#Timerintbit,Intmask
	Beq.s	.no_sound
	Tst.b	Music_On+Data
	Bne.s	.No_Sound
	Tst.b	DSP_Halted+Data
	Bne.s	.No_sound
	jsr	nt_vbl
.no_sound
	Movem.l	(sp)+,d0-d7/a0-a6
	Move.w	#$0,Int2+Hardware
	Rte	

.Vbl_Exit
	Addq.b	#1,Vbl_Flag(a4)
	move.w	#$109,INT1+Hardware
	Jsr	Fadedown
	Addq.b	#1,Vbl_Flag(a4)
	Movem.l	(sp)+,d0-d7/a0-a6
	Move.l	#EXit_Intro,2(sp)
	move.w	#0,INT2+Hardware
	Rte	

**********************************************************
Check_Intermision
	Tst.b	Flag_To_Kill_Interm_Mod+Data
	Beq.s	.No_Interm_Mod
	Addq.w	#1,Interm_Mod_Delay+Data
	Tst.b	Ntsc_Flag(a4)
	Bne.s	.Ntsc
	Cmp.w	#((10*50)*6)/5,Interm_Mod_Delay+Data
	Bne.s	.No_Interm_Mod
	Bra.s	.Kill_Mod
.Ntsc
	Cmp.w	#10*50,Interm_Mod_Delay+Data
	Bne.s	.No_Interm_Mod
.Kill_Mod
	Clr.b	Flag_To_Kill_Interm_Mod+Data
	Jsr	Stop_Mod
.No_Interm_Mod
	Rts

**********************************************************
End_Lev_Vbl
	Clr.b	Vbl_Flag(a4)
	Bsr	Setup_Mainloop_Vars		
	Tst.b	Doing_Carrier(a4)
	Bne.s	.Skip_Cycle
	Move.b	This_Level(a4),-(sp)
	Clr.b	This_Level(a4)
	Bsr	Level_Pallete_Stuff		; Cycle / pulses etc
	Move.b	(sp)+,This_Level(a4)
.Skip_Cycle
	Bsr	Old_VBL_STUFF
	Tst.b	Doing_Carrier(a4)
	Bne.s	.Skip_Cycle2
	Jsr	Display_Bonus_Panel
.Skip_Cycle2
	Jsr	Add_Bonus
	Bsr	Swapscreens			
	Rts

**********************************************************

Copy_List_To_Vbl_Buffer
	Tst.b	List_Made(a4)
	Bne.s	.Yes
	Rts
.Yes	Movem.l	Object_List_Pointer+4(a4),a0-a1	; Destination buffer is VBL buffer
	Moveq	#0,d0
	Move.w	Num_Objects_To_Display+2(a4),d0
	Addq.w	#1,d0
	Lsl.w	#4,d0			; Number of bytes
;	Move.l	#0,(a0)
;	Move.l	#4,4(a0)
	Bra	Fast_68000_Copy

Copy_Vbl_Buffer_To_List
	Tst.b	List_Made(a4)
	Beq.s	.Yes
	Rts
.Yes	Movem.l	Object_List_Pointer+4(a4),a0-a1	; Destination buffer is VBL buffer
	Exg	a0,a1
	Moveq	#0,d0
	Move.w	Num_Objects_To_Display+2(a4),d0
	Addq.w	#1,d0
	Lsl.w	#4,d0			; Number of bytes
;	Move.l	#0,(a0)
;	Move.l	#4,4(a0)
	Bra	Fast_68000_Copy

Setup_Object_Processor_To_Point_to_Stop
	Move.l	Dont_Know_What_This_Does_Pointer,d0
	Subq.l	#8,d0
	Swap	d0
	Move.l	d0,OLP+Hardware
	Rts

Setup_Object_Processor
	Move.l	Dont_Know_What_This_Does_Pointer,a0
	Lea	16(a0),a0
	Move.l	Object_List_Pointer+4(a4),a1
	Move.w	#BRA_VCEQ,d0
	Move.w	#$7ff,d1
	Jsr	Make_Branch_Object

	Move.l	Dont_Know_What_This_Does_Pointer,d0
;	Move.l	d0,a1
;	Move.l	#0,(a1)+
;	Move.l	#4,(a1)+

	Swap	d0
	Move.l	d0,OLP(a5)			; and other bits of the OL address
	Rts

**********************************************************
Fast_68000_Copy
	Push	
	Moveq	#44,d1
.Copy_Loop1
	Sub.w	d1,d0
	Bmi.s	.Copy_Extra_Few_Longs
	Movem.l	(a0)+,d2-d7/a2-a6
	Movem.l	d2-d7/a2-a6,(a1)
	Add.w	d1,a1	
	Bra.s	.Copy_Loop1
.Copy_Extra_Few_Longs
	Add.w	d1,d0
	Beq.s	.Done
	Ext.l	d0
.Loop2	Subq.w	#4,d0
	Bmi.s	.Copy_Extra_Few_Bytes
	Move.l	(a0)+,(a1)+
	Bra.s	.Loop2
.Copy_Extra_Few_Bytes
	Addq.w	#4,d0
	Beq.s	.Done
	Bsr	Copy_Bytes
.Done	Pull
	Rts	


**********************************************************
Check_Bomb_Button
	Tst.b	No_Firing_Bombing_Or_Pausing(a4)
	Beq.s	.Ok_Do
	Rts
.Ok_Do	Lea	Pl1,a3
	Bsr.s	.Do			
	Lea	Pl2,a3

.Do	Tst_Act
	Tst_Startup			; Just make sure can use button anyway!
	Tst.b	Cant_Bomb(a3)
	Bne	.Exit
	Tst.b	Death_Sequence(a3)
	Bne	.Exit			; If you just been hit, cant do !
	Tst.b	Bomb_Active(a4)
	Bne	.Exit			; If already dropping/flashing bomb, cant do
	Tst.b	Bomb_Pressed_On_Read(a3)
	Beq	.Exit			; Check if you pressed this button anyway
	Tst.b	No_Bombing(a4)
	Bne.s	.Exit			; Also check this global flag
	Tst.b	Num_Bombs(a3)		; Cant bomb when you aint got any!
	Ble.s	.Exit
	Tst.w	Cheat_Mode_Active
	Bne.s	.No_Bomb_Dec
	Subq.b	#1,Num_Bombs(a3)	; Cant bomb when you aint got any!
.No_Bomb_Dec
	Clr.b	Player_That_Bombed(a4)
	Cmp.l	#Pl1,a3
	Beq.s	.Player1_Bombed
	Move.b	#1,Player_That_Bombed(a4)
.Player1_Bombed
	St	Cant_Bomb+Pl1
	St	Cant_Bomb+Pl2
	Movem.w	Shipxy(a3),d0-d1	; Get X/Y of ship !
	Subq.w	#8,d1
	Add.w	X_Offset_Into_Map(a4),d0	; Add to X!
	Addq.w	#8,d0			; Make X more realistic
	Movem.w	Clearr(a4),d2-d4	; Clear top values
	Movem.w	d0-d4,Bomb_Struct(a4)	; X/Y of bomb into structure
	Clr.b	Initial_Bomb_Blast(a4)
	Lea	Bomb_Sfx,a6
	Tst.b	Ntsc_Flag(a4)
	Beq.s	.Pal_Expl
	Bsr	Play_This_Sample
	Bra.s	.Skip_Pal_Sfx
.Pal_Expl
	Tst.b	Demo_Mode(a4)
	Bne.s	.Skip_Pal_Sfx
	Move.l	a6,a0
	Movem.w	(a0)+,d0-d3
	Sub.w	#$30,d3
	Jsr	playfx
.Skip_Pal_Sfx
	Clr.w	Bomb_Explo_Delay(a4)
.Exit	Rts
	
**********************************************************
Draw_Bomb
	Tst.w	Bomb_Struct(a4)
	Beq.s	.No_Bomb_Drop
	Tst.b	Bomb_Active(a4)
	Bne.s	.No_Bomb_Drop
	Movem.w	Bomb_Struct(a4),d0-d1
	Move.w	Bomb_Drop_Frame_Number(a4),d2
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFx_Base(a4),a5
	Sub.w	X_Offset_Into_Map(a4),d0
	Lea	Pre_Generated_Player_Objects,a6
	Move.l	Current_List_Pointer(a4),a0
	Bsr	Quick_Player_Blit
	Move.l	a0,Current_List_Pointer(a4)
.No_Bomb_Drop
	Rts

**********************************************************
Draw_Bomb_Explosion
	Tst.b	Bomb_Active(a4)
	Beq	.Not_Active
	Tst.b	Initial_Bomb_Blast(a4)
	Beq.s	.Do_Initial_Bomb_Blast
	Subq.w	#1,Bomb_Explo_Delay(a4)
	Tst.w	Bomb_Explo_Delay(a4)
	Bpl.s	.Back
	Move.w	#9,Bomb_Explo_Delay(a4)
	Lea	Massive_Explosion_Sfx,a6
	Bsr	Play_This_Sample
	Bra.s	.Back
.Do_Initial_Bomb_Blast
	Subq.w	#1,Bomb_Explo_Delay(a4)
	Tst.w	Bomb_Explo_Delay(a4)
	Bpl.s	.Back
	Move.w	#40,Bomb_Explo_Delay(a4)
	Lea	Massive_Explosion_Sfx,a6
	Bsr	Play_This_Sample
	St	Initial_Bomb_Blast(a4)

.Back	
	Tst.w	Bomb_Explosion_Repeatval(a4)
	Bne.s	.Doing_Anim


	Move.l	Bomb_Explosion_Framepointer(a4),a3
	Move.w	Bomb_Explosion_MaxAnimation_Number(a4),d3
	Add.w	d3,d3
	Lea	(a3,d3),a3
	Move.w	(a3)+,Bomb_Explosion_Repeatval(a4)
	Bmi	.Kill_Bomb
	Move.w	(a3)+,Bomb_Explosion_MaxAnimation_Number(a4)
	Clr.w	Bomb_Explosion_Animation_Number(a4)
	Move.l	a3,Bomb_Explosion_Framepointer(a4)
.Doing_Anim
	Move.l	Bomb_Explosion_Framepointer(a4),a3
	Move.w	Bomb_Explosion_Animation_Number(a4),d3
	Cmp.w	Bomb_Explosion_MaxAnimation_Number(a4),d3
	Bne.s	.Not_End_Of_List
	Clr.w	Bomb_Explosion_Animation_Number(a4)
	Subq.w	#1,Bomb_Explosion_Repeatval(a4)
	Beq.s	.Back
	Bra.s	.Doing_Anim
.Not_End_Of_List
	Add.w	d3,d3
	Move.w	(a3,d3),d2
	Move.w	d2,Bomb_Explosion_Sprite_Num(a4)
	Addq.w	#1,Bomb_Explosion_Animation_Number(a4)

	Subq.b	#1,Bomb_Up_Del(a4)
	Bgt.s	.No_Up_Bomb
	Move.b	#2,Bomb_Up_Del(a4)
	Subq.w	#1,Bomb_Struct+2(a4)
.No_Up_Bomb
	Movem.w	Bomb_Struct(a4),d0-d1
	Move.w	d2,d7
	Lsl.w	#4,d7
	Move.l	Player_Sprite_Base(a4),a3
	Move.w	Spr_Yoffset(a3,d7),d4
	Move.w	Spr_SHeight(a3,d7),d6
	Asr.w	#1,d6
	Move.w	Spr_Pixel_Width(a3,d7),d7
	Cmp.w	#239,d2
	Bgt.s	.Normal_Width
	Movem.l	d2/a6,-(sp)
	Lea	Bomb_1_Col_Offsets(pc),a6
	Sub.w	#235,d2
	Add.w	d2,d2
	Sub.w	(a6,d2),d7
	Movem.l	(sp)+,d2/a6
.Normal_Width
	Sub.w	d6,d1
	Sub.w	d7,d0
	Movem.w	d0-d2/d6-d7,-(sp)
	Move.l	Player_Gfx_Base(a4),a5
	Bsr	Blit_A_Sprite
	Movem.w	(sp)+,d0-d2/d6-d7
	St	Reflect_Object_Flag(a4)
	Add.w	d7,d0	
	Add.w	d7,d0	
	Subq.w	#1,d0	
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_Gfx_Base(a4),a5
	Bsr	Blit_A_Sprite
	Sf	Reflect_Object_Flag(a4)
	Move.w	Bomb_Explosion_Sprite_Num(a4),d2
	Cmp.w	#247,d2
	Beq.s	.Do_Minis
	Cmp.w	#248,d2
	Beq.s	.Do_Minis
	Cmp.w	#249,d2
	Beq.s	.Do_Minis
	Bra	.Not_Active
.Do_Minis
	Lea	Bomb_Mini_Explosion_Frames(pc),a2
	Lea	Bomb_Mini_Translation(pc),a1
	Move.l	Enemy_Sprites_Base(a4),a3
	Move.l	Enemy_Gfx_Base(a4),a5
	Move.l	Current_List_Pointer(a4),a0
	Tst.w	Bomb_Wobble(a4)
	Bne.s	.Flip_Wobble
	Addq	#1,Bomb_Wobble(a4)
.Flip_Wobble
	Neg.w	Bomb_Wobble(a4)
.Mini_Loop
	Movem.w	(a2)+,d5-d7
	Cmp.w	#$8000,d5
	Beq.s	.Not_Active1
	Addq.w	#1,d7
	Move.w	d7,d2
	Add.w	d2,d2
	Tst.w	(a1,d2)
	Bpl.s	.Ok
	Clr.w	d7
	Move.w	d7,d2
.Ok	Move.w	(a1,d2),d2	
	Beq.s	.Just_Save
	Move.w	d5,d4
	And.w	#$ff,d4
	Add.w	d4,d4
	Lea	Alien_Sine,a6
	Move.w	(a6,d4),d0
	Add.w	#$80,d4
	Move.w	(a6,d4),d1
	Add.w	d6,d6
	Muls	d6,d0
	Muls	d6,d1
	Asr.w	#1,d6
	Swap	d0
	Swap	d1
	Add.w	Bomb_Struct(a4),d0
	Add.w	Bomb_Struct+2(a4),d1
	Lea	Pre_Generated_Objects,a6
	Movem.w	d5-d7,-6(a2)
	Bsr	Quick_Enemy_Blit
	Bra.s	.Mini_Loop
.Just_Save
	Movem.w	d5-d7,-6(a2)
	Bra.s	.Mini_Loop
.Not_Active1
	Move.l	a0,Current_List_Pointer(a4)
	Rts
.Not_Active
	Clr.w	Bomb_Wobble(a4)
	Rts

.Kill_Bomb
	Clr.l	Bomb_Struct(a4)
	Sf	Bomb_Active(a4)
	Sf	Cant_Bomb+Pl1
	Sf	Cant_Bomb+Pl2
	Rts

Bomb_Explosion_Frames
	Dc.w	1,5,235,236,237,238,239
	Dc.w	1,3,244,245,246
	Dc.w	25,3,247,248,249
	Dc.w	1,3,246,245,244
	Dc.w	-1

Bomb_Mini_Explosion_Frames
	Dc.w	$00,50,0
	Dc.w	$20,40,1
	Dc.w	$30,30,2
	Dc.w	$40,60,3
	Dc.w	$50,50,4
	Dc.w	$60,60,0
	Dc.w	$80,50,1
	Dc.w	$90,30,2
	Dc.w	$a0,50,3
	Dc.w	$b0,20,4
	Dc.w	$c0,50,0
	Dc.w	$e0,60,2
	Dc.w	$8000

Bomb_Mini_Translation
	Dc.w	0,0,80,80,81,81,82,82,114,114,-1

Bomb_1_Col_Offsets
	Dc.w	64-16+1
	Dc.w	64-32+1
	Dc.w	64-52+1
	Dc.w	64-64+1
	Dc.w	128-80+1


**********************************************************
Move_Bomb
	Tst.w	Bomb_Struct(a4)
	Beq	.Exit				; Check x in structure, 0 nowt!
	Tst.b	Bomb_Active(a4)
	Bne	.Exit				; Only do if bomb active

	Lea	Bomb_Struct(a4),a0		; pointer to bomb strcuture
	Movem.w	(a0)+,d0-d2			; X/Y/ Sine value
	Lea	Alien_Sine(pc),a1		; Pointer to sine table
	Sub.w	(a0)+,d0
	Sub.w	(a0)+,d1			; Adjust X/Y
	Addq.w	#2,d2
	And.w	#$3f,d2				; Mask !
	Bne.s	.Bomb_Not_Hit_Floor
	St	Bomb_Active(a4)
	Clr.w	Bomb_Explosion_MaxAnimation_Number(a4)
	Clr.w	Bomb_Explosion_Animation_Number(a4)
	Clr.w	Bomb_Explosion_Repeatval(a4)
	Move.l	#Bomb_Explosion_Frames,Bomb_Explosion_Framepointer(a4)
	Move.l	#Bomb_Mini_Explosion_Frames,Mini_Bomb_Explosion_Pointer(a4)
	Sf	Bomb_Up_Del(a4)
	Rts
.Bomb_Not_Hit_Floor
	Move.w	d2,-6(a0)			; Save sine value !
	Add.w	d2,d2
	Move.w	(a1,d2),d2			; Sine value into d2 !
	Move.w	d2,d3				; Save in d3
	Mulu	#6,d3
	Swap	d3				; Anim in d3
	Move.b	Bomb_Flip(a4),d4		; Bomb flip Flag
	And.w	#3,d4				; Get 0-2
	Add.w	d4,d3				; Add it to base sprite
	Move.b	.Bomb_Anms(pc,d3),d3		; Collect the appropriate sprite
	Move.w	d3,Bomb_Drop_Frame_Number(a4)
	Mulu	#42,d2				; upto -42!
	Add.l	d2,d2
	Swap	d2
	Neg.w	d2				; Negate
	Move.w	d2,-2(a0)			; Save Y offset value
	Add.w	d2,d1				; Get normal Y
	Movem.w	d0-d1,-10(a0)			; Save x/y
.Exit	Rts

.Bomb_Anms
	Dc.b	51,52,53
	Dc.b	54,82,83

**********************************************************
Can_I_Let_It_Loose
	Tst.b	No_Firing_Bombing_Or_Pausing(a4)
	Beq.s	.Ok_I_Do
	Rts
.Ok_I_Do
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
	
.Do	Move.l	a3,Player_Use(a4)
	Lea	Shots_To_Do(a3),a2	; Table of stuff for weapons
	Tst.b	Death_Sequence(a3)
	Beq.s	.Normal_Fire
	Tst.b	Spit_Out_Flag(a3)
	Bne.s	.Do_Spit
	Rts	
.Do_Spit
	Sf	Spit_Out_Flag(a3)
	Lea	Spit_Out_Table_Red(pc),a0
	Cmp.l	#Pl1,a3
	Beq.s	.Spit_Loop
	Lea	Spit_Out_Table_Blue(pc),a0
.Spit_Loop
	Tst.b	(a0)
	Bmi.s	.Done_spitting
	Bsr	Search_Shot_Table		; Search in table
	Pea	Wep_End(a2)
	St	Is_Weapon_A_Rocket(a2)
	St	Is_Weapon_A_Homing_Missle(a2)
	Move.b	(a0)+,(a2)+			; Damage
	Addq.l	#1,a0				; Skip null byte
	Clr.b	(a2)+
	Clr.w	(a2)+				; Clear this word, cant remember what it does
	Movem.w	Shipxy(a3),d0-d1
	Add.w	X_Offset_Into_Map(a4),d0
	Add.w	#16,d0
	Add.w	#16,d1
	Move.w	d0,(a2)+	
	Move.w	d1,(a2)+	
	Move.w	(a0)+,(a2)			; Move rest of shit
	Move.w	(a2),d3
	Move.b	Spit_Out_Rotation(a3),d4
	Add.b	d4,d3
	Move.w	d3,(a2)+
	Move.w	(a0)+,(a2)+			; Move rest of shit
	Move.l	(a0)+,(a2)+
	Move.l	(sp)+,a2
	Move.w	(a0)+,Wep_Explosion_Num-Wep_End(a2)
	Bra.s	.Spit_loop
.Done_spitting
	Rts

.Normal_Fire
	Bsr	Do_A_Stream
	Tst.b	No_Move(a3)		; Can you move ?
	Beq.s	.Yes
	Clr.l	Draw_X_Speed(a3)
	Clr.l	X_Speed(a3)		; Clear speed if not!
	Rts	
.Yes	Tst_Act
	Tst_Startup			; Test if active or startup
	Tst.b	No_Firing(a4)		; Can u Fire ?
	Beq.s	.Oktf
	Rts	
.Oktf	Tst.b	Repeat_Delay_Set(a3)
	Beq.s	.No_Set1
	Tst.b	Button_Held_Down(a3)
	Bne.s	.No_Set1
	Sf	Repeat_Delay_Set(a3)
	Sub.b	#20,Fire_delay(a3)		; 2 From Fire delay
	Scc	d0				; Clear this reg if carry generated
	And.b	d0,Fire_Delay(a3)		; Mask delay
.No_Set1
	Tst.b	Repeat_Delay_Set1(a3)
	Beq.s	.No_Set2
	Tst.b	Button_Held_Down(a3)
	Bne.s	.No_Set2
	Sf	Repeat_Delay_Set1(a3)
	Sub.b	#20,Fire_delay2(a3)		; 2 From Fire delay
	Scc	d0				; Clear this reg if carry generated
	And.b	d0,Fire_Delay2(a3)		; Mask delay
.No_Set2
	Subq.b	#2,Fire_delay(a3)		; 2 From Fire delay
	Scc	d0				; Clear this reg if carry generated
	And.b	d0,Fire_Delay(a3)		; Mask delay
	Subq.b	#2,Fire_Delay2(a3)
	Scc	d0				; Same for secondry weapon
	And.b	d0,Fire_Delay2(a3)

	Tst.b	We_Have_Fired(a3)		; Have we pressed fire ?
	Beq.s	.Notfired			; No, Clear flag !
	Tst.b	Fire_Delay(a3)
	Bne.s	.Fire2				; Fire2 if no delay for 1!
	Tst.b	Button_Held_Down(a3)
	Beq.s	.No_Repeat
	Tst.b	Repeat_Delay_Set(a3)
	Bne.s	.No_Repeat
	St	Repeat_Delay_Set(a3)
	Add.b	#20,Fire_Delay(a3)
	Bra.s	.Fire2
.No_Repeat
	Sf	Repeat_Delay_Set(a3)
	Pea	.Fire2(pc)			; Else set return address!
	Pea	Process_Fire(pc)		; Come back on this !
	St	Flash_Mussle(a3)		; Flag to flash mussle round ship
	Tst.b	Weapon_In_Use(a3)		; Test weapon in use
	Beq.s	.Shot				; 0, its not that fackin blue ting
	Cmp.b	#2,Weapon_In_Use(a3)		; Spitting out bolts ?
	Beq.s	.Notfired			; Yes !
.Shot	Lea	Shot_Sfx,a6			; Play SHOT SFX
	Bsr	Play_This_Sample
.Notfired
	Clr.b	We_Have_Fired(a3)			
	Rts	

.Fire2	Tst.b	Secondry_Weapon(a3)
	Bmi.s	.NotFired			; Secondry weapon not active (-1)
	Tst.b	Fire_Delay2(a3)			; Delay must be zero !
	Bne.s	.NotFired				
	Tst.b	Button_Held_Down(a3)
	Beq.s	.No_Repeat2
	Tst.b	Repeat_Delay_Set1(a3)
	Bne.s	.No_Repeat2
	St	Repeat_Delay_Set1(a3)
	Add.b	#20,Fire_Delay2(a3)
	Bra.s	.NotFired
.No_Repeat2
	Sf	Repeat_Delay_Set1(a3)
	Move.b	Weapon_In_Use(a3),-(sp)
	Move.b	Weapon_Power(a3),-(sp)		; Save primary weapon variables
	Move.b	Secondry_Weapon(a3),Weapon_In_Use(a3)	
	Addq.b	#2,Weapon_In_Use(a3)	; Save secondry weapon and add 3
	Move.b	Weapon_Power2(a3),Weapon_Power(a3) ; New weapon power
	Bsr.s	Process_Fire		; Fire it
	Move.b	(sp)+,Weapon_Power(a3)
	Move.b	(sp)+,Weapon_In_Use(a3)		; Restore primary variables
	Bra	.NotFired				

Process_Fire
	Moveq	#0,d2
	Moveq	#0,d3
	Move.b	Weapon_In_Use(a3),d2			
	Move.b	Weapon_Power(a3),d3		; Collect weaopon in use/Powrr
	Lea	Weapon_Jump_Table(pc),a0	; Jump to approprtiate routine
	Add.w	d2,d2
	Jmp	(a0,d2)

;	Pea	(a0,d2)
;	Asr.w	#1,d2
;	Rts


Spit_Out_Table_Red
	Wep_Ent	5,$c0,12,22,0,0,0,8	; Angle/Scale value ! / Animation frames
	Wep_Ent	5,$f0,12,22,0,0,0,8
	Wep_Ent	5,$30,12,22,0,0,0,8
	Wep_Ent	5,$a0,12,22,0,0,0,8
	Wep_Ent	5,$80,12,22,0,0,0,8
	Wep_Ent	5,$50,12,22,0,0,0,8
	Dc.b	-1
	even
Spit_Out_Table_Blue
	Wep_Ent	5,$c0,12,23,0,0,0,8	; Angle/Scale value ! / Animation frames
	Wep_Ent	5,$f0,12,23,0,0,0,8
	Wep_Ent	5,$30,12,23,0,0,0,8
	Wep_Ent	5,$a0,12,23,0,0,0,8
	Wep_Ent	5,$80,12,23,0,0,0,8
	Wep_Ent	5,$50,12,23,0,0,0,8
	Dc.b	-1
	even




**********************************************************
Search_Shot_Table
	Tst.b	(a2)			
	Beq.s	.Weapon_Slot_Free
	Lea	Wep_End(a2),a2
	Bra.s	Search_Shot_Table
.Weapon_Slot_Free
	Rts
**********************************************************
Do_Fir3	Move.w	(a0)+,d6			; This is the maximum number of missles that can be on the screen at one time
	Move.w	(a0)+,d5			; This is the number of missles to insert
	St	Weapon_Is_A_Homing(a4)
	Sf	Weapon_Is_A_Rocket(a4)
	Move.b	Num_Homes(a3),d4		; Current number of homing missles
	Add.b	d5,d4				; Added to the number of missles to insert (total missle count)
	Cmp.b	d6,d4				; If total missle count <= to max number, ok !
	Ble.s	.Nx
	Rts
.Nx	Add.b	d5,Num_Homes(a3)		; Add this value to number of homes
	Move.w	(a0)+,d6
	Move.b	d6,Fire_Delay2(a3)		; Set fire delay
	Bra.s	SkipF				; Fireit
Do_Fir2	
	Sf	Weapon_Is_A_Homing(a4)
	St	Weapon_Is_A_Rocket(a4)
	Move.w	(a0)+,d6
	Move.b	d6,Fire_Delay2(a3)		; Set fire delay for rocket
	Move.w	X_Offset_Into_Map(a4),d6		; Offset into game area
	Addq.w	#8,d6				; Add 8 to align
	Bra.s	SkipF2
Do_Fir1	Move.w	(a0)+,d6
	Move.b	d6,Fire_Delay(a3)		; Set fire delay
	Sf	Weapon_Is_A_Homing(a4)
	Sf	Weapon_Is_A_Rocket(a4)

Skipf	
	Move.w	X_Offset_Into_Map(a4),d6		; Offset into game area
	Add.w	#12,d6				; Add 8 to align
Skipf2
	Cmp.b	#1,Weapon_In_Use(a3)
	Bne.s	.Loop
	Tst.b	Stream_Done(a3)
	Bne.s	.Exit
	Move.l	(a0),Stream_Pointer(a3)
	St	Stream_Done(a3)
	Bra.s	Do_A_Stream

.Loop	Tst.w	(a0)				; Script for missles to be fired,-1= no more
	Bmi.s	.Exit
	Bsr	Search_Shot_Table		; Search in table
	Pea	Wep_End(a2)
	Move.b	Weapon_Is_A_Rocket(a4),Is_Weapon_A_Rocket(a2)
	Move.b	Weapon_Is_A_Homing(a4),Is_Weapon_A_Homing_Missle(a2)
	Move.b	(a0)+,(a2)+			; Damage
	Addq.l	#1,a0				; Skip null byte
	Clr.b	(a2)+
	Clr.w	(a2)+				; Clear this word, cant remember what it does
	Move.l	Shipxy(a3),(a2)+		; Save x/y cardinate
	Add.w	d6,-4(a2)			; Add to x coard
	Addq.w	#2,-2(a2)			; Add to y coard
	Tst.b	Weapon_In_Use(a3)
	Bne.s	.Not_Splatter			; Dont process if not splatter
	Cmp.b	#1,Weapon_Power(a3)
	Bne.s	.Not_Splatter
	Not.b	Splatter_Flag(a3)		; Double shot if power up 2
	Bne.s	.Add
	Subq.w	#8,-4(a2)
.Add	Addq.w	#4,-4(a2)
.Not_Splatter	
	Move.l	(a0)+,(a2)+
	Move.l	(a0)+,(a2)+			; Move rest of shit
	Move.l	(sp)+,a2
	Move.w	(a0)+,Wep_Explosion_Num-Wep_End(a2)
	Bra.s	.Loop
.Exit	Rts
	
**********************************************************
Do_A_Stream
	Tst.b	Stream_Done(a3)
	Beq.s	.Exit
	Move.l	Stream_Pointer(a3),a0
	Tst.b	(a0)
	Spl	Stream_Done(a3)
	Bmi.s	.Exit
	St	Flash_Mussle(a3)		; Flag to flash mussle round ship
	Bsr	Search_Shot_Table		; Search in table
	Pea	Wep_End(a2)
	Clr.b	Is_Weapon_A_Rocket(a2)
	Clr.b	Is_Weapon_A_Homing_Missle(a2)
	Move.b	(a0)+,(a2)+			; Damage
	Addq.l	#1,a0				; Skip null byte
	Clr.b	(a2)+
	Clr.w	(a2)+				; Clear this word, cant remember what it does
	Move.l	Shipxy(a3),(a2)+		; Save x/y cardinate
	Move.w	X_Offset_Into_Map(a4),d6		; Offset into game area
	Subq.w	#2,d6
	Add.w	d6,-4(a2)			; Add to x coard
	Add.w	#8,-2(a2)
	Move.w	Laser_Shift(a4),d6
	Subq.w	#2,-2(a2)			; Add to y coard
	Sub.w	d6,-2(a2)
	Move.l	(a0)+,(a2)+
	Move.l	(a0)+,(a2)+			; Move rest of shit
	Move.l	(sp)+,a2
	Move.w	(a0)+,Wep_Explosion_Num-Wep_End(a2)
	Move.l	a0,Stream_Pointer(a3)
	Sub.w	#11,Laser_Shift(a4)
	And.w	#$f,Laser_Shift(a4)
	Lea	Laser_Sfx,a6
	Bsr	Play_This_Sample		; Play Lazer SFX
.Exit	Rts

**********************************************************
Dead_Count_Dec
	Tst.b	Pause_Flag(a4)
	Bne.s	.Exit				; Pause flag active, dont do
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Subq.b	#1,Dead_Count(a3)		; 1 from dead count
	Scc	d0	
	And.b	d0,Dead_Count(a3)		; Mask zero if carry was generated
.Exit	Rts

**********************************************************
Adj_Speed
	Tst.b	Pause_Flag(a4)
	Bne.s	.Xit			; Pause flag acvtive, cant move !
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Tst_Act
	Tst_Startup			; Test if active and startup
	Tst.b	No_Move(a3)
	Beq.s	.Can_Move
	Clr.l	Draw_X_Speed(a3)
	Clr.l	X_Speed(a3)		; Clear X vector/Y vector
.Xit	Rts	
.Can_Move
	Subq.b	#1,Move_Delay(a3)
	Bgt.s	.Xit
	Move.b	#2,Move_Delay(a3)
	Movem.w	XDirection(a3),d0-d1	; Get left/right/up/down movement flags
	Movem.w	X_Speed(a3),d2-d3	; Speeds into d2-d3
	Tst.w	d0			; if 0, lower the x vector
	Beq.s	.Subxit				
	Bpl.s	.Check_Posx
	Tst.w	d2
	Ble.s	.Vector_X
	Moveq	#0,d2
	Bra.s	.Vector_X
.Check_Posx
	Tst.w	d2
	Bge.s	.Vector_X
	Moveq	#0,d2
.Vector_X
	Add.w	d0,d2			; Else add direction to X vector	
.Ret1	Tst.w	d1			; if 0, lower the Y vector
	Beq.s	.Subyit				
	Bpl.s	.Check_Posy
	Tst.w	d3
	Ble.s	.Vector_Y
	Moveq	#0,d3
	Bra.s	.Vector_Y
.Check_Posy
	Tst.w	d3
	Bge.s	.Vector_Y
	Moveq	#0,d3
.Vector_Y
	Add.w	d1,d3			; Else add direction to y vector
.Ret2	
	Cmp.w	#-3,d2
	Bge.s	.Ok1
	Moveq	#-3,d2
.Ok1	Cmp.w	#3,d2
	Ble.s	.Ok2
	Moveq	#3,d2
.Ok2	Cmp.w	#-3,d3
	Bge.s	.Ok3
	Moveq	#-3,d3
.Ok3	Cmp.w	#3,d3
	Ble.s	.Ok4
	Moveq	#3,d3
.Ok4	Movem.w	d2-d3,X_Speed(a3)	; Save speeds
	Move.w	d2,d0
	Move.w	d3,d1
	Cmp.w	#-2,d0			; If >-2, Ok
	Bge.s	.Ok5
	Moveq	#-2,d0			; Else Fix it to -2
.Ok5	Cmp.w	#-2,d1
	Bge.s	.Ok6
	Moveq	#-2,d1
.Ok6	Cmp.w	#2,d0			; Do rest of checks for x/y vectors
	Ble.s	.Ok7
	Moveq	#2,d0
.Ok7	Cmp.w	#2,d1
	Ble.s	.Ok8
	Moveq	#2,d1
.Ok8	Movem.w	d0-d1,Draw_X_Speed(a3)	; resave the speed
	Rts

.Subyit	

;	Tst.w	d3			; Test Y vector
;	Beq.s	.Ret2			; If 0, no need to modify
;	Bpl.s	.Pos2
;	Addq.w	#2,d3			; Else bring it towards zero
;.Pos2	Subq.w	#1,d3
	Moveq	#0,d3
	Bra.s	.Ret2

.Subxit	

;	Tst.w	d2			; Test Y vector
;	Beq.s	.Ret1			; If 0, no need to modify	
;	Bpl.s	.Pos1
;	Addq.w	#2,d2			; Else bring it towards zero
;.Pos1	Subq.w	#1,d2
	Moveq	#0,d2
	Bra.s	.Ret1	


**********************************************************
Check_Fire_Button
	Tst.b	No_Firing(a4)
	Beq.s	.Ok_to_Fire
	Rts
.Ok_to_Fire
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
.Do	Tst_Act
	Tst_Startup				; Cant process if not active or starting up
	Tst.b	Button_Repeat(a3)
	Bne.s	.Repeating
	Tst.b	Fire_Pressed_On_read(a3)	; Test if fire button pressed
	Sne	Button_Repeat(a3)
	Sne	We_Have_Fired(a3)		; Set flag if it was pressed
	Clr.b	Fire_Pressed_On_Read(a3)	; Clear fire button pressed flag
	Sf	Button_Held_Down(a3)
	Rts

.Repeating
	Tst.b	Fire_Pressed_On_read(a3)	; Test if fire button pressed
	Sne	Button_Repeat(a3)
	Sne	We_Have_Fired(a3)
	St	Button_Held_Down(a3)
	Rts

**********************************************************
Check_ship_bound
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Tst.b	Num_Lives(a3)
	Bne.s	.Ok
	Rts
.Ok	Movem.w	Shipxy(a3),d0-d1
	Cmp.w	#12,d0
	Bge.s	.X_Not_Left_Bound
	Moveq	#12,d0
.X_Not_Left_Bound
	Move.w	#Playfield_Width-44,d5
	Add.w	Panel_X(a4),d5
	Cmp.w	d5,d0
	Ble.s	.X_Not_Right_Bound
	Move.w	d5,d0
.X_Not_Right_Bound
	Cmp.w	#8,d1
	Bge.s	.Y_Not_Up_Bound
	Moveq	#8,d1
.Y_Not_Up_Bound
;	Cmp.w	#Screen_Height-32,d1
	Move.w	Height_Of_Screen(a4),d2
	Sub.w	#32,d2
	Cmp.w	d2,d1
	Ble.s	.Y_Not_Dn_Bound
	Move.w	d2,d1
.Y_Not_Dn_Bound
	Movem.w	d0-d1,Shipxy(a3)	; Resave coardinates
.No_Check
	Rts

**********************************************************
Move_ship
	Tst.b	Pause_Flag(a4)
	Bne.s	.Exit
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Tst_Act
	Tst_Startup				
	Movem.w	X_speed(a3),d0-d1		
	Add.w	d0,ShipXY(a3)
	Add.w	d1,ShipXY+2(a3)	
.Exit	Rts

**********************************************************
Readjoysticks
	Jsr	ReadPAD			; read the JAG joypad
	Tst.b	Demo_Mode(a4)
	Bne.s	.Demo_Mode_On
	Tst.b	Entering_Hi_Score(a4)
	Bne.s	.No_Lives
	Tst.b	Num_Lives+Pl1
	Beq.s	.No_Lives
	Tst.w	Continue_Delay(a4)
	Bne.s	.No_Lives2
	Tst.b	Game_Over_Delay(a4)
	Bne.s	.No_Lives2
.Check1	Jsr	Hash_Asterisk_Pressed1
	Bne	Restart_Game
.No_Lives
	Tst.b	Entering_Hi_Score(a4)
	Bne.s	.No_Lives2
	Tst.b	Num_Lives+Pl2
	Beq.s	.No_Lives2
	Tst.w	Continue_Delay(a4)
	Bne.s	.No_Lives2
	Tst.b	Game_Over_Delay(a4)
	Bne.s	.No_Lives2
.Check2	Jsr	Hash_Asterisk_Pressed2
	Bne	Restart_Game
.No_Lives2
.Demo_Mode_On
	Clr.b	Reset_Delay(a4)
	Cmp.w	#256,Master_Intens(a4)
	Blt.s	.Check_Pause
	Clr.b	d6
	Clr.b	d7
	Tst.w	Panel_X(a4)
	Bne.s	.Check_Pause
	Tst.b	Player_Active+Pl1
	Beq.s	.No_Check_Player1
	Jsr	Pause_Pressed
	Sne	d6
.No_Check_Player1
	Tst.b	Player_Active+Pl2
	Beq.s	.No_Check_Player2
	Jsr	Pause_Pressed_2
	Sne	d7
.No_Check_Player2
	Or.b	d6,d7
	Beq.s	.No_Pause_Pressed
	Tst.b	Demo_Mode(a4)
	Bne.s	.Demo_Mode_On2
	Tst.b	Pause_Flag_Still_Pressed(a4)
	Bne.s	.Check_Pause
	Not.b	Pause_Flag(a4)
	Bne.s	.Stopstop
	Move.w	#$3f,d0
	Jsr	RESUMEDSP
.Stopstop
	Clr.w	Added_Sprites_To_List(a4)
	Clr.b	Music_On_Off
	Clr.b	SFX_On_Off
	St	Pause_Flag_Still_Pressed(a4)
	Bra.s	.Check_Pause
.Demo_Mode_On2
.No_Pause_Pressed
	Sf	Pause_Flag_Still_Pressed(a4)
.Check_Pause
	Tst.b	Pause_Flag(a4)
	Bne	.Game_Paused
	Bsr	Readjoy1
	Bsr	Readjoy2
.Game_Paused
	Rts
Readjoy1
	Lea	Pl1,a3
	Movem.w	Clearr(a4),d6-d7		; Clear work registers
	Sf	Fire_Pressed_On_Read(a3)
	Sf	Bomb_Pressed_On_Read(a3)	; Clear fire/bomb button flags
	
	Tst.b	Play_Through_The_Script(a4)
	Beq.s	.No_Script
	Move.l	Player_Script_Pointer(a4),a1
	Move.w	2(a1),d0
	Bmi	Out_Of_Demo_Attract
	And.w	#%100000,d0
	Sne	Fire_Pressed_On_Read(a3)	; Set this flag
	Bra.s	.Not_B
.No_Script

	Tst.b	Pause_Flag(a4)
	Bne	.Ok2				; Pause flag pressed, dont process
	Jsr	Fire_A_Pressed			; If ya pressed A
	Sne	Fire_Pressed_On_Read(a3)	; Set this flag
	Jsr	Fire_B_Pressed
	Beq.s	.Not_B
	St	Fire_Pressed_On_Read(a3)	; Same for fire button B
.Not_B	
	Ifne	Record
	Clr.w	Joysave
	Move.b	Fire_Pressed_On_Read(a3),Joysave+1
	And.w	#%100000,Joysave
	Endc


	Tst.b	Play_Through_The_Script(a4)
	Beq.s	.No_Script2
	Move.l	Player_Script_Pointer(a4),a1
	Move.w	2(a1),d0
	And.w	#%10000,d0
	Sne	Bomb_Pressed_On_Read(a3)	; Set if pressed	
	Bra.s	.Skip_Sk
.No_Script2
	Jsr	Fire_C_Pressed			; Fire button C used as a bomb button
	Sne	Bomb_Pressed_On_Read(a3)	; Set if pressed
.Skip_Sk


	Ifne	Record
	Move.b	Bomb_Pressed_On_Read(a3),d0
	And.w	#%10000,d0
	Or.w	d0,Joysave
	Endc

	Jsr	direction_pressed		; Get direction buttons

	Tst.b	Play_Through_The_Script(a4)
	Beq.s	.No_Script3
	Move.l	Player_Script_Pointer(a4),a1
	Move.w	2(a1),d0
	And.w	#%1111,d0
.No_Script3

	Ifne	Record
	And.w	#%1111,d0
	Or.w	d0,Joysave	
	Endc

	Btst	#2,d0
	Sne	d6
	Btst	#3,d0
	Beq.s	.Ok1
	Moveq	#1,d6
.Ok1	Btst	#0,d0				; d6/d7 corrosponds to x/y direction you pushed
	Sne	d7
	Btst	#1,d0
	Beq.s	.Ok2
	Moveq	#1,d7
.Ok2	Ext.w	d6
	Ext.w	d7				; Extend to 16 bits
	Movem.w	d6-d7,Xdirection(a3)		; Move in the 16bit flags
	Ifne	Record
	Move.l	Player_Script_Pointer(a4),a1
	Move.w	Joysave,d0
	Cmp.w	2(a1),d0
	Bne.s	.Change
	Addq.w	#1,(a1)
	Rts
.Change	Addq.l	#4,a1
	Move.w	#1,(a1)
	Move.w	d0,2(a1)
	Move.l	a1,Player_Script_Pointer(a4)
	Endc


	Tst.b	Play_Through_The_Script(a4)
	Beq.s	.No_Script4
	Move.l	Player_Script_Pointer(a4),a1
	Subq.w	#1,(a1)
	Bne.s	.No_Script4
	Addq.l	#4,Player_Script_Pointer(a4)
.No_Script4
	Rts

Readjoy2
	Lea	Pl2,a3
	Movem.w	Clearr(a4),d6-d7		; Clear work registers
	Sf	Fire_Pressed_On_Read(a3)
	Sf	Bomb_Pressed_On_Read(a3)	; Clear fire/bomb button flags

	Tst.b	Play_Through_The_Script(a4)
	Beq.s	.No_Script
	Move.l	Player_Script_Pointer+4(a4),a1
	Move.w	2(a1),d0
	And.w	#%100000,d0
	Sne	Fire_Pressed_On_Read(a3)	; Set this flag
	Bra.s	.Not_B
.No_Script
	Tst.b	Pause_Flag(a4)
	Bne	.Ok2				; Pause flag pressed, dont process
	Jsr	Fire_A_Pressed_2		; If ya pressed A
	Sne	Fire_Pressed_On_Read(a3)	; Set this flag
	Jsr	Fire_B_Pressed_2
	Beq.s	.Not_B
	St	Fire_Pressed_On_Read(a3)	; Same for fire button B
.Not_B	
	Ifne	Record
	Clr.w	Joysave
	Move.b	Fire_Pressed_On_Read(a3),Joysave+1
	And.w	#%100000,Joysave
	Endc

	Tst.b	Play_Through_The_Script(a4)
	Beq.s	.No_Script1
	Move.l	Player_Script_Pointer+4(a4),a1
	Move.w	2(a1),d0
	Bmi	Out_Of_Demo_Attract
	And.w	#%10000,d0
	Sne	Bomb_Pressed_On_Read(a3)	; Set if pressed	
	Bra.s	.Skip_Sk1
.No_Script1
	Jsr	Fire_C_Pressed_2		; Fire button C used as a bomb button
	Sne	Bomb_Pressed_On_Read(a3)	; Set if pressed
.Skip_Sk1

	Ifne	Record
	Move.b	Bomb_Pressed_On_Read(a3),d0
	And.w	#%10000,d0
	Or.w	d0,Joysave
	Endc


	Jsr	direction_pressed_2		; Get direction buttons

	Tst.b	Play_Through_The_Script(a4)
	Beq.s	.No_Script2
	Move.l	Player_Script_Pointer+4(a4),a1
	Move.w	2(a1),d0
	And.w	#%1111,d0
.No_Script2

	Ifne	Record
	And.w	#%1111,d0
	Or.w	d0,Joysave	
	Endc

	Btst	#2,d0
	Sne	d6
	Btst	#3,d0
	Beq.s	.Ok1
	Moveq	#1,d6
.Ok1	Btst	#0,d0				; d6/d7 corrosponds to x/y direction you pushed
	Sne	d7
	Btst	#1,d0
	Beq.s	.Ok2
	Moveq	#1,d7
.Ok2	Ext.w	d6
	Ext.w	d7				; Extend to 16 bits
	Movem.w	d6-d7,Xdirection(a3)		; Move in the 16bit flags
	Ifne	Record
	Move.l	Player_Script_Pointer+4(a4),a1
	Move.w	Joysave,d0
	Cmp.w	2(a1),d0
	Bne.s	.Change
	Addq.w	#1,(a1)
	Rts
.Change	Addq.l	#4,a1
	Move.w	#1,(a1)
	Move.w	d0,2(a1)
	Move.l	a1,Player_Script_Pointer+4(a4)
	Endc

	Tst.b	Play_Through_The_Script(a4)
	Beq.s	.No_Script3
	Move.l	Player_Script_Pointer+4(a4),a1
	Subq.w	#1,(a1)
	Bne.s	.No_Script3
	Addq.l	#4,Player_Script_Pointer+4(a4)
.No_Script3
	Rts

Joysave	Ds.w	1

Restart_Game
	Lea	Data,a4
;	Addq.b	#1,Reset_Delay(a4)
;	Cmp.b	#5,Reset_Delay(a4)
;	Bne.s	.No_Reset
	Jsr	Stop_Gpu
	Sf	Video_Flag
	Jsr	Setup_Object_Processor_To_Point_to_Stop
	Move.w	#$3f,d0
	Jsr	RESUMEDSP
	Jsr	Clear_Out_Data_Variables		; Clear em all !
	Jsr	Clear_Out_Player_Variables		; Clear all player variables
	Jsr	Stop_Mod
	Jsr	Get_Sound_Effect_Music_Vol_From_Eeprom
	Jsr	Set_SFXmusic_Volumes
	Clr.w	Cheat_Mode_Active
	Clr.b	Music_On(a4)
	Move.w	#$2100,sr
	Jmp	Re_Start
.No_Reset
	Rts

Out_Of_Demo_Attract
	Push
	Moveq	#25-1,d7
	Moveq	#25-1,d7
.Loop	Jsr	Wait_Main_Vbl
	Dbra	d7,.Loop
	Pull
	Jsr	Setup_Screens
	Lea	12(sp),sp
	Rts

**********************************************************
Draw_Shadow_For_Players
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
	
.Do	TST_ACT
	Tst.b	Death_sequence(a3)
	Bne.s	.No_Shadows
	Tst.b	Hover_Mode(a3)
	Bne.s	.No_Shadows
	Movem.w	Shipxy(a3),d0-d1
	Add.w	#20,d0
	Add.w	#20,d1
	Move.w	Draw_X_Speed(a3),d2
	Add.w	#216,d2
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5
	Lea	Pre_Generated_Player_Objects,a6
	Move.l	Current_List_Pointer(a4),a0
	Bsr	Quick_Player_Blit
	Move.l	a0,Current_List_Pointer(a4)
	Move.l	-8(a0),d0
	Bset	#14,d0
	Move.l	d0,-8(a0)
.No_Shadows
	Rts


**********************************************************
Draw_Ship
	Move.l	Current_List_Pointer(a4),a0
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
	Bsr.s	.Do
	Move.l	a0,Current_List_Pointer(a4)
	Rts

.Do	Tst_Act					; Not active, dont draw
	Move.l	a3,Player_Use(a4)
	Tst.b	Just_Dead(a3)
	Beq.s	.No_Initialize_Death_Sequence
	Clr.l	X_Speed(a3)
	St	Death_sequence(a3)
	Sf	Just_Dead(a3)
	St	Death_sequence(a3)
	St	No_Move(a3)		
	Move.w	#Player_Explosion_Delay,Ship_explosion_Dec(a3)
	Clr.w	Ship_Explosion_Num(a3)
	Lea	PlayerExplosion_Sfx,a6
	Bsr	Play_This_Sample
.No_Initialize_Death_Sequence
	Tst.b	Death_Sequence(a3)
	Bne	Player_Dying_Anim_Routine

	Tst.b	Dead_Count(a3)
	Beq.s	.Ok_Print			; Only draw if this is zero
	Subq.b	#1,Flash_Count(a3)		; Else decrement it
	Btst	#0,Flash_Count(a3)		; and flash on/off every 8loops
	Beq.s	.Ok_Print
	Rts
.Ok_Print	
	Bra	.No_Draw_Fire
.Print_Mussle
	Tst.b	Flash_Mussle(a3)
	Beq.s	.No_Mussle
	Clr.b	Flash_Mussle(a3)		; If we must draw the mussle, clear the flag
	Movem.w	Shipxy(a3),d0-d1
	Subq.w	#2,d1
	Lea	Wep_Shot_Mussle_Sprites(pc),a6
	Tst.b	Weapon_In_Use(a3)
	Beq.s	.Ok_Its_A_Normal_Shot_Mussle
	Lea	Wep_Laser_Mussle_Sprites(pc),a6
.Ok_Its_A_Normal_Shot_Mussle
	Moveq	#0,d3
	Move.b	Weapon_Power(a3),d3
	Add.w	d3,d3
	Move.w	(a6,d3),d2
	Move.l	Player_GFX_Base(a4),a5
	Pea	(a6)
	Lea	Shot_Offsets(pc),a6
	Move.w	Draw_X_Speed(a3),d4
	Addq.w	#2,d4
	Lsl.w	#2,d4
	Add.w	$0(a6,d4),d0
	Add.w	$2(a6,d4),d1
	Move.l	Player_Sprite_Base(a4),a3
	Lea	Pre_Generated_Player_Objects,a6
	Bsr	Quick_Player_Blit
	Move.l	(sp)+,a6
	Move.l	Player_Use(a4),a3
.No_Mussle
	Rts
.No_Draw_Fire
	Addq.w	#1,Anim_Toggle(a3)
	And.w	#$3,Anim_Toggle(a3)
	Cmp.b	#2,Transforming_Ship(a3)
	Beq	.No_Boost
	Tst.b	Hover_Mode(a3)
	Beq.s	.No_Hover
	Move.w	Anim_Toggle(a3),d2
	Lsr.w	#1,d2
	Move.w	Draw_X_Speed(a3),d4
	Addq.w	#2,d4
	Lea	Hover_Sprites(pc),a6
	Add.w	d4,d4
	Move.w	(a6,d4),d4
	Add.w	d4,d2
	Movem.w	Shipxy(a3),d0-d1
	Move.w	Draw_X_Speed(a3),d4
	Addq.w	#2,d4
	Lea	Hover_Adj(pc),a6
	Add.w	d4,d4
	Add.w	(a6,d4),d0
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5
	Addq.w	#2,d1

	Lea	Pre_Generated_Player_Objects,a6
	Bsr	Quick_Player_Blit
	Bra.s	.No_Boost
.No_Hover
	Movem.w	Shipxy(a3),d0-d1
	Move.w	Anim_Toggle(a3),d2
	Add.w	#98,d2
	Add.w	#22,d1
	Move.w	Draw_X_Speed(a3),d4
	Tst.b	Transforming_Ship(a3)
	Beq.s	.No_Transforming
	Clr.w	d4
.No_Transforming
	Addq.w	#2,d4
	Lsl.w	#2,d4
	Lea	Boost_Offsets(pc),a6
	Lea	(a6,d4),a6
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5
	Add.w	(a6)+,d0
	Movem.l	d0-d2/a3-a6,-(sp)
	Lea	Pre_Generated_Player_Objects,a6
	Bsr	Quick_Player_Blit
	Movem.l	(sp)+,d0-d2/a3-a6
	Add.w	(a6)+,d0
	Lea	Pre_Generated_Player_Objects,a6
	Bsr	Quick_Player_Blit
.No_Boost
	Move.l	Player_Use(a4),a3
	Bsr	.Print_Mussle
	Move.l	Player_Use(a4),a3
	Tst.b	Transforming_Ship(a3)
	Bne	.Transform
.Draw_Normal_Ship							; HOVER MODE HAS BEEN TAKEN OUT, ITS FUCKIN` SHITE
	Cmp.l	#Pl1,a3
	Beq.s	.Pl1_Sprites
.Pl2_Sprites
	Moveq	#124,d2
	Cmp.b	#4,Weapon_Power(a3)	; If weapon power >=2
	Bge.s	.Sprite_1b
	Cmp.b	#2,Weapon_Power2(a3)	; If weapon power >=2
	Blt.s	.Sprite_1a
.Sprite_1b
	Move.w	#129,d2
.Sprite_1a
	Movem.w	Shipxy(a3),d0-d1
	Addq.w	#2,d2
	Move.w	d2,Player_Sprite_To_Draw(a3)
	Add.w	Draw_X_Speed(a3),d2	
	Lea	Player_Sprite_X_Offsets(pc),a6
	Move.w	Draw_X_Speed(a3),d3
	Addq.w	#2,d3
	Add.w	d3,d3
	Move.w	(a6,d3),d3
	Add.w	d3,d0
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5
	Lea	Pre_Generated_Player_Objects,a6
	Bsr	Quick_Player_Blit
	Rts

.Pl1_Sprites
	Moveq	#0,d2
	Cmp.b	#4,Weapon_Power(a3)	; If weapon power >=2
	Bge.s	.Sprite1_Up
	Cmp.b	#2,Weapon_Power2(a3)	; If weapon power >=2
	Blt.s	.Sprite_1
.Sprite1_Up
	Move.w	#57,d2
.Sprite_1
	Movem.w	Shipxy(a3),d0-d1
	Addq.w	#2,d2
	Move.w	d2,Player_Sprite_To_Draw(a3)
	Add.w	Draw_X_Speed(a3),d2	
	Lea	Player_Sprite_X_Offsets(pc),a6
	Move.w	Draw_X_Speed(a3),d3
	Addq.w	#2,d3
	Add.w	d3,d3
	Move.w	(a6,d3),d3
	Add.w	d3,d0
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5

	Lea	Pre_Generated_Player_Objects,a6
	Bsr	Quick_Player_Blit

	Rts

.Transform
	Move.l	Player_Use(a4),a3
	Cmp.b	#1,Transforming_Ship(a3)
	Beq	.Transforming_From_Low_Power_To_High_Power

.Transforming_To_Hover
	Tst.b	Hover_Direction(a3)
	Beq.s	.ForwardAnim
	Lea	HOVER_Transform_Table_RED_LO_BACK(pc),a6
	Cmp.l	#Pl1,a3
	Beq.s	.Set_Playery
	Lea	HOVER_Transform_Table_BLUE_LO_BACK(pc),a6
.Set_Playery
	Cmp.b	#2,Weapon_Power2(a3)
	Bge.s	.Ok5
	Cmp.b	#4,Weapon_Power(a3)
	Blt.s	.Red_Player2
.Ok5	Lea	HOVER_Transform_Table_RED_HI_BACK(pc),a6
	Cmp.l	#Pl1,a3
	Beq.s	.Red_Player2
	Lea	HOVER_Transform_Table_BLUE_HI_BACK(pc),a6
	Bra.s	.Red_Player2
.ForwardAnim
	Lea	HOVER_Transform_Table_RED_LO(pc),a6
	Cmp.l	#Pl1,a3
	Beq.s	.Set_Player
	Lea	HOVER_Transform_Table_BLUE_LO(pc),a6
.Set_Player
	Cmp.b	#4,Weapon_Power(a3)
	Blt.s	.Red_Player2
	Lea	HOVER_Transform_Table_RED_HI(pc),a6
	Cmp.l	#Pl1,a3
	Beq.s	.Red_Player2
	Lea	HOVER_Transform_Table_BLUE_HI(pc),a6
.Red_Player2
	Move.w	Transform_Frame(a3),d0
	Add.w	d0,d0
	Move.w	(a6,d0),d2
	Bpl.s	.Still_Transforming_Hover	
	Tst.b	Hover_Direction(a3)
	Beq.s	.Up_Hover
	Sf	Hover_Mode(a3)
	Bra.s	.Transform_Complete
.Up_Hover
	St	Hover_Mode(a3)
	Bra.s	.Transform_Complete
.Still_Transforming_Hover	
	Movem.w	Shipxy(a3),d0-d1
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5
	Subq.w	#1,d2
	Lea	Pre_Generated_Player_Objects,a6
	Bsr	Quick_Player_Blit
	Bra.s	.Exit

.Transforming_From_Low_Power_To_High_Power
	Move.w	Transform_Frame(a3),d0
	Lea	PUP_Transform_Table_RED(pc),a6
	Cmp.l	#Pl1,a3
	Beq.s	.Red_Player
	Lea	PUP_Transform_Table_BLUE(pc),a6
.Red_Player
	Add.w	d0,d0
	Move.w	(a6,d0),d2
	Bmi.s	.Transform_Complete
	Movem.w	Shipxy(a3),d0-d1
	Move.l	Player_GFX_Base(a4),a5
	Subq.w	#1,d2
	Move.w	d2,Player_Sprite_To_Draw(a3)
	Move.l	Player_Sprite_Base(a4),a3
	Lea	Pre_Generated_Player_Objects,a6
	Bsr	Quick_Player_Blit
	Bra	.Exit
	Nop
.Exit	Move.l	Player_Use(a4),a3
	Subq.b	#1,Transform_Frame_Delay(a3)
	Bpl.s	.Exit2
	Move.b	#3,Transform_Frame_Delay(a3)
	Addq.w	#1,Transform_Frame(a3)
.Exit2	Rts

.Transform_Complete
	Move.w	-2(a6,d0),d2
	Movem.w	Shipxy(a3),d0-d1
	Move.l	Player_GFX_Base(a4),a5
	Subq.w	#1,d2
	Move.w	d2,Player_Sprite_To_Draw(a3)
	Move.l	Player_Sprite_Base(a4),a3
	Lea	Pre_Generated_Player_Objects,a6
	Bsr	Quick_Player_Blit
	Move.l	Player_Use(a4),a3
	Clr.b	Transforming_Ship(a3)
	Clr.w	Transform_Frame(a3)
	Clr.l	Draw_X_Speed(a3)
	Clr.l	X_Speed(a3)
	Move.b	#3,Transform_Frame_Delay(a3)
	Rts


PUP_Transform_Table_RED
	Dc.w	149,150,151,152,153,-1
PUP_Transform_Table_Blue
	Dc.w	135,136,137,138,139,-1

HOVER_Transform_Table_RED_LO
	Dc.w	158,159,160,161,-1
HOVER_Transform_Table_Blue_LO
	Dc.w	144,145,146,147,-1

HOVER_Transform_Table_RED_HI
	Dc.w	154,155,156,157,-1
HOVER_Transform_Table_BLUE_HI
	Dc.w	140,141,142,143,-1


HOVER_Transform_Table_RED_LO_BACK
	Dc.w	161,160,159,158,-1
HOVER_Transform_Table_Blue_LO_BACK
	Dc.w	147,146,145,144,-1

HOVER_Transform_Table_RED_HI_BACK
	Dc.w	157,156,155,154,-1
HOVER_Transform_Table_BLUE_HI_BACK
	Dc.w	143,142,141,140,-1

Shot_Offsets
	Dc.w	-2+4,0,-1+2,0,0,0,-1+2,0,-2+4,0

Boost_Offsets
	Dc.w	8+4,4
	Dc.w	6+5,7
	Dc.w	2+5+2-1,8-1+1+1
	Dc.w	1+6+5,4
	Dc.w	1+8+3,4

Player_Dying_Anim_Routine
	Move.w	Ship_Explosion_Num(a3),d0
	Add.w	d0,d0
	Move.w	.Ship_Dead_Anims(pc,d0),d2
	Bmi.s	.Death_Seq_Done
	Movem.w	Shipxy(a3),d0-d1
	Add.w	X_Offset_Into_Map(a4),d0
	Move.l	Enemy_Sprites_Base(a4),a3
	Move.l	Enemy_GFX_Base(a4),a5
	Move.l	a0,Current_List_Pointer(a4)
	Jsr	Blit_A_Sprite
	Move.l	Current_List_Pointer(a4),a0
	Move.l	Player_Use(a4),a3
	Subq.b	#1,Spit_Out_Delay(a3)
	Bpl.s	.No_Flag_For_Spit_Out
	Move.b	#5,Spit_Out_Delay(a3)
	Add.b	#23,Spit_Out_Rotation(a3)
	St	Spit_Out_Flag(a3)
.No_Flag_For_Spit_Out
	Subq.w	#1,Ship_explosion_Dec(a3)
	Bpl.s	.Done
	Move.w	#Player_Explosion_Delay,Ship_explosion_Dec(a3)
	Addq.w	#1,Ship_Explosion_Num(a3)
.Done	Rts
	
.Death_Seq_Done
	Tst.w	Cheat_Mode_Active
	Bne.s	.No_Sub_From_Lives
	Subq.b	#1,Num_Lives(a3)
	Beq.s	.Player_Is_Dead
.No_Sub_From_Lives
	Move.l	Score(a3),-(sp)
	Move.l	Live_Add(a3),-(sp)
	Bsr	Setup_Player
	Move.l	(sp)+,Live_Add(a3)
	Move.l	(sp)+,Score(a3)
	Rts

.Player_Is_Dead
	Sf	Player_Active(a3)
	Rts

.Ship_Dead_Anims
	Dc.w	174,175,176,83,84,85,-1

Wep_Shot_Mussle_Sprites
	Dc.w	102,102,103,103,103,104,104,104
Wep_Laser_Mussle_Sprites
	Dc.w	107,107,108,108,108,109,109,109

Player_Sprite_X_Offsets
	Dc.w	2,1,0,1,2
Hover_Adj
	Dc.w	+4,+2,0,-1,-1

Hover_Sprites
	Dc.w	196,198,200,202,204

**********************************************************
Wait_For_100
	Tst.b	Pause_Flag(a4)
	Bne.s	.Exit
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Tst.b	Startup(a3)		; If not starting up, dont do !
	Beq.s	.Exit
	Tst_Act				; Test if active
	Subq.w	#3,Shipxy+2(a3)		; 1 from y value of ship
	Cmp.w	#120+21,Shipxy+2(a3)	; Wait for this line (hmmm its not 100, not important ! dont fucking panic!)
	Sgt	Startup(a3)		; Still in startup if not equal
	Move.w	Prev_X_Offset_Into_Map(a4),d1
	Add.w	d1,Shipxy(a3)
.Exit	Rts

**********************************************************
Check_For_Pal_Ntsc
	Lea	Data,a4
	Move.w	$f14002.l,d0
	Btst	#4,d0
	Sne	Ntsc_Flag(a4)			; Set this flag if  ntsc !
	Beq.s	.Pal_Screen
	Move.w	#Ntsc_Height,Height_Of_Screen(a4)
	Rts	
.Pal_Screen
	Move.w	#Pal_Height,Height_Of_Screen(a4)
	Rts

**********************************************************
Weapon_Jump_Table
	Bra.s	.Twin_Shot
	Bra.s	.Big_Fuck_Off_Blaster
	Bra.s	.Sidewinder
	Bra.s	.Homing_Missle

.Sidewinder
	Lea	.Sw(pc),a0
	Asl.w	#3,d3
	Jmp	(a0,d3)
.Homing_Missle
	Lea	.Hm(pc),a0
	Asl.w	#3,d3
	Jmp	(a0,d3)
.Big_Fuck_Off_Blaster
	Lea	.Bl(pC),a0
	Asl.w	#3,d3
	Jmp	(a0,d3)			; Jump to appropriate routine for power-up value
.Twin_Shot
	Lea	.Ts(pc),a0
	Asl.w	#3,d3
	Jmp	(a0,d3)

.Ts	Lea	.Tst1(pc),a0
	Bra	Do_Fir1
	Lea	.Tst2(pc),a0
	Bra	Do_Fir1
	Lea	.Tst3(pc),a0
	Bra	Do_Fir1
	Lea	.Tst4(pc),a0
	Bra	Do_Fir1
	Lea	.Tst5(pc),a0
	Bra	Do_Fir1
	Lea	.Tst6(pc),a0
	Bra	Do_Fir1
	Lea	.Tst7(pc),a0
	Bra	Do_Fir1
	Lea	.Tst8(pc),a0
	Bra	Do_Fir1
.Bl	Lea	.Blt1(pc),a0
	Bra	Do_Fir1
	Lea	.Blt2(pc),a0
	Bra	Do_Fir1
	Lea	.Blt3(pc),a0
	Bra	Do_Fir1
	Lea	.Blt4(pc),a0
	Bra	Do_Fir1
	Lea	.Blt5(pc),a0
	Bra	Do_Fir1
	Lea	.Blt6(pc),a0
	Bra	Do_Fir1
	Lea	.Blt7(pc),a0
	Bra	Do_Fir1
	Lea	.Blt8(pc),a0
	Bra	Do_Fir1
.Sw	Lea	.Swt1(pc),a0
	Bra	Do_Fir2
	Lea	.Swt2(pc),a0
	Bra	Do_Fir2
	Lea	.Swt3(pc),a0
	Bra	Do_Fir2
	Lea	.Swt4(pc),a0
	Bra	Do_Fir2
	Lea	.Swt5(pc),a0
	Bra	Do_Fir2
.Hm	Lea	.Hmt1(pc),a0
	Bra	Do_Fir3
	Lea	.Hmt2(pc),a0
	Bra	Do_Fir3
	Lea	.Hmt3(pc),a0
	Bra	Do_Fir3
	Lea	.Hmt4(pc),a0
	Bra	Do_Fir3
	Lea	.Hmt5(pc),a0
	Bra	Do_Fir3

.Tst1	Dc.w	09				; DELAY
	Wep_Ent	2,0,-11,0,0,0,0,4		Damage,x modifier,y modifier, anim number
	Dc.w	-1
.Tst2	Dc.w	09
	Wep_Ent	2,0,-11,0,0,0,0,4
	Wep_Ent	1,0,-11,0,0,0,0,4
	Dc.w	-1
.Tst3	Dc.w	10
	Wep_Ent	1,0,-11,0,0,0,0,4
	Wep_Ent	2,-3,-10,1,0,0,0,4
	Wep_Ent	1,+3,-10,2,0,0,0,4
	Dc.w	-1
.Tst4	Dc.w	11
	Wep_Ent	2,+0,-11,4,0,0,0,4
	Wep_Ent	2,-3,-10,3,0,0,0,4
	Wep_Ent	2,+3,-10,5,0,0,0,4
	Dc.w	-1
.Tst5	Dc.w	11
	Wep_Ent	1,0,-11,0,0,0,0,4
	Wep_Ent	1,-3,-10,1,0,0,0,4
	Wep_Ent	1,+3,-10,2,0,0,0,4
	Wep_Ent	1,-5,-08,6,0,0,0,4
	Wep_Ent	1,+5,-08,25,0,0,0,4
	Dc.w	-1
.Tst6	Dc.w	12
	Wep_Ent	2,+0,-11,4,0,0,0,4
	Wep_Ent	2,-3,-10,3,0,0,0,4
	Wep_Ent	2,+3,-10,5,0,0,0,4
	Wep_Ent	2,-5,-08,26,0,0,0,4
	Wep_Ent	2,+5,-08,27,0,0,0,4
	Dc.w	-1
.Tst7	Dc.w	12
	Wep_Ent	2,+0,-11,30,0,0,0,4
	Wep_Ent	3,-3,-10,29,0,0,0,4
	Wep_Ent	2,+3,-10,31,0,0,0,4
	Wep_Ent	3,-5,-08,28,0,0,0,4
	Wep_Ent	2,+5,-08,32,0,0,0,4
	Dc.w	-1
.Tst8	Dc.w	13
	Wep_Ent	1,+0,-11,30,0,0,0,4
	Wep_Ent	2,-3,-10,29,0,0,0,4
	Wep_Ent	3,+3,-10,31,0,0,0,4
	Wep_Ent	2,-5,-08,28,0,0,0,4
	Wep_Ent	3,+5,-08,32,0,0,0,4
	Wep_Ent	2,-7,-07,33,0,0,0,4
	Wep_Ent	1,+7,-07,34,0,0,0,4
	Dc.w	-1

.Swt1	Dc.w	35			; Delay for fire !
	Wep_Ent	2,-1,-1,12,0,12,10,6	; Damage/x modifier/y mod/Anmset/Sine val/Scale/Speed
	Wep_Ent	2,+1,-1,12,0,12,10,6
	Dc.w	-1
.Swt2	Dc.w	35
	Wep_Ent	1,-1,-1,12,0,12,10,6
	Wep_Ent	2,+1,-1,12,0,12,10,6
	Wep_Ent	1,+0,-1,12,0,12,10,6
	Dc.w	-1
.Swt3	Dc.w	35
	Wep_Ent	2,-2,-1,13,0,14,10,6	; Damage/x modifier/y mod/Anmset/Sine val/Scale/Speed
	Wep_Ent	1,+2,-1,13,0,14,10,6
	Wep_Ent	1,-1,-1,13,0,12,10,6
	Wep_Ent	2,+1,-1,13,0,12,10,6
	Dc.w	-1
.Swt4	Dc.w	17
	Wep_Ent	1,-2,-1,14,0,18,10,6	; Damage/x modifier/y mod/Anmset/Sine val/Scale/Speed
	Wep_Ent	2,+2,-1,14,0,18,10,6
	Wep_Ent	1,-1,-1,14,0,15,10,6
	Wep_Ent	2,+1,-1,14,0,15,10,6
	Dc.w	-1
.Swt5	Dc.w	17
	Wep_Ent	2,-2,-1,15,0,18,10,6	; Damage/x modifier/y mod/Anmset/Sine val/Scale/Speed
	Wep_Ent	2,+2,-1,15,0,18,10,6
	Wep_Ent	2,-1,-1,15,0,15,10,6
	Wep_Ent	2,+1,-1,15,0,15,10,6
	Dc.w	-1


.Hmt1	Dc.w	2			; Number of homes !
	Dc.w	2
	Dc.w	30
	Wep_Ent	1,$e0,11,17,0,0,0,7	
	Wep_Ent	2,$20,11,17,0,0,0,7
	Dc.w	-1
.Hmt2	Dc.w	4			; Number of homes !
	Dc.w	4
	Dc.w	30
	Wep_Ent	1,$c0,11,18,0,0,0,7	; Angle/Scale value !
	Wep_Ent	2,$f0,11,18,0,0,0,7
	Wep_Ent	1,$10,11,18,0,0,0,7
	Wep_Ent	2,$40,11,18,0,0,0,7
	Dc.w	-1
.Hmt3	Dc.w	6
	Dc.w	4
	Dc.w	40
	Wep_Ent	2,$c0,12,19,0,0,0,7	; Angle/Scale value !
	Wep_Ent	2,$f0,12,19,0,0,0,7
	Wep_Ent	2,$10,12,19,0,0,0,7
	Wep_Ent	2,$40,12,19,0,0,0,7
	Dc.w	-1
.Hmt4	Dc.w	8
	Dc.w	4
	Dc.w	25
	Wep_Ent	2,$c0,13,20,0,0,0,7	; Angle/Scale value !
	Wep_Ent	3,$f0,13,20,0,0,0,7
	Wep_Ent	2,$10,13,20,0,0,0,7
	Wep_Ent	3,$40,13,20,0,0,0,7
	Dc.w	-1
.Hmt5	Dc.w	8
	Dc.w	4
	Dc.w	50
	Wep_Ent	3,$c0,13,21,0,0,0,7	; Angle/Scale value !
	Wep_Ent	3,$f0,13,21,0,0,0,7
	Wep_Ent	3,$10,13,21,0,0,0,7
	Wep_Ent	3,$40,13,21,0,0,0,7
	Dc.w	-1

.Blt1	Dc.w	10
	Dc.l	.Blue_Stream_1

.Blt2	Dc.w	11
	Dc.l	.Blue_Stream_2

.Blt3	Dc.w	10
	Dc.l	.Blue_Stream_3

.Blt4	Dc.w	10
	Dc.l	.Blue_Stream_4

.Blt5	Dc.w	10
	Dc.l	.Blue_Stream_5

.Blt6	Dc.w	10
	Dc.l	.Blue_Stream_6

.Blt7	Dc.w	10
	Dc.l	.Blue_Stream_7

.Blt8	Dc.w	9
	Dc.l	.Blue_Stream_8


.Blue_Stream_1
	Wep_Ent	1,0,-11,7,0,0,0,5
	Wep_Ent	2,0,-11,7,0,0,0,5
	Dc.w	-1

.Blue_Stream_2
	Wep_Ent	1,0,-11,7,0,0,0,5
	Wep_Ent	1,0,-11,7,0,0,0,5
	Wep_Ent	2,0,-11,7,0,0,0,5
	Wep_Ent	1,0,-11,7,0,0,0,5
	Dc.w	-1

.Blue_Stream_3
	Wep_Ent	1,0,-11,08,0,0,0,5
	Wep_Ent	1,0,-11,08,0,0,0,5
	Wep_Ent	1,0,-11,08,0,0,0,5
	Wep_Ent	1,0,-11,08,0,0,0,5
	Wep_Ent	1,0,-11,08,0,0,0,5
	Dc.w	-1


.Blue_Stream_4
	Wep_Ent	2,0,-11,09,0,0,0,5
	Wep_Ent	1,0,-11,09,0,0,0,5
	Wep_Ent	1,0,-11,08,0,0,0,5
	Wep_Ent	1,0,-11,08,0,0,0,5
	Wep_Ent	1,0,-11,08,0,0,0,5
	Dc.w	-1

.Blue_Stream_5
	Wep_Ent	2,0,-11,09,0,0,0,5
	Wep_Ent	2,0,-11,09,0,0,0,5
	Wep_Ent	1,0,-11,09,0,0,0,5
	Wep_Ent	1,0,-11,09,0,0,0,5
	Wep_Ent	1,0,-11,09,0,0,0,5
	Dc.w	-1

.Blue_Stream_6
	Wep_Ent	1,0,-11,10,0,0,0,5
	Wep_Ent	1,0,-11,10,0,0,0,5
	Wep_Ent	1,0,-11,09,0,0,0,5
	Wep_Ent	2,0,-11,09,0,0,0,5
	Wep_Ent	2,0,-11,09,0,0,0,5
	Dc.w	-1

.Blue_Stream_7
	Wep_Ent	2,0,-11,10,0,0,0,5
	Wep_Ent	1,0,-11,10,0,0,0,5
	Wep_Ent	1,0,-11,10,0,0,0,5
	Wep_Ent	2,0,-11,10,0,0,0,5
	Wep_Ent	1,0,-11,10,0,0,0,5
	Dc.w	-1

.Blue_Stream_8
	Wep_Ent	2,0,-11,11,0,0,0,5
;	Wep_Ent	1,0,-11,11,0,0,0,5
	Wep_Ent	1,0,-11,11,0,0,0,5
	Wep_Ent	2,0,-11,11,0,0,0,5
	Wep_Ent	2,0,-11,11,0,0,0,5
	Dc.w	-1

	Include	Dataz.S
		