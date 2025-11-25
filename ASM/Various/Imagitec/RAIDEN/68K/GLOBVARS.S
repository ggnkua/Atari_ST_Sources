	Rsreset
Map_Pointer		Rs.l	1
Map_Start_Address	Rs.l	1
Map_Start_Height	Rs.w	1
Map_Height		Rs.w	1
Map_Width		Rs.w	1
Map_Y_Offset		Rs.w	1
Base_Map_Element	Rs.l	1
Map_Line_Stack_Pointer	Rs.l	1

Map_Structure_End	Rs.w	0


	Rsreset
Object_PHRASE_BUFFER	Rs.b	32
Object_List1		Rs.b	16*(Max_Aliens+120)
Object_List2		Rs.b	16*(Max_Aliens+120)
Object_List_VBL_Buffer	Rs.b	16*(Max_Aliens+120)
Object_List_Pointer	Rs.l	3
Current_List_Pointer	Rs.l	1
Object_To_Link_TO	Rs.l	1
Added_Sprites_To_List	Rs.w	1
Num_Objects_To_Display	Rs.w	2
Player1_Start		Rs.b	1
Player2_Start		Rs.b	1

Continue_Mod_Address	Rs.l	1
Weapon_Num2		Rs.w	1
Weapon_Powersave2	Rs.w	1
Weapon_Num		Rs.w	1
Weapon_Powersave	Rs.w	1



Map_Offset_Variable	Rs.w	1
Player_Script_Pointer	Rs.l	2
O_Repeat		Rs.b	1
Music_On		Rs.b	1
Intro_Mod_Address	Rs.l	1
Height_Of_Screen	Rs.w	1
Ntsc_Flag			Rs.w	1

Var_Clear_Start		Rs.w	0
Rel_Base		Rs.l	1
Num_Spiders		Rs.w	1
Train_Links_Number	Rs.w	1
Iwidth			Rs.w	1
Dwidth			Rs.w	1
Base_Mod_Address	Rs.l	1
Address_For_Branch	Rs.l	1
Num_Maps_Loaded		Rs.w	1
Paralax_Data_Pointer	RS.l	1	
Paralax_Map_Number	Rs.w	1
Paralax_Event_Pointer	Rs.l	1
Pal_Number		Rs.w	1

Map_X_Left_Bound	Rs.w	1
Map_X_Right_Bound	Rs.w	1

Laser_Shift		Rs.w	1
Level_Map_Height	Rs.w	1		
Base_Map_Height		Rs.w	1
Stack_Save		Rs.l	1
Digit_Number		Rs.w	1
Digit_Entry_Number	Rs.w	1
Hi_Score_Number		Rs.w	1
Intro_Header_Address	Rs.l	1
Intro_Gfx_Address	Rs.l	1
Plate_Header_Address	Rs.l	1
Plate_Gfx_Address	Rs.l	1
Atari_Logo_Scale	Rs.w	1

			Rsset	(__RS+4)&$fffffffc
Quick_Mul		Rs.l	16
Sort_Counts		Rs.w	16
Gpu_Parameter_Start	Rs.l	1
Gpu_PAlign		Rs.l	1
Gpu_Parameters		Rs.l	20
Score_Board_Mem_Pointer	Rs.l	1
Num_Pixels		Rs.w	1
Num_Pixels2		Rs.w	1
Pal_Number2		Rs.w	1
Player_Gfx_Base		Rs.l	1
Special_Object_Bufferp	Rs.l	2
Special_Object_Pointer	Rs.l	1
			Rsset	(__RS+4)&$fffffffc
Aln_Activelist_Pointer	Rs.l	1
Map_Table		Rs.l	5
Map_Info		Rs.b	Map_Structure_End*5
Sr_Save			Rs.w	1		; Status register
Clearr			Rs.w	16		; Used for register clears
File_Len		Rs.l	1
Player_Use		Rs.l	1		; Which player to process (1 only for now!)
Seed			Rs.w	1		; Random number seed
Event_Base		Rs.l	1		; Event table start
Y_Off_For_Explosion	Rs.w	1		; Used for level 1 baddie
Crator_Tabp		Rs.l	1		; Pointer into crator insert table
Score_Bonus_Tablep	Rs.l	1
Power_Up_Posp		Rs.l	1
Alien_Sort_Pointer	Rs.l	1
Alien_Trackp		Rs.l	1
Explosion_Tabp 		Rs.l	1
Event_Tablep		Rs.l	1
Power_Up_Event_Table_Pointer	Rs.l	1
Bullets_Header_Base	Rs.l	1
Bullets_GFX_Base	Rs.l	1
Aliens_Insert_P		Rs.l	1
			Rsset	(__RS+4)&$fffffffc
Enemy_Sprites_Base	Rs.l	1
Gfxblocks_Base		Rs.l	1
Track_Shipxy		Rs.w	4		
Player_Sprite_Base	Rs.l	1
Enemy_GFX_Base		Rs.l	1
Lev3_Height_Save	Rs.w	4
Aln_X_Save		Rs.w	2
Aln_Sprite_Save		Rs.w	1
Intens			Rs.w	1
Master_Intens		Rs.w	1
Sprite_X_Save		Rs.w	1
Wash_Intensity		Rs.w	1
Wash_Mem_Pointer	Rs.l	1
Base_Of_Map_Elements	Rs.l	1
Bomb_Drop_Frame_Number	Rs.w	1
Bomb_Struct		Rs.w	5
Bomb_Explosion_Repeatval	Rs.w	1
Bomb_Explosion_Framepointer	Rs.l	1
Bomb_Explosion_MaxAnimation_Number	Rs.w	1
Bomb_Explosion_Animation_Number	Rs.w	1
Mini_Bomb_Explosion_Pointer	Rs.l	1
Bomb_Explosion_Sprite_Num	Rs.w	1
Bomb_Box			Rs.w	4
Base_Icon_X			Rs.w	0
Text_X_Save			Rs.w	1
Bomb_Y_Position			Rs.w	1
Bomb_Explo_Delay		Rs.w	1
Prev_X_Offset_Into_Map		Rs.w	1
Guardian_Delay		Rs.w	1
Num_Guardians_Active	Rs.w	1
Train_Links		Rs.l	3*3
Panel_X			Rs.w	1
Map_Display_Width	Rs.w	1
Gameover_Modaddress	Rs.l	1
Pow_Ins0		Rs.l	1
Pow_Ins1		Rs.l	1
Alien_List_Search_Pointer	Rs.l	1

X_Offset_Into_Map	Rs.w	1
Number_Of_Sprites_In_Activelist		Rs.w	1
Number_Of_Sprites_On_Screen		Rs.w	1
Continue_Delay		Rs.w	1
Right_Hand_Screenxbound	Rs.w	1

Screen_Location		Rs.l	1
Repeat_Screen_Location	Rs.l	1
Screen_Script_Pointer	Rs.l	1
Guardian_Mod_Address	Rs.l	1

Guardian_Music_On	Rs.b	1
Screen_Script_Repeat	Rs.b	1
This_Level		Rs.b	1
Both_Players_Active	Rs.b	1
Bomb_Kill_Count		Rs.b	1
No_More_Scrolling	Rs.b	1
Flag_To_Stop_Scrolling	Rs.b	1
Bomb_Flip		Rs.b	1
Flash_Pal		Rs.b	1
Direction_Of_Intens	Rs.b	1
End_Level		Rs.b	1
Vbl_Flag		Rs.b	1
Frame_Diff		Rs.b	1
Frame_Rate_To_Wait	Rs.b	1
Demo_Mode		Rs.b	1
No_Firing		Rs.b	1
No_Bombing		Rs.b	1
Fade_Direction		Rs.b	1
Old_Vbl_On_Vbl		Rs.b	1
Pause_Flag		Rs.b	1
Game_Over_Delay		Rs.b	1
This_Level_Bonus	Rs.b	1
Pause_Flag_Still_Pressed	Rs.b	1
Pause_Display_Del	Rs.b	1
Pause_Display_Flip	Rs.b	1
Track_Del		Rs.b	1
Num_Credits		Rs.b	1
Make_Event		Rs.b	1
Make_Event_Delay		Rs.b	1
Flip_Flag		Rs.b	1
List_Made		Rs.b	1
Bomb_Active		Rs.b	1
Plates_Displayed	Rs.b	1
Track_Player1or2	Rs.b	1
Reflect_Object_Flag	Rs.b	1
Mini_Bomb_Explosion_Del	Rs.b	1
Repeat_Direction	Rs.b	1
Fire_Repeat		Rs.b	1
Player_That_Bombed	Rs.b	1
Player_Icon_Print	Rs.b	1
Display_Game_Over_Or_Start_Delay	Rs.b	1
Display_Game_Over_Or_Start	Rs.b	1
Leading_Zero		Rs.b	1
Ship_Shadow		Rs.b	1
Weapon_Is_A_Homing	Rs.b	1
Weapon_Is_A_Rocket	Rs.b	1
Bomb_Up_Del		Rs.b	1
Number_Of_Powerups_On_Screen	Rs.b	1
Copy_The_Pallete	Rs.b	1
Both_Players_In_Place	Rs.b	1
Bonus_Sequence_Done	Rs.b	1
Bonus_Score_Dec		Rs.b	1
Bonus_Sequence_Dec	Rs.b	1
Initial_Bomb_Blast	Rs.b	1
Bonus_Sequence_Out_Delay	Rs.b	1
Exit_On_Vbl			Rs.b	1
Base_Map_Add_Flag		Rs.b	1
Delay_For_Player_fire		Rs.b	1
Delay_Set_For_Player_fire	Rs.b	1
Paralax_Active			Rs.b	1
Paralax_Scroll_PXL		Rs.b	1
Paralax_Event_Flag		Rs.b	1
Checking_A_Paralax_Event	Rs.b	1
Killed_Branch			Rs.b	1
No_Firing_Bombing_Or_Pausing	Rs.b	1
Options_Repeat			Rs.b	1
No_Player_Collisions		Rs.b	1
No_Printing_top_Map		Rs.b	1
Wash_Add			Rs.b	1
Panel_Light_Frame_Number	Rs.b	1
Play_Through_Script		Rs.b	0
Play_Through_The_Script		Rs.b	1
Interm_Mod_Delay		Rs.w	1
Flag_To_Kill_Interm_Mod		Rs.b	1
Reset_Delay			Rs.b	1
Completed_Raiden		Rs.b	1
Clouds_Active			Rs.b	1
Kill_Clouds_Active		Rs.b	1
No_More_Clouds			Rs.b	1
Up_Complete_Bonus		Rs.b	1
Bonus_Score_Init		Rs.b	1
Boost_Blocks_Up			Rs.b	1
Boost_Away			Rs.b	1
Boost_Type			Rs.b	1
Done_Carrier			Rs.b	1
Escape_Val			Rs.b	1
Doing_Carrier			Rs.b	1
Atmosphere			Rs.b	1
Boosters_On_Aanyway		Rs.b	1
Print_Top_Carrier_Map		Rs.b	1
Drag_Done			Rs.b	1
Stop_Cycle4			Rs.b	1
DSP_Halted			Rs.b	1
Panel_Offon			Rs.b	1
Bomb_Explosion_Off		RS.B	1
Times_Through			Rs.b	1
Player_Check_Even_odd		Rs.b	1
Loading_Stuff			RS.B	1
Atari_Logo_On_Vblank		Rs.b	1
Entering_Hi_Score		Rs.b	1
Red_player_Start		Rs.b	1
Delay_Char			Rs.b	1
Second_Delay			Rs.b	1
One_Player_Game			Rs.b	1
Flag_To_Ewrite_Music		Rs.b	1
Even_Odd_Missles		Rs.b	1
				Even

Carrier_Sequence_Base_Map	Rs.l	1
Launch_Blockset_Base		Rs.l	1
Launch_Map_Base			Rs.l	1
Cry_Screen_Base			Rs.l	1
Carrier_Event0			Rs.l	1
Carrier_Event1			Rs.l	1
Map_Line_Offset0		Rs.w	1
Map_Line_Offset1		Rs.w	1
Map_Len0			Rs.w	1
Map_Pointer0			Rs.l	1
Map_Len1			Rs.w	1
Map_Pointer1			Rs.l	1
Carrier_Event_Delay0		Rs.b	1
Carrier_Event_Delay1		Rs.b	1
Scroll_Rate0			Rs.b	1
Scroll_Rate1			Rs.b	1
Block_Line_Offset0		Rs.w	1
Block_Line_Offset1		Rs.w	1
Carrier_Seq_Number		Rs.w	1
Carrier_Sprites_Base		Rs.l	1
Carrier_GFX_Base		Rs.l	1
Destruct_Table			Rs.l	2
Y_Accum				Rs.w	1
Red_Shipxy			Rs.w	2
Blue_Shipxy			Rs.w	2
Option_Header_Base		Rs.l	1
Option_Gfx_Base			Rs.l	1
Alien_Hit_With			Rs.l	1
Name_Address			Rs.l	1
Difficuly			Rs.w	1
Home_Dirp			Rs.l	1
Unique_Fire			Rs.w	1
Bomb_Wobble			Rs.w	1
Alien_search_Count		RS.W	1
				Even

Score_Bonus_Table	Rs.w	10*4
Power_Up_Pos		Rs.w	10*5
Sort_Pad		Rs.l	2
Alien_Sort_Table	Rs.l	Max_Aliens*16
Aliens_Insert_T		Rs.w	3*Max_Aliens
Crator_Tab		Rs.l	Max_Aliens/2
Explosion_Tab		Rs.l	Max_Aliens/2
			Rsset	(__RS+4)&$fffffffc
Home_Dir		Rs.l	(Max_Homes*2)+2
			Rsset	(__RS+4)&$fffffffc
Aln_Activelist		Rs.l	Max_Aliens+1
			Rsset	(__RS+4)&$fffffffc
Weapon_Check_Table	Rs.l	Max_Aliens+1
			Rsset	(__RS+4)&$fffffffc
Player_Check_Table	Rs.l	Max_Aliens+1
			Rsset	(__RS+4)&$fffffffc
Draw_Check_Table	Rs.l	Max_Aliens+1
			Rsset	(__RS+8)&$fffffffc
GPU_Checked_Aliensp	Rs.l	2
GPU_Checked_Aliens	Rs.l	Max_Aliens+1
			Rsset	(__RS+8)&$fffffffc
Wep_Hit_Listp		Rs.l	2
Wep_Hit_List		Rs.l	(Max_Aliens*2)+1
			Rsset	(__RS+4)&$fffffffc
Alien_Table		Rs.b	Aln_End*Max_Aliens
Alien_Tablee		Rs.b	0

Varend			Rs.b	0


;-----------------------------------------	
	Rsreset
Live_Add		Rs.l	1
Player_Sprite_To_Draw	Rs.w	1
Draw_X_Speed		Rs.w	2
Stream_Pointer		Rs.l	1
Shipxy			Rs.w	2		
Bonus_Score		Rs.l	1
Bonus_Score_Ascii	Rs.l	1
X_Speed			Rs.w	1		
Y_Speed			Rs.w	1		
XDirection		Rs.w	1		
YDirection		Rs.w	1		
Ten_Point_Accumolate	Rs.w	1
Can_Continue		Rs.w	1

			Rsset	(__RS+4)&$fffffffc
Shots_To_Do		Rs.b 	Wep_End*Max_weapons

			Rsset	(__RS+4)&$fffffffc
Weapon_Active_List	Rs.l 	Max_weapons
Ship_Explosion_Dec	Rs.w	1
Ship_Explosion_Num	Rs.w	1
Anim_Toggle		Rs.w	1
Transform_Frame		Rs.w	1
Score			Rs.b	4		
Startup			Rs.b	1		
Transform_Frame_Delay	Rs.b	1
Num_Lives		Rs.b	1		
Num_Bombs		Rs.b	1		
Player_Active		Rs.b	1		
Dead_Count		Rs.b	1		
Transforming_Ship	Rs.b	1
We_Have_Fired		Rs.b	1		
Fire_Delay		Rs.b	1		
Fire_Delay2		Rs.b	1		
Button_Repeat		Rs.b	1
Weapon_In_Use		Rs.b	1		
Weapon_Power		Rs.b	1		
Secondry_Weapon 	Rs.b	1
Weapon_Power2		Rs.b	1		
No_Move			Rs.b	1		
Just_Dead		Rs.b	1
Hover_Mode		Rs.b	1
Cant_Bomb		Rs.b	1
Medals_Got		Rs.b	1
Fire_Pressed_On_Read	Rs.b	1
Flash_Count		Rs.b	1
Flash_Mussle		Rs.b	1
Num_Homes		Rs.b	1
Bomb_Pressed_On_Read	Rs.b	1
Death_Sequence		Rs.b	1
Spit_Out_Flag		Rs.b	1
Spit_Out_Delay		Rs.b	1
Spit_Out_Rotation	Rs.b	1
Joybutton_Kept_Down	Rs.b	1
Repeat_Delay_Set	Rs.b	1
Repeat_Delay_Set1	Rs.b	1
Button_Held_Down	Rs.b	1
Level_Reached		Rs.b	1
Stage_Reached		Rs.b	1
Stream_Done		Rs.b	1
Hover_Direction		Rs.b	1
Splatter_Flag		Rs.b	1
Pups_Got		Rs.b	1
Num_Creds		Rs.b	1
Move_Delay		Rs.b	1
Even_Odd_Weapon_Check	Rs.b	1
One_Three_Repeat	Rs.b	1
PVarend			Rs.b	0
